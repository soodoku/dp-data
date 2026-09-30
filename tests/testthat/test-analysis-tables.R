source(file.path(root, "R", "analysis_phase_recruitment.R"))
source(file.path(root, "R", "analysis_phases.R"))
source(file.path(root, "R", "analysis_poll_metadata.R"))
source(file.path(root, "R", "analysis_tables.R"))
source(file.path(root, "R", "analysis_attitudes.R"))

test_that("documented nonanswers keep their codes and zero correctness", {
  for (name in c("analysis_item_responses", "analysis_phase_item_responses")) {
    items <- arrow::read_parquet(project_path(
      "output", "analysis", paste0(name, ".parquet")
    ))
    a1r <- items$poll_id == "america-in-one-room-2019" &
      items$raw_value %in% c(-8, 77, 98, 99)
    ireland <- items$poll_id == "northern-ireland-2007" &
      items$source_dataset == "control" & items$raw_value %in% c(9, 10)
    climate <- items$poll_id == "a1r-climate-2021" &
      items$item_id %in% sprintf("knowledge_%03d", 3:8) &
      items$raw_value %in% c(77, 98, 99)
    expect_equal(sum(a1r), 13709L)
    expect_equal(sum(ireland), 356L)
    expect_equal(sum(climate), 16580L)
    selected <- a1r | ireland | climate
    expect_true(all(items$response_status[selected] == "non_substantive"))
    invalid <- selected & items$response_reason == "invalid_response"
    expect_true(all(is.na(items$correct[invalid])))
    expect_true(all(items$correct[selected & !invalid] == 0L))
    expect_false(anyNA(items$raw_value[selected]))
    substantive <- items$poll_id == "america-in-one-room-2019" &
      items$raw_value %in% 1:4
    expect_true(all(items$response_status[substantive] == "answered"))
  }
})

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

test_that("Marousi separates partial quizzes, absent exits and phases", {
  source <- analysis_marousi_source()
  scores <- analysis_marousi_scores(source)
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "marousi-2006", "approved_values.csv"
  ), show_col_types = FALSE) |>
    dplyr::mutate(historical_caseid = as.character(historical_caseid))
  departure <- scores |>
    dplyr::filter(wave == "t2") |>
    dplyr::left_join(approved,
      by = c("respondent_id" = "historical_caseid"),
      relationship = "one-to-one"
    )
  expect_equal(nrow(source), 146L)
  expect_equal(nrow(scores), 438L)
  expect_setequal(unique(scores$wave), c("t0", "t1", "t2"))
  expect_equal(scores$score[scores$wave == "t0"], source$t1know)
  expect_equal(departure$score, departure$approved_departure_score)
  expect_equal(sum(is.na(departure$score)), 17L)
  partial <- departure$reason == "partial_quiz_positive_score_replaced_by_zero"
  expect_equal(sum(partial), 10L)
  expect_equal(sum(departure$n_correct[partial]), 24L)
  expect_true(all(departure$score[partial] > 0))
  expect_equal(sum(departure$n_correct, na.rm = TRUE), 391L)
  expect_true(all(is.na(departure$n_correct[is.na(departure$score)])))
  expect_true(all(departure$n_observed[is.na(departure$score)] == 0L))
  expect_equal(scores$score[scores$wave == "t1"], source$arrival_correct / 7)
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_participants.parquet"
  )) |>
    dplyr::filter(poll_id == "marousi-2006")
  expect_setequal(people$respondent_id, as.character(source$caseid))
  expect_equal(sum(people$panel), 129L)
  expect_equal(people$small_group_id, as.character(source$pollgroup))
  expect_equal(people$source_row, source$original_source_row)
  full <- haven::read_sav(project_path("data", "marousi-2006", "survey.sav"))
  expect_equal(nrow(full), 1275L)
  expect_equal(digest::digest(file = project_path(
    "data", "marousi-2006", "survey.sav"
  ), algo = "sha256"),
  "cc79623a9432a5d4d0bc9b8c3ff1ea3eebaa5021799c80631048f261ca9a651f")
  observed <- source[1, ]
  observed$departure_correct <- 0L
  observed$departure_observed <- TRUE
  zero <- analysis_marousi_scores(observed)
  expect_equal(zero$score[zero$wave == "t2"], 0)
})

