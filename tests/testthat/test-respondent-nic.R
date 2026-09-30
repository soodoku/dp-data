source(file.path(root, "R", "respondents.R"))

test_that("NIC percentage scores use documented inclusive bounds", {
  survey <- read_poll_survey("nic-1996")
  stems <- c(WEDLOCK = "KNOWWED", AFDC = "KNOWAFD", UNEMP = "KNOWEMP")
  baseline_fields <- setdiff(
    names(survey)[match("AGE18UP1", names(survey)):
                    match("POLDEM1", names(survey))], "PARTYST1"
  )
  exit_fields <- c(
    names(survey)[match("NICWAS2", names(survey)):
                    match("DISCBAL2", names(survey))],
    names(survey)[match("GOVSAY2", names(survey)):
                    match("POLDEM2", names(survey))]
  )
  source_form_observed <- function(fields) {
    answers <- lapply(survey[fields], function(x) {
      if (is.character(x)) !is.na(x) & nzchar(trimws(x)) else !is.na(x)
    })
    rowSums(as.data.frame(answers)) > 0L
  }
  forms <- list(
    source_form_observed(baseline_fields),
    source_form_observed(exit_fields),
    rep(TRUE, nrow(survey))
  )
  expect_equal(vapply(forms, function(x) sum(!x), integer(1)),
    c(6L, 279L, 0L)
  )
  for (wave in 1:3) {
    built <- nic_knowledge_items(survey, wave)
    for (stem in names(stems)) {
      stored <- rounded_source_code(survey[[paste0(stems[[stem]], wave)]])
      observed <- !is.na(stored) & forms[[wave]]
      expect_equal(built[observed, stem], stored[observed])
      expect_true(all(is.na(built[!forms[[wave]], stem])))
    }
  }
  survey$WEDLOCK1[1:5] <- c(24.9, 25, 40, 40.1, NA)
  expect_equal(
    nic_knowledge_items(survey, 1L)[1:5, "WEDLOCK"],
    c(0, 1, 1, 0, 0)
  )
})

test_that("NIC builds without stored scores and independently of row order", {
  survey <- read_poll_survey("nic-1996")
  expected <- build_nic_individual(survey)
  derived <- grepl("^(KNOW|EFACT|FFACT|FTFACT)", names(survey))
  raw <- survey[, !derived]
  expect_equal(build_nic_individual(raw), expected)
  order <- rev(seq_len(nrow(raw)))
  expect_equal(build_nic_individual(raw[order, ]), expected[order, ])
  raw$SPEND2[1] <- 7
  expect_error(build_nic_individual(raw), "Unreviewed source codes in SPEND2")
  expect_error(
    build_nic_individual(survey[, names(survey) != "WEDLOCK1"]),
    "Missing source field: WEDLOCK1"
  )
})

