source(file.path(root, "R", "respondents.R"))

test_that("exact unconsidered labels exclude ambiguous codes", {
  labels <- tibble::tibble(
    source_column = c("a", "b", "c", "d", "e", "e", "f"),
    source_value = c("6", "4", "5", "8", "6", "6", "1"),
    value_label = c(
      "haven't thought much about that", "haven't thought much about this",
      "haven't thought much about it", "haven't thought about this8",
      "haven't thought much about that", "Agree", "Strongly agree"
    )
  )
  expect_equal(source_nonanswer_codes(labels), tibble::tibble(
    source_column = c("a", "b", "c"), source_value = c("6", "4", "5")
  ))
})

test_that("unconsidered attitudes retain raw values and missing reasons", {
  counts <- c(
    "btp-presidential-primaries-2004" = 1464L,
    "btp-national-2003" = 358L, "nic2-2003" = 2211L
  )
  contract <- read_metadata("respondent_sources")
  phrases <- c(
    "haven't thought much about that", "haven't thought much about this",
    "haven't thought much about it"
  )
  for (poll in names(counts)) {
    built <- build_poll_respondents(contract[contract$poll_id == poll, ])
    labels <- readr::read_csv(project_path(
      "data", poll, "value-labels.csv"
    ), show_col_types = FALSE)
    unconsidered <- labels[labels$value_label %in% phrases, ]
    answers <- dplyr::inner_join(
      built$source_responses, unconsidered,
      by = c("source_column", "raw_numeric" = "source_value")
    )
    survey <- read_poll_survey(poll)
    covered <- unconsidered[unconsidered$source_column %in%
                              unique(built$source_responses$source_column), ]
    expected <- purrr::map(seq_len(nrow(covered)), function(i) {
      field <- covered$source_column[i]
      code <- covered$source_value[i]
      rows <- which(as.numeric(survey[[field]]) == code)
      tibble::tibble(
        respondent_id = built$people$respondent_id[
          match(survey$source_row[rows], built$people$source_row)
        ],
        source_column = field, raw_numeric = code
      )
    }) |>
      purrr::list_rbind() |>
      dplyr::arrange(.data$source_column, .data$respondent_id)
    actual <- answers |>
      dplyr::select("respondent_id", "source_column", "raw_numeric") |>
      dplyr::arrange(.data$source_column, .data$respondent_id)
    expect_equal(actual, expected)
    expect_equal(nrow(answers), unname(counts[poll]))
    expect_true(all(answers$response_status == "non-substantive"))
    expect_equal(answers$missing_code, as.character(answers$raw_numeric))
    expect_true(all(is.finite(answers$raw_numeric)))
  }
})
