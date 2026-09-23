source("R/paths.R")
source("R/sources.R")
source("R/metadata.R")
source("R/poll_sources.R")
source("R/polardata.R")

verify_source_files()
rebuilt <- build_health_polardata()
benchmark <- readr::read_tsv(
  project_path("evidence", "benchmarks", "polardata.tab"),
  show_col_types = FALSE
)
parity <- compare_health_polardata(rebuilt, benchmark)

path <- project_path("output", "polardata", "uk-health-1998-attitudes.parquet")
fs::dir_create(dirname(path))
arrow::write_parquet(rebuilt, path)
stopifnot(identical(rebuilt, arrow::read_parquet(path)))
readr::write_csv(parity, project_path("audit", "polardata_parity.csv"))
print(parity)
