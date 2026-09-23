source(file.path(root, "R", "provenance.R"))

test_that("checksum matches conserve files and retain duplicate locations", {
  files <- tibble::tibble(
    repository = "example", path = letters[1:4],
    sha256 = c("one", "two", "three", NA_character_)
  )
  published <- tibble::tibble(
    path = c("data/b", "data/a", "data/c"),
    sha256 = c("one", "one", NA_character_)
  )
  archived <- tibble::tibble(
    path = c("archive/a", "archive/b"), sha256 = c("one", "two")
  )
  result <- match_source_checksums(files, published, archived, archived)
  expect_equal(nrow(result), nrow(files))
  expect_identical(
    result$byte_match,
    c("published-exact", "archive-exact-only", rep("no-exact-match", 2))
  )
  expect_identical(result$published_paths[[1]], "data/a|data/b")
  expect_identical(result$archive_paths[[1]], "archive/a")
  expect_true(is.na(result$published_paths[[4]]))
  expect_identical(result$reviewed_source, c(TRUE, TRUE, FALSE, FALSE))
  expect_error(match_source_checksums(
    dplyr::bind_rows(files, files[1, ]), published, archived, archived
  ))
})

test_that("empty source catalogs do not drop input candidates", {
  files <- tibble::tibble(repository = "example", path = "a", sha256 = "one")
  empty <- tibble::tibble(path = character(), sha256 = character())
  result <- match_source_checksums(files, empty, empty, empty)
  expect_equal(nrow(result), 1L)
  expect_identical(result$byte_match, "no-exact-match")
})

test_that("the local inventory hashes tracked files without reading records", {
  files <- inventory_repository_files(root)
  expect_gt(nrow(files), 0L)
  expect_equal(anyDuplicated(files[c("repository", "path")]), 0L)
  expect_true(all(grepl("^[a-f0-9]{64}$", files$sha256)))
  expect_true(all(grepl("^[a-f0-9]{40}$", files$repository_commit)))
  expect_true(all(grepl("^(data/|inst/extdata/)", files$path)))
  selected <- files |> dplyr::filter(
    .data$path == "data/uk-crime-1994/codebook.txt"
  )
  expect_equal(nrow(selected), 1L)
  expect_identical(
    selected$sha256,
    digest::digest(
      file = file.path(root, selected$path), algo = "sha256"
    )
  )
})
