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

test_that("derived exports preserve unique people and reviewed gain", {
  derived <- arrow::read_parquet(project_path(
    "output", "polardata", "derived_measures.parquet"
  ))
  expect_equal(nrow(derived), 5867L * 31L)
  expect_false(anyDuplicated(derived[c(
    "poll_id", "respondent_id", "legacy_field", "definition_version"
  )]) > 0L)
  infinite <- derived$value_status == "positive-infinity"
  expect_equal(sum(infinite), 0L)
  wide <- full_polardata()
  expect_equal(wide$loggain, historical_log_score(wide$grpgain))
  australia_gain <- derived$poll_id == "australia-republic-1999" &
    derived$legacy_field %in% c("grpgain", "loggain")
  expect_setequal(unique(derived$definition_version[australia_gain]),
                  "aus-04-v2")
  election_group <- derived$poll_id == "uk-general-election-1997" &
    derived$legacy_field %in% c(
      "grpgain", "grpgainr", "loggain", "avgsd", "genvar"
    )
  expect_setequal(unique(derived$definition_version[election_group]),
                  "ukge-05-v2")
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
  approved <- approved[!approved$legacy_field %in%
                         c("ukbge.t2tax", "avgsd", "genvar"), ]
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

test_that("UKGE-02 protects approved post tax-and-spending values", {
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "uk-general-election-1997", "approved_values.csv"
  ), show_col_types = FALSE)
  approved <- approved[approved$legacy_field == "ukbge.t2tax", ]
  expect_equal(nrow(approved), 275L)
  data <- full_polardata()
  actual <- data[data$dpnum == 4L, ]
  expect_setequal(actual$caseid, approved$caseid)
  positions <- match(actual$caseid, approved$caseid)
  expect_equal(actual$ukbge.t2tax, approved$approved_value[positions],
               tolerance = 1e-10)
  paired <- !is.na(approved$historical_value) &
    !is.na(approved$approved_value)
  expect_equal(sum(abs(approved$historical_value[paired] -
                         approved$approved_value[paired]) > 1e-10), 207L)
  expect_equal(sum(is.na(approved$historical_value) !=
                     is.na(approved$approved_value)), 17L)
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  changed <- which(paired & abs(approved$historical_value -
                                  approved$approved_value) > 1e-10)[1]
  row <- which(data$dpnum == 4L & data$caseid == approved$caseid[changed])
  data$ukbge.t2tax[row] <- approved$historical_value[changed]
  parity <- compare_historical_polardata(data, reference, audit)
  expect_equal(sum(parity$unexplained_differences), 1L)
})

test_that("UKGE-05 excludes a nonparticipant from early group metrics", {
  survey <- read_poll_survey("uk-general-election-1997")
  excluded <- which(as.numeric(survey$serial) == 4416)
  expect_length(excluded, 1L)
  expect_equal(as.numeric(survey$group[excluded]), 9)
  expect_equal(as.numeric(survey$partic[excluded]), 0)
  expect_true(is.na(survey$taxr2[excluded]))
  profile <- core_poll_profile(survey, "uk-general-election-1997")
  expect_true(is.na(profile$group[excluded]))
  expect_equal(sum(profile$group == 2509, na.rm = TRUE), 17L)

  fields <- c("grpgain", "grpgainr", "loggain", "avgsd", "genvar")
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "uk-general-election-1997", "approved_values.csv"
  ), show_col_types = FALSE)
  approved <- approved[approved$legacy_field %in% fields, ]
  expect_equal(nrow(approved), 275L * length(fields))
  data <- full_polardata()
  actual <- data[data$dpnum == 4L, ]
  for (field in fields) {
    evidence <- approved[approved$legacy_field == field, ]
    expect_setequal(evidence$caseid, actual$caseid)
    position <- match(actual$caseid, evidence$caseid)
    expect_equal(actual[[field]], evidence$approved_value[position],
                 tolerance = 1e-10)
  }
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  row <- which(data$dpnum == 4L & data$pollgroup == 2509)[1]
  evidence <- approved[approved$legacy_field == "avgsd" &
                         approved$caseid == data$caseid[row], ]
  expect_gt(abs(data$avgsd[row] - evidence$historical_value), 1e-10)
  data$avgsd[row] <- evidence$historical_value
  parity <- compare_historical_polardata(data, reference, audit)
  expect_equal(sum(parity$unexplained_differences), 1L)
})

