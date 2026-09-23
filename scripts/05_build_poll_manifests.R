source("R/paths.R")
source("R/metadata.R")

artifacts <- read_metadata("artifacts") |>
  dplyr::filter(!is.na(.data$poll_id))

artifacts |>
  dplyr::group_by(.data$poll_id) |>
  tidyr::nest() |>
  purrr::pwalk(function(poll_id, data) {
    directory <- project_path("polls", poll_id)
    fs::dir_create(directory)
    readr::write_csv(
      dplyr::mutate(data, poll_id = poll_id, .before = 1),
      file.path(directory, "manifest.csv"),
      na = ""
    )
  })
