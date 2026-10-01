source("R/paths.R")
load_project()

resources <- c(
  "oos_sources",
  "survey_weights",
  "attitude_index_wave_fixes",
  "paired_attitude_items",
  "source_attitude_items",
  "tanzania_attitude_items",
  "respondent_sources",
  "respondent_source_components",
  "education_normalization",
  "polardata_reviewed_covariances",
  "polardata_fields",
  "derived_measure_names",
  "polardata_targets",
  "measure_definitions",
  "harmonized_ordinal_measures",
  "measure_inputs",
  "artifact_types",
  "archive_collections",
  "artifacts",
  "canonical_tables",
  "analysis_phase_roles",
  "analysis_survey_waves",
  "canonical_columns",
  "knowledge_batteries",
  "survey_sources",
  "survey_components",
  "component_field_exclusions",
  "source_field_exclusions",
  "knowledge_items",
  "knowledge_response_codes",
  "source_nonanswer_rules",
  "marousi_knowledge_items",
  "items",
  "knowledge_join_contracts",
  "poll_references",
  "poll_facts",
  "poll_material_coverage",
  "document_previews",
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
  version = unname(read.dcf(project_path("DESCRIPTION"))[1, "Version"]),
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
