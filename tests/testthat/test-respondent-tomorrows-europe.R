source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "respondent_tomorrows_europe.R"))

test_that("tomorrows-europe uses raw questions independently of row order", {
  survey <- read_poll_survey("tomorrows-europe-2007")
  fields <- c(
    "q11a_1",
    "q11b_1",
    "q11c_1",
    "q12a_1",
    "q12b_1",
    "q12c_1",
    "q12d_1",
    "q13b_1",
    "q15a_1",
    "q15b_1",
    "q15c_1",
    "q15d_1",
    "q16_1",
    "q17_1",
    "q18_1",
    "q19_1",
    "q1_1",
    "q20_1",
    "q21_1",
    "q22_1",
    "q23_1",
    "q24_1",
    "q33a_1",
    "q33b_1",
    "q35",
    "q36",
    "q39",
    "q4_1",
    "q7c_1",
    "t2q1",
    "t2q11a",
    "t2q11b",
    "t2q11c",
    "t2q12a",
    "t2q12b",
    "t2q12c",
    "t2q12d",
    "t2q16a",
    "t2q16b",
    "t2q16c",
    "t2q16f",
    "t2q16j",
    "t2q17a",
    "t2q17b",
    "t2q17c",
    "t2q17d",
    "t2q17e",
    "t2q17f",
    "t2q17g",
    "t2q17h",
    "t2q17i",
    "t2q18a",
    "t2q18b",
    "t2q18c",
    "t2q18d",
    "t2q19",
    "t2q20",
    "t2q21",
    "t2q22",
    "t2q23",
    "t2q24",
    "t2q25",
    "t2q26",
    "t2q27",
    "t2q36a",
    "t2q36b",
    "t2q4",
    "t2q5a",
    "t2q5b",
    "t2q5c",
    "t2q5d",
    "t2q7a",
    "t2q7c",
    "t2q7d",
    "t2q8",
    "t3q1",
    "t3q11a",
    "t3q11b",
    "t3q11c",
    "t3q12a",
    "t3q12b",
    "t3q12c",
    "t3q12d",
    "t3q16a",
    "t3q16b",
    "t3q16c",
    "t3q16f",
    "t3q16j",
    "t3q17a",
    "t3q17b",
    "t3q17c",
    "t3q17d",
    "t3q17e",
    "t3q17f",
    "t3q17g",
    "t3q17h",
    "t3q17i",
    "t3q18a",
    "t3q18b",
    "t3q18c",
    "t3q18d",
    "t3q19",
    "t3q20",
    "t3q21",
    "t3q22",
    "t3q23",
    "t3q24",
    "t3q25",
    "t3q26",
    "t3q27",
    "t3q36a",
    "t3q36b",
    "t3q4",
    "t3q42",
    "t3q5a",
    "t3q5b",
    "t3q5c",
    "t3q5d",
    "t3q7a",
    "t3q7c",
    "t3q7d",
    "t3q8"
  )
  raw <- survey[, match(tolower(fields), tolower(names(survey)))]
  built <- build_tomorrow_individual(survey)
  expect_equal(build_tomorrow_individual(raw), built)
  order <- rev(seq_len(nrow(raw)))
  expect_equal(build_tomorrow_individual(raw[order, ]), built[order, ])
  raw[[match("q35", tolower(names(raw)))]][1] <- 777
  expect_error(build_tomorrow_individual(raw), "Unreviewed source codes")
  missing <- survey[, -match("q35", tolower(names(survey)))]
  expect_error(build_tomorrow_individual(missing), "Missing source field")
})

test_that("tomorrows-europe matches every historical respondent target", {
  survey <- read_poll_survey("tomorrows-europe-2007")
  built <- build_tomorrow_individual(survey)
  benchmark <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  benchmark <- benchmark[benchmark$dpnum == 7, ]
  group <- as.numeric(unclass(survey[[
    match("group_no", tolower(names(survey)))
  ]]))
  selected <- !is.na(group)
  ids <- as.character(unclass(survey[[
    match("v_b", tolower(names(survey)))
  ]]))
  expect_equal(sum(selected), 344L)
  expect_setequal(ids[selected], as.character(benchmark$caseid))
  built <- built[match(as.character(benchmark$caseid), ids), ]
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
    "eu.support_eu_membership_t1" = "eu_membership_t1",
    "eu.att_towards_privatization_t1" = "privatization_t1",
    "eu.attitude_towards_migration_t1" = "migration_t1",
    "eu.mil_att_11_12_t1" = "military_t1",
    "eu.turkey_enlargement_att_t1" = "turkey_t1",
    "eu.eu_veto_support_t1" = "veto_t1",
    "eu.t1q11b" = "military_never_t1",
    "eu.support_eu_membership_t2" = "eu_membership_t2",
    "eu.att_towards_privatization_t2" = "privatization_t2",
    "eu.attitude_towards_migration_t2" = "migration_t2",
    "eu.mil_att_11_12_t2" = "military_t2",
    "eu.turkey_enlargement_att_t2" = "turkey_t2",
    "eu.eu_veto_support_t2" = "veto_t2",
    "eu.pay_for_pension_1_t2_r" = "pension_t2",
    "eu.free_trade_index_t2" = "trade_t2",
    "eu.general_enlargement_att_f_t2" = "enlargement_t2",
    "eu.eu_level_decision_making_t2" = "decision_level_t2",
    "eu.t2q11br" = "military_never_t2",
    "eu.t2q16jr" = "enlargement_limit_t2",
    "eu.support_eu_membership_t3" = "eu_membership_t3",
    "eu.att_towards_privatization_t3" = "privatization_t3",
    "eu.attitude_towards_migration_t3" = "migration_t3",
    "eu.mil_att_11_12_t3" = "military_t3",
    "eu.turkey_enlargement_att_t3" = "turkey_t3",
    "eu.eu_veto_support_t3" = "veto_t3",
    "eu.pay_for_pension_1_t3_r" = "pension_t3",
    "eu.free_trade_index_t3" = "trade_t3",
    "eu.general_enlargement_att_f_t3" = "enlargement_t3",
    "eu.eu_level_decision_making_t3" = "decision_level_t3",
    "eu.t3q11br" = "military_never_t3",
    "eu.t3q16jr" = "enlargement_limit_t3"
  )
  for (field in setdiff(names(mapping), c(
    "eu.mil_att_11_12_t3", "eu.free_trade_index_t3"
  ))) {
    expect_equal(
      built[[mapping[[field]]]], as.numeric(benchmark[[field]]),
      tolerance = 1e-10
    )
  }
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "tomorrows-europe-2007", "approved_values.csv"
  ), show_col_types = FALSE)
  expect_equal(nrow(approved), 344L * 2L)
  for (field in c("eu.mil_att_11_12_t3", "eu.free_trade_index_t3")) {
    evidence <- approved[approved$legacy_field == field, ]
    position <- match(benchmark$caseid, evidence$caseid)
    expect_false(anyNA(position))
    expect_equal(as.numeric(benchmark[[field]]),
                 evidence$historical_value[position], tolerance = 1e-10)
    expect_equal(built[[mapping[[field]]]],
                 evidence$approved_value[position], tolerance = 1e-10)
  }
})
