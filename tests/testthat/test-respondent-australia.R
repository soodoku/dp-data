source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "respondent_australia.R"))

test_that("australia uses raw questions independently of row order", {
  survey <- read_poll_survey("australia-republic-1999")
  fields <- c(
    "moreind1", "stanwor1", "qbritin1", "moredem1", "quedem1",
    "brither1", "preserv1", "prespol1", "ppchpre1",
    "age",
    "anthem1",
    "anthem2",
    "busines1",
    "busines2",
    "confron1",
    "constrd1",
    "edulev",
    "firstop1",
    "firstop2",
    "firstop3",
    "flagchg1",
    "flagchg2",
    "gender",
    "ggrole1",
    "ggrole2",
    "headaus1",
    "headaus2",
    "income",
    "intpol1",
    "jgeorge1",
    "jgeorge2",
    "overseas",
    "pargame1",
    "pargame2",
    "pmpower1",
    "polstab1",
    "presrol1",
    "presrol2",
    "qrole1",
    "qrole2",
    "rempres1",
    "rempres2",
    "repexp1",
    "ridgewy1",
    "ridgewy2",
    "secop1",
    "secop2",
    "secop3",
    "stweak1",
    "tiesbr1",
    "tiesbr2",
    "wdroyal1",
    "wdroyal2",
    "welfare1",
    "welfare2"
  )
  raw <- survey[, match(tolower(fields), tolower(names(survey)))]
  built <- build_australia_individual(survey)
  expect_equal(build_australia_individual(raw), built)
  order <- rev(seq_len(nrow(raw)))
  expect_equal(build_australia_individual(raw[order, ]), built[order, ])
  raw[[match("income", tolower(names(raw)))]][1] <- 777
  expect_error(build_australia_individual(raw), "Unreviewed source codes")
  missing <- survey[, -match("income", tolower(names(survey)))]
  expect_error(build_australia_individual(missing), "Missing source field")
})

test_that("australia matches every historical respondent target", {
  survey <- read_poll_survey("australia-republic-1999")
  built <- build_australia_individual(survey)
  benchmark <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  benchmark <- benchmark[benchmark$dpnum == 5, ]
  group <- as.numeric(unclass(survey[[
    match("group", tolower(names(survey)))
  ]]))
  selected <- !is.na(group) & group != 100
  ids <- as.character(unclass(survey[[
    match("caseid", tolower(names(survey)))
  ]]))
  expect_equal(sum(selected), 347L)
  expect_setequal(ids[selected], as.character(benchmark$caseid))
  built <- built[match(as.character(benchmark$caseid), ids), ]
  mapping <- c(
    "readbrief" = "read_briefing",
    "t1know" = "knowledge_t1",
    "t1knowr" = "issue_knowledge",
    "t1knowcor" = "knowledge_joint",
    "t1knowrcor" = "issue_knowledge",
    "t2know" = "knowledge_t2",
    "t2knowr" = "issue_knowledge",
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
    "knowgainr" = "issue_knowledge",
    "knowgain2" = "knowledge_gain_joint",
    "knowgainr2" = "issue_knowledge",
    "logpk" = "log_knowledge_joint",
    "tobitpk" = "high_knowledge_joint",
    "aus.popparl1" = "popular_t1_midpoint_imputed",
    "aus.popparl2" = "popular_t2_midpoint_imputed",
    "aus.republican1" = "republican_t1_midpoint_imputed",
    "aus.republican2" = "republican_t2_midpoint_imputed"
  )
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "australia-republic-1999", "approved_values.csv"
  ), show_col_types = FALSE)
  for (field in names(mapping)) {
    expected <- as.numeric(benchmark[[field]])
    if (field %in% c("attextreme", "aus.popparl2", "ppage",
                     "aus.republican1", "aus.republican2")) {
      correction <- approved[approved$legacy_field == field, ]
      expected <- correction$approved_value[match(
        benchmark$caseid, correction$caseid
      )]
    }
    expect_equal(built[[mapping[[field]]]], expected, tolerance = 1e-10,
                 info = field)
  }
})

