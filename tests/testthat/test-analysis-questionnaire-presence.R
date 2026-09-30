source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "source_questionnaire_presence.R"))

questionnaire_analysis_people <- function() {
  arrow::read_parquet(project_path(
    "output", "analysis", "analysis_participants.parquet"
  ))
}

test_that("reviewed forms distinguish absent, unknown and returned forms", {
  expected <- tibble::tribble(
    ~poll, ~wave, ~observed, ~absent, ~unknown,
    "cpl-1996", "t2", 216L, 1030L, 0L,
    "uk-crime-1994", "t2", 300L, 569L, 0L,
    "uk-general-election-1997", "t2", 275L, 935L, 0L,
    "uk-health-1998", "t2", 228L, 2L, 0L,
    "europolis-2009", "t2", 348L, 4036L, 0L,
    "tomorrows-europe-2007", "t2", 359L, 0L, 3191L,
    "btp-presidential-primaries-2004", "t1", 1220L, 0L, 69L,
    "btp-presidential-primaries-2004", "t2", 745L, 129L, 415L,
    "nic2-2003", "t1", 881L, 0L, 612L,
    "nic2-2003", "t2", 952L, 0L, 541L,
    "nic-1996", "t1", 905L, 0L, 6L,
    "nic-1996", "t2", 632L, 0L, 279L,
    "zeguo-2005", "t1", 268L, 0L, 1L
  )
  people <- questionnaire_analysis_people()
  evidence <- analysis_reviewed_presence(people)
  historical <- evidence[evidence$source_dataset == "historical", ]
  for (i in seq_len(nrow(expected))) {
    row <- expected[i, ]
    values <- historical$wave_observed[
      historical$poll_id == row$poll & historical$wave == row$wave
    ]
    expect_equal(sum(values %in% TRUE), row$observed, info = row$poll)
    expect_equal(sum(values %in% FALSE), row$absent, info = row$poll)
    expect_equal(sum(is.na(values)), row$unknown, info = row$poll)
  }
  keys <- c("poll_id", "source_dataset", "respondent_id", "wave")
  expect_equal(anyDuplicated(evidence[keys]), 0L)
  expect_false(any(evidence$poll_id == "san-mateo-2008"))
  expect_false(any(evidence$poll_id == "tomorrows-europe-2007" &
                     evidence$wave == "t1"))
  expect_identical(people, questionnaire_analysis_people())
})

test_that("Health completion evidence does not erase positive attendance", {
  people <- questionnaire_analysis_people()
  evidence <- analysis_reviewed_presence(people)
  missing_health <- evidence |>
    dplyr::filter(poll_id == "uk-health-1998", !wave_observed)
  expect_setequal(missing_health$respondent_id, c("3809", "4307"))
  expect_equal(nrow(missing_health), 4L)
  original <- people |>
    dplyr::semi_join(missing_health,
      by = c("poll_id", "source_dataset", "respondent_id")
    )
  expect_true(all(original$attended))
  survey <- read_poll_survey("uk-health-1998")
  row <- which(as.numeric(survey$serial_m) == 3809)
  fields <- questionnaire_form_contract("uk-health-1998")$fields[[1]]
  expect_length(fields, 75L)
  expect_true(all(is.na(as.matrix(survey[row, fields]))))
  expect_equal(as.numeric(survey$manwkend[row]), 0)
  survey$mtneed2[row] <- 1
  expect_error(questionnaire_form_evidence(survey, "uk-health-1998"))
})

test_that("a returned questionnaire with a blank quiz remains observed", {
  survey <- read_poll_survey("uk-health-1998")
  fields <- paste0("soph", letters[1:6], "2")
  row <- which(as.numeric(survey$manwkend) == 1)[1L]
  survey[row, fields] <- NA_real_
  evidence <- questionnaire_form_evidence(survey, "uk-health-1998")
  expect_true(evidence$wave_observed[evidence$source_row == row])
  expect_true(all(is.na(as.matrix(survey[row, fields]))))
})

test_that("NIC empty forms stay unknown despite participant indicators", {
  survey <- read_poll_survey("nic-1996")
  evidence <- questionnaire_form_evidence(survey, "nic-1996")
  before <- evidence[evidence$wave == "t1", ]
  after <- evidence[evidence$wave == "t2", ]
  selected <- as.numeric(survey$PART) %in% 1
  expect_equal(sum(selected & is.na(before$wave_observed)), 5L)
  expect_equal(sum(selected & is.na(after$wave_observed)), 6L)
  expect_equal(sum(selected & (is.na(before$wave_observed) |
                                 is.na(after$wave_observed))), 10L)
  expect_false(any(evidence$wave_observed %in% FALSE))
  interviewed <- as.numeric(survey$CASEID) %in% c(
    10000531, 10008110, 10008970, 10009010, 10009020, 10009310, 10012190
  )
  expect_equal(sum(interviewed), 7L)
  expect_true(all(before$wave_observed[interviewed]))
})

test_that("copied NIC2 income is not evidence of a post questionnaire", {
  survey <- read_poll_survey("nic2-2003")
  evidence <- questionnaire_form_evidence(survey, "nic2-2003")
  after <- evidence[evidence$wave == "t2", ]
  empty <- is.na(after$wave_observed)
  expect_equal(sum(empty), 541L)
  expect_equal(sum(!is.na(survey$qisum[empty])), 480L)
  expect_equal(
    as.numeric(survey$qisum[empty]),
    as.numeric(survey$isum[empty])
  )
  row <- which(empty & !is.na(survey$qisum))[1L]
  survey$qisum[row] <- as.numeric(survey$qisum[row]) + 1
  expect_error(questionnaire_form_evidence(survey, "nic2-2003"))
})

test_that("identities cannot silently cross source rows", {
  people <- questionnaire_analysis_people() |>
    dplyr::filter(poll_id == "uk-health-1998")
  row <- which(people$source_dataset == "cor_sood")[1L]
  people$source_row[row] <- people$source_row[row] + 1L
  expect_error(analysis_reviewed_presence(people))
  unsupported <- tibble::tibble(
    poll_id = "san-mateo-2008", source_dataset = "historical"
  )
  expect_null(analysis_reviewed_presence(unsupported))
})

test_that("TE arrival evidence cannot overwrite the pre-arrival baseline", {
  people <- questionnaire_analysis_people()
  selected <- analysis_reviewed_presence(people) |>
    dplyr::filter(poll_id == "tomorrows-europe-2007")
  arrival <- analysis_te_arrival_presence(people)
  expect_true(all(selected$wave == "t2"))
  expect_true(all(arrival$wave == "t1"))
  expect_equal(sum(arrival$source_dataset == "historical" &
                     is.na(arrival$wave_observed)), 3212L)
  expect_equal(sum(arrival$source_dataset == "cor_sood" &
                     is.na(arrival$wave_observed)), 26L)
  survey <- read_poll_survey("tomorrows-europe-2007")
  original_rows <- survey$source_row[!is.na(survey$group_no)]
  expect_length(original_rows, 344L)
  main <- people |>
    dplyr::filter(poll_id == "tomorrows-europe-2007",
      source_dataset == "historical", source_row %in% original_rows
    )
  current <- arrival |>
    dplyr::semi_join(main,
      by = c("poll_id", "source_dataset", "respondent_id")
    )
  expect_equal(sum(is.na(current$wave_observed)), 7L)
  expect_false(any(arrival$wave_observed %in% FALSE))
})
