source(project_path("R", "source_australia.R"))
source(project_path("R", "source_questionnaire_presence.R"))
source(project_path("R", "source_new_haven.R"))

analysis_new_haven_presence <- function(survey) {
  stopifnot(
    all(c("source_row", "assigned") %in% names(survey)),
    !anyNA(survey$source_row), !anyDuplicated(survey$source_row),
    !anyNA(survey$assigned), !anyDuplicated(survey$assigned)
  )
  tibble::tibble(
    source_row = survey$source_row,
    respondent_id = as.character(survey$assigned),
    departure_observed = new_haven_departure_observed(survey)
  )
}

source(project_path("R", "source_monarchy.R"))
source(project_path("R", "source_zeguo.R"))

analysis_phase_control_scores <- function(sources, roles) {
  specifications <- list(
    list(
      poll = "america-in-one-room-2019", data = sources$a1r,
      id = "source_row", prefix = "PK", questions = 1:7
    ),
    list(
      poll = "a1r-climate-2021", data = sources$climate,
      id = "CaseId", prefix = "Q", questions = 17:24
    )
  )
  catalog <- read_metadata("items")
  purrr::map(specifications, function(specification) {
    poll <- specification$poll
    data <- specification$data
    bank <- catalog |>
      dplyr::filter(poll_id == poll) |>
      dplyr::arrange(item_id)
    stopifnot(nrow(bank) == length(specification$questions))
    study_roles <- roles |>
      dplyr::filter(poll_id == poll, source_dataset == "control")
    purrr::map(seq_len(nrow(study_roles)), function(i) {
      role <- study_roles[i, ]
      prefix <- if (role$score_wave == "t1") "" else toupper(role$score_wave)
      columns <- paste0(prefix, specification$prefix, specification$questions)
      raw <- as.matrix(data[columns])
      correct <- rowSums(sweep(raw, 2L, as.numeric(bank$correct_codes), "=="),
        na.rm = TRUE
      )
      question_fields <- grep(paste0("^", prefix, "(Q[0-9]|PK[0-9]|D[0-9])"),
        names(data),
        value = TRUE
      )
      stopifnot(length(question_fields) > nrow(bank))
      observed <- rowSums(!is.na(data[question_fields])) > 0L
      tibble::tibble(
        poll_id = poll, source_dataset = "control",
        respondent_id = as.character(data[[specification$id]]),
        wave = role$wave, n_items = as.integer(nrow(bank)),
        n_observed = as.integer(rowSums(!is.na(raw))),
        n_correct = dplyr::if_else(observed, as.integer(correct), NA_integer_),
        score = dplyr::if_else(observed, correct / nrow(bank), NA_real_),
        scale = "proportion_correct", wave_observed = observed,
        original_score_wave = role$score_wave, wave_role = role$wave_role,
        timing_evidence = role$timing_evidence
      )
    }) |>
      purrr::list_rbind()
  }) |>
    purrr::list_rbind()
}

analysis_amr_presence <- function(survey) {
  fields <- grep(
    paste0("^(a_|b_|proposal_|statement_|value_|civic_|disagree_|",
           "trust_|knowledge_|eval_)[0-9]+(_[0-9]+)?$"),
    names(survey), value = TRUE
  )
  stopifnot(
    all(c("ID", "Time", paste0("knowledge_", 1:6)) %in% names(survey)),
    !anyNA(survey$ID), !anyNA(survey$Time), all(survey$Time %in% 0:1),
    !anyDuplicated(survey[c("ID", "Time")]), length(fields) > 6L
  )
  answered <- rowSums(!is.na(survey[fields])) > 0L
  tibble::tibble(
    poll_id = "amr-2024", source_dataset = "control",
    respondent_id = as.character(survey$ID),
    wave = paste0("t", survey$Time + 1L),
    form_observed = dplyr::if_else(answered, TRUE, NA)
  )
}

