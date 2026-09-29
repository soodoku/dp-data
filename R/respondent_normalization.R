above_reference_median <- function(value, reference) {
  stopifnot(
    is.numeric(value), is.numeric(reference),
    all(is.na(value) | is.finite(value)),
    all(is.na(reference) | is.finite(reference))
  )
  observed <- reference[!is.na(reference)]
  if (!length(observed)) return(rep(NA_real_, length(value)))
  as.numeric(value > stats::median(observed))
}

normalize_demographic_flags <- function(
  values, included, respondent_id, education = NULL
) {
  stopifnot(
    nrow(values) == length(included), length(included) == length(respondent_id),
    is.logical(included), !anyNA(respondent_id), !anyDuplicated(respondent_id)
  )
  selected <- included %in% TRUE
  legacy <- "educ4" %in% names(values)
  if (is.null(education)) {
    education <- values[[if (legacy) "educ4" else "education_four"]]
  }
  income <- values[[if (legacy) "hhincome" else "household_income"]]
  stopifnot(length(education) == nrow(values), length(income) == nrow(values))
  values[[if (legacy) "bettered" else "higher_education"]] <-
    above_reference_median(education, education[selected])
  values[[if (legacy) "highinc" else "high_income"]] <-
    above_reference_median(income, income[selected])
  values
}

education_normalization_values <- function(values, survey, poll_id) {
  rules <- read_metadata("education_normalization") |>
    dplyr::filter(.data$poll_id == .env$poll_id)
  if (!nrow(rules)) {
    field <- if ("educ4" %in% names(values)) "educ4" else "education_four"
    return(values[[field]])
  }
  stopifnot(nrow(rules) == 1L, nrow(survey) == nrow(values))
  rule <- rules[1, ]
  numbers <- function(value) as.numeric(strsplit(value, "|", fixed = TRUE)[[1]])
  code <- as.numeric(survey[[rule$source_column]])
  categories <- numbers(rule$source_codes)
  order <- numbers(rule$ordered_values)
  missing <- numbers(rule$missing_codes)
  stopifnot(
    length(code) == nrow(values), length(categories) == length(order),
    !anyDuplicated(categories), !anyNA(order),
    all(is.na(code) | code %in% c(categories, missing))
  )
  value <- order[match(code, categories)]
  if (!is.na(rule$override_column)) {
    override <- as.numeric(survey[[rule$override_column]])
    stopifnot(length(override) == length(value))
    value[override %in% as.numeric(rule$override_code)] <-
      as.numeric(rule$override_value)
  }
  value
}
