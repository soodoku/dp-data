knowledge_form_unavailable <- function(poll, observed) {
  stopifnot(length(poll) == length(observed), is.logical(observed))
  !observed %in% TRUE
}

mask_reviewed_knowledge_items <- function(items, presence) {
  if (is.null(presence) || !nrow(presence)) {
    return(items)
  }
  keys <- c("poll_id", "source_dataset", "respondent_id", "wave")
  stopifnot(!anyDuplicated(presence[keys]))
  position <- match(
    do.call(paste, items[keys]), do.call(paste, presence[keys])
  )
  reviewed <- !is.na(position)
  observed <- presence$wave_observed[position]
  unobserved <- reviewed & knowledge_form_unavailable(items$poll_id, observed)
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
    "nic-1996" = if (wave %in% c("1", "2")) {
      paste0("t", wave)
    } else {
      NA_character_
    },
    "zeguo-2005" = if (wave == "pre") "t1" else NA_character_,
    "btp-presidential-primaries-2004" =
      c(b1 = "t1", f1 = "t2")[[wave]],
    "nic2-2003" = paste0("t", wave),
    if (wave == "2") "t2" else NA_character_
  )
  if (poll == "tomorrows-europe-2007" && wave == "2") {
    evidence <- te_arrival_form_evidence(survey)
  } else {
    if (is.na(selected_wave)) {
      return(items)
    }
    evidence <- questionnaire_form_evidence(survey, poll, selected_wave)
  }
  stopifnot(!anyDuplicated(evidence$source_row))
  position <- match(questionnaire_local_rows(survey), evidence$source_row)
  stopifnot(length(position) == nrow(items), !anyNA(position))
  unavailable <- knowledge_form_unavailable(
    rep(poll, nrow(items)), evidence$wave_observed[position]
  )
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

questionnaire_field_block <- function(dictionary, first, last) {
  stopifnot(all(c("source_column", "public") %in% names(dictionary)))
  fields <- dictionary$source_column[dictionary$public]
  positions <- match(c(first, last), fields)
  stopifnot(!anyNA(positions), positions[1L] <= positions[2L])
  fields[seq.int(positions[1L], positions[2L])]
}

