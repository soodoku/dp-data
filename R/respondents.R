source(project_path("R", "respondent_health.R"))
source(project_path("R", "respondent_eu.R"))
source(project_path("R", "respondent_recode.R"))
source(project_path("R", "respondent_harmonized.R"))
source(project_path("R", "respondent_monarchy.R"))
source(project_path("R", "respondent_election.R"))
source(project_path("R", "respondent_utilities.R"))
source(project_path("R", "respondent_crime.R"))
source(project_path("R", "respondent_nic.R"))
source(project_path("R", "respondent_bulgaria.R"))
source(project_path("R", "respondent_australia.R"))
source(project_path("R", "respondent_tomorrows_europe.R"))
source(project_path("R", "respondent_europolis.R"))
source(project_path("R", "respondent_btp_general.R"))
source(project_path("R", "respondent_btp_health.R"))
source(project_path("R", "respondent_btp_national.R"))
source(project_path("R", "respondent_san_mateo.R"))
source(project_path("R", "respondent_btp_primaries.R"))
source(project_path("R", "respondent_nic2.R"))
source(project_path("R", "respondent_new_haven.R"))
source(project_path("R", "respondent_zeguo.R"))

historical_nic2_ids <- function(survey) {
  bridge <- readr::read_csv(project_path(
    "data", "nic2-2003", "historical-ids.csv"
  ), show_col_types = FALSE)
  stopifnot(
    !anyNA(bridge$nicid), !anyDuplicated(bridge$nicid),
    !anyDuplicated(bridge$historical_caseid)
  )
  selected <- as.numeric(survey$casetype) %in% 1
  stopifnot(setequal(as.numeric(survey$nicid[selected]), bridge$nicid))
  as.character(bridge$historical_caseid[
    match(as.numeric(survey$nicid), bridge$nicid)
  ])
}

historical_new_haven_ids <- function(survey) {
  path <- project_path("data", "new-haven-2004", "historical-ids.csv")
  bridge <- readr::read_csv(path, show_col_types = FALSE)
  stopifnot(
    !anyNA(bridge$assigned), !anyDuplicated(bridge$assigned),
    !anyDuplicated(bridge$historical_caseid),
    setequal(survey$assigned, bridge$assigned)
  )
  position <- match(survey$assigned, bridge$assigned)
  as.character(bridge$historical_caseid[position])
}

source_people <- function(survey, contract) {
  source_id <- contract$source_id[[1]]
  column <- contract$id_column[[1]]
  raw_id <- rep(NA_character_, nrow(survey))
  if (!is.na(column) && nzchar(column)) {
    stopifnot(column %in% names(survey))
    values <- survey[[column]]
    raw_id <- if (is.numeric(values)) {
      as.character(rounded_source_code(values))
    } else {
      as.character(values)
    }
  }
  absent <- is.na(raw_id) | raw_id == ""
  repeated <- duplicated(raw_id) | duplicated(raw_id, fromLast = TRUE)
  usable <- !absent & !repeated
  tibble::tibble(
    poll_id = contract$poll_id[[1]],
    respondent_id = ifelse(usable, raw_id, paste0(
      source_id, ":source-row-", survey$source_row
    )),
    source_id = source_id, source_row = as.integer(survey$source_row),
    source_respondent_id = raw_id,
    historical_respondent_id = switch(contract$poll_id[[1]],
      "uk-health-1998" = raw_id,
      "uk-eu-1995" = raw_id,
      "australia-republic-1999" = raw_id,
      "tomorrows-europe-2007" = raw_id,
      "europolis-2009" = paste0("71", raw_id),
      "btp-general-election-2004" = as.character(940000 + survey$source_row),
      "btp-national-2003" = as.character(930000 + survey$source_row),
      "btp-health-education-2005" = as.character(970000 + survey$source_row),
      "btp-presidential-primaries-2004" = as.character(
        950000 + survey$source_row
      ),
      "san-mateo-2008" = san_mateo_historical_ids(survey),
      "nic2-2003" = historical_nic2_ids(survey),
      "new-haven-2004" = historical_new_haven_ids(survey),
      "zeguo-2005" = as.character(52000 + survey$p),
      "uk-general-election-1997" = raw_id,
      "nic-1996" = raw_id,
      "wtu-1996" = raw_id,
      "swepco-1996" = raw_id,
      "bulgaria-crime-2002" = paste0("53", 10000 + survey$source_row),
      "cpl-1996" = paste0("29", 10000 + survey$source_row),
      "uk-monarchy-1996" = as.character(1000 + survey$source_row),
      "uk-crime-1994" = as.character(10000 + survey$source_row),
      rep(NA_character_, nrow(survey))
    ),
    identity_basis = ifelse(usable, "unique-source-id", ifelse(
      absent, "file-scoped-missing-id", "file-scoped-ambiguous-id"
    ))
  )
}

