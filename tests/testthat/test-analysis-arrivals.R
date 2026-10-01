test_that("added arrivals preserve question batteries and source identities", {
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_participants.parquet"
  ))
  items <- analysis_arrival_items(people)
  scores <- analysis_arrival_scores(items)
  keys <- c("poll_id", "source_dataset", "respondent_id", "battery_id", "wave")
  expect_false(anyDuplicated(items[c(keys, "item_id")]) > 0L)
  expect_false(anyNA(scores$timing_evidence))
  unmatched <- dplyr::anti_join(scores, people,
    by = c("poll_id", "source_dataset", "respondent_id")
  )
  expect_equal(nrow(unmatched), 0L)
  absent <- !scores$wave_observed
  expect_true(all(is.na(scores$score[absent])))
  expect_true(all(scores$n_observed[absent] == 0L))
  expect_true(all(is.na(items$correct[!items$wave_observed])))
  common <- dplyr::filter(
    scores, grepl(":knowledge$", battery_id),
    source_dataset == "cor_sood"
  )
  counts <- common |>
    dplyr::summarise(n = sum(wave_observed), .by = poll_id) |>
    dplyr::pull(n)
  expect_equal(counts, c(396L, 348L, 358L, 146L, 309L))
  euro <- dplyr::filter(
    scores, poll_id == "europolis-2009",
    source_dataset == "cor_sood"
  )
  expect_equal(mean(euro$score[grepl(":knowledge$", euro$battery_id)]),
    27.7777777778 / 100,
    tolerance = 1e-10
  )
  expanded <- dplyr::filter(euro, grepl("expanded_nine$", battery_id))
  expect_equal(mean(expanded$score[expanded$wave == "t1"]),
    29.6296296296 / 100,
    tolerance = 1e-10
  )
  expect_equal(mean(expanded$score[expanded$wave == "t2"]),
    37.8033205619 / 100,
    tolerance = 1e-10
  )
  ca <- dplyr::filter(
    scores, poll_id == "california-whats-next-2011",
    grepl("expanded_eight$", battery_id)
  )
  expect_equal(sum(ca$n_correct[ca$wave == "t1"]), 1900L)
  expect_equal(sum(ca$n_correct[ca$wave == "t2"]), 2430L)
  michigan <- dplyr::filter(scores, poll_id == "michigan-2009")
  expect_setequal(michigan$n_items, c(4L, 6L, 9L))
  expect_true(all(michigan$n_items[michigan$wave == "t0"] == 4L))
  four <- dplyr::filter(michigan, n_items == 4L)
  expect_equal(sum(four$wave == "t1" & four$wave_observed), 309L)
  expect_equal(sum(four$wave == "t1" & !four$wave_observed), 1L)
  added <- dplyr::filter(items, poll_id == "michigan-2009", wave == "t1")
  totals <- added |>
    dplyr::summarise(total = sum(correct, na.rm = TRUE), .by = item_id)
  expect_equal(totals$total[totals$item_id == "knowledge_010"], 196L)
  expect_equal(totals$total[totals$item_id == "knowledge_011"], 209L)
})

test_that("phase item export links to scores and canonical questions", {
  directory <- project_path("output", "analysis")
  items <- arrow::read_parquet(file.path(
    directory,
    "analysis_phase_item_responses.parquet"
  ))
  scores <- arrow::read_parquet(file.path(
    directory,
    "analysis_phase_scores.parquet"
  ))
  catalog <- read_metadata("items")
  keys <- c(
    "poll_id", "source_dataset", "respondent_id", "battery_id",
    "wave_instance_id"
  )
  expect_false(anyDuplicated(items[c(keys, "item_id")]) > 0L)
  expect_equal(nrow(dplyr::anti_join(items, scores, by = keys)), 0L)
  unmatched <- dplyr::anti_join(items, catalog,
    by = c("poll_id", "item_id")
  )
  expect_equal(nrow(unmatched), 0L)
  rebuilt <- items |>
    dplyr::filter(original_score_wave == "arrival" |
                    grepl("expanded|placements", battery_id)) |>
    dplyr::summarise(
      observed = dplyr::first(wave_observed),
      reconstructed = dplyr::if_else(observed,
        sum(correct, na.rm = TRUE) / dplyr::n(), NA_real_
      ), .by = dplyr::all_of(keys)
    ) |>
    dplyr::left_join(scores, by = keys, relationship = "one-to-one")
  expect_equal(rebuilt$reconstructed, rebuilt$score)
  expect_true(all(is.na(rebuilt$score[!rebuilt$observed])))
})


