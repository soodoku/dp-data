source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "respondent_nic2.R"))
source(file.path(root, "R", "polardata_derived.R"))
source(file.path(root, "R", "polardata_assembly.R"))
source(file.path(root, "R", "polardata_nic2.R"))

test_that("NIC2 uses raw questions and stable identities", {
  survey <- haven::read_dta(project_path("data", "nic2-2003", "survey.dta"))
  fields <- c(
    "aid1",
    "aid2a_b",
    "aid2a_c",
    "aid2b_a",
    "aid2b_b",
    "aid3",
    "educ_a",
    "educ_b",
    "eval5",
    "fp2a_a",
    "fp2b_a",
    "fp2b_c",
    "fp2b_d",
    "fp2c_a",
    "fp2c_b",
    "fp2c_d",
    "fp3a_s",
    "fp4a_a",
    "fp4b_b",
    "int1a_a",
    "int1a_b",
    "int1b_c",
    "int1b_d",
    "int2a",
    "int2b",
    "isum",
    "kno1_a",
    "kno1_b",
    "kno2_a",
    "kno2_b",
    "kno3_a",
    "kno3_b",
    "mact1_s",
    "mact2_s",
    "mact4_s",
    "mact5_s",
    "pair1_a",
    "pair1_b",
    "pair2_a",
    "pair2_b",
    "pair3_a",
    "pair3_b",
    "pdem1_a",
    "pdem1_b",
    "pdem1_c",
    "pdem2_a",
    "pdem2_b",
    "pdem2_c",
    "pint_b",
    "ppage",
    "qaid1",
    "qaid2a_b",
    "qaid2a_c",
    "qaid2b_a",
    "qaid2b_b",
    "qaid3",
    "qfp2a_a",
    "qfp2b_a",
    "qfp2b_c",
    "qfp2b_d",
    "qfp2c_a",
    "qfp2c_b",
    "qfp2c_d",
    "qfp3a_s",
    "qfp4a_a",
    "qfp4b_b",
    "qint1a_a",
    "qint1a_b",
    "qint1b_c",
    "qint1b_d",
    "qint2a",
    "qint2b",
    "qkno1_a",
    "qkno1_b",
    "qkno2_a",
    "qkno2_b",
    "qkno3_a",
    "qkno3_b",
    "qmact1_s",
    "qmact2_s",
    "qmact4_s",
    "qmact5_s",
    "qpair1_a",
    "qpair1_b",
    "qpair2_a",
    "qpair2_b",
    "qpair3_a",
    "qpair3_b",
    "qpdem1_a",
    "qpdem1_b",
    "qpdem1_c",
    "qpdem2_a",
    "qpdem2_b",
    "qpdem2_c",
    "qtrd1_a",
    "qtrd2",
    "qwrm1_b",
    "qwrm2a_s",
    "qwrm2b_s",
    "qwrm3_a",
    "qwrm3_b",
    "qwrm3_c",
    "qwrm4a_s",
    "qwrm5",
    "race",
    "sex",
    "trd1_a",
    "trd2",
    "wrm1_b",
    "wrm2a_s",
    "wrm2b_s",
    "wrm3_a",
    "wrm3_b",
    "wrm3_c",
    "wrm4a_s",
    "wrm5"
  )
  raw <- survey[, fields]
  built <- build_nic2_individual(raw)
  expect_equal(built, build_nic2_individual(survey))
  order <- rev(seq_len(nrow(raw)))
  expect_equal(build_nic2_individual(raw[order, ]), built[order, ])
  raw$sex[1] <- 2
  expect_error(build_nic2_individual(raw), "Unreviewed source codes in sex")
  expect_error(build_nic2_individual(survey[, names(survey) != "fp2a_a"]),
    "Missing source field: fp2a_a"
  )
})

