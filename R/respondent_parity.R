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
  if (poll_id == "zeguo-2005" && field == "genvar") {
    approved <- readr::read_csv(project_path(
      "audit", "corrections", poll_id, "approved_values.csv"
    ), show_col_types = FALSE)
    approved <- approved[
      approved$legacy_field == field & approved$pollgroup == 5207,
    ]
    rows <- match(approved$caseid, caseid)
    stopifnot(nrow(approved) == 16L, !anyNA(rows),
      !anyDuplicated(approved$caseid),
      all(abs(historical[rows] - approved$historical_value) <= tolerance)
    )
    historical[rows] <- approved$approved_value
    return(historical)
  }
  reviewed <- list(
    "europolis-2009" = list(fields = c("ppage", "meanage"), rows = 348L),
    "btp-national-2003" = list(
      fields = c("btp03.olt1demo", "btp03.olt2demo",
                 "btp03.olt1global", "btp03.olt2global",
                 "attextreme", "meanxtreme", "avgsd", "genvar"),
      rows = 245L
    ),
    "btp-presidential-primaries-2004" = list(
      fields = c(
        "grpgain", "grpgainr", "loggain", "groupsize", "vareduc",
        "sdeduc", "pfemale_ind", "meant1know_ind", "meant1knowcor_ind"
      ), rows = 217L
    ),
    "san-mateo-2008" = list(
      fields = "t1knowlevel", rows = 239L
    ),
    "zeguo-2005" = list(
      fields = c("chi.t1att2", "chi.t2att3", "attextreme",
                 "meanxtreme", "avgsd", "ppage", "meanage"), rows = 233L
    ),
    "new-haven-2004" = list(
      fields = c("minority", "pminority"), rows = 132L
    ),
    "btp-health-education-2005" = list(
      fields = c("female", "pfemale", "varfemale", "sdfemale",
                 "pfemale_ind", "entropy", "t1knowlevel"), rows = 454L
    ),
    "tomorrows-europe-2007" = list(
      fields = c(
        "eu.mil_att_11_12_t3", "eu.free_trade_index_t3",
        "ppage", "educ4", "educ3", "bettered", "vareduc", "sdeduc",
        "meaned", "meanage", "entropy"
      ), rows = 344L
    ),
    "cpl-1996" = list(
      fields = c("grpgain", "grpgainr", "loggain"), rows = 216L
    ),
    "swepco-1996" = list(
      fields = c("swp.t2att3", "attextreme", "meanxtreme", "avgsd", "genvar"),
      rows = 232L
    ),
    "wtu-1996" = list(
      fields = c("wtu.t2att3", "attextreme", "meanxtreme", "avgsd",
                 "genvar"),
      rows = 230L
    ),
    "uk-general-election-1997" = list(
      fields = c("ukbge.t2tax", "grpgain", "grpgainr", "loggain",
                 "avgsd", "genvar"),
      rows = 275L
    ),
    "uk-eu-1995" = list(
      fields = c("ukeu.eurelat2g", "ukeu.euscope2g"), rows = 238L
    ),
    "uk-monarchy-1996" = list(
      fields = c(
        "t1knowcor", "t1knowrcor", "t2know", "t2knowr", "knowgain",
        "knowgain2", "knowgainr", "knowgainr2", "logpk", "tobitpk",
        "grpgain", "grpgainr", "loggain", "meant1knowcor",
        "meant1knowrcor", "meant1knowcor_ind", "t1knowlevelcor",
        "t1knowlevelrcor", "meant2know", "t2knowlevel"
      ), rows = 258L
    ),
    "australia-republic-1999" = list(
      fields = c("grpgain", "loggain", "attextreme", "meanxtreme",
                 "aus.popparl2"), rows = 347L
    )
  )
  contract <- reviewed[[poll_id]]
  if (!is.null(contract) && field %in% contract$fields) {
    filename <- if (poll_id == "europolis-2009") {
      "approved_age_values.csv"
    } else {
      "approved_values.csv"
    }
    approved <- readr::read_csv(project_path(
      "audit", "corrections", poll_id, filename
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
      identical(is.infinite(historical),
                is.infinite(approved$historical_value)),
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
    "t1knowlevelrcor"
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
  stopifnot(!anyNA(reference$caseid))
  if (nrow(reference) == 217L) {
    stopifnot(!anyDuplicated(reference$caseid))
    return(reference)
  }
  stopifnot(nrow(reference) == 434L, all(table(reference$caseid) == 2L))
  comparable <- reference[, setdiff(names(reference), "X"), drop = FALSE]
  unique_people <- comparable[!duplicated(comparable$caseid), , drop = FALSE]
  matched <- unique_people[match(comparable$caseid, unique_people$caseid), ]
  rownames(comparable) <- NULL
  rownames(matched) <- NULL
  stopifnot(isTRUE(all.equal(comparable, matched, check.attributes = FALSE)))
  reference[!duplicated(reference$caseid), , drop = FALSE]
}

btp_ge_approved_inclusions <- function() {
  added <- readr::read_csv(project_path(
    "audit", "corrections", "btp-general-election-2004",
    "approved_inclusions.csv"
  ), show_col_types = FALSE)
  stopifnot(
    nrow(added) == 2L, !anyDuplicated(added$historical_caseid),
    setequal(added$respondent_id, c(552, 585)),
    setequal(added$historical_caseid, c(940052, 940246)),
    all(added$post_items_observed == 9L),
    all(added$post_knowledge_correct == 0),
    all(!is.na(added$attitude_extremity)),
    all(added$participation_flag == 1)
  )
  added
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
    rebuilt_count <- nrow(persons)
    if (poll == "btp-general-election-2004") {
      added <- btp_ge_approved_inclusions()
      new_people <- persons[!persons$historical_respondent_id %in%
                              as.character(expected$caseid), ]
      stopifnot(
        rebuilt_count == 248L, nrow(expected) == 246L,
        setequal(new_people$respondent_id,
                 as.character(added$respondent_id)),
        setequal(new_people$historical_respondent_id,
                 as.character(added$historical_caseid))
      )
      persons <- persons[persons$historical_respondent_id %in%
                           as.character(expected$caseid), ]
    }
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
      respondents = rebuilt_count, compared_values = sum(both),
      missingness_differences = sum(is.na(actual) != is.na(expected)),
      value_differences = sum(errors > tolerance),
      max_absolute_difference = if (length(errors)) max(errors) else 0,
      unexplained_differences = unexplained, tolerance = tolerance
    )
  }) |> purrr::list_rbind()
}