analysis_btp_followup_presence <- function(survey, poll) {
  if (poll == "btp-national-2003") {
    fields <- c("serial", "f_dt_st", "f_tm_st", "f_dt_end", "f_tm_end",
                "f_durat")
    stopifnot(all(fields %in% names(survey)))
    identifier <- survey$serial
    timed_interview <- stats::complete.cases(survey[fields[-1L]]) &
      survey$f_durat > 0 & survey$f_dt_st > 0 &
      survey$f_tm_st >= 0 & survey$f_tm_end >= 0 &
      (survey$f_dt_end > survey$f_dt_st |
         (survey$f_dt_end == survey$f_dt_st &
            survey$f_tm_end >= survey$f_tm_st))
    observed <- timed_interview %in% TRUE
  } else {
    stopifnot(
      poll == "btp-presidential-primaries-2004",
      all(c("caseid", "compf1") %in% names(survey)),
      all(is.na(survey$compf1) | survey$compf1 %in% 1:2)
    )
    identifier <- survey$caseid
    observed <- survey$compf1 %in% 1
  }
  stopifnot(!anyNA(identifier), !anyDuplicated(identifier))
  tibble::tibble(
    poll_id = poll, source_dataset = "historical",
    respondent_id = as.character(identifier), wave = "t2",
    form_observed = dplyr::if_else(observed, TRUE, NA)
  )
}

analysis_monarchy_presence <- function(survey) {
  tibble::tibble(
    source_row = survey$source_row,
    departure_observed = monarchy_departure_observed(survey)
  )
}

