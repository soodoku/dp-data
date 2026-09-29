for (module in c("paths", "metadata", "poll_sources", "source_utilities")) {
  source(file.path("R", paste0(module, ".R")))
}

historical <- arrow::read_parquet(project_path(
  "output", "respondent", "historical_knowledge_items.parquet"
))
reviews <- purrr::map(c("swepco-1996", "wtu-1996"), function(poll) {
  review <- review_utilities_original(poll)
  original <- review$original
  attendees <- original[original$PART == 1L, ]
  item_names <- c("source", "use", "rt", "smog", "setrt")
  keys <- if (poll == "swepco-1996") c(1, 3, 1, 2, 1) else c(3, 1, 1, 2, 1)
  evidence <- purrr::map(1:2, function(wave) {
    purrr::map(seq_along(item_names), function(item) {
      field <- paste0(toupper(item_names[[item]]), wave)
      value <- as.numeric(attendees[[field]])
      tibble::tibble(
        poll_id = poll, respondent_id = as.character(attendees$CASEID),
        wave = wave, item_id = item_names[[item]], source_column = field,
        raw_value = value,
        correct_from_source = as.numeric(value == keys[[item]])
      )
    }) |>
      purrr::list_rbind()
  }) |>
    purrr::list_rbind() |>
    dplyr::left_join(historical,
      by = c("poll_id", "respondent_id", "wave", "item_id"),
      relationship = "one-to-one"
    )
  stopifnot(
    nrow(evidence) == nrow(attendees) * 10L, !anyNA(evidence$correct),
    all(evidence$correct == evidence$correct_from_source)
  )
  nonanswers <- evidence |>
    dplyr::filter(raw_value == 99) |>
    dplyr::select(
      "poll_id", "respondent_id", "source_row", "wave",
      "item_id", "source_column", "raw_value", "correct"
    ) |>
    dplyr::mutate(source_label = "Don't know")
  summary <- tibble::tibble(
    poll_id = poll, source_rows = nrow(original),
    source_columns = ncol(original),
    attendees = nrow(attendees), collapsed_nonanswers = nrow(review$collapsed),
    recovered_attendee_knowledge_nonanswers = nrow(nonanswers),
    absent_post_forms = length(review$absent_post_ids),
    attendee_item_correctness_changes = sum(
      evidence$correct != evidence$correct_from_source
    )
  )
  list(
    summary = summary, nonanswers = nonanswers,
    absence = tibble::tibble(
      poll_id = poll,
      respondent_id = review$absent_post_ids, source_part = 2L,
      direct_post_fields = 74L, observed_post_fields = 0L
    )
  )
})
destination <- project_path("audit", "corrections", "utilities-source-recovery")
fs::dir_create(destination)
for (table in c("summary", "nonanswers", "absence")) {
  out <- purrr::map(reviews, table) |> purrr::list_rbind()
  readr::write_csv(out, file.path(destination, paste0(table, ".csv")))
}
message("Original Texas sources verified; production values unchanged.")
