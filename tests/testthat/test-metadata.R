test_that("metadata contracts are valid", {
  expect_no_error(validate_metadata())
})

test_that("the Frictionless package names every metadata table", {
  package <- frictionless::read_package(project_path("datapackage.json"))
  expect_setequal(
    frictionless::resource_names(package),
    c(
      "artifact_types",
      "polls",
      "poll_aliases",
      "source_bundles",
      "source_files",
      "recode_ledger",
      "downstream_contracts"
    )
  )
})