test_that("CPL-05 uses full group sizes and guards approved gain values", {
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "cpl-1996", "approved_values.csv"
  ), show_col_types = FALSE)
  fields <- c("grpgain", "grpgainr", "loggain")
  expect_setequal(approved$legacy_field, fields)
  expect_equal(nrow(approved), 216L * length(fields))
  data <- full_polardata()
  cpl <- data[data$dpnum == 8L, ]
  expect_equal(nrow(cpl), 216L)
  for (field in fields) {
    frozen <- approved[approved$legacy_field == field, ]
    expect_setequal(cpl$caseid, frozen$caseid)
    expect_equal(cpl[[field]][match(frozen$caseid, cpl$caseid)],
                 frozen$approved_value, tolerance = 1e-10)
    expect_equal(sum(abs(frozen$approved_value -
                           frozen$historical_value) > 1e-10), 132L)
  }
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  reverted <- data
  frozen <- approved[approved$legacy_field == "grpgain", ]
  changed <- which(abs(frozen$approved_value - frozen$historical_value) >
                     1e-10)[1]
  row <- which(reverted$dpnum == 8L & reverted$caseid == frozen$caseid[changed])
  reverted$grpgain[row] <- frozen$historical_value[changed]
  parity <- compare_historical_polardata(reverted, reference, audit)
  expect_equal(sum(parity$unexplained_differences), 1L)
})

test_that("SWE-02 protects every approved conservation value", {
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "swepco-1996", "approved_values.csv"
  ), show_col_types = FALSE)
  expect_equal(nrow(approved), 232L)
  expect_true(all(approved$legacy_field == "swp.t2att3"))
  data <- full_polardata()
  selected <- data$dpnum == 21L
  expect_setequal(data$caseid[selected], approved$caseid)
  positions <- match(data$caseid[selected], approved$caseid)
  expect_equal(data$swp.t2att3[selected], approved$approved_value[positions],
               tolerance = 1e-10)
  expect_equal(sum(abs(approved$historical_value -
                         approved$approved_value) > 1e-10), 137L)
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  changed <- which(abs(approved$historical_value -
                         approved$approved_value) > 1e-10)[1]
  row <- which(selected & data$caseid == approved$caseid[changed])
  data$swp.t2att3[row] <- approved$historical_value[changed]
  parity <- compare_historical_polardata(data, reference, audit)
  expect_equal(sum(parity$unexplained_differences), 1L)
})

test_that("UKEU-03 protects every approved post EU-relations value", {
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "uk-eu-1995", "approved_values.csv"
  ), show_col_types = FALSE)
  approved <- approved[approved$legacy_field == "ukeu.eurelat2g", ]
  expect_equal(nrow(approved), 238L)
  data <- full_polardata()
  selected <- data$dpnum == 1L
  expect_setequal(data$caseid[selected], approved$caseid)
  positions <- match(data$caseid[selected], approved$caseid)
  expect_equal(data$ukeu.eurelat2g[selected],
               approved$approved_value[positions], tolerance = 1e-10)
  paired <- !is.na(approved$historical_value) &
    !is.na(approved$approved_value)
  expect_equal(sum(paired), 224L)
  expect_equal(sum(abs(approved$historical_value[paired] -
                         approved$approved_value[paired]) > 1e-10), 211L)
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  changed <- which(paired & abs(approved$historical_value -
                                  approved$approved_value) > 1e-10)[1]
  row <- which(selected & data$caseid == approved$caseid[changed])
  data$ukeu.eurelat2g[row] <- approved$historical_value[changed]
  parity <- compare_historical_polardata(data, reference, audit)
  expect_equal(sum(parity$unexplained_differences), 1L)
})

test_that("UKEU-04 protects approved post EU-scope values", {
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "uk-eu-1995", "approved_values.csv"
  ), show_col_types = FALSE)
  approved <- approved[approved$legacy_field == "ukeu.euscope2g", ]
  expect_equal(nrow(approved), 238L)
  data <- full_polardata()
  selected <- data$dpnum == 1L
  expect_setequal(data$caseid[selected], approved$caseid)
  positions <- match(data$caseid[selected], approved$caseid)
  expect_equal(data$ukeu.euscope2g[selected],
               approved$approved_value[positions], tolerance = 1e-10)
  expect_equal(sum(is.na(approved$approved_value)), 14L)
  paired <- !is.na(approved$historical_value) &
    !is.na(approved$approved_value)
  expect_equal(sum(abs(approved$historical_value[paired] -
                         approved$approved_value[paired]) > 1e-10), 209L)
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  row <- which(selected & data$caseid == approved$caseid[
    which(is.na(approved$approved_value))[1]
  ])
  data$ukeu.euscope2g[row] <- approved$historical_value[
    which(is.na(approved$approved_value))[1]
  ]
  parity <- compare_historical_polardata(data, reference, audit)
  expect_equal(sum(parity$unexplained_differences), 1L)
})

