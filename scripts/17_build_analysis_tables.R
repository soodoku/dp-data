source("R/analysis_phase_recruitment.R")
source("R/paths.R")
source("R/metadata.R")
source("R/poll_sources.R")
source("R/exports.R")
source("R/analysis_poll_metadata.R")
source("R/poll_adapters.R")
source("R/respondents.R")
source("R/respondent_nic.R")
source("R/analysis_tables.R")
source("R/analysis_covariates.R")
source("R/analysis_attitudes.R")
source("R/analysis_phases.R")
source("R/analysis_arrivals.R")
source("R/analysis_wave_catalog.R")
source("R/analysis_attendance.R")

tables <- build_analysis_tables()
directory <- project_path("output", "analysis")
fs::dir_create(directory)
manifest <- purrr::imap(tables, function(data, table_name) {
  version <- switch(table_name,
    analysis_participants = "3",
    analysis_phase_participants = "4",
    analysis_item_responses = "2",
    analysis_phase_item_responses = "2",
    analysis_attitudes = "2",
    analysis_attitude_responses = "2",
    analysis_phase_scores = "2",
    "1"
  )
  write_typed_export(data, table_name, directory, schema_version = version)
}) |>
  purrr::list_rbind()
readr::write_csv(manifest, file.path(directory, "manifest.csv"))
print(manifest)
