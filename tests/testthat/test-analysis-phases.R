source(file.path(root, "R", "analysis_phases.R"))

phase_export <- function(table) {
  arrow::read_parquet(project_path(
    "output", "analysis", paste0(table, ".parquet")
  ))
}

test_that("phase exports retain recruitment and unique linked measurements", {
  people <- phase_export("analysis_phase_participants")
  scores <- phase_export("analysis_phase_scores")
  keys <- c("poll_id", "source_dataset", "respondent_id")
  expect_equal(nrow(people), 53053L)
  expect_false(anyDuplicated(people[keys]) > 0L)
  expect_false(anyDuplicated(scores[c(keys, "battery_id", "wave")]) > 0L)
  expect_equal(nrow(dplyr::anti_join(scores, people, by = keys)), 0L)
  expect_false(any(c("bulgaria-crime-2002", "amr-2024") %in% scores$poll_id))
  absent <- scores$wave_observed %in% FALSE
  expect_true(all(is.na(scores$score[absent])))
  expect_true(all(is.na(scores$n_correct[absent])))
  expect_true(all(!is.na(scores$timing_evidence)))
})

test_that("source timing overrides misleading selected-wave names", {
  scores <- phase_export("analysis_phase_scores")
  nic <- dplyr::filter(
    scores, poll_id == "nic-1996",
    source_dataset == "historical"
  )
  expect_setequal(unique(nic$wave), c("t0", "t2", "t3"))
  expect_true(all(
    nic$wave[nic$original_score_wave == "knowledge_midterm"] == "t2"
  ))
  expect_true(all(nic$wave[nic$original_score_wave == "t2"] == "t3"))
  haven <- dplyr::filter(scores, poll_id == "new-haven-2004")
  expect_false(any(haven$wave == "t1"))
  expect_true(any(haven$wave == "interim_1"))
  europe <- dplyr::filter(
    scores, poll_id == "tomorrows-europe-2007",
    source_dataset == "historical"
  )
  expect_setequal(unique(europe$wave), c("t0", "t1", "t2"))
})

test_that("control sources retain absent waves in the recruitment frame", {
  scores <- phase_export("analysis_phase_scores")
  people <- phase_export("analysis_phase_participants")
  for (poll in c("america-in-one-room-2019", "a1r-climate-2021")) {
    study <- dplyr::filter(people, poll_id == poll, source_dataset == "control")
    phases <- dplyr::filter(
      scores, poll_id == poll, source_dataset == "control"
    )
    counts <- dplyr::count(phases, wave)
    expect_true(all(counts$n == nrow(study)))
    expect_true(any(phases$wave_observed %in% FALSE))
    expect_true(all(is.na(phases$score[phases$wave_observed %in% FALSE])))
  }
})
