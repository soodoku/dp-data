test_that("poll facts cannot cite a different poll or an unknown source", {
  facts <- read_documentation("poll_facts")
  references <- read_documentation("poll_references")
  facts$reference_id[1] <- "missing-reference"
  expect_error(validate_poll_documentation(facts = facts))
  facts$reference_id[1] <- references$reference_id[
    which(references$poll_id != facts$poll_id[1])[1]
  ]
  expect_error(validate_poll_documentation(facts = facts))
})

test_that("material coverage cannot silently omit a poll", {
  coverage <- read_documentation("poll_material_coverage")
  expect_error(validate_poll_documentation(coverage = coverage[-1, ]))
})

test_that("document previews must match their preserved originals", {
  previews <- read_documentation("document_previews")
  previews$source_sha256[1] <- strrep("0", 64)
  expect_error(validate_poll_documentation(previews = previews))
})

test_that("every poll has generated metadata with resolvable source links", {
  polls <- read_metadata("polls")
  facts <- read_documentation("poll_facts")
  references <- read_documentation("poll_references")
  coverage <- read_documentation("poll_material_coverage")
  previews <- read_documentation("document_previews")
  artifacts <- read_metadata("artifacts")
  for (index in seq_len(nrow(polls))) {
    poll <- polls[index, ]
    path <- project_path("data", poll$poll_id, "metadata.json")
    observed <- jsonlite::read_json(path)
    expected <- poll_documentation(
      poll, artifacts, references, facts, coverage, previews
    )
    encoded <- jsonlite::toJSON(expected,
      auto_unbox = TRUE, na = "null", dataframe = "rows"
    )
    expected <- jsonlite::fromJSON(encoded, simplifyVector = FALSE)
    expect_equal(observed, expected)
    expect_gt(length(observed$references), 0L)
    expect_gt(length(observed$facts), 0L)
    for (artifact in observed$artifacts) {
      expect_true(file.exists(file.path(dirname(path), artifact$relative_path)))
    }
  }
})

test_that("poll documentation rejects unregistered genres and fact fields", {
  references <- read_documentation("poll_references")
  references$kind[1] <- "invented-genre"
  expect_error(validate_poll_documentation(references = references))
  facts <- read_documentation("poll_facts")
  facts$field[1] <- "not-an-event-field"
  expect_error(validate_poll_documentation(facts = facts))
})

test_that("published poll summaries omit unavailable vault artifacts", {
  observed <- jsonlite::read_json(
    project_path("data", "marousi-2006", "metadata.json")
  )
  expect_true(all(vapply(observed$artifacts, function(artifact) {
    artifact$publication_status == "published" &&
      !startsWith(artifact$location, "vault/")
  }, logical(1))))
})

test_that("available instruments require local instrument evidence", {
  coverage <- read_documentation("poll_material_coverage")
  references <- read_documentation("poll_references")
  row <- which(
    coverage$poll_id == "nic-1996" &
      coverage$material_type == "questionnaires"
  )
  paper_rows <- references$poll_id == "nic-1996" &
    references$kind == "paper"
  paper <- references$reference_id[paper_rows][1]
  coverage$checked_references[row] <- paper
  expect_error(validate_poll_documentation(coverage = coverage))
})
