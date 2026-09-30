source(file.path(root, "R", "analysis_covariates.R"))

source_covariate_fixture <- function() {
  people <- tibble::tibble(
    poll_id = "example", source_row = 1:2,
    respondent_id = c("10", "survey:source-row-2"), source_id = "survey",
    identity_basis = c("unique-source-id", "missing-source-id")
  )
  participants <- tibble::tibble(
    poll_id = "example", source_dataset = c("historical", "cor_sood",
      "historical", "cor_sood", "control"
    ),
    source_row = c(1L, 1L, 2L, 2L, 1L),
    respondent_id = c("10", "10", "survey:source-row-2", "source-row-2", "10"),
    age = c(20 + 1e-8, rep(NA_real_, 4)), female = NA_real_,
    education = NA_real_, minority = NA_real_, extremity = NA_real_,
    read_briefing = NA_real_, ba = NA_real_, attended = TRUE, panel = TRUE
  )
  targets <- tibble::tibble(
    poll_id = "example", legacy_field = c("ppage", "female", "educ3",
      "minority", "attextreme"
    ),
    canonical_definition = letters[1:5], status = "implemented"
  )
  measures <- tidyr::expand_grid(
    respondent_id = people$respondent_id, definition_id = letters[1:5]
  ) |>
    dplyr::mutate(poll_id = "example",
      value_numeric = c(20, 1, .5, 0, .25)[match(definition_id, letters[1:5])]
    )
  reading <- tibble::tibble(poll_id = "example",
    respondent_id = people$respondent_id, reading_score = c(.75, NA_real_)
  )
  list(participants = participants, people = people, measures = measures,
    targets = targets, reading = reading
  )
}

test_that("covariates follow verified source IDs without inventing degrees", {
  fixture <- source_covariate_fixture()
  result <- do.call(add_source_covariates, fixture)
  expect_identical(result$age, c(20 + 1e-8, 20, 20, 20, NA_real_))
  expect_identical(result$education, c(rep(.5, 4), NA_real_))
  expect_identical(result$read_briefing, c(.75, .75, rep(NA_real_, 3)))
  expect_true(all(is.na(result$ba)))
  expect_identical(result$attended, fixture$participants$attended)
  expect_identical(result$panel, fixture$participants$panel)
  fixture$participants <- result
  expect_identical(do.call(add_source_covariates, fixture), result)
  fixture$people <- fixture$people[2:1, ]
  expect_identical(do.call(add_source_covariates, fixture), result)
  fixture$participants$respondent_id[2] <- "wrong-id"
  expect_error(do.call(add_source_covariates, fixture))
})

test_that("source-row aliases and observed disagreements require evidence", {
  fixture <- source_covariate_fixture()
  fixture$participants$source_row[4] <- 1L
  expect_error(do.call(add_source_covariates, fixture))
  fixture <- source_covariate_fixture()
  fixture$participants$female[1] <- 0
  expect_error(do.call(add_source_covariates, fixture))
  fixture <- source_covariate_fixture()
  fixture$people <- dplyr::bind_rows(fixture$people, fixture$people[1, ])
  expect_error(do.call(add_source_covariates, fixture))
})

test_that("reviewed Europolis covariates reach the full source frame", {
  people <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_participants.parquet"
  ))
  europolis <- people |>
    dplyr::filter(poll_id == "europolis-2009")
  fields <- c("age", "female", "education", "minority", "extremity",
    "read_briefing"
  )
  input <- europolis
  input[fields] <- NA_real_
  result <- add_source_covariates(input)
  historical <- result$source_dataset == "historical"
  expect_equal(colSums(!is.na(result[historical, fields[1:4]])),
    c(age = 4377L, female = 4384L, education = 4236L, minority = 4377L)
  )
  cor <- result$source_dataset == "cor_sood"
  expect_equal(colSums(!is.na(result[cor, fields[1:4]])),
    c(age = 347L, female = 348L, education = 335L, minority = 348L)
  )
  expect_true(all(is.na(result$education) |
                    result$education %in% c(0, .5, 1)))
  expect_identical(result[setdiff(names(input), fields)],
    input[setdiff(names(input), fields)]
  )
  with_observed <- add_source_covariates(europolis)
  for (field in fields) {
    observed <- !is.na(europolis[[field]])
    expect_identical(with_observed[[field]][observed],
      europolis[[field]][observed]
    )
  }
})
