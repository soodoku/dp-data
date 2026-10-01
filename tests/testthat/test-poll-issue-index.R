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

test_that("bold and wrapped issues share the heading index contract", {
  register <- list(poll_prefixes = list(UKM = "uk-monarchy-1996"))
  lines <- c(
    '<a id="ukm-01"></a>',
    "**UKM-01 — earlier proposal.** Original evidence.",
    "### UKM-01: Later headed decision",
    '<a id="ukm-02"></a>',
    "**UKM-02 — a wrapped", "source-identity title.** Evidence stays separate."
  )
  index <- poll_issue_index(register, lines)
  expect_equal(nrow(index), 2L)
  expect_equal(index$title[index$issue_id == "UKM-01"],
    "UKM-01: Later headed decision"
  )
  expect_equal(index$title[index$issue_id == "UKM-02"],
    "UKM-02 — a wrapped source-identity title."
  )
  expect_true(all(index$poll_id == "uk-monarchy-1996"))
  expect_error(poll_issue_index(register, lines[-1]), "anchor")
  expect_error(poll_issue_index(list(poll_prefixes = list()), lines), "prefix")
})

test_that("the index covers every primary issue and all analytical polls", {
  index <- poll_issue_index()
  evidence <- readLines(project_path("docs", "poll-evidence.md"), warn = FALSE)
  primary <- grep(
    "^(#{2,6} |\\*\\*)[A-Z][A-Z0-9]*-[0-9]{2,4}",
    evidence, value = TRUE
  )
  leading <- sub(":.*$| —.*$", "", primary)
  expected <- unique(unlist(stringr::str_extract_all(
    leading, "\\b[A-Z][A-Z0-9]*-[0-9]{2,4}\\b"
  )))
  expect_setequal(unique(index$issue_id), expected)
  expect_equal(length(unique(index$issue_id)), 243L)
  expect_setequal(index$issue_id[index$poll_id %in% "uk-monarchy-1996"],
    sprintf("UKM-%02d", 1:8)
  )
  expect_true(all(sprintf("UKEU-%02d", 1:5) %in% index$issue_id))
  expect_true("AUS-01" %in% index$issue_id)
  selected <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_participants.parquet"
  ), col_select = "poll_id")
  phases <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_phase_participants.parquet"
  ), col_select = "poll_id")
  expect_setequal(selected$poll_id, phases$poll_id)
  expect_equal(length(unique(selected$poll_id)), 33L)
  expected_polls <- c(unique(selected$poll_id), "bulgaria-2007")
  expect_setequal(stats::na.omit(index$poll_id), expected_polls)
  expect_equal(length(unique(stats::na.omit(index$poll_id))), 34L)
  expect_equal(index$poll_id[index$issue_id == "BG07-01"], "bulgaria-2007")
  expect_equal(index$title[index$issue_id == "CPL-05"],
    "CPL-05: Group gain uses a truncated early group-size calculation"
  )
})
