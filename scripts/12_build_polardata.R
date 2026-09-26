source("R/paths.R")
source("R/sources.R")
source("R/metadata.R")
source("R/poll_sources.R")
source("R/poll_adapters.R")
source("R/knowledge.R")
source("R/exports.R")
source("R/respondents.R")
source("R/polardata.R")
source("R/polardata_rebuild.R")

contracts <- read_metadata("respondent_sources")
stopifnot(nrow(contracts) == 21L, all(contracts$status == "reviewed-source"))
contracts <- contracts[order(contracts$dpnum), ]
manifest <- source_files()
source_directories <- paste0("data/", contracts$poll_id, "/")
required <- vapply(manifest$path, function(path) {
  any(startsWith(path, source_directories)) ||
    path == paste0(
      "data/shared/codebooks/attitude_indices/", "allpollindices.csv"
    )
}, logical(1))
verify_source_files(manifest[required, ])
polls <- purrr::map(contracts$poll_id, build_historical_poll) |>
  rlang::set_names(contracts$poll_id)
rebuilt <- historical_wide_export(polls)
stopifnot(nrow(rebuilt) == 5869L, ncol(rebuilt) == 364L)
directory <- project_path("output", "polardata")
fs::dir_create(directory)
path <- file.path(directory, "polardata.parquet")
arrow::write_parquet(rebuilt, path, compression = "zstd")
stopifnot(identical(rebuilt, arrow::read_parquet(path)))
readr::write_tsv(rebuilt, file.path(directory, "polardata.tab"), na = "")
derived <- historical_derived_measures(polls)
manifest <- write_typed_export(derived, "derived_measures", directory,
                               schema_version = "2")
readr::write_csv(manifest, file.path(directory, "manifest.csv"))

health <- build_health_polardata()
path <- file.path(directory, "uk-health-1998.parquet")
arrow::write_parquet(health, path)
stopifnot(identical(health, arrow::read_parquet(path)))

indices <- readr::read_csv(project_path(
  "data", "shared", "codebooks", "attitude_indices", "allpollindices.csv"
), show_col_types = FALSE)
stopifnot(
  nrow(indices) == 129L, ncol(indices) == 7L,
  all(indices$t1var %in% names(rebuilt)),
  all(indices$t2_t3var %in% names(rebuilt))
)
arrow::write_parquet(indices, file.path(directory, "attitude-indices.parquet"))
readr::write_tsv(indices, file.path(directory, "attitude-indices.tab"), na = "")

files <- c(
  "polardata.parquet", "polardata.tab", "attitude-indices.parquet",
  "attitude-indices.tab", "uk-health-1998.parquet"
)
wide_manifest <- tibble::tibble(
  table = c("polardata", "polardata", "attitude_indices", "attitude_indices",
            "uk_health_partial"),
  path = paste0("output/polardata/", files),
  rows = c(nrow(rebuilt), nrow(rebuilt), nrow(indices), nrow(indices),
           nrow(health)),
  columns = c(ncol(rebuilt), ncol(rebuilt), ncol(indices), ncol(indices),
              ncol(health)),
  sha256 = vapply(file.path(directory, files), function(path) {
    digest::digest(file = path, algo = "sha256")
  }, character(1)),
  schema_version = "1"
)
readr::write_csv(dplyr::bind_rows(manifest, wide_manifest),
                 file.path(directory, "manifest.csv"))
