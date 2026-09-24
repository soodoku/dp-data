europolis_source_codes <- function(survey, field, allowed) {
  position <- match(tolower(field), tolower(names(survey)))
  if (is.na(position)) stop("Missing source field: ", field)
  value <- as.numeric(unclass(survey[[position]]))
  if (any(!is.na(value) & !value %in% c(allowed, 997:999))) {
    stop("Unreviewed source codes in ", field)
  }
  value[value %in% 997:999] <- NA_real_
  value
}

europolis_knowledge_items <- function(survey, wave) {
  key <- c(`43` = 2, `44` = 1, `46` = 2, `47` = 1, `49` = 4, `50` = 1)
  purrr::imap(key, function(correct, question) {
    field <- paste0("V", wave, "Q", question)
    value <- europolis_source_codes(survey, field, 1:5)
    as.numeric(value %in% correct)
  }) |>
    tibble::as_tibble() |>
    as.matrix()
}

build_europolis_individual <- function(
  survey = read_poll_survey("europolis-2009")) {
  read <- function(field, allowed) {
    europolis_source_codes(survey, field, allowed)
  }
  before <- rowMeans(europolis_knowledge_items(survey, 1L))
  after <- rowMeans(europolis_knowledge_items(survey, 3L))
  climate <- (10 - read("V1Q21", 0:10)) / 10
  immigration <- (read("V1Q11_1", 1:5) - 1) / 4
  birth_year <- read("age1", 1900:1991)
  education <- read("educ1", 0:35)
  studying <- which(education == 0)
  education[studying] <- pmin(2010 - birth_year, 35)[studying]
  education <- round(education / 35, 2)
  birth <- read("birth1", 1:5)
  parents <- read("parentsbirth1", 1:4)
  minority <- as.numeric(
    ifelse(is.na(birth), 1, birth > 1) +
      ifelse(is.na(parents), 1, parents > 1) > 0
  )
  extremity <- rowMeans(abs(cbind(climate, immigration) - .5), na.rm = TRUE)
  extremity[is.nan(extremity)] <- NA_real_
  tibble::tibble(
    climate_t1 = climate,
    climate_t2 = (10 - read("V3Q21", 0:10)) / 10,
    immigration_t1 = immigration,
    immigration_t2 = (read("V3Q11_1", 1:5) - 1) / 4,
    knowledge_t1 = before, knowledge_t2 = after,
    knowledge_joint = NA_real_, knowledge_gain = after - before,
    knowledge_gain_joint = NA_real_, log_knowledge_joint = NA_real_,
    high_knowledge_joint = NA_real_, knowledge_midterm = NA_real_,
    knowledge_midterm_joint = NA_real_, knowledge_joint_midterm = NA_real_,
    age = 2009 - birth_year, female = as.numeric(read("sex1", 1:2) == 2),
    minority = minority, education_four = education,
    education_three = collapse_historical_education(education),
    higher_education = as.numeric(education > .57),
    household_income = NA_real_, high_income = NA_real_,
    political_interest_t1 = NA_real_, read_briefing = NA_real_,
    attitude_extremity = extremity, attitude_extremity_midterm = NA_real_
  )
}
