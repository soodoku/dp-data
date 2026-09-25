reviewed_us_baseline_level <- function(poll_id, survey = NULL) {
  if (poll_id == "btp-general-election-2004") {
    if (is.null(survey)) {
      survey <- haven::read_dta(project_path(
        "data", poll_id, "raw-responses.dta"
      ))
    }
    items <- btp_general_knowledge(survey, "b")
    fields <- paste0("w4b", c(60, 61, 62, 63, 64, 65, 66, 68, 69))
    for (item in seq_along(fields)) {
      missing <- is.na(survey[[fields[item]]])
      if (fields[item] == "w4b62") {
        missing <- missing | survey[[fields[item]]] %in% -1
      }
      items[missing, item] <- NA_real_
    }
    scores <- rowMeans(items)
  } else if (poll_id == "btp-health-education-2005") {
    if (is.null(survey)) {
      survey <- arrow::read_parquet(project_path(
        "data", poll_id, "calibration-responses.parquet"
      ))
    }
    items <- btp_health_knowledge(survey, 1L)
    items[, 1] <- as.numeric(survey$q15 %in% 3)
    fields <- paste0("q", c(15, 16, 17, 26, 27, 28))
    for (item in seq_along(fields)) {
      items[is.na(survey[[fields[item]]]), item] <- NA_real_
    }
    scores <- rowMeans(items, na.rm = TRUE)
    scores[is.nan(scores)] <- 0
  } else if (poll_id == "san-mateo-2008") {
    if (is.null(survey)) survey <- read_poll_survey(poll_id)
    scores <- rowSums(san_mateo_knowledge(survey, 1L)) / 9
  } else {
    stop("Unsupported reviewed US calibration: ", poll_id)
  }
  as_historical_float(round(
    mean(as_historical_float(scores), na.rm = TRUE), 7
  ))
}

reviewed_us_legacy_values <- function(measures) {
  tibble::tibble(
    female = measures$female, minority = measures$minority,
    educ4 = measures$education_four, ppage = measures$age,
    attextreme = measures$attitude_extremity,
    t1know = measures$knowledge_t1, t2know = measures$knowledge_t2,
    t1knowcor = measures$knowledge_joint, t1knowr = measures$knowledge_t1,
    t1knowrcor = measures$knowledge_joint
  )
}

reviewed_us_group_gain <- function(before, after, group, knowledge_joint) {
  joint <- before * after
  size <- historical_group_summary(rep(1, length(group)), group, sum)
  components <- purrr::map(seq_len(ncol(joint)), function(item) {
    total <- historical_group_summary(joint[, item], group, sum)
    value <- as_historical_float(total / (size - 1) / ncol(joint))
    value[joint[, item] == 1] <- 0
    value
  }) |> do.call(what = cbind)
  original <- rep(0, nrow(components))
  for (item in seq_len(ncol(components))) {
    value <- components[, item]
    value[is.na(value)] <- 0
    original <- as_historical_float(original + value)
  }
  gain <- original * ncol(joint) / ((1 - knowledge_joint) * ncol(joint))
  gain[is.nan(gain)] <- NA_real_
  gain
}

reviewed_us_average_sd <- function(attitudes, group) {
  deviations <- purrr::map(attitudes, function(value) {
    as_historical_float(historical_group_summary(value, group, stats::sd))
  }) |> do.call(what = cbind)
  result <- as_historical_float(rowMeans(deviations, na.rm = TRUE))
  result[is.nan(result)] <- NA_real_
  result
}

reviewed_us_derived <- function(survey, values, measures, selected, group,
                                attitudes, before, after, early_high_income,
                                pollid, mode, numindices, numissues,
                                t1knowlevel, length = NA_real_) {
  rows <- which(selected)
  legacy <- reviewed_us_legacy_values(measures)[rows, ]
  result <- historical_derived_columns(
    legacy, group[rows],
    early_high_income[rows], attitudes[rows, , drop = FALSE]
  )
  result$avgsd <- reviewed_us_average_sd(
    attitudes[rows, , drop = FALSE],
    group[rows]
  )
  result$grpgain <- reviewed_us_group_gain(
    before[rows, , drop = FALSE],
    after[rows, , drop = FALSE], group[rows], legacy$t1knowcor
  )
  result$grpgainr <- result$grpgain
  result$grpgain2 <- NA_real_
  result$t1knowlevel <- t1knowlevel
  result$pollid <- pollid
  result$pollgroup <- group[rows]
  result$country <- 1
  result$mode <- mode
  result$numitems <- ncol(before)
  result$numindices <- numindices
  result$numissues <- numissues
  result$length <- length
  result$timebtw <- NA_real_
  index <- match(values$source_row, survey$source_row[rows])
  stopifnot(!anyNA(index))
  result[index, , drop = FALSE]
}

