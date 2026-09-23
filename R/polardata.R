historical_health_response <- function(x, categories, folded = FALSE) {
  x <- as.numeric(x)
  allowed <- c(-9, -8, seq_len(categories))
  if (any(!is.na(x) & !x %in% allowed)) {
    stop("Unreviewed UK Health response code")
  }
  x[x %in% c(-9, -8)] <- NA_real_
  if (folded) {
    stopifnot(categories == 3L)
    return(ifelse(x == 2, 0.5, ifelse(is.na(x), NA_real_, 1)))
  }
  (x - 1) / (categories - 1)
}

historical_available_mean <- function(x) {
  value <- rowMeans(x, na.rm = TRUE)
  value[is.nan(value)] <- NA_real_
  value
}

build_health_polardata <- function(
  survey = read_poll_survey("uk-health-1998")
) {
  ids <- as.numeric(survey$serial_m)
  stopifnot(
    nrow(survey) == 230L, !anyNA(ids), !anyDuplicated(ids),
    all(ids == round(ids)), identical(ids, as.numeric(survey$serial_a))
  )
  result <- tibble::tibble(dpnum = 2L, caseid = ids)
  for (wave in 1:2) {
    response <- function(stem, categories = 5L, folded = FALSE) {
      field <- paste0(stem, wave)
      if (!field %in% names(survey)) stop("Missing source field: ", field)
      historical_health_response(survey[[field]], categories, folded)
    }
    average <- function(stems, reverse = FALSE) {
      values <- vapply(stems, response, numeric(nrow(survey)))
      if (reverse) values <- 1 - values
      historical_available_mean(values)
    }
    difference <- response("lista") - response("severa")
    limits <- range(difference, na.rm = TRUE)
    stopifnot(all(is.finite(limits)), diff(limits) > 0)
    indices <- list(
      payhlt = response("payhlth", 3L),
      poora = response("poora"),
      option = response("options", 3L),
      hlthfu = average(c("chgp", "chvis", "chmeal", "chstay", "chamb")),
      ctexpt = average(c("treata", "cthart", "ctnurs", "ctbaby"), TRUE),
      pritre = average(c("ctfert", "cthosp", "ctcosm"), TRUE),
      severi = (difference - limits[1]) / diff(limits),
      preven = response("preva"),
      dispub = historical_available_mean(cbind(
        response("ingova", 3L, TRUE), response("inpuba", 3L, TRUE)
      )),
      avgdis = historical_available_mean(cbind(
        response("ingpa", 3L, TRUE), response("indoca", 3L, TRUE)
      )),
      moresa = response("say")
    )
    names(indices) <- paste0("ukhealth.t", wave, names(indices))
    result <- dplyr::bind_cols(result, tibble::as_tibble(indices))
  }
  health_polardata_demographics(result, survey)
}

health_polardata_demographics <- function(result, survey) {
  source_code <- function(field, allowed) {
    value <- as.numeric(survey[[field]])
    if (
      length(value) != nrow(survey) || anyNA(value) || any(!value %in% allowed)
    ) {
      stop("Unreviewed UK Health source field: ", field)
    }
    value
  }
  result$female <- as.numeric(source_code("gender", 1:2) == 2)
  result$minority <- as.numeric(source_code("ethnic", 1:8) != 1)
  result$ppage <- source_code("age", 18:110)
  school <- source_code("educa", c(-9, 0:4))
  result$educ4 <- c(0, .33, .66, 1, .66)[match(school, 0:4)]
  result$educ3 <- ifelse(
    result$educ4 %in% c(0, 1), result$educ4,
    ifelse(is.na(result$educ4), NA_real_, .5)
  )
  result$bettered <- result$educ4 >= .66
  income <- source_code("income", c(-9, -8, -7, 1:16))
  income[income < 1] <- NA_real_
  result$hhincome <- (income - 1) / 15
  result$highinc <- result$hhincome > .34
  result$pollgroup <- 2200 + source_code("group", 1:15)
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
  result$phighinc <- group_summary(as.numeric(result$hhincome > .8))
  result$pfemale_ind <- (
    result$pfemale * result$groupsize - result$female
  ) / (result$groupsize - 1)

  attitudes <- as.matrix(result[grep("^ukhealth[.]t1", names(result))])
  # These summaries precede the severity rescaling in 05_fix_data.R (UKH-09).
  attitudes[, "ukhealth.t1severi"] <-
    historical_health_response(survey$lista1, 5L) -
    historical_health_response(survey$severa1, 5L)
  result$attextreme <- historical_available_mean(abs(attitudes - .5))
  result$meanxtreme <- group_summary(result$attextreme)
  result$avgsd <- ave(seq_len(nrow(result)), result$pollgroup,
    FUN = function(rows) mean(apply(attitudes[rows, ], 2, sd, na.rm = TRUE))
  )
  result
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
    "phighinc", "pfemale_ind", "attextreme", "meanxtreme", "avgsd"
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
