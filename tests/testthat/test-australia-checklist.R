test_that("Australia's declared inputs reconstruct individual measures", {
  poll <- "australia-republic-1999"
  inputs <- read_metadata("measure_inputs") |>
    dplyr::filter(poll_id == poll)
  definitions <- read_metadata("measure_definitions") |>
    dplyr::filter(poll_id == poll)
  baseline <- inputs$source_column[
    inputs$definition_id == "knowledge_t1@aus-08-v2"
  ]
  exit <- inputs$source_column[
    inputs$definition_id == "knowledge_t2@historical-v1"
  ]
  expect_true("dkchg1" %in% baseline)
  expect_false("dkchg1" %in% exit)
  expect_equal(length(baseline), 13L)
  expect_equal(length(exit), 12L)
  survey <- read_poll_survey(poll)
  declared <- survey[unique(inputs$source_column)]
  expect_identical(
    build_australia_individual(declared), build_australia_individual(survey)
  )
  affected <- c("knowledge_t1", "knowledge_joint", "knowledge_gain",
    "knowledge_gain_joint", "log_knowledge_joint", "high_knowledge_joint"
  )
  expect_setequal(
    definitions$definition_id[definitions$measure_id %in% affected],
    paste0(affected, "@aus-08-v2")
  )
  expect_true(all(vapply(affected, function(measure) {
    "dkchg1" %in% inputs$source_column[
      inputs$definition_id == paste0(measure, "@aus-08-v2")
    ]
  }, logical(1))))
})

australia_checklist_items <- function(survey) {
  purrr::map_dfr(1:2, function(wave) {
    tibble::as_tibble(australia_knowledge_items(survey, wave)) |>
      dplyr::mutate(source_row = survey$source_row) |>
      tidyr::pivot_longer(-"source_row",
        names_to = "item_id", values_to = "correct"
      ) |>
      dplyr::mutate(
        poll_id = "australia-republic-1999",
        respondent_id = paste0("source-row-", source_row),
        wave = wave, correct = as.integer(correct)
      )
  }) |>
    apply_knowledge_contract(survey, "australia-republic-1999", "historical")
}

test_that("Australia batteries agree on their shared checklist", {
  survey <- read_poll_survey("australia-republic-1999")
  original <- survey
  before <- australia_knowledge_items(survey, 1L)
  after <- australia_knowledge_items(survey, 2L)
  initial <- as.numeric(survey$dkchg1) %in% 1
  exit <- as.numeric(survey$dkchg2) %in% 1
  core <- as.numeric(survey$group) %in% 1:24
  symbols <- c("flagchg", "anthem", "wdroyal", "pargame")
  expect_equal(dim(before), c(4659L, 12L))
  expect_equal(sum(initial), 168L)
  expect_equal(sum(initial & core), 52L)
  expect_equal(sum(initial & as.numeric(survey$part) %in% 1), 54L)
  expect_equal(sum(exit & core), 37L)
  expect_true(all(before[initial, symbols] == 0))
  expect_equal(unname(after[exit, symbols]),
    matrix(rep(c(1, 1, 0, 1), each = 37), nrow = 37)
  )
  ungated <- survey
  ungated$dkchg1[initial] <- 2
  previous <- australia_knowledge_items(ungated, 1L)
  expect_equal(sum(previous - before, na.rm = TRUE), 504)
  expect_equal(sum(previous[core, ] - before[core, ], na.rm = TRUE), 156)
  expect_equal(rowMeans(before)[initial], rowMeans(previous)[initial] - .25)
  expect_identical(before[!initial, ], previous[!initial, ])
  expect_identical(after, australia_knowledge_items(ungated, 2L))

  historical <- australia_checklist_items(survey)
  cor <- build_poll_knowledge("australia-republic-1999")
  expect_true(all(cor$knowledge_scores$n_items == 10L))
  shared <- dplyr::inner_join(cor$knowledge_responses, historical,
    by = c("source_row", "wave", "source_column"),
    relationship = "one-to-one", suffix = c("_cor", "_historical")
  )
  expect_equal(nrow(shared), 6940L)
  expect_identical(shared$correct_cor, shared$correct_historical)
  expect_identical(shared$response_reason_cor,
    shared$response_reason_historical
  )
  expect_identical(shared$knowledge_response_cor,
    shared$knowledge_response_historical
  )
  expect_identical(shared$raw_value_cor, shared$raw_value_historical)
  expect_equal(sum(historical$response_reason == "none_or_dk"), 672L)
  expect_equal(sum(cor$knowledge_responses$response_reason == "none_or_dk"),
    208L
  )
  absent <- historical$wave_observed %in% FALSE
  unknown <- is.na(historical$wave_observed)
  expect_equal(sum(absent), 10476L)
  expect_true(all(is.na(historical$correct[absent | unknown])))
  expect_true(all(historical$raw_value[absent] == 100))
  expect_true(all(is.na(historical$raw_value[unknown])))
  measures <- build_australia_individual(survey)
  previous_measures <- build_australia_individual(ungated)
  unchanged <- names(measures)[!grepl("knowledge", names(measures))]
  expect_identical(measures[unchanged], previous_measures[unchanged])
  expect_identical(survey, original)
})

