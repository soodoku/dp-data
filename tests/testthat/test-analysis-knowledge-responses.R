source(project_path("R", "analysis_knowledge_responses.R"))

test_that("knowledge nonanswers use exact meanings and retain distinctions", {
  labels <- c(
    "8. Don't know", "(can't choose)", "You couldn’t say",
    "Or couldn t you say about that ?", "9   not answered", "Refused",
    "item not applicable", "Don't know / refused",
    "Don't know whether prices rise",
    "incorrect", "missing", NA_character_
  )
  expect_identical(knowledge_label_reason(labels), c(
    "dk", "dk", "dk", "dk", "blank", "refused", "not_asked",
    NA_character_, NA_character_, NA_character_, "unclassified_nonanswer",
    NA_character_
  ))
})

test_that("scoring converts reviewed observed nonanswers only", {
  items <- tibble::tibble(
    poll_id = "example", respondent_id = as.character(1:10),
    item_id = "knowledge_001", wave = "t2", correct = c(
      rep(NA_integer_, 8),
      1L, 0L
    ),
    knowledge_response = c("dk", rep(NA_character_, 7), "dk", "incorrect"),
    response_reason = c(
      "dk", "refused", "blank", "source_missing", "not_asked",
      "scored_only", "dk", "dk", "dk", "answered"
    ),
    wave_observed = c(rep(TRUE, 6), FALSE, NA, TRUE, TRUE)
  )
  result <- standardize_knowledge_scores(items)
  expect_identical(result$items$correct, c(
    rep(0L, 4), rep(NA_integer_, 4),
    1L, 0L
  ))
  expect_identical(result$n_changed, 4L)
  expect_identical(result$changes$respondent_id, as.character(1:4))
  expect_identical(result$dk_correct_conflicts$respondent_id, "9")
  expect_identical(
    result$items[names(items) != "correct"],
    items[names(items) != "correct"]
  )
  expect_equal(sum(items$correct, na.rm = TRUE), sum(result$items$correct,
    na.rm = TRUE
  ))
})

test_that("enrichment preserves raw values and source meanings", {
  items <- tibble::tibble(
    poll_id = "uk-health-1998", source_dataset = "cor_sood",
    respondent_id = "1",
    wave = "t1", item_id = "knowledge_001", source_row = 1L,
    source_column = c("sopha1", "sopha1", "sopha1", "sopha1", "sopha1"),
    raw_value = c(-8, -9, -1, 0, 1234), raw_text = NA_character_,
    correct = c(NA_integer_, NA_integer_, NA_integer_, 1L, 0L),
    response_status = c(
      "non_substantive", "non_substantive",
      "non_substantive", "answered", "answered"
    )
  )
  result <- enrich_knowledge_responses(items)
  expect_identical(result[names(items)], items)
  expect_identical(result$knowledge_response, c(
    "dk", NA_character_,
    NA_character_, "correct", NA_character_
  ))
  expect_identical(result$response_reason, c(
    "dk", "blank", "not_asked",
    "answered", "unreviewed_code"
  ))
  expect_identical(result$source_response_label[1], "can't choose")
})

test_that("historical raw recovery conserves keys and scores", {
  items <- arrow::read_parquet(project_path(
    "output", "analysis",
    "analysis_item_responses.parquet"
  ))
  items <- dplyr::filter(items, poll_id %in% c(
    "zeguo-2005",
    "uk-health-1998"
  ), source_dataset == "historical")
  original <- items
  items$source_column <- NA_character_
  items$raw_value <- NA_real_
  items$raw_text <- NA_character_
  result <- enrich_knowledge_responses(items)
  expect_false(anyNA(result$source_column))
  expect_identical(result$correct, original$correct)
  keys <- c(
    "poll_id", "source_dataset", "respondent_id", "wave", "item_id",
    "source_row"
  )
  expect_identical(result[keys], original[keys])
  survey <- read_poll_survey("zeguo-2005")
  zeguo <- dplyr::filter(
    result, poll_id == "zeguo-2005", wave == "t2",
    item_id == "knowledge_001"
  )
  expect_equal(zeguo$raw_value, survey$post_d3043[match(
    zeguo$source_row,
    survey$source_row
  )])
})

test_that("binary scores do not prove an observed wrong answer", {
  items <- tibble::tibble(
    poll_id = "uk-health-1998", source_dataset = "cor_sood",
    respondent_id = c("1", "2"), wave = "t1", item_id = "knowledge_001",
    source_row = 1:2, source_column = "answera1", raw_value = c(0, 1),
    raw_text = NA_character_, correct = 0:1, response_status = "scored"
  )
  result <- enrich_knowledge_responses(items)
  expect_identical(result$response_reason, rep("scored_only", 2))
  expect_identical(result$knowledge_response, c(NA_character_, "correct"))
  expect_identical(result$correct, 0:1)
})

