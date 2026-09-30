marousi_knowledge_response <- function(values, labels, key, observed) {
  raw <- as.numeric(values)
  label <- names(labels)[match(raw, as.numeric(labels))]
  reason <- dplyr::case_when(
    !observed ~ "wave_absent",
    is.na(raw) ~ "blank",
    label == "dk" ~ "dk",
    label == "na" ~ "unclassified_nonanswer",
    !is.na(label) ~ "answered",
    TRUE ~ "invalid_response"
  )
  correct <- as.integer(raw %in% key)
  correct[reason %in% c("wave_absent", "invalid_response")] <- NA_integer_
  tibble::tibble(
    raw_value = raw, raw_text = NA_character_, correct,
    response_status = dplyr::case_when(
      reason == "wave_absent" ~ "wave_absent",
      reason == "blank" ~ "source_missing",
      reason == "answered" ~ "answered",
      TRUE ~ "non_substantive"
    ),
    knowledge_response = dplyr::case_when(
      reason == "dk" ~ "dk",
      reason == "answered" & correct == 1L ~ "correct",
      reason == "answered" & correct == 0L ~ "incorrect",
      TRUE ~ NA_character_
    ),
    response_reason = reason, source_response_label = label
  )
}

analysis_marousi_raw <- function() {
  record <- read_metadata("survey_sources") |>
    dplyr::filter(poll_id == "marousi-2006")
  stopifnot(nrow(record) == 1L)
  raw <- haven::read_sav(project_path(record$public_path))
  normalize_survey_labels(raw, record[["label_encoding"]])
}

analysis_marousi_phase_items <- function(participants, scores) {
  raw <- analysis_marousi_raw()
  definitions <- read_metadata("marousi_knowledge_items")
  people <- participants |>
    dplyr::filter(poll_id == "marousi-2006", source_dataset == "score_only") |>
    dplyr::arrange(source_row)
  phase_scores <- scores |>
    dplyr::filter(poll_id == "marousi-2006", source_dataset == "score_only")
  expected_ids <- paste0("source-", as.character(raw$P_Q1_0))
  grouped <- which(!is.na(raw$GROUP))
  expected_ids[grouped] <- as.character(79999L + seq_along(grouped))
  stopifnot(
    nrow(raw) == 1275L, !anyNA(raw$P_Q1_0),
    !anyDuplicated(raw$P_Q1_0), length(grouped) == 146L,
    identical(as.integer(people$source_row), seq_len(nrow(raw))),
    identical(people$respondent_id, expected_ids),
    nrow(definitions) == 21L,
    !anyDuplicated(definitions[c("wave", "item_id")]),
    all(definitions$poll_id == "marousi-2006"),
    nrow(phase_scores) == 3825L,
    !anyDuplicated(phase_scores[c("respondent_id", "wave")])
  )
  presence <- function(wave) {
    prefix <- c(t0 = "^P_", t1 = "^AR_", t2 = "^F_")[[wave]]
    fields <- setdiff(
      grep(prefix, names(raw), value = TRUE),
      c("P_Q1_0", "P_DAY", "AR_CODE", "F_CODE")
    )
    stopifnot(length(fields) > 7L)
    rowSums(!is.na(raw[fields])) > 0L
  }
  out <- purrr::map(seq_len(nrow(definitions)), function(i) {
    definition <- definitions[i, ]
    phase <- phase_scores[phase_scores$wave == definition$wave, ]
    phase <- phase[match(people$respondent_id, phase$respondent_id), ]
    observed <- presence(definition$wave)
    values <- raw[[definition$source_column]]
    labels <- attr(values, "labels")
    key <- as.numeric(definition$correct_values)
    authored <- as.numeric(raw[[definition$authored_correct_column]])
    stopifnot(
      length(key) == 1L, !is.na(key), length(labels) > 0L,
      !anyDuplicated(as.numeric(labels)),
      !anyNA(phase$respondent_id),
      identical(phase$wave_observed, observed),
      all(phase$original_survey_wave == definition$original_survey_wave),
      identical(as.numeric(as.numeric(values) %in% key), authored)
    )
    response <- marousi_knowledge_response(values, labels, key, observed)
    tibble::tibble(
      poll_id = people$poll_id, source_dataset = people$source_dataset,
      respondent_id = people$respondent_id, battery_id = phase$battery_id,
      wave = phase$wave, item_id = definition$item_id,
      source_row = as.integer(people$source_row),
      source_column = definition$source_column,
      raw_value = response$raw_value, raw_text = response$raw_text,
      correct = response$correct, response_status = response$response_status,
      wave_observed = observed, original_score_wave = phase$original_score_wave,
      study_id = phase$study_id, wave_instance_id = phase$wave_instance_id,
      original_survey_wave = phase$original_survey_wave,
      knowledge_response = response$knowledge_response,
      response_reason = response$response_reason,
      source_response_label = response$source_response_label
    )
  }) |>
    purrr::list_rbind()
  reconstructed <- out |>
    dplyr::summarise(
      n_correct = if (all(is.na(correct))) NA_integer_ else sum(correct),
      n_observed = sum(!is.na(raw_value)),
      .by = c(respondent_id, wave)
    ) |>
    dplyr::left_join(
      phase_scores |>
        dplyr::select(respondent_id, wave, n_correct, n_observed, score),
      by = c("respondent_id", "wave"),
      suffix = c("_items", "_score"), relationship = "one-to-one"
    )
  stopifnot(
    nrow(out) == 26775L,
    !anyDuplicated(out[c("respondent_id", "wave", "item_id")]),
    identical(reconstructed$n_correct_items, reconstructed$n_correct_score),
    identical(reconstructed$n_observed_items, reconstructed$n_observed_score),
    all(is.na(reconstructed$score) |
          abs(reconstructed$n_correct_items / 7 - reconstructed$score) < 3e-8)
  )
  out
}
