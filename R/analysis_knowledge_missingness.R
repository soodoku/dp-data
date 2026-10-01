knowledge_flags <- function(items, participants, scores) {
  people_keys <- c("poll_id", "source_dataset", "respondent_id")
  form_keys <- c(people_keys, "battery_id", "wave", "wave_instance_id")
  stopifnot(
    !anyDuplicated(participants[people_keys]),
    !anyDuplicated(scores[form_keys]),
    !anyDuplicated(items[c(form_keys, "item_id")])
  )
  raw_empty <- is.na(items$raw_value) &
    (is.na(items$raw_text) | !nzchar(trimws(items$raw_text)))
  source_known <- !is.na(items$source_column) & nzchar(items$source_column)
  items$system_blank <- source_known & raw_empty &
    items$response_reason %in% c("source_missing", "blank")
  items$recorded_blank <- source_known & !raw_empty &
    items$response_reason %in% "blank"
  items$blank <- items$system_blank | items$recorded_blank
  collect_values <- function(x) {
    paste(sort(unique(x[!is.na(x)])), collapse = "|")
  }
  counts <- items |>
    dplyr::summarise(
      n_item_rows = dplyr::n(),
      n_blank = sum(blank), n_system_blank = sum(system_blank),
      n_recorded_blank = sum(recorded_blank),
      n_dk = sum(response_reason %in% "dk"),
      n_none_or_dk = sum(response_reason %in% "none_or_dk"),
      n_substantive = sum(response_reason %in% "answered"),
      n_refused = sum(response_reason %in% "refused"),
      n_unclassified_nonanswer = sum(
        response_reason %in% "unclassified_nonanswer"
      ),
      n_invalid = sum(response_reason %in% "invalid_response"),
      n_scored_only = sum(response_reason %in% "scored_only"),
      n_unreviewed = sum(response_reason %in% "unreviewed_code"),
      blank_item_ids = collect_values(item_id[blank]),
      blank_source_columns = collect_values(source_column[blank]),
      blank_source_rows = collect_values(source_row[blank]),
      .by = dplyr::all_of(form_keys)
    )
  stopifnot(nrow(dplyr::anti_join(counts, scores, by = form_keys)) == 0L)
  people <- participants |>
    dplyr::select(dplyr::all_of(people_keys), "source_row", "attended",
      dplyr::any_of(c("participant", "exclusion_reason"))
    )
  if (!"participant" %in% names(people)) people$participant <- NA
  if (!"exclusion_reason" %in% names(people)) {
    people$exclusion_reason <- NA_character_
  }
  forms <- scores |>
    dplyr::select(dplyr::all_of(form_keys), "original_survey_wave", "wave_role",
      "n_items", "wave_observed", "score"
    ) |>
    dplyr::left_join(people, by = people_keys, relationship = "many-to-one") |>
    dplyr::left_join(counts, by = form_keys, relationship = "one-to-one") |>
    dplyr::mutate(
      item_evidence = !is.na(n_item_rows),
      complete_item_evidence = item_evidence & n_item_rows == n_items,
      any_blank = dplyr::if_else(
        wave_observed %in% TRUE & item_evidence, n_blank > 0L, NA
      ),
      all_blank = dplyr::if_else(
        wave_observed %in% TRUE & complete_item_evidence,
        n_blank == n_items, NA
      ),
      zero_score = dplyr::if_else(
        wave_observed %in% TRUE & is.finite(score), score == 0, NA
      ),
      zero_pattern = dplyr::case_when(
        !zero_score %in% TRUE ~ NA_character_,
        !complete_item_evidence ~ "unresolved_item_evidence",
        all_blank %in% TRUE ~ "all_blank",
        n_dk == n_items ~ "all_explicit_dk",
        n_substantive > 0L ~ "some_substantive_answers",
        TRUE ~ "other_nonanswers_or_unresolved"
      )
    )
  stopifnot(!anyNA(forms$source_row))
  forms
}

knowledge_missingness <- function(forms) {
  scopes <- list(
    source_frame = forms,
    attendees = forms[forms$attended %in% TRUE, ]
  )
  if (any(!is.na(forms$participant))) {
    scopes$participants <- forms[forms$participant %in% TRUE, ]
  }
  summary <- purrr::imap(scopes, function(data, scope) {
    data |>
      dplyr::summarise(
        scope = scope,
        n_people = dplyr::n(),
        n_observed_forms = sum(wave_observed %in% TRUE),
        n_absent_forms = sum(wave_observed %in% FALSE),
        n_unknown_forms = sum(is.na(wave_observed)),
        n_observed_with_complete_items = sum(
          wave_observed %in% TRUE & complete_item_evidence
        ),
        n_observed_without_item_evidence = sum(
          wave_observed %in% TRUE & !item_evidence
        ),
        n_people_any_blank = sum(any_blank %in% TRUE),
        n_people_all_blank = sum(all_blank %in% TRUE),
        n_observed_scored_forms = sum(
          wave_observed %in% TRUE & is.finite(score)
        ),
        n_zero_scores = sum(zero_score %in% TRUE),
        zero_score_rate = dplyr::if_else(
          n_observed_scored_forms > 0L,
          n_zero_scores / n_observed_scored_forms, NA_real_
        ),
        n_zero_all_blank = sum(zero_pattern %in% "all_blank"),
        n_zero_all_dk = sum(zero_pattern %in% "all_explicit_dk"),
        n_zero_some_substantive = sum(
          zero_pattern %in% "some_substantive_answers"
        ),
        n_zero_other = sum(zero_pattern %in% c(
          "other_nonanswers_or_unresolved", "unresolved_item_evidence"
        )),
        n_blank_items = sum(n_blank[wave_observed %in% TRUE], na.rm = TRUE),
        n_system_blank_items = sum(
          n_system_blank[wave_observed %in% TRUE], na.rm = TRUE
        ),
        n_recorded_blank_items = sum(
          n_recorded_blank[wave_observed %in% TRUE], na.rm = TRUE
        ),
        n_dk_items = sum(n_dk[wave_observed %in% TRUE], na.rm = TRUE),
        n_refused_items = sum(n_refused[wave_observed %in% TRUE], na.rm = TRUE),
        n_unclassified_nonanswers = sum(
          n_unclassified_nonanswer[wave_observed %in% TRUE], na.rm = TRUE
        ),
        n_invalid_items = sum(n_invalid[wave_observed %in% TRUE], na.rm = TRUE),
        n_scored_only_items = sum(
          n_scored_only[wave_observed %in% TRUE], na.rm = TRUE
        ),
        n_unreviewed_items = sum(
          n_unreviewed[wave_observed %in% TRUE], na.rm = TRUE
        ),
        .by = c(
          "poll_id", "source_dataset", "battery_id", "wave",
          "wave_instance_id", "original_survey_wave", "wave_role", "n_items"
        )
      )
  }) |>
    purrr::list_rbind() |>
    dplyr::arrange(poll_id, source_dataset, battery_id, wave, scope)
  respondents <- forms |>
    dplyr::filter(any_blank) |>
    dplyr::mutate(blank_pattern = dplyr::if_else(
      all_blank, "all_items_blank", "some_items_blank"
    )) |>
    dplyr::arrange(poll_id, source_dataset, battery_id, wave, respondent_id)
  list(summary = summary, respondents = respondents)
}
