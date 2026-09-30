source(project_path("R", "analysis_knowledge_missingness.R"))

missingness_fixture <- function() {
  ids <- c("blank", "dk", "incorrect", "refused", "absent", "unknown",
           "score_only", "partial", "nonattendee", "positive_blank", "skipped")
  people <- tibble::tibble(
    poll_id = "test", source_dataset = "historical", respondent_id = ids,
    source_row = seq_along(ids), attended = ids != "nonattendee",
    participant = dplyr::case_when(
      ids == "unknown" ~ NA,
      ids %in% c("nonattendee", "absent") ~ FALSE, TRUE ~ TRUE
    )
  )
  scores <- people |>
    dplyr::select("poll_id", "source_dataset", "respondent_id") |>
    dplyr::mutate(
      battery_id = "quiz", wave = "t0", wave_instance_id = "T1",
      original_survey_wave = "T1", wave_role = "pre_arrival",
      n_items = 2L,
      wave_observed = dplyr::case_when(
        respondent_id == "absent" ~ FALSE,
        respondent_id == "unknown" ~ NA, TRUE ~ TRUE
      ),
      score = dplyr::case_when(
        respondent_id %in% c("absent", "unknown") ~ NA_real_,
        respondent_id == "positive_blank" ~ .5, TRUE ~ 0
      )
    )
  items <- scores[rep(seq_along(ids), each = 2L), ] |>
    dplyr::mutate(
      item_id = rep(c("q1", "q2"), length(ids)),
      source_row = rep(seq_along(ids), each = 2L),
      source_column = rep(c("Q1", "Q2"), length(ids)),
      raw_value = dplyr::case_when(
        respondent_id == "dk" ~ 8, respondent_id == "incorrect" ~ 1,
        respondent_id == "refused" ~ 9,
        respondent_id == "skipped" & item_id == "q1" ~ 98,
        respondent_id == "skipped" & item_id == "q2" ~ 8,
        TRUE ~ NA_real_
      ),
      raw_text = NA_character_,
      response_reason = dplyr::case_when(
        respondent_id == "dk" ~ "dk",
        respondent_id == "incorrect" ~ "answered",
        respondent_id == "refused" ~ "refused",
        respondent_id == "absent" ~ "wave_absent",
        respondent_id == "skipped" & item_id == "q1" ~ "blank",
        respondent_id == "skipped" & item_id == "q2" ~ "dk",
        TRUE ~ "source_missing"
      ),
      knowledge_response = dplyr::case_when(
        response_reason == "dk" ~ "dk",
        response_reason == "answered" ~ "incorrect",
        wave_observed %in% TRUE & score == 0 &
          response_reason %in% c("blank", "source_missing") ~ "dk",
        TRUE ~ NA_character_
      )
    ) |>
    dplyr::filter(
      respondent_id != "score_only",
      !(respondent_id == "partial" & item_id == "q2")
    )
  list(items = items, people = people, scores = scores)
}

testthat::test_that("zero scores retain distinct raw response explanations", {
  fixture <- missingness_fixture()
  original <- fixture
  flags <- knowledge_flags(fixture$items, fixture$people, fixture$scores)
  testthat::expect_identical(fixture, original)
  expected <- c(
    blank = "all_blank", dk = "all_explicit_dk",
    incorrect = "some_substantive_answers",
    refused = "other_nonanswers_or_unresolved",
    score_only = "unresolved_item_evidence",
    partial = "unresolved_item_evidence"
  )
  testthat::expect_identical(
    flags$zero_pattern[match(names(expected), flags$respondent_id)],
    unname(expected)
  )
  raw_blank <- fixture$items[fixture$items$respondent_id == "blank", ]
  testthat::expect_true(all(raw_blank$knowledge_response == "dk"))
  testthat::expect_identical(flags$n_dk[flags$respondent_id == "blank"], 0L)
  testthat::expect_identical(flags$n_dk[flags$respondent_id == "dk"], 2L)
  unavailable <- flags$respondent_id %in% c("absent", "unknown")
  testthat::expect_true(all(is.na(flags$zero_score[unavailable])))
  testthat::expect_true(all(is.na(flags$all_blank[unavailable])))
  unsupported <- flags$respondent_id %in% c("score_only", "partial")
  testthat::expect_true(all(is.na(flags$all_blank[unsupported])))
  positive <- flags[flags$respondent_id == "positive_blank", ]
  testthat::expect_true(positive$all_blank)
  testthat::expect_false(positive$zero_score)
  testthat::expect_identical(flags$score, fixture$scores$score)
  skipped <- flags[flags$respondent_id == "skipped", ]
  testthat::expect_identical(skipped$n_recorded_blank, 1L)
  testthat::expect_identical(skipped$n_dk, 1L)
  testthat::expect_false(skipped$all_blank)
  testthat::expect_identical(skipped$blank_source_columns, "Q1")
  unknown_size <- fixture$scores
  score_only_row <- unknown_size$respondent_id == "score_only"
  unknown_size$n_items[score_only_row] <- NA_integer_
  unknown_flags <- knowledge_flags(fixture$items, fixture$people, unknown_size)
  score_only <- unknown_flags[unknown_flags$respondent_id == "score_only", ]
  testthat::expect_true(is.na(score_only$n_items))
  testthat::expect_false(score_only$complete_item_evidence)
  testthat::expect_true(score_only$zero_score)

})

