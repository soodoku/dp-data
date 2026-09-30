source_attitude_nonanswer <- function(label) {
  text <- tolower(trimws(dplyr::coalesce(label, "")))
  dplyr::case_when(
    grepl(paste0("dk/na|^na$|no answer */ *refused|", "not applicable"),
      text
    ) ~ "nonanswer",
    grepl(paste0(
      "refus|vil ikke svare|^don't want to answer$|",
      "^i do not accept the scale$"
    ), text) ~ "refused",
    grepl(paste0(
      "don't know|don.t know|^dont know$|no opinion|ved ikke|^dk$|undecided|",
      "not yet decided|haven.t thought|never heard"
    ), text) ~ "dk",
    grepl("no answer|not answered", text) ~ "nonanswer",
    TRUE ~ NA_character_
  )
}

source_attitude_values <- function(raw, labels, minimum, maximum, unit,
                                   categories = numeric(), observed = NULL) {
  stopifnot(is.numeric(raw), length(labels) == length(raw))
  if (is.null(observed)) observed <- rep(NA, length(raw))
  stopifnot(is.logical(observed), length(observed) == length(raw))
  reason <- source_attitude_nonanswer(labels)
  valid <- !is.na(raw) & is.finite(raw)
  if (unit == "unverified") {
    valid[] <- FALSE
  } else if (unit == "category") {
    valid <- valid & raw %in% categories
  } else {
    if (!is.na(minimum)) valid <- valid & raw >= minimum
    if (!is.na(maximum)) valid <- valid & raw <= maximum
    if (unit == "rating") valid <- valid & raw == floor(raw)
  }
  status <- dplyr::case_when(
    !is.na(raw) & !is.na(reason) ~ reason,
    valid ~ "answered",
    !is.na(raw) & unit == "unverified" ~ "unclassified_response",
    !is.na(raw) ~ "invalid_response",
    observed %in% FALSE ~ "absent_form",
    observed %in% TRUE ~ "blank",
    TRUE ~ "source_missing"
  )
  value <- dplyr::if_else(status == "answered", raw, NA_real_)
  normalized <- rep(NA_real_, length(raw))
  if (unit != "category" && !is.na(minimum) && !is.na(maximum)) {
    stopifnot(maximum > minimum)
    normalized <- (value - minimum) / (maximum - minimum)
  }
  tibble::tibble(
    raw_value = raw, source_response_label = labels,
    response_status = status, value, normalized_value = normalized,
    wave_observed = observed
  )
}

source_attitude_sources <- function() {
  tibble::tribble(
    ~poll_id, ~path, ~dictionary, ~source_wave, ~id_column,
    "denmark-euro-2000", "survey.parquet", "", "t0", "ipnr",
    "denmark-euro-2000", "arrival.sav", "arrival-", "t1", "DELNR",
    "denmark-euro-2000", "departure.parquet", "departure-", "t2", "DELNR",
    "denmark-euro-2000", "source-materials/follow-up-survey.parquet",
    "source-materials/follow-up-survey-dictionary.json", "t3", "DELNR",
    "denmark-euro-2000", "source-materials/control-follow-up-survey.parquet",
    "source-materials/control-follow-up-survey-dictionary.json",
    "source_t2ctrl", "IP",
    "vermont-energy-2007", "survey.sav", "", "multiple", "CASEID",
    "marousi-2006", "survey.sav", "", "multiple", "P_Q1_0",
    "amr-2024", "participants.csv", "", "multiple", "ID",
    "california-whats-next-2011", "survey.parquet", "", "multiple", "id"
  )
}

