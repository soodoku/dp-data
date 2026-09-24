source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "respondent_zeguo.R"))

zeguo_test_survey <- function() {
  arrow::read_parquet(project_path("data", "zeguo-2005", "survey.parquet"))
}

test_that("Zeguo reconstruction ignores archived summary columns", {
  survey <- zeguo_test_survey()
  expected <- build_zeguo_individual(survey)
  keep <- grepl("^(pre_|post_|d20[0-9][0-9]p?$)", names(survey)) |
    names(survey) %in% c("p", "Age", "Education", "Gender")
  raw <- survey[, keep]
  expect_equal(build_zeguo_individual(raw), expected)
  order <- rev(seq_len(nrow(raw)))
  expect_equal(build_zeguo_individual(raw[order, ]), expected[order, ])
  expect_equal(build_zeguo_individual(raw[1:12, ]), expected[1:12, ])
  raw$d2014[1] <- 99
  expect_error(build_zeguo_individual(raw), "Unreviewed source codes")
})

test_that("Zeguo preserves raw answers and historical item coding", {
  survey <- zeguo_test_survey()
  row <- which(survey$p == 105)
  expect_equal(survey$post_d3045[row], 1)
  scores <- zeguo_knowledge_items(survey, "post")
  expect_equal(unname(scores[row, "post_d3045"]), 1)
  survey$post_d3045[row] <- 2
  expect_error(zeguo_knowledge_items(survey, "post"))
})

test_that("Zeguo retains the pre-cleaning group-summary vintage", {
  survey <- zeguo_test_survey()
  raw <- zeguo_attitudes(survey, 1L)
  built <- build_zeguo_individual(survey)
  expect_equal(sum(raw$village_roads > 1), 1L)
  expect_true(all(is.na(built$village_roads_t1[raw$village_roads > 1])))
  expect_equal(built$attitude_extremity, rowMeans(abs(raw - .5)))
  expect_equal(built$main_roads_t2, built$main_roads_t1)
})

test_that("Zeguo raw source projections reproduce the joined survey", {
  source(project_path("R", "source_zeguo.R"), local = TRUE)
  directory <- project_path("data", "zeguo-2005", "source-materials")
  expect_equal(read_zeguo_sources(directory), zeguo_test_survey())
})
