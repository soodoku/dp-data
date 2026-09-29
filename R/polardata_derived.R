historical_group_summary <- function(value, group, statistic = mean) {
  stopifnot(length(value) == length(group))
  result <- rep(NA_real_, length(value))
  rows <- split(which(!is.na(group)), group[!is.na(group)])
  for (index in rows) result[index] <- statistic(value[index], na.rm = TRUE)
  result[is.nan(result)] <- NA_real_
  result
}

observed_peer_mean <- function(value, group) {
  stopifnot(
    is.numeric(value), length(value) == length(group),
    all(is.finite(value) | is.na(value))
  )
  observed <- !is.na(value)
  total <- historical_group_summary(value, group, sum)
  count <- historical_group_summary(as.numeric(observed), group, sum)
  peers <- count - as.numeric(observed)
  focal <- ifelse(observed, value, 0)
  result <- (total - focal) / peers
  result[is.na(peers) | peers == 0] <- NA_real_
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

historical_composition <- function(values, group) {
  stopifnot(
    length(group) == nrow(values),
    length(values$high_income) == nrow(values)
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
    phighinc = average(values$high_income),
    meanxtreme = average(values$attitude_extremity),
    pfemale_ind = observed_peer_mean(values$female, group),
    entropy = combined_entropy
  )
}
