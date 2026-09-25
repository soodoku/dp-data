approved_reference_values <- function(poll_id, field, caseid, historical,
                                      tolerance = 1e-10) {
  if (poll_id == "nic-1996" && field %in% c("ppage", "meanage", "mode")) {
    approved <- readr::read_csv(project_path(
      "audit", "corrections", "nic-1996", "approved_values.csv"
    ), show_col_types = FALSE)
    approved <- approved[approved$legacy_field == field, ]
    stopifnot(
      nrow(approved) == 466L, !anyDuplicated(approved$caseid),
      !anyDuplicated(approved$source_row), sum(is.na(approved$caseid)) == 1L,
      sum(is.na(caseid)) == 1L, !anyDuplicated(caseid),
      setequal(as.character(caseid), as.character(approved$caseid))
    )
    rows <- match(as.character(caseid), as.character(approved$caseid))
    approved <- approved[rows, ]
    stopifnot(
      identical(is.na(historical), is.na(approved$historical_value)),
      all(abs(historical - approved$historical_value) <= tolerance,
        na.rm = TRUE
      )
    )
    return(approved$approved_value)
  }
  reviewed <- list(
    "tomorrows-europe-2007" = list(
      fields = c("eu.mil_att_11_12_t3", "eu.free_trade_index_t3"),
      rows = 344L
    ),
    "cpl-1996" = list(
      fields = c("grpgain", "grpgainr", "loggain"), rows = 216L
    )
  )
  contract <- reviewed[[poll_id]]
  if (!is.null(contract) && field %in% contract$fields) {
    approved <- readr::read_csv(project_path(
      "audit", "corrections", poll_id, "approved_values.csv"
    ), show_col_types = FALSE)
    approved <- approved[approved$legacy_field == field, ]
    stopifnot(
      nrow(approved) == contract$rows,
      !anyDuplicated(approved$caseid), !anyDuplicated(caseid),
      setequal(as.character(caseid), as.character(approved$caseid))
    )
    approved <- approved[match(as.character(caseid),
                               as.character(approved$caseid)), ]
    stopifnot(
      identical(is.na(historical), is.na(approved$historical_value)),
      all(abs(historical - approved$historical_value) <= tolerance,
        na.rm = TRUE
      )
    )
    return(approved$approved_value)
  }
  election_fields <- c(
    "t1knowcor",
    "t2know",
    "t1knowrcor",
    "t2knowr",
    "knowgain",
    "knowgain2",
    "logpk",
    "knowgainr",
    "knowgainr2",
    "meant1knowcor",
    "meant2know",
    "meant1knowrcor",
    "meant1knowcor_ind",
    "t1knowlevelcor",
    "t2knowlevel",
    "t1knowlevelrcor",
    "grpgain",
    "grpgainr",
    "loggain"
  )
  if (poll_id == "uk-general-election-1997" && field %in% election_fields) {
    approved <- readr::read_csv(project_path(
      "audit", "corrections", "uk-general-election-1997", "approved_values.csv"
    ), show_col_types = FALSE)
    approved <- approved[approved$legacy_field == field, ]
    if (!nrow(approved)) {
      return(historical)
    }
    stopifnot(
      nrow(approved) == 275L, !anyDuplicated(approved$caseid),
      setequal(as.character(caseid), as.character(approved$caseid))
    )
    rows <- match(as.character(caseid), as.character(approved$caseid))
    approved <- approved[rows, ]
    stopifnot(
      identical(is.na(historical), is.na(approved$historical_value)),
      all(abs(historical - approved$historical_value) <= tolerance,
        na.rm = TRUE
      )
    )
    return(approved$approved_value)
  }
  if (poll_id != "uk-crime-1994" || field != "ukcrime.rootcauset2") {
    return(historical)
  }
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "uk-crime-1994", "respondent_comparison.csv"
  ), show_col_types = FALSE)
  stopifnot(
    nrow(approved) == 299L, !anyDuplicated(approved$caseid),
    setequal(as.character(caseid), as.character(approved$caseid))
  )
  rows <- match(as.character(caseid), as.character(approved$caseid))
  approved <- approved[rows, ]
  stopifnot(
    identical(is.na(historical), is.na(approved$historical_post)),
    all(abs(historical - approved$historical_post) <= tolerance, na.rm = TRUE)
  )
  approved$candidate_post
}

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
    expected_caseid <- persons$historical_respondent_id
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
    approved <- approved_reference_values(
      poll, target$legacy_field, expected_caseid, expected, tolerance
    )
    approved_both <- !is.na(actual) & !is.na(approved)
    unexplained <- sum(is.na(actual) != is.na(approved)) +
      sum(abs(actual[approved_both] - approved[approved_both]) > tolerance)
    both <- !is.na(actual) & !is.na(expected)
    errors <- abs(actual[both] - expected[both])
    tibble::tibble(
      poll_id = poll, legacy_field = target$legacy_field,
      definition_id = target$canonical_definition,
      respondents = length(actual), compared_values = sum(both),
      missingness_differences = sum(is.na(actual) != is.na(expected)),
      value_differences = sum(errors > tolerance),
      max_absolute_difference = if (length(errors)) max(errors) else 0,
      unexplained_differences = unexplained, tolerance = tolerance
    )
  }) |> purrr::list_rbind()
}
