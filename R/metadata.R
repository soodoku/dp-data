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
  assertr::verify(
    recodes,
    all(.data$status %in% c("adopted", "legacy", "proposed", "rejected")),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    contracts,
    all(.data$status %in% c("current", "planned", "retired")),
    error_fun = assertr::error_stop
  )
  invisible(TRUE)
}
