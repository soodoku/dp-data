match_source_checksums <- function(files, published, archived, reviewed) {
  stopifnot(!anyDuplicated(files[c("repository", "path")]))
  summarize_paths <- function(x, name) {
    x |>
      dplyr::group_by(.data$sha256) |>
      dplyr::summarise(
        paths = paste(sort(unique(.data$path)), collapse = "|"),
        .groups = "drop"
      ) |>
      dplyr::rename(!!name := "paths")
  }
  files |>
    dplyr::left_join(
      summarize_paths(published, "published_paths"),
      by = "sha256", relationship = "many-to-one", na_matches = "never"
    ) |>
    dplyr::left_join(
      summarize_paths(archived, "archive_paths"),
      by = "sha256", relationship = "many-to-one", na_matches = "never"
    ) |>
    dplyr::left_join(
      summarize_paths(reviewed, "reviewed_source_paths"),
      by = "sha256", relationship = "many-to-one", na_matches = "never"
    ) |>
    dplyr::mutate(
      byte_match = dplyr::case_when(
        !is.na(.data$published_paths) ~ "published-exact",
        !is.na(.data$archive_paths) ~ "archive-exact-only",
        TRUE ~ "no-exact-match"
      ),
      reviewed_source = !is.na(.data$reviewed_source_paths)
    )
}

inventory_repository_files <- function(directory) {
  git <- function(args) {
    result <- system2(
      "git", c("-C", shQuote(directory), args),
      stdout = TRUE
    )
    if (!is.null(attr(result, "status"))) stop("Git inventory failed.")
    result
  }
  head <- git(c("rev-parse", "HEAD"))
  paths <- git(c("ls-files", "--", "data", "inst/extdata"))
  if (any(grepl('^"', paths))) stop("Quoted Git paths require review.")
  paths <- paths[!grepl("(^|/)(README[^/]*|\\.DS_Store)$", paths)]
  if (any(!file.exists(file.path(directory, paths)))) {
    stop("Tracked input candidate missing from working tree.")
  }
  tibble::tibble(
    repository = rep(basename(directory), length(paths)),
    repository_commit = rep(head, length(paths)),
    working_tree_dirty = rep(
      length(git(c("status", "--porcelain", "--untracked-files=no"))) > 0L,
      length(paths)
    ),
    path = paths,
    bytes = as.numeric(fs::file_size(file.path(directory, paths))),
    sha256 = purrr::map_chr(
      file.path(directory, paths), digest::digest,
      file = TRUE,
      algo = "sha256", serialize = FALSE
    )
  )
}
