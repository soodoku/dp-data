source(file.path(root, "R", "respondents.R"))

test_that("NIC percentage scores use documented inclusive bounds", {
  survey <- read_poll_survey("nic-1996")
  stems <- c(WEDLOCK = "KNOWWED", AFDC = "KNOWAFD", UNEMP = "KNOWEMP")
  for (wave in 1:3) {
    built <- nic_knowledge_items(survey, wave)
    for (stem in names(stems)) {
      stored <- rounded_source_code(survey[[paste0(stems[[stem]], wave)]])
      observed <- !is.na(stored)
      expect_equal(built[observed, stem], stored[observed])
    }
  }
  survey$WEDLOCK1[1:5] <- c(24.9, 25, 40, 40.1, NA)
  expect_equal(nic_knowledge_items(survey, 1L)[1:5, "WEDLOCK"],
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
  expect_error(build_nic_individual(survey[, names(survey) != "WEDLOCK1"]),
    "Missing source field: WEDLOCK1"
  )
})

test_that("NIC historical respondent fields retain values and missingness", {
  audit <- readr::read_csv(project_path("audit", "respondent_parity.csv"),
    show_col_types = FALSE
  )
  nic <- audit[audit$poll_id == "nic-1996", ]
  expect_equal(nrow(nic), 45L)
  expect_true(all(nic$respondents == 466L))
  expect_true(all(nic$value_differences == 0L))
  expect_true(all(nic$missingness_differences == 0L))
})

test_that("NIC rejects a second missing historical identity", {
  source(project_path("R", "respondent_parity.R"), local = TRUE)
  read_export <- function(name) {
    arrow::read_parquet(project_path("output", "respondent",
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
