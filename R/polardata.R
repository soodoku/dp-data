source(project_path("R", "respondent_health.R"))

build_health_polardata <- function(
  survey = read_poll_survey("uk-health-1998")
) {
  stopifnot(nrow(survey) == 230L)
  result <- build_health_individual(survey)
  result <- health_polardata_demographics(result, survey)
  result <- health_polardata_knowledge(result, survey)
  result[c("dpnum", "caseid", health_polardata_fields())]
}

health_polardata_demographics <- function(result, survey) {
  group <- as.numeric(survey$group)
  if (anyNA(group) || any(!group %in% 1:15)) {
    stop("Unreviewed UK Health group code")
  }
  result$pollgroup <- 2200 + group
  group_summary <- function(value, fun = mean) {
    ave(value, result$pollgroup, FUN = function(x) fun(x, na.rm = TRUE))
  }
  result$groupsize <- group_summary(rep(1, nrow(result)), sum)
  result$pfemale <- group_summary(result$female)
  result$pminority <- group_summary(result$minority)
  result$varfemale <- result$pfemale * (1 - result$pfemale)
  result$sdfemale <- sqrt(result$varfemale)
  result$vareduc <- group_summary(result$educ4, var)
  result$sdeduc <- sqrt(result$vareduc)
  result$meaned <- group_summary(result$educ4)
  result$meanage <- group_summary(result$ppage)
  # The group share predates the individual threshold revision (UKH-08).
  result$phighinc <- group_summary(as.numeric(result$highinc_early))
  result$pfemale_ind <- (
    result$pfemale * result$groupsize - result$female
  ) / (result$groupsize - 1)

  attitudes <- as.matrix(result[grep("^ukhealth[.]t1", names(result))])
  # These summaries precede the severity rescaling in 05_fix_data.R (UKH-09).
  attitudes[, "ukhealth.t1severi"] <-
    result$severity_t1_unscaled
  result$meanxtreme <- group_summary(result$attextreme)
  result$avgsd <- ave(seq_len(nrow(result)), result$pollgroup,
    FUN = function(rows) mean(apply(attitudes[rows, ], 2, sd, na.rm = TRUE))
  )
  result
}

historical_group_gain <- function(corrected, group) {
  stopifnot(
    is.matrix(corrected), nrow(corrected) == length(group),
    ncol(corrected) > 0L, !anyNA(group), all(corrected %in% c(0, 1))
  )
  size <- ave(rep(1, length(group)), group, FUN = sum)
  stopifnot(all(size > 1))
  peer_means <- apply(corrected, 2, function(value) {
    ave(value, group, FUN = mean) * size / (size - 1)
  })
  unknown <- 1 - corrected
  gain <- rowSums(unknown * peer_means) / rowSums(unknown)
  gain[is.nan(gain)] <- NA_real_
  gain
}

health_polardata_knowledge <- function(result, survey) {
  before <- historical_health_items(survey, 1L)
  after <- historical_health_items(survey, 2L)
  corrected <- before * after
  group_mean <- function(value) ave(value, result$pollgroup, FUN = mean)
  result$grpgain <- historical_group_gain(corrected, result$pollgroup)
  result$meant1know <- group_mean(result$t1know)
  result$meant2know <- group_mean(result$t2know)
  result$meant1knowcor <- group_mean(result$t1knowcor)
  result$t1knowlevel <- mean(result$t1know_rounded)
  result$t1knowlevelcor <- mean(result$t1knowcor)
  result$t2knowlevel <- mean(result$t2know)
  result$meant1know_ind <- (
    result$meant1know * result$groupsize - result$t1know
  ) / (result$groupsize - 1)
  result$meant1knowcor_ind <- (
    result$meant1knowcor * result$groupsize - result$t1knowcor
  ) / (result$groupsize - 1)
  result$loggain <- historical_log_score(result$grpgain)
  aliases <- c(
    t1knowr = "t1know", t2knowr = "t2know", t1knowrcor = "t1knowcor",
    grpgainr = "grpgain", meant1knowr = "meant1know",
    meant1knowrcor = "meant1knowcor", t1knowlevelrcor = "t1knowlevelcor",
    knowgainr = "knowgain", knowgainr2 = "knowgain2"
  )
  for (name in names(aliases)) result[[name]] <- result[[aliases[[name]]]]
  result
}

health_knowledge_fields <- function() {
  c(
    "t1know", "t2know", "t1knowcor", "grpgain", "meant1know", "meant2know",
    "meant1knowcor", "t1knowlevel", "t1knowlevelcor", "t2knowlevel",
    "meant1know_ind", "meant1knowcor_ind", "knowgain", "knowgain2", "logpk",
    "loggain", "tobitpk", "t1knowr", "t2knowr", "t1knowrcor", "grpgainr",
    "meant1knowr", "meant1knowrcor", "t1knowlevelrcor",
    "knowgainr", "knowgainr2"
  )
}

health_polardata_fields <- function() {
  attitudes <- unlist(lapply(1:2, function(wave) {
    paste0("ukhealth.t", wave, c(
      "payhlt", "poora", "option", "hlthfu", "ctexpt", "pritre", "severi",
      "preven", "dispub", "avgdis", "moresa"
    ))
  }))
  c(attitudes, "female", "minority", "ppage", "educ4", "educ3", "bettered",
    "hhincome", "highinc", "pollgroup", "groupsize", "pfemale", "pminority",
    "varfemale", "sdfemale", "vareduc", "sdeduc", "meaned", "meanage",
    "phighinc", "pfemale_ind", "attextreme", "meanxtreme", "avgsd",
    health_knowledge_fields()
  )
}

compare_health_polardata <- function(rebuilt, benchmark, tolerance = 1e-10) {
  reference <- benchmark[benchmark$dpnum == 2L, , drop = FALSE]
  stopifnot(
    nrow(rebuilt) == 230L, nrow(reference) == nrow(rebuilt),
    all(rebuilt$dpnum == 2L),
    !anyNA(reference$caseid), !anyDuplicated(reference$caseid),
    !anyNA(rebuilt$caseid), !anyDuplicated(rebuilt$caseid),
    setequal(rebuilt$caseid, reference$caseid)
  )
  reference <- reference[match(rebuilt$caseid, reference$caseid), ]
  fields <- health_polardata_fields()
  stopifnot(
    setequal(names(rebuilt), c("dpnum", "caseid", fields)),
    all(fields %in% names(reference))
  )
  parity <- purrr::map(fields, function(field) {
    actual <- rebuilt[[field]]
    expected <- reference[[field]]
    both <- !is.na(actual) & !is.na(expected)
    errors <- abs(actual[both] - expected[both])
    tibble::tibble(
      poll_id = "uk-health-1998", field = field,
      respondents = nrow(rebuilt), compared_values = sum(both),
      missingness_differences = sum(is.na(actual) != is.na(expected)),
      value_differences = sum(errors > tolerance),
      max_absolute_difference = if (length(errors)) max(errors) else 0,
      tolerance = tolerance
    )
  }) |> purrr::list_rbind()
  changed <- parity$missingness_differences != 0 | parity$value_differences != 0
  if (any(changed)) {
    stop("UK Health reconstruction differs from historical polardata")
  }
  parity
}
