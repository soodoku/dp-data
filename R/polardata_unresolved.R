unresolved_poll_rows <- function(survey, values) {
  stopifnot(
    !anyDuplicated(survey$source_row),
    all(values$source_row %in% survey$source_row)
  )
  match(values$source_row, survey$source_row)
}

build_zeguo_derived <- function(survey, values) {
  rows <- unresolved_poll_rows(survey, values)
  group <- 5200 + survey$groupnum[rows]
  attitudes <- zeguo_attitudes(survey, 1L)[rows, ]
  result <- historical_derived_columns(
    values, group,
    rep(NA_real_, length(rows)), attitudes
  )
  before <- zeguo_knowledge_items(survey, "pre")[rows, , drop = FALSE]
  after <- zeguo_knowledge_items(survey, "post")[rows, , drop = FALSE]
  result$grpgain <- historical_fractional_gain(before * after, group)
  result$grpgainr <- result$grpgain
  result$grpgain2 <- NA_real_
  result$t1knowlevel <- mean(rowMeans(before))
  result$pollid <- 52
  result$pollgroup <- group
  result$country <- 6
  result$mode <- 0
  result$numitems <- 4
  result$numindices <- 9
  result$numissues <- 1
  result$length <- 1
  result$timebtw <- 25
  result
}

build_new_haven_derived <- function(survey, values) {
  measures <- build_new_haven_individual(survey)
  level <- as_historical_float(mean(measures$knowledge_t1))
  result <- reviewed_us_derived(survey, values, measures,
    rep(TRUE, nrow(survey)), 9100 + survey$group,
    new_haven_attitudes(survey, "pre"),
    new_haven_knowledge_items(survey, "pre"),
    new_haven_knowledge_items(survey, "post"),
    as.numeric(measures$household_income > 7),
    pollid = 91, mode = 0, numindices = 3, numissues = 2,
    t1knowlevel = level
  )
  rows <- unresolved_poll_rows(survey, values)
  group <- 9100 + survey$group[rows]
  result$avgsd2 <- reviewed_us_average_sd(
    new_haven_attitudes(survey, "mid")[rows, ], group
  )
  result$grpgain2 <- reviewed_us_group_gain(
    new_haven_knowledge_items(survey, "mid")[rows, , drop = FALSE],
    new_haven_knowledge_items(survey, "post")[rows, , drop = FALSE],
    group, measures$knowledge_midterm_joint[rows]
  )
  result
}

build_btp_primaries_derived <- function(survey, values) {
  rows <- unresolved_poll_rows(survey, values)
  group <- 9500 + survey$groupnumc[rows]
  attitudes <- primaries_attitudes(survey, "b1")[rows, ]
  # Historical merge duplicates each person before later composition summaries.
  repeated <- rep(seq_len(nrow(values)), 2L)
  result <- historical_derived_columns(
    values[repeated, ], group[repeated],
    as.numeric(survey$ppincimp[rows][repeated] >= 14), attitudes[repeated, ]
  )[seq_len(nrow(values)), ]
  dispersion <- historical_group_dispersion(attitudes, group)
  result$genvar <- dispersion$generalized_variance
  result$avgsd <- reviewed_us_average_sd(attitudes, group)
  before <- primaries_knowledge_items(survey, "b1")
  after <- primaries_knowledge_items(survey, "f1")
  joint <- before[rows, , drop = FALSE] * after[rows, , drop = FALSE]
  stopifnot(!anyNA(joint))
  size <- historical_group_summary(rep(1, length(rows)), group, sum)
  total <- rep(0, length(rows))
  for (item in seq_len(ncol(joint))) {
    group_total <- historical_group_summary(joint[, item], group, sum)
    component <- as_historical_float(group_total / (size - 1) / 7)
    component[joint[, item] == 1] <- 0
    total <- as_historical_float(total + component)
  }
  result$grpgain <- total * 7 / ((1 - values$t1knowcor) * 7)
  result$grpgain[is.nan(result$grpgain)] <- NA_real_
  result$grpgainr <- result$grpgain
  result$grpgain2 <- NA_real_
  result$t1knowlevel <- as_historical_float(round(
    mean(as_historical_float(rowMeans(before, na.rm = TRUE)), na.rm = TRUE), 7
  ))
  result$pollid <- 95
  result$pollgroup <- group
  result$country <- 1
  result$mode <- 1
  result$numitems <- 7
  result$numindices <- 3
  result$numissues <- 1
  result$length <- NA_real_
  result$timebtw <- NA_real_
  result
}
