source(project_path("R", "source_zeguo.R"))

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
    scores[!zeguo_departure_observed(survey), ] <- NA_real_
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
    value[is.nan(value)] <- NA_real_
    value
  }
  result <- tibble::tibble(
    industrial_roads = mean_items(c(14, 20, 21)),
    village_roads = mean_items(c(7, 10, 11)),
    main_roads = mean_items(c(15:19, 22)),
    commercial_roads = mean_items(12:13),
    wenchang_main_avenue = mean_items(6),
    other_parks = mean_items(c(24, 28, 29), FALSE) / 10,
    township_image = mean_items(c(25, 31), FALSE) / 10,
    cultural_heritage = mean_items(c(25, 32)),
    sewage = mean_items(c(30, 33:35))
  )
  absent <- if (wave == 2L) !zeguo_departure_observed(survey)
  else rep(FALSE, nrow(survey))
  add_midpoint_imputed_variants(result, absent_form = absent)
}

zeguo_public_works <- function(survey, wave) {
  stopifnot(wave %in% 1:2, length(wave) == 1L)
  suffix <- if (wave == 1L) "" else "p"
  fields <- paste0("d20", sprintf("%02d", c(8, 9, 25, 27)), suffix)
  components <- purrr::map(fields, \(field) {
    allowed <- switch(field, d2027 = c(0:10, 5.5),
      d2008p = c(0:10, 6.5), 0:10
    )
    read_source_codes(survey, field, allowed)
  })
  value <- as_historical_float(rowMeans(as.data.frame(components),
    na.rm = TRUE
  )) / 10
  value[is.nan(value)] <- NA_real_
  absent <- if (wave == 2L) !zeguo_departure_observed(survey)
  else rep(FALSE, nrow(survey))
  add_midpoint_imputed_variants(
    tibble::tibble(township_image_public_works = value),
    absent_form = absent
  )
}

build_zeguo_individual <- function(survey = read_poll_survey("zeguo-2005")) {
  before <- zeguo_knowledge_items(survey, "pre")
  after <- zeguo_knowledge_items(survey, "post")
  baseline <- zeguo_attitudes(survey, 1L)
  post <- zeguo_attitudes(survey, 2L)
  historical_indices <- c(
    "industrial_roads", "village_roads", "main_roads", "commercial_roads",
    "wenchang_main_avenue", "other_parks", "township_image",
    "cultural_heritage", "sewage"
  )
  historical_baseline <- baseline |>
    dplyr::select(dplyr::all_of(paste0(
      historical_indices, "_midpoint_imputed"
    )))
  extremity <- rowMeans(abs(historical_baseline - .5))
  baseline <- dplyr::bind_cols(baseline, zeguo_public_works(survey, 1L))
  post <- dplyr::bind_cols(post, zeguo_public_works(survey, 2L))
  wave_names <- function(names, wave) {
    ifelse(endsWith(names, "_midpoint_imputed"),
      sub("_midpoint_imputed$", paste0("_t", wave, "_midpoint_imputed"), names),
      paste0(names, "_t", wave)
    )
  }
  education <- recode_source_values(survey, "Education",
    c(0, 0, 0, .33, .66, .66, 1)
  )
  age <- read_source_codes(survey, "Age", 0:100)
  corrected <- which(survey$p == 125)
  if (length(corrected)) {
    stopifnot(length(corrected) == 1L, age[corrected] == 1,
      as.numeric(unclass(survey[["____1p"]][corrected])) == 33
    )
    age[corrected] <- 33
  }
  dplyr::bind_cols(
    dplyr::rename_with(baseline, \(name) wave_names(name, 1L)),
    dplyr::rename_with(post, \(name) wave_names(name, 2L)),
    summarise_historical_knowledge(before, after),
    tibble::tibble(
      age = age,
      female = recode_source_values(survey, "Gender", c(0, 1)),
      education_four = education,
      education_three = collapse_historical_education(education),

      attitude_extremity = extremity,
      household_income = NA_real_, minority = NA_real_,
      political_interest_t1 = NA_real_, read_briefing = NA_real_,
      knowledge_midterm = NA_real_, knowledge_midterm_joint = NA_real_,
      knowledge_joint_midterm = NA_real_, attitude_extremity_midterm = NA_real_
    )
  )
}
