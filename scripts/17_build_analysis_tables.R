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
source("R/analysis_knowledge_missingness.R")

tables <- build_analysis_tables()
directory <- project_path("output", "analysis")
fs::dir_create(directory)
manifest <- purrr::imap(tables, function(data, table_name) {
  version <- switch(table_name,
    analysis_participants = "4",
    analysis_phase_participants = "5",
    analysis_item_responses = "2",
    analysis_phase_item_responses = "2",
    analysis_attitudes = "3",
    analysis_attitude_responses = "2",
    analysis_phase_scores = "2",
    analysis_source_attitude_responses = "2",
    analysis_knowledge_flags = "2",
    "1"
  )
  write_typed_export(data, table_name, directory, schema_version = version)
}) |>
  purrr::list_rbind()
readr::write_csv(manifest, file.path(directory, "manifest.csv"))
print(manifest)

missingness <- knowledge_missingness(tables$analysis_knowledge_flags)
readr::write_csv(missingness$summary,
  project_path("audit", "knowledge_blanks.csv")
)
readr::write_csv(missingness$respondents,
  project_path("audit", "knowledge_blank_respondents.csv")
)
cat("Knowledge blanks by source and battery; duplicate source representations",
    "are reported separately. DK and refusal are not blanks.\n")
log_scope <- if ("participant" %in% names(tables$analysis_phase_participants)) {
  "participants"
} else {
  "attendees"
}
cat("Population shown:", log_scope, "with zero scores; no rows excluded.\n")
blank_log <- missingness$summary |>
  dplyr::filter(scope == log_scope, n_zero_scores > 0L) |>
  dplyr::select("poll_id", "source_dataset", "battery_id", "wave",
                "n_observed_scored_forms", "n_people_any_blank",
                "n_people_all_blank",
                "n_zero_scores", "zero_score_rate")
print(blank_log, n = 20L, width = Inf)
cat("Complete poll/wave counts: audit/knowledge_blanks.csv;",
    "source IDs: audit/knowledge_blank_respondents.csv\n")
