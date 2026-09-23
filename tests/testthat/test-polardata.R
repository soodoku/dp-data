source(file.path(root, "R", "polardata.R"))

health_reference <- function() {
  readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
}

test_that("UK Health raw answers reproduce all 45 reconstructed fields", {
  rebuilt <- build_health_polardata()
  parity <- compare_health_polardata(rebuilt, health_reference())
  expect_equal(dim(rebuilt), c(230L, 47L))
  expect_equal(nrow(parity), 45L)
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
  derived <- grep("^t[12]", names(survey), value = TRUE)
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
