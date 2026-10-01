test_that("TE nonanswers and literal waves survive source transport", {
  contract <- read_metadata("respondent_sources")
  built <- build_poll_respondents(contract[
    contract$poll_id == "tomorrows-europe-2007",
  ])
  survey <- read_poll_survey("tomorrows-europe-2007")
  inputs <- read_metadata("measure_inputs")
  inputs <- inputs[inputs$poll_id == "tomorrows-europe-2007", ]
  definitions <- read_metadata("measure_definitions")
  definitions <- definitions[
    definitions$poll_id == "tomorrows-europe-2007",
  ]
  attitude_names <- unlist(lapply(1:3, function(wave) {
    paste0(names(tomorrows_europe_attitudes(survey, wave)), "_t", wave)
  }))
  attitude_definitions <- definitions$definition_id[
    definitions$measure_id %in% attitude_names
  ]
  fields <- unique(inputs$source_column[
    inputs$definition_id %in% attitude_definitions
  ])
  expect_length(attitude_names, 31L)
  expect_length(fields, 85L)
  answers <- built$source_responses
  expected_answered <- list()
  baseline_five <- c("q7c_1", paste0("q11", letters[1:3], "_1"), "q13b_1")
  post_five <- c(
    paste0("5", letters[1:4]), paste0("7", c("a", "c", "d")),
    paste0("11", letters[1:3]), paste0("16", c("a", "b", "c", "f", "j"))
  )
  for (field in fields) {
    value <- as.numeric(survey[[field]])
    baseline <- !startsWith(field, "t")
    five <- field %in% baseline_five || sub("^t[23]q", "", field) %in% post_five
    minimum <- if (baseline || five) 1 else 0
    maximum <- if (five) 5 else if (baseline) 11 else 10
    valid <- !is.na(value) & value >= minimum & value <= maximum
    expected_answered[[field]] <- valid
    observed <- answers[answers$source_column == field, ]
    expect_identical(observed$raw_numeric, value)
    expect_identical(observed$response_status == "answered", valid)
    expect_true(all(observed$response_status[is.na(value)] == "system-missing"))
    nonanswer <- !is.na(value) & !valid
    expect_true(all(observed$response_status[nonanswer] == "non-substantive"))
    expect_identical(
      observed$missing_code[nonanswer], as.character(value[nonanswer])
    )
    wave <- if (baseline) "T1" else paste0("T", substr(field, 2L, 2L))
    expect_true(all(observed$source_wave == wave))
  }
  for (definition in attitude_definitions) {
    columns <- inputs$source_column[inputs$definition_id == definition]
    expected <- rowSums(as.data.frame(expected_answered[columns]))
    values <- built$respondent_measures[
      built$respondent_measures$definition_id == definition,
    ]
    expect_identical(values$n_observed_fields, as.integer(expected))
  }
  arrival_fields <- c(paste0("t2q", 19:27), "t2q36a", "t2q36b")
  arrival <- answers[answers$source_column %in% arrival_fields, ]
  code_99 <- !is.na(arrival$raw_numeric) & arrival$raw_numeric == 99
  expect_equal(sum(code_99), 844L)
  expect_true(all(arrival$response_status[code_99] == "non-substantive"))
  expect_true(all(arrival$source_wave == "T2"))
  for (field in arrival_fields) {
    value <- as.numeric(survey[[field]])
    placement <- grepl("36[ab]$", field)
    minimum <- if (placement) 0 else 1
    maximum <- if (placement) {
      10
    } else if (field %in% paste0("t2q", 24:26)) {
      5
    } else {
      4
    }
    valid <- !is.na(value) & value >= minimum & value <= maximum
    observed <- arrival[arrival$source_column == field, ]
    expect_identical(observed$response_status == "answered", valid)
  }
  expect_identical(source_wave_label("tomorrows-europe-2007", 2L), "T3")
  expect_true(all(is.na(answers$source_wave[answers$source_column == "age"])))
})
