source(file.path(root, "R", "poll_adapters.R"))
source(file.path(root, "R", "analysis_knowledge_responses.R"))
source(file.path(root, "R", "analysis_arrivals.R"))


test_that("Michigan arrival adds nine shared items without borrowing facts", {
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_participants.parquet"
  ))
  source <- read_poll_survey("michigan-2009")
  raw <- analysis_arrival_items(people)
  items <- standardize_knowledge_scores(enrich_knowledge_responses(raw))$items
  full <- dplyr::filter(items,
    poll_id == "michigan-2009", grepl(":knowledge$", battery_id)
  )
  expect_equal(nrow(full), 310L * 9L)
  expect_setequal(full$wave, "t1")
  expect_setequal(full$original_score_wave, "arrival")
  expect_setequal(full$source_column, paste0("t2q", c(38:42, 10, 11, 13, 14)))
  expect_equal(anyDuplicated(full[c("respondent_id", "item_id")]), 0L)
  facts <- dplyr::filter(full, source_column %in% paste0("t2q", 38:42))
  expect_true(all(is.na(facts$raw_value)))
  for (field in unique(facts$source_column)) {
    observed <- facts[facts$source_column == field, ]
    position <- match(observed$source_row, source$source_row)
    expect_identical(observed$raw_text, source[[field]][position])
  }
  fact_totals <- facts |>
    dplyr::summarise(total = sum(correct, na.rm = TRUE), .by = source_column) |>
    dplyr::arrange(source_column)
  expect_equal(fact_totals$total, c(116L, 149L, 22L, 42L, 94L))
  blank <- dplyr::filter(facts, wave_observed, raw_text == "")
  expect_true(all(blank$correct == 0L))
  expect_true(all(blank$response_reason == "source_missing"))
  ambiguous <- dplyr::filter(full,
    (respondent_id == "1103" & source_column == "t2q38") |
      (respondent_id == "1108" & source_column == "t2q39")
  )
  expect_equal(nrow(ambiguous), 2L)
  expect_setequal(ambiguous$raw_text, c("house of rep", "dec"))
  expect_true(all(ambiguous$correct == 0L))
  expect_true(all(ambiguous$response_reason == "unreviewed_code"))
  expect_true(all(is.na(ambiguous$knowledge_response)))
  dk <- dplyr::filter(facts, tolower(raw_text) == "e")
  expect_equal(nrow(dk), 313L)
  expect_true(all(dk$knowledge_response == "dk"))
  expect_true(all(dk$correct == 0L))
  incorrect <- dplyr::filter(facts,
    source_column == "t2q40", tolower(raw_text) == "c"
  )
  expect_equal(nrow(incorrect), 112L)
  expect_true(all(incorrect$knowledge_response == "incorrect"))
  absent <- dplyr::filter(full, respondent_id == "5000")
  expect_equal(nrow(absent), 9L)
  expect_true(all(!absent$wave_observed))
  expect_true(all(is.na(absent$correct)))
  invalid <- dplyr::filter(full,
    respondent_id == "501", source_column == "t2q10"
  )
  expect_identical(invalid$raw_value, 9)
  expect_identical(invalid$response_reason, "invalid_response")
  expect_true(is.na(invalid$correct))
  scores <- analysis_arrival_scores(items)
  nine <- dplyr::filter(scores,
    poll_id == "michigan-2009", n_items == 9L
  )
  four <- dplyr::filter(scores,
    poll_id == "michigan-2009", n_items == 4L, wave == "t1"
  )
  expect_equal(sum(!is.na(nine$score)), 309L)
  expect_equal(mean(nine$score, na.rm = TRUE), 1156 / (309 * 9))
  expect_equal(mean(four$score, na.rm = TRUE), 733 / (309 * 4))
  expect_setequal(nine$respondent_id[is.na(nine$score)], "5000")
  expect_equal(nine$n_observed[nine$respondent_id == "5000"], 0L)
  expect_true(any(nine$n_observed > 4L))
  expect_equal(nine$score[nine$respondent_id == "501"], 4 / 9)
  rebuilt <- full |>
    dplyr::summarise(
      score = if (dplyr::first(wave_observed)) {
        sum(correct, na.rm = TRUE) / dplyr::n()
      } else {
        NA_real_
      }, .by = respondent_id
    )
  expect_equal(nine$score, rebuilt$score[match(
    nine$respondent_id, rebuilt$respondent_id
  )])
})
