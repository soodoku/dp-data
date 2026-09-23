source(file.path(root, "R", "respondents.R"))

respondent_export <- function(name) {
  arrow::read_parquet(project_path("output", "respondent",
    paste0(name, ".parquet")
  ))
}

test_that("every reviewed source row survives with an explicit identity", {
  people <- respondent_export("people")
  contracts <- read_metadata("respondent_sources")
  reviewed <- contracts[contracts$status == "reviewed-source", ]
  expect_equal(nrow(contracts), 21L)
  expect_equal(nrow(reviewed), 16L)
  expect_equal(nrow(people), 24361L)
  expect_false(anyDuplicated(people[c("poll_id", "respondent_id")]) > 0L)
  for (poll in reviewed$poll_id) {
    source <- read_poll_survey(poll)
    rows <- people[people$poll_id == poll, ]
    expect_identical(rows$source_row, source$source_row)
  }
  fallback <- people$identity_basis != "unique-source-id"
  expect_true(all(grepl(":source-row-", people$respondent_id[fallback])))
})

test_that("ambiguous and absent source IDs cannot merge people", {
  survey <- tibble::tibble(source_row = 1:5, id = c(1, 2, 2, NA, 5))
  contract <- tibble::tibble(poll_id = "p", source_id = "s", id_column = "id")
  people <- source_people(survey, contract)
  expect_identical(people$respondent_id,
    c("1", "s:source-row-2", "s:source-row-3", "s:source-row-4", "5")
  )
  expect_identical(source_people(survey[5:1, ], contract), people[5:1, ])
  expect_identical(people$source_respondent_id, c("1", "2", "2", NA, "5"))
})

test_that("sample exclusions do not become invented historical controls", {
  samples <- respondent_export("sample_memberships")
  historical <- samples[samples$sample_id == "historical-polardata", ]
  expect_true(all(is.na(historical$included[
    !historical$poll_id %in% c("uk-health-1998", "uk-eu-1995")
  ])))
  expect_true(all(historical$included[
    historical$poll_id == "uk-health-1998"
  ]))
  expect_true(all(samples$included[samples$sample_id == "reviewed-source"]))
  expect_true(any(!samples$included[samples$sample_id == "knowledge-battery"]))
})

test_that("raw missing codes and literal waves survive the long export", {
  responses <- respondent_export("source_responses")
  health <- responses[responses$poll_id == "uk-health-1998", ]
  expect_true(any(health$response_status == "non-substantive"))
  expect_true(all(!is.na(health$raw_numeric[
    health$response_status == "non-substantive"
  ])))
  missing <- responses$response_status == "system-missing"
  expect_true(all(is.na(responses$raw_numeric[missing])))
  expect_true(all(responses$missing_code[missing] == "system"))
  europe <- responses$poll_id %in% c("europolis-2009", "tomorrows-europe-2007")
  expect_setequal(unique(responses$source_wave[europe]), c("T1", "T3"))
})

test_that("individual measures need no group or stored aggregate fields", {
  survey <- read_poll_survey("uk-health-1998")
  expected <- build_health_individual(survey)
  inputs <- read_metadata("measure_inputs")
  inputs <- inputs[inputs$poll_id == "uk-health-1998", ]
  fields <- unique(c("serial_m", "serial_a", inputs$source_column))
  bare <- survey[fields]
  expect_identical(build_health_individual(bare), expected)
  expect_identical(build_health_individual(bare[230:1, ]), expected[230:1, ])
  expect_identical(build_health_individual(bare[c(1L, 7L, 80L), ]),
    expected[c(1L, 7L, 80L), ]
  )
  expect_identical(build_health_individual(bare[1L, ]), expected[1L, ])
})

test_that("respondent contracts have complete dependencies and valid keys", {
  definitions <- read_metadata("measure_definitions")
  inputs <- read_metadata("measure_inputs")
  expect_equal(nrow(definitions), 78L)
  expect_false(anyDuplicated(definitions[c("poll_id", "definition_id")]) > 0L)
  expect_setequal(inputs$definition_id, definitions$definition_id[
    definitions$scoring_rule != "historical-constant-missing"
  ])
  expect_true(all(nzchar(definitions$scoring_rule)))
  expect_true(all(nzchar(definitions$denominator_policy)))
  tables <- lapply(c("people", "sample_memberships", "source_responses",
                     "respondent_measures", "respondent_memberships"
                   ), respondent_export)
  names(tables) <- c("people", "sample_memberships", "source_responses",
    "respondent_measures", "respondent_memberships"
  )
  expect_silent(validate_respondent_tables(tables))
  broken <- tables
  broken$respondent_measures$respondent_id[1] <- "unknown-person"
  expect_error(validate_respondent_tables(broken))
  broken <- tables
  broken$respondent_measures$definition_id[1] <- "unknown-definition"
  expect_error(validate_respondent_tables(broken))
  broken <- tables
  broken$respondent_measures$n_observed_fields[1] <- 100L
  expect_error(validate_respondent_tables(broken))
})

