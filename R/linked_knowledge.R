link_respondent_knowledge <- function(people, responses) {
  identity <- people |>
    dplyr::select(
      "poll_id", "source_row", "respondent_id", "historical_respondent_id"
    )
  stopifnot(!anyDuplicated(identity[c("poll_id", "source_row")]))
  responses <- responses |>
    dplyr::select(-"respondent_id") |>
    dplyr::left_join(identity,
      by = c("poll_id", "source_row"), relationship = "many-to-one"
    )
  stopifnot(!anyNA(responses$respondent_id))
  result <- responses |>
    dplyr::transmute(
      poll_id, respondent_id, historical_respondent_id, source_row,
      item_id, wave, source_column, raw_value, raw_text, correct,
      correct_before_standardization, response_status, missing_code,
      wave_observed,
      knowledge_response, response_reason, source_response_label
    )
  stopifnot(!anyDuplicated(result[c(
    "poll_id", "respondent_id", "item_id", "wave"
  )]))
  result
}

build_respondent_knowledge <- function(people) {
  polls <- intersect(unique(people$poll_id), knowledge_poll_ids())
  responses <- purrr::map(polls, function(poll_id) {
    build_poll_knowledge(poll_id)$knowledge_responses
  }) |>
    purrr::list_rbind()
  link_respondent_knowledge(people, responses)
}
