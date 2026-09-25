core_poll_constants <- function(poll_id) {
  constants <- list(
    "uk-health-1998" = c(22, 2, 0, 6, 11),
    "uk-eu-1995" = c(20, 2, 0, 5, 4),
    "uk-monarchy-1996" = c(23, 2, 0, 9, 4),
    "uk-general-election-1997" = c(25, 2, 0, 15, 4),
    "uk-crime-1994" = c(27, 2, 0, 7, 5),
    "nic-1996" = c(1001, 1, 0, 11, 9),
    "cpl-1996" = c(29, 1, 0, 7, 7),
    "wtu-1996" = c(986, 1, 0, 5, 7),
    "swepco-1996" = c(3000, 1, 0, 5, 7),
    "bulgaria-crime-2002" = c(53, 8, 0, 7, 5)
  )[[poll_id]]
  stopifnot(!is.null(constants))
  stats::setNames(constants, c(
    "pollid", "country", "mode", "numitems",
    "numindices"
  ))
}

core_eu_knowledge <- function(survey, wave) {
  key <- c(eusize = 1, swiss = 2, inctax = 2, elect = 1, ptyapp = 2)
  purrr::imap(key, function(correct, stem) {
    value <- eu_source_value(
      survey, paste0(stem, wave),
      if (wave == 1L) c(-1, 1, 2, 8, 9) else c(-1, 1, 2, 3, 9)
    )
    as.numeric(value %in% correct)
  }) |> do.call(what = cbind)
}

core_poll_profile <- function(survey, poll_id) {
  constants <- core_poll_constants(poll_id)
  group_field <- switch(poll_id,
    "uk-monarchy-1996" = "GROUP",
    "nic-1996" = "RGROUP2",
    "wtu-1996" = "GROUP",
    "swepco-1996" = "GROUP",
    "bulgaria-crime-2002" = "group0",
    "group"
  )
  group <- rounded_source_code(survey[[group_field]])
  group[group <= 0 & !is.na(group)] <- NA_real_
  prefix <- if (poll_id == "nic-1996") 95445 else constants[["pollid"]]
  present <- !is.na(group)
  group[present] <- as.numeric(paste0(
    prefix,
    ifelse(group[present] < 10, "0", ""), group[present]
  ))
  builder <- switch(poll_id,
    "uk-health-1998" = build_health_individual,
    "uk-eu-1995" = build_eu_individual,
    "uk-monarchy-1996" = build_monarchy_individual,
    "uk-general-election-1997" = build_election_individual,
    "uk-crime-1994" = build_crime_individual,
    "nic-1996" = build_nic_individual,
    "bulgaria-crime-2002" = build_bulgaria_individual,
    function(survey) build_utility_individual(survey, poll_id)
  )
  individual <- builder(survey)
  items <- switch(poll_id,
    "uk-health-1998" = historical_health_items,
    "uk-eu-1995" = core_eu_knowledge,
    "uk-monarchy-1996" = monarchy_knowledge_items,
    "uk-general-election-1997" = election_knowledge_items,
    "uk-crime-1994" = crime_knowledge_items,
    "nic-1996" = nic_knowledge_items,
    "bulgaria-crime-2002" = bulgaria_knowledge_items,
    function(survey, wave) utility_knowledge_items(survey, poll_id, wave)
  )
  before <- items(survey, 1L)
  after <- items(survey, if (poll_id == "nic-1996") 3L else 2L)
  baseline <- switch(poll_id,
    "uk-health-1998" = individual[grep("^ukhealth[.]t1", names(individual))],
    "uk-eu-1995" = individual[grep("^ukeu[.].*1[gr]$", names(individual))],
    "uk-crime-1994" = crime_attitudes(survey, 1L),
    "cpl-1996" = cpl_attitudes(survey, 1L),
    "wtu-1996" = utility_attitudes(survey, poll_id, 1L),
    "swepco-1996" = utility_attitudes(survey, poll_id, 1L),
    individual[
      grepl("_t1$", names(individual)) &
        !names(individual) %in% c("knowledge_t1", "political_interest_t1")
    ]
  )
  if (poll_id == "uk-health-1998") {
    baseline$ukhealth.t1severi <- individual$severity_t1_unscaled
  }
  if (poll_id %in% c("cpl-1996", "wtu-1996", "swepco-1996")) {
    competition <- read_utility_value(survey, poll_id, "compet1", 1:5)
    if (poll_id != "cpl-1996") {
      baseline$research_t1 <- baseline$research_t1 * 10
      competition <- dplyr::coalesce(competition, 5)
    }
    baseline$competition <- (competition - 1) / 4
  }
  early_income <- switch(poll_id,
    "uk-health-1998" = individual$highinc_early,
    "uk-general-election-1997" = as.numeric(individual$household_income > 3),
    "cpl-1996" = individual$high_income,
    "bulgaria-crime-2002" = as.numeric(individual$household_income > 4),
    rep(NA_real_, nrow(survey))
  )
  score <- if ("knowledge_t1" %in% names(individual)) {
    individual$knowledge_t1
  } else {
    individual$t1know
  }
  if (poll_id == "uk-health-1998") score <- individual$t1know_rounded
  list(
    group = group, before = before, after = after, attitudes = baseline,
    early_income = early_income, poll_score = score
  )
}

