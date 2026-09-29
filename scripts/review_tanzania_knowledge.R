# TZ-03 independent reconstruction and approved missing-component validation.
source("R/paths.R")

poll_id <- "tanzania-2015"
source_path <- project_path("data", poll_id, "participants.dta")
source_hash <- tools::md5sum(source_path)
survey <- haven::read_dta(source_path) |>
  dplyr::filter(haven::as_factor(.data$sample) == "Citizens")
baseline <- as.matrix(survey[paste0("H6", 1:9, 0)])
follow_up <- as.matrix(survey[paste0("H6", 1:9, 1)])
control_rows <- which(survey$z == 0)
stopifnot(
  nrow(survey) == 2002L, !anyDuplicated(survey$HHID),
  length(control_rows) == 1000L,
  sum(baseline[, 1] == -99, na.rm = TRUE) == 173L,
  sum(follow_up[, 1] == -99, na.rm = TRUE) == 25L
)

standardized_composite <- function(items, calibration) {
  standardized_items <- sweep(
    sweep(items, 2L, calibration$item_mean),
    2L, calibration$item_sd, "/"
  )
  result <- rowMeans(standardized_items, na.rm = TRUE)
  result[rowSums(!is.na(items)) == 0L] <- NA_real_
  result
}

fit_calibration <- function(items, reference_rows) {
  reference <- items[reference_rows, , drop = FALSE]
  calibration <- list(
    item_mean = colMeans(reference, na.rm = TRUE),
    item_sd = apply(reference, 2L, stats::sd, na.rm = TRUE)
  )
  stopifnot(all(is.finite(calibration$item_sd)), all(calibration$item_sd > 0))
  composite <- standardized_composite(items, calibration)[reference_rows]
  calibration$composite_mean <- mean(composite, na.rm = TRUE)
  calibration$composite_sd <- stats::sd(composite, na.rm = TRUE)
  stopifnot(is.finite(calibration$composite_sd), calibration$composite_sd > 0)
  calibration
}

score_items <- function(items, calibration) {
  (standardized_composite(items, calibration) - calibration$composite_mean) /
    calibration$composite_sd
}

assert_scores_equal <- function(actual, expected) {
  stopifnot(
    length(actual) == length(expected),
    identical(is.na(actual), is.na(expected)),
    all(abs(actual - expected) < 1e-10, na.rm = TRUE)
  )
}

old_calibration <- fit_calibration(baseline, control_rows)
assert_scores_equal(score_items(baseline, old_calibration), survey$H600)
assert_scores_equal(score_items(follow_up, old_calibration), survey$H601)

proposed_baseline <- baseline
proposed_follow_up <- follow_up
proposed_baseline[which(baseline[, 1] == -99), 1] <- 0
proposed_follow_up[which(follow_up[, 1] == -99), 1] <- 0
stopifnot(
  identical(baseline[, -1], proposed_baseline[, -1]),
  identical(follow_up[, -1], proposed_follow_up[, -1]),
  identical(is.na(baseline), is.na(proposed_baseline)),
  identical(is.na(follow_up), is.na(proposed_follow_up))
)
proposed_calibration <- fit_calibration(proposed_baseline, control_rows)

# Approved recode: exclude -99 without imputing any other missing component.
missing_baseline <- baseline
missing_follow_up <- follow_up
missing_baseline[which(baseline[, 1] == -99), 1] <- NA_real_
missing_follow_up[which(follow_up[, 1] == -99), 1] <- NA_real_
stopifnot(
  identical(baseline[, -1], missing_baseline[, -1]),
  identical(follow_up[, -1], missing_follow_up[, -1]),
  sum(is.na(missing_baseline)) - sum(is.na(baseline)) == 173L,
  sum(is.na(missing_follow_up)) - sum(is.na(follow_up)) == 25L
)
missing_calibration <- fit_calibration(missing_baseline, control_rows)

