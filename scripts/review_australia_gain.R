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
values <- purrr::map_dfr(c("grpgain", "loggain"), function(name) {
  original <- if (name == "grpgain") historical_gain else historical_log
  tibble::tibble(
    legacy_field = name, caseid = corrected$caseid,
    historical_value = original, approved_value = corrected[[name]]
  )
})
readr::write_csv(values, file.path(directory, "approved_values.csv"))

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
  all(summary$finite_paired_changes == 342L),
  all(summary$missingness_changes == 1L),
  all(summary$historical_infinite == 1L),
  all(summary$corrected_infinite == 0L)
)
readr::write_csv(summary, file.path(directory, "field_changes.csv"))
print(summary)
