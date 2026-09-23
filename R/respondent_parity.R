compare_respondent_measures <- function(measures, people, samples, reference,
                                        tolerance = 1e-10) {
  targets <- read_metadata("polardata_targets")
  targets <- targets[targets$status == "implemented", ]
  contracts <- read_metadata("respondent_sources")
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
    stopifnot(
      nrow(persons) == nrow(expected), !anyNA(persons$source_respondent_id),
      !anyDuplicated(expected$caseid), !anyDuplicated(persons$respondent_id),
      setequal(persons$source_respondent_id, as.character(expected$caseid))
    )
    expected <- expected[match(persons$source_respondent_id,
                           as.character(expected$caseid)
                         ), ][[target$legacy_field]]
    actual <- measures[
      measures$poll_id == poll &
        measures$definition_id == target$canonical_definition,
    ]
    stopifnot(!anyDuplicated(actual$respondent_id),
      all(persons$respondent_id %in% actual$respondent_id)
    )
    actual <- actual$value_numeric[match(persons$respondent_id,
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
