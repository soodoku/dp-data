# UKGE-03 counterfactual review; production files are never overwritten.
for (file in c(
  "paths", "sources", "metadata", "poll_sources", "poll_adapters",
  "knowledge", "exports", "respondents", "polardata", "polardata_rebuild"
)) {
  source(paste0("R/", file, ".R"))
}
arguments <- commandArgs(trailingOnly = TRUE)
stopifnot(length(arguments) <= 1L)
directory <- if (length(arguments)) {
  arguments[[1]]
} else {
  tempfile("uk-ge-review-")
}
fs::dir_create(directory)
poll_id <- "uk-general-election-1997"
survey <- read_poll_survey(poll_id)
before <- build_historical_poll(poll_id)
individual_before <- build_election_individual(survey)
original_items <- election_knowledge_items
items_before <- original_items(survey, 2L)
election_knowledge_items <- function(survey, wave) {
  result <- original_items(survey, wave)
  if (wave == 2L) {
    value <- read_source_codes(survey, "wagel2", c(-9, -8, 1:7))
    result[, "wage_l"] <- as.numeric(value %in% 5:7)
  }
  result
}
after <- build_historical_poll(poll_id)
individual_after <- build_election_individual(survey)
items_after <- election_knowledge_items(survey, 2L)
stopifnot(
  identical(before$caseid, after$caseid), nrow(before) == 275L,
  identical(
    items_before[, colnames(items_before) != "wage_l"],
    items_after[, colnames(items_after) != "wage_l"]
  ),
  identical(individual_before$knowledge_t1, individual_after$knowledge_t1)
)
compare_fields <- function(a, b) {
  purrr::map_dfr(names(a), function(field) {
    both <- !is.na(a[[field]]) & !is.na(b[[field]])
    delta <- if (is.numeric(a[[field]])) b[[field]] - a[[field]] else NA_real_
    tibble::tibble(
      field = field,
      value_changes = if (is.numeric(a[[field]])) {
        sum(abs(a[[field]][both] - b[[field]][both]) > 1e-12)
      } else {
        sum(a[[field]][both] != b[[field]][both])
      },
      exact_value_changes = sum(a[[field]][both] != b[[field]][both]),
      missingness_changes = sum(is.na(a[[field]]) != is.na(b[[field]])),
      mean_before = if (is.numeric(a[[field]])) {
        mean(a[[field]], na.rm = TRUE)
      } else {
        NA_real_
      },
      mean_after = if (is.numeric(b[[field]])) {
        mean(b[[field]], na.rm = TRUE)
      } else {
        NA_real_
      },
      max_absolute_delta = if (all(is.na(delta))) {
        NA_real_
      } else {
        max(abs(delta), na.rm = TRUE)
      }
    )
  }) |> dplyr::filter(value_changes + missingness_changes > 0)
}
readr::write_csv(
  compare_fields(before, after),
  file.path(directory, "aggregate_field_changes.csv")
)
readr::write_csv(
  compare_fields(individual_before, individual_after),
  file.path(directory, "canonical_field_changes.csv")
)
selected <- survey$source_row %in% before$source_row
source_score <- as.numeric(survey$wgel2cor)
stopifnot(identical(
  source_score[selected], as.numeric(items_after[selected, "wage_l"])
))
readr::write_csv(tibble::tibble(
  respondents = sum(selected),
  deposited_correct = sum(source_score[selected] == 1),
  historical_disagreements = sum(
    source_score[selected] != items_before[selected, "wage_l"]
  ),
  candidate_disagreements = sum(
    source_score[selected] != items_after[selected, "wage_l"]
  ),
  source_field = "wgel2cor",
  source_label = attr(survey$wgel2cor, "label")
), file.path(directory, "deposited_score_check.csv"))
rows <- tibble::tibble(
  source_row = survey$source_row, caseid = as.numeric(survey$serial),
  historical_sample = selected, group = as.numeric(survey$group),
  baseline_raw = as.numeric(survey$wagel1),
  post_raw = as.numeric(survey$wagel2),
  historical_item = items_before[, "wage_l"],
  candidate_item = items_after[, "wage_l"],
  baseline_knowledge = individual_before$knowledge_t1,
  historical_post_knowledge = individual_before$knowledge_t2,
  candidate_post_knowledge = individual_after$knowledge_t2,
  historical_joint_knowledge = individual_before$knowledge_joint,
  candidate_joint_knowledge = individual_after$knowledge_joint
)
readr::write_csv(rows, file.path(directory, "respondent_comparison.csv"))
summary <- rows |>
  dplyr::group_by(historical_sample) |>
  dplyr::summarise(
    respondents = dplyr::n(),
    historical_item_mean = mean(historical_item),
    candidate_item_mean = mean(candidate_item),
    incorrect_to_correct = sum(historical_item == 0 & candidate_item == 1),
    correct_to_incorrect = sum(historical_item == 1 & candidate_item == 0),
    baseline_knowledge = mean(baseline_knowledge),
    historical_post_knowledge = mean(historical_post_knowledge),
    candidate_post_knowledge = mean(candidate_post_knowledge),
    historical_joint_knowledge = mean(historical_joint_knowledge),
    candidate_joint_knowledge = mean(candidate_joint_knowledge),
    historical_gain = mean(historical_post_knowledge - baseline_knowledge),
    candidate_gain = mean(candidate_post_knowledge - baseline_knowledge)
  )
readr::write_csv(summary, file.path(directory, "summary.csv"))
wide <- arrow::read_parquet("output/polardata/polardata.parquet")
keep <- which(wide$dpnum == 4L)
stopifnot(length(keep) == 275L)
positions <- match(wide$caseid[keep], before$caseid)
stopifnot(!anyNA(positions))
fields <- intersect(names(before), names(wide))
for (field in fields) wide[[field]][keep] <- before[[field]][positions]
readr::write_tsv(wide,
  file.path(directory, "historical-polardata.tab"),
  na = ""
)
for (field in fields) wide[[field]][keep] <- after[[field]][positions]
readr::write_tsv(wide, file.path(directory, "candidate-polardata.tab"), na = "")
print(summary, width = Inf)
print(compare_fields(before, after), n = Inf, width = Inf)
message("Unapproved UKGE-03 diagnostics written to: ", directory)
