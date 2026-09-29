item_display_text <- function(values) {
  replacements <- c(
    "gov general" = "Governor-General", "governor general" = "Governor-General",
    "appts" = "appointed", "recommend of" = "recommendation of",
    "p.m." = "prime minister", "w/o" = "without", "w/" = "with",
    "later house approve" = "later House approval", "dont" = "don't",
    "british" = "British", "australian" = "Australian", "american" = "American",
    "liberal party" = "Liberal Party", "labor party" = "Labor Party",
    "labor member" = "Labor member", "democrats" = "Democrats",
    "high court" = "High Court", "parliament" = "Parliament",
    "house" = "House", "queen" = "Queen",
    "teachers federation" = "Teachers Federation"
  )
  normalize <- function(text) {
    letters <- gsub("[^[:alpha:]]", "", gsub("\\(correct\\)", "", text))
    if (!nzchar(letters) || letters != toupper(letters)) {
      return(text)
    }
    text <- tolower(text)
    for (word in names(replacements)) {
      text <- gsub(word, replacements[[word]], text, fixed = TRUE)
    }
    match <- regexpr("[[:alpha:]]", text)
    if (match > 0L) {
      substr(text, match, match) <- toupper(substr(text, match, match))
    }
    text
  }
  vapply(values, function(value) {
    if (is.na(value)) {
      return(NA_character_)
    }
    paste(vapply(
      strsplit(value, " | ", fixed = TRUE)[[1]], normalize,
      character(1)
    ), collapse = " | ")
  }, character(1), USE.NAMES = FALSE)
}

analysis_item_catalog <- function() {
  readr::read_csv(
    project_path("metadata", "items.csv"), show_col_types = FALSE
  ) |>
    dplyr::mutate(dplyr::across(
      c("question", "answer_choices", "correct_answer"), item_display_text,
      .names = "{.col}_display"
    ))
}

analysis_historical_people <- function() {
  people <- arrow::read_parquet(project_path(
    "output", "respondent", "people.parquet"
  ))
  legacy <- arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  ))
  polls <- read_metadata("respondent_sources") |>
    dplyr::select("poll_id", "dpnum")
  selected <- legacy |>
    dplyr::left_join(polls, by = "dpnum", relationship = "many-to-one") |>
    dplyr::transmute(
      poll_id, historical_respondent_id = as.character(caseid),
      group_id = as.character(pollgroup), cluster_id = as.character(pollgroup),
      ba = as.numeric(educ3 == 1), female, age = ppage, education = educ3,
      minority, extremity = attextreme, historical_panel = TRUE
    )
  stopifnot(!anyNA(selected$poll_id), !anyDuplicated(selected[c(
    "poll_id", "historical_respondent_id"
  )]))
  people |>
    dplyr::left_join(
      selected, by = c("poll_id", "historical_respondent_id"),
      relationship = "many-to-one"
    ) |>
    dplyr::transmute(
      poll_id, source_dataset = "historical", respondent_id,
      historical_respondent_id, source_row, identity_basis, arm = "surveyed",
      assignment = NA_character_,
      attended = dplyr::if_else(dplyr::coalesce(historical_panel, FALSE),
                                TRUE, NA),
      panel = dplyr::coalesce(historical_panel, FALSE),
      small_group_id = group_id, cluster_id,
      country = NA_character_,
      weight = NA_real_, ba, female, age, education, minority, extremity,
      score_wave1 = NA_real_, score_wave2 = NA_real_
    )
}

