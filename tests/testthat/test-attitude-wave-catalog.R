source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "attitude_catalog.R"))

test_that("TE exit correction changes only seven catalog endpoints", {
  rebuilt <- arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  ))
  archived <- readr::read_csv(project_path(
    "data", "shared", "codebooks", "attitude_indices", "allpollindices.csv"
  ), show_col_types = FALSE)
  labels <- read_metadata("attitude_index_label_fixes")
  label_rows <- match(labels$t1var, archived$t1var)
  archived$att_index[label_rows] <- labels$reviewed_label
  corrected <- build_attitude_catalog(rebuilt)
  changed <- archived$t2_t3var != corrected$t2_t3var
  expect_equal(sum(changed), 7L)
  expect_true(all(corrected$dpnum[changed] == 7))
  expect_identical(corrected[!changed, ], archived[!changed, ])
  expect_identical(
    dplyr::select(corrected, -"t2_t3var"),
    dplyr::select(archived, -"t2_t3var")
  )
  expected <- sub("t2", "t3", archived$t2_t3var[changed], fixed = TRUE)
  expect_identical(corrected$t2_t3var[changed], expected)
  expect_false(any(grepl("_f$|trade", corrected$t2_t3var[changed])))
  expect_identical(rebuilt, arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  )))
})

test_that("TE reviewed contrasts retain all three distinct survey occasions", {
  rebuilt <- arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  ))
  catalog <- build_attitude_catalog(rebuilt)
  contrasts <- reviewed_attitude_contrasts(catalog)
  main <- contrasts[contrasts$primary, ]
  alternative <- contrasts[!contrasts$primary, ]
  expect_equal(nrow(contrasts), 14L)
  expect_equal(nrow(main), 7L)
  expect_identical(main$attitude_id, alternative$attitude_id)
  expect_identical(main$later_column, alternative$later_column)
  expect_true(all(main$earlier_wave == "t0" & main$later_wave == "t2"))
  expect_true(all(
    alternative$earlier_wave == "t1" & alternative$later_wave == "t2"
  ))
  expect_true(all(main$earlier_phase == "pre_arrival"))
  expect_true(all(alternative$earlier_phase == "arrival"))
  expect_true(all(contrasts$later_phase == "post_deliberation"))
  expect_true(all(main$earlier_wave_instance_id == "tomorrows-europe-2007:T1"))
  expect_true(all(
    alternative$earlier_wave_instance_id == "tomorrows-europe-2007:T2"
  ))
  expect_true(all(
    contrasts$later_wave_instance_id == "tomorrows-europe-2007:T3"
  ))
  people <- rebuilt[rebuilt$dpnum == 7, ]
  expect_equal(nrow(people), 344L)
  expect_equal(dplyr::n_distinct(people$pollgroup), 18L)
  expect_equal(
    colSums(!is.na(people[main$earlier_column])),
    stats::setNames(c(339, 335, 339, 344, 320, 337, 341), main$earlier_column)
  )
  expect_equal(
    colSums(!is.na(people[main$later_column])),
    stats::setNames(c(332, 328, 331, 334, 324, 330, 329), main$later_column)
  )
  directory <- tempfile("attitude-contrast-test-")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  expect_no_error(write_typed_export(
    contrasts, "attitude_contrasts", directory
  ))
  restored <- arrow::read_parquet(file.path(
    directory, "attitude_contrasts.parquet"
  ))
  expect_identical(restored$primary, contrasts$primary)
})


test_that("BTP health labels describe the scored constructs", {
  rebuilt <- arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  ))
  catalog <- build_attitude_catalog(rebuilt)
  expected <- c(
    "btp05.t1fcvsch" = "Support for Charter Schools and Vouchers",
    "btp05.t1costcov" = "Health Care Costs and Coverage",
    "btp05.t1medqual" = "Importance of Improving Medical Care",
    "btp05.t1nclb" = "Opposition to No Child Left Behind"
  )
  rows <- match(names(expected), catalog$t1var)
  expect_false(anyNA(rows))
  expect_identical(catalog$att_index[rows], unname(expected))
  survey <- read_poll_survey("btp-health-education-2005")
  for (wave in 1:2) {
    attitudes <- btp_health_attitudes(survey, wave)
    post <- if (wave == 1L) "" else "post"
    nclb <- as.numeric(survey[[paste0("q12", post)]])
    expect_true(all(attitudes$no_child_left_behind[nclb %in% 1] == 1))
    expect_true(all(attitudes$no_child_left_behind[nclb %in% 5] == 0))
    charter <- survey[[if (wave == 1L) "q7_a" else "q7post_a"]]
    voucher <- survey[[if (wave == 1L) "q7_b" else "q7post_b"]]
    both_support <- charter %in% 10 & voucher %in% 10
    expect_gt(sum(both_support), 0)
    expect_true(all(attitudes$school_choice[both_support] == 1))
  }
})
