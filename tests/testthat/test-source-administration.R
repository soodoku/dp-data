test_that("weekly moderator assignments preserve the treatment provenance", {
  survey <- read_poll_survey("btp-2007")
  fields <- paste0("mod", 1:4)
  expect_equal(nrow(survey), 1501L)
  expect_identical(survey$source_row, seq_len(nrow(survey)))
  expect_equal(unname(vapply(
    survey[fields], function(x) sum(nzchar(x)), integer(1)
  )), rep(301L, 4))
  expect_equal(unname(vapply(
    survey[fields], function(x) length(unique(x[nzchar(x)])), integer(1)
  )), c(9L, 8L, 9L, 9L))
  observed <- nzchar(survey$mod1)
  expect_true(all(survey$group[observed] == 1))
  expect_equal(length(unique(survey$Sgroup[observed])), 20L)
  changed <- apply(as.data.frame(survey[fields]), 1, function(x) {
    length(unique(x[nzchar(x)])) > 1L
  })
  expect_equal(sum(changed), 40L)
  expect_false("screenname" %in% names(survey))
})

test_that("NIC retains the documented other moderator answers", {
  survey <- read_poll_survey("nic-1996")
  expect_equal(nrow(survey), 911L)
  for (field in c("Q40_OTHE", "Q45_OTHE")) {
    expect_equal(sum(nzchar(trimws(survey[[field]]))), 1L)
    expect_identical(
      trimws(as.character(survey[[field]][nzchar(trimws(survey[[field]]))])),
      "MC NEAL"
    )
  }
})

test_that("Denmark preserves geography without changing municipal codes", {
  survey <- read_poll_survey("denmark-euro-2000")
  expect_equal(nrow(survey), 1702L)
  expect_equal(sum(nzchar(survey$kommunen)), 1641L)
  expect_equal(sum(nzchar(survey$amt)), 1641L)
  mapped <- survey |>
    dplyr::filter(nzchar(.data$kommunen)) |>
    dplyr::group_by(.data$kmnkode) |>
    dplyr::summarise(
      municipalities = dplyr::n_distinct(.data$kommunen),
      counties = dplyr::n_distinct(.data$amt)
    )
  expect_equal(nrow(mapped), 259L)
  expect_true(all(mapped$municipalities == 1L & mapped$counties == 1L))
})

test_that("Tomorrow's Europe retains literal source identifiers", {
  survey <- read_poll_survey("tomorrows-europe-2007")
  expect_equal(nrow(survey), 3550L)
  present <- nzchar(survey$part)
  expect_equal(sum(present), 750L)
  expect_true(all(grepl("^P[0-9]{3}$", survey$part[present])))
  expect_equal(length(unique(survey$part[present])), 750L)
  expect_identical(present, survey$invited == 1)
  expect_equal(sum(nzchar(survey$source)), 315L)
  expect_equal(sum(nzchar(survey$coder_name)), 359L)
  expect_equal(length(unique(survey$source[nzchar(survey$source)])), 8L)
  expect_equal(length(unique(survey$coder_name[nzchar(survey$coder_name)])), 9L)
})
