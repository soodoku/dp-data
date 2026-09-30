knowledge_source_field <- function(poll, field, wave) {
  if (wave == "t1") {
    return(field)
  }
  stopifnot(wave %in% c("t2", "t3"))
  switch(poll,
    "btp-general-election-2004" = sub("^w4b", "w4f", field),
    "btp-health-education-2005" = paste0(field, "post"),
    "btp-national-2003" = sub("^qb", "qf", field),
    "btp-presidential-primaries-2004" = sub("^b1", "f1", field),
    "bulgaria-crime-2002" = paste0(field, "p"),
    "europolis-2009" = sub("^V1", "V3", field),
    "new-haven-2004" = sub("^pre_", "post_", field),
    "nic2-2003" = paste0("q", field),
    "san-mateo-2008" = paste0("t2", field),
    "tomorrows-europe-2007" = if (grepl("^q33", field)) {
      sub("^q33([ab])_1$", "t3q36\\1", field)
    } else {
      paste0("t3q", as.integer(sub("^q([0-9]+)_1$", "\\1", field)) + 3L)
    },
    "uk-monarchy-1996" = sub("^Q", "R", field),
    "zeguo-2005" = sub("^pre_", "post_", field),
    {
      stopifnot(poll %in% c(
        "australia-republic-1999", "cpl-1996", "nic-1996", "swepco-1996",
        "uk-crime-1994", "uk-eu-1995", "uk-general-election-1997",
        "uk-health-1998", "wtu-1996"
      ), grepl("1$", field))
      sub("1$", sub("^t", "", wave), field)
    }
  )
}

recover_knowledge_raw <- function(items, catalog = read_metadata("items")) {
  positions <- which(items$source_dataset == "historical" &
                       is.na(items$source_column))
  if (!length(positions)) {
    return(items)
  }
  for (poll in unique(items$poll_id[positions])) {
    survey <- read_poll_survey(poll)
    stopifnot(!anyDuplicated(survey$source_row))
    rows <- positions[items$poll_id[positions] == poll]
    bank <- catalog[catalog$poll_id == poll, ]
    stopifnot(!anyDuplicated(bank$item_id))
    waves <- if ("original_score_wave" %in% names(items)) {
      items$original_score_wave[rows]
    } else {
      items$wave[rows]
    }
    eligible <- waves %in% c("t1", "t2", "t3")
    rows <- rows[eligible]
    waves <- waves[eligible]
    definitions <- match(items$item_id[rows], bank$item_id)
    stopifnot(!anyNA(definitions))
    fields <- mapply(knowledge_source_field, poll,
      bank$source_column_t1[definitions], waves,
      USE.NAMES = FALSE
    )
    field_positions <- match(tolower(fields), tolower(names(survey)))
    stopifnot(!anyNA(field_positions))
    fields <- names(survey)[field_positions]
    source_rows <- match(items$source_row[rows], survey$source_row)
    stopifnot(!anyNA(source_rows))
    for (field in unique(fields)) {
      take <- which(fields == field)
      target <- rows[take]
      values <- survey[[field]][source_rows[take]]
      items$source_column[target] <- field
      if (is.character(values)) {
        items$raw_text[target] <- values
      } else {
        items$raw_value[target] <- as.numeric(values)
      }
    }
  }
  items
}

knowledge_normalize_label <- function(label) {
  text <- tolower(trimws(label))
  text <- gsub("[\u2019\u2018]", "'", text)
  text <- gsub("couldn\u00c6t", "couldn't", text, ignore.case = TRUE)
  text <- gsub("[()]", "", text)
  text <- sub("^[0-9]+([.][0-9]+)?[. :]+", "", text)
  text <- gsub("[[:space:]]+", " ", text)
  trimws(sub("[ .?!]+$", "", text))
}

