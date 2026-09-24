source(file.path(root, "R", "respondents.R"))

test_that("Bulgaria builds from raw answers without stored indices", {
  survey <- read_poll_survey("bulgaria-crime-2002")
  expected <- build_bulgaria_individual(survey)
  raw <- survey[, !grepl("^t[12]", names(survey))]
  expect_equal(build_bulgaria_individual(raw), expected)
  order <- rev(seq_len(nrow(raw)))
  expect_equal(build_bulgaria_individual(raw[order, ]), expected[order, ])
  raw$q15_1[1] <- 7
  expect_error(build_bulgaria_individual(raw), "Unreviewed source codes")
})

test_that("Bulgaria Version E is reconstructed at original float precision", {
  survey <- read_poll_survey("bulgaria-crime-2002")
  for (wave in 1:2) {
    built <- bulgaria_attitudes(survey, wave)
    expect_equal(built$civil_liberties,
                 as.numeric(survey[[paste0("t", wave, "clibe")]]))
    expect_equal(built$tougher_punishment,
                 as.numeric(survey[[paste0("t", wave, "tghpc")]]))
  }
})

test_that("Bulgaria reproduces all historical respondent targets", {
  audit <- readr::read_csv(project_path("audit", "respondent_parity.csv"),
    show_col_types = FALSE
  )
  rows <- audit[audit$poll_id == "bulgaria-crime-2002", ]
  expect_equal(nrow(rows), 51L)
  expect_true(all(rows$respondents == 278L))
  expect_true(all(rows$value_differences == 0L))
  expect_true(all(rows$missingness_differences == 0L))
})
