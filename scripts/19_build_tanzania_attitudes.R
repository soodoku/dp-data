source("R/paths.R")
source("R/metadata.R")
source("R/exports.R")
source("R/tanzania_attitudes.R")

tables <- build_tanzania_attitude_tables()
directory <- project_path("output", "tanzania_attitudes")
fs::dir_create(directory)
manifest <- purrr::imap(tables, function(data, table_name) {
  write_typed_export(data, table_name, directory)
}) |>
  purrr::list_rbind()
readr::write_csv(manifest, file.path(directory, "manifest.csv"))
print(manifest)
