source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "historical_items.R"))

test_that("historical item scores reproduce both respondent waves", {
  items <- arrow::read_parquet(project_path(
    "output", "respondent", "historical_knowledge_items.parquet"
  ))
  historical <- readr::read_tsv(project_path(
    "output", "polardata", "polardata.tab"
  ), show_col_types = FALSE) |>
    dplyr::distinct(.data$dpnum, .data$caseid, .keep_all = TRUE)
  aliases <- read_metadata("respondent_sources") |>
    dplyr::select("poll_id", "dpnum")
  scores <- items |>
    dplyr::filter(!is.na(.data$historical_respondent_id)) |>
    dplyr::summarise(
      score = mean(.data$correct, na.rm = TRUE),
      .by = c("poll_id", "historical_respondent_id", "wave")
    ) |>
    dplyr::left_join(aliases, by = "poll_id", relationship = "many-to-one") |>
    dplyr::mutate(caseid = as.numeric(.data$historical_respondent_id)) |>
    dplyr::inner_join(
      dplyr::select(historical, "dpnum", "caseid", "t1know", "t2know"),
      by = c("dpnum", "caseid"), relationship = "many-to-one"
    )
  expect_equal(dplyr::n_distinct(scores$poll_id), 21L)
  expect_equal(dplyr::n_distinct(scores$wave), 2L)
  expect_lt(max(abs(scores$score - ifelse(
    scores$wave == 1L, scores$t1know, scores$t2know
  )), na.rm = TRUE), 1e-6)
  expect_false(anyDuplicated(items[c(
    "poll_id", "respondent_id", "item_id", "wave"
  )]) > 0L)
})