test_that("source-specific DK rules never apply to unrelated numeric answers", {
  items <- tibble::tibble(
    poll_id = c(rep("nic-1996", 3), rep("zeguo-2005", 3)),
    source_dataset = "historical", respondent_id = "example", wave = "t1",
    item_id = c(
      "knowledge_001", "knowledge_004", "knowledge_010",
      "knowledge_001", "knowledge_004", "knowledge_004"
    ),
    source_row = 1L,
    source_column = c(
      "WEDLOCK1", "SPEND1", "POLREP1",
      "pre_d3043", "pre_d3046", "pre_d3046"
    ),
    raw_value = c(8.5, 8, 8, 5, 5, 6), raw_text = NA_character_,
    correct = 0L, response_status = "scored"
  )
  result <- enrich_knowledge_responses(items)
  expect_identical(
    result$knowledge_response,
    c("incorrect", "dk", "dk", "dk", "incorrect", "dk")
  )
  expect_identical(result$raw_value, items$raw_value)
})

test_that("A1R raw codebook separates DK skipped and multiple responses", {
  items <- tibble::tibble(
    poll_id = "america-in-one-room-2019", source_dataset = "control",
    respondent_id = as.character(1:3), wave = "t2", item_id = "knowledge_003",
    source_row = 1:3, source_column = "T2PK3", raw_value = c(77, 98, -8),
    raw_text = NA_character_, correct = 0L, response_status = "non_substantive"
  )
  result <- enrich_knowledge_responses(items)
  expect_identical(
    result$knowledge_response, c("dk", NA_character_, NA_character_)
  )
  expect_identical(result$response_reason, c("dk", "blank", "invalid_response"))
})


test_that("reviewed literal NA remains a source label", {
  labels <- analysis_knowledge_labels(
    "uk-crime-1994", read_metadata("items"), "kw11"
  )$fields
  expect_identical(labels$source_response_label[labels$code == "9"], "NA")
  expect_identical(knowledge_label_reason("NA"), "unclassified_nonanswer")
})

test_that("Denmark phase dictionaries retain source-specific codes", {
  items <- tibble::tibble(
    poll_id = "denmark-euro-2000", source_dataset = "original",
    respondent_id = as.character(1:4), wave = c("t1", "t1", "t2", "t2"),
    item_id = "knowledge_001", source_row = 1:4,
    source_column = c("S4_1", "S4_1", "T2_S4_2", "T2_S4_2"),
    raw_value = c(3, 1, 3, 1), raw_text = NA_character_,
    correct = c(0L, 1L, 0L, 1L), response_status = "answered"
  )
  result <- enrich_knowledge_responses(items)
  expect_identical(
    result$knowledge_response, c("dk", "correct", "dk", "correct")
  )
  expect_identical(result$source_response_label[c(1, 3)], rep("Ved ikke", 2))
  expect_identical(result[names(items)], items)
})


test_that("Michigan textual answers reuse reviewed spelling rules", {
  items <- tibble::tibble(
    poll_id = "michigan-2009", source_dataset = "original",
    respondent_id = as.character(1:3), wave = "t2",
    item_id = "knowledge_001", source_row = 1:3,
    source_column = c("t3q38", "t3q38", "t3q40"),
    raw_value = NA_real_, raw_text = c("Democrat", "Republican", "A"),
    correct = c(0L, 1L, 1L), response_status = "answered"
  )
  result <- enrich_knowledge_responses(items)
  expect_identical(
    result$knowledge_response, c("incorrect", "correct", "correct")
  )
  expect_identical(result[names(items)], items)
})


test_that("New Haven keeps combined baseline nonanswers distinct from DK", {
  items <- tibble::tibble(
    poll_id = "new-haven-2004", source_dataset = "original",
    respondent_id = as.character(1:4), wave = c("t1", "t2", "t1", "t2"),
    item_id = "knowledge_001", source_row = 1:4,
    source_column = c("pre_q35", "post_q35", "pre_q43", "post_q35"),
    raw_value = c(5, 5, 3, 0), raw_text = NA_character_,
    correct = 0L, response_status = "answered"
  )
  result <- enrich_knowledge_responses(items)
  expect_identical(result$knowledge_response, c(NA_character_, "dk", "dk", NA))
  expect_identical(result$response_reason, c(
    "unclassified_nonanswer", "dk", "dk", "invalid_response"
  ))
  expect_identical(result[names(items)], items)
})


