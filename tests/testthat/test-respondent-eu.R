test_that("UK EU uses the same substantive scale across waves", {
  survey <- read_poll_survey("uk-eu-1995")
  observed <- as.numeric(survey$part) == 1 &
    as.numeric(survey$releu2) %in% 1:5
  survey <- survey[which(observed)[1:5], ]
  for (stem in c("commies", "favref")) {
    for (wave in 1:2) survey[[paste0(stem, wave)]] <- 1:5
  }
  result <- build_eu_individual(survey)
  for (field in c(
    "ukeu.commies1r", "ukeu.commies2r", "ukeu.favref1r", "ukeu.favref2r"
  )) expect_equal(result[[field]], c(0, .25, .5, .75, 1))
  single <- build_eu_individual(survey[3L, ])
  expect_equal(single$ukeu.commies1r, .5)
  expect_equal(single$ukeu.favref1r, .5)
})

test_that("UK EU baseline nonanswers never become maximum support", {
  survey <- read_poll_survey("uk-eu-1995")
  result <- build_eu_individual(survey)
  for (stem in c("commies", "favref")) {
    raw <- as.numeric(survey[[paste0(stem, "1")]])
    score <- result[[paste0("ukeu.", stem, "1r")]]
    expect_true(all(is.na(score[raw == 9])))
    expect_true(all(score[raw == 5] == 1))
  }
  expect_equal(sum(is.na(result$ukeu.commies1r)), 12L)
  expect_equal(sum(is.na(result$ukeu.favref1r)), 4L)
  expect_equal(sum(is.na(result$attextreme)), 2L)
  expect_true(all(is.na(result$minority[survey$ethnic == 8])))
})

test_that("UK EU respondent corrections match independently reviewed values", {
  reference <- readr::read_csv(project_path(
    "audit", "corrections", "uk-eu-1995", "baseline_scale_approved_values.csv"
  ), show_col_types = FALSE)
  reference <- dplyr::filter(reference, .data$cohort == "all_source")
  result <- build_eu_individual(read_poll_survey("uk-eu-1995"))
  for (field in unique(reference$field)) {
    expected <- reference[reference$field == field, ]
    positions <- match(expected$caseid, result$caseid)
    expect_false(anyNA(positions))
    expect_equal(result[[field]][positions], expected$proposed_value)
  }
})
