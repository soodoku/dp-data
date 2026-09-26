pilot_tables <- function() {
  polls <- purrr::map(
    knowledge_poll_ids(), build_poll_knowledge
  )
  names(polls[[1]]) |>
    rlang::set_names() |>
    purrr::map(function(name) {
      purrr::map(polls, name) |> purrr::list_rbind()
    })
}

test_that("survey comparisons report differences without imposing parity", {
  tables <- pilot_tables()
  audit <- compare_knowledge_batteries(tables)$summary
  expect_equal(sum(audit$item_differences, na.rm = TRUE), 765)
  expect_equal(sum(audit$female_differences, na.rm = TRUE), 2)
  expect_equal(nrow(tables$respondents), 6669L)
  expect_equal(nrow(tables$knowledge_responses), 103116L)
  expect_equal(nrow(tables$knowledge_scores), 13338L)
  expect_equal(nrow(tables$memberships), 6147L)
  expect_equal(nrow(tables$groups), 406L)
})

test_that("Northern Ireland retains its first headerless group record", {
  raw_lines <- readLines(
    project_path("data", "northern-ireland-2007", "groups.csv")
  )
  first <- strsplit(raw_lines[[1]], ",", fixed = TRUE)[[1]]
  built <- build_poll_knowledge("northern-ireland-2007")
  restored <- built$memberships |>
    dplyr::filter(.data$respondent_id == first[[1]])
  expect_equal(nrow(restored), 1L)
  expect_equal(restored$group_id, first[[2]])
  expect_setequal(
    built$memberships$respondent_id, built$respondents$respondent_id
  )
})

test_that("Northern Ireland ordering follows cserial rather than source row", {
  survey <- read_poll_survey("northern-ireland-2007")
  original <- knowledge_participants("northern-ireland-2007", survey)
  reversed <- knowledge_participants(
    "northern-ireland-2007", survey[rev(seq_len(nrow(survey))), ]
  )
  expect_identical(original, reversed)
})

test_that("duplicate and incomplete group mappings are rejected", {
  survey <- read_poll_survey("northern-ireland-2007")
  groups <- readr::read_csv(
    project_path("data", "northern-ireland-2007", "groups.csv"),
    col_names = c("respondent_id", "group_id"),
    col_types = readr::cols(.default = readr::col_character())
  )
  expect_error(knowledge_participants(
    "northern-ireland-2007", survey,
    dplyr::bind_rows(groups, groups[1, ])
  ))
  expect_error(knowledge_participants(
    "northern-ireland-2007", survey, groups[-1, ]
  ))
})

test_that("unreviewed response codes cannot silently become missing", {
  tables <- build_poll_knowledge("uk-health-1998")
  raw <- tables$knowledge_responses |>
    dplyr::select(
      "poll_id", "respondent_id", "source_row", "source_column", "raw_value"
    )
  raw$raw_value[[1]] <- 999
  expect_error(
    score_knowledge_responses(raw, read_metadata("knowledge_items")),
    "Unmapped response code"
  )
})

test_that("benchmark comparisons report an additional changed scored item", {
  tables <- pilot_tables()
  row <- which(!is.na(tables$knowledge_responses$correct))[[1]]
  tables$knowledge_responses$correct[[row]] <-
    1L - tables$knowledge_responses$correct[[row]]
  audit <- compare_knowledge_batteries(tables)
  expect_equal(sum(audit$summary$item_differences, na.rm = TRUE), 766L)
  expect_equal(nrow(audit$differences), 766L)
})