test_that("NIC respondent fields match historical or approved values", {
  source(project_path("R", "polardata.R"), local = TRUE)
  source(project_path("R", "polardata_rebuild.R"), local = TRUE)
  source(project_path("R", "respondent_parity.R"), local = TRUE)
  rebuilt <- build_historical_poll("nic-1996")
  reference <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  reference <- reference[reference$pollid == 1001, ]
  reference <- reference[match(rebuilt$caseid, reference$caseid), ]
  targets <- read_metadata("polardata_targets")
  selected <- targets$poll_id == "nic-1996" &
    targets$status == "implemented"
  fields <- targets$legacy_field[selected]
  expect_length(fields, 45L)
  expect_equal(nrow(rebuilt), 466L)
  differences <- vapply(fields, function(field) {
    expected <- approved_reference_values(
      "nic-1996", field,
      rebuilt$caseid, reference[[field]]
    )
    expect_equal(rebuilt[[field]], expected, tolerance = 1e-10)
    sum(abs(rebuilt[[field]] - reference[[field]]) > 1e-10, na.rm = TRUE)
  }, integer(1))
  expect_setequal(
    names(differences)[differences > 0],
    c("ppage", "attextreme", "attextreme2", "bettered")
  )
  expect_equal(unname(differences[
    c("ppage", "attextreme", "attextreme2", "bettered")
  ]), c(454L, 123L, 309L, 125L))
  expect_equal(sum(differences), 1011L)
  missingness <- vapply(fields, function(field) {
    sum(is.na(rebuilt[[field]]) != is.na(reference[[field]]))
  }, integer(1))
  knowledge_fields <- c(
    "t1know", "t1knowr", "t1knowcor", "t1knowrcor", "knowgain",
    "knowgain2", "logpk", "tobitpk", "knowgainr", "knowgainr2",
    "t12know", "t12knowcor", "t1knowcor2", "t2know", "t2knowr"
  )
  expect_equal(unname(missingness[knowledge_fields]),
    c(rep(5L, 10), 6L, 6L, 10L, 0L, 0L)
  )
  expect_equal(sum(missingness[knowledge_fields]), 72L)
  expect_equal(sum(missingness[setdiff(fields, knowledge_fields)]), 1191L)
})

test_that("NIC rejects a second missing historical identity", {
  source(project_path("R", "respondent_parity.R"), local = TRUE)
  read_export <- function(name) {
    arrow::read_parquet(project_path(
      "output", "respondent",
      paste0(name, ".parquet")
    ))
  }
  people <- read_export("people")
  samples <- read_export("sample_memberships")
  measures <- read_export("respondent_measures")
  reference <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  historical <- samples$sample_id == "historical-polardata" &
    samples$poll_id == "nic-1996" & !is.na(samples$included) & samples$included
  selected <- people$poll_id == "nic-1996" &
    people$respondent_id %in% samples$respondent_id[historical]
  expect_equal(sum(is.na(people$historical_respondent_id[selected])), 1L)
  index <- which(selected & !is.na(people$historical_respondent_id))[1]
  people$historical_respondent_id[index] <- NA_character_
  expect_error(compare_respondent_measures(
    measures, people, samples, reference
  ))
})

test_that("NIC age corrects the year typo and withholds unsupported ages", {
  survey <- read_poll_survey("nic-1996")
  result <- build_nic_individual(survey)$age
  caseid <- rounded_source_code(survey$CASEID)
  unknown <- c(10005580, 10006530, 10008740, 10008780, 10011470)
  expect_true(all(is.na(result[caseid %in% unknown])))
  expect_equal(result[which(caseid == 10007590)], 29)
  expect_equal(sum(!is.na(result)), 886L)
  expect_equal(sum(result < 18, na.rm = TRUE), 0L)
  changed <- dplyr::mutate(
    survey,
    BYEAR = dplyr::if_else(.data$CASEID == 10007590, 67, .data$BYEAR)
  )
  expect_equal(nic_age(changed), result)
  mismatch <- which(!is.na(survey$BYEAR) & !is.na(survey$BIRTHDY1) &
                      round(survey$BYEAR) != round(survey$BIRTHDY1) %% 100)
  expect_length(mismatch, 1L)
  expect_equal(caseid[mismatch], 10007590)
  underage <- which(96 - survey$BYEAR < 18)
  expect_setequal(caseid[underage], unknown)
})

