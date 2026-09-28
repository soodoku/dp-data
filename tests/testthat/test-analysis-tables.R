source(file.path(root, "R", "analysis_poll_metadata.R"))
source(file.path(root, "R", "analysis_tables.R"))

test_that("absent questionnaires stay missing while observed zero stays zero", {
  items <- tibble::tibble(
    poll_id = rep(
      c(rep("btp-general-election-2004", 3), "other-poll"), each = 9
    ),
    source_dataset = "historical",
    respondent_id = rep(c("absent", "zero", "one_correct", "legacy"), each = 9),
    wave = "t2", correct = c(
      rep(NA_integer_, 9), rep(0L, 9), 1L, rep(0L, 8), rep(NA_integer_, 9)
    ),
    raw_value = NA_real_, raw_text = NA_character_,
    response_status = c(rep("wave_absent", 9), rep("scored", 27))
  )
  participants <- tibble::tibble(
    poll_id = character(), source_dataset = character(),
    respondent_id = character(),
    score_wave1 = numeric(), score_wave2 = numeric()
  )
  scores <- analysis_scores(items, participants)
  expect_equal(scores$score, c(NA_real_, 0, 1 / 9, 0))
  expect_equal(scores$n_correct, c(NA_integer_, 0L, 1L, 0L))
  expect_equal(scores$n_observed, c(0L, NA_integer_, NA_integer_, NA_integer_))
})

test_that("analysis exports preserve keys and canonical question IDs", {
  directory <- project_path("output", "analysis")
  manifest <- readr::read_csv(
    file.path(directory, "manifest.csv"), show_col_types = FALSE
  )
  expect_equal(nrow(manifest), 6L)
  expect_true(all(file.exists(project_path(manifest$path))))
  expect_equal(
    vapply(project_path(manifest$path), digest::digest,
           character(1), file = TRUE, algo = "sha256", USE.NAMES = FALSE),
    manifest$sha256
  )
  tables <- stats::setNames(
    lapply(project_path(manifest$path), arrow::read_parquet), manifest$table
  )
  expect_equal(
    unname(vapply(tables, nrow, integer(1))), manifest$rows
  )
  polls <- tables$analysis_polls
  catalog <- tables$analysis_items
  people <- tables$analysis_participants
  responses <- tables$analysis_item_responses
  scores <- tables$analysis_scores
  expect_equal(nrow(polls), 50L)
  expect_equal(nrow(catalog), 245L)
  expect_equal(dplyr::n_distinct(people$poll_id), 33L)
  expect_equal(dplyr::n_distinct(responses$poll_id), 31L)
  expect_true(all(grepl("^knowledge_[0-9]{3}$", catalog$item_id)))
  expect_false(anyDuplicated(catalog[c("poll_id", "item_id")]) > 0L)
  expect_false(anyDuplicated(people[c(
    "poll_id", "source_dataset", "respondent_id"
  )]) > 0L)
  cor_people <- dplyr::filter(people, source_dataset == "cor_sood")
  expect_equal(sum(!is.na(cor_people$small_group_id)), 6147L)
  expect_equal(
    sum(!is.na(cor_people$small_group_id[
      cor_people$poll_id == "btp-online-primaries-2004"
    ])), 315L
  )
  expect_true(all(is.na(cor_people$small_group_id[
    cor_people$poll_id %in% c("denmark-euro-2000", "vermont-energy-2007")
  ])))
  expect_false(anyDuplicated(responses[c(
    "poll_id", "source_dataset", "respondent_id", "wave", "item_id"
  )]) > 0L)
  expect_false(anyDuplicated(scores[c(
    "poll_id", "source_dataset", "respondent_id", "wave"
  )]) > 0L)
  expect_equal(nrow(dplyr::anti_join(
    dplyr::distinct(responses, poll_id, source_dataset, respondent_id),
    people, by = c("poll_id", "source_dataset", "respondent_id")
  )), 0L)
  expect_equal(nrow(dplyr::anti_join(
    dplyr::distinct(responses, poll_id, item_id), catalog,
    by = c("poll_id", "item_id")
  )), 0L)
  expect_setequal(
    unique(people$arm[people$poll_id == "amr-2024"]),
    c("attended", "control")
  )
  amr_people <- dplyr::filter(
    people, poll_id == "amr-2024", source_dataset == "control"
  )
  expect_equal(nrow(amr_people), 2419L)
  expect_equal(sum(amr_people$female), 1190)
  expect_false(anyNA(amr_people$female))
  a1r_people <- dplyr::filter(
    people, poll_id == "america-in-one-room-2019",
    source_dataset == "control"
  )
  expect_equal(sum(a1r_people$attended), 526L)
  expect_equal(sum(a1r_people$panel), 1367L)
  expect_equal(sum(a1r_people$attended & !a1r_people$panel), 3L)
  expect_true(all(!is.na(a1r_people$small_group_id[a1r_people$attended])))
  expect_true(all(a1r_people$arm[a1r_people$attended] == "attended"))
  climate_people <- dplyr::filter(
    people, poll_id == "a1r-climate-2021", source_dataset == "control"
  )
  expect_equal(nrow(climate_people), 8814L)
  expect_equal(sum(climate_people$female), 5066)
  expect_false(anyNA(climate_people$female))
  ni_people <- dplyr::filter(
    people, poll_id == "northern-ireland-2007",
    source_dataset == "control"
  )
  ni_items <- dplyr::filter(
    responses, poll_id == "northern-ireland-2007",
    source_dataset == "control"
  )
  expect_equal(nrow(ni_people), 243L)
  expect_equal(sum(ni_people$arm == "attended"), 93L)
  expect_equal(sum(ni_people$arm == "control"), 150L)
  ni_t2_ids <- people |>
    dplyr::filter(poll_id == "northern-ireland-2007",
                  source_dataset == "cor_sood") |>
    dplyr::pull(respondent_id)
  expect_equal(sum(ni_people$respondent_id %in% ni_t2_ids), 93L)
  expect_equal(nrow(ni_items), 243L * 7L)
  expect_setequal(unique(ni_items$wave), "t3")
  expect_setequal(unique(ni_items$item_id),
                  paste0("knowledge_", sprintf("%03d", 1:7)))
  ni_example <- dplyr::filter(
    ni_items, respondent_id == "22"
  ) |>
    dplyr::arrange(item_id)
  expect_equal(ni_example$raw_value, c(9, 4, 3, 2, 9, 1, 2))
  expect_equal(ni_example$correct, c(0L, 1L, 0L, 0L, 0L, 1L, 0L))
  ni_score <- dplyr::filter(
    scores, poll_id == "northern-ireland-2007",
    source_dataset == "control", respondent_id == "22"
  )
  expect_equal(ni_score$score, 2 / 7)
  expect_equal(
    unique(scores$scale[scores$poll_id == "tanzania-2015"]),
    "standardized_index"
  )
  tanzania_people <- dplyr::filter(
    people, poll_id == "tanzania-2015", source_dataset == "control"
  )
  expect_equal(nrow(tanzania_people), 2002L)
  expect_equal(sum(tanzania_people$female, na.rm = TRUE), 1052)
  expect_equal(sum(is.na(tanzania_people$female)), 1L)
  absent <- scores$source_dataset == "historical" &
    scores$poll_id == "btp-general-election-2004" & is.na(scores$score)
  expect_equal(sum(absent), 46L)
  expect_true(all(scores$n_observed[absent] == 0L))
  expect_true(all(is.na(scores$n_correct[absent])))
  expect_true(all(is.na(scores$n_observed[
    scores$source_dataset == "historical" & !absent
  ])))
  absent_items <- responses$response_status == "wave_absent"
  expect_equal(sum(absent_items), 414L)
  expect_true(all(
    responses$poll_id[absent_items] == "btp-general-election-2004"
  ))
  expect_true(all(is.na(responses$correct[absent_items])))
})

