source(project_path("R", "argument_codes.R"))

test_that("coder extraction keeps all slots and excludes response text", {
  grid <- expand.grid(
    wave = 2:3, topic = 18:21, side = c("a", "b"), slot = 1:5,
    coder = c("ch", "la", "monty"), stringsAsFactors = FALSE
  )
  columns <- with(grid, paste0(
    "t", wave, ".q", topic, ".", side, slot, ".", coder
  ))
  data <- tibble::tibble(
    `Participant ID` = c(1L, 2L), response = "private text"
  )
  for (column in columns) data[[column]] <- c("c4.c5", NA_character_)
  result <- extract_northern_ireland_codes(data)
  expect_named(result, c(
    "respondent_id", "wave", "topic", "side", "slot", "coder", "raw_code"
  ))
  expect_equal(nrow(result), 480L)
  expect_equal(sum(is.na(result$raw_code)), 240L)
  expect_true(all(stats::na.omit(result$raw_code) == "c4.c5"))
  expect_error(extract_northern_ireland_codes(data[, -3]))
  data[["Participant ID"]] <- c(1L, 1L)
  expect_error(extract_northern_ireland_codes(data))
})

test_that("published argument labels retain the complete coder-slot grid", {
  data <- arrow::read_parquet(project_path(
    "data", "northern-ireland-2007", "argument-codes.parquet"
  ))
  expect_equal(nrow(data), 65760L)
  expect_equal(dplyr::n_distinct(data$respondent_id), 274L)
  expect_equal(anyDuplicated(data[1:6]), 0L)
  expect_true(all(table(data$respondent_id) == 240L))
  expect_setequal(data$wave, 2:3)
  expect_setequal(data$topic, 18:21)
  expect_setequal(data$side, c("a", "b"))
  expect_setequal(data$slot, 1:5)
  expect_setequal(data$coder, c("ch", "la", "monty"))
  expect_type(data$raw_code, "character")
})


test_that("CSV imports preserve literal multi-code labels", {
  grid <- expand.grid(
    wave = 2:3, topic = 18:21, side = c("a", "b"), slot = 1:5,
    coder = c("ch", "la", "monty"), stringsAsFactors = FALSE
  )
  columns <- with(grid, paste0(
    "t", wave, ".q", topic, ".", side, slot, ".", coder
  ))
  labels <- c("3,4", "4,5", "1,2", "c4,c5", " c4", " 4,5", "", "NA")
  data <- tibble::tibble(`Participant ID` = as.character(seq_along(labels)))
  for (column in columns) data[[column]] <- labels
  data$response_text <- "Not part of the coding extract"
  path <- tempfile(fileext = ".csv")
  on.exit(unlink(path))
  readr::write_csv(data, path)
  result <- read_northern_ireland_codes(path)
  expected <- labels[result$respondent_id]
  expected[expected %in% c("", "NA")] <- NA_character_
  expect_identical(result$raw_code, expected)
  expect_equal(nrow(result), length(labels) * 240L)
  expect_equal(anyDuplicated(result[1:6]), 0L)
  expect_false("response_text" %in% names(result))
  data[[columns[[1L]]]] <- seq_along(labels)
  expect_error(extract_northern_ireland_codes(data))
})

test_that("published labels retain reviewed original comma-separated sets", {
  data <- arrow::read_parquet(project_path(
    "data", "northern-ireland-2007", "argument-codes.parquet"
  ))
  expected <- tibble::tribble(
    ~respondent_id, ~wave, ~topic, ~side, ~slot, ~coder, ~raw_code,
    131201L, 2L, 21L, "b", 1L, "ch", "1,3",
    153008L, 2L, 20L, "b", 5L, "ch", " c4",
    256042L, 3L, 19L, "a", 1L, "la", " 4,5"
  )
  actual <- dplyr::semi_join(data, expected, by = names(data)[1:6])
  actual <- dplyr::arrange(actual, .data$respondent_id)
  expect_equal(actual, expected)
})