questionnaire_form_contract <- function(poll) {
  dictionaries <- read_metadata("survey_sources")
  record <- dictionaries[dictionaries$poll_id == poll, ]
  stopifnot(nrow(record) == 1L)
  dictionary <- readr::read_csv(project_path(
    dirname(record$public_path), "variables.csv"
  ), show_col_types = FALSE)
  dictionary <- dictionary[dictionary$public, ]
  fields <- dictionary$source_column
  labels <- stats::setNames(dictionary$variable_label, fields)
  labels[is.na(labels)] <- ""
  block <- function(first, last) {
    questionnaire_field_block(dictionary, first, last)
  }
  matching <- function(pattern) {
    fields[grepl(pattern, fields, ignore.case = TRUE)]
  }
  form <- function(original_wave, wave, answers, auxiliary = character(),
                   implementation = "questionnaire_form_evidence") {
    stopifnot(all(c(answers, auxiliary) %in% fields))
    tibble::tibble(original_wave, wave, implementation,
      fields = list(unique(answers)), auxiliary = list(auxiliary)
    )
  }
  switch(poll,
    "cpl-1996" = form(
      "T2", "t2",
      fields[grepl("2$", fields) & !startsWith(fields, "know")], "part"
    ),
    "san-mateo-2008" = {
      answers <- block("t2Q1", "t2q42")
      answers <- answers[grepl("^t2[qQ]", answers)]
      form("T2", "t2", answers, c("participant", "t2QSTGRP"))
    },
    "uk-eu-1995" = form(
      "T2", "t2", fields[grepl("SAQ2", labels, fixed = TRUE)], "part"
    ),
    "uk-health-1998" = form(
      "T2", "t2", block("mtneed2", "dopint"),
      "manwkend"
    ),
    "uk-crime-1994" = form("T2", "t2", c(
      fields[grepl("\\(QQ", toupper(labels)) &
               !grepl("^(lk|pk)[0-9]$", fields)],
      "kw12", "kw22", "kw32", "kw42", "pkw12", "pkw22", "pkw32"
    ), "part"),
    "uk-general-election-1997" = {
      answers <- block("int2", "dopint")
      answers <- answers[!grepl("recod|correct|derived", labels[answers],
                           ignore.case = TRUE
                         ) & !grepl("(re|co|cor)$", answers)]
      form("T2", "t2", answers, "partic")
    },
    "europolis-2009" = form(
      "T3", "t2", matching("^V3Q[0-9]"),
      c("GROUP_T1BIS", "WAVE3")
    ),
    "tomorrows-europe-2007" = dplyr::bind_rows(
      form("T2", "arrival", matching("^t2q[0-9]+[a-z]?(_[0-9]+)?$")),
      form("T3", "t2", matching("^t3q[0-9]+[a-z]?(_[0-9]+)?$"))
    ),
    "btp-presidential-primaries-2004" = dplyr::bind_rows(
      form("T1", "t1", setdiff(
        matching("^b1q[0-9]"),
        matching("cor$|_r$")
      )),
      form("T2", "t2", setdiff(
        matching("^f1q[0-9]"),
        matching("cor$|_r$")
      ), "compf1")
    ),
    "nic2-2003" = dplyr::bind_rows(
      form("T1", "t1", block("fp1", "isum")),
      form("T2", "t2", c(
        setdiff(block("qfp1", "qisum"), "qisum"),
        block("eval1a", "sq5b")
      ), c("isum", "qisum"))
    ),
    "nic-1996" = dplyr::bind_rows(
      form("T1", "t1", setdiff(block("AGE18UP1", "POLDEM1"), "PARTYST1")),
      form("T2", "t2", c(
        block("NICWAS2", "DISCBAL2"),
        block("GOVSAY2", "POLDEM2")
      ))
    ),
    "zeguo-2005" = dplyr::bind_rows(
      form("T1", "t1", block("Gender", "d3046")),
      form("T2", "t2", c(
        paste0("d20", sprintf("%02d", 6:35), "p"),
        paste0("post_d304", 3:6)
      ), c("pp", "preandpost"), "zeguo_departure_observed")
    ),
    stop("No reviewed questionnaire-presence rule for ", poll)
  )
}

questionnaire_local_rows <- function(survey) {
  rows <- survey[["source_row"]]
  if (is.null(rows)) rows <- seq_len(nrow(survey))
  stopifnot(length(rows) == nrow(survey), !anyNA(rows), !anyDuplicated(rows))
  rows
}

