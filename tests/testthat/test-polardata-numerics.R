source(file.path(root, "R", "polardata_derived.R"))
source(file.path(root, "R", "polardata_numerics.R"))
source(file.path(root, "R", "polardata_parity.R"))

test_that("covariance diagnostics distinguish singular and indefinite data", {
  singular <- cbind(seq_len(6), seq_len(6))
  result <- covariance_diagnostics(singular)
  expect_equal(result$covariance_class, "numerically_singular")
  expect_equal(result$covariance_rank, 1)
  expect_equal(result$negative_eigenvalues, 0)
  expect_equal(result$complete_n, 6)
  expect_equal(result$pairwise_n_min, 6)
  expect_equal(result$source_genvar, 0)

  incomplete <- cbind(
    c(-1, 1, NA, NA, -1, 1),
    c(-1, 1, -1, 1, NA, NA),
    c(NA, NA, -1, 1, 1, -1)
  )
  indefinite <- covariance_diagnostics(incomplete)
  expect_equal(indefinite$covariance_class, "indefinite")
  expect_equal(indefinite$negative_eigenvalues, 1)
  expect_equal(indefinite$complete_n, 0)
  expect_equal(indefinite$pairwise_n_min, 2)
  expect_equal(indefinite$pairwise_n_max, 4)
  expect_lt(indefinite$minimum_eigenvalue, -1)
  expect_true(is.na(indefinite$source_genvar))
  both <- covariance_diagnostics(cbind(incomplete, incomplete[, 1]))
  expect_equal(both$covariance_class, "indefinite_and_singular")
  expect_equal(both$near_zero_eigenvalues, 1)
  expect_true(is.na(both$source_genvar))
  missing <- covariance_diagnostics(cbind(seq_len(6), NA_real_))
  expect_equal(missing$covariance_class, "undefined")
  expect_true(is.na(missing$source_genvar))
})

test_that("invalid covariance stays missing with either determinant sign", {
  incomplete <- cbind(
    c(-1, 1, NA, NA, -1, 1),
    c(-1, 1, -1, 1, NA, NA),
    c(NA, NA, -1, 1, 1, -1)
  )
  expect_lt(det(stats::cov(incomplete, use = "pairwise.complete.obs")), 0)
  expect_true(is.na(historical_genvar(incomplete)))

  # Two independent incompatible pairwise batteries have two negative roots.
  two_batteries <- rbind(
    cbind(incomplete, matrix(NA_real_, 6, 3)),
    cbind(matrix(NA_real_, 6, 3), incomplete),
    matrix(0, 2, 6)
  )
  diagnostic <- covariance_diagnostics(two_batteries)
  expect_equal(diagnostic$negative_eigenvalues, 2L)
  expect_gt(diagnostic$determinant, 0)
  expect_true(is.na(historical_genvar(two_batteries)))
  complete <- two_batteries[stats::complete.cases(two_batteries), ]
  expect_equal(historical_genvar(complete), 0)

  audit <- group_covariance_audit(two_batteries, rep(1, 14), "example")
  reviewed <- audit[c("poll_id", "pollgroup", "attitudes_sha256", "n", "p")]
  reference <- tibble::tibble(pollgroup = 1, genvar = 0.001)
  expect_false(group_covariance_audit(
    two_batteries, rep(1, 14), "example", reference, reviewed
  )$numerical_exception)
})

test_that("spectrum tolerance separates roundoff from substantive negatives", {
  for (scale in c(1e-20, 1, 1e20)) {
    roundoff <- covariance_spectrum(diag(c(1, -.Machine$double.eps) * scale))
    expect_false(any(roundoff$values < -roundoff$tolerance))
    material <- covariance_spectrum(diag(c(1, -1e-8) * scale))
    expect_true(any(material$values < -material$tolerance))
    zero <- covariance_spectrum(matrix(0, 3, 3))
    expect_equal(zero$tolerance, 0)
    expect_false(any(zero$values < -zero$tolerance))
  }
  missing <- covariance_spectrum(matrix(c(1, NA, NA, 1), 2))
  expect_true(all(is.na(missing$values)))
  expect_true(is.na(missing$tolerance))

  for (attitudes in list(
    cbind(seq_len(6), c(1, 2, 4, 3, 5, 8)),
    cbind(seq_len(6), seq_len(6)),
    matrix(0, 6, 2)
  )) {
    covariance <- stats::cov(attitudes, use = "pairwise.complete.obs")
    original <- sqrt(sqrt(det(covariance)^2)^(1 / ncol(attitudes)))
    expect_identical(historical_genvar(attitudes), original)
  }
})

