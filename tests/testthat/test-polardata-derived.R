source(file.path(root, "R", "polardata_derived.R"))

test_that("historical entropy retains missing denominators and absent levels", {
  expect_equal(historical_entropy(c(0, 1), 2L), 1)
  expect_equal(historical_entropy(c(0, 0, NA, NA), 2L), 1)
  expect_equal(historical_entropy(rep(0, 4), 2L), 0)
  expect_true(is.na(historical_entropy(c(0, .33, 1), 4L)))
  expect_equal(historical_entropy(c(0, .33, .66, 1), 4L), 2)
  expect_true(is.na(historical_entropy(c(NA, NA), 2L)))
})

test_that("historical dispersion handles singular and missing covariance", {
  expect_equal(historical_genvar(cbind(1:4, 1:4)), 0)
  expect_equal(historical_genvar(cbind(1:4, rep(1, 4))), 0)
  expect_true(is.na(historical_genvar(cbind(1:4, NA_real_))))
  expect_equal(historical_genvar(matrix(1:4, ncol = 1)), sd(1:4))
  values <- cbind(c(0, .5, 1, .5), c(1, 0, .5, .5))
  expected <- historical_group_dispersion(values, c(1, 1, 2, 2))
  order <- c(3, 1, 4, 2)
  expect_equal(
    historical_group_dispersion(values[order, ], c(1, 1, 2, 2)[order]),
    expected[order, ]
  )
})

test_that("group summaries retain unassigned rows and missing groups", {
  expect_equal(
    historical_group_summary(c(1, 2, 3, NA), c(1, NA, 1, 2)),
    c(2, NA, 2, NA)
  )
  expect_equal(historical_group_summary(numeric(), numeric()), numeric())
})
