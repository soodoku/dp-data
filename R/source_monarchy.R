monarchy_departure_observed <- function(survey) {
  fields <- grep("^R[0-9]", names(survey), value = TRUE)
  stopifnot(
    length(fields) == 61L, "WEEKEND" %in% names(survey),
    !anyNA(survey$source_row), !anyDuplicated(survey$source_row),
    all(survey$WEEKEND %in% c(-1, 1)),
    all(vapply(survey[fields], is.numeric, logical(1)))
  )
  answers <- as.matrix(survey[fields])
  observed <- rowSums(!is.na(answers) & answers != -1) > 0L
  absent <- survey$WEEKEND == -1
  stopifnot(!any(absent & observed))
  dplyr::case_when(absent ~ FALSE, observed ~ TRUE, TRUE ~ NA)
}
