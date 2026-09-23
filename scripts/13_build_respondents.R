source("R/paths.R")
source("R/metadata.R")
source("R/sources.R")
source("R/poll_sources.R")
source("R/poll_adapters.R")
source("R/knowledge.R")
source("R/exports.R")
source("R/respondents.R")

validate_respondent_metadata()
contracts <- read_metadata("respondent_sources")
reviewed <- contracts[contracts$status == "reviewed-source", ]
manifest <- source_files()
source_manifest <- manifest[manifest$source_id %in% reviewed$source_id, ]
stopifnot(setequal(source_manifest$source_id, reviewed$source_id))
dictionary_paths <- paste0("data/", reviewed$poll_id, "/variables.csv")
dictionaries <- manifest[manifest$path %in% dictionary_paths, ]
stopifnot(setequal(dictionaries$path, dictionary_paths))
verify_source_files(dplyr::bind_rows(source_manifest, dictionaries))
polls <- purrr::map(seq_len(nrow(reviewed)), function(i) {
  build_poll_respondents(reviewed[i, ])
})
tables <- purrr::map(names(polls[[1]]), function(name) {
  purrr::map(polls, name) |> purrr::list_rbind()
}) |>
  rlang::set_names(names(polls[[1]]))
validate_respondent_tables(tables)
directory <- project_path("output", "respondent")
fs::dir_create(directory)
manifest <- purrr::imap(tables, write_typed_export, directory = directory) |>
  purrr::list_rbind()
readr::write_csv(manifest, file.path(directory, "manifest.csv"))
coverage <- contracts |>
  dplyr::left_join(
    tables$people |> dplyr::count(.data$poll_id, name = "source_records"),
    by = "poll_id", relationship = "one-to-one"
  ) |>
  dplyr::left_join(
    tables$respondent_measures |>
      dplyr::distinct(.data$poll_id, .data$definition_id) |>
      dplyr::count(.data$poll_id, name = "built_definitions"),
    by = "poll_id", relationship = "one-to-one"
  )
targets <- read_metadata("polardata_targets") |>
  dplyr::group_by(.data$poll_id) |>
  dplyr::summarise(
    target_fields = dplyr::n(),
    implemented_fields = sum(.data$status == "implemented"), .groups = "drop"
  )
coverage <- coverage |>
  dplyr::left_join(targets, by = "poll_id", relationship = "one-to-one")
coverage$built_definitions[is.na(coverage$built_definitions)] <- 0L
readr::write_csv(coverage, project_path("audit", "respondent_coverage.csv"))
print(manifest)
