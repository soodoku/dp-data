source("R/paths.R")
source("R/metadata.R")

artifacts <- read_metadata("artifacts") |>
  dplyr::mutate(directory = dplyr::coalesce(.data$poll_id, "shared"))

artifacts |>
  dplyr::group_by(.data$directory) |>
  tidyr::nest() |>
  purrr::pwalk(function(directory, data) {
    directory <- project_path("data", directory)
    fs::dir_create(directory)
    readr::write_csv(
      dplyr::select(data, "poll_id", dplyr::everything()),
      file.path(directory, "manifest.csv"),
      na = ""
    )
  })