analysis_phase_presence <- function(
  scores, items, measures, definitions, targets, amr = NULL, participants = NULL
) {
  responses <- arrow::read_parquet(project_path(
    "output", "respondent", "source_responses.parquet"
  ), as_data_frame = FALSE)
  inputs <- read_metadata("measure_inputs")
  source_registry <- read_metadata("respondent_sources")
  item_presence <- items |>
    dplyr::summarise(
      raw_answer = any(!is.na(raw_value) | !is.na(raw_text)),
      absent = all(response_status == "wave_absent"),
      .by = c(poll_id, source_dataset, respondent_id, wave)
    ) |>
    dplyr::mutate(
      wave_observed = dplyr::case_when(
        absent ~ FALSE, raw_answer ~ TRUE, TRUE ~ NA
      )
    ) |>
    dplyr::select(-"raw_answer", -"absent")
  historical <- scores |>
    dplyr::filter(source_dataset == "historical") |>
    dplyr::distinct(poll_id, wave)
  evidence <- purrr::map(seq_len(nrow(historical)), function(i) {
    poll <- historical$poll_id[i]
    wave <- historical$wave[i]
    field <- if (wave == "t1") "t1know" else "t2know"
    target <- targets |>
      dplyr::filter(poll_id == poll, legacy_field == field)
    stopifnot(nrow(target) == 1L)
    definition <- definitions |>
      dplyr::filter(
        poll_id == poll,
        definition_id == target$canonical_definition
      )
    if (poll == "nic-1996" && wave == "t2") {
      definition <- definitions |>
        dplyr::filter(poll_id == poll, measure_id == "knowledge_midterm",
          scoring_rule != "historical-constant-missing"
        )
    }
    stopifnot(nrow(definition) == 1L)
    wave_definitions <- definitions |>
      dplyr::filter(
        poll_id == poll,
        source_waves == definition$source_waves
      )
    fields <- inputs |>
      dplyr::filter(
        poll_id == poll,
        definition_id %in% wave_definitions$definition_id
      ) |>
      dplyr::pull(source_column) |>
      unique()
    identifiers <- source_registry$id_column[source_registry$poll_id == poll]
    fields <- fields[!fields %in% c("source_row", "CASEID", identifiers)]
    fields <- fields[!grepl(
      "^(FFACT|EFACT|FTFACT|KNOW)[[:alnum:]]*$|^t[0-9]+(know|pk)",
      fields,
      ignore.case = TRUE
    )]
    responses |>
      dplyr::filter(poll_id == poll, source_column %in% fields) |>
      dplyr::select("poll_id", "respondent_id", "response_status",
                    "raw_numeric", "raw_text") |>
      dplyr::collect() |>
      dplyr::summarise(
        wave_observed = dplyr::if_else(
          any(response_status == "answered" &
                (!is.na(raw_numeric) | !is.na(raw_text))), TRUE, NA
        ),
        .by = c(poll_id, respondent_id)
      ) |>
      dplyr::mutate(source_dataset = "historical", wave)
  }) |>
    purrr::list_rbind()
  out <- dplyr::left_join(item_presence, evidence,
    by = c("poll_id", "source_dataset", "respondent_id", "wave"),
    relationship = "one-to-one", suffix = c("", "_source")
  ) |>
    dplyr::mutate(wave_observed = dplyr::coalesce(
      wave_observed, wave_observed_source
    )) |>
    dplyr::select(-"wave_observed_source")
  if (!is.null(participants)) {
    reviewed <- analysis_reviewed_presence(participants)
    if (!is.null(reviewed)) {
      reviewed <- reviewed |>
        dplyr::select(-"evidence_basis") |>
        dplyr::rename(reviewed_observed = "wave_observed") |>
        dplyr::mutate(presence_reviewed = TRUE)
      out <- out |>
        dplyr::left_join(reviewed,
          by = c("poll_id", "source_dataset", "respondent_id", "wave"),
          relationship = "one-to-one"
        ) |>
        dplyr::mutate(wave_observed = dplyr::if_else(
          presence_reviewed %in% TRUE, reviewed_observed, wave_observed
        )) |>
        dplyr::select(-"reviewed_observed", -"presence_reviewed")
    }
  }
  if (any(out$poll_id == "australia-republic-1999")) {
    people <- arrow::read_parquet(project_path(
      "output", "respondent", "people.parquet"
    )) |>
      dplyr::filter(poll_id == "australia-republic-1999") |>
      dplyr::mutate(source_dataset = "historical")
    forms <- analysis_australia_presence(people) |>
      dplyr::rename(departure_observed = wave_observed) |>
      dplyr::mutate(presence_reviewed = TRUE)
    out <- out |>
      dplyr::left_join(forms,
        by = c("poll_id", "source_dataset", "respondent_id", "wave"),
        relationship = "one-to-one"
      ) |>
      dplyr::mutate(wave_observed = dplyr::if_else(
        presence_reviewed %in% TRUE, departure_observed, wave_observed
      )) |>
      dplyr::select(-"departure_observed", -"presence_reviewed")
  }
  btp_polls <- intersect(unique(out$poll_id), c(
    "btp-national-2003", "btp-presidential-primaries-2004"
  ))
  if (any(out$poll_id == "new-haven-2004")) {
    survey <- read_poll_survey("new-haven-2004")
    forms <- analysis_new_haven_presence(survey) |>
      dplyr::mutate(poll_id = "new-haven-2004", wave = "t2") |>
      dplyr::select(-"source_row")
    out <- out |>
      dplyr::left_join(forms,
        by = c("poll_id", "respondent_id", "wave"),
        relationship = "many-to-one"
      ) |>
      dplyr::mutate(wave_observed = dplyr::coalesce(
        departure_observed, wave_observed
      )) |>
      dplyr::select(-"departure_observed")
  }
  if (any(out$poll_id == "uk-monarchy-1996")) {
    forms <- analysis_monarchy_presence(
      read_poll_survey("uk-monarchy-1996")
    )
    identities <- arrow::read_parquet(project_path(
      "output", "respondent", "people.parquet"
    )) |>
      dplyr::filter(poll_id == "uk-monarchy-1996") |>
      dplyr::select("poll_id", "respondent_id", "source_row")
    forms <- identities |>
      dplyr::left_join(forms, by = "source_row", relationship = "one-to-one") |>
      dplyr::mutate(source_dataset = "historical", wave = "t2") |>
      dplyr::select(-"source_row")
    out <- out |>
      dplyr::left_join(forms,
        by = c("poll_id", "source_dataset", "respondent_id", "wave"),
        relationship = "one-to-one"
      ) |>
      dplyr::mutate(wave_observed = dplyr::coalesce(
        departure_observed, wave_observed
      )) |>
      dplyr::select(-"departure_observed")
  }
  if (any(out$poll_id == "zeguo-2005")) {
    survey <- read_poll_survey("zeguo-2005")
    forms <- tibble::tibble(
      poll_id = "zeguo-2005", source_dataset = "historical",
      respondent_id = as.character(survey$p), wave = "t2",
      departure_observed = zeguo_departure_observed(survey)
    )
    out <- out |>
      dplyr::left_join(forms,
        by = c("poll_id", "source_dataset", "respondent_id", "wave"),
        relationship = "one-to-one"
      )
    stopifnot(
      !any(out$wave_observed %in% TRUE & out$departure_observed %in% FALSE)
    )
    out <- out |>
      dplyr::mutate(wave_observed = dplyr::coalesce(
        departure_observed, wave_observed
      )) |>
      dplyr::select(-"departure_observed")
  }
  if (length(btp_polls)) {
    forms <- purrr::map(btp_polls, function(poll) {
      analysis_btp_followup_presence(read_poll_survey(poll), poll)
    }) |>
      purrr::list_rbind()
    out <- out |>
      dplyr::left_join(forms,
        by = c("poll_id", "source_dataset", "respondent_id", "wave"),
        relationship = "one-to-one"
      )
    stopifnot(!any(out$wave_observed %in% FALSE & out$form_observed %in% TRUE))
    out <- out |>
      dplyr::mutate(wave_observed = dplyr::coalesce(
        wave_observed, form_observed
      )) |>
      dplyr::select(-"form_observed")
  }
  if (any(out$poll_id == "denmark-euro-2000" &
            out$source_dataset == "cor_sood" & out$wave == "t2")) {
    departure <- arrow::read_parquet(project_path(
      "data", "denmark-euro-2000", "departure.parquet"
    ))
    question_fields <- grep("^S[0-9]", names(departure), value = TRUE)
    stopifnot(length(question_fields) > 9L, !anyDuplicated(departure$DELNR))
    observed <- rowSums(!is.na(departure[question_fields])) > 0L
    evidence <- tibble::tibble(
      poll_id = "denmark-euro-2000", source_dataset = "cor_sood",
      respondent_id = as.character(departure$DELNR), wave = "t2",
      departure_observed = dplyr::if_else(observed, TRUE, NA)
    )
    out <- out |>
      dplyr::left_join(evidence,
        by = c("poll_id", "source_dataset", "respondent_id", "wave"),
        relationship = "one-to-one"
      ) |>
      dplyr::mutate(wave_observed = dplyr::coalesce(
        wave_observed, departure_observed
      )) |>
      dplyr::select(-"departure_observed")
  }
  if (any(out$poll_id == "amr-2024")) {
    if (is.null(amr)) {
      amr <- readr::read_csv(project_path(
        "data", "amr-2024", "participants.csv"
      ), show_col_types = FALSE)
    }
    out <- out |>
      dplyr::left_join(analysis_amr_presence(amr),
        by = c("poll_id", "source_dataset", "respondent_id", "wave"),
        relationship = "one-to-one"
      ) |>
      dplyr::mutate(wave_observed = dplyr::coalesce(
        wave_observed, form_observed
      )) |>
      dplyr::select(-"form_observed")
  }
  out
}

