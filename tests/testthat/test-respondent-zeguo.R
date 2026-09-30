source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "respondent_zeguo.R"))

zeguo_test_survey <- function() {
  arrow::read_parquet(project_path("data", "zeguo-2005", "survey.parquet"))
}

test_that("Zeguo reconstruction ignores archived summary columns", {
  survey <- zeguo_test_survey()
  expected <- build_zeguo_individual(survey)
  inputs <- read_metadata("measure_inputs")
  contracts <- read_metadata("respondent_sources")
  identity <- contracts$id_column[contracts$poll_id == "zeguo-2005"]
  fields <- unique(c("source_row", identity, inputs$source_column[
    inputs$poll_id == "zeguo-2005"
  ]))
  positions <- match(tolower(fields), tolower(names(survey)))
  expect_false(anyNA(positions))
  raw <- survey[, positions]
  expect_equal(build_zeguo_individual(raw), expected)
  expect_equal(build_zeguo_individual(raw[, rev(seq_len(ncol(raw)))]),
    expected
  )
  order <- rev(seq_len(nrow(raw)))
  expect_equal(build_zeguo_individual(raw[order, ]), expected[order, ])
  expect_equal(build_zeguo_individual(raw[1:12, ]), expected[1:12, ])
  raw$d2014[1] <- 99
  expect_error(build_zeguo_individual(raw), "Unreviewed source codes")
})

test_that("Zeguo corrects one baseline age from the paired interview", {
  survey <- zeguo_test_survey()
  row <- which(survey$p == 125)
  expect_equal(survey$Age[row], 1)
  expect_equal(survey[["____1p"]][row], 33)
  age <- build_zeguo_individual(survey)$age
  expect_equal(age[row], 33)
  expect_equal(age[-row], read_source_codes(survey, "Age", 0:100)[-row])
  survey[["____1p"]][row] <- 34
  expect_error(build_zeguo_individual(survey))
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

test_that("Zeguo scales the 4.5 rating and uses post road answers", {
  survey <- zeguo_test_survey()
  baseline <- zeguo_attitudes(survey, 1L)
  post <- zeguo_attitudes(survey, 2L)
  built <- build_zeguo_individual(survey)
  row <- which(survey$p == 50)
  expect_equal(survey$d2007[row], 4.5)
  scaled <- as_historical_float(c(4.5, 5, 5) / 10)
  expect_equal(baseline$village_roads[row],
               as_historical_float(mean(scaled)))
  expect_true(all(baseline$village_roads <= 1, na.rm = TRUE))
  expect_equal(built$village_roads_t1, baseline$village_roads)
  imputed <- baseline |>
    dplyr::select(dplyr::ends_with("_midpoint_imputed"))
  expect_equal(built$attitude_extremity, rowMeans(abs(imputed - .5)))
  expect_equal(built$main_roads_t2, post$main_roads)
  expect_gt(sum(built$main_roads_t2 != built$main_roads_t1, na.rm = TRUE), 0L)
  expect_equal(built$wenchang_main_avenue_t1, baseline$wenchang_main_avenue)
  expect_equal(built$wenchang_main_avenue_t2, post$wenchang_main_avenue)
  expect_true(all(is.na(built$wenchang_main_avenue_t1[is.na(survey$d2006)])))
  expect_equal(
    built$wenchang_main_avenue_t1_midpoint_imputed[is.na(survey$d2006)],
    rep(.5, sum(is.na(survey$d2006)))
  )
  observed <- zeguo_departure_observed(survey)
  blank <- is.na(survey$d2006p) & observed
  expect_true(all(is.na(built$wenchang_main_avenue_t2[blank])))
  expect_equal(built$wenchang_main_avenue_t2_midpoint_imputed[blank],
               rep(.5, sum(blank)))
  expect_true(all(is.na(built$wenchang_main_avenue_t2[!observed])))
  paired <- !is.na(survey$preandpost) &
    !is.na(survey$d2006) & !is.na(survey$d2006p)
  expect_equal(sum(paired), 160L)
  expect_equal(round(mean(survey$d2006[paired]) / 10, 3), .825)
  expect_equal(round(mean(survey$d2006p[paired]) / 10, 3), .924)
})

test_that("Zeguo departure identities distinguish blank quiz answers", {
  survey <- zeguo_test_survey()
  observed <- zeguo_departure_observed(survey)
  expect_equal(sum(!observed), 34L)
  expect_true(observed[survey$p == 90])
  expect_true(all(is.na(survey[survey$p == 90, paste0("post_d304", 3:6)])))
  scores <- zeguo_knowledge_items(survey, "post")
  expect_true(all(is.na(scores[!observed, ])))
  expect_equal(unname(scores[survey$p == 90, ]), rep(0, 4))
  attitudes <- zeguo_attitudes(survey, 2L)
  expect_true(all(is.na(as.matrix(attitudes[!observed, ]))))
  plain <- attitudes |>
    dplyr::select(-dplyr::ends_with("_midpoint_imputed"))
  imputed <- attitudes |>
    dplyr::select(dplyr::ends_with("_midpoint_imputed"))
  expect_true(all(is.na(plain[survey$p == 90, ])))
  expect_equal(unname(unlist(imputed[survey$p == 90, ])), rep(.5, 9))
  expect_equal(observed[survey$p %in% c(29, 31)], c(FALSE, FALSE))
  corrupt <- survey
  corrupt$pp[corrupt$p == 29] <- 277
  corrupt$preandpost[corrupt$p == 29] <- 1
  expect_error(zeguo_departure_observed(corrupt))
  corrupt <- survey
  corrupt$d2006p[corrupt$p == 29] <- 10
  expect_error(zeguo_departure_observed(corrupt))
})

test_that("Zeguo raw source projections reproduce the joined survey", {
  source(project_path("R", "source_zeguo.R"), local = TRUE)
  directory <- project_path("data", "zeguo-2005", "source-materials")
  expect_equal(read_zeguo_sources(directory), zeguo_test_survey())
})