analysis_cor_people <- function() {
  memberships <- arrow::read_parquet(project_path(
    "output", "memberships.parquet"
  )) |>
    dplyr::filter(session_id == "deliberation") |>
    dplyr::select("poll_id", "respondent_id", "group_id")
  stopifnot(!anyDuplicated(memberships[c("poll_id", "respondent_id")]))
  arrow::read_parquet(project_path("output", "respondents.parquet")) |>
    dplyr::left_join(memberships, by = c("poll_id", "respondent_id"),
                     relationship = "one-to-one") |>
    dplyr::transmute(
      poll_id, source_dataset = "cor_sood", respondent_id, source_row,
      historical_respondent_id = NA_character_,
      identity_basis = "source-or-file-row", arm,
      assignment = NA_character_, attended = NA,
      panel = TRUE, small_group_id = group_id, cluster_id = group_id,
      country = NA_character_, weight = NA_real_, ba = NA_real_, female,
      score_wave1 = NA_real_, score_wave2 = NA_real_
    )
}

analysis_marousi_source <- function() {
  raw <- haven::read_sav(project_path(
    "data", "marousi-2006", "survey.sav"
  )) |>
    dplyr::mutate(original_source_row = dplyr::row_number())
  stopifnot(
    nrow(raw) == 1275L, !anyNA(raw$P_Q1_0),
    !anyDuplicated(raw$P_Q1_0)
  )
  observed <- function(prefix) {
    columns <- grep(prefix, names(raw), value = TRUE)
    columns <- setdiff(columns, c("AR_CODE", "F_CODE"))
    stopifnot(length(columns) > 7L)
    rowSums(!is.na(raw[columns])) > 0L
  }
  count_correct <- function(columns) {
    flags <- as.data.frame(lapply(raw[columns], as.numeric))
    stopifnot(length(columns) == 7L, all(
      is.na(as.matrix(flags)) | as.matrix(flags) %in% 0:1
    ))
    as.integer(rowSums(flags == 1, na.rm = TRUE))
  }
  source <- raw |>
    dplyr::mutate(
      arrival_observed = observed("^AR_"),
      departure_observed = observed("^F_"),
      arrival_n_observed = as.integer(rowSums(!is.na(
        raw[paste0("AR_Q", 14:20)]
      ))),
      departure_n_observed = as.integer(rowSums(!is.na(
        raw[paste0("F_Q", 14:20)]
      ))),
      arrival_correct = count_correct(c(
        "KQ1_T2", "KQ2POPT2", "KQ3STORE", "KQ4WASTE",
        "KQ5PERT2", "KQ6TRANT", "KQ7METRO"
      )),
      departure_correct = count_correct(c(
        "KQ1_T3", "KQ2POPT3", "KQ3STOR0", "KQ4WAST0",
        "KQ5PERT3", "KQ6TRAN0", "KQ7METR0"
      ))
    ) |>
    dplyr::filter(!is.na(GROUP)) |>
    dplyr::transmute(
      caseid = 79999L + dplyr::row_number(), original_source_row,
      original_respondent_id = as.character(P_Q1_0),
      source_group = 200000 + as.numeric(GROUP),
      telephone_score = as.numeric(KNOWT1),
      historical_departure_score = dplyr::coalesce(as.numeric(KNOWT3), 0),
      arrival_observed, departure_observed,
      arrival_n_observed, departure_n_observed,
      arrival_correct, departure_correct
    )
  historical <- readr::read_csv(project_path(
    "data", "marousi-2006", "participants.csv"
  ), show_col_types = FALSE)
  out <- dplyr::left_join(historical, source,
    by = "caseid", relationship = "one-to-one"
  )
  stopifnot(
    nrow(source) == 146L, nrow(out) == nrow(historical),
    !anyNA(out$original_source_row),
    all(out$pollgroup == out$source_group),
    all(abs(out$t1know - out$telephone_score) < 1e-7),
    all(abs(out$t2know - out$historical_departure_score) < 1e-7)
  )
  out
}

