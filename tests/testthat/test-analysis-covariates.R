test_that("Health degree status uses the separate degree question", {
  survey <- tibble::tibble(educb = c(0:12, -9, NA_real_))
  expect_equal(
    health_degree_status(survey),
    c(rep(0, 9), 1, rep(0, 3), NA_real_, NA_real_)
  )
  survey$educb[1] <- 99
  expect_error(health_degree_status(survey))

  raw <- read_poll_survey("uk-health-1998")
  stored <- as.numeric(raw$degree)
  stored[stored == -9] <- NA_real_
  expect_equal(health_degree_status(raw), stored)
  expect_equal(sum(stored == 1, na.rm = TRUE), 32L)
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_participants.parquet"
  )) |>
    dplyr::filter(
      poll_id == "uk-health-1998", source_dataset == "historical"
    )
  expect_equal(nrow(people), 230L)
  expect_equal(people$ba, stored[match(people$source_row, raw$source_row)])
  expect_equal(sum(is.na(people$ba)), 1L)
  phases <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_participants.parquet"
  )) |>
    dplyr::filter(
      poll_id == "uk-health-1998", source_dataset == "historical"
    )
  expect_setequal(phases$respondent_id, people$respondent_id)
  expect_equal(phases$ba, people$ba[
    match(phases$respondent_id, people$respondent_id)
  ])
})

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
  expect_true(all(
    is.na(people$read_briefing) |
      (people$read_briefing >= 0 & people$read_briefing <= 1)
  ))
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