test_that("analysis exports preserve keys and canonical question IDs", {
  directory <- project_path("output", "analysis")
  manifest <- readr::read_csv(
    file.path(directory, "manifest.csv"), show_col_types = FALSE
  )
  registered <- read_metadata("canonical_tables") |>
    dplyr::filter(status == "current", startsWith(table, "analysis_"))
  expect_setequal(manifest$table, registered$table)
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
  expect_equal(nrow(catalog), 260L)
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
  expect_equal(sum(a1r_people$arm == "recruitment_nonattender"), 2215L)
  expect_true(all(a1r_people$assignment[a1r_people$arm != "control"] ==
                    "recruitment"))
  expect_false(any(a1r_people$arm == "invited_nonattender"))
  climate_people <- dplyr::filter(
    people, poll_id == "a1r-climate-2021", source_dataset == "control"
  )
  expect_equal(nrow(climate_people), 8814L)
  completed <- dplyr::filter(climate_people, arm == "completed")
  mapping <- readr::read_csv(project_path(
    "audit", "corrections", "a1r-climate-2021", "membership_mapping.csv"
  ), show_col_types = FALSE, col_types = readr::cols(.default = "c"))
  position <- match(completed$respondent_id, mapping$respondent_id)
  expect_false(anyNA(position))
  expect_identical(
    completed$small_group_id, mapping$candidate_small_group_id[position]
  )
  expect_equal(dplyr::n_distinct(completed$small_group_id), 105L)
  expect_equal(range(table(completed$small_group_id)), c(2L, 18L))

  expect_equal(sum(climate_people$female), 5066)
  expect_false(anyNA(climate_people$female))
  expect_equal(sum(climate_people$arm == "completed"), 962L)
  expect_equal(sum(climate_people$arm == "invited_noncompleter"), 7018L)
  expect_equal(sum(climate_people$attended %in% TRUE), 962L + 184L)
  expect_equal(sum(climate_people$attended %in% FALSE), 834L + 6834L)
  expect_equal(sum(is.na(climate_people$attended)), 0L)
  expect_equal(sum(climate_people$panel), 1633L)
  noncompleters <- dplyr::filter(climate_people, arm == "invited_noncompleter")
  expect_equal(sum(noncompleters$attended), 184L)
  inferred <- noncompleters$attendance_basis ==
    "inferred_absent_post_questionnaire"
  expect_equal(sum(inferred), 6408L)
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
    scores$source_dataset == "historical" & !is.na(scores$score)
  ])))
  absent_items <- responses$response_status == "wave_absent"
  expected_absent <- tibble::tribble(
    ~poll_id, ~source_dataset, ~wave, ~people, ~items,
    "australia-republic-1999", "historical", "t2", 873L, 12L,
    "btp-general-election-2004", "historical", "t1", 13L, 9L,
    "btp-general-election-2004", "historical", "t2", 33L, 9L,
    "btp-online-primaries-2004", "cor_sood", "t2", 43L, 7L,
    "btp-presidential-primaries-2004", "historical", "t2", 129L, 7L,
    "california-whats-next-2011", "cor_sood", "t1", 10L, 5L,
    "cpl-1996", "historical", "t2", 1030L, 7L,
    "europolis-2009", "historical", "t2", 4036L, 6L,
    "new-haven-2004", "historical", "t2", 1L, 8L,
    "nic-1996", "historical", "t3", 911L - 387L, 11L,
    "san-mateo-2008", "historical", "t2", 1567L, 8L,
    "swepco-1996", "historical", "t2", 1246L, 5L,
    "uk-crime-1994", "historical", "t2", 569L, 7L,
    "uk-eu-1995", "historical", "t2", 662L, 5L,
    "uk-general-election-1997", "historical", "t2", 935L, 15L,
    "uk-health-1998", "cor_sood", "t2", 2L, 6L,
    "uk-health-1998", "historical", "t2", 2L, 6L,
    "uk-monarchy-1996", "historical", "t2", 599L, 9L,
    "wtu-1996", "historical", "t2", 1000L, 5L,
    "zeguo-2005", "historical", "t2", 34L, 4L
  ) |>
    dplyr::transmute(poll_id, source_dataset, wave, n = people * items)
  actual_absent <- responses[absent_items, ] |>
    dplyr::count(poll_id, source_dataset, wave)
  expect_equal(actual_absent, expected_absent)
  expect_true(all(is.na(responses$correct[absent_items])))
})

