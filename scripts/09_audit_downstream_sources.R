source("R/paths.R")
source("R/metadata.R")
source("R/provenance.R")

args <- commandArgs(trailingOnly = TRUE)
root <- if (length(args)) args[[1]] else dirname(project_path())
repositories <- c(
  "dp-distortions", "dp-learning", "dp-nireland",
  "guessing-and-forgetting", "dp-knowledge-linkage",
  "dp-steadier-not-closer", "dp-deliberately"
)
directories <- file.path(root, repositories)
stopifnot(all(dir.exists(directories)))
files <- purrr::map(directories, inventory_repository_files) |>
  purrr::list_rbind()
published <- read_metadata("source_files") |>
  dplyr::select("path", "sha256")
artifacts <- read_metadata("artifacts") |>
  dplyr::filter(.data$publication_status == "published") |>
  dplyr::transmute(path = .data$location, sha256 = .data$sha256)
published <- dplyr::bind_rows(published, artifacts) |> dplyr::distinct()
archived <- readr::read_csv(
  project_path("audit", "cdd_archive_files.csv"),
  col_types = readr::cols(.default = readr::col_character())
) |>
  dplyr::select("path", "sha256")
reviewed <- dplyr::bind_rows(
  read_metadata("survey_sources"), read_metadata("survey_components")
) |>
  dplyr::transmute(path = .data$public_path, sha256 = .data$source_sha256)
matched <- match_source_checksums(files, published, archived, reviewed)
readr::write_csv(
  matched, project_path("audit", "downstream_source_inventory.csv"),
  na = ""
)
summary <- matched |>
  dplyr::count(.data$repository, .data$byte_match, name = "files")
readr::write_csv(
  summary, project_path("audit", "downstream_source_summary.csv")
)
repositories <- tibble::tibble(repository = repositories) |>
  dplyr::left_join(
    dplyr::count(files, .data$repository, name = "tracked_candidates"),
    by = "repository", relationship = "one-to-one"
  ) |>
  dplyr::mutate(tracked_candidates = tidyr::replace_na(
    .data$tracked_candidates, 0L
  )) |>
  dplyr::mutate(repository_commit = purrr::map_chr(
    file.path(root, .data$repository), function(directory) {
      system2("git", c("-C", shQuote(directory), "rev-parse", "HEAD"),
        stdout = TRUE
      )
    }
  ))
readr::write_csv(
  repositories, project_path("audit", "downstream_repository_coverage.csv")
)
print(summary, n = Inf)

batteries <- read_metadata("knowledge_batteries") |>
  dplyr::transmute(
    repository = "guessing-and-forgetting",
    path = paste0("data/", basename(.data$original_archive_path)),
    upstream_path = paste0("data/", .data$poll_id, "/knowledge-battery.csv")
  )
transport <- dplyr::bind_rows(
  batteries,
  tibble::tibble(
    repository = "dp-nireland", path = "data/groups.csv",
    upstream_path = "data/northern-ireland-2007/groups.csv"
  )
) |>
  dplyr::mutate(
    same_text_lines = purrr::pmap_lgl(
      list(.data$repository, .data$path, .data$upstream_path),
      function(repository, path, upstream_path) {
        identical(
          readLines(file.path(root, repository, path), warn = FALSE),
          readLines(project_path(upstream_path), warn = FALSE)
        )
      }
    )
  )
readr::write_csv(
  transport, project_path("audit", "downstream_text_transport.csv")
)

jsonlite::write_json(
  list(
    scope = "Tracked files under data/ and inst/extdata/; README excluded",
    unit = "One working-tree file in one downstream repository",
    limits = paste(
      "Not a dependency audit; generated files may occur in these directories.",
      "No exact match does not establish new content or permission to publish.",
      "Text comparison ignores line terminators but does not parse data.",
      "Reviewed-source matches identify a source of a published extract;",
      "they do not establish equivalence between raw and redacted files.",
      "No respondent scores or downstream inputs are changed."
    ),
    checked_at_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    upstream_catalog_sha256 = digest::digest(
      file = project_path("metadata", "source_files.csv"), algo = "sha256"
    ),
    archive_inventory_sha256 = digest::digest(
      file = project_path("audit", "cdd_archive_files.csv"), algo = "sha256"
    ),
    inventory_sha256 = digest::digest(
      file = project_path("audit", "downstream_source_inventory.csv"),
      algo = "sha256"
    )
  ),
  project_path("audit", "downstream_source_audit.json"),
  auto_unbox = TRUE, pretty = TRUE
)
