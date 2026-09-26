compare_historical_polardata <- function(rebuilt, reference, numerical_audit,
                                         tolerance = 1e-10) {
  stopifnot(
    identical(names(rebuilt), names(reference)),
    nrow(rebuilt) == 5869L, nrow(reference) == 6084L,
    !anyNA(rebuilt$X), all(rebuilt$X == seq_len(nrow(rebuilt)))
  )
  contracts <- read_metadata("respondent_sources")
  purrr::map_dfr(seq_len(nrow(contracts)), function(index) {
    contract <- contracts[index, ]
    actual <- rebuilt[rebuilt$dpnum == contract$dpnum, ]
    expected <- reference[reference$dpnum == contract$dpnum, ]
    rebuilt_count <- nrow(actual)
    if (contract$poll_id == "btp-general-election-2004") {
      added <- btp_ge_approved_inclusions()
      new_people <- actual[!actual$caseid %in% expected$caseid, ]
      added <- added[match(new_people$caseid,
                           added$historical_caseid), ]
      stopifnot(
        rebuilt_count == 248L, nrow(expected) == 246L,
        nrow(new_people) == 2L, !anyNA(added$historical_caseid),
        identical(as.numeric(new_people$pollgroup),
                  as.numeric(added$pollgroup)),
        all(abs(new_people$t2know -
                  added$post_knowledge_correct) <= tolerance),
        all(abs(new_people$attextreme -
                  added$attitude_extremity) <= tolerance)
      )
      actual <- actual[actual$caseid %in% expected$caseid, ]
    } else {
      expected_rows <- if (contract$poll_id ==
                             "btp-presidential-primaries-2004") 2L else 1L
      stopifnot(nrow(expected) == nrow(actual) * expected_rows)
    }
    actual <- historical_reference_people(actual, contract$poll_id)
    expected <- historical_reference_people(expected, contract$poll_id)
    stopifnot(setequal(actual$caseid, expected$caseid))
    expected <- expected[match(actual$caseid, expected$caseid), ]
    audit <- numerical_audit[
      numerical_audit$poll_id == contract$poll_id &
        numerical_audit$numerical_exception,
    ]
    audit_rows <- match(actual$pollgroup, audit$pollgroup)
    verified_numeric <- !is.na(audit_rows) &
      abs(actual$genvar - audit$source_genvar[audit_rows]) <= tolerance
    verified_numeric[is.na(verified_numeric)] <- FALSE
    purrr::map_dfr(names(actual), function(field) {
      a <- actual[[field]]
      b <- expected[[field]]
      observed <- !is.na(a) & !is.na(b)
      missing <- is.na(a) != is.na(b)
      difference <- rep(FALSE, length(a))
      error <- rep(0, length(a))
      if (is.numeric(a) && is.numeric(b)) {
        finite <- observed & is.finite(a) & is.finite(b)
        error[finite] <- abs(a[finite] - b[finite])
        difference[finite] <- error[finite] > tolerance
        nonfinite <- observed & !finite
        difference[nonfinite] <- a[nonfinite] != b[nonfinite]
        error[nonfinite & difference] <- Inf
      } else {
        difference[observed] <- a[observed] != b[observed]
      }
      approved <- approved_reference_values(
        contract$poll_id, field, actual$caseid, b, tolerance
      )
      approved_changed <- is.na(approved) != is.na(b)
      both_approved <- !is.na(approved) & !is.na(b)
      approved_changed[both_approved] <- if (is.numeric(b)) {
        abs(approved[both_approved] - b[both_approved]) > tolerance
      } else {
        approved[both_approved] != b[both_approved]
      }
      approved_changed[is.na(approved_changed)] <- FALSE
      matches_approved <- is.na(a) & is.na(approved)
      observed_approved <- !is.na(a) & !is.na(approved)
      matches_approved[observed_approved] <- if (is.numeric(a)) {
        abs(a[observed_approved] - approved[observed_approved]) <= tolerance
      } else {
        a[observed_approved] == approved[observed_approved]
      }
      matches_approved[is.na(matches_approved)] <- FALSE
      if (contract$poll_id == "zeguo-2005" && field == "genvar") {
        corrected <- !is.na(actual$pollgroup) & actual$pollgroup == 5207
        review <- numerical_audit[
          numerical_audit$poll_id == contract$poll_id &
            numerical_audit$pollgroup == 5207,
        ]
        source_fingerprint <- paste0(
          "3514924de53bbb8c3bb14d334d3f5de6",
          "dd7c324e89be7f82acf9b4a7d34e0a05"
        )
        verified <- nrow(review) == 1L &&
          sum(corrected) == 16L &&
          identical(review$attitudes_sha256, source_fingerprint) &&
          review$n == 16L && review$p == 9L &&
          review$covariance_rank == 8L &&
          review$near_zero_eigenvalues == 1L &&
          !review$numerical_exception &&
          is.finite(review$source_genvar) &&
          review$source_genvar >= 0 &&
          review$source_genvar <= review$perturbation_upper &&
          is.finite(review$benchmark_genvar) &&
          all(abs(b[corrected] - review$benchmark_genvar) <= tolerance) &&
          abs(review$source_genvar - review$benchmark_genvar) > tolerance
        matches_approved[corrected] <- if (isTRUE(verified)) {
          !is.na(a[corrected]) &
            abs(a[corrected] - review$source_genvar) <= tolerance
        } else {
          FALSE
        }
      }
      numerical <- difference & field == "genvar" &
        verified_numeric
      artifact <- field == "X"
      tibble::tibble(
        poll_id = contract$poll_id, legacy_field = field,
        respondents = rebuilt_count, compared_values = sum(observed),
        missingness_differences = sum(missing),
        value_differences = sum(difference),
        reviewed_numerical_differences = sum(numerical),
        approved_correction_differences = sum(
          approved_changed & matches_approved
        ),
        export_artifact = artifact,
        unexplained_differences = if (artifact) {
          0L
        } else {
          sum((missing | (difference & !numerical)) & !approved_changed) +
            sum(approved_changed & !matches_approved)
        },
        max_absolute_difference = max(error), tolerance = tolerance
      )
    })
  })
}
