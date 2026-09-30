source(file.path(root, "R", "analysis_phases.R"))


test_that("Tanzania presence requires an actual substantive policy answer", {
  definitions <- read_metadata("tanzania_attitude_items")
  fields <- c(definitions$pre_column, definitions$post_column)
  survey <- tibble::tibble(HHID = 1:7, sample = "Citizens")
  for (field in fields) survey[[field]] <- NA_real_
  survey$H110 <- c(1, -99, -97, 98, 99, 8, 7)
  survey$H111 <- c(NA, 7, -99, NA, NA, NA, NA)
  survey$X1 <- 10
  survey$H600 <- 10
  survey$zdelib <- 1
  survey$group1 <- 1
  survey$sample[7] <- "Elites"
  result <- analysis_tanzania_presence(survey)
  expect_equal(nrow(result), 12L)
  expect_setequal(result$respondent_id, as.character(1:6))
  baseline <- dplyr::filter(result, wave == "t1")
  follow_up <- dplyr::filter(result, wave == "t2")
  expect_identical(baseline$wave_observed, c(TRUE, rep(NA, 5)))
  expect_identical(follow_up$wave_observed, c(NA, TRUE, rep(NA, 4)))
  expect_false(any(result$wave_observed %in% FALSE))
  reversed <- analysis_tanzania_presence(survey[7:1, ]) |>
    dplyr::arrange(wave, respondent_id)
  expect_equal(reversed, dplyr::arrange(result, wave, respondent_id))
  survey$H220[6] <- 0
  zero <- analysis_tanzania_presence(survey)
  expect_true(zero$wave_observed[zero$respondent_id == "6" &
                                   zero$wave == "t1"])
  duplicated <- dplyr::bind_rows(survey, survey[1, ])
  expect_error(analysis_tanzania_presence(duplicated), "Duplicated")
  incomplete <- survey[setdiff(names(survey), "H110")]
  expect_error(analysis_tanzania_presence(incomplete))
})


test_that("Tanzania source presence preserves native IDs and verified timing", {
  survey <- haven::read_dta(project_path(
    "data", "tanzania-2015", "participants.dta"
  ))
  result <- analysis_tanzania_presence(survey)
  citizens <- survey[survey$sample == "Citizens", ]
  expect_equal(nrow(result), 4004L)
  expect_equal(anyDuplicated(result[c("respondent_id", "wave")]), 0L)
  expect_setequal(result$respondent_id, as.character(citizens$HHID))
  expect_equal(sum(result$wave_observed %in% TRUE), 3859L)
  expect_equal(sum(is.na(result$wave_observed)), 145L)
  expect_identical(result$wave_observed[result$respondent_id == "240301"],
    c(NA, TRUE)
  )
  for (wave in 0:1) {
    source_wave <- paste0("t", wave + 1L)
    recorded <- result[result$wave == source_wave, ]
    position <- match(recorded$respondent_id, as.character(citizens$HHID))
    expect_false(anyNA(position))
    absent <- !recorded$wave_observed %in% TRUE
    fields <- grep(paste0("^[HX][0-9]+", wave, "$"), names(citizens),
      value = TRUE
    )
    expect_length(fields, 109L)
    fields <- c(fields, paste0(c("Xcitizen", "Xempsector"), wave))
    expect_true(all(is.na(citizens[position[absent], fields])))
    expect_equal(sum(!absent), c(2001L, 1858L)[wave + 1L])
  }
  roles <- read_metadata("analysis_phase_roles") |>
    dplyr::filter(poll_id == "tanzania-2015") |>
    dplyr::arrange(score_wave)
  expect_identical(roles$wave, c("t0", "t3"))
  expect_identical(roles$wave_role, c("pre_arrival", "follow_up"))
  waves <- read_metadata("analysis_survey_waves") |>
    dplyr::filter(poll_id == "tanzania-2015", wave == "t3")
  expect_identical(waves$mode, "telephone")
})


test_that("Tanzania phase presence preserves cohorts", {
  survey <- haven::read_dta(project_path(
    "data", "tanzania-2015", "participants.dta"
  ))
  expected <- analysis_tanzania_presence(survey) |>
    dplyr::mutate(wave = dplyr::recode(wave, t1 = "t0", t2 = "t3")) |>
    dplyr::arrange(respondent_id, wave)
  actual <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_scores.parquet"
  )) |>
    dplyr::filter(poll_id == "tanzania-2015") |>
    dplyr::arrange(respondent_id, wave)
  expect_equal(actual[names(expected)], expected)
  expect_identical(actual$questionnaire_presence_status, dplyr::if_else(
    actual$wave_observed %in% TRUE, "observed", "unknown"
  ))
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_participants.parquet"
  )) |>
    dplyr::filter(poll_id == "tanzania-2015")
  expect_equal(nrow(people), 2002L)
  expect_setequal(people$respondent_id, expected$respondent_id)
  follow_up_only <- people[people$respondent_id == "240301", ]
  expect_equal(nrow(follow_up_only), 1L)
  expect_identical(follow_up_only$arm, "other")
  expect_identical(follow_up_only$panel, FALSE)
  expect_true(is.na(follow_up_only$attended))
})
