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

testthat::test_that("Michigan retains questionnaire answers and late flag", {
  survey <- read_poll_survey("michigan-2009")
  expected <- c(
    q26oth = 0L, q32oth = 3L, q40oth = 4L, q42oth = 1L,
    t3q16 = 291L, t3q17 = 306L, t3q18 = 304L, t3q19 = 305L,
    t3q47 = 299L, t3q48 = 297L, t3q49oth = 47L,
    t2filter_late = 16L, coder_initials_x = 303L,
    coder_initials_y = 291L, c135 = 1L,
    t2q16 = 292L, t2q17 = 293L, t2q18 = 296L, t2q19 = 296L,
    t2q26a = 300L, t2q33b = 303L,
    t2q49 = 299L, t2q50 = 300L, t2q51 = 290L, t2q51oth = 31L
  )
  testthat::expect_equal(nrow(survey), 610L)
  testthat::expect_equal(ncol(survey), 350L)
  testthat::expect_equal(
    vapply(survey[names(expected)], function(x) sum(nzchar(x)), integer(1)),
    expected
  )
  testthat::expect_true(all(vapply(
    survey[names(expected)], is.character, logical(1)
  )))
  testthat::expect_equal(sum(survey$t2q17 == "v"), 1L)
  testthat::expect_equal(sum(survey$t3q16 == "8"), 1L)
  testthat::expect_equal(sum(survey$t2q26a %in% c("a", "b")), 3L)
  testthat::expect_equal(sum(survey$t2q33b == "9-"), 1L)
  testthat::expect_equal(sum(survey$t2filter_late == "1"), 16L)
  testthat::expect_equal(survey$c135[survey$c135 != ""], "s")
  testthat::expect_equal(
    sum(survey$q32oth != "" & is.na(survey$postit)), 2L
  )
  testthat::expect_equal(
    sum(survey$q40oth != "" & is.na(survey$postit)), 1L
  )
  excluded <- read_metadata("source_field_exclusions") |>
    dplyr::filter(poll_id == "michigan-2009")
  testthat::expect_setequal(excluded$source_column, c(
    "city", "st", "zipcode", "fname", "lname", "variabl0",
    "phone1", "phone2", "email"
  ))
  testthat::expect_false(any(excluded$source_column %in% names(survey)))
})
