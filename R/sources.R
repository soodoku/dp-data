source_files <- function() {
  readr::read_csv(
    project_path("metadata", "source_files.csv"),
    show_col_types = FALSE
  )
}

source_bundles <- function() {
  readr::read_csv(
    project_path("metadata", "source_bundles.csv"),
    show_col_types = FALSE
  )
}

verify_source_bundles <- function(manifest = source_bundles()) {
  observed <- manifest |>
    dplyr::mutate(
      path = project_path(.data$local_filename),
      exists = fs::file_exists(.data$path),
      observed_bytes = purrr::map_dbl(.data$path, fs::file_size),
      observed_sha256 = purrr::map_chr(
        .data$path,
        digest::digest,
        file = TRUE,
        algo = "sha256",
        serialize = FALSE
      )
    )

  assertr::verify(observed, all(.data$exists), error_fun = assertr::error_stop)
  assertr::verify(
    observed,
    all(.data$bytes == .data$observed_bytes),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    observed,
    all(.data$sha256 == .data$observed_sha256),
    error_fun = assertr::error_stop
  )
  invisible(observed)
}

verify_source_files <- function(manifest = source_files()) {
  observed <- manifest |>
    dplyr::mutate(
      exists = fs::file_exists(project_path(.data$path)),
      observed_bytes = purrr::map_dbl(project_path(.data$path), fs::file_size),
      observed_sha256 = purrr::map_chr(
        project_path(.data$path),
        digest::digest,
        file = TRUE,
        algo = "sha256",
        serialize = FALSE
      )
    )

  assertr::verify(observed, all(.data$exists), error_fun = assertr::error_stop)
  assertr::verify(
    observed,
    all(.data$bytes == .data$observed_bytes),
    error_fun = assertr::error_stop
  )
  assertr::verify(
    observed,
    all(.data$sha256 == .data$observed_sha256),
    error_fun = assertr::error_stop
  )
  invisible(observed)
}
