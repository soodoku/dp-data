knowledge_participants <- function(poll_id, survey, groups = NULL) {
  if (poll_id == "uk-health-1998") {
    stopifnot(all(survey$group > 0))
    participants <- survey |>
      dplyr::transmute(
        source_row = .data$source_row,
        respondent_id = as.character(as.integer(.data$serial_m)),
        female = dplyr::case_when(
          .data$gender == 2 ~ 1L,
          .data$gender == 1 ~ 0L,
          TRUE ~ NA_integer_
        ),
        group_id = as.character(as.integer(.data$group))
      )
  } else if (poll_id == "northern-ireland-2007") {
    if (is.null(groups)) {
      groups <- readr::read_csv(
        project_path("data", poll_id, "groups.csv"),
        col_names = c("respondent_id", "group_id"),
        col_types = readr::cols(
          respondent_id = readr::col_integer(),
          group_id = readr::col_character()
        )
      )
    }
    groups <- groups |>
      dplyr::transmute(
        respondent_id = as.character(.data$respondent_id),
        group_id = .data$group_id
      )
    groups |>
      assertr::verify(
        !anyNA(.data$respondent_id) && !anyDuplicated(.data$respondent_id),
        error_fun = assertr::error_stop
      )
    participants <- survey |>
      dplyr::filter(.data$attend == 1) |>
      dplyr::arrange(.data$cserial) |>
      dplyr::transmute(
        source_row = .data$source_row,
        respondent_id = as.character(as.integer(.data$cserial)),
        female = as.integer(.data$female)
      ) |>
      dplyr::left_join(
        groups, by = "respondent_id",
        relationship = "one-to-one", na_matches = "never"
      )
    stopifnot(all(groups$respondent_id %in% participants$respondent_id))
  } else {
    stop("No participant selection rule for ", poll_id)
  }

  participants <- participants |>
    dplyr::mutate(
      poll_id = poll_id, arm = "participant",
      battery_row = dplyr::row_number()
    )
  participants |>
    assertr::verify(
      !anyNA(.data$respondent_id) && !anyDuplicated(.data$respondent_id),
      error_fun = assertr::error_stop
    )
  contract <- read_metadata("knowledge_join_contracts") |>
    dplyr::filter(.data$poll_id == .env$poll_id)
  stopifnot(
    nrow(contract) == 1L,
    nrow(participants) == contract$expected_left_rows,
    sum(!is.na(participants$group_id)) == contract$expected_matches
  )
  participants
}

knowledge_code_lookup <- function(items) {
  codes <- items |>
    dplyr::select(
      "poll_id", "wave", "item_id", "correct_value",
      "incorrect_values", "missing_values"
    ) |>
    dplyr::mutate(correct_values = as.character(.data$correct_value)) |>
    dplyr::select(-"correct_value") |>
    tidyr::pivot_longer(
      c("correct_values", "incorrect_values", "missing_values"),
      names_to = "rule", values_to = "raw_value"
    ) |>
    tidyr::separate_longer_delim("raw_value", delim = "|") |>
    dplyr::mutate(
      raw_value = as.numeric(.data$raw_value),
      correct = dplyr::case_when(
        .data$rule == "correct_values" ~ 1L,
        .data$rule == "incorrect_values" ~ 0L,
        TRUE ~ NA_integer_
      ),
      response_status = dplyr::if_else(
        .data$rule == "missing_values", "non_substantive", "answered"
      )
    ) |>
    dplyr::select(-"rule")
  stopifnot(
    !anyNA(codes$raw_value),
    !anyDuplicated(codes[c("poll_id", "wave", "item_id", "raw_value")])
  )
  codes
}

score_knowledge_responses <- function(raw, items) {
  scored <- raw |>
    dplyr::left_join(
      items |>
        dplyr::select("poll_id", "source_column", "wave", "item_id"),
      by = c("poll_id", "source_column"),
      relationship = "many-to-one"
    ) |>
    dplyr::left_join(
      knowledge_code_lookup(items),
      by = c("poll_id", "wave", "item_id", "raw_value"),
      relationship = "many-to-one", na_matches = "never"
    )
  if (any(!is.na(scored$raw_value) & is.na(scored$response_status))) {
    stop("Unmapped response code; update the reviewed item rules.")
  }
  scored |>
    dplyr::mutate(
      response_status = dplyr::if_else(
        is.na(.data$raw_value), "source_missing", .data$response_status
      ),
      missing_code = dplyr::case_when(
        is.na(.data$raw_value) ~ "system",
        .data$response_status == "non_substantive" ~
          as.character(.data$raw_value),
        TRUE ~ NA_character_
      )
    ) |>
    dplyr::select(
      "poll_id", "respondent_id", "wave", "item_id", "source_row",
      "source_column", "raw_value", "correct", "response_status", "missing_code"
    ) |>
    dplyr::arrange(
      .data$poll_id, .data$respondent_id, .data$wave, .data$item_id
    )
}

