crime_attitudes <- function(survey, wave) {
  average <- function(stems, reversed = character()) {
    values <- purrr::map(stems, function(stem) {
      field <- paste0(stem, wave)
      value <- read_source_codes(survey, field, 1:5)
      if (stem %in% reversed) (5 - value) / 4 else (value - 1) / 4
    })
    historical_available_mean(do.call(cbind, values))
  }
  tibble::tibble(
    root_causes = average(c("timchld", "violtv", "schdisc")),
    policing = average(c("morecop", "copgun")),
    punishment = average(
      c(
        "punref", "stiffer", "morprsn", "refpris", "s_tough", "fewpris",
        "pr_only", "outprsn", "comserv", "milserv", "train", "ptough",
        "life", "lifmean", "death"
      ),
      reversed = c(
        "refpris", "fewpris", "pr_only", "outprsn", "comserv",
        "train"
      )
    ),
    procedural_restrictions = average(
      c(
        "innglt", "copbend", "fewjury", "ctrules", "presum", "mentsil",
        "rtsil", "confess"
      ),
      reversed = c("rtsil", "confess")
    ),
    self_protection = average(c("propsec", "watch", "patrols"))
  ) |>
    dplyr::rename_with(\(name) paste0(name, "_t", wave))
}

crime_knowledge_items <- function(survey, wave) {
  key <- c(kw1 = 0, kw2 = 1, kw3 = 1, kw4 = 0, pkw1 = 0, pkw2 = 0, pkw3 = 0)
  purrr::imap(key, function(correct, stem) {
    value <- read_source_codes(survey, paste0(stem, wave), c(0:1, 8:9))
    as.numeric(value %in% correct)
  }) |>
    tibble::as_tibble() |>
    as.matrix()
}

build_crime_individual <- function(survey = read_poll_survey("uk-crime-1994")) {
  attitudes <- purrr::map(1:2, \(wave) crime_attitudes(survey, wave)) |>
    purrr::list_cbind()
  knowledge <- summarise_historical_knowledge(
    crime_knowledge_items(survey, 1L), crime_knowledge_items(survey, 2L)
  )
  education_code <- read_source_codes(survey, "educ7", 0:6)
  education <- c(0, 0, .33, .33, .66, .66, 1)[match(education_code, 0:6)]
  baseline <- attitudes |> dplyr::select(dplyr::ends_with("_t1"))
  demographics <- tibble::tibble(
    female = as.numeric(read_source_codes(survey, "sex", 0:1) == 0),
    minority = read_source_codes(survey, "nonwhite", 0:1),
    age = read_source_codes(survey, "age", 18:120),
    education_four = education,
    education_three = collapse_historical_education(education),
    higher_education = as.numeric(education >= .66)
  )
  dplyr::bind_cols(attitudes, demographics, knowledge) |>
    dplyr::mutate(
      attitude_extremity = historical_available_mean(abs(
        as.matrix(baseline) - .5
      )),
      household_income = NA_real_, high_income = NA_real_,
      political_interest_t1 = NA_real_, read_briefing = NA_real_,
      knowledge_joint_midterm = NA_real_, knowledge_midterm = NA_real_,
      knowledge_midterm_joint = NA_real_, attitude_extremity_midterm = NA_real_,
      # UKC-03: the deposited export omits the script's issue-specific scores.
      knowledge_issue_t1 = NA_real_, knowledge_issue_t2 = NA_real_,
      knowledge_issue_joint = NA_real_, knowledge_issue_gain = NA_real_,
      knowledge_issue_gain_joint = NA_real_
    )
}
