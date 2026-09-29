source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "polardata_derived.R"))

test_that("median classification keeps ties and missing observations intact", {
  expect_equal(above_reference_median(c(1, 2, 3, NA), c(1, 2, 2)),
               c(0, 0, 1, NA))
  expect_equal(above_reference_median(c(1, 2), c(1, 2)), c(0, 1))
  expect_equal(above_reference_median(c(1, 2), c(NA_real_, NA_real_)),
               c(NA_real_, NA_real_))
  expect_equal(above_reference_median(rep(2, 3), rep(2, 3)), rep(0, 3))
  expect_error(above_reference_median(c(1, Inf), 1:3))
})

test_that("only unique reference participants set the demographic median", {
  values <- tibble::tibble(
    education_four = c(1, 2, 3, 100, NA),
    household_income = c(20, NA, 40, 1000, NA)
  )
  included <- c(TRUE, TRUE, TRUE, FALSE, NA)
  ids <- letters[1:5]
  result <- normalize_demographic_flags(values, included, ids)
  expect_equal(result$higher_education, c(0, 0, 1, 1, NA))
  expect_equal(result$high_income, c(0, NA, 1, 1, NA))
  expect_identical(result[names(values)], values)
  order <- c(4, 2, 5, 1, 3)
  shuffled <- normalize_demographic_flags(
    values[order, ], included[order], ids[order]
  )
  expect_equal(shuffled, result[order, ])
  expect_error(normalize_demographic_flags(values, included, rep("a", 5)))
})

test_that("finer education preserves graduate and diploma ordering", {
  ordered <- function(poll, survey) {
    education_normalization_values(
      tibble::tibble(education_four = rep(1, nrow(survey))), survey, poll
    )
  }
  expect_equal(ordered("australia-republic-1999",
                       tibble::tibble(edulev = c(4, 5, 98))), c(4, 5, NA))
  expect_equal(ordered("new-haven-2004",
                       tibble::tibble(pre_q61 = c(4, 5, 6, 7, 8))),
               c(4, 5, 6, 4, NA))
  expect_equal(ordered("nic2-2003", tibble::tibble(
    educ_a = c(2, 10, 15, 16, 17, 18), educ_b = c(1, 1, NA, NA, NA, NA)
  )), c(12, 12, 15, 16, 17, 18))
  expect_equal(ordered("san-mateo-2008",
                       tibble::tibble(Q128 = c(4, 5, 6, 7, 8))),
               c(4, 5, 6, NA, NA))
})

test_that("group income share uses the normalized individual flag", {
  values <- tibble::tibble(
    female = c(0, 1, 0), minority = c(0, 0, 1), education_four = c(1, 2, 3),
    age = c(20, 30, 40), attitude_extremity = c(.1, .2, .3),
    high_income = c(0, 1, NA_real_)
  )
  result <- historical_composition(values, c(1, 1, 1))
  expect_equal(result$phighinc, rep(.5, 3))
  values$high_income[] <- NA_real_
  expect_true(all(is.na(historical_composition(values, c(1, 1, 1))$phighinc)))
})