analysis_marousi_scores <- function(source) {
  columns <- c("poll_id", "source_dataset", "respondent_id", "wave",
               "n_items", "n_observed", "n_correct", "score", "scale")
  telephone <- source |>
    dplyr::transmute(
      poll_id = "marousi-2006", source_dataset = "score_only",
      respondent_id = as.character(caseid), wave = "t0",
      n_items = 7L, n_observed = NA_integer_,
      n_correct = as.integer(round(t1know * 7)),
      score = as.numeric(t1know), scale = "proportion_correct"
    )
  later_score <- function(role, wave_id) {
    observed <- source[[paste0(role, "_observed")]]
    correct <- source[[paste0(role, "_correct")]]
    n_observed <- source[[paste0(role, "_n_observed")]]
    tibble::tibble(
      poll_id = "marousi-2006", source_dataset = "score_only",
      respondent_id = as.character(source$caseid), wave = wave_id,
      n_items = 7L,
      n_observed = dplyr::if_else(observed, n_observed, 0L),
      n_correct = dplyr::if_else(observed, correct, NA_integer_),
      score = dplyr::if_else(observed, correct / 7, NA_real_),
      scale = "proportion_correct"
    )
  }
  later <- purrr::map2(c("arrival", "departure"), c("t1", "t2"), later_score) |>
    purrr::list_rbind()
  dplyr::bind_rows(telephone, later) |>
    dplyr::select(dplyr::all_of(columns))
}

analysis_control_sources <- function() {
  list(
    a1r = readr::read_tsv(project_path(
      "data", "america-in-one-room-2019", "participants.tab"
    ), show_col_types = FALSE) |>
      dplyr::mutate(source_row = dplyr::row_number()),
    climate = readr::read_tsv(project_path(
      "data", "a1r-climate-2021", "participants.tab"
    ), show_col_types = FALSE) |>
      dplyr::mutate(source_row = dplyr::row_number()),
    tanzania = haven::read_dta(project_path(
      "data", "tanzania-2015", "participants.dta"
    )) |>
      dplyr::filter(
        sample == "Citizens" | haven::as_factor(sample) == "Citizens"
      ),
    amr = readr::read_csv(project_path(
      "data", "amr-2024", "participants.csv"
    ), show_col_types = FALSE),
    northern_ireland = arrow::read_parquet(project_path(
      "data", "northern-ireland-2007", "survey.parquet"
    )),
    marousi = analysis_marousi_source()
  )
}

