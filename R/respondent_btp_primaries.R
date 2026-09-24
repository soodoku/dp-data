primaries_sample <- function(survey) {
  treatment <- read_source_codes(survey, "expcont", 0:1)
  attendance <- read_source_codes(survey, "mtgatt", 0:5)
  groups <- read_source_codes(survey, "groupnumc", 1:16)
  post <- paste0("f1q", 43:49)
  stopifnot(all(post %in% names(survey)))
  selected <- treatment == 1 & !is.na(groups) & attendance >= 3 &
    rowSums(!is.na(survey[post])) > 0
  selected[is.na(selected)] <- FALSE
  selected
}

primaries_knowledge_items <- function(survey, wave) {
  keys <- c(`43` = 1, `44` = 3, `45` = 2, `46` = 4,
    `47` = 3, `48` = 2, `49` = 1
  )
  purrr::imap(keys, function(key, item) {
    value <- read_source_codes(survey, paste0(wave, "q", item), c(-2:-1, 1:5))
    ifelse(is.na(value), NA_real_, as.numeric(value == key))
  }) |>
    tibble::as_tibble() |>
    as.matrix()
}

primaries_attitudes <- function(survey, wave) {
  scale_seven <- function(item) {
    value <- read_source_codes(survey, paste0(wave, "q", item), c(-2:-1, 1:8))
    as_historical_float(c(0, .167, .333, .5, .667, .833, 1)[match(value, 1:7)])
  }
  share <- recode_source_values(survey, paste0(wave, "q2"),
    c(1, .75, .5, .25, 0), c(-2:-1, 6)
  )
  invade <- recode_source_values(survey, paste0(wave, "q3"),
    c(0, .25, .5, .75, 1), c(-2:-1, 6)
  )
  multilateralism <- as_historical_float(rowMeans(
    cbind(share, invade, scale_seven(29)), na.rm = TRUE
  ))
  multilateralism[is.nan(multilateralism)] <- NA_real_
  tibble::tibble(trade = scale_seven(31),
    multilateralism = multilateralism, services = scale_seven(25)
  )
}

build_btp_primaries_individual <- function(
  survey = read_poll_survey("btp-presidential-primaries-2004")) {
  before <- primaries_knowledge_items(survey, "b1")
  after <- primaries_knowledge_items(survey, "f1")
  joint <- before
  joint[!is.na(after) & after == 0] <- 0
  knowledge <- tibble::tibble(
    knowledge_t1 = as_historical_float(rowMeans(before, na.rm = TRUE)),
    knowledge_t2 = as_historical_float(rowMeans(after, na.rm = TRUE)),
    knowledge_joint = as_historical_float(rowMeans(joint, na.rm = TRUE))
  )
  knowledge[is.na(knowledge)] <- NA_real_
  knowledge <- dplyr::mutate(knowledge,
    knowledge_gain = .data$knowledge_t2 - .data$knowledge_t1,
    knowledge_gain_joint = .data$knowledge_t2 - .data$knowledge_joint,
    log_knowledge_joint = historical_log_score(.data$knowledge_joint),
    high_knowledge_joint = as.numeric(.data$knowledge_joint > .6)
  )
  baseline <- primaries_attitudes(survey, "b1")
  post <- primaries_attitudes(survey, "f1")
  education <- recode_source_values(survey, "ppeduc",
    c(0, 0, .33, .66, .66, 1, 1, 1, 1), -2:-1
  )
  income <- read_source_codes(survey, "ppincimp", c(-2:-1, 1:19))
  household_income <- income
  dplyr::bind_cols(
    dplyr::rename_with(baseline, \(name) paste0(name, "_t1")),
    dplyr::rename_with(post, \(name) paste0(name, "_t2")), knowledge,
    tibble::tibble(
      age = read_source_codes(survey, "ppage", 0:100),
      female = recode_source_values(survey, "ppgender", c(0, 1), -2:-1),
      minority = recode_source_values(survey, "ppeth", c(0, 1, 1, 1), -2:-1),
      education_four = education,
      education_three = collapse_historical_education(education),
      higher_education = as.numeric(education >= .66),
      household_income = household_income,
      high_income = as.numeric(household_income > 11),
      political_interest_t1 = recode_source_values(survey, "b1q18",
        as_historical_float(c(0, .33, .66, 1)), -2:-1
      ),
      read_briefing = NA_real_,
      attitude_extremity = as_historical_float(rowMeans(
        as.data.frame(lapply(baseline, \(x) as_historical_float(abs(x - .5)))),
        na.rm = TRUE
      )),
      knowledge_midterm = NA_real_, knowledge_midterm_joint = NA_real_,
      knowledge_joint_midterm = NA_real_, attitude_extremity_midterm = NA_real_
    )
  )
}