test_that("historical panel scores match the existing aggregate export", {
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_participants.parquet"
  ))
  scores <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_scores.parquet"
  ))
  legacy <- arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  ))
  sources <- read_metadata("respondent_sources") |>
    dplyr::select("poll_id", "dpnum")
  panel <- people |>
    dplyr::filter(source_dataset == "historical", panel) |>
    dplyr::inner_join(scores, by = c(
      "poll_id", "source_dataset", "respondent_id"
    )) |>
    dplyr::mutate(
      historical_respondent_id = as.numeric(historical_respondent_id)
    ) |>
    dplyr::left_join(sources, by = "poll_id", relationship = "many-to-one") |>
    dplyr::left_join(
      legacy, by = c("dpnum", "historical_respondent_id" = "caseid"),
      relationship = "many-to-one"
    )
  expect_equal(nrow(panel), 2L * nrow(legacy))
  expect_equal(
    panel$score[panel$wave == "t1"],
    panel$t1know[panel$wave == "t1"], tolerance = 1e-7
  )
  expect_equal(
    panel$score[panel$wave == "t2"],
    panel$t2know[panel$wave == "t2"], tolerance = 1e-7
  )
})

test_that("reported timing conflicts remain visible without a false date", {
  events <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_poll_events.parquet"
  ))
  polls <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_polls.parquet"
  ))
  conflict <- dplyr::filter(events, poll_id == "new-haven-2004")
  expect_equal(nrow(conflict), 2L)
  expect_true(any(conflict$year_conflict))
  expect_true(all(is.na(conflict$start_date[conflict$year_conflict])))
  expect_true(is.na(polls$event_start_date[
    polls$poll_id == "new-haven-2004"
  ]))
  expect_true(all(!is.na(events$reference_id)))
})

test_that("conflicting source years null poll timing", {
  polls <- tibble::tibble(poll_id = "new-haven-2004", year = 2004L)
  facts <- tibble::tibble(
    poll_id = "new-haven-2004", field = "event_dates",
    value = c("2002-03-01 through 2002-03-03",
              "Archive appendix says 2004, March 1–3"),
    reference_id = c("paper", "archive"), source_locator = "date"
  )
  events <- analysis_poll_events(polls, facts)
  expect_true(all(events$year_conflict))
  expect_true(all(is.na(events$start_date)))
  expect_true(all(is.na(events$month)))
})


test_that("item display text preserves source fields and scoring", {
  source(file.path(root, "R", "analysis_tables.R"))
  catalog <- analysis_item_catalog()
  source <- readr::read_csv(project_path("metadata", "items.csv"),
    show_col_types = FALSE
  )
  expect_equal(catalog[names(source)], source)
  expect_equal(
    item_display_text(c(
      "4: APPTS ON ADVICE OF P.M. (correct)",
      "Which EU policy?", NA_character_
    )),
    c(
      "4: Appointed on advice of prime minister (correct)",
      "Which EU policy?", NA_character_
    )
  )
  expect_equal(
    item_display_text("1: LIBERAL PARTY MORE | 2: NO ROLE"),
    "1: Liberal Party more | 2: No role"
  )
  expect_equal(
    item_display_text(catalog$answer_choices_display),
    catalog$answer_choices_display
  )
})
