test_that("metadata contracts are valid", {
  expect_no_error(validate_metadata())
})

test_that("the Frictionless package names every metadata table", {
  package <- frictionless::read_package(project_path("datapackage.json"))
  expect_setequal(
    frictionless::resource_names(package),
    c(
      "respondent_sources",
      "polardata_fields",
      "polardata_targets",
      "measure_definitions",
      "measure_inputs",
      "artifact_types",
      "archive_collections",
      "artifacts",
      "canonical_tables",
      "canonical_columns",
      "knowledge_batteries",
      "survey_sources",
      "survey_components",
      "component_field_exclusions",
      "source_field_exclusions",
      "knowledge_items",
      "knowledge_join_contracts",
      "polls",
      "poll_aliases",
      "source_bundles",
      "source_files",
      "source_findings",
      "downstream_porting_review",
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
      project_path("data", current_poll_id, "manifest.csv"),
      show_col_types = FALSE,
      col_types = readr::cols(.default = readr::col_character())
    )
    expected <- artifacts |>
      dplyr::filter(.data$poll_id == current_poll_id) |>
      dplyr::select("poll_id", dplyr::everything())
    expect_equal(manifest, expected)
  }
})
