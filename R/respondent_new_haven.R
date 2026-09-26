new_haven_knowledge_items <- function(survey, wave) {
  keys <- c(
    `35` = 3, `36` = 2, `37` = 2, `39` = 3,
    `40` = 1, `41` = 1, `42` = 4, `43` = 1
  )
  purrr::imap(keys, function(key, item) {
    value <- read_source_codes(survey, paste0(wave, "_q", item), 0:6)
    as.numeric(value %in% key)
  }) |>
    tibble::as_tibble() |>
    as.matrix()
}

new_haven_attitudes <- function(survey, wave) {
  item <- function(question) {
    value <- read_source_codes(survey, paste0(wave, "_q", question), 0:6)
    value[is.na(value) | value == 6] <- 3
    scaled <- (5 - value) / 4
    if (wave == "mid") scaled[value == 0] <- 0
    scaled
  }
  airport <- (item(12) - item(13)) / 2 + .5
  if (wave == "mid") {
    unknown <- is.na(survey$mid_q12) | survey$mid_q12 == 6
    airport[unknown] <- .5
  }
  voluntary <- (item(21) + item(22)) / 2
  tibble::tibble(
    airport_expansion = as_historical_float(airport),
    mandatory_sharing = (item(23) - voluntary) / 2 + .5,
    voluntary_sharing = (voluntary - item(20)) / 2 + .5
  )
}

build_new_haven_individual <- function(
  survey = read_poll_survey("new-haven-2004")
) {
  before <- new_haven_knowledge_items(survey, "pre")
  after <- new_haven_knowledge_items(survey, "post")
  arrival <- new_haven_knowledge_items(survey, "mid")
  arrival_attitudes <- new_haven_attitudes(survey, "mid")
  knowledge <- summarise_historical_knowledge(before, after)
  baseline <- new_haven_attitudes(survey, "pre")
  post <- new_haven_attitudes(survey, "post")
  education <- recode_source_values(
    survey, "pre_q61",
    c(0, 0, .33, .66, 1, 1, .66), 8
  )
  income <- read_source_codes(survey, "pre_q69", c(1, 3:13))
  income <- match(income, c(1, 3:12))
  birth_year <- read_source_codes(survey, "pre_q62", 1800:2002)
  birth_year[birth_year == 1890 & !is.na(birth_year)] <- NA_real_
  race <- read_source_codes(survey, "pre_q70", 1:5)
  dplyr::bind_cols(
    dplyr::rename_with(baseline, \(name) paste0(name, "_t1")),
    dplyr::rename_with(post, \(name) paste0(name, "_t2")), knowledge,
    tibble::tibble(
      age = 2002 - birth_year,
      female = recode_source_values(survey, "pre_q72", c(0, 1)),
      minority = dplyr::case_when(
        race == 3 ~ 0,
        race %in% c(1, 2, 4) ~ 1,
        .default = NA_real_
      ),
      education_four = education,
      education_three = collapse_historical_education(education),
      higher_education = as.numeric(education == 1),
      household_income = as.numeric(income),
      high_income = as.numeric(income > 5),
      political_interest_t1 = NA_real_, read_briefing = NA_real_,
      attitude_extremity = as_historical_float(rowMeans(
        as.data.frame(lapply(baseline, \(x) as_historical_float(abs(x - .5))))
      )),
      knowledge_midterm = rowMeans(arrival),
      knowledge_midterm_joint = rowMeans(arrival * after),
      knowledge_joint_midterm = rowMeans(before * arrival * after),
      attitude_extremity_midterm = as_historical_float(rowMeans(
        as.data.frame(lapply(
          arrival_attitudes,
          \(x) as_historical_float(abs(x - .5))
        ))
      ))
    )
  )
}
