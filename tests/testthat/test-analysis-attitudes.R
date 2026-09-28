source(file.path(root, "R", "analysis_attitudes.R"))

read_attitudes_export <- function(name) {
  arrow::read_parquet(file.path(root, "output", "analysis", name))
}

test_that("baseline policy responses join the canonical participants", {
  people <- read_attitudes_export("analysis_participants.parquet")
  catalog <- read_attitudes_export("analysis_attitudes.parquet")
  responses <- read_attitudes_export("analysis_attitude_responses.parquet")
  keys <- c("poll_id", "source_dataset", "respondent_id")
  expect_equal(dplyr::n_distinct(catalog$poll_id), 28L)
  expect_equal(nrow(dplyr::anti_join(responses, people, by = keys)), 0L)
  expect_false(anyDuplicated(responses[c(keys, "attitude_id", "wave")]) > 0L)
  expect_false(anyDuplicated(catalog[c("poll_id", "attitude_id")]) > 0L)
  valid <- is.na(responses$value) |
    responses$value >= 0 & responses$value <= 1
  expect_true(all(valid))
  expect_equal(unique(responses$wave), "t1")
  unmatched <- dplyr::anti_join(responses, catalog,
    by = c("poll_id", "attitude_id")
  )
  expect_equal(nrow(unmatched), 0L)
  expect_true(all(
    c("control", "historical", "cor_sood") %in% responses$source_dataset
  ))
})

test_that("policy scaling excludes missing codes and preserves source rows", {
  people <- read_attitudes_export("analysis_participants.parquet")
  responses <- read_attitudes_export("analysis_attitude_responses.parquet")
  raw <- arrow::read_parquet(file.path(
    root, "data", "btp-2007", "survey.parquet"
  ))
  check <- responses |>
    dplyr::filter(poll_id == "btp-2007", attitude_id == "att_pre_q5a") |>
    dplyr::left_join(people,
      by = c("poll_id", "source_dataset", "respondent_id"),
      relationship = "one-to-one"
    )
  original <- raw$PRE_Q5a[match(check$source_row, raw$source_row)]
  expected <- ifelse(original %in% 1:5, (original - 1) / 4, NA_real_)
  expect_equal(check$value, expected)
  expect_true(any(is.na(expected)))
  expect_true(any(!is.na(expected)))
})

test_that("historical policy values use the documented respondent crosswalk", {
  people <- read_attitudes_export("analysis_participants.parquet")
  values <- read_attitudes_export("analysis_attitude_responses.parquet")
  raw <- arrow::read_parquet(file.path(
    root, "output", "polardata", "polardata.parquet"
  ))
  catalog <- read_attitudes_export("analysis_attitudes.parquet")
  poll_map <- read_metadata("respondent_sources")
  for (id in unique(people$poll_id[people$source_dataset == "historical"])) {
    definitions <- dplyr::filter(catalog, poll_id == id)
    if (!nrow(definitions)) next
    check <- values |>
      dplyr::filter(poll_id == id, attitude_id == definitions$attitude_id[1]) |>
      dplyr::left_join(people,
        by = c("poll_id", "source_dataset", "respondent_id"),
        relationship = "one-to-one"
      )
    number <- poll_map$dpnum[poll_map$poll_id == id]
    source <- dplyr::filter(raw, dpnum == number)
    expected <- source[[definitions$source_column[1]]][
      match(check$historical_respondent_id, as.character(source$caseid))
    ]
    expect_equal(check$value, expected, info = id)
    expect_true(any(!is.na(check$value)), info = id)
  }
})
