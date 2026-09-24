# These diagnostics belong to benchmark review, never respondent construction.
covariance_fingerprint <- function(covariance) {
  digest::digest(
    as.numeric(covariance), algo = "sha256", serialize = TRUE,
    serializeVersion = 2
  )
}

covariance_diagnostics <- function(attitudes) {
  attitudes <- as.matrix(attitudes)
  covariance <- stats::cov(attitudes, use = "pairwise.complete.obs")
  pairwise_n <- crossprod(!is.na(attitudes))
  result <- tibble::tibble(
    n = nrow(attitudes), p = ncol(attitudes),
    complete_n = sum(stats::complete.cases(attitudes)),
    pairwise_n_min = min(pairwise_n), pairwise_n_max = max(pairwise_n),
    covariance_sha256 = covariance_fingerprint(covariance),
    attitudes_sha256 = covariance_fingerprint(attitudes)
  )
  if (anyNA(covariance)) {
    eigenvalues <- rep(NA_real_, ncol(attitudes))
  } else {
    eigenvalues <- eigen(
      covariance, symmetric = TRUE, only.values = TRUE
    )$values
  }
  defined <- all(is.finite(eigenvalues))
  tolerance <- if (defined) {
    64 * .Machine$double.eps * ncol(attitudes) * max(abs(eigenvalues))
  } else {
    NA_real_
  }
  rank <- if (defined) sum(abs(eigenvalues) > tolerance) else NA_integer_
  negative <- if (defined) sum(eigenvalues < -tolerance) else NA_integer_
  singular <- defined && rank < ncol(attitudes)
  classification <- if (!defined) {
    "undefined"
  } else if (negative > 0 && singular) {
    "indefinite_and_singular"
  } else if (negative > 0) {
    "indefinite"
  } else if (singular) {
    "numerically_singular"
  } else {
    "positive_definite"
  }
  determinant <- if (defined) det(covariance) else NA_real_
  # A diagnostic perturbation envelope, not a generic comparison tolerance.
  upper <- if (defined) {
    exp(sum(log(abs(eigenvalues) + tolerance)) / (2 * ncol(attitudes)))
  } else {
    NA_real_
  }
  dplyr::mutate(result,
    covariance_class = classification, covariance_rank = rank,
    negative_eigenvalues = negative,
    near_zero_eigenvalues = if (defined) {
      sum(abs(eigenvalues) <= tolerance)
    } else {
      NA_integer_
    },
    minimum_eigenvalue = if (defined) min(eigenvalues) else NA_real_,
    maximum_eigenvalue = if (defined) max(eigenvalues) else NA_real_,
    eigenvalue_tolerance = tolerance,
    eigenvalues = paste(sprintf("%.17g", eigenvalues), collapse = ";"),
    determinant = determinant,
    source_genvar = historical_genvar(attitudes),
    perturbation_upper = upper
  )
}

group_covariance_audit <- function(attitudes, group, poll_id,
                                   benchmark = NULL, reviewed = NULL) {
  stopifnot(nrow(attitudes) == length(group), length(poll_id) == 1L)
  result <- purrr::map_dfr(sort(unique(stats::na.omit(group))), function(id) {
    rows <- which(group == id)
    diagnostics <- covariance_diagnostics(attitudes[rows, , drop = FALSE])
    dplyr::mutate(diagnostics, poll_id = poll_id, pollgroup = id, .before = 1)
  })
  result$benchmark_genvar <- NA_real_
  if (!is.null(benchmark)) {
    stopifnot(all(c("pollgroup", "genvar") %in% names(benchmark)))
    result$benchmark_genvar <- purrr::map_dbl(result$pollgroup, function(id) {
      value <- unique(benchmark$genvar[benchmark$pollgroup %in% id])
      if (length(value) > 1L) stop("Inconsistent benchmark within group: ", id)
      if (!length(value)) NA_real_ else value
    })
  }
  result$absolute_delta <- abs(result$source_genvar - result$benchmark_genvar)
  result$relative_delta <- result$absolute_delta / abs(result$benchmark_genvar)
  result$reviewed_covariance <- FALSE
  if (!is.null(reviewed)) {
    keys <- c("poll_id", "pollgroup", "attitudes_sha256", "n", "p")
    stopifnot(all(keys %in% names(reviewed)))
    key <- function(data) do.call(paste, c(data[keys], sep = "|"))
    result$reviewed_covariance <- key(result) %in% key(reviewed)
  }
  result$numerical_exception <- with(result,
    reviewed_covariance & near_zero_eigenvalues > 0 &
      is.finite(source_genvar) & is.finite(benchmark_genvar) &
      benchmark_genvar >= 0 &
      source_genvar <= perturbation_upper &
      benchmark_genvar <= perturbation_upper
  )
  result$numerical_exception[is.na(result$numerical_exception)] <- FALSE
  result
}


audit_historical_covariances <- function(benchmark, reviewed = NULL) {
  polls <- c(
    "uk-eu-1995", "btp-health-education-2005", "san-mateo-2008", "zeguo-2005"
  )
  purrr::map_dfr(polls, function(poll_id) {
    survey <- read_poll_survey(poll_id)
    profile <- if (poll_id == "uk-eu-1995") {
      core_poll_profile(survey, poll_id)
    } else if (poll_id == "zeguo-2005") {
      list(
        attitudes = zeguo_attitudes(survey, 1L),
        group = ifelse(!is.na(survey$preandpost), 5200 + survey$groupnum, NA)
      )
    } else {
      reviewed_us_covariance_inputs(survey, poll_id)
    }
    group_covariance_audit(
      profile$attitudes, profile$group, poll_id, benchmark, reviewed
    )
  })
}
