source(file.path(root, "R", "polardata.R"))

health_reference <- function() {
  readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
}

test_that("Bulgaria attitude catalog names match the source questions", {
  indices <- arrow::read_parquet(project_path(
    "output", "polardata", "attitude-indices.parquet"
  ))
  fields <- paste0("bulgaria.bulgaria.t1", c(
    "q10_3", "q16", "q21", "q22", "q23", "q19"
  ))
  labels <- indices$att_index[match(fields, indices$t1var)]
  expect_equal(labels, c(
    "Penalties for Drug Taking", "Allowing Vigilantism",
    "Institutional Change", "Independence of Investigation Service",
    "Place of Prosecution", "Death Penalty"
  ))
})

test_that("NIC2 attitude catalog names match the final source indices", {
  indices <- arrow::read_parquet(project_path(
    "output", "polardata", "attitude-indices.parquet"
  ))
  fields <- paste0("nic2.t1", c(
    "humrh2", "multi", "inter", "global", "demo", "forai1"
  ))
  labels <- indices$att_index[match(fields, indices$t1var)]
  expect_equal(labels, c(
    "Human Rights", "Multilateralism", "Internationalism",
    "Fighting Poverty and Suffering", "Promoting Democracy",
    "Increasing Foreign Aid"
  ))
})

test_that("BTP National attitude catalog separates security and poverty", {
  indices <- arrow::read_parquet(project_path(
    "output", "polardata", "attitude-indices.parquet"
  ))
  fields <- paste0("btp03.olt1", c("usseca", "global"))
  labels <- indices$att_index[match(fields, indices$t1var)]
  expect_equal(labels, c(
    "Fighting Terrorism", "Fighting Poverty and Suffering"
  ))
})

test_that("NIC 1996 catalog names the nine spending questions", {
  indices <- arrow::read_parquet(project_path(
    "output", "polardata", "attitude-indices.parquet"
  ))
  fields <- paste0("nic1.t1att", 1:9)
  labels <- indices$att_index[match(fields, indices$t1var)]
  expect_equal(labels, paste("Spending on", c(
    "Environment", "Medicare/Medicaid", "Law Enforcement",
    "Drug Rehabilitation", "Education and Training", "National Defense",
    "Foreign Aid", "Welfare", "Social Security"
  )))
})

test_that("Monarchy public index is not labeled as royal powers", {
  indices <- arrow::read_parquet(project_path(
    "output", "polardata", "attitude-indices.parquet"
  ))
  label <- indices$att_index[
    indices$t1var == "ukmonarchy.t1mpop"
  ]
  expect_equal(label, "Royal Family and the Public")
})

test_that("UK Health raw answers reproduce all 71 reconstructed fields", {
  rebuilt <- build_health_polardata()
  parity <- compare_health_polardata(rebuilt, health_reference())
  expect_equal(dim(rebuilt), c(230L, 73L))
  expect_equal(nrow(parity), 71L)
  expect_true(all(parity$missingness_differences == 0L))
  expect_true(all(parity$value_differences == 0L))
  path <- tempfile(fileext = ".parquet")
  withr::defer(unlink(path))
  arrow::write_parquet(rebuilt, path)
  expect_identical(arrow::read_parquet(path), rebuilt)
})

test_that("stored indices cannot supply the reconstruction", {
  survey <- read_poll_survey("uk-health-1998")
  expected <- build_health_polardata(survey)
  derived <- grep("^(t[12]|hknow|answer)", names(survey), value = TRUE)
  expect_gt(length(derived), 0L)
  survey[derived] <- NULL
  expect_identical(build_health_polardata(survey), expected)
})

test_that("Health ordered responses preserve missingness", {
  expect_equal(
    historical_health_response(c(1, 2, 3, -9, -8, NA), 3L),
    c(0, 0.5, 1, NA, NA, NA)
  )
  expect_equal(
    historical_available_mean(rbind(c(NA, 0.5), c(NA, NA))),
    c(0.5, NA)
  )
  expect_error(historical_health_response(999, 5L), "Unreviewed")
  expect_error(historical_health_response(-1, 5L), "Unreviewed")
})

test_that("parity uses IDs and rejects loss, duplication, or changed values", {
  rebuilt <- build_health_polardata()
  benchmark <- health_reference()
  expect_silent(compare_health_polardata(rebuilt[230:1, ], benchmark))
  duplicate <- rebuilt
  duplicate$caseid[1] <- duplicate$caseid[2]
  expect_error(compare_health_polardata(duplicate, benchmark))
  expect_error(compare_health_polardata(rebuilt[-1, ], benchmark))
  field <- "ukhealth.t1payhlt"
  row <- which(!is.na(rebuilt[[field]]))[1]
  changed <- rebuilt
  changed[[field]][row] <- changed[[field]][row] + 0.01
  expect_error(compare_health_polardata(changed, benchmark), "differs")
  changed[[field]][row] <- NA_real_
  expect_error(compare_health_polardata(changed, benchmark), "differs")
})

