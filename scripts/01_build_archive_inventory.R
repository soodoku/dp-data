source("R/paths.R")

vault <- project_path("vault", "cdd")
if (!fs::dir_exists(vault)) {
  stop(
    "The local CDD vault is absent; extract the archive bundles into vault/cdd."
  )
}

paths <- fs::dir_ls(
  vault,
  all = TRUE,
  recurse = TRUE,
  type = "file",
  fail = TRUE
)
relative <- fs::path_rel(paths, start = vault)
hashes <- purrr::map_chr(
  paths,
  digest::digest,
  file = TRUE,
  algo = "sha256",
  serialize = FALSE
)

inventory <- tibble::tibble(
  path = relative,
  bytes = as.numeric(fs::file_size(paths)),
  sha256 = hashes,
  extension = tolower(fs::path_ext(paths))
) |>
  dplyr::add_count(.data$sha256, name = "identical_copies") |>
  dplyr::mutate(
    disclosure_status = "review_required",
    publication_status = "vault_only"
  ) |>
  dplyr::arrange(.data$path)

fs::dir_create(project_path("audit"))
readr::write_csv(inventory, project_path("audit", "cdd_archive_files.csv"))