analysis_control_people <- function(sources) {
  a1r <- sources$a1r |>
    dplyr::transmute(
      poll_id = "america-in-one-room-2019", source_dataset = "control",
      respondent_id = as.character(source_row), source_row,
      historical_respondent_id = NA_character_,
      identity_basis = "file-row", arm = dplyr::case_when(
        CONDITION == 0 ~ "control", !is.na(GROUP) ~ "attended",
        TRUE ~ "recruitment_nonattender"
      ),
      assignment = dplyr::if_else(CONDITION == 1, "recruitment", "control"),
      attended = CONDITION == 1 & !is.na(GROUP),
      panel = POST == 1,
      small_group_id = dplyr::if_else(CONDITION == 1 & !is.na(GROUP),
                                      as.character(GROUP), NA_character_),
      cluster_id = as.character(source_row), country = "United States",
      weight = dplyr::if_else(CONDITION == 1, WEIGHT_DELEGATE, WEIGHT_CONTROL),
      ba = dplyr::if_else(EDUC4 %in% 1:4, as.numeric(EDUC4 == 4), NA_real_),
      female = dplyr::if_else(
        GENDER %in% 1:2, as.numeric(GENDER == 2), NA_real_
      ),
      score_wave1 = NA_real_, score_wave2 = NA_real_
    )
  stopifnot(
    all(sources$climate$GENDER %in% 1:2),
    all(is.na(sources$climate$T3GENDER) |
          sources$climate$GENDER == sources$climate$T3GENDER)
  )
  climate <- sources$climate |>
    dplyr::transmute(
      poll_id = "a1r-climate-2021", source_dataset = "control",
      respondent_id = as.character(CaseId), source_row,
      historical_respondent_id = NA_character_,
      identity_basis = "source-id", arm = dplyr::case_when(
        P_TREATMENT == 0 ~ "control", P_DELEGATE == 1 ~ "completed",
        TRUE ~ "invited_noncompleter"
      ),
      assignment = dplyr::if_else(P_TREATMENT == 1, "invited", "control"),
      attended = dplyr::case_when(
        P_DELEGATE == 1 ~ TRUE, P_TREATMENT == 0 ~ FALSE, TRUE ~ NA
      ),
      panel = P_DELEGATE == 1 | (P_TREATMENT == 0 & P_DELEGATE == 0),
      small_group_id = dplyr::if_else(P_DELEGATE == 1, as.character(ROOM),
                                      NA_character_),
      cluster_id = as.character(CaseId), country = "United States",
      weight = WEIGHT1,
      ba = dplyr::if_else(EDUC5 %in% 1:5, as.numeric(EDUC5 >= 4), NA_real_),
      female = as.numeric(GENDER == 2),
      score_wave1 = NA_real_, score_wave2 = NA_real_
    )
  stopifnot(all(is.na(sources$tanzania$male) |
                  sources$tanzania$male %in% 0:1))
  tanzania <- sources$tanzania |>
    dplyr::mutate(source_row = dplyr::row_number()) |>
    dplyr::transmute(
      poll_id = "tanzania-2015", source_dataset = "control",
      respondent_id = as.character(source_row), source_row,
      historical_respondent_id = NA_character_,
      identity_basis = "filtered-file-row", arm = dplyr::case_when(
        zdelib == 1 ~ "deliberation", zoinfo == 1 ~ "information",
        zspill == 1 ~ "spillover", z == 0 ~ "control",
        TRUE ~ "other"
      ),
      assignment = dplyr::case_when(
        zdelib == 1 ~ "deliberation", zoinfo == 1 ~ "information",
        zspill == 1 ~ "spillover", z == 0 ~ "control"
      ),
      attended = NA, panel = !is.na(H601), small_group_id = NA_character_,
      cluster_id = as.character(VillageID), country = "Tanzania",
      weight = NA_real_, ba = NA_real_,
      female = as.numeric(male == 0),
      score_wave1 = as.numeric(H600), score_wave2 = as.numeric(H601)
    )
  amr <- sources$amr |>
    dplyr::mutate(source_row = dplyr::row_number()) |>
    dplyr::group_by(ID) |>
    dplyr::mutate(
      n_group = dplyr::n_distinct(Group),
      n_country = dplyr::n_distinct(Country),
      n_gender = dplyr::n_distinct(gender)
    ) |>
    dplyr::ungroup()
  stopifnot(
    all(amr$n_group == 1L), all(amr$n_country == 1L),
    all(amr$n_gender == 1L), all(amr$gender %in% 0:1)
  )
  amr <- amr |>
    dplyr::filter(Time == 0) |>
    dplyr::transmute(
      poll_id = "amr-2024", source_dataset = "control",
      respondent_id = as.character(ID), source_row,
      historical_respondent_id = NA_character_,
      identity_basis = "source-id", arm = dplyr::if_else(
        Group == 1, "attended", "control"
      ),
      assignment = dplyr::if_else(Group == 1, "invited", "control"),
      attended = Group == 1,
      panel = TRUE, small_group_id = NA_character_,
      cluster_id = as.character(ID),
      country = c(
        "Brazil", "Colombia", "India", "Indonesia", "Nigeria", "Tanzania"
      )[Country],
      weight = Weight, ba = as.numeric(education_ISCE >= 6),
      female = as.numeric(gender == 1),
      score_wave1 = NA_real_, score_wave2 = NA_real_
    )
  ni_groups <- readr::read_csv(
    project_path("data", "northern-ireland-2007", "groups.csv"),
    col_names = c("respondent_id", "group_id"),
    col_types = readr::cols(
      respondent_id = readr::col_character(),
      group_id = readr::col_character()
    )
  )
  northern_ireland <- sources$northern_ireland |>
    dplyr::filter(!is.na(time3) | !is.na(cgq36)) |>
    dplyr::mutate(respondent_id = as.character(as.integer(cserial))) |>
    dplyr::left_join(ni_groups, by = "respondent_id",
                     relationship = "many-to-one") |>
    dplyr::transmute(
      poll_id = "northern-ireland-2007", source_dataset = "control",
      respondent_id, source_row,
      historical_respondent_id = NA_character_,
      identity_basis = "source-id",
      arm = dplyr::if_else(is.na(cgq36), "attended", "control"),
      assignment = NA_character_, attended = is.na(cgq36), panel = TRUE,
      small_group_id = dplyr::if_else(is.na(cgq36), group_id, NA_character_),
      cluster_id = dplyr::if_else(is.na(cgq36), group_id, respondent_id),
      country = "United Kingdom", weight = NA_real_,
      ba = NA_real_, female = as.numeric(female),
      score_wave1 = NA_real_, score_wave2 = NA_real_
    )
  stopifnot(
    nrow(northern_ireland) == 243L,
    sum(northern_ireland$arm == "attended") == 93L,
    sum(northern_ireland$arm == "control") == 150L,
    !anyNA(northern_ireland$cluster_id)
  )
  marousi <- sources$marousi |>
    dplyr::transmute(
      poll_id = "marousi-2006", source_dataset = "score_only",
      respondent_id = as.character(caseid),
      source_row = as.integer(original_source_row),
      historical_respondent_id = as.character(caseid),
      identity_basis = "verified-source-bridge", arm = "participant",
      panel = arrival_observed & departure_observed,
      assignment = NA_character_, attended = TRUE,
      small_group_id = as.character(pollgroup),
      cluster_id = as.character(pollgroup),
      country = "Greece", weight = NA_real_,
      ba = as.numeric(educ3 == 1),
      female,
      score_wave1 = as.numeric(t1know), score_wave2 = as.numeric(t2know)
    )
  dplyr::bind_rows(a1r, climate, tanzania, amr, northern_ireland, marousi)
}

