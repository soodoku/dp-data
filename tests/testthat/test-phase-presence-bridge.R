source(file.path(root, "R", "analysis_phases.R"))

presence_bridge_fixture <- function() {
  people <- tibble::tibble(
    poll_id = "poll", source_dataset = c("historical", "cor_sood"),
    respondent_id = "123", historical_respondent_id = c("123", NA_character_),
    source_row = 1L,
    identity_basis = c("unique-source-id", "source-or-file-row")
  )
  scores <- tibble::tibble(
    poll_id = "poll", source_dataset = c("historical", "cor_sood"),
    respondent_id = "123", wave = "t2", wave_role = "post_deliberation",
    wave_observed = c(TRUE, NA), score = c(0, 0), n_items = 5L,
    n_observed = 0L, n_correct = 0L
  )
  list(people = people, scores = scores)
}

test_that("verified full-form evidence fills a blank quiz without scoring it", {
  fixture <- presence_bridge_fixture()
  result <- bridge_analysis_phase_presence(fixture$scores, fixture$people)
  expect_identical(result$wave_observed, c(TRUE, TRUE))
  expect_identical(result[names(result) != "wave_observed"],
    fixture$scores[names(fixture$scores) != "wave_observed"]
  )
  expect_identical(
    bridge_analysis_phase_presence(result, fixture$people), result
  )
  fixture$scores$wave_observed <- c(NA, NA)
  expect_identical(bridge_analysis_phase_presence(
    fixture$scores, fixture$people
  ), fixture$scores)
  fixture$scores$wave_observed <- c(FALSE, NA)
  expect_identical(bridge_analysis_phase_presence(
    fixture$scores, fixture$people
  ), fixture$scores)
})

test_that("source identities and survey phases constrain the bridge", {
  fixture <- presence_bridge_fixture()
  fixture$people$respondent_id[1] <- "other"
  expect_error(bridge_analysis_phase_presence(fixture$scores, fixture$people),
    "mismatched source identities"
  )
  fixture <- presence_bridge_fixture()
  fixture$people$source_row[2] <- 2L
  expect_error(bridge_analysis_phase_presence(fixture$scores, fixture$people),
    "mismatched source rows"
  )
  fixture <- presence_bridge_fixture()
  fixture$people$historical_respondent_id[2] <- "other"
  expect_error(bridge_analysis_phase_presence(fixture$scores, fixture$people),
    "mismatched historical IDs"
  )
  fixture <- presence_bridge_fixture()
  fixture$scores$wave_role[2] <- "follow_up"
  expect_identical(bridge_analysis_phase_presence(
    fixture$scores, fixture$people
  ), fixture$scores)
  fixture$scores$wave_role[2] <- "post_deliberation"
  fixture$scores$wave[2] <- "t3"
  expect_identical(bridge_analysis_phase_presence(
    fixture$scores, fixture$people
  ), fixture$scores)
  fixture <- presence_bridge_fixture()
  fixture$scores$wave_observed[2] <- FALSE
  expect_error(bridge_analysis_phase_presence(fixture$scores, fixture$people),
    "conflicts with explicit absence"
  )
  fixture <- presence_bridge_fixture()
  expect_error(bridge_analysis_phase_presence(
    fixture$scores, dplyr::bind_rows(fixture$people, fixture$people[1, ])
  ))
})

test_that("file-scoped source rows and nonlinked records remain distinct", {
  fixture <- presence_bridge_fixture()
  fixture$people$respondent_id <- c("source:source-row-1", "source-row-1")
  fixture$people$identity_basis[1] <- "file-scoped-missing-id"
  fixture$scores$respondent_id <- fixture$people$respondent_id
  expect_identical(bridge_analysis_phase_presence(
    fixture$scores, fixture$people
  )$wave_observed, c(TRUE, TRUE))
  fixture$people$source_row[2] <- 2L
  expect_error(bridge_analysis_phase_presence(fixture$scores, fixture$people),
    "mismatched source rows"
  )
  fixture$people$respondent_id[2] <- "unlinked"
  fixture$scores$respondent_id[2] <- "unlinked"
  expect_identical(bridge_analysis_phase_presence(
    fixture$scores, fixture$people
  ), fixture$scores)
})

test_that("the full-source bridge changes only verified unknown presence", {
  scores <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_scores.parquet"
  ))
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_participants.parquet"
  ))
  result <- bridge_analysis_phase_presence(scores, people)
  expect_identical(result[names(result) != "wave_observed"],
    scores[names(scores) != "wave_observed"]
  )
  changed <- is.na(scores$wave_observed) & result$wave_observed %in% TRUE
  expect_true(all(result$source_dataset[changed] == "cor_sood"))
  expect_identical(
    result$wave_observed[!changed], scores$wave_observed[!changed]
  )
  expect_false(any(result$wave_observed[changed] %in% FALSE))
})

test_that("NIC blank quizzes borrow baseline answers, never exit answers", {
  scores <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_scores.parquet"
  ))
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_participants.parquet"
  ))
  result <- bridge_analysis_phase_presence(scores, people)
  baseline <- result |>
    dplyr::filter(poll_id == "nic-1996", wave == "t0") |>
    dplyr::inner_join(
      dplyr::select(people, "poll_id", "source_dataset", "respondent_id",
                    "source_row"),
      by = c("poll_id", "source_dataset", "respondent_id"),
      relationship = "many-to-one"
    )
  expect_true(all(baseline$wave_observed[
    baseline$respondent_id == "10008110"
  ]))
  expect_true(all(is.na(baseline$wave_observed[baseline$source_row == 1L])))
  survey <- read_poll_survey("nic-1996")
  row <- match(480L, survey$source_row)
  expect_equal(as.numeric(survey$EDLEVEL1[row]), 11)
  expect_equal(as.numeric(survey$POLINTR1[row]), 3)
})
