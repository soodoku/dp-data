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
      names(data) %in% excluded, "Verbatim field excluded", "Retained"
    )
  )
}

survey_value_labels <- function(data) {
  purrr::imap(data, function(column, name) {
    labels <- attr(column, "labels", exact = TRUE)
    tibble::tibble(
      source_column = rep(name, length(labels)),
      source_value = as.character(unname(labels)),
      value_label = names(labels)
    )
  }) |>
    purrr::list_rbind()
}

public_survey_extract <- function(data, excluded) {
  stopifnot(
    all(excluded %in% names(data)),
    setequal(names(data)[purrr::map_lgl(data, is.character)], excluded)
  )
  data |>
    dplyr::select(-dplyr::all_of(excluded)) |>
    dplyr::mutate(
      dplyr::across(dplyr::everything(), function(column) {
        if (inherits(column, "Date")) as.Date(column) else as.numeric(column)
      }),
      source_row = dplyr::row_number(),
      .before = 1
    )
}

import_reviewed_surveys <- function() {
  sources <- read_metadata("survey_sources")
  exclusions <- read_metadata("source_field_exclusions")
  purrr::walk(seq_len(nrow(sources)), function(row) {
    record <- sources[row, ]
    data <- read_archive_survey(record)
    excluded <- exclusions |>
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
        public, project_path(record$public_path), compression = "zstd"
      )
      restored <- arrow::read_parquet(project_path(record$public_path))
      stopifnot(identical(public, restored))
    } else {
      stop("Unreviewed transformation: ", record$transformation)
    }
    readr::write_csv(
      survey_dictionary(
        data, excluded, parquet = record$transformation == "exclude-verbatim"
      ),
      file.path(directory, "variables.csv"), na = ""
    )
    readr::write_csv(
      survey_value_labels(data),
      file.path(directory, "value-labels.csv"), na = ""
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
  invisible(TRUE)
}

read_poll_survey <- function(poll_id) {
  if (poll_id == "uk-health-1998") {
    haven::read_sav(
      project_path("data", poll_id, "survey.sav"), user_na = TRUE
    ) |>
      dplyr::mutate(source_row = dplyr::row_number(), .before = 1)
  } else if (poll_id == "northern-ireland-2007") {
    arrow::read_parquet(project_path("data", poll_id, "survey.parquet"))
  } else {
    stop("No reviewed survey reader for ", poll_id)
  }
}
