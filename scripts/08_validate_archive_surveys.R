source("R/paths.R")
source("R/metadata.R")
source("R/poll_sources.R")

sources <- dplyr::bind_rows(
  read_metadata("survey_sources"), read_metadata("survey_components")
)
exclusions <- read_metadata("source_field_exclusions")
purrr::walk(seq_len(nrow(sources)), function(row) {
  record <- sources[row, ]
  original <- read_archive_survey(record)
  poll_exclusions <- if (
    record$source_id == "cdd-denmark-euro-2000-departure"
  ) {
    read_metadata("component_field_exclusions")
  } else {
    exclusions
  }
  excluded <- poll_exclusions |>
    dplyr::filter(.data$poll_id == record$poll_id) |>
    dplyr::pull(.data$source_column)
  if (record$transformation == "exclude-verbatim") {
    expected <- public_survey_extract(original, excluded)
    observed <- read_public_survey(record)
    stopifnot(identical(expected, observed))
  } else {
    stopifnot(
      digest::digest(
        file = project_path(record$public_path), algo = "sha256"
      ) == record$source_sha256
    )
  }
  dictionary <- readr::read_csv(
    project_path(
      "data", record$poll_id,
      paste0(dictionary_prefix(record), "variables.csv")
    ),
    col_types = readr::cols(
      .default = readr::col_character(), public = readr::col_logical()
    ),
    na = character(), trim_ws = FALSE
  )
  stopifnot(isTRUE(all.equal(
    dictionary, survey_dictionary(
      original, excluded,
      parquet = record$transformation == "exclude-verbatim"
    ),
    check.attributes = FALSE
  )))
  labels <- readr::read_csv(
    project_path(
      "data", record$poll_id,
      paste0(dictionary_prefix(record), "value-labels.csv")
    ),
    col_types = readr::cols(.default = readr::col_character()),
    na = character(), trim_ws = FALSE
  )
  stopifnot(isTRUE(all.equal(
    labels, survey_value_labels(original),
    check.attributes = FALSE
  )))
  message(
    record$poll_id, ": source bytes, retained values, and dictionaries verified"
  )
})
