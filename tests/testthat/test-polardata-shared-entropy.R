source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "respondent_parity.R"))
source(file.path(root, "R", "polardata_rebuild.R"))

test_that("shared entropy freezes all people against historical values", {
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "shared-entropy", "approved_values.csv"
  ), show_col_types = FALSE)
  data <- arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  ))
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  contracts <- read_metadata("respondent_sources")
  expect_equal(nrow(approved), 5869L)
  expect_setequal(unique(approved$poll_id), contracts$poll_id)
  expect_true(all(approved$legacy_field == "entropy"))
  expect_false(anyDuplicated(approved[c("poll_id", "caseid")]) > 0L)
  expect_equal(sum(!approved$historical_present), 2L)
  expect_true(all(is.na(approved$historical_value[
    !approved$historical_present
  ])))
  expect_equal(sum(is.na(approved$caseid)), 1L)
  for (i in seq_len(nrow(contracts))) {
    poll <- contracts$poll_id[[i]]
    actual <- data[data$dpnum == contracts$dpnum[[i]], ]
    frozen <- approved[approved$poll_id == poll, ]
    original <- historical_reference_people(
      reference[reference$dpnum == contracts$dpnum[[i]], ], poll
    )
    position <- match(frozen$caseid, original$caseid)
    expect_identical(!is.na(position), frozen$historical_present)
    expect_equal(frozen$historical_value, original$entropy[position],
                 tolerance = 1e-10)
    expected <- approved_reference_values(
      poll, "entropy", original$caseid, original$entropy
    )
    expect_equal(actual$entropy[match(original$caseid, actual$caseid)],
                 expected, tolerance = 1e-10)
    expect_setequal(actual$caseid, frozen$caseid)
    expect_equal(actual$entropy[match(frozen$caseid, actual$caseid)],
                 frozen$approved_value, tolerance = 1e-10)
  }
  changed <- abs(approved$approved_value - approved$previous_value) > 1e-10
  expect_equal(sum(changed), 3436L)
})

test_that("entropy coverage retains summary populations and components", {
  groups <- readr::read_csv(project_path(
    "audit", "corrections", "shared-entropy", "group_components.csv"
  ), show_col_types = FALSE)
  expect_equal(nrow(groups), 397L)
  expect_false(anyDuplicated(groups[c("poll_id", "pollgroup")]) > 0L)
  expect_equal(sum(groups$changed), 245L)
  expect_equal(sum(groups$exported_people[groups$changed]), 3436L)
  expect_equal(sum(groups$available_components == 3), 363L)
  expect_equal(sum(groups$available_components == 2), 34L)
  components <- as.matrix(groups[c(
    "corrected_gender_entropy", "corrected_minority_entropy",
    "corrected_education_entropy"
  )])
  expect_equal(rowSums(!is.na(components)), groups$available_components)
  expect_equal(rowSums(components, na.rm = TRUE), groups$corrected_entropy,
               tolerance = 1e-10)
  counts <- as.matrix(groups[c(
    "gender_observed", "minority_observed", "education_observed"
  )])
  expect_true(all(counts >= 0 & counts <= groups$summary_people))
  election <- groups[groups$poll_id == "btp-general-election-2004", ]
  expect_equal(sum(election$summary_people), 299L)
  expect_equal(sum(election$exported_people), 248L)
  expect_equal(sum(election$changed), 4L)
  expect_setequal(election$pollgroup[election$changed],
                  c(9403, 9410, 9413, 9415))
  europolis <- groups[groups$poll_id == "europolis-2009", ]
  expect_true(all(europolis$changed))
  expect_equal(sum(europolis$exported_people), 348L)
  expect_gt(max(europolis$education_categories), 4L)
  expect_equal(max(europolis$corrected_education_entropy), 3.5)
  expect_gt(max(europolis$corrected_entropy), 4)
})

test_that("shared entropy approval rejects altered historical inputs", {
  frozen <- readr::read_csv(project_path(
    "audit", "corrections", "shared-entropy", "approved_values.csv"
  ), show_col_types = FALSE)
  frozen <- frozen[frozen$poll_id == "uk-eu-1995", ]
  expect_equal(approved_reference_values(
    "uk-eu-1995", "entropy", frozen$caseid, frozen$historical_value
  ), frozen$approved_value)
  altered <- frozen$historical_value
  altered[[1]] <- altered[[1]] + .01
  expect_error(approved_reference_values(
    "uk-eu-1995", "entropy", frozen$caseid, altered
  ))
  expect_error(approved_reference_values(
    "uk-eu-1995", "entropy", frozen$caseid, frozen$approved_value
  ))
  expect_error(approved_reference_values(
    "uk-eu-1995", "entropy", frozen$caseid[-1], frozen$historical_value[-1]
  ))
})
