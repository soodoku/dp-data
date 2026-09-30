testthat::test_that("Michigan preserves arrival factual text and identity", {
  survey <- read_poll_survey("michigan-2009")
  fields <- paste0("t2q", 38:42)
  testthat::expect_equal(nrow(survey), 610L)
  testthat::expect_equal(sum(!is.na(survey$postit)), 310L)
  testthat::expect_true(all(vapply(survey[fields], is.character, logical(1))))
  testthat::expect_equal(
    unname(vapply(survey[fields], function(x) sum(nzchar(x)), integer(1))),
    c(262L, 254L, 279L, 288L, 300L)
  )
  testthat::expect_equal(
    survey$t2q38[which(survey$postit == 1103)], "house of rep"
  )
  testthat::expect_equal(survey$t2q39[which(survey$postit == 1108)], "dec")
  testthat::expect_equal(
    survey$t2q38[which(survey$postit %in% c(402, 509))], c("n/a", "n/a")
  )
  testthat::expect_true(all(
    vapply(survey[which(survey$postit == 5000), fields],
      function(x) all(x == ""), logical(1)
    )
  ))
  dictionary <- readr::read_csv(
    project_path("data/michigan-2009/variables.csv"),
    show_col_types = FALSE
  )
  testthat::expect_true(all(dictionary$public[
    match(fields, dictionary$source_column)
  ]))
  exclusions <- read_metadata("source_field_exclusions") |>
    dplyr::filter(poll_id == "michigan-2009")
  testthat::expect_false(any(fields %in% exclusions$source_column))
})