knowledge_label_reason <- function(label) {
  text <- knowledge_normalize_label(label)
  dk <- c(
    "dk", "d.k", "don't know", "dont know", "do not know", "can't say",
    "cannot say", "couldn't say", "could not say", "can't choose",
    "cannot choose",
    "not sure", "unsure", "don't know haven't thought", "not much idea",
    "ved ikke", "no opinion",
    "not much impression",
    "haven't thought much about this", "haven't thought much about that",
    "haven't thought much about it", "you couldn't say",
    "or couldn't you say about that",
    "or couldn t you say about that", "or couldn t say about that",
    "or couldn't say about that", "don't you have much idea about that",
    "haven't heard anything about this", "not much impression/don't know",
    "not much impression/dont know", "no opinion / don't know"
  )
  dplyr::case_when(
    text %in% dk ~ "dk",
    text %in% c("refused", "refuse", "refusal", "ref") ~ "refused",
    text %in% c(
      "not asked", "not applicable", "item not applicable",
      "inapplicable", "not in universe", "inap"
    ) ~ "not_asked",
    text %in% c(
      "skipped", "skip", "skipped on web", "skipped on web/papi",
      "not answered", "no answer",
      "unanswered", "blank"
    ) ~ "blank",
    text %in% c(
      "missing", "system missing", "not available", "unknown",
      "na", "no response / don't know", "don't know / no response",
      "n/a / refused"
    ) ~
      "unclassified_nonanswer",
    text %in% c("multiple responses", "multiple answers") ~ "invalid_response",
    TRUE ~ NA_character_
  )
}

analysis_knowledge_labels <- function(poll, catalog, fields) {
  path <- project_path("data", poll, "value-labels.csv")
  labels <- if (file.exists(path)) {
    readr::read_csv(path,
      col_types = readr::cols(.default = readr::col_character()),
      na = "", show_col_types = FALSE
    ) |>
      dplyr::transmute(
        source_column = tolower(source_column),
        code = source_value, source_response_label = value_label
      )
  } else {
    tibble::tibble(
      source_column = character(), code = character(),
      source_response_label = character()
    )
  }
  if (poll == "denmark-euro-2000") {
    phase_labels <- purrr::map_dfr(c("arrival", "departure"), function(phase) {
      readr::read_csv(
        project_path("data", poll, paste0(phase, "-value-labels.csv")),
        col_types = readr::cols(.default = readr::col_character()),
        na = "", show_col_types = FALSE
      ) |>
        dplyr::transmute(
          source_column = tolower(paste0(
            if (phase == "departure") "T2_" else "", source_column
          )),
          code = source_value, source_response_label = value_label
        )
    })
    labels <- dplyr::bind_rows(labels, phase_labels)
  }
  if (poll == "america-in-one-room-2019") {
    labels <- readr::read_tsv(
      project_path(
        "data", poll, "codebooks",
        "a1r_codebook.tab"
      ),
      col_types = readr::cols(.default = readr::col_character()),
      na = "", show_col_types = FALSE
    ) |>
      dplyr::mutate(Variable = dplyr::na_if(Variable, "")) |>
      tidyr::fill(Variable) |>
      dplyr::filter(!is.na(Value)) |>
      dplyr::transmute(
        source_column = tolower(Variable), code = Value,
        source_response_label = ValueLabel
      )
  }
  reviewed <- read_metadata("knowledge_response_codes", na = "") |>
    dplyr::filter(poll_id == poll) |>
    dplyr::transmute(
      source_column = tolower(source_column),
      code = as.character(code),
      source_response_label = label, reviewed_reason = response_reason
    )
  stopifnot(!anyDuplicated(reviewed[c("source_column", "code")]))
  labels <- dplyr::filter(labels, !is.na(source_response_label))
  labels <- dplyr::bind_rows(labels, dplyr::anti_join(reviewed, labels,
    by = c("source_column", "code")
  ))
  # Explicit numeric answer choices supply labels for control sources without
  # a value-label dictionary. They do not assign undocumented missing codes.
  bank <- catalog[catalog$poll_id == poll, ]
  bank <- bank[bank$poll_id %in% c(
    "a1r-climate-2021", "america-in-one-room-2019", "amr-2024",
    "zeguo-2005", "new-haven-2004", "cpl-1996", "nic-1996"
  ), ]
  choices <- lapply(seq_len(nrow(bank)), function(i) {
    choice <- strsplit(bank$answer_choices[i], "|", fixed = TRUE)[[1]]
    choice <- trimws(choice[!is.na(choice)])
    choice <- choice[grepl("^-?[0-9]+([.][0-9]+)?:", choice)]
    tibble::tibble(
      item_id = bank$item_id[i],
      code = sub(":.*$", "", choice),
      source_response_label = trimws(sub("^[^:]+:", "", choice))
    )
  }) |>
    dplyr::bind_rows()
  labels <- labels[labels$source_column %in% tolower(fields), ] |>
    dplyr::distinct()
  stopifnot(!anyDuplicated(labels[c("source_column", "code")]))
  score_labels <- knowledge_normalize_label(labels$source_response_label)
  scored_fields <- unique(labels$source_column[score_labels %in%
    c(
      "correct", "incorrect", "correct answer", "incorrect answer",
      "wrong answer"
    )])
  list(fields = labels, choices = choices, scored_fields = scored_fields)
}