source_attitude_dictionary <- function(specification) {
  directory <- project_path("data", specification$poll_id)
  prefix <- specification$dictionary
  if (specification$poll_id == "california-whats-next-2011") {
    items <- read_metadata("source_attitude_items") |>
      dplyr::filter(poll_id == specification$poll_id)
    stopifnot(
      nrow(items) == 39L, !anyDuplicated(items$source_suffix),
      setequal(items$source_suffix, c(letters, paste0("a", letters[1:13]))),
      !anyNA(items$label), all(nzchar(items$label))
    )
    variables <- purrr::map(c("t2", "t3"), function(wave) {
      tibble::tibble(
        source_column = paste0(wave, "q2", items$source_suffix),
        variable_label = items$label, evidence = items$evidence
      )
    }) |> purrr::list_rbind()
    labels <- tidyr::expand_grid(
      source_column = variables$source_column, source_value = c(0, 5, 10, 99)
    ) |>
      dplyr::mutate(value_label = c(
        "Extremely undesirable", "Exactly in the middle",
        "Extremely desirable", "No opinion"
      )[match(source_value, c(0, 5, 10, 99))])
  } else if (grepl("json$", prefix)) {
    contents <- jsonlite::fromJSON(file.path(directory, prefix),
      simplifyVector = FALSE
    )$columns
    variables <- purrr::map(contents, function(column) {
      tibble::tibble(
        source_column = column$name,
        variable_label = column$source_label
      )
    }) |> purrr::list_rbind()
    labels <- purrr::map(contents, function(column) {
      codes <- column$value_labels
      tibble::tibble(
        source_column = rep(column$name, length(codes)),
        source_value = as.numeric(names(codes)),
        value_label = unlist(codes, use.names = FALSE)
      )
    }) |> purrr::list_rbind()
  } else if (specification$poll_id == "amr-2024") {
    path <- file.path(directory, "codebooks", "harmonized-codebook.xlsx")
    variables <- readxl::read_excel(path, sheet = "variables") |>
      dplyr::transmute(source_column = variable, variable_label = label)
    labels <- readxl::read_excel(path, sheet = "categories") |>
      dplyr::transmute(
        source_column = variable,
        source_value = as.numeric(value), value_label = label
      )
  } else {
    variables <- readr::read_csv(file.path(
      directory,
      paste0(prefix, "variables.csv")
    ), show_col_types = FALSE)
    labels <- readr::read_csv(file.path(
      directory,
      paste0(prefix, "value-labels.csv")
    ), show_col_types = FALSE)
  }
  stopifnot(
    !anyDuplicated(variables$source_column),
    !anyDuplicated(labels[c("source_column", "source_value")])
  )
  list(variables = variables, labels = labels)
}

source_attitude_fields <- function(specification, dictionary) {
  fields <- dictionary$variables$source_column
  poll <- specification$poll_id
  if (poll == "california-whats-next-2011") return(fields)
  if (poll == "amr-2024") {
    return(grep("^(proposal|statement|value|civic|disagree|trust)_", fields,
      value = TRUE
    ))
  }
  if (poll == "vermont-energy-2007") {
    baseline <- grepl("^Q[0-9]+$", fields)
    number <- suppressWarnings(as.integer(sub("^Q", "", fields)))
    later <- grepl("^Q[0-9]{3}[A-Z]?T[23]$", fields)
    later_number <- suppressWarnings(as.integer(substr(fields, 2, 4)))
    return(fields[(baseline & number <= 76) %in% TRUE |
                    (later & later_number <= 29) %in% TRUE])
  }
  if (poll == "marousi-2006") {
    telephone <- grep("^P_Q", fields, value = TRUE)
    excluded <- c(
      "P_Q1_0", "P_Q1", "P_Q4", "P_Q7", "P_Q13",
      paste0("P_Q", 21:27)
    )
    event <- grep("^(AR|F)_Q", fields, value = TRUE)
    excluded <- c(
      excluded, paste0("AR_Q", 14:20), paste0("F_Q", 14:20),
      "F_Q27"
    )
    return(setdiff(c(telephone, event), excluded))
  }
  pattern <- switch(specification$source_wave,
    t0 = "^s_(15b?|16|17_[0-9]+|26_[0-9]+|27_[0-9]+|30|32|35_[0-9]+|36)$",
    t1 = "^S(1B?|2|3[A-R]|12[A-F]|13[A-D]|16|17|18[A-C]|19)_1$",
    t2 = "^S(1B?|2|3[A-R]|12[A-F]|13[A-D]|16|17|18[A-C]|19)_2$",
    t3 = "^S(14_[A-Q]|23_[A-F]|24_[A-D]|27|29|30_[A-C]|31)_3$",
    source_t2ctrl = "^S_(08B?|09|10_[0-9]+)$"
  )
  grep(pattern, fields, value = TRUE)
}

