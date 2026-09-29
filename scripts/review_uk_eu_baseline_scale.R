# UKEU-02 proposal: exclude nonanswers before scaling baseline attitudes.
for (module in c(
  "paths", "sources", "metadata", "poll_sources", "poll_adapters", "knowledge",
  "exports", "respondents", "polardata", "polardata_rebuild"
)) source(file.path("R", paste0(module, ".R")))

poll_id <- "uk-eu-1995"
source_path <- project_path("data", poll_id, "survey.sav")
source_hash <- tools::md5sum(source_path)
survey <- read_poll_survey(poll_id)
spss_source <- haven::read_sav(source_path, user_na = TRUE)
stopifnot(
  nrow(survey) == 900L, !anyDuplicated(survey$caseid),
  identical(as.numeric(spss_source$caseid), as.numeric(survey$caseid)),
  setequal(attr(spss_source$commies1, "na_values"), c(8, 9)),
  setequal(attr(spss_source$favref1, "na_values"), c(-1, 8, 9))
)

assert_values_equal <- function(actual, expected) {
  stopifnot(
    length(actual) == length(expected),
    identical(is.na(actual), is.na(expected)),
    all(abs(actual - expected) < 1e-10, na.rm = TRUE)
  )
}

current_individual <- build_eu_individual(survey)
proposed_individual <- current_individual
for (source_field in c("commies1", "favref1")) {
  raw_value <- as.numeric(survey[[source_field]])
  measure <- paste0("ukeu.", source_field, "r")
  assert_values_equal(current_individual[[measure]], (raw_value - 1) / 8)
  declared_missing <- attr(spss_source[[source_field]], "na_values")
  raw_value[raw_value %in% declared_missing] <- NA_real_
  stopifnot(all(is.na(raw_value) | raw_value %in% 1:5))
  proposed_individual[[measure]] <- (raw_value - 1) / 4
}
attitude_fields <- c(
  "ukeu.eurelat1g", "ukeu.euscope1g", "ukeu.commies1r", "ukeu.favref1r"
)
current_attitudes <- as.matrix(current_individual[attitude_fields])
proposed_attitudes <- as.matrix(proposed_individual[attitude_fields])
assert_values_equal(
  current_individual$attextreme,
  historical_available_mean(abs(current_attitudes - .5))
)
proposed_individual$attextreme <- historical_available_mean(
  abs(proposed_attitudes - .5)
)

current_aggregate <- build_historical_poll(poll_id)
source_rows <- match(current_aggregate$caseid, survey$caseid)
stopifnot(
  nrow(current_aggregate) == 238L, !anyNA(source_rows),
  !anyDuplicated(source_rows), all(survey$part[source_rows] == 1)
)
profile <- core_poll_profile(survey, poll_id)
current_dispersion <- historical_group_dispersion(
  current_attitudes, profile$group
)
proposed_dispersion <- historical_group_dispersion(
  proposed_attitudes, profile$group
)
assert_values_equal(
  current_aggregate$avgsd, current_dispersion$average_sd[source_rows]
)
assert_values_equal(
  current_aggregate$genvar, current_dispersion$generalized_variance[source_rows]
)
assert_values_equal(
  current_aggregate$meanxtreme,
  historical_group_summary(
    current_individual$attextreme[source_rows], current_aggregate$pollgroup
  )
)

proposed_aggregate <- current_aggregate
individual_fields <- c("ukeu.commies1r", "ukeu.favref1r", "attextreme")
for (field in individual_fields) {
  assert_values_equal(
    current_aggregate[[field]], current_individual[[field]][source_rows]
  )
  proposed_aggregate[[field]] <- proposed_individual[[field]][source_rows]
}
proposed_aggregate$meanxtreme <- historical_group_summary(
  proposed_aggregate$attextreme, current_aggregate$pollgroup
)
proposed_aggregate$avgsd <- proposed_dispersion$average_sd[source_rows]
proposed_aggregate$genvar <-
  proposed_dispersion$generalized_variance[source_rows]
aggregate_fields <- c(individual_fields, "meanxtreme", "avgsd", "genvar")

comparison_rows <- function(current, proposed, fields, cohort, source_rows) {
  purrr::map(fields, function(measure_name) {
    tibble::tibble(
      status = "proposed", poll_id, cohort, field = measure_name,
      caseid = as.numeric(survey$caseid[source_rows]),
      source_row = survey$source_row[source_rows],
      current_value = current[[measure_name]],
      proposed_value = proposed[[measure_name]]
    )
  }) |>
    purrr::list_rbind()
}
values <- dplyr::bind_rows(
  comparison_rows(
    current_individual, proposed_individual, individual_fields,
    "all_source", seq_len(nrow(survey))
  ),
  comparison_rows(
    current_aggregate, proposed_aggregate, aggregate_fields,
    "historical_participants", source_rows
  )
)
summary <- values |>
  dplyr::summarise(
    respondents = dplyr::n(),
    numeric_changes = sum(
      abs(.data$current_value - .data$proposed_value) > 1e-10, na.rm = TRUE
    ),
    missingness_changes = sum(
      is.na(.data$current_value) != is.na(.data$proposed_value)
    ),
    current_observed = sum(!is.na(.data$current_value)),
    proposed_observed = sum(!is.na(.data$proposed_value)),
    current_mean = mean(.data$current_value, na.rm = TRUE),
    proposed_mean = mean(.data$proposed_value, na.rm = TRUE),
    .by = c("status", "poll_id", "cohort", "field")
  ) |>
  dplyr::mutate(
    changed_values = .data$numeric_changes + .data$missingness_changes
  )
participant_summary <- dplyr::filter(
  summary, .data$cohort == "historical_participants"
)
source_summary <- dplyr::filter(summary, .data$cohort == "all_source")
stopifnot(
  identical(
    participant_summary$changed_values, c(228L, 235L, 218L, 222L, 238L, 238L)
  ),
  all(participant_summary$missingness_changes == 0L),
  identical(source_summary$changed_values, c(855L, 886L, 822L)),
  identical(source_summary$missingness_changes, c(12L, 4L, 2L))
)

count_answer_artifacts <- function(stem) {
  baseline <- as.numeric(survey[[paste0(stem, "1")]])
  post <- as.numeric(survey[[paste0(stem, "2")]])
  same_answer <- which(survey$part == 1 & baseline %in% 2:5 & baseline == post)
  field <- paste0("ukeu.", stem)
  stopifnot(all(
    current_individual[[paste0(field, "2r")]][same_answer] >
      current_individual[[paste0(field, "1r")]][same_answer]
  ))
  assert_values_equal(
    proposed_individual[[paste0(field, "1r")]][same_answer],
    proposed_individual[[paste0(field, "2r")]][same_answer]
  )
  length(same_answer)
}
unchanged_answer_counts <- purrr::map_int(
  c("commies", "favref"), count_answer_artifacts
)
stopifnot(
  identical(unchanged_answer_counts, c(95L, 101L)),
  identical(source_hash, tools::md5sum(source_path))
)
summary$unchanged_answer_artifacts <- NA_integer_
summary$unchanged_answer_artifacts[match(
  paste("historical_participants", individual_fields[1:2]),
  paste(summary$cohort, summary$field)
)] <- unchanged_answer_counts

directory <- project_path("audit", "corrections", poll_id)
fs::dir_create(directory)
readr::write_csv(
  values, file.path(directory, "baseline_scale_proposed_values.csv")
)
readr::write_csv(summary, file.path(directory, "baseline_scale_summary.csv"))
print(summary)
message("UKEU-02 proposal written; production values unchanged.")
