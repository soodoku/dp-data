source(file.path(root, "R", "analysis_tables.R"))
source(file.path(root, "R", "analysis_phases.R"))
source(file.path(root, "R", "analysis_attendance.R"))

australia_analysis_export <- function(name) {
  arrow::read_parquet(project_path(
    "output", "analysis", paste0(name, ".parquet")
  )) |>
    dplyr::filter(poll_id == "australia-republic-1999")
}

test_that("Australian attendance and questionnaire presence are distinct", {
  survey <- read_poll_survey("australia-republic-1999")
  evidence <- australia_form_evidence(survey)
  roster <- haven::read_sav(project_path(
    "data", "australia-republic-1999", "source-materials",
    "attendance-roster.sav"
  ))
  position <- match(as.numeric(survey$caseid), as.numeric(roster$id))
  expect_equal(sum(!is.na(position)), 1220L)
  expect_identical(evidence$attended, as.numeric(roster$attend[position]) == 1)
  expect_equal(sum(evidence$attended %in% TRUE), 356L)
  expect_equal(sum(evidence$attended %in% FALSE), 864L)
  expect_equal(sum(evidence$departure_observed %in% TRUE), 347L)
  expect_equal(sum(evidence$departure_observed %in% FALSE), 873L)
  expect_equal(sum(is.na(evidence$departure_observed)), 3439L)
  absent_attendees <- evidence$attended %in% TRUE &
    evidence$departure_observed %in% FALSE
  expect_equal(sum(absent_attendees), 9L)
  expect_equal(as.numeric(survey$caseid[absent_attendees]),
    c(59, 209, 475, 486, 502, 529, 659, 1229, 1571)
  )
  expect_true(all(as.numeric(survey$group[absent_attendees]) == 100))
  expect_equal(sum(evidence$baseline_observed %in% TRUE), 1220L)
  expect_true(all(is.na(evidence$baseline_observed[
    is.na(survey$caseid)
  ])))
  labels <- vapply(survey, function(value) {
    label <- attr(value, "label", exact = TRUE)
    if (is.null(label)) "" else label
  }, character(1))
  raw <- do.call(cbind, lapply(survey[grepl("T2 \\(W", labels)], as.numeric))
  absent <- evidence$departure_observed %in% FALSE
  expect_equal(sum(raw[absent, ] == 100), 57618L)
  expect_true(all(is.na(raw[is.na(evidence$departure_observed), ])))
})

test_that("form presence governs scores without erasing skipped items", {
  items <- tibble::tibble(
    poll_id = "example", source_dataset = "historical",
    respondent_id = rep(c("observed", "absent", "unknown"), each = 2),
    wave = "t2", correct = NA_integer_, raw_value = NA_real_,
    raw_text = NA_character_, response_status = "source_missing"
  )
  presence <- tibble::tibble(
    poll_id = "example", source_dataset = "historical",
    respondent_id = c("observed", "absent", "unknown"), wave = "t2",
    wave_observed = c(TRUE, FALSE, NA)
  )
  people <- tibble::tibble(
    poll_id = character(), source_dataset = character(),
    respondent_id = character(),
    score_wave1 = numeric(), score_wave2 = numeric()
  )
  scores <- analysis_scores(items, people, presence = presence)
  expect_equal(scores$score, c(0, NA_real_, NA_real_))
  expect_equal(scores$n_correct, c(0L, NA_integer_, NA_integer_))
  expect_equal(scores$n_observed, c(NA_integer_, 0L, NA_integer_))
})

