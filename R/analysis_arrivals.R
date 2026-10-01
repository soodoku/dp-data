analysis_arrival_items <- function(participants) {
  polls <- c(
    "california-whats-next-2011", "europolis-2009",
    "denmark-euro-2000", "vermont-energy-2007", "michigan-2009"
  )
  bank <- read_metadata("knowledge_items")
  catalog <- read_metadata("items")
  score_wave <- c(t0 = "t1", t1 = "arrival", t2 = "t2")
  purrr::map(polls, function(poll) {
    people <- participants |>
      dplyr::filter(
        poll_id == poll, source_dataset %in% c("cor_sood", "historical")
      )
    survey <- read_poll_survey(poll)
    position <- match(people$source_row, survey$source_row)
    stopifnot(!anyNA(position), !anyDuplicated(survey$source_row))
    data <- survey[position, , drop = FALSE]
    id_column <- switch(poll,
      "california-whats-next-2011" = "id",
      "europolis-2009" = "UniqueID",
      "denmark-euro-2000" = "delnr",
      "vermont-energy-2007" = "CASEID",
      "michigan-2009" = "postit"
    )
    cor <- people$source_dataset == "cor_sood"
    stopifnot(all(as.character(as.numeric(data[[id_column]][cor])) ==
                    people$respondent_id[cor]))
    specifications <- bank |>
      dplyr::filter(poll_id == poll, wave == 2L) |>
      dplyr::arrange(item_order)
    keys <- strsplit(specifications$correct_values, "|", fixed = TRUE)
    fields <- specifications$source_column
    item_ids <- catalog |>
      dplyr::filter(poll_id == poll, !is.na(cor_item_id)) |>
      dplyr::arrange(match(cor_item_id, specifications$item_id)) |>
      dplyr::pull(item_id)
    stopifnot(length(item_ids) == nrow(specifications))
    if (poll == "denmark-euro-2000") {
      arrival <- haven::read_sav(
        project_path("data", poll, "arrival.sav"),
        user_na = TRUE
      )
      stopifnot(!anyNA(arrival$DELNR), !anyDuplicated(arrival$DELNR))
      index <- match(as.numeric(people$respondent_id), arrival$DELNR)
      arrival_data <- arrival[index, , drop = FALSE]
      arrival_data$source_row <- as.integer(index)
      fields <- sub("_2$", "_1", sub("^T2_", "", fields))
    } else {
      arrival_data <- data
      fields <- switch(poll,
        "california-whats-next-2011" = sub("^t3", "t2", fields),
        "europolis-2009" = sub("^V3", "V2", fields),
        "vermont-energy-2007" = sub("T3$", "T2", fields),
        "michigan-2009" = sub("^t3", "t2", fields)
      )
    }
    presence <- function(source, wave) {
      source_wave <- if (wave == "t1") 2 else 3
      pattern <- switch(poll,
        "california-whats-next-2011" = paste0("^t", source_wave, "q[0-9]"),
        "europolis-2009" = paste0("^V", source_wave, "Q[0-9]"),
        "vermont-energy-2007" = paste0("^Q[0-9]+[A-Z]?T", source_wave, "$"),
        "denmark-euro-2000" = "^S[0-9]",
        "michigan-2009" = if (wave == "t0") {
          "^q[0-9]"
        } else {
          paste0("^t", source_wave, "q[0-9]")
        }
      )
      columns <- grep(pattern, names(source), value = TRUE)
      stopifnot(length(columns) > 9L)
      answers <- lapply(source[columns], function(x) {
        if (is.numeric(x)) {
          !is.na(x) & !as.numeric(x) %in% c(997, 998, 999)
        } else {
          !is.na(x) & nzchar(trimws(as.character(x)))
        }
      })
      rowSums(as.data.frame(answers)) > 0L
    }
    make_items <- function(source, columns, correct_keys, ids, phase, suffix) {
      stopifnot(
        length(columns) == length(correct_keys),
        length(columns) == length(ids), all(columns %in% names(source))
      )
      observed <- presence(source, phase)
      purrr::map(seq_along(columns), function(i) {
        raw <- source[[columns[i]]]
        text_item <- poll == "michigan-2009" && is.character(raw)
        numeric <- if (text_item) {
          rep(NA_real_, length(raw))
        } else {
          suppressWarnings(as.numeric(as.character(raw)))
        }
        raw_text <- if (text_item) as.character(raw) else NA_character_
        raw_code <- if (text_item) {
          knowledge_raw_code(rep(poll, length(raw)), numeric, raw_text)
        } else {
          as.character(numeric)
        }
        allowed <- switch(poll,
          "california-whats-next-2011" = c(0:5, 88, 98, 99),
          "europolis-2009" = c(1:5, 8, 9, 98, 99, 997:999),
          "denmark-euro-2000" = 1:5,
          "vermont-energy-2007" = c(1:5, 88, 99),
          "michigan-2009" = c(1:7, 9, 98, 99)
        )
        stopifnot(all(is.na(numeric) | numeric %in% allowed))
        tibble::tibble(
          poll_id = poll, source_dataset = people$source_dataset,
          respondent_id = people$respondent_id,
          battery_id = paste(poll, people$source_dataset, suffix, sep = ":"),
          wave = phase, original_score_wave = unname(score_wave[phase]),
          item_id = ids[i], source_row = as.integer(source$source_row),
          source_column = columns[i], raw_value = numeric,
          raw_text = raw_text,
          correct = dplyr::if_else(observed,
            as.integer(raw_code %in% correct_keys[[i]]), NA_integer_
          ),
          response_status = dplyr::case_when(
            !observed ~ "wave_absent",
            is_response_empty(numeric, raw_text) ~
              "source_missing",
            numeric %in% c(997, 998, 999) ~ "non_substantive", TRUE ~ "answered"
          ),
          wave_observed = observed
        )
      }) |>
        purrr::list_rbind()
    }
    if (poll == "michigan-2009") {
      shared <- 6:9
      before <- bank |>
        dplyr::filter(poll_id == poll, wave == 1L) |>
        dplyr::arrange(item_order)
      common <- dplyr::bind_rows(
        make_items(
          data, before$source_column[shared], keys[shared],
          item_ids[shared], "t0", "knowledge_placements_four"
        ),
        make_items(
          arrival_data, fields[shared], keys[shared],
          item_ids[shared], "t1", "knowledge_placements_four"
        ),
        make_items(
          data, specifications$source_column[shared], keys[shared],
          item_ids[shared], "t2", "knowledge_placements_four"
        )
      )
      expanded <- purrr::map(c("t1", "t2"), function(phase) {
        prefix <- if (phase == "t1") "t2q" else "t3q"
        make_items(
          data, paste0(prefix, c(10, 11, 13, 14, 7, 8)),
          c(keys[shared], list(1:3, 5:7)),
          c(item_ids[shared], "knowledge_010", "knowledge_011"),
          phase, "knowledge_placements_six"
        )
      }) |>
        purrr::list_rbind()
      arrival_keys <- list(
        c("rep", "repbulican", "republican", "republicans", "repubs",
          "gop", "rethuglican", "r", "rpublicans"),
        c("d", "dem", "demo", "democrat", "democrats", "democratic",
          "democrate", "dems", "democrates", "democratsithink",
          "democratsnotsure", "demorcraticparty"),
        "a", "a", "c"
      )
      full <- make_items(
        arrival_data, fields, c(arrival_keys, keys[shared]),
        item_ids, "t1", "knowledge"
      )
      return(dplyr::bind_rows(common, expanded, full))
    }
    common <- make_items(
      arrival_data, fields, keys, item_ids, "t1", "knowledge"
    )
    expanded <- NULL
    if (poll %in% c("california-whats-next-2011", "europolis-2009")) {
      european <- poll == "europolis-2009"
      numbers <- if (european) c(43, 44, 46, 47, 49, 50, 45, 48, 51) else 27:34
      extra_keys <- if (european) list(1, 1, 2) else list(1, 2, 2)
      extra_ids <- sprintf("knowledge_%03d", if (european) 7:9 else 6:8)
      expanded <- purrr::map(c("t1", "t2"), function(phase) {
        prefix <- if (poll == "europolis-2009") "V" else "t"
        letter <- if (poll == "europolis-2009") "Q" else "q"
        columns <- paste0(prefix, if (phase == "t1") 2 else 3, letter, numbers)
        suffix <- if (european) {
          "knowledge_expanded_nine"
        } else {
          "knowledge_expanded_eight"
        }
        make_items(
          data, columns, c(keys, extra_keys),
          c(item_ids, extra_ids), phase, suffix
        )
      }) |>
        purrr::list_rbind()
    }
    dplyr::bind_rows(common, expanded)
  }) |>
    purrr::list_rbind()
}

