source(project_path("R", "respondents.R"))
source(project_path("R", "historical_items.R"))
source(project_path("R", "linked_knowledge.R"))

testthat::test_that("knowledge preserves DK and respects form presence", {
  poll <- build_poll_knowledge("nic-1996")
  responses <- poll$knowledge_responses
  dk <- responses$response_reason %in% "dk"
  testthat::expect_true(any(dk))
  testthat::expect_true(all(responses$correct[dk] == 0L))
  testthat::expect_true(all(is.na(
    responses$correct_before_standardization[dk]
  )))
  blank <- responses$wave_observed %in% TRUE &
    responses$response_reason %in% c("blank", "source_missing") &
    responses$correct %in% 0L
  testthat::expect_true(any(blank))
  testthat::expect_true(all(responses$knowledge_response[blank] == "dk"))
  testthat::expect_true(all(responses$correct[blank] == 0L))
  unavailable <- !responses$wave_observed %in% TRUE
  testthat::expect_equal(sum(unavailable), 88L)
  testthat::expect_true(all(is.na(responses$correct[unavailable])))
  scores <- poll$knowledge_scores
  testthat::expect_equal(sum(is.na(scores$score)), 11L)
  testthat::expect_true(all(is.na(
    scores$n_correct[!scores$wave_observed %in% TRUE]
  )))
  testthat::expect_equal(nrow(responses), 7456L)
})

testthat::test_that("NIC follow-up uses its own return indicator", {
  survey <- read_poll_survey("nic-1996")
  contract <- read_metadata("respondent_sources") |>
    dplyr::filter(poll_id == "nic-1996")
  people <- source_people(survey, contract)
  matrices <- historical_item_matrices("nic-1996", survey)
  raw <- purrr::map2_dfr(matrices, 1:2, function(matrix, wave) {
    tibble::as_tibble(matrix) |>
      dplyr::mutate(source_row = survey$source_row) |>
      tidyr::pivot_longer(
        -source_row, names_to = "item_id", values_to = "correct"
      ) |>
      dplyr::mutate(
        poll_id = "nic-1996", wave = wave, correct = as.integer(correct)
      )
  }) |>
    dplyr::left_join(dplyr::select(people, source_row, respondent_id),
      by = "source_row", relationship = "many-to-one"
    )
  result <- apply_knowledge_contract(raw, survey, "nic-1996", "historical")
  post <- result[result$wave == 2L, ]
  index <- match(post$source_row, survey$source_row)
  expected <- rounded_source_code(survey$PART3[index]) %in% 1L
  testthat::expect_identical(post$wave_observed, expected)
  testthat::expect_equal(sum(!expected), 5764L)
  testthat::expect_true(all(is.na(matrices[[2]][!rounded_source_code(
    survey$PART3
  ) %in% 1L, ])))
  testthat::expect_true(all(is.na(post$correct[!expected])))
  testthat::expect_true(all(grepl("3$", post$source_column)))
  testthat::expect_identical(result$correct_before_standardization, raw$correct)
  testthat::expect_identical(
    post$correct[expected] == 1L,
    post$correct_before_standardization[expected] == 1L
  )
})

testthat::test_that("observed questionnaires retain blank quizzes", {
  denmark <- build_poll_knowledge("denmark-euro-2000")$knowledge_responses
  person <- denmark[denmark$respondent_id == "321" & denmark$wave == 2L, ]
  testthat::expect_equal(nrow(person), 9L)
  testthat::expect_true(all(is.na(person$raw_value)))
  testthat::expect_true(all(person$wave_observed))
  testthat::expect_true(all(person$correct == 0L))
  testthat::expect_true(all(person$knowledge_response == "dk"))
  testthat::expect_true(all(
    person$response_reason %in% c("blank", "source_missing")
  ))
  california <- build_california_knowledge()
  items <- california$california_knowledge_responses
  testthat::expect_equal(dplyr::n_distinct(items$respondent_id), 412L)
  testthat::expect_equal(sum(!items$wave_observed), 128L)
  testthat::expect_true(all(is.na(items$correct[!items$wave_observed])))
  testthat::expect_true(all(is.na(items$correct[
    items$response_reason == "invalid_response"
  ])))
  testthat::expect_true(any(items$knowledge_response %in% "dk"))
})
