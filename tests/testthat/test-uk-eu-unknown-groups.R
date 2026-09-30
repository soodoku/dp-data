source(project_path("R", "respondents.R"))
source(project_path("R", "polardata_rebuild.R"))

testthat::test_that("UK EU unknown groups retain attendees without a cluster", {
  survey <- read_poll_survey("uk-eu-1995")
  unknown <- as.numeric(survey$group) %in% 99
  testthat::expect_setequal(
    as.numeric(survey$caseid)[unknown], c(1008, 3132, 4316, 5022)
  )
  testthat::expect_true(all(survey$part[unknown] == 1))
  profile <- core_poll_profile(survey, "uk-eu-1995")
  testthat::expect_true(all(is.na(profile$group[unknown])))
  known <- !is.na(survey$group) & !unknown
  testthat::expect_equal(profile$group[known], 2000 + survey$group[known],
    ignore_attr = TRUE
  )
  values <- historical_respondent_wide("uk-eu-1995")
  derived <- build_core_derived(survey, values, "uk-eu-1995")
  affected <- values$caseid %in% c(1008, 3132, 4316, 5022)
  testthat::expect_equal(nrow(values), 238L)
  testthat::expect_equal(sum(affected), 4L)
  testthat::expect_true(all(!is.na(values$t1know[affected])))
  testthat::expect_true(all(!is.na(values$t2know[affected])))
  testthat::expect_equal(length(unique(stats::na.omit(derived$pollgroup))), 15L)
  testthat::expect_equal(sum(!is.na(derived$pollgroup)), 234L)
  group_fields <- c(
    "pollgroup", "groupsize", "pfemale", "pfemale_ind", "pminority",
    "meanage", "meaned", "entropy", "avgsd", "genvar", "meant1know",
    "meant2know", "meant1know_ind", "grpgain", "grpgainr"
  )
  testthat::expect_true(all(is.na(derived[affected, group_fields])))
  known_group <- profile$group[match(values$source_row, survey$source_row)]
  expected_size <- as.numeric(table(known_group)[as.character(known_group)])
  testthat::expect_equal(derived$groupsize, expected_size)
  testthat::expect_equal(derived$meant1know,
    historical_group_summary(values$t1know, known_group)
  )
})
