marousi_phase_fixture <- function() {
  participants <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_participants.parquet"
  ))
  bridge <- analysis_marousi_source()
  list(
    original = participants, bridge = bridge,
    full = analysis_phase_recruitment(participants, list(marousi = bridge))
  )
}

test_that("Marousi recruitment preserves existing people and the full frame", {
  fixture <- marousi_phase_fixture()
  original <- fixture$original
  participants <- fixture$full$participants
  marousi <- participants |>
    dplyr::filter(poll_id == "marousi-2006")
  existing <- original |>
    dplyr::filter(poll_id == "marousi-2006")
  expect_identical(names(participants), names(original))
  expect_equal(nrow(participants), nrow(original) + 1129L)
  expect_equal(nrow(marousi), 1275L)
  expect_identical(
    participants[participants$poll_id != "marousi-2006", ],
    original[original$poll_id != "marousi-2006", ]
  )
  preserved <- marousi[match(existing$respondent_id, marousi$respondent_id), ]
  expect_identical(preserved, existing)
  expect_equal(sum(marousi$attended %in% TRUE), 142L)
  expect_equal(sum(is.na(marousi$attended)), 1116L)
  expect_equal(sum(marousi$attended %in% FALSE), 17L)
  absent <- fixture$full$scores |>
    dplyr::filter(wave == "t2", !wave_observed) |>
    dplyr::pull(respondent_id)
  expect_true(all(marousi$respondent_id[marousi$attended %in% FALSE] %in%
                    absent))
  phase_evidence <- analysis_attendance_evidence(
    marousi, fixture$full$scores
  )
  finalized <- analysis_attendance_contract(existing,
    phase_evidence$participants, phase_evidence$scores
  )
  expect_equal(sum(finalized$phase_participants$attended %in% TRUE &
                     finalized$phase_participants$poll_id == "marousi-2006"),
    138L
  )
  expect_equal(sum(marousi$panel), 133L)
  extra <- marousi[!marousi$respondent_id %in% existing$respondent_id, ]
  expect_true(all(grepl("^source-[0-9]+$", extra$respondent_id)))
  expect_true(all(is.na(extra$historical_respondent_id)))
  expect_true(all(is.na(extra$small_group_id)))
  expect_true(all(is.na(extra$assignment)))
  expect_true(all(is.na(extra$age) & is.na(extra$female) & is.na(extra$ba)))
  expect_equal(sum(extra$attended %in% TRUE), 13L)
})

test_that("Marousi full scores reproduce the report and preserve recruitment", {
  fixture <- marousi_phase_fixture()
  scores <- fixture$full$scores
  expect_equal(nrow(scores), 3825L)
  expect_equal(table(scores$wave), table(rep(c("t0", "t1", "t2"), each = 1275)))
  expect_equal(vapply(c("t0", "t1", "t2"), function(wave) {
    sum(scores$wave_observed[scores$wave == wave])
  }, integer(1)), c(t0 = 1275L, t1 = 154L, t2 = 138L))
  absent <- scores[!scores$wave_observed, ]
  expect_true(all(is.na(absent$score) & is.na(absent$n_correct)))
  expect_true(all(absent$n_observed == 0L))
  expect_true(all(scores$n_items == 7L))
  expect_true(all(scores$battery_id == "marousi-2006:score_only:knowledge"))
  telephone <- scores[scores$wave == "t0", ]
  expect_identical(
    telephone$score[match(as.character(fixture$bridge$caseid),
                          telephone$respondent_id)],
    fixture$bridge$t1know
  )
  post <- scores[scores$wave == "t2" & scores$wave_observed, ]
  expect_equal(tabulate(post$n_correct + 1L, nbins = 8L),
               c(1L, 21L, 29L, 35L, 33L, 17L, 2L, 0L))
  expect_equal(sum(post$n_correct), 413L)
  expect_equal(mean(post$score), 413 / (138 * 7))
  zero <- post[post$respondent_id == "source-31916", ]
  expect_equal(nrow(zero), 1L)
  expect_equal(zero$score, 0)
  expect_true(zero$wave_observed)
  participants <- fixture$full$participants
  post_people <- participants[match(post$respondent_id,
                                    participants$respondent_id), ]
  expect_equal(sum(is.na(post_people$small_group_id)), 9L)
  omitted_flag <- participants |>
    dplyr::filter(respondent_id == "source-14825")
  expect_true(omitted_flag$attended)
  expect_true(omitted_flag$panel)
  recovered_arrival <- scores |>
    dplyr::filter(respondent_id == "source-14825", wave == "t1")
  expect_equal(recovered_arrival$score, 5 / 7)
  expect_equal(scores$original_score_wave, scores$wave)
  expect_true(all(grepl("original T[123]", scores$timing_evidence)))
  blank_quiz <- scores[scores$respondent_id == "80000" &
                         scores$wave == "t1", ]
  expect_equal(blank_quiz$n_observed, 0L)
  expect_true(blank_quiz$wave_observed)
  expect_equal(blank_quiz$score, 0)
})

test_that("Marousi recruitment rejects an altered historical source bridge", {
  fixture <- marousi_phase_fixture()
  altered <- fixture$original
  first <- which(altered$poll_id == "marousi-2006")[1]
  altered$respondent_id[first] <- "source-30154"
  expect_error(analysis_phase_recruitment(
    altered, list(marousi = fixture$bridge)
  ))
})
