source(file.path(root, "R", "linkage.R"))

test_that("the crosswalk conserves both poll universes", {
  root <- normalizePath(file.path(testthat::test_path(), "..", ".."))
  crosswalk <- read.csv(file.path(root, "output/linkage/poll_crosswalk.csv"))
  expect_equal(nrow(crosswalk), 28)
  expect_equal(sum(!is.na(crosswalk$dpnum)), 21)
  expect_equal(sum(crosswalk$match_status == "distortions_only"), 5)
  expect_equal(sum(crosswalk$match_status == "cor_sood_only"), 7)
  expect_equal(sum(crosswalk$match_status == "validated_person_link"), 6)
  file_keys <-
    crosswalk$file_key[!is.na(crosswalk$file_key) & nzchar(crosswalk$file_key)]
  expect_equal(anyDuplicated(file_keys), 0)
})

test_that("published reliability summary is reproduced", {
  root <- normalizePath(file.path(testthat::test_path(), "..", ".."))
  reliability <- read.csv(file.path(
    root,
    "output/linkage/knowledge_reliability.csv"
  ))
  expect_equal(nrow(reliability), 23)
  expect_equal(sum(reliability$items), 177)
  expect_equal(mean(reliability$alpha_t1), 0.495, tolerance = 0.001)
  expect_equal(mean(reliability$alpha_t2), 0.561, tolerance = 0.001)
  expect_equal(sum(reliability$alpha_t2_higher), 18)
})

test_that("respondent output contains only validated links", {
  root <- normalizePath(file.path(testthat::test_path(), "..", ".."))
  linked <- read.csv(file.path(root, "output/linkage/respondent_items.csv"))
  expect_setequal(unique(linked$dpnum), c(2, 6, 8, 18, 19, 21))
  expect_setequal(unique(linked$wave), c("t1", "t2"))
  expect_setequal(unique(linked$correct), c(0, 1))
  expect_true(all(linked$linkage_basis == "validated_public_row_position"))
  expect_equal(anyDuplicated(linked[c(
    "dpnum", "caseid", "item_id",
    "wave"
  )]), 0)
})

test_that("knowledge-attitude panel uses only validated respondent links", {
  root <- normalizePath(file.path(testthat::test_path(), "..", ".."))
  panel <- read.csv(file.path(
    root,
    "output/linkage/knowledge_attitude_panel.csv"
  ))
  expect_setequal(unique(panel$dpnum), c(2, 6, 8, 18, 19, 21))
  expect_equal(anyDuplicated(panel[c("dpnum", "caseid", "attitude_index")]), 0)
  expect_true(all(panel$t1_knowledge >= 0 & panel$t1_knowledge <= 1))
  expect_true(all(panel$t2_knowledge >= 0 & panel$t2_knowledge <= 1))
  expect_true(all(panel$t1_knowledge_items == panel$t2_knowledge_items))
  expect_true(any(!is.na(panel$t1_attitude) & !is.na(panel$t2_attitude)))
})

test_that("all linkage outputs reproduce the frozen pre-migration baseline", {
  expected <- read.csv(project_path(
    "tests", "fixtures",
    "linkage_checksums.csv"
  ))
  for (i in seq_len(nrow(expected))) {
    path <- project_path("output", "linkage", expected$file[i])
    expect_identical(
      digest::digest(file = path, algo = "sha256"), expected$sha256[i],
      info = expected$file[i]
    )
  }
})

test_that("altered respondent scores cannot create a positional link", {
  poll <- read_polardata()
  battery <- read_battery(linkage_battery_path("ukhealth"))
  expect_silent(validate_person_link(poll, battery, 2L))
  battery$t1[1, 1] <- 1 - battery$t1[1, 1]
  expect_error(validate_person_link(poll, battery, 2L))
})