test_that("numerical review is scoped to exact inputs and a finite envelope", {
  attitudes <- cbind(seq_len(6), seq_len(6))
  group <- rep(99, 6)
  reference <- tibble::tibble(pollgroup = 99, genvar = 1e-5)
  unreviewed <- group_covariance_audit(attitudes, group, "example", reference)
  expect_false(unreviewed$numerical_exception)
  reviewed <- unreviewed[
    c("poll_id", "pollgroup", "attitudes_sha256", "n", "p")
  ]
  result <- group_covariance_audit(
    attitudes, group, "example", reference, reviewed
  )
  expect_true(result$numerical_exception)
  expect_equal(result$absolute_delta, 1e-5)
  expect_equal(result$relative_delta, 1)
  changed <- attitudes
  changed[1, 1] <- changed[1, 1] + 1e-8
  expect_false(group_covariance_audit(
    changed, group, "example", reference, reviewed
  )$numerical_exception)
  expect_false(group_covariance_audit(
    attitudes, group, "another", reference, reviewed
  )$numerical_exception)
  reference$genvar <- 1
  expect_false(group_covariance_audit(
    attitudes, group, "example", reference, reviewed
  )$numerical_exception)
  reference$genvar <- NA_real_
  expect_false(group_covariance_audit(
    attitudes, group, "example", reference, reviewed
  )$numerical_exception)
  expect_error(group_covariance_audit(
    attitudes, group, "example",
    tibble::tibble(pollgroup = c(99, 99), genvar = c(0, 1))
  ), "Inconsistent benchmark")
})

test_that("full rank matrices never receive numerical singularity exceptions", {
  attitudes <- cbind(seq_len(6), c(1, 2, 4, 3, 5, 8))
  result <- group_covariance_audit(attitudes, rep(1, 6), "example")
  expect_equal(result$covariance_class, "positive_definite")
  reference <- tibble::tibble(pollgroup = 1, genvar = result$source_genvar)
  reviewed <- result[c("poll_id", "pollgroup", "attitudes_sha256", "n", "p")]
  expect_false(group_covariance_audit(
    attitudes, rep(1, 6), "example", reference, reviewed
  )$numerical_exception)
})

test_that("reviewed public source matrices identify only registered inputs", {
  for (module in c(
    "respondents", "polardata", "polardata_assembly", "polardata_core",
    "polardata_btp_reviewed", "respondent_zeguo"
  )) {
    source(file.path(root, "R", paste0(module, ".R")))
  }
  benchmark <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  reviewed <- readr::read_csv(
    project_path("metadata", "polardata_reviewed_covariances.csv"),
    show_col_types = FALSE
  )
  expect_equal(nrow(reviewed), 7L)
  expect_equal(length(unique(reviewed$pollgroup)), 6L)
  expect_false(any(reviewed$pollgroup %in% c(9601, 9621)))
  result <- audit_historical_covariances(benchmark, reviewed)
  accepted <- result[result$numerical_exception, ]
  expect_equal(nrow(accepted), 7)
  expect_equal(sum(accepted$reference_kind == "approved"), 1L)
  expect_setequal(accepted$pollgroup, reviewed$pollgroup)
  invalid <- result[result$pollgroup %in% c(9601, 9621), ]
  expect_equal(invalid$covariance_class, rep("indefinite_and_singular", 2))
  expect_true(all(is.na(invalid$source_genvar)))
  expect_false(any(invalid$numerical_exception))
  expect_false(any(invalid$reviewed_covariance))
  expect_true(all(accepted$negative_eigenvalues == 0))
  expect_true(all(accepted$covariance_rank < accepted$p))
  expect_true(all(accepted$benchmark_genvar <= accepted$perturbation_upper))
  changed <- reviewed
  changed$attitudes_sha256[1] <- "changed"
  rejected <- audit_historical_covariances(benchmark, changed)
  expect_false(rejected$numerical_exception[
    rejected$pollgroup == changed$pollgroup[1] &
      rejected$reference_kind == "historical"
  ])
  changed <- reviewed
  corrected_hash <- accepted$attitudes_sha256[
    accepted$reference_kind == "approved"
  ]
  changed$attitudes_sha256[
    changed$attitudes_sha256 == corrected_hash
  ] <- "changed"
  rejected <- audit_historical_covariances(benchmark, changed)
  expect_false(any(rejected$reference_kind == "approved"))
})

test_that("approved covariance exceptions require both verified values", {
  attitudes <- cbind(seq_len(6), seq_len(6))
  group <- rep(99, 6)
  reference <- tibble::tibble(pollgroup = 99, genvar = 1e-5)
  audit <- group_covariance_audit(attitudes, group, "example", reference)
  reviewed <- audit[c("poll_id", "pollgroup", "attitudes_sha256", "n", "p")]
  audit <- group_covariance_audit(
    attitudes, group, "example", reference, reviewed,
    reference_kind = "approved"
  )
  expect_true(verified_covariance_values(0, 99, audit, 1e-5))
  expect_false(verified_covariance_values(1e-6, 99, audit, 1e-5))
  expect_false(verified_covariance_values(0, 100, audit, 1e-5))
  expect_false(verified_covariance_values(0, 99, audit, 2e-5))
  expect_false(verified_covariance_values(NA_real_, 99, audit, 1e-5))
  expect_false(verified_covariance_values(0, 99, audit, NA_real_))
  out_of_bounds <- audit
  out_of_bounds$source_genvar <- 1
  expect_false(verified_covariance_values(1, 99, out_of_bounds, 1e-5))
  audit$numerical_exception <- FALSE
  expect_false(verified_covariance_values(0, 99, audit, 1e-5))
})