test_that("Australian guessing flags keep combined choices distinct from DK", {
  survey <- read_poll_survey("australia-republic-1999")
  battery <- build_poll_knowledge("australia-republic-1999")
  cor <- battery$knowledge_responses |>
    dplyr::filter(grepl("^(flagchg|anthem|wdroyal|pargame)[12]$",
      source_column
    )) |>
    dplyr::mutate(
      source_dataset = "cor_sood", wave = paste0("t", wave),
      battery_id = "checklist", wave_instance_id = wave
    )
  participants <- cor |>
    dplyr::distinct(poll_id, source_dataset, respondent_id, source_row) |>
    dplyr::mutate(attended = TRUE)
  scores <- cor |>
    dplyr::summarise(
      n_items = dplyr::n(), wave_observed = TRUE,
      score = sum(correct) / n_items,
      .by = c(poll_id, source_dataset, respondent_id, battery_id, wave,
        wave_instance_id
      )
    ) |>
    dplyr::mutate(original_survey_wave = wave, wave_role = wave)
  flags <- knowledge_flags(cor, participants, scores)
  flags$source_flag <- vapply(seq_len(nrow(flags)), function(i) {
    as.numeric(survey[[paste0("dkchg", sub("^t", "", flags$wave[i]))]][
      match(flags$source_row[i], survey$source_row)
    ])
  }, numeric(1))
  initial <- flags[flags$wave == "t1" & flags$source_flag %in% 1, ]
  exit <- flags[flags$wave == "t2" & flags$source_flag %in% 1, ]
  expect_equal(nrow(initial), 52L)
  expect_true(all(initial$n_dk == 0L))
  expect_true(all(initial$n_none_or_dk == 4L))
  expect_true(all(initial$n_substantive == 0L))
  expect_true(all(initial$zero_pattern == "other_nonanswers_or_unresolved"))
  expect_equal(nrow(exit), 37L)
  expect_true(all(exit$n_dk == 0L))
  expect_true(all(exit$n_none_or_dk == 0L))
  expect_true(all(exit$n_substantive == 4L))
  expect_true(all(exit$score == .75))
  post_items <- cor |>
    dplyr::filter(wave == "t2", respondent_id %in% exit$respondent_id)
  expect_equal(nrow(post_items), 148L)
  expect_equal(sum(post_items$correct), 111L)
  expect_equal(sum(post_items$correct) / 10, 37 * .3)
  literal_dk <- battery$knowledge_responses |>
    dplyr::filter(response_reason == "dk")
  expect_gt(nrow(literal_dk), 0L)
  expect_true(all(literal_dk$knowledge_response == "dk"))
  expect_true(all(literal_dk$correct == 0L))
  expect_true(all(literal_dk$raw_value == 97))
  expect_equal(sum(flags$n_dk), sum(cor$response_reason == "dk"))
})

test_that("checklist provenance respects form presence and invalid codes", {
  survey <- read_poll_survey("australia-republic-1999")
  source_row <- survey$source_row[which(as.numeric(survey$dkchg1) %in% 1)[1]]
  items <- tibble::tibble(
    poll_id = "australia-republic-1999", source_dataset = "historical",
    respondent_id = "fixture", source_row = source_row,
    source_column = c("flagchg1", "rempres1", "flagchg2",
      rep("flagchg1", 4)
    ),
    item_id = c("knowledge_009", "knowledge_002", rep("knowledge_009", 5)),
    wave = c("t1", "t1", "t2", rep("t1", 4)),
    raw_value = c(1, 97, 99, NA, 777, 1, 1), raw_text = NA_character_,
    correct = c(0L, NA, NA, NA, NA, NA, NA),
    response_status = c(rep("scored", 5), "wave_absent", "scored"),
    wave_observed = c(rep(TRUE, 5), FALSE, NA)
  )
  result <- enrich_knowledge_responses(items) |>
    standardize_knowledge_scores()
  expect_equal(result$items$response_reason,
    c("none_or_dk", "dk", "blank", "source_missing", "unreviewed_code",
      "wave_absent", "none_or_dk")
  )
  expect_equal(result$items$correct, c(0L, 0L, 0L, 0L, NA, NA, NA))
  expect_equal(result$items$knowledge_response,
    c("dk", "dk", "dk", "dk", NA, NA, "dk")
  )
  expect_identical(result$items$raw_value, items$raw_value)
  expect_true(all(is.na(result$dk_correct_conflicts$correct)))
  expect_identical(apply_knowledge_overrides(items, "nic-1996", survey), items)
  expect_error(australia_checklist_none_or_dk(survey, "flagchg1", 999999))
  bad_flag <- survey
  bad_flag$dkchg1[1] <- 777
  expect_error(australia_checklist_none_or_dk(
    bad_flag, rep("flagchg1", nrow(bad_flag))
  ))
  expect_error(australia_knowledge_items(
    survey[, !names(survey) %in% "dkchg1"], 1L
  ), "Missing source field: dkchg1")
})
