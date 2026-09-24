historical_reference_people <- function(reference, poll_id) {
  if (poll_id != "btp-presidential-primaries-2004") {
    stopifnot(!anyDuplicated(reference$caseid))
    return(reference)
  }
  stopifnot(
    nrow(reference) == 434L, !anyNA(reference$caseid),
    all(table(reference$caseid) == 2L)
  )
  comparable <- reference[, setdiff(names(reference), "X"), drop = FALSE]
  unique_people <- comparable[!duplicated(comparable$caseid), , drop = FALSE]
  matched <- unique_people[match(comparable$caseid, unique_people$caseid), ]
  rownames(comparable) <- NULL
  rownames(matched) <- NULL
  stopifnot(isTRUE(all.equal(comparable, matched, check.attributes = FALSE)))
  reference[!duplicated(reference$caseid), , drop = FALSE]
}

compare_respondent_measures <- function(measures, people, samples, reference,
                                        tolerance = 1e-10) {
  targets <- read_metadata("polardata_targets")
  targets <- targets[targets$status == "implemented", ]
  contracts <- read_metadata("respondent_sources")
  measure_lookup <- purrr::map(
    split(measures, measures$poll_id),
    function(poll) split(poll, poll$definition_id)
  )
  purrr::map(seq_len(nrow(targets)), function(i) {
    target <- targets[i, ]
    poll <- target$poll_id
    selected <- samples$respondent_id[
      samples$poll_id == poll & samples$sample_id == "historical-polardata" &
        !is.na(samples$included) & samples$included
    ]
    persons <- people[people$poll_id == poll &
                        people$respondent_id %in% selected, ]
    expected <- reference[reference$dpnum == contracts$dpnum[
      match(poll, contracts$poll_id)
    ], ]
    expected <- historical_reference_people(expected, poll)
    stopifnot(
      nrow(persons) == nrow(expected),
      if (poll == "nic-1996") {
        sum(is.na(persons$historical_respondent_id)) == 1L &&
          sum(is.na(expected$caseid)) == 1L
      } else {
        !anyNA(persons$historical_respondent_id)
      },
      !anyDuplicated(expected$caseid), !anyDuplicated(persons$respondent_id),
      !anyDuplicated(persons$historical_respondent_id),
      setequal(persons$historical_respondent_id, as.character(expected$caseid))
    )
    expected <- expected[match(
      persons$historical_respondent_id,
      as.character(expected$caseid)
    ), ][[target$legacy_field]]
    actual <- measure_lookup[[poll]][[target$canonical_definition]]
    stopifnot(!is.null(actual))
    stopifnot(
      !anyDuplicated(actual$respondent_id),
      all(persons$respondent_id %in% actual$respondent_id)
    )
    actual <- actual$value_numeric[match(
      persons$respondent_id,
      actual$respondent_id
    )]
    both <- !is.na(actual) & !is.na(expected)
    errors <- abs(actual[both] - expected[both])
    tibble::tibble(
      poll_id = poll, legacy_field = target$legacy_field,
      definition_id = target$canonical_definition,
      respondents = length(actual), compared_values = sum(both),
      missingness_differences = sum(is.na(actual) != is.na(expected)),
      value_differences = sum(errors > tolerance),
      max_absolute_difference = if (length(errors)) max(errors) else 0,
      tolerance = tolerance
    )
  }) |> purrr::list_rbind()
}