test_that("unreviewed survey codes stop the build", {
  survey <- read_poll_survey("uk-health-1998")
  survey$payhlth1 <- as.numeric(survey$payhlth1)
  survey$payhlth1[1] <- 999
  expect_error(build_health_polardata(survey), "Unreviewed")
  survey <- read_poll_survey("uk-health-1998")
  survey$group <- rep(999, nrow(survey))
  expect_error(build_health_polardata(survey), "Unreviewed UK Health group")
})


test_that("group summaries use the final individual definitions", {
  rebuilt <- build_health_polardata()
  final_share <- ave(as.numeric(rebuilt$highinc), rebuilt$pollgroup,
    FUN = function(x) mean(x, na.rm = TRUE)
  )
  expect_equal(final_share, rebuilt$phighinc)
  final_attitudes <- as.matrix(
    rebuilt[grep("^ukhealth[.]t1", names(rebuilt))]
  )
  recalculated <- historical_available_mean(abs(final_attitudes - .5))
  expect_equal(recalculated, rebuilt$attextreme)
  expect_equal(rebuilt$meanxtreme, ave(
    recalculated, rebuilt$pollgroup, FUN = function(x) mean(x, na.rm = TRUE)
  ))
  expected_sd <- ave(seq_len(nrow(rebuilt)), rebuilt$pollgroup,
    FUN = function(rows) {
      mean(apply(final_attitudes[rows, ], 2, sd, na.rm = TRUE))
    }
  )
  expect_equal(rebuilt$avgsd, expected_sd)
  incomplete <- rebuilt
  incomplete$educ4 <- NULL
  expect_error(compare_health_polardata(incomplete, health_reference()))
  changed <- rebuilt
  changed$educ4[1] <- .123
  expect_error(compare_health_polardata(changed, health_reference()), "differs")
})


test_that("raw knowledge keys preserve scores in returned questionnaires", {
  survey <- read_poll_survey("uk-health-1998")
  for (wave in 1:2) {
    scores <- historical_health_items(survey, wave)
    stored <- vapply(letters[1:6], function(item) {
      value <- as.numeric(survey[[paste0("answer", item, wave)]])
      value[is.na(value)] <- 0
      value
    }, numeric(nrow(survey)))
    if (wave == 2L) {
      absent <- as.numeric(survey$manwkend) == 0
      expect_setequal(as.numeric(survey$serial_m[absent]), c(3809, 4307))
      post_fields <- paste0("soph", letters[1:6], "2")
      expect_true(all(is.na(as.matrix(survey[absent, post_fields]))))
      expect_true(all(stored[absent, ] == 0))
      stored[absent, ] <- NA_real_
    }
    expect_identical(scores, stored)
  }
  before <- rowMeans(historical_health_items(survey, 1L))
  expect_identical(
    historical_health_precision(before), as.numeric(survey$hknow1)
  )
  survey$sopha1 <- rep(999, nrow(survey))
  expect_error(historical_health_items(survey, 1L), "Unreviewed")
})

test_that("group gain conditions on unknown items and excludes self", {
  corrected <- rbind(c(1, 0), c(0, 0), c(1, 1))
  expect_equal(historical_group_gain(corrected, rep(1, 3)), c(.5, .75, 0))
  expect_error(historical_group_gain(corrected, 1:3))
  expect_error(historical_group_gain(corrected, c(1, NA, 1)))
  corrected[1, 1] <- NA_real_
  expect_equal(historical_group_gain(corrected, rep(1, 3)), c(NA, .75, 0))
  corrected[1, 1] <- 2
  expect_error(historical_group_gain(corrected, rep(1, 3)))
})

test_that("knowledge transformations preserve missing and zero cases", {
  rebuilt <- build_health_polardata()
  absent <- rebuilt$caseid %in% c(3809, 4307)
  expect_identical(is.na(rebuilt$grpgain), absent)
  expect_identical(is.na(rebuilt$t1knowcor), absent)
  expect_identical(is.na(rebuilt$knowgain2), absent)
  expect_false(anyNA(rebuilt$t1know))
  ceiling <- rebuilt$t1knowcor %in% 1
  expect_equal(sum(ceiling), 12L)
  expect_true(all(rebuilt$grpgain[ceiling] == 0))
  expect_true(all(rebuilt$knowgain2[!absent] >= 0))
  expect_true(all(rebuilt$t1knowcor[!absent] <= rebuilt$t1know[!absent]))
  expect_equal(
    historical_log_score(c(0, .00005, 1, NA)),
    c(log(.0001), log(.00005), 0, NA)
  )
  changed <- rebuilt
  changed$t1knowlevel <- mean(changed$t1know)
  expect_error(compare_health_polardata(changed, health_reference()), "differs")
})

