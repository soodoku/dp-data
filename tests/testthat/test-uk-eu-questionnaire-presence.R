test_that("UK EU nonapplicable post forms never become observed zero scores", {
  survey <- read_poll_survey("uk-eu-1995")
  dictionary <- readr::read_csv(project_path(
    "data", "uk-eu-1995", "variables.csv"
  ), show_col_types = FALSE)
  fields <- dictionary$source_column[grepl("SAQ2", dictionary$variable_label)]
  expect_length(fields, 51L)
  post <- as.matrix(as.data.frame(lapply(survey[fields], as.numeric)))
  unavailable <- rowSums(post == -1) == length(fields)
  expect_false(anyNA(unavailable))
  expect_equal(sum(unavailable), 676L)
  attendee <- as.numeric(survey$part) == 1
  expect_equal(sum(unavailable & !attendee), 662L)
  expect_equal(as.numeric(survey$caseid[unavailable & attendee]), c(
    204, 502, 519, 802, 806, 812, 814, 833, 933, 937,
    2132, 3601, 3611, 3617
  ))
  result <- build_eu_individual(survey)
  expect_equal(nrow(result), 900L)
  expect_identical(result$caseid, as.numeric(survey$caseid))
  expect_false(anyNA(result$t1know))
  for (field in c(
    "t2know", "t1knowcor", "knowgain", "knowgain2", "logpk", "tobitpk"
  )) {
    expect_true(all(is.na(result[[field]][unavailable])), info = field)
  }
  key <- c(eusize = 1, swiss = 2, inctax = 2, elect = 1, ptyapp = 2)
  old_items <- purrr::imap(key, function(answer, stem) {
    as.numeric(as.numeric(survey[[paste0(stem, "2")]]) %in% answer)
  }) |>
    tibble::as_tibble() |>
    as.matrix()
  items <- eu_knowledge_items(survey, 2L)
  expect_true(all(is.na(items[unavailable, ])))
  expect_equal(items[!unavailable, ], old_items[!unavailable, ])
  expect_equal(sum(result$t2know[!unavailable] == 0), 14L)
  expect_equal(sum(!is.na(result$t2know[attendee])), 224L)
  row <- which(unavailable & attendee)[1L]
  expect_equal(eu_knowledge_items(survey[row, ], 2L),
    items[row, , drop = FALSE]
  )
})

test_that("UK EU blank quizzes inside returned forms still earn zero", {
  survey <- read_poll_survey("uk-eu-1995")
  row <- which(as.numeric(survey$part) == 1 &
                 as.numeric(survey$releu2) %in% 1:5)[1L]
  observed_form <- survey[row, ]
  fields <- paste0(c("eusize", "swiss", "inctax", "elect", "ptyapp"), "2")
  for (missing in c(NA_real_, 9, 3)) {
    observed_form[fields] <- missing
    expect_equal(as.numeric(eu_knowledge_items(observed_form, 2L)), rep(0, 5))
    expect_equal(build_eu_individual(observed_form)$t2know, 0)
  }
  observed_form$eusize2 <- 44
  expect_error(eu_knowledge_items(observed_form, 2L),
    "Unreviewed UK EU source code: eusize2"
  )
})

test_that("UK EU group knowledge uses observed exits and retains attendees", {
  source(file.path(root, "R", "polardata.R"))
  source(file.path(root, "R", "polardata_rebuild.R"))
  survey <- read_poll_survey("uk-eu-1995")
  result <- build_historical_poll("uk-eu-1995")
  expect_equal(nrow(result), 238L)
  expect_equal(sum(!is.na(result$t2know)), 224L)
  expect_equal(sum(!is.na(result$pollgroup)), 234L)
  expect_equal(core_eu_knowledge(survey, 2L), eu_knowledge_items(survey, 2L))
  missing_ids <- c(
    204, 502, 519, 802, 806, 812, 814, 833, 933, 937,
    2132, 3601, 3611, 3617
  )
  missing <- result$caseid %in% missing_ids
  expect_equal(sum(missing), 14L)
  expect_true(all(is.na(result$grpgain[missing])))
  expect_equal(result$t2knowlevel, rep(804 / (224 * 5), 238))
  for (group in unique(stats::na.omit(result$pollgroup))) {
    members <- result$pollgroup %in% group
    mean_exit <- mean(result$t2know[members], na.rm = TRUE)
    mean_joint <- mean(result$t1knowcor[members], na.rm = TRUE)
    expect_equal(result$meant2know[members], rep(mean_exit, sum(members)))
    expect_equal(result$meant1knowcor[members], rep(mean_joint, sum(members)))
  }
  affected_groups <- unique(result$pollgroup[missing])
  expect_length(affected_groups, 10L)
  expect_equal(sum(result$pollgroup %in% affected_groups), 160L)
})
