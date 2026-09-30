source(file.path(root, "R", "respondents.R"))

test_that("San Mateo unavailable departure forms have missing knowledge", {
  survey <- read_poll_survey("san-mateo-2008")
  raw_fields <- names(survey)[seq.int(
    match("t2Q1", names(survey)), match("t2q42", names(survey))
  )]
  raw_fields <- raw_fields[grepl("^t2[qQ]", raw_fields)]
  expect_length(raw_fields, 90L)
  absent <- rowSums(!is.na(as.matrix(survey[raw_fields]))) == 0L
  expect_equal(sum(absent), 1568L)
  expect_true(all(is.na(as.matrix(survey[absent, raw_fields]))))
  expect_true(all(survey$t2Q19_cor[absent] == 0))
  expect_true(all(survey$t2pkind[absent] == 0))

  evidence <- questionnaire_form_evidence(survey, "san-mateo-2008", "t2")
  position <- match(survey$source_row, evidence$source_row)
  expect_false(anyNA(position))
  expect_true(all(evidence$wave_observed[position[absent]] %in% FALSE))
  scored <- san_mateo_knowledge(survey, 2L)
  expect_true(all(is.na(scored[absent, ])))
  expect_equal(sum(is.na(scored)), 1568L * 8L)
  measures <- build_san_mateo_individual(survey)
  expected_missing <- c(
    "knowledge_t2", "knowledge_joint", "knowledge_gain",
    "knowledge_gain_joint", "log_knowledge_joint", "high_knowledge_joint"
  )
  expect_true(all(is.na(as.matrix(measures[absent, expected_missing]))))
  expect_equal(nrow(measures), nrow(survey))

  current <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_participants.parquet"
  )) |>
    dplyr::filter(
      .data$poll_id == "san-mateo-2008",
      .data$source_dataset == "historical"
    )
  people <- match(survey$source_row[absent], current$source_row)
  expect_false(anyNA(people))
  expect_true(all(!current$panel[people]))
})

test_that("San Mateo headers cannot substitute for questionnaire answers", {
  survey <- read_poll_survey("san-mateo-2008")
  pending <- which(survey$PARTICIPANTID %in% 1467)
  expect_length(pending, 1L)
  expect_equal(survey$participant[pending], 1)
  expect_equal(survey$t2QSTGRP[pending], 1)
  evidence <- questionnaire_form_evidence(survey, "san-mateo-2008", "t2")
  expect_false(evidence$wave_observed[
    match(survey$source_row[pending], evidence$source_row)
  ])
  expect_true(all(is.na(san_mateo_knowledge(survey[pending, ], 2L))))

  observed <- which(survey$participant == 1 & !is.na(survey$t2Q1))[1L]
  blank <- survey[observed, ]
  blank[paste0("t2Q", 19:26)] <- NA_real_
  expect_true(all(san_mateo_knowledge(blank, 2L) == 0))
  expect_equal(build_san_mateo_individual(blank)$knowledge_t2, 0)
  expect_true(questionnaire_form_evidence(
    blank, "san-mateo-2008", "t2"
  )$wave_observed)

  selected <- c(pending, which(survey$participant == 0)[1:2], observed)
  expect_equal(
    san_mateo_knowledge(survey[rev(selected), ], 2L),
    san_mateo_knowledge(survey, 2L)[rev(selected), , drop = FALSE]
  )
})


test_that("San Mateo empty form retains identity without attendance or score", {
  survey <- read_poll_survey("san-mateo-2008")
  pending_row <- survey$source_row[survey$PARTICIPANTID %in% 1467]
  keys <- c("poll_id", "source_dataset", "respondent_id")
  for (prefix in c("analysis", "analysis_phase")) {
    people <- arrow::read_parquet(project_path(
      "output", "analysis", paste0(prefix, "_participants.parquet")
    )) |>
      dplyr::filter(poll_id == "san-mateo-2008", source_row == pending_row)
    expect_equal(nrow(people), 2L)
    expect_true(all(!people$attended))
    expect_true(all(!people$panel))
    scores <- arrow::read_parquet(project_path(
      "output", "analysis", paste0(prefix, "_scores.parquet")
    )) |>
      dplyr::semi_join(people, by = keys) |>
      dplyr::filter(wave == "t2")
    expect_equal(nrow(scores), 2L)
    expect_true(all(is.na(scores$score)))
    expect_true(all(is.na(scores$n_correct)))
    if (prefix == "analysis_phase") {
      expect_true(all(!scores$wave_observed))
    }
  }
})