analysis_historical_items <- function(catalog) {
  selected <- catalog |>
    dplyr::filter(!is.na(historical_item_id)) |>
    dplyr::select("poll_id", "historical_item_id", "historical_item_id_t2",
                  canonical_item_id = "item_id")
  map <- dplyr::bind_rows(
    selected |>
      dplyr::transmute(poll_id, wave = 1L, historical_item_id,
                       canonical_item_id),
    selected |>
      dplyr::transmute(
        poll_id, wave = 2L,
        historical_item_id = dplyr::coalesce(
          historical_item_id_t2, historical_item_id
        ),
        canonical_item_id
      )
  )
  out <- arrow::read_parquet(project_path(
    "output", "respondent", "historical_knowledge_items.parquet"
  )) |>
    dplyr::left_join(map, by = c("poll_id", "wave",
                                 "item_id" = "historical_item_id"),
                     relationship = "many-to-one")
  stopifnot(!anyNA(out$canonical_item_id))
  out <- out |>
    dplyr::transmute(
      poll_id, source_dataset = "historical", respondent_id,
      wave = paste0("t", wave),
      item_id = canonical_item_id, source_row,
      source_column = NA_character_, raw_value = NA_real_,
      raw_text = NA_character_,
      correct = as.integer(correct),
      response_status = dplyr::if_else(
        poll_id == "btp-general-election-2004" & is.na(correct),
        "wave_absent", "scored"
      )
    )
  dplyr::bind_rows(
    dplyr::filter(out, poll_id != "nic-1996"),
    analysis_nic_items(catalog)
  )
}

