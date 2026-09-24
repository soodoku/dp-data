source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "respondent_btp_general.R"))
source(file.path(root, "R", "respondent_btp_health.R"))
source(file.path(root, "R", "respondent_btp_national.R"))
source(file.path(root, "R", "polardata_derived.R"))
source(file.path(root, "R", "polardata_assembly.R"))
source(file.path(root, "R", "polardata_btp_reviewed.R"))
source(file.path(root, "R", "polardata_btp_national.R"))

national_test_source <- function() {
  survey <- haven::read_dta(
    project_path("data", "btp-national-2003", "survey.dta")
  )
  survey$source_row <- seq_len(nrow(survey))
  survey
}

test_that("National recodes need raw answers, not stored scale columns", {
  survey <- national_test_source()
  expected <- build_btp_national_individual(survey)
  raw <- survey[, grepl("^(qb|qf|pp)", names(survey))]
  expect_equal(build_btp_national_individual(raw), expected)
  index <- c(245L, 80L, 1L)
  expect_equal(build_btp_national_individual(raw[index, ]), expected[index, ])
  raw$qb15b[1] <- 11
  expect_error(build_btp_national_individual(raw), "Unreviewed source codes")
  expect_error(
    build_btp_national_individual(survey[, names(survey) != "qb22"]),
    "Missing source field: qb22"
  )
})

test_that("National preserves climate-placement thresholds and nonresponse", {
  survey <- national_test_source()[rep(1, 5), ]
  survey$qb15b <- c(-1, 5, 6, 10, NA)
  survey$qb15c <- c(-1, 0, 4, 5, NA)
  items <- btp_national_knowledge(survey, 1L)
  expect_equal(items[, "democratic"], c(0, 0, 1, 1, 0))
  expect_equal(items[, "republican"], c(0, 1, 1, 0, 0))
  survey$qb22 <- c(1, 2, 3, 4, -1)
  components <- btp_national_item(survey, "qb22", "support") / 2
  expect_equal(components, c(.5, 0, .25, NA_real_, NA_real_))
})

test_that("National respondent and aggregate values retain historical parity", {
  survey <- national_test_source()
  actual <- build_btp_national_individual(survey)
  benchmark <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  expected <- benchmark[benchmark$dpnum == 14, ]
  index <- match(expected$caseid, 930000 + survey$source_row)
  expect_false(anyNA(index))
  expect_equal(nrow(expected), 245L)
  mapping <- c(
    t1know = "knowledge_t1", t1knowr = "knowledge_t1",
    t2know = "knowledge_t2", t2knowr = "knowledge_t2",
    t1knowcor = "knowledge_joint", t1knowrcor = "knowledge_joint",
    knowgain = "knowledge_gain", knowgainr = "knowledge_gain",
    knowgain2 = "knowledge_gain_joint", knowgainr2 = "knowledge_gain_joint",
    logpk = "log_knowledge_joint", tobitpk = "high_knowledge_joint",
    ppage = "age", female = "female", minority = "minority",
    educ4 = "education_four", educ3 = "education_three",
    bettered = "higher_education", hhincome = "household_income",
    highinc = "high_income", attextreme = "attitude_extremity",
    readbrief = "read_briefing", t1polint = "political_interest_t1",
    t1knowcor2 = "knowledge_joint_midterm", t12know = "knowledge_midterm",
    t12knowcor = "knowledge_midterm_joint",
    attextreme2 = "attitude_extremity_midterm"
  )
  attitudes <- c(
    usseca = "security", humrh2 = "human_rights",
    envir = "environment", inter = "internationalism",
    multi = "multilateralism",
    demo = "democracy", forai1 = "foreign_aid", global = "global_altruism",
    trade = "trade"
  )
  for (wave in 1:2) {
    keys <- paste0("btp03.olt", wave, names(attitudes))
    mapping[keys] <- paste0(attitudes, "_t", wave)
  }
  for (field in names(mapping)) {
    value <- actual[[mapping[[field]]]][index]
    expect_identical(is.na(value), is.na(expected[[field]]), info = field)
    expect_equal(value, as.numeric(expected[[field]]),
      tolerance = 1e-10,
      info = field
    )
  }
  values <- tibble::tibble(source_row = survey$source_row[index])
  derived <- build_btp_national_derived(survey, values)
  for (field in names(derived)) {
    expect_identical(is.na(derived[[field]]), is.na(expected[[field]]),
      info = field
    )
    expect_equal(derived[[field]], as.numeric(expected[[field]]),
      tolerance = 1e-10, info = field
    )
  }
  expect_equal(
    build_btp_national_derived(survey[rev(seq_len(nrow(survey))), ], values),
    derived
  )
})

testthat::test_that("National preserves historical identities", {
  contract <- read_metadata("respondent_sources") |>
    dplyr::filter(.data$poll_id == "btp-national-2003")
  built <- build_poll_respondents(contract)
  testthat::expect_equal(nrow(built$people), 245L)
  testthat::expect_equal(
    built$people$historical_respondent_id,
    as.character(930001:930245)
  )
  sample <- built$sample_memberships |>
    dplyr::filter(.data$sample_id == "historical-polardata")
  testthat::expect_true(all(sample$included))
  testthat::expect_equal(nrow(built$respondent_memberships), 245L)
  testthat::expect_setequal(
    built$respondent_memberships$group_id, as.character(9301:9315)
  )
})
