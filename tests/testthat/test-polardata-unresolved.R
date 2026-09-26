source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "respondent_parity.R"))
for (name in c(
  "respondent_new_haven", "respondent_btp_primaries",
  "respondent_zeguo", "polardata_derived", "polardata_assembly",
  "polardata_core", "polardata_btp_reviewed", "polardata_unresolved"
)) {
  source(file.path(root, "R", paste0(name, ".R")))
}

unresolved_test_fields <- function(poll) {
  fields <- c(
    ppage = "age", female = "female", minority = "minority",
    educ4 = "education_four", educ3 = "education_three",
    bettered = "higher_education", hhincome = "household_income",
    highinc = "high_income", t1polint = "political_interest_t1",
    attextreme = "attitude_extremity", readbrief = "read_briefing",
    t1know = "knowledge_t1", t1knowr = "knowledge_t1",
    t2know = "knowledge_t2", t2knowr = "knowledge_t2",
    t1knowcor = "knowledge_joint", t1knowrcor = "knowledge_joint",
    knowgain = "knowledge_gain", knowgainr = "knowledge_gain",
    knowgain2 = "knowledge_gain_joint", knowgainr2 = "knowledge_gain_joint",
    logpk = "log_knowledge_joint", tobitpk = "high_knowledge_joint",
    t12know = "knowledge_midterm", t12knowcor = "knowledge_midterm_joint",
    t1knowcor2 = "knowledge_joint_midterm",
    attextreme2 = "attitude_extremity_midterm"
  )
  attitude <- switch(poll,
    new_haven = c(
      endexp = "airport_expansion", manvol = "mandatory_sharing",
      volloc = "voluntary_sharing"
    ),
    btp_primaries = c(
      trade = "trade", mindex = "multilateralism",
      services = "services"
    ),
    zeguo = stats::setNames(c(
      "industrial_roads", "village_roads", "main_roads",
      "commercial_roads", "main_roads_rescaled", "other_parks",
      "township_image", "cultural_heritage", "sewage"
    ), paste0("att", 1:9))
  )
  prefix <- switch(poll,
    new_haven = "nh",
    btp_primaries = "btp04pr",
    zeguo = "chi"
  )
  for (wave in 1:2) {
    fields <- c(fields, stats::setNames(
      paste0(attitude, "_t", wave),
      paste0(prefix, ".t", wave, names(attitude))
    ))
  }
  fields
}

test_that("resolved polls reproduce historical fields", {
  path <- project_path("evidence", "benchmarks", "polardata.tab")
  reference <- readr::read_tsv(path, show_col_types = FALSE)
  for (poll in c("new_haven", "btp_primaries", "zeguo")) {
    id <- switch(poll,
      new_haven = "new-haven-2004",
      btp_primaries = "btp-presidential-primaries-2004",
      zeguo = "zeguo-2005"
    )
    dpnum <- switch(poll,
      new_haven = 12,
      btp_primaries = 16,
      zeguo = 9
    )
    survey <- arrow::read_parquet(project_path("data", id, "survey.parquet"))
    selected <- switch(poll,
      new_haven = rep(TRUE, nrow(survey)),
      btp_primaries = primaries_sample(survey),
      zeguo = !is.na(survey$groupnum) & !is.na(survey$preandpost)
    )
    caseid <- switch(poll,
      new_haven = {
        bridge_path <- project_path("data", id, "historical-ids.csv")
        bridge <- readr::read_csv(bridge_path,
          show_col_types = FALSE
        )
        bridge$historical_caseid[match(survey$assigned, bridge$assigned)]
      },
      btp_primaries = 950000 + survey$source_row,
      zeguo = 52000 + survey$p
    )
    expected <- reference[reference$dpnum == dpnum, ]
    expected <- expected[!duplicated(expected$caseid), ]
    expect_setequal(caseid[selected], expected$caseid)
    expected <- expected[match(caseid[selected], expected$caseid), ]
    if (poll %in% c("new_haven", "zeguo", "btp_primaries")) {
      corrected <- switch(poll,
        new_haven = c("minority", "pminority"),
        zeguo = c("chi.t1att2", "chi.t2att3", "attextreme",
                  "meanxtreme", "avgsd", "genvar", "ppage", "meanage"),
        btp_primaries = c(
          "grpgain", "grpgainr", "loggain", "groupsize", "vareduc",
          "sdeduc", "pfemale_ind", "meant1know_ind",
          "meant1knowcor_ind"
        )
      )
      for (field in corrected) {
        expected[[field]] <- approved_reference_values(
          id, field, expected$caseid, expected[[field]]
        )
      }
    }
    individual <- get(paste0("build_", poll, "_individual"))(survey)
    fields <- unresolved_test_fields(poll)
    values <- tibble::as_tibble(purrr::map(fields, \(name) {
      individual[[name]][selected]
    }))
    for (field in names(fields)) {
      expect_equal(values[[field]], as.numeric(expected[[field]]),
        tolerance = 1e-10,
        info = paste(poll, field)
      )
    }
    values$source_row <- survey$source_row[selected]
    derived <- get(paste0("build_", poll, "_derived"))(survey, values)
    compare <- names(derived)
    if (poll == "zeguo") compare <- setdiff(compare, "genvar")
    for (field in compare) {
      expect_equal(derived[[field]], expected[[field]],
        tolerance = 1e-10,
        info = paste(poll, field)
      )
    }
    order <- rev(seq_len(nrow(survey)))
    builder <- get(paste0("build_", poll, "_derived"))
    reordered <- builder(survey[order, ], values)
    expect_equal(reordered, derived, tolerance = 1e-10)
  }
})
