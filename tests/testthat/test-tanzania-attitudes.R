test_that("Tanzania scales retain nonanswers and reject unreviewed codes", {
  values <- tanzania_attitude_scale(
    c(1, 3, 5, -99, -97, 98, 99, NA_real_, 20),
    1, 5, c(rep(TRUE, 8), FALSE)
  )
  expect_equal(values$value, c(0, 0.5, 1, rep(NA_real_, 6)))
  expect_equal(values$response_status, c(
    rep("answered", 3), rep("nonresponse", 4),
    "system_missing", "out_of_scope"
  ))
  expect_identical(values$raw_value,
                   c(1, 3, 5, -99, -97, 98, 99, NA_real_, 20))
  expect_error(tanzania_attitude_scale(6, 1, 5, TRUE))
  expect_equal(tanzania_attitude_scale(0, 0, 10, TRUE)$value, 0)
})

test_that("all source rows survive without assuming noncitizen scales", {
  rebuilt <- build_tanzania_attitude_tables()
  definitions <- rebuilt$tanzania_attitude_definitions
  responses <- rebuilt$tanzania_attitude_responses
  source <- haven::read_dta(project_path(
    "data", "tanzania-2015", "participants.dta"
  ))
  expect_equal(nrow(definitions), 22L)
  expect_equal(nrow(responses), 97900L)
  expect_equal(dplyr::n_distinct(responses$source_unit_id), 2225L)
  expect_equal(sum(responses$source_sample == "Citizens"), 2002L * 44L)
  noncitizens <- responses[responses$source_sample != "Citizens", ]
  expect_equal(nrow(noncitizens), 223L * 44L)
  expect_true(all(noncitizens$response_status == "out_of_scope"))
  expect_true(all(is.na(noncitizens$value)))
  expect_true(all(is.na(noncitizens$wave)))
  expect_true(all(is.na(noncitizens$wave_role)))
  expect_true(all(is.na(noncitizens$wave_instance_id)))

  for (column in c(definitions$pre_column, definitions$post_column)) {
    actual <- responses[responses$source_column == column, ]
    expect_identical(actual$source_row, seq_len(nrow(source)))
    expect_identical(actual$source_unit_id, as.character(source$HHID))
    expect_identical(actual$raw_value, as.numeric(source[[column]]))
  }
  for (table_name in names(rebuilt)) {
    path <- project_path("output", "tanzania_attitudes",
                         paste0(table_name, ".parquet"))
    restored <- arrow::read_parquet(path)
    expect_equal(restored, rebuilt[[table_name]][names(restored)])
    schema <- arrow::read_parquet(path, as_data_frame = FALSE)$schema
    expect_true(schema$Equals(export_schema(table_name)))
  }
})

test_that("borrowing preserves prior paired items and roster scope", {
  responses <- arrow::read_parquet(project_path(
    "output", "tanzania_attitudes", "tanzania_attitude_responses.parquet"
  ))
  grouped <- responses |>
    dplyr::filter(!is.na(group_id)) |>
    dplyr::select("source_unit_id", "attitude_id", "source_column",
                  "discussion_round", "group_id", "wave", "value")
  expect_equal(dplyr::n_distinct(grouped$source_unit_id), 371L)
  expect_equal(nrow(grouped), 371L * 44L)
  expect_setequal(grouped$wave, c("t0", "t3"))
  paired <- grouped |>
    dplyr::select(-"source_column") |>
    tidyr::pivot_wider(names_from = "wave", values_from = "value") |>
    dplyr::mutate(paired = !is.na(t0) & !is.na(t3))
  borrowing <- paired[paired$attitude_id == "borrowing_opposition", ]
  expect_equal(sum(!is.na(borrowing$t0)), 370L)
  expect_equal(sum(!is.na(borrowing$t3)), 361L)
  expect_equal(sum(borrowing$paired), 360L)
  expect_equal(dplyr::n_distinct(borrowing$group_id[borrowing$paired]), 25L)
  expect_true(all(borrowing$discussion_round == "round_1"))
  prior <- paired[paired$attitude_id != "borrowing_opposition", ]
  expect_equal(sum(prior$paired), 7530L)
  expect_equal(sum(prior$paired[prior$discussion_round == "round_1"]), 2519L)
  expect_equal(sum(prior$paired[prior$discussion_round == "round_2"]), 5011L)
  expect_equal(sum(paired$paired), 7890L)

  original <- haven::read_dta(project_path(
    "data", "tanzania-2015", "participants.dta"
  ))
  definitions <- read_metadata("tanzania_attitude_items")
  definitions <- definitions |>
    dplyr::filter(attitude_id != "borrowing_opposition")
  for (index in seq_len(nrow(definitions))) {
    definition <- definitions[index, ]
    actual <- prior[prior$attitude_id == definition$attitude_id, ]
    rows <- match(actual$source_unit_id, as.character(original$HHID))
    for (wave in c("t0", "t3")) {
      column <- if (wave == "t0") {
        definition$pre_column
      } else {
        definition$post_column
      }
      raw <- as.numeric(original[[column]][rows])
      expected <- ifelse(
        raw %in% c(-99, -97, 98, 99), NA_real_,
        (raw - definition$lower) / (definition$upper - definition$lower)
      )
      expect_identical(actual[[wave]], expected)
    }
  }
  special <- paired[paired$source_unit_id == "240301", ]
  expect_equal(nrow(special), 22L)
  expect_true(all(is.na(special$t0)))
  expect_true(all(!is.na(special$t3)))
})
