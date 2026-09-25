monarchy_attitudes <- function(survey, wave) {
  prefix <- if (wave == 1L) "Q" else "R"
  response <- function(stem, values, missing) {
    recode_source_values(survey, paste0(prefix, stem), values,
      missing = c(-1, missing)
    ) |> as_historical_float()
  }
  average <- function(values) {
    historical_available_mean(as.matrix(tibble::as_tibble(values))) |>
      as_historical_float()
  }
  descending <- c(1, .75, .5, .25, 0)
  tibble::tibble(
    monarchy_support = average(list(
      retention = response("1", c(1, .5, 0), 4:5),
      duration = response("11", c(1, .8, .6, .4, .2, 0), 7:8),
      succession = response("9", c(1, 0), 3:4),
      referendum = response("14", c(0, .333, 1, .667), 5:6)
    )),
    monarchy_people = average(list(
      mix = response("6A", descending, 6),
      retire = response("6B", descending, 6),
      taxes = response("6E", descending, 6),
      glamour = response("6F", rev(descending), 6),
      popular_support = response("7A", descending, 6),
      public_succession = response("7B", descending, 6)
    )),
    monarchy_power = average(list(
      appoint = response("15", c(1, 0), 3:4),
      ceremonial = response("13D", descending, 6)
    )),
    lords_reform = average(list(
      replace = response("18", c(0, .5, 1), 4:5),
      hereditary = response("19A", c(0, 1), 3:4),
      appointed = response("19B", c(0, 1), 3:4)
    ))
  ) |>
    dplyr::rename_with(\(name) paste0(name, "_t", wave))
}

monarchy_knowledge_items <- function(survey, wave) {
  key <- c(A = 2, B = 2, C = 1, D = 2, E = 1, F = 1, G = 2, H = 1)
  items <- purrr::imap(key, function(correct, item) {
    prefix <- if (wave == 1L) "Q" else "R"
    value <- read_source_codes(survey, paste0(prefix, "5", item), c(-1, 1:4))
    as.numeric(value %in% correct)
  })
  prefix <- if (wave == 1L) "Q" else "R"
  succession <- read_source_codes(survey, paste0(prefix, "8A"), c(-1, 1:9))
  items$succession <- as.numeric(succession %in% 5)
  as.matrix(tibble::as_tibble(items))
}

monarchy_demographics <- function(survey) {
  school <- read_source_codes(survey, "B12A", 1:6)
  qualification <- read_source_codes(survey, "B12B", 1:14)
  education <- dplyr::case_when(
    qualification %in% 7:11 ~ 1,
    qualification %in% 4:6 ~ .66,
    school %in% 4:5 ~ .33,
    school %in% 1:3 ~ 0,
    .default = school
  )
  age_band <- read_source_codes(survey, "AGEB", 2:11)
  age_midpoints <- c(18.5, 25, 35, 45, 55, 65, 74, 83)
  age <- dplyr::coalesce(age_midpoints[match(age_band, 2:9)], age_band)
  tibble::tibble(
    female = as.numeric(read_source_codes(survey, "SEX", 1:2) != 1),
    minority = as.numeric(read_source_codes(survey, "B16", 1:8) != 1),
    age = age,
    education_four = education,
    education_three = collapse_historical_education(education),
    higher_education = as.numeric(education >= .33),
    political_interest_t1 = recode_source_values(survey, "A6",
      c(1, .66, .33, 0, NA_real_, 6)
    )
  )
}

build_monarchy_individual <- function(
  survey = read_poll_survey("uk-monarchy-1996")
) {
  attitudes <- purrr::map(1:2, \(wave) monarchy_attitudes(survey, wave)) |>
    purrr::list_cbind()
  knowledge <- summarise_historical_knowledge(
    monarchy_knowledge_items(survey, 1L), monarchy_knowledge_items(survey, 2L)
  )
  baseline <- attitudes |> dplyr::select(dplyr::ends_with("_t1"))
  dplyr::bind_cols(attitudes, monarchy_demographics(survey), knowledge) |>
    dplyr::mutate(
      attitude_extremity = historical_available_mean(abs(
        as.matrix(baseline) - .5
      )),
      household_income = NA_real_, high_income = NA_real_,
      read_briefing = NA_real_, knowledge_joint_midterm = NA_real_,
      knowledge_midterm = NA_real_, knowledge_midterm_joint = NA_real_,
      attitude_extremity_midterm = NA_real_
    )
}
