export_schema <- function(table_name) {
  columns <- read_metadata("canonical_columns") |>
    dplyr::filter(.data$table == table_name)
  stopifnot(nrow(columns) > 0L)
  types <- list(
    string = arrow::utf8(), int32 = arrow::int32(),
    float64 = arrow::float64(), bool = arrow::boolean(),
    date32 = arrow::date32()
  )
  fields <- purrr::pmap(
    columns[c("column", "arrow_type", "nullable")],
    function(column, arrow_type, nullable) {
      arrow::field(column, types[[arrow_type]], nullable = nullable)
    }
  )
  do.call(arrow::schema, fields)
}

write_typed_export <- function(data, table_name, directory,
                               schema_version = "1") {
  columns <- read_metadata("canonical_columns") |>
    dplyr::filter(.data$table == table_name)
  stopifnot(setequal(names(data), columns$column))
  data <- data |> dplyr::select(dplyr::all_of(columns$column))
  required <- columns$column[!columns$nullable]
  stopifnot(!anyNA(data[required]))
  key <- columns$column[columns$key]
  stopifnot(!anyDuplicated(data[key]))
  table <- arrow::Table$create(data, schema = export_schema(table_name))
  path <- file.path(directory, paste0(table_name, ".parquet"))
  arrow::write_parquet(table, path, compression = "zstd")
  restored <- arrow::read_parquet(path)
  stopifnot(identical(as.data.frame(table), as.data.frame(restored)))
  checksum <- digest::digest(file = path, algo = "sha256")
  tibble::tibble(
    table = table_name, path = fs::path_rel(path, project_path()),
    rows = nrow(data), columns = ncol(data),
    sha256 = checksum,
    schema_version = schema_version
  )
}