source_attitude_scale <- function(poll, field, label, labels) {
  codes <- labels$source_value[is.na(source_attitude_nonanswer(
    labels$value_label
  ))]
  unit <- "rating"
  if (poll == "amr-2024") {
    lower <- 0
    upper <- 10
  } else if (poll == "vermont-energy-2007" &&
               grepl("percentage", label, ignore.case = TRUE)) {
    unit <- "percent"
    lower <- 0
    upper <- 100
  } else if (poll == "vermont-energy-2007" &&
               grepl("dollars per month", label, ignore.case = TRUE)) {
    unit <- "dollars_per_month"
    lower <- 0
    upper <- NA_real_
  } else if (poll == "marousi-2006" &&
               grepl("^(P_Q(18|20)_|AR_Q(3|22)_|F_Q(3|22)_)", field)) {
    unit <- "thermometer"
    lower <- 0
    upper <- 100
  } else {
    if (!length(codes)) {
      return(list(
        minimum = NA_real_, maximum = NA_real_,
        unit = "unverified", categories = numeric()
      ))
    }
    lower <- min(codes)
    upper <- max(codes)
    nominal <- (poll == "denmark-euro-2000" &&
      grepl(
        "^(s_(15b?|32|36)|S(1B?|17|19)_[12]|S(29|31)_3|S_08B?)$",
        field
      )) || (poll == "marousi-2006" &&
               grepl("^(P_Q(6|8|9|10|11|12)|AR_Q9|F_Q9)$", field))
    if (nominal) {
      unit <- "category"
      lower <- upper <- NA_real_
    }
  }
  list(
    minimum = as.numeric(lower), maximum = as.numeric(upper), unit = unit,
    categories = codes
  )
}

source_attitude_identity <- function(raw, specification, participants) {
  result <- tibble::tibble(
    source_dataset = rep(NA_character_, nrow(raw)),
    respondent_id = rep(NA_character_, nrow(raw))
  )
  if (is.null(participants) || specification$source_wave == "source_t2ctrl") {
    return(result)
  }
  people <- participants[participants$poll_id == specification$poll_id, ]
  if (!nrow(people)) {
    return(result)
  }
  stopifnot(!anyDuplicated(people$source_row))
  if (specification$poll_id == "amr-2024") {
    stopifnot(!anyDuplicated(people$respondent_id))
    position <- match(as.character(raw$ID), people$respondent_id)
  } else if (specification$poll_id == "denmark-euro-2000" &&
               specification$source_wave != "t0") {
    baseline <- arrow::read_parquet(project_path(
      "data", "denmark-euro-2000", "survey.parquet"
    ))
    ids <- baseline$delnr[match(people$source_row, baseline$source_row)]
    stopifnot(!anyNA(ids), !anyDuplicated(ids))
    position <- match(as.numeric(raw$DELNR), ids)
  } else {
    position <- match(seq_len(nrow(raw)), people$source_row)
  }
  result$source_dataset <- people$source_dataset[position]
  result$respondent_id <- people$respondent_id[position]
  result
}

source_attitude_presence <- function(responses) {
  keys <- c("poll_id", "source_id", "source_row", "source_wave")
  stopifnot(
    !anyNA(responses[keys]),
    all(is.finite(responses$raw_value[responses$response_status == "answered"]))
  )
  forms <- responses |>
    dplyr::summarise(
      observed_answer = any(
        response_status %in% c("answered", "dk", "refused") &
          !is.na(raw_value)
      ),
      explicitly_absent = any(wave_observed %in% FALSE),
      source_id_count = dplyr::n_distinct(source_unit_id),
      .by = dplyr::all_of(keys)
    )
  if (any(forms$source_id_count != 1L)) {
    stop("Source questionnaire has inconsistent native respondent identifiers.")
  }
  if (any(forms$observed_answer & forms$explicitly_absent)) {
    stop("Source questionnaire answers conflict with explicit absence.")
  }
  index <- match(
    do.call(paste, responses[keys]), do.call(paste, forms[keys])
  )
  stopifnot(!anyNA(index))
  fill <- is.na(responses$wave_observed) & forms$observed_answer[index]
  responses$wave_observed[fill] <- TRUE
  blank <- fill & is.na(responses$raw_value) &
    responses$response_status == "source_missing"
  responses$response_status[blank] <- "blank"
  responses
}