read_analysis <- function(table_name) {
  arrow::read_parquet(project_path(
    "output", "analysis", paste0(table_name, ".parquet")
  )) |>
    dplyr::filter(
      .data$poll_id == .env$poll_id, .data$source_dataset == "control"
    )
}
participants <- read_analysis("analysis_participants")
stopifnot(
  identical(participants$source_row, seq_len(nrow(survey))),
  identical(participants$respondent_id, as.character(seq_len(nrow(survey)))),
  identical(participants$cluster_id, as.character(survey$VillageID))
)

# Both canonical score tables must reproduce the approved independent recode.
for (table_name in c("analysis_scores", "analysis_phase_scores")) {
  scores <- read_analysis(table_name)
  waves <- if (table_name == "analysis_scores") c("t1", "t2") else c("t0", "t3")
  stopifnot(nrow(scores) == 4004L, setequal(scores$wave, waves))
  for (wave_index in seq_along(waves)) {
    wave_scores <- scores[scores$wave == waves[wave_index], ]
    positions <- match(wave_scores$respondent_id, participants$respondent_id)
    stopifnot(
      length(positions) == nrow(survey), !anyNA(positions),
      !anyDuplicated(positions)
    )
    expected <- score_items(
      list(missing_baseline, missing_follow_up)[[wave_index]],
      missing_calibration
    )[positions]
    assert_scores_equal(wave_scores$score, expected)
    stopifnot(all(wave_scores$scale == "standardized_index"))
  }
}

values <- purrr::map(seq_len(2L), function(wave_index) {
  items <- list(baseline, follow_up)[[wave_index]]
  proposed_items <- list(proposed_baseline, proposed_follow_up)[[wave_index]]
  tibble::tibble(
    status = "not-adopted-zero-alternative", poll_id,
    source_dataset = "control",
    respondent_id = participants$respondent_id, source_hhid = survey$HHID,
    arm = participants$arm, wave = c("t0", "t3")[wave_index],
    source_field = c("H600", "H601")[wave_index],
    raw_first_component = items[, 1],
    proposed_first_component = proposed_items[, 1],
    n_observed_components = rowSums(!is.na(items)),
    current_value = as.numeric(survey[[c("H600", "H601")[wave_index]]]),
    proposed_value = score_items(proposed_items, proposed_calibration),
    fixed_calibration_value = score_items(proposed_items, old_calibration)
  )
}) |>
  purrr::list_rbind()
score_summary <- values |>
  dplyr::summarise(
    respondents = dplyr::n(),
    first_component_changes = sum(
      .data$raw_first_component != .data$proposed_first_component, na.rm = TRUE
    ),
    fixed_calibration_changes = sum(
      abs(.data$fixed_calibration_value - .data$current_value) > 1e-10,
      na.rm = TRUE
    ),
    current_observed = sum(!is.na(.data$current_value)),
    proposed_observed = sum(!is.na(.data$proposed_value)),
    changed_values = sum(
      abs(.data$proposed_value - .data$current_value) > 1e-10, na.rm = TRUE
    ),
    missingness_changes = sum(
      is.na(.data$current_value) != is.na(.data$proposed_value)
    ),
    current_value = mean(.data$current_value, na.rm = TRUE),
    proposed_value = mean(.data$proposed_value, na.rm = TRUE),
    fixed_calibration_value = mean(.data$fixed_calibration_value, na.rm = TRUE),
    .by = "wave"
  ) |>
  dplyr::mutate(record_type = "score_mean", arm = "all")
stopifnot(
  identical(score_summary$first_component_changes, c(173L, 25L)),
  identical(score_summary$fixed_calibration_changes, c(173L, 25L)),
  identical(score_summary$current_observed, c(2001L, 1858L)),
  identical(score_summary$changed_values, c(2001L, 1858L)),
  all(score_summary$missingness_changes == 0L)
)
paired <- values |>
  dplyr::select(
    "respondent_id", "arm", "wave", "current_value", "proposed_value",
    "fixed_calibration_value"
  ) |>
  tidyr::pivot_wider(
    names_from = "wave",
    values_from = c(
      "current_value", "proposed_value", "fixed_calibration_value"
    )
  ) |>
  dplyr::filter(!is.na(.data$current_value_t0), !is.na(.data$current_value_t3))
