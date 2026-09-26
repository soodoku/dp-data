btp_health_item <- function(survey, field, rule = "ten") {
  codes <- switch(rule,
    ten = c(0:10, 77),
    binary = c(1:2, 7),
    reverse_binary = c(1:2, 7),
    three = c(1:3, 7),
    cost = c(1:3, 7),
    five = c(1:5, 7),
    reverse_five = c(1:5, 7)
  )
  value <- btp_source_codes(survey, field, codes)
  value[value %in% c(7, 77) & rule != "ten"] <- NA_real_
  if (rule == "ten") value[value == 77 & !is.na(value)] <- NA_real_
  answer <- switch(rule,
    ten = value / 10,
    binary = value - 1,
    reverse_binary = 2 - value,
    three = (value - 1) / 2,
    cost = c(.5, 1, 0)[value],
    five = (value - 1) / 4,
    reverse_five = (5 - value) / 4
  )
  as_historical_float(answer)
}

btp_health_mean <- function(...) {
  value <- rowMeans(cbind(...), na.rm = TRUE)
  value[is.nan(value)] <- NA_real_
  as_historical_float(value)
}

btp_health_alpha <- function(...) {
  items <- cbind(...)
  count <- rowSums(!is.na(items))
  items[is.na(items)] <- 0
  total <- rep(0, nrow(items))
  for (column in seq_len(ncol(items))) {
    total <- as_historical_float(total + items[, column])
  }
  value <- as_historical_float(total / count)
  value[count == 0] <- NA_real_
  value
}

btp_health_attitudes <- function(survey, wave) {
  field <- function(pre, post) if (wave == 1L) pre else post
  item <- function(pre, post, rule = "ten") {
    btp_health_item(survey, field(pre, post), rule)
  }
  tibble::tibble(
    reform = item("q3", "q3post", "reverse_binary"),
    school_choice = btp_health_mean(
      item("q7_a", "q7post_a"),
      item("q7_b", "q7post_b")
    ),
    school_funding = btp_health_mean(
      item("q7_c", "q7post_c"),
      item("q7_d", "q7post_d"), item("q7_e", "q7post_e"),
      item("q7_f", "q7post_f"), item("q8_f", "q8post_f")
    ),
    standardized_testing = btp_health_mean(
      1 - item("q4", "q4post", "three"), item("q5", "q5post_m")
    ),
    local_testing = item("q6", "q6post", "binary"),
    no_child_left_behind = item("q12", "q12post", "reverse_five"),
    government_involvement = btp_health_alpha(
      item("q24a", "q24apost", "five"), item("q24f", "q24fpost", "five")
    ),
    medical_quality = btp_health_alpha(
      item("q19_d", "q19pos_c"),
      item("q19_e", "q19pos_d"), item("q19_f", "q19pos_e")
    ),
    cost_coverage = btp_health_alpha(
      item("q19_a", "q19post"),
      item("q19_b", "q19pos_a"), item("q19_c", "q19pos_b"),
      item("q23", "q23post", "cost")
    ),
    employer_payment = item("q24b", "q24bpost", "five"),
    individual_payment = item("q24c", "q24cpost", "five")
  )
}

btp_health_knowledge <- function(survey, wave) {
  keys <- c(q15 = 2, q16 = 1, q17 = 1, q26 = 3, q27 = 3, q28 = 3)
  purrr::imap(keys, function(correct, item) {
    field <- paste0(item, if (wave == 2L) "post" else "")
    value <- btp_source_codes(survey, field, c(1:5, 7))
    as.numeric(value %in% correct)
  }) |>
    tibble::as_tibble() |>
    as.matrix()
}

build_btp_health_individual <- function(
  survey = read_poll_survey("btp-health-education-2005")
) {
  before <- btp_health_attitudes(survey, 1L)
  after <- btp_health_attitudes(survey, 2L)
  education <- btp_source_codes(survey, "educ", 1:6)
  education <- c(0, .33, .66, .66, 1, 1)[education]
  age <- 2005 - btp_source_codes(survey, "birthyr", c(1900:2005, 9999))
  age[age < 0 & !is.na(age)] <- NA_real_
  deviations <- purrr::map_dfc(before, function(value) {
    as_historical_float(abs(value - .5))
  })
  extremity <- as_historical_float(rowMeans(as.matrix(deviations),
    na.rm = TRUE
  ))
  extremity[is.nan(extremity)] <- NA_real_
  dplyr::bind_cols(
    dplyr::rename_with(before, \(name) paste0(name, "_t1")),
    dplyr::rename_with(after, \(name) paste0(name, "_t2")),
    btp_float_knowledge(
      btp_health_knowledge(survey, 1L),
      btp_health_knowledge(survey, 2L)
    ),
    tibble::tibble(
      age = age,
      female = as.numeric(btp_source_codes(survey, "gender", 1:2) == 2),
      minority = as.numeric(btp_source_codes(survey, "race", 1:7) != 1),
      education_four = education,
      education_three = collapse_historical_education(education),
      higher_education = as.numeric(education == 1),
      household_income = NA_real_, high_income = NA_real_,
      attitude_extremity = extremity,
      read_briefing = NA_real_,
      political_interest_t1 = as_historical_float(c(0, .33, .66, 1)[
        btp_source_codes(survey, "q40", 1:4)
      ]),
      knowledge_joint_midterm = NA_real_, knowledge_midterm = NA_real_,
      knowledge_midterm_joint = NA_real_, attitude_extremity_midterm = NA_real_
    )
  )
}
