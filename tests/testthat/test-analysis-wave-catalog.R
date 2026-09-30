source(file.path(root, "R", "analysis_wave_catalog.R"))

test_that("published phase tables retain their declared Arrow types", {
  tables <- c(
    "analysis_studies", "analysis_survey_waves",
    "analysis_phase_participants", "analysis_phase_scores",
    "analysis_phase_item_responses"
  )
  for (table in tables) {
    published <- arrow::read_parquet(
      project_path("output", "analysis", paste0(table, ".parquet")),
      as_data_frame = FALSE
    )
    expect_true(published$schema$Equals(export_schema(table)), info = table)
  }
})

test_that("wave catalog separates studies, phases and survey instances", {
  catalog <- analysis_wave_catalog()
  waves <- catalog$analysis_survey_waves
  studies <- catalog$analysis_studies
  expect_equal(nrow(studies), nrow(read_metadata("polls")))
  aliases <- studies$study_id[studies$poll_id %in% c(
    "btp-online-primaries-2004", "btp-presidential-primaries-2004"
  )]
  expect_equal(aliases, rep("btp-primaries-2004", 2L))
  expect_s3_class(waves$date_start, "Date")
  expect_s3_class(waves$date_end, "Date")
  expect_type(waves$temporal_order, "integer")
  expect_false(anyDuplicated(waves[c("poll_id", "wave_instance_id")]) > 0L)
  expect_true(all(c("amr-2024", "bulgaria-crime-2002") %in% studies$poll_id))
})

test_that("retained arrivals have scores with explicit battery scope", {
  waves <- analysis_wave_catalog()$analysis_survey_waves
  arrivals <- dplyr::filter(waves, wave == "t1")
  missing_exports <- dplyr::filter(
    arrivals, poll_id %in% c(
      "california-whats-next-2011", "europolis-2009", "denmark-euro-2000",
      "vermont-energy-2007", "michigan-2009"
    )
  )
  expect_true(all(missing_exports$availability == "score_exported"))
  expect_setequal(missing_exports$poll_id, c(
    "california-whats-next-2011", "europolis-2009", "denmark-euro-2000",
    "vermont-energy-2007", "michigan-2009"
  ))
  expect_equal(missing_exports$battery_scope[
    missing_exports$poll_id == "michigan-2009"
  ], "shared_selected_nine_and_separate_placement_batteries")
  expect_false(any(waves$wave == "t1" & waves$poll_id == "new-haven-2004"))
  expect_false(any(waves$wave == "t1" & waves$poll_id == "nic-1996"))
  follow_up <- dplyr::filter(waves, poll_id == "tanzania-2015", wave == "t3")
  expect_equal(
    strsplit(follow_up$source_fields, "|", fixed = TRUE)[[1]],
    paste0("H6", 1:9, 1)
  )
  baseline <- dplyr::filter(waves, poll_id == "tanzania-2015", wave == "t0")
  expect_equal(
    strsplit(baseline$source_fields, "|", fixed = TRUE)[[1]],
    paste0("H6", 1:9, 0)
  )
  expect_equal(follow_up$wave_role, "follow_up")
})

test_that("wave identities preserve numeric scores and literal timing", {
  scores <- tibble::tibble(
    poll_id = c("marousi-2006", "nic-1996", "tanzania-2015"),
    source_dataset = c("score_only", "historical", "control"),
    original_score_wave = c("t0", "t2", "t2"),
    score = c(0, NA_real_, -0.1)
  )
  enriched <- add_analysis_wave_identity(scores)
  expect_identical(enriched[names(scores)], scores)
  expect_equal(enriched$original_survey_wave, c("T1", "T2", "follow_up"))
  expect_error(add_analysis_wave_identity(dplyr::mutate(
    scores, original_score_wave = "nonexistent"
  )))
  catalog <- analysis_wave_catalog()$analysis_survey_waves
  extra <- dplyr::filter(catalog, poll_id == "marousi-2006", wave == "t0")
  extra$original_survey_wave <- "additional_pre_arrival"
  extra$wave_instance_id <- "marousi-2006:additional_pre_arrival"
  multiple <- add_analysis_wave_identity(
    scores, dplyr::bind_rows(catalog, extra)
  )
  expect_identical(multiple, enriched)
})

test_that("catalog arrival and exit fields trace literal raw source columns", {
  waves <- analysis_wave_catalog()$analysis_survey_waves
  europe <- dplyr::filter(
    waves, poll_id == "tomorrows-europe-2007", wave == "t1"
  )
  expected <- c(paste0("t2q", 19:27), "t2q36a", "t2q36b")
  expect_equal(strsplit(europe$source_fields, "|", fixed = TRUE)[[1]], expected)
  source <- arrow::read_parquet(project_path(europe$source_path))
  expect_true(all(expected %in% names(source)))
  baseline <- dplyr::filter(
    waves, poll_id == "tomorrows-europe-2007", wave == "t0"
  )
  expect_equal(baseline$mode, "mixed")
  denmark <- dplyr::filter(
    waves, poll_id == "denmark-euro-2000", wave == "t2"
  )
  source <- arrow::read_parquet(project_path(denmark$source_path))
  expected <- strsplit(denmark$source_fields, "|", fixed = TRUE)[[1]]
  expect_true(all(expected %in% names(source)))
  expect_false(any(startsWith(expected, "T2_")))
})


test_that("recovered Denmark follow-up preserves timing and is not exit", {
  waves <- analysis_wave_catalog()$analysis_survey_waves
  follow_up <- dplyr::filter(
    waves, poll_id == "denmark-euro-2000", wave == "t3"
  )
  expect_equal(nrow(follow_up), 1L)
  expect_equal(follow_up$wave_role, "follow_up")
  expect_equal(follow_up$availability, "source_exists_but_not_exported")
  source <- arrow::read_parquet(project_path(follow_up$source_path))
  baseline <- arrow::read_parquet(project_path(
    "data", "denmark-euro-2000", "survey.parquet"
  ))
  expect_equal(nrow(source), 355L)
  expect_false(anyDuplicated(source$DELNR) > 0L)
  expect_true(all(source$DELNR %in% baseline$delnr))
  expect_identical(source$source_row, seq_len(nrow(source)))
  expect_equal(range(source$DATO), c(follow_up$date_start, follow_up$date_end))
  fields <- strsplit(follow_up$source_fields, "|", fixed = TRUE)[[1]]
  expect_true(all(fields %in% names(source)))
  expect_true(follow_up$date_start > as.Date("2000-08-27"))
})
