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

add_midpoint_imputed_variants <- function(
  values, fallback = .5, absent_form = rep(FALSE, nrow(values)),
  imputed = NULL) {
  stopifnot(
    is.data.frame(values), all(vapply(values, is.numeric, logical(1))),
    !any(endsWith(names(values), "_midpoint_imputed")),
    length(absent_form) == nrow(values), !anyNA(absent_form),
    is.logical(absent_form), is.numeric(fallback), !anyNA(fallback)
  )
  if (is.null(imputed)) {
    if (length(fallback) == 1L) {
      fallback <- stats::setNames(rep(fallback, ncol(values)), names(values))
    }
    stopifnot(setequal(names(fallback), names(values)))
    imputed <- purrr::imap(values, function(value, name) {
      dplyr::coalesce(value, fallback[[name]])
    }) |>
      tibble::as_tibble()
  }
  stopifnot(
    is.data.frame(imputed), nrow(imputed) == nrow(values),
    identical(names(imputed), names(values)),
    all(vapply(imputed, is.numeric, logical(1)))
  )
  imputed <- imputed |>
    dplyr::rename_with(\(name) paste0(name, "_midpoint_imputed"))
  result <- dplyr::bind_cols(values, imputed)
  result[absent_form, ] <- NA_real_
  result
}

as_historical_float <- function(value) {
  # SPSS/Stata float storage is part of the historical numeric representation.
  bytes <- writeBin(as.numeric(value), raw(), size = 4)
  readBin(bytes, what = "double", n = length(value), size = 4)
}

summarise_historical_knowledge <- function(before, after,
                                           baseline = rowMeans(before)) {
  stopifnot(
    identical(dim(before), dim(after)),
    all(is.na(before) | before %in% 0:1),
    all(is.na(after) | after %in% 0:1),
    all(rowSums(is.na(before)) %in% c(0L, ncol(before))),
    all(rowSums(is.na(after)) %in% c(0L, ncol(after)))
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
