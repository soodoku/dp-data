new_haven_test_survey <- function() {
  arrow::read_parquet(project_path("data", "new-haven-2004", "survey.parquet"))
}

test_that("New Haven uses original responses with stable source identities", {
  survey <- new_haven_test_survey()
  expected <- build_new_haven_individual(survey)
  expect_equal(nrow(expected), 132L)
  expect_false(anyDuplicated(survey$assigned) > 0L)
  order <- rev(seq_len(nrow(survey)))
  expect_equal(build_new_haven_individual(survey[order, ]), expected[order, ])
  expect_equal(build_new_haven_individual(survey[1:12, ]), expected[1:12, ])
  survey$post_q35[1] <- 99
  expect_error(build_new_haven_individual(survey), "Unreviewed source codes")
})

test_that("New Haven airport scale preserves valid response categories", {
  survey <- new_haven_test_survey()
  built <- build_new_haven_individual(survey)
  expect_equal(sum(is.na(built$age)), 3L)
  expect_true(all(is.na(built$age[survey$pre_q62 == 1890])))
  airport <- cbind(
    built$airport_expansion_t1,
    new_haven_attitudes(survey, "mid")$airport_expansion,
    built$airport_expansion_t2
  )
  expect_equal(colSums(!is.na(airport)), c(122, 120, 122))
  expect_equal(colSums(airport == as_historical_float(.625), na.rm = TRUE),
               c(11, 11, 5))
  expect_equal(round(2 * colMeans(airport, na.rm = TRUE) - 1, 3),
               c(.588, .477, .473))
  expect_equal(sum(airport == as_historical_float(.675), na.rm = TRUE), 0L)
  zero_q12 <- match(c(3022, 3248), survey$assigned)
  expect_true(all(is.na(airport[zero_q12, 2])))
  zero_q20 <- match(3169, survey$assigned)
  expect_true(is.na(new_haven_attitudes(survey, "mid")$voluntary_sharing[
    zero_q20
  ]))
  all_zero_post <- match(3124, survey$assigned)
  expect_true(all(is.na(unlist(built[all_zero_post, c(
    "airport_expansion_t2", "mandatory_sharing_t2",
    "voluntary_sharing_t2"
  )], use.names = FALSE))))
  expect_equal(sum(!is.na(built$attitude_extremity)), 100L)
  expect_equal(sum(!is.na(built$attitude_extremity_midterm)), 114L)
  expect_equal(sum(survey$pre_q70 == 5), 4L)
  expect_true(all(is.na(built$minority[survey$pre_q70 == 5])))
  expect_true(all(built$minority[survey$pre_q70 == 3] == 0))
  expect_true(all(built$minority[survey$pre_q70 %in% c(1, 2, 4)] == 1))
})

test_that("New Haven public workbook reproduces the raw projection", {
  source(project_path("R", "source_new_haven.R"), local = TRUE)
  path <- project_path("data", "new-haven-2004", "source-materials",
    "survey-waves.xlsx"
  )
  expect_equal(read_new_haven_workbook(path), new_haven_test_survey())
})

test_that("zero is recorded as nonresponse on New Haven attitude items", {
  responses <- arrow::read_parquet(project_path(
    "output", "respondent", "source_responses.parquet"
  ))
  zero <- responses[
    responses$poll_id == "new-haven-2004" &
      responses$source_column %in% paste0(
        rep(c("pre", "mid", "post"), each = 6L), "_q",
        rep(c(12, 13, 20, 21, 22, 23), 3L)
      ) & !is.na(responses$raw_numeric) & responses$raw_numeric == 0,
  ]
  expect_equal(nrow(zero), 9L)
  expect_true(all(zero$response_status == "non-substantive"))
  expect_true(all(zero$missing_code == "0"))
})

test_that("New Haven attitude nonanswers agree with substantive input counts", {
  contract <- read_metadata("respondent_sources")
  built <- build_poll_respondents(
    contract[contract$poll_id == "new-haven-2004", ]
  )
  fields <- paste0(
    rep(c("pre", "mid", "post"), each = 6L), "_q",
    rep(c(12, 13, 20, 21, 22, 23), 3L)
  )
  answers <- built$source_responses[
    built$source_responses$source_column %in% fields,
  ]
  dk <- answers[!is.na(answers$raw_numeric) & answers$raw_numeric == 6, ]
  expect_equal(nrow(dk), 118L)
  expect_equal(table(sub("_.*$", "", dk$source_column)),
    table(rep(c("pre", "mid", "post"), c(64L, 25L, 29L)))
  )
  expect_true(all(dk$response_status == "non-substantive"))
  expect_true(all(dk$missing_code == "6"))
  substantive <- answers[
    !is.na(answers$raw_numeric) & answers$raw_numeric %in% 1:5,
  ]
  expect_true(all(substantive$response_status == "answered"))
  expect_true(all(is.na(substantive$missing_code)))

  proposal <- readr::read_csv(project_path(
    "audit", "corrections", "new-haven-2004", "observed_input_counts.csv"
  ), show_col_types = FALSE, col_types = readr::cols(
    respondent_id = readr::col_character(), value_numeric = readr::col_double(),
    .default = readr::col_guess()
  ))
  expect_equal(nrow(proposal), 122L)
  expect_equal(dplyr::n_distinct(proposal$respondent_id), 43L)
  key <- function(x) paste(x$respondent_id, x$definition_id)
  observed <- built$respondent_measures[
    match(key(proposal), key(built$respondent_measures)),
  ]
  expect_equal(observed$n_observed_fields, proposal$proposed)
  expect_equal(observed$value_numeric, proposal$value_numeric)
  expect_true(all(is.na(observed$value_numeric)))

  survey <- new_haven_test_survey()
  inputs <- read_metadata("measure_inputs")
  inputs <- inputs[inputs$poll_id == "new-haven-2004", ]
  definitions <- unique(proposal$definition_id)
  rows <- match(built$people$source_row, survey$source_row)
  for (definition in definitions) {
    columns <- inputs$source_column[inputs$definition_id == definition]
    raw <- as.matrix(survey[rows, columns])
    expected <- rowSums(!is.na(raw) & raw >= 1 & raw <= 5)
    values <- built$respondent_measures[
      built$respondent_measures$definition_id == definition,
    ]
    expect_equal(values$n_source_fields, rep(length(columns), nrow(survey)))
    expect_equal(values$n_observed_fields, expected)
  }
})