analysis_nic_items <- function(catalog) {
  survey <- read_poll_survey("nic-1996")
  people <- arrow::read_parquet(project_path(
    "output", "respondent", "people.parquet"
  )) |>
    dplyr::filter(poll_id == "nic-1996") |>
    dplyr::select("source_row", "respondent_id")
  bank <- catalog |>
    dplyr::filter(poll_id == "nic-1996") |>
    dplyr::arrange(item_id)
  stopifnot(nrow(bank) == 11L)
  purrr::map(1:3, function(wave) {
    correct <- nic_knowledge_items(survey, wave)
    stopifnot(identical(colnames(correct), bank$historical_item_id))
    fields <- sub("1$", as.character(wave), bank$source_column_t1)
    raw <- as.matrix(survey[fields])
    out <- tibble::tibble(
      poll_id = "nic-1996", source_dataset = "historical",
      source_row = rep(survey$source_row, each = nrow(bank)),
      wave = paste0("t", wave), item_id = rep(bank$item_id, nrow(survey)),
      source_column = rep(fields, nrow(survey)),
      raw_value = as.numeric(t(raw)), raw_text = NA_character_,
      correct = as.integer(t(correct)),
      response_status = dplyr::if_else(is.na(raw_value),
        "source_missing", "answered"
      )
    ) |>
      dplyr::left_join(people, by = "source_row", relationship = "many-to-one")
    if (wave == 3L) {
      absent <- survey$source_row[!rounded_source_code(survey$PART3) %in% 1L]
      out <- out |>
        dplyr::mutate(
          correct = dplyr::if_else(
            source_row %in% absent, NA_integer_, correct
          ),
          response_status = dplyr::if_else(source_row %in% absent,
            "wave_absent", response_status
          )
        )
    }
    stopifnot(!anyNA(out$respondent_id))
    out
  }) |>
    purrr::list_rbind()
}

analysis_cor_items <- function(catalog) {
  map <- catalog |>
    dplyr::filter(!is.na(cor_item_id)) |>
    dplyr::select("poll_id", cor_item_id = "cor_item_id",
                  canonical_item_id = "item_id")
  out <- arrow::read_parquet(project_path(
    "output", "knowledge_responses.parquet"
  )) |>
    dplyr::left_join(map, by = c("poll_id", "item_id" = "cor_item_id"),
                     relationship = "many-to-one")
  stopifnot(!anyNA(out$canonical_item_id))
  out |>
    dplyr::transmute(
      poll_id, source_dataset = "cor_sood", respondent_id,
      wave = paste0("t", wave),
      item_id = canonical_item_id, source_row, source_column,
      raw_value, raw_text, correct, response_status
    )
}