test_that("Australia age refusals stay missing without changing attendance", {
  survey <- read_poll_survey("australia-republic-1999")
  raw_age <- australia_source_codes(survey, "age", c(18:88, 98))
  group <- australia_source_codes(survey, "group", c(1:24, 100))
  ids <- as.numeric(unclass(survey[[
    match("caseid", tolower(names(survey)))
  ]]))
  refused <- !is.na(raw_age) & raw_age == 98
  selected <- !is.na(group) & group != 100
  built <- build_australia_individual(survey)

  expect_equal(sum(refused), 14L)
  expect_equal(sum(refused & selected), 3L)
  expect_setequal(ids[refused & selected], c(199, 648, 1226))
  expect_true(all(is.na(built$age[refused])))
  expect_equal(built$age[!refused], raw_age[!refused])
  expect_equal(sum(is.na(built$age)), sum(is.na(raw_age)) + 14L)
  expect_equal(sum(selected), 347L)
  expect_equal(sum(!is.na(built$age[selected])), 344L)

  contract <- read_metadata("respondent_sources")
  contract <- contract[contract$poll_id == "australia-republic-1999", ]
  tables <- build_poll_respondents(contract)
  memberships <- tables$sample_memberships
  included <- memberships$respondent_id[
    memberships$sample_id == "historical-polardata" & memberships$included
  ]
  expect_setequal(included, as.character(ids[selected]))
  expect_equal(australia_source_codes(survey, "age", c(18:88, 98)), raw_age)
})

test_that("Queen first survives an unanswered second choice", {
  for (wave in 1:2) {
    survey <- tibble::tibble(
      firstop = c(3, 3, 3, 3, 1, 97, NA),
      secop = c(1, 2, 97, if (wave == 1L) 100 else 99, 97, 97, NA),
      tiesbr = rep(NA_real_, 7), headaus = rep(NA_real_, 7)
    )
    names(survey) <- paste0(names(survey), wave)
    actual <- australia_ranking(survey, wave)
    expect_equal(actual$republican, c(0, 0, 0, 0, NA, NA, NA))
    expect_equal(actual$popular, c(.75, .25, NA, NA, NA, NA, NA))
    expect_equal(actual$republican_midpoint_imputed,
                 c(0, 0, 0, 0, .5, .5, NA))
    expect_equal(actual$popular_midpoint_imputed,
                 c(.75, .25, .5, NA, .5, .5, NA))
  }
})

test_that("Australia preserves observed components without ranking DK", {
  for (wave in 1:2) {
    survey <- tibble::tibble(
      firstop = c(97, 1, 3, NA_real_),
      secop = c(97, 97, 97, NA_real_),
      tiesbr = c(1, 1, 1, NA_real_),
      headaus = c(5, 5, 5, NA_real_)
    )
    names(survey) <- paste0(names(survey), wave)
    actual <- australia_ranking(survey, wave)
    expect_equal(actual$republican, c(1, 1, 2 / 3, NA_real_))
    expect_equal(actual$republican_midpoint_imputed,
                 c(5 / 6, 5 / 6, 2 / 3, NA_real_))
    expect_true(all(is.na(actual$popular)))
    expect_equal(actual$popular_midpoint_imputed,
                 c(.5, .5, .5, NA_real_))
  }
})

test_that("Australia ranking correction matches all source rows", {
  survey <- read_poll_survey("australia-republic-1999")
  actual <- build_australia_individual(survey)
  evidence <- readr::read_csv(project_path(
    "audit", "corrections", "australia-republic-1999",
    "ranking_source_values.csv"
  ), show_col_types = FALSE)
  changed_people <- numeric()
  for (wave in 1:2) {
    field <- paste0("aus.republican", wave)
    expected <- evidence[evidence$legacy_field == field, ]
    expect_identical(expected$source_row, as.numeric(survey$source_row))
    expect_equal(
      actual[[paste0("republican_t", wave, "_midpoint_imputed")]],
      expected$approved_value
    )
    expect_identical(
      is.na(expected$previous_value), is.na(expected$approved_value)
    )
    changed <- abs(expected$previous_value - expected$approved_value) > 1e-10
    expect_equal(sum(changed, na.rm = TRUE), c(36, 13)[wave])
    selected <- expected$historical_sample & !is.na(changed) & changed
    expect_equal(sum(selected), c(11, 13)[wave])
    expect_true(all(expected$first_preference[selected] == 3))
    changed_people <- union(changed_people, expected$caseid[selected])
  }
  expect_length(changed_people, 21)
})
