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

analysis_phase_presence <- function(
  scores, items, measures, definitions, targets
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
  out
}

analysis_phase_scores <- function(scores, items, participants, sources,
                                  recruitment = NULL) {
  roles <- read_metadata("analysis_phase_roles")
  definitions <- read_metadata("measure_definitions")
  targets <- read_metadata("polardata_targets")
  measures <- arrow::read_parquet(project_path(
    "output", "respondent", "respondent_measures.parquet"
  ))
  presence <- analysis_phase_presence(
    scores, items, measures, definitions, targets
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
  stopifnot(
    !anyDuplicated(out[c(
      "poll_id", "source_dataset", "respondent_id", "battery_id", "wave"
    )]),
    nrow(dplyr::anti_join(
      out, participants,
      by = c("poll_id", "source_dataset", "respondent_id")
    )) == 0L
  )
  out
}