test_that("responses preserve missing codes and scores declare filling", {
  tables <- pilot_tables()
  responses <- tables$knowledge_responses
  missing <- responses$response_status != "answered"
  expect_true(any(responses$response_status == "source_missing"))
  expect_true(any(responses$response_status == "non_substantive"))
  expect_true(all(is.na(responses$correct[missing])))
  expect_true(all(!is.na(responses$missing_code[missing])))
  expect_true(all(is.na(responses$missing_code[!missing])))
  expect_true(all(responses$correct[!missing] %in% 0:1))

  expected <- responses |>
    dplyr::group_by(.data$poll_id, .data$respondent_id, .data$wave) |>
    dplyr::summarise(
      n_items = dplyr::n(),
      n_observed = sum(!is.na(.data$correct)),
      n_correct = sum(.data$correct == 1L, na.rm = TRUE),
      score_zero_filled = .data$n_correct / .data$n_items,
      .groups = "drop"
    )
  actual <- tables$knowledge_scores |>
    dplyr::arrange(.data$poll_id, .data$respondent_id, .data$wave)
  expect_equal(actual, expected, ignore_attr = TRUE)
})

test_that("the Northern Ireland public extract excludes all named verbatims", {
  survey <- read_poll_survey("northern-ireland-2007")
  excluded <- read_metadata("source_field_exclusions") |>
    dplyr::filter(.data$poll_id == "northern-ireland-2007") |>
    dplyr::pull(.data$source_column)
  variables <- readr::read_csv(
    project_path("data", "northern-ireland-2007", "variables.csv"),
    show_col_types = FALSE
  )
  expect_equal(dim(survey), c(868L, 449L))
  expect_equal(survey$source_row, seq_len(868L))
  expect_s3_class(survey$intdate, "Date")
  expect_false(any(purrr::map_lgl(survey, is.character)))
  expect_length(intersect(excluded, names(survey)), 0L)
  expect_equal(nrow(variables), 528L)
  expect_equal(sum(!variables$public), 80L)
  expect_setequal(variables$source_column[variables$public], names(survey)[-1])
})

test_that("Parquet exports preserve declared types and values", {
  tables <- pilot_tables()
  directory <- withr::local_tempdir()
  expected_types <- c(
    string = "character", int32 = "integer",
    float64 = "double", bool = "logical"
  )
  for (name in names(tables)) {
    manifest <- write_typed_export(tables[[name]], name, directory)
    restored <- arrow::read_parquet(
      file.path(directory, paste0(name, ".parquet"))
    )
    columns <- read_metadata("canonical_columns") |>
      dplyr::filter(.data$table == name)
    expect_identical(
      unname(purrr::map_chr(restored, typeof)),
      unname(expected_types[columns$arrow_type])
    )
    expect_equal(nrow(restored), manifest$rows)
    expect_equal(restored, tables[[name]][columns$column], ignore_attr = TRUE)
  }
})

test_that("UK Health keys agree with the original correctness variables", {
  survey <- read_poll_survey("uk-health-1998")
  responses <- build_poll_knowledge("uk-health-1998")$knowledge_responses
  purrr::walk(unique(responses$source_column), function(column) {
    observed <- responses |>
      dplyr::filter(.data$source_column == .env$column) |>
      dplyr::arrange(.data$source_row)
    answer_column <- sub("^soph", "answer", column)
    expect_equal(
      dplyr::if_else(
        observed$response_status == "source_missing", NA_integer_,
        tidyr::replace_na(observed$correct, 0L)
      ),
      as.numeric(survey[[answer_column]])
    )
  })
})

test_that("Crime uses validated original IDs and the deposited sample", {
  survey <- read_poll_survey("uk-crime-1994")
  selected <- knowledge_participants("uk-crime-1994", survey)
  expect_equal(sum(survey$part == 1), 300)
  expect_equal(sum(survey$part == 1 & is.na(survey$group)), 1)
  expect_equal(nrow(selected), 299L)
  expect_equal(as.integer(selected$respondent_id), selected$source_row)
  expect_identical(
    selected,
    knowledge_participants("uk-crime-1994", dplyr::arrange(
      survey, dplyr::desc(.data$source_row)
    ))
  )
  damaged <- survey
  damaged$caseid[[1]] <- 1.2
  expect_error(knowledge_participants("uk-crime-1994", damaged))
  damaged$caseid[[1]] <- damaged$caseid[[2]]
  expect_error(knowledge_participants("uk-crime-1994", damaged))
})

