btp_national_baseline_level <- function(
  survey = arrow::read_parquet(project_path(
    "data", "btp-national-2003", "calibration-responses.parquet"
  ))
) {
  items <- btp_national_knowledge(survey, 1L)
  items[is.na(survey$qb15b) | survey$qb15b < 0, 1] <- NA_real_
  items[is.na(survey$qb15c) | survey$qb15c < 0, 2] <- NA_real_
  score <- as_historical_float(rowMeans(items, na.rm = TRUE))
  as_historical_float(round(mean(score), 7))
}

build_btp_national_derived <- function(survey, values) {
  survey <- survey[order(survey$source_row), ]
  measures <- build_btp_national_individual(survey)
  before <- btp_national_knowledge(survey, 1L)
  after <- btp_national_knowledge(survey, 2L)
  # reagg.txt accumulates the trade item first, then Republican and Democratic.
  item_order <- c(11L, 2L, 1L, 3:10)
  reviewed_us_derived(survey, values, measures, rep(TRUE, nrow(survey)),
    9300 + as.numeric(survey$group), btp_national_attitudes(survey, 1L),
    before[, item_order], after[, item_order],
    as.numeric(measures$household_income > 7),
    pollid = 93, mode = 1, numindices = 9, numissues = 1,
    t1knowlevel = btp_national_baseline_level()
  )
}
