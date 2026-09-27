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
bulgaria_fields <- paste0("bulgaria.bulgaria.t1", c(
  "q10_3", "q16", "q21", "q22", "q23", "q19"
))
bulgaria_rows <- match(bulgaria_fields, indices$t1var)
stopifnot(
  !anyNA(bulgaria_rows), all(indices$dpnum[bulgaria_rows] == 10L),
  identical(indices$att_index[bulgaria_rows], c(
    "Legalizing Drugs", "Penalties for Drug Taking", "Allowing Vigilantism",
    "Institutional Change", "Independence of Investigation Service",
    "Place of Prosecution"
  ))
)
indices$att_index[bulgaria_rows] <- c(
  "Penalties for Drug Taking", "Allowing Vigilantism",
  "Institutional Change", "Independence of Investigation Service",
  "Place of Prosecution", "Death Penalty"
)
nic2_fields <- paste0("nic2.t1", c(
  "humrh2", "multi", "inter", "global", "demo", "forai1"
))
nic2_rows <- match(nic2_fields, indices$t1var)
stopifnot(
  !anyNA(nic2_rows), all(indices$dpnum[nic2_rows] == 13L),
  identical(indices$att_index[nic2_rows], c(
    "Increasing Foreign Aid", "Internationalism", "Multilateralism",
    "Promoting Democracy", "Fighting Poverty and Suffering", "Human Rights"
  ))
)
indices$att_index[nic2_rows] <- c(
  "Human Rights", "Multilateralism", "Internationalism",
  "Fighting Poverty and Suffering", "Promoting Democracy",
  "Increasing Foreign Aid"
)
btp_national_fields <- paste0("btp03.olt1", c("usseca", "global"))
btp_national_rows <- match(btp_national_fields, indices$t1var)
stopifnot(
  !anyNA(btp_national_rows),
  all(indices$dpnum[btp_national_rows] == 14L),
  identical(indices$att_index[btp_national_rows], c(
    "Fighting Poverty and Suffering", "Fighting Terrorism"
  ))
)
indices$att_index[btp_national_rows] <- c(
  "Fighting Terrorism", "Fighting Poverty and Suffering"
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