stopifnot(nrow(paired) == 1857L)
gain_summary <- paired |>
  dplyr::summarise(
    respondents = dplyr::n(),
    current_value = mean(.data$current_value_t3 - .data$current_value_t0),
    proposed_value = mean(.data$proposed_value_t3 - .data$proposed_value_t0),
    fixed_calibration_value = mean(
      .data$fixed_calibration_value_t3 - .data$fixed_calibration_value_t0
    ), .by = "arm"
  ) |>
  dplyr::mutate(record_type = "paired_mean_gain", wave = "t0_to_t3")

paired_flag <- !is.na(survey$H600) & !is.na(survey$H601)
historical_panel <- !is.na(survey$H601)
panel_discrepancies <- which(historical_panel != paired_flag)
stopifnot(
  length(panel_discrepancies) == 1L,
  survey$HHID[panel_discrepancies] == 240301,
  participants$respondent_id[panel_discrepancies] == "1323",
  identical(participants$panel, paired_flag), sum(participants$panel) == 1857L
)
panel_summary <- tibble::tibble(
  record_type = "panel_count_if_both_scores_required", arm = "all",
  wave = "t0_to_t3", respondents = nrow(survey), changed_values = 1L,
  current_value = sum(historical_panel), proposed_value = sum(paired_flag)
)
summary <- dplyr::bind_rows(score_summary, gain_summary, panel_summary) |>
  dplyr::mutate(status = dplyr::if_else(
    .data$record_type == "panel_count_if_both_scores_required",
    "approved", "not-adopted-zero-alternative"
  ), .before = 1L)
stopifnot(identical(source_hash, tools::md5sum(source_path)))
directory <- project_path("audit", "corrections", poll_id)
fs::dir_create(directory)
readr::write_csv(values, file.path(directory, "proposed_values.csv"))
readr::write_csv(summary, file.path(directory, "summary.csv"))

missing_values <- purrr::map(seq_len(2L), function(wave_index) {
  items <- list(missing_baseline, missing_follow_up)[[wave_index]]
  original <- values[values$wave == c("t0", "t3")[wave_index], ]
  dplyr::transmute(
    original, status = "approved-missing", .data$poll_id, .data$source_dataset,
    .data$respondent_id, .data$source_hhid, .data$arm, .data$wave,
    .data$source_field, .data$raw_first_component,
    first_component_excluded = .data$raw_first_component %in% -99,
    current_available_components = .data$n_observed_components,
    missing_available_components = rowSums(!is.na(items)),
    current_value = .data$current_value,
    zero_refitted_value = .data$proposed_value,
    zero_fixed_value = .data$fixed_calibration_value,
    missing_refitted_value = score_items(items, missing_calibration),
    missing_fixed_value = score_items(items, old_calibration)
  )
}) |>
  purrr::list_rbind()
stopifnot(
  identical(
    is.na(missing_values$current_value),
    is.na(missing_values$missing_refitted_value)
  ),
  sum(abs(missing_values$missing_fixed_value -
            missing_values$current_value) > 1e-10, na.rm = TRUE) == 198L,
  sum(abs(missing_values$missing_refitted_value -
            missing_values$current_value) > 1e-10, na.rm = TRUE) == 3859L
)
alternative_scores <- missing_values |>
  dplyr::mutate(original_score = .data$current_value) |>
  tidyr::pivot_longer(
    cols = dplyr::ends_with("_value"), names_to = "scoring",
    values_to = "value"
  )
