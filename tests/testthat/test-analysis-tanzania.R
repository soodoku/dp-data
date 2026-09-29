source(file.path(root, "R", "analysis_tables.R"))

tanzania_test_source <- function() {
  haven::read_dta(project_path(
    "data", "tanzania-2015", "participants.dta"
  )) |>
    dplyr::filter(haven::as_factor(sample) == "Citizens")
}

test_that("Tanzania excludes only the documented first-component sentinel", {
  survey <- tanzania_test_source()
  for (wave in 0:1) {
    fields <- paste0("H6", 1:9, wave)
    original <- as.matrix(survey[fields])
    corrected <- analysis_tanzania_items(survey, wave)
    excluded <- original[, 1] %in% -99
    expect_equal(sum(excluded), c(173L, 25L)[wave + 1L])
    expect_true(all(is.na(corrected[excluded, 1])))
    expect_equal(corrected[!excluded, 1], original[!excluded, 1])
    expect_equal(corrected[, -1], original[, -1], tolerance = 0)
    expect_equal(
      sum(is.na(corrected)) - sum(is.na(original)), sum(excluded)
    )
    expect_true(all(is.na(corrected) | corrected %in% 0:1))
  }
  unexpected <- survey
  unexpected$H620[1] <- -99
  expect_error(analysis_tanzania_items(unexpected, 0L), "Unreviewed Tanzania")
  unexpected <- survey
  unexpected$H610[1] <- 2
  expect_error(analysis_tanzania_items(unexpected, 0L), "Unreviewed Tanzania")
})

test_that("Tanzania scores match the frozen independent missing-value recode", {
  survey <- tanzania_test_source()
  actual <- analysis_tanzania_knowledge(survey)
  expected <- readr::read_csv(project_path(
    "audit", "corrections", "tanzania-2015", "missing_values.csv"
  ), show_col_types = FALSE, col_types = readr::cols(
    respondent_id = readr::col_character()
  ))
  expect_equal(nrow(actual), 2002L)
  changed <- 0L
  for (wave in 1:2) {
    reference <- expected[expected$wave == c("t0", "t3")[wave], ]
    expect_identical(reference$respondent_id, as.character(seq_len(2002L)))
    expect_equal(reference$source_hhid, as.numeric(survey$HHID))
    values <- actual[[paste0("score_wave", wave)]]
    deposited <- as.numeric(survey[[c("H600", "H601")[wave]]])
    expect_equal(values, reference$missing_refitted_value, tolerance = 1e-10)
    expect_identical(is.na(values), is.na(deposited))
    expect_equal(sum(!is.na(values)), c(2001L, 1858L)[wave])
    changed <- changed + sum(abs(values - deposited) > 1e-10, na.rm = TRUE)
  }
  expect_equal(changed, 3859L)
  controls <- actual$score_wave1[survey$z == 0]
  expect_equal(mean(controls, na.rm = TRUE), 0, tolerance = 1e-12)
  expect_equal(stats::sd(controls, na.rm = TRUE), 1, tolerance = 1e-12)
})

test_that("Tanzania keeps source people and requires both scores for panel", {
  survey <- tanzania_test_source()
  people <- analysis_tanzania_people(survey)
  expect_equal(nrow(people), 2002L)
  expect_identical(people$respondent_id, as.character(seq_len(2002L)))
  expect_identical(people$source_row, seq_len(2002L))
  expect_equal(people$cluster_id, as.character(survey$VillageID))
  expect_equal(sum(people$female, na.rm = TRUE), 1052)
  expect_equal(sum(is.na(people$female)), 1L)
  expect_equal(sum(people$panel), 1857L)
  old_panel <- !is.na(survey$H601)
  changed <- which(people$panel != old_panel)
  expect_equal(changed, 1323L)
  expect_equal(as.numeric(survey$HHID[changed]), 240301)
  expect_false(people$panel[changed])
  expect_true(is.na(people$score_wave1[changed]))
  expect_false(is.na(people$score_wave2[changed]))
  empty_items <- tibble::tibble(
    poll_id = character(), source_dataset = character(),
    respondent_id = character(), wave = character(), correct = integer(),
    response_status = character(), raw_value = numeric(), raw_text = character()
  )
  scores <- analysis_scores(empty_items, people)
  expect_equal(nrow(scores), 4004L)
  expect_true(all(scores$scale == "standardized_index"))
  expect_true(all(is.na(scores$n_correct)))
  expect_true(all(is.na(scores$n_items)))
  expect_true(all(is.na(scores$n_observed)))
  expect_equal(sum(!is.na(scores$score)), 3859L)
})
