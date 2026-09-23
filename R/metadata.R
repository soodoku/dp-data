read_metadata <- function(name) {
  readr::read_csv(
    project_path("metadata", paste0(name, ".csv")),
    show_col_types = FALSE
  )
}

validate_metadata <- function() {
  polls <- read_metadata("polls")
  aliases <- read_metadata("poll_aliases")
  artifact_types <- read_metadata("artifact_types")
  archive_collections <- read_metadata("archive_collections")
  artifacts <- read_metadata("artifacts")
  canonical_tables <- read_metadata("canonical_tables")
  canonical_columns <- read_metadata("canonical_columns")
  sources <- read_metadata("source_files")
  recodes <- read_metadata("recode_ledger")
  contracts <- read_metadata("downstream_contracts")

  assertr::verify(
    polls,
    !anyDuplicated(.data$poll_id),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    polls,
    all(!is.na(.data$title)),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    aliases,
    all(.data$poll_id %in% polls$poll_id),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    artifact_types,
    !anyDuplicated(.data$artifact_type),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    archive_collections,
    !anyDuplicated(.data$collection_id),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    archive_collections,
    all(is.na(.data$poll_id) | .data$poll_id %in% polls$poll_id),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    artifacts,
    !anyDuplicated(.data$artifact_id),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    canonical_tables,
    !anyDuplicated(.data$table),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    canonical_tables,
    all(.data$format %in% c("csv", "parquet")),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    canonical_tables,
    all(.data$status %in% c("current", "planned")),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    canonical_columns,
    all(.data$table %in% canonical_tables$table),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    canonical_columns,
    !anyDuplicated(paste(.data$table, .data$column)),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    canonical_columns,
    all(
      .data$arrow_type %in%
        c("bool", "float64", "int32", "string")
    ),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    artifacts,
    all(is.na(.data$poll_id) | .data$poll_id %in% polls$poll_id),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    artifacts,
    all(.data$artifact_type %in% artifact_types$artifact_type),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    artifacts,
    all(is.na(.data$source_id) | .data$source_id %in% sources$source_id),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    artifacts,
    all(
      .data$rights_status %in%
        c("public-license", "owner-approved", "review-required")
    ),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    artifacts,
    all(
      .data$disclosure_status %in%
        c(
          "approved-public",
          "approved-redacted",
          "review-required",
          "vault-only"
        )
    ),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    artifacts,
    all(
      .data$publication_status %in%
        c("published", "review-required", "vault-only")
    ),
    error_fun = assertr::error_stop
  )
  published <- artifacts |>
    dplyr::filter(.data$publication_status == "published") |>
    dplyr::mutate(
      file_exists = fs::file_exists(project_path(.data$location)),
      observed_sha256 = purrr::map_chr(
        project_path(.data$location),
        digest::digest,
        file = TRUE,
        algo = "sha256",
        serialize = FALSE
      )
    )
  assertr::verify(
    published,
    all(.data$file_exists),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    published,
    all(.data$sha256 == .data$observed_sha256),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    recodes,
    all(.data$status %in% c("adopted", "legacy", "proposed", "rejected")),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    contracts,
    all(.data$status %in% c("current", "planned", "transitional", "retired")),
    error_fun = assertr::error_stop
  )
  validate_respondent_metadata()
  invisible(TRUE)
}


validate_respondent_metadata <- function() {
  contracts <- read_metadata("respondent_sources")
  surveys <- read_metadata("survey_sources")
  fields <- read_metadata("polardata_fields")
  targets <- read_metadata("polardata_targets")
  definitions <- read_metadata("measure_definitions")
  inputs <- read_metadata("measure_inputs")
  reviewed <- contracts[contracts$status == "reviewed-source", ]
  defined <- paste(definitions$poll_id, definitions$definition_id)
  dependencies <- paste(inputs$poll_id, inputs$definition_id)
  implemented <- targets[targets$status == "implemented", ]
  constant <- definitions$scoring_rule == "historical-constant-missing"
  stopifnot(
    !anyDuplicated(contracts$poll_id), !anyDuplicated(contracts$dpnum),
    setequal(contracts$dpnum, 1:21),
    all(contracts$status %in% c("reviewed-source", "source-unresolved")),
    all(paste(reviewed$poll_id, reviewed$source_id) %in%
          paste(surveys$poll_id, surveys$source_id)),
    !anyDuplicated(fields$legacy_field),
    all(fields$layer %in% c("identifier", "export-artifact", "respondent",
          "group-derived", "poll-derived", "poll-metadata"
        )),
    all(targets$poll_id %in% contracts$poll_id),
    !anyDuplicated(targets[c("poll_id", "legacy_field")]),
    all(targets$legacy_field %in% fields$legacy_field[
      fields$layer == "respondent"
    ]),
    all(targets$status %in% c("implemented", "not-yet-reconstructed",
          "source-unresolved"
        )),
    !anyDuplicated(defined), !anyDuplicated(inputs),
    all(definitions$poll_id %in% reviewed$poll_id),
    all(dependencies %in% defined),
    setequal(defined[!constant], dependencies),
    all(paste(implemented$poll_id, implemented$canonical_definition) %in%
          defined),
    all(!is.na(targets$blocker[targets$status != "implemented"])),
    all(!is.na(definitions$scoring_rule)),
    all(!is.na(definitions$missing_policy)),
    all(!is.na(definitions$denominator_policy)),
    all(definitions$post_dependent == grepl("T2|T3", definitions$source_waves))
  )
  invisible(TRUE)
}
