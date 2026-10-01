test_that("label normalization repairs only invalid label bytes", {
  euro <- rawToChar(as.raw(0x80))
  apostrophe <- rawToChar(as.raw(0x92))
  dash <- rawToChar(as.raw(0x97))
  values <- c(1, 2, NA_real_)
  attr(values, "label") <- paste0("Cost ", euro)
  attr(values, "labels") <- stats::setNames(c(1, 2), c(
    paste0("Can", apostrophe, "t choose"), paste0("Low", dash, "high")
  ))
  attr(values, "na_values") <- 2
  text <- c(paste0("raw ", euro), "valid \u20ac", NA_character_)
  attr(text, "label") <- "Already valid \u20ac"
  data <- tibble::tibble(values, text)
  result <- normalize_survey_labels(data, "windows-1252")
  expect_identical(as.numeric(result$values), as.numeric(data$values))
  expect_identical(result$text, data$text)
  expect_identical(attr(result$values, "label"), "Cost \u20ac")
  expect_identical(names(attr(result$values, "labels")),
    c("Can\u2019t choose", "Low\u2014high")
  )
  expect_identical(unname(attr(result$values, "labels")), c(1, 2))
  expect_identical(attr(result$values, "na_values"), 2)
  expect_identical(normalize_survey_labels(result, "windows-1252"), result)
  expect_identical(normalize_survey_labels(data), data)
  expect_identical(normalize_survey_labels(data, NA_character_), data)
  expect_identical(normalize_survey_labels(data, ""), data)
  expect_error(normalize_survey_labels(data, "ASCII"),
    "Cannot convert survey labels"
  )
})

test_that("Marousi imports reproduce UTF-8 dictionaries without data changes", {
  record <- read_metadata("survey_sources") |>
    dplyr::filter(poll_id == "marousi-2006")
  expect_equal(record$label_encoding, "windows-1252")
  other <- read_metadata("survey_sources") |>
    dplyr::filter(poll_id != "marousi-2006")
  expect_true(all(is.na(other$label_encoding)))
  source <- haven::read_sav(project_path(record$public_path), user_na = TRUE)
  expect_equal(ncol(source), 1026L)
  expect_equal(nrow(source), 1275L)
  archive <- read_archive_survey(record)
  public <- read_public_survey(record)
  expect_identical(public$source_row, seq_len(nrow(source)))
  public$source_row <- NULL
  expect_identical(archive, public)
  expect_identical(names(archive), names(source))
  expect_identical(lapply(archive, as.numeric), lapply(source, as.numeric))
  other_attributes <- function(data) {
    lapply(data, function(column) {
      properties <- attributes(column)
      properties$label <- NULL
      if (!is.null(properties$labels)) {
        names(properties$labels) <- NULL
      }
      properties
    })
  }
  expect_identical(other_attributes(archive), other_attributes(source))
  labels <- survey_value_labels(archive)
  variables <- survey_dictionary(archive, character())
  expect_true(all(validUTF8(labels$value_label)))
  expect_true(all(validUTF8(variables$variable_label)))
  expected_labels <- readr::read_csv(project_path(
    "data", "marousi-2006", "value-labels.csv"
  ), col_types = readr::cols(.default = readr::col_character()),
  na = character(), trim_ws = FALSE)
  expected_variables <- readr::read_csv(project_path(
    "data", "marousi-2006", "variables.csv"
  ), col_types = readr::cols(.default = readr::col_character()),
  na = character(), trim_ws = FALSE)
  expect_equal(labels, expected_labels)
  variables <- dplyr::mutate(variables,
    dplyr::across(dplyr::everything(), as.character)
  )
  expect_equal(variables, expected_variables)
  expect_true(any(!validUTF8(survey_value_labels(source)$value_label)))
  expect_true(any(!validUTF8(survey_dictionary(
    source, character()
  )$variable_label)))
})

test_that("survey components without label metadata preserve their reader", {
  component <- read_metadata("survey_components") |>
    dplyr::filter(source_id == "cdd-denmark-euro-2000-arrival")
  expect_null(component[["label_encoding"]])
  source <- haven::read_sav(project_path(component$public_path), user_na = TRUE)
  imported <- read_public_survey(component)
  imported$source_row <- NULL
  expect_identical(imported, source)
})
