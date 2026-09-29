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
  expect_true("amr-2024" %in% scores$poll_id)
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
    nic$wave[nic$original_score_wave == "t2"] == "t2"
  ))
  expect_true(all(nic$wave[nic$original_score_wave == "t3"] == "t3"))
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


test_that("Bulgaria baseline comes from the original national survey", {
  recruitment <- haven::read_sav(project_path(
    "data", "bulgaria-crime-2002", "recruitment.sav"
  ))
  baseline <- haven::read_sav(project_path(
    "data", "bulgaria-crime-2002", "attendee-baseline.sav"
  ))
  fields <- intersect(grep("^Q", names(baseline), value = TRUE),
                      names(recruitment))
  fingerprint <- function(data) {
    apply(as.matrix(data[fields]), 1L, function(row) {
      digest::digest(as.numeric(row))
    })
  }
  expect_equal(nrow(recruitment), 1035L)
  expect_equal(nrow(baseline), 278L)
  expect_length(fields, 119L)
  expect_true(all(fingerprint(baseline) %in% fingerprint(recruitment)))
  scores <- phase_export("analysis_phase_scores") |>
    dplyr::filter(poll_id == "bulgaria-crime-2002")
  expect_equal(nrow(scores), 1112L)
  expect_setequal(scores$wave, c("t0", "t2"))
  expect_true(all(scores$wave_observed))
  expect_true(all(scores$wave[scores$original_score_wave == "t1"] == "t0"))
})

test_that("NIC separates source Time 2 exit and absent follow-up", {
  raw <- read_poll_survey("nic-1996")
  people <- phase_export("analysis_participants") |>
    dplyr::filter(poll_id == "nic-1996", source_dataset == "historical")
  scores <- phase_export("analysis_scores") |>
    dplyr::filter(poll_id == "nic-1996", source_dataset == "historical") |>
    dplyr::left_join(people, by = c(
      "poll_id", "source_dataset", "respondent_id"
    ), relationship = "many-to-one")
  items <- phase_export("analysis_item_responses") |>
    dplyr::filter(poll_id == "nic-1996", source_dataset == "historical")
  expect_equal(nrow(items), nrow(raw) * 11L * 3L)
  for (wave in 1:3) {
    fields <- items$source_column[items$wave == paste0("t", wave)]
    expect_true(all(endsWith(fields, as.character(wave))))
  }
  measures <- arrow::read_parquet(project_path(
    "output", "respondent", "respondent_measures.parquet"
  )) |>
    dplyr::filter(poll_id == "nic-1996",
      definition_id == "knowledge_midterm@historical-v1"
    )
  exit <- scores |>
    dplyr::filter(wave == "t2") |>
    dplyr::left_join(measures, by = c("poll_id", "respondent_id"),
      relationship = "one-to-one"
    )
  expect_equal(exit$score, exit$value_numeric, tolerance = 1e-10)
  followup <- scores |> dplyr::filter(wave == "t3")
  observed <- round(raw$PART3[match(followup$source_row, raw$source_row)]) == 1
  expect_equal(sum(observed), 387L)
  expect_true(all(is.na(followup$score[!observed])))
  expect_true(all(is.finite(followup$score[observed])))
})


test_that("AMR preserves the pre-invitation and event-end panel", {
  original <- phase_export("analysis_scores") |>
    dplyr::filter(poll_id == "amr-2024")
  phases <- phase_export("analysis_phase_scores") |>
    dplyr::filter(poll_id == "amr-2024")
  people <- phase_export("analysis_participants") |>
    dplyr::filter(poll_id == "amr-2024")
  expect_equal(nrow(phases), 4838L)
  expect_equal(nrow(people), 2419L)
  expect_setequal(phases$wave, c("t0", "t2"))
  expect_equal(table(phases$wave) |> as.integer(), c(2419L, 2419L))
  expect_setequal(phases$respondent_id, people$respondent_id)
  expect_true(all(phases$wave_observed))
  comparison <- phases |>
    dplyr::left_join(original,
      by = c("poll_id", "source_dataset", "respondent_id",
             "original_score_wave" = "wave"),
      relationship = "one-to-one", suffix = c("_phase", "_original")
    )
  for (field in c("n_items", "n_observed", "n_correct", "score")) {
    expect_equal(comparison[[paste0(field, "_phase")]],
                 comparison[[paste0(field, "_original")]])
  }
  expect_equal(sum(phases$n_observed == 0L), 46L)
  expect_true(all(phases$score[phases$n_observed == 0L] == 0))
  items <- phase_export("analysis_phase_item_responses") |>
    dplyr::filter(poll_id == "amr-2024")
  expect_equal(nrow(items), 29028L)
  expect_setequal(items$wave, c("t0", "t2"))
  waves <- read_metadata("analysis_survey_waves") |>
    dplyr::filter(poll_id == "amr-2024")
  expect_equal(nrow(waves), 2L)
  expect_true(all(waves$mode == "unknown"))
  expect_true(all(is.na(waves$date_start) & is.na(waves$date_end)))
})
