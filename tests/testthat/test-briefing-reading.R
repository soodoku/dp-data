source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "briefing_reading.R"))

test_that("briefing-reading export uses observed source responses", {
  reading <- arrow::read_parquet(project_path(
    "output", "respondent", "briefing_reading.parquet"
  ))
  expect_equal(dplyr::n_distinct(reading$poll_id), 9L)
  expect_false(anyDuplicated(reading[c("poll_id", "respondent_id")]) > 0L)
  expect_true(all(reading$reading_score[!is.na(reading$reading_score)] %in% c(
    0, .25, .33, .5, .66, .75, 1
  )))
  observed <- reading |>
    dplyr::filter(!is.na(.data$reading_score)) |>
    dplyr::count(.data$poll_id, name = "n")
  expected <- c(
    "australia-republic-1999" = 344L,
    "cpl-1996" = 209L,
    "europolis-2009" = 340L,
    "swepco-1996" = 232L,
    "wtu-1996" = 230L
  )
  counts <- observed$n[match(names(expected), observed$poll_id)]
  expect_equal(stats::setNames(counts, names(expected)), expected)
})

test_that("four previously scored briefing reports retain their values", {
  reading <- arrow::read_parquet(project_path(
    "output", "respondent", "briefing_reading.parquet"
  ))
  original <- c(
    "nic-1996", "nic2-2003", "san-mateo-2008", "tomorrows-europe-2007"
  )
  aliases <- read_metadata("respondent_sources") |>
    dplyr::select("poll_id", "dpnum")
  historical <- readr::read_tsv(project_path(
    "output", "polardata", "polardata.tab"
  ), show_col_types = FALSE) |>
    dplyr::distinct(.data$dpnum, .data$caseid, .keep_all = TRUE)
  comparison <- reading |>
    dplyr::filter(.data$poll_id %in% original) |>
    dplyr::left_join(aliases, by = "poll_id", relationship = "many-to-one") |>
    dplyr::mutate(caseid = as.numeric(.data$historical_respondent_id)) |>
    dplyr::inner_join(
      dplyr::select(historical, "dpnum", "caseid", "readbrief"),
      by = c("dpnum", "caseid"), relationship = "many-to-one"
    )
  expect_equal(dplyr::n_distinct(comparison$poll_id), 4L)
  delta <- abs(comparison$reading_score - comparison$readbrief)
  expect_lt(max(delta, na.rm = TRUE), 1e-6)
})