build_poll_knowledge <- function(poll_id) {
  survey <- read_poll_survey(poll_id)
  participants <- knowledge_participants(poll_id, survey)
  items <- read_metadata("knowledge_items") |>
    dplyr::filter(.data$poll_id == .env$poll_id)
  values <- survey |>
    dplyr::select("source_row", dplyr::all_of(items$source_column)) |>
    dplyr::mutate(
      dplyr::across(dplyr::all_of(items$source_column), as.numeric)
    )
  raw <- participants |>
    dplyr::select("poll_id", "respondent_id", "source_row") |>
    dplyr::inner_join(values, by = "source_row", relationship = "one-to-one") |>
    tidyr::pivot_longer(
      dplyr::all_of(items$source_column),
      names_to = "source_column", values_to = "raw_value"
    )
  stopifnot(nrow(raw) == nrow(participants) * nrow(items))
  responses <- score_knowledge_responses(raw, items)
  respondents <- participants |>
    dplyr::select(
      "poll_id", "respondent_id", "arm", "source_row", "battery_row", "female"
    )
  memberships <- participants |>
    dplyr::filter(!is.na(.data$group_id)) |>
    dplyr::transmute(
      poll_id = .data$poll_id, respondent_id = .data$respondent_id,
      session_id = "deliberation", group_id = .data$group_id, weight = 1
    )
  groups <- memberships |>
    dplyr::distinct(.data$poll_id, .data$session_id, .data$group_id)
  scores <- responses |>
    dplyr::group_by(.data$poll_id, .data$respondent_id, .data$wave) |>
    dplyr::summarise(
      n_items = dplyr::n(),
      n_observed = sum(!is.na(.data$correct)),
      n_correct = sum(.data$correct, na.rm = TRUE),
      score_zero_filled = .data$n_correct / .data$n_items,
      .groups = "drop"
    )
  list(
    respondents = respondents, knowledge_responses = responses,
    knowledge_scores = scores, groups = groups, memberships = memberships
  )
}

validate_knowledge_parity <- function(tables) {
  items <- read_metadata("knowledge_items")
  poll_ids <- unique(tables$respondents$poll_id)
  audit <- purrr::map(poll_ids, function(poll_id) {
    specification <- items |>
      dplyr::filter(.data$poll_id == .env$poll_id)
    expected <- readr::read_csv(
      project_path("data", poll_id, "knowledge-battery.csv"),
      col_types = readr::cols(.default = readr::col_double())
    )
    people <- tables$respondents |>
      dplyr::filter(.data$poll_id == .env$poll_id) |>
      dplyr::arrange(.data$battery_row)
    actual <- tables$knowledge_responses |>
      dplyr::filter(.data$poll_id == .env$poll_id) |>
      dplyr::inner_join(
        specification |>
          dplyr::select("poll_id", "wave", "item_id", "benchmark_column"),
        by = c("poll_id", "wave", "item_id"), relationship = "many-to-one"
      ) |>
      dplyr::inner_join(
        people |> dplyr::select("respondent_id", "battery_row"),
        by = "respondent_id", relationship = "many-to-one"
      ) |>
      dplyr::select("battery_row", "benchmark_column", "correct") |>
      tidyr::pivot_wider(
        names_from = "benchmark_column", values_from = "correct"
      ) |>
      dplyr::arrange(.data$battery_row) |>
      dplyr::select(dplyr::all_of(specification$benchmark_column))
    stopifnot(nrow(actual) == nrow(expected))
    deposited <- as.matrix(expected[specification$benchmark_column])
    rebuilt <- as.matrix(actual)
    item_differences <- sum(xor(is.na(rebuilt), is.na(deposited))) +
      sum(rebuilt != deposited, na.rm = TRUE)
    female_differences <-
      sum(xor(is.na(people$female), is.na(expected$female))) +
      sum(people$female != expected$female, na.rm = TRUE)
    tibble::tibble(
      poll_id = poll_id, respondents = nrow(actual),
      item_wave_columns = ncol(actual),
      item_differences = item_differences,
      female_differences = female_differences
    )
  }) |>
    purrr::list_rbind()
  audit |>
    assertr::verify(
      all(.data$item_differences == 0 & .data$female_differences == 0),
      error_fun = assertr::error_stop
    )
  audit
}
