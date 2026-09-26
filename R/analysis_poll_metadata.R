analysis_poll_facts <- function(polls) {
  purrr::map(polls$poll_id, function(poll_id) {
    path <- project_path("data", poll_id, "metadata.json")
    if (!file.exists(path)) return(tibble::tibble())
    facts <- jsonlite::fromJSON(path)$facts
    if (is.null(facts) || nrow(facts) == 0L) return(tibble::tibble())
    tibble::as_tibble(facts) |>
      dplyr::filter(
        status == "reported", field %in% c("location", "event_dates")
      ) |>
      dplyr::select(
        "poll_id", "field", "value", "reference_id", "source_locator"
      )
  }) |>
    purrr::list_rbind()
}

parse_event_dates <- function(value, registry_year) {
  iso <- "[0-9]{4}-[0-9]{2}-[0-9]{2}"
  start <- end <- as.Date(NA)
  month <- NA_integer_
  parsed_year <- NA_integer_
  if (grepl(paste0("^", iso, " through ", iso, "$"), value)) {
    dates <- regmatches(value, gregexpr(iso, value))[[1]]
    start <- as.Date(dates[[1]])
    end <- as.Date(dates[[2]])
  } else if (grepl(paste0("^", iso, "$"), value)) {
    start <- end <- as.Date(value)
  } else {
    months <- match(tolower(month.name), tolower(month.name))
    names(months) <- tolower(month.name)
    day_range <- regexec(
      "^([0-9]{1,2})[–-]([0-9]{1,2}) ([A-Za-z]+) ([0-9]{4})(?: .*)?$",
      value
    )
    match_range <- regmatches(value, day_range)[[1]]
    day_single <- regexec(
      "^([0-9]{1,2}) ([A-Za-z]+) ([0-9]{4})(?:; .*)?$", value
    )
    match_single <- regmatches(value, day_single)[[1]]
    month_only <- regexec("^([A-Za-z]+) ([0-9]{4})$", value)
    match_month <- regmatches(value, month_only)[[1]]
    if (length(match_range) == 5L) {
      month <- unname(months[tolower(match_range[[4]])])
      parsed_year <- as.integer(match_range[[5]])
      if (!is.na(month)) {
        start <- as.Date(sprintf("%04d-%02d-%02d", parsed_year, month,
                                 as.integer(match_range[[2]])))
        end <- as.Date(sprintf("%04d-%02d-%02d", parsed_year, month,
                               as.integer(match_range[[3]])))
      }
    } else if (length(match_single) == 4L) {
      month <- unname(months[tolower(match_single[[3]])])
      parsed_year <- as.integer(match_single[[4]])
      if (!is.na(month)) {
        start <- end <- as.Date(sprintf(
          "%04d-%02d-%02d", parsed_year, month,
          as.integer(match_single[[2]])
        ))
      }
    } else if (length(match_month) == 3L) {
      month <- unname(months[tolower(match_month[[2]])])
      parsed_year <- as.integer(match_month[[3]])
    }
  }
  if (!is.na(start)) month <- as.integer(format(start, "%m"))
  if (is.na(month) && grepl(as.character(registry_year), value, fixed = TRUE)) {
    named_months <- vapply(
      month.name,
      \(name) grepl(paste0("\\b", name, "\\b"), value, ignore.case = TRUE),
      logical(1)
    )
    if (sum(named_months) == 1L) month <- which(named_months)
  }
  conflicts <- (!is.na(start) &&
                  registry_year < as.integer(format(start, "%Y"))) ||
    (!is.na(end) && registry_year > as.integer(format(end, "%Y"))) ||
    (!is.na(parsed_year) && is.na(start) && parsed_year != registry_year)
  if (conflicts) {
    start <- end <- as.Date(NA)
    month <- NA_integer_
  }
  if (!is.na(start) && !is.na(end) &&
        format(start, "%Y-%m") != format(end, "%Y-%m")) {
    month <- NA_integer_
  }
  list(start_date = start, end_date = end, month = month,
       year_conflict = conflicts)
}

