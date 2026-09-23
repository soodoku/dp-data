source("R/paths.R")
source("R/sources.R")
source("R/metadata.R")

frictionless::read_package(project_path("datapackage.json")) |>
  frictionless::check_package()
verify_source_files()
validate_metadata()

message("Source files, metadata, and Data Package are valid.")
