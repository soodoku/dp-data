election_attitudes <- function(survey, wave) {
  stems <- c(redistribution = "redstr", tax = "taxr",
    minimum_wage = "wager", european_union = "eur"
  )
  indices <- purrr::map(stems, function(stem) {
    field <- paste0(stem, wave)
    recode_source_values(survey, field,
      c(0, .17, .33, .5, .67, .83, 1), missing = c(-9, -8)
    ) |>
      as_historical_float()
  })
  tibble::as_tibble(indices) |>
    dplyr::rename_with(\(name) paste0(name, "_t", wave))
}

election_knowledge_items <- function(survey, wave) {
  factual_key <- c(inflat = 1, intrst = 2, ukempl = 2)
  facts <- purrr::imap(factual_key, function(correct, stem) {
    value <- read_source_codes(survey, paste0(stem, wave), c(-9, -8, 1:2))
    as.numeric(value %in% correct)
  }) |> tibble::as_tibble()
  placements <- purrr::map(c("c", "l", "ld"), function(party) {
    stems <- c("redst", "tax", "wage", "eu")
    items <- purrr::map(stems, function(stem) {
      field <- paste0(stem, party, wave)
      value <- read_source_codes(survey, field, c(-9, -8, 1:7))
      correct <- if (party == "c") value %in% 1:3 else value %in% 5:7
      as.numeric(correct)
    })
    names(items) <- paste0(stems, "_", party)
    tibble::as_tibble(items)
  }) |> purrr::list_cbind()
  as.matrix(dplyr::bind_cols(facts, placements))
}

election_demographics <- function(survey) {
  school <- read_source_codes(survey, "educa", c(-9, 0:4))
  qualification <- read_source_codes(survey, "educb", c(-9, 0:12))
  education <- dplyr::case_when(
    qualification %in% 7:11 ~ 1,
    qualification %in% 4:6 ~ .66,
    school %in% 3:4 ~ .33,
    school %in% 0:2 ~ 0,
    .default = NA_real_
  )
  ethnic <- read_source_codes(survey, "ethnic", c(-7, 1:8))
  age <- read_source_codes(survey, "age", c(-7, 18:110))
  income <- recode_source_values(survey, "income",
    c(rep(1, 4), rep(2, 4), rep(3, 4), rep(4, 3), 5), c(-9, -8)
  )
  tibble::tibble(
    female = as.numeric(read_source_codes(survey, "gender", 0:1) == 0),
    minority = dplyr::if_else(ethnic == -7, NA_real_, as.numeric(ethnic != 1)),
    age = dplyr::na_if(age, -7),
    education_four = education,
    education_three = collapse_historical_education(education),
    higher_education = as.numeric(education >= .33),
    household_income = income,
    high_income = as.numeric(income > 2),
    political_interest_t1 = recode_source_values(survey, "int1",
      c(0, .33, .66, 1, 1), c(-9, -8)
    )
  )
}

build_election_individual <- function(
  survey = read_poll_survey("uk-general-election-1997")
) {
  attitudes <- purrr::map(1:2, \(wave) election_attitudes(survey, wave)) |>
    purrr::list_cbind()
  before <- election_knowledge_items(survey, 1L)
  after <- election_knowledge_items(survey, 2L)
  # Preserve the stored factual subscale's float precision before weighting.
  factual_score <- as_historical_float(rowMeans(before[, 1:3, drop = FALSE]))
  placement_score <- rowSums(before[, 4:15, drop = FALSE]) / 4
  knowledge <- summarise_historical_knowledge(before, after,
    baseline = placement_score * (4 / 15) + factual_score * (3 / 15)
  )
  baseline <- attitudes |> dplyr::select(dplyr::ends_with("_t1"))
  dplyr::bind_cols(attitudes, election_demographics(survey), knowledge) |>
    dplyr::mutate(
      attitude_extremity = historical_available_mean(abs(
        as.matrix(baseline) - .5
      )),
      read_briefing = NA_real_, knowledge_joint_midterm = NA_real_,
      knowledge_midterm = NA_real_, knowledge_midterm_joint = NA_real_,
      attitude_extremity_midterm = NA_real_
    )
}