analysis_poll_events <- function(polls, facts) {
  facts |>
    dplyr::filter(field == "event_dates") |>
    dplyr::left_join(dplyr::select(polls, "poll_id", "year"), by = "poll_id",
                     relationship = "many-to-one") |>
    dplyr::group_by(poll_id) |>
    dplyr::mutate(event_id = dplyr::row_number()) |>
    dplyr::ungroup() |>
    dplyr::rowwise() |>
    dplyr::mutate(parsed = list(parse_event_dates(value, year))) |>
    dplyr::ungroup() |>
    dplyr::transmute(
      poll_id, event_id = as.integer(event_id),
      stage = "reported_event_timing",
      start_date = as.Date(vapply(
        parsed, \(x) as.character(x$start_date), character(1)
      )),
      end_date = as.Date(vapply(
        parsed, \(x) as.character(x$end_date), character(1)
      )),
      month = as.integer(vapply(parsed, \(x) x$month, integer(1))),
      year_conflict = vapply(parsed, \(x) x$year_conflict, logical(1)),
      reported_text = value, reference_id, source_locator
    )
}

analysis_poll_location <- function(location_text, place, poll_id) {
  online <- grepl("online", location_text, ignore.case = TRUE)
  country <- dplyr::case_when(
    place %in% c("Britain", "Northern Ireland") ~ "United Kingdom",
    place %in% c("United States", "Texas", "California", "Connecticut",
                 "Michigan") ~ "United States",
    place == "European Union" ~ "Belgium",
    place == "Greece" ~ "Greece", place == "China" ~ "China",
    place == "Denmark" ~ "Denmark", place == "Australia" ~ "Australia",
    place == "Bulgaria" ~ "Bulgaria", place == "Tanzania" ~ "Tanzania",
    grepl("Brazil", place, fixed = TRUE) ~ "Brazil",
    grepl("United States", location_text, fixed = TRUE) ~ "United States",
    TRUE ~ NA_character_
  )
  if (online || is.na(location_text)) country <- NA_character_
  us_states <- c(
    "Texas", "California", "Connecticut", "Michigan", "Vermont",
    "Louisiana", "Ohio", "Nebraska", "New York", "Missouri", "Indiana",
    "Virginia", "New Mexico", "Florida"
  )
  if (is.na(country) && !is.na(location_text) &&
    any(vapply(
      us_states, \(x) grepl(x, location_text, fixed = TRUE), logical(1)
    ))) {
    country <- "United States"
  }
  city <- if (online || is.na(location_text)) {
    NA_character_
  } else {
    parts <- trimws(strsplit(location_text, ",", fixed = TRUE)[[1]])
    if (length(parts) < 2L) NA_character_ else parts[[1]]
  }
  if (poll_id == "san-mateo-2008") city <- "Redwood City"
  if (poll_id == "bulgaria-crime-2002") city <- "Sofia"
  if (poll_id == "tomorrows-europe-2007") city <- "Brussels"
  if (poll_id == "europolis-2009") city <- "Brussels"
  if (poll_id == "zeguo-2005") city <- "Wenling"
  if (poll_id == "tanzania-2015") city <- "Dar es Salaam"
  if (poll_id == "btp-health-education-2005") city <- NA_character_
  if (poll_id == "baton-rouge-hammond-healthcare-2005") city <- NA_character_
  list(country = country, city = city)
}

analysis_polls <- function(polls, facts, events) {
  location <- facts |>
    dplyr::filter(field == "location") |>
    dplyr::group_by(poll_id) |>
    dplyr::slice_head(n = 1L) |>
    dplyr::ungroup() |>
    dplyr::transmute(poll_id, location_text = value,
                     location_reference_id = reference_id)
  date <- events |>
    dplyr::filter(!year_conflict, !is.na(month)) |>
    dplyr::group_by(poll_id) |>
    dplyr::arrange(dplyr::desc(!is.na(start_date)), event_id) |>
    dplyr::slice_head(n = 1L) |>
    dplyr::ungroup() |>
    dplyr::transmute(poll_id, event_month = month,
                     event_start_date = start_date, event_end_date = end_date,
                     event_reference_id = reference_id)
  out <- polls |>
    dplyr::left_join(location, by = "poll_id", relationship = "one-to-one") |>
    dplyr::left_join(date, by = "poll_id", relationship = "one-to-one")
  normalized <- purrr::pmap(
    out[c("location_text", "place", "poll_id")], analysis_poll_location
  )
  out$event_country <- purrr::map_chr(
    normalized, "country", .default = NA_character_
  )
  out$city <- purrr::map_chr(normalized, "city", .default = NA_character_)
  out
}
