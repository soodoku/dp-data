source(project_path("R", "analysis_attitudes.R"))

testthat::test_that("plain indices are primary and imputed values are stable", {
  directory <- project_path("output", "analysis")
  participants <- arrow::read_parquet(file.path(
    directory, "analysis_participants.parquet"
  ))
  built <- analysis_attitudes(participants)
  plain <- built$catalog |>
    dplyr::filter(
      construction == "policy index preserving component missingness"
    )
  testthat::expect_equal(nrow(plain), 23L)
  testthat::expect_true(all(plain$is_primary))
  alternatives <- built$catalog |>
    dplyr::filter(!is_primary)
  testthat::expect_equal(nrow(alternatives), 23L)
  testthat::expect_true(all(grepl(
    "_midpoint_imputed$", alternatives$attitude_id
  )))
  testthat::expect_setequal(plain$attitude_id,
    sub("_midpoint_imputed$", "", alternatives$attitude_id)
  )
  constructs <- built$catalog |>
    dplyr::mutate(construct = sub("_midpoint_imputed$", "", attitude_id)) |>
    dplyr::summarise(n_primary = sum(is_primary), .by = c(poll_id, construct))
  testthat::expect_true(all(constructs$n_primary == 1L))
  prior <- arrow::read_parquet(file.path(
    directory, "analysis_attitude_responses.parquet"
  )) |>
    dplyr::anti_join(plain, by = c("poll_id", "attitude_id"))
  retained <- built$responses |>
    dplyr::anti_join(plain, by = c("poll_id", "attitude_id"))
  testthat::expect_identical(retained, prior)
  definitions <- read_metadata("measure_definitions")
  measures <- arrow::read_parquet(project_path(
    "output", "respondent", "respondent_measures.parquet"
  ))
  historical <- arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  )) |>
    dplyr::left_join(
      dplyr::select(read_metadata("respondent_sources"), poll_id, dpnum),
      by = "dpnum", relationship = "many-to-one"
    ) |>
    dplyr::transmute(poll_id, historical_respondent_id = as.character(caseid),
      in_historical_scope = TRUE
    )
  check <- built$responses |>
    dplyr::inner_join(plain,
      by = c("poll_id", "attitude_id"), relationship = "many-to-one"
    ) |>
    dplyr::left_join(definitions,
      by = c("poll_id", "source_column" = "measure_id"),
      relationship = "many-to-one"
    ) |>
    dplyr::left_join(
      dplyr::select(measures, poll_id, respondent_id, definition_id,
        value_numeric
      ),
      by = c("poll_id", "respondent_id", "definition_id"),
      relationship = "one-to-one"
    ) |>
    dplyr::left_join(
      dplyr::select(participants, poll_id, source_dataset, respondent_id,
        historical_respondent_id
      ),
      by = c("poll_id", "source_dataset", "respondent_id"),
      relationship = "many-to-one"
    ) |>
    dplyr::left_join(historical,
      by = c("poll_id", "historical_respondent_id"),
      relationship = "many-to-one"
    )
  included <- check$in_historical_scope %in% TRUE
  testthat::expect_identical(check$value[included],
    check$value_numeric[included]
  )
  testthat::expect_true(all(is.na(check$value[!included])))
  testthat::expect_equal(nrow(check), sum(
    prior$attitude_id %in% alternatives$attitude_id
  ))
  testthat::expect_true(all(
    is.na(built$responses$value) | dplyr::between(built$responses$value, 0, 1)
  ))
  comparison <- check |>
    dplyr::mutate(attitude_id = paste0(attitude_id, "_midpoint_imputed")) |>
    dplyr::left_join(built$responses,
      by = c("poll_id", "source_dataset", "respondent_id", "attitude_id",
        "wave"
      ), relationship = "one-to-one", suffix = c("_plain", "_imputed")
    )
  testthat::expect_true(any(
    is.na(comparison$value_plain) & !is.na(comparison$value_imputed)
  ))
  testthat::expect_true(any(
    !is.na(comparison$value_plain) & !is.na(comparison$value_imputed) &
      comparison$value_plain != comparison$value_imputed
  ))
})
