test_that("San Mateo preserves scientific strings without interpreting them", {
  survey <- arrow::read_parquet(project_path(
    "data", "san-mateo-2008", "survey.parquet"
  ))
  bins <- c(paste0("Q", c(1:4, 7:9), "I"), paste0("t2Q", c(1:4, 7:9), "I"))
  fields <- c(bins, "Q128OTHER", "INTDATE", "QSTGRP", "SRVYINV")
  expect_equal(nrow(survey), 1806L)
  expect_equal(ncol(survey), 325L)
  expect_true(all(vapply(survey[fields], is.character, logical(1))))
  expect_identical(survey$source_row, seq_len(nrow(survey)))
  expect_equal(sum(!is.na(survey$PARTICIPANTID)), 710L)
  expect_equal(dplyr::n_distinct(survey$PARTICIPANTID, na.rm = TRUE), 710L)
  expect_equal(sum(survey$Q128OTHER != ""), 16L)
  expect_true(all(survey$Q128[survey$Q128OTHER != ""] == 7))
  expect_equal(sum(survey$SRVYINV != ""), 235L)
  expect_true(all(survey$DISPOS[survey$SRVYINV != ""] %in% c(19, 20)))
  expect_setequal(survey$QSTGRP, c("1", "2"))
  dates <- as.Date(survey$INTDATE, "%Y%m%d")
  expect_false(anyNA(dates))
  expect_equal(range(dates), as.Date(c("2008-02-03", "2008-03-06")))
  expect_equal(sum(survey$Q3I == "6 to 10"), 88L)
  expect_true(all(is.na(survey$Q3[survey$Q3I == "6 to 10"])))
  expect_true(all(survey$t2Q7I == ""))
  expect_equal(sum(survey$t2Q7 %in% 0:10), 236L)
  partial <- survey[survey$PARTICIPANTID %in% 1411, ]
  expect_equal(nrow(partial), 1L)
  expect_identical(as.character(partial$t2Q2I), "1 to 3")
  expect_identical(as.character(partial$t2Q8I), "1 to 3")
  expect_true(is.na(partial$t2Q2))
  expect_true(is.na(partial$t2Q8))
  pending <- survey[survey$PARTICIPANTID %in% 1467, ]
  expect_equal(nrow(pending), 1L)
  expect_equal(pending$participant, 1)
  expect_equal(pending$t2QSTGRP, 1)
  expect_true(all(pending[paste0("t2Q", c(1:4, 7:9), "I")] == ""))
  excluded <- read_metadata("source_field_exclusions") |>
    dplyr::filter(poll_id == "san-mateo-2008") |>
    dplyr::pull(source_column)
  expect_setequal(excluded, c(
    "CITY", "ZCODE", "ALTPHN", "BSTTIM", "COMMENT1", "PHNNUM"
  ))
  expect_false(any(excluded %in% names(survey)))
})