analysis_arrival_scores <- function(items) {
  roles <- read_metadata("analysis_phase_roles")
  items |>
    dplyr::summarise(
      n_items = as.integer(dplyr::n()),
      n_observed = if (dplyr::first(wave_observed)) {
        as.integer(sum(
          !is_response_empty(raw_value, raw_text)
        ))
      } else {
        0L
      },
      wave_observed = dplyr::first(wave_observed),
      n_correct = if (dplyr::first(wave_observed)) {
        as.integer(sum(correct, na.rm = TRUE))
      } else {
        NA_integer_
      },
      .by = c(
        poll_id, source_dataset, respondent_id, battery_id, wave,
        original_score_wave
      )
    ) |>
    dplyr::mutate(score = n_correct / n_items, scale = "proportion_correct") |>
    dplyr::left_join(
      dplyr::select(roles, "poll_id", "source_dataset",
        original_score_wave = "score_wave",
        "wave_role", "timing_evidence"
      ),
      by = c("poll_id", "source_dataset", "original_score_wave"),
      relationship = "many-to-one"
    )
}

analysis_intermediate_items <- function(participants, scores) {
  catalog <- read_metadata("items")
  keys <- c("poll_id", "source_dataset", "respondent_id")
  purrr::map(c("new-haven-2004", "tomorrows-europe-2007"), function(poll) {
    measurements <- scores |>
      dplyr::filter(
        poll_id == poll, source_dataset == "historical",
        original_score_wave == "knowledge_midterm"
      ) |>
      dplyr::inner_join(
        dplyr::select(
          participants, dplyr::all_of(keys),
          "source_row"
        ),
        by = keys, relationship = "one-to-one"
      )
    survey <- read_poll_survey(poll)
    positions <- match(measurements$source_row, survey$source_row)
    stopifnot(!anyNA(positions), !anyDuplicated(survey$source_row))
    bank <- catalog |>
      dplyr::filter(poll_id == poll) |>
      dplyr::arrange(item_id)
    fields <- if (poll == "new-haven-2004") {
      sub("^pre_", "mid_", bank$source_column_t1)
    } else {
      vapply(bank$source_column_t1, function(field) {
        sub("^t3", "t2", knowledge_source_field(poll, field, "t2"))
      }, character(1), USE.NAMES = FALSE)
    }
    stopifnot(
      all(fields %in% names(survey)),
      all(measurements$n_items == nrow(bank))
    )
    items <- purrr::map(seq_len(nrow(bank)), function(i) {
      raw <- as.numeric(survey[[fields[i]]][positions])
      correct_codes <- as.numeric(strsplit(
        bank$correct_codes[i], "|", fixed = TRUE
      )[[1]])
      # Telephone placement codes start at1; arrival and exit start at0.
      placement <- grepl("^q33", bank$source_column_t1[i])
      if (poll == "tomorrows-europe-2007" && placement) {
        correct_codes <- correct_codes - 1
      }
      tibble::tibble(
        poll_id = poll, source_dataset = measurements$source_dataset,
        respondent_id = measurements$respondent_id,
        battery_id = measurements$battery_id, wave = measurements$wave,
        original_score_wave = measurements$original_score_wave,
        item_id = bank$item_id[i], source_row = measurements$source_row,
        source_column = fields[i], raw_value = raw, raw_text = NA_character_,
        correct = dplyr::if_else(measurements$wave_observed %in% TRUE,
          as.integer(raw %in% correct_codes), NA_integer_
        ),
        response_status = dplyr::case_when(
          measurements$wave_observed %in% FALSE ~ "wave_absent",
          is.na(raw) ~ "source_missing", TRUE ~ "answered"
        ),
        wave_observed = measurements$wave_observed
      )
    }) |>
      purrr::list_rbind()
    rebuilt <- items |>
      dplyr::summarise(
        rebuilt = sum(correct) / dplyr::n(),
        .by = dplyr::all_of(keys)
      ) |>
      dplyr::left_join(
        dplyr::select(measurements, dplyr::all_of(keys),
                      "score", "wave_observed"),
        by = keys, relationship = "one-to-one"
      )
    rebuilt$expected <- dplyr::if_else(
      rebuilt$wave_observed %in% TRUE, rebuilt$score, NA_real_
    )
    stopifnot(
      all(abs(rebuilt$rebuilt - rebuilt$expected) < 1e-10, na.rm = TRUE),
      identical(is.na(rebuilt$rebuilt), is.na(rebuilt$expected))
    )
    items
  }) |>
    purrr::list_rbind()
}

analysis_phase_items <- function(items, scores, arrivals, participants) {
  keys <- c("poll_id", "source_dataset", "respondent_id")
  selected <- scores |>
    dplyr::filter(grepl(":knowledge$", battery_id)) |>
    dplyr::select(
      dplyr::all_of(keys), "battery_id", "wave",
      "original_score_wave", "wave_observed"
    )
  original <- items |>
    dplyr::rename(original_score_wave = "wave") |>
    dplyr::inner_join(selected,
      by = c(keys, "original_score_wave"), relationship = "many-to-one"
    ) |>
    dplyr::mutate(
      correct = dplyr::if_else(wave_observed %in% FALSE, NA_integer_, correct),
      response_status = dplyr::if_else(
        wave_observed %in% FALSE, "wave_absent", response_status
      )
    )
  dplyr::bind_rows(original, arrivals, analysis_intermediate_items(
    participants, scores
  )) |>
    add_analysis_wave_identity() |>
    dplyr::select(
      "poll_id", "source_dataset", "respondent_id", "battery_id",
      "wave", "item_id",
      "source_row", "source_column", "raw_value", "raw_text",
      "correct", "response_status",
      "wave_observed", "original_score_wave", "study_id", "wave_instance_id",
      "original_survey_wave"
    )
}
