australia_source_codes <- function(survey, field, allowed) {
  position <- match(tolower(field), tolower(names(survey)))
  if (is.na(position)) stop("Missing source field: ", field)
  value <- as.numeric(unclass(survey[[position]]))
  if (any(!is.na(value) & !value %in% allowed)) {
    stop("Unreviewed source codes in ", field)
  }
  value
}

australia_knowledge_items <- function(survey, wave) {
  keys <- c(qrole = 4, rempres = 2, ggrole = 4, presrol = 4,
    welfare = 3, busines = 1, ridgewy = 4, jgeorge = 4
  )
  closed <- purrr::imap(keys, function(correct, stem) {
    value <- australia_source_codes(survey, paste0(stem, wave), c(1:5, 96:100))
    as.numeric(value == correct)
  })
  keys <- c(flagchg = 1, anthem = 1, wdroyal = 2, pargame = 1)
  symbolic <- purrr::imap(keys, function(correct, stem) {
    value <- australia_source_codes(survey, paste0(stem, wave), c(1:2, 96:100))
    if (wave == 1L) {
      as.numeric(value == correct)
    } else {
      value[value %in% c(96:98, 100)] <- NA_real_
      as.numeric(value == correct)
    }
  })
  as.matrix(tibble::as_tibble(c(closed, symbolic)))
}

australia_ranking <- function(survey, wave) {
  read <- function(stem, w = wave) {
    australia_source_codes(survey, paste0(stem, w), c(1:3, 97, 99, 100))
  }
  first <- read("firstop")
  second <- read("secop")
  republic <- rep(NA_real_, nrow(survey))
  republic[which(first == 3)] <- 0
  midway <- if (wave == 1L) c(3, 97, 100) else c(3, 97, 99)
  republic[which(second %in% midway)] <- .5
  republic[which(first != 3 & second != 3 & second < 90)] <- 1
  popular <- rep(NA_real_, nrow(survey))
  popular[which(first == 1 & second == 3)] <- 1
  popular[which((first == 1 & second == 2) |
                  (first == 3 & second == 1))] <- .75
  # The historical wave-two midpoint condition reads wave-three rankings.
  unsure <- if (wave == 2L) read("firstop", 3L) == 97 |
    read("secop", 3L) == 97 else first == 97 | second == 97
  popular[which(!is.na(first) & !is.na(second) &
                  (unsure | (first == 3 & second == 3)))] <- .5
  popular[which((first == 2 & second == 1) |
                  (first == 3 & second == 2))] <- .25
  popular[which(first == 2 & second == 3)] <- 0
  ties <- australia_source_codes(survey, paste0("tiesbr", wave),
    c(1:5, 97, 99, 100)
  )
  ties[ties > 5 & !is.na(ties)] <- NA_real_
  head <- australia_source_codes(survey, paste0("headaus", wave),
    c(1:5, 97, 99, 100)
  )
  head[head > 5 & !is.na(head)] <- NA_real_
  republican <- rowMeans(cbind(republic, (5 - ties) / 4, (head - 1) / 4),
    na.rm = TRUE
  )
  republican[is.nan(republican)] <- NA_real_
  tibble::tibble(popular = popular, republican = republican)
}

australia_original_attitudes <- function(survey) {
  read <- function(stem, reverse = FALSE) {
    value <- australia_source_codes(survey, paste0(stem, 1L), c(1:5, 94:103))
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
  tibble::tibble(
    autonomy = average(c("moreind", "stanwor", "qbritin")),
    workability = average(workability, workability),
    democracy = average(c("moredem", "quedem"), "quedem"),
    tradition = average(c("brither", "preserv")),
    politicization = average(c("prespol", "ppchpre"), "prespol")
  )
}

build_australia_individual <- function(
  survey = read_poll_survey("australia-republic-1999")) {
  read <- function(field, allowed) {
    australia_source_codes(survey, field, allowed)
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
  attitudes <- australia_original_attitudes(survey)
  # Capitalized column references in the historical script resolve to NULL.
  extremity <- abs(attitudes$workability - .5)
  tibble::tibble(
    popular_t1 = ranking_before$popular, popular_t2 = ranking_after$popular,
    republican_t1 = ranking_before$republican,
    republican_t2 = ranking_after$republican,
    knowledge_t1 = baseline, knowledge_t2 = post, knowledge_joint = joint,
    knowledge_gain = post - baseline, knowledge_gain_joint = post - joint,
    log_knowledge_joint = historical_log_score(joint),
    high_knowledge_joint = as.numeric(joint > .6),
    knowledge_midterm = NA_real_, knowledge_midterm_joint = NA_real_,
    knowledge_joint_midterm = NA_real_, issue_knowledge = NA_real_,
    age = read("age", c(18:88, 98)),
    female = as.numeric(read("gender", 1:2) == 2),
    minority = as.numeric(read("overseas", c(1:2, 100)) < 2),
    education_four = education,
    education_three = collapse_historical_education(education),
    higher_education = as.numeric(education == 1),
    household_income = income, high_income = as.numeric(income > .66),
    political_interest_t1 = c(0, .33, .66, 1)[read("intpol1", c(1:4, 97))],
    read_briefing = NA_real_, attitude_extremity = extremity,
    attitude_extremity_midterm = NA_real_
  )
}
