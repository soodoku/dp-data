test_that("float components use observed peers and retain missing focal", {
  value <- c(0, 1, NA, 0, 0, NA)
  group <- c(1, 1, 1, 1, 2, 2)
  expect_equal(reviewed_peer_component(value, group, 7),
    c(as_historical_float(1 / 14), 0, NA,
      as_historical_float(1 / 14), NA, NA)
  )
  expect_equal(reviewed_peer_component(c(1, NA), c(1, 1), 11), c(0, NA))
})

test_that("unknown peers cannot create zero opportunity", {
  before <- rbind(c(0, 0), c(1, 0), c(NA, NA))
  after <- before
  joint <- rowMeans(before * after)
  expect_equal(reviewed_us_group_gain(before, after, rep(1, 3), joint),
    c(.5, 0, NA)
  )
  before[2L, ] <- NA_real_
  expect_true(all(is.na(reviewed_us_group_gain(
    before, after, rep(1, 3), rowMeans(before * after)
  ))))
  before <- rbind(c(1, 1), c(NA, NA))
  expect_equal(reviewed_us_group_gain(
    before, before, c(1, 1), rowMeans(before)
  ), c(0, NA))
})

test_that("complete peers retain the authored single-precision accumulation", {
  before <- rbind(c(0, 1, 0), c(1, 0, 1), c(1, 1, 0), c(0, 0, 0))
  after <- before
  expected <- rep(0, 4)
  for (item in seq_len(ncol(before))) {
    component <- as_historical_float(sum(before[, item]) / 3 / 3)
    contribution <- rep(component, 4)
    contribution[before[, item] == 1] <- 0
    expected <- as_historical_float(expected + contribution)
  }
  knowledge <- as_historical_float(rowMeans(before))
  expected <- expected * 3 / ((1 - knowledge) * 3)
  expect_identical(reviewed_us_group_gain(
    before, after, rep(1, 4), knowledge
  ), expected)
})

test_that("BTP source completion flags explain the omitted peer observations", {
  survey <- read_poll_survey("btp-general-election-2004")
  before <- btp_general_knowledge(survey, "b")
  after <- btp_general_knowledge(survey, "f")
  joint <- before * after
  missing <- rowSums(is.na(joint)) == ncol(joint)
  expect_equal(sum(missing), 46L)
  expect_equal(sum(as.numeric(survey$w4comsta) == 2), 33L)
  expect_equal(sum(as.numeric(survey$w4comsta) == 3), 13L)
  expect_identical(missing, as.numeric(survey$w4comsta) != 1)
  group <- as.numeric(survey$smgrpnumber)
  expect_equal(length(unique(group[missing])), 14L)
  score <- as_historical_float(rowMeans(joint))
  actual <- reviewed_us_group_gain(before, after, group, score)
  expected <- vapply(seq_len(nrow(joint)), function(row) {
    if (missing[row]) return(NA_real_)
    if (all(joint[row, ] == 1)) return(0)
    peers <- group == group[row] & seq_len(nrow(joint)) != row
    total <- 0
    for (item in seq_len(ncol(joint))) {
      value <- if (joint[row, item] == 1) {
        0
      } else {
        as_historical_float(mean(joint[peers, item], na.rm = TRUE) /
                              ncol(joint))
      }
      total <- as_historical_float(total + value)
    }
    total * ncol(joint) / ((1 - score[row]) * ncol(joint))
  }, numeric(1))
  expect_identical(actual, expected)
  expect_true(all(is.na(actual[missing])))
})

test_that("invalid focal items do not become missed peer opportunities", {
  items <- rbind(c(NA, 0), c(1, 1), c(0, 0))
  knowledge <- c(0, 1, 0)
  expect_equal(
    reviewed_us_group_gain(items, items, rep(1, 3), knowledge),
    c(.5, 0, .75)
  )
  items[1L, ] <- c(NA, 1)
  expect_true(is.na(reviewed_us_group_gain(
    items, items, rep(1, 3), c(.5, 1, 0)
  )[1L]))
})