test_that("NIC age accepts source subsets and rejects unreviewed anomalies", {
  survey <- read_poll_survey("nic-1996")
  expected <- nic_age(survey)
  for (row in seq_len(nrow(survey))) {
    expect_equal(nic_age(survey[row, ]), expected[row])
  }
  reversed <- rev(seq_len(nrow(survey)))
  expect_equal(nic_age(survey[reversed, ]), expected[reversed])
  rows <- c(1L, 23L, 240L, 710L, 755L, 775L)
  expect_equal(nic_age(survey[rows, ]), expected[rows])

  mismatch_row <- which(survey$CASEID == 10007590)
  unexpected <- survey[mismatch_row, ]
  unexpected$CASEID <- 10000001
  expect_error(nic_age(unexpected))
  unexpected <- survey[mismatch_row, ]
  unexpected$BYEAR <- 8
  expect_error(nic_age(unexpected))
  unexpected <- survey[mismatch_row, ]
  unexpected$BIRTHDY1 <- 66
  expect_error(nic_age(unexpected))

  underage_row <- which(survey$CASEID == 10005580)
  unexpected <- survey[underage_row, ]
  unexpected$CASEID <- 10000001
  expect_error(nic_age(unexpected))
  unexpected <- survey[underage_row, ]
  unexpected$BDAYRTE1 <- 2
  expect_error(nic_age(unexpected))
})

test_that("NIC exit extremity uses the exit spending answers", {
  survey <- read_poll_survey("nic-1996")
  eligible <- survey$PART == 1 &
    rounded_source_code(survey$SPFAID2) == 1
  index <- which(eligible)[1]
  original <- build_nic_individual(survey)$attitude_extremity_midterm[index]

  changed_baseline <- survey
  changed_baseline$SPFAID1[index] <- 3
  expect_equal(
    build_nic_individual(changed_baseline)$attitude_extremity_midterm[index],
    original
  )

  changed_exit <- survey
  changed_exit$SPFAID2[index] <- 2
  expect_equal(
    build_nic_individual(changed_exit)$attitude_extremity_midterm[index],
    original - .5 / sum(!is.na(nic_attitudes(survey, 2L)[index, ])),
    tolerance = 1e-10
  )
})

test_that("NIC spending nonanswers remain missing in all source waves", {
  stems <- c(
    "SPENVIR", "SPMEDIC", "SPLAW", "SPDRUG", "SPEDUC",
    "SPDEF", "SPFAID", "SPWELF", "SPSS"
  )
  source <- read_poll_survey("nic-1996")
  for (wave in 1:3) {
    survey <- source
    for (stem in stems) {
      survey[[paste0(stem, wave)]][1:5] <- c(1, 2, 3, 8, NA)
    }
    values <- nic_attitudes(survey, wave)
    expect_equal(nrow(values), 911L)
    for (field in names(values)) {
      expect_equal(values[[field]][1:5], c(0, .5, 1, NA, NA))
    }
    survey[[paste0(stems[1], wave)]][1] <- 4
    expect_error(nic_attitudes(survey, wave), "Unreviewed source codes")
    survey <- source
    survey$SPDRUG2[1] <- 9
    expect_true(is.na(nic_attitudes(survey, 2L)$drugs[1]))
    survey[[paste0(stems[1], wave)]][1] <- 9
    expect_error(nic_attitudes(survey, wave), "Unreviewed source codes")
  }
})

test_that("NIC extremity uses observed attitudes without midpoint imputation", {
  survey <- read_poll_survey("nic-1996")
  stems <- c(
    "SPENVIR", "SPMEDIC", "SPLAW", "SPDRUG", "SPEDUC",
    "SPDEF", "SPFAID", "SPWELF", "SPSS"
  )
  for (wave in 1:2) {
    for (stem in stems) survey[[paste0(stem, wave)]][1:2] <- c(8, NA)
    survey[[paste0(stems[1], wave)]][1] <- 1
  }
  values <- build_nic_individual(survey)
  expect_equal(values$attitude_extremity[1:2], c(.5, NA))
  expect_equal(values$attitude_extremity_midterm[1:2], c(.5, NA))
  expect_equal(nrow(values), 911L)
})

