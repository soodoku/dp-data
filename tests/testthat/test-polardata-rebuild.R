source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "respondent_parity.R"))
source(file.path(root, "R", "polardata.R"))
source(file.path(root, "R", "polardata_rebuild.R"))
source(file.path(root, "R", "polardata_parity.R"))

full_polardata <- function() {
  arrow::read_parquet(project_path("output", "polardata", "polardata.parquet"))
}

test_that("full export preserves people and historical multiplicity", {
  data <- full_polardata()
  expect_identical(dim(data), c(6084L, 364L))
  expect_identical(names(data), read_metadata("polardata_fields")$legacy_field)
  expect_equal(sum(duplicated(data[c("dpnum", "caseid")])), 217L)
  counts <- table(data$dpnum)
  contracts <- read_metadata("respondent_sources")
  targets <- read_metadata("polardata_targets")
  for (i in seq_len(nrow(contracts))) {
    rows <- unique(targets$historical_rows[
      targets$poll_id == contracts$poll_id[[i]]
    ])
    expect_equal(unname(counts[as.character(contracts$dpnum[[i]])]), rows)
  }
  expect_true(all(is.na(data[grepl("^grk[.]", names(data))])))
})

test_that("derived exports preserve unique people and nonfinite history", {
  derived <- arrow::read_parquet(project_path(
    "output", "polardata", "derived_measures.parquet"
  ))
  expect_equal(nrow(derived), 5867L * 31L)
  expect_false(anyDuplicated(derived[c(
    "poll_id", "respondent_id", "legacy_field", "definition_version"
  )]) > 0L)
  infinite <- derived$value_status == "positive-infinity"
  expect_equal(sum(infinite), 2L)
  expect_true(all(derived$poll_id[infinite] == "australia-republic-1999"))
  expect_setequal(derived$legacy_field[infinite], c("grpgain", "loggain"))
  expect_true(all(derived$value_numeric[infinite] == Inf))
})

test_that("numerical exceptions cannot hide changed aggregate values", {
  data <- full_polardata()
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  parity <- compare_historical_polardata(data, reference, audit)
  expect_equal(sum(parity$unexplained_differences), 0L)
  expect_equal(sum(parity$reviewed_numerical_differences), 288L)
  group <- audit$pollgroup[which(audit$numerical_exception)[1]]
  row <- which(data$pollgroup == group)[1]
  data$genvar[[row]] <- 1
  parity <- compare_historical_polardata(data, reference, audit)
  expect_equal(sum(parity$unexplained_differences), 1L)
  data$genvar[[row]] <- NA_real_
  parity <- compare_historical_polardata(data, reference, audit)
  expect_equal(sum(parity$unexplained_differences), 1L)
})


test_that("regenerated export row numbers cannot be corrupted", {
  data <- full_polardata()
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  data$X[[1]] <- 999999L
  expect_error(compare_historical_polardata(data, reference, audit))
  data$X[[1]] <- NA_integer_
  expect_error(compare_historical_polardata(data, reference, audit))
})

test_that("UKC-01 approval cannot hide new changes or a reverted correction", {
  data <- full_polardata()
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  compare <- function(x) compare_historical_polardata(x, reference, audit)
  expect_equal(sum(compare(data)$approved_correction_differences), 142L)
  row <- which(data$dpnum == 6 & data$caseid == 10005)
  changed <- data
  changed$ukcrime.rootcauset2[row] <- reference$ukcrime.rootcauset2[row]
  expect_equal(sum(compare(changed)$unexplained_differences), 1L)
  changed$ukcrime.rootcauset2[row] <- 0.123
  expect_equal(sum(compare(changed)$unexplained_differences), 1L)
  changed <- data
  row <- which(data$dpnum == 6 & data$caseid == 10388)
  changed$ukcrime.rootcauset2[row] <- 1
  expect_equal(sum(compare(changed)$unexplained_differences), 1L)
})
