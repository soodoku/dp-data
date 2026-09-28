historical_group_summary <- function(value, group, statistic = mean) {
  stopifnot(length(value) == length(group))
  result <- rep(NA_real_, length(value))
  rows <- split(which(!is.na(group)), group[!is.na(group)])
  for (index in rows) result[index] <- statistic(value[index], na.rm = TRUE)
  result[is.nan(result)] <- NA_real_
  result
}

categorical_entropy <- function(value) {
  stopifnot(is.numeric(value), all(is.finite(value) | is.na(value)))
  frequencies <- table(round(value, 2))
  if (!length(frequencies)) {
    return(NA_real_)
  }
  probabilities <- as.numeric(frequencies) / sum(frequencies)
  -sum(probabilities * log2(probabilities))
}

historical_genvar <- function(attitudes) {
  attitudes <- as.matrix(attitudes)
  stopifnot(is.numeric(attitudes), ncol(attitudes) > 0L)
  covariance <- stats::cov(attitudes, use = "pairwise.complete.obs")
  if (anyNA(covariance)) {
    return(NA_real_)
  }
  determinant <- det(covariance)
  sqrt(sqrt(determinant^2)^(1 / ncol(attitudes)))
}

historical_group_dispersion <- function(attitudes, group) {
  attitudes <- as.matrix(attitudes)
  stopifnot(nrow(attitudes) == length(group), ncol(attitudes) > 0L)
  result <- tibble::tibble(
    average_sd = rep(NA_real_, length(group)),
    generalized_variance = rep(NA_real_, length(group))
  )
  rows <- split(which(!is.na(group)), group[!is.na(group)])
  for (index in rows) {
    values <- attitudes[index, , drop = FALSE]
    result$average_sd[index] <- mean(apply(values, 2, stats::sd, na.rm = TRUE))
    result$generalized_variance[index] <- historical_genvar(values)
  }
  result
}

historical_composition <- function(values, group, early_high_income) {
  stopifnot(
    length(group) == nrow(values),
    length(early_high_income) == nrow(values)
  )
  average <- function(value) historical_group_summary(value, group)
  size <- historical_group_summary(rep(1, length(group)), group, sum)
  female <- average(values$female)
  education_variance <- historical_group_summary(
    values$education_four, group,
    stats::var
  )
  entropy <- purrr::map(
    list(values$female, values$minority, values$education_four),
    function(value) {
      historical_group_summary(value, group, function(x, ...) {
        categorical_entropy(x)
      })
    }
  ) |> do.call(what = cbind)
  combined_entropy <- rowSums(entropy, na.rm = TRUE)
  combined_entropy[rowSums(!is.na(entropy)) == 0L] <- NA_real_
  tibble::tibble(
    groupsize = size, pfemale = female, pminority = average(values$minority),
    varfemale = female * (1 - female), sdfemale = sqrt(female * (1 - female)),
    vareduc = education_variance, sdeduc = sqrt(education_variance),
    meaned = average(values$education_four), meanage = average(values$age),
    phighinc = average(early_high_income),
    meanxtreme = average(values$attitude_extremity),
    pfemale_ind = (female * size - values$female) / (size - 1),
    entropy = combined_entropy
  )
}
