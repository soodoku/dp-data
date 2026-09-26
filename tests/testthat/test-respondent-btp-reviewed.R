source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "respondent_btp_general.R"))
source(file.path(root, "R", "respondent_btp_health.R"))
source(file.path(root, "R", "respondent_parity.R"))
source(file.path(root, "R", "respondent_san_mateo.R"))

test_that("BTP election rejects absent and ambiguous joins", {
  survey <- read_poll_survey("btp-general-election-2004")
  raw <- haven::read_dta(project_path(
    "data", "btp-general-election-2004",
    "raw-responses.dta"
  ))
  expected <- build_btp_general_individual(survey, raw)
  selected <- c(10L, 2L, 7L)
  expect_equal(
    build_btp_general_individual(survey[selected, ], raw),
    expected[selected, ]
  )
  expect_equal(
    build_btp_general_individual(survey, raw[rev(seq_len(nrow(raw))), ]),
    expected
  )
  raw_missing <- raw[raw$caseid != survey$caseid_original[1], ]
  expect_error(
    augment_btp_general_source(survey, raw_missing),
    "identity is missing"
  )
  expect_error(augment_btp_general_source(survey, rbind(raw, raw[1, ])))
  augmented <- augment_btp_general_source(survey, raw)
  fields <- c(
    "source_row", "caseid_original", "ppeducat", "ppincimp", "ppage",
    "ppgender", "ppeth", grep("^raw_", names(augmented), value = TRUE),
    paste0(
      rep(c("w4b", "w4f"), each = 9),
      rep(c(60, 61, 62, 63, 64, 65, 66, 68, 69), 2)
    )
  )
  expect_equal(build_btp_general_individual(augmented[, fields]), expected)
  augmented$raw_w4b42[1] <- 8
  expect_error(
    build_btp_general_individual(augmented),
    "Unreviewed source codes"
  )
})

test_that("Health uses raw responses independently of row order", {
  survey <- read_poll_survey("btp-health-education-2005")
  expected <- build_btp_health_individual(survey)
  fields <- c(
    grep("^q[0-9]", names(survey), value = TRUE),
    "birthyr", "gender", "race", "educ"
  )
  raw <- survey[, fields]
  expect_equal(build_btp_health_individual(raw), expected)
  selected <- c(454L, 17L, 1L)
  expect_equal(
    build_btp_health_individual(raw[selected, ]), expected[selected, ]
  )
  expect_error(
    build_btp_health_individual(raw[, names(raw) != "q8_f"]),
    "Missing source field: q8_f"
  )
  raw$q15[1] <- 99
  expect_error(
    build_btp_health_individual(raw),
    "Unreviewed source codes in q15"
  )
  expect_equal(
    btp_health_alpha(c(NA_real_, .1), c(NA_real_, .2)),
    c(NA_real_, as_historical_float(as_historical_float(.1 + .2) / 2))
  )
})

test_that("San Mateo uses raw responses and stable historical IDs", {
  survey <- read_poll_survey("san-mateo-2008")
  expected <- build_san_mateo_individual(survey)
  fields <- c(
    paste0(
      rep(c("", "t2"), each = 15),
      rep(paste0("Q", c(1:4, 7:9, 19:26)), 2)
    ),
    "Q128", "Q129", "Q131", "Q132", "Q135", "t2q37"
  )
  expect_equal(build_san_mateo_individual(survey[, fields]), expected)
  selected <- c(1806L, 1700L, 1L)
  expect_equal(
    build_san_mateo_individual(survey[selected, fields]),
    expected[selected, ]
  )
  ids <- san_mateo_historical_ids(survey, survey)
  expect_equal(
    san_mateo_historical_ids(survey[selected, ], survey),
    ids[selected]
  )
  expect_equal(sum(!is.na(ids)), 239L)
  expect_equal(sort(as.numeric(ids[!is.na(ids)])), 960001:960239)
  survey$Q1[1] <- 8
  expect_error(
    build_san_mateo_individual(survey),
    "Unreviewed source codes in Q1"
  )
})

test_that("Reviewed US polls reproduce historical values and missingness", {
  cases <- list(
    list(
      poll = "btp-general-election-2004", number = 15L,
      builder = build_btp_general_individual
    ),
    list(
      poll = "btp-health-education-2005", number = 18L,
      builder = build_btp_health_individual
    ),
    list(
      poll = "san-mateo-2008", number = 17L,
      builder = build_san_mateo_individual
    )
  )
  benchmark <- readr::read_tsv(
    project_path(
      "evidence", "benchmarks",
      "polardata.tab"
    ),
    show_col_types = FALSE
  )
  mapping <- c(
    t1know = "knowledge_t1", t2know = "knowledge_t2",
    t1knowcor = "knowledge_joint", knowgain = "knowledge_gain",
    knowgain2 = "knowledge_gain_joint", logpk = "log_knowledge_joint",
    tobitpk = "high_knowledge_joint", ppage = "age", female = "female",
    minority = "minority", educ4 = "education_four", educ3 = "education_three",
    bettered = "higher_education", hhincome = "household_income",
    highinc = "high_income", attextreme = "attitude_extremity",
    readbrief = "read_briefing"
  )
  for (case in cases) {
    survey <- read_poll_survey(case$poll)
    actual <- case$builder(survey)
    ids <- switch(case$poll,
      "btp-general-election-2004" = 940000 + survey$source_row,
      "btp-health-education-2005" = 970000 + survey$source_row,
      "san-mateo-2008" = as.numeric(san_mateo_historical_ids(survey, survey))
    )
    expected <- benchmark[benchmark$dpnum == case$number, ]
    if (case$poll == "btp-health-education-2005") {
      expected$female <- approved_reference_values(
        case$poll, "female", expected$caseid, expected$female
      )
    }
    index <- match(expected$caseid, ids)
    expect_false(anyNA(index))
    for (field in names(mapping)) {
      value <- actual[[mapping[[field]]]][index]
      expect_identical(is.na(value), is.na(expected[[field]]), info = field)
      expect_equal(value, as.numeric(expected[[field]]),
        tolerance = 1e-10,
        info = field
      )
    }
  }
})
