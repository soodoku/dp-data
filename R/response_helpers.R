is_response_empty <- function(raw_value, raw_text) {
  is.na(raw_value) & (is.na(raw_text) | !nzchar(trimws(raw_text)))
}

select_comparison_presence <- function(scores) {
  presence <- scores |>
    dplyr::filter(grepl(":knowledge$", battery_id)) |>
    dplyr::transmute(
      poll_id, source_dataset, respondent_id,
      wave = original_score_wave, wave_observed
    )
  keys <- c("poll_id", "source_dataset", "respondent_id", "wave")
  stopifnot(!anyDuplicated(presence[keys]))
  presence
}