test_that("Australian identity and main sample survive presence repair", {
  survey <- read_poll_survey("australia-republic-1999")
  people <- australia_analysis_export("analysis_participants")
  phase_people <- australia_analysis_export("analysis_phase_participants")
  items <- australia_analysis_export("analysis_item_responses")
  previous_scores <- australia_analysis_export("analysis_scores")
  presence <- analysis_australia_presence(people, survey)
  scoring_people <- people |>
    dplyr::mutate(score_wave1 = NA_real_, score_wave2 = NA_real_)
  scores <- analysis_scores(items, scoring_people, presence = presence)
  reviewed <- scores |>
    dplyr::left_join(presence,
      by = c("poll_id", "source_dataset", "respondent_id", "wave"),
      relationship = "one-to-one"
    )
  historical <- reviewed$source_dataset == "historical"
  expect_true(all(is.na(reviewed$score[
    historical & !reviewed$wave_observed %in% TRUE
  ])))
  expect_equal(sum(historical & is.na(reviewed$wave_observed)), 6878L)
  expect_equal(sum(historical & reviewed$wave_observed %in% FALSE), 873L)
  main <- people |>
    dplyr::filter(source_dataset == "historical", panel) |>
    dplyr::pull(respondent_id)
  expect_length(main, 347L)
  keys <- c("poll_id", "source_dataset", "respondent_id", "wave")
  check <- scores |>
    dplyr::filter(source_dataset == "historical", respondent_id %in% main) |>
    dplyr::left_join(previous_scores, by = keys,
      relationship = "one-to-one", suffix = c("", "_previous")
    )
  expect_equal(check$score, check$score_previous)
  expect_equal(check$n_correct, check$n_correct_previous)
  cor <- scores |>
    dplyr::filter(source_dataset == "cor_sood") |>
    dplyr::arrange(respondent_id, wave)
  original_cor <- previous_scores |>
    dplyr::filter(source_dataset == "cor_sood") |>
    dplyr::arrange(respondent_id, wave)
  expect_identical(cor, original_cor)
  expect_equal(nrow(cor), 694L)
  phase_scores <- reviewed |>
    dplyr::mutate(
      wave_observed = dplyr::if_else(
        source_dataset == "cor_sood", TRUE, wave_observed
      ),
      original_score_wave = wave, wave = dplyr::recode(wave, t1 = "t0"),
      battery_id = paste(poll_id, source_dataset, "knowledge", sep = ":")
    )
  corrected <- reconcile_analysis_presence(
    people, scores, items, phase_people, phase_scores
  )
  expect_identical(corrected$items$raw_value, items$raw_value)
  expect_identical(corrected$items$raw_text, items$raw_text)
  absent_items <- corrected$items$response_status == "wave_absent"
  expect_equal(sum(absent_items), 10476L)
  expect_true(all(is.na(corrected$items$correct[absent_items])))
  expect_true(all(corrected$items$raw_value[absent_items] == 100))
  result <- analysis_attendance_contract(
    corrected$participants, corrected$phase_participants, phase_scores,
    survey_reader = function(poll) survey
  )
  historical_people <- result$participants$source_dataset == "historical"
  expect_equal(sum(historical_people & result$participants$attended %in% TRUE),
    356L
  )
  expect_equal(sum(historical_people & result$participants$attended %in% FALSE),
    864L
  )
  expect_equal(sum(historical_people & is.na(result$participants$attended)),
    3439L
  )
  unchanged <- setdiff(names(people), c("attended", "attendance_basis"))
  expect_identical(result$participants[unchanged], people[unchanged])
  no_group <- as.numeric(survey$group[result$participants$source_row]) %in% 100
  expect_true(all(is.na(result$participants$small_group_id[no_group])))
  expect_true(all(is.na(result$participants$cluster_id[no_group])))
  wrong <- people
  wrong$respondent_id[which(wrong$source_row == 3498L)] <- "7059"
  expect_error(analysis_australia_presence(wrong, survey))
})

test_that("phase presence overrides nonapplicable Australian source codes", {
  people <- australia_analysis_export("analysis_participants")
  expected <- analysis_australia_presence(people)
  actual <- analysis_phase_presence(
    australia_analysis_export("analysis_scores"),
    australia_analysis_export("analysis_item_responses"),
    tibble::tibble(), read_metadata("measure_definitions"),
    read_metadata("polardata_targets")
  )
  keys <- c("poll_id", "source_dataset", "respondent_id", "wave")
  check <- dplyr::inner_join(actual, expected,
    by = keys, relationship = "one-to-one", suffix = c("", "_expected")
  )
  expect_equal(nrow(check), nrow(expected))
  expect_identical(check$wave_observed, check$wave_observed_expected)
})