test_that("NIC2 matches all historical respondent and aggregate values", {
  survey <- haven::read_dta(project_path("data", "nic2-2003", "survey.dta"))
  survey$source_row <- seq_len(nrow(survey))
  bridge <- readr::read_csv(
    project_path("data", "nic2-2003", "historical-ids.csv"),
    show_col_types = FALSE
  )
  expect_equal(nrow(bridge), 340L)
  expect_false(anyDuplicated(bridge$nicid) > 0)
  expect_setequal(bridge$nicid, as.numeric(survey$nicid[survey$casetype == 1]))
  rows <- match(bridge$nicid, as.numeric(survey$nicid))
  expect_equal(bridge$source_caseid, as.numeric(survey$caseid[rows]))
  built <- build_nic2_individual(survey)[rows, ]
  mapping <- c(
    "readbrief" = "read_briefing",
    "t1know" = "knowledge_t1",
    "t1knowr" = "knowledge_t1",
    "t1knowcor" = "knowledge_joint",
    "t1knowrcor" = "knowledge_joint",
    "t2know" = "knowledge_t2",
    "t2knowr" = "knowledge_t2",
    "ppage" = "age",
    "female" = "female",
    "minority" = "minority",
    "educ4" = "education_four",
    "educ3" = "education_three",
    "bettered" = "higher_education",
    "hhincome" = "household_income",
    "highinc" = "high_income",
    "t1polint" = "political_interest_t1",
    "attextreme" = "attitude_extremity",
    "attextreme2" = "attitude_extremity_midterm",
    "t1knowcor2" = "knowledge_joint_midterm",
    "t12know" = "knowledge_midterm",
    "t12knowcor" = "knowledge_midterm_joint",
    "knowgain" = "knowledge_gain",
    "knowgainr" = "knowledge_gain",
    "knowgain2" = "knowledge_gain_joint",
    "knowgainr2" = "knowledge_gain_joint",
    "logpk" = "log_knowledge_joint",
    "tobitpk" = "high_knowledge_joint",
    "nic2.t1envir" = "environment_t1",
    "nic2.t1usseca" = "security_t1",
    "nic2.t1humrh2" = "human_rights_t1",
    "nic2.t1demo" = "democracy_t1",
    "nic2.t1multi" = "multilateralism_t1",
    "nic2.t1inter" = "internationalism_t1",
    "nic2.t1forai1" = "foreign_aid_t1",
    "nic2.t1global" = "global_altruism_t1",
    "nic2.t1trade_b" = "trade_t1",
    "nic2.t2envir" = "environment_t2",
    "nic2.t2usseca" = "security_t2",
    "nic2.t2humrh2" = "human_rights_t2",
    "nic2.t2demo" = "democracy_t2",
    "nic2.t2multi" = "multilateralism_t2",
    "nic2.t2inter" = "internationalism_t2",
    "nic2.t2forai1" = "foreign_aid_t2",
    "nic2.t2global" = "global_altruism_t2",
    "nic2.t2trade_b" = "trade_t2"
  )
  values <- tibble::tibble(source_row = survey$source_row[rows])
  reference <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  reference <- reference[reference$dpnum == 13, ]
  reference <- reference[match(bridge$historical_caseid, reference$caseid), ]
  for (field in names(mapping)) {
    values[[field]] <- built[[mapping[[field]]]]
    expect_equal(values[[field]], as.numeric(reference[[field]]),
      tolerance = 1e-10, info = field
    )
  }
  result <- build_nic2_derived(survey, values)
  for (field in names(result)) {
    expect_equal(result[[field]], as.numeric(reference[[field]]),
      tolerance = 1e-10, info = field
    )
  }
  order <- rev(seq_len(nrow(survey)))
  expect_equal(build_nic2_derived(survey[order, ], values), result)
  order <- rev(seq_len(nrow(values)))
  expect_equal(build_nic2_derived(survey, values[order, ]), result[order, ])
})

test_that("NIC2 identity inference rejects ambiguous or unmatched features", {
  fields <- c("ppage", "qnews1_a", "qnews1_b", "qnews2_a", "qnews2_b",
    "eval7c", "eval7d"
  )
  survey <- tibble::tibble(casetype = c(1, 1), group = c(1, 1),
    nicid = c(101, 102), caseid = c(120, 125)
  )
  for (field in fields) survey[[field]] <- c(2, 3)
  historical <- survey
  historical$pollgroup <- 9201
  historical$caseid <- c(920002, 920001)
  result <- nic2_identity_bridge(survey, historical)
  expect_equal(result$historical_caseid, c(920002, 920001))
  historical$ppage[1] <- 500
  expect_error(nic2_identity_bridge(survey, historical))
  expect_error(nic2_identity_bridge(survey[c(1, 1), ], historical))
})
