source(file.path(root, "R", "respondents.R"))

test_that("all reconstructed plain attitudes retain all-missing inputs", {
  builders <- c(
    "uk-health-1998" = "build_health_individual",
    "uk-eu-1995" = "build_eu_individual",
    "uk-monarchy-1996" = "build_monarchy_individual",
    "uk-general-election-1997" = "build_election_individual",
    "uk-crime-1994" = "build_crime_individual",
    "nic-1996" = "build_nic_individual",
    "bulgaria-crime-2002" = "build_bulgaria_individual",
    "australia-republic-1999" = "build_australia_individual",
    "tomorrows-europe-2007" = "build_tomorrow_individual",
    "europolis-2009" = "build_europolis_individual",
    "btp-general-election-2004" = "build_btp_general_individual",
    "btp-health-education-2005" = "build_btp_health_individual",
    "btp-national-2003" = "build_btp_national_individual",
    "san-mateo-2008" = "build_san_mateo_individual",
    "nic2-2003" = "build_nic2_individual",
    "new-haven-2004" = "build_new_haven_individual",
    "zeguo-2005" = "build_zeguo_individual",
    "btp-presidential-primaries-2004" = "build_btp_primaries_individual"
  )
  utilities <- c("cpl-1996", "wtu-1996", "swepco-1996")
  catalog <- readr::read_csv(project_path(
    "data", "shared", "codebooks", "attitude_indices", "allpollindices.csv"
  ), show_col_types = FALSE)
  fields <- unique(c(catalog$t1var, catalog$t2_t3var))
  targets <- read_metadata("polardata_targets") |>
    dplyr::filter(legacy_field %in% fields)
  definitions <- read_metadata("measure_definitions")
  inputs <- read_metadata("measure_inputs")
  expect_setequal(unique(targets$poll_id), c(names(builders), utilities))
  for (poll in unique(targets$poll_id)) {
    selected <- targets$canonical_definition[targets$poll_id == poll]
    measures <- definitions |>
      dplyr::filter(poll_id == poll, definition_id %in% selected)
    columns <- inputs |>
      dplyr::filter(poll_id == poll, definition_id %in% selected) |>
      dplyr::pull(source_column) |>
      unique()
    expect_true(length(columns) > 0L, info = poll)
    if (poll == "zeguo-2005") {
      columns <- grep("^d20", columns, value = TRUE)
    }
    survey <- read_poll_survey(poll)
    survey[columns] <- NA_real_
    built <- if (poll %in% utilities) {
      build_utility_individual(survey, poll)
    } else {
      get(builders[[poll]])(survey)
    }
    plain <- unique(sub("_midpoint_imputed$", "", measures$measure_id))
    expect_true(all(plain %in% names(built)), info = poll)
    expect_true(all(is.na(as.matrix(built[plain]))), info = poll)
  }
})

test_that("Texas separates missing scores from named midpoint variants", {
  stems <- c("imported_power", "conservation", "low_income_support",
             "renewables", "research", "fossil_fuels")
  fields <- c("BUYPWR", "ADDFAC", "REDUCE", "NEEDTO", "RENEW", "WIND",
              "FEDRCH", "RESCH", "FUELS")
  for (poll in c("wtu-1996", "swepco-1996")) {
    survey <- read_poll_survey(poll)
    row <- which(survey$PART == 1)[1]
    for (wave in 1:2) {
      fixture <- survey
      fixture[row, paste0(fields, wave)] <- NA_real_
      result <- utility_attitudes(fixture, poll, wave)
      plain <- paste0(stems, "_t", wave)
      imputed <- paste0(plain, "_midpoint_imputed")
      expect_setequal(names(result), c(plain, imputed))
      expect_true(all(is.na(result[row, plain])))
      expected <- rep(.5, 6L)
      if (poll == "wtu-1996" && wave == 2L) expected[5] <- 4 / 9
      expect_equal(unname(unlist(result[row, imputed])), expected)
      fixture[[paste0("FEDRCH", wave)]][row] <- 4
      partial <- utility_attitudes(fixture, poll, wave)
      expected_partial <- if (poll == "wtu-1996" && wave == 2L) 1 / 3 else .4
      expect_equal(partial[[paste0("research_t", wave)]][row], expected_partial)
      imputed_research <- paste0("research_t", wave, "_midpoint_imputed")
      expect_equal(partial[[imputed_research]][row], expected_partial)
    }
    after <- utility_attitudes(survey, poll, 2L)
    expect_true(all(is.na(as.matrix(after[survey$PART == 2, ]))))
    before <- utility_attitudes(survey, poll, 1L)
    imputed <- before |>
      dplyr::select(dplyr::ends_with("_midpoint_imputed"))
    competition <- read_utility_value(survey, poll, "compet1", 1:5)
    competition <- (dplyr::coalesce(competition, 5) - 1) / 4
    expected <- historical_available_mean(abs(cbind(imputed, competition) - .5))
    expect_identical(build_utility_individual(survey, poll)$attitude_extremity,
                     expected)
  }
})

