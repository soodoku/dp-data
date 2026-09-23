attribute_text <- function(column, name) {
  value <- attr(column, name, exact = TRUE)
  if (is.null(value)) "" else paste(value, collapse = "|")
}

read_archive_survey <- function(record) {
  path <- project_path("vault", "cdd", record$archive_path)
  observed <- digest::digest(file = path, algo = "sha256")
  if (!identical(observed, record$source_sha256)) {
    stop("Archive survey checksum mismatch: ", record$poll_id)
  }
  data <- if (grepl("\\.sav$", path)) {
    haven::read_sav(path, user_na = TRUE)
  } else {
    haven::read_dta(path)
  }
  stopifnot(
    nrow(data) == record$source_rows,
    ncol(data) == record$source_columns,
    !anyDuplicated(names(data))
  )
  tagged <- purrr::map_int(data, ~ sum(haven::is_tagged_na(.x)))
  if (any(tagged > 0L)) {
    stop("Tagged missing values require an explicit export rule.")
  }
  data
}

survey_dictionary <- function(data, excluded, parquet = FALSE) {
  tibble::tibble(
    source_column = names(data),
    storage_type = purrr::map_chr(data, typeof),
    source_class = purrr::map_chr(data, ~ paste(class(.x), collapse = "|")),
    parquet_type = dplyr::if_else(
      names(data) %in% excluded, "",
      purrr::map_chr(data, function(column) {
        if (!parquet) {
          ""
        } else if (inherits(column, "Date")) {
          "date32"
        } else if (is.character(column)) {
          "string"
        } else {
          "float64"
        }
      })
    ),
    variable_label = purrr::map_chr(data, attribute_text, name = "label"),
    source_format = purrr::map_chr(data, function(column) {
      paste(
        attribute_text(column, "format.spss"),
        attribute_text(column, "format.stata")
      ) |>
        trimws()
    }),
    missing_values = purrr::map_chr(data, attribute_text, name = "na_values"),
    missing_range = purrr::map_chr(data, attribute_text, name = "na_range"),
    public = !names(data) %in% excluded,
    publication_note = dplyr::if_else(
      names(data) %in% excluded,
      "Excluded; see source_field_exclusions", "Retained"
    )
  )
}

survey_value_labels <- function(data) {
  purrr::imap(data, function(column, name) {
    labels <- attr(column, "labels", exact = TRUE)
    tibble::tibble(
      source_column = rep(name, length(labels)),
      source_value = as.character(unname(labels)),
      value_label = as.character(names(labels))
    )
  }) |>
    purrr::list_rbind()
}

public_survey_extract <- function(data, excluded) {
  stopifnot(
    all(excluded %in% names(data))
  )
  data |>
    dplyr::select(-dplyr::all_of(excluded)) |>
    dplyr::mutate(
      dplyr::across(dplyr::everything(), function(column) {
        if (inherits(column, "Date")) {
          as.Date(column)
        } else if (is.character(column)) {
          column
        } else {
          as.numeric(column)
        }
      }),
      source_row = dplyr::row_number(),
      .before = 1
    )
}

import_reviewed_surveys <- function() {
  sources <- dplyr::bind_rows(
    read_metadata("survey_sources"), read_metadata("survey_components")
  )
  exclusions <- read_metadata("source_field_exclusions")
  purrr::walk(seq_len(nrow(sources)), function(row) {
    record <- sources[row, ]
    data <- read_archive_survey(record)
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
    directory <- project_path("data", record$poll_id)
    fs::dir_create(directory)

    if (record$transformation == "exact-copy") {
      stopifnot(length(excluded) == 0L)
      fs::file_copy(
        project_path("vault", "cdd", record$archive_path),
        project_path(record$public_path),
        overwrite = TRUE
      )
    } else if (record$transformation == "exclude-verbatim") {
      public <- public_survey_extract(data, excluded)
      arrow::write_parquet(
        public, project_path(record$public_path),
        compression = "zstd"
      )
      restored <- arrow::read_parquet(project_path(record$public_path))
      stopifnot(identical(public, restored))
    } else {
      stop("Unreviewed transformation: ", record$transformation)
    }
    readr::write_csv(
      survey_dictionary(
        data, excluded,
        parquet = record$transformation == "exclude-verbatim"
      ),
      file.path(directory, paste0(dictionary_prefix(record), "variables.csv")),
      na = ""
    )
    readr::write_csv(
      survey_value_labels(data),
      file.path(
        directory, paste0(dictionary_prefix(record), "value-labels.csv")
      ),
      na = ""
    )
  })

  groups <- project_path("vault", "cdd", "data", "Ireland", "groups.csv")
  stopifnot(
    digest::digest(file = groups, algo = "sha256") ==
      "cf7f63cb0c41bdf03f510e9a006b931d818e702bbd0ecd29ad029942b7ead6a1"
  )
  fs::file_copy(
    groups, project_path("data", "northern-ireland-2007", "groups.csv"),
    overwrite = TRUE
  )
  codebooks <- read_metadata("artifacts") |>
    dplyr::filter(
      .data$publication_status == "published",
      !is.na(.data$original_archive_path),
      .data$artifact_type %in% c("questionnaire", "codebook"),
      grepl("\\.(docx?|pdf|txt)$", .data$location)
    )
  purrr::walk(seq_len(nrow(codebooks)), function(row) {
    record <- codebooks[row, ]
    original <- project_path("vault", "cdd", record$original_archive_path)
    stopifnot(
      digest::digest(file = original, algo = "sha256") == record$sha256
    )
    fs::file_copy(original, project_path(record$location), overwrite = TRUE)
  })
  invisible(TRUE)
}

read_poll_survey <- function(poll_id) {
  record <- read_metadata("survey_sources") |>
    dplyr::filter(.data$poll_id == .env$poll_id)
  if (nrow(record) != 1L) {
    stop("No reviewed survey reader for ", poll_id)
  }
  data <- read_public_survey(record)
  if (poll_id == "denmark-euro-2000") {
    component <- read_metadata("survey_components") |>
      dplyr::filter(.data$source_id == "cdd-denmark-euro-2000-departure")
    stopifnot(nrow(component) == 1L)
    departure <- read_public_survey(component)
    stopifnot(
      !anyDuplicated(departure$DELNR), !anyNA(departure$DELNR),
      !anyDuplicated(data$delnr[!is.na(data$delnr)]),
      all(departure$DELNR %in% data$delnr)
    )
    departure <- departure |>
      dplyr::rename_with(~ paste0("T2_", .x))
    data <- data |>
      dplyr::left_join(
        departure,
        by = c("delnr" = "T2_DELNR"),
        relationship = "many-to-one", na_matches = "never"
      )
    stopifnot(sum(!is.na(data$T2_source_row)) == nrow(departure))
  }
  data
}

dictionary_prefix <- function(record) {
  if (basename(record$public_path) == "departure.parquet") "departure-" else ""
}

read_public_survey <- function(record) {
  path <- project_path(record$public_path)
  if (record$transformation == "exact-copy" && grepl("\\.sav$", path)) {
    haven::read_sav(path, user_na = TRUE) |>
      dplyr::mutate(source_row = dplyr::row_number(), .before = 1)
  } else if (record$transformation == "exact-copy" && grepl("\\.dta$", path)) {
    haven::read_dta(path) |>
      dplyr::mutate(source_row = dplyr::row_number(), .before = 1)
  } else if (record$transformation == "exclude-verbatim") {
    arrow::read_parquet(path)
  } else {
    stop("No reviewed survey reader for ", record$poll_id)
  }
}
