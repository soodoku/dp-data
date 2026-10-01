test_that("case-insensitive readers preserve reviewed codes and raw labels", {
  survey <- tibble::tibble(
    MiXeD = haven::labelled(c(1, 2, NA_real_, 98), c(refused = 98))
  )
  original <- survey
  expect_identical(
    read_source_codes_ignore_case(survey, "mixed", c(1:2, 98)),
    c(1, 2, NA_real_, 98)
  )
  expect_identical(survey, original)
  expect_error(read_source_codes_ignore_case(survey, "absent", 1:2),
    "Missing source field: absent", fixed = TRUE
  )
  expect_error(read_source_codes_ignore_case(survey, "mixed", 1:2),
    "Unreviewed source codes in mixed", fixed = TRUE
  )
  expect_error(read_source_codes(survey, "mixed", c(1:2, 98)),
    "Missing source field: mixed", fixed = TRUE
  )
})

test_that("Europolis alone retains its reviewed high-code missing mask", {
  survey <- tibble::tibble(V1Q43 = c(1, 2, 997:999, NA_real_))
  expect_identical(
    read_source_codes_ignore_case(survey, "v1q43", c(1:2, 997:999)),
    survey$V1Q43
  )
  expect_identical(europolis_source_codes(survey, "v1q43", 1:2),
    c(1, 2, rep(NA_real_, 4))
  )
  survey$V1Q43[1] <- 996
  expect_error(europolis_source_codes(survey, "v1q43", 1:2),
    "Unreviewed source codes in v1q43", fixed = TRUE
  )
})

test_that("shared float means preserve missingness and nested weighting", {
  expect_identical(
    calculate_float_mean(c(0, NA_real_, 1), c(1, NA_real_, NA_real_)),
    c(.5, NaN, 1)
  )
  expect_identical(calculate_float_mean(.1, .1, .1, .1, .1, .1, .1),
    0.10000000149011612
  )
  expect_identical(btp_health_alpha(.1, .1, .1, .1, .1, .1, .1),
    0.10000000894069672
  )
  expect_identical(calculate_float_mean(calculate_float_mean(0, 1), 1), .75)
  expect_identical(calculate_float_mean(0, 1, 1), 0.66666668653488159)
  expect_identical(historical_available_mean(matrix(NA_real_, 2, 2)),
    rep(NA_real_, 2)
  )
})

test_that("historical affine ranges remain unclipped", {
  expect_identical(rescale_historical_range(c(-1, 0, 5, 10, 11, NA), 1, 10),
    c(-2, -1, 4, 9, 10, NA) / 9
  )
  expect_error(rescale_historical_range(1, 1, 1))
  expect_error(rescale_historical_range(1, c(0, 1), 2))
})

test_that("shared historical recodes keep their original thresholds", {
  expect_identical(collapse_historical_education(c(NA, 0, .33, .66, 1)),
    c(NA_real_, 0, .5, .5, 1)
  )
  expect_identical(historical_log_score(c(-1, 0, .00001, .25, 1, NA)),
    log(c(.0001, .0001, .00001, .25, 1, NA))
  )
})
