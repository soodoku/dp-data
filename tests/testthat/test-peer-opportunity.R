test_that("knowing every scored item leaves no peer learning opportunity", {
  items <- rbind(c(1, 1), c(0, 1), c(0, 0))
  group <- rep(1, 3)
  expect_equal(historical_group_gain(items, group), c(0, 0.5, 0.75))
  expect_equal(historical_fractional_gain(items, group), c(0, 0.5, 0.75))
  expect_equal(
    reviewed_us_group_gain(items, items, group, rowMeans(items)),
    c(0, 0.5, 0.75)
  )
  expect_equal(historical_log_score(0), log(0.0001))
})

test_that("no knowledgeable peers already yields zero opportunity", {
  items <- matrix(0, nrow = 3, ncol = 2)
  group <- rep(1, 3)
  expect_equal(historical_group_gain(items, group), rep(0, 3))
  expect_equal(historical_fractional_gain(items, group), rep(0, 3))
  expect_equal(
    reviewed_us_group_gain(items, items, group, rowMeans(items)), rep(0, 3)
  )
})

test_that("observed ceilings tolerate source numeric encoding", {
  items <- rbind(
    c(1 + 1e-11, 1), c(1, 1), c(1, NA), c(NA, NA),
    c(1, 0.999), c(1, 1), c(1, 1)
  )
  group <- c(1, 1, 1, 1, 1, NA, 2)
  previous <- c(NA, -0.001, NA, NA, 0.25, NA, NA)
  expect_equal(
    apply_peer_opportunity_ceiling(previous, items, group),
    c(0, 0, NA, NA, 0.25, NA, NA)
  )
  fractional <- rbind(c(1 + 1e-11, 1), c(0, 1 + 1e-11))
  expect_equal(historical_fractional_gain(fractional, c(1, 1))[1], 0)
  absent <- matrix(NA_real_, nrow = 2, ncol = 2)
  expect_true(all(is.na(reviewed_us_group_gain(
    absent, absent, c(1, 1), c(NA_real_, NA_real_)
  ))))
})

test_that("missing groups and singletons cannot establish peer opportunity", {
  items <- matrix(0, nrow = 1, ncol = 2)
  expect_true(is.na(reviewed_us_group_gain(items, items, 1, 0)))
  expect_true(is.na(reviewed_us_group_gain(items, items, NA_real_, 0)))
  expect_true(is.na(apply_peer_opportunity_ceiling(0, items, 1)))
  expect_true(is.na(apply_peer_opportunity_ceiling(0, items, NA_real_)))
})