test_that("EU excludes inapplicable batteries without inventing group 99", {
  survey <- read_poll_survey("uk-eu-1995")
  attendees <- survey |> dplyr::filter(.data$part == 1)
  excluded <- attendees |> dplyr::filter(as.numeric(.data$eusize2) == -1)
  post <- paste0(c("eusize", "swiss", "inctax", "elect", "ptyapp"), 2)
  expect_equal(nrow(attendees), 238L)
  expect_equal(nrow(excluded), 14L)
  expect_true(all(purrr::map_lgl(excluded[post], ~ all(as.numeric(.x) == -1))))
  built <- build_poll_knowledge("uk-eu-1995")
  expect_equal(nrow(built$respondents), 224L)
  expect_equal(nrow(built$memberships), 220L)
  expect_setequal(built$groups$group_id, as.character(1:15))
  unmatched <- dplyr::anti_join(
    built$respondents, built$memberships,
    by = c("poll_id", "respondent_id")
  )
  expect_setequal(unmatched$respondent_id, c("1008", "3132", "4316", "5022"))
  expect_equal(
    sum(built$knowledge_responses$respondent_id %in% unmatched$respondent_id),
    40L
  )
  expect_true(all(built$knowledge_responses$raw_value %in% c(1, 2, 3, 8, 9)))
  people <- knowledge_participants("uk-eu-1995", survey)
  expect_identical(people, knowledge_participants(
    "uk-eu-1995", dplyr::arrange(survey, dplyr::desc(.data$source_row))
  ))
  damaged <- survey
  damaged$group <- as.numeric(damaged$group)
  damaged$group[which(damaged$part == 1)[[1]]] <- 16
  expect_error(knowledge_participants("uk-eu-1995", damaged))
})

test_that("empty source value labels retain their dictionary schema", {
  labels <- survey_value_labels(read_poll_survey("uk-crime-1994"))
  expect_equal(nrow(labels), 0L)
  expect_named(labels, c("source_column", "source_value", "value_label"))
  expect_true(all(purrr::map_lgl(labels, is.character)))
})

test_that("new poll keys agree with source correctness for answered items", {
  purrr::walk(c("uk-crime-1994", "uk-eu-1995"), function(poll_id) {
    survey <- read_poll_survey(poll_id)
    items <- read_metadata("knowledge_items") |>
      dplyr::filter(.data$poll_id == .env$poll_id)
    responses <- build_poll_knowledge(poll_id)$knowledge_responses
    purrr::walk(seq_len(nrow(items)), function(row) {
      item <- items[row, ]
      observed <- responses |>
        dplyr::filter(
          .data$source_column == item$source_column,
          .data$response_status == "answered"
        )
      scored_column <- sub("raw$", "", item$benchmark_column)
      expect_equal(
        observed$correct,
        as.numeric(survey[[scored_column]][observed$source_row])
      )
    })
  })
})

test_that("Monarchy T2 uses R5C and the deposit demonstrably repeats Q5C", {
  poll_id <- "uk-monarchy-1996"
  source <- read_poll_survey(poll_id)
  built <- build_poll_knowledge(poll_id)
  people <- built$respondents |> dplyr::arrange(.data$battery_row)
  battery <- read_knowledge_battery(poll_id)
  score <- function(x) {
    dplyr::case_when(x == 1 ~ 1L, x == 2 ~ 0L, TRUE ~ NA_integer_)
  }
  expect_identical(battery$knowc2raw, score(source$Q5C[people$source_row]))
  observed <- built$knowledge_responses |>
    dplyr::filter(.data$item_id == "knowledge-3", .data$wave == 2) |>
    dplyr::arrange(.data$source_row)
  expect_identical(observed$correct, score(source$R5C[people$source_row]))
  comparison <- compare_knowledge_batteries(built)
  expect_equal(nrow(comparison$differences), 58L)
  expect_setequal(comparison$differences$source_column, "R5C")
  change <- comparison$score_changes |>
    dplyr::filter(.data$wave == 2)
  expect_equal(change$changed_scores, 55L)
  expect_equal(change$change_percentage_points, -100 * 5 / (258 * 8))
  expect_identical(
    knowledge_participants(poll_id, source),
    knowledge_participants(poll_id, source[rev(seq_len(nrow(source))), ])
  )
})

