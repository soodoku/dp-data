test_that("reviewed unavailable questionnaires are missing at item decoding", {
  cases <- tibble::tribble(
    ~poll, ~wave, ~decoder, ~missing,
    "uk-health-1998", 2L, historical_health_items, 2L,
    "uk-crime-1994", 2L, crime_knowledge_items, 569L,
    "uk-general-election-1997", 2L, election_knowledge_items, 935L,
    "europolis-2009", 3L, europolis_knowledge_items, 4036L,
    "tomorrows-europe-2007", 2L, tomorrow_knowledge_items, 3212L,
    "tomorrows-europe-2007", 3L, tomorrow_knowledge_items, 3191L,
    "nic-1996", 1L, nic_knowledge_items, 6L,
    "nic-1996", 2L, nic_knowledge_items, 279L,
    "nic-1996", 3L, nic_knowledge_items, 524L,
    "nic2-2003", 1L, nic2_knowledge_items, 612L,
    "nic2-2003", 2L, nic2_knowledge_items, 541L
  )
  for (i in seq_len(nrow(cases))) {
    survey <- read_poll_survey(cases$poll[i])
    items <- cases$decoder[[i]](survey, cases$wave[i])
    absent <- rowSums(is.na(items)) == ncol(items)
    expect_equal(sum(absent), cases$missing[i], info = cases$poll[i])
    expect_equal(nrow(items), nrow(survey))
    observed_items <- items[!absent, , drop = FALSE]
    expect_true(all(is.na(observed_items) | observed_items %in% 0:1))
    expected_invalid <- if (cases$poll[i] == "tomorrows-europe-2007") {
      if (cases$wave[i] == 2L) 12L else 2L
    } else {
      0L
    }
    expect_equal(sum(is.na(observed_items)), expected_invalid)
    if (cases$poll[i] == "nic-1996" && cases$wave[i] == 3L) {
      expect_identical(absent, !round(as.numeric(survey$PART3)) %in% 1L)
    }
    if (any(absent)) {
      subset <- which(absent)[1L]
      expect_equal(cases$decoder[[i]](survey[subset, ], cases$wave[i]),
        items[subset, , drop = FALSE]
      )
    }
  }
  cpl <- read_poll_survey("cpl-1996")
  items <- utility_knowledge_items(cpl, "cpl-1996", 2L)
  expect_equal(sum(rowSums(is.na(items)) == ncol(items)), 1030L)
  zeguo <- read_poll_survey("zeguo-2005")
  items <- zeguo_knowledge_items(zeguo, "pre")
  expect_equal(which(rowSums(is.na(items)) == ncol(items)), 269L)
})

test_that("returned blank knowledge batteries remain zero", {
  survey <- read_poll_survey("uk-health-1998")
  row <- which(as.numeric(survey$manwkend) == 1)[1L]
  survey[row, paste0("soph", letters[1:6], "2")] <- NA_real_
  expect_equal(as.numeric(historical_health_items(survey, 2L)[row, ]),
    rep(0, 6)
  )
  nic <- read_poll_survey("nic-1996")
  people <- as.numeric(nic$CASEID) %in% c(
    10000531, 10008110, 10008970, 10009010, 10009020, 10009310, 10012190
  )
  expect_equal(sum(people), 7L)
  expect_equal(rowSums(nic_knowledge_items(nic, 1L)[people, ]), rep(0, 7))
})

test_that("Primaries joint knowledge requires both questionnaires", {
  survey <- read_poll_survey("btp-presidential-primaries-2004")
  presence <- questionnaire_form_evidence(
    survey, "btp-presidential-primaries-2004"
  )
  unavailable <- presence$source_row[!presence$wave_observed %in% TRUE]
  result <- build_btp_primaries_individual(survey)
  absent <- survey$source_row %in% unavailable
  expect_true(all(is.na(result$knowledge_joint[absent])))
  expect_true(all(is.na(result$knowledge_gain_joint[absent])))
  before <- primaries_knowledge_items(survey, "b1")
  after <- primaries_knowledge_items(survey, "f1")
  prior_joint <- before
  prior_joint[!is.na(after) & after == 0] <- 0
  expect_equal(result$knowledge_joint[!absent],
    as_historical_float(rowMeans(prior_joint[!absent, ], na.rm = TRUE))
  )
})