test_that("arrival rules preserve anomalies outside printed response options", {
  items <- tibble::tibble(
    poll_id = c(rep("california-whats-next-2011", 3), rep("michigan-2009", 3)),
    source_dataset = "original", respondent_id = as.character(1:6),
    wave = "t1", item_id = "knowledge_001", source_row = 1:6,
    source_column = c("t2q29", "t2q29", "t3q33", "t2q10", "t2q10", "t2q10"),
    raw_value = c(1, 5, 0, 1, 99, 9), raw_text = NA_character_,
    correct = 0L, response_status = "answered"
  )
  result <- enrich_knowledge_responses(items)
  expect_identical(result$knowledge_response, c(
    "incorrect", "dk", NA_character_, "incorrect", "dk", NA_character_
  ))
  expect_identical(result$response_reason[c(3, 6)], rep("invalid_response", 2))
  expect_true(all(is.na(result$source_response_label[c(3, 6)])))
  expect_identical(result[names(items)], items)
})


test_that("known nonanswers score zero without fabricating a DK category", {
  items <- tibble::tibble(
    respondent_id = as.character(1:6), correct = NA_integer_,
    knowledge_response = NA_character_,
    response_reason = c(
      "unclassified_nonanswer", "invalid_response", "unreviewed_code",
      "scored_only", "not_asked", "unclassified_nonanswer"
    ), wave_observed = c(rep(TRUE, 5), FALSE)
  )
  result <- standardize_knowledge_scores(items)
  expect_identical(result$items$correct, c(0L, rep(NA_integer_, 5)))
  expect_true(all(is.na(result$items$knowledge_response)))
  expect_identical(result$items$response_reason, items$response_reason)
  expect_equal(sum(result$items$correct, na.rm = TRUE), 0)
})


test_that("NIC follow-up labels distinguish answers from authored scores", {
  items <- tibble::tibble(
    poll_id = "nic-1996", source_dataset = "historical",
    respondent_id = as.character(1:4), wave = "t3",
    item_id = "knowledge_001", source_row = 1:4,
    source_column = c("TROOPSA3", "TROOPSA3", "POLREP3", "POLDEM3"),
    raw_value = c(0, 1, 2, 7), raw_text = NA_character_,
    correct = c(0L, 1L, 0L, 0L), response_status = "answered"
  )
  result <- enrich_knowledge_responses(items)
  expect_identical(result$knowledge_response, c(
    "incorrect", "correct", "incorrect", "incorrect"
  ))
  expect_identical(result$source_response_label, c(
    "No", "Yes", "Liberal", "Extremely conservative"
  ))
  expect_identical(result[names(items)], items)
})


test_that("invalid knowledge codes remain missing even on observed forms", {
  items <- tibble::tibble(
    respondent_id = c("multiple", "out_of_range", "dk"),
    correct = c(0L, 1L, 0L), knowledge_response = c(NA, NA, "dk"),
    response_reason = c("invalid_response", "invalid_response", "dk"),
    wave_observed = TRUE
  )
  result <- standardize_knowledge_scores(items)
  expect_identical(result$items$correct, c(NA_integer_, NA_integer_, 0L))
  expect_identical(result$items$knowledge_response, items$knowledge_response)
  expect_equal(result$n_changed, 2L)
  expect_identical(standardize_knowledge_scores(result$items)$n_changed, 0L)
})


test_that("Zeguo offered codes distinguish DK from invalid knowledge answers", {
  items <- tibble::tibble(
    poll_id = "zeguo-2005", source_dataset = "original",
    respondent_id = as.character(1:5), wave = "t2", item_id = "knowledge_004",
    source_row = 1:5,
    source_column = c("post_d3045", "post_d3045", rep("post_d3046", 3)),
    raw_value = c(5, 6, 1, 6, 0), raw_text = NA_character_,
    correct = c(0L, 0L, 0L, 0L, 0L), response_status = "answered"
  )
  result <- enrich_knowledge_responses(items)
  expect_identical(result$response_reason, c(
    "dk", "invalid_response", "answered", "dk", "invalid_response"
  ))
  result <- standardize_knowledge_scores(result, rep(TRUE, nrow(result)))$items
  expect_identical(result$correct, c(0L, NA_integer_, 0L, 0L, NA_integer_))
  expect_identical(result$raw_value, items$raw_value)
})


