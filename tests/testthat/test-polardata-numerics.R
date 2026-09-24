source(file.path(root, "R", "polardata_derived.R"))
source(file.path(root, "R", "polardata_numerics.R"))

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
  both <- covariance_diagnostics(cbind(incomplete, incomplete[, 1]))
  expect_equal(both$covariance_class, "indefinite_and_singular")
  expect_equal(both$near_zero_eigenvalues, 1)
  missing <- covariance_diagnostics(cbind(seq_len(6), NA_real_))
  expect_equal(missing$covariance_class, "undefined")
  expect_true(is.na(missing$source_genvar))
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

test_that("reviewed public source matrices identify only the 24 known groups", {
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
  result <- audit_historical_covariances(benchmark, reviewed)
  accepted <- result[result$numerical_exception, ]
  expect_equal(nrow(accepted), 24)
  expect_setequal(accepted$pollgroup, reviewed$pollgroup)
  expect_setequal(
    accepted$pollgroup[accepted$covariance_class == "indefinite_and_singular"],
    c(9601, 9621)
  )
  expect_true(all(accepted$covariance_rank < accepted$p))
  expect_true(all(accepted$benchmark_genvar <= accepted$perturbation_upper))
  changed <- reviewed
  changed$attitudes_sha256[1] <- "changed"
  rejected <- audit_historical_covariances(benchmark, changed)
  expect_false(rejected$numerical_exception[
    rejected$pollgroup == changed$pollgroup[1]
  ])
})
