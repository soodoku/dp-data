source(file.path(root, "R", "respondents.R"))

test_that("CPL codebook nonanswers do not count as observed attitude inputs", {
  contract <- read_metadata("respondent_sources")
  built <- build_poll_respondents(contract[contract$poll_id == "cpl-1996", ])
  fields <- grep(paste0(
    "^(resch|fedrch|addfac|reduce|lowinc|poor|renew|wind|",
    "fuels|buypwr|compet)[12]$"
  ), built$source_responses$source_column, value = TRUE)
  answers <- built$source_responses[
    built$source_responses$source_column %in% fields,
  ]
  dk <- answers[!is.na(answers$raw_numeric) & answers$raw_numeric == 99, ]
  expect_equal(nrow(dk), 1016L)
  original_fields <- dk[dk$source_column != "compet2", ]
  expect_equal(nrow(original_fields), 1001L)
  expect_equal(dplyr::n_distinct(original_fields$respondent_id), 498L)
  expect_equal(sum(dk$source_column == "compet2"), 15L)
  expect_equal(dplyr::n_distinct(dk$respondent_id), 505L)
  expect_true(all(dk$response_status == "non-substantive"))
  expect_true(all(dk$missing_code == "99"))
  substantive <- answers[
    !is.na(answers$raw_numeric) & answers$raw_numeric != 99,
  ]
  expect_true(all(substantive$response_status == "answered"))
  expect_true(all(is.na(substantive$missing_code)))
  expect_true(any(substantive$raw_numeric == 0))
  expect_true(any(substantive$raw_numeric == 10))

  survey <- read_poll_survey("cpl-1996")
  inputs <- read_metadata("measure_inputs")
  inputs <- inputs[inputs$poll_id == "cpl-1996", ]
  definitions <- unique(inputs$definition_id[inputs$source_column %in% fields])
  for (definition in definitions) {
    columns <- inputs$source_column[inputs$definition_id == definition]
    rules <- read_metadata("source_nonanswer_rules")
    rules <- rules[rules$poll_id == "cpl-1996", ]
    observed <- purrr::map(columns, function(field) {
      value <- as.numeric(survey[[field]])
      codes <- as.numeric(rules$source_value[rules$source_column == field])
      !is.na(value) & !value %in% codes
    })
    expected <- rowSums(do.call(cbind, observed))
    values <- built$respondent_measures[
      built$respondent_measures$definition_id == definition,
    ]
    expect_equal(values$n_source_fields, rep(length(columns), nrow(survey)))
    expect_equal(values$n_observed_fields, expected)
  }
})


test_that("CPL reviewed nonanswers reproduce the primary codebook tables", {
  survey <- read_poll_survey("cpl-1996")
  contracts <- read_metadata("respondent_sources")
  built <- build_poll_respondents(contracts[contracts$poll_id == "cpl-1996", ])
  rules <- read_metadata("source_nonanswer_rules")
  rules <- rules[rules$poll_id == "cpl-1996", ]
  expect_equal(nrow(rules), 152L)
  items <- read_metadata("knowledge_items")
  items <- items[items$poll_id == "cpl-1996", ]
  all_responses <- source_response_rows(survey, built$people,
    tibble::tibble(source_column = unique(rules$source_column)), items
  )
  text <- readLines(project_path("data", "cpl-1996", "codebook.txt"))
  header_pattern <- paste0("^\\s*([A-Z][A-Z0-9_]*)\\s+Frequency",
    "\\s+Percent\\s+Frequency\\s+Percent\\s*$"
  )
  headers <- grep(header_pattern, text)
  for (i in seq_len(nrow(rules))) {
    rule <- rules[i, ]
    line <- as.integer(sub(".*:L([0-9]+);.*", "\\1", rule$evidence))
    header <- max(headers[headers < line])
    field <- tolower(sub("^\\s*([A-Z][A-Z0-9_]*).*$", "\\1", text[header]))
    expect_equal(field, rule$source_column)
    pattern <- paste0("^\\s*([0-9]+)\\s+(.+?)\\s{2,}([0-9]+)",
      "\\s+[0-9.]+\\s+[0-9]+\\s+[0-9.]+\\s*$"
    )
    entry <- regmatches(text[line], regexec(pattern, text[line]))[[1]]
    expect_length(entry, 4L)
    expect_equal(as.numeric(entry[2]), as.numeric(rule$source_value))
    label <- tolower(entry[3])
    allowed_labels <- c("dk", "refused", "na", "missing/dk", "missing/ref")
    expect_true(label %in% allowed_labels)
    expected_reason <- if (label == "dk") "dk" else
      if (label == "refused") "refused" else "nonanswer"
    expect_equal(rule$reason, expected_reason)
    rows <- which(as.numeric(survey[[field]]) == as.numeric(rule$source_value))
    printed_count <- as.integer(entry[4])
    if (field == "im1cpl2") {
      expect_equal(printed_count,
        if (as.numeric(rule$source_value) == 98) 3L else 1L
      )
      expect_equal(length(rows),
        if (as.numeric(rule$source_value) == 98) 0L else 3L
      )
    } else {
      expect_equal(length(rows), printed_count, info = field)
    }
    expected_ids <- built$people$respondent_id[
      match(survey$source_row[rows], built$people$source_row)
    ]
    actual <- all_responses[
                            all_responses$source_column == field &
                              all_responses$raw_numeric %in%
                                as.numeric(rule$source_value), ]
    expect_setequal(actual$respondent_id, expected_ids)
    expect_true(all(actual$response_status == "non-substantive"))
    expect_true(all(actual$missing_code == as.character(rule$source_value)))
    expect_equal(actual$raw_numeric,
      rep(as.numeric(rule$source_value), length(rows))
    )
  }
  raw <- tibble::tibble(readmat = 99, paywnd2 = 99, airpol2 = 99,
    knowa1 = 0
  )
  people <- tibble::tibble(poll_id = "cpl-1996", respondent_id = "fixture")
  inputs <- tibble::tibble(source_column = names(raw))
  items <- read_metadata("knowledge_items")
  items <- items[items$poll_id == "cpl-1996", ]
  answers <- source_response_rows(raw, people, inputs, items[0, ])
  expect_identical(answers$raw_numeric, c(99, 99, 99, 0))
  expect_identical(answers$response_status,
    c("answered", "answered", "non-substantive", "answered")
  )
  expect_identical(answers$missing_code, c(NA, NA, "99", NA))
})
