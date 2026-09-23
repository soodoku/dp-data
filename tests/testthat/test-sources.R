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
