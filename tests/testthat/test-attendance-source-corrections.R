source(file.path(root, "R", "analysis_phases.R"))
source(file.path(root, "R", "analysis_attendance.R"))
source(file.path(root, "R", "respondents.R"))

test_that("New Haven distinguishes a zero placeholder form from a blank quiz", {
  survey <- read_poll_survey("new-haven-2004")
  evidence <- analysis_new_haven_presence(survey)
  expect_equal(sum(evidence$departure_observed %in% FALSE), 1L)
  expect_equal(sum(evidence$departure_observed %in% TRUE), 131L)
  absent <- survey$assigned == 3124
  expect_equal(survey$source_row[absent], 46L)
  expect_false(evidence$departure_observed[absent])
  fields <- grep("^post_q", names(survey), value = TRUE)
  expect_equal(length(fields), 78L)
  expect_true(all(as.matrix(survey[absent, fields]) == 0))
  post <- new_haven_knowledge_items(survey, "post")
  expect_true(all(is.na(post[absent, ])))
  expect_true(all(!is.na(post[!absent, ])))
  built <- build_new_haven_individual(survey)
  dependent <- c(
    "knowledge_t2", "knowledge_joint", "knowledge_gain",
    "knowledge_gain_joint", "log_knowledge_joint", "high_knowledge_joint",
    "knowledge_midterm_joint", "knowledge_joint_midterm"
  )
  expect_true(all(is.na(built[absent, dependent])))
  expect_false(is.na(built$knowledge_t1[absent]))
  expect_false(is.na(built$knowledge_midterm[absent]))
  fixture <- survey[rep(which(absent), 3), ]
  fixture[2, fields] <- NA_real_
  fixture$post_q1a[3] <- 1
  expect_identical(new_haven_departure_observed(fixture), c(FALSE, NA, TRUE))
  expect_equal(new_haven_knowledge_items(fixture, "post")[3, ],
    stats::setNames(rep(0, 8), colnames(post))
  )
  expect_error(new_haven_departure_observed(
    dplyr::select(survey, -"post_q52d")
  ))
  expect_identical(read_poll_survey("new-haven-2004"), survey)
})

test_that("BTP National attendance follows recorded meetings", {
  expect_identical(btp_national_attendance(tibble::tibble(
    countmtg = c(0, 1, 8, NA_real_)
  )), c(FALSE, TRUE, TRUE, NA))
  expect_error(btp_national_attendance(tibble::tibble(countmtg = 9)))
  survey <- read_poll_survey("btp-national-2003")
  expect_equal(sum(survey$countmtg == 0), 1L)
  expect_equal(survey$serial[survey$countmtg == 0], 134)
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_participants.parquet"
  )) |>
    dplyr::filter(poll_id == "btp-national-2003")
  selected <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_participants.parquet"
  )) |>
    dplyr::filter(poll_id == "btp-national-2003")
  scores <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_scores.parquet"
  )) |>
    dplyr::filter(poll_id == "btp-national-2003")
  result <- analysis_attendance_contract(selected, people, scores)
  corrected <- result$phase_participants
  expect_equal(nrow(corrected), 245L)
  expect_equal(sum(corrected$attended %in% FALSE), 1L)
  expect_equal(sum(corrected$attended %in% TRUE), 244L)
  expect_false(corrected$attended[corrected$respondent_id == "134"])
  expect_false(result$participants$attended[
    result$participants$respondent_id == "134"
  ])
  expect_identical(corrected$panel, people$panel)
  expect_identical(corrected$source_row, people$source_row)
  expect_identical(corrected$respondent_id, people$respondent_id)
  expect_true(all(corrected$attendance_basis == "source_session_records"))
  expect_identical(read_poll_survey("btp-national-2003"), survey)
})
