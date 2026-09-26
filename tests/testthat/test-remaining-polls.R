test_that("all 23 deposited poll batteries have source-based builds", {
  expect_setequal(
    knowledge_poll_ids(),
    read_metadata("knowledge_batteries")$poll_id
  )
  purrr::walk(knowledge_poll_ids(), function(poll_id) {
    survey <- read_poll_survey(poll_id)
    people <- knowledge_participants(poll_id, survey)
    expect_identical(
      people,
      knowledge_participants(poll_id, survey[rev(seq_len(nrow(survey))), ])
    )
    expect_false(anyNA(people$respondent_id))
    expect_equal(anyDuplicated(people$respondent_id), 0L)
    expect_true(all(is.na(people$female) | people$female %in% 0:1))
  })
})

test_that("redacted extracts expose only the reviewed text fields", {
  sources <- read_metadata("survey_sources")
  excluded <- read_metadata("source_field_exclusions")
  purrr::walk(seq_len(nrow(sources)), function(i) {
    record <- sources[i, ]
    survey <- read_public_survey(record)
    withheld <- excluded$source_column[excluded$poll_id == record$poll_id]
    expect_length(intersect(names(survey), withheld), 0L)
    strings <- names(survey)[purrr::map_lgl(survey, is.character)]
    allowed <- switch(record$poll_id,
      "btp-2007" = "Sgroup",
      "michigan-2009" = paste0("t3q", 38:42),
      "nic2-2003" = c("stcd", "time", "qstcd"),
      "btp-presidential-primaries-2004" = c(
        "b1q38", "f1q49a", "f1q49b", "f1q49c", "f1q49d"
      ),
      "uk-health-1998" = c("pollid1", "group1", "pollgroup1"),
      character()
    )
    expect_setequal(strings, allowed)
  })
})

test_that("San Mateo uses original IDs and the source correctness fields", {
  source <- read_poll_survey("san-mateo-2008")
  built <- build_poll_knowledge("san-mateo-2008")
  expect_equal(nrow(source), 1806L)
  expect_equal(nrow(built$respondents), 239L)
  columns <- unique(built$knowledge_responses$source_column)
  purrr::walk(columns, function(column) {
    r <- built$knowledge_responses |>
      dplyr::filter(.data$source_column == .env$column)
    expect_equal(
      tidyr::replace_na(r$correct, 0L),
      as.numeric(source[[paste0(column, "_cor")]][r$source_row])
    )
  })
  comparison <- compare_knowledge_batteries(built)
  expect_equal(nrow(comparison$differences), 113L)
  expect_setequal(comparison$differences$source_column, c("t2Q20", "t2Q26"))
  change <- comparison$score_changes |> dplyr::filter(.data$wave == 2)
  expect_equal(change$changed_scores, 92L)
  expect_equal(change$change_percentage_points, 100 * 111 / (239 * 8))
})

test_that("Michigan written answers preserve nonresponse and original text", {
  built <- build_poll_knowledge("michigan-2009")
  r <- built$knowledge_responses
  unknown <- r |>
    dplyr::filter(
      .data$source_column %in% paste0("t3q", 40:42),
      tolower(.data$raw_text) == "e"
    )
  expect_equal(nrow(unknown), 291L)
  expect_true(all(is.na(unknown$correct)))
  expect_true(all(unknown$response_status == "non_substantive"))
  expect_true(all(is.na(unknown$raw_value)))
  expect_true(any(r$raw_text == "Republican", na.rm = TRUE))
  expect_equal(
    sum(compare_knowledge_batteries(built)$score_changes$changed_scores), 0
  )
  raw <- r |>
    dplyr::select(
      "poll_id", "respondent_id", "source_row", "source_column",
      "raw_value", "raw_text"
    )
  row <- which(raw$source_column == "t3q38")[[1]]
  raw$raw_text[[row]] <- "unreviewed answer"
  expect_error(
    score_knowledge_responses(raw, read_metadata("knowledge_items")),
    "Unmapped response code"
  )
})

test_that("Vermont follows the key including its dual-answer ambiguity", {
  built <- build_poll_knowledge("vermont-energy-2007")
  r <- built$knowledge_responses
  efficiency <- r |> dplyr::filter(
    .data$item_id == "knowledge-2",
    .data$response_status == "answered"
  )
  expect_equal(efficiency$correct, as.integer(efficiency$raw_value == 3))
  renewables <- r |> dplyr::filter(
    .data$item_id == "knowledge-3",
    .data$response_status == "answered"
  )
  expect_equal(
    renewables$correct, as.integer(renewables$raw_value %in% c(2, 3))
  )
  expect_equal(nrow(built$groups), 0L)
  expect_equal(nrow(built$respondents), 146L)
})

test_that("Denmark joins independent wave files without expanding records", {
  source <- read_poll_survey("denmark-euro-2000")
  departure <- read_public_survey(read_metadata("survey_components"))
  built <- build_poll_knowledge("denmark-euro-2000")
  expect_equal(nrow(source), 1702L)
  expect_equal(nrow(departure), 359L)
  expect_equal(nrow(built$respondents), 359L)
  expect_setequal(
    built$respondents$respondent_id, as.character(departure$DELNR)
  )
  r <- built$knowledge_responses |>
    dplyr::filter(.data$source_column == "T2_S4_2")
  source_rows <- match(r$respondent_id, as.character(departure$DELNR))
  expect_equal(
    r$raw_value,
    as.numeric(departure$S4_2[source_rows])
  )
  expect_equal(nrow(built$memberships), 0L)
})

