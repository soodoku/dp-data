read_source_codes <- function(survey, field, allowed) {
  if (!field %in% names(survey)) stop("Missing source field: ", field)
  value <- as.numeric(survey[[field]])
  invalid <- !is.na(value) & !value %in% allowed
  if (any(invalid)) {
    stop("Unreviewed source codes in ", field, ": ",
      paste(sort(unique(value[invalid])), collapse = ", ")
    )
  }
  value
}

recode_source_values <- function(survey, field, values, missing = numeric()) {
  codes <- seq_along(values)
  value <- read_source_codes(survey, field, c(codes, missing))
  values[match(value, codes)]
}

as_historical_float <- function(value) {
  # SPSS/Stata float storage is part of the historical numeric representation.
  bytes <- writeBin(as.numeric(value), raw(), size = 4)
  readBin(bytes, what = "double", n = length(value), size = 4)
}

summarise_historical_knowledge <- function(before, after,
                                           baseline = rowMeans(before)) {
  stopifnot(identical(dim(before), dim(after)), !anyNA(before), !anyNA(after),
    all(before %in% 0:1), all(after %in% 0:1)
  )
  tibble::tibble(
    knowledge_t1 = baseline,
    knowledge_t2 = rowMeans(after),
    knowledge_joint = rowMeans(before * after)
  ) |>
    dplyr::mutate(
      knowledge_gain = .data$knowledge_t2 - .data$knowledge_t1,
      knowledge_gain_joint = .data$knowledge_t2 - .data$knowledge_joint,
      log_knowledge_joint = historical_log_score(.data$knowledge_joint),
      high_knowledge_joint = as.numeric(.data$knowledge_joint > .6)
    )
}

collapse_historical_education <- function(education) {
  dplyr::case_when(
    is.na(education) ~ NA_real_,
    education %in% c(0, 1) ~ education,
    .default = .5
  )
}
