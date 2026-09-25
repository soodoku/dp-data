# TE-04 wave-only proposal; preserve historical samples, scales and weights.
for (file in c(
  "paths", "sources", "metadata", "poll_sources", "poll_adapters",
  "knowledge", "exports", "respondents", "polardata", "polardata_rebuild"
)) {
  source(paste0("R/", file, ".R"))
}
arguments <- commandArgs(trailingOnly = TRUE)
stopifnot(length(arguments) <= 1L)
directory <- if (length(arguments)) arguments[[1]] else tempfile("te-review-")
fs::dir_create(directory)
poll_id <- "tomorrows-europe-2007"
survey <- read_poll_survey(poll_id)
before <- build_historical_poll(poll_id)
original_attitudes <- tomorrows_europe_attitudes
historical_all <- original_attitudes(survey, 3L)
tomorrows_europe_attitudes <- function(survey, wave) {
  result <- original_attitudes(survey, wave)
  if (wave == 3L) {
    item <- function(question, scale = 10, reverse = FALSE) {
      value <- tomorrows_europe_codes(
        survey, paste0("t3q", question), c(if (scale == 10) 0:10 else 1:5, 99)
      )
      value[value == 99 & !is.na(value)] <- NA_real_
      value <- if (scale == 10) value / 10 else (value - 1) / 4
      if (reverse) 1 - value else value
    }
    militarism <- tomorrows_europe_mean(
      item("11a", 5, TRUE), item("11c", 5, TRUE)
    )
    circumstances <- tomorrows_europe_mean(
      item("12a"), item("12b"), item("12c"), item("12d")
    )
    result$military <- tomorrows_europe_mean(militarism, circumstances)
    trade <- (item("7d", 5) - item("7a", 5) + 1) / 2
    result$trade <- tomorrows_europe_mean(trade, item("8"))
  }
  result
}
after <- build_historical_poll(poll_id)
candidate_all <- tomorrows_europe_attitudes(survey, 3L)
stopifnot(
  nrow(before) == 344L, identical(before$caseid, after$caseid),
  identical(before$source_row, after$source_row)
)
changed_fields <- names(before)[!vapply(names(before), function(field) {
  isTRUE(all.equal(before[[field]], after[[field]], tolerance = 1e-12))
}, logical(1))]
stopifnot(setequal(
  changed_fields, c("eu.mil_att_11_12_t3", "eu.free_trade_index_t3")
))
field_changes <- purrr::map_dfr(changed_fields, function(field) {
  a <- before[[field]]
  b <- after[[field]]
  common <- !is.na(a) & !is.na(b)
  tibble::tibble(
    field = field, respondents = length(a),
    historical_observed = sum(!is.na(a)), candidate_observed = sum(!is.na(b)),
    value_changes = sum(abs(a[common] - b[common]) > 1e-12),
    observed_to_missing = sum(!is.na(a) & is.na(b)),
    missing_to_observed = sum(is.na(a) & !is.na(b)),
    historical_mean = mean(a, na.rm = TRUE),
    candidate_mean = mean(b, na.rm = TRUE),
    common_sample = sum(common), historical_common = mean(a[common]),
    candidate_common = mean(b[common]),
    max_absolute_delta = max(abs(b[common] - a[common]))
  )
})
readr::write_csv(field_changes, file.path(directory, "field_changes.csv"))
rows <- tibble::tibble(
  source_row = survey$source_row,
  caseid = as.numeric(survey$v_b),
  historical_sample = survey$source_row %in% before$source_row,
  historical_military = historical_all$military,
  candidate_military = candidate_all$military,
  historical_trade = historical_all$trade,
  candidate_trade = candidate_all$trade
)
raw_fields <- c(
  "t2q8", "t3q8", paste0("t2q12", letters[1:4]),
  paste0("t3q12", letters[1:4]), "t3q11a", "t3q11c", "t3q7a", "t3q7d"
)
for (field in raw_fields) {
  position <- match(tolower(field), tolower(names(survey)))
  rows[[field]] <- as.numeric(survey[[position]])
}
readr::write_csv(rows, file.path(directory, "respondent_comparison.csv"))
all_summary <- purrr::map_dfr(c("military", "trade"), function(measure) {
  tibble::tibble(
    historical_sample = rows$historical_sample,
    a = rows[[paste0("historical_", measure)]],
    b = rows[[paste0("candidate_", measure)]]
  ) |>
    dplyr::group_by(historical_sample) |>
    dplyr::summarise(
      measure = measure, source_records = dplyr::n(),
      historical_observed = sum(!is.na(a)), candidate_observed = sum(!is.na(b)),
      value_changes = sum(abs(a - b) > 1e-12, na.rm = TRUE),
      observed_to_missing = sum(!is.na(a) & is.na(b)),
      missing_to_observed = sum(is.na(a) & !is.na(b))
    )
})
readr::write_csv(all_summary, file.path(directory, "all_source_records.csv"))
stored_checks <- purrr::map_dfr(c("military", "trade"), function(measure) {
  field <- if (measure == "military") {
    "mil_att_11_12_t3"
  } else {
    "Free_trade_index_t3"
  }
  stored <- as.numeric(survey[[field]])
  historical <- rows[[paste0("historical_", measure)]]
  candidate <- rows[[paste0("candidate_", measure)]]
  both <- !is.na(stored) & !is.na(historical)
  stopifnot(
    identical(is.na(stored), is.na(historical)),
    all(abs(stored[both] - historical[both]) < 1e-10)
  )
  common <- !is.na(stored) & !is.na(candidate)
  tibble::tibble(
    measure = measure, stored_field = field,
    historical_value_changes = sum(
      abs(stored[both] - historical[both]) > 1e-10
    ),
    historical_missing_changes = sum(is.na(stored) != is.na(historical)),
    candidate_value_changes = sum(
      abs(stored[common] - candidate[common]) > 1e-10
    ),
    candidate_missing_changes = sum(is.na(stored) != is.na(candidate))
  )
})
readr::write_csv(
  stored_checks,
  file.path(directory, "deposited_index_check.csv")
)

wide <- arrow::read_parquet("output/polardata/polardata.parquet")
keep <- which(wide$dpnum == 7L)
positions <- match(wide$caseid[keep], before$caseid)
stopifnot(length(keep) == 344L, !anyNA(positions))
for (field in changed_fields) wide[[field]][keep] <- before[[field]][positions]
readr::write_tsv(wide,
  file.path(directory, "historical-polardata.tab"),
  na = ""
)
for (field in changed_fields) wide[[field]][keep] <- after[[field]][positions]
readr::write_tsv(wide,
  file.path(directory, "candidate-polardata.tab"),
  na = ""
)
print(field_changes, width = Inf)
print(all_summary, width = Inf)
message("Unapproved TE-04 diagnostics written to: ", directory)
