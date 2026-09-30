test_that("issue metadata links directly to detailed evidence", {
  index <- poll_issue_index()
  expect_false(anyDuplicated(index[c("issue_id", "poll_id")]) > 0L)
  expect_true(all(startsWith(
    index$evidence_path,
    "../../docs/poll-evidence.md#"
  )))
  evidence <- readLines(project_path("docs", "poll-evidence.md"), warn = FALSE)
  decisions <- readLines(project_path("docs", "poll-issues.md"), warn = FALSE)
  anchors <- paste0('<a id="', tolower(unique(index$issue_id)), '"></a>')
  expect_true(all(vapply(anchors, function(anchor) {
    any(grepl(anchor, evidence, fixed = TRUE))
  }, logical(1))))
  expect_true(all(vapply(anchors, function(anchor) {
    any(grepl(anchor, decisions, fixed = TRUE))
  }, logical(1))))
  expect_setequal(
    index$poll_id[index$issue_id == "NEW-01"],
    c("a1r-climate-2021", "amr-2024")
  )
  expect_equal(index$poll_id[index$issue_id == "WTU-07"], "wtu-1996")
  expect_equal(index$poll_id[index$issue_id == "SWE-06"], "swepco-1996")
  expect_true(is.na(index$poll_id[index$issue_id == "X-28"]))
})

test_that("in-memory poll documentation preserves direct evidence links", {
  polls <- read_metadata("polls")
  poll <- polls[polls$poll_id == "san-mateo-2008", ]
  documentation <- poll_documentation(
    poll, read_metadata("artifacts"), read_documentation("poll_references"),
    read_documentation("poll_facts"),
    read_documentation("poll_material_coverage"),
    read_documentation("document_previews")
  )
  index <- documentation$issues$evidence_index
  expect_true("SM-11" %in% index$issue_id)
  expect_true(all(startsWith(
    index$evidence_path,
    "../../docs/poll-evidence.md#"
  )))
  expect_equal(
    documentation$issues$shared_rules_path,
    paste0(
      "../../docs/poll-evidence.md#",
      "cross-poll-issues-for-the-eventual-schema"
    )
  )
  expect_true(all(vapply(
    documentation$issues$reviewed_flags,
    function(issue) issue$decision == "retain_main_analysis", logical(1)
  )))
})
