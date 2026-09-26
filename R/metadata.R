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
        c("bool", "date32", "float64", "int32", "string")
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
  oos <- read_metadata("oos_sources")
  source_rows <- match(oos$source_id, sources$source_id)
  stopifnot(
    !anyDuplicated(oos$file), !anyDuplicated(oos$path),
    !anyNA(source_rows),
    all(oos$path == sources$path[source_rows]),
    all(oos$sha256 == sources$sha256[source_rows])
  )
  validate_poll_documentation()
  validate_respondent_metadata()
  invisible(TRUE)
}


validate_respondent_metadata <- function() {
  contracts <- read_metadata("respondent_sources")
  surveys <- read_metadata("survey_sources")
  fields <- read_metadata("polardata_fields")
  targets <- read_metadata("polardata_targets")
  derived_names <- read_metadata("derived_measure_names")
  definitions <- read_metadata("measure_definitions")
  inputs <- read_metadata("measure_inputs")
  harmonized <- read_metadata("harmonized_ordinal_measures")
  reviewed <- contracts[contracts$status == "reviewed-source", ]
  defined <- paste(definitions$poll_id, definitions$definition_id)
  dependencies <- paste(inputs$poll_id, inputs$definition_id)
  implemented <- targets[targets$status == "implemented", ]
  constant <- definitions$scoring_rule == "historical-constant-missing"
  expected_derived <- fields$legacy_field[
    fields$layer %in% c("group-derived", "poll-derived")
  ]
  stopifnot(
    !anyDuplicated(contracts$poll_id), !anyDuplicated(contracts$dpnum),
    setequal(contracts$dpnum, 1:21),
    all(contracts$status %in% c("reviewed-source", "source-unresolved")),
    all(paste(reviewed$poll_id, reviewed$source_id) %in%
          paste(surveys$poll_id, surveys$source_id)),
    !anyDuplicated(fields$legacy_field),
    setequal(derived_names$legacy_field, expected_derived),
    !anyDuplicated(derived_names$legacy_field),
    !anyDuplicated(derived_names$measure_name),
    all(grepl("^[a-z][a-z0-9]*(_[a-z0-9]+)*$",
              derived_names$measure_name)),
    all(derived_names$aggregation_level %in% c("group", "poll")),
    all(derived_names$respondent_scope %in%
          c("group_members", "leave_one_out", "respondent_specific",
            "poll_sample")),
    all(startsWith(derived_names$measure_name,
                   paste0(derived_names$aggregation_level, "_"))),
    all(derived_names$aggregation_level == "group" |
          derived_names$respondent_scope == "poll_sample"),
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
    !anyDuplicated(harmonized[c("poll_id", "definition_id")]),
    !anyDuplicated(harmonized[c("poll_id", "source_column")]),
    setequal(
      paste(harmonized$poll_id, harmonized$definition_id),
      defined[grepl("_harmonized$", definitions$measure_id)]
    ),
    all(harmonized$measure_id == definitions$measure_id[
      match(paste(harmonized$poll_id, harmonized$definition_id), defined)
    ]),
    all(harmonized$poll_id %in% reviewed$poll_id),
    all(paste(harmonized$poll_id, harmonized$definition_id,
              harmonized$source_column) %in%
          paste(inputs$poll_id, inputs$definition_id,
                inputs$source_column)),
    all(harmonized$min_code < harmonized$max_code),
    all(harmonized$high_code == harmonized$min_code |
          harmonized$high_code == harmonized$max_code),
    all(!is.na(harmonized$evidence)),
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

read_documentation <- function(name) {
  readr::read_csv(
    project_path("metadata", paste0(name, ".csv")),
    col_types = readr::cols(.default = readr::col_character())
  )
}

validate_poll_documentation <- function(
  references = read_documentation("poll_references"),
  facts = read_documentation("poll_facts"),
  coverage = read_documentation("poll_material_coverage"),
  previews = read_documentation("document_previews")) {
  polls <- read_metadata("polls")$poll_id
  artifacts <- read_metadata("artifacts")
  required_materials <- c(
    "questionnaires", "briefing-materials", "event-reports",
    "papers", "codebooks"
  )
  reference_rows <- match(facts$reference_id, references$reference_id)
  artifact_rows <- match(references$local_artifact_id, artifacts$artifact_id)
  local <- !is.na(references$local_artifact_id)
  stopifnot(
    !anyNA(references$reference_id),
    !anyDuplicated(references$reference_id),
    all(references$poll_id %in% polls),
    all(references$kind %in% read_metadata("artifact_types")$artifact_type),
    all(!is.na(references$title)),
    all(!is.na(references$url) | local),
    all(is.na(references$url) | grepl("^https?://", references$url)),
    all(!is.na(references$accessed)),
    all(!is.na(artifact_rows[local])),
    all(is.na(artifacts$poll_id[artifact_rows[local]]) |
          artifacts$poll_id[artifact_rows[local]] == references$poll_id[local]),
    all(facts$poll_id %in% polls),
    all(facts$field %in% c(
      "event_dates", "location", "organizers", "population", "recruitment",
      "participants", "mode", "topics"
    )),
    !anyNA(reference_rows),
    all(facts$poll_id == references$poll_id[reference_rows]),
    all(!is.na(facts$field)), all(!is.na(facts$value)),
    all(!is.na(facts$source_locator)),
    all(facts$status %in% c("reported", "corroborated", "conflicting")),
    !anyDuplicated(facts),
    all(coverage$poll_id %in% polls),
    all(coverage$material_type %in% required_materials),
    !anyDuplicated(coverage[c("poll_id", "material_type")]),
    setequal(
      paste(coverage$poll_id, coverage$material_type),
      as.vector(outer(polls, required_materials, paste))
    ),
    all(coverage$status %in%
          c("available", "partial", "external-only", "not-found")),
    all(!is.na(coverage$notes)),
    !anyDuplicated(previews$source_path),
    !anyDuplicated(previews$preview_path),
    all(previews$source_path %in% artifacts$location),
    all(previews$preview_path %in% artifacts$location),
    all(grepl("\\.pdf$", previews$preview_path)),
    all(as.integer(previews$pages) > 0L),
    all(!is.na(previews$converter_version)),
    all(!is.na(previews$text_check)), all(!is.na(previews$visual_check))
  )
  material_kinds <- list(
    questionnaires = c("questionnaire", "codebook"),
    `briefing-materials` = "briefing-material",
    `event-reports` = c("event-report", "press-release"),
    papers = "paper",
    codebooks = "codebook"
  )
  purrr::walk(seq_len(nrow(coverage)), function(index) {
    row <- coverage[index, ]
    ids <- trimws(strsplit(row$checked_references, ";", fixed = TRUE)[[1]])
    stopifnot(all(ids %in% references$reference_id[
      references$poll_id == row$poll_id
    ]))
    if (row$status == "available") {
      checked <- references[match(ids, references$reference_id), ]
      published <- artifacts$artifact_id[
        artifacts$publication_status == "published"
      ]
      stopifnot(any(
        checked$kind %in% material_kinds[[row$material_type]] &
          checked$local_artifact_id %in% published
      ))
    }
  })
  for (kind in c("source", "preview")) {
    paths <- previews[[paste0(kind, "_path")]]
    hashes <- purrr::map_chr(project_path(paths), digest::digest,
      file = TRUE, algo = "sha256", serialize = FALSE
    )
    stopifnot(identical(hashes, previews[[paste0(kind, "_sha256")]]))
  }
  invisible(TRUE)
}

poll_documentation <- function(poll, artifacts, references, facts,
                               coverage, previews) {
  poll_id <- poll$poll_id[[1]]
  reference_rows <- references[references$poll_id == poll_id, ]
  artifact_rows <- artifacts |>
    dplyr::filter(
      .data$publication_status == "published",
      .data$poll_id == .env$poll_id |
        .data$artifact_id %in% reference_rows$local_artifact_id
    )
  artifact_rows$relative_path <- as.character(fs::path_rel(
    project_path(artifact_rows$location), project_path("data", poll_id)
  ))
  preview_rows <- previews[previews$source_path %in% artifact_rows$location, ]
  list(
    catalog = as.list(poll[1, ]),
    interpretation = paste(
      "Catalog labels preserve historical identifiers.",
      "Sourced facts retain reported definitions and disagreements;",
      "they do not change respondent coding or aggregate outputs.",
      "Material coverage describes the sources checked, not proof of absence."
    ),
    facts = facts[facts$poll_id == poll_id, ],
    references = reference_rows,
    material_coverage = coverage[coverage$poll_id == poll_id, ],
    artifacts = artifact_rows,
    document_previews = preview_rows
  )
}