test_that("Climate nonanswers are scoped to verified questions and waves", {
  fields <- c("Q17", "Q18", "T2Q17", "T2Q18", "T3Q17", "T3Q18",
    "Q17", "T2Q18"
  )
  items <- tibble::tibble(
    poll_id = "a1r-climate-2021", source_dataset = "control",
    respondent_id = as.character(seq_along(fields)),
    item_id = ifelse(grepl("18$", fields), "knowledge_002", "knowledge_001"),
    source_row = seq_along(fields), source_column = fields,
    wave = c("t0", "t0", "t2", "t2", "t3", "t3", "t0", "t2"),
    raw_value = c(rep(98, 6), 77, 77), raw_text = NA_character_,
    correct = 0L, response_status = "answered", wave_observed = TRUE
  )
  result <- enrich_knowledge_responses(items)
  expect_identical(result$response_reason,
    c(rep("unclassified_nonanswer", 4), rep("unreviewed_code", 4))
  )
  expect_identical(result$source_response_label,
    c(rep("NA.", 4), rep(NA_character_, 4))
  )
  expect_true(all(is.na(result$knowledge_response)))
  expect_identical(result[names(items)], items)
  scored <- standardize_knowledge_scores(result)
  expect_identical(scored$items$correct, items$correct)
  expect_identical(scored$n_changed, 0L)
})


test_that("Climate code 98 reproduces the item-specific report categories", {
  survey <- readr::read_tsv(project_path(
    "data", "a1r-climate-2021", "participants.tab"
  ), show_col_types = FALSE)
  cohort <- survey[survey$P_DELEGATE == 1, ]
  expect_equal(nrow(cohort), 962L)
  for (item in c("Q17", "Q18")) {
    fields <- c(item, paste0("T2", item))
    printed_means <- if (item == "Q17") c(.672, .693) else c(.752, .799)
    printed_na <- if (item == "Q17") c(.8, .0) else c(1.2, .2)
    matching <- numeric()
    for (code in c(1, 2, 3, 77, 98)) {
      selected <- complete.cases(cohort[fields]) &
        rowSums(cohort[fields] == code) == 0L
      means <- vapply(fields, function(field) {
        stats::weighted.mean(cohort[[field]][selected] == 1,
          cohort$WEIGHT1[selected]
        )
      }, numeric(1))
      missing_shares <- vapply(fields, function(field) {
        100 * stats::weighted.mean(cohort[[field]] == code, cohort$WEIGHT1)
      }, numeric(1))
      if (identical(unname(round(means, 3)), printed_means) &&
            identical(unname(round(missing_shares, 1)), printed_na)) {
        matching <- c(matching, code)
        expect_equal(sum(selected), if (item == "Q17") 949L else 948L)
      }
    }
    expect_identical(matching, 98)
  }
  counts <- vapply(c("Q17", "Q18", "T2Q17", "T2Q18"), function(field) {
    sum(survey[[field]] == 98, na.rm = TRUE)
  }, integer(1))
  expect_identical(unname(counts), c(92L, 134L, 13L, 16L))
})


test_that("New Haven interim labels distinguish DK from invalid zeros", {
  source(project_path("R", "source_new_haven.R"))
  items <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_item_responses.parquet"
  )) |>
    dplyr::filter(poll_id == "new-haven-2004", wave == "interim_1")
  enriched <- enrich_knowledge_responses(items)
  result <- standardize_knowledge_scores(enriched)$items
  invalid <- result |> dplyr::filter(raw_value == 0)
  expect_equal(nrow(invalid), 5L)
  expect_setequal(invalid$respondent_id, c("3133", "3255", "3269"))
  expect_true(all(invalid$wave_observed))
  expect_true(all(is.na(invalid$correct)))
  expect_true(all(invalid$response_reason == "invalid_response"))
  expect_true(all(is.na(invalid$knowledge_response)))
  dk <- result |> dplyr::filter(knowledge_response == "dk")
  expect_equal(nrow(dk), 174L)
  expect_true(all(dk$correct == 0L))
  expect_true(all(dk$source_response_label == "Don't know"))
  expect_false(any(dk$source_column == "mid_q36"))
  expect_identical(result$raw_value, items$raw_value)
  expect_identical(result$respondent_id, items$respondent_id)
  expect_identical(result$wave_observed, items$wave_observed)

  survey <- read_new_haven_workbook(project_path(
    "data", "new-haven-2004", "source-materials", "survey-waves.xlsx"
  ))
  source <- dplyr::filter(survey, assigned %in% c(3133, 3255, 3269))
  fields <- grep("^mid_q", names(source), value = TRUE)
  expect_equal(length(fields), 55L)
  expect_equal(rowSums(as.matrix(source[fields]) != 0), c(50, 54, 54))
  expect_equal(result$raw_value, purrr::map2_dbl(
    result$respondent_id, result$source_column,
    \(id, field) survey[[field]][match(as.numeric(id), survey$assigned)]
  ))
  old_totals <- items |>
    dplyr::group_by(respondent_id) |>
    dplyr::summarise(score = sum(correct, na.rm = TRUE) / 8, .groups = "drop")
  new_totals <- result |>
    dplyr::group_by(respondent_id) |>
    dplyr::summarise(score = sum(correct, na.rm = TRUE) / 8, .groups = "drop")
  expect_identical(old_totals, new_totals)
})
