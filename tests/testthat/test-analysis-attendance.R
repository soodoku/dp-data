attendance_inputs <- function() {
  list(
    participants = arrow::read_parquet(project_path(
      "output", "analysis", "analysis_phase_participants.parquet"
    )),
    scores = arrow::read_parquet(project_path(
      "output", "analysis", "analysis_phase_scores.parquet"
    ))
  )
}

test_that("reviewed attendance enriches phase tables without changing IDs", {
  inputs <- attendance_inputs()
  result <- analysis_attendance_evidence(inputs$participants, inputs$scores)
  people <- result$participants
  ids <- c("poll_id", "source_dataset", "respondent_id")
  expect_identical(people[ids], inputs$participants[ids])
  expect_identical(result$scores[c(ids, "battery_id", "wave")],
                   inputs$scores[c(ids, "battery_id", "wave")])
  expect_false(anyNA(people$attendance_status))
  expect_false(anyNA(people$attendance_evidence))
  expect_type(people$sessions_attended, "integer")
  expect_setequal(unique(result$scores$questionnaire_presence_status),
                  c("observed", "absent", "unknown"))
  expected <- c(
    `btp-2007` = 301L, `btp-online-primaries-2004` = 250L,
    `california-whats-next-2011` = 396L, `denmark-euro-2000` = 359L,
    `michigan-2009` = 310L, `northern-ireland-2007` = 124L,
    `vermont-energy-2007` = 146L
  )
  for (poll in names(expected)) {
    study <- people |>
      dplyr::filter(poll_id == poll, source_dataset == "cor_sood")
    expect_equal(sum(study$attended %in% TRUE), unname(expected[poll]))
  }
  reviewed <- inputs$participants$poll_id %in% names(expected) &
    inputs$participants$source_dataset == "cor_sood"
  expect_identical(people$attended[!reviewed],
                   inputs$participants$attended[!reviewed])
})

test_that("online post responders need not have attended any meetings", {
  inputs <- attendance_inputs()
  result <- analysis_attendance_evidence(inputs$participants, inputs$scores)
  people <- result$participants |>
    dplyr::filter(poll_id == "btp-online-primaries-2004",
                  source_dataset == "cor_sood")
  scores <- result$scores |>
    dplyr::filter(poll_id == "btp-online-primaries-2004",
                  source_dataset == "cor_sood", wave == "t2")
  post <- scores$wave_observed[match(people$respondent_id,
                                     scores$respondent_id)]
  expect_equal(sum(people$attended %in% FALSE), 78L)
  expect_equal(sum(people$attended %in% FALSE & post %in% TRUE), 46L)
  expect_equal(sum(people$attended %in% TRUE & post %in% TRUE), 239L)
  expect_equal(sum(people$attended %in% TRUE & post %in% TRUE &
                     !is.na(people$small_group_id)), 238L)
  expect_equal(sum(post %in% FALSE), 43L)
  expect_true(all(people$sessions_attended[people$attended %in% FALSE] == 0))
  expect_true(all(people$sessions_attended[people$attended %in% TRUE] > 0))
})

test_that("missing meeting flags do not automatically mean nonattendance", {
  raw <- tibble::tibble(
    mtg1 = c(0, NA, NA, 1), mtg2 = c(0, NA, NA, NA),
    mtg3 = c(0, NA, NA, NA), mtg4 = c(0, NA, NA, NA),
    mtg5 = c(0, NA, NA, NA), mtgatt = c(NA, NA, 0, NA),
    trtcont = c(NA, NA, 1, NA), expcont = 1
  )
  result <- primaries_attendance(raw)
  expect_identical(result$attended, c(FALSE, NA, FALSE, TRUE))
  expect_identical(result$sessions, c(0L, NA_integer_, 0L, NA_integer_))
  conflicting <- raw
  conflicting$mtg1[3] <- 1
  expect_error(primaries_attendance(conflicting))
  fractional <- raw[4, ]
  fractional$mtgatt <- 1.5
  fractional$trtcont <- 2
  expect_error(primaries_attendance(fractional))
})

