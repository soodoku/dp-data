zeguo_knowledge_items <- function(survey, wave) {
  fields <- paste0(wave, "_d304", 3:6)
  values <- purrr::map(fields, function(field) {
    as.numeric(read_source_codes(survey, field, c(0:6, 98)) %in% 3)
  })
  names(values) <- fields
  scores <- as.matrix(tibble::as_tibble(values))
  if (wave == "post") {
    path <- project_path("data", "zeguo-2005", "source-materials",
      "knowledge-reconciliation.csv"
    )
    ledger <- readr::read_csv(path, show_col_types = FALSE)
    stopifnot(!anyDuplicated(paste(ledger$p, ledger$item)),
      all(ledger$item %in% fields), all(ledger$historical_score %in% 0:1)
    )
    for (row in seq_len(nrow(ledger))) {
      index <- which(survey$p == ledger$p[row])
      if (!length(index)) next
      value <- survey[[ledger$item[row]]][index]
      original <- ledger$original_answer[row]
      stopifnot(length(index) == 1L,
        identical(is.na(value), is.na(original)),
        is.na(original) || value == original
      )
      scores[index, ledger$item[row]] <- ledger$historical_score[row]
    }
  }
  scores
}

zeguo_attitudes <- function(survey, wave) {
  suffix <- if (wave == 1L) "" else "p"
  item <- function(number, scaled = TRUE) {
    field <- paste0("d20", sprintf("%02d", number), suffix)
    allowed <- if (wave == 1L && number == 7L) c(0:10, 4.5) else 0:10
    value <- read_source_codes(survey, field, allowed)
    if (!scaled) return(value)
    value <- as_historical_float(value / 10)
    value
  }
  mean_items <- function(numbers, scaled = TRUE) {
    value <- as_historical_float(rowMeans(
      as.data.frame(purrr::map(numbers, item, scaled = scaled)), na.rm = TRUE
    ))
    value[is.na(value)] <- if (scaled) .5 else 5
    value
  }
  tibble::tibble(
    industrial_roads = mean_items(c(14, 20, 21)),
    village_roads = mean_items(c(7, 10, 11)),
    main_roads = mean_items(c(15:19, 22)),
    commercial_roads = mean_items(12:13),
    main_roads_rescaled = mean_items(c(15:19, 22), FALSE) / 10,
    other_parks = mean_items(c(24, 28, 29), FALSE) / 10,
    township_image = mean_items(c(25, 31), FALSE) / 10,
    cultural_heritage = mean_items(c(25, 32)),
    sewage = mean_items(c(30, 33:35))
  )
}

build_zeguo_individual <- function(survey = read_poll_survey("zeguo-2005")) {
  before <- zeguo_knowledge_items(survey, "pre")
  after <- zeguo_knowledge_items(survey, "post")
  baseline <- zeguo_attitudes(survey, 1L)
  post <- zeguo_attitudes(survey, 2L)
  extremity <- rowMeans(abs(baseline - .5))
  education <- recode_source_values(survey, "Education",
    c(0, 0, 0, .33, .66, .66, 1)
  )
  dplyr::bind_cols(
    dplyr::rename_with(baseline, \(name) paste0(name, "_t1")),
    dplyr::rename_with(post, \(name) paste0(name, "_t2")),
    summarise_historical_knowledge(before, after),
    tibble::tibble(
      age = read_source_codes(survey, "Age", 0:100),
      female = recode_source_values(survey, "Gender", c(0, 1)),
      education_four = education,
      education_three = collapse_historical_education(education),
      higher_education = as.numeric(education > 0),
      attitude_extremity = extremity,
      household_income = NA_real_, high_income = NA_real_, minority = NA_real_,
      political_interest_t1 = NA_real_, read_briefing = NA_real_,
      knowledge_midterm = NA_real_, knowledge_midterm_joint = NA_real_,
      knowledge_joint_midterm = NA_real_, attitude_extremity_midterm = NA_real_
    )
  )
}