build_btp_general_derived <- function(survey, values) {
  if (!"raw_w4b42" %in% names(survey)) {
    survey <- augment_btp_general_source(survey)
  }
  measures <- build_btp_general_individual(survey)
  reviewed_us_derived(survey, values, measures, rep(TRUE, nrow(survey)),
    9400 + as.numeric(survey$smgrpnumber), btp_general_attitudes(survey, "b"),
    btp_general_knowledge(survey, "b"), btp_general_knowledge(survey, "f"),
    as.numeric(measures$household_income > 7),
    pollid = 94, mode = 1, numindices = 6, numissues = 1,
    t1knowlevel = reviewed_us_baseline_level("btp-general-election-2004")
  )
}

build_btp_health_derived <- function(survey, values) {
  measures <- build_btp_health_individual(survey)
  reviewed_us_derived(survey, values, measures, survey$filter %in% 1,
    9700 + as.numeric(survey$groupnum), btp_health_attitudes(survey, 1L),
    btp_health_knowledge(survey, 1L), btp_health_knowledge(survey, 2L),
    rep(NA_real_, nrow(survey)),
    pollid = 97, mode = 1, numindices = 11, numissues = 2,
    t1knowlevel = reviewed_us_baseline_level("btp-health-education-2005")
  )
}

build_san_mateo_derived <- function(survey, values) {
  survey <- survey[order(survey$PARTICIPANTID), ]
  measures <- build_san_mateo_individual(survey)
  reviewed_us_derived(survey, values, measures, survey$participant %in% 1,
    9600 + as.numeric(survey$GRP),
    san_mateo_attitudes(survey, 1L)[c(
      "more_housing", "below_market_housing", "open_space", "less_commuting",
      "consultation", "county_local", "county_state"
    )],
    san_mateo_knowledge(survey, 1L), san_mateo_knowledge(survey, 2L),
    as.numeric(measures$household_income > 4),
    pollid = 96, mode = 0, numindices = 7, numissues = 1,
    t1knowlevel = reviewed_us_baseline_level("san-mateo-2008", survey),
    length = 2
  )
}

reviewed_us_covariance_inputs <- function(survey, poll_id) {
  if (poll_id == "btp-general-election-2004") {
    survey <- augment_btp_general_source(survey)
    attitudes <- btp_general_attitudes(survey, "b")
    group <- 9400 + as.numeric(survey$smgrpnumber)
  } else if (poll_id == "btp-health-education-2005") {
    attitudes <- btp_health_attitudes(survey, 1L)
    group <- 9700 + as.numeric(survey$groupnum)
  } else if (poll_id == "san-mateo-2008") {
    survey <- survey[survey$participant %in% 1, ]
    survey <- survey[order(survey$PARTICIPANTID), ]
    attitudes <- san_mateo_attitudes(survey, 1L)
    attitudes <- attitudes[c(
      "more_housing", "below_market_housing", "open_space",
      "less_commuting", "consultation", "county_local", "county_state"
    )]
    group <- 9600 + as.numeric(survey$GRP)
  } else {
    stop("Unsupported reviewed US covariance: ", poll_id)
  }
  list(attitudes = attitudes, group = group)
}

reviewed_us_covariance_audit <- function(survey, poll_id) {
  inputs <- reviewed_us_covariance_inputs(survey, poll_id)
  groups <- split(seq_along(inputs$group), inputs$group)
  purrr::imap_dfr(groups, function(index, group) {
    attitudes <- as.matrix(inputs$attitudes[index, , drop = FALSE])
    covariance <- stats::cov(attitudes, use = "pairwise.complete.obs")
    spectrum <- eigen(covariance, symmetric = TRUE, only.values = TRUE)$values
    singular <- svd(covariance, nu = 0, nv = 0)$d
    tibble::tibble(
      poll_id = poll_id, pollgroup = as.numeric(group),
      respondents = length(index), attitude_count = ncol(attitudes),
      covariance_rank = qr(covariance)$rank,
      determinant = det(covariance),
      minimum_eigenvalue = min(spectrum), maximum_eigenvalue = max(spectrum),
      minimum_singular_value = min(singular),
      maximum_singular_value = max(singular),
      condition_number = max(singular) / min(singular),
      eigenvalues = paste(format(spectrum, digits = 17), collapse = "|"),
      singular_values = paste(format(singular, digits = 17), collapse = "|"),
      source_genvar = historical_genvar(attitudes)
    )
  })
}
