source(file.path(root, "R", "polardata.R"))

health_reference <- function() {
  readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
}

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

test_that("historical folds and missingness are preserved without new codes", {
  expect_equal(
    historical_health_response(c(1, 2, 3, -9, -8, NA), 3L, TRUE),
    c(1, 0.5, 1, NA, NA, NA)
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


test_that("historical summary vintages remain distinct", {
  rebuilt <- build_health_polardata()
  final_share <- ave(as.numeric(rebuilt$highinc), rebuilt$pollgroup,
    FUN = function(x) mean(x, na.rm = TRUE)
  )
  expect_true(all(abs(final_share - rebuilt$phighinc) > 1e-10))
  final_attitudes <- as.matrix(
    rebuilt[grep("^ukhealth[.]t1", names(rebuilt))]
  )
  recalculated <- historical_available_mean(abs(final_attitudes - .5))
  expect_gt(sum(abs(recalculated - rebuilt$attextreme) > 1e-10), 0L)
  incomplete <- rebuilt
  incomplete$educ4 <- NULL
  expect_error(compare_health_polardata(incomplete, health_reference()))
  changed <- rebuilt
  changed$educ4[1] <- .123
  expect_error(compare_health_polardata(changed, health_reference()), "differs")
})


test_that("raw knowledge keys reproduce stored correctness and precision", {
  survey <- read_poll_survey("uk-health-1998")
  for (wave in 1:2) {
    scores <- historical_health_items(survey, wave)
    stored <- vapply(letters[1:6], function(item) {
      value <- as.numeric(survey[[paste0("answer", item, wave)]])
      value[is.na(value)] <- 0
      value
    }, numeric(nrow(survey)))
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
  expect_equal(historical_group_gain(corrected, rep(1, 3)), c(.5, .75, NA))
  expect_error(historical_group_gain(corrected, 1:3))
  expect_error(historical_group_gain(corrected, c(1, NA, 1)))
  corrected[1, 1] <- NA_real_
  expect_error(historical_group_gain(corrected, rep(1, 3)))
})

test_that("knowledge transformations preserve missing and zero cases", {
  rebuilt <- build_health_polardata()
  expect_identical(is.na(rebuilt$grpgain), rebuilt$t1knowcor == 1)
  expect_true(all(rebuilt$knowgain2 >= 0))
  expect_true(all(rebuilt$t1knowcor <= rebuilt$t1know))
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
  expect_identical(dim(full), c(5867L, 364L))
  expect_identical(full, arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  )))
})
