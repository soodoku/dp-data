source(project_path("R", "analysis_source_attitudes.R"))

testthat::test_that("nonanswers do not erase valid percentages", {
  ratings <- source_attitude_values(
    c(0, 5, 10, 11, 0.5, 88, 99, NA, NA, NA),
    c(rep(NA_character_, 5), "No opinion", "No Answer / Refused",
      rep(NA_character_, 3)),
    0, 10, "rating", observed = c(rep(TRUE, 7), FALSE, TRUE, NA)
  )
  testthat::expect_identical(ratings$response_status,
    c(rep("answered", 3), rep("invalid_response", 2), "dk", "nonanswer",
      "absent_form", "blank", "source_missing")
  )
  testthat::expect_equal(ratings$value, c(0, 5, 10, rep(NA_real_, 7)))
  testthat::expect_equal(ratings$normalized_value[1:3], c(0, 0.5, 1))
  testthat::expect_identical(ratings$raw_value,
    c(0, 5, 10, 11, 0.5, 88, 99, NA, NA, NA)
  )
  for (unit in c("percent", "thermometer")) {
    percent <- source_attitude_values(c(99, 888, 999),
      c(NA, "No opinion", "No answer"), 0, 100, unit
    )
    testthat::expect_equal(percent$value, c(99, NA, NA))
    testthat::expect_equal(percent$normalized_value, c(0.99, NA, NA))
  }
  baseline <- source_attitude_values(c(88, 99),
    c("No Opinion/Don't Know", "No Answer/Refused"), 0, 10, "rating"
  )
  event <- source_attitude_values(c(88, 99),
    c("No answer", "Don't know"), 0, 10, "rating"
  )
  testthat::expect_equal(baseline$response_status, c("dk", "nonanswer"))
  testthat::expect_equal(event$response_status, c("nonanswer", "dk"))
})

testthat::test_that("transport keeps currencies and nominal choices distinct", {
  currency <- source_attitude_values(c(0, 50, 8888, 9999),
    c(NA, NA, "Don't know", "Refused"), 0, NA_real_, "dollars_per_month"
  )
  testthat::expect_equal(currency$value, c(0, 50, NA, NA))
  testthat::expect_true(all(is.na(currency$normalized_value)))
  choice <- source_attitude_values(c(1, 3, 2), rep(NA_character_, 3),
    NA_real_, NA_real_, "category", categories = c(1, 3)
  )
  testthat::expect_equal(choice$value, c(1, 3, NA))
  testthat::expect_true(all(is.na(choice$normalized_value)))
  unknown <- source_attitude_values(c(50, NA), c(NA, NA),
    NA_real_, NA_real_, "unverified"
  )
  testthat::expect_equal(unknown$response_status,
    c("unclassified_response", "source_missing")
  )
  testthat::expect_equal(unknown$raw_value, c(50, NA))
  testthat::expect_true(all(is.na(unknown$value)))
})