source_wave_label <- function(poll_id, wave) {
  if (poll_id %in% c("europolis-2009", "tomorrows-europe-2007")) {
    return(ifelse(wave == 1L, "T1", "T3"))
  }
  if (poll_id == "btp-general-election-2004") {
    return(ifelse(wave == 1L, "W4B", "W4F"))
  }
  if (poll_id == "btp-health-education-2005") {
    return(ifelse(wave == 1L, "pre", "post"))
  }
  if (poll_id == "bulgaria-crime-2002") {
    return(ifelse(wave == 1L, "pre", "post"))
  }
  paste0("T", wave)
}

source_response_rows <- function(survey, people, inputs, items) {
  fields <- union(inputs$source_column, items$source_column)
  stopifnot(all(fields %in% names(survey)))
  ordinal_rules <- read_metadata("harmonized_ordinal_measures") |>
    dplyr::filter(.data$poll_id == people$poll_id[[1]])
  dictionary_path <- project_path("data", people$poll_id[[1]], "variables.csv")
  dictionary <- readr::read_csv(dictionary_path, show_col_types = FALSE)
  purrr::map(fields, function(field) {
    raw <- survey[[field]]
    value <- if (is.numeric(raw)) {
      as.numeric(raw)
    } else {
      rep(NA_real_, length(raw))
    }
    text <- if (is.character(raw)) raw else rep(NA_character_, length(raw))
    item <- items[items$source_column == field, ]
    classified <- ifelse(abs(value - round(value)) < 1e-8, round(value), value)
    code <- ifelse(is.na(text), as.character(classified), text)
    missing <- is.na(value) & is.na(text)
    dictionary_missing <- dictionary$missing_values[
      dictionary$source_column == field
    ]
    dictionary_missing <- dictionary_missing[!is.na(dictionary_missing)]
    known_missing <- unique(unlist(strsplit(
      as.character(dictionary_missing), "|",
      fixed = TRUE
    )))
    range <- dictionary$missing_range[dictionary$source_column == field]
    range <- as.numeric(unlist(strsplit(
      as.character(range[!is.na(range)]), "|",
      fixed = TRUE
    )))
    in_range <- rep(FALSE, length(value))
    if (length(range)) {
      stopifnot(length(range) == 2L, !anyNA(range), range[1] <= range[2])
      in_range <- !is.na(classified) & classified >= range[1] &
        classified <= range[2]
    }
    known_values <- character()
    if (nrow(item)) {
      known_missing <- union(
        known_missing,
        unique(unlist(strsplit(item$missing_values, "|", fixed = TRUE)))
      )
      known_values <- unique(unlist(strsplit(c(
        item$correct_values, item$incorrect_values
      ), "|", fixed = TRUE)))
    }
    ordinal_rule <- ordinal_rules[ordinal_rules$source_column == field, ]
    if (nrow(ordinal_rule) && !is.na(ordinal_rule$missing_codes[[1]])) {
      known_missing <- union(known_missing, strsplit(
        ordinal_rule$missing_codes[[1]], "|", fixed = TRUE
      )[[1]])
    }
    if (people$poll_id[[1]] == "new-haven-2004" &&
          grepl("^(pre|mid|post)_q(12|13|20|21|22|23)$", field)) {
      known_missing <- union(known_missing, "0")
    }
    status <- ifelse(missing, "system-missing", ifelse(
      code %in% known_missing | in_range, "non-substantive", ifelse(
        nrow(item) == 0L | code %in% known_values, "answered", "unreviewed-code"
      )
    ))
    wave <- if (nrow(item)) {
      source_wave_label(people$poll_id[[1]], item$wave[[1]])
    } else if (people$poll_id[[1]] == "uk-health-1998") {
      if (grepl("[12]$", field)) {
        paste0("T", substr(
          field, nchar(field),
          nchar(field)
        ))
      } else {
        "T1"
      }
    } else if (people$poll_id[[1]] %in%
      c(
        "uk-eu-1995", "uk-general-election-1997", "cpl-1996",
        "wtu-1996", "swepco-1996", "uk-crime-1994"
      )) {
      if (grepl("[12]$", field)) {
        paste0("T", substr(
          field, nchar(field),
          nchar(field)
        ))
      } else {
        "T1"
      }
    } else if (people$poll_id[[1]] == "uk-monarchy-1996") {
      if (startsWith(field, "R")) "T2" else "T1"
    } else {
      NA_character_
    }
    tibble::tibble(
      poll_id = people$poll_id, respondent_id = people$respondent_id,
      source_column = field, source_wave = wave,
      raw_numeric = value, raw_text = text, response_status = status,
      missing_code = ifelse(missing, "system", ifelse(
        status == "non-substantive", code, NA_character_
      ))
    )
  }) |>
    purrr::list_rbind()
}

