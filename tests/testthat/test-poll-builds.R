pilot_tables <- function() {
  polls <- purrr::map(
    c("uk-health-1998", "northern-ireland-2007"), build_poll_knowledge
  )
  names(polls[[1]]) |>
    rlang::set_names() |>
    purrr::map(function(name) {
      purrr::map(polls, name) |> purrr::list_rbind()
    })
}

test_that("the two survey builds exactly reproduce the deposited batteries", {
  tables <- pilot_tables()
  audit <- validate_knowledge_parity(tables)
  expect_equal(sum(audit$item_differences), 0)
  expect_equal(sum(audit$female_differences), 0)
  expect_equal(nrow(tables$respondents), 354L)
  expect_equal(nrow(tables$knowledge_responses), 4496L)
  expect_equal(nrow(tables$knowledge_scores), 708L)
  expect_equal(nrow(tables$memberships), 354L)
  expect_equal(nrow(tables$groups), 35L)
})

test_that("Northern Ireland retains its first headerless group record", {
  raw_lines <- readLines(
    project_path("data", "northern-ireland-2007", "groups.csv")
  )
  first <- strsplit(raw_lines[[1]], ",", fixed = TRUE)[[1]]
  built <- build_poll_knowledge("northern-ireland-2007")
  restored <- built$memberships |>
    dplyr::filter(.data$respondent_id == first[[1]])
  expect_equal(nrow(restored), 1L)
  expect_equal(restored$group_id, first[[2]])
  expect_setequal(
    built$memberships$respondent_id, built$respondents$respondent_id
  )
})

test_that("Northern Ireland ordering follows cserial rather than source row", {
  survey <- read_poll_survey("northern-ireland-2007")
  original <- knowledge_participants("northern-ireland-2007", survey)
  reversed <- knowledge_participants(
    "northern-ireland-2007", survey[rev(seq_len(nrow(survey))), ]
  )
  expect_identical(original, reversed)
})

test_that("duplicate and incomplete group mappings are rejected", {
  survey <- read_poll_survey("northern-ireland-2007")
  groups <- readr::read_csv(
    project_path("data", "northern-ireland-2007", "groups.csv"),
    col_names = c("respondent_id", "group_id"),
    col_types = readr::cols(.default = readr::col_character())
  )
  expect_error(knowledge_participants(
    "northern-ireland-2007", survey,
    dplyr::bind_rows(groups, groups[1, ])
  ))
  expect_error(knowledge_participants(
    "northern-ireland-2007", survey, groups[-1, ]
  ))
})

test_that("unreviewed response codes cannot silently become missing", {
  tables <- build_poll_knowledge("uk-health-1998")
  raw <- tables$knowledge_responses |>
    dplyr::select(
      "poll_id", "respondent_id", "source_row", "source_column", "raw_value"
    )
  raw$raw_value[[1]] <- 999
  expect_error(
    score_knowledge_responses(raw, read_metadata("knowledge_items")),
    "Unmapped response code"
  )
})

test_that("parity checks detect a changed scored item", {
  tables <- pilot_tables()
  row <- which(!is.na(tables$knowledge_responses$correct))[[1]]
  tables$knowledge_responses$correct[[row]] <-
    1L - tables$knowledge_responses$correct[[row]]
  expect_error(validate_knowledge_parity(tables))
})

test_that("responses preserve missing codes and scores declare filling", {
  tables <- pilot_tables()
  responses <- tables$knowledge_responses
  missing <- responses$response_status != "answered"
  expect_true(any(responses$response_status == "source_missing"))
  expect_true(any(responses$response_status == "non_substantive"))
  expect_true(all(is.na(responses$correct[missing])))
  expect_true(all(!is.na(responses$missing_code[missing])))
  expect_true(all(is.na(responses$missing_code[!missing])))
  expect_true(all(responses$correct[!missing] %in% 0:1))

  for (poll_id in unique(tables$respondents$poll_id)) {
    battery <- readr::read_csv(
      project_path("data", poll_id, "knowledge-battery.csv"),
      col_types = readr::cols(.default = readr::col_double())
    )
    people <- tables$respondents |>
      dplyr::filter(.data$poll_id == .env$poll_id) |>
      dplyr::arrange(.data$battery_row)
    items <- read_metadata("knowledge_items") |>
      dplyr::filter(.data$poll_id == .env$poll_id)
    for (wave in 1:2) {
      columns <- items$benchmark_column[items$wave == wave]
      expected <- as.matrix(battery[columns])
      expected[is.na(expected)] <- 0
      scores <- tables$knowledge_scores |>
        dplyr::filter(
          .data$poll_id == .env$poll_id, .data$wave == .env$wave
        ) |>
        dplyr::arrange(match(.data$respondent_id, people$respondent_id))
      expect_equal(scores$score_zero_filled, rowMeans(expected))
      expect_true(all(scores$n_observed <= scores$n_items))
    }
  }
})

test_that("the Northern Ireland public extract excludes all named verbatims", {
  survey <- read_poll_survey("northern-ireland-2007")
  excluded <- read_metadata("source_field_exclusions")$source_column
  variables <- readr::read_csv(
    project_path("data", "northern-ireland-2007", "variables.csv"),
    show_col_types = FALSE
  )
  expect_equal(dim(survey), c(868L, 449L))
  expect_equal(survey$source_row, seq_len(868L))
  expect_s3_class(survey$intdate, "Date")
  expect_false(any(purrr::map_lgl(survey, is.character)))
  expect_length(intersect(excluded, names(survey)), 0L)
  expect_equal(nrow(variables), 528L)
  expect_equal(sum(!variables$public), 80L)
  expect_setequal(variables$source_column[variables$public], names(survey)[-1])
})

test_that("Parquet exports preserve declared types and values", {
  tables <- pilot_tables()
  directory <- withr::local_tempdir()
  expected_types <- c(
    string = "character", int32 = "integer",
    float64 = "double", bool = "logical"
  )
  for (name in names(tables)) {
    manifest <- write_typed_export(tables[[name]], name, directory)
    restored <- arrow::read_parquet(
      file.path(directory, paste0(name, ".parquet"))
    )
    columns <- read_metadata("canonical_columns") |>
      dplyr::filter(.data$table == name)
    expect_identical(
      unname(purrr::map_chr(restored, typeof)),
      unname(expected_types[columns$arrow_type])
    )
    expect_equal(nrow(restored), manifest$rows)
    expect_equal(restored, tables[[name]][columns$column], ignore_attr = TRUE)
  }
})

test_that("UK Health keys agree with the original correctness variables", {
  survey <- read_poll_survey("uk-health-1998")
  responses <- build_poll_knowledge("uk-health-1998")$knowledge_responses
  purrr::walk(unique(responses$source_column), function(column) {
    observed <- responses |>
      dplyr::filter(.data$source_column == .env$column) |>
      dplyr::arrange(.data$source_row)
    answer_column <- sub("^soph", "answer", column)
    expect_equal(
      dplyr::if_else(
        observed$response_status == "source_missing", NA_integer_,
        tidyr::replace_na(observed$correct, 0L)
      ),
      as.numeric(survey[[answer_column]])
    )
  })
})