testthat::test_that("transport preserves all source records and cells", {
  participants <- arrow::read_parquet(project_path("output", "analysis",
    "analysis_phase_participants.parquet"
  ))
  scores <- arrow::read_parquet(project_path("output", "analysis",
    "analysis_phase_scores.parquet"
  ))
  original_participants <- participants
  original_scores <- scores
  built <- analysis_source_attitudes(participants, scores)
  definitions <- built$analysis_source_attitude_definitions
  responses <- built$analysis_source_attitude_responses
  testthat::expect_equal(nrow(definitions), 829)
  testthat::expect_equal(nrow(responses), 1039910)
  testthat::expect_identical(participants, original_participants)
  testthat::expect_identical(scores, original_scores)
  testthat::expect_false(anyDuplicated(
    responses[c("source_id", "source_row", "source_column")]
  ) > 0)
  specs <- source_attitude_sources()
  for (i in seq_len(nrow(specs))) {
    spec <- specs[i, ]
    path <- project_path("data", spec$poll_id, spec$path)
    raw <- switch(tools::file_ext(path),
      parquet = arrow::read_parquet(path),
      csv = readr::read_csv(path, show_col_types = FALSE),
      sav = haven::read_sav(path, user_na = TRUE)
    )
    source_path <- paste0("data/", spec$poll_id, "/", spec$path)
    subset_defs <- definitions[definitions$source_path == source_path, ]
    source_id <- unique(subset_defs$source_id)
    subset <- responses[responses$source_id == source_id, ]
    testthat::expect_equal(nrow(subset),
      nrow(raw) * length(unique(subset_defs$source_column))
    )
    testthat::expect_equal(sort(unique(subset$source_row)), seq_len(nrow(raw)))
    for (field in unique(subset_defs$source_column)) {
      values <- subset[subset$source_column == field, ]
      values <- values[order(values$source_row), ]
      testthat::expect_identical(values$raw_value, as.numeric(raw[[field]]),
        info = paste(spec$poll_id, spec$path, field)
      )
      id_column <- spec$id_column
      if (spec$poll_id == "marousi-2006") {
        id_column <- if (startsWith(field, "P_")) {
          "P_Q1_0"
        } else if (startsWith(field, "AR_")) {
          "AR_CODE"
        } else {
          "F_CODE"
        }
      }
      testthat::expect_identical(values$source_unit_id,
        as.character(raw[[id_column]]), info = paste(source_path, field)
      )
      testthat::expect_equal(unique(subset_defs$source_unit_id_column[
        subset_defs$source_column == field
      ]), id_column)
    }
  }
  marousi <- responses[responses$poll_id == "marousi-2006", ]
  ids <- marousi |>
    dplyr::select("source_row", "source_wave", "source_unit_id",
      "source_dataset", "respondent_id"
    ) |>
    dplyr::distinct()
  wave_ids <- tidyr::pivot_wider(ids, names_from = "source_wave",
    values_from = "source_unit_id"
  )
  testthat::expect_equal(nrow(wave_ids), 1275)
  testthat::expect_equal(sum(!is.na(wave_ids$T1)), 1275)
  testthat::expect_equal(sum(!is.na(wave_ids$T2)), 153)
  testthat::expect_equal(sum(!is.na(wave_ids$T3)), 138)
  testthat::expect_equal(sum(wave_ids$T1 != wave_ids$T2, na.rm = TRUE), 0)
  testthat::expect_equal(sum(wave_ids$T1 != wave_ids$T3, na.rm = TRUE), 16)
  canonical <- participants[participants$poll_id == "marousi-2006", ]
  position <- match(wave_ids$source_row, canonical$source_row)
  testthat::expect_identical(wave_ids$respondent_id,
    canonical$respondent_id[position]
  )
  testthat::expect_identical(wave_ids$source_dataset,
    canonical$source_dataset[position]
  )
  expected_means <- c(5.20272727272727, 5.26583407671722, 7.40194346289753)
  expected_refusals <- c(83L, 52L, 48L)
  for (i in seq_along(expected_refusals)) {
    field <- paste0("P_Q", 14 + i)
    item <- marousi[marousi$source_column == field, ]
    definition <- definitions[definitions$poll_id == "marousi-2006" &
                                definitions$source_column == field, ]
    testthat::expect_equal(definition$maximum, 10)
    refused <- item[item$raw_value %in% 88, ]
    testthat::expect_equal(nrow(refused), expected_refusals[i])
    testthat::expect_true(all(refused$response_status == "refused"))
    testthat::expect_true(all(is.na(refused$value)))
    testthat::expect_equal(mean(item$value, na.rm = TRUE), expected_means[i])
    raw_mean <- mean(item$raw_value[item$raw_value %in% 0:10])
    testthat::expect_equal(mean(item$normalized_value, na.rm = TRUE),
      raw_mean / 10
    )
  }
  no_answer <- marousi[marousi$source_column %in%
                         c("P_Q14", "P_Q19", "AR_Q23", "F_Q23") &
                         marousi$raw_value %in% 9, ]
  testthat::expect_equal(nrow(no_answer), 17)
  testthat::expect_true(all(no_answer$response_status == "nonanswer"))
  testthat::expect_true(all(is.na(no_answer$value)))
  denmark <- responses[responses$poll_id == "denmark-euro-2000", ]
  refused <- denmark[denmark$source_column == "s_32" &
                       denmark$raw_value %in% 16, ]
  unknown_choice <- denmark[denmark$source_column == "s_36" &
                              denmark$raw_value %in% 5, ]
  testthat::expect_equal(nrow(refused), 32)
  testthat::expect_true(all(refused$response_status == "refused"))
  testthat::expect_true(all(is.na(refused$value)))
  testthat::expect_equal(nrow(unknown_choice), 140)
  testthat::expect_true(all(unknown_choice$response_status == "dk"))
  testthat::expect_true(all(is.na(unknown_choice$value)))
  substantive <- denmark[(denmark$source_column == "s_32" &
                            denmark$raw_value %in% c(13, 14)) |
                           (denmark$source_column == "s_36" &
                              denmark$raw_value %in% 4), ]
  testthat::expect_equal(nrow(substantive), 66)
  testthat::expect_true(all(substantive$response_status == "answered"))
  testthat::expect_identical(substantive$value, substantive$raw_value)
  control <- responses[responses$source_wave == "source_t2ctrl", ]
  testthat::expect_equal(nrow(control), 993 * 21)
  testthat::expect_true(all(is.na(control$respondent_id)))
  testthat::expect_true(all(is.na(control$wave)))
  observed_control <- unique(control$source_row[
    control$response_status %in% c("answered", "dk", "refused")
  ])
  testthat::expect_length(observed_control, 992L)
  testthat::expect_true(all(control$wave_observed[
    control$source_row %in% observed_control
  ]))
  testthat::expect_true(all(is.na(control$wave_observed[
    !control$source_row %in% observed_control
  ])))
  dk_only <- denmark[
    (denmark$source_wave == "t0" &
       denmark$source_unit_id %in% c("1475", "2210", "3183", "3366")) |
      (denmark$source_wave == "source_t2ctrl" &
         denmark$source_unit_id == "11834"),
  ]
  testthat::expect_equal(nrow(dk_only), 165L)
  testthat::expect_equal(sum(dk_only$response_status == "dk"), 78L)
  testthat::expect_equal(sum(dk_only$response_status == "blank"), 87L)
  testthat::expect_true(all(dk_only$wave_observed))
  testthat::expect_true(all(is.na(dk_only$value)))
  vermont <- responses[responses$poll_id == "vermont-energy-2007", ]
  testthat::expect_true(all(vermont$wave_observed[
    vermont$source_wave == "T1"
  ]))
  unlinked_later <- vermont$source_wave %in% c("T2", "T3") &
    is.na(vermont$respondent_id)
  testthat::expect_equal(sum(unlinked_later), 2L * 604L * 84L)
  testthat::expect_true(all(is.na(vermont$wave_observed[unlinked_later])))
  testthat::expect_true(all(is.na(vermont$raw_value[unlinked_later])))
  invalid <- responses[responses$response_status == "invalid_response", ]
  testthat::expect_equal(nrow(invalid), 40)
  testthat::expect_true(all(invalid$poll_id == "vermont-energy-2007"))
  testthat::expect_true(all(invalid$source_column == "Q67"))
  testthat::expect_equal(as.integer(table(invalid$raw_value)), c(38L, 2L))
  unknown <- responses[
                       responses$response_status == "unclassified_response", ]
  testthat::expect_equal(nrow(unknown), 271)
  testthat::expect_setequal(unique(unknown$source_column), c("AR_Q21", "F_Q21"))
  testthat::expect_true(all(is.na(unknown$value)))
  testthat::expect_true(all(is.na(responses$value[
    responses$response_status != "answered"
  ])))
  valid_names <- grepl("^[a-z][a-z0-9_]*$", definitions$attitude_id)
  testthat::expect_true(all(valid_names))
})

