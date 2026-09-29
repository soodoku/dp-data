source(project_path("R", "respondent_normalization.R"))

health_degree_status <- function(survey) {
  qualification <- as.numeric(survey$educb)
  stopifnot(
    length(qualification) == nrow(survey),
    all(is.na(qualification) | qualification %in% c(-9, 0:12))
  )
  qualification[qualification == -9 & !is.na(qualification)] <- NA_real_
  as.numeric(qualification == 9)
}

analysis_extra_covariates <- function(poll_id, data) {
  education <- function(x, low, middle, high) {
    dplyr::case_when(
      x %in% low ~ 0, x %in% middle ~ .5,
      x %in% high ~ 1, TRUE ~ NA_real_
    )
  }
  age <- switch(poll_id,
    "btp-2007" = 2007 - data$birthyr,
    "btp-online-primaries-2004" = data$ppage,
    "california-whats-next-2011" = data$q62age,
    "michigan-2009" = dplyr::if_else(data$q27aa == 98, NA_real_, data$q27aa),
    "northern-ireland-2007" = data$t1q2,
    data$AGE
  )
  age[is.na(age) | age < 16 | age > 110] <- NA_real_
  schooling <- switch(poll_id,
    "btp-2007" = education(data$educ, 1, 2:4, 5:6),
    "btp-online-primaries-2004" = education(data$ppeducat, 1, 2:3, 4),
    "california-whats-next-2011" = education(data$q58, 1, 2:3, 4:6),
    "michigan-2009" = education(data$q26, 1, 2:3, 4:6),
    "northern-ireland-2007" = education(data$t1q8, 6:7, 2:5, 1),
    "america-in-one-room-2019" = education(data$EDUC4, 1, 2:3, 4),
    "a1r-climate-2021" = education(data$EDUC5, 1, 2:3, 4:5)
  )
  reading <- rep(NA_real_, nrow(data))
  if (poll_id == "btp-2007") {
    reading <- c(0, .25, .5, .75, 1)[match(data$POST_Q32_groups, c(1:4, 99))]
  }
  if (poll_id == "michigan-2009") {
    reading <- (match(tolower(trimws(data$t3q45)), letters[1:5]) - 1) / 4
  }
  if (poll_id == "california-whats-next-2011") {
    reading <- (match(data$t3q46, 1:5) - 1) / 4
  }
  tibble::tibble(
    source_row = as.integer(data$source_row), age = as.numeric(age),
    education = as.numeric(schooling), read_briefing = as.numeric(reading)
  )
}

add_analysis_covariates <- function(participants) {
  extra <- c(
    "btp-2007", "btp-online-primaries-2004", "california-whats-next-2011",
    "michigan-2009", "northern-ireland-2007", "america-in-one-room-2019",
    "a1r-climate-2021"
  )
  rows <- lapply(extra, function(poll_id) {
    path <- project_path("data", poll_id, "survey.parquet")
    data <- if (file.exists(path)) {
      arrow::read_parquet(path)
    } else {
      readr::read_tsv(project_path("data", poll_id, "participants.tab"),
        show_col_types = FALSE
      ) |>
        dplyr::mutate(source_row = dplyr::row_number())
    }
    values <- analysis_extra_covariates(poll_id, data)
    stopifnot(!anyNA(values$source_row), !anyDuplicated(values$source_row))
    identity <- participants |>
      dplyr::filter(.data$poll_id == .env$poll_id) |>
      dplyr::select("poll_id", "source_dataset", "respondent_id", "source_row")
    stopifnot(all(identity$source_row %in% values$source_row))
    dplyr::left_join(identity, values,
      by = "source_row",
      relationship = "many-to-one"
    )
  }) |>
    dplyr::bind_rows() |>
    dplyr::select(-"source_row")
  historical_reading <- arrow::read_parquet(project_path(
    "output", "respondent", "briefing_reading.parquet"
  )) |>
    dplyr::transmute(poll_id,
      source_dataset = "historical", respondent_id,
      read_briefing = reading_score
    )
  rows <- dplyr::bind_rows(rows, historical_reading)
  keys <- c("poll_id", "source_dataset", "respondent_id")
  stopifnot(!anyDuplicated(rows[keys]))
  out <- dplyr::left_join(participants, rows,
    by = keys,
    relationship = "one-to-one", suffix = c("", "_extra")
  ) |>
    dplyr::mutate(
      age = dplyr::coalesce(age, age_extra),
      education = dplyr::coalesce(education, education_extra),
      ba = dplyr::coalesce(ba, as.numeric(education == 1))
    ) |>
    dplyr::select(-"age_extra", -"education_extra")
  stopifnot(nrow(out) == nrow(participants), !anyDuplicated(out[keys]))
  health_rows <- which(
    out$poll_id == "uk-health-1998" & out$source_dataset == "historical"
  )
  if (length(health_rows)) {
    survey <- read_poll_survey("uk-health-1998")
    source_rows <- match(out$source_row[health_rows], survey$source_row)
    stopifnot(!anyNA(source_rows), !anyDuplicated(survey$source_row))
    out$ba[health_rows] <- health_degree_status(survey)[source_rows]
  }
  add_analysis_median_flags(out)
}

