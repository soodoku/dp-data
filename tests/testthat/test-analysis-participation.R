source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "analysis_participation.R"))

test_that("eligibility requires collected stages, not later follow-up", {
  people <- tibble::tibble(
    poll_id = c(rep("arrival", 5), "no-arrival", "unresolved"),
    source_dataset = "fixture", respondent_id = as.character(1:7),
    attended = c(TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE),
    panel = TRUE
  )
  waves <- tibble::tibble(
    poll_id = c(rep("arrival", 4), rep("no-arrival", 2), "unresolved"),
    wave = c("t0", "t1", "t2", "t3", "t0", "t2", "t0")
  )
  presence <- people |>
    dplyr::select(-"attended", -"panel") |>
    dplyr::inner_join(waves, by = "poll_id", relationship = "many-to-many") |>
    dplyr::mutate(wave_observed = dplyr::case_when(
      respondent_id == "1" & wave == "t3" ~ FALSE,
      respondent_id == "2" & wave == "t0" ~ FALSE,
      respondent_id == "3" & wave == "t1" ~ FALSE,
      respondent_id == "4" & wave == "t2" ~ FALSE,
      respondent_id == "7" ~ NA,
      TRUE ~ TRUE
    ))
  result <- analysis_participation(people, people, NULL,
    survey_waves = waves, presence = presence
  )
  expect_identical(result$participants$participant,
    c(TRUE, FALSE, FALSE, FALSE, FALSE, TRUE, NA)
  )
  expect_identical(result$participants$exclusion_reason, c(
    NA_character_, "missing_t0_questionnaire", "missing_t1_questionnaire",
    "missing_t2_questionnaire", "nonattendee", NA_character_,
    "questionnaire_presence_unknown"
  ))
  expect_identical(result$participants$attended, people$attended)
  expect_identical(result$participants$panel, people$panel)
  expect_identical(result$participants,
    result$phase_participants[names(result$participants)]
  )
  expect_error(analysis_participation(people, people, NULL,
    survey_waves = waves, presence = dplyr::bind_rows(presence, presence[1, ])
  ))
})

test_that("actual missing earlier forms exclude only documented attendees", {
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_participants.parquet"
  ))
  scores <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_scores.parquet"
  ))
  selected <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_participants.parquet"
  ))
  attendance <- analysis_attendance_contract(selected, people, scores)
  result <- analysis_participation(attendance$participants,
    attendance$phase_participants, scores
  )
  excluded <- result$phase_participants |>
    dplyr::filter(attended %in% TRUE, !participant %in% TRUE)
  expected <- tibble::tribble(
    ~poll_id, ~source_row,
    "california-whats-next-2011", 461L,
    "california-whats-next-2011", 462L,
    "california-whats-next-2011", 463L,
    "california-whats-next-2011", 464L,
    "california-whats-next-2011", 465L,
    "california-whats-next-2011", 466L,
    "california-whats-next-2011", 468L,
    "california-whats-next-2011", 469L,
    "california-whats-next-2011", 470L,
    "california-whats-next-2011", 471L,
    "denmark-euro-2000", 836L,
    "marousi-2006", 86L,
    "marousi-2006", 87L,
    "marousi-2006", 88L,
    "marousi-2006", 137L,
    "marousi-2006", 138L,
    "michigan-2009", 306L,
    "nic-1996", 1L,
    "nic-1996", 240L,
    "nic-1996", 710L,
    "nic-1996", 775L,
    "tomorrows-europe-2007", 3445L,
    "tomorrows-europe-2007", 3446L,
    "tomorrows-europe-2007", 3447L
  )
  actual <- dplyr::distinct(excluded, poll_id, source_row)
  expect_equal(nrow(excluded), 31L)
  unexpected <- dplyr::anti_join(actual, expected,
    by = c("poll_id", "source_row")
  )
  omitted <- dplyr::anti_join(expected, actual,
    by = c("poll_id", "source_row")
  )
  expect_equal(nrow(unexpected), 0L)
  expect_equal(nrow(omitted), 0L)
  ni <- result$phase_participants |>
    dplyr::filter(poll_id == "northern-ireland-2007",
      source_dataset == "control", attended %in% TRUE
    )
  expect_equal(nrow(ni), 93L)
  expect_true(all(ni$participant))
  expect_identical(result$phase_participants$attended,
    attendance$phase_participants$attended
  )
  expect_identical(result$phase_participants$panel,
    attendance$phase_participants$panel
  )
  expect_equal(nrow(result$participants), nrow(selected))
  expect_equal(nrow(result$phase_participants), nrow(people))
})
