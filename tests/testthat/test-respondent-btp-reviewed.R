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
    "source_row", "caseid_original", "w4comsta", "ppeducat", "ppincimp",
    "ppage", "ppgender", "ppeth", grep("^raw_", names(augmented), value = TRUE),
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

test_that("BTP election distinguishes absent waves from wrong answers", {
  survey <- read_poll_survey("btp-general-election-2004")
  values <- build_btp_general_individual(survey)
  before_absent <- survey$w4comsta == 3
  after_absent <- survey$w4comsta == 2
  expect_equal(sum(before_absent), 13L)
  expect_equal(sum(after_absent), 33L)
  expect_true(all(is.na(btp_general_knowledge(survey, "b")[before_absent, ])))
  expect_true(all(is.na(btp_general_knowledge(survey, "f")[after_absent, ])))
  expect_identical(is.na(values$knowledge_t1), before_absent)
  expect_identical(is.na(values$knowledge_t2), after_absent)
  for (field in c(
    "knowledge_joint", "knowledge_gain", "knowledge_gain_joint",
    "log_knowledge_joint", "high_knowledge_joint"
  )) {
    expect_true(all(is.na(values[[field]][before_absent | after_absent])),
      info = field
    )
  }
  observed <- which(survey$w4comsta == 1)[1]
  missing_item <- survey[observed, ]
  missing_item$w4b60 <- NA_real_
  expect_equal(unname(btp_general_knowledge(missing_item, "b")[1, "60"]), 0)
  missing_item$w4comsta <- 4
  expect_error(btp_general_knowledge(missing_item, "b"),
    "Unreviewed source codes in w4comsta"
  )
  without_status <- survey[, names(survey) != "w4comsta"]
  expect_error(btp_general_knowledge(without_status, "b"),
    "Missing source field: w4comsta"
  )
  raw <- haven::read_dta(project_path(
    "data", "btp-general-election-2004", "raw-responses.dta"
  ))
  expect_true(all(is.na(btp_general_knowledge(raw, "b")[
    is.na(raw$w4comsta),
  ])))
  absent <- missing_item
  absent$w4comsta <- -3
  expect_error(btp_general_knowledge(absent, "b"),
    "completion status contradicts observed wave responses"
  )
  absent[grep("^w4b[0-9]", names(absent), value = TRUE)] <- NA_real_
  expect_true(all(is.na(btp_general_knowledge(absent, "b"))))
  for (code in c(-4, -3)) {
    absent$w4comsta <- code
    absent[grep("^w4[bf][0-9]", names(absent), value = TRUE)] <- code
    expect_true(all(is.na(btp_general_knowledge(absent, "b"))))
    expect_true(all(is.na(btp_general_knowledge(absent, "f"))))
  }
  for (code in c(-2, -1)) {
    absent$w4b60 <- code
    expect_error(btp_general_knowledge(absent, "b"),
      "completion status contradicts observed wave responses"
    )
  }
})

test_that("BTPGE-05 includes observed zero-correct post respondents", {
  survey <- read_poll_survey("btp-general-election-2004")
  contracts <- read_metadata("respondent_sources")
  contract <- contracts[contracts$poll_id == "btp-general-election-2004", ]
  built <- build_poll_respondents(contract)
  sample <- built$sample_memberships
  sample <- sample[sample$sample_id == "historical-polardata", ]
  expect_equal(sum(sample$included), 248L)
  approved <- btp_ge_approved_inclusions()
  expect_setequal(approved$respondent_id, c(552, 585))
  rows <- match(approved$respondent_id, survey$caseid_original)
  expect_equal(survey$source_row[rows], approved$source_row)
  expect_equal(as.numeric(survey$dop4part[rows]), c(1, 1))
  post_items <- paste0("w4f", c(60, 61, 62, 63, 64, 65, 66, 68, 69))
  expect_equal(rowSums(!is.na(survey[rows, post_items])), c(9, 9))
  expect_equal(sum(rowSums(!is.na(survey[post_items])) == 0L), 33L)
  values <- build_btp_general_individual(survey)
  expect_equal(values$knowledge_t2[rows], c(0, 0))
  expect_false(anyNA(values$attitude_extremity[rows]))
  expect_true(all(sample$included[
    match(as.character(approved$respondent_id), sample$respondent_id)
  ]))
})

test_that("Health achievement-gap knowledge keys decreasing in both waves", {
  fields <- paste0("q", c(15, 16, 17, 26, 27, 28))
  survey <- tibble::as_tibble(stats::setNames(
    rep(list(rep(7, 5)), 12), c(fields, paste0(fields, "post"))
  ))
  survey$q17 <- c(1, 2, 3, 7, NA_real_)
  survey$q17post <- c(3, 2, 1, 7, NA_real_)
  before <- btp_health_knowledge(survey, 1L)
  after <- btp_health_knowledge(survey, 2L)
  expect_equal(unname(before[, "q17"]), c(0, 0, 1, 0, 0))
  expect_equal(unname(after[, "q17"]), c(1, 0, 0, 0, 0))
  scores <- btp_float_knowledge(before, after)
  expect_equal(scores$knowledge_t1, as_historical_float(c(0, 0, 1 / 6, 0, 0)))
  expect_equal(scores$knowledge_t2, as_historical_float(c(1 / 6, 0, 0, 0, 0)))
  expect_equal(scores$knowledge_joint, rep(0, 5))
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
  contract <- questionnaire_form_contract("san-mateo-2008")
  fields <- unique(c(
    fields, unlist(contract$fields), unlist(contract$auxiliary), "source_row"
  ))
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
    hhincome = "household_income",
    attextreme = "attitude_extremity",
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
    for (field in names(mapping)) {
      expected[[field]] <- approved_reference_values(
        case$poll, field, expected$caseid, expected[[field]]
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
