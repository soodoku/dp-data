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
  expect_equal(sum(compare(data)$approved_correction_differences[
    compare(data)$poll_id == "uk-crime-1994"
  ]), 142L)
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

test_that("UKGE-03 approval protects every affected aggregate field", {
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "uk-general-election-1997", "approved_values.csv"
  ), show_col_types = FALSE)
  expect_equal(nrow(approved), 275L * 19L)
  data <- full_polardata()
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  fields <- unique(approved$legacy_field)
  changed <- data
  for (field in fields) {
    evidence <- approved[approved$legacy_field == field, ]
    row <- which(abs(evidence$historical_value - evidence$approved_value) >
                   1e-10)[1]
    target <- which(changed$dpnum == 4 & changed$caseid == evidence$caseid[row])
    changed[[field]][target] <- evidence$historical_value[row]
  }
  parity <- compare_historical_polardata(changed, reference, audit)
  expect_equal(sum(parity$unexplained_differences), 19L)
  actual <- data[data$dpnum == 4, ]
  for (field in fields) {
    evidence <- approved[approved$legacy_field == field, ]
    expect_equal(actual[[field]][match(evidence$caseid, actual$caseid)],
                 evidence$approved_value, tolerance = 1e-10)
  }
})

test_that("NIC approved ages and mode retain the single missing identity", {
  data <- full_polardata()
  nic <- data[data$dpnum == 20, ]
  expect_equal(nrow(nic), 466L)
  expect_equal(sum(is.na(nic$caseid)), 1L)
  expect_true(all(nic$mode == 0))
  expect_equal(sum(!is.na(nic$ppage)), 458L)
  expect_equal(sum(nic$ppage < 16, na.rm = TRUE), 4L)
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  changed <- data
  row <- which(data$dpnum == 20 & !is.na(data$ppage))[1]
  for (field in c("ppage", "meanage", "mode")) {
    changed[[field]][row] <- reference[[field]][row]
  }
  result <- compare_historical_polardata(changed, reference, audit)
  expect_equal(sum(result$unexplained_differences), 3L)
  changed <- data
  row <- which(data$dpnum == 20 & is.na(data$caseid))
  changed$mode[row] <- 1
  result <- compare_historical_polardata(changed, reference, audit)
  expect_equal(sum(result$unexplained_differences), 1L)
})
