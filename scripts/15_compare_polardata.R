source("R/paths.R")
source("R/metadata.R")
source("R/poll_sources.R")
source("R/poll_adapters.R")
source("R/knowledge.R")
source("R/respondents.R")
source("R/respondent_parity.R")
source("R/polardata.R")
source("R/polardata_rebuild.R")
source("R/polardata_numerics.R")
source("R/polardata_parity.R")

rebuilt <- arrow::read_parquet(
  project_path("output", "polardata", "polardata.parquet")
)
benchmark <- readr::read_tsv(
  project_path("evidence", "benchmarks", "polardata.tab"),
  show_col_types = FALSE
)
reviewed <- read_metadata("polardata_reviewed_covariances")
numerical <- audit_historical_covariances(benchmark, reviewed)
readr::write_csv(numerical, project_path("audit", "polardata_covariances.csv"))
parity <- compare_historical_polardata(rebuilt, benchmark, numerical)
readr::write_csv(parity, project_path("audit", "polardata_parity.csv"))
reviewed_differences <- numerical |>
  dplyr::filter(
    .data$reference_kind == "approved", .data$numerical_exception,
    .data$absolute_delta > 1e-10
  ) |>
  dplyr::select(
    "poll_id", "pollgroup", "reference_kind",
    "attitudes_sha256", "covariance_rank",
    "source_genvar", "benchmark_genvar", "perturbation_upper"
  )
if (nrow(reviewed_differences)) {
  cat("Verified numerical differences against approved values:\n")
  cat(readr::format_csv(reviewed_differences))
}
if (any(parity$unexplained_differences != 0L)) {
  failures <- parity |>
    dplyr::filter(.data$unexplained_differences != 0L)
  print(failures, n = Inf, width = Inf)
  contracts <- read_metadata("respondent_sources")
  cells <- purrr::map(seq_len(nrow(failures)), function(index) {
    failure <- failures[index, ]
    poll_id <- failure$poll_id
    field <- failure$legacy_field
    dpnum <- contracts$dpnum[match(poll_id, contracts$poll_id)]
    actual <- historical_reference_people(
      rebuilt[rebuilt$dpnum == dpnum, ], poll_id
    )
    expected <- historical_reference_people(
      benchmark[benchmark$dpnum == dpnum, ], poll_id
    )
    actual <- actual[actual$caseid %in% expected$caseid, ]
    expected <- expected[match(actual$caseid, expected$caseid), ]
    approved <- approved_reference_values(
      poll_id, field, actual$caseid, expected[[field]], failure$tolerance
    )
    different <- is.na(actual[[field]]) != is.na(approved)
    observed <- !is.na(actual[[field]]) & !is.na(approved)
    different[observed] <- if (is.numeric(approved)) {
      abs(actual[[field]][observed] - approved[observed]) > failure$tolerance
    } else {
      actual[[field]][observed] != approved[observed]
    }
    different[is.na(different)] <- FALSE
    historical_values <- as.character(expected[[field]])
    rebuilt_values <- as.character(actual[[field]])
    tibble::tibble(
      poll_id, field, caseid = actual$caseid, pollgroup = actual$pollgroup,
      historical = historical_values,
      approved = as.character(approved),
      rebuilt = rebuilt_values
    )[different, ]
  }) |>
    purrr::list_rbind()
  cat(readr::format_csv(cells))
  stop("Aggregate reconstruction differs; see audit/polardata_parity.csv")
}
print(parity |>
  dplyr::filter(
    .data$value_differences > 0 | .data$missingness_differences > 0
  ))

indices <- arrow::read_parquet(project_path(
  "output", "polardata", "attitude-indices.parquet"
))
expected_indices <- readr::read_tsv(project_path(
  "evidence", "benchmarks", "attitude-indices.tab"
), show_col_types = FALSE)
label_fixes <- read_metadata("attitude_index_label_fixes")
rows <- match(label_fixes$t1var, expected_indices$t1var)
stopifnot(
  !anyNA(rows),
  identical(expected_indices$dpnum[rows], label_fixes$dpnum),
  identical(expected_indices$att_index[rows], label_fixes$archived_label)
)
expected_indices$att_index[rows] <- label_fixes$reviewed_label
wave_fixes <- read_metadata("attitude_index_wave_fixes")
rows <- match(wave_fixes$t1var, expected_indices$t1var)
stopifnot(
  !anyNA(rows), !anyDuplicated(wave_fixes$t1var),
  identical(expected_indices$dpnum[rows], wave_fixes$dpnum),
  identical(expected_indices$t2_t3var[rows], wave_fixes$archived_later_column)
)
expected_indices$t2_t3var[rows] <- wave_fixes$reviewed_later_column
stopifnot(
  identical(names(indices), names(expected_indices)),
  isTRUE(all.equal(indices, expected_indices, check.attributes = FALSE))
)
