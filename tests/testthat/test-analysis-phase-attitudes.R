source(file.path(root, "R", "analysis_phase_attitudes.R"))

test_that("phase attitudes retain raw codes and distinguish missingness", {
  raw <- c(0, 5, 10, 77, 98, -8, 11, 2.5, NA, NA, NA, 4)
  observed <- c(rep(TRUE, 9), FALSE, NA, FALSE)
  labels <- rep(NA_character_, length(raw))
  labels[6] <- "Multiple responses"
  result <- phase_attitude_values(
    raw, 0, 10, c(-8, 77, 98, 99), observed, labels
  )
  expect_identical(result$raw_value, raw)
  expect_equal(result$value, c(0, .5, 1, rep(NA_real_, 8), .4))
  expect_identical(result$response_status, c(
    rep("answered", 3), rep("non_substantive", 2),
    rep("invalid_response", 3), "blank", "absent_form",
    "source_missing", "answered"
  ))
  expect_identical(result$wave_observed, observed)
  expect_identical(result$source_response_label, labels)
})

test_that("each attitude wave uses only its own raw response", {
  before <- phase_attitude_values(c(2, 5, NA), 0, 10, 77, rep(TRUE, 3))
  after <- phase_attitude_values(c(77, NA, 8), 0, 10, 77, rep(TRUE, 3))
  expect_equal(before$value, c(.2, .5, NA))
  expect_equal(after$value, c(NA, NA, .8))
  expect_equal(before$value, phase_attitude_values(
    c(2, 5, NA), 0, 10, 77, rep(TRUE, 3)
  )$value)
})

test_that("paired attitude exports preserve source people and both waves", {
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_participants.parquet"
  ))
  scores <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_scores.parquet"
  ))
  tables <- analysis_phase_attitudes(people, scores)
  definitions <- tables$analysis_phase_attitudes
  values <- tables$analysis_phase_attitude_responses
  expect_equal(nrow(definitions), 119L)
  expect_equal(nrow(values), 2L * (3842L * 47L + 8814L * 72L))
  keys <- c("poll_id", "source_dataset", "respondent_id")
  response_keys <- c(keys, "attitude_id", "wave_instance_id")
  expect_equal(anyDuplicated(values[response_keys]), 0L)
  expect_setequal(values$wave, c("t0", "t2"))
  expect_setequal(values$wave_role, c("pre_arrival", "post_deliberation"))
  expect_equal(nrow(dplyr::anti_join(
    dplyr::distinct(values, poll_id, source_dataset, respondent_id),
    people, by = keys
  )), 0L)
  selected <- dplyr::filter(people, poll_id %in% definitions$poll_id)
  expect_equal(nrow(dplyr::anti_join(selected, values, by = keys)), 0L)
  expect_true(all(is.na(values$value[values$response_status != "answered"])))
  expect_true(all(values$value[values$raw_value %in% 0] == 0))
  expect_true(all(values$value[values$raw_value %in% 5] == .5))
  climate <- dplyr::filter(values, poll_id == "a1r-climate-2021")
  expect_true(all(is.na(climate$source_response_label)))
  multiple <- dplyr::filter(values,
    poll_id == "america-in-one-room-2019", raw_value == -8
  )
  expect_equal(nrow(multiple), 5L)
  expect_true(all(multiple$response_status == "invalid_response"))
  expect_true(all(multiple$source_response_label == "Multiple responses"))
  expect_true(all(is.na(multiple$value)))
  expected_counts <- tibble::tribble(
    ~poll_id, ~wave, ~n,
    "america-in-one-room-2019", "t0", 166312L,
    "america-in-one-room-2019", "t2", 61159L,
    "a1r-climate-2021", "t0", 571331L,
    "a1r-climate-2021", "t2", 111962L
  )
  counts <- values |>
    dplyr::summarise(n = sum(!is.na(value)), .by = c("poll_id", "wave")) |>
    dplyr::arrange(poll_id, wave)
  expect_equal(counts, dplyr::arrange(expected_counts, poll_id, wave))
  for (poll in unique(definitions$poll_id)) {
    raw <- readr::read_tsv(project_path("data", poll, "participants.tab"),
      col_types = readr::cols(.default = readr::col_character())
    )
    exported <- dplyr::filter(values, poll_id == poll)
    expected <- rep(NA_real_, nrow(exported))
    for (field in unique(exported$source_column)) {
      rows <- which(exported$source_column == field)
      text <- trimws(raw[[field]][exported$source_row[rows]])
      text[!is.na(text) & !nzchar(text)] <- NA_character_
      expected[rows] <- as.numeric(text)
    }
    expect_equal(exported$raw_value, expected)
    expect_equal(exported$value,
      dplyr::if_else(expected %in% 0:10, expected / 10, NA_real_)
    )
  }
})
