analysis_attitudes <- function(participants) {
  index <- arrow::read_parquet(project_path(
    "output", "polardata", "attitude-indices.parquet"
  )) |>
    dplyr::select("dpnum", "att_index", "t1var") |>
    dplyr::left_join(
      dplyr::select(read_metadata("respondent_sources"), "poll_id", "dpnum"),
      by = "dpnum", relationship = "many-to-one"
    )
  historical <- arrow::read_parquet(project_path(
    "output", "polardata", "polardata.parquet"
  ))
  catalog <- index |>
    dplyr::transmute(
      poll_id,
      attitude_id = paste0("att_", t1var),
      source_column = t1var, minimum = 0, maximum = 1,
      label = att_index, evidence = "output/polardata/attitude-indices.parquet",
      construction = "existing policy index"
    ) |>
    dplyr::bind_rows(dplyr::mutate(read_metadata("attitude_items"),
      construction = "single policy response"
    ))
  imputed_targets <- read_metadata("polardata_targets") |>
    dplyr::inner_join(
      read_metadata("measure_definitions") |>
        dplyr::filter(grepl("_midpoint_imputed$", measure_id)) |>
        dplyr::select("poll_id", "definition_id", "measure_id"),
      by = c("poll_id", "canonical_definition" = "definition_id"),
      relationship = "many-to-one"
    ) |>
    dplyr::transmute(poll_id, source_column = legacy_field, measure_id)
  catalog <- catalog |>
    dplyr::left_join(imputed_targets,
      by = c("poll_id", "source_column"), relationship = "one-to-one"
    ) |>
    dplyr::mutate(
      attitude_id = dplyr::if_else(!is.na(measure_id),
        paste0("att_", measure_id), attitude_id
      ),
      construction = dplyr::if_else(!is.na(measure_id),
        "policy index with explicit midpoint imputation", construction
      )
    ) |>
    dplyr::select(-"measure_id")
  keys <- c("poll_id", "source_dataset", "respondent_id")
  responses <- lapply(unique(catalog$poll_id), function(id) {
    definitions <- dplyr::filter(catalog, .data$poll_id == id)
    people <- dplyr::filter(participants, .data$poll_id == id)
    if (id %in% index$poll_id) {
      people <- dplyr::filter(people, source_dataset == "historical")
      number <- unique(index$dpnum[index$poll_id == id])
      raw <- dplyr::filter(historical, dpnum == number) |>
        dplyr::mutate(historical_respondent_id = as.character(caseid))
      values <- dplyr::left_join(
        dplyr::select(people, dplyr::all_of(keys), "historical_respondent_id"),
        dplyr::select(
          raw, "historical_respondent_id",
          dplyr::all_of(definitions$source_column)
        ),
        by = "historical_respondent_id", relationship = "one-to-one"
      ) |>
        dplyr::select(-"historical_respondent_id")
    } else {
      path <- project_path("data", id, "survey.parquet")
      raw <- if (file.exists(path)) {
        arrow::read_parquet(path)
      } else {
        readr::read_tsv(project_path("data", id, "participants.tab"),
          show_col_types = FALSE
        ) |>
          dplyr::mutate(source_row = dplyr::row_number())
      }
      stopifnot(all(people$source_row %in% raw$source_row))
      values <- dplyr::left_join(
        dplyr::select(people, dplyr::all_of(keys), "source_row"),
        dplyr::select(
          raw, "source_row",
          dplyr::all_of(definitions$source_column)
        ),
        by = "source_row", relationship = "many-to-one"
      ) |>
        dplyr::select(-"source_row")
    }
    values |>
      tidyr::pivot_longer(
        cols = dplyr::all_of(definitions$source_column),
        names_to = "source_column", values_to = "raw_value"
      ) |>
      dplyr::left_join(definitions,
        by = c("poll_id", "source_column"), relationship = "many-to-one"
      ) |>
      dplyr::transmute(
        poll_id, source_dataset, respondent_id, attitude_id,
        wave = "t1",
        value = dplyr::if_else(
          raw_value >= minimum & raw_value <= maximum,
          (raw_value - minimum) / (maximum - minimum), NA_real_
        )
      )
  }) |>
    dplyr::bind_rows()
  alternatives <- catalog |>
    dplyr::filter(grepl("_midpoint_imputed$", attitude_id)) |>
    dplyr::mutate(
      imputed_attitude_id = attitude_id,
      attitude_id = sub("_midpoint_imputed$", "", attitude_id),
      source_column = sub("^att_", "", attitude_id)
    ) |>
    dplyr::left_join(
      read_metadata("measure_definitions") |>
        dplyr::select("poll_id", "measure_id", "definition_id"),
      by = c("poll_id", "source_column" = "measure_id"),
      relationship = "one-to-one"
    )
  stopifnot(!anyNA(alternatives$definition_id))
  eligible <- historical |>
    dplyr::left_join(
      dplyr::distinct(index, poll_id, dpnum),
      by = "dpnum", relationship = "many-to-one"
    ) |>
    dplyr::transmute(poll_id,
      historical_respondent_id = as.character(caseid)
    )
  people <- participants |>
    dplyr::filter(source_dataset == "historical") |>
    dplyr::inner_join(eligible,
      by = c("poll_id", "historical_respondent_id"),
      relationship = "one-to-one"
    ) |>
    dplyr::select(dplyr::all_of(keys))
  measures <- arrow::read_parquet(project_path(
    "output", "respondent", "respondent_measures.parquet"
  )) |>
    dplyr::inner_join(
      dplyr::select(alternatives, poll_id, attitude_id, definition_id),
      by = c("poll_id", "definition_id"), relationship = "many-to-one"
    ) |>
    dplyr::inner_join(people,
      by = c("poll_id", "respondent_id"), relationship = "many-to-one"
    ) |>
    dplyr::select(dplyr::all_of(keys), attitude_id, value = value_numeric)
  plain_responses <- responses |>
    dplyr::inner_join(
      dplyr::select(alternatives, poll_id, imputed_attitude_id, attitude_id),
      by = c("poll_id", "attitude_id" = "imputed_attitude_id"),
      relationship = "many-to-one", suffix = c("_imputed", "")
    ) |>
    dplyr::select(dplyr::all_of(keys), attitude_id, wave) |>
    dplyr::left_join(measures,
      by = c(keys, "attitude_id"), relationship = "one-to-one"
    )
  plain_catalog <- alternatives |>
    dplyr::mutate(
      evidence = paste0("output/respondent/respondent_measures.parquet; ",
        definition_id
      ),
      construction = "policy index preserving component missingness"
    ) |>
    dplyr::select(dplyr::all_of(names(catalog)))
  catalog <- dplyr::bind_rows(catalog, plain_catalog) |>
    dplyr::mutate(is_primary = !grepl("_midpoint_imputed$", attitude_id))
  responses <- dplyr::bind_rows(responses, plain_responses)
  stopifnot(
    !anyDuplicated(catalog[c("poll_id", "attitude_id")]),
    !anyDuplicated(responses[c(keys, "attitude_id", "wave")]),
    !anyNA(catalog$poll_id),
    all(is.na(responses$value) | responses$value >= 0 & responses$value <= 1)
  )
  list(catalog = catalog, responses = responses)
}
