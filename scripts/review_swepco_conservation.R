# SWE-02 approved correction: replay the historical one-item T2 index.
for (file in c(
  "paths", "sources", "metadata", "poll_sources", "poll_adapters",
  "knowledge", "exports", "respondents", "polardata", "polardata_rebuild"
)) {
  source(paste0("R/", file, ".R"))
}
arguments <- commandArgs(trailingOnly = TRUE)
stopifnot(length(arguments) <= 1L)
directory <- if (length(arguments)) arguments[[1]] else tempfile("swe-review-")
fs::dir_create(directory)
poll_id <- "swepco-1996"
survey <- read_poll_survey(poll_id)
corrected_attitudes <- utility_attitudes
utility_attitudes <- function(survey, poll_id, wave) {
  result <- corrected_attitudes(survey, poll_id, wave)
  if (poll_id == "swepco-1996" && wave == 2L) {
    reduce <- read_utility_value(survey, poll_id, "reduce2", 0:10)
    result$conservation_t2 <- dplyr::coalesce(reduce / 10, .5)
  }
  result
}
before <- build_historical_poll(poll_id)
historical_all <- utility_attitudes(survey, poll_id, 2L)
utility_attitudes <- corrected_attitudes
after <- build_historical_poll(poll_id)
candidate_all <- utility_attitudes(survey, poll_id, 2L)
stopifnot(
  nrow(before) == 232L, identical(before$caseid, after$caseid),
  identical(before$source_row, after$source_row)
)
field <- "swp.t2att3"
stopifnot(identical(
  before[setdiff(names(before), field)],
  after[setdiff(names(after), field)]
))
raw <- tibble::tibble(
  source_row = survey$source_row,
  caseid = as.numeric(survey$CASEID),
  historical_sample = survey$PART == 1,
  addfac1 = as.numeric(survey$ADDFAC1),
  reduce1 = as.numeric(survey$REDUCE1),
  addfac2 = as.numeric(survey$ADDFAC2),
  reduce2 = as.numeric(survey$REDUCE2),
  historical_post = historical_all$conservation_t2,
  candidate_post = candidate_all$conservation_t2
)
stopifnot(sum(raw$historical_sample) == 232L)
readr::write_csv(raw, file.path(directory, "respondent_comparison.csv"))
pre <- before[[field]]
post <- after[[field]]
summary <- tibble::tibble(
  field = field, respondents = length(pre),
  historical_observed = sum(!is.na(pre)),
  candidate_observed = sum(!is.na(post)),
  value_changes = sum(abs(pre - post) > 1e-12, na.rm = TRUE),
  missingness_changes = sum(is.na(pre) != is.na(post)),
  historical_mean = mean(pre), candidate_mean = mean(post),
  mean_paired_delta = mean(post - pre),
  max_absolute_delta = max(abs(post - pre))
)
readr::write_csv(summary, file.path(directory, "field_changes.csv"))
checks <- raw |>
  dplyr::filter(.data$historical_sample) |>
  dplyr::summarise(
    participants = dplyr::n(),
    addfac_observed = sum(!is.na(.data$addfac2)),
    reduce_observed = sum(!is.na(.data$reduce2)),
    both_observed = sum(!is.na(.data$addfac2) & !is.na(.data$reduce2)),
    addfac_mean = mean(.data$addfac2, na.rm = TRUE),
    reduce_mean = mean(.data$reduce2, na.rm = TRUE),
    item_correlation = cor(.data$addfac2, .data$reduce2,
                           use = "complete.obs")
  )
readr::write_csv(checks, file.path(directory, "source_checks.csv"))
wide <- arrow::read_parquet("output/polardata/polardata.parquet")
keep <- which(wide$dpnum == 21L)
positions <- match(wide$caseid[keep], before$caseid)
stopifnot(length(keep) == 232L, !anyNA(positions))
wide[[field]][keep] <- before[[field]][positions]
readr::write_tsv(
  wide, file.path(directory, "historical-polardata.tab"), na = ""
)
wide[[field]][keep] <- after[[field]][positions]
readr::write_tsv(wide, file.path(directory, "candidate-polardata.tab"), na = "")
print(summary, width = Inf)
print(checks, width = Inf)
message("SWE-02 correction replay written to: ", directory)
