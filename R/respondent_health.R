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

historical_health_items <- function(survey, wave) {
  key <- c(a = 0, b = 1, c = 1, d = 0, e = 0, f = 0)
  values <- vapply(names(key), function(item) {
    field <- paste0("soph", item, wave)
    if (!field %in% names(survey)) stop("Missing source field: ", field)
    value <- as.numeric(survey[[field]])
    if (any(!is.na(value) & !value %in% c(-9, -8, -1, 0, 1))) {
      stop("Unreviewed UK Health knowledge code: ", field)
    }
    as.numeric(value %in% key[[item]])
  }, numeric(nrow(survey)))
  matrix(values, nrow = nrow(survey), ncol = length(key),
    dimnames = list(NULL, names(key))
  )
}

historical_log_score <- function(value) {
  value[!is.na(value) & value <= 0] <- .0001
  log(value)
}

historical_health_precision <- function(value) {
  # This numeric representation matches every stored hknow1 value (UKH-10).
  bytes <- writeBin(round(value, 2), raw(), size = 4)
  readBin(bytes, what = "double", n = length(value), size = 4)
}

build_health_individual <- function(
  survey = read_poll_survey("uk-health-1998")
) {
  ids <- as.numeric(survey$serial_m)
  stopifnot(
    !anyNA(ids), !anyDuplicated(ids),
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
      values <- matrix(vapply(stems, response, numeric(nrow(survey))),
        nrow = nrow(survey), ncol = length(stems)
      )
      if (reverse) values <- 1 - values
      historical_available_mean(values)
    }
    difference <- response("lista") - response("severa")
    limits <- if (wave == 1L) c(-1, 1) else c(-1, .5)
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
  result <- health_individual_demographics(result, survey)
  result <- health_individual_knowledge(result, survey)
  for (field in c("readbrief", "t1polint", "t1knowcor2", "t12know",
    "t12knowcor", "attextreme2"
  )) result[[field]] <- rep(NA_real_, nrow(survey))
  result
}

health_individual_demographics <- function(result, survey) {
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
  attitudes <- as.matrix(result[grep("^ukhealth[.]t1", names(result))])
  raw_severity <- historical_health_response(survey$lista1, 5L) -
    historical_health_response(survey$severa1, 5L)
  attitudes[, "ukhealth.t1severi"] <- raw_severity
  result$attextreme <- historical_available_mean(abs(attitudes - .5))
  result$severity_t1_unscaled <- raw_severity
  result$severity_t2_unscaled <-
    historical_health_response(survey$lista2, 5L) -
    historical_health_response(survey$severa2, 5L)
  result$highinc_early <- result$hhincome > .8
  result
}

health_individual_knowledge <- function(result, survey) {
  before <- historical_health_items(survey, 1L)
  after <- historical_health_items(survey, 2L)
  result$t1know <- rowMeans(before)
  result$t2know <- rowMeans(after)
  result$t1knowcor <- rowMeans(before * after)
  result$knowgain <- result$t2know - result$t1know
  result$knowgain2 <- result$t2know - result$t1knowcor
  result$logpk <- historical_log_score(result$t1knowcor)
  result$tobitpk <- as.numeric(result$t1knowcor > .6)
  result$t1know_rounded <- historical_health_precision(result$t1know)
  result
}
