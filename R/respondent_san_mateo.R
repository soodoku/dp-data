san_mateo_attitudes <- function(survey, wave) {
  items <- c(
    more_housing = 1, open_space = 2, less_commuting = 3,
    below_market_housing = 4, consultation = 7, county_local = 8,
    county_state = 9
  )
  purrr::imap(items, function(item, name) {
    field <- paste0(if (wave == 2L) "t2" else "", "Q", item)
    allowed <- if (item == 7) 0:10 else 1:7
    value <- btp_source_codes(survey, field, c(allowed, 99))
    value[value == 99 & !is.na(value)] <- NA_real_
    value <- if (item == 7) value / 10 else (value - 1) / 6
    if (name %in% c("more_housing", "below_market_housing", "county_state")) {
      value <- 1 - value
    }
    as_historical_float(round(value, 7))
  }) |> tibble::as_tibble()
}

san_mateo_knowledge <- function(survey, wave) {
  keys <- c(
    `19` = 3, `20` = 5, `21` = 1, `22` = 3, `23` = 4,
    `24` = 3, `25` = 1, `26` = 5
  )
  purrr::imap(keys, function(correct, item) {
    field <- paste0(if (wave == 2L) "t2" else "", "Q", item)
    value <- btp_source_codes(survey, field, c(1:6, 8, 9))
    as.numeric(value %in% correct)
  }) |>
    tibble::as_tibble() |>
    as.matrix()
}

san_mateo_historical_ids <- function(
  survey,
  reference = read_poll_survey("san-mateo-2008")
) {
  selected <- btp_source_codes(reference, "participant", 0:1) %in% 1
  ids <- sort(reference$PARTICIPANTID[selected])
  stopifnot(!anyNA(ids), !anyDuplicated(ids))
  as.character(960000 + match(survey$PARTICIPANTID, ids))
}

build_san_mateo_individual <- function(
  survey = read_poll_survey("san-mateo-2008")
) {
  before <- san_mateo_attitudes(survey, 1L)
  after <- san_mateo_attitudes(survey, 2L)
  education <- btp_source_codes(survey, "Q128", 1:7)
  education <- c(0, .33, .66, 1, 1, 1, NA_real_)[education]
  income <- btp_source_codes(survey, "Q131", 1:7)
  deviations <- purrr::map_dfc(
    before,
    \(value) as_historical_float(abs(value - .5))
  )
  extremity <- as_historical_float(
    rowMeans(as.matrix(deviations), na.rm = TRUE)
  )
  extremity[is.nan(extremity)] <- NA_real_
  dplyr::bind_cols(
    dplyr::rename_with(before, \(name) paste0(name, "_t1")),
    dplyr::rename_with(after, \(name) paste0(name, "_t2")),
    btp_float_knowledge(
      san_mateo_knowledge(survey, 1L),
      san_mateo_knowledge(survey, 2L)
    ),
    tibble::tibble(
      age = 2008 - btp_source_codes(survey, "Q129", 1900:2008),
      female = as.numeric(btp_source_codes(survey, "Q135", 1:2) == 2),
      minority = as.numeric(btp_source_codes(survey, "Q132", 1:7) != 1),
      education_four = education,
      education_three = collapse_historical_education(education),
      higher_education = as.numeric(education == 1),
      household_income = income, high_income = as.numeric(income > 4),
      attitude_extremity = extremity,
      read_briefing = (btp_source_codes(survey, "t2q37", 1:5) - 1) / 4,
      political_interest_t1 = NA_real_,
      knowledge_joint_midterm = NA_real_, knowledge_midterm = NA_real_,
      knowledge_midterm_joint = NA_real_, attitude_extremity_midterm = NA_real_
    )
  )
}
