source(project_path("R", "linked_knowledge.R"))

testthat::test_that("item identity follows source keys, not row order", {
  people <- tibble::tibble(
    poll_id = "poll", source_row = c(2L, 1L),
    respondent_id = c("person-b", "person-a"),
    historical_respondent_id = c("200", "100")
  )
  responses <- tibble::tibble(
    poll_id = "poll", respondent_id = c("old-a", "old-b"),
    source_row = 1:2, item_id = "knowledge-1", wave = 1L,
    source_column = "q1", correct = c(1L, NA_integer_),
    response_status = c("answered", "source_missing")
  )
  result <- link_respondent_knowledge(people, responses)
  testthat::expect_identical(result$historical_respondent_id, c("100", "200"))
  testthat::expect_identical(result$correct, c(1L, NA_integer_))
  testthat::expect_identical(result$correct_zero_filled, c(1L, 0L))
  testthat::expect_identical(result$response_status, responses$response_status)
  testthat::expect_error(link_respondent_knowledge(people[1, ], responses))
  testthat::expect_error(link_respondent_knowledge(
    dplyr::bind_rows(people, people[1, ]), responses
  ))
  testthat::expect_error(link_respondent_knowledge(
    people, dplyr::bind_rows(responses, responses[1, ])
  ))
})
