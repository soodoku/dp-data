test_that("response emptiness preserves numeric and literal text evidence", {
  cases <- tidyr::expand_grid(
    raw_value = c(NA_real_, NaN, 0, 5, Inf),
    raw_text = c(NA_character_, "", " ", "\t", "0", "NA", "Don't know")
  )
  before <- cases
  expected <- is.na(cases$raw_value) &
    (is.na(cases$raw_text) | !nzchar(trimws(cases$raw_text)))
  actual <- is_response_empty(cases$raw_value, cases$raw_text)
  expect_identical(actual, expected)
  observed <- !is.na(cases$raw_value) |
    (!is.na(cases$raw_text) & nzchar(trimws(cases$raw_text)))
  expect_identical(!actual, observed)
  expect_identical(cases, before)
  expect_false(anyNA(actual))
  expect_identical(is_response_empty(numeric(), character()), logical())
})

test_that("comparison presence preserves source and selected wave identities", {
  scores <- tibble::tibble(
    poll_id = "example",
    source_dataset = c("historical", "cor_sood", "historical", "historical"),
    respondent_id = "1", battery_id = c(
      "example:historical:knowledge", "example:cor_sood:knowledge",
      "example:historical:knowledge_expanded", "example:historical:knowledge"
    ),
    wave = c("t0", "t0", "t1", "t3"),
    original_score_wave = c("t1", "t1", "arrival", "t2"),
    wave_observed = c(TRUE, NA, TRUE, FALSE)
  )
  expected <- tibble::tibble(
    poll_id = "example",
    source_dataset = c("historical", "cor_sood", "historical"),
    respondent_id = "1", wave = c("t1", "t1", "t2"),
    wave_observed = c(TRUE, NA, FALSE)
  )
  expect_identical(select_comparison_presence(scores), expected)
  duplicate <- dplyr::bind_rows(scores, scores[1, ])
  expect_error(select_comparison_presence(duplicate))
  empty <- select_comparison_presence(scores[FALSE, ])
  expect_identical(empty, expected[FALSE, ])
})
