test_that("A1R median uses unique attendees without conditioning on outcomes", {
  survey <- tibble::tibble(
    CONDITION = c(1, 1, 1, 0, 1), GROUP = c(1, 2, 3, NA, NA),
    EDUC4 = c(3, 4, 4, 1, NA)
  )
  participants <- tidyr::expand_grid(
    source_dataset = c("control", "cor_sood"), source_row = 1:5
  ) |>
    dplyr::mutate(
      poll_id = "america-in-one-room-2019", panel = FALSE,
      education_above_median = NA, income_above_median = NA
    )
  result <- add_analysis_a1r_median_flags(participants, survey)
  expect_identical(
    result$education_above_median, rep(c(FALSE, FALSE, FALSE, FALSE, NA), 2)
  )
  expect_identical(
    dplyr::select(result, -"education_above_median"),
    dplyr::select(participants, -"education_above_median")
  )
  subset <- participants[1, ]
  expect_false(add_analysis_a1r_median_flags(
    subset, survey
  )$education_above_median)
  survey$EDUC4[1:3] <- NA_real_
  expect_true(all(is.na(add_analysis_a1r_median_flags(
    participants, survey
  )$education_above_median)))
})

test_that("A1R deposited education has no category above the attendee median", {
  survey <- readr::read_tsv(project_path(
    "data", "america-in-one-room-2019", "participants.tab"
  ), show_col_types = FALSE)
  attendee <- survey$CONDITION == 1 & !is.na(survey$GROUP)
  expect_equal(sum(attendee), 526L)
  expect_equal(
    as.integer(table(survey$EDUC4[attendee])), c(7L, 44L, 206L, 269L)
  )
  expect_equal(stats::median(survey$EDUC4[attendee]), 4)
  participants <- tibble::tibble(
    poll_id = "america-in-one-room-2019", source_dataset = "control",
    source_row = seq_len(nrow(survey)), panel = survey$POST == 1,
    education_above_median = NA
  )
  result <- add_analysis_a1r_median_flags(participants)
  expect_equal(nrow(result), 3842L)
  expect_identical(result$panel, participants$panel)
  expect_type(result$education_above_median, "logical")
  expect_identical(result$education_above_median, rep(FALSE, 3842L))
})
