build_attitude_catalog <- function(rebuilt) {
  indices <- readr::read_csv(project_path(
    "data", "shared", "codebooks", "attitude_indices", "allpollindices.csv"
  ), show_col_types = FALSE)
  stopifnot(nrow(indices) == 129L, ncol(indices) == 7L)
  label_fixes <- read_metadata("attitude_index_label_fixes")
  rows <- match(label_fixes$t1var, indices$t1var)
  stopifnot(
    ncol(label_fixes) == 5L,
    !anyDuplicated(label_fixes$t1var), !anyNA(rows),
    all(!is.na(label_fixes$issue_id) & nzchar(label_fixes$issue_id)),
    identical(indices$dpnum[rows], label_fixes$dpnum),
    identical(indices$att_index[rows], label_fixes$archived_label),
    all(label_fixes$reviewed_label != label_fixes$archived_label)
  )
  indices$att_index[rows] <- label_fixes$reviewed_label
  fixes <- read_metadata("attitude_index_wave_fixes")
  rows <- match(fixes$t1var, indices$t1var)
  stopifnot(
    !anyNA(rows), !anyDuplicated(fixes$t1var),
    identical(indices$dpnum[rows], fixes$dpnum),
    identical(indices$t2_t3var[rows], fixes$archived_later_column),
    all(fixes$reviewed_later_column != fixes$archived_later_column)
  )
  indices$t2_t3var[rows] <- fixes$reviewed_later_column
  stopifnot(
    all(indices$t1var %in% names(rebuilt)),
    all(indices$t2_t3var %in% names(rebuilt))
  )
  indices
}

reviewed_attitude_contrasts <- function(indices) {
  fixes <- read_metadata("attitude_index_wave_fixes")
  waves <- read_metadata("analysis_survey_waves")
  stopifnot(!anyDuplicated(waves[c("poll_id", "wave_instance_id")]))
  rows <- match(fixes$t1var, indices$t1var)
  stopifnot(
    !anyNA(rows),
    identical(indices$t2_t3var[rows], fixes$reviewed_later_column)
  )
  contrasts <- purrr::map(c(TRUE, FALSE), function(is_primary) {
    fixes |>
      dplyr::transmute(
        poll_id, attitude_id = paste0("att_", t1var),
        contrast_id = if (is_primary) "initial_to_exit" else "arrival_to_exit",
        primary = is_primary, source_dataset = "historical",
        earlier_column = if (is_primary) t1var else archived_later_column,
        later_column = reviewed_later_column,
        earlier_wave_instance_id = if (is_primary) {
          initial_wave_instance_id
        } else {
          arrival_wave_instance_id
        },
        later_wave_instance_id, evidence
      )
  }) |>
    purrr::list_rbind()
  for (side in c("earlier", "later")) {
    identity <- paste(contrasts$poll_id, contrasts[[paste0(
      side, "_wave_instance_id"
    )]])
    position <- match(identity, paste(waves$poll_id, waves$wave_instance_id))
    stopifnot(!anyNA(position))
    contrasts[[paste0(side, "_wave")]] <- waves$wave[position]
    contrasts[[paste0(side, "_phase")]] <- waves$wave_role[position]
  }
  stopifnot(!anyNA(contrasts), !anyDuplicated(contrasts[c(
    "poll_id", "attitude_id", "contrast_id"
  )]))
  contrasts
}
