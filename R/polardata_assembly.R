historical_respondent_wide <- function(poll_id) {
  contracts <- read_metadata("respondent_sources")
  contract <- contracts[contracts$poll_id == poll_id, ]
  stopifnot(nrow(contract) == 1L, contract$status == "reviewed-source")
  built <- build_poll_respondents(contract)
  targets <- read_metadata("polardata_targets")
  targets <- targets[targets$poll_id == poll_id, ]
  if (any(targets$status != "implemented")) {
    stop("Incomplete historical respondent reconstruction: ", poll_id)
  }
  sample <- built$sample_memberships
  selected <- sample$respondent_id[sample$sample_id == "historical-polardata" &
                                     !is.na(sample$included) & sample$included]
  people <- built$people[built$people$respondent_id %in% selected, ]
  values <- tibble::tibble(
    respondent_id = people$respondent_id, source_row = people$source_row,
    dpnum = contract$dpnum, caseid = as.numeric(people$historical_respondent_id)
  )
  measures <- built$respondent_measures
  for (index in seq_len(nrow(targets))) {
    target <- targets[index, ]
    observed <- measures[
      measures$definition_id == target$canonical_definition,
    ]
    stopifnot(
      !anyDuplicated(observed$respondent_id),
      all(people$respondent_id %in% observed$respondent_id)
    )
    values[[target$legacy_field]] <- observed$value_numeric[
      match(people$respondent_id, observed$respondent_id)
    ]
  }
  values
}

historical_derived_columns <- function(values, group, early_high_income,
                                       baseline_attitudes,
                                       arrival_attitudes = NULL) {
  canonical <- tibble::tibble(
    female = values$female, minority = values$minority,
    education_four = values$educ4, age = values$ppage,
    attitude_extremity = values$attextreme
  )
  result <- historical_composition(canonical, group, early_high_income)
  dispersion <- historical_group_dispersion(baseline_attitudes, group)
  result$avgsd <- dispersion$average_sd
  result$genvar <- dispersion$generalized_variance
  result$avgsd2 <- if (is.null(arrival_attitudes)) {
    NA_real_
  } else {
    historical_group_dispersion(arrival_attitudes, group)$average_sd
  }
  average <- function(value) historical_group_summary(value, group)
  result$meant1know <- average(values$t1know)
  result$meant1knowcor <- average(values$t1knowcor)
  result$meant2know <- average(values$t2know)
  result$meant1knowr <- average(values$t1knowr)
  result$meant1knowrcor <- average(values$t1knowrcor)
  result$meant1know_ind <- (result$meant1know * result$groupsize -
                              values$t1know) / (result$groupsize - 1)
  result$meant1knowcor_ind <- (result$meant1knowcor * result$groupsize -
                                 values$t1knowcor) / (result$groupsize - 1)
  result$t1knowlevelcor <- mean(values$t1knowcor, na.rm = TRUE)
  result$t2knowlevel <- mean(values$t2know, na.rm = TRUE)
  result$t1knowlevelrcor <- mean(values$t1knowrcor, na.rm = TRUE)
  result
}
