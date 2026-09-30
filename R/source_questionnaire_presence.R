mask_reviewed_knowledge_items <- function(items, presence) {
  if (is.null(presence) || !nrow(presence)) return(items)
  keys <- c("poll_id", "source_dataset", "respondent_id", "wave")
  stopifnot(!anyDuplicated(presence[keys]))
  position <- match(
    do.call(paste, items[keys]), do.call(paste, presence[keys])
  )
  reviewed <- !is.na(position)
  observed <- presence$wave_observed[position]
  unobserved <- reviewed & !observed %in% TRUE
  stopifnot(all(is.na(items$correct[unobserved]) |
                  items$correct[unobserved] == 0L))
  items$correct[unobserved] <- NA_integer_
  items$response_status[unobserved] <- "source_missing"
  items$response_status[reviewed & observed %in% FALSE] <- "wave_absent"
  items
}

mask_reviewed_knowledge <- function(items, survey, poll, original_wave) {
  stopifnot(is.matrix(items), nrow(items) == nrow(survey))
  wave <- as.character(original_wave)
  selected_wave <- switch(poll,
    "tomorrows-europe-2007" = if (wave == "3") "t2" else NA_character_,
    "europolis-2009" = if (wave == "3") "t2" else NA_character_,
    "nic-1996" = if (wave %in% c("1", "2")) paste0("t", wave)
    else NA_character_,
    "zeguo-2005" = if (wave == "pre") "t1" else NA_character_,
    "btp-presidential-primaries-2004" =
      c(b1 = "t1", f1 = "t2")[[wave]],
    "nic2-2003" = paste0("t", wave),
    if (wave == "2") "t2" else NA_character_
  )
  if (poll == "tomorrows-europe-2007" && wave == "2") {
    evidence <- te_arrival_form_evidence(survey)
  } else {
    if (is.na(selected_wave)) return(items)
    evidence <- questionnaire_form_evidence(survey, poll)
    evidence <- evidence[evidence$wave == selected_wave, ]
  }
  stopifnot(!anyDuplicated(evidence$source_row))
  position <- match(survey$source_row, evidence$source_row)
  stopifnot(length(position) == nrow(items), !anyNA(position))
  unavailable <- !evidence$wave_observed[position] %in% TRUE
  stopifnot(all(is.na(items[unavailable, ]) | items[unavailable, ] == 0))
  items[unavailable, ] <- NA_real_
  items
}

questionnaire_form_answers <- function(survey, fields) {
  stopifnot(length(fields) > 6L, all(fields %in% names(survey)))
  answered <- purrr::map(survey[fields], function(value) {
    if (is.character(value)) {
      !is.na(value) & nzchar(trimws(value))
    } else {
      !is.na(as.numeric(value))
    }
  })
  rowSums(do.call(cbind, answered)) > 0L
}

questionnaire_field_block <- function(survey, first, last) {
  positions <- match(c(first, last), names(survey))
  stopifnot(!anyNA(positions), positions[1L] <= positions[2L])
  names(survey)[seq.int(positions[1L], positions[2L])]
}

questionnaire_form_evidence <- function(survey, poll) {
  stopifnot(
    "source_row" %in% names(survey), !anyNA(survey$source_row),
    !anyDuplicated(survey$source_row)
  )
  labels <- vapply(survey, function(value) {
    label <- attr(value, "label", exact = TRUE)
    if (is.null(label)) "" else label
  }, character(1))
  block <- function(first, last) {
    questionnaire_field_block(survey, first, last)
  }
  form <- function(wave, fields, explicitly_absent = NULL) {
    observed <- questionnaire_form_answers(survey, unique(fields))
    if (is.null(explicitly_absent)) {
      explicitly_absent <- rep(FALSE, nrow(survey))
    }
    stopifnot(
      length(explicitly_absent) == nrow(survey),
      !anyNA(explicitly_absent), !any(observed & explicitly_absent)
    )
    tibble::tibble(
      source_row = survey$source_row, wave,
      wave_observed = dplyr::case_when(
        observed ~ TRUE, explicitly_absent ~ FALSE, TRUE ~ NA
      ),
      evidence_basis = dplyr::case_when(
        observed ~ "observed_full_questionnaire_answers",
        explicitly_absent ~ "source_indicator_and_empty_questionnaire",
        TRUE ~ "empty_questionnaire_without_return_indicator"
      )
    )
  }
  switch(poll,
    "cpl-1996" = form(
      "t2",
      names(survey)[grepl("2$", names(survey)) &
                      !startsWith(names(survey), "know")],
      as.numeric(survey$part) %in% 2
    ),
    "uk-health-1998" = form(
      "t2", block("mtneed2", "dopint"),
      as.numeric(survey$manwkend) %in% 0
    ),
    "uk-crime-1994" = form("t2", c(
      names(survey)[grepl("\\(QQ", toupper(labels)) &
                      !grepl("^(lk|pk)[0-9]$", names(survey))],
      "kw12", "kw22", "kw32", "kw42", "pkw12", "pkw22", "pkw32"
    ), as.numeric(survey$part) %in% 0),
    "uk-general-election-1997" = {
      fields <- block("int2", "dopint")
      fields <- fields[!grepl("recod|correct|derived", labels[fields],
                         ignore.case = TRUE
                       ) & !grepl("(re|co|cor)$", fields)]
      form("t2", fields, as.numeric(survey$partic) %in% 0)
    },
    "europolis-2009" = form(
      "t2",
      names(survey)[grepl("^V3Q[0-9]", names(survey))],
      as.numeric(survey$GROUP_T1BIS) %in% c(2, 3) & is.na(survey$WAVE3)
    ),
    "tomorrows-europe-2007" = form(
      "t2",
      names(survey)[grepl("^t3q[0-9]+[a-z]?(_[0-9]+)?$",
        names(survey),
        ignore.case = TRUE
      )]
    ),
    "btp-presidential-primaries-2004" = dplyr::bind_rows(
      form("t1", names(survey)[grepl("^b1q[0-9]", names(survey))]),
      form(
        "t2", names(survey)[grepl("^f1q[0-9]", names(survey))],
        as.numeric(survey$compf1) %in% 2
      )
    ),
    "nic2-2003" = {
      fields <- c(
        setdiff(block("qfp1", "qisum"), "qisum"),
        block("eval1a", "sq5b")
      )
      empty <- !questionnaire_form_answers(survey, fields)
      before_income <- as.numeric(survey$isum[empty])
      after_income <- as.numeric(survey$qisum[empty])
      stopifnot(all(
        (is.na(before_income) & is.na(after_income)) |
          (!is.na(before_income) & !is.na(after_income) &
             before_income == after_income)
      ))
      dplyr::bind_rows(
        form("t1", block("fp1", "isum")), form("t2", fields)
      )
    },
    "nic-1996" = dplyr::bind_rows(
      form("t1", setdiff(block("AGE18UP1", "POLDEM1"), "PARTYST1")),
      form("t2", c(
        block("NICWAS2", "DISCBAL2"),
        block("GOVSAY2", "POLDEM2")
      ))
    ),
    "zeguo-2005" = form("t1", block("Gender", "d3046")),
    stop("No reviewed questionnaire-presence rule for ", poll)
  )
}