add_analysis_median_flags <- function(participants) {
  definitions <- read_metadata("measure_definitions") |>
    dplyr::filter(measure_id %in% c(
      "bettered", "higher_education", "highinc", "high_income"
    )) |>
    dplyr::transmute(
      poll_id, definition_id,
      variable = dplyr::if_else(
        measure_id %in% c("bettered", "higher_education"),
        "education_above_median", "income_above_median"
      )
    )
  stopifnot(!anyDuplicated(definitions[c("poll_id", "variable")]))
  values <- arrow::read_parquet(project_path(
    "output", "respondent", "respondent_measures.parquet"
  )) |>
    dplyr::inner_join(definitions,
      by = c("poll_id", "definition_id"), relationship = "many-to-one"
    )
  stopifnot(all(is.na(values$value_numeric) | values$value_numeric %in% 0:1))
  values <- values |>
    dplyr::transmute(
      poll_id, respondent_id, variable,
      value = as.logical(value_numeric)
    ) |>
    tidyr::pivot_wider(names_from = "variable", values_from = "value")
  people <- arrow::read_parquet(project_path(
    "output", "respondent", "people.parquet"
  )) |>
    dplyr::select("poll_id", "source_row", "respondent_id")
  stopifnot(!anyDuplicated(people[c("poll_id", "source_row")]))
  cor <- participants |>
    dplyr::filter(source_dataset == "cor_sood", poll_id %in% values$poll_id) |>
    dplyr::select("poll_id", "source_dataset", "respondent_id", "source_row") |>
    dplyr::left_join(
      dplyr::rename(people, normalized_respondent_id = respondent_id),
      by = c("poll_id", "source_row"), relationship = "one-to-one"
    )
  stopifnot(!anyNA(cor$normalized_respondent_id))
  cor <- cor |>
    dplyr::left_join(values,
      by = c("poll_id", "normalized_respondent_id" = "respondent_id"),
      relationship = "one-to-one"
    ) |>
    dplyr::select(-"source_row", -"normalized_respondent_id")
  values <- dplyr::bind_rows(
    dplyr::mutate(values, source_dataset = "historical"), cor
  )
  keys <- c("poll_id", "source_dataset", "respondent_id")
  stopifnot(!anyDuplicated(values[keys]), !anyDuplicated(participants[keys]))
  out <- dplyr::left_join(participants, values,
    by = keys, relationship = "one-to-one"
  )
  stopifnot(nrow(out) == nrow(participants))
  add_analysis_a1r_median_flags(out)
}


add_analysis_a1r_median_flags <- function(participants, survey = NULL) {
  selected <- participants$poll_id == "america-in-one-room-2019" &
    participants$source_dataset %in% c("control", "cor_sood")
  if (!any(selected)) return(participants)
  if (is.null(survey)) {
    survey <- readr::read_tsv(project_path(
      "data", "america-in-one-room-2019", "participants.tab"
    ), show_col_types = FALSE)
  }
  education <- as.numeric(survey$EDUC4)
  stopifnot(
    length(education) == nrow(survey),
    all(is.na(education) | education %in% 1:4)
  )
  attendee <- survey$CONDITION == 1 & !is.na(survey$GROUP)
  classification <- as.logical(above_reference_median(
    education, education[attendee %in% TRUE]
  ))
  position <- match(participants$source_row[selected], seq_len(nrow(survey)))
  stopifnot(!anyNA(position))
  participants$education_above_median[selected] <- classification[position]
  participants
}
