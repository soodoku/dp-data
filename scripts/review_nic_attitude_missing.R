# NIC-12: compare midpoint imputation with the approved missing-answer rule.
for (module in c(
  "paths", "sources", "metadata", "poll_sources", "poll_adapters", "knowledge",
  "exports", "respondents", "polardata", "polardata_rebuild"
)) {
  source(file.path("R", paste0(module, ".R")))
}

survey <- read_poll_survey("nic-1996")
stopifnot(nrow(survey) == 911L, !anyDuplicated(survey$source_row))
selected <- which(round(as.numeric(survey$PART)) == 1)
stopifnot(length(selected) == 466L)
case_ids <- round(as.numeric(survey$CASEID[selected]))
group <- round(as.numeric(survey$RGROUP2))
group[!is.na(group) & group <= 0] <- NA_real_
stems <- c(
  "SPENVIR", "SPMEDIC", "SPLAW", "SPDRUG", "SPEDUC", "SPDEF",
  "SPFAID", "SPWELF", "SPSS"
)
available_mean <- function(values) {
  result <- rowMeans(as.matrix(values), na.rm = TRUE)
  result[is.nan(result)] <- NA_real_
  result
}
raw_attitudes <- function(wave, impute_midpoint) {
  values <- vapply(stems, function(stem) {
    raw <- as.numeric(survey[[paste0(stem, wave)]])
    stopifnot(all(is.na(raw) | abs(raw - round(raw)) < 1e-8))
    code <- round(raw)
    allowed <- if (stem == "SPDRUG" && wave == 2L) c(1:3, 8, 9)
    else c(1:3, 8)
    stopifnot(all(is.na(code) | code %in% allowed))
    absent <- is.na(code) | code %in% c(8, 9)
    code[absent] <- if (impute_midpoint) 2 else NA_real_
    (code - 1) / 2
  }, numeric(nrow(survey)))
  values
}
review_values <- function(impute_midpoint) {
  waves <- lapply(1:3, raw_attitudes, impute_midpoint = impute_midpoint)
  baseline <- waves[[1]][selected, , drop = FALSE]
  exit <- waves[[2]][selected, , drop = FALSE]
  follow_up <- waves[[3]][selected, , drop = FALSE]
  colnames(baseline) <- paste0("nic1.t1att", 1:9)
  colnames(follow_up) <- paste0("nic1.t2att", 1:9)
  result <- tibble::as_tibble(cbind(baseline, follow_up))
  result$attextreme <- available_mean(abs(baseline - .5))
  result$attextreme2 <- available_mean(abs(exit - .5))
  result$meanxtreme <- result$avgsd <- result$genvar <- result$avgsd2 <-
    NA_real_
  for (rows in split(seq_along(selected), group[selected])) {
    full_rows <- which(group == group[selected[rows[1]]])
    attitudes <- waves[[1]][full_rows, , drop = FALSE]
    covariance <- stats::cov(attitudes, use = "pairwise.complete.obs")
    result$meanxtreme[rows] <- mean(result$attextreme[rows], na.rm = TRUE)
    result$avgsd[rows] <- mean(apply(
      attitudes, 2L, stats::sd,
      na.rm = TRUE
    ))
    result$genvar[rows] <- if (anyNA(covariance)) {
      NA_real_
    } else {
      abs(det(covariance))^(1 / (2 * ncol(attitudes)))
    }
    result$avgsd2[rows] <- mean(apply(
      exit[rows, , drop = FALSE], 2L, stats::sd,
      na.rm = TRUE
    ))
  }
  result
}
previous <- review_values(TRUE)
approved <- review_values(FALSE)
rebuilt <- build_historical_poll("nic-1996")
stopifnot(identical(as.integer(rebuilt$source_row), as.integer(selected)))
original <- readr::read_tsv(
  project_path("evidence", "benchmarks", "polardata.tab"),
  show_col_types = FALSE
) |>
  dplyr::filter(.data$pollid == 1001)
stopifnot(
  nrow(original) == 466L, !anyDuplicated(case_ids),
  !anyDuplicated(original$caseid), sum(is.na(case_ids)) == 1L,
  sum(is.na(original$caseid)) == 1L,
  setequal(case_ids, original$caseid)
)
original_rows <- match(case_ids, original$caseid)
# NIC-12 records the missing-answer step; the later shared covariance rule
# additionally withholds generalized variance for invalid covariance matrices.
final_genvar <- approved$genvar
baseline <- raw_attitudes(1L, FALSE)
for (rows in split(seq_along(selected), group[selected])) {
  full_rows <- which(group == group[selected[rows[1]]])
  covariance <- stats::cov(
    baseline[full_rows, ], use = "pairwise.complete.obs"
  )
  if (any(!is.finite(covariance))) {
    final_genvar[rows] <- NA_real_
  } else {
    eigenvalues <- eigen(
      covariance, symmetric = TRUE, only.values = TRUE
    )$values
    tolerance <- 64 * .Machine$double.eps * ncol(covariance) *
      max(abs(eigenvalues))
    if (any(eigenvalues < -tolerance)) final_genvar[rows] <- NA_real_
  }
}
comparison <- purrr::map(names(approved), function(field) {
  actual <- rebuilt[[field]]
  expected <- approved[[field]]
  final_expected <- if (field == "genvar") final_genvar else expected
  stopifnot(
    identical(is.na(actual), is.na(final_expected)),
    all(abs(actual - final_expected) < 1e-10, na.rm = TRUE)
  )
  tibble::tibble(
    legacy_field = field, caseid = case_ids,
    source_row = survey$source_row[selected],
    historical_value = original[[field]][original_rows],
    previous_value = previous[[field]], approved_value = expected
  )
}) |>
  purrr::list_rbind()
summary <- comparison |>
  dplyr::summarise(
    n_people = dplyr::n(),
    changed_values = sum(
      abs(.data$approved_value - .data$previous_value) > 1e-10,
      na.rm = TRUE
    ),
    newly_missing = sum(
      !is.na(.data$previous_value) & is.na(.data$approved_value)
    ),
    previous_mean = mean(.data$previous_value, na.rm = TRUE),
    approved_mean = mean(.data$approved_value, na.rm = TRUE),
    .by = "legacy_field"
  )
source_summary <- purrr::map(1:3, function(wave) {
  values <- raw_attitudes(wave, FALSE)
  purrr::map(list(
    all_source = seq_len(nrow(survey)),
    historical_participants = selected
  ), function(rows) {
    tibble::tibble(
      source_wave = wave, n_people = length(rows),
      newly_missing_indices = sum(is.na(values[rows, , drop = FALSE])),
      all_nine_missing = sum(rowSums(!is.na(values[rows, , drop = FALSE])) == 0)
    )
  }) |> purrr::list_rbind(names_to = "cohort")
}) |>
  purrr::list_rbind()
directory <- project_path("audit", "corrections", "nic-1996")
readr::write_csv(
  comparison,
  file.path(directory, "attitude_missing_approved_values.csv")
)
readr::write_csv(
  summary,
  file.path(directory, "attitude_missing_summary.csv")
)
readr::write_csv(
  source_summary,
  file.path(directory, "attitude_missing_source_summary.csv")
)
print(summary, n = Inf, width = Inf)
print(source_summary, n = Inf)
