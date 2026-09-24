source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "respondent_btp_primaries.R"))

primaries_test_survey <- function() {
  arrow::read_parquet(project_path("data", "btp-presidential-primaries-2004",
    "survey.parquet"
  ))
}

test_that("primaries preserves people and legacy multiplicity", {
  survey <- primaries_test_survey()
  selected <- primaries_sample(survey)
  expect_equal(sum(selected), 217L)
  expect_equal(as.numeric(survey$caseid), 950000 + seq_len(nrow(survey)))
  path <- project_path("evidence", "benchmarks", "polardata.tab")
  reference <- readr::read_tsv(path, show_col_types = FALSE)
  reference <- reference[reference$dpnum == 16, ]
  expect_equal(nrow(reference), 434L)
  expect_true(all(table(reference$caseid) == 2L))
  expect_setequal(survey$caseid[selected], reference$caseid)
})

test_that("primaries reconstruction uses only original response fields", {
  survey <- primaries_test_survey()
  expected <- build_btp_primaries_individual(survey)
  keep <- grepl("^(b1q|f1q|pp)", names(survey)) &
    !grepl("cor$|_r$", names(survey))
  raw <- survey[, keep]
  expect_equal(build_btp_primaries_individual(raw), expected)
  order <- rev(seq_len(nrow(raw)))
  expect_equal(build_btp_primaries_individual(raw[order, ]), expected[order, ])
  expect_equal(build_btp_primaries_individual(raw[1:12, ]), expected[1:12, ])
  raw$b1q43[1] <- 77
  expect_error(build_btp_primaries_individual(raw), "Unreviewed source codes")
  missing <- survey[, names(survey) != "b1q43"]
  expect_error(build_btp_primaries_individual(missing),
    "Missing source field: b1q43"
  )
})
