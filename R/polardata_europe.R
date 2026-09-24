europe_derived_source_rows <- function(survey, values) {
  stopifnot(!anyDuplicated(survey$source_row),
    all(values$source_row %in% survey$source_row)
  )
  match(values$source_row, survey$source_row)
}

build_europolis_derived <- function(survey, values) {
  rows <- europe_derived_source_rows(survey, values)
  field <- match("small_groupw3", tolower(names(survey)))
  group <- as.numeric(paste0(71, as.numeric(unclass(survey[[field]]))[rows]))
  individual <- build_europolis_individual(survey)
  attitudes <- individual[rows, c("climate_t1", "immigration_t1")]
  result <- historical_derived_columns(
    values, group, rep(NA_real_, nrow(values)), attitudes
  )
  result$t1knowlevel <- mean(individual$knowledge_t1[rows])
  result$grpgain <- NA_real_
  result$grpgain2 <- NA_real_
  result$grpgainr <- NA_real_
  result$loggain <- NA_real_
  result$pollgroup <- group
  result$pollid <- 71
  result$country <- 0
  result$mode <- 0
  result$numitems <- 6
  result$numindices <- 2
  result$length <- NA_real_
  result$timebtw <- NA_real_
  result$numissues <- 1
  result
}

build_australia_derived <- function(survey, values) {
  rows <- europe_derived_source_rows(survey, values)
  field <- match("group", tolower(names(survey)))
  group <- 2600 + as.numeric(unclass(survey[[field]]))[rows]
  attitudes <- australia_original_attitudes(survey)[rows, ]
  result <- historical_derived_columns(values, group, values$highinc, attitudes)
  selected <- which(as.numeric(unclass(survey[[field]])) %in% 1:24)
  selected <- selected[order(survey$source_row[selected])]
  before <- australia_knowledge_items(survey, 1L)[selected, ]
  after <- australia_knowledge_items(survey, 2L)[selected, ]
  selected_group <- as.numeric(unclass(survey[[field]]))[selected]
  joint <- rowMeans(before * after)
  gain <- historical_group_gain(before * after, selected_group) *
    (1 - joint) * 12 / 11
  gain[is.na(gain) & joint == 1] <- 0
  # ifelse() recycled a participant vector across the full source file.
  recycled <- gain[(values$source_row - 1L) %% length(gain) + 1L]
  result$grpgain <- recycled / (1 - values$t1knowcor)
  result$grpgain2 <- NA_real_
  result$grpgainr <- NA_real_
  result$loggain <- historical_log_score(result$grpgain)
  result$t1knowlevel <- NA_real_
  result$pollgroup <- group
  result$pollid <- 26
  result$country <- 3
  result$mode <- 0
  result$numitems <- 11
  result$numindices <- 5
  result$length <- 2
  result$timebtw <- NA_real_
  result$numissues <- 1
  result
}

build_tomorrow_derived <- function(survey, values) {
  rows <- europe_derived_source_rows(survey, values)
  field <- match("group_no", tolower(names(survey)))
  group <- 2800 + as.numeric(unclass(survey[[field]]))[rows]
  before <- tomorrows_europe_attitudes(survey, 1L)[rows, 1:7]
  arrival <- tomorrows_europe_attitudes(survey, 2L)[rows, 1:7]
  result <- historical_derived_columns(
    values, group, rep(NA_real_, nrow(values)), before, arrival
  )
  knowledge_before <- tomorrow_knowledge_items(survey, 1L)
  knowledge_arrival <- tomorrow_knowledge_items(survey, 2L)[rows, ]
  knowledge_after <- tomorrow_knowledge_items(survey, 3L)[rows, ]
  result$grpgain <- historical_group_gain(knowledge_before[rows, ], group) *
    (1 - values$t1know) / (1 - values$t1knowcor)
  result$grpgain2 <- historical_group_gain(
    knowledge_arrival * knowledge_after, group
  )
  result$grpgainr <- result$grpgain
  result$loggain <- historical_log_score(result$grpgain)
  result$t1knowlevel <- mean(knowledge_before)
  result$pollgroup <- group
  result$pollid <- 28
  result$country <- 0
  result$mode <- 0
  result$numitems <- 11
  result$numindices <- 7
  result$length <- 2
  result$timebtw <- NA_real_
  result$numissues <- 4
  result
}
