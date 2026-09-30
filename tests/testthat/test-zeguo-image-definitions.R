source(file.path(root, "R", "respondents.R"))

test_that("public-works image reproduces both authored source summaries", {
  survey <- read_poll_survey("zeguo-2005")
  observed <- zeguo_departure_observed(survey)
  for (wave in 1:2) {
    actual <- zeguo_public_works(survey, wave)
    expected <- as.numeric(survey[[paste0("image3t", wave)]]) / 10
    if (wave == 2L) expected[!observed] <- NA_real_
    expect_identical(actual$township_image_public_works, expected)
    imputed <- dplyr::coalesce(expected, .5)
    if (wave == 2L) imputed[!observed] <- NA_real_
    expect_identical(actual$township_image_public_works_midpoint_imputed,
                     imputed)
  }
  built <- build_zeguo_individual(survey)
  expect_equal(built$township_image_public_works_t1[survey$p == 15],
               6.333333492279053 / 10, tolerance = 0)
  expect_equal(built$township_image_public_works_t1[survey$p == 262], 1)
  expect_equal(built$township_image_t1_midpoint_imputed[survey$p == 262], .5)
  paired <- !is.na(built$township_image_public_works_t1) &
    !is.na(built$township_image_public_works_t2)
  expect_equal(sum(paired), 176L)
  expect_equal(sum(is.na(built$township_image_public_works_t1)), 45L)
  expect_equal(sum(is.na(built$township_image_public_works_t2) & observed), 26L)
  expect_equal(survey$p[which(survey$d2027 == 5.5)], 2)
  expect_equal(survey$p[which(survey$d2008p == 6.5)], 21)
  expect_equal(built$township_image_public_works_t1[survey$p == 2], .7875)
  expect_equal(built$township_image_public_works_t2[survey$p == 21], .3375)
})

test_that("public-works missingness distinguishes answers and absent forms", {
  survey <- read_poll_survey("zeguo-2005")
  row <- which(survey$p == 15)
  fields <- paste0("d20", sprintf("%02d", c(8, 9, 25, 27)))
  survey[row, fields] <- NA_real_
  actual <- zeguo_public_works(survey, 1L)
  expect_true(is.na(actual$township_image_public_works[row]))
  expect_equal(actual$township_image_public_works_midpoint_imputed[row], .5)
  survey$d2008[row] <- 0
  partial <- zeguo_public_works(survey, 1L)
  expect_equal(partial$township_image_public_works[row], 0)
  survey$d2008[row] <- 99
  expect_error(zeguo_public_works(survey, 1L), "Unreviewed source codes")
  survey$d2008[row] <- 6.5
  expect_error(zeguo_public_works(survey, 1L), "Unreviewed source codes")
  survey$d2008[row] <- 0
  survey$d2027[row] <- 6.5
  expect_error(zeguo_public_works(survey, 1L), "Unreviewed source codes")
  observed <- zeguo_departure_observed(survey)
  post <- zeguo_public_works(survey, 2L)
  expect_true(all(is.na(as.matrix(post[!observed, ]))))
})

test_that("the historical nine-index battery excludes public works", {
  survey <- read_poll_survey("zeguo-2005")
  original <- zeguo_attitudes(survey, 1L)
  expect_equal(ncol(original), 18L)
  expect_false(any(grepl("public_works", names(original))))
  expected <- rowMeans(abs(as.matrix(original[
    endsWith(names(original), "_midpoint_imputed")
  ]) - .5))
  built <- build_zeguo_individual(survey)
  expect_identical(built$attitude_extremity, expected)
  observed <- questionnaire_form_evidence(survey, "zeguo-2005")$wave_observed
  survey$d2008[observed %in% TRUE] <- 10
  survey$d2009[observed %in% TRUE] <- 10
  survey$d2027[observed %in% TRUE] <- 10
  changed <- build_zeguo_individual(survey)
  old_columns <- names(built)[!grepl("public_works", names(built))]
  expect_identical(changed[old_columns], built[old_columns])
  expect_gt(sum(changed$township_image_public_works_t1 !=
                  built$township_image_public_works_t1, na.rm = TRUE), 0L)
})

test_that("public-works waves and variants reach typed respondent measures", {
  contract <- read_metadata("respondent_sources") |>
    dplyr::filter(.data$poll_id == "zeguo-2005")
  tables <- build_poll_respondents(contract)
  directory <- tempfile("zeguo-image-export-")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  expect_silent(write_typed_export(tables$respondent_measures,
    "respondent_measures", directory
  ))
  definitions <- read_metadata("measure_definitions") |>
    dplyr::filter(.data$poll_id == "zeguo-2005",
                  grepl("^township_image_public_works_", .data$measure_id))
  expect_equal(nrow(definitions), 4L)
  inputs <- read_metadata("measure_inputs")
  survey <- read_poll_survey("zeguo-2005")
  built <- build_zeguo_individual(survey)
  for (index in seq_len(nrow(definitions))) {
    definition <- definitions[index, ]
    fields <- inputs$source_column[
      inputs$definition_id == definition$definition_id
    ]
    suffix <- if (definition$source_waves == "T1") "" else "p"
    score_fields <- paste0("d20", sprintf("%02d", c(8, 9, 25, 27)), suffix)
    required <- score_fields
    if (definition$source_waves == "T2") {
      form <- questionnaire_form_contract("zeguo-2005")
      form <- form[form$original_wave == "T2", ]
      required <- union(required, c(form$fields[[1]], form$auxiliary[[1]]))
      expect_length(required, 36L)
    }
    expect_setequal(fields, required)
    rows <- tables$respondent_measures |>
      dplyr::filter(.data$definition_id == definition$definition_id)
    expect_equal(nrow(rows), 269L)
    expect_identical(rows$respondent_id, tables$people$respondent_id)
    expect_identical(rows$value_numeric, built[[definition$measure_id]])
    expect_true(all(rows$n_source_fields == length(required)))
    observed <- tables$source_responses |>
      dplyr::filter(.data$source_column %in% required) |>
      dplyr::summarise(
        n = sum(.data$response_status == "answered"),
        .by = "respondent_id"
      )
    expect_equal(rows$n_observed_fields,
                 as.integer(observed$n[match(rows$respondent_id,
                                             observed$respondent_id)]))
  }
})
