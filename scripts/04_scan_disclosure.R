source("R/paths.R")

vault <- project_path("vault", "cdd")
if (!fs::dir_exists(vault)) {
  stop(
    "The local CDD vault is absent; extract the archive bundles into vault/cdd."
  )
}

identifier_pattern <- paste(
  "(^|_)(full_?)?name($|_)",
  "(^|_)(first|last|sur)name($|_)",
  "phone|telephone|mobile|cellphone",
  "e_?mail",
  "(^|_)(home_?)?address($|_)",
  "street|postcode|zip_?code|zipcode",
  "contact|comment|verbatim|open_?text",
  sep = "|"
)

scan_frame <- function(data, path, component) {
  labels <- purrr::map_chr(data, function(column) {
    label <- attr(column, "label")
    if (is.null(label)) "" else as.character(label)
  })
  fields <- names(data)
  searchable <- paste(fields, labels)
  hits <- stringr::str_detect(
    searchable,
    stringr::regex(identifier_pattern, TRUE)
  )
  tibble::tibble(
    path = fs::path_rel(path, vault),
    component = component,
    column_count = length(fields),
    flagged_columns = paste(fields[hits], collapse = ";"),
    flagged_labels = paste(labels[hits], collapse = ";"),
    scan_status = if (any(hits)) "review_required" else "no_name_label_hit",
    error = NA_character_
  )
}

scan_tabular <- function(path) {
  extension <- tolower(fs::path_ext(path))
  reader <- switch(
    extension,
    dta = function(path) haven::read_dta(path, n_max = 1),
    sav = function(path) haven::read_sav(path, n_max = 1),
    por = function(path) haven::read_por(path, n_max = 1),
    sas7bdat = function(path) haven::read_sas(path, n_max = 1),
    csv = function(path) {
      readr::read_csv(path, n_max = 1, show_col_types = FALSE)
    },
    tab = function(path) {
      readr::read_tsv(path, n_max = 1, show_col_types = FALSE)
    },
    NULL
  )
  if (is.null(reader)) {
    return(NULL)
  }
  tryCatch(
    {
      data <- reader(path)
      scan_frame(data, path, "data")
    },
    error = function(error) {
      tibble::tibble(
        path = fs::path_rel(path, vault),
        component = "data",
        column_count = NA_integer_,
        flagged_columns = NA_character_,
        flagged_labels = NA_character_,
        scan_status = "unreadable",
        error = conditionMessage(error)
      )
    }
  )
}

scan_excel <- function(path) {
  tryCatch(
    {
      readxl::excel_sheets(path) |>
        purrr::map(
          ~ readxl::read_excel(path, sheet = .x, n_max = 1) |>
            scan_frame(path, .x)
        ) |>
        purrr::list_rbind()
    },
    error = function(error) {
      tibble::tibble(
        path = fs::path_rel(path, vault),
        component = "workbook",
        column_count = NA_integer_,
        flagged_columns = NA_character_,
        flagged_labels = NA_character_,
        scan_status = "unreadable",
        error = conditionMessage(error)
      )
    }
  )
}

scan_rdata <- function(path) {
  tryCatch(
    {
      environment <- new.env(parent = emptyenv())
      objects <- load(path, envir = environment)
      purrr::map(objects, function(object) {
        value <- environment[[object]]
        if (!is.data.frame(value)) {
          return(NULL)
        }
        scan_frame(value, path, object)
      }) |>
        purrr::compact() |>
        purrr::list_rbind()
    },
    error = function(error) {
      tibble::tibble(
        path = fs::path_rel(path, vault),
        component = "R object",
        column_count = NA_integer_,
        flagged_columns = NA_character_,
        flagged_labels = NA_character_,
        scan_status = "unreadable",
        error = conditionMessage(error)
      )
    }
  )
}

scan_file <- function(path) {
  extension <- tolower(fs::path_ext(path))
  if (extension %in% c("xls", "xlsx")) {
    return(scan_excel(path))
  }
  if (extension %in% c("rdata", "rda")) {
    return(scan_rdata(path))
  }
  scan_tabular(path)
}

paths <- fs::dir_ls(
  vault,
  all = TRUE,
  recurse = TRUE,
  type = "file",
  fail = TRUE
)
results <- paths |>
  purrr::map(scan_file) |>
  purrr::compact() |>
  purrr::list_rbind() |>
  dplyr::arrange(.data$path, .data$component)

fs::dir_create(project_path("audit"))
readr::write_csv(results, project_path("audit", "disclosure_scan.csv"))
