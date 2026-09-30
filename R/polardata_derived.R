reviewed_peer_component <- function(value, group, n_items) {
  component <- as_historical_float(observed_peer_mean(value, group) / n_items)
  component[value %in% 1] <- 0
  component[is.na(value)] <- NA_real_
  component
}

historical_group_summary <- function(value, group, statistic = mean) {
  stopifnot(length(value) == length(group))
  result <- rep(NA_real_, length(value))
  rows <- split(which(!is.na(group)), group[!is.na(group)])
  for (index in rows) result[index] <- statistic(value[index], na.rm = TRUE)
  result[is.nan(result)] <- NA_real_
  result
}

apply_peer_opportunity_ceiling <- function(gain, scored_items, group) {
  scored_items <- as.matrix(scored_items)
  stopifnot(
    is.numeric(scored_items), ncol(scored_items) > 0L,
    nrow(scored_items) == length(gain), length(group) == length(gain)
  )
  known <- !is.na(scored_items) & abs(scored_items - 1) <= 1e-10
  complete_ceiling <- rowSums(known) == ncol(scored_items)
  size <- historical_group_summary(rep(1, length(group)), group, sum)
  has_peers <- !is.na(group) & !is.na(size) & size > 1
  gain[!has_peers] <- NA_real_
  gain[complete_ceiling & has_peers] <- 0
  gain
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

covariance_spectrum <- function(covariance) {
  stopifnot(is.matrix(covariance), nrow(covariance) == ncol(covariance))
  values <- if (all(is.finite(covariance))) {
    eigen(covariance, symmetric = TRUE, only.values = TRUE)$values
  } else {
    rep(NA_real_, ncol(covariance))
  }
  tolerance <- if (all(is.finite(values))) {
    64 * .Machine$double.eps * ncol(covariance) * max(abs(values))
  } else {
    NA_real_
  }
  list(values = values, tolerance = tolerance)
}

historical_genvar <- function(attitudes) {
  attitudes <- as.matrix(attitudes)
  stopifnot(is.numeric(attitudes), ncol(attitudes) > 0L)
  covariance <- stats::cov(attitudes, use = "pairwise.complete.obs")
  spectrum <- covariance_spectrum(covariance)
  if (anyNA(spectrum$values) ||
        any(spectrum$values < -spectrum$tolerance)) {
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
