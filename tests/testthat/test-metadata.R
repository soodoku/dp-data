test_that("metadata contracts are valid", {
  expect_no_error(validate_metadata())
})

test_that("the Frictionless package names every metadata table", {
  package <- frictionless::read_package(project_path("datapackage.json"))
  expect_setequal(
    frictionless::resource_names(package),
    c(
      "oos_sources",
      "respondent_sources",
      "respondent_source_components",
      "polardata_reviewed_covariances",
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
      "items",
      "knowledge_join_contracts",
      "poll_references",
      "poll_facts",
      "poll_material_coverage",
      "document_previews",
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
    dplyr::mutate(directory = dplyr::coalesce(.data$poll_id, "shared"))

  for (current_directory in unique(artifacts$directory)) {
    manifest <- readr::read_csv(
      project_path("data", current_directory, "manifest.csv"),
      show_col_types = FALSE,
      col_types = readr::cols(.default = readr::col_character())
    )
    expected <- artifacts |>
      dplyr::filter(.data$directory == current_directory) |>
      dplyr::select(-"directory") |>
      dplyr::select("poll_id", dplyr::everything())
    expect_equal(manifest, expected)
  }
})

test_that("source materials are preserved once and every reference resolves", {
  materials <- source_files() |>
    dplyr::filter(startsWith(.data$source_id, "material-"))
  artifacts <- read_metadata("artifacts") |>
    dplyr::filter(startsWith(.data$source_id, "material-"))
  expect_equal(anyDuplicated(materials$sha256), 0L)
  expect_true(all(startsWith(materials$path, "data/")))
  sources <- match(artifacts$source_id, materials$source_id)
  expect_false(anyNA(sources))
  expect_equal(artifacts$location, materials$path[sources])
  expect_equal(artifacts$sha256, materials$sha256[sources])
  expect_true(all(materials$source_id %in% artifacts$source_id))
})
