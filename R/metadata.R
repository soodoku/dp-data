read_metadata <- function(name) {
  readr::read_csv(
    project_path("metadata", paste0(name, ".csv")),
    show_col_types = FALSE
  )
}

validate_metadata <- function() {
  polls <- read_metadata("polls")
  aliases <- read_metadata("poll_aliases")
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