test_that("historical comparisons retain the correct source-wave pairs", {
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
    dplyr::filter(poll_id != "nic-1996" | wave != "t2") |>
    dplyr::mutate(
      wave = dplyr::if_else(poll_id == "nic-1996" & wave == "t3", "t2", wave),
      historical_respondent_id = as.numeric(historical_respondent_id)
    ) |>
    dplyr::left_join(sources, by = "poll_id", relationship = "many-to-one") |>
    dplyr::left_join(
      legacy, by = c("dpnum", "historical_respondent_id" = "caseid"),
      relationship = "many-to-one"
    )
  expected_unpaired <- tibble::tribble(
    ~dpnum, ~caseid,
    1, 204, 1, 502, 1, 519, 1, 802, 1, 806, 1, 812, 1, 814,
    1, 833, 1, 933, 1, 937, 1, 2132, 1, 3601, 1, 3611, 1, 3617,
    2, 3809, 2, 4307,
    7, 3522, 7, 3495, 7, 2824, 7, 625, 7, 516,
    7, 693, 7, 374, 7, 225, 7, 148,
    12, 910042,
    20, NA_real_, 20, 10000460, 20, 10004670, 20, 10011680, 20, 10012790
  )
  unpaired <- legacy[is.na(legacy$t1know) | is.na(legacy$t2know), ]
  expect_equal(unpaired[c("dpnum", "caseid")], expected_unpaired)
  # NIC's selected exit is source wave 2; polardata's later score is wave 3.
  expected_excluded <- dplyr::bind_rows(expected_unpaired,
    tibble::tibble(dpnum = 20, caseid = c(
      10000400, 10007580, 10007590, 10014282, 10014650
    ))
  )
  historical_people <- people |>
    dplyr::filter(source_dataset == "historical") |>
    dplyr::mutate(caseid = as.numeric(historical_respondent_id)) |>
    dplyr::left_join(sources, by = "poll_id", relationship = "many-to-one") |>
    dplyr::inner_join(legacy[c("dpnum", "caseid")],
      by = c("dpnum", "caseid"), relationship = "one-to-one"
    )
  excluded <- historical_people |>
    dplyr::filter(!panel) |>
    dplyr::select(dpnum, caseid)
  expect_equal(dplyr::arrange(excluded, dpnum, caseid),
    dplyr::arrange(expected_excluded, dpnum, caseid)
  )
  expect_equal(nrow(panel), 2L * (nrow(legacy) - nrow(expected_excluded)))
  selected_scores <- scores |>
    dplyr::semi_join(dplyr::filter(historical_people, panel),
      by = c("poll_id", "source_dataset", "respondent_id")
    ) |>
    dplyr::filter(wave %in% c("t1", "t2"))
  expect_false(anyNA(selected_scores$score))
  nic_people <- dplyr::filter(historical_people, poll_id == "nic-1996", panel)
  nic_scores <- scores |>
    dplyr::semi_join(nic_people,
      by = c("poll_id", "source_dataset", "respondent_id")
    )
  expect_equal(sum(nic_scores$wave == "t2"), 456L)
  expect_equal(sum(is.na(nic_scores$score[nic_scores$wave == "t3"])), 73L)
  expect_equal(
    panel$score[panel$wave == "t1"],
    panel$t1know[panel$wave == "t1"], tolerance = 1e-7
  )
  expect_equal(
    panel$score[panel$wave == "t2" & !is.na(panel$score)],
    panel$t2know[panel$wave == "t2" & !is.na(panel$score)], tolerance = 1e-7
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
