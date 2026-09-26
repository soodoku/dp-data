# Reproduce the NIC-03 age/mode comparison before the later NIC-08 age review.
for (file in c(
  "paths", "sources", "metadata", "poll_sources", "poll_adapters",
  "knowledge", "exports", "respondents", "polardata", "polardata_rebuild"
)) {
  source(paste0("R/", file, ".R"))
}
arguments <- commandArgs(trailingOnly = TRUE)
stopifnot(length(arguments) <= 1L)
directory <- if (length(arguments)) arguments[[1]] else tempfile("nic-age-")
fs::dir_create(directory)
poll_id <- "nic-1996"
survey <- read_poll_survey(poll_id)
corrected_individual <- build_nic_individual
corrected_constants <- core_poll_constants
build_nic_individual <- function(survey = read_poll_survey("nic-1996")) {
  result <- corrected_individual(survey)
  result$age <- 1996 - nic_source_codes(survey, "BYEAR", 0:99)
  result
}
core_poll_constants <- function(poll_id) {
  result <- corrected_constants(poll_id)
  if (poll_id == "nic-1996") result[["mode"]] <- 1
  result
}
before <- build_historical_poll(poll_id)
build_nic_individual <- function(survey = read_poll_survey("nic-1996")) {
  result <- corrected_individual(survey)
  result$age <- 96 - nic_source_codes(survey, "BYEAR", 0:99)
  result
}
core_poll_constants <- corrected_constants
after <- build_historical_poll(poll_id)
build_nic_individual <- corrected_individual
stopifnot(
  identical(before$caseid, after$caseid),
  identical(before$source_row, after$source_row),
  identical(is.na(before$ppage), is.na(after$ppage)),
  all(before$ppage - after$ppage == 1900, na.rm = TRUE),
  all(before$mode == 1), all(after$mode == 0),
  identical(
    before[setdiff(names(before), c("ppage", "meanage", "mode"))],
    after[setdiff(names(after), c("ppage", "meanage", "mode"))]
  )
)
field_changes <- purrr::map_dfr(c("ppage", "meanage", "mode"), function(field) {
  a <- before[[field]]
  b <- after[[field]]
  tibble::tibble(
    field = field, respondents = length(a),
    observed_before = sum(!is.na(a)), observed_after = sum(!is.na(b)),
    value_changes = sum(abs(a - b) > 1e-10, na.rm = TRUE),
    missingness_changes = sum(is.na(a) != is.na(b)),
    mean_before = mean(a, na.rm = TRUE), mean_after = mean(b, na.rm = TRUE)
  )
})
readr::write_csv(field_changes, file.path(directory, "field_changes.csv"))
birth_year <- nic_source_codes(survey, "BYEAR", 0:99)
birth_date <- rounded_source_code(survey$BIRTHDY1)
rows <- tibble::tibble(
  source_row = survey$source_row,
  caseid = as.numeric(survey$CASEID),
  historical_sample = survey$source_row %in% before$source_row,
  birth_year = birth_year, birth_date = birth_date,
  date_year = birth_date %% 100,
  year_matches_date = birth_year == birth_date %% 100,
  birthday_before_nov_1977 = as.numeric(survey$BDAYRTE1),
  historical_age = 1996 - birth_year,
  candidate_age = 96 - birth_year,
  implausible_under_16 = 96 - birth_year < 16
)
readr::write_csv(rows, file.path(directory, "respondent_comparison.csv"))
summary <- rows |>
  dplyr::group_by(historical_sample) |>
  dplyr::summarise(
    respondents = dplyr::n(),
    age_observed = sum(!is.na(candidate_age)),
    mean_historical = mean(historical_age, na.rm = TRUE),
    mean_candidate = mean(candidate_age, na.rm = TRUE),
    min_candidate = min(candidate_age, na.rm = TRUE),
    max_candidate = max(candidate_age, na.rm = TRUE),
    birthdate_matches = sum(year_matches_date, na.rm = TRUE),
    birthdate_disagrees = sum(!year_matches_date, na.rm = TRUE),
    age_under_16 = sum(implausible_under_16, na.rm = TRUE),
    historical_mode = unique(before$mode),
    candidate_mode = core_poll_constants(poll_id)[["mode"]]
  )
readr::write_csv(summary, file.path(directory, "summary.csv"))
readr::write_csv(
  rows |>
    dplyr::filter(!year_matches_date | implausible_under_16),
  file.path(directory, "source_anomalies.csv")
)
wide <- arrow::read_parquet("output/polardata/polardata.parquet")
keep <- which(wide$dpnum == 20L)
stopifnot(length(keep) == nrow(before))
positions <- match(wide$caseid[keep], before$caseid)
stopifnot(!anyNA(positions))
for (field in c("ppage", "meanage", "mode")) {
  wide[[field]][keep] <- before[[field]][positions]
}
readr::write_tsv(wide,
  file.path(directory, "historical-polardata.tab"),
  na = ""
)
for (field in c("ppage", "meanage", "mode")) {
  wide[[field]][keep] <- after[[field]][positions]
}
readr::write_tsv(wide,
  file.path(directory, "candidate-polardata.tab"),
  na = ""
)
print(summary, width = Inf)
message("Approved NIC age/mode diagnostics written to: ", directory)
