source(file.path(root, "R", "respondents.R"))

test_that("blank text is missing without changing literal source answers", {
  survey <- read_poll_survey("nic-1996")[1:6, ]
  text <- c("", " \t ", NA_character_, "teacher", "NA", "n/a")
  survey$OCCUPAT1 <- text
  people <- tibble::tibble(
    poll_id = rep("nic-1996", 6L),
    respondent_id = as.character(1:6), source_row = survey$source_row
  )
  inputs <- tibble::tibble(
    poll_id = "nic-1996", definition_id = "knowledge_t1@historical-v1",
    source_column = "OCCUPAT1"
  )
  items <- read_metadata("knowledge_items")[0, ]
  answers <- source_response_rows(survey, people, inputs, items)
  expect_identical(answers$raw_text, text)
  expect_true(all(is.na(answers$raw_numeric)))
  expect_identical(answers$response_status,
    c(rep("system-missing", 3L), rep("answered", 3L))
  )
  expect_identical(answers$missing_code,
    c(rep("system", 3L), rep(NA_character_, 3L))
  )
})