test_that("the legacy inventory accounts for all fields and poll targets", {
  fields <- read_metadata("polardata_fields")
  historical <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  expect_setequal(fields$legacy_field, names(historical))
  expect_equal(nrow(fields), ncol(historical))
  expect_false(anyNA(fields$layer))
  targets <- read_metadata("polardata_targets")
  expect_equal(length(unique(targets$poll_id)), 21L)
  expect_true(all(targets$legacy_field %in%
                    fields$legacy_field[fields$layer == "respondent"]))
  definitions <- read_metadata("measure_definitions")
  implemented <- targets[targets$status == "implemented", ]
  expect_true(all(implemented$canonical_definition %in%
                    definitions$definition_id))
  expect_true(all(nzchar(targets$blocker[targets$status != "implemented"])))
})


test_that("UK EU keeps 238 historical attendees and 224 knowledge cases", {
  survey <- read_poll_survey("uk-eu-1995")
  samples <- respondent_export("sample_memberships")
  samples <- samples[samples$poll_id == "uk-eu-1995", ]
  expect_equal(sum(samples$included[
    samples$sample_id == "historical-polardata"
  ]), 238L)
  expect_equal(sum(samples$included[
    samples$sample_id == "knowledge-battery"
  ]), 224L)
  expected <- build_eu_individual(survey)
  inputs <- read_metadata("measure_inputs")
  fields <- unique(c("caseid", inputs$source_column[
    inputs$poll_id == "uk-eu-1995"
  ]))
  expect_identical(build_eu_individual(survey[fields]), expected)
  expect_identical(build_eu_individual(survey[1L, fields]), expected[1L, ])
  expect_identical(
    build_eu_individual(survey[900:1, fields]), expected[900:1, ]
  )
  survey$releu2 <- as.numeric(survey$releu2)
  survey$releu2[1] <- 999
  expect_error(build_eu_individual(survey), "Unreviewed")
})

source(file.path(root, "R", "respondent_parity.R"))

test_that("implemented definitions match historical values by IDs", {
  measures <- respondent_export("respondent_measures")
  people <- respondent_export("people")
  samples <- respondent_export("sample_memberships")
  benchmark <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  compare <- function(values, persons = people, sample = samples) {
    compare_respondent_measures(values, persons, sample, benchmark)
  }
  parity <- compare(measures)
  expect_equal(nrow(parity), 84L)
  expect_true(all(parity$missingness_differences == 0L))
  expect_true(all(parity$value_differences == 0L))
  expect_identical(compare(measures[rev(seq_len(nrow(measures))), ]), parity)
  index <- which(measures$definition_id == "female@historical-v1" &
                   measures$poll_id == "uk-health-1998")[1]
  changed <- measures
  changed$value_numeric[index] <- 3
  expect_gt(sum(compare(changed)$value_differences), 0)
  changed$value_numeric[index] <- NA_real_
  expect_gt(sum(compare(changed)$missingness_differences), 0)
  expect_error(compare(measures[-index, ]))
  person <- which(people$poll_id == "uk-health-1998")[1]
  expect_error(compare(measures, people[-person, ]))
})


test_that("dictionary missing ranges survive sample expansion", {
  responses <- respondent_export("source_responses")
  eu_age <- responses[
    responses$poll_id == "uk-eu-1995" & responses$source_column == "age",
  ]
  missing <- !is.na(eu_age$raw_numeric) & eu_age$raw_numeric %in% 97:99
  expect_equal(sum(missing), 5L)
  expect_true(all(eu_age$response_status[missing] == "non-substantive"))
  expect_identical(sort(eu_age$raw_numeric[missing]), c(97, 97, 97, 97, 99))
  australia <- responses[responses$poll_id == "australia-republic-1999", ]
  missing <- !is.na(australia$raw_numeric) &
    australia$raw_numeric >= 94 & australia$raw_numeric <= 103
  expect_gt(sum(missing), 0L)
  expect_true(all(australia$response_status[missing] == "non-substantive"))
})
