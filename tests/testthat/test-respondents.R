source(file.path(root, "R", "respondents.R"))

respondent_export <- function(name) {
  arrow::read_parquet(project_path(
    "output", "respondent",
    paste0(name, ".parquet")
  ))
}

test_that("every reviewed source row survives with an explicit identity", {
  people <- respondent_export("people")
  contracts <- read_metadata("respondent_sources")
  reviewed <- contracts[contracts$status == "reviewed-source", ]
  expect_equal(nrow(contracts), 21L)
  expect_equal(nrow(reviewed), 21L)
  expect_setequal(unique(people$poll_id), reviewed$poll_id)
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
  expect_identical(
    people$respondent_id,
    c("1", "s:source-row-2", "s:source-row-3", "s:source-row-4", "5")
  )
  expect_identical(source_people(survey[5:1, ], contract), people[5:1, ])
  expect_identical(people$source_respondent_id, c("1", "2", "2", NA, "5"))
})

test_that("sample exclusions do not become invented historical controls", {
  samples <- respondent_export("sample_memberships")
  historical <- samples[samples$sample_id == "historical-polardata", ]
  expect_setequal(
    unique(historical$poll_id),
    read_metadata("respondent_sources")$poll_id
  )
  expect_true(all(!is.na(historical$included)))
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
  expect_setequal(
    unique(responses$source_wave[europe]),
    c("T1", "T3", NA_character_)
  )
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
  expect_identical(
    build_health_individual(bare[c(1L, 7L, 80L), ]),
    expected[c(1L, 7L, 80L), ]
  )
  expect_identical(build_health_individual(bare[1L, ]), expected[1L, ])
})