wave_summary <- alternative_scores |>
  dplyr::summarise(
    respondents = dplyr::n(), observed = sum(!is.na(.data$value)),
    lost_scores = sum(!is.na(.data$original_score) & is.na(.data$value)),
    changed_values = sum(
      abs(.data$value - .data$original_score) > 1e-10, na.rm = TRUE
    ),
    affected_components = sum(.data$first_component_excluded),
    affected_with_no_components = sum(
      .data$first_component_excluded & .data$missing_available_components == 0
    ),
    mean_value = mean(.data$value, na.rm = TRUE),
    .by = c("scoring", "wave")
  ) |>
  dplyr::mutate(record_type = "score_mean", arm = "all")
alternative_pairs <- alternative_scores |>
  dplyr::select("respondent_id", "arm", "wave", "scoring", "value") |>
  tidyr::pivot_wider(names_from = "wave", values_from = "value") |>
  dplyr::mutate(current_pair = paired_flag[
    match(.data$respondent_id, participants$respondent_id)
  ])
alternative_gains <- alternative_pairs |>
  dplyr::summarise(
    respondents = dplyr::n(),
    observed = sum(!is.na(.data$t0) & !is.na(.data$t3)),
    lost_pairs = sum(.data$current_pair & (is.na(.data$t0) | is.na(.data$t3))),
    mean_value = mean(.data$t3 - .data$t0, na.rm = TRUE),
    .by = c("scoring", "arm")
  ) |>
  dplyr::mutate(record_type = "paired_mean_gain", wave = "t0_to_t3")
control_gains <- alternative_gains |>
  dplyr::filter(.data$arm == "control") |>
  dplyr::select("scoring", control_gain = "mean_value")
gain_differences <- alternative_gains |>
  dplyr::filter(.data$arm != "control") |>
  dplyr::left_join(
    control_gains, by = "scoring", relationship = "many-to-one"
  ) |>
  dplyr::mutate(
    mean_value = .data$mean_value - .data$control_gain,
    record_type = "paired_gain_minus_control"
  ) |>
  dplyr::select(-"control_gain")
missing_summary <- dplyr::bind_rows(
  wave_summary, alternative_gains, gain_differences
) |>
  dplyr::mutate(status = dplyr::case_when(
    .data$scoring == "missing_refitted_value" ~ "approved-missing",
    .data$scoring == "current_value" ~ "source-comparison",
    startsWith(.data$scoring, "zero_") ~ "not-adopted-zero-alternative",
    TRUE ~ "not-adopted-fixed-calibration"
  ), .before = 1L)
component_counts <- missing_values |>
  dplyr::filter(.data$first_component_excluded) |>
  dplyr::count(
    .data$wave, .data$current_available_components,
    .data$missing_available_components, name = "respondents"
  )
calibration_names <- c("current", "zero", "missing")
calibration_values <- purrr::map(calibration_names, function(key) {
  calibration <- list(
    current = old_calibration, zero = proposed_calibration,
    missing = missing_calibration
  )[[key]]
  tibble::tibble(
    status = switch(key,
      current = "source-comparison", zero = "not-adopted-zero-alternative",
      missing = "approved-missing"
    ), scoring = key,
    component = c(colnames(baseline), "composite"),
    baseline_control_mean = c(
      calibration$item_mean, calibration$composite_mean
    ),
    baseline_control_sd = c(calibration$item_sd, calibration$composite_sd)
  )
}) |>
  purrr::list_rbind()
stopifnot(identical(source_hash, tools::md5sum(source_path)))
readr::write_csv(missing_values, file.path(directory, "missing_values.csv"))
readr::write_csv(missing_summary, file.path(directory, "missing_summary.csv"))
readr::write_csv(
  component_counts, file.path(directory, "missing_components.csv")
)
readr::write_csv(calibration_values, file.path(directory, "calibrations.csv"))
print(gain_summary)
print(
  gain_differences |>
    dplyr::filter(.data$arm == "deliberation")
)
message("TZ-03 approved missing recode and TZ-04 panel flag verified; ",
        "zero alternatives retained for comparison only.")