bridge_analysis_phase_presence <- function(scores, participants) {
  person_keys <- c("poll_id", "source_dataset", "respondent_id")
  people <- participants |>
    dplyr::filter(source_dataset %in% c("historical", "cor_sood"))
  stopifnot(
    !anyDuplicated(people[person_keys]), !anyNA(people$source_row),
    !anyDuplicated(people[c("poll_id", "source_dataset", "source_row")])
  )
  historical <- people |>
    dplyr::filter(source_dataset == "historical") |>
    dplyr::transmute(
      poll_id, source_row, historical_id = respondent_id,
      original_id = historical_respondent_id,
      historical_basis = identity_basis
    )
  bridge <- people |>
    dplyr::filter(source_dataset == "cor_sood") |>
    dplyr::left_join(historical,
      by = c("poll_id", "source_row"), relationship = "one-to-one"
    )
  identity_rows <- bridge |>
    dplyr::select("poll_id", "respondent_id", "source_row") |>
    dplyr::left_join(
      dplyr::select(historical, "poll_id", "historical_id", "source_row"),
      by = c("poll_id", "respondent_id" = "historical_id"),
      relationship = "one-to-one", suffix = c("", "_historical")
    )
  row_differs <- !is.na(identity_rows$source_row_historical) &
    identity_rows$source_row != identity_rows$source_row_historical
  if (any(row_differs)) {
    stop("Questionnaire presence bridge has mismatched source rows.")
  }
  row_named <- startsWith(bridge$respondent_id, "source-row-")
  row_name_differs <- row_named & bridge$respondent_id !=
    paste0("source-row-", bridge$source_row)
  if (any(row_name_differs)) {
    stop("Questionnaire presence bridge has mismatched source rows.")
  }
  linked <- !is.na(bridge$historical_id)
  row_id <- paste0("source-row-", bridge$source_row)
  file_row <- bridge$historical_basis %in% "file-scoped-missing-id" &
    bridge$respondent_id == row_id &
    endsWith(bridge$historical_id, paste0(":", row_id))
  agrees <- bridge$respondent_id == bridge$historical_id | file_row
  if (any(linked & !agrees)) {
    stop("Questionnaire presence bridge has mismatched source identities.")
  }
  original_known <- linked & !is.na(bridge$historical_respondent_id)
  original_differs <- is.na(bridge$original_id) |
    bridge$historical_respondent_id != bridge$original_id
  if (any(original_known & original_differs)) {
    stop("Questionnaire presence bridge has mismatched historical IDs.")
  }
  bridge <- bridge[linked, ]
  linked_scores <- scores$source_dataset %in% c("historical", "cor_sood")
  stopifnot(
    !anyNA(scores$wave[linked_scores]),
    !anyNA(scores$wave_role[linked_scores])
  )
  historical_scores <- scores |>
    dplyr::filter(source_dataset == "historical") |>
    dplyr::inner_join(
      dplyr::select(people, dplyr::all_of(person_keys), "source_row"),
      by = person_keys, relationship = "many-to-one"
    ) |>
    dplyr::summarise(
      observed = any(wave_observed %in% TRUE),
      absent = any(wave_observed %in% FALSE),
      .by = c("poll_id", "source_row", "wave", "wave_role")
    )
  stopifnot(!any(historical_scores$observed & historical_scores$absent))
  evidence <- bridge |>
    dplyr::select(dplyr::all_of(person_keys), "source_row") |>
    dplyr::inner_join(
      dplyr::filter(historical_scores, observed),
      by = c("poll_id", "source_row"), relationship = "one-to-many"
    ) |>
    dplyr::select(dplyr::all_of(person_keys), "wave", "wave_role", "observed")
  matched <- scores |>
    dplyr::left_join(evidence,
      by = c(person_keys, "wave", "wave_role"), relationship = "many-to-one"
    )
  if (any(matched$wave_observed %in% FALSE & matched$observed %in% TRUE)) {
    stop("Positive questionnaire evidence conflicts with explicit absence.")
  }
  fill <- is.na(matched$wave_observed) & matched$observed %in% TRUE
  scores$wave_observed[fill] <- TRUE
  scores
}

