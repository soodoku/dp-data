source(file.path(root, "R", "source_utilities.R"))

test_that("original Texas responses preserve substantive values", {
  for (poll in c("swepco-1996", "wtu-1996")) {
    path <- project_path(
      "data", poll, "source-materials", "survey-original.por"
    )
    before <- digest::digest(file = path, algo = "sha256")
    review <- review_utilities_original(poll)
    expect_identical(digest::digest(file = path, algo = "sha256"), before)
    swepco <- poll == "swepco-1996"
    expect_equal(nrow(review$collapsed), if (swepco) 14774L else 12823L)
    expect_length(review$absent_post_ids, if (swepco) 1246L else 1000L)
    items <- paste0(
      rep(c("SOURCE", "USE", "RT", "SMOG", "SETRT"), 2),
      rep(1:2, each = 5L)
    )
    attendee_items <- review$original[review$original$PART == 1L, items]
    expect_false(anyNA(attendee_items))
    expect_equal(sum(attendee_items == 99), if (swepco) 436L else 409L)
  }
})

test_that("source comparison rejects a missing maintained column", {
  maintained <- read_poll_survey("swepco-1996")
  maintained$SOURCE1 <- NULL
  expect_error(
    review_utilities_original("swepco-1996", maintained),
    "names(original)", fixed = TRUE
  )
})
