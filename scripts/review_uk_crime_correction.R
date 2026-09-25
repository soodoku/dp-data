# Reproduce the approved UKC-01 comparison without altering production outputs.
for (file in c(
  "paths", "sources", "metadata", "poll_sources", "poll_adapters",
  "knowledge", "exports", "respondents", "polardata",
  "polardata_rebuild"
)) {
  source(paste0("R/", file, ".R"))
}
arguments <- commandArgs(trailingOnly = TRUE)
stopifnot(length(arguments) <= 1L)
directory <- if (length(arguments)) {
  arguments[[1]]
} else {
  tempfile("uk-crime-correction-")
}
fs::dir_create(directory)
poll_id <- "uk-crime-1994"
survey <- read_poll_survey(poll_id)
corrected_attitudes <- crime_attitudes
crime_attitudes <- function(survey, wave) {
  result <- corrected_attitudes(survey, wave)
  if (wave == 2L) {
    components <- vapply(c("morecop1", "violtv2", "schdisc2"), function(field) {
      (read_source_codes(survey, field, 1:5) - 1) / 4
    }, numeric(nrow(survey)))
    result$root_causes_t2 <- historical_available_mean(components)
  }
  result
}
before <- build_historical_poll(poll_id)
all_before <- crime_attitudes(survey, 2L)$root_causes_t2
crime_attitudes <- corrected_attitudes
after <- build_historical_poll(poll_id)
all_after <- crime_attitudes(survey, 2L)$root_causes_t2
all_rows <- tibble::tibble(
  source_row = survey$source_row,
  sample = dplyr::case_when(
    survey$source_row %in% before$source_row ~ "historical-299",
    as.numeric(survey$part) == 1 ~ "attendee-outside-historical",
    .default = "other-source-records"
  ),
  historical_post = all_before, candidate_post = all_after
)
all_summary <- all_rows |>
  dplyr::group_by(.data$sample) |>
  dplyr::summarise(
    source_records = dplyr::n(),
    historical_observed = sum(!is.na(.data$historical_post)),
    candidate_observed = sum(!is.na(.data$candidate_post)),
    value_changes = sum(
      .data$historical_post != .data$candidate_post, na.rm = TRUE
    ),
    observed_to_missing = sum(
      !is.na(.data$historical_post) & is.na(.data$candidate_post)
    ),
    missing_to_observed = sum(
      is.na(.data$historical_post) & !is.na(.data$candidate_post)
    )
  )
readr::write_csv(all_summary, file.path(directory, "all_source_records.csv"))
stopifnot(identical(before$caseid, after$caseid))
changes <- lapply(names(before), function(field) {
  a <- before[[field]]
  b <- after[[field]]
  both <- !is.na(a) & !is.na(b)
  tibble::tibble(
    field = field, value_changes = sum(a[both] != b[both]),
    missingness_changes = sum(is.na(a) != is.na(b))
  )
}) |>
  dplyr::bind_rows() |>
  dplyr::filter(value_changes + missingness_changes > 0)
readr::write_csv(changes, file.path(directory, "field_changes.csv"))
stopifnot(identical(changes$field, "ukcrime.rootcauset2"))
rows <- match(before$source_row, survey$source_row)
a <- before$ukcrime.rootcauset2
b <- after$ukcrime.rootcauset2
pre <- before$ukcrime.rootcauset1
comparison <- tibble::tibble(
  caseid = before$caseid, source_row = before$source_row,
  pollgroup = before$pollgroup,
  baseline_police_raw = as.numeric(survey$morecop1[rows]),
  post_children_raw = as.numeric(survey$timchld2[rows]),
  post_tv_raw = as.numeric(survey$violtv2[rows]),
  post_discipline_raw = as.numeric(survey$schdisc2[rows]),
  pre = pre, historical_post = a, candidate_post = b, delta = b - a
)
readr::write_csv(comparison, file.path(directory, "respondent_comparison.csv"))
summary <- tibble::tibble(
  version = c("historical", "candidate"), n = c(sum(!is.na(a)), sum(!is.na(b))),
  mean_pre_all = mean(pre, na.rm = TRUE),
  mean_post = c(mean(a, na.rm = TRUE), mean(b, na.rm = TRUE)),
  mean_change = c(mean(a - pre, na.rm = TRUE), mean(b - pre, na.rm = TRUE)),
  sd_post = c(sd(a, na.rm = TRUE), sd(b, na.rm = TRUE))
)
readr::write_csv(summary, file.path(directory, "summary.csv"))
paired <- complete.cases(pre, a, b)
readr::write_csv(tibble::tibble(
  n = sum(paired), historical_post = mean(a[paired]),
  candidate_post = mean(b[paired]),
  mean_pre = mean(pre[paired]),
  historical_change = mean(a[paired] - pre[paired]),
  candidate_change = mean(b[paired] - pre[paired]),
  mean_delta = mean(b[paired] - a[paired]),
  max_absolute_delta = max(abs(b[paired] - a[paired])),
  increases = sum(b[paired] > a[paired]),
  decreases = sum(b[paired] < a[paired]),
  unchanged = sum(b[paired] == a[paired])
), file.path(directory, "common_sample.csv"))
wide <- arrow::read_parquet("output/polardata/polardata.parquet")
keep <- which(wide$dpnum == 6)
stopifnot(length(keep) == 299L)
idx <- match(wide$caseid[keep], before$caseid)
stopifnot(
  !anyNA(idx), isTRUE(all.equal(wide$ukcrime.rootcauset2[keep], b[idx]))
)
wide$ukcrime.rootcauset2[keep] <- a[idx]
readr::write_tsv(wide,
  file.path(directory, "historical-polardata.tab"), na = ""
)
wide$ukcrime.rootcauset2[keep] <- b[idx]
readr::write_tsv(wide, file.path(directory, "candidate-polardata.tab"), na = "")
arrow::write_parquet(wide, file.path(directory, "candidate-polardata.parquet"))
print(changes)
print(summary)
print(readr::read_csv(
  file.path(directory, "common_sample.csv"), show_col_types = FALSE
))
print(comparison[is.na(a) != is.na(b), ])

message("Approved correction comparisons written to: ", directory)