analysis_phase_scores <- function(scores, items, participants, sources,
                                  recruitment = NULL, arrival_items = NULL) {
  roles <- read_metadata("analysis_phase_roles")
  definitions <- read_metadata("measure_definitions")
  targets <- read_metadata("polardata_targets")
  measures <- arrow::read_parquet(project_path(
    "output", "respondent", "respondent_measures.parquet"
  ))
  presence <- analysis_phase_presence(
    scores, items, measures, definitions, targets, sources$amr, participants
  )
  base <- scores |>
    dplyr::rename(original_score_wave = "wave") |>
    dplyr::inner_join(roles,
      by = c("poll_id", "source_dataset", "original_score_wave" = "score_wave"),
      relationship = "many-to-one"
    ) |>
    dplyr::left_join(presence,
      by = c("poll_id", "source_dataset", "respondent_id",
        "original_score_wave" = "wave"
      ),
      relationship = "one-to-one"
    )
  control_scores <- analysis_phase_control_scores(sources, roles)
  original_controls <- base |>
    dplyr::filter(
      source_dataset == "control", poll_id %in% control_scores$poll_id
    )
  check <- dplyr::inner_join(original_controls, control_scores,
    by = c("poll_id", "source_dataset", "respondent_id", "wave"),
    relationship = "one-to-one", suffix = c("_original", "_rebuilt")
  )
  stopifnot(all(
    abs(check$score_original[check$wave_observed_rebuilt] -
          check$score_rebuilt[check$wave_observed_rebuilt]) < 1e-10
  ))
  base <- dplyr::bind_rows(
    base |> dplyr::filter(!(
      source_dataset == "control" & poll_id %in% control_scores$poll_id
    )), control_scores
  )
  midterm_roles <- roles |>
    dplyr::filter(score_wave == "knowledge_midterm")
  midterms <- purrr::map(seq_len(nrow(midterm_roles)), function(i) {
    role <- midterm_roles[i, ]
    poll <- role$poll_id
    definition <- definitions |>
      dplyr::filter(
        poll_id == poll, measure_id == "knowledge_midterm",
        scoring_rule != "historical-constant-missing"
      )
    stopifnot(nrow(definition) == 1L)
    wave_definitions <- definitions |>
      dplyr::filter(
        poll_id == poll,
        source_waves == definition$source_waves
      )
    observed <- measures |>
      dplyr::filter(
        poll_id == poll,
        definition_id %in% wave_definitions$definition_id
      ) |>
      dplyr::summarise(
        wave_observed = dplyr::if_else(any(n_observed_fields > 0L), TRUE, NA),
        .by = c(poll_id, respondent_id)
      )
    before <- scores |>
      dplyr::filter(
        poll_id == poll, source_dataset == "historical", wave == "t1"
      ) |>
      dplyr::select("poll_id", "source_dataset", "respondent_id", "n_items")
    measures |>
      dplyr::filter(
        poll_id == poll,
        definition_id == definition$definition_id
      ) |>
      dplyr::inner_join(before,
        by = c("poll_id", "respondent_id"), relationship = "one-to-one"
      ) |>
      dplyr::left_join(observed,
        by = c("poll_id", "respondent_id"), relationship = "one-to-one"
      ) |>
      dplyr::transmute(
        poll_id, source_dataset, respondent_id,
        wave = role$wave,
        n_items, n_observed = NA_integer_,
        n_correct = as.integer(round(value_numeric * n_items)),
        score = value_numeric, scale = "proportion_correct", wave_observed,
        original_score_wave = "knowledge_midterm", wave_role = role$wave_role,
        timing_evidence = role$timing_evidence
      )
  }) |>
    purrr::list_rbind()
  if (!is.null(recruitment)) {
    base <- dplyr::bind_rows(
      base |> dplyr::filter(poll_id != "marousi-2006"), recruitment$scores
    )
  }
  out <- dplyr::bind_rows(base, midterms) |>
    dplyr::mutate(
      battery_id = paste(poll_id, source_dataset, "knowledge", sep = ":"),
      score = dplyr::if_else(wave_observed %in% FALSE, NA_real_, score),
      n_correct = dplyr::if_else(
        wave_observed %in% FALSE, NA_integer_, n_correct
      )
    ) |>
    dplyr::select(
      "poll_id", "source_dataset", "respondent_id", "wave",
      "n_items", "n_observed", "n_correct", "score", "scale",
      "wave_observed", "battery_id", "original_score_wave",
      "wave_role", "timing_evidence"
    )
  if (!is.null(arrival_items)) {
    out <- dplyr::bind_rows(out, analysis_arrival_scores(arrival_items))
  }
  arrival_presence <- analysis_te_arrival_presence(participants)
  if (!is.null(arrival_presence)) {
    out <- out |>
      dplyr::left_join(
        arrival_presence |>
          dplyr::select(-"evidence_basis") |>
          dplyr::rename(arrival_observed = "wave_observed") |>
          dplyr::mutate(arrival_reviewed = TRUE),
        by = c("poll_id", "source_dataset", "respondent_id", "wave"),
        relationship = "one-to-one"
      ) |>
      dplyr::mutate(
        wave_observed = dplyr::if_else(
          arrival_reviewed %in% TRUE, arrival_observed, wave_observed
        ),
        score = dplyr::if_else(
          arrival_reviewed %in% TRUE & !arrival_observed %in% TRUE,
          NA_real_, score
        ),
        n_correct = dplyr::if_else(
          arrival_reviewed %in% TRUE & !arrival_observed %in% TRUE,
          NA_integer_, n_correct
        )
      ) |>
      dplyr::select(-"arrival_observed", -"arrival_reviewed")
  }
  stopifnot(
    !anyDuplicated(out[c(
      "poll_id", "source_dataset", "respondent_id", "battery_id",
      "original_score_wave"
    )]),
    nrow(dplyr::anti_join(
      out, participants,
      by = c("poll_id", "source_dataset", "respondent_id")
    )) == 0L
  )
  bridge_analysis_phase_presence(out, participants)
}