historical_fractional_gain <- function(corrected, group) {
  stopifnot(nrow(corrected) == length(group), !anyNA(corrected))
  size <- historical_group_summary(rep(1, length(group)), group, sum)
  peer <- apply(corrected, 2, function(value) {
    historical_group_summary(value, group) * size / (size - 1)
  })
  numerator <- rowSums((corrected == 0) * peer)
  numerator / (ncol(corrected) * (1 - rowMeans(corrected)))
}

build_core_derived <- function(survey, values, poll_id) {
  rows <- match(values$source_row, survey$source_row)
  stopifnot(!anyNA(rows), !anyDuplicated(survey$source_row))
  profile <- core_poll_profile(survey, poll_id)
  group <- profile$group[rows]
  arrival <- NULL
  if (poll_id == "nic-1996") {
    arrival <- nic_attitudes(survey, 2L)[rows, ]
    arrival[, 7:9] <- profile$attitudes[rows, 7:9]
  }
  result <- historical_derived_columns(
    values, group, profile$early_income[rows],
    profile$attitudes[rows, ], arrival
  )
  result$t1knowlevel <- mean(profile$poll_score)
  if (poll_id %in% c("nic-1996", "wtu-1996", "swepco-1996")) {
    result$t1knowlevel <- mean(profile$poll_score[rows])
  }
  joint <- profile$before[rows, , drop = FALSE] *
    profile$after[rows, , drop = FALSE]
  full_joint <- profile$before * profile$after
  result$grpgain <- historical_fractional_gain(full_joint, profile$group)[rows]
  full_dispersion <- historical_group_dispersion(
    profile$attitudes, profile$group
  )
  result$avgsd <- full_dispersion$average_sd[rows]
  result$genvar <- full_dispersion$generalized_variance[rows]
  result$grpgain2 <- NA_real_
  if (poll_id == "nic-1996") {
    arrival_joint <- nic_knowledge_items(survey, 2L)[rows, ] *
      profile$after[rows, ]
    # Nine stored factual indicators carry the SPSS numeric encoding offset.
    arrival_joint[, 1:9] <- arrival_joint[, 1:9] * (1 + 1e-11)
    result$grpgain2 <- historical_fractional_gain(arrival_joint, group)
  }
  result$grpgainr <- result$grpgain
  if (poll_id == "uk-crime-1994") result$grpgainr <- NA_real_
  result$pollgroup <- group
  constants <- core_poll_constants(poll_id)
  for (field in names(constants)) result[[field]] <- constants[[field]]
  result$length <- if (poll_id == "uk-crime-1994") 2 else NA_real_
  result$timebtw <- NA_real_
  result$numissues <- 1
  result
}
