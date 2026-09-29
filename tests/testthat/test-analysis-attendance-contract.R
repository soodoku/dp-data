source(file.path(root, "R", "analysis_attendance.R"))
source(file.path(root, "R", "respondents.R"))

attendance_contract_people <- function() {
  tibble::tibble(
    poll_id = "example", source_dataset = "historical",
    respondent_id = as.character(1:5), source_row = 1:5,
    attended = c(NA, TRUE, NA, NA, FALSE),
    panel = c(FALSE, TRUE, FALSE, FALSE, TRUE),
    assignment = NA_character_,
    attendance_evidence = "existing source evidence",
    attendance_status = c(
      "unknown", "attended", "unknown", "unknown",
      "did_not_attend"
    ),
    sessions_attended = NA_integer_
  )
}

test_that("immediate absence preserves stronger attendance evidence", {
  people <- attendance_contract_people()
  scores <- tibble::tibble(
    poll_id = "example", source_dataset = "historical",
    respondent_id = as.character(1:5),
    wave = c("t2", "t2", "t3", "t2", "t2"),
    wave_observed = c(FALSE, FALSE, FALSE, TRUE, TRUE)
  )
  result <- analysis_attendance_contract(people, people, scores)
  expect_identical(result$participants$attended, c(FALSE, TRUE, NA, NA, FALSE))
  expect_identical(
    result$participants$attended,
    result$phase_participants$attended
  )
  expect_identical(
    result$participants$attendance_basis,
    result$phase_participants$attendance_basis
  )
  expect_equal(
    result$participants$attendance_basis[1],
    "inferred_absent_post_questionnaire"
  )
  expect_identical(result$participants$panel, people$panel)
  expect_identical(result$participants$assignment, people$assignment)
  expect_identical(result$participants$respondent_id, people$respondent_id)
  conflict <- dplyr::bind_rows(scores, dplyr::mutate(scores[1, ],
    wave_observed = TRUE
  ))
  expect_error(analysis_attendance_contract(people, people, conflict))
})

test_that("Texas indicators distinguish nonattendance from uncertainty", {
  people <- attendance_contract_people()[1:2, ]
  people$poll_id <- "wtu-1996"
  people$attended <- c(TRUE, NA)
  raw <- tibble::tibble(source_row = 1:2, CASEID = 1:2, PART = c(1, 2))
  scores <- tibble::tibble(
    poll_id = "wtu-1996", source_dataset = "historical",
    respondent_id = c("1", "2"), wave = "t2", wave_observed = c(TRUE, FALSE)
  )
  result <- analysis_attendance_contract(people, people, scores,
    survey_reader = function(poll) raw
  )
  expect_identical(result$participants$attended, c(TRUE, FALSE))
  expect_true(all(result$participants$attendance_basis == "source_indicator"))
  expect_identical(result$participants$panel, people$panel)
})

test_that("climate partial attendance outranks absent exit questionnaires", {
  people <- attendance_contract_people()
  people$poll_id <- "a1r-climate-2021"
  people$source_dataset <- "control"
  people$attended <- c(NA, NA, NA, TRUE, FALSE)
  raw <- tibble::tibble(
    CaseId = 1:5, SESSION1 = c(1, 0, NA, 1, NA),
    SESSION2 = c(0, 0, NA, 1, NA), SESSION3 = c(0, 0, NA, 1, NA),
    SESSION4 = c(0, 0, NA, 1, NA)
  )
  for (number in 1:10) raw[[paste0("T2Q", number)]] <- c(NA, NA, NA, 5, 5)
  scores <- tibble::tibble(
    poll_id = "a1r-climate-2021", source_dataset = "control",
    respondent_id = as.character(1:5), wave = "t2",
    wave_observed = c(FALSE, FALSE, FALSE, TRUE, TRUE)
  )
  result <- analysis_attendance_contract(people, people, scores, climate = raw)
  expect_identical(result$participants$attended, c(
    TRUE, FALSE, FALSE, TRUE,
    FALSE
  ))
  expect_identical(
    result$phase_participants$sessions_attended,
    c(1L, 0L, NA_integer_, 4L, NA_integer_)
  )
  expect_equal(
    result$participants$attendance_basis[1:3],
    c(
      "source_session_records", "source_session_records",
      "inferred_absent_post_questionnaire"
    )
  )
  expect_identical(result$participants$panel, people$panel)
  raw$T2Q1[3] <- 99
  expect_error(analysis_attendance_contract(people, people, scores,
    climate = raw
  ))
})

test_that("Zeguo returned forms establish attendance without a group", {
  survey <- read_poll_survey("zeguo-2005")
  absent <- !zeguo_departure_observed(survey)
  ids <- c("36", "211", "90", as.character(survey$p[which(absent)[1]]))
  people <- attendance_contract_people()[1:4, ]
  people$poll_id <- "zeguo-2005"
  people$respondent_id <- ids
  people$attended <- c(NA, NA, TRUE, NA)
  people$panel <- c(FALSE, FALSE, TRUE, FALSE)
  scores <- tibble::tibble(
    poll_id = "zeguo-2005", source_dataset = "historical",
    respondent_id = ids, wave = "t2", wave_observed = c(TRUE, TRUE, TRUE, FALSE)
  )
  result <- analysis_attendance_contract(people, people, scores)
  expect_identical(result$participants$attended, c(TRUE, TRUE, TRUE, FALSE))
  expect_equal(
    result$participants$attendance_basis[1:3],
    rep("observed_post_questionnaire", 3)
  )
  expect_identical(result$participants$panel, people$panel)
})


test_that("same-source Cor bridges preserve identity and reject disagreement", {
  historical <- attendance_contract_people()[1:2, ]
  historical$attended <- c(TRUE, FALSE)
  cor <- historical
  cor$source_dataset <- "cor_sood"
  cor$respondent_id <- c("other-identity-2", "other-identity-1")
  cor$source_row <- c(2L, 1L)
  cor$attended <- NA
  people <- dplyr::bind_rows(historical, cor)
  scores <- tibble::tibble(
    poll_id = "example", source_dataset = "historical",
    respondent_id = c("1", "2"), wave = "t2", wave_observed = TRUE
  )
  result <- analysis_attendance_contract(people, people, scores)
  expect_identical(result$participants$attended, c(TRUE, FALSE, FALSE, TRUE))
  expect_identical(result$participants$respondent_id, people$respondent_id)
  expect_identical(result$participants$panel, people$panel)
  people$attended[3] <- TRUE
  expect_error(analysis_attendance_contract(people, people, scores))
})
