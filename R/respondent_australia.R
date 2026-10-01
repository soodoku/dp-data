australia_knowledge_items <- function(survey, wave) {
  keys <- c(qrole = 4, rempres = 2, ggrole = 4, presrol = 4,
    welfare = 3, busines = 1, ridgewy = 4, jgeorge = 4
  )
  closed <- purrr::imap(keys, function(correct, stem) {
    value <- read_source_codes_ignore_case(
      survey, paste0(stem, wave), c(1:5, 96:100)
    )
    as.numeric(value == correct)
  })
  keys <- c(flagchg = 1, anthem = 1, wdroyal = 2, pargame = 1)
  symbolic <- purrr::imap(keys, function(correct, stem) {
    value <- read_source_codes_ignore_case(
      survey, paste0(stem, wave), c(1:2, 96:100)
    )
    if (wave == 1L) {
      score <- as.numeric(value == correct)
      none_or_dk <- australia_checklist_none_or_dk(
        survey, rep(paste0(stem, wave), nrow(survey))
      ) & value %in% 1:2
      score[none_or_dk] <- 0
      score
    } else {
      value[value %in% c(96:98, 100)] <- NA_real_
      as.numeric(value == correct)
    }
  })
  as.matrix(tibble::as_tibble(c(closed, symbolic)))
}

australia_ranking <- function(survey, wave) {
  read <- function(stem) {
    read_source_codes_ignore_case(
      survey, paste0(stem, wave), c(1:3, 97, 99, 100)
    )
  }
  first <- read("firstop")
  second <- read("secop")
  ties <- read_source_codes_ignore_case(survey, paste0("tiesbr", wave),
    c(1:5, 97, 99, 100)
  )
  ties[ties > 5 & !is.na(ties)] <- NA_real_
  head <- read_source_codes_ignore_case(survey, paste0("headaus", wave),
    c(1:5, 97, 99, 100)
  )
  head[head > 5 & !is.na(head)] <- NA_real_
  rank_values <- function(first, second, impute) {
    if (!impute) {
      first[!first %in% 1:3] <- NA_real_
      second[!second %in% 1:3] <- NA_real_
    }
    republic <- rep(NA_real_, nrow(survey))
    midway <- if (!impute) 3 else if (wave == 1L) c(3, 97, 100)
    else c(3, 97, 99)
    republic[which(second %in% midway)] <- .5
    republic[which(first != 3 & second != 3 & second < 90)] <- 1
    republic[which(first == 3)] <- 0
    popular <- rep(NA_real_, nrow(survey))
    popular[which(first == 1 & second == 3)] <- 1
    popular[which((first == 1 & second == 2) |
                    (first == 3 & second == 1))] <- .75
    unsure <- first == 97 | second == 97
    popular[which(!is.na(first) & !is.na(second) &
                    (unsure | (first == 3 & second == 3)))] <- .5
    popular[which((first == 2 & second == 1) |
                    (first == 3 & second == 2))] <- .25
    popular[which(first == 2 & second == 3)] <- 0
    republican <- rowMeans(cbind(republic, (5 - ties) / 4, (head - 1) / 4),
      na.rm = TRUE
    )
    republican[is.nan(republican)] <- NA_real_
    tibble::tibble(popular = popular, republican = republican)
  }
  add_midpoint_imputed_variants(
    rank_values(first, second, FALSE),
    imputed = rank_values(first, second, TRUE)
  )
}

australia_original_attitudes <- function(
  survey, indices = c(
    "autonomy", "workability", "democracy", "tradition", "politicization"
  )
) {
  read <- function(stem, reverse = FALSE) {
    value <- read_source_codes_ignore_case(
      survey, paste0(stem, 1L), c(1:5, 94:103)
    )
    value[value > 5 & !is.na(value)] <- NA_real_
    if (reverse) (5 - value) / 4 else (value - 1) / 4
  }
  average <- function(stems, reverse = character()) {
    values <- purrr::map(stems, \(stem) read(stem, stem %in% reverse))
    frame <- tibble::as_tibble(values, .name_repair = "unique_quiet")
    value <- rowMeans(as.matrix(frame), na.rm = TRUE)
    value[is.nan(value)] <- NA_real_
    value
  }
  workability <- c("pmpower", "polstab", "confron", "stweak",
    "repexp", "constrd"
  )
  items <- list(
    autonomy = c("moreind", "stanwor", "qbritin"),
    workability = workability, democracy = c("moredem", "quedem"),
    tradition = c("brither", "preserv"),
    politicization = c("prespol", "ppchpre")
  )
  reverse <- list(workability = workability, democracy = "quedem",
    politicization = "prespol"
  )
  stopifnot(!anyDuplicated(indices), all(indices %in% names(items)))
  purrr::imap(items[indices], function(stems, index) {
    average(stems, reverse[[index]])
  }) |>
    tibble::as_tibble()
}

build_australia_individual <- function(
  survey = read_poll_survey("australia-republic-1999")) {
  read <- function(field, allowed) {
    read_source_codes_ignore_case(survey, field, allowed)
  }
  before <- australia_knowledge_items(survey, 1L)
  after <- australia_knowledge_items(survey, 2L)
  baseline <- rowMeans(before)
  post <- rowMeans(after)
  joint <- rowMeans(before * after)
  ranking_before <- australia_ranking(survey, 1L)
  ranking_after <- australia_ranking(survey, 2L)
  education <- c(0, .33, .66, 1, 1)[read("edulev", c(1:5, 98))]
  income <- c(.16, .33, .5, .66, .83, 1)[read("income", c(1:6, 97, 98))]
  age <- dplyr::na_if(read("age", c(18:88, 98)), 98)
  extremity_indices <- c(
    "workability", "democracy", "tradition", "politicization"
  )
  attitudes <- australia_original_attitudes(survey, extremity_indices)
  extremity <- rowMeans(
    abs(as.matrix(attitudes[extremity_indices]) - .5), na.rm = TRUE
  )
  extremity[is.nan(extremity)] <- NA_real_
  tibble::tibble(
    popular_t1 = ranking_before$popular, popular_t2 = ranking_after$popular,
    republican_t1 = ranking_before$republican,
    republican_t2 = ranking_after$republican,
    popular_t1_midpoint_imputed = ranking_before$popular_midpoint_imputed,
    popular_t2_midpoint_imputed = ranking_after$popular_midpoint_imputed,
    republican_t1_midpoint_imputed = ranking_before$republican_midpoint_imputed,
    republican_t2_midpoint_imputed = ranking_after$republican_midpoint_imputed,
    knowledge_t1 = baseline, knowledge_t2 = post, knowledge_joint = joint,
    knowledge_gain = post - baseline, knowledge_gain_joint = post - joint,
    log_knowledge_joint = historical_log_score(joint),
    high_knowledge_joint = as.numeric(joint > .6),
    knowledge_midterm = NA_real_, knowledge_midterm_joint = NA_real_,
    knowledge_joint_midterm = NA_real_, issue_knowledge = NA_real_,
    age = age,
    female = as.numeric(read("gender", 1:2) == 2),
    minority = as.numeric(read("overseas", c(1:2, 100)) < 2),
    education_four = education,
    education_three = collapse_historical_education(education),

    household_income = income,
    political_interest_t1 = c(0, .33, .66, 1)[read("intpol1", c(1:4, 97))],
    read_briefing = NA_real_, attitude_extremity = extremity,
    attitude_extremity_midterm = NA_real_
  )
}
