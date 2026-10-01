test_that("shared assembly uses observed peers for each knowledge measure", {
  values <- tibble::tibble(
    female = c(0, 1, 0, 1, 0), minority = 0, educ4 = .5, ppage = .5,
    attextreme = .25, highinc = 0,
    t1know = c(NA, .25, .75, NA, NA),
    t1knowcor = c(NA, .2, .6, NA, NA),
    t2know = c(NA, .5, 1, NA, NA),
    t1knowr = t1know, t1knowrcor = t1knowcor
  )
  group <- c(1, 1, 1, 2, 2)
  attitudes <- matrix(c(.2, .4, .6, .3, .7), ncol = 1)
  result <- historical_derived_columns(values, group, attitudes)
  expect_equal(result$groupsize, c(3, 3, 3, 2, 2))
  expect_equal(result$meant1know_ind, c(.5, .75, .25, NA, NA))
  expect_equal(result$meant1knowcor_ind, c(.4, .6, .2, NA, NA))
  expect_equal(result$meant1know, c(.5, .5, .5, NA, NA))
  expect_equal(result$meant1knowcor, c(.4, .4, .4, NA, NA))
})

test_that("combined exports preserve observed-other-person denominators", {
  data <- arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  ))
  selected <- rep(TRUE, nrow(data))
  btp <- read_poll_survey("btp-general-election-2004")
  btp_measures <- build_btp_general_individual(btp)
  btp_group <- 9400 + as.numeric(btp$smgrpnumber)
  fields <- c(meant1know_ind = "t1know", meant1knowcor_ind = "t1knowcor")
  for (field in names(fields)) {
    value <- data[[fields[[field]]]]
    expected <- vapply(which(selected), function(i) {
      if (data$dpnum[i] == 15) {
        focal <- match(data$caseid[i], 940000 + btp$source_row)
        stopifnot(!is.na(focal))
        peers <- setdiff(which(btp_group == data$pollgroup[i]), focal)
        source_value <- if (field == "meant1know_ind") {
          btp_measures$knowledge_t1
        } else {
          btp_measures$knowledge_joint
        }
        observed <- source_value[peers][!is.na(source_value[peers])]
        return(if (length(observed)) mean(observed) else NA_real_)
      }
      peers <- which(data$dpnum == data$dpnum[i] &
                       data$pollgroup == data$pollgroup[i])
      peers <- setdiff(peers, i)
      observed <- value[peers][!is.na(value[peers])]
      if (length(observed)) mean(observed) else NA_real_
    }, numeric(1))
    expect_equal(data[[field]][selected], expected, tolerance = 1e-10)
  }
})
