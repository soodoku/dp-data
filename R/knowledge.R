knowledge_participants <- function(poll_id, survey, groups = NULL) {
  survey <- survey |> dplyr::arrange(.data$source_row)
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
  } else if (poll_id == "uk-crime-1994") {
    stopifnot(
      all(abs(survey$caseid - round(survey$caseid)) < 1e-8),
      !anyNA(survey$caseid), !anyDuplicated(round(survey$caseid)),
      all(survey$sex %in% 0:1),
      all(survey$group[!is.na(survey$group)] %in% 1:20)
    )
    participants <- survey |>
      dplyr::filter(.data$part == 1, !is.na(.data$group)) |>
      dplyr::arrange(.data$source_row) |>
      dplyr::transmute(
        source_row = .data$source_row,
        respondent_id = as.character(as.integer(round(.data$caseid))),
        female = as.integer(1 - .data$sex),
        group_id = as.character(as.integer(.data$group))
      )
  } else if (poll_id == "uk-eu-1995") {
    stopifnot(
      all(survey$caseid == round(survey$caseid)),
      !anyNA(survey$caseid), !anyDuplicated(survey$caseid),
      all(as.numeric(survey$sex) %in% 0:1),
      all(as.numeric(survey$group[survey$part == 1]) %in% c(1:15, 99))
    )
    participants <- survey |>
      dplyr::filter(.data$part == 1, as.numeric(.data$eusize2) != -1) |>
      dplyr::arrange(.data$source_row) |>
      dplyr::transmute(
        source_row = .data$source_row,
        respondent_id = as.character(as.integer(.data$caseid)),
        female = as.integer(.data$sex),
        group_id = dplyr::if_else(
          as.numeric(.data$group) == 99, NA_character_,
          as.character(as.integer(.data$group))
        )
      )
  } else if (poll_id == "uk-monarchy-1996") {
    stopifnot(all(survey$GROUP %in% c(-1, 2:16)))
    participants <- survey |>
      dplyr::filter(.data$GROUP > 0) |>
      dplyr::arrange(.data$source_row) |>
      dplyr::transmute(
        source_row = .data$source_row,
        respondent_id = paste0("source-row-", .data$source_row),
        female = as.integer(.data$SEX == 2),
        group_id = as.character(as.integer(.data$GROUP))
      )
  } else if (poll_id == "uk-general-election-1997") {
    stopifnot(all(survey$serial == round(survey$serial)))
    participants <- survey |>
      dplyr::filter(.data$filter == 1) |>
      dplyr::arrange(.data$source_row) |>
      dplyr::transmute(
        source_row = .data$source_row,
        respondent_id = as.character(as.integer(.data$serial)),
        female = as.integer(1 - .data$gender),
        group_id = as.character(as.integer(.data$group))
      )
  } else if (poll_id %in% c("cpl-1996", "swepco-1996", "wtu-1996")) {
    fields <- if (poll_id == "cpl-1996") {
      c("caseid", "part", "group", "gender")
    } else {
      c("CASEID", "PART", "GROUP", "GENDER")
    }
    stopifnot(
      all(survey[[fields[[1]]]] == round(survey[[fields[[1]]]])),
      all(survey[[fields[[4]]]] %in% 1:2)
    )
    participants <- survey |>
      dplyr::filter(.data[[fields[[2]]]] == 1) |>
      dplyr::arrange(.data$source_row) |>
      dplyr::transmute(
        source_row = .data$source_row,
        respondent_id = as.character(as.integer(.data[[fields[[1]]]])),
        female = as.integer(.data[[fields[[4]]]] == 2),
        group_id = as.character(as.integer(.data[[fields[[3]]]]))
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
        groups,
        by = "respondent_id",
        relationship = "one-to-one", na_matches = "never"
      )
    stopifnot(all(groups$respondent_id %in% participants$respondent_id))
  } else {
    participants <- remaining_participants(poll_id, survey)
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
      "poll_id", "wave", "item_id", "correct_values",
      "incorrect_values", "missing_values"
    ) |>
    tidyr::pivot_longer(
      c("correct_values", "incorrect_values", "missing_values"),
      names_to = "rule", values_to = "raw_code"
    ) |>
    dplyr::filter(!is.na(.data$raw_code), .data$raw_code != "") |>
    tidyr::separate_longer_delim("raw_code", delim = "|") |>
    dplyr::mutate(
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
    !anyNA(codes$raw_code),
    !anyDuplicated(codes[c("poll_id", "wave", "item_id", "raw_code")])
  )
  codes
}

