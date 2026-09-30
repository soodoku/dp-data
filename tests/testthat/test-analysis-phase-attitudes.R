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
  expect_equal(nrow(definitions), 140L)
  expect_equal(nrow(values), 2L * (3842L * 47L + 8814L * 93L))
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
    "a1r-climate-2021", "t0", 746050L,
    "a1r-climate-2021", "t2", 145065L
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


test_that("Climate additional ratings retain their report scales and means", {
  fields <- c(paste0("Q13", LETTERS[1:4]), paste0("Q14", LETTERS[1:5]),
    paste0("Q15", LETTERS[1:9]), paste0("Q16", LETTERS[1:3])
  )
  definitions <- read_metadata("paired_attitude_items") |>
    dplyr::filter(poll_id == "a1r-climate-2021", pre_column %in% fields) |>
    dplyr::arrange(pre_column)
  expect_identical(definitions$pre_column, fields)
  expect_identical(definitions$post_column, paste0("T2", fields))
  expect_identical(definitions$direction, c(
    rep("greater_agreement", 9), rep("greater_importance", 9),
    rep("greater_frequency", 3)
  ))
  expect_true(all(definitions$minimum == 0 & definitions$maximum == 10))
  expect_true(all(definitions$nonresponse_codes == "77|88|98|99"))
  survey <- readr::read_tsv(project_path(
    "data", "a1r-climate-2021", "participants.tab"
  ), show_col_types = FALSE)
  printed <- readr::read_csv(project_path(
    "audit", "corrections", "a1r-climate-2021",
    "attitude_report_comparison.csv"
  ), show_col_types = FALSE) |>
    dplyr::filter(item %in% fields) |>
    dplyr::arrange(item)
  delegates <- survey[survey$P_DELEGATE == 1, ]
  expect_equal(nrow(delegates), 962L)
  means <- purrr::map(fields, function(field) {
    initial <- delegates[[field]]
    exit <- delegates[[paste0("T2", field)]]
    paired <- initial %in% 0:10 & exit %in% 0:10
    before <- stats::weighted.mean(initial[paired], delegates$WEIGHT1[paired])
    after <- stats::weighted.mean(exit[paired], delegates$WEIGHT1[paired])
    tibble::tibble(before, after, change = after - before)
  }) |>
    purrr::list_rbind()
  expected <- as.matrix(printed[c(
    "reported_pre", "reported_post", "reported_change"
  )])
  expect_true(all(abs(as.matrix(means) - expected) <= .00050001))
  initial <- unlist(survey[fields], use.names = FALSE)
  exit <- unlist(survey[paste0("T2", fields)], use.names = FALSE)
  expect_equal(sum(initial %in% 0:10), 174719L)
  expect_equal(sum(exit %in% 0:10), 33103L)
  expect_equal(sum(initial %in% c(77, 88, 98, 99)), 10375L)
  expect_equal(sum(exit %in% c(77, 88, 98, 99)), 1190L)
  expect_true(all(is.na(initial) | initial %in% c(0:10, 77, 88, 98, 99)))
  expect_true(all(is.na(exit) | exit %in% c(0:10, 77, 88, 98, 99)))
})