test_that("NIC attitude corrections match independently reviewed cells", {
  source(project_path("R", "polardata.R"), local = TRUE)
  source(project_path("R", "polardata_rebuild.R"), local = TRUE)
  source(project_path("R", "respondent_parity.R"), local = TRUE)
  rebuilt <- build_historical_poll("nic-1996")
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "nic-1996",
    "attitude_missing_approved_values.csv"
  ), show_col_types = FALSE)
  expect_equal(nrow(rebuilt), 466L)
  expect_equal(length(unique(approved$legacy_field)), 24L)
  for (field in unique(approved$legacy_field)) {
    evidence <- approved[approved$legacy_field == field, ]
    positions <- match(rebuilt$source_row, evidence$source_row)
    expect_false(anyNA(positions))
    expected <- evidence$approved_value
    if (field == "genvar") {
      survey <- read_poll_survey("nic-1996")
      attitudes <- nic_attitudes(survey, 1L)
      source_group <- rounded_source_code(survey$RGROUP2)
      groups <- split(seq_len(nrow(evidence)),
                      source_group[evidence$source_row])
      for (rows in groups) {
        focal_group <- source_group[evidence$source_row[rows[1]]]
        members <- which(source_group == focal_group)
        covariance <- stats::cov(
          as.matrix(attitudes[members, ]), use = "pairwise.complete.obs"
        )
        spectrum <- covariance_spectrum(covariance)
        if (anyNA(spectrum$values) ||
              any(spectrum$values < -spectrum$tolerance)) {
          expected[rows] <- NA_real_
        }
      }
    }
    expect_equal(rebuilt[[field]], expected[positions],
      tolerance = 1e-10
    )
    expect_equal(approved_reference_values(
      "nic-1996", field,
      evidence$caseid, evidence$historical_value
    ), expected, tolerance = 1e-10)
  }
})


test_that("NIC unavailable forms do not erase observed blanks or later waves", {
  survey <- read_poll_survey("nic-1996")
  values <- build_nic_individual(survey)
  absent_baseline <- c(1L, 23L, 240L, 710L, 755L, 775L)
  selected <- !is.na(survey$RGROUP2)
  expect_equal(sum(selected[absent_baseline]), 5L)
  expect_true(all(is.na(survey$DATEDUN1[absent_baseline])))
  expect_true(all(is.na(values$knowledge_t1[absent_baseline])))
  expect_true(all(survey$PART[absent_baseline[selected[absent_baseline]]] == 1))
  absent_exit_ids <- c(
    10000400, 10000460, 10007580, 10007590, 10014282, 10014650
  )
  exit_rows <- match(absent_exit_ids, survey$CASEID)
  expect_false(anyNA(exit_rows))
  expect_true(all(is.na(values$knowledge_midterm[exit_rows])))
  expect_true(all(survey$PART[exit_rows] == 1))
  expect_equal(length(intersect(absent_baseline, exit_rows)), 1L)
  for (stem in c("KNOWWED", "KNOWAFD", "KNOWEMP")) {
    stored <- survey[[paste0(stem, 1)]][absent_baseline]
    expect_equal(unname(as.numeric(stored)), rep(0, 6))
    expect_equal(sum(stored[selected[absent_baseline]] == 0), 5L)
  }

  changed <- survey
  raw_stems <- c(
    "WEDLOCK", "AFDC", "UNEMP", "SPEND", "TRADE", "TROOPSA",
    "TROOPSB", "TROOPSC", "TROOPSD", "POLREP", "POLDEM"
  )
  observed_row <- which(!is.na(survey$DATEDUN1) &
                          !is.na(survey$AGE18UP1))[1]
  for (stem in raw_stems) changed[[paste0(stem, 1)]][observed_row] <- NA
  expect_equal(nic_knowledge_items(changed, 1L)[observed_row, ],
    stats::setNames(rep(0, 11), colnames(nic_knowledge_items(survey, 1L)))
  )
  expect_equal(nic_knowledge_items(changed, 3L),
    nic_knowledge_items(survey, 3L)
  )
  expect_equal(build_nic_individual(changed)$knowledge_t2, values$knowledge_t2)
})
