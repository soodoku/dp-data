source("R/paths.R")
source("R/metadata.R")
source("R/exports.R")
source("R/analysis_poll_metadata.R")
source("R/analysis_tables.R")

tables <- build_analysis_tables()
directory <- project_path("output", "analysis")
fs::dir_create(directory)
manifest <- purrr::imap(tables, write_typed_export, directory = directory) |>
  purrr::list_rbind()
readr::write_csv(manifest, file.path(directory, "manifest.csv"))
print(manifest)
