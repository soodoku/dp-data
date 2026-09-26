analysis_item_catalog <- function() {
  readr::read_csv(project_path("metadata", "items.csv"), show_col_types = FALSE)
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
      ba = as.numeric(educ3 == 1), female, historical_panel = TRUE
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
      weight = NA_real_, ba, female,
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
    marousi = readr::read_csv(project_path(
      "data", "marousi-2006", "participants.csv"
    ), show_col_types = FALSE)
  )
}

analysis_control_people <- function(sources) {
  a1r <- sources$a1r |>
    dplyr::transmute(
      poll_id = "america-in-one-room-2019", source_dataset = "control",
      respondent_id = as.character(source_row), source_row,
      historical_respondent_id = NA_character_,
      identity_basis = "file-row", arm = dplyr::case_when(
        CONDITION == 0 ~ "control", POST == 1 ~ "attended",
        TRUE ~ "invited_nonattender"
      ),
      assignment = dplyr::if_else(CONDITION == 1, "invited", "control"),
      attended = CONDITION == 1 & POST == 1,
      panel = POST == 1,
      small_group_id = dplyr::if_else(CONDITION == 1 & POST == 1,
                                      as.character(GROUP), NA_character_),
      cluster_id = as.character(source_row), country = "United States",
      weight = dplyr::if_else(CONDITION == 1, WEIGHT_DELEGATE, WEIGHT_CONTROL),
      ba = dplyr::if_else(EDUC4 %in% 1:4, as.numeric(EDUC4 == 4), NA_real_),
      female = dplyr::if_else(
        GENDER %in% 1:2, as.numeric(GENDER == 2), NA_real_
      ),
      score_wave1 = NA_real_, score_wave2 = NA_real_
    )
  climate <- sources$climate |>
    dplyr::transmute(
      poll_id = "a1r-climate-2021", source_dataset = "control",
      respondent_id = as.character(CaseId), source_row,
      historical_respondent_id = NA_character_,
      identity_basis = "source-id", arm = dplyr::case_when(
        P_TREATMENT == 0 ~ "control", P_DELEGATE == 1 ~ "attended",
        TRUE ~ "invited_nonattender"
      ),
      assignment = dplyr::if_else(P_TREATMENT == 1, "invited", "control"),
      attended = P_DELEGATE == 1,
      panel = P_DELEGATE == 1 | (P_TREATMENT == 0 & P_DELEGATE == 0),
      small_group_id = dplyr::if_else(P_DELEGATE == 1, as.character(ROOM),
                                      NA_character_),
      cluster_id = as.character(CaseId), country = "United States",
      weight = WEIGHT1,
      ba = dplyr::if_else(EDUC5 %in% 1:5, as.numeric(EDUC5 >= 4), NA_real_),
      female = NA_real_,
      score_wave1 = NA_real_, score_wave2 = NA_real_
    )
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
      female = NA_real_,
      score_wave1 = as.numeric(H600), score_wave2 = as.numeric(H601)
    )
  amr <- sources$amr |>
    dplyr::mutate(source_row = dplyr::row_number()) |>
    dplyr::group_by(ID) |>
    dplyr::mutate(
      n_group = dplyr::n_distinct(Group), n_country = dplyr::n_distinct(Country)
    ) |>
    dplyr::ungroup()
  stopifnot(all(amr$n_group == 1L), all(amr$n_country == 1L))
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
      female = NA_real_,
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
    dplyr::mutate(source_row = dplyr::row_number()) |>
    dplyr::transmute(
      poll_id = "marousi-2006", source_dataset = "score_only",
      respondent_id = as.character(caseid), source_row,
      historical_respondent_id = NA_character_,
      identity_basis = "source-id", arm = "participant", panel = TRUE,
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
  out |>
    dplyr::transmute(
      poll_id, source_dataset = "historical", respondent_id,
      wave = paste0("t", wave),
      item_id = canonical_item_id, source_row,
      source_column = NA_character_, raw_value = NA_real_,
      raw_text = NA_character_,
      correct = as.integer(correct), response_status = "scored"
    )
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

analysis_scores <- function(items, participants) {
  item_scores <- items |>
    dplyr::summarise(
      n_items = dplyr::n(),
      n_observed = dplyr::if_else(
        dplyr::first(source_dataset) == "historical", NA_integer_,
        as.integer(sum(!is.na(raw_value) | !is.na(raw_text)))
      ),
      n_correct = sum(correct == 1L, na.rm = TRUE),
      .by = c(poll_id, source_dataset, respondent_id, wave)
    ) |>
    dplyr::mutate(
      score = n_correct / n_items,
      scale = "proportion_correct"
    )
  score_only <- participants |>
    dplyr::filter(source_dataset %in% c("control", "score_only"),
                  poll_id %in% c("tanzania-2015", "marousi-2006")) |>
    dplyr::select("poll_id", "source_dataset", "respondent_id",
                  "score_wave1", "score_wave2") |>
    tidyr::pivot_longer(c("score_wave1", "score_wave2"),
                        names_to = "wave", values_to = "score") |>
    dplyr::mutate(
      wave = dplyr::recode(wave, score_wave1 = "t1", score_wave2 = "t2"),
      n_items = NA_integer_, n_observed = NA_integer_, n_correct = NA_integer_,
      scale = dplyr::if_else(
        poll_id == "tanzania-2015",
        "standardized_index", "proportion_correct"
      )
    )
  dplyr::bind_rows(item_scores, score_only) |>
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
  )
  items <- dplyr::bind_rows(
    analysis_historical_items(catalog), analysis_cor_items(catalog),
    analysis_control_items(sources, catalog)
  )
  scores <- analysis_scores(items, participants)
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
    analysis_scores = scores
  )
}
