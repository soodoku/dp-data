test_that("canonical item catalog covers both scored baseline batteries", {
  catalog <- read_metadata("items") |>
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character))
  historical <- arrow::read_parquet(project_path(
    "output", "respondent", "historical_knowledge_items.parquet"
  )) |>
    dplyr::filter(.data$wave == 1L) |>
    dplyr::distinct(.data$poll_id, historical_item_id = .data$item_id)
  cor <- read_metadata("knowledge_items") |>
    dplyr::filter(.data$wave == 1L) |>
    dplyr::distinct(
      .data$poll_id,
      cor_item_id = .data$item_id,
      source_column_t1 = .data$source_column
    )

  expect_equal(nrow(catalog), 224L)
  expect_equal(dplyr::n_distinct(catalog$poll_id), 28L)
  expect_false(anyDuplicated(catalog[c("poll_id", "item_id")]) > 0L)
  has_historical <- !is.na(catalog$historical_item_id)
  has_cor <- !is.na(catalog$cor_item_id)
  expect_true(all(has_historical | has_cor))
  expect_equal(sum(has_historical & has_cor), 123L)
  historical_ids <- catalog[
    !is.na(catalog$historical_item_id),
    c("poll_id", "historical_item_id")
  ]
  cor_ids <- catalog[!is.na(catalog$cor_item_id), c("poll_id", "cor_item_id")]
  expect_false(anyDuplicated(historical_ids) > 0L)
  expect_false(anyDuplicated(cor_ids) > 0L)
  expect_setequal(
    paste(historical$poll_id, historical$historical_item_id),
    paste(
      catalog$poll_id[!is.na(catalog$historical_item_id)],
      catalog$historical_item_id[!is.na(catalog$historical_item_id)]
    )
  )
  expect_setequal(
    paste(cor$poll_id, cor$cor_item_id),
    paste(
      catalog$poll_id[!is.na(catalog$cor_item_id)],
      catalog$cor_item_id[!is.na(catalog$cor_item_id)]
    )
  )
  expect_setequal(
    paste(cor$poll_id, cor$cor_item_id, cor$source_column_t1),
    paste(
      catalog$poll_id[!is.na(catalog$cor_item_id)],
      catalog$cor_item_id[!is.na(catalog$cor_item_id)],
      catalog$source_column_t1[!is.na(catalog$cor_item_id)]
    )
  )
  expect_false(anyNA(catalog[c(
    "poll_id", "item_id", "source_column_t1",
    "question", "wording_source", "response_type", "correct_codes",
    "correct_answer", "source_reference"
  )]))
  open_types <- c("open numeric", "open coded", "open text")
  open <- catalog$response_type %in% open_types
  expect_true(all(!is.na(catalog$answer_choices[!open])))
  administrative <- "refused|not asked|skipped|T2 only group|no answer"
  expect_false(any(grepl(
    administrative, catalog$answer_choices, ignore.case = TRUE
  ), na.rm = TRUE))
  expect_true(all(!is.na(catalog$coding_note[open])))
  expect_true(all(file.exists(project_path(catalog$source_reference))))
})