test_that("intermediate items preserve arrival and within-event timing", {
  directory <- project_path("output", "analysis")
  people <- arrow::read_parquet(file.path(
    directory, "analysis_phase_participants.parquet"
  ))
  scores <- arrow::read_parquet(file.path(
    directory, "analysis_phase_scores.parquet"
  ))
  items <- analysis_intermediate_items(people, scores)
  expect_equal(nrow(items), 3550L * 11L + 132L * 8L)
  keys <- c("poll_id", "respondent_id", "wave", "item_id")
  expect_false(anyDuplicated(items[keys]) > 0L)
  nh <- dplyr::filter(items, poll_id == "new-haven-2004")
  te <- dplyr::filter(items, poll_id == "tomorrows-europe-2007")
  expect_setequal(nh$wave, "interim_1")
  expect_true(all(nh$wave_observed))
  expect_true(all(grepl("^mid_q", nh$source_column)))
  expect_setequal(te$wave, "t1")
  observed <- te$wave_observed %in% TRUE
  expect_equal(dplyr::n_distinct(te$respondent_id[observed]), 338L)
  expect_true(all(grepl("^t2q", te$source_column)))
  unknown <- is.na(te$wave_observed)
  expect_equal(dplyr::n_distinct(te$respondent_id[unknown]), 3212L)
  survey <- read_poll_survey("tomorrows-europe-2007")
  returned <- survey[as.numeric(survey$v_b) == 1082, ]
  expect_equal(returned$source_row, 3431L)
  answered_fields <- paste0("t2q38", letters[4:15])
  expect_equal(sum(!is.na(returned[answered_fields])), 12L)
  blank_quiz <- dplyr::filter(te, respondent_id == "1082")
  expect_equal(nrow(blank_quiz), 11L)
  expect_true(all(is.na(blank_quiz$raw_value)))
  expect_true(all(blank_quiz$wave_observed))
  expect_true(all(blank_quiz$correct == 0L))
  placements <- dplyr::filter(te, source_column %in% c("t2q36a", "t2q36b"))
  expected <- with(placements, as.integer(
    ifelse(source_column == "t2q36a", raw_value %in% 6:10, raw_value %in% 0:4)
  ))
  expected[!placements$wave_observed %in% TRUE] <- NA_integer_
  expect_identical(placements$correct, expected)
  enriched <- enrich_knowledge_responses(items) |>
    standardize_knowledge_scores()
  enriched <- enriched$items
  invalid <- dplyr::filter(enriched, response_reason == "invalid_response")
  expect_setequal(invalid$poll_id, c("tomorrows-europe-2007", "new-haven-2004"))
  expected_invalid <- tibble::tribble(
    ~poll_id, ~respondent_id, ~source_column, ~raw_value,
    "tomorrows-europe-2007", "1656", "t2q19", 6,
    "tomorrows-europe-2007", "1199", "t2q24", 24,
    "tomorrows-europe-2007", "2527", "t2q24", 1004,
    "tomorrows-europe-2007", "2579", "t2q24", 1004,
    "tomorrows-europe-2007", "207", "t2q24", 1004,
    "tomorrows-europe-2007", "191", "t2q24", 1004,
    "tomorrows-europe-2007", "2527", "t2q27", 1004,
    "tomorrows-europe-2007", "2579", "t2q27", 1004,
    "tomorrows-europe-2007", "3202", "t2q27", 44,
    "tomorrows-europe-2007", "207", "t2q27", 1004,
    "tomorrows-europe-2007", "191", "t2q27", 1004,
    "tomorrows-europe-2007", "211", "t2q27", 1004,
    "new-haven-2004", "3133", "mid_q36", 0,
    "new-haven-2004", "3269", "mid_q36", 0,
    "new-haven-2004", "3133", "mid_q41", 0,
    "new-haven-2004", "3255", "mid_q41", 0,
    "new-haven-2004", "3133", "mid_q43", 0
  )
  actual_invalid <- dplyr::select(
    invalid, dplyr::all_of(names(expected_invalid))
  )
  expect_equal(
    dplyr::arrange(actual_invalid, poll_id, respondent_id, source_column),
    dplyr::arrange(expected_invalid, poll_id, respondent_id, source_column)
  )
  expect_true(all(is.na(invalid$correct)))
  expect_true(all(is.na(invalid$knowledge_response)))
  expect_equal(invalid$raw_value, items$raw_value[match(
    paste(invalid$poll_id, invalid$respondent_id, invalid$item_id),
    paste(items$poll_id, items$respondent_id, items$item_id)
  )])
})