test_that("Health summaries use observed people and observed peers", {
  survey <- read_poll_survey("uk-health-1998")
  result <- build_health_polardata(survey)
  absent <- as.numeric(survey$serial_m) %in% c(3809, 4307)
  expect_equal(sum(absent), 2L)
  expect_true(all(is.na(result$t2know[absent])))
  expect_true(all(is.na(result$t1knowcor[absent])))
  expect_true(all(is.na(result$grpgain[absent])))
  expect_true(all(!is.na(result$t1know[absent])))
  expect_equal(nrow(result), 230L)
  for (i in seq_len(nrow(result))) {
    same_group <- result$pollgroup == result$pollgroup[i]
    peers <- same_group & seq_len(nrow(result)) != i
    expect_equal(result$meant2know[i], mean(result$t2know[same_group],
      na.rm = TRUE
    ))
    expect_equal(result$meant1knowcor_ind[i],
      mean(result$t1knowcor[peers], na.rm = TRUE)
    )
  }
  expect_equal(unique(result$t2knowlevel), mean(result$t2know, na.rm = TRUE))
})

test_that("peer gain uses observed people without dropping groups", {
  items <- rbind(c(0, 0), c(1, 0), c(NA, NA))
  expect_equal(historical_group_gain(items, rep(1, 3)), c(.5, 0, NA))
  items[2L, ] <- NA_real_
  expect_true(all(is.na(historical_group_gain(items, rep(1, 3)))))
})


test_that("fractional opportunity uses observed peers for each item", {
  items <- rbind(c(0, 0), c(1, 0), c(NA, NA), c(0, 1))
  group <- c(1, 1, 1, NA)
  expect_equal(historical_fractional_gain(items, group), c(.5, 0, NA, NA))
  items[2L, ] <- NA_real_
  expect_true(all(is.na(historical_fractional_gain(items, group))))
  items <- rbind(c(1, 1), c(NA, NA), c(0, 0))
  expect_equal(historical_fractional_gain(items, rep(1, 3)), c(0, NA, 1))
  items[1L, ] <- 1 + 1e-11
  expect_equal(historical_fractional_gain(items, rep(1, 3)), c(0, NA, 1))
})


test_that("Europe invalid items are distinct from absent questionnaires", {
  survey <- read_poll_survey("tomorrows-europe-2007")
  expected <- tibble::tribble(
    ~wave, ~source_row, ~item, ~raw,
    2L, 3435L, 1L, 6,
    2L, 3427L, 6L, 24,
    2L, 3465L, 6L, 1004,
    2L, 3467L, 6L, 1004,
    2L, 3485L, 6L, 1004,
    2L, 3486L, 6L, 1004,
    2L, 3465L, 9L, 1004,
    2L, 3467L, 9L, 1004,
    2L, 3480L, 9L, 44,
    2L, 3485L, 9L, 1004,
    2L, 3486L, 9L, 1004,
    2L, 3487L, 9L, 1004,
    3L, 3359L, 1L, 0,
    3L, 3486L, 1L, 6
  )
  for (wave in 2:3) {
    items <- tomorrow_knowledge_items(survey, wave)
    positions <- which(is.na(items) & rowSums(is.na(items)) < ncol(items),
      arr.ind = TRUE
    )
    source <- expected[expected$wave == wave, ]
    expect_equal(survey$source_row[positions[, "row"]], source$source_row)
    expect_equal(unname(positions[, "col"]), source$item)
    raw <- vapply(seq_len(nrow(source)), function(i) {
      row <- match(source$source_row[i], survey$source_row)
      as.numeric(survey[[paste0("t", wave, "q", source$item[i] + 18L)]][row])
    }, numeric(1))
    expect_equal(raw, source$raw)
  }
})
