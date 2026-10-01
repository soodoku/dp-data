test_that("supplied weights preserve every source row and numeric value", {
  tables <- build_survey_weight_tables()
  definitions <- tables$survey_weight_definitions
  values <- tables$survey_weights
  expect_equal(nrow(definitions), 16L)
  expect_equal(dplyr::n_distinct(definitions$poll_id), 10L)
  expect_equal(nrow(values), 63234L)
  expect_equal(sum(!is.na(values$value)), 26929L)
  expect_false(anyDuplicated(
    values[c("source_id", "weight_id", "source_row")]
  ) > 0L)
  expect_true(all(definitions$usage_decision == "undecided"))

  for (index in seq_len(nrow(definitions))) {
    definition <- definitions[index, ]
    source <- read_survey_weight_source(project_path(definition$source_path))
    actual <- values |>
      dplyr::filter(source_id == definition$source_id,
                    weight_id == definition$weight_id)
    original <- as.numeric(source[[definition$source_column]])
    expect_identical(actual$source_row, seq_len(nrow(source)))
    expect_identical(actual$value, original)
    expect_equal(sum(is.na(actual$value)), sum(is.na(original)))
    expect_equal(sum(actual$value == 0, na.rm = TRUE),
                 sum(original == 0, na.rm = TRUE))
    expect_equal(range(actual$value, na.rm = TRUE),
                 range(original, na.rm = TRUE))
    if (!is.na(definition$source_unit_column)) {
      expect_identical(actual$source_unit_id,
                       as.character(source[[definition$source_unit_column]]))
    }
    if (!is.na(definition$source_wave_column)) {
      expect_identical(actual$source_wave,
                       as.character(source[[definition$source_wave_column]]))
    }
    if (!is.na(definition$weight_group_column)) {
      expect_identical(actual$weight_group,
                       as.character(source[[definition$weight_group_column]]))
    }
  }
})

test_that("alternative weights and wave-specific source identity survive", {
  definitions <- arrow::read_parquet(project_path(
    "output", "weights", "survey_weight_definitions.parquet"
  ))
  values <- arrow::read_parquet(project_path(
    "output", "weights", "survey_weights.parquet"
  ))
  climate <- values[values$poll_id == "a1r-climate-2021", ] |>
    dplyr::summarise(observed = sum(!is.na(value)), .by = weight_id)
  expect_equal(climate$observed[match(
    c("weight1", "weight2", "t3_weight1", "t3_weight2"), climate$weight_id
  )], c(1633L, 1633L, 1419L, 1419L))
  a1r <- values[values$poll_id == "america-in-one-room-2019", ]
  expect_true(all(is.na(a1r$source_unit_id)))
  expect_setequal(a1r$weight_id, c("weight_control", "weight_delegate"))
  amr <- values[values$poll_id == "amr-2024", ]
  expect_equal(nrow(amr), 4838L)
  expect_false(anyDuplicated(amr[c("source_unit_id", "source_wave")]) > 0L)
  expect_setequal(amr$source_wave, c("0", "1"))
  expect_equal(dplyr::n_distinct(amr$weight_group), 12L)
  nic2 <- values[values$poll_id == "nic2-2003", ]
  expect_false(anyNA(nic2$source_unit_id))
  expect_equal(dplyr::n_distinct(nic2$source_unit_id), 1493L)
  expect_true(any(values$value[values$poll_id == "michigan-2009"] == 0))

  rebuilt <- build_survey_weight_tables()
  for (table_name in names(rebuilt)) {
    restored <- arrow::read_parquet(project_path(
      "output", "weights", paste0(table_name, ".parquet")
    ))
    expect_equal(restored, rebuilt[[table_name]][names(restored)])
    schema <- arrow::read_parquet(project_path(
      "output", "weights", paste0(table_name, ".parquet")
    ), as_data_frame = FALSE)$schema
    expect_true(schema$Equals(export_schema(table_name)))
  }
  expect_true(all(definitions$source_sha256 != ""))
})

test_that("weight preservation does not normalize or discard incomplete rows", {
  source <- tibble::tibble(
    id = c("same", "same", NA_character_, "other"),
    wave = c(0L, 1L, 0L, 1L), context = c("A", "A", "B", NA_character_),
    supplied = c(0, NA_real_, 2.75, -1)
  )
  definitions <- tibble::tibble(
    poll_id = "fixture", source_id = "source", weight_id = "supplied",
    source_column = "supplied", source_unit_column = "id",
    source_wave_column = "wave", source_wave = NA_character_,
    weight_group_column = "context"
  )
  values <- survey_weight_values(source, definitions)
  expect_identical(values$value, source$supplied)
  expect_identical(values$source_unit_id, source$id)
  expect_identical(values$source_wave, as.character(source$wave))
  expect_identical(values$weight_group, source$context)
  definitions$source_wave_column <- "absent"
  expect_error(survey_weight_values(source, definitions))
  definitions$source_wave_column <- "wave"
  source$supplied <- as.character(source$supplied)
  expect_error(survey_weight_values(source, definitions))
})
