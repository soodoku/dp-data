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
    "knowgainr" = "issue_knowledge",
    "knowgain2" = "knowledge_gain_joint",
    "knowgainr2" = "issue_knowledge",
    "logpk" = "log_knowledge_joint",
    "tobitpk" = "high_knowledge_joint",
    "aus.popparl1" = "popular_t1",
    "aus.popparl2" = "popular_t2",
    "aus.republican1" = "republican_t1",
    "aus.republican2" = "republican_t2"
  )
  for (field in names(mapping)) {
    expect_equal(
      built[[mapping[[field]]]], as.numeric(benchmark[[field]]),
      tolerance = 1e-10
    )
  }
})
