bulgaria_attitudes <- function(survey, wave) {
  suffix <- if (wave == 1L) "" else "p"
  response <- function(stem, values = seq(0, 1, .25), missing = 99) {
    recode_source_values(survey, paste0(stem, suffix), values, missing)
  }
  average <- function(stems) {
    purrr::map(stems, response) |>
      do.call(what = cbind) |>
      historical_available_mean() |>
      as_historical_float()
  }
  tibble::tibble(
    tougher_punishment = average(paste0("q8_", 3:6)),
    civil_liberties = average(c("q15_1", "q15_3", "q17_1", "q17_2", "q17_4")),
    social_causes = response("q8_7"), economic_causes = response("q8_1"),
    rehabilitation = response("q8_8"), faster_trials = response("q8_11"),
    drug_penalties = response("q10_3"), vigilantism = response("q16"),
    institutional_change = response("q21", c(0, 1), 3),
    independent_investigation = response("q22", c(0, 1), 3),
    prosecution = response("q23", c(0, 0, 1), 4),
    death_penalty = response("q19", c(1, .75, .5, .25))
  )
}

bulgaria_knowledge_items <- function(survey, wave) {
  key <- c(2, 2, 2, 2, 1, 2, 1)
  purrr::map2(seq_along(key), key, function(item, correct) {
    field <- paste0("q12_", item, if (wave == 1L) "" else "p")
    value <- read_source_codes(survey, field, c(1:2, 99))
    as.numeric(value %in% correct)
  }) |> do.call(what = cbind)
}

build_bulgaria_individual <- function(
  survey = read_poll_survey("bulgaria-crime-2002")
) {
  baseline <- bulgaria_attitudes(survey, 1L)
  post <- bulgaria_attitudes(survey, 2L)
  drug_index <- purrr::map(c("q10_1", "q10_2"), function(field) {
    recode_source_values(survey, field, seq(0, 1, .25), 99)
  }) |>
    do.call(what = cbind) |>
    historical_available_mean() |>
    as_historical_float()
  education <- recode_source_values(survey, "edu", c(1, .66, .33, 0, 0), 0)
  income <- read_source_codes(survey, "incomes", 0:6)
  income <- dplyr::if_else(income == 0, NA_real_, income + 1)
  dplyr::bind_cols(
    dplyr::rename_with(baseline, \(name) paste0(name, "_t1")),
    dplyr::rename_with(post, \(name) paste0(name, "_t2")),
    summarise_historical_knowledge(
      bulgaria_knowledge_items(survey, 1L), bulgaria_knowledge_items(survey, 2L)
    ),
    tibble::tibble(
      age = read_source_codes(survey, "age_full", 18:100),
      female = as.numeric(read_source_codes(survey, "sex", 1:2) == 2),
      minority = as.numeric(read_source_codes(survey, "ethnos", 0:4) != 1),
      education_four = education,
      education_three = collapse_historical_education(education),
      higher_education = as.numeric(education >= .66),
      household_income = income, high_income = as.numeric(income > 2),
      attitude_extremity = historical_available_mean(abs(
        cbind(as.matrix(baseline), drug_index) - .5
      )),
      read_briefing = NA_real_, political_interest_t1 = NA_real_,
      knowledge_joint_midterm = NA_real_, knowledge_midterm = NA_real_,
      knowledge_midterm_joint = NA_real_, attitude_extremity_midterm = NA_real_
    )
  )
}
