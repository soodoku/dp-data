analysis_wave_catalog <- function() {
  waves <- readr::read_csv(
    project_path("metadata", "analysis_survey_waves.csv"),
    col_types = readr::cols(
      .default = readr::col_character(),
      temporal_order = readr::col_integer(),
      date_start = readr::col_date(), date_end = readr::col_date()
    )
  )
  studies <- read_metadata("polls") |>
    dplyr::transmute(
      poll_id,
      study_id = dplyr::if_else(
        poll_id %in% c(
          "btp-online-primaries-2004", "btp-presidential-primaries-2004"
        ), "btp-primaries-2004", poll_id
      )
    )
  phases <- c(
    t0 = "pre_arrival", t1 = "arrival", t2 = "post_deliberation",
    t3 = "follow_up", interim_1 = "interim_deliberation"
  )
  required <- setdiff(names(waves), c("date_start", "date_end"))
  stopifnot(
    !anyNA(studies), !anyDuplicated(studies$poll_id),
    !anyNA(waves[required]),
    !anyDuplicated(waves[c("poll_id", "wave_instance_id")]),
    !anyDuplicated(waves[c("poll_id", "original_survey_wave")]),
    all(waves$poll_id %in% studies$poll_id),
    all(waves$study_id == studies$study_id[
      match(waves$poll_id, studies$poll_id)
    ]),
    all(waves$wave %in% names(phases)),
    all(waves$wave_role == unname(phases[waves$wave])),
    all(waves$temporal_order >= 0L),
    all(waves$mode %in% c(
      "telephone", "web", "face_to_face", "self_completion", "mixed", "unknown"
    )),
    all(waves$timing_status %in% c(
      "documented_design", "respondent_timestamps",
      "respondent_start_order_unverified"
    )),
    all(waves$availability %in% c(
      "score_exported", "source_exists_but_not_exported"
    )),
    all(is.na(waves$date_start) | is.na(waves$date_end) |
          waves$date_start <= waves$date_end)
  )
  instances <- waves |>
    dplyr::distinct(
      study_id, wave_instance_id, original_survey_wave, wave, temporal_order
    )
  stopifnot(!anyDuplicated(instances$wave_instance_id))
  list(analysis_studies = studies, analysis_survey_waves = waves)
}

add_analysis_wave_identity <- function(
  scores, catalog = analysis_wave_catalog()$analysis_survey_waves
) {
  keys <- c("poll_id", "source_dataset", "original_score_wave")
  stopifnot(all(keys %in% names(scores)))
  roles <- read_metadata("analysis_phase_roles") |>
    dplyr::select(
      "poll_id", "source_dataset", original_score_wave = "score_wave",
      "original_survey_wave"
    )
  stopifnot(!anyDuplicated(roles[keys]))
  identity <- catalog |>
    dplyr::select(
      "poll_id", "original_survey_wave", "study_id", "wave_instance_id"
    )
  stopifnot(!anyDuplicated(identity[c("poll_id", "original_survey_wave")]))
  out <- scores |>
    dplyr::left_join(roles, by = keys, relationship = "many-to-one") |>
    dplyr::left_join(identity,
      by = c("poll_id", "original_survey_wave"), relationship = "many-to-one"
    )
  stopifnot(
    nrow(out) == nrow(scores),
    !anyNA(out[c("study_id", "wave_instance_id", "original_survey_wave")])
  )
  out
}
