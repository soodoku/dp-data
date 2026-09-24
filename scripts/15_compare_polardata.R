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
if (any(parity$unexplained_differences != 0L)) {
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
stopifnot(
  identical(names(indices), names(expected_indices)),
  isTRUE(all.equal(indices, expected_indices, check.attributes = FALSE))
)