analysis_source_attitudes <- function(participants = NULL, scores = NULL) {
  sources <- read_metadata("source_files")
  occasions <- read_metadata("analysis_survey_waves")
  specs <- source_attitude_sources()
  built <- purrr::map(seq_len(nrow(specs)), function(i) {
    spec <- specs[i, ]
    path <- paste0("data/", spec$poll_id, "/", spec$path)
    source <- sources[sources$path == path, ]
    stopifnot(nrow(source) == 1L, identical(
      digest::digest(file = project_path(path), algo = "sha256"), source$sha256
    ))
    raw <- switch(tools::file_ext(path),
      parquet = arrow::read_parquet(project_path(path)),
      csv = readr::read_csv(project_path(path), show_col_types = FALSE),
      sav = haven::read_sav(project_path(path), user_na = TRUE)
    )
    stopifnot(spec$id_column %in% names(raw))
    dictionary <- source_attitude_dictionary(spec)
    fields <- source_attitude_fields(spec, dictionary)
    stopifnot(length(fields) > 0L, all(fields %in% names(raw)))
    identity <- source_attitude_identity(raw, spec, participants)
    purrr::map(fields, function(field) {
      label <- dictionary$variables$variable_label[
        match(field, dictionary$variables$source_column)
      ]
      labels <- dictionary$labels[dictionary$labels$source_column == field, ]
      scale <- source_attitude_scale(spec$poll_id, field, label, labels)
      source_wave <- if (spec$source_wave != "multiple") {
        spec$source_wave
      } else {
        switch(spec$poll_id,
          "amr-2024" = paste0("Time", raw$Time),
          "california-whats-next-2011" = toupper(substr(field, 1, 2)),
          "vermont-energy-2007" = if (grepl("T[23]$", field)) {
            sub(".*(T[23])$", "\\1", field)
          } else {
            "T1"
          },
          "marousi-2006" = if (startsWith(field, "P_")) {
            "T1"
          } else if (startsWith(field, "AR_")) {
            "T2"
          } else {
            "T3"
          }
        )
      }
      purrr::map(unique(source_wave), function(wave) {
        rows <- if (length(source_wave) == 1L) {
          seq_len(nrow(raw))
        } else {
          which(source_wave == wave)
        }
        occasion <- occasions[occasions$poll_id == spec$poll_id &
                                occasions$original_survey_wave == wave, ]
        stopifnot(nrow(occasion) == if (wave == "source_t2ctrl") 0L else 1L)
        wave_id <- if (nrow(occasion)) {
          occasion$wave_instance_id
        } else {
          NA_character_
        }
        phase <- if (nrow(occasion)) occasion$wave else NA_character_
        role <- if (nrow(occasion)) occasion$wave_role else NA_character_
        observed <- rep(NA, length(rows))
        if (!is.null(scores) && !is.na(wave_id)) {
          presence <- scores |>
            dplyr::filter(
              poll_id == spec$poll_id,
              wave_instance_id == wave_id
            ) |>
            dplyr::select("source_dataset", "respondent_id", "wave_observed") |>
            dplyr::distinct()
          stopifnot(!anyDuplicated(
            presence[c("source_dataset", "respondent_id")]
          ))
          key <- paste(identity$source_dataset[rows],
            identity$respondent_id[rows]
          )
          observed <- presence$wave_observed[match(
            key,
            paste(presence$source_dataset, presence$respondent_id)
          )]
        }
        if (spec$poll_id == "california-whats-next-2011") {
          form_fields <- grep(paste0("^", tolower(wave), "q"),
            names(raw), value = TRUE
          )
          stopifnot(length(form_fields) > 0L)
          answered_form <- rowSums(!is.na(raw[rows, form_fields])) > 0L
          if (any(answered_form & observed %in% FALSE)) {
            stop("California questionnaire answers conflict with absence.")
          }
          observed[is.na(observed) & answered_form] <- TRUE
        }
        values <- as.numeric(raw[[field]][rows])
        source_labels <- labels$value_label[match(values, labels$source_value)]
        response <- source_attitude_values(
          values, source_labels,
          scale$minimum, scale$maximum, scale$unit, scale$categories, observed
        )
        semantic <- tolower(iconv(label, to = "ASCII//TRANSLIT"))
        semantic <- gsub("[^a-z0-9]+", "_", semantic)
        semantic <- gsub("^_+|_+$", "", semantic)
        attitude_id <- paste0("attitude_", substr(semantic, 1, 160), "_",
          tolower(field)
        )
        evidence <- if (spec$poll_id == "california-whats-next-2011") {
          dictionary$variables$evidence[
            match(field, dictionary$variables$source_column)
          ]
        } else if (spec$poll_id == "amr-2024") {
          paste0(
            "data/amr-2024/codebooks/harmonized-codebook.xlsx; ",
            "data/amr-2024/questionnaires/survey-and-extended-data.pdf"
          )
        } else {
          paste0(
            "data/", spec$poll_id, "/",
            if (grepl("json$", spec$dictionary)) {
              spec$dictionary
            } else {
              paste0(
                spec$dictionary, "variables.csv; data/", spec$poll_id,
                "/", spec$dictionary, "value-labels.csv"
              )
            }
          )
        }
        id_column <- if (spec$poll_id == "california-whats-next-2011") {
          paste0(tolower(wave), "_ParticipantNumber")
        } else if (spec$poll_id == "marousi-2006") {
          switch(wave, T1 = "P_Q1_0", T2 = "AR_CODE", T3 = "F_CODE")
        } else {
          spec$id_column
        }
        stopifnot(length(id_column) == 1L, id_column %in% names(raw))
        definition <- tibble::tibble(
          poll_id = spec$poll_id,
          source_id = source$source_id, source_path = path,
          source_sha256 = source$sha256, attitude_id, source_column = field,
          source_unit_id_column = id_column,
          source_wave = wave, wave_instance_id = wave_id, wave = phase,
          wave_role = role, label,
          item_family = if (spec$poll_id == "amr-2024") {
            sub("_[0-9]+$", "", field)
          } else if (spec$poll_id == "denmark-euro-2000") {
            "euro_and_democracy_attitudes"
          } else if (spec$poll_id == "vermont-energy-2007") {
            "electricity_preferences_and_beliefs"
          } else if (spec$poll_id == "california-whats-next-2011") {
            "government_reform_policy_desirability"
          } else if (grepl("^[AF][R_]*_?Q(25|26|28|29)", field)) {
            "event_evaluation"
          } else {
            "municipal_policy_and_political_evaluations"
          }, minimum = scale$minimum,
          maximum = scale$maximum, unit = scale$unit,
          source_value_labels = as.character(jsonlite::toJSON(
            stats::setNames(as.list(labels$value_label), labels$source_value),
            auto_unbox = TRUE
          )), evidence
        )
        responses <- dplyr::bind_cols(tibble::tibble(
          poll_id = spec$poll_id, source_id = source$source_id,
          source_row = as.integer(rows),
          source_unit_id = as.character(raw[[id_column]][rows]),
          attitude_id, source_column = field, source_wave = wave,
          wave_instance_id = wave_id, wave = phase, wave_role = role
        ), identity[rows, ], response)
        list(definitions = definition, responses = responses)
      })
    }) |>
      purrr::list_flatten()
  }) |>
    purrr::list_flatten()
  definitions <- purrr::map(built, "definitions") |> purrr::list_rbind()
  responses <- purrr::map(built, "responses") |>
    purrr::list_rbind() |>
    source_attitude_presence()
  stopifnot(
    !anyDuplicated(definitions[c("source_id", "source_column", "source_wave")]),
    !anyDuplicated(responses[c("source_id", "source_row", "source_column")]),
    all(is.na(responses$value[responses$response_status != "answered"])),
    all(is.na(responses$normalized_value) |
          dplyr::between(responses$normalized_value, 0, 1))
  )
  list(
    analysis_source_attitude_definitions = definitions,
    analysis_source_attitude_responses = responses
  )
}