test_that("sample differences and unordered comparisons do not invent links", {
  purrr::walk(
    c("denmark-euro-2000", "tomorrows-europe-2007"),
    function(poll_id) {
      comparison <- compare_knowledge_batteries(build_poll_knowledge(poll_id))
      expect_identical(
        comparison$summary$comparison_status, "unlinked-sample-difference"
      )
      expect_true(is.na(comparison$summary$item_differences))
      expect_equal(nrow(comparison$differences), 0L)
      expect_equal(nrow(comparison$score_changes), 0L)
    }
  )
  california <- read_knowledge_battery("california-whats-next-2011")
  expect_equal(nrow(california), 401L)
  expect_true(all(rowSums(!is.na(california[397:401, ])) == 0L))
  comparison <- compare_knowledge_batteries(
    build_poll_knowledge("california-whats-next-2011")
  )
  expect_identical(
    comparison$summary$comparison_status, "row-aligned-after-blank-tail"
  )
  expect_equal(comparison$summary$respondents, 396L)
  expect_equal(comparison$summary$benchmark_respondents, 401L)
  expect_equal(comparison$summary$item_differences, 2L)
  expect_equal(comparison$summary$female_differences, 0L)
  expect_setequal(comparison$differences$respondent_id, c("321", "438"))
  expect_true(all(comparison$differences$source_column == "t3q27"))
  expect_true(all(comparison$differences$raw_value == 3))
  expect_true(all(is.na(comparison$differences$deposited_correct)))
  expect_true(all(comparison$differences$correct == 0L))
  expect_true(all(comparison$score_changes$changed_scores == 0L))

  built <- build_poll_knowledge("europolis-2009")
  comparison <- compare_knowledge_batteries(built)
  expect_identical(
    comparison$summary$comparison_status, "unordered-exact-match"
  )
  expect_true(is.na(comparison$summary$item_differences))
  row <- which(!is.na(built$knowledge_responses$correct))[[1]]
  built$knowledge_responses$correct[[row]] <-
    1L - built$knowledge_responses$correct[[row]]
  expect_identical(
    compare_knowledge_batteries(built)$summary$comparison_status,
    "unordered-different"
  )
})

test_that("NIC keeps missing IDs and rejects substantive numeric drift", {
  built <- build_poll_knowledge("nic-1996")
  expect_true("source-row-1" %in% built$respondents$respondent_id)
  expect_equal(sum(grepl("^source-row-", built$respondents$respondent_id)), 1L)
  expect_equal(rounded_source_code(c(1 + 1e-11, 2, NA)), c(1, 2, NA))
  expect_error(rounded_source_code(1.01))
})

test_that("BTP refusal and absent gender remain missing", {
  polls <- c("btp-general-election-2004", "btp-online-primaries-2004")
  purrr::walk(polls, function(p) {
    r <- build_poll_knowledge(p)$knowledge_responses
    refused <- r |> dplyr::filter(.data$raw_value == -1)
    expect_gt(nrow(refused), 0L)
    expect_true(all(is.na(refused$correct)))
    expect_true(all(refused$missing_code == "-1"))
  })
  expect_equal(
    sum(is.na(build_poll_knowledge(
      "btp-health-education-2005"
    )$respondents$female)), 2L
  )
})

test_that("Bulgaria crime and Roma remain distinct events", {
  polls <- read_metadata("polls")
  expect_equal(polls$year[polls$poll_id == "bulgaria-crime-2002"], 2002)
  expect_equal(polls$year[polls$poll_id == "bulgaria-2007"], 2007)
  batteries <- read_metadata("knowledge_batteries")$poll_id
  expect_true("bulgaria-crime-2002" %in% batteries)
  expect_false("bulgaria-2007" %in% batteries)
})

test_that("BTP 2007 agrees with independently supplied correctness fields", {
  survey <- read_poll_survey("btp-2007")
  r <- build_poll_knowledge("btp-2007")$knowledge_responses
  purrr::walk(unique(r$source_column), function(column) {
    item <- r |> dplyr::filter(.data$source_column == .env$column)
    expected <- as.numeric(survey[[paste0(column, "COR")]][item$source_row])
    expect_equal(tidyr::replace_na(item$correct, 0L), expected)
  })
})

test_that("Australia preserves unknown flags and original missing codes", {
  survey <- read_poll_survey("australia-republic-1999")
  r <- build_poll_knowledge("australia-republic-1999")$knowledge_responses
  changes <- r |>
    dplyr::filter(grepl("^(flagchg|anthem|wdroyal|pargame)", source_column))
  purrr::walk(1:2, function(wave) {
    items <- changes |> dplyr::filter(.data$wave == .env$wave)
    flagged <- as.numeric(survey[[paste0("dkchg", wave)]][items$source_row])
    expect_true(all(is.na(items$correct[which(flagged == 1)])))
  })
  unknown <- r |> dplyr::filter(.data$raw_value == 99)
  expect_true(all(is.na(unknown$correct)))
  expect_equal(sum(r$wave == 2 & r$raw_value == 99, na.rm = TRUE), 28L)
})