analysis_reviewed_presence <- function(participants, surveys = NULL) {
  supported <- c(
    "cpl-1996", "uk-health-1998", "uk-crime-1994",
    "uk-general-election-1997", "europolis-2009",
    "tomorrows-europe-2007", "btp-presidential-primaries-2004",
    "nic2-2003", "nic-1996", "zeguo-2005"
  )
  people <- participants |>
    dplyr::filter(
      poll_id %in% supported,
      source_dataset %in% c("historical", "cor_sood")
    )
  if (!nrow(people)) {
    return(NULL)
  }
  join_questionnaire_evidence(people, surveys, questionnaire_form_evidence)
}

join_questionnaire_evidence <- function(people, surveys, build) {
  if (!nrow(people)) return(NULL)
  contracts <- read_metadata("respondent_sources")
  purrr::map(unique(people$poll_id), function(poll) {
    survey <- if (is.null(surveys)) read_poll_survey(poll) else surveys[[poll]]
    stopifnot(
      !is.null(survey), !anyNA(survey$source_row),
      !anyDuplicated(survey$source_row)
    )
    contract <- contracts[contracts$poll_id == poll, ]
    stopifnot(nrow(contract) == 1L)
    identities <- source_people(survey, contract)
    selected <- people[people$poll_id == poll, ]
    stopifnot(!anyDuplicated(
      selected[c("source_dataset", "respondent_id")]
    ))
    position <- match(selected$source_row, identities$source_row)
    stopifnot(!anyNA(position))
    expected <- identities$respondent_id[position]
    file_scoped <- startsWith(expected, paste0(contract$source_id, ":"))
    cor_file_row <- selected$source_dataset == "cor_sood" & file_scoped &
      selected$respondent_id == paste0("source-row-", selected$source_row)
    stopifnot(all(selected$respondent_id == expected | cor_file_row))
    selected |>
      dplyr::select(
        "poll_id", "source_dataset", "respondent_id", "source_row"
      ) |>
      dplyr::left_join(build(survey, poll),
        by = "source_row", relationship = "many-to-many"
      ) |>
      dplyr::select(-"source_row")
  }) |>
    purrr::list_rbind()
}

analysis_te_arrival_presence <- function(participants, survey = NULL) {
  people <- participants |>
    dplyr::filter(poll_id == "tomorrows-europe-2007",
      source_dataset %in% c("historical", "cor_sood")
    )
  surveys <- if (is.null(survey)) {
    NULL
  } else {
    list(`tomorrows-europe-2007` = survey)
  }
  join_questionnaire_evidence(people, surveys, function(survey, poll) {
    te_arrival_form_evidence(survey)
  })
}

te_arrival_form_evidence <- function(survey) {
  fields <- names(survey)[grepl(
    "^t2q[0-9]+[a-z]?(_[0-9]+)?$", names(survey), ignore.case = TRUE
  )]
  observed <- questionnaire_form_answers(survey, fields)
  tibble::tibble(
    source_row = survey$source_row, wave = "t1",
    wave_observed = dplyr::if_else(observed, TRUE, NA),
    evidence_basis = dplyr::if_else(observed,
      "observed_full_questionnaire_answers",
      "empty_arrival_form_administrative_missingness_possible"
    )
  )
}
