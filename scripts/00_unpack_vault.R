source("R/paths.R")
source("R/sources.R")

bundles <- verify_source_bundles()
vault <- project_path("vault", "cdd")
fs::dir_create(vault)

purrr::walk(
  bundles$path,
  utils::unzip,
  exdir = vault,
  overwrite = TRUE
)
