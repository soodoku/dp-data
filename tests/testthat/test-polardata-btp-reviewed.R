source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "polardata.R"))
source(file.path(root, "R", "respondent_btp_general.R"))
source(file.path(root, "R", "respondent_btp_health.R"))
source(file.path(root, "R", "respondent_parity.R"))
source(file.path(root, "R", "respondent_san_mateo.R"))
source(file.path(root, "R", "polardata_derived.R"))
source(file.path(root, "R", "polardata_assembly.R"))
source(file.path(root, "R", "polardata_btp_reviewed.R"))

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

test_that("US aggregates match except diagnosed singular covariances", {
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
      expected$t1knowlevel <- approved_reference_values(
        poll, "t1knowlevel", expected$caseid, expected$t1knowlevel
      )
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
    diagnostics <- reviewed_us_covariance_audit(survey, poll)
    singular <- diagnostics$pollgroup[
      diagnostics$covariance_rank < diagnostics$attitude_count
    ]
    regular <- !actual$pollgroup %in% singular
    expect_equal(actual$genvar[regular], expected$genvar[regular],
      tolerance = 1e-10
    )
    different <- abs(actual$genvar - expected$genvar) > 1e-10
    expect_true(all(actual$pollgroup[different] %in% singular))
    expect_equal(sum(different), c(0, 20, 31)[index])
  }
})

test_that("peer learning opportunity is zero when no unknown items remain", {
  items <- matrix(1, nrow = 3, ncol = 2)
  expect_equal(reviewed_us_group_gain(
    items, items, c(1, 1, 1),
    rep(1, 3)
  ), rep(0, 3))
})
