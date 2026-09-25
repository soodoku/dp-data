build_nic2_derived <- function(survey, values) {
  stopifnot(!anyDuplicated(survey$source_row),
    all(values$source_row %in% survey$source_row)
  )
  rows <- match(values$source_row, survey$source_row)
  group <- 9200 + as.numeric(unclass(survey$group))[rows]
  attitudes <- nic2_attitudes(survey, 1L)[rows, ]
  result <- historical_derived_columns(values, group,
    as.numeric(values$hhincome > 7), attitudes
  )
  item_sd <- purrr::map(attitudes, function(value) {
    as_historical_float(historical_group_summary(value, group, stats::sd))
  }) |> tibble::as_tibble()
  result$avgsd <- as_historical_float(
    rowMeans(as.matrix(item_sd), na.rm = TRUE)
  )
  before <- nic2_knowledge_items(survey, 1L)[rows, ]
  after <- nic2_knowledge_items(survey, 2L)[rows, ]
  joint <- before * after
  terms <- apply(joint, 2, function(value) {
    total <- historical_group_summary(value, group, sum)
    term <- as_historical_float(total / (result$groupsize - 1) / 11)
    term[value == 1] <- 0
    term
  })
  term_order <- c(11L, seq_len(10L))
  raw_gain <- rep(0, nrow(values))
  for (item in term_order) {
    raw_gain <- as_historical_float(raw_gain + terms[, item])
  }
  result$grpgain <- raw_gain / (1 - values$t1knowcor)
  result$grpgain2 <- NA_real_
  result$grpgainr <- result$grpgain
  result$t1knowlevel <- as_historical_float(mean(
    as_historical_float(rowMeans(before))
  ))
  result$pollgroup <- group
  result$pollid <- 92
  result$country <- 1
  result$mode <- 0
  result$numitems <- 11
  result$numindices <- 9
  result$length <- NA_real_
  result$timebtw <- NA_real_
  result$numissues <- 1
  result
}
