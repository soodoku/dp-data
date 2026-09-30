source(file.path(root, "R", "analysis_phases.R"))

phase_presence_polls <- c(
  "nic-1996", "denmark-euro-2000", "btp-general-election-2004", "amr-2024",
  "btp-national-2003", "btp-presidential-primaries-2004"
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

test_that("documented BTP interviews survive non-substantive batteries", {
  check <- phase_presence_result |>
    dplyr::filter(source_dataset == "historical", wave == "t2",
      (poll_id == "btp-national-2003" & respondent_id == "364") |
        (poll_id == "btp-presidential-primaries-2004" &
           respondent_id %in% c("950382", "950534"))
    )
  expect_equal(nrow(check), 3L)
  expect_true(all(check$wave_observed))
})

test_that("BTP interview evidence does not equate noncompletion with absence", {
  primaries <- tibble::tibble(caseid = 1:3, compf1 = c(1, 2, NA))
  result <- analysis_btp_followup_presence(
    primaries, "btp-presidential-primaries-2004"
  )
  expect_identical(result$form_observed, c(TRUE, NA, NA))
  national <- tibble::tibble(
    serial = 1:3, f_dt_st = c(20030116, 20030116, NA),
    f_tm_st = c(61513, 61513, NA), f_dt_end = c(20030116, 20030116, NA),
    f_tm_end = c(62459, 60000, NA), f_durat = c(9, 9, NA)
  )
  expect_identical(analysis_btp_followup_presence(
    national, "btp-national-2003"
  )$form_observed, c(TRUE, NA, NA))
})

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
  expect_true(all(is.na(scores$score)))
  expect_true(all(is.na(scores$n_correct)))
  expect_true(all(is.na(scores$n_observed)))
  items <- phase_presence_items |>
    dplyr::filter(poll_id == "nic-1996", source_dataset == "historical",
                  respondent_id %in% ids, wave == "t1")
  expect_equal(nrow(items), 5L * 11L)
  expect_true(all(is.na(items$correct)))
  expect_true(all(items$response_status == "source_missing"))
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


test_that("AMR full-form answers establish presence when its quiz is missing", {
  raw <- readr::read_csv(project_path(
    "data", "amr-2024", "participants.csv"
  ), show_col_types = FALSE)
  blank <- rowSums(!is.na(raw[paste0("knowledge_", 1:6)])) == 0L
  expect_equal(sum(blank), 46L)
  evidence <- analysis_amr_presence(raw)
  expect_equal(nrow(evidence), 4838L)
  expect_true(all(evidence$form_observed))
  check <- phase_presence_result |>
    dplyr::filter(poll_id == "amr-2024")
  expect_equal(nrow(check), 4838L)
  expect_true(all(check$wave_observed))
  score <- phase_presence_scores |>
    dplyr::filter(poll_id == "amr-2024")
  position <- match(paste(raw$ID, paste0("t", raw$Time + 1L)),
                    paste(score$respondent_id, score$wave))
  expect_false(anyNA(position))
  expect_equal(score$score[position[blank]], rep(0, 46))
})


test_that("AMR identifiers and demographics cannot establish form presence", {
  raw <- readr::read_csv(project_path(
    "data", "amr-2024", "participants.csv"
  ), show_col_types = FALSE)[1:2, ]
  questions <- setdiff(names(raw), c(
    "ID", "Group", "weight_group", "Weight", "Time", "Country", "gender",
    "urban_global", "education_ISCE", "age"
  ))
  raw[questions] <- NA_real_
  expect_true(all(is.na(analysis_amr_presence(raw)$form_observed)))
  raw$proposal_01[1] <- 0
  expect_equal(analysis_amr_presence(raw)$form_observed, c(TRUE, NA))
  expect_error(analysis_amr_presence(dplyr::bind_rows(raw, raw[1, ])))
})