score_knowledge_responses <- function(raw, items) {
  if (!"raw_text" %in% names(raw)) raw$raw_text <- NA_character_
  raw <- raw |>
    dplyr::mutate(raw_code = knowledge_raw_code(
      .data$poll_id, .data$raw_value, .data$raw_text
    ))
  scored <- raw |>
    dplyr::left_join(
      items |>
        dplyr::select("poll_id", "source_column", "wave", "item_id"),
      by = c("poll_id", "source_column"),
      relationship = "many-to-one"
    ) |>
    dplyr::left_join(
      knowledge_code_lookup(items),
      by = c("poll_id", "wave", "item_id", "raw_code"),
      relationship = "many-to-one", na_matches = "never"
    )
  if (any(!is.na(scored$raw_code) & is.na(scored$response_status))) {
    bad <- scored |>
      dplyr::filter(!is.na(.data$raw_code), is.na(.data$response_status)) |>
      dplyr::distinct(.data$poll_id, .data$source_column, .data$raw_code)
    print(bad, n = Inf)
    stop("Unmapped response code; update the reviewed item rules.")
  }
  scored |>
    dplyr::mutate(
      response_status = dplyr::if_else(
        is.na(.data$raw_code), "source_missing", .data$response_status
      ),
      missing_code = dplyr::case_when(
        is.na(.data$raw_code) ~ "system",
        .data$response_status == "non_substantive" ~
          dplyr::coalesce(.data$raw_text, as.character(.data$raw_value)),
        TRUE ~ NA_character_
      )
    ) |>
    dplyr::select(
      "poll_id", "respondent_id", "wave", "item_id", "source_row",
      "source_column", "raw_value", "raw_text", "correct",
      "response_status", "missing_code"
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
  raw <- purrr::map(items$source_column, function(column) {
    values <- survey[[column]]
    tibble::tibble(
      source_row = survey$source_row, source_column = column,
      raw_value = if (is.character(values)) NA_real_ else as.numeric(values),
      raw_text = if (is.character(values)) values else NA_character_
    )
  }) |>
    purrr::list_rbind() |>
    dplyr::inner_join(
      participants |> dplyr::select("poll_id", "respondent_id", "source_row"),
      by = "source_row", relationship = "many-to-one"
    )
  stopifnot(nrow(raw) == nrow(participants) * nrow(items))
  responses <- score_knowledge_responses(raw, items) |>
    apply_knowledge_overrides(poll_id, survey)
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

read_knowledge_battery <- function(poll_id) {
  data <- readr::read_csv(
    project_path("data", poll_id, "knowledge-battery.csv"),
    col_types = readr::cols(.default = readr::col_character()), na = "NA"
  )
  values <- unlist(data, use.names = FALSE)
  stopifnot(all(is.na(values) | values %in% c("0", "1", "FALSE", "TRUE")))
  data |>
    dplyr::mutate(dplyr::across(dplyr::everything(), function(value) {
      dplyr::if_else(
        is.na(value), NA_integer_, as.integer(value %in% c("1", "TRUE"))
      )
    }))
}

compare_knowledge_batteries <- function(tables) {
  items <- read_metadata("knowledge_items")
  poll_ids <- unique(tables$respondents$poll_id)
  comparisons <- purrr::map(poll_ids, function(poll_id) {
    specification <- items |>
      dplyr::filter(.data$poll_id == .env$poll_id)
    expected <- read_knowledge_battery(poll_id)
    people <- tables$respondents |>
      dplyr::filter(.data$poll_id == .env$poll_id) |>
      dplyr::arrange(.data$battery_row)
    if (nrow(expected) != nrow(people)) {
      return(list(
        summary = tibble::tibble(
          poll_id = poll_id, respondents = nrow(people),
          item_wave_columns = nrow(specification),
          item_differences = NA_integer_, female_differences = NA_integer_,
          benchmark_respondents = nrow(expected),
          comparison_status = "unlinked-sample-difference"
        ),
        differences = NULL, score_changes = NULL
      ))
    }

    if (poll_id == "europolis-2009") {
      rebuilt <- tables$knowledge_responses |>
        dplyr::filter(.data$poll_id == .env$poll_id) |>
        dplyr::left_join(
          specification |> dplyr::select("wave", "item_id", "benchmark_column"),
          by = c("wave", "item_id"), relationship = "many-to-one"
        ) |>
        dplyr::select("respondent_id", "benchmark_column", "correct") |>
        tidyr::pivot_wider(
          names_from = "benchmark_column", values_from = "correct"
        ) |>
        dplyr::left_join(
          people |> dplyr::select("respondent_id", "female"),
          by = "respondent_id", relationship = "one-to-one"
        ) |>
        dplyr::select(-"respondent_id")
      counts <- dplyr::full_join(
        rebuilt |>
          dplyr::count(dplyr::across(dplyr::everything()), name = "rebuilt"),
        expected |>
          dplyr::count(dplyr::across(dplyr::everything()), name = "deposited"),
        by = names(expected), relationship = "one-to-one"
      )
      same <- all(
        !is.na(counts$rebuilt), !is.na(counts$deposited),
        counts$rebuilt == counts$deposited
      )
      return(list(
        summary = tibble::tibble(
          poll_id = poll_id, respondents = nrow(people),
          item_wave_columns = nrow(specification),
          item_differences = NA_integer_, female_differences = NA_integer_,
          benchmark_respondents = nrow(expected),
          comparison_status = if (same) {
            "unordered-exact-match"
          } else {
            "unordered-different"
          }
        ),
        differences = NULL, score_changes = NULL
      ))
    }
    female_differences <-
      sum(xor(is.na(people$female), is.na(expected$female))) +
      sum(people$female != expected$female, na.rm = TRUE)
    deposited <- expected |>
      dplyr::select(dplyr::all_of(specification$benchmark_column)) |>
      dplyr::mutate(battery_row = dplyr::row_number()) |>
      tidyr::pivot_longer(
        -"battery_row",
        names_to = "benchmark_column",
        values_to = "deposited_correct"
      ) |>
      dplyr::left_join(
        people |> dplyr::select("battery_row", "respondent_id"),
        by = "battery_row", relationship = "many-to-one"
      ) |>
      dplyr::left_join(
        specification |>
          dplyr::select("benchmark_column", "poll_id", "wave", "item_id"),
        by = "benchmark_column", relationship = "many-to-one"
      )
    observed <- tables$knowledge_responses |>
      dplyr::filter(.data$poll_id == .env$poll_id)
    detail <- dplyr::inner_join(
      observed, deposited,
      by = c("poll_id", "respondent_id", "wave", "item_id"),
      relationship = "one-to-one", unmatched = "error"
    ) |>
      dplyr::mutate(
        differs = xor(is.na(.data$correct), is.na(.data$deposited_correct)) |
          tidyr::replace_na(.data$correct != .data$deposited_correct, FALSE)
      )
    stopifnot(nrow(detail) == nrow(people) * nrow(specification))
    summary <- tibble::tibble(
      poll_id = poll_id, respondents = nrow(people),
      item_wave_columns = nrow(specification),
      item_differences = sum(detail$differs),
      female_differences = female_differences,
      benchmark_respondents = nrow(expected), comparison_status = "row-aligned"
    )
    scores <- detail |>
      dplyr::group_by(.data$poll_id, .data$respondent_id, .data$wave) |>
      dplyr::summarise(
        deposited_score = sum(.data$deposited_correct, na.rm = TRUE) /
          dplyr::n(),
        rebuilt_score = sum(.data$correct, na.rm = TRUE) / dplyr::n(),
        .groups = "drop"
      ) |>
      dplyr::group_by(.data$poll_id, .data$wave) |>
      dplyr::summarise(
        respondents = dplyr::n(),
        deposited_mean = mean(.data$deposited_score),
        rebuilt_mean = mean(.data$rebuilt_score),
        changed_scores = sum(.data$deposited_score != .data$rebuilt_score),
        change_percentage_points =
          100 * mean(.data$rebuilt_score - .data$deposited_score),
        .groups = "drop"
      )
    list(
      summary = summary,
      differences = detail |> dplyr::filter(.data$differs),
      score_changes = scores
    )
  })
  c("summary", "differences", "score_changes") |>
    rlang::set_names() |>
    purrr::map(function(name) {
      purrr::map(comparisons, name) |> purrr::list_rbind()
    })
}
