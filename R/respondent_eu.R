eu_source_value <- function(survey, field, allowed) {
  if (!field %in% names(survey)) stop("Missing source field: ", field)
  value <- as.numeric(survey[[field]])
  if (any(!is.na(value) & !value %in% allowed)) {
    stop("Unreviewed UK EU source code: ", field)
  }
  value
}

build_eu_individual <- function(survey = read_poll_survey("uk-eu-1995")) {
  result <- tibble::tibble(dpnum = 1L, caseid = as.numeric(survey$caseid))
  stopifnot(!anyNA(result$caseid), !anyDuplicated(result$caseid))
  response <- function(field, missing, limits) {
    upper_code <- if (field %in% c("releu2", "longpol2")) 6L else 5L
    value <- eu_source_value(survey, field, c(-1, seq_len(upper_code), 8, 9))
    value[value %in% missing] <- NA_real_
    (value - limits[1]) / diff(limits)
  }
  for (wave in 1:2) {
    average <- function(stems, missing, lower = 1) {
      values <- lapply(stems, function(stem) {
        field <- paste0(stem, wave)
        missing_codes <- if (field %in% c("releu2", "longpol2")) {
          c(missing, 6)
        } else {
          missing
        }
        response(field, missing_codes, c(lower, 5))
      })
      historical_available_mean(do.call(cbind, values))
    }
    result[[paste0("ukeu.eurelat", wave, "g")]] <-
      average(c("releu", "longpol", "unite"), c(-1, 8, 9))
    scope_missing <- if (wave == 1L) c(8, 9) else c(-1, 8, 9)
    result[[paste0("ukeu.euscope", wave, "g")]] <-
      average(c("trabloc", "pasport"), scope_missing)
    for (stem in c("commies", "favref")) {
      result[[paste0("ukeu.", stem, wave, "r")]] <- response(
        paste0(stem, wave), if (wave == 1) numeric() else c(-1, 8, 9),
        if (wave == 1) c(1, 9) else c(1, 5)
      )
    }
  }
  attitudes <- as.matrix(result[grep("1[gr]$", names(result))])
  result$attextreme <- historical_available_mean(abs(attitudes - .5))
  result$female <- eu_source_value(survey, "sex", 0:1)
  ethnic <- eu_source_value(survey, "ethnic", c(-1, 1:8, 97, 99))
  ethnic[ethnic %in% c(-1, 8, 97, 99)] <- NA_real_
  result$minority <- as.numeric(ethnic != 1)
  age <- eu_source_value(survey, "age", c(-1, 18:110))
  age[age %in% c(-1, 97, 98, 99)] <- NA_real_
  result$ppage <- age
  school <- eu_source_value(survey, "educ", c(-1, 0:13, 99))
  result$educ4 <- c(0, 0, 0, .33, .33, .33, .66, .66, .66, .66, .66, 1,
    .66, NA_real_
  )[match(school, 0:13)]
  result$educ3 <- ifelse(result$educ4 %in% c(0, 1), result$educ4,
    ifelse(is.na(result$educ4), NA_real_, .5)
  )
  result$bettered <- result$educ4 >= .33
  interest <- eu_source_value(survey, "genint", c(-1, 1:4, 8, 9))
  result$t1polint <- c(0, .33, .66, 1)[match(interest, 1:4)]
  key <- c(eusize = 1, swiss = 2, inctax = 2, elect = 1, ptyapp = 2)
  correctness <- function(wave) {
    do.call(cbind, lapply(names(key), function(stem) {
      value <- eu_source_value(survey, paste0(stem, wave),
        if (wave == 1) c(-1, 1, 2, 8, 9) else c(-1, 1, 2, 3, 9)
      )
      as.numeric(value %in% key[[stem]])
    }))
  }
  before <- correctness(1L)
  after <- correctness(2L)
  result$t1know <- rowMeans(before)
  result$t2know <- rowMeans(after)
  result$t1knowcor <- rowMeans(before * after)
  result$knowgain <- result$t2know - result$t1know
  result$knowgain2 <- result$t2know - result$t1knowcor
  result$logpk <- historical_log_score(result$t1knowcor)
  result$tobitpk <- as.numeric(result$t1knowcor > .6)
  for (field in c("readbrief", "hhincome", "highinc", "t1knowcor2", "t12know",
    "t12knowcor", "attextreme2"
  )) result[[field]] <- rep(NA_real_, nrow(survey))
  result
}
