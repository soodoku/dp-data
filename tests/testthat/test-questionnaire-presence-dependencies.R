presence_dependency_builders <- list(
  "cpl-1996" = function(survey) build_utility_individual(survey, "cpl-1996"),
  "san-mateo-2008" = build_san_mateo_individual,
  "uk-eu-1995" = build_eu_individual,
  "uk-health-1998" = build_health_individual,
  "uk-crime-1994" = build_crime_individual,
  "uk-general-election-1997" = build_election_individual,
  "europolis-2009" = build_europolis_individual,
  "tomorrows-europe-2007" = build_tomorrow_individual,
  "btp-presidential-primaries-2004" = build_btp_primaries_individual,
  "nic2-2003" = build_nic2_individual,
  "nic-1996" = build_nic_individual,
  "zeguo-2005" = build_zeguo_individual
)

test_that("declared dependencies cover each reviewed source form", {
  definitions <- read_metadata("measure_definitions")
  definitions <- definitions[
    definitions$poll_id %in% names(presence_dependency_builders),
  ]
  dependencies <- questionnaire_dependencies(definitions)
  expect_false(anyNA(dependencies))
  expect_equal(anyDuplicated(dependencies), 0L)
  inputs <- read_metadata("measure_inputs")
  undeclared <- dplyr::anti_join(dependencies, inputs,
    by = c("poll_id", "definition_id", "source_column")
  )
  expect_equal(nrow(undeclared), 0L)
  expect_false(any(dependencies$source_column == "source_row"))
  for (poll in names(presence_dependency_builders)) {
    survey <- read_poll_survey(poll)
    fields <- dependencies$source_column[dependencies$poll_id == poll]
    expect_true(all(fields %in% names(survey)), info = poll)
  }
})

test_that("declared raw inputs reproduce full builders in arbitrary order", {
  inputs <- read_metadata("measure_inputs")
  for (poll in names(presence_dependency_builders)) {
    survey <- read_poll_survey(poll)
    build <- presence_dependency_builders[[poll]]
    expected <- build(survey)
    fields <- unique(inputs$source_column[inputs$poll_id == poll])
    identity <- switch(poll,
      "uk-health-1998" = c("serial_a", "serial_m"),
      "uk-eu-1995" = "caseid",
      "zeguo-2005" = "p", character()
    )
    raw <- survey[rev(union(fields, identity))]
    expect_false("source_row" %in% names(raw))
    expect_identical(build(raw), expected, info = poll)
    order <- rev(seq_len(nrow(raw)))
    expect_identical(build(raw[order, ]), expected[order, ], info = poll)
    expect_identical(build(raw[1L, ]), expected[1L, ], info = poll)
    selected <- unique(c(nrow(raw), 1L, 7L))
    expect_identical(build(raw[selected, ]), expected[selected, ], info = poll)
  }
})

test_that("local row indices never relax supplied source identity checks", {
  survey <- read_poll_survey("uk-health-1998")
  fields <- read_metadata("measure_inputs") |>
    dplyr::filter(poll_id == "uk-health-1998") |>
    dplyr::pull(source_column) |>
    unique()
  rows <- which(as.numeric(survey$serial_m) %in% c(3809, 4307))
  raw <- survey[rows, rev(fields)]
  expect_identical(historical_health_items(raw, 2L),
    historical_health_items(survey, 2L)[rows, , drop = FALSE]
  )
  raw$source_row <- c(1L, 1L)
  expect_error(historical_health_items(raw, 2L))
  raw$source_row <- c(1L, NA_integer_)
  expect_error(historical_health_items(raw, 2L))
  raw$source_row <- c(136L, 102L)
  raw$mtneed2[1L] <- 1
  expect_error(historical_health_items(raw, 2L))
  raw$mtneed2 <- NULL
  expect_error(historical_health_items(raw, 2L),
    "Missing questionnaire-presence fields: mtneed2"
  )
  expect_error(questionnaire_field_block(survey, "mtneed2", "dopint"))
})

test_that("presence fields retain the reviewed wave semantics", {
  te <- questionnaire_form_contract("tomorrows-europe-2007")
  expect_equal(te$original_wave, c("T2", "T3"))
  expect_equal(te$wave, c("arrival", "t2"))
  expect_equal(lengths(te$fields), c(142L, 185L))
  nic <- questionnaire_form_contract("nic-1996")
  expect_equal(nic$original_wave, c("T1", "T2"))
  expect_equal(lengths(nic$fields), c(145L, 99L))
  expect_false("PARTYST1" %in% nic$fields[[1L]])
  health <- questionnaire_form_contract("uk-health-1998")
  expect_equal(length(health$fields[[1L]]), 75L)
  expect_equal(health$auxiliary[[1L]], "manwkend")
})