enrich_knowledge_responses <- function(
  items,
  catalog = read_metadata("items")
) {
  before_correct <- items$correct
  items <- recover_knowledge_raw(items, catalog)
  rules <- read_metadata("knowledge_items") |>
    tidyr::pivot_longer(
      c(
        "correct_values", "incorrect_values",
        "missing_values"
      ),
      names_to = "kind", values_to = "code"
    ) |>
    dplyr::filter(!is.na(code), code != "") |>
    tidyr::separate_longer_delim(code, delim = "|") |>
    dplyr::mutate(source_column = tolower(source_column))
  rule_keys <- paste(rules$poll_id, rules$source_column, rules$code,
    sep = "\r"
  )
  stopifnot(!anyDuplicated(rule_keys))
  items$knowledge_response <- NA_character_
  items$response_reason <- NA_character_
  items$source_response_label <- NA_character_
  for (poll in unique(items$poll_id)) {
    rows <- which(items$poll_id == poll)
    values <- items$raw_value[rows]
    text <- items$raw_text[rows]
    classified <- values
    near_integer <- !is.na(values) & abs(values - round(values)) < 1e-8
    classified[near_integer] <- round(classified[near_integer])
    code <- ifelse(is.na(text), as.character(classified), text)
    labels <- analysis_knowledge_labels(
      poll, catalog,
      items$source_column[rows]
    )
    dictionary <- labels$fields
    keys <- paste(tolower(items$source_column[rows]), code, sep = "\r")
    matched <- match(keys, paste(dictionary$source_column, dictionary$code,
      sep = "\r"
    ))
    label <- dictionary$source_response_label[matched]
    choices <- labels$choices
    if (nrow(choices)) {
      fallback <- match(
        paste(items$item_id[rows], code, sep = "\r"),
        paste(choices$item_id, choices$code, sep = "\r")
      )
      use <- is.na(label)
      label[use] <- choices$source_response_label[fallback[use]]
    }
    rule_code <- code
    has_text <- !is.na(text)
    rule_code[has_text] <- knowledge_raw_code(
      rep(poll, sum(has_text)), rep(NA_real_, sum(has_text)), text[has_text]
    )
    requested <- paste(
      poll, tolower(items$source_column[rows]), rule_code,
      sep = "\r"
    )
    matched_rule <- match(requested, rule_keys)
    code_rule <- rules$kind[matched_rule]
    reason <- knowledge_label_reason(label)
    reviewed_reason <- dictionary$reviewed_reason[matched]
    use_reviewed <- !is.na(reviewed_reason)
    stopifnot(all(is.na(reason[use_reviewed]) |
                    reason[use_reviewed] == reviewed_reason[use_reviewed]))
    reason[use_reviewed] <- reviewed_reason[use_reviewed]
    from_text <- knowledge_label_reason(text)
    reason[is.na(reason)] <- from_text[is.na(reason)]
    absent <- items$response_status[rows] == "wave_absent"
    if ("wave_observed" %in% names(items)) {
      absent <- absent | items$wave_observed[rows] %in% FALSE
    }
    raw_missing <- is.na(values) & (is.na(text) | !nzchar(trimws(text)))
    scored_only <- is.na(items$source_column[rows]) |
      tolower(items$source_column[rows]) %in% labels$scored_fields
    nonanswer <- items$response_status[rows] == "non_substantive" |
      code_rule %in% "missing_values"
    reason[is.na(reason) & nonanswer] <- "unclassified_nonanswer"
    reviewed_answer <- code_rule %in% c("correct_values", "incorrect_values") |
      (!is.na(label) & !is.na(code))
    bank <- catalog[catalog$poll_id == poll, ]
    definition <- match(items$item_id[rows], bank$item_id)
    if (poll %in% c("btp-national-2003", "nic2-2003")) {
      placement <- bank$response_type[definition] %in% "placement scale"
      reviewed_answer <- reviewed_answer | (placement & classified %in% 0:10)
    }
    if (poll == "nic-1996") {
      open <- bank$response_type[definition] %in% "open numeric"
      valid_percent <- open & !is.na(classified) &
        classified >= 0 & classified <= 100
      reviewed_answer <- reviewed_answer | valid_percent
    }
    reason[is.na(reason) & !raw_missing & reviewed_answer] <- "answered"
    reason[is.na(reason) & !raw_missing] <- "unreviewed_code"
    reason[is.na(reason) & raw_missing] <- "source_missing"
    reason[scored_only & !reason %in% c(
      "dk", "refused", "blank",
      "not_asked"
    )] <- "scored_only"
    reason[absent] <- "wave_absent"
    response <- rep(NA_character_, length(rows))
    response[reason == "dk"] <- "dk"
    response[reason == "answered" & items$correct[rows] %in% 0L] <- "incorrect"
    response[!reason %in% c(
      "dk", "refused", "blank", "not_asked",
      "wave_absent", "invalid_response"
    ) &
      items$correct[rows] %in% 1L] <- "correct"
    items$knowledge_response[rows] <- response
    items$response_reason[rows] <- reason
    items$source_response_label[rows] <- label
  }
  stopifnot(
    identical(items$correct, before_correct),
    all(is.na(items$knowledge_response) |
          items$knowledge_response %in% c("correct", "incorrect", "dk")),
    !anyNA(items$response_reason)
  )
  items
}

