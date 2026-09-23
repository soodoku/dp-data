linkage_poll_map <- tibble::tibble(
  file_key = c(
    "aus", "btp04", "btp04GE", "btp05", "btp07", "bul", "ca", "cpl", "dk",
    "eu2007", "eu2009", "ire", "mi", "nic1", "sm", "swp", "ukbge", "ukcrime",
    "ukeu", "ukhealth", "ukmon", "vt", "wtu"
  ),
  cor_poll_name = c(
    "Australia Constitutional Referendum",
    "By the People 2004 Online Primaries",
    "By the People 2004 General Election", "By the People 2005",
    "By the People 2007",
    "Bulgaria", "California What's Next", "Central Power & Light",
    "Denmark: Euro",
    "Tomorrow's Europe (EU)", "Europolis", "Northern Ireland", "Michigan",
    "National Issues Convention", "San Mateo", "Southwestern Electric Power",
    "UK General Election", "UK Crime", "UK EU", "UK Health", "UK Monarchy",
    "Vermont Energy", "West Texas Utilities"
  ),
  dpnum = c(
    5L, NA, 15L, 18L, NA, 10L, NA, 8L, NA, 7L, 11L, NA, NA, 20L, 17L,
    21L, 4L, 6L, 1L, 2L, 3L, NA, 19L
  ),
  match_status = c(
    "poll_only_battery_mismatch", "cor_sood_only", "poll_only_count_mismatch",
    "validated_person_link", "cor_sood_only", "poll_only_row_order_mismatch",
    "cor_sood_only", "validated_person_link", "cor_sood_only",
    "poll_only_count_mismatch", "poll_only_row_order_mismatch", "cor_sood_only",
    "cor_sood_only", "poll_only_battery_mismatch", "poll_only_score_mismatch",
    "validated_person_link", "poll_only_score_mismatch",
    "validated_person_link",
    "poll_only_count_mismatch", "validated_person_link",
    "poll_only_battery_mismatch",
    "cor_sood_only", "validated_person_link"
  ),
  mismatch_reason = c(
    "Deposited battery has 10 items; polardata score uses a larger battery.",
    "Poll is absent from polardata.",
    "Item file has 250 rows; polardata has 246 retained rows.", "",
    "Poll is absent from polardata.",
    "Battery and score distribution agree, but public row order does not.",
    "Poll is absent from polardata.", "", "Poll is absent from polardata.",
    "Item file has 335 rows; polardata has 344 retained rows.",
    "Battery and score distribution agree, but public row order does not.",
    "Poll is absent from polardata.", "Poll is absent from polardata.",
    "Deposited battery has 8 items; polardata score uses 11 items.",
    "T1 reconstructs exactly; T2 scores differ for some rows.", "",
    "T1 reconstructs exactly; T2 scores differ slightly for some rows.", "",
    "Item file has 224 rows; polardata has 238 retained rows.", "",
    "Deposited battery has 8 items; polardata score uses 9 items.",
    "Poll is absent from polardata.", ""
  )
)

linkage_missing_polls <- tibble::tibble(
  file_key = NA_character_,
  cor_poll_name = NA_character_,
  dpnum = c(9L, 12L, 13L, 14L, 16L),
  match_status = "distortions_only",
  mismatch_reason =
    "No matching public item matrix was found in the Cor-Sood deposit."
)

read_polardata <- function(
  path = project_path("evidence", "benchmarks", "polardata.tab")
) {
  readr::read_tsv(path, show_col_types = FALSE) |>
    dplyr::distinct(dplyr::across(-X), .keep_all = TRUE)
}

linkage_battery_path <- function(file_key) {
  batteries <- read_metadata("knowledge_batteries")
  keys <- sub("[.]csv$", "", basename(batteries$original_archive_path))
  poll_id <- batteries$poll_id[keys == file_key]
  stopifnot(length(poll_id) == 1L)
  project_path("data", poll_id, "knowledge-battery.csv")
}

read_battery <- function(path) {
  data <- readr::read_csv(path, na = c("", "NA"), show_col_types = FALSE)
  item_names <- setdiff(names(data), "female")
  tibble::tibble(item_count = length(item_names)) |>
    assertr::verify(item_count %% 2L == 0L)
  item_count <- length(item_names) / 2L
  t1_names <- item_names[seq_len(item_count)]
  t2_names <- item_names[item_count + seq_len(item_count)]
  score_items <- function(names) {
    data |>
      dplyr::select(dplyr::all_of(names)) |>
      dplyr::mutate(
        dplyr::across(
          dplyr::everything(),
          ~ tidyr::replace_na(as.numeric(.x), 0)
        )
      )
  }
  list(
    t1 = score_items(t1_names),
    t2 = score_items(t2_names),
    t1_names = t1_names,
    t2_names = t2_names,
    female = as.numeric(data$female)
  )
}

battery_summary <- function(file_key) {
  battery <- read_battery(linkage_battery_path(file_key))
  tibble::tibble(
    file_key = file_key,
    respondents = nrow(battery$t1),
    items = ncol(battery$t1),
    alpha_t1 = ltm::cronbach.alpha(battery$t1)$alpha,
    alpha_t2 = ltm::cronbach.alpha(battery$t2)$alpha,
    score_correlation = stats::cor(rowMeans(battery$t1), rowMeans(battery$t2))
  )
}

