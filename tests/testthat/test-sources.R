test_that("public sources match their catalog", {
  expect_no_error(verify_source_files())
})

test_that("source paths are unique and repository relative", {
  manifest <- source_files()
  expect_equal(anyDuplicated(manifest$path), 0L)
  expect_true(all(!fs::is_absolute_path(manifest$path)))
})

test_that("CDD source bundle names are unique and repository relative", {
  manifest <- source_bundles()
  expect_equal(anyDuplicated(manifest$local_filename), 0L)
  expect_true(all(!fs::is_absolute_path(manifest$local_filename)))
  expect_true(all(manifest$publication_status != "public"))
})

test_that("archive references resolve to retained bytes after deduplication", {
  retained <- "data/uk-crime-1994/survey.sav"
  checksum <- digest::digest(file = project_path(retained), algo = "sha256")
  inventory <- tibble::tibble(
    path = "removed/original.sav", sha256 = checksum, retained_path = retained
  )
  expect_identical(
    archive_source_path("removed/original.sav", checksum, inventory),
    project_path(retained)
  )
  expect_error(archive_source_path("missing.sav", inventory = inventory),
    "Unknown or ambiguous"
  )
  expect_error(archive_source_path("removed/original.sav", "wrong", inventory),
    "checksum contract mismatch"
  )
  expect_error(
    archive_source_path("removed/original.sav",
      inventory = dplyr::bind_rows(inventory, inventory)
    ),
    "Unknown or ambiguous"
  )
  inventory$retained_path <- "DESCRIPTION"
  expect_error(
    archive_source_path("removed/original.sav", inventory = inventory),
    "source checksum mismatch"
  )
  inventory$retained_path <- "missing-original.sav"
  expect_error(
    archive_source_path("removed/original.sav", inventory = inventory),
    "source is absent"
  )
})

test_that("archive locators distinguish retained and removed duplicates", {
  inventory <- readr::read_csv(
    project_path("audit", "cdd_archive_files.csv"), show_col_types = FALSE
  )
  expect_equal(anyDuplicated(inventory$path), 0L)
  removed <- inventory$publication_status == "removed-content-duplicate"
  expect_equal(inventory$sha256[removed],
    "66486d9ce06dc2568654ae654582d010d8afd454c0afe0162905d922b1172bbc"
  )
  expect_true(all(is.na(inventory$retained_path[removed])))
  retained <- inventory[!removed, ]
  expect_false(anyNA(retained$retained_path))
  expect_true(all(grepl("^(data|vault)/", retained$retained_path)))
  copies <- retained |> dplyr::distinct(.data$retained_path, .data$sha256)
  expect_equal(anyDuplicated(copies$retained_path), 0L)
})
