source("R/paths.R")
source("R/sources.R")
source("R/metadata.R")
source("R/poll_sources.R")
source("R/poll_adapters.R")
source("R/knowledge.R")
source("R/exports.R")

verify_source_files()
poll_ids <- knowledge_poll_ids()
polls <- purrr::map(poll_ids, build_poll_knowledge)
table_names <- names(polls[[1]])
tables <- purrr::map(table_names, function(name) {
  purrr::map(polls, name) |> purrr::list_rbind()
}) |>
  rlang::set_names(table_names)

comparison <- compare_knowledge_batteries(tables)
parity <- comparison$summary
directory <- project_path("output")
fs::dir_create(directory)
manifest <- purrr::imap(tables, write_typed_export, directory = directory) |>
  purrr::list_rbind()
readr::write_csv(manifest, file.path(directory, "manifest.csv"))
readr::write_csv(parity, project_path("audit", "knowledge_parity.csv"))
purrr::walk(c("differences", "score_changes"), function(name) {
  readr::write_csv(
    comparison[[name]],
    project_path("audit", paste0("knowledge_", name, ".csv"))
  )
})

counts <- tables$knowledge_responses |>
  dplyr::count(
    .data$poll_id, .data$source_column, .data$raw_value,
    .data$raw_text, .data$correct,
    .data$response_status, .data$missing_code,
    name = "respondents"
  )
readr::write_csv(counts, project_path("audit", "knowledge_recode_counts.csv"))

joins <- tables$respondents |>
  dplyr::left_join(
    tables$memberships |>
      dplyr::select("poll_id", "respondent_id", "group_id"),
    by = c("poll_id", "respondent_id"), relationship = "one-to-one"
  ) |>
  dplyr::group_by(.data$poll_id) |>
  dplyr::summarise(
    respondents = dplyr::n(),
    matched = sum(!is.na(.data$group_id)),
    unmatched = sum(is.na(.data$group_id)),
    groups = dplyr::n_distinct(.data$group_id, na.rm = TRUE),
    .groups = "drop"
  )
readr::write_csv(joins, project_path("audit", "knowledge_join_checks.csv"))
print(parity)
print(joins)

vermont <- tables$knowledge_responses |>
  dplyr::filter(.data$poll_id == "vermont-energy-2007")
sensitivity <- purrr::imap(
  list(both_starred = c(2, 3), only_15_percent = 2, only_25_percent = 3),
  function(key, scenario) {
    vermont |>
      dplyr::mutate(
        scenario = scenario,
        correct = dplyr::if_else(
          .data$item_id == "knowledge-3" & !is.na(.data$correct),
          as.integer(.data$raw_value %in% key), .data$correct
        )
      ) |>
      dplyr::group_by(.data$poll_id, .data$scenario, .data$wave) |>
      dplyr::summarise(
        respondents = dplyr::n_distinct(.data$respondent_id),
        item_responses = dplyr::n(),
        mean_zero_filled = sum(.data$correct, na.rm = TRUE) / dplyr::n(),
        .groups = "drop"
      )
  }
) |>
  purrr::list_rbind()
readr::write_csv(
  sensitivity, project_path("audit", "knowledge_key_sensitivity.csv")
)
