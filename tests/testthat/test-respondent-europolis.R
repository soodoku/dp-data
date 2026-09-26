source(file.path(root, "R", "respondents.R"))
source(file.path(root, "R", "respondent_europolis.R"))

test_that("Europolis is reconstructed from raw questions", {
  survey <- read_poll_survey("europolis-2009")
  fields <- c(
    "age1", "educ1", "birth1", "parentsbirth1", "sex1",
    "V1Q21", "V3Q21", "V1Q11_1", "V3Q11_1",
    paste0("V1Q", c(43, 44, 46, 47, 49, 50)),
    paste0("V3Q", c(43, 44, 46, 47, 49, 50))
  )
  raw <- survey[, match(tolower(fields), tolower(names(survey)))]
  built <- build_europolis_individual(raw)
  expect_equal(built, build_europolis_individual(survey))
  approved <- readr::read_csv(project_path(
    "audit", "corrections", "europolis-2009", "approved_values.csv"
  ), show_col_types = FALSE)
  changed <- which(is.na(built$minority))
  expect_equal(survey$source_row[changed], approved$source_row)
  expect_equal(as.character(survey$UniqueID[changed]),
               as.character(approved$respondent_id))
  expect_true(all(approved$historical_minority == 1))
  expect_true(all(is.na(approved$approved_minority)))
  birth <- europolis_source_codes(survey, "birth1", 1:5)
  parents <- europolis_source_codes(survey, "parentsbirth1", 1:4)
  confirmed_foreign <- (birth > 1 & !is.na(birth)) |
    (parents > 1 & !is.na(parents))
  expect_true(all(built$minority[confirmed_foreign] == 1))
  order <- rev(seq_len(nrow(raw)))
  expect_equal(build_europolis_individual(raw[order, ]), built[order, ])
  raw$V1Q21[1] <- 42
  expect_error(build_europolis_individual(raw), "Unreviewed source codes")
  missing <- survey[, -match("age1", names(survey))]
  expect_error(build_europolis_individual(missing), "Missing source field")
})

test_that("Europolis respondent values match historical identities", {
  survey <- read_poll_survey("europolis-2009")
  built <- build_europolis_individual(survey)
  benchmark <- readr::read_tsv(
    project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
  benchmark <- benchmark[benchmark$dpnum == 11, ]
  selected <- survey[[match("group_t1bis", tolower(names(survey)))]] %in% 1
  expect_equal(sum(selected), 348L)
  ids <- paste0(71, survey$UniqueID)
  expect_setequal(ids[selected], as.character(benchmark$caseid))
  built <- built[match(as.character(benchmark$caseid), ids), ]
  mapping <- c(
    t1know = "knowledge_t1", t2know = "knowledge_t2", ppage = "age",
    female = "female", minority = "minority", educ4 = "education_four",
    educ3 = "education_three", bettered = "higher_education",
    attextreme = "attitude_extremity", eu2009.cc1 = "climate_t1",
    eu2009.cc2 = "climate_t2", eu2009.imm1 = "immigration_t1",
    eu2009.imm2 = "immigration_t2"
  )
  for (field in names(mapping)) {
    expect_equal(
      built[[mapping[[field]]]], as.numeric(benchmark[[field]]),
      tolerance = 1e-10
    )
  }
})
