source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "polardata.R"))
source(file.path(root, "R", "polardata_derived.R"))
source(file.path(root, "R", "polardata_assembly.R"))
source(file.path(root, "R", "polardata_europe.R"))

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
      expect_equal(result[[field]], as.numeric(reference[[field]]),
        tolerance = 1e-10, info = paste(polls[index], field)
      )
    }
    order <- rev(seq_len(nrow(survey)))
    expect_equal(builders[[index]](survey[order, ], values), result)
    reversed <- rev(seq_len(nrow(values)))
    expect_equal(builders[[index]](survey, values[reversed, ]),
      result[reversed, ]
    )
  }
})

test_that("Australian legacy gain explicitly retains its recycled infinity", {
  survey <- read_poll_survey("australia-republic-1999")
  values <- historical_respondent_wide("australia-republic-1999")
  result <- build_australia_derived(survey, values)
  expect_equal(sum(is.infinite(result$grpgain)), 1L)
  expect_equal(sum(is.infinite(result$loggain)), 1L)
  broken <- values
  broken$source_row[1] <- max(survey$source_row) + 1
  expect_error(build_australia_derived(survey, broken))
})
