testthat::test_that("California policy transport preserves source occasions", {
  raw <- arrow::read_parquet(project_path(
    "data", "california-whats-next-2011", "survey.parquet"
  ))
  participants <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_participants.parquet"
  ))
  scores <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_scores.parquet"
  ))
  built <- analysis_source_attitudes(participants, scores)
  poll <- "california-whats-next-2011"
  definitions <- built$analysis_source_attitude_definitions |>
    dplyr::filter(poll_id == poll)
  responses <- built$analysis_source_attitude_responses |>
    dplyr::filter(poll_id == poll)
  testthat::expect_equal(nrow(definitions), 78L)
  testthat::expect_equal(nrow(responses), 36816L)
  testthat::expect_setequal(unique(responses$source_row), seq_len(472L))
  testthat::expect_equal(sum(responses$response_status == "answered"), 30040L)
  testthat::expect_equal(sum(responses$response_status == "blank"), 1667L)
  testthat::expect_equal(sum(responses$response_status == "source_missing"),
    5109L
  )
  testthat::expect_false(any(responses$wave_observed %in% FALSE))
  testthat::expect_true(all(definitions$minimum == 0))
  testthat::expect_true(all(definitions$maximum == 10))
  testthat::expect_true(all(definitions$unit == "rating"))
  testthat::expect_identical(responses$source_scale_value, responses$raw_value)
  testthat::expect_identical(responses$value,
    responses$raw_value / 10
  )
  native_counts <- c(T2 = 401L, T3 = 412L)
  answer_counts <- c(T2 = 14510L, T3 = 15530L)
  for (wave in c("T2", "T3")) {
    values <- responses[responses$source_wave == wave, ]
    id_column <- paste0(tolower(wave), "_ParticipantNumber")
    testthat::expect_equal(sum(!is.na(values$raw_value)), answer_counts[[wave]])
    testthat::expect_equal(sum(values$wave_observed %in% TRUE),
      native_counts[[wave]] * 39L
    )
    testthat::expect_equal(unique(values$wave),
      if (wave == "T2") "t1" else "t2"
    )
    testthat::expect_equal(unique(values$wave_role),
      if (wave == "T2") "arrival" else "post_deliberation"
    )
    for (column in unique(values$source_column)) {
      item <- values[values$source_column == column, ]
      item <- item[order(item$source_row), ]
      testthat::expect_identical(item$raw_value, as.numeric(raw[[column]]))
      testthat::expect_identical(item$source_unit_id,
        as.character(raw[[id_column]])
      )
    }
  }
  linked <- responses |>
    dplyr::select(source_row, source_dataset, respondent_id) |>
    dplyr::distinct()
  people <- participants[participants$poll_id == poll, ]
  position <- match(linked$source_row, people$source_row)
  testthat::expect_identical(linked$respondent_id,
    people$respondent_id[position]
  )
  testthat::expect_equal(sum(is.na(linked$respondent_id)), 76L)
  arrival_only <- responses[responses$source_wave == "T2" &
                              responses$source_row %in% 1:5, ]
  testthat::expect_true(all(is.na(arrival_only$respondent_id)))
  testthat::expect_true(all(!is.na(arrival_only$source_unit_id)))
  testthat::expect_true(all(arrival_only$wave_observed))
  for (wave in c("T2", "T3")) {
    source_row <- if (wave == "T2") 1L else which(raw$id %in% 107)
    blank_policy <- responses[responses$source_wave == wave &
                                responses$source_row == source_row, ]
    testthat::expect_equal(nrow(blank_policy), 39L)
    testthat::expect_true(all(is.na(blank_policy$raw_value)))
    testthat::expect_true(all(blank_policy$wave_observed))
    testthat::expect_true(all(blank_policy$response_status == "blank"))
  }
  for (name in names(built)) {
    prior <- arrow::read_parquet(project_path(
      "output", "analysis", paste0(name, ".parquet")
    )) |>
      dplyr::filter(poll_id != poll)
    if ("normalized_value" %in% names(prior)) {
      prior <- prior |>
        dplyr::rename(source_scale_value = value, value = normalized_value)
    }
    retained <- built[[name]] |> dplyr::filter(poll_id != poll)
    testthat::expect_setequal(names(retained), names(prior))
    testthat::expect_identical(retained[names(prior)], prior)
  }
  report <- tibble::tribble(
    ~suffix, ~arrival, ~exit,
    "a", 0.609, 0.692,
    "b", 0.442, 0.449,
    "q", 0.501, 0.774,
    "am", 0.385, 0.489
  )
  for (i in seq_len(nrow(report))) {
    before <- raw[[paste0("t2q2", report$suffix[i])]]
    after <- raw[[paste0("t3q2", report$suffix[i])]]
    paired <- raw$part %in% 1 & !is.na(before) & !is.na(after)
    testthat::expect_equal(round(mean(before[paired]) / 10, 3),
      report$arrival[i]
    )
    testthat::expect_equal(round(mean(after[paired]) / 10, 3), report$exit[i])
  }
})

testthat::test_that("California no opinion differs from a substantive middle", {
  spec <- source_attitude_sources() |>
    dplyr::filter(poll_id == "california-whats-next-2011")
  dictionary <- source_attitude_dictionary(spec)
  for (field in c("t2q2a", "t3q2a")) {
    raw <- c(0, 5, 10, 99, NA_real_, 11, 0.5)
    labels <- dictionary$labels |>
      dplyr::filter(source_column == field)
    response <- source_attitude_values(raw,
      labels$value_label[match(raw, labels$source_value)],
      0, 10, "rating", observed = rep(TRUE, length(raw))
    )
    testthat::expect_identical(response$raw_value, raw)
    testthat::expect_identical(response$response_status,
      c("answered", "answered", "answered", "dk", "blank",
        "invalid_response", "invalid_response")
    )
    testthat::expect_equal(response$value,
      c(0, 0.5, 1, rep(NA_real_, 4))
    )
  }
})
