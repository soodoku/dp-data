health_attendance_fixture <- function() {
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_participants.parquet"
  )) |>
    dplyr::filter(poll_id == "uk-health-1998",
      respondent_id %in% c("3809", "4307")
    ) |>
    dplyr::select(-dplyr::any_of(c(
      "attendance_before_post_rule", "attendance_basis_before_post_rule",
      "attendance_evidence_before_post_rule"
    )))
  people$attended <- TRUE
  people$attended[people$source_dataset == "cor_sood"] <- NA
  scores <- tibble::as_tibble(people[
    c("poll_id", "source_dataset", "respondent_id")
  ]) |>
    dplyr::mutate(wave = "t2", wave_observed = FALSE)
  list(people = people, scores = scores)
}

test_that("source attendance is preserved before the empty-post override", {
  fixture <- health_attendance_fixture()
  people <- fixture$people
  expect_equal(nrow(people), 4L)
  expect_true(all(people$attended[people$source_dataset == "historical"]))
  result <- analysis_attendance_contract(people, people, fixture$scores)
  expect_true(all(result$participants$attended %in% FALSE))
  expect_true(all(result$phase_participants$attended %in% FALSE))
  expect_true(all(result$phase_participants$attendance_status ==
                    "did_not_attend"))
  expect_true(all(result$participants$attendance_before_post_rule))
  expect_true(all(result$participants$attendance_basis ==
                    "inferred_absent_post_questionnaire"))
  cor <- result$phase_participants$source_dataset == "cor_sood"
  expect_true(all(startsWith(
    result$phase_participants$attendance_evidence_before_post_rule[cor],
    "Verified same-source row bridge:"
  )))
  expect_identical(result$participants$panel, people$panel)
  expect_identical(result$participants$assignment, people$assignment)
  expect_identical(result$phase_participants$source_row, people$source_row)
})

test_that("explicit conflicting attendance is still rejected", {
  fixture <- health_attendance_fixture()
  people <- fixture$people
  people$attended[people$source_dataset == "cor_sood"] <- FALSE
  expect_error(analysis_attendance_contract(people, people, fixture$scores))
})

test_that("unknown attendance uses immediate absence only after the bridge", {
  fixture <- health_attendance_fixture()
  people <- fixture$people
  people$attended <- NA
  result <- analysis_attendance_contract(people, people, fixture$scores)
  expect_true(all(result$participants$attended %in% FALSE))
  expect_true(all(result$phase_participants$attendance_status ==
                    "did_not_attend"))
  expect_true(all(result$participants$attendance_basis ==
                    "inferred_absent_post_questionnaire"))
  fixture$scores$wave <- "t3"
  later <- analysis_attendance_contract(people, people, fixture$scores)
  expect_true(all(is.na(later$participants$attended)))
  expect_true(all(later$phase_participants$attendance_status == "unknown"))
})
