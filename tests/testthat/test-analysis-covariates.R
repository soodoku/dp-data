source(file.path(root, "R", "analysis_covariates.R"))

test_that("new demographic fields cover each additional grouped poll", {
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_participants.parquet"
  ))
  ids <- c(
    "btp-2007", "btp-online-primaries-2004", "california-whats-next-2011",
    "michigan-2009", "northern-ireland-2007", "america-in-one-room-2019",
    "a1r-climate-2021"
  )
  for (id in ids) {
    x <- people[people$poll_id == id & !is.na(people$small_group_id), ]
    expect_true(any(!is.na(x$age)), info = id)
    expect_true(any(!is.na(x$education)), info = id)
    expect_equal(x$ba, as.numeric(x$education == 1), info = id)
  }
  expect_true(all(is.na(people$age) | (people$age >= 16 & people$age <= 110)))
  expect_true(all(is.na(people$education) | people$education %in% c(0, .5, 1)))
  expect_true(all(is.na(people$read_briefing) |
    (people$read_briefing >= 0 & people$read_briefing <= 1)))
})

test_that("reading retains substantive 99 and rejects ambiguous codes", {
  btp <- tibble::tibble(
    source_row = 1:4, birthyr = c(1950, 1960, 9998, 9999),
    educ = c(1, 4, 5, 8), POST_Q32_groups = c(1, 4, 99, 998)
  )
  result <- analysis_extra_covariates("btp-2007", btp)
  expect_equal(result$age, c(57, 47, NA, NA))
  expect_equal(result$education, c(0, .5, 1, NA))
  expect_equal(result$read_briefing, c(0, .75, 1, NA))
  michigan <- tibble::tibble(
    source_row = 1:4, q27aa = c(40, 98, 50, 60),
    q26 = c(1, 3, 4, 98), t3q45 = c("A", "e", "1", "g")
  )
  result <- analysis_extra_covariates("michigan-2009", michigan)
  expect_equal(result$age, c(40, NA, 50, 60))
  expect_equal(result$education, c(0, .5, 1, NA))
  expect_equal(result$read_briefing, c(0, 1, NA, NA))
})

test_that("Michigan reading fields contain reviewed categorical codes", {
  survey <- arrow::read_parquet(project_path(
    "data", "michigan-2009", "survey.parquet"
  ))
  expect_true(all(tolower(survey$t3q45) %in% c("", "1", letters[1:5], "g")))
  expect_true(all(tolower(survey$t3q46) %in% c("", letters[1:5])))
  valid <- survey$q27by != 98 & survey$q27aa != 98
  expect_equal(survey$q27aa[valid], 2009 - (1900 + survey$q27by[valid]))
})
