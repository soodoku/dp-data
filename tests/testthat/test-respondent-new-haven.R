source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "respondent_new_haven.R"))

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
  expect_equal(colSums(airport == as_historical_float(.625)),
               c(12, 12, 5))
  expect_equal(round(2 * colMeans(airport) - 1, 3),
               c(.540, .426, .434))
  expect_equal(sum(airport == as_historical_float(.675)), 0L)
  zero_q12 <- match(c(3022, 3248), survey$assigned)
  expect_equal(airport[zero_q12, 2], c(.5, .5))
  zero_q20 <- match(3169, survey$assigned)
  expect_equal(new_haven_attitudes(survey, "mid")$voluntary_sharing[
    zero_q20
  ], .6875)
  all_zero_post <- match(3124, survey$assigned)
  expect_equal(unlist(built[all_zero_post, c(
    "airport_expansion_t2", "mandatory_sharing_t2",
    "voluntary_sharing_t2"
  )], use.names = FALSE), c(.5, .5, .5))
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
