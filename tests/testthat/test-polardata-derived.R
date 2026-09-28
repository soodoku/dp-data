source(file.path(root, "R", "polardata_derived.R"))

test_that("entropy uses all observed categories and answered denominators", {
  expect_equal(categorical_entropy(c(0, 1)), 1)
  expect_equal(categorical_entropy(c(0, 0, NA, NA)), 0)
  expect_equal(categorical_entropy(c(1, 1, NA)), 0)
  expect_equal(categorical_entropy(rep(0, 4)), 0)
  expect_equal(categorical_entropy(c(0, .33, 1)), log2(3))
  expect_equal(categorical_entropy(c(0, .33, .66, 1)), 2)
  expect_equal(categorical_entropy(seq(0, 1, .2)), log2(6))
  expect_true(is.na(categorical_entropy(c(NA_real_, NA_real_))))
  expect_true(is.na(categorical_entropy(numeric())))
  expect_error(categorical_entropy(c(0, Inf)))
  values <- c(0, 0, 1, NA_real_)
  expected <- -.75 * log2(.75) - .25 * log2(.25)
  expect_equal(categorical_entropy(c(0, 0, 0, 1, NA_real_)), expected)
  expect_equal(categorical_entropy(rev(values)), categorical_entropy(values))
})

test_that("combined entropy preserves partial coverage and unknown groups", {
  values <- tibble::tibble(
    female = c(0, 1, NA_real_, NA_real_, 0, 1),
    minority = NA_real_, education_four = NA_real_, age = NA_real_,
    attitude_extremity = NA_real_
  )
  group <- c(1, 1, 2, 2, NA_real_, NA_real_)
  result <- historical_composition(values, group, rep(NA_real_, 6))
  expect_equal(result$entropy, c(1, 1, NA, NA, NA, NA))
  reversed <- rev(seq_len(nrow(values)))
  expect_equal(
    historical_composition(values[reversed, ], group[reversed],
                           rep(NA_real_, 6))$entropy,
    result$entropy[reversed]
  )
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
