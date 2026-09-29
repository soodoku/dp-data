phase_attitude_values <- function(
  raw, minimum, maximum, nonresponse_codes, wave_observed,
  source_response_label = rep(NA_character_, length(raw))
) {
  stopifnot(
    is.numeric(raw), is.logical(wave_observed),
    length(raw) == length(wave_observed),
    length(raw) == length(source_response_label),
    length(minimum) == 1L, length(maximum) == 1L, maximum > minimum
  )
  valid <- !is.na(raw) & is.finite(raw) & raw == floor(raw) &
    raw >= minimum & raw <= maximum
  multiple <- !is.na(source_response_label) &
    tolower(trimws(source_response_label)) %in%
      c("multiple responses", "multiple answers")
  status <- dplyr::case_when(
    multiple ~ "invalid_response",
    valid ~ "answered",
    !is.na(raw) & raw %in% nonresponse_codes ~ "non_substantive",
    !is.na(raw) ~ "invalid_response",
    wave_observed %in% FALSE ~ "absent_form",
    wave_observed %in% TRUE ~ "blank",
    TRUE ~ "source_missing"
  )
  tibble::tibble(
    raw_value = raw, source_response_label,
    response_status = status, wave_observed,
    value = dplyr::if_else(status == "answered",
      (raw - minimum) / (maximum - minimum), NA_real_
    )
  )
}

phase_attitude_labels <- function(poll) {
  if (poll != "america-in-one-room-2019") {
    return(tibble::tibble(
      source_column = character(), raw_value = double(),
      source_response_label = character()
    ))
  }
  readr::read_tsv(project_path(
    "data", poll, "codebooks", "a1r_codebook.tab"
  ), col_types = readr::cols(.default = readr::col_character())) |>
    tidyr::fill("Variable") |>
    dplyr::filter(grepl("^(T2)?Q[2-6][A-J]$", Variable)) |>
    dplyr::transmute(
      source_column = Variable,
      raw_value = as.numeric(Value), source_response_label = ValueLabel
    )
}

analysis_phase_attitudes <- function(participants, scores) {
  definitions <- read_metadata("paired_attitude_items")
  keys <- c("poll_id", "source_dataset", "respondent_id")
  waves <- read_metadata("analysis_survey_waves") |>
    dplyr::filter(
      poll_id %in% definitions$poll_id,
      original_survey_wave %in% c("PRE", "T2")
    )
  stopifnot(
    !anyDuplicated(definitions[c("poll_id", "attitude_id")]),
    !anyDuplicated(waves[c("poll_id", "original_survey_wave")]),
    all(waves$wave[waves$original_survey_wave == "PRE"] == "t0"),
    all(waves$wave[waves$original_survey_wave == "T2"] == "t2"),
    !anyNA(waves$timing_evidence)
  )
  presence <- scores |>
    dplyr::filter(wave_instance_id %in% waves$wave_instance_id) |>
    dplyr::select(dplyr::all_of(keys), "wave_instance_id", "wave_observed") |>
    dplyr::distinct()
  stopifnot(!anyDuplicated(presence[c(keys, "wave_instance_id")]))
  responses <- purrr::map(unique(definitions$poll_id), function(poll) {
    people <- participants |>
      dplyr::filter(poll_id == poll) |>
      dplyr::select(dplyr::all_of(keys), "source_row")
    stopifnot(!anyDuplicated(people[keys]), !anyNA(people$source_row))
    survey <- readr::read_tsv(project_path(
      "data", poll, "participants.tab"
    ), col_types = readr::cols(.default = readr::col_character()))
    stopifnot(all(people$source_row %in% seq_len(nrow(survey))))
    survey <- survey[people$source_row, , drop = FALSE]
    bank <- dplyr::filter(definitions, poll_id == poll)
    dictionary <- phase_attitude_labels(poll)
    stopifnot(!anyDuplicated(dictionary[c("source_column", "raw_value")]))
    purrr::map(c("PRE", "T2"), function(source_wave) {
      wave_row <- dplyr::filter(
        waves, poll_id == poll, original_survey_wave == source_wave
      )
      stopifnot(nrow(wave_row) == 1L)
      observed <- people |>
        dplyr::mutate(wave_instance_id = wave_row$wave_instance_id) |>
        dplyr::left_join(presence,
          by = c(keys, "wave_instance_id"), relationship = "one-to-one"
        )
      unmatched <- dplyr::anti_join(observed, presence,
        by = c(keys, "wave_instance_id")
      )
      stopifnot(nrow(unmatched) == 0L)
      purrr::map(seq_len(nrow(bank)), function(i) {
        definition <- bank[i, ]
        field <- if (source_wave == "PRE") {
          definition$pre_column
        } else {
          definition$post_column
        }
        stopifnot(field %in% names(survey))
        text <- trimws(survey[[field]])
        text[!is.na(text) & !nzchar(text)] <- NA_character_
        raw <- suppressWarnings(as.numeric(text))
        stopifnot(all(is.na(text) | !is.na(raw)))
        labels <- dplyr::filter(dictionary, source_column == field)
        label <- labels$source_response_label[match(raw, labels$raw_value)]
        missing_codes <- as.numeric(strsplit(
          definition$nonresponse_codes, "|", fixed = TRUE
        )[[1]])
        stopifnot(!anyNA(missing_codes))
        values <- phase_attitude_values(
          raw, definition$minimum, definition$maximum, missing_codes,
          observed$wave_observed, label
        )
        dplyr::bind_cols(
          people |>
            dplyr::transmute(
              poll_id, source_dataset, respondent_id,
              attitude_id = definition$attitude_id,
              wave_instance_id = wave_row$wave_instance_id,
              wave = wave_row$wave, wave_role = wave_row$wave_role,
              source_column = field, source_row = as.integer(source_row)
            ),
          values
        )
      }) |>
        purrr::list_rbind()
    }) |>
      purrr::list_rbind()
  }) |>
    purrr::list_rbind()
  stopifnot(!anyDuplicated(responses[c(
    keys, "attitude_id", "wave_instance_id"
  )]))
  list(
    analysis_phase_attitudes = definitions,
    analysis_phase_attitude_responses = responses
  )
}
