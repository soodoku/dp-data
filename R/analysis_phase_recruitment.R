analysis_phase_recruitment <- function(participants, sources) {
  raw <- haven::read_sav(project_path(
    "data", "marousi-2006", "survey.sav"
  ))
  stopifnot(
    nrow(raw) == 1275L, !anyNA(raw$P_Q1_0),
    !anyDuplicated(raw$P_Q1_0)
  )
  observed <- function(prefix, excluded) {
    columns <- setdiff(grep(prefix, names(raw), value = TRUE), excluded)
    stopifnot(length(columns) > 7L)
    rowSums(!is.na(raw[columns])) > 0L
  }
  telephone_observed <- observed("^P_", c("P_Q1_0", "P_DAY"))
  arrival_observed <- observed("^AR_", "AR_CODE")
  departure_observed <- observed("^F_", "F_CODE")
  event_observed <- arrival_observed | departure_observed
  stopifnot(!any(!event_observed & !is.na(raw$GROUP)))
  columns <- setdiff(names(participants), c("score_wave1", "score_wave2"))
  existing <- participants |>
    dplyr::select(dplyr::all_of(columns)) |>
    dplyr::filter(poll_id == "marousi-2006")
  bridge <- sources$marousi
  stopifnot(
    nrow(existing) == 146L, nrow(bridge) == 146L,
    all(existing$source_dataset == "score_only"),
    !anyNA(existing$source_row), !anyDuplicated(existing$source_row),
    setequal(existing$source_row, bridge$original_source_row)
  )
  bridge_index <- match(existing$source_row, bridge$original_source_row)
  stopifnot(
    all(existing$respondent_id == as.character(bridge$caseid[bridge_index])),
    all(existing$small_group_id ==
          as.character(bridge$pollgroup[bridge_index])),
    all(existing$panel == (arrival_observed & departure_observed)[
      existing$source_row
    ])
  )
  source_rows <- seq_len(nrow(raw))
  respondent_id <- paste0("source-", as.character(raw$P_Q1_0))
  respondent_id[existing$source_row] <- existing$respondent_id
  supplementary <- tibble::tibble(
    poll_id = "marousi-2006", source_dataset = "score_only", respondent_id,
    historical_respondent_id = NA_character_, source_row = source_rows,
    identity_basis = "source-id",
    arm = dplyr::if_else(event_observed, "participant", "attendance_unknown"),
    assignment = NA_character_,
    attended = dplyr::if_else(event_observed, TRUE, NA),
    panel = arrival_observed & departure_observed,
    small_group_id = NA_character_, cluster_id = NA_character_,
    country = "Greece", weight = NA_real_, ba = NA_real_, female = NA_real_,
    age = NA_real_, education = NA_real_, minority = NA_real_,
    extremity = NA_real_, read_briefing = NA_real_
  ) |>
    dplyr::filter(!source_row %in% existing$source_row)
  marousi <- dplyr::bind_rows(existing, supplementary) |>
    dplyr::arrange(source_row) |>
    dplyr::select(dplyr::all_of(columns))
  full_participants <- participants |>
    dplyr::select(dplyr::all_of(columns)) |>
    dplyr::filter(poll_id != "marousi-2006") |>
    dplyr::bind_rows(marousi)
  flag_columns <- list(
    c(
      "KQ1_T1", "KQ2POPT1", "KQ3STOR1", "KQ4WAST1",
      "KQ5PERT1", "KQ6TRAN1", "KQ7METR1"
    ),
    c(
      "KQ1_T2", "KQ2POPT2", "KQ3STORE", "KQ4WASTE",
      "KQ5PERT2", "KQ6TRANT", "KQ7METRO"
    ),
    c(
      "KQ1_T3", "KQ2POPT3", "KQ3STOR0", "KQ4WAST0",
      "KQ5PERT3", "KQ6TRAN0", "KQ7METR0"
    )
  )
  quiz_columns <- list(
    c("P_Q13", paste0("P_Q", 21:25), "P_Q27"),
    paste0("AR_Q", 14:20), paste0("F_Q", 14:20)
  )
  presence <- list(telephone_observed, arrival_observed, departure_observed)
  wave_roles <- c("pre_arrival", "arrival", "post_deliberation")
  scores <- purrr::map(seq_len(3L), function(i) {
    flags <- raw[flag_columns[[i]]] |>
      lapply(as.numeric) |>
      as.data.frame() |>
      as.matrix()
    stopifnot(all(is.na(flags) | flags %in% 0:1))
    correct <- as.integer(rowSums(flags == 1, na.rm = TRUE))
    score <- correct / 7
    stopifnot(all(abs(score - as.numeric(raw[[paste0("KNOWT", i, "_2")]])) <
                    1e-7))
    if (i == 1L) {
      score[bridge$original_source_row] <- bridge$t1know
      stopifnot(all(round(bridge$t1know * 7) ==
                      correct[bridge$original_source_row]))
    }
    tibble::tibble(
      poll_id = "marousi-2006", source_dataset = "score_only", respondent_id,
      wave = paste0("t", i - 1L), n_items = 7L,
      n_observed = as.integer(rowSums(!is.na(raw[quiz_columns[[i]]]))),
      n_correct = dplyr::if_else(presence[[i]], correct, NA_integer_),
      score = dplyr::if_else(presence[[i]], score, NA_real_),
      scale = "proportion_correct", wave_observed = presence[[i]],
      battery_id = "marousi-2006:score_only:knowledge",
      original_score_wave = paste0("t", i - 1L),
      wave_role = wave_roles[i],
      timing_evidence = paste0(
        "data/marousi-2006/survey.sav original T", i,
        " -> canonical t", i - 1L, "; docs/poll-issues.md MAR-02"
      )
    )
  }) |>
    purrr::list_rbind()
  keys <- c("poll_id", "source_dataset", "respondent_id")
  stopifnot(
    nrow(marousi) == nrow(raw),
    nrow(full_participants) == nrow(participants) + 1129L,
    !anyDuplicated(full_participants[keys]),
    !anyDuplicated(scores[c(keys, "wave")]),
    nrow(dplyr::anti_join(scores, full_participants, by = keys)) == 0L
  )
  list(participants = full_participants, scores = scores)
}
