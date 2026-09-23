source("R/paths.R")

resources <- c(
  "respondent_sources",
  "polardata_fields",
  "polardata_targets",
  "measure_definitions",
  "measure_inputs",
  "artifact_types",
  "archive_collections",
  "artifacts",
  "canonical_tables",
  "canonical_columns",
  "knowledge_batteries",
  "survey_sources",
  "survey_components",
  "component_field_exclusions",
  "source_field_exclusions",
  "knowledge_items",
  "knowledge_join_contracts",
  "polls",
  "poll_aliases",
  "source_bundles",
  "source_files",
  "source_findings",
  "downstream_porting_review",
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
    data = file.path("metadata", paste0(resource, ".csv"))
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
