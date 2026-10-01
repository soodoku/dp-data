test_that("Texas absence propagates through post scores and gains", {
  for (poll in c("swepco-1996", "wtu-1996")) {
    survey <- read_poll_survey(poll)
    absent <- survey$PART == 2L
    before <- utility_knowledge_items(survey, poll, 1L)
    after <- utility_knowledge_items(survey, poll, 2L)
    expect_false(anyNA(before))
    expect_true(all(is.na(after[absent, ])))
    expect_false(anyNA(after[!absent, ]))
    scores <- summarise_historical_knowledge(before, after)
    expect_equal(scores$knowledge_t1, rowMeans(before))
    expect_true(all(is.na(scores[absent, names(scores) != "knowledge_t1"])))

    answered <- survey[which(!absent)[1L], ]
    answered$SOURCE2 <- NA_real_
    expect_identical(
      unname(utility_knowledge_items(answered, poll, 2L)[1L, "source"]), 0
    )
    contradictory <- survey[which(absent)[1L], ]
    contradictory$SOURCE2 <- 1
    expect_error(utility_knowledge_items(contradictory, poll, 2L))
  }
})

test_that("knowledge summaries distinguish invalid items and absent forms", {
  before <- rbind(c(1, 0), c(1, 0), c(1, 0))
  after <- rbind(c(NA, 1), c(NA, 0), c(NA, NA))
  original <- after
  scores <- summarise_historical_knowledge(before, after)
  expect_identical(after, original)
  expect_equal(scores$knowledge_t1, rep(.5, 3))
  expect_equal(scores$knowledge_t2, c(.5, 0, NA))
  expect_equal(scores$knowledge_joint, c(0, 0, NA))
  expect_equal(scores$knowledge_gain, c(0, -.5, NA))
  expect_true(all(is.na(scores[3L, names(scores) != "knowledge_t1"])))
  after[1L, 1L] <- .5
  expect_error(summarise_historical_knowledge(before, after))
  after[1L, 1L] <- 2
  expect_error(summarise_historical_knowledge(before, after))
})

test_that("ungrouped absent forms cannot change observed group gains", {
  observed <- matrix(c(0, 1, 1, 0), nrow = 2L, byrow = TRUE)
  expected <- historical_fractional_gain(observed, c(1, 1))
  with_absent <- rbind(observed, c(NA_real_, NA_real_))
  actual <- historical_fractional_gain(with_absent, c(1, 1, NA))
  expect_equal(actual[1:2], expected)
  expect_true(is.na(actual[3L]))
  same_group <- historical_fractional_gain(with_absent, c(1, 1, 1))
  expect_equal(same_group[1:2], expected)
  expect_true(is.na(same_group[3L]))
})