test_that("UKM-01 protects every approved post-knowledge value", {
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "uk-monarchy-1996", "approved_values.csv"
  ), show_col_types = FALSE)
  expect_equal(nrow(approved), 20L * 258L)
  data <- full_polardata()
  selected <- data$dpnum == 3L
  expect_equal(sum(selected), 258L)
  for (field in unique(approved$legacy_field)) {
    frozen <- approved[approved$legacy_field == field, ]
    expect_equal(nrow(frozen), 258L)
    expect_setequal(data$caseid[selected], frozen$caseid)
    positions <- match(data$caseid[selected], frozen$caseid)
    expect_equal(data[[field]][selected], frozen$approved_value[positions],
                 tolerance = 1e-10)
  }
  t2 <- approved[approved$legacy_field == "t2know", ]
  expect_equal(sum(abs(t2$historical_value - t2$approved_value) > 1e-10),
               55L)
  joint <- approved[approved$legacy_field == "t1knowcor", ]
  expect_equal(sum(abs(joint$historical_value - joint$approved_value) > 1e-10),
               30L)
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  changed <- which(abs(t2$historical_value - t2$approved_value) > 1e-10)[1]
  row <- which(selected & data$caseid == t2$caseid[changed])
  data$t2know[row] <- t2$historical_value[changed]
  parity <- compare_historical_polardata(data, reference, audit)
  expect_equal(sum(parity$unexplained_differences), 1L)
})

test_that("WTU-03 protects every approved conservation value", {
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "wtu-1996", "approved_values.csv"
  ), show_col_types = FALSE)
  expect_equal(nrow(approved), 230L)
  expect_true(all(approved$legacy_field == "wtu.t2att3"))
  data <- full_polardata()
  selected <- data$dpnum == 19L
  expect_setequal(data$caseid[selected], approved$caseid)
  positions <- match(data$caseid[selected], approved$caseid)
  expect_equal(data$wtu.t2att3[selected], approved$approved_value[positions],
               tolerance = 1e-10)
  expect_equal(sum(abs(approved$historical_value -
                         approved$approved_value) > 1e-10), 179L)
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  changed <- which(abs(approved$historical_value -
                         approved$approved_value) > 1e-10)[1]
  row <- which(selected & data$caseid == approved$caseid[changed])
  data$wtu.t2att3[row] <- approved$historical_value[changed]
  parity <- compare_historical_polardata(data, reference, audit)
  expect_equal(sum(parity$unexplained_differences), 1L)
})

test_that("AUS-04 aligns frozen group gains to respondents", {
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "australia-republic-1999", "approved_values.csv"
  ), show_col_types = FALSE)
  expect_equal(nrow(approved), 694L)
  data <- full_polardata()
  australia <- data[data$pollid == 26, ]
  expect_equal(nrow(australia), 347L)
  for (field in c("grpgain", "loggain")) {
    frozen <- approved[approved$legacy_field == field, ]
    expect_setequal(australia$caseid, frozen$caseid)
    expect_equal(australia[[field]][match(frozen$caseid, australia$caseid)],
                 frozen$approved_value, tolerance = 1e-10)
    paired <- is.finite(frozen$historical_value) &
      is.finite(frozen$approved_value)
    expect_equal(sum(abs(frozen$historical_value[paired] -
                           frozen$approved_value[paired]) > 1e-10), 342L)
    expect_equal(sum(is.na(frozen$historical_value) !=
                       is.na(frozen$approved_value)), 1L)
  }
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  audit <- readr::read_csv(project_path(
    "audit", "polardata_covariances.csv"
  ), show_col_types = FALSE)
  frozen <- approved[approved$legacy_field == "grpgain", ]
  paired <- is.finite(frozen$historical_value) &
    is.finite(frozen$approved_value)
  changed <- which(paired & abs(frozen$historical_value -
                                  frozen$approved_value) > 1e-10)[1]
  row <- which(data$pollid == 26 & data$caseid == frozen$caseid[changed])
  data$grpgain[row] <- frozen$historical_value[changed]
  parity <- compare_historical_polardata(data, reference, audit)
  expect_equal(sum(parity$unexplained_differences), 1L)
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
