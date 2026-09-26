tomorrows_europe_codes <- function(survey, field, allowed) {
  position <- match(tolower(field), tolower(names(survey)))
  if (is.na(position)) stop("Missing source field: ", field)
  value <- as.numeric(unclass(survey[[position]]))
  if (any(!is.na(value) & !value %in% allowed)) {
    stop("Unreviewed source codes in ", field)
  }
  value
}

tomorrows_europe_age <- function(survey) {
  age <- tomorrows_europe_codes(survey, "age", 18:120)
  birth_year <- tomorrows_europe_codes(survey, "v_q36", 1900:2007)
  age_band <- tomorrows_europe_codes(survey, "q36", 1:6)
  observed <- !is.na(age)
  stopifnot(
    identical(is.na(age), is.na(birth_year)),
    all(age[observed] == 2007 - birth_year[observed]),
    all(as.integer(cut(age[observed], c(17, 24, 39, 54, 69, Inf))) ==
          age_band[observed]),
    all(age_band[!observed] == 6)
  )
  age
}

tomorrows_europe_mean <- function(...) {
  value <- rowMeans(cbind(...), na.rm = TRUE)
  value[is.nan(value)] <- NA_real_
  value
}

tomorrows_europe_attitudes <- function(survey, wave) {
  item <- function(question, scale = 10, reverse = FALSE) {
    field <- if (wave == 1L) paste0("q", question, "_1") else
      paste0("t", wave, "q", question)
    allowed <- if (wave == 1L) seq_len(scale + 3L) else
      c(if (scale == 10) 0:10 else 1:5, 99)
    exceptions <- list(t2q11a = 8, t3q16a = 10, t3q18c = 55)
    allowed <- c(allowed, exceptions[[field]])
    value <- tomorrows_europe_codes(survey, field, allowed)
    if (wave == 1L && scale == 10) value <- value - 1
    value[value > scale & !is.na(value)] <- NA_real_
    value <- if (scale == 10) value / 10 else (value - 1) / 4
    if (reverse) 1 - value else value
  }
  average <- function(
    questions, scale = 10, reverse = FALSE) {
    values <- purrr::map(questions, \(q) item(q, scale, reverse))
    do.call(tomorrows_europe_mean, values)
  }
  military <- tomorrows_europe_mean(
    average(c("11a", "11c"), 5, TRUE),
    average(paste0("12", letters[1:4]))
  )
  result <- tibble::tibble(
    eu_membership = item("1"), privatization = item("4"),
    migration = item("7c", 5, wave == 1L), military = military,
    military_never = item("11b", 5, TRUE),
    turkey = item(if (wave == 1L) "13b" else "16b", 5, TRUE),
    veto = average(paste0(if (wave == 1L) "15" else "18", letters[1:4]))
  )
  if (wave != 1L) {
    pension <- average(c("5b", "5c"), 5) - average(c("5a", "5d"), 5)
    trade <- (item("7d", 5) - item("7a", 5) + 1) / 2
    result$pension <- (pension + 1) / 1.875
    result$trade <- tomorrows_europe_mean(trade, item("8"))
    result$enlargement <- tomorrows_europe_mean(
      item("16a", 5, TRUE), average(c("16b", "16c", "16f"), 5, TRUE)
    )
    result$decision_level <- average(paste0("17", letters[1:9]))
    result$enlargement_limit <- item("16j", 5, TRUE)
  }
  result
}

tomorrow_knowledge_items <- function(survey, wave) {
  key <- c(3, 1, 2, 4, 1, 4, 2, 1, 4)
  closed <- purrr::map(seq_along(key), function(index) {
    field <- if (wave == 1L) paste0("q", index + 15L, "_1") else
      paste0("t", wave, "q", index + 18L)
    allowed <- if (wave == 1L) 1:7 else c(1:5, 99)
    exceptions <- list(t2q19 = 6, t3q19 = c(0, 6),
      t2q24 = c(24, 1004), t2q27 = c(44, 1004)
    )
    allowed <- c(allowed, exceptions[[field]])
    value <- tomorrows_europe_codes(survey, field, allowed)
    as.numeric(value %in% key[index])
  })
  placement <- purrr::map(c("a", "b"), function(suffix) {
    field <- if (wave == 1L) paste0("q33", suffix, "_1") else
      paste0("t", wave, "q36", suffix)
    allowed <- if (wave == 1L) 1:13 else c(0:10, 24, 44, 99, 1004)
    value <- tomorrows_europe_codes(survey, field, allowed)
    if (wave == 1L) value <- value - 1
    value[value > 10 & !is.na(value)] <- NA_real_
    as.numeric(!is.na(value) & if (suffix == "a") value > 5 else value < 5)
  })
  as.matrix(tibble::as_tibble(c(closed, placement),
    .name_repair = "unique_quiet"
  ))
}

build_tomorrow_individual <- function(
  survey = read_poll_survey("tomorrows-europe-2007")) {
  before <- tomorrow_knowledge_items(survey, 1L)
  arrival <- tomorrow_knowledge_items(survey, 2L)
  after <- tomorrow_knowledge_items(survey, 3L)
  attitudes <- purrr::map(1:3, \(wave) tomorrows_europe_attitudes(survey, wave))
  extremity <- function(values) {
    value <- rowMeans(abs(as.matrix(values[, 1:7]) - .5), na.rm = TRUE)
    value[is.nan(value)] <- NA_real_
    value
  }
  read <- function(field, allowed) {
    tomorrows_europe_codes(survey, field, allowed)
  }
  education <- c(0, .33, .66, 1, 1, 1, NA)[read("q39", 1:7)]
  dplyr::bind_cols(
    purrr::map2(attitudes, 1:3, function(values, wave) {
      dplyr::rename_with(values, \(name) paste0(name, "_t", wave))
    }) |> dplyr::bind_cols(),
    summarise_historical_knowledge(before, after),
    tibble::tibble(
      knowledge_midterm = rowMeans(arrival),
      knowledge_midterm_joint = rowMeans(arrival * after),
      knowledge_joint_midterm = rowMeans(before * arrival * after),
      age = tomorrows_europe_age(survey),
      female = as.numeric(read("q35", 1:2) == 2), minority = NA_real_,
      education_four = education,
      education_three = collapse_historical_education(education),
      higher_education = as.numeric(education >= .66),
      household_income = NA_real_, high_income = NA_real_,
      political_interest_t1 = NA_real_,
      read_briefing = (read("t3q42", 1:5) - 1) / 4,
      attitude_extremity = extremity(attitudes[[1]]),
      attitude_extremity_midterm = extremity(attitudes[[2]])
    )
  )
}