test_that("CPL retains explicit unknown codes and original respondent IDs", {
  source <- read_poll_survey("cpl-1996")
  built <- build_poll_knowledge("cpl-1996")
  expect_equal(dim(source), c(1246L, 196L))
  expect_equal(nrow(built$respondents), 216L)
  unknown <- built$knowledge_responses |>
    dplyr::filter(.data$raw_value == 99)
  expect_equal(nrow(unknown), 759L)
  expect_true(all(is.na(unknown$correct)))
  expect_true(all(unknown$missing_code == "99"))
  expect_true(all(unknown$response_status == "non_substantive"))
  expect_equal(
    built$respondents$respondent_id,
    as.character(as.integer(source$caseid[source$part == 1]))
  )
})

test_that("utility keys agree with original correctness fields", {
  purrr::walk(c("cpl-1996", "swepco-1996", "wtu-1996"), function(poll_id) {
    source <- read_poll_survey(poll_id)
    built <- build_poll_knowledge(poll_id)
    items <- read_metadata("knowledge_items") |>
      dplyr::filter(.data$poll_id == .env$poll_id)
    purrr::walk(seq_len(nrow(items)), function(row) {
      item <- items[row, ]
      scored_column <- sub("raw$", "", item$benchmark_column)
      if (poll_id != "cpl-1996") scored_column <- toupper(scored_column)
      observed <- built$knowledge_responses |>
        dplyr::filter(.data$source_column == item$source_column)
      expect_equal(
        tidyr::replace_na(observed$correct, 0L),
        as.numeric(source[[scored_column]][observed$source_row])
      )
    })
    expect_identical(
      knowledge_participants(poll_id, source),
      knowledge_participants(poll_id, source[rev(seq_len(nrow(source))), ])
    )
  })
})

test_that("WTU includes the documented post-wave wholesale category", {
  built <- build_poll_knowledge("wtu-1996")
  wholesale <- built$knowledge_responses |>
    dplyr::filter(.data$source_column == "USE2", .data$raw_value == 4)
  expect_equal(nrow(wholesale), 2L)
  expect_true(all(wholesale$correct == 0L))
  expect_setequal(wholesale$respondent_id, c("20000100", "20001180"))
})

test_that("election scoring separates missing codes and party-placement keys", {
  source <- read_poll_survey("uk-general-election-1997")
  built <- build_poll_knowledge("uk-general-election-1997")
  expect_equal(nrow(built$respondents), 275L)
  expect_false("4416" %in% built$respondents$respondent_id)
  expect_true(4416 %in% source$serial)
  responses <- built$knowledge_responses
  negative <- responses$raw_value %in% c(-8, -9)
  expect_true(any(negative))
  expect_true(all(is.na(responses$correct[negative])))
  conservative <- grepl(
    "^(redstc|taxc|wagec|euc)[12]$", responses$source_column
  )
  other_party <- grepl(
    "^(redstl|taxl|wagel|eul|redstld|taxld|wageld|euld)[12]$",
    responses$source_column
  )
  expect_equal(
    responses$correct[conservative & !negative],
    as.integer(responses$raw_value[conservative & !negative] < 4)
  )
  expect_equal(
    responses$correct[other_party & !negative],
    as.integer(responses$raw_value[other_party & !negative] > 4)
  )
  expect_identical(
    knowledge_participants("uk-general-election-1997", source),
    knowledge_participants(
      "uk-general-election-1997", source[rev(seq_len(nrow(source))), ]
    )
  )
  battery <- read_knowledge_battery("uk-general-election-1997")
  expect_true(all(purrr::map_lgl(battery, is.integer)))
  expect_equal(battery$redstc1raw[[1]], 1L)
})
