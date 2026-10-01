source("R/paths.R")
load_project()

tables <- build_survey_weight_tables()
directory <- project_path("output", "weights")
fs::dir_create(directory)
manifest <- purrr::imap(tables, function(data, table_name) {
  write_typed_export(data, table_name, directory)
}) |>
  purrr::list_rbind()
readr::write_csv(manifest, file.path(directory, "manifest.csv"))
print(manifest)
