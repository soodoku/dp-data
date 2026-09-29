analysis_tanzania_items <- function(survey, wave) {
  stopifnot(length(wave) == 1L, wave %in% 0:1)
  fields <- paste0("H6", 1:9, wave)
  stopifnot(all(fields %in% names(survey)))
  items <- vapply(
    fields, function(field) as.numeric(survey[[field]]),
    numeric(nrow(survey))
  )
  items[items[, 1] %in% -99, 1] <- NA_real_
  if (any(!is.na(items) & !items %in% 0:1)) {
    stop("Unreviewed Tanzania knowledge component code")
  }
  items
}

analysis_tanzania_composite <- function(items, calibration) {
  standardized <- sweep(
    sweep(items, 2L, calibration$item_mean, "-"),
    2L, calibration$item_sd, "/"
  )
  composite <- rowMeans(standardized, na.rm = TRUE)
  composite[rowSums(!is.na(items)) == 0L] <- NA_real_
  composite
}

analysis_tanzania_calibration <- function(baseline, controls) {
  stopifnot(
    is.matrix(baseline), ncol(baseline) == 9L,
    is.logical(controls), length(controls) == nrow(baseline),
    !anyNA(controls), any(controls)
  )
  reference <- baseline[controls, , drop = FALSE]
  calibration <- list(
    item_mean = colMeans(reference, na.rm = TRUE),
    item_sd = apply(reference, 2L, stats::sd, na.rm = TRUE)
  )
  stopifnot(
    all(is.finite(calibration$item_mean)),
    all(is.finite(calibration$item_sd)), all(calibration$item_sd > 0)
  )
  composite <- analysis_tanzania_composite(reference, calibration)
  calibration$composite_mean <- mean(composite, na.rm = TRUE)
  calibration$composite_sd <- stats::sd(composite, na.rm = TRUE)
  stopifnot(
    is.finite(calibration$composite_mean),
    is.finite(calibration$composite_sd), calibration$composite_sd > 0
  )
  calibration
}

analysis_tanzania_knowledge <- function(survey) {
  stopifnot(
    nrow(survey) == 2002L, !anyNA(survey$HHID), !anyDuplicated(survey$HHID),
    all(haven::as_factor(survey$sample) == "Citizens")
  )
  baseline <- analysis_tanzania_items(survey, 0L)
  follow_up <- analysis_tanzania_items(survey, 1L)
  controls <- !is.na(survey$z) & survey$z == 0
  stopifnot(sum(controls) == 1000L)
  calibration <- analysis_tanzania_calibration(baseline, controls)
  score <- function(items) {
    (analysis_tanzania_composite(items, calibration) -
       calibration$composite_mean) / calibration$composite_sd
  }
  tibble::tibble(
    score_wave1 = score(baseline), score_wave2 = score(follow_up)
  )
}

analysis_tanzania_people <- function(survey) {
  stopifnot(all(is.na(survey$male) | survey$male %in% 0:1))
  scores <- analysis_tanzania_knowledge(survey)
  dplyr::bind_cols(survey, scores) |>
    dplyr::mutate(source_row = dplyr::row_number()) |>
    dplyr::transmute(
      poll_id = "tanzania-2015", source_dataset = "control",
      respondent_id = as.character(source_row), source_row,
      historical_respondent_id = NA_character_,
      identity_basis = "filtered-file-row", arm = dplyr::case_when(
        zdelib == 1 ~ "deliberation", zoinfo == 1 ~ "information",
        zspill == 1 ~ "spillover", z == 0 ~ "control", TRUE ~ "other"
      ),
      assignment = dplyr::case_when(
        zdelib == 1 ~ "deliberation", zoinfo == 1 ~ "information",
        zspill == 1 ~ "spillover", z == 0 ~ "control"
      ),
      attended = NA,
      panel = !is.na(score_wave1) & !is.na(score_wave2),
      small_group_id = NA_character_, cluster_id = as.character(VillageID),
      country = "Tanzania", weight = NA_real_, ba = NA_real_,
      female = as.numeric(male == 0), score_wave1, score_wave2
    )
}
