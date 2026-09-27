source(file.path(root, "R", "respondents.R"))

test_that("Bulgaria builds from raw answers without stored indices", {
  survey <- read_poll_survey("bulgaria-crime-2002")
  expected <- build_bulgaria_individual(survey)
  raw <- survey[, !grepl("^t[12]", names(survey))]
  expect_equal(build_bulgaria_individual(raw), expected)
  order <- rev(seq_len(nrow(raw)))
  expect_equal(build_bulgaria_individual(raw[order, ]), expected[order, ])
  raw$q15_1[1] <- 7
  expect_error(build_bulgaria_individual(raw), "Unreviewed source codes")
})

test_that("Bulgaria Version E is reconstructed at original float precision", {
  survey <- read_poll_survey("bulgaria-crime-2002")
  for (wave in 1:2) {
    built <- bulgaria_attitudes(survey, wave)
    expect_equal(built$civil_liberties,
                 as.numeric(survey[[paste0("t", wave, "clibe")]]))
    expect_equal(built$tougher_punishment,
                 as.numeric(survey[[paste0("t", wave, "tghpc")]]))
  }
})

test_that("Bulgaria death-penalty agreement spans both scale endpoints", {
  survey <- read_poll_survey("bulgaria-crime-2002")
  expected <- c(1, 2 / 3, 1 / 3, 0)
  for (wave in 1:2) {
    source <- if (wave == 1L) "q19" else "q19p"
    codes <- as.numeric(survey[[source]])
    scores <- bulgaria_attitudes(survey, wave)$death_penalty
    for (code in 1:4) {
      expect_true(any(codes == code, na.rm = TRUE))
      expect_equal(unique(scores[which(codes == code)]), expected[code])
    }
    expect_true(all(is.na(scores[is.na(codes) | codes == 99])))
  }
})

test_that("Bulgaria individual and group high-income rules agree", {
  survey <- read_poll_survey("bulgaria-crime-2002")
  individual <- build_bulgaria_individual(survey)
  source_income <- as.numeric(survey$incomes)
  expect_equal(sum(individual$high_income == 1, na.rm = TRUE), 28L)
  expect_equal(sum(is.na(individual$high_income)), 5L)
  in_band_four <- !is.na(source_income) & source_income == 4
  in_band_three <- !is.na(source_income) & source_income == 3
  expect_equal(individual$high_income[in_band_four],
               rep(1, sum(in_band_four)))
  expect_equal(individual$high_income[in_band_three],
               rep(0, sum(in_band_three)))
  wide <- arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  )) |>
    dplyr::filter(.data$pollid == 53)
  shares <- wide |>
    dplyr::group_by(.data$pollgroup) |>
    dplyr::summarise(computed = mean(.data$highinc, na.rm = TRUE),
                     stored = dplyr::first(.data$phighinc), .groups = "drop")
  expect_equal(shares$computed, shares$stored, tolerance = 1e-8)
})

test_that("Bulgaria matches reviewed BGC-03 and BGC-04 corrections", {
  audit <- readr::read_csv(project_path("audit", "respondent_parity.csv"),
    show_col_types = FALSE
  )
  rows <- audit[audit$poll_id == "bulgaria-crime-2002", ]
  expect_equal(nrow(rows), 51L)
  expect_true(all(rows$respondents == 278L))
  changed <- rows[rows$value_differences > 0L, ]
  expect_setequal(changed$legacy_field, c(
    "bulgaria.bulgaria.t1q19", "bulgaria.bulgaria.t2q19", "attextreme",
    "highinc"
  ))
  expect_equal(changed$value_differences[
    match(c("bulgaria.bulgaria.t1q19", "bulgaria.bulgaria.t2q19",
            "attextreme", "highinc"), changed$legacy_field)
  ], c(131L, 170L, 131L, 165L))
  expect_true(all(rows$unexplained_differences == 0L))
  expect_true(all(rows$missingness_differences == 0L))
})