individual_measure_rows <- function(values, people, responses,
                                    definitions, inputs) {
  stopifnot(setequal(
    setdiff(names(values), c("dpnum", "caseid")), definitions$measure_id
  ))
  purrr::map(seq_len(nrow(definitions)), function(i) {
    definition <- definitions[i, ]
    fields <- inputs$source_column[
      inputs$definition_id == definition$definition_id
    ]
    observed <- responses |>
      dplyr::filter(.data$source_column %in% fields) |>
      dplyr::group_by(.data$respondent_id) |>
      dplyr::summarise(
        n = sum(.data$response_status == "answered"),
        .groups = "drop"
      )
    tibble::tibble(
      poll_id = people$poll_id, respondent_id = people$respondent_id,
      definition_id = definition$definition_id,
      value_numeric = as.numeric(values[[definition$measure_id]]),
      n_source_fields = as.integer(length(fields)),
      n_observed_fields = if (length(fields)) {
        as.integer(observed$n[
          match(people$respondent_id, observed$respondent_id)
        ])
      } else {
        rep(0L, nrow(people))
      }
    )
  }) |>
    purrr::list_rbind()
}

build_poll_respondents <- function(contract) {
  poll_id <- contract$poll_id[[1]]
  survey <- read_poll_survey(poll_id)
  if (poll_id == "btp-general-election-2004") {
    survey <- augment_btp_general_source(survey)
  }
  people <- source_people(survey, contract)
  stopifnot(!anyNA(people$respondent_id), !anyDuplicated(people$respondent_id))
  selected <- if (poll_id %in% read_metadata("knowledge_batteries")$poll_id) {
    knowledge_participants(poll_id, survey)
  } else {
    tibble::tibble(source_row = integer(), group_id = character())
  }
  sample_rows <- function(name, included, evidence) {
    tibble::tibble(
      poll_id = poll_id, respondent_id = people$respondent_id,
      sample_id = name, included = included, evidence = evidence
    )
  }
  historical <- if (poll_id %in% c(
    "uk-health-1998", "bulgaria-crime-2002",
    "new-haven-2004", "btp-national-2003"
  )) {
    rep(TRUE, nrow(survey))
  } else if (poll_id == "uk-eu-1995") {
    as.numeric(survey$part) == 1
  } else if (poll_id == "uk-monarchy-1996") {
    as.numeric(survey$GROUP) != -1
  } else if (poll_id == "uk-general-election-1997") {
    as.numeric(survey$filter) == 1
  } else if (poll_id == "uk-crime-1994") {
    as.numeric(survey$part) == 1 & !is.na(survey$group)
  } else if (poll_id == "cpl-1996") {
    !is.na(survey$group)
  } else if (poll_id %in% c("wtu-1996", "swepco-1996", "nic-1996")) {
    rounded_source_code(survey$PART) == 1
  } else if (poll_id == "australia-republic-1999") {
    !is.na(survey$group) & as.numeric(survey$group) != 100
  } else if (poll_id == "tomorrows-europe-2007") {
    !is.na(survey$group_no)
  } else if (poll_id == "europolis-2009") {
    as.numeric(survey[[match("group_t1bis", tolower(names(survey)))]]) == 1
  } else if (poll_id == "btp-presidential-primaries-2004") {
    primaries_sample(survey)
  } else if (poll_id == "btp-health-education-2005") {
    as.numeric(survey$filter) == 1
  } else if (poll_id == "zeguo-2005") {
    !is.na(survey$groupnum) & !is.na(survey$preandpost)
  } else if (poll_id == "nic2-2003") {
    as.numeric(survey$casetype) == 1
  } else if (poll_id == "san-mateo-2008") {
    as.numeric(survey$participant) == 1
  } else if (poll_id == "btp-general-election-2004") {
    value <- build_btp_general_individual(survey)
    post_items <- paste0("w4f", c(60, 61, 62, 63, 64, 65, 66, 68, 69))
    stopifnot(all(post_items %in% names(survey)))
    post_observed <- rowSums(!is.na(survey[post_items])) > 0
    post_observed & !is.na(value$attitude_extremity)
  } else {
    rep(NA, nrow(survey))
  }
  historical_evidence <- if (poll_id == "uk-health-1998") {
    "uk_health.R: all 230 source rows"
  } else if (poll_id == "uk-eu-1995") {
    "uk_eu.R: part == 1; 238 source attendees"
  } else {
    switch(poll_id,
      "uk-monarchy-1996" = "uk_monarchy.R: GROUP != -1; 258 attendees",
      "new-haven-2004" = "All 132 participants; unique raw-ID wave joins",
      "zeguo-2005" = "groupnum and preandpost nonmissing; 233 attendees",
      "btp-presidential-primaries-2004" =
        "Treatment, assigned group, >=3 meetings and post survey; 217 people",
      "uk-general-election-1997" = "uk_bge.R: filter == 1; 275 attendees",
      "uk-crime-1994" = paste(
        "uk_crime.R: part == 1 and nonmissing group; 299 attendees"
      ),
      "cpl-1996" = "tx_cpl.R: nonmissing group; 216 attendees",
      "bulgaria-crime-2002" = "bulgaria.r: all 278 source rows",
      "nic-1996" = "nic1.R: PART == 1; 466 attendees",
      "wtu-1996" = "tx_wtu.R: PART == 1; 230 attendees",
      "swepco-1996" = "tx_swp.R: PART == 1; 232 attendees",
      "australia-republic-1999" = "aus_republic.R: nonmissing group except100",
      "tomorrows-europe-2007" = "eu_2007.R: nonmissing group_no",
      "europolis-2009" = "eu_2009.R: Group_T1bis == 1",
      "btp-general-election-2004" = paste(
        "BTPGE-05: observed post knowledge response and extremity;",
        "zero correct answers remain eligible"
      ),
      "btp-health-education-2005" = "filter == 1; 454 records",
      "nic2-2003" = "casetype == 1; 340 records",
      "btp-national-2003" = "All 245 selected HLM source records",
      "san-mateo-2008" = "participant == 1; 239 records",
      "btp-presidential-primaries-2004" = "primaries_sample: 217 unique people",
      "Historical identity and selection remain unresolved"
    )
  }
  samples <- dplyr::bind_rows(
    sample_rows("reviewed-source", TRUE, contract$source_id),
    sample_rows(
      "knowledge-battery", people$source_row %in% selected$source_row,
      "metadata/knowledge_join_contracts.csv"
    ),
    sample_rows(
      "historical-polardata",
      historical, historical_evidence
    )
  )
  if (poll_id == "uk-eu-1995") {
    selected <- survey[as.numeric(survey$part) == 1 &
                         as.numeric(survey$group) %in% 1:15, ] |>
      dplyr::transmute(
        source_row = .data$source_row,
        group_id = as.character(as.numeric(.data$group))
      )
  }
  if (poll_id == "btp-presidential-primaries-2004") {
    selected <- tibble::tibble(
      source_row = survey$source_row[historical],
      group_id = as.character(survey$groupnumc[historical])
    )
  }
  if (poll_id %in% c("new-haven-2004", "zeguo-2005", "nic2-2003")) {
    group <- if (poll_id == "zeguo-2005") survey$groupnum else survey$group
    selected <- tibble::tibble(
      source_row = survey$source_row[historical],
      group_id = as.character(group[historical])
    )
  }
  if (poll_id == "btp-national-2003") {
    selected <- tibble::tibble(
      source_row = survey$source_row,
      group_id = as.character(9300 + as.numeric(survey$group))
    )
  }
  selected <- selected[!is.na(selected$group_id), ]
  memberships <- tibble::tibble(
    poll_id = rep(poll_id, nrow(selected)),
    respondent_id = people$respondent_id[
      match(selected$source_row, people$source_row)
    ],
    session_id = rep("deliberation", nrow(selected)),
    group_id = selected$group_id, weight = rep(1, nrow(selected))
  )
  definitions <- read_metadata("measure_definitions") |>
    dplyr::filter(.data$poll_id == .env$poll_id)
  harmonized <- read_metadata("harmonized_ordinal_measures") |>
    dplyr::filter(.data$poll_id == .env$poll_id)
  inputs <- read_metadata("measure_inputs") |>
    dplyr::filter(.data$poll_id == .env$poll_id)
  items <- read_metadata("knowledge_items") |>
    dplyr::filter(.data$poll_id == .env$poll_id)
  responses <- source_response_rows(survey, people, inputs, items)
  builder <- switch(poll_id,
    "uk-health-1998" = build_health_individual,
    "uk-eu-1995" = build_eu_individual,
    "uk-monarchy-1996" = build_monarchy_individual,
    "uk-general-election-1997" = build_election_individual,
    "uk-crime-1994" = build_crime_individual,
    "nic-1996" = build_nic_individual,
    "bulgaria-crime-2002" = build_bulgaria_individual,
    "australia-republic-1999" = build_australia_individual,
    "tomorrows-europe-2007" = build_tomorrow_individual,
    "europolis-2009" = build_europolis_individual,
    "btp-general-election-2004" = build_btp_general_individual,
    "btp-health-education-2005" = build_btp_health_individual,
    "btp-national-2003" = build_btp_national_individual,
    "san-mateo-2008" = build_san_mateo_individual,
    "nic2-2003" = build_nic2_individual,
    "new-haven-2004" = build_new_haven_individual,
    "zeguo-2005" = build_zeguo_individual,
    "btp-presidential-primaries-2004" = build_btp_primaries_individual
  )
  if (poll_id %in% c("cpl-1996", "wtu-1996", "swepco-1996")) {
    builder <- function(survey) build_utility_individual(survey, poll_id)
  }
  measures <- if (!is.null(builder)) {
    values <- builder(survey)
    dplyr::bind_rows(
      individual_measure_rows(
        values, people, responses,
        definitions[!definitions$definition_id %in%
                      harmonized$definition_id, ], inputs
      ),
      harmonized_ordinal_rows(people, responses, harmonized)
    )
  } else {
    tibble::tibble(
      poll_id = character(), respondent_id = character(),
      definition_id = character(), value_numeric = double(),
      n_source_fields = integer(), n_observed_fields = integer()
    )
  }
  list(
    people = people, sample_memberships = samples,
    source_responses = responses, respondent_measures = measures,
    respondent_memberships = memberships
  )
}

