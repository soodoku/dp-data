source(file.path(root, "R", "respondents.R"))

test_that("Monarchy refusal correction preserves attendee ethnicity", {
  survey <- read_poll_survey("uk-monarchy-1996")
  built <- monarchy_demographics(survey)
  ethnicity <- as.numeric(survey$B16)
  refused <- ethnicity == 8
  attendees <- as.numeric(survey$GROUP) != -1

  expect_identical(survey$source_row[refused], 59L)
  expect_false(any(attendees[refused]))
  expect_true(all(is.na(built$minority[refused])))
  expect_true(all(built$minority[ethnicity == 1] == 0))
  expect_true(all(built$minority[ethnicity %in% 2:7] == 1))
  expect_equal(sum(attendees), 258L)

  benchmark <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  benchmark <- benchmark[benchmark$dpnum == 3, ]
  position <- match(benchmark$caseid, 1000 + survey$source_row)
  expect_false(anyNA(position))
  expect_equal(built$minority[position], as.numeric(benchmark$minority))

  reversed <- rev(seq_len(nrow(survey)))
  expect_identical(monarchy_demographics(survey[reversed, ]), built[reversed, ])
})

test_that("Monarchy demographic nonresponse does not become observed values", {
  survey <- read_poll_survey("uk-monarchy-1996")
  built <- monarchy_demographics(survey)
  age_band <- as.numeric(survey$AGEB)
  attendees <- as.numeric(survey$GROUP) != -1

  expect_identical(survey$source_row[age_band == 11],
                   c(97L, 141L, 225L, 322L, 481L))
  expect_identical(survey$source_row[age_band == 10], c(320L, 325L, 509L))
  expect_true(all(is.na(built$age[age_band %in% 10:11])))
  midpoints <- c(18.5, 25, 35, 45, 55, 65, 74, 83)
  observed <- age_band %in% 2:9
  expect_equal(built$age[observed], midpoints[age_band[observed] - 1])
  expect_identical(survey$source_row[as.numeric(survey$A6) == 6], 447L)
  expect_true(is.na(built$political_interest_t1[447]))

  education <- c("education_four", "education_three", "higher_education")
  expect_true(all(is.na(as.matrix(built[509, education]))))
  expect_true(all(as.matrix(built[c(431, 754), education]) == 0))
  affected <- c(59L, 97L, 141L, 225L, 320L, 322L, 325L, 447L, 481L, 509L)
  expect_false(any(attendees[affected]))

  benchmark <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  benchmark <- benchmark[benchmark$dpnum == 3, ]
  position <- match(benchmark$caseid, 1000 + survey$source_row)
  fields <- c(ppage = "age", educ4 = "education_four",
              educ3 = "education_three", bettered = "higher_education")
  for (field in names(fields)) {
    expect_equal(built[[fields[[field]]]][position],
                 as.numeric(benchmark[[field]]), tolerance = 1e-10)
  }
})