analysis_control_items <- function(sources, catalog) {
  make_wave <- function(data, poll_id, id, wave, columns) {
    data |>
      dplyr::mutate(respondent_id = as.character({{ id }})) |>
      dplyr::select("source_row", "respondent_id", dplyr::all_of(columns)) |>
      tidyr::pivot_longer(dplyr::all_of(columns), names_to = "source_column",
                          values_to = "raw_value") |>
      dplyr::mutate(
        poll_id = poll_id, source_dataset = "control", wave = as.integer(wave),
        source_item_id = sub("^T[23]", "", source_column),
        raw_value = as.numeric(raw_value),
        raw_text = NA_character_
      )
  }
  a1r <- dplyr::bind_rows(
    make_wave(sources$a1r, "america-in-one-room-2019", source_row, 1L,
              paste0("PK", 1:7)),
    make_wave(dplyr::filter(sources$a1r, POST == 1), "america-in-one-room-2019",
              source_row, 2L, paste0("T2PK", 1:7))
  )
  climate_panel <- sources$climate |>
    dplyr::filter(P_DELEGATE == 1 | (P_TREATMENT == 0 & P_DELEGATE == 0))
  climate_t3 <- sources$climate |>
    dplyr::filter(!is.na(T3Q17))
  climate <- dplyr::bind_rows(
    make_wave(sources$climate, "a1r-climate-2021", CaseId, 1L,
              paste0("Q", 17:24)),
    make_wave(climate_panel, "a1r-climate-2021", CaseId, 2L,
              paste0("T2Q", 17:24)),
    make_wave(climate_t3, "a1r-climate-2021", CaseId, 3L,
              paste0("T3Q", 17:24))
  )
  amr <- sources$amr |>
    dplyr::mutate(
      source_row = dplyr::row_number(), respondent_id = as.character(ID)
    ) |>
    dplyr::select("source_row", "respondent_id", "Time",
                  dplyr::all_of(paste0("knowledge_", 1:6))) |>
    tidyr::pivot_longer(dplyr::all_of(paste0("knowledge_", 1:6)),
                        names_to = "source_column", values_to = "raw_value") |>
    dplyr::transmute(
      poll_id = "amr-2024", source_dataset = "control", respondent_id,
      wave = as.integer(Time + 1), source_item_id = source_column, source_row,
      source_column, raw_value = as.numeric(raw_value), raw_text = NA_character_
    )
  northern_ireland <- sources$northern_ireland |>
    dplyr::filter(!is.na(time3) | !is.na(cgq36)) |>
    dplyr::mutate(respondent_id = as.character(as.integer(cserial))) |>
    dplyr::select("source_row", "respondent_id",
                  dplyr::all_of(paste0("t3q", 11:17))) |>
    tidyr::pivot_longer(dplyr::all_of(paste0("t3q", 11:17)),
                        names_to = "source_column", values_to = "raw_value") |>
    dplyr::transmute(
      poll_id = "northern-ireland-2007", source_dataset = "control",
      respondent_id, wave = 3L,
      source_item_id = paste0(
        "t1q", as.integer(sub("t3q", "", source_column)) + 10L
      ),
      source_row, source_column,
      raw_value = as.numeric(raw_value), raw_text = NA_character_
    )
  keys <- catalog |>
    dplyr::filter(poll_id %in% c(
      "america-in-one-room-2019", "a1r-climate-2021", "amr-2024",
      "northern-ireland-2007"
    )) |>
    dplyr::transmute(
      poll_id, source_item_id = source_column_t1, item_id,
      key = as.numeric(correct_codes)
    )
  out <- dplyr::bind_rows(a1r, climate, amr, northern_ireland) |>
    dplyr::left_join(keys, by = c("poll_id", "source_item_id"),
                     relationship = "many-to-one")
  stopifnot(!anyNA(out$key))
  out |>
    dplyr::transmute(
      poll_id, source_dataset, respondent_id, wave = paste0("t", wave),
      item_id, source_row,
      source_column, raw_value, raw_text,
      correct = as.integer(!is.na(raw_value) & raw_value == key),
      response_status = dplyr::if_else(
        is.na(raw_value), "source_missing", "answered"
      )
    )
}

