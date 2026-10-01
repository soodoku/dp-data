test_that("US poll calibration preserves earlier scoring and sample vintages", {
  election <- tibble::as_tibble(setNames(
    rep(list(c(1, NA_real_)), 9),
    paste0("w4b", c(60, 61, 62, 63, 64, 65, 66, 68, 69))
  ))
  election$w4comsta <- c(2, 2)
  election$w4b62[2] <- -1
  expect_equal(
    reviewed_us_baseline_level("btp-general-election-2004", election),
    as_historical_float(.1111111)
  )
  health <- tibble::tibble(
    q15 = c(2, NA_real_), q16 = c(NA_real_, NA_real_),
    q17 = c(NA_real_, NA_real_), q26 = c(NA_real_, NA_real_),
    q27 = c(NA_real_, NA_real_), q28 = c(NA_real_, NA_real_)
  )
  expect_equal(
    reviewed_us_baseline_level("btp-health-education-2005", health), .5
  )
  san <- tibble::as_tibble(setNames(
    as.list(c(3, 5, 1, 3, 4, 3, 1, 5)),
    paste0("Q", 19:26)
  ))
  expect_equal(
    reviewed_us_baseline_level("san-mateo-2008", san),
    as_historical_float(1)
  )
})

test_that("Health corrected calibration retains available-item denominators", {
  fields <- paste0("q", c(15, 16, 17, 26, 27, 28))
  survey <- tibble::as_tibble(stats::setNames(
    rep(list(rep(NA_real_, 6)), length(fields)), fields
  ))
  survey$q17 <- c(1, 2, 3, 7, NA_real_, 3)
  survey$q15[2] <- 2
  expect_equal(
    reviewed_us_baseline_level("btp-health-education-2005", survey),
    as_historical_float(.4166667)
  )
})

test_that("US aggregates match approved values and exact covariance reviews", {
  benchmark <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  polls <- c(
    "btp-general-election-2004", "btp-health-education-2005",
    "san-mateo-2008"
  )
  builders <- list(
    build_btp_general_derived, build_btp_health_derived,
    build_san_mateo_derived
  )
  for (index in seq_along(polls)) {
    poll <- polls[index]
    survey <- read_poll_survey(poll)
    expected <- benchmark[benchmark$dpnum == c(15, 18, 17)[index], ]
    values <- historical_respondent_wide(poll)
    actual <- builders[[index]](survey, values)
    rows <- match(expected$caseid, values$caseid)
    expect_false(anyNA(rows))
    expect_false(anyDuplicated(values$caseid) > 0L)
    actual <- actual[rows, ]
    expected$genvar <- approved_reference_values(
      poll, "genvar", expected$caseid, expected$genvar
    )
    expected$phighinc <- approved_reference_values(
      poll, "phighinc", expected$caseid, expected$phighinc
    )
    expected$entropy <- approved_reference_values(
      poll, "entropy", expected$caseid, expected$entropy
    )
    for (field in c("grpgain", "grpgain2", "grpgainr", "loggain")) {
      expected[[field]] <- approved_reference_values(
        poll, field, expected$caseid, expected[[field]]
      )
    }
    if (poll == "san-mateo-2008") {
      for (field in c(
        "t1knowlevel", "meant1knowcor", "meant2know", "meant1knowrcor",
        "meant1knowcor_ind", "t1knowlevelcor", "t2knowlevel", "t1knowlevelrcor"
      )) {
        expected[[field]] <- approved_reference_values(
          poll, field, expected$caseid, expected[[field]]
        )
      }
    }
    if (poll == "btp-health-education-2005") {
      for (field in c(
        "female", "pfemale", "varfemale", "sdfemale", "pfemale_ind",
        "meant1know", "meant1knowr", "meant1know_ind",
        "meant1knowcor", "meant1knowrcor", "meant1knowcor_ind",
        "meant2know", "t1knowlevelcor", "t1knowlevelrcor", "t2knowlevel",
        "t1knowlevel"
      )) {
        expected[[field]] <- approved_reference_values(
          poll, field, expected$caseid, expected[[field]]
        )
      }
    }
    if (poll == "btp-general-election-2004") {
      for (field in c(
        "meant1know", "meant1knowr", "meant1know_ind",
        "meant1knowcor", "meant1knowrcor", "meant1knowcor_ind",
        "meant2know", "t1knowlevelcor", "t1knowlevelrcor", "t2knowlevel"
      )) {
        expected[[field]] <- approved_reference_values(
          poll, field, expected$caseid, expected[[field]]
        )
      }
    }
    for (field in setdiff(names(actual), "genvar")) {
      expect_identical(is.na(actual[[field]]), is.na(expected[[field]]),
        info = paste(poll, field)
      )
      expect_equal(actual[[field]], as.numeric(expected[[field]]),
        tolerance = 1e-10, info = paste(poll, field)
      )
    }
    inputs <- reviewed_us_covariance_inputs(survey, poll)
    reviewed <- readr::read_csv(project_path(
      "metadata", "polardata_reviewed_covariances.csv"
    ), show_col_types = FALSE)
    diagnostics <- group_covariance_audit(
      inputs$attitudes, inputs$group, poll, expected, reviewed
    )
    invalid <- diagnostics$pollgroup[diagnostics$negative_eigenvalues > 0L]
    expect_identical(is.na(actual$genvar), is.na(expected$genvar))
    expect_equal(sum(is.na(actual$genvar)), c(20L, 193L, 75L)[index])
    expect_setequal(unique(actual$pollgroup[is.na(actual$genvar)]), invalid)
    observed <- !is.na(actual$genvar) & !is.na(expected$genvar)
    different <- observed & abs(actual$genvar - expected$genvar) > 1e-10
    verified <- verified_covariance_values(
      actual$genvar, actual$pollgroup, diagnostics, expected$genvar
    )
    expect_true(all(verified[different]))
    expect_equal(sum(different), c(0L, 20L, 20L)[index])
  }
})

test_that("peer learning opportunity is zero when no unknown items remain", {
  items <- matrix(1, nrow = 3, ncol = 2)
  expect_equal(reviewed_us_group_gain(
    items, items, c(1, 1, 1),
    rep(1, 3)
  ), rep(0, 3))
})