validate_respondent_tables <- function(tables) {
  columns <- read_metadata("canonical_columns")
  for (name in names(tables)) {
    schema <- columns[columns$table == name, ]
    data <- tables[[name]]
    stopifnot(
      setequal(names(data), schema$column),
      !anyNA(data[schema$column[!schema$nullable]]),
      !anyDuplicated(data[schema$column[schema$key]])
    )
  }
  people <- tables$people
  stopifnot(
    !anyDuplicated(people[c("source_id", "source_row")]),
    all(people$source_row > 0L)
  )
  key <- paste(people$poll_id, people$respondent_id)
  stopifnot(!anyDuplicated(key))
  for (name in setdiff(names(tables), "people")) {
    data <- tables[[name]]
    stopifnot(all(paste(data$poll_id, data$respondent_id) %in% key))
  }
  measures <- tables$respondent_measures
  definitions <- read_metadata("measure_definitions")
  stopifnot(
    all(paste(measures$poll_id, measures$definition_id) %in%
          paste(definitions$poll_id, definitions$definition_id)),
    all(measures$n_observed_fields <= measures$n_source_fields),
    !anyNA(measures$n_observed_fields),
    all(measures$n_observed_fields >= 0L),
    all(is.na(measures$value_numeric) | is.finite(measures$value_numeric))
  )
  inputs <- read_metadata("measure_inputs")
  measure_lookup <- purrr::map(
    split(measures, measures$poll_id),
    function(poll) split(poll, poll$definition_id)
  )
  for (i in seq_len(nrow(definitions))) {
    definition <- definitions[i, ]
    rows <- measure_lookup[[definition$poll_id]][[definition$definition_id]]
    stopifnot(!is.null(rows))
    dependencies <- inputs$source_column[
      inputs$poll_id == definition$poll_id &
        inputs$definition_id == definition$definition_id
    ]
    stopifnot(
      setequal(rows$respondent_id, people$respondent_id[
        people$poll_id == definition$poll_id
      ]),
      all(rows$n_source_fields == length(dependencies))
    )
  }
  responses <- tables$source_responses
  stopifnot(
    !any(!is.na(responses$raw_numeric) & !is.na(responses$raw_text)),
    all(responses$response_status %in% c(
      "system-missing", "non-substantive",
      "answered", "unreviewed-code"
    ))
  )
  invisible(TRUE)
}
