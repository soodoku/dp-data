marousi_items_fixture <- local({
  fixture <- NULL
  function() {
    if (is.null(fixture)) {
      people <- arrow::read_parquet(project_path(
        "output", "analysis", "analysis_phase_participants.parquet"
      )) |>
        dplyr::filter(poll_id == "marousi-2006")
      scores <- arrow::read_parquet(project_path(
        "output", "analysis", "analysis_phase_scores.parquet"
      )) |>
        dplyr::filter(poll_id == "marousi-2006")
      raw <- haven::read_sav(project_path(
        "data", "marousi-2006", "survey.sav"
      ))
      fixture <<- list(
        people = people, scores = scores, raw = raw,
        items = analysis_marousi_phase_items(people, scores)
      )
    }
    fixture
  }
})

test_that("Marousi items recover raw answers without changing phase records", {
  fixture <- marousi_items_fixture()
  items <- fixture$items
  expect_equal(nrow(items), 26775L)
  expect_equal(dplyr::n_distinct(items$respondent_id), 1275L)
  expect_equal(dplyr::n_distinct(items$item_id), 7L)
  expect_false(anyDuplicated(items[c("respondent_id", "wave", "item_id")]) > 0)
  expected <- tibble::tribble(
    ~wave, ~correct, ~incorrect, ~dk, ~blank, ~unknown, ~absent,
    "t0", 2771L, 3713L, 2435L, 0L, 6L, 0L,
    "t1", 435L, 374L, 211L, 58L, 0L, 7847L,
    "t2", 413L, 366L, 167L, 20L, 0L, 7959L
  )
  actual <- items |>
    dplyr::summarise(
      correct = sum(knowledge_response %in% "correct"),
      incorrect = sum(knowledge_response %in% "incorrect"),
      dk = sum(knowledge_response %in% "dk"),
      blank = sum(response_reason == "blank"),
      unknown = sum(response_reason == "unclassified_nonanswer"),
      absent = sum(response_reason == "wave_absent"), .by = wave
    ) |>
    dplyr::arrange(wave)
  expect_equal(actual, expected)
  before <- serialize(list(fixture$people, fixture$scores), NULL)
  repeated <- analysis_marousi_phase_items(fixture$people, fixture$scores)
  expect_identical(items, repeated)
  expect_identical(
    before, serialize(list(fixture$people, fixture$scores), NULL)
  )
  expect_identical(
    names(items), arrow::open_dataset(project_path(
      "output", "analysis", "analysis_phase_item_responses.parquet"
    ))$schema$names
  )
})

test_that("Marousi retains authored rows for disputed departure IDs", {
  fixture <- marousi_items_fixture()
  raw <- fixture$raw
  expect_equal(raw$P_Q1_0[2], 8805)
  expect_equal(raw$AR_CODE[2], 8805)
  expect_equal(raw$F_CODE[2], 9046)
  exit <- fixture$items |>
    dplyr::filter(source_row == 2L, wave == "t2") |>
    dplyr::arrange(item_id)
  expect_true(all(exit$respondent_id == "80001"))
  expect_equal(exit$raw_value, as.numeric(raw[2, paste0("F_Q", 14:20)]))
  expect_equal(sum(exit$correct), 3L)
  expect_equal(sum(
    !is.na(raw$F_CODE) & raw$F_CODE != raw$P_Q1_0, na.rm = TRUE
  ), 16L)
  bad_people <- fixture$people
  bad_people$source_row[1:2] <- rev(bad_people$source_row[1:2])
  expect_error(analysis_marousi_phase_items(bad_people, fixture$scores))
})

test_that("Marousi item totals reproduce every current phase score", {
  fixture <- marousi_items_fixture()
  recovered <- fixture$items |>
    dplyr::summarise(
      observed = sum(!is.na(raw_value)),
      total = if (all(is.na(correct))) NA_integer_ else sum(correct),
      .by = c(respondent_id, wave)
    ) |>
    dplyr::left_join(
      fixture$scores, by = c("respondent_id", "wave"),
      relationship = "one-to-one"
    )
  expect_equal(nrow(recovered), 3825L)
  expect_identical(recovered$total, recovered$n_correct)
  expect_identical(recovered$observed, recovered$n_observed)
  expect_identical(is.na(recovered$total), is.na(recovered$score))
  later <- recovered[recovered$wave != "t0", ]
  expect_identical(later$total / 7, later$score)
  expect_equal(recovered$total / 7, recovered$score, tolerance = 3e-8)
  expect_equal(sum(
    abs(recovered$total / 7 - recovered$score) > 0, na.rm = TRUE
  ), 144L)
})

test_that("Marousi distinguishes observed blanks from absent forms", {
  items <- marousi_items_fixture()$items
  blank <- items |>
    dplyr::filter(respondent_id == "80000", wave == "t1")
  expect_equal(nrow(blank), 7L)
  expect_true(all(blank$wave_observed & is.na(blank$raw_value)))
  expect_true(all(blank$correct == 0L & is.na(blank$knowledge_response)))
  absent <- items |>
    dplyr::filter(!wave_observed)
  expect_true(all(is.na(absent$correct) & is.na(absent$knowledge_response)))
  expect_true(all(absent$response_status == "wave_absent"))
  no_arrival_flag <- items |>
    dplyr::filter(respondent_id == "source-14825", wave == "t1")
  expect_true(all(no_arrival_flag$wave_observed))
  expect_equal(sum(no_arrival_flag$correct), 5L)
  all_wrong <- items |>
    dplyr::filter(respondent_id == "source-31916", wave == "t2")
  expect_true(all(all_wrong$wave_observed))
  expect_equal(sum(all_wrong$correct), 0L)
  expect_true(all(items$correct[items$knowledge_response %in% "dk"] == 0L))
  unknown <- items |>
    dplyr::filter(response_reason == "unclassified_nonanswer")
  expect_true(all(unknown$source_response_label == "na"))
  expect_true(all(unknown$raw_value == 99 & unknown$correct == 0L))
  expect_true(all(is.na(unknown$knowledge_response)))
})

test_that("Marousi retains labels without inventing guessing options", {
  definitions <- read_metadata("marousi_knowledge_items")
  mayor <- definitions[definitions$item_order == 1L, ]
  expect_true(all(is.na(mayor$n_substantive_options)))
  expect_true(all(grepl("open", mayor$response_type)))
  expect_true(all(definitions$n_substantive_options[
    definitions$item_order != 1L
  ] == 4L))
  labels <- c(tzanikos = 1, "other names" = 2, dk = 88, na = 99)
  classified <- marousi_knowledge_response(
    c(1, 2, 88, 99, NA, 17, 88), labels, 1, c(rep(TRUE, 6), FALSE)
  )
  expect_identical(classified$correct, c(1L, 0L, 0L, 0L, 0L, NA, NA))
  expect_identical(classified$knowledge_response,
                   c("correct", "incorrect", "dk", NA, NA, NA, NA))
  expect_identical(classified$response_reason, c(
    "answered", "answered", "dk", "unclassified_nonanswer", "blank",
    "invalid_response", "wave_absent"
  ))
  expect_identical(classified$source_response_label,
                   c("tzanikos", "other names", "dk", "na", NA, NA, "dk"))
})
