archive_source_path <- function(archive_path, expected_sha256 = NULL,
                                inventory = NULL) {
  if (is.null(inventory)) {
    inventory <- readr::read_csv(
      project_path("audit", "cdd_archive_files.csv"),
      show_col_types = FALSE
    )
  }
  record <- inventory[inventory$path == archive_path, ]
  if (nrow(record) != 1L) {
    stop("Unknown or ambiguous archive path: ", archive_path)
  }
  if (!is.null(expected_sha256) && record$sha256 != expected_sha256) {
    stop("Archive checksum contract mismatch: ", archive_path)
  }
  path <- project_path(record$retained_path)
  if (!file.exists(path)) stop("Retained archive source is absent: ", path)
  if (digest::digest(file = path, algo = "sha256") != record$sha256) {
    stop("Retained archive source checksum mismatch: ", archive_path)
  }
  path
}

copy_archive_source <- function(archive_path, destination, expected_sha256) {
  source <- archive_source_path(archive_path, expected_sha256)
  destination <- project_path(destination)
  if (source != destination) {
    fs::dir_create(dirname(destination))
    fs::file_copy(source, destination, overwrite = TRUE)
  }
  invisible(destination)
}

attribute_text <- function(column, name) {
  value <- attr(column, name, exact = TRUE)
  if (is.null(value)) "" else paste(value, collapse = "|")
}

read_archive_survey <- function(record) {
  if (record$transformation %in% c("join-workbook", "join-zeguo")) {
    return(read_joined_public_source(record))
  }
  path <- archive_source_path(record$archive_path, record$source_sha256)
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

read_joined_public_source <- function(record) {
  directory <- project_path("data", record$poll_id, "source-materials")
  data <- if (record$transformation == "join-workbook") {
    source(project_path("R", "source_new_haven.R"), local = TRUE)
    read_new_haven_workbook(file.path(directory, "survey-waves.xlsx"))
  } else if (record$transformation == "join-zeguo") {
    source(project_path("R", "source_zeguo.R"), local = TRUE)
    read_zeguo_sources(directory)
  } else {
    stop("Unsupported public source join: ", record$poll_id)
  }
  stopifnot(
    nrow(data) == record$source_rows,
    ncol(data) == record$source_columns, !anyDuplicated(names(data))
  )
  data
}

import_reviewed_surveys <- function() {
  sources <- dplyr::bind_rows(
    read_metadata("survey_sources"), read_metadata("survey_components")
  )
  exclusions <- read_metadata("source_field_exclusions")
  purrr::walk(seq_len(nrow(sources)), function(row) {
    record <- sources[row, ]
    data <- read_archive_survey(record)
    if (record$transformation %in% c("join-workbook", "join-zeguo")) {
      arrow::write_parquet(data, project_path(record$public_path))
      return(invisible(NULL))
    }
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
      copy_archive_source(
        record$archive_path, record$public_path, record$source_sha256
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

  copy_archive_source(
    "data/Ireland/groups.csv", "data/northern-ireland-2007/groups.csv",
    "cf7f63cb0c41bdf03f510e9a006b931d818e702bbd0ecd29ad029942b7ead6a1"
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
    copy_archive_source(
      record$original_archive_path, record$location, record$sha256
    )
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
  } else if (record$transformation %in%
               c("exclude-verbatim", "join-workbook", "join-zeguo")) {
    arrow::read_parquet(path)
  } else {
    stop("No reviewed survey reader for ", record$poll_id)
  }
}
