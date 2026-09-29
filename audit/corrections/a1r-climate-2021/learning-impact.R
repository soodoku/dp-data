arguments <- commandArgs(trailingOnly = TRUE)
stopifnot(length(arguments) == 3L)
data_root <- normalizePath(arguments[[1]])
learning_root <- normalizePath(arguments[[2]])
out <- normalizePath(arguments[[3]], mustWork = FALSE)
dir.create(out, recursive = TRUE, showWarnings = FALSE)
setwd(learning_root)
Sys.setenv(DP_DATA_ROOT = data_root, DP_BOOT_WORKERS = "4")
purrr::walk(list.files("R", full.names = TRUE), source)
options(dp.bootstrap.replicates = 999L)
write_result <- function(data, name) readr::write_csv( # nolint: brace_linter.
  data, file.path(out, name)
)
source_people <- read_analysis_participants()
source_phase_people <- read_phase_participants()
raw <- readr::read_tsv(
  file.path(dp_data_root(), "data/a1r-climate-2021/participants.tab"),
  show_col_types = FALSE
)
mapping <- raw |>
  dplyr::filter(P_DELEGATE == 1) |>
  dplyr::transmute(
    respondent_id = as.character(CaseId), room = as.character(ROOM),
    schedule = as.character(T2P_OPTION),
    candidate = paste(ROOM, T2P_OPTION, sep = "_")
  )
stopifnot(
  nrow(mapping) == 962L, !anyNA(mapping), !anyDuplicated(mapping$respondent_id),
  dplyr::n_distinct(mapping$room) == 58L,
  dplyr::n_distinct(mapping$candidate) == 105L
)
replace_group <- function(x, target = mapping$candidate) {
  rows <- x$poll_id == "a1r-climate-2021" &
    x$respondent_id %in% mapping$respondent_id
  positions <- match(x$respondent_id[rows], mapping$respondent_id)
  stopifnot(
    sum(rows) == 962L,
    (identical(x$small_group_id[rows], mapping$room[positions]) ||
       identical(x$small_group_id[rows], mapping$candidate[positions]))
  )
  x$small_group_id[rows] <- target[positions]
  x
}
people <- replace_group(source_people, mapping$room)
phase_people <- replace_group(source_phase_people, mapping$room)
candidate_people <- replace_group(people)
candidate_phase_people <- replace_group(phase_people)
before_attendees <- attendee_panel(
  participants = people, phase_participants = phase_people
)
after_attendees <- attendee_panel(
  participants = candidate_people, phase_participants = candidate_phase_people
)
stopifnot(identical(
  before_attendees[setdiff(names(before_attendees), "group")],
  after_attendees[setdiff(names(after_attendees), "group")]
))
before <- core_group_frame(before_attendees)
after <- core_group_frame(after_attendees)
stopifnot(identical(
  before[c("poll_id", "respondent_id", "k1", "k2")],
  after[c("poll_id", "respondent_id", "k1", "k2")]
))
same <- function(x, y) (is.na(x) & is.na(y)) | (!is.na(x) & !is.na(y) & x == y)
changes <- dplyr::bind_rows(lapply(
  c("group_size", "group_k1", "p_female"), function(field) {
    rows <- !same(before[[field]], after[[field]])
    stopifnot(all(before$poll_id[rows] == "a1r-climate-2021"))
    tibble::tibble(
      field, n_changed = sum(rows),
      largest_absolute_change = max(
        abs(after[[field]] - before[[field]]), na.rm = TRUE
      )
    )
  }
))
write_result(changes, "learning_covariate_changes.csv")
models <- function(frame) {
  attitude <- add_attitude_measures(frame)
  reading <- dplyr::filter(frame, any(!is.na(read_briefing)), .by = poll_id)
  specs <- list(
    core = list(frame, core_formula),
    demographic = list(frame, demographic_formula),
    core_demographic_sample = list(
      frame[model_complete_cases(frame, demographic_formula), ], core_formula
    ),
    briefing = list(reading, expanded_briefing_formula),
    attitudes = list(attitude, attitude_formula),
    attitude_sd = list(attitude, attitude_sd_formula),
    demographic_attitude_sample = list(
      attitude[model_complete_cases(attitude, attitude_formula), ],
      demographic_formula
    ),
    items = list(
      add_item_peer_measure(frame, read_analysis_responses()), items_formula
    )
  )
  purrr::imap(specs, function(spec, name) {
    message("Point fit: ", name)
    fit <- fit_knowledge(spec[[1]], spec[[2]], check = FALSE)
    result <- tidy_fit(fit, name)
    result$convergence_message <- paste(
      fit@optinfo$conv$lme4$messages, collapse = "; "
    )
    result
  }) |> purrr::list_rbind()
}
old_models <- models(before)
new_models <- models(after)
model_comparison <- dplyr::inner_join(
  old_models, new_models, by = c("model", "term"),
  suffix = c("_current", "_candidate"), relationship = "one-to-one"
) |>
  dplyr::mutate(difference = estimate_candidate - estimate_current)
