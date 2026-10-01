test_that("tomorrows-europe uses raw questions independently of row order", {
  survey <- read_poll_survey("tomorrows-europe-2007")
  inputs <- read_metadata("measure_inputs")
  contracts <- read_metadata("respondent_sources")
  identity <- contracts$id_column[contracts$poll_id == "tomorrows-europe-2007"]
  fields <- unique(c("source_row", identity, inputs$source_column[
    inputs$poll_id == "tomorrows-europe-2007"
  ]))
  positions <- match(tolower(fields), tolower(names(survey)))
  expect_false(anyNA(positions))
  raw <- survey[, positions]
  built <- build_tomorrow_individual(survey)
  expect_equal(build_tomorrow_individual(raw), built)
  expect_equal(build_tomorrow_individual(raw[, rev(seq_len(ncol(raw)))]),
    built
  )
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

    "hhincome" = "household_income",

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
  source_rows <- match(as.character(benchmark$caseid), ids)
  arrival_fields <- grep("^t2q[0-9]+[a-z]?(_[0-9]+)?$", names(survey),
    ignore.case = TRUE, value = TRUE
  )
  exit_fields <- grep("^t3q[0-9]+[a-z]?(_[0-9]+)?$", names(survey),
    ignore.case = TRUE, value = TRUE
  )
  arrival_missing <- rowSums(!is.na(survey[source_rows, arrival_fields])) == 0
  exit_missing <- rowSums(!is.na(survey[source_rows, exit_fields])) == 0
  expect_equal(length(arrival_fields), 142L)
  expect_equal(length(exit_fields), 185L)
  expect_setequal(benchmark$caseid[arrival_missing],
    c(3522, 3495, 2824, 148, 1130, 1143, 1157)
  )
  expect_setequal(benchmark$caseid[exit_missing],
    c(3522, 3495, 2824, 625, 516, 693, 374, 225, 148)
  )
  exit_dependent <- c("t1knowcor", "t1knowrcor", "t2know", "t2knowr",
    "knowgain", "knowgainr", "knowgain2", "knowgainr2", "logpk", "tobitpk"
  )
  both_dependent <- c("t1knowcor2", "t12knowcor")
  corrected <- c("ppage", "educ4", "educ3")
  for (field in setdiff(names(mapping), c(
    "eu.mil_att_11_12_t3", "eu.free_trade_index_t3", corrected
  ))) {
    expected <- as.numeric(benchmark[[field]])
    unavailable <- if (field %in% exit_dependent) {
      exit_missing
    } else if (field %in% both_dependent) {
      arrival_missing | exit_missing
    } else if (field == "t12know") {
      arrival_missing
    } else {
      rep(FALSE, nrow(benchmark))
    }
    expected[unavailable] <- NA_real_
    expect_equal(built[[mapping[[field]]]], expected,
      tolerance = 1e-10, info = field
    )
    if (any(unavailable)) {
      expect_true(all(is.na(built[[mapping[[field]]]][unavailable])),
        info = field
      )
    }
  }
  source_rows <- match(as.character(benchmark$caseid), ids)
  education_code <- as.numeric(unclass(survey$q39))[source_rows]
  source_age <- as.numeric(unclass(survey$age))[source_rows]
  expect_equal(built$age, source_age)
  expect_equal(sum(built$age != benchmark$ppage), 326L)
  expect_equal(sum(!is.na(built$education_four)), 343L)
  expect_equal(sum(education_code == 5L), 17L)
  expect_true(all(built$education_four[education_code == 5L] == 1))
  expect_true(all(built$education_three[education_code == 5L] == 1))

  approved <- readr::read_csv(project_path(
    "audit", "corrections", "tomorrows-europe-2007", "approved_values.csv"
  ), show_col_types = FALSE)
  expect_equal(nrow(approved), 344L * 11L)
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
