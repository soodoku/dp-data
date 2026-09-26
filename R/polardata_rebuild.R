source(project_path("R", "polardata_derived.R"))
source(project_path("R", "polardata_assembly.R"))
source(project_path("R", "polardata_core.R"))
source(project_path("R", "polardata_europe.R"))
source(project_path("R", "polardata_btp_reviewed.R"))
source(project_path("R", "polardata_nic2.R"))
source(project_path("R", "polardata_unresolved.R"))
source(project_path("R", "polardata_btp_national.R"))

historical_poll_name <- function(poll_id) {
  names <- c(
    "uk-eu-1995" = "UK EU", "uk-health-1998" = "UK Health",
    "uk-monarchy-1996" = "UK Monarchy",
    "uk-general-election-1997" = "UK General Election",
    "australia-republic-1999" = "Australia Republic Referendum",
    "uk-crime-1994" = "UK Crime",
    "tomorrows-europe-2007" = "Tomorrow's Europe (EU)",
    "cpl-1996" = "Central Power & Light", "zeguo-2005" = "Zeguo Township",
    "bulgaria-crime-2002" = "Bulgarian National",
    "europolis-2009" = "Europolis", "new-haven-2004" = "New Haven, CT",
    "nic2-2003" = "National Issues Convention 2",
    "btp-national-2003" = "By the People: National",
    "btp-general-election-2004" = "By the People 2004 US General Election",
    "btp-presidential-primaries-2004" = paste(
      "By the People 2004 US Presidential Primaries"
    ),
    "san-mateo-2008" = "San Mateo, CA",
    "btp-health-education-2005" = "By the People: Health and Education",
    "wtu-1996" = "West Texas Utilities",
    "nic-1996" = "National Issues Convention",
    "swepco-1996" = "Southwestern Electric Power"
  )
  stopifnot(poll_id %in% names(names))
  unname(names[[poll_id]])
}

build_historical_poll <- function(poll_id) {
  values <- historical_respondent_wide(poll_id)
  survey <- read_poll_survey(poll_id)
  builder <- switch(poll_id,
    "australia-republic-1999" = build_australia_derived,
    "tomorrows-europe-2007" = build_tomorrow_derived,
    "europolis-2009" = build_europolis_derived,
    "btp-general-election-2004" = build_btp_general_derived,
    "btp-health-education-2005" = build_btp_health_derived,
    "san-mateo-2008" = build_san_mateo_derived,
    "nic2-2003" = build_nic2_derived,
    "btp-national-2003" = build_btp_national_derived,
    "zeguo-2005" = build_zeguo_derived,
    "new-haven-2004" = build_new_haven_derived,
    "btp-presidential-primaries-2004" = build_btp_primaries_derived
  )
  derived <- if (is.null(builder)) {
    build_core_derived(survey, values, poll_id)
  } else {
    builder(survey, values)
  }
  derived$loggain <- historical_log_score(derived$grpgain)
  stopifnot(
    nrow(derived) == nrow(values),
    !length(intersect(names(derived), names(values)))
  )
  result <- dplyr::bind_cols(values, derived)
  result$pollname <- historical_poll_name(poll_id)
  result
}

historical_wide_export <- function(polls) {
  fields <- read_metadata("polardata_fields")$legacy_field
  data <- purrr::list_rbind(polls)
  stopifnot(!anyDuplicated(data[c("dpnum", "caseid")]))
  rows <- unlist(lapply(seq_len(nrow(data)), function(row) {
    rep(row, if (data$dpnum[[row]] == 16) 2L else 1L)
  }))
  data <- data[rows, ]
  data$X <- seq_len(nrow(data))
  for (field in setdiff(fields, names(data))) data[[field]] <- NA_real_
  data[, fields]
}

historical_derived_measures <- function(polls) {
  layers <- read_metadata("polardata_fields")
  fields <- layers$legacy_field[
    layers$layer %in% c("group-derived", "poll-derived")
  ]
  purrr::imap(polls, function(data, poll_id) {
    data |>
      dplyr::select("respondent_id", dplyr::all_of(fields)) |>
      tidyr::pivot_longer(-"respondent_id",
        names_to = "legacy_field", values_to = "value_numeric"
      ) |>
      dplyr::mutate(
        poll_id = .env$poll_id,
        definition_version = dplyr::case_when(
          .env$poll_id == "swepco-1996" &
            .data$legacy_field %in% c("meanxtreme", "avgsd", "genvar") ~
            "swe-04-v2",
          .env$poll_id == "wtu-1996" &
            .data$legacy_field %in% c("meanxtreme", "avgsd", "genvar") ~
            "wtu-05-v2",
          .env$poll_id == "uk-general-election-1997" &
            .data$legacy_field %in% c(
              "grpgain", "grpgainr", "loggain", "avgsd", "genvar"
            ) ~ "ukge-05-v2",
          .env$poll_id == "uk-general-election-1997" &
            .data$legacy_field %in% c(
              "meant1knowcor", "t1knowlevelcor", "meant1knowcor_ind",
              "meant2know", "t2knowlevel", "meant1knowrcor",
              "t1knowlevelrcor"
            ) ~ "ukge-03-v2",
          .env$poll_id == "uk-monarchy-1996" &
            .data$legacy_field %in% c(
              "grpgain", "grpgainr", "loggain", "meant1knowcor",
              "meant1knowrcor", "meant1knowcor_ind", "t1knowlevelcor",
              "t1knowlevelrcor", "meant2know", "t2knowlevel"
            ) ~ "ukm-01-v2",
          .env$poll_id == "nic-1996" & .data$legacy_field == "meanage" ~
            "nic-03-v2",
          .env$poll_id == "cpl-1996" & .data$legacy_field %in%
            c("grpgain", "grpgainr", "loggain") ~ "cpl-05-v2",
          .env$poll_id == "australia-republic-1999" &
            .data$legacy_field %in% c("grpgain", "loggain") ~ "aus-04-v2",
          .env$poll_id == "btp-health-education-2005" &
            .data$legacy_field %in% c(
              "pfemale", "varfemale", "sdfemale", "pfemale_ind", "entropy"
            ) ~ "btphe-01-v2",
          .env$poll_id == "btp-health-education-2005" &
            .data$legacy_field == "t1knowlevel" ~ "btphe-03-v2",
          .env$poll_id == "new-haven-2004" &
            .data$legacy_field == "pminority" ~ "nh-04-v2",
          .default = "historical-v1"
        ),
        value_status = dplyr::case_when(
          is.na(.data$value_numeric) ~ "missing",
          .data$value_numeric == Inf ~ "positive-infinity",
          .data$value_numeric == -Inf ~ "negative-infinity",
          .default = "finite"
        ), .before = 1
      )
  }) |>
    purrr::list_rbind()
}
