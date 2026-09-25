compare_historical_polardata <- function(rebuilt, reference, numerical_audit,
                                         tolerance = 1e-10) {
  stopifnot(
    identical(names(rebuilt), names(reference)),
    nrow(rebuilt) == nrow(reference), nrow(rebuilt) == 6084L,
    !anyNA(rebuilt$X), all(rebuilt$X == seq_len(nrow(rebuilt)))
  )
  contracts <- read_metadata("respondent_sources")
  purrr::map_dfr(seq_len(nrow(contracts)), function(index) {
    contract <- contracts[index, ]
    actual <- rebuilt[rebuilt$dpnum == contract$dpnum, ]
    expected <- reference[reference$dpnum == contract$dpnum, ]
    stopifnot(nrow(actual) == nrow(expected))
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
      numerical <- difference & field == "genvar" &
        verified_numeric
      artifact <- field == "X"
      tibble::tibble(
        poll_id = contract$poll_id, legacy_field = field,
        respondents = nrow(actual), compared_values = sum(observed),
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