test_that("generated correctness fields do not establish wave presence", {
  raw <- stats::setNames(
    as.data.frame(matrix(NA_real_, nrow = 2, ncol = 10)),
    paste0("f1q", 1:10)
  )
  raw$f1q43cor <- 0
  raw$f1q44cor_1 <- 0
  raw$f1q45correct <- 1
  raw$f1q46flag <- 0
  raw$f1q47score <- 0
  raw$f1q48 <- "generated text is not numeric raw-response evidence"
  expect_identical(questionnaire_observed(raw, "^f1q[0-9]"),
                   c(FALSE, FALSE))
  raw$f1q3[1] <- 99
  expect_identical(questionnaire_observed(raw, "^f1q[0-9]"),
                   c(TRUE, FALSE))
})

test_that("California distinguishes blank quizzes from absent questionnaires", {
  inputs <- attendance_inputs()
  result <- analysis_attendance_evidence(inputs$participants, inputs$scores)
  scores <- result$scores |>
    dplyr::filter(poll_id == "california-whats-next-2011",
                  source_dataset == "cor_sood",
                  grepl(":knowledge$", battery_id))
  phone <- dplyr::filter(scores, wave == "t0")
  exit <- dplyr::filter(scores, wave == "t2")
  expect_equal(sum(phone$wave_observed %in% TRUE), 386L)
  expect_equal(sum(phone$wave_observed %in% FALSE), 10L)
  expect_equal(sum(exit$wave_observed %in% TRUE), 396L)
  blank_phone <- c("153", "155", "207", "211", "324", "514", "528")
  blank_exit <- c("107", "219", "222", "407")
  expect_true(all(phone$wave_observed[phone$respondent_id %in% blank_phone]))
  expect_equal(phone$score[phone$respondent_id %in% blank_phone], rep(0, 7))
  expect_true(all(exit$wave_observed[exit$respondent_id %in% blank_exit]))
  expect_equal(exit$score[exit$respondent_id %in% blank_exit], rep(0, 4))
  absent <- phone$wave_observed %in% FALSE
  expect_true(all(is.na(phone$score[absent])))
  expect_true(all(is.na(phone$n_correct[absent])))
  expect_true(all(phone$n_observed[absent] == 0L))
  expect_true(all(phone$questionnaire_presence_status[absent] == "absent"))
  expect_true(all(result$participants$attended[
    result$participants$poll_id == "california-whats-next-2011" &
      result$participants$source_dataset == "cor_sood"
  ]))
})

test_that("BTP 2007 scheduled times are not counted as attended sessions", {
  inputs <- attendance_inputs()
  result <- analysis_attendance_evidence(inputs$participants, inputs$scores)
  people <- result$participants |>
    dplyr::filter(poll_id == "btp-2007", source_dataset == "cor_sood")
  expect_true(all(people$attended))
  expect_true(all(is.na(people$sessions_attended)))
  exceptional <- people$respondent_id == "2392"
  expect_equal(sum(exceptional), 1L)
  expect_match(people$attendance_evidence[exceptional],
               "positive logged discuss1:discuss4")
  raw <- read_poll_survey("btp-2007")
  selected <- attendance_source_rows(people, raw, "CaseID")
  selected[paste0("POST_Q31", letters[1:6], "_groups")] <- 998
  selected[paste0("discuss", 1:4)] <- 0
  unknown <- analysis_btp2007_attendance(selected)
  expect_true(all(is.na(unknown$attended)))
})

test_that("attendance evidence refuses an incorrect within-source ID join", {
  inputs <- attendance_inputs()
  people <- inputs$participants |>
    dplyr::filter(poll_id == "california-whats-next-2011",
                  source_dataset == "cor_sood")
  raw <- read_poll_survey("california-whats-next-2011")
  expect_equal(nrow(attendance_source_rows(people, raw, "id")), 396L)
  people$respondent_id[1] <- "unmatched-source-id"
  expect_error(attendance_source_rows(people, raw, "id"),
               "does not match within-source respondent IDs")
})
