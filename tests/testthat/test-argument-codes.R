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