stopifnot(all(model_comparison$n_current == model_comparison$n_candidate))
write_result(model_comparison, "learning_model_points.csv")
climate_before <- dplyr::filter(before, poll_id == "a1r-climate-2021")
climate_after <- dplyr::filter(after, poll_id == "a1r-climate-2021")
gain_statistic <- function(x) c( # nolint: brace_linter.
  raw_gain = mean(x$k2 - x$k1),
  relative_gain = mean(x$k2 - x$k1) / mean(x$k1)
)
gain <- dplyr::bind_rows(
  dplyr::mutate(
    bootstrap_rows(bootstrap_stat(
      climate_before, gain_statistic, resample_polls = FALSE
    )), version = "current"
  ),
  dplyr::mutate(
    bootstrap_rows(bootstrap_stat(
      climate_after, gain_statistic, resample_polls = FALSE
    )), version = "candidate"
  )
)
write_result(gain, "climate_gain_uncertainty.csv")
peer <- dplyr::bind_rows(lapply(c("k1", "female"), function(variable) {
  dplyr::bind_rows(
    dplyr::mutate(
      peer_effect(climate_before, variable),
      version = "current", peer = variable
    ),
    dplyr::mutate(
      peer_effect(climate_after, variable),
      version = "candidate", peer = variable
    )
  )
})) |> dplyr::select(-draws)
write_result(peer, "climate_peer_associations.csv")
control_before <- read_climate(control_panel(participants = people))
control_after <- read_climate(control_panel(participants = candidate_people))
controls <- dplyr::bind_rows(lapply(
  c("unweighted", "weighted", "one_year"), function(specification) {
    x <- control_before
    y <- control_after
    if (specification == "one_year") {
      x$k2 <- x$k3
      y$k2 <- y$k3
    }
    weights <- if (specification == "weighted") "weight" else NULL
    dplyr::bind_rows(
      dplyr::mutate(
        effect(x, "treated", 1, 0, weights), version = "current", specification
      ),
      dplyr::mutate(
        effect(y, "treated", 1, 0, weights),
        version = "candidate", specification
      )
    )
  }
))
write_result(controls, "climate_control_uncertainty.csv")
retention <- dplyr::bind_rows(
  dplyr::mutate(
    retention_estimates(dplyr::filter(
      retention_frame(participants = phase_people),
      poll_id == "a1r-climate-2021"
    )), version = "current"
  ),
  dplyr::mutate(
    retention_estimates(dplyr::filter(
      retention_frame(participants = candidate_phase_people),
      poll_id == "a1r-climate-2021"
    )), version = "candidate"
  )
)
write_result(retention, "climate_retention_uncertainty.csv")
write_result(mapping, "independent_group_mapping.csv")
jsonlite::write_json(
  list(
    data_commit = system2(
      "git", c("-C", shQuote(data_root), "rev-parse", "HEAD"), stdout = TRUE
    ),
    learning_commit = system2(
      "git", c("-C", shQuote(learning_root), "rev-parse", "HEAD"), stdout = TRUE
    ),
    sources = upstream_source_manifest(), bootstrap_replicates = 999L,
    bootstrap_seed = 20260927L, retention_seed = 20260928L,
    adopted = FALSE, samples_unchanged = TRUE,
    limitation = "Mixed-model coefficients are point estimates only; full regression bootstrap and paper not rebuilt." # nolint: line_length_linter.
  ),
  file.path(out, "provenance.json"),
  pretty = TRUE, auto_unbox = TRUE
)
message("Counterfactual complete. Production files unchanged.")
