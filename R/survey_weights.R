read_survey_weight_source <- function(path) {
  switch(tools::file_ext(path),
    parquet = arrow::read_parquet(path),
    dta = haven::read_dta(path),
    sav = haven::read_sav(path),
    tab = readr::read_tsv(path, show_col_types = FALSE),
    csv = readr::read_csv(path, show_col_types = FALSE),
    stop("Unsupported survey weight source: ", path)
  )
}

survey_weight_values <- function(source, definitions) {
  optional_column <- function(column, fallback = NA_character_) {
    if (is.na(column)) {
      return(rep(fallback, nrow(source)))
    }
    stopifnot(column %in% names(source))
    as.character(source[[column]])
  }
  purrr::map(seq_len(nrow(definitions)), function(index) {
    definition <- definitions[index, ]
    column <- definition$source_column[[1]]
    stopifnot(column %in% names(source), is.numeric(source[[column]]))
    tibble::tibble(
      poll_id = definition$poll_id,
      source_id = definition$source_id,
      weight_id = definition$weight_id,
      source_row = seq_len(nrow(source)),
      source_unit_id = optional_column(definition$source_unit_column),
      source_wave = optional_column(
        definition$source_wave_column, definition$source_wave
      ),
      weight_group = optional_column(definition$weight_group_column),
      value = as.numeric(source[[column]])
    )
  }) |>
    purrr::list_rbind()
}

build_survey_weight_tables <- function() {
  registry <- readr::read_csv(
    project_path("metadata", "survey_weights.csv"),
    col_types = readr::cols(.default = readr::col_character())
  )
  stopifnot(
    !anyNA(registry[c("poll_id", "source_id", "weight_id", "source_column")]),
    !anyDuplicated(registry[c("source_id", "weight_id")]),
    !anyDuplicated(registry[c("source_id", "source_column")]),
    all(grepl("^[a-z][a-z0-9]*(_[a-z0-9]+)*$", registry$weight_id)),
    all(registry$poll_id %in% read_metadata("polls")$poll_id),
    all(registry$usage_decision == "undecided")
  )
  sources <- read_metadata("source_files") |>
    dplyr::select("source_id", source_path = "path", source_sha256 = "sha256")
  definitions <- dplyr::left_join(registry, sources,
    by = "source_id", relationship = "many-to-one"
  )
  stopifnot(!anyNA(definitions[c("source_path", "source_sha256")]))
  values <- purrr::map(unique(definitions$source_id), function(id) {
    subset <- definitions[definitions$source_id == id, ]
    stopifnot(dplyr::n_distinct(subset$source_path) == 1L)
    path <- project_path(subset$source_path[[1]])
    stopifnot(identical(
      digest::digest(file = path, algo = "sha256"),
      subset$source_sha256[[1]]
    ))
    survey_weight_values(read_survey_weight_source(path), subset)
  }) |>
    purrr::list_rbind()
  stopifnot(
    !anyDuplicated(values[c("source_id", "weight_id", "source_row")]),
    all(is.na(values$value) | is.finite(values$value))
  )
  list(survey_weight_definitions = definitions, survey_weights = values)
}
