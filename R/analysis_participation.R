source(project_path("R", "analysis_attendance.R"))

participation_presence <- function(people, scores) {
  keys <- c("poll_id", "source_dataset", "respondent_id", "wave")
  presence <- scores |>
    dplyr::filter(wave %in% c("t0", "t1", "t2")) |>
    dplyr::summarise(
      observed = any(wave_observed %in% TRUE),
      absent = any(wave_observed %in% FALSE),
      .by = dplyr::all_of(keys)
    )
  stopifnot(!any(presence$observed & presence$absent))
  presence <- presence |>
    dplyr::mutate(wave_observed = dplyr::case_when(
      observed ~ TRUE, absent ~ FALSE, TRUE ~ NA
    )) |>
    dplyr::select(dplyr::all_of(keys), "wave_observed")

  # These sources retain collected forms beyond their exported score pairs.
  te <- analysis_te_arrival_presence(people)
  nic_people <- dplyr::filter(people, poll_id == "nic-1996")
  nic <- NULL
  if (nrow(nic_people)) {
    nic <- analysis_reviewed_presence(nic_people) |>
      dplyr::filter(wave == "t1") |>
      dplyr::mutate(wave = "t0")
  }
  reviewed <- dplyr::bind_rows(te, nic)
  if (nrow(reviewed)) {
    reviewed <- reviewed |>
      dplyr::mutate(wave_observed = wave_observed %in% TRUE) |>
      dplyr::select(dplyr::all_of(keys), "wave_observed")
    presence <- presence |>
      dplyr::anti_join(reviewed, by = keys) |>
      dplyr::bind_rows(reviewed)
  }

  ni <- people |>
    dplyr::filter(poll_id == "northern-ireland-2007",
      source_dataset == "control"
    )
  if (nrow(ni)) {
    raw <- attendance_source_rows(
      ni, read_poll_survey("northern-ireland-2007"), "cserial"
    )
    reviewed <- purrr::map2(c("t1", "t2"), c("t0", "t2"),
      function(original_wave, phase) {
        fields <- grep(paste0("^", original_wave, "q[0-9]"),
          names(raw), value = TRUE
        )
        ni |>
          dplyr::select(dplyr::all_of(setdiff(keys, "wave"))) |>
          dplyr::mutate(wave = phase,
            wave_observed = questionnaire_form_answers(raw, fields)
          )
      }
    ) |>
      purrr::list_rbind()
    presence <- presence |>
      dplyr::anti_join(reviewed, by = keys) |>
      dplyr::bind_rows(reviewed)
  }
  stopifnot(!anyDuplicated(presence[keys]))
  presence
}

analysis_participation <- function(
  participants, phase_participants, phase_scores,
  survey_waves = read_metadata("analysis_survey_waves"), presence = NULL
) {
  keys <- c("poll_id", "source_dataset", "respondent_id")
  people <- phase_participants |>
    dplyr::select(-dplyr::any_of(c("participant", "exclusion_reason")))
  stopifnot(!anyDuplicated(people[keys]),
    !anyDuplicated(participants[keys])
  )
  if (is.null(presence)) {
    presence <- participation_presence(people, phase_scores)
  }
  stopifnot(!anyDuplicated(presence[c(keys, "wave")]))
  required <- survey_waves |>
    dplyr::filter(wave %in% c("t0", "t1", "t2")) |>
    dplyr::distinct(poll_id, wave)
  review <- people |>
    dplyr::select(dplyr::all_of(keys)) |>
    dplyr::inner_join(required, by = "poll_id",
      relationship = "many-to-many"
    ) |>
    dplyr::left_join(presence, by = c(keys, "wave"),
      relationship = "one-to-one"
    ) |>
    dplyr::arrange(wave) |>
    dplyr::summarise(
      missing_wave = dplyr::first(wave[wave_observed %in% FALSE],
        default = NA_character_
      ),
      presence_unknown = any(is.na(wave_observed)),
      .by = dplyr::all_of(keys)
    )
  people <- people |>
    dplyr::left_join(review, by = keys, relationship = "one-to-one") |>
    dplyr::mutate(
      exclusion_reason = dplyr::case_when(
        attended %in% FALSE ~ "nonattendee",
        !is.na(missing_wave) ~ paste0("missing_", missing_wave,
          "_questionnaire"
        ),
        is.na(attended) ~ "attendance_unknown",
        is.na(presence_unknown) | presence_unknown ~
          "questionnaire_presence_unknown",
        TRUE ~ NA_character_
      ),
      participant = dplyr::case_when(
        attended %in% FALSE | !is.na(missing_wave) ~ FALSE,
        is.na(exclusion_reason) ~ TRUE,
        TRUE ~ NA
      )
    ) |>
    dplyr::select(-"missing_wave", -"presence_unknown")
  flags <- people |>
    dplyr::select(dplyr::all_of(keys), "participant", "exclusion_reason")
  selected <- participants |>
    dplyr::select(-dplyr::any_of(c("participant", "exclusion_reason"))) |>
    dplyr::left_join(flags, by = keys, relationship = "one-to-one")
  stopifnot(nrow(selected) == nrow(participants),
    nrow(people) == nrow(phase_participants)
  )
  list(participants = selected, phase_participants = people)
}