test_that("Zeguo separates index blanks from absence in both named variants", {
  survey <- read_poll_survey("zeguo-2005")
  observed <- zeguo_departure_observed(survey)
  before <- zeguo_attitudes(survey, 1L)
  after <- zeguo_attitudes(survey, 2L)
  plain <- names(before)[!endsWith(names(before), "_midpoint_imputed")]
  imputed <- paste0(plain, "_midpoint_imputed")
  expect_equal(length(plain), 9L)
  expect_equal(length(imputed), 9L)
  expect_true(all(is.na(as.matrix(after[!observed, ]))))
  row <- which(survey$p == 90)
  expect_true(observed[row])
  expect_true(all(is.na(after[row, plain])))
  expect_equal(unname(unlist(after[row, imputed])), rep(.5, 9L))
  for (index in seq_along(plain)) {
    for (wave in 1:2) {
      result <- if (wave == 1L) before else after
      included <- if (wave == 1L) rep(TRUE, nrow(survey)) else observed
      available <- !is.na(result[[plain[index]]])
      expect_identical(result[[plain[index]]][available],
                       result[[imputed[index]]][available])
      expect_true(all(result[[imputed[index]]][included & !available] == .5))
    }
  }
  partial <- survey
  partial[row, c("d2014p", "d2020p", "d2021p")] <- list(8, NA_real_, NA_real_)
  scored <- zeguo_attitudes(partial, 2L)
  expect_equal(scored$industrial_roads[row], as_historical_float(.8))
  expect_identical(scored$industrial_roads[row],
                   scored$industrial_roads_midpoint_imputed[row])
  built <- build_zeguo_individual(survey)
  for (wave in 1:2) {
    expect_true(all(paste0(plain, "_t", wave) %in% names(built)))
    expect_true(all(paste0(plain, "_t", wave, "_midpoint_imputed") %in%
                      names(built)))
  }
  expect_identical(built$attitude_extremity,
                   rowMeans(abs(before[imputed] - .5)))
})

test_that("shared imputation names variants and never fills absent forms", {
  values <- tibble::tibble(first = c(0, NA_real_, NA_real_),
                           second = c(.5, 1, NA_real_))
  result <- add_midpoint_imputed_variants(values,
    fallback = c(first = 4 / 9, second = .5),
    absent_form = c(FALSE, FALSE, TRUE)
  )
  expect_identical(result[names(values)], values)
  expect_equal(result$first_midpoint_imputed, c(0, 4 / 9, NA_real_))
  expect_equal(result$second_midpoint_imputed, c(.5, 1, NA_real_))
  expect_error(add_midpoint_imputed_variants(result))
  expect_error(add_midpoint_imputed_variants(
    values, fallback = c(first = .5, wrong = .5)
  ))
  expect_error(add_midpoint_imputed_variants(values,
    absent_form = c(FALSE, NA, TRUE)
  ))
  component_imputed <- values
  component_imputed$second[1] <- .75
  separate <- add_midpoint_imputed_variants(values,
    imputed = component_imputed
  )
  expect_identical(separate[names(values)], values)
  expect_identical(separate$second_midpoint_imputed,
                   component_imputed$second)
  expect_error(add_midpoint_imputed_variants(values,
    imputed = component_imputed[1, ]
  ))
  expect_error(add_midpoint_imputed_variants(values,
    imputed = component_imputed[rev(names(component_imputed))]
  ))
})
