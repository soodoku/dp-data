nic_source_codes <- function(survey, field, allowed) {
  if (!field %in% names(survey)) stop("Missing source field: ", field)
  value <- rounded_source_code(survey[[field]])
  if (any(!is.na(value) & !value %in% allowed)) {
    stop("Unreviewed source codes in ", field)
  }
  value
}

nic_knowledge_items <- function(survey, wave) {
  read <- function(stem, allowed) {
    nic_source_codes(survey, paste0(stem, wave), allowed)
  }
  bounds <- list(WEDLOCK = c(25, 40), AFDC = c(1, 10), UNEMP = c(5, 10))
  open <- purrr::imap(bounds, function(interval, stem) {
    field <- paste0(stem, wave)
    if (!field %in% names(survey)) stop("Missing source field: ", field)
    value <- as.numeric(survey[[field]])
    close <- !is.na(value) & abs(value - round(value)) < 1e-8
    value[close] <- round(value[close])
    stopifnot(all(is.na(value) | (value >= 0 & value <= 999)))
    as.numeric(!is.na(value) & value >= interval[1] & value <= interval[2])
  })
  keys <- c(SPEND = 3, TRADE = 1, TROOPSA = 1, TROOPSB = 1,
    TROOPSC = 0, TROOPSD = 1
  )
  closed <- purrr::imap(keys, function(correct, stem) {
    allowed <- if (startsWith(stem, "TROOPS")) c(0, 1, 8) else c(1:4, 8)
    if (stem == "SPEND" && wave == 2L) allowed <- c(allowed, 9)
    as.numeric(read(stem, allowed) %in% correct)
  })
  placements <- list(
    republican = as.numeric(read("POLREP", 1:8) %in% 5:7),
    democratic = as.numeric(read("POLDEM", 1:8) %in% 1:3)
  )
  as.matrix(tibble::as_tibble(c(open, closed, placements)))
}

nic_attitudes <- function(survey, wave) {
  stems <- c(environment = "SPENVIR", medicare = "SPMEDIC", law = "SPLAW",
    drugs = "SPDRUG", education = "SPEDUC", defense = "SPDEF",
    foreign_aid = "SPFAID", welfare = "SPWELF", social_security = "SPSS"
  )
  purrr::map(stems, function(stem) {
    allowed <- if (stem == "SPDRUG" && wave == 2L) c(1:3, 8, 9)
    else c(1:3, 8)
    value <- nic_source_codes(survey, paste0(stem, wave), allowed)
    value[is.na(value) | value > 4] <- 2
    (value - 1) / 2
  }) |> tibble::as_tibble()
}

build_nic_individual <- function(survey = read_poll_survey("nic-1996")) {
  before <- nic_knowledge_items(survey, 1L)
  arrival <- nic_knowledge_items(survey, 2L)
  after <- nic_knowledge_items(survey, 3L)
  baseline <- nic_attitudes(survey, 1L)
  midterm <- nic_attitudes(survey, 2L)
  post <- nic_attitudes(survey, 3L)
  # The historical arrival summary retains three baseline items.
  midterm[, 7:9] <- baseline[, 7:9]
  education <- nic_source_codes(survey, "EDLEVEL1", c(1:13, 99))
  education <- dplyr::case_when(
    education %in% 1:3 ~ 0, education %in% 4:7 ~ .33,
    education %in% 8:10 ~ .66, education %in% 11:13 ~ 1,
    .default = NA_real_
  )
  interest <- nic_source_codes(survey, "POLINTR1", c(1:4, 8))
  interest[interest == 8 & !is.na(interest)] <- NA_real_
  briefing <- nic_source_codes(survey, "READDIS2", 1:5)
  dplyr::bind_cols(
    dplyr::rename_with(baseline, \(name) paste0(name, "_t1")),
    dplyr::rename_with(post, \(name) paste0(name, "_t2")),
    summarise_historical_knowledge(before, after),
    tibble::tibble(
      knowledge_midterm = rowMeans(arrival),
      knowledge_midterm_joint = rowMeans(arrival * after),
      knowledge_joint_midterm = rowMeans(before * arrival * after),
      age = 96 - nic_source_codes(survey, "BYEAR", 0:99),
      female = as.numeric(nic_source_codes(survey, "SEX1", 1:2) == 2),
      minority = as.numeric(nic_source_codes(survey, "RACE1", 1:6) != 1),
      education_four = education,
      education_three = collapse_historical_education(education),
      higher_education = as.numeric(education >= .66),
      household_income = NA_real_, high_income = NA_real_,
      political_interest_t1 = (interest - 1) / 3,
      read_briefing = c(0, .33, .33, .66, 1)[briefing],
      attitude_extremity = rowMeans(abs(as.matrix(baseline) - .5)),
      attitude_extremity_midterm = rowMeans(abs(as.matrix(midterm) - .5))
    )
  )
}
