source(file.path(root, "R", "analysis_poll_metadata.R"))

test_that("analysis exports preserve keys and canonical question IDs", {
  directory <- project_path("output", "analysis")
  manifest <- readr::read_csv(
    file.path(directory, "manifest.csv"), show_col_types = FALSE
  )
  expect_equal(nrow(manifest), 6L)
  expect_true(all(file.exists(project_path(manifest$path))))
  expect_equal(
    vapply(project_path(manifest$path), digest::digest,
           character(1), file = TRUE, algo = "sha256", USE.NAMES = FALSE),
    manifest$sha256
  )
  tables <- stats::setNames(
    lapply(project_path(manifest$path), arrow::read_parquet), manifest$table
  )
  expect_equal(
    unname(vapply(tables, nrow, integer(1))), manifest$rows
  )
  polls <- tables$analysis_polls
  catalog <- tables$analysis_items
  people <- tables$analysis_participants
  responses <- tables$analysis_item_responses
  scores <- tables$analysis_scores
  expect_equal(nrow(polls), 50L)
  expect_equal(nrow(catalog), 245L)
  expect_equal(dplyr::n_distinct(people$poll_id), 33L)
  expect_equal(dplyr::n_distinct(responses$poll_id), 31L)
  expect_true(all(grepl("^knowledge_[0-9]{3}$", catalog$item_id)))
  expect_false(anyDuplicated(catalog[c("poll_id", "item_id")]) > 0L)
  expect_false(anyDuplicated(people[c(
    "poll_id", "source_dataset", "respondent_id"
  )]) > 0L)
  expect_false(anyDuplicated(responses[c(
    "poll_id", "source_dataset", "respondent_id", "wave", "item_id"
  )]) > 0L)
  expect_false(anyDuplicated(scores[c(
    "poll_id", "source_dataset", "respondent_id", "wave"
  )]) > 0L)
  expect_equal(nrow(dplyr::anti_join(
    dplyr::distinct(responses, poll_id, source_dataset, respondent_id),
    people, by = c("poll_id", "source_dataset", "respondent_id")
  )), 0L)
  expect_equal(nrow(dplyr::anti_join(
    dplyr::distinct(responses, poll_id, item_id), catalog,
    by = c("poll_id", "item_id")
  )), 0L)
  expect_setequal(
    unique(people$arm[people$poll_id == "amr-2024"]),
    c("attended", "control")
  )
  expect_equal(
    unique(scores$scale[scores$poll_id == "tanzania-2015"]),
    "standardized_index"
  )
  expect_true(all(is.na(scores$n_observed[
    scores$source_dataset == "historical"
  ])))
})

test_that("historical panel scores match the existing aggregate export", {
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_participants.parquet"
  ))
  scores <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_scores.parquet"
  ))
  legacy <- arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  ))
  sources <- read_metadata("respondent_sources") |>
    dplyr::select("poll_id", "dpnum")
  panel <- people |>
    dplyr::filter(source_dataset == "historical", panel) |>
    dplyr::inner_join(scores, by = c(
      "poll_id", "source_dataset", "respondent_id"
    )) |>
    dplyr::mutate(
      historical_respondent_id = as.numeric(historical_respondent_id)
    ) |>
    dplyr::left_join(sources, by = "poll_id", relationship = "many-to-one") |>
    dplyr::left_join(
      legacy, by = c("dpnum", "historical_respondent_id" = "caseid"),
      relationship = "many-to-one"
    )
  expect_equal(nrow(panel), 2L * nrow(legacy))
  expect_false(anyNA(panel$t1know))
  expect_equal(
    panel$score[panel$wave == "t1"],
    panel$t1know[panel$wave == "t1"], tolerance = 1e-7
  )
  expect_equal(
    panel$score[panel$wave == "t2"],
    panel$t2know[panel$wave == "t2"], tolerance = 1e-7
  )
})

test_that("reported timing conflicts remain visible without a false date", {
  events <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_poll_events.parquet"
  ))
  polls <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_polls.parquet"
  ))
  conflict <- dplyr::filter(events, poll_id == "new-haven-2004")
  expect_equal(nrow(conflict), 2L)
  expect_true(any(conflict$year_conflict))
  expect_true(all(is.na(conflict$start_date[conflict$year_conflict])))
  expect_true(is.na(polls$event_start_date[
    polls$poll_id == "new-haven-2004"
  ]))
  expect_true(all(!is.na(events$reference_id)))
})

test_that("conflicting source years null poll timing", {
  polls <- tibble::tibble(poll_id = "new-haven-2004", year = 2004L)
  facts <- tibble::tibble(
    poll_id = "new-haven-2004", field = "event_dates",
    value = c("2002-03-01 through 2002-03-03",
              "Archive appendix says 2004, March 1–3"),
    reference_id = c("paper", "archive"), source_locator = "date"
  )
  events <- analysis_poll_events(polls, facts)
  expect_true(all(events$year_conflict))
  expect_true(all(is.na(events$start_date)))
  expect_true(all(is.na(events$month)))
})
