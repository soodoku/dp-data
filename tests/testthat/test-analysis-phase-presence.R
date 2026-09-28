source(file.path(root, "R", "analysis_phases.R"))

phase_presence_polls <- c(
  "nic-1996", "denmark-euro-2000", "btp-general-election-2004"
)
phase_presence_scores <- arrow::read_parquet(project_path(
  "output", "analysis", "analysis_scores.parquet"
)) |>
  dplyr::filter(poll_id %in% phase_presence_polls)
phase_presence_items <- arrow::read_parquet(project_path(
  "output", "analysis", "analysis_item_responses.parquet"
)) |>
  dplyr::filter(poll_id %in% phase_presence_polls)
phase_presence_result <- analysis_phase_presence(
  phase_presence_scores, phase_presence_items,
  arrow::read_parquet(project_path(
    "output", "respondent", "respondent_measures.parquet"
  )),
  read_metadata("measure_definitions"), read_metadata("polardata_targets")
)

test_that("NIC identifiers and generated flags do not establish an interview", {
  ids <- c("10000460", "10004670", "10011680", "10012410", "10012790")
  source_rows <- c(23L, 240L, 710L, 755L, 775L)
  raw <- arrow::read_parquet(project_path("data", "nic-1996", "survey.parquet"))
  respondents <- raw[match(source_rows, raw$source_row), ]
  expect_equal(as.character(respondents$CASEID), ids)
  expect_true(all(is.na(respondents$DATEDUN1)))
  expect_true(all(is.na(respondents$SEX1)))
  expect_true(all(!is.na(respondents$KNOW1)))
  check <- phase_presence_result |>
    dplyr::filter(poll_id == "nic-1996", source_dataset == "historical",
                  respondent_id %in% ids, wave == "t1")
  expect_equal(nrow(check), 5L)
  expect_true(all(is.na(check$wave_observed)))
  scores <- phase_presence_scores |>
    dplyr::filter(poll_id == "nic-1996", source_dataset == "historical",
                  respondent_id %in% ids, wave == "t1")
  expect_equal(scores$score, rep(0, 5))
})

test_that("Denmark's observed questionnaire with a blank quiz retains zero", {
  raw <- arrow::read_parquet(project_path(
    "data", "denmark-euro-2000", "departure.parquet"
  )) |>
    dplyr::filter(DELNR == 321)
  quiz_fields <- c(paste0("S", 4:9, "_2"), paste0("S11_", c(7, 9, 11), "_2"))
  expect_equal(raw$source_row, 296L)
  expect_true(all(is.na(raw[quiz_fields])))
  question_fields <- grep("^S[0-9]", names(raw), value = TRUE)
  expect_equal(sum(!is.na(raw[question_fields])), 41L)
  check <- phase_presence_result |>
    dplyr::filter(poll_id == "denmark-euro-2000", source_dataset == "cor_sood",
                  respondent_id == "321", wave == "t2")
  expect_equal(check$wave_observed, TRUE)
  score <- phase_presence_scores |>
    dplyr::filter(poll_id == "denmark-euro-2000", source_dataset == "cor_sood",
                  respondent_id == "321", wave == "t2")
  expect_equal(score$score, 0)
})

test_that("explicit absent-wave evidence takes precedence over the fallback", {
  check <- phase_presence_result |>
    dplyr::filter(poll_id == "btp-general-election-2004",
                  source_dataset == "historical", wave_observed %in% FALSE)
  expect_equal(sum(check$wave == "t1"), 13L)
  expect_equal(sum(check$wave == "t2"), 33L)
  nic <- phase_presence_result |>
    dplyr::filter(poll_id == "nic-1996")
  expect_false(any(nic$wave_observed[nic$wave != "t3"] %in% FALSE))
  expect_true(any(nic$wave_observed[nic$wave == "t3"] %in% FALSE))
})

test_that("NIC phase roles distinguish event exit from the later follow-up", {
  roles <- read_metadata("analysis_phase_roles") |>
    dplyr::filter(poll_id == "nic-1996", source_dataset == "historical")
  expect_equal(roles$wave[roles$score_wave == "t1"], "t0")
  expect_equal(roles$wave[roles$score_wave == "t2"], "t2")
  expect_equal(roles$wave_role[roles$score_wave == "t2"],
               "post_deliberation")
  expect_equal(roles$wave[roles$score_wave == "t3"], "t3")
  expect_equal(roles$wave_role[roles$score_wave == "t3"], "follow_up")
  expect_false(any(roles$wave_role == "arrival"))
})