poll_inventory <- function(polardata) {
  polardata |>
    dplyr::distinct(dpnum, pollid, pollname, numitems) |>
    dplyr::left_join(
      dplyr::count(polardata, dpnum, name = "polardata_respondents"),
      by = "dpnum",
      relationship = "one-to-one"
    )
}

make_crosswalk <- function(polardata, reliability) {
  dplyr::bind_rows(linkage_poll_map, linkage_missing_polls) |>
    dplyr::left_join(
      dplyr::select(reliability, -cor_poll_name, -dpnum),
      by = "file_key",
      relationship = "many-to-one",
      na_matches = "never"
    ) |>
    dplyr::left_join(
      poll_inventory(polardata),
      by = "dpnum",
      relationship = "many-to-one",
      na_matches = "never"
    ) |>
    dplyr::arrange(is.na(dpnum), dpnum, file_key)
}

validate_person_link <- function(polardata, battery, dpnum, tolerance = 1e-7) {
  poll <- dplyr::filter(polardata, .data$dpnum == .env$dpnum)
  t1_score <- rowMeans(battery$t1)
  t2_score <- rowMeans(battery$t2)
  observed_gender <- !is.na(battery$female) & !is.na(poll$female)
  checks <- tibble::tibble(
    same_rows = nrow(poll) == nrow(battery$t1),
    same_t1 = length(t1_score) == nrow(poll) &&
      all(abs(t1_score - poll$t1know) <= tolerance),
    same_t2 = length(t2_score) == nrow(poll) &&
      all(abs(t2_score - poll$t2know) <= tolerance),
    same_gender =
      all(battery$female[observed_gender] == poll$female[observed_gender])
  )
  assertr::verify(
    checks,
    all(as.matrix(checks)),
    error_fun = assertr::error_stop
  )
  poll
}

linked_items_for_poll <- function(file_key, dpnum, polardata) {
  battery <- read_battery(linkage_battery_path(file_key))
  poll <- validate_person_link(polardata, battery, dpnum)
  make_wave <- function(items, wave) {
    items |>
      dplyr::mutate(
        source_row = dplyr::row_number(),
        caseid = poll$caseid,
        female = poll$female
      ) |>
      tidyr::pivot_longer(
        cols = -c(source_row, caseid, female),
        names_to = "source_variable",
        values_to = "correct"
      ) |>
      dplyr::mutate(
        dpnum = dpnum,
        poll_name = poll$pollname[[1]],
        item_id = paste0("item_", match(source_variable, names(items))),
        wave = wave,
        linkage_basis = "validated_public_row_position",
        .before = 1
      )
  }
  dplyr::bind_rows(make_wave(battery$t1, "t1"), make_wave(battery$t2, "t2"))
}

make_knowledge_attitude_panel <- function(
  polardata,
  respondent_items,
  index_path = project_path("evidence", "benchmarks", "attitude-indices.tab")
) {
  validated_dpnums <- sort(unique(respondent_items$dpnum))
  index_map <- readr::read_tsv(index_path, show_col_types = FALSE) |>
    dplyr::filter(.data$dpnum %in% validated_dpnums)
  index_long <- index_map |>
    tidyr::pivot_longer(
      cols = c(t1var, t2_t3var),
      names_to = "wave",
      values_to = "source_variable"
    ) |>
    dplyr::mutate(wave = dplyr::recode(wave, t1var = "t1", t2_t3var = "t2")) |>
    dplyr::select(dpnum, attitude_index = att_index, wave, source_variable)

  source_variables <- unique(index_long$source_variable)
  tibble::tibble(
    all_variables_present =
      all(source_variables %in% names(polardata))
  ) |>
    assertr::verify(all_variables_present)

  attitudes <- polardata |>
    dplyr::filter(.data$dpnum %in% validated_dpnums) |>
    dplyr::select(
      dpnum, caseid,
      poll_name = pollname, group_id = pollgroup, groupsize,
      female, dplyr::all_of(source_variables)
    ) |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(source_variables),
      names_to = "source_variable",
      values_to = "attitude"
    ) |>
    dplyr::inner_join(
      index_long,
      by = c("dpnum", "source_variable"),
      relationship = "many-to-one"
    ) |>
    tidyr::pivot_wider(
      names_from = wave,
      values_from = c(source_variable, attitude),
      names_glue = "{wave}_{.value}"
    )

  knowledge <- respondent_items |>
    dplyr::summarise(
      knowledge = mean(correct),
      knowledge_items = dplyr::n_distinct(item_id),
      .by = c(dpnum, caseid, wave)
    ) |>
    tidyr::pivot_wider(
      names_from = wave,
      values_from = c(knowledge, knowledge_items),
      names_glue = "{wave}_{.value}"
    )

  panel <- attitudes |>
    dplyr::left_join(
      knowledge,
      by = c("dpnum", "caseid"),
      relationship = "many-to-one"
    ) |>
    dplyr::arrange(dpnum, caseid, attitude_index)
  assertr::verify(panel, !is.na(t1_knowledge) & !is.na(t2_knowledge))
  panel
}
