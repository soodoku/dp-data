# CPL-05 group-count proposal; respondent coding and group membership are fixed.
for (file in c(
  "paths", "sources", "metadata", "poll_sources", "poll_adapters",
  "knowledge", "exports", "respondents", "polardata", "polardata_rebuild"
)) {
  source(paste0("R/", file, ".R"))
}
arguments <- commandArgs(trailingOnly = TRUE)
stopifnot(length(arguments) <= 1L)
directory <- if (length(arguments)) arguments[[1]] else tempfile("cpl-review-")
fs::dir_create(directory)
poll_id <- "cpl-1996"
survey <- read_poll_survey(poll_id)
before <- build_historical_poll(poll_id)
original_derived <- build_core_derived
build_core_derived <- function(survey, values, poll_id) {
  result <- original_derived(survey, values, poll_id)
  if (poll_id == "cpl-1996") {
    profile <- core_poll_profile(survey, poll_id)
    rows <- match(values$source_row, survey$source_row)
    result$grpgain <- historical_fractional_gain(
      profile$before * profile$after, profile$group
    )[rows]
    result$grpgainr <- result$grpgain
    result$loggain <- historical_log_score(result$grpgain)
  }
  result
}
after <- build_historical_poll(poll_id)
fields <- c("grpgain", "grpgainr", "loggain")
stopifnot(
  nrow(before) == 216L, identical(before$caseid, after$caseid),
  identical(
    before[setdiff(names(before), fields)],
    after[setdiff(names(after), fields)]
  )
)
profile <- core_poll_profile(survey, poll_id)
joint <- profile$before * profile$after
size <- historical_group_summary(rep(1, nrow(survey)), profile$group, sum)
early_size <- historical_group_summary(
  ifelse(survey$source_row <= 202, 1, NA_real_), profile$group, sum
)
# Reproduce the archived grpfun indexing with its short vector literally.
short <- rep(1, 202L)[!is.na(profile$group)]
archived_count <- unsplit(
  lapply(split(short, profile$group[!is.na(profile$group)]), sum, na.rm = TRUE),
  profile$group[!is.na(profile$group)]
)
stopifnot(
  identical(as.numeric(archived_count), early_size[!is.na(profile$group)])
)
candidate <- historical_fractional_gain(joint, profile$group)
historical <- candidate * (early_size / (early_size - 1)) / (size / (size - 1))
selected <- match(before$source_row, survey$source_row)
direct <- vapply(selected, function(row) {
  missed <- which(joint[row, ] == 0)
  peers <- which(profile$group == profile$group[row])
  peers <- setdiff(peers, row)
  if (!length(missed)) {
    return(NA_real_)
  }
  mean(joint[peers, missed, drop = FALSE])
}, numeric(1))
stopifnot(isTRUE(all.equal(candidate[selected], direct, tolerance = 1e-12)))
rows <- tibble::tibble(
  source_row = survey$source_row,
  historical_sample = survey$source_row %in% before$source_row,
  historical_respondent_id = before$caseid[
    match(survey$source_row, before$source_row)
  ],
  pollgroup = profile$group, early_group_size = early_size, group_size = size,
  historical_gain = historical, candidate_gain = candidate,
  joint_knowledge = rowMeans(joint)
)
readr::write_csv(rows, file.path(directory, "respondent_comparison.csv"))
groups <- rows |>
  dplyr::filter(!is.na(pollgroup)) |>
  dplyr::summarise(
    respondents = dplyr::n(), early_group_size = dplyr::first(early_group_size),
    historical_mean = mean(historical_gain, na.rm = TRUE),
    candidate_mean = mean(candidate_gain, na.rm = TRUE),
    value_changes = sum(
      abs(historical_gain - candidate_gain) > 1e-12, na.rm = TRUE
    ),
    .by = pollgroup
  )
readr::write_csv(groups, file.path(directory, "group_comparison.csv"))
all_source <- rows |>
  dplyr::summarise(
    source_records = dplyr::n(),
    historical_observed = sum(!is.na(historical_gain)),
    candidate_observed = sum(!is.na(candidate_gain)),
    value_changes = sum(
      abs(historical_gain - candidate_gain) > 1e-12, na.rm = TRUE
    ),
    missingness_changes = sum(is.na(historical_gain) != is.na(candidate_gain)),
    .by = historical_sample
  )
readr::write_csv(all_source, file.path(directory, "all_source_records.csv"))
summary <- purrr::map_dfr(fields, function(field) {
  a <- before[[field]]
  b <- after[[field]]
  both <- !is.na(a) & !is.na(b)
  tibble::tibble(
    field = field, respondents = length(a),
    historical_observed = sum(!is.na(a)), candidate_observed = sum(!is.na(b)),
    value_changes = sum(abs(a[both] - b[both]) > 1e-12),
    missingness_changes = sum(is.na(a) != is.na(b)),
    historical_mean = mean(a, na.rm = TRUE),
    candidate_mean = mean(b, na.rm = TRUE),
    max_absolute_delta = max(abs(a[both] - b[both]))
  )
})
readr::write_csv(summary, file.path(directory, "field_changes.csv"))
wide <- arrow::read_parquet("output/polardata/polardata.parquet")
keep <- which(wide$dpnum == 8L)
positions <- match(wide$caseid[keep], before$caseid)
stopifnot(length(keep) == 216L, !anyNA(positions))
for (field in fields) wide[[field]][keep] <- before[[field]][positions]
readr::write_tsv(wide,
  file.path(directory, "historical-polardata.tab"),
  na = ""
)
for (field in fields) wide[[field]][keep] <- after[[field]][positions]
readr::write_tsv(wide,
  file.path(directory, "candidate-polardata.tab"),
  na = ""
)
print(summary, width = Inf)
print(groups, n = Inf, width = Inf)
message("Unapproved CPL-05 diagnostics written to: ", directory)