test_that("polardata construction needs no benchmark or vault", {
  isolated <- tempfile("polardata-source-only-")
  fs::dir_create(isolated)
  withr::defer(unlink(isolated, recursive = TRUE))
  fs::file_copy(project_path("DESCRIPTION"), isolated)
  fs::dir_copy(project_path("R"), file.path(isolated, "R"))
  fs::dir_copy(project_path("metadata"), file.path(isolated, "metadata"))
  fs::dir_copy(project_path("data"), file.path(isolated, "data"))
  script <- project_path("scripts", "12_build_polardata.R")
  expect_false(dir.exists(file.path(isolated, "evidence")))
  expect_false(dir.exists(file.path(isolated, "vault")))
  withr::with_dir(isolated, source(script, local = new.env()))
  rebuilt <- arrow::read_parquet(file.path(isolated, "output", "polardata",
                                           "uk-health-1998.parquet"))
  expect_equal(rebuilt, build_health_polardata())
  full <- arrow::read_parquet(file.path(
    isolated, "output", "polardata", "polardata.parquet"
  ))
  expect_identical(dim(full), c(5869L, 364L))
  expect_identical(full, arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  )))
})

test_that("Health parity rejects stale flags and new missingness", {
  rebuilt <- build_health_polardata()
  benchmark <- health_reference()
  historical <- benchmark[benchmark$dpnum == 2L, ]
  historical <- historical[match(rebuilt$caseid, historical$caseid), ]
  for (field in c("bettered", "phighinc")) {
    changed <- rebuilt
    changed[[field]] <- historical[[field]]
    expect_error(compare_health_polardata(changed, benchmark), "differs")
    changed <- rebuilt
    changed[[field]][which(!is.na(changed[[field]]))[1]] <- NA_real_
    expect_error(compare_health_polardata(changed, benchmark), "differs")
  }
})


test_that("UK Health severity uses the same theoretical scale at both waves", {
  survey <- read_poll_survey("uk-health-1998")
  responses <- expand.grid(lista = 1:5, severa = 1:5)
  rows <- seq_len(nrow(responses))
  for (wave in 1:2) {
    survey[[paste0("lista", wave)]][rows] <- responses$lista
    survey[[paste0("severa", wave)]][rows] <- responses$severa
    survey[[paste0("lista", wave)]][26] <- -9
  }
  individual <- build_health_individual(survey)
  expected <- .5 + (responses$lista - responses$severa) / 8
  for (wave in 1:2) {
    actual <- individual[[paste0("ukhealth.t", wave, "severi")]]
    expect_equal(actual[rows], expected)
    expect_true(is.na(actual[26]))
    expect_equal(range(actual, na.rm = TRUE), c(0, 1))
  }
})


test_that("shared Health dispersion uses the final attitude indices", {
  source(project_path("R", "polardata_core.R"), local = TRUE)
  survey <- read_poll_survey("uk-health-1998")
  individual <- build_health_individual(survey)
  final <- individual[grep("^ukhealth[.]t1", names(individual))]
  profile <- core_poll_profile(survey, "uk-health-1998")
  expect_equal(profile$attitudes, final)
  expect_equal(ncol(profile$attitudes), 11L)
})


test_that("Health input indices distinguish none from all at both interviews", {
  survey <- read_poll_survey("uk-health-1998")
  pairs <- rbind(
    expand.grid(first = 1:3, second = 1:3),
    c(-9, 3), c(1, -8), c(-9, -8), c(NA, NA)
  )
  expected <- c(0, .25, .5, .25, .5, .75, .5, .75, 1, 1, 0, NA, NA)
  rows <- seq_len(nrow(pairs))
  for (wave in 1:2) {
    for (stems in list(c("ingova", "inpuba"), c("ingpa", "indoca"))) {
      survey[[paste0(stems[1], wave)]][rows] <- pairs[, 1]
      survey[[paste0(stems[2], wave)]][rows] <- pairs[, 2]
    }
  }
  individual <- build_health_individual(survey)
  for (wave in 1:2) {
    for (index in c("dispub", "avgdis")) {
      values <- individual[[paste0("ukhealth.t", wave, index)]][rows]
      expect_equal(values, expected)
    }
  }
})


test_that("Health input ordering agrees with independent evidence", {
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "uk-health-1998", "folded_input_approved_values.csv"
  ), show_col_types = FALSE)
  rebuilt <- build_historical_poll("uk-health-1998")
  benchmark <- health_reference()
  benchmark <- benchmark[benchmark$dpnum == 2L, ]
  expect_equal(nrow(rebuilt), 230L)
  expect_false(anyDuplicated(rebuilt$caseid) > 0L)
  for (field in unique(approved$legacy_field)) {
    expected <- approved[approved$legacy_field == field, ]
    rows <- match(expected$caseid, rebuilt$caseid)
    expect_false(anyNA(rows))
    final_expected <- expected$approved_value
    if (field == "genvar") {
      historical <- benchmark$genvar[
        match(expected$caseid, benchmark$caseid)
      ]
      expect_equal(final_expected, approved_poll_reference_values(
        "uk-health-1998", field, expected$caseid, historical
      ), tolerance = 1e-10)
      final_expected <- approved_reference_values(
        "uk-health-1998", field, expected$caseid, historical
      )
      expect_equal(sum(is.na(final_expected)), 152L)
    }
    expect_equal(
      rebuilt[[field]][rows], final_expected, tolerance = 1e-10
    )
    expect_identical(
      is.na(expected$previous_value), is.na(expected$approved_value)
    )
  }
})
