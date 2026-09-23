test_that("metadata contracts are valid", {
  expect_no_error(validate_metadata())
})

test_that("the Frictionless package names every metadata table", {
  package <- frictionless::read_package(project_path("datapackage.json"))
  expect_setequal(
    frictionless::resource_names(package),
    c(
      "artifact_types",
      "archive_collections",
      "artifacts",
      "polls",
      "poll_aliases",
      "source_bundles",
      "source_files",
      "recode_ledger",
      "downstream_contracts"
    )
  )
})

test_that("Data Package paths are portable", {
  package <- frictionless::read_package(project_path("datapackage.json"))
  paths <- purrr::map_chr(package$resources, "path")
  expect_true(all(!fs::is_absolute_path(paths)))
  expect_true(all(stringr::str_starts(paths, "metadata/")))
})

test_that("generated poll manifests match the central artifact catalog", {
  artifacts <- read_metadata("artifacts") |>
    dplyr::filter(!is.na(.data$poll_id))

  for (current_poll_id in unique(artifacts$poll_id)) {
    manifest <- readr::read_csv(
      project_path("polls", current_poll_id, "manifest.csv"),
      show_col_types = FALSE
    )
    expected <- artifacts |>
      dplyr::filter(.data$poll_id == current_poll_id) |>
      dplyr::select("poll_id", dplyr::everything())
    expect_equal(manifest, expected)
  }
})
