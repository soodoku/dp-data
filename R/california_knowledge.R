california_wave_present <- function(survey, wave) {
  columns <- grep(paste0("^t", wave, "q"), names(survey), value = TRUE)
  stopifnot(length(columns) > 0L)
  rowSums(!is.na(survey[columns])) > 0L
}

build_california_knowledge <- function(
  survey = read_poll_survey("california-whats-next-2011"),
  items = read_metadata("california_knowledge_items")
) {
  stopifnot(
    nrow(items) == 8L, identical(as.integer(items$item_number), 27:34),
    !anyDuplicated(items$item_number)
  )
  people <- survey |>
    dplyr::filter(.data$part == 1) |>
    dplyr::mutate(respondent_id = as.character(as.integer(.data$id)))
  arrival <- california_wave_present(people, 2L)
  departure <- california_wave_present(people, 3L)
  stopifnot(!anyNA(people$respondent_id), !anyDuplicated(people$respondent_id))
  responses <- purrr::map(c(2L, 3L), function(wave) {
    present <- if (wave == 2L) arrival else departure
    purrr::map(seq_len(nrow(items)), function(i) {
      column <- paste0("t", wave, "q", items$item_number[[i]])
      raw <- as.numeric(people[[column]])
      stopifnot(all(is.na(raw) | raw %in% 0:5))
      invalid <- knowledge_invalid_codes(
        "california-whats-next-2011", column, raw
      )
      tibble::tibble(
        poll_id = "california-whats-next-2011",
        respondent_id = people$respondent_id,
        source_row = as.integer(people$source_row),
        paired = arrival & departure, wave_observed = present,
        wave = as.integer(wave),
        item_number = as.integer(items$item_number[[i]]),
        source_column = column, raw_code = raw,
        correct = dplyr::if_else(
          present & !invalid,
          as.integer(!is.na(raw) & raw == items$correct_code[[i]]),
          NA_integer_
        )
      )
    }) |>
      purrr::list_rbind()
  }) |>
    purrr::list_rbind()
  responses <- responses |>
    dplyr::mutate(
      source_dataset = "cor_sood",
      item_id = sprintf("knowledge_%03d", item_number - 26L),
      raw_value = raw_code, raw_text = NA_character_,
      response_status = dplyr::case_when(
        !wave_observed ~ "wave_absent", is.na(raw_code) ~ "source_missing",
        TRUE ~ "answered"
      )
    ) |>
    enrich_knowledge_responses()
  responses <- standardize_knowledge_scores(responses)$items |>
    dplyr::select(-"source_dataset", -"item_id", -"raw_value", -"raw_text")
  scores <- responses |>
    dplyr::group_by(
      .data$poll_id, .data$respondent_id, .data$source_row,
      .data$paired, .data$wave_observed, .data$wave
    ) |>
    dplyr::summarise(
      n_items = dplyr::n(), n_answered = sum(!is.na(.data$raw_code)),
      n_correct = dplyr::if_else(
        dplyr::first(.data$wave_observed),
        sum(.data$correct, na.rm = TRUE), NA_integer_
      ),
      score = .data$n_correct / .data$n_items,
      .groups = "drop"
    )
  list(
    california_knowledge_responses = responses,
    california_knowledge_scores = scores
  )
}

audit_california_report <- function(
  survey = read_poll_survey("california-whats-next-2011"),
  items = read_metadata("california_knowledge_items")
) {
  report <- survey |>
    dplyr::filter(
      .data$part == 1 |
        (is.na(.data$part) & !is.na(.data$t2_ParticipantNumber))
    )
  purrr::map(c(2L, 3L), function(wave) {
    purrr::map(seq_len(nrow(items)), function(i) {
      column <- paste0("t", wave, "q", items$item_number[[i]])
      n_correct <- sum(
        report[[column]] == items$correct_code[[i]],
        na.rm = TRUE
      )
      tibble::tibble(
        wave = wave, item_number = as.integer(items$item_number[[i]]),
        source_column = column, denominator = nrow(report),
        nonparticipants = sum(!california_wave_present(report, 3L)),
        n_correct = as.integer(n_correct), percent_correct = 100 * n_correct /
          nrow(report)
      )
    }) |>
      purrr::list_rbind()
  }) |>
    purrr::list_rbind()
}
