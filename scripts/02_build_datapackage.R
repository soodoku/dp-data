source("R/paths.R")

resources <- c(
  "artifact_types",
  "polls",
  "poll_aliases",
  "source_bundles",
  "source_files",
  "recode_ledger",
  "downstream_contracts"
)

package <- frictionless::create_package(list(
  name = "deliberative-poll-data",
  title = "Deliberative Poll data",
  description = paste(
    "Source metadata and contracts for Deliberative Poll research data."
  ),
  version = "0.1.0",
  resources = list()
))

for (resource in resources) {
  package <- frictionless::add_resource(
    package,
    resource_name = resource,
    data = project_path("metadata", paste0(resource, ".csv"))
  )
}

descriptor <- unclass(package)
attr(descriptor, "directory") <- NULL
jsonlite::write_json(
  descriptor,
  project_path("datapackage.json"),
  auto_unbox = TRUE,
  pretty = TRUE
)