test_that("respondent contracts have complete dependencies and valid keys", {
  definitions <- read_metadata("measure_definitions")
  inputs <- read_metadata("measure_inputs")
  expect_setequal(
    unique(definitions$poll_id),
    read_metadata("respondent_sources")$poll_id
  )
  expect_false(anyDuplicated(definitions[c("poll_id", "definition_id")]) > 0L)
  expect_setequal(inputs$definition_id, definitions$definition_id[
    definitions$scoring_rule != "historical-constant-missing"
  ])
  expect_true(all(nzchar(definitions$scoring_rule)))
  expect_true(all(nzchar(definitions$denominator_policy)))
  tables <- lapply(c(
    "people", "sample_memberships", "source_responses",
    "respondent_measures", "respondent_memberships"
  ), respondent_export)
  names(tables) <- c(
    "people", "sample_memberships", "source_responses",
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

test_that("definitions match historical or approved values by IDs", {
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
  expect_equal(nrow(parity), sum(
    read_metadata("polardata_targets")$status == "implemented"
  ))
  expect_equal(sum(parity$missingness_differences[
    parity$poll_id == "tomorrows-europe-2007"
  ]), 15L)
  expect_equal(sum(parity$missingness_differences[
    parity$poll_id != "tomorrows-europe-2007"
  ]), 1L)
  expect_equal(sum(parity$value_differences[
    parity$poll_id == "uk-crime-1994"
  ]), 141L)
  expect_true(all(parity$unexplained_differences == 0L))
  expect_identical(compare(measures[rev(seq_len(nrow(measures))), ]), parity)
  index <- which(measures$definition_id == "female@historical-v1" &
                   measures$poll_id == "uk-health-1998")[1]
  changed <- measures
  changed$value_numeric[index] <- 3
  expect_equal(sum(compare(changed)$unexplained_differences), 1L)
  changed$value_numeric[index] <- NA_real_
  expect_equal(sum(compare(changed)$unexplained_differences), 1L)
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

test_that("Britain recodes depend only on declared raw responses", {
  builders <- list(
    "uk-monarchy-1996" = build_monarchy_individual,
    "uk-general-election-1997" = build_election_individual
  )
  inputs <- read_metadata("measure_inputs")
  for (poll in names(builders)) {
    survey <- read_poll_survey(poll)
    build <- builders[[poll]]
    expected <- build(survey)
    fields <- unique(inputs$source_column[inputs$poll_id == poll])
    raw <- survey[fields]
    expect_true(all(grepl("^[a-z][a-z0-9_]*$", names(expected))))
    expect_identical(build(raw), expected)
    expect_identical(build(raw[1L, ]), expected[1L, ])
    order <- rev(seq_len(nrow(raw)))
    expect_identical(build(raw[order, ]), expected[order, ])
    expect_identical(build(raw[c(1L, 7L, 80L), ]), expected[c(1L, 7L, 80L), ])
    expect_error(build(raw[-1]), "Missing source field")
    raw[[1]] <- as.numeric(raw[[1]])
    raw[[1]][1] <- 999
    expect_error(build(raw), "Unreviewed source codes")
  }
})

test_that("historical aliases do not overwrite source identity", {
  people <- respondent_export("people")
  monarchy <- people[people$poll_id == "uk-monarchy-1996", ]
  expect_true(all(is.na(monarchy$source_respondent_id)))
  expect_identical(
    monarchy$historical_respondent_id,
    as.character(1000 + monarchy$source_row)
  )
  contracts <- read_metadata("respondent_sources")
  contract <- contracts[contracts$poll_id == "uk-monarchy-1996", ]
  survey <- read_poll_survey("uk-monarchy-1996")
  order <- rev(seq_len(nrow(survey)))
  expect_identical(source_people(survey[order, ], contract), monarchy[order, ])
  measures <- respondent_export("respondent_measures")
  samples <- respondent_export("sample_memberships")
  benchmark <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  selected <- samples$respondent_id[
    samples$poll_id == "uk-monarchy-1996" &
      samples$sample_id == "historical-polardata" & samples$included
  ]
  rows <- which(
    people$poll_id == "uk-monarchy-1996" & people$respondent_id %in% selected
  )
  people$historical_respondent_id[rows[1]] <-
    people$historical_respondent_id[rows[2]]
  expect_error(compare_respondent_measures(
    measures, people, samples, benchmark
  ))
})

test_that("preserved cross-wave dependencies remain explicit", {
  monarchy <- read_poll_survey("uk-monarchy-1996")
  before <- build_monarchy_individual(monarchy)
  monarchy$R5C <- rep(1, nrow(monarchy))
  expect_identical(build_monarchy_individual(monarchy), before)
  monarchy$Q5C <- ifelse(monarchy$Q5C == 1, 2, 1)
  after <- build_monarchy_individual(monarchy)
  expect_true(all(before$knowledge_t2 != after$knowledge_t2))
  election <- read_poll_survey("uk-general-election-1997")
  before <- build_election_individual(election)
  election$taxr2 <- rep(1, nrow(election))
  expect_identical(build_election_individual(election), before)
  election$taxret2 <- rep(1, nrow(election))
  after <- build_election_individual(election)
  expect_true(all(after$tax_t2 == 0))
  expect_true(any(before$tax_t2 != after$tax_t2, na.rm = TRUE))
})

test_that("utility calibration is independent of the supplied sample", {
  inputs <- read_metadata("measure_inputs")
  for (poll in c("cpl-1996", "wtu-1996", "swepco-1996")) {
    survey <- read_poll_survey(poll)
    expected <- build_utility_individual(survey, poll)
    fields <- unique(inputs$source_column[inputs$poll_id == poll])
    raw <- survey[fields]
    expect_true(all(grepl("^[a-z][a-z0-9_]*$", names(expected))))
    expect_identical(build_utility_individual(raw, poll), expected)
    expect_identical(build_utility_individual(raw[1L, ], poll), expected[1L, ])
    order <- rev(seq_len(nrow(raw)))
    expect_identical(
      build_utility_individual(raw[order, ], poll),
      expected[order, ]
    )
    selected <- c(1L, 7L, 80L)
    expect_identical(
      build_utility_individual(raw[selected, ], poll),
      expected[selected, ]
    )
    expect_error(
      build_utility_individual(raw[-1], poll), "Missing source field"
    )
    raw[[1]] <- as.numeric(raw[[1]])
    raw[[1]][1] <- 1001
    expect_error(build_utility_individual(raw, poll), "Unreviewed source codes")
  }
})

test_that("utility extremity retains its historical calculation stage", {
  for (poll in c("wtu-1996", "swepco-1996")) {
    survey <- read_poll_survey(poll)
    before <- build_utility_individual(survey, poll)
    survey$ADDFAC2 <- rep(0, nrow(survey))
    survey$LOWINC1 <- rep(0, nrow(survey))
    survey$POOR1 <- rep(1, nrow(survey))
    expect_identical(build_utility_individual(survey, poll), before)
    survey$COMPET1 <- ifelse(survey$COMPET1 == 1, 5, 1)
    after <- build_utility_individual(survey, poll)
    attitude_fields <- grep("_t[12]$", names(before), value = TRUE)
    expect_identical(after[attitude_fields], before[attitude_fields])
    expect_true(any(after$attitude_extremity != before$attitude_extremity,
      na.rm = TRUE
    ))
  }
})

test_that("UK Crime uses raw fields and preserves row order", {
  survey <- read_poll_survey("uk-crime-1994")
  fields <- read_metadata("measure_inputs") |>
    dplyr::filter(.data$poll_id == "uk-crime-1994") |>
    dplyr::pull("source_column") |>
    unique()
  raw <- survey |> dplyr::select(dplyr::all_of(fields))
  values <- build_crime_individual(raw)
  expect_equal(values, build_crime_individual(survey))
  expect_equal(
    build_crime_individual(raw[c(12, 1, 800), ]),
    values[c(12, 1, 800), ]
  )
  expect_equal(build_crime_individual(raw[12, ]), values[12, ])
  raw$morecop1[1] <- 99
  expect_error(build_crime_individual(raw), "Unreviewed source codes")
  expect_error(
    build_crime_individual(survey[, names(survey) != "kw11"]),
    "Missing source field"
  )
})

test_that("UK Crime root causes uses post items without baseline reuse", {
  survey <- read_poll_survey("uk-crime-1994")[1, ]
  survey$morecop1 <- 1
  survey$timchld2 <- 5
  survey$violtv2 <- 5
  survey$schdisc2 <- 5
  original <- build_crime_individual(survey)
  expect_equal(original$root_causes_t2, 1)
  survey$timchld2 <- 1
  expect_equal(build_crime_individual(survey)$root_causes_t2, 2 / 3)
  survey$morecop1 <- 5
  expect_equal(build_crime_individual(survey)$root_causes_t2, 2 / 3)
  survey$timchld2 <- NA_real_
  survey$violtv2 <- NA_real_
  survey$schdisc2 <- NA_real_
  expect_true(is.na(build_crime_individual(survey)$root_causes_t2))
  expect_true(is.na(original$knowledge_issue_t1))
  expect_true(is.na(original$knowledge_issue_joint))
})

test_that("UK Crime keeps the ungrouped attendee outside its historical view", {
  survey <- read_poll_survey("uk-crime-1994")
  contract <- read_metadata("respondent_sources") |>
    dplyr::filter(.data$poll_id == "uk-crime-1994")
  people <- source_people(survey, contract)
  expect_equal(
    people$historical_respondent_id,
    as.character(10000 + survey$source_row)
  )
  samples <- respondent_export("sample_memberships") |>
    dplyr::filter(
      .data$poll_id == "uk-crime-1994",
      .data$sample_id == "historical-polardata"
    )
  expect_equal(sum(as.numeric(survey$part) == 1), 300L)
  expect_equal(sum(samples$included), 299L)
  expect_equal(samples$included, survey$part == 1 & !is.na(survey$group))
})


test_that("Primaries duplicate rows must agree", {
  source(project_path("R", "respondent_parity.R"))
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  primary <- reference[reference$dpnum == 16, ]
  expect_equal(nrow(historical_reference_people(
    primary, "btp-presidential-primaries-2004"
  )), 217L)
  primary$t1know[[1]] <- primary$t1know[[1]] + .1
  expect_error(historical_reference_people(
    primary, "btp-presidential-primaries-2004"
  ))
  expect_error(historical_reference_people(
    reference[reference$dpnum == 16, ], "uk-health-1998"
  ))
})


test_that("UK Crime nonparticipants have no invented post root-causes scores", {
  survey <- read_poll_survey("uk-crime-1994")
  values <- build_crime_individual(survey)$root_causes_t2
  expect_length(values, 869L)
  expect_equal(sum(!is.na(values)), 299L)
  expect_true(all(is.na(values[which(survey$part != 1)])))
})

test_that("UKGE-03 scores the post Labour wage placement from its own wave", {
  survey <- read_poll_survey("uk-general-election-1997")[1, ]
  survey$wagel1 <- 1
  survey$wagel2 <- 7
  expect_equal(unname(election_knowledge_items(survey, 2L)[, "wage_l"]), 1)
  survey$wagel1 <- 7
  expect_equal(unname(election_knowledge_items(survey, 2L)[, "wage_l"]), 1)
  survey$wagel2 <- 1
  expect_equal(unname(election_knowledge_items(survey, 2L)[, "wage_l"]), 0)
  survey$wagel2 <- NA_real_
  expect_equal(unname(election_knowledge_items(survey, 2L)[, "wage_l"]), 0)
  expect_equal(unname(election_knowledge_items(survey, 1L)[, "wage_l"]), 1)
})

test_that("UKGE-03 agrees with deposited post correctness for attendees", {
  survey <- read_poll_survey("uk-general-election-1997")
  selected <- survey$filter == 1
  items <- election_knowledge_items(survey, 2L)
  expect_equal(sum(selected), 275L)
  expect_equal(items[selected, "wage_l"], as.numeric(survey$wgel2cor[selected]))
  scores <- build_election_individual(survey)
  expect_true(all(scores$knowledge_t2[!selected] == 0))
})
