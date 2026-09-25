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


polls <- read_metadata("polls")
references <- read_documentation("poll_references")
facts <- read_documentation("poll_facts")
coverage <- read_documentation("poll_material_coverage")
previews <- read_documentation("document_previews")

purrr::walk(seq_len(nrow(polls)), function(index) {
  poll <- polls[index, ]
  directory <- project_path("data", poll$poll_id)
  fs::dir_create(directory)
  document <- poll_documentation(
    poll, dplyr::select(artifacts, -"directory"), references,
    facts, coverage, previews
  )
  jsonlite::write_json(document, file.path(directory, "metadata.json"),
    auto_unbox = TRUE, pretty = TRUE, na = "null", dataframe = "rows"
  )
})