analysis_scores <- function(items, participants, marousi = NULL) {
  item_scores <- items |>
    dplyr::summarise(
      n_items = dplyr::n(),
      wave_absent = all(response_status == "wave_absent"),
      n_observed = dplyr::if_else(
        wave_absent, 0L,
        dplyr::if_else(
          dplyr::first(source_dataset) == "historical", NA_integer_,
          as.integer(sum(!is.na(raw_value) | !is.na(raw_text)))
        )
      ),
      n_correct = dplyr::if_else(
        wave_absent, NA_integer_, as.integer(sum(correct == 1L, na.rm = TRUE))
      ),
      .by = c(poll_id, source_dataset, respondent_id, wave)
    ) |>
    dplyr::mutate(
      score = n_correct / n_items,
      scale = "proportion_correct"
    )
  score_only <- participants |>
    dplyr::filter(source_dataset == "control", poll_id == "tanzania-2015") |>
    dplyr::select("poll_id", "source_dataset", "respondent_id",
                  "score_wave1", "score_wave2") |>
    tidyr::pivot_longer(c("score_wave1", "score_wave2"),
                        names_to = "wave", values_to = "score") |>
    dplyr::mutate(
      wave = dplyr::recode(wave, score_wave1 = "t1", score_wave2 = "t2"),
      n_items = NA_integer_, n_observed = NA_integer_, n_correct = NA_integer_,
      scale = "standardized_index"
    )
  marousi_scores <- if (is.null(marousi)) {
    stopifnot(!any(participants$poll_id == "marousi-2006"))
    NULL
  } else {
    analysis_marousi_scores(marousi)
  }
  dplyr::bind_rows(item_scores, score_only, marousi_scores) |>
    dplyr::select("poll_id", "source_dataset", "respondent_id", "wave",
                  "n_items", "n_observed", "n_correct", "score", "scale")
}

build_analysis_tables <- function() {
  catalog <- analysis_item_catalog()
  polls <- read_metadata("polls")
  facts <- analysis_poll_facts(polls)
  events <- analysis_poll_events(polls, facts)
  sources <- analysis_control_sources()
  participants <- dplyr::bind_rows(
    analysis_historical_people(), analysis_cor_people(),
    analysis_control_people(sources)
  ) |>
    add_analysis_covariates()
  items <- dplyr::bind_rows(
    analysis_historical_items(catalog), analysis_cor_items(catalog),
    analysis_control_items(sources, catalog)
  )
  scores <- analysis_scores(items, participants, sources$marousi)
  attitudes <- analysis_attitudes(participants)
  recruitment <- analysis_phase_recruitment(participants, sources)
  wave_catalog <- analysis_wave_catalog()
  phase_people <- recruitment$participants |>
    dplyr::left_join(wave_catalog$analysis_studies,
      by = "poll_id", relationship = "many-to-one"
    )
  stopifnot(!anyNA(phase_people$study_id))
  arrival_items <- analysis_arrival_items(recruitment$participants)
  phase_scores <- analysis_phase_scores(
    scores, items, recruitment$participants, sources, recruitment, arrival_items
  ) |>
    add_analysis_wave_identity(wave_catalog$analysis_survey_waves)
  phase_evidence <- analysis_attendance_evidence(phase_people, phase_scores)
  stopifnot(
    !anyDuplicated(participants[c(
      "poll_id", "source_dataset", "respondent_id"
    )]),
    !anyDuplicated(items[c(
      "poll_id", "source_dataset", "respondent_id", "wave", "item_id"
    )]),
    nrow(dplyr::anti_join(
      dplyr::distinct(items, poll_id, source_dataset, respondent_id),
      participants, by = c("poll_id", "source_dataset", "respondent_id")
    )) == 0L,
    nrow(dplyr::anti_join(
      dplyr::distinct(items, poll_id, item_id),
      catalog, by = c("poll_id", "item_id")
    )) == 0L,
    !anyDuplicated(scores[c(
      "poll_id", "source_dataset", "respondent_id", "wave"
    )])
  )
  list(
    analysis_polls = analysis_polls(polls, facts, events),
    analysis_poll_events = events,
    analysis_items = catalog,
    analysis_participants = dplyr::select(
      participants, -"score_wave1", -"score_wave2"
    ),
    analysis_item_responses = items,
    analysis_scores = scores,
    analysis_attitudes = attitudes$catalog,
    analysis_attitude_responses = attitudes$responses,
    analysis_phase_participants = phase_evidence$participants,
    analysis_phase_scores = phase_evidence$scores,
    analysis_phase_item_responses = analysis_phase_items(
      items, phase_evidence$scores, arrival_items
    ),
    analysis_studies = wave_catalog$analysis_studies,
    analysis_survey_waves = wave_catalog$analysis_survey_waves
  )
}
