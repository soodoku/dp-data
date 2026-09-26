test_that("baseline political interest has one consistent direction", {
  rules <- read_metadata("harmonized_ordinal_measures")
  measures <- arrow::read_parquet(project_path(
    "output", "respondent", "respondent_measures.parquet"
  ))
  interest <- measures[measures$definition_id %in% rules$definition_id, ]
  expected <- c(
    "australia-republic-1999" = 1216L,
    "btp-health-education-2005" = 453L,
    "btp-national-2003" = 245L,
    "btp-presidential-primaries-2004" = 1216L,
    "nic-1996" = 903L,
    "nic2-2003" = 880L,
    "uk-eu-1995" = 899L,
    "uk-general-election-1997" = 1192L,
    "uk-monarchy-1996" = 855L
  )
  counts <- interest |>
    dplyr::group_by(.data$poll_id) |>
    dplyr::summarise(observed = sum(!is.na(.data$value_numeric)),
                     .groups = "drop")
  expect_setequal(counts$poll_id, names(expected))
  expect_identical(counts$observed[match(names(expected), counts$poll_id)],
                   unname(expected))
  expect_true(all(interest$value_numeric[!is.na(interest$value_numeric)] >= 0))
  expect_true(all(interest$value_numeric[!is.na(interest$value_numeric)] <= 1))

  responses <- arrow::read_parquet(project_path(
    "output", "respondent", "source_responses.parquet"
  ))
  for (i in seq_len(nrow(rules))) {
    rule <- rules[i, ]
    values <- interest[interest$poll_id == rule$poll_id, ]
    raw <- responses[
      responses$poll_id == rule$poll_id &
        responses$source_column == rule$source_column,
    ]
    code <- round(raw$raw_numeric[match(values$respondent_id,
                                        raw$respondent_id)])
    least <- if (rule$high_code == rule$max_code) {
      rule$min_code
    } else {
      rule$max_code
    }
    expect_true(all(values$value_numeric[code == least & !is.na(code)] == 0))
    expect_true(all(values$value_numeric[
      code == rule$high_code & !is.na(code)
    ] == 1))
    expect_true(all(is.na(values$value_numeric[
      is.na(code) | code < rule$min_code | code > rule$max_code
    ])))
    status <- raw$response_status[match(values$respondent_id,
                                        raw$respondent_id)]
    non_substantive <- !is.na(code) &
      (code < rule$min_code | code > rule$max_code)
    expect_true(all(status[non_substantive] == "non-substantive"))
  }
})

test_that("five-category interest retains its middle category", {
  measures <- arrow::read_parquet(project_path(
    "output", "respondent", "respondent_measures.parquet"
  ))
  responses <- arrow::read_parquet(project_path(
    "output", "respondent", "source_responses.parquet"
  ))
  values <- measures[
    measures$definition_id ==
      "uk-general-election-1997.political_interest_t1_harmonized@v1",
  ]
  raw <- responses[
    responses$poll_id == "uk-general-election-1997" &
      responses$source_column == "int1",
  ]
  code <- round(raw$raw_numeric[match(values$respondent_id,
                                      raw$respondent_id)])
  expect_true(any(code == 3, na.rm = TRUE))
  expect_true(all(values$value_numeric[code == 3 & !is.na(code)] == .5))
})