questionnaire_form_evidence <- function(survey, poll, waves = NULL) {
  contract <- questionnaire_form_contract(poll)
  contract <- contract[contract$implementation ==
                         "questionnaire_form_evidence", ]
  if (is.null(waves)) waves <- setdiff(contract$wave, "arrival")
  contract <- contract[contract$wave %in% waves, ]
  stopifnot(nrow(contract) == length(waves))
  purrr::map(seq_len(nrow(contract)), function(i) {
    form <- contract[i, ]
    required <- c(form$fields[[1]], form$auxiliary[[1]])
    absent <- setdiff(required, names(survey))
    if (length(absent)) {
      stop("Missing questionnaire-presence fields: ", paste(absent,
        collapse = ", "
      ))
    }
    observed <- questionnaire_form_answers(survey, form$fields[[1]])
    if (poll == "uk-eu-1995") {
      answers <- survey[form$fields[[1]]]
      answers[] <- lapply(answers, function(value) {
        value <- as.numeric(value)
        value[value == -1 & !is.na(value)] <- NA_real_
        value
      })
      observed <- questionnaire_form_answers(answers, names(answers))
    }
    explicitly_absent <- switch(poll,
      "cpl-1996" = as.numeric(survey$part) %in% 2,
      "san-mateo-2008" = !observed,
      "uk-eu-1995" = as.numeric(survey$part) %in% 0 & !observed,
      "uk-health-1998" = as.numeric(survey$manwkend) %in% 0,
      "uk-crime-1994" = as.numeric(survey$part) %in% 0,
      "uk-general-election-1997" = as.numeric(survey$partic) %in% 0,
      "europolis-2009" = as.numeric(survey$GROUP_T1BIS) %in% c(2, 3) &
        is.na(survey$WAVE3),
      "btp-presidential-primaries-2004" = if (form$wave == "t2") {
        as.numeric(survey$compf1) %in% 2
      } else {
        rep(FALSE, nrow(survey))
      },
      rep(FALSE, nrow(survey))
    )
    stopifnot(
      length(explicitly_absent) == nrow(survey),
      !anyNA(explicitly_absent), !any(observed & explicitly_absent)
    )
    if (poll == "nic2-2003" && form$wave == "t2") {
      before_income <- as.numeric(survey$isum[!observed])
      after_income <- as.numeric(survey$qisum[!observed])
      stopifnot(all(
        (is.na(before_income) & is.na(after_income)) |
          (!is.na(before_income) & !is.na(after_income) &
             before_income == after_income)
      ))
    }
    tibble::tibble(
      source_row = questionnaire_local_rows(survey), wave = form$wave,
      wave_observed = dplyr::case_when(
        observed ~ TRUE, explicitly_absent ~ FALSE, TRUE ~ NA
      ),
      evidence_basis = dplyr::case_when(
        observed ~ "observed_full_questionnaire_answers",
        poll == "san-mateo-2008" & explicitly_absent ~
          "empty_post_questionnaire",
        explicitly_absent ~ "source_indicator_and_empty_questionnaire",
        form$wave == "arrival" ~
          "empty_arrival_form_administrative_missingness_possible",
        TRUE ~ "empty_questionnaire_without_return_indicator"
      )
    )
  }) |> purrr::list_rbind()
}

questionnaire_dependencies <- function(definitions) {
  knowledge <- grepl("know|^logpk$|^tobitpk$", definitions$measure_id)
  zeguo_post <- definitions$poll_id == "zeguo-2005" &
    grepl("T2", definitions$source_waves, fixed = TRUE)
  required <- (knowledge | zeguo_post) &
    definitions$scoring_rule != "historical-constant-missing"
  definitions <- definitions[required, ]
  purrr::map(unique(definitions$poll_id), function(poll) {
    contract <- questionnaire_form_contract(poll)
    selected <- definitions[definitions$poll_id == poll, ]
    purrr::map(seq_len(nrow(selected)), function(i) {
      definition <- selected[i, ]
      waves <- strsplit(definition$source_waves, "|", fixed = TRUE)[[1]]
      forms <- contract[contract$original_wave %in% waves, ]
      fields <- unique(unlist(c(forms$fields, forms$auxiliary)))
      if (!length(fields)) {
        return(NULL)
      }
      tibble::tibble(
        poll_id = poll, definition_id = definition$definition_id,
        source_column = fields
      )
    }) |> purrr::list_rbind()
  }) |>
    purrr::list_rbind()
}

analysis_reviewed_presence <- function(participants, surveys = NULL) {
  supported <- c(
    "cpl-1996", "san-mateo-2008", "uk-eu-1995",
    "uk-health-1998", "uk-crime-1994",
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
  if (!nrow(people)) {
    return(NULL)
  }
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
    dplyr::filter(
      poll_id == "tomorrows-europe-2007",
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
  result <- questionnaire_form_evidence(
    survey, "tomorrows-europe-2007", "arrival"
  )
  result$wave <- "t1"
  result
}