standardize_knowledge_scores <- function(
  items,
  wave_observed = items$wave_observed
) {
  stopifnot(
    length(wave_observed) == nrow(items), is.logical(wave_observed),
    all(c(
      "knowledge_response", "response_reason",
      "correct"
    ) %in% names(items))
  )
  change <- is.na(items$correct) & wave_observed %in% TRUE &
    items$response_reason %in% c(
      "dk", "refused", "blank", "source_missing",
      "unclassified_nonanswer"
    )
  invalid <- items$response_reason %in% "invalid_response" &
    !is.na(items$correct)
  changes <- items[change | invalid, intersect(c(
    "poll_id", "source_dataset", "respondent_id",
    "item_id", "wave", "source_column", "response_reason"
  ), names(items))]
  items$correct[change] <- 0L
  items$correct[invalid] <- NA_integer_
  observed_blank <- wave_observed %in% TRUE & items$correct %in% 0L &
    items$response_reason %in% c("blank", "source_missing")
  items$knowledge_response[observed_blank] <- "dk"
  items$knowledge_response[items$response_reason %in% "invalid_response"] <-
    NA_character_
  conflicts <- items[items$knowledge_response %in% "dk" &
                       items$correct %in% 1L, ]
  list(
    items = items, n_changed = sum(change | invalid), changes = changes,
    dk_correct_conflicts = conflicts
  )
}