testthat::test_that("zero rates use observed scored forms by scope", {
  fixture <- missingness_fixture()
  flags <- knowledge_flags(fixture$items, fixture$people, fixture$scores)
  reports <- knowledge_missingness(flags)
  source <- reports$summary[reports$summary$scope == "source_frame", ]
  attendees <- reports$summary[reports$summary$scope == "attendees", ]
  testthat::expect_identical(source$n_people, 11L)
  testthat::expect_identical(source$n_observed_scored_forms, 9L)
  testthat::expect_identical(source$n_zero_scores, 8L)
  testthat::expect_equal(source$zero_score_rate, 8 / 9)
  testthat::expect_identical(attendees$n_observed_scored_forms, 8L)
  testthat::expect_identical(attendees$n_zero_scores, 7L)
  testthat::expect_equal(attendees$zero_score_rate, 7 / 8)
  testthat::expect_identical(source$n_people_any_blank, 5L)
  testthat::expect_identical(source$n_people_all_blank, 3L)
  testthat::expect_identical(attendees$n_people_all_blank, 2L)
  testthat::expect_identical(source$n_dk_items, 3L)
  testthat::expect_identical(source$n_refused_items, 2L)
  testthat::expect_identical(source$n_observed_without_item_evidence, 1L)
  testthat::expect_setequal(reports$respondents$respondent_id,
    c("blank", "partial", "nonattendee", "positive_blank", "skipped")
  )
  testthat::expect_true("participants" %in% reports$summary$scope)
})

testthat::test_that("source aliases and zero-score batteries remain separate", {
  fixture <- missingness_fixture()
  flags <- knowledge_flags(fixture$items, fixture$people, fixture$scores)
  alias <- dplyr::mutate(flags, source_dataset = "cor_sood")
  reports <- knowledge_missingness(dplyr::bind_rows(flags, alias))
  testthat::expect_equal(nrow(reports$summary), 6L)
  testthat::expect_equal(nrow(reports$respondents), 10L)
  post <- dplyr::mutate(flags,
    wave = "t2", wave_instance_id = "T2", original_survey_wave = "T2",
    score = dplyr::if_else(respondent_id == "blank", .5, score),
    zero_score = dplyr::if_else(respondent_id == "blank", FALSE, zero_score)
  )
  paired <- dplyr::inner_join(
    dplyr::select(flags, poll_id, source_dataset, respondent_id, battery_id,
                  baseline_zero = zero_score),
    dplyr::select(post, poll_id, source_dataset, respondent_id, battery_id,
                  exit_zero = zero_score),
    by = c("poll_id", "source_dataset", "respondent_id", "battery_id"),
    relationship = "one-to-one"
  )
  person <- paired[paired$respondent_id == "blank", ]
  testthat::expect_true(person$baseline_zero)
  testthat::expect_false(person$exit_zero)
  testthat::expect_true(person$baseline_zero | person$exit_zero)
  testthat::expect_error(knowledge_flags(
    dplyr::bind_rows(fixture$items, fixture$items[1, ]),
    fixture$people, fixture$scores
  ))
})
