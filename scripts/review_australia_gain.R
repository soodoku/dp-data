for (file in c(
  "paths", "sources", "metadata", "poll_sources", "poll_adapters",
  "knowledge", "exports", "respondents", "polardata", "polardata_rebuild"
)) {
  source(paste0("R/", file, ".R"))
}

survey <- read_poll_survey("australia-republic-1999")
corrected <- build_historical_poll("australia-republic-1999")
field <- match("group", tolower(names(survey)))
selected <- which(as.numeric(unclass(survey[[field]])) %in% 1:24)
selected <- selected[order(survey$source_row[selected])]
before <- australia_knowledge_items(survey, 1L)[selected, ]
after <- australia_knowledge_items(survey, 2L)[selected, ]
group <- as.numeric(unclass(survey[[field]]))[selected]
joint <- rowMeans(before * after)
gain <- historical_group_gain(before * after, group) *
  (1 - joint) * 12 / 11
gain[is.na(gain) & joint == 1] <- 0
historical_gain <- gain[(corrected$source_row - 1L) %% length(gain) + 1L] /
  (1 - corrected$t1knowcor)
historical_log <- historical_log_score(historical_gain)
positions <- match(corrected$source_row, survey$source_row[selected])
previous_gain <- gain[positions] / (1 - corrected$t1knowcor)
stopifnot(
  ncol(before) == 12L, ncol(after) == 12L,
  all(corrected$numitems == 12),
  isTRUE(all.equal(corrected$grpgain, previous_gain * 11 / 12,
                   tolerance = 1e-10)),
  sum(is.na(corrected$grpgain)) == 1L,
  sum(abs(corrected$grpgain - previous_gain) > 1e-10, na.rm = TRUE) == 346L
)

reference <- readr::read_tsv(
  "evidence/benchmarks/polardata.tab", show_col_types = FALSE
)
reference <- reference[reference$pollid == 26, ]
positions <- match(corrected$caseid, reference$caseid)
stopifnot(
  nrow(corrected) == 347L, nrow(reference) == 347L,
  !anyNA(positions), !anyDuplicated(positions),
  isTRUE(all.equal(historical_gain, reference$grpgain[positions],
                   tolerance = 1e-10)),
  isTRUE(all.equal(historical_log, reference$loggain[positions],
                   tolerance = 1e-10))
)

directory <- "audit/corrections/australia-republic-1999"
fs::dir_create(directory)
fields <- c("grpgain", "loggain", "numitems")
values <- purrr::map_dfr(fields, function(name) {
  original <- switch(name, grpgain = historical_gain,
                     loggain = historical_log, numitems = rep(11, 347L))
  tibble::tibble(
    legacy_field = name, caseid = corrected$caseid,
    historical_value = original, approved_value = corrected[[name]]
  )
})
path <- file.path(directory, "approved_values.csv")
existing <- readr::read_csv(path, show_col_types = FALSE)
combined <- dplyr::rows_upsert(
  existing, values, by = c("legacy_field", "caseid")
)
readr::write_csv(combined, path)

summary <- values |>
  dplyr::group_by(.data$legacy_field) |>
  dplyr::summarise(
    respondents = dplyr::n(),
    finite_paired_changes = sum(
      is.finite(.data$historical_value) &
        is.finite(.data$approved_value) &
        abs(.data$historical_value - .data$approved_value) > 1e-10,
      na.rm = TRUE
    ),
    missingness_changes = sum(
      is.na(.data$historical_value) != is.na(.data$approved_value)
    ),
    historical_infinite = sum(is.infinite(.data$historical_value)),
    corrected_infinite = sum(is.infinite(.data$approved_value)),
    .groups = "drop"
  )
stopifnot(
  all(summary$missingness_changes[summary$legacy_field != "numitems"] == 1L),
  all(summary$historical_infinite[summary$legacy_field != "numitems"] == 1L),
  all(summary$corrected_infinite == 0L),
  summary$finite_paired_changes[summary$legacy_field == "numitems"] == 347L
)
summary_path <- file.path(directory, "field_changes.csv")
existing_summary <- readr::read_csv(summary_path, show_col_types = FALSE)
readr::write_csv(dplyr::rows_upsert(
  existing_summary, summary, by = "legacy_field"
), summary_path)
count_values <- tibble::tibble(
  caseid = corrected$caseid, source_row = corrected$source_row,
  previous_grpgain = previous_gain, corrected_grpgain = corrected$grpgain,
  previous_loggain = historical_log_score(previous_gain),
  corrected_loggain = corrected$loggain,
  previous_numitems = 11L, corrected_numitems = corrected$numitems
)
readr::write_csv(count_values, file.path(directory, "item_count_values.csv"))
print(summary)
