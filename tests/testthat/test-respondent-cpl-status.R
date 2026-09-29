source(file.path(root, "R", "respondents.R"))

test_that("CPL codebook nonanswers do not count as observed attitude inputs", {
  contract <- read_metadata("respondent_sources")
  built <- build_poll_respondents(contract[contract$poll_id == "cpl-1996", ])
  fields <- grep(paste0(
    "^(resch|fedrch|addfac|reduce|lowinc|poor|renew|wind|",
    "fuels|buypwr|compet)[12]$"
  ), built$source_responses$source_column, value = TRUE)
  answers <- built$source_responses[
    built$source_responses$source_column %in% fields,
  ]
  dk <- answers[!is.na(answers$raw_numeric) & answers$raw_numeric == 99, ]
  expect_equal(nrow(dk), 1001L)
  expect_equal(dplyr::n_distinct(dk$respondent_id), 498L)
  expect_true(all(dk$response_status == "non-substantive"))
  expect_true(all(dk$missing_code == "99"))
  substantive <- answers[
    !is.na(answers$raw_numeric) & answers$raw_numeric != 99,
  ]
  expect_true(all(substantive$response_status == "answered"))
  expect_true(all(is.na(substantive$missing_code)))
  expect_true(any(substantive$raw_numeric == 0))
  expect_true(any(substantive$raw_numeric == 10))

  survey <- read_poll_survey("cpl-1996")
  inputs <- read_metadata("measure_inputs")
  inputs <- inputs[inputs$poll_id == "cpl-1996", ]
  definitions <- unique(inputs$definition_id[inputs$source_column %in% fields])
  for (definition in definitions) {
    columns <- inputs$source_column[inputs$definition_id == definition]
    raw <- as.matrix(survey[, columns])
    expected <- rowSums(!is.na(raw) & !raw %in% c(99, 999))
    values <- built$respondent_measures[
      built$respondent_measures$definition_id == definition,
    ]
    expect_equal(values$n_source_fields, rep(length(columns), nrow(survey)))
    expect_equal(values$n_observed_fields, expected)
  }
})
