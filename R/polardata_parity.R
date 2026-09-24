compare_historical_polardata <- function(rebuilt, reference, numerical_audit,
                                         tolerance = 1e-10) {
  stopifnot(identical(names(rebuilt), names(reference)),
    nrow(rebuilt) == nrow(reference), nrow(rebuilt) == 6084L
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
      numerical <- difference & field == "genvar" &
        verified_numeric
      artifact <- field == "X"
      tibble::tibble(
        poll_id = contract$poll_id, legacy_field = field,
        respondents = nrow(actual), compared_values = sum(observed),
        missingness_differences = sum(missing),
        value_differences = sum(difference),
        reviewed_numerical_differences = sum(numerical),
        export_artifact = artifact,
        unexplained_differences = if (artifact) {
          0L
        } else {
          sum(missing | (difference & !numerical))
        },
        max_absolute_difference = max(error), tolerance = tolerance
      )
    })
  })
}
