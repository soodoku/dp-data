source(file.path(root, "R", "analysis_attendance.R"))

test_that("paired eligibility preserves completed blank quizzes", {
  people <- tibble::tibble(
    poll_id = "example", source_dataset = "survey",
    respondent_id = letters[1:5], panel = c(TRUE, TRUE, TRUE, TRUE, FALSE),
    attended = c(TRUE, TRUE, TRUE, FALSE, NA)
  )
  scores <- tidyr::expand_grid(
    respondent_id = letters[1:5], wave = c("t1", "t2")
  ) |>
    dplyr::mutate(
      poll_id = "example", source_dataset = "survey", n_items = 2L,
      n_observed = 0L, n_correct = 0L, score = 0
    )
  items <- scores |>
    tidyr::uncount(2L, .id = "item_id") |>
    dplyr::transmute(
      poll_id, source_dataset, respondent_id, wave,
      item_id = as.character(item_id), raw_value = NA_real_,
      raw_text = NA_character_, correct = 0L, response_status = "source_missing"
    )
  phase <- scores |>
    dplyr::mutate(
      original_score_wave = wave,
      wave_observed = !(respondent_id == "a" & wave == "t2") &
        !(respondent_id == "b" & wave == "t1"),
      battery_id = "example:survey:knowledge"
    )
  phase <- dplyr::bind_rows(phase, phase[1L, ] |>
    dplyr::mutate(
      respondent_id = "c", wave = "t3", original_score_wave = "t3",
      wave_observed = FALSE, score = NA_real_
    ))
  phase$wave_observed[phase$respondent_id == "d"] <- NA
  result <- reconcile_analysis_presence(people, scores, items, people, phase)
  expect_identical(
    result$participants$panel, c(FALSE, FALSE, TRUE, TRUE, FALSE)
  )
  expect_identical(result$phase_participants$panel, result$participants$panel)
  expect_identical(result$participants$attended, people$attended)
  expect_equal(sum(is.na(result$scores$score)), 2L)
  expect_equal(sum(is.na(result$items$correct)), 4L)
  expect_equal(sum(result$items$response_status == "wave_absent"), 4L)
  expect_identical(result$items$raw_value, items$raw_value)
  expect_identical(result$items$raw_text, items$raw_text)
  expect_true(all(result$scores$score[result$scores$respondent_id == "c"] == 0))
  invalid <- scores
  invalid$score[invalid$respondent_id == "a" & invalid$wave == "t2"] <- .5
  expect_error(reconcile_analysis_presence(
    people, invalid, items, people, phase
  ))
})


test_that("a followup-only source is not marked as a paired panel", {
  people <- tibble::tibble(
    poll_id = "example", source_dataset = "followup", respondent_id = "a",
    panel = TRUE, attended = TRUE
  )
  scores <- tibble::tibble(
    poll_id = "example", source_dataset = "followup", respondent_id = "a",
    wave = "t3", n_items = 1L, n_observed = 1L, n_correct = 1L, score = 1
  )
  items <- scores |>
    dplyr::transmute(
      poll_id, source_dataset, respondent_id, wave, item_id = "q1",
      raw_value = 1, raw_text = NA_character_, correct = 1L,
      response_status = "answered"
    )
  phase <- scores |>
    dplyr::mutate(
      original_score_wave = "t3", battery_id = "example:followup:knowledge",
      wave_observed = TRUE
    )
  result <- reconcile_analysis_presence(people, scores, items, people, phase)
  expect_false(result$participants$panel)
  expect_false(result$phase_participants$panel)
  expect_identical(result$participants$attended, people$attended)
  expect_identical(result$scores, scores)
  expect_identical(result$items, items)
})


test_that("reviewed absences agree across selected and phase tables", {
  read_table <- function(name) {
    arrow::read_parquet(project_path(
      "output", "analysis", paste0("analysis_", name, ".parquet")
    ))
  }
  result <- reconcile_analysis_presence(
    read_table("participants"), read_table("scores"),
    read_table("item_responses"), read_table("phase_participants"),
    read_table("phase_scores")
  )
  expected <- c(
    `btp-online-primaries-2004` = 285L, `california-whats-next-2011` = 386L
  )
  for (poll in names(expected)) {
    rows <- result$participants$poll_id == poll &
      result$participants$source_dataset == "cor_sood"
    expect_equal(sum(result$participants$panel[rows]), expected[[poll]])
    phase_rows <- result$phase_participants$poll_id == poll &
      result$phase_participants$source_dataset == "cor_sood"
    expect_equal(
      sum(result$phase_participants$panel[phase_rows]), expected[[poll]]
    )
  }
  northern_ireland <- result$participants |>
    dplyr::filter(poll_id == "northern-ireland-2007")
  followup <- northern_ireland$source_dataset != "cor_sood"
  expect_equal(sum(followup), 243L)
  expect_false(any(northern_ireland$panel[followup]))
  expect_equal(sum(northern_ireland$panel[!followup]), 124L)
  absent <- result$items$response_status == "wave_absent"
  expect_true(all(is.na(result$items$correct[absent])))
  primaries <- result$scores$poll_id == "btp-online-primaries-2004" &
    result$scores$source_dataset == "cor_sood" & result$scores$wave == "t2"
  california <- result$scores$poll_id == "california-whats-next-2011" &
    result$scores$source_dataset == "cor_sood" & result$scores$wave == "t1"
  expect_equal(sum(is.na(result$scores$score[primaries])), 43L)
  expect_equal(sum(is.na(result$scores$score[california])), 10L)
})
