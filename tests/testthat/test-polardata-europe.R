source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "polardata.R"))
source(file.path(root, "R", "polardata_rebuild.R"))

test_that("European and Australian aggregates match every historical field", {
  polls <- c(
    "australia-republic-1999", "tomorrows-europe-2007", "europolis-2009"
  )
  builders <- list(build_australia_derived, build_tomorrow_derived,
    build_europolis_derived
  )
  benchmark <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  for (index in seq_along(polls)) {
    survey <- read_poll_survey(polls[index])
    values <- historical_respondent_wide(polls[index])
    result <- builders[[index]](survey, values)
    reference <- benchmark[benchmark$dpnum == values$dpnum[1], ]
    reference <- reference[match(values$caseid, reference$caseid), ]
    for (field in names(result)) {
      expected <- as.numeric(reference[[field]])
      if (polls[index] == "australia-republic-1999" &&
            field %in% c("grpgain", "loggain")) {
        approved <- readr::read_csv(project_path(
          "audit", "corrections", polls[index], "approved_values.csv"
        ), show_col_types = FALSE)
        approved <- approved[approved$legacy_field == field, ]
        expected <- approved$approved_value[match(values$caseid,
                                                  approved$caseid)]
      }
      expect_equal(result[[field]], expected, tolerance = 1e-10,
                   info = paste(polls[index], field))
    }
    order <- rev(seq_len(nrow(survey)))
    expect_equal(builders[[index]](survey[order, ], values), result)
    reversed <- rev(seq_len(nrow(values)))
    expect_equal(builders[[index]](survey, values[reversed, ]),
      result[reversed, ]
    )
  }
})

test_that("Australian gain joins by source row", {
  survey <- read_poll_survey("australia-republic-1999")
  values <- historical_respondent_wide("australia-republic-1999")
  result <- build_australia_derived(survey, values)
  expect_equal(sum(is.infinite(result$grpgain)), 0L)
  assembled <- build_historical_poll("australia-republic-1999")
  expect_equal(sum(is.infinite(assembled$loggain)), 0L)
  broken <- values
  broken$source_row[1] <- max(survey$source_row) + 1
  expect_error(build_australia_derived(survey, broken))
})
