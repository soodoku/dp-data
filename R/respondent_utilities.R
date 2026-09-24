utility_source_field <- function(poll_id, field) {
  if (poll_id == "cpl-1996") field else toupper(field)
}

read_utility_value <- function(survey, poll_id, field, allowed) {
  missing <- if (poll_id == "cpl-1996") c(99, 999) else numeric()
  value <- read_source_codes(survey, utility_source_field(poll_id, field),
    c(allowed, missing)
  )
  value[value %in% missing] <- NA_real_
  value
}

scale_historical_range <- function(value, lower, upper) {
  stopifnot(length(lower) == 1L, length(upper) == 1L, upper > lower)
  (value - lower) / (upper - lower)
}

cpl_attitudes <- function(survey, wave) {
  response <- function(stem) {
    read_utility_value(survey, "cpl-1996", paste0(stem, wave),
      if (stem == "poor") 1:5 else 0:10
    )
  }
  scale <- function(stem) {
    lower <- if (stem == "poor" || (stem == "fuels" && wave == 2L)) 1 else 0
    upper <- if (stem == "poor") 5 else 10
    scale_historical_range(response(stem), lower, upper)
  }
  average <- function(stems) {
    values <- purrr::map(stems, scale) |> rlang::set_names(stems)
    historical_available_mean(as.matrix(tibble::as_tibble(values)))
  }
  tibble::tibble(
    research = average(c("resch", "fedrch")),
    conservation = average(c("addfac", "reduce")),
    low_income_support = average(c("lowinc", "poor")),
    renewables = average(c("renew", "wind")),
    fossil_fuels = scale("fuels"),
    imported_power = scale("buypwr")
  ) |>
    dplyr::rename_with(\(name) paste0(name, "_t", wave))
}

utility_attitudes <- function(survey, poll_id, wave) {
  stopifnot(poll_id %in% c("wtu-1996", "swepco-1996"), wave %in% 1:2)
  response <- function(stem) {
    read_utility_value(survey, poll_id, paste0(stem, wave), 0:10)
  }
  average <- function(stems) {
    values <- purrr::map(stems, response) |> rlang::set_names(stems)
    historical_available_mean(as.matrix(tibble::as_tibble(values)))
  }
  wtu <- poll_id == "wtu-1996"
  conservation <- if (wave == 1L) average(c("addfac", "reduce"))
  else response("reduce")
  # ADDFACT2 is absent in the archived script's input; only REDUCE2 survives.
  conservation_min <- if (wave == 1L) {
    if (wtu) 2 else 3
  } else {
    if (wtu) 3 else 0
  }
  renewables_min <- if (wtu) 2.5 else if (wave == 1L) 1 else 0
  research_min <- if (wtu && wave == 2L) 1 else 0
  tibble::tibble(
    imported_power = dplyr::coalesce(response("buypwr"), 5) / 10,
    conservation = dplyr::coalesce(
      scale_historical_range(conservation, conservation_min, 10), .5
    ),
    low_income_support = dplyr::coalesce(response("needto"), 5) / 10,
    renewables = dplyr::coalesce(scale_historical_range(
      average(c("renew", "wind")), renewables_min, 10
    ), .5),
    research = scale_historical_range(
      dplyr::coalesce(average(c("fedrch", "resch")), 5), research_min, 10
    ),
    fossil_fuels = dplyr::coalesce(response("fuels"), 5) / 10
  ) |>
    dplyr::rename_with(\(name) paste0(name, "_t", wave))
}

utility_knowledge_items <- function(survey, poll_id, wave) {
  key <- switch(poll_id,
    "cpl-1996" = c(source = 3, use = 3, rt = 2, smog = 2, setrt = 1,
      profit = 0, pctful = 2
    ),
    "wtu-1996" = c(source = 3, use = 1, rt = 1, smog = 2, setrt = 1),
    "swepco-1996" = c(source = 1, use = 3, rt = 1, smog = 2, setrt = 1)
  )
  stopifnot(!is.null(key))
  ranges <- list(source = 1:6, use = 1:3, rt = 1:3, smog = 1:3,
    setrt = 1:6, profit = 0:3, pctful = 1:5
  )
  if (poll_id == "wtu-1996" && wave == 2L) ranges$use <- 1:4
  values <- purrr::imap(key, function(correct, stem) {
    value <- read_utility_value(survey, poll_id, paste0(stem, wave),
      ranges[[stem]]
    )
    as.numeric(value %in% correct)
  })
  as.matrix(tibble::as_tibble(values))
}

utility_demographics <- function(survey, poll_id) {
  response <- function(field, allowed) {
    read_utility_value(survey, poll_id, field, allowed)
  }
  education <- c(0, 0, .33, .66, 1, 1)[match(response("educ", 1:6), 1:6)]
  income <- if (poll_id == "cpl-1996") response("income", 1:8)
  else rep(NA_real_, nrow(survey))
  tibble::tibble(
    female = as.numeric(response("gender", 1:2) == 2),
    minority = as.numeric(response("race", 1:6) != 4),
    age = response("age", 16:110),
    education_four = education,
    education_three = collapse_historical_education(education),
    higher_education = as.numeric(education >= .66),
    household_income = income,
    high_income = as.numeric(income > 4)
  )
}

build_utility_individual <- function(survey, poll_id) {
  cpl <- poll_id == "cpl-1996"
  attitudes <- purrr::map(1:2, function(wave) {
    if (cpl) cpl_attitudes(survey, wave)
    else utility_attitudes(survey, poll_id, wave)
  }) |> purrr::list_cbind()
  baseline <- attitudes |> dplyr::select(dplyr::ends_with("_t1"))
  if (!cpl) {
    # The merge rescales research after extremity was already calculated.
    baseline$research_t1 <- baseline$research_t1 * 10
  }
  competition <- read_utility_value(survey, poll_id, "compet1", 1:5)
  if (!cpl) competition <- dplyr::coalesce(competition, 5)
  baseline$competition_t1 <- (competition - 1) / 4
  extremity <- historical_available_mean(abs(as.matrix(baseline) - .5))
  if (cpl) {
    # The historical export recalibrates conservation after computing extremity.
    attitudes$conservation_t1 <-
      scale_historical_range(attitudes$conservation_t1, .05, 1)
  }
  knowledge <- summarise_historical_knowledge(
    utility_knowledge_items(survey, poll_id, 1L),
    utility_knowledge_items(survey, poll_id, 2L)
  )
  demographics <- utility_demographics(survey, poll_id)
  dplyr::bind_cols(attitudes, demographics, knowledge) |>
    dplyr::mutate(
      attitude_extremity = extremity,
      political_interest_t1 = NA_real_, read_briefing = NA_real_,
      knowledge_joint_midterm = NA_real_, knowledge_midterm = NA_real_,
      knowledge_midterm_joint = NA_real_, attitude_extremity_midterm = NA_real_
    )
}
