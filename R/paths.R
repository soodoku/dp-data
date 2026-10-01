project_path <- function(...) {
  file.path(rprojroot::find_root(rprojroot::has_file("DESCRIPTION")), ...)
}

load_project <- function(root = project_path(), envir = parent.frame()) {
  stopifnot(is.environment(envir), file.exists(file.path(root, "DESCRIPTION")))
  files <- list.files(
    file.path(root, "R"), pattern = "\\.R$", full.names = TRUE
  )
  priority <- ifelse(basename(files) == "paths.R", 0L,
    ifelse(grepl("_helpers\\.R$", files), 1L, 2L)
  )
  files <- files[order(priority, files)]
  purrr::walk(files, source, local = envir)
  invisible(files)
}
