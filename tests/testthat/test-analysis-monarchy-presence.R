source(file.path(root, "R", "analysis_phases.R"))
source(file.path(root, "R", "respondents.R"))

test_that("Monarchy's source cohort and full post block establish absence", {
  survey <- read_poll_survey("uk-monarchy-1996")
  evidence <- analysis_monarchy_presence(survey)
  fields <- grep("^R[0-9]", names(survey), value = TRUE)
  expect_length(fields, 61L)
  expect_equal(sum(survey$WEEKEND == -1), 599L)
  expect_true(all(as.matrix(survey[survey$WEEKEND == -1, fields]) == -1))
  expect_identical(evidence$source_row, survey$source_row)
  expect_identical(evidence$departure_observed, survey$WEEKEND == 1)
  quiz <- c(paste0("R5", LETTERS[1:8]), "R8A")
  attendee <- which(survey$WEEKEND == 1)[1]
  survey[attendee, quiz] <- -1
  expect_true(analysis_monarchy_presence(survey)$
                departure_observed[attendee])
  survey[attendee, fields] <- -1
  expect_true(is.na(analysis_monarchy_presence(survey)$
                      departure_observed[attendee]))
  nonattendee <- which(survey$WEEKEND == -1)[1]
  survey$R1[nonattendee] <- 1
  expect_error(analysis_monarchy_presence(survey))
})

test_that("Monarchy absence overrides post placeholders only", {
  scores <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_scores.parquet"
  )) |>
    dplyr::filter(poll_id == "uk-monarchy-1996")
  items <- arrow::read_parquet(project_path(
    "output", "analysis", "analysis_item_responses.parquet"
  )) |>
    dplyr::filter(poll_id == "uk-monarchy-1996")
  presence <- analysis_phase_presence(scores, items,
    arrow::read_parquet(project_path(
      "output", "respondent", "respondent_measures.parquet"
    )),
    read_metadata("measure_definitions"), read_metadata("polardata_targets")
  )
  historical <- presence |>
    dplyr::filter(source_dataset == "historical")
  expect_equal(sum(historical$wave == "t2" & !historical$wave_observed), 599L)
  expect_equal(sum(historical$wave == "t2" & historical$wave_observed), 258L)
  expect_true(all(historical$wave_observed[historical$wave == "t1"]))
  cor <- presence |> dplyr::filter(source_dataset == "cor_sood")
  expect_true(all(cor$wave_observed))
  expect_equal(nrow(cor), 516L)
})


test_that("Monarchy absent forms cannot yield respondent knowledge outcomes", {
  survey <- read_poll_survey("uk-monarchy-1996")
  absent <- survey$WEEKEND == -1
  before <- monarchy_knowledge_items(survey, 1L)
  after <- monarchy_knowledge_items(survey, 2L)
  expect_equal(dim(after), c(857L, 9L))
  expect_true(all(is.na(after[absent, ])))
  expect_false(anyNA(after[!absent, ]))
  built <- build_monarchy_individual(survey)
  post_fields <- c("knowledge_t2", "knowledge_joint", "knowledge_gain",
                   "knowledge_gain_joint", "log_knowledge_joint",
                   "high_knowledge_joint")
  expect_true(all(is.na(as.matrix(built[absent, post_fields]))))
  expect_identical(built$knowledge_t1, rowMeans(before))
  attendees <- survey[!absent, ]
  expect_identical(monarchy_knowledge_items(attendees, 2L), after[!absent, ])
  order <- rev(seq_len(nrow(survey)))
  expect_identical(
    monarchy_knowledge_items(survey[order, ], 2L), after[order, ]
  )
  blank <- attendees
  blank[1, c(paste0("R5", LETTERS[1:8]), "R8A")] <- -1
  expect_true(all(monarchy_knowledge_items(blank, 2L)[1, ] == 0))
})
