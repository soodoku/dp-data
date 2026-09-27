build_california_report <- function(
  survey = read_poll_survey("california-whats-next-2011"),
  items = read_metadata("california_report_knowledge_items")
) {
  stopifnot(
    nrow(items) == 8L, identical(as.integer(items$item_number), 27:34),
    !anyDuplicated(items$item_number)
  )
  people <- survey |>
    dplyr::filter(
      .data$part == 1 |
        (is.na(.data$part) & !is.na(.data$t2_ParticipantNumber))
    ) |>
    dplyr::mutate(
      respondent_id = dplyr::if_else(
        !is.na(.data$id), as.character(as.integer(.data$id)),
        paste0("arrival-roster-", as.integer(.data$t2_ParticipantNumber))
      ),
      cohort_basis = dplyr::if_else(
        .data$part == 1, "participant-flag", "arrival-roster-only",
        missing = "arrival-roster-only"
      )
    )
  stopifnot(!anyNA(people$respondent_id), !anyDuplicated(people$respondent_id))
  responses <- purrr::map(c(2L, 3L), function(wave) {
    purrr::map(seq_len(nrow(items)), function(i) {
      column <- paste0("t", wave, "q", items$item_number[[i]])
      raw <- as.numeric(people[[column]])
      stopifnot(all(is.na(raw) | raw %in% 0:5))
      tibble::tibble(
        poll_id = "california-whats-next-2011",
        respondent_id = people$respondent_id,
        source_row = as.integer(people$source_row),
        cohort_basis = people$cohort_basis,
        wave = as.integer(wave),
        item_number = as.integer(items$item_number[[i]]),
        source_column = column,
        raw_code = raw,
        correct = as.integer(!is.na(raw) & raw == items$correct_code[[i]])
      )
    }) |> purrr::list_rbind()
  }) |>
    purrr::list_rbind()
  scores <- responses |>
    dplyr::group_by(
      .data$poll_id, .data$respondent_id, .data$source_row,
      .data$cohort_basis, .data$wave
    ) |>
    dplyr::summarise(
      n_items = dplyr::n(),
      n_answered = sum(!is.na(.data$raw_code)),
      n_correct = sum(.data$correct),
      score_zero_filled = .data$n_correct / .data$n_items,
      .groups = "drop"
    )
  list(california_report_responses = responses,
       california_report_scores = scores)
}
