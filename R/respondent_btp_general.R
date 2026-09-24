btp_source_codes <- function(survey, field, allowed) {
  if (!field %in% names(survey)) stop("Missing source field: ", field)
  value <- rounded_source_code(as.numeric(survey[[field]]))
  if (any(!is.na(value) & !value %in% allowed)) {
    stop("Unreviewed source codes in ", field)
  }
  value
}

btp_float_knowledge <- function(before, after) {
  baseline <- as_historical_float(rowMeans(before))
  post <- as_historical_float(rowMeans(after))
  joint <- as_historical_float(rowMeans(before * after))
  tibble::tibble(
    knowledge_t1 = baseline, knowledge_t2 = post, knowledge_joint = joint,
    knowledge_gain = post - baseline, knowledge_gain_joint = post - joint,
    log_knowledge_joint = historical_log_score(joint),
    high_knowledge_joint = as.numeric(joint > .6)
  )
}

augment_btp_general_source <- function(
  survey,
  raw_survey = haven::read_dta(project_path(
    "data", "btp-general-election-2004", "raw-responses.dta"
  ))
) {
  stopifnot(!anyDuplicated(raw_survey$caseid), !anyNA(raw_survey$caseid))
  index <- match(survey$caseid_original, raw_survey$caseid)
  if (anyNA(index)) stop("BTP election raw-response identity is missing")
  fields <- paste0(
    rep(c("w4b", "w4f"), each = 6),
    rep(c(42, 45, 48, 51, 54, 57), 2)
  )
  stopifnot(all(fields %in% names(raw_survey)))
  for (field in fields) {
    survey[[paste0("raw_", field)]] <- raw_survey[[field]][index]
  }
  survey
}

btp_general_knowledge <- function(survey, wave) {
  keys <- c(
    `60` = 1, `61` = 2, `62` = 2, `63` = 2, `64` = 2,
    `65` = 4, `66` = 2, `68` = 4, `69` = 3
  )
  purrr::imap(keys, function(correct, item) {
    allowed <- if (item %in% c("62", "63", "64")) -4:4 else -4:6
    value <- btp_source_codes(survey, paste0("w4", wave, item), allowed)
    as.numeric(value %in% correct)
  }) |>
    tibble::as_tibble() |>
    as.matrix()
}

btp_general_attitudes <- function(raw, wave) {
  items <- c(
    services = 42, military = 45, trade = 48, rights = 51,
    health_insurance = 54, marriage = 57
  )
  purrr::map(items, function(item) {
    value <- btp_source_codes(
      raw, paste0("raw_w4", wave, item), c(-4:-1, 1:7, 9)
    )
    value[!value %in% 1:7] <- NA_real_
    as_historical_float(round((value - 1) / 6, 5))
  }) |> tibble::as_tibble()
}

build_btp_general_individual <- function(
  survey = read_poll_survey("btp-general-election-2004"),
  raw_survey = NULL
) {
  if (!is.null(raw_survey)) {
    survey <- augment_btp_general_source(survey, raw_survey)
  } else if (!"raw_w4b42" %in% names(survey)) {
    survey <- augment_btp_general_source(survey)
  }
  before <- btp_general_attitudes(survey, "b")
  after <- btp_general_attitudes(survey, "f")
  education <- btp_source_codes(survey, "ppeducat", 1:4)
  education <- c(0, .33, .66, 1)[education]
  income <- btp_source_codes(survey, "ppincimp", 1:17)
  income <- c(1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 5:9, 10, 10)[income]
  extremity <- as_historical_float(rowMeans(abs(as.matrix(before) - .5),
    na.rm = TRUE
  ))
  extremity[is.nan(extremity)] <- NA_real_
  dplyr::bind_cols(
    dplyr::rename_with(before, \(name) paste0(name, "_t1")),
    dplyr::rename_with(after, \(name) paste0(name, "_t2")),
    btp_float_knowledge(
      btp_general_knowledge(survey, "b"),
      btp_general_knowledge(survey, "f")
    ),
    tibble::tibble(
      age = btp_source_codes(survey, "ppage", 18:100),
      female = as.numeric(btp_source_codes(survey, "ppgender", 1:2) == 2),
      minority = as.numeric(btp_source_codes(survey, "ppeth", 1:4) != 1),
      education_four = education,
      education_three = collapse_historical_education(education),
      higher_education = as.numeric(education >= .66),
      household_income = income, high_income = as.numeric(income > 5),
      attitude_extremity = extremity,
      read_briefing = NA_real_, political_interest_t1 = NA_real_,
      knowledge_joint_midterm = NA_real_, knowledge_midterm = NA_real_,
      knowledge_midterm_joint = NA_real_, attitude_extremity_midterm = NA_real_
    )
  )
}
