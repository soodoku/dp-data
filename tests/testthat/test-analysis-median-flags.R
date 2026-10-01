test_that("analysis median flags retain upstream definitions and identities", {
  participants <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_participants.parquet"
  ))
  fields <- c("education_above_median", "income_above_median")
  original <- dplyr::select(participants, -dplyr::any_of(fields))
  result <- add_analysis_median_flags(original)
  expect_identical(dplyr::select(result, -dplyr::all_of(fields)), original)
  expect_true(all(vapply(result[fields], is.logical, logical(1))))
  legacy <- arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  )) |>
    dplyr::left_join(
      dplyr::select(read_metadata("respondent_sources"), "poll_id", "dpnum"),
      by = "dpnum", relationship = "many-to-one"
    ) |>
    dplyr::transmute(
      poll_id, historical_respondent_id = as.character(caseid),
      education_expected = as.logical(bettered),
      income_expected = as.logical(highinc)
    )
  matched <- result |>
    dplyr::filter(source_dataset == "historical") |>
    dplyr::inner_join(legacy,
      by = c("poll_id", "historical_respondent_id"),
      relationship = "one-to-one"
    )
  expect_equal(nrow(matched), 5869L)
  expect_identical(matched$education_above_median, matched$education_expected)
  expect_identical(matched$income_above_median, matched$income_expected)
  cor <- result |>
    dplyr::filter(source_dataset == "cor_sood", poll_id %in% legacy$poll_id) |>
    dplyr::inner_join(
      result |>
        dplyr::filter(source_dataset == "historical") |>
        dplyr::select("poll_id", "source_row", dplyr::all_of(fields)),
      by = c("poll_id", "source_row"), relationship = "one-to-one",
      suffix = c("", "_historical")
    )
  expect_equal(nrow(cor), 4705L)
  expect_equal(dplyr::n_distinct(cor$poll_id), 16L)
  for (field in fields) {
    expect_identical(cor[[field]], cor[[paste0(field, "_historical")]])
    supported <- legacy$poll_id
    if (field == "education_above_median") {
      supported <- c(supported, "america-in-one-room-2019")
    }
    expect_true(all(is.na(result[[field]][!result$poll_id %in% supported])))
  }
  changed_sample <- original
  changed_sample$panel <- FALSE
  expect_identical(
    add_analysis_median_flags(changed_sample)[fields], result[fields]
  )
})