testthat::test_that("identity bridges reject ambiguous canonical source rows", {
  spec <- source_attitude_sources()[6, ]
  raw <- tibble::tibble(CASEID = c(10, 20, 30))
  people <- tibble::tibble(poll_id = spec$poll_id, source_row = c(1L, 3L),
    source_dataset = "cor_sood", respondent_id = c("a", "c")
  )
  linked <- source_attitude_identity(raw, spec, people)
  testthat::expect_identical(linked$respondent_id, c("a", NA, "c"))
  testthat::expect_error(source_attitude_identity(raw, spec,
    dplyr::bind_rows(people, people[1, ])
  ))
})


testthat::test_that("source answers establish presence outside the cohort", {
  answers <- tibble::tibble(
    poll_id = rep("example", 10),
    source_id = c(rep("first", 8), "second", "first"),
    source_row = c(1L, 1L, 2L, 2L, 3L, 3L, 4L, 4L, 1L, 1L),
    source_unit_id = c("a", "a", "b", "b", "c", "c", "d", "d", "a", "a"),
    source_wave = c(rep("before", 9), "after"),
    raw_value = c(0, NA, 99, NA, NA, NA, NA, NA, NA, NA),
    value = c(0, NA, NA, NA, 0.5, NA, NA, NA, NA, NA),
    response_status = c("answered", "source_missing", "dk", "source_missing",
      "source_missing", "source_missing", "absent_form", "absent_form",
      "source_missing", "source_missing"
    ),
    wave_observed = c(rep(NA, 6), FALSE, FALSE, NA, NA)
  )
  actual <- source_attitude_presence(answers)
  testthat::expect_identical(actual$wave_observed,
    c(TRUE, TRUE, TRUE, TRUE, NA, NA, FALSE, FALSE, NA, NA)
  )
  testthat::expect_identical(actual$response_status,
    replace(answers$response_status, c(2L, 4L), "blank")
  )
  retained <- setdiff(names(answers), c("wave_observed", "response_status"))
  testthat::expect_identical(actual[retained], answers[retained])
  order <- rev(seq_len(nrow(answers)))
  testthat::expect_identical(
    source_attitude_presence(answers[order, ])[order, ], actual
  )
  for (status in c("refused", "nonanswer", "not_asked", "invalid_response")) {
    variant <- answers
    variant$response_status[3] <- status
    result <- source_attitude_presence(variant)
    if (status == "refused") {
      testthat::expect_true(all(result$wave_observed[3:4]))
    } else {
      testthat::expect_true(all(is.na(result$wave_observed[3:4])))
    }
  }
  missing_code <- answers
  missing_code$raw_value[3] <- NA_real_
  testthat::expect_true(all(is.na(
    source_attitude_presence(missing_code)$wave_observed[3:4]
  )))
  conflicting <- answers
  conflicting$wave_observed[2] <- FALSE
  testthat::expect_error(source_attitude_presence(conflicting),
    "answers conflict with explicit absence"
  )
  conflicting <- answers
  conflicting$source_unit_id[2] <- "another person"
  testthat::expect_error(source_attitude_presence(conflicting),
    "inconsistent native respondent identifiers"
  )
})
