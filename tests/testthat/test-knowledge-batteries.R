test_that("all deposited knowledge batteries match their declared schema", {
  batteries <- read_metadata("knowledge_batteries")
  polls <- read_metadata("polls")
  sources <- read_metadata("source_files")

  expect_equal(nrow(batteries), 23L)
  expect_equal(anyDuplicated(batteries$poll_id), 0L)
  expect_true(all(batteries$poll_id %in% polls$poll_id))
  expect_true(all(batteries$source_id %in% sources$source_id))
  expect_true(all(batteries$linkage_status == "no-respondent-id"))

  for (row in seq_len(nrow(batteries))) {
    battery <- batteries[row, ]
    source_path <- sources |>
      dplyr::filter(.data$source_id == battery$source_id) |>
      dplyr::pull(.data$path)
    expect_length(source_path, 1L)
    responses <- readr::read_csv(
      project_path(source_path),
      show_col_types = FALSE
    )
    pre <- strsplit(battery$pre_columns, "|", fixed = TRUE)[[1]]
    post <- strsplit(battery$post_columns, "|", fixed = TRUE)[[1]]

    expect_equal(nrow(responses), battery$respondents)
    expect_length(pre, battery$items)
    expect_length(post, battery$items)
    expect_identical(
      names(responses),
      c(pre, post, battery$demographic_column)
    )
    values <- unlist(responses[c(pre, post)], use.names = FALSE)
    expect_true(all(stats::na.omit(values) %in% c(0, 1)))
  }
})
