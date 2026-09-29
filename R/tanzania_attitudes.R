tanzania_attitude_scale <- function(raw, lower, upper, in_scope) {
  missing_codes <- c(-99, -97, 98, 99)
  substantive <- !is.na(raw) & !raw %in% missing_codes
  stopifnot(
    length(in_scope) == length(raw), !anyNA(in_scope), lower < upper,
    all(!in_scope | !substantive | raw >= lower & raw <= upper)
  )
  tibble::tibble(
    raw_value = as.numeric(raw),
    response_status = dplyr::case_when(
      !in_scope ~ "out_of_scope",
      is.na(raw) ~ "system_missing",
      raw %in% missing_codes ~ "nonresponse",
      TRUE ~ "answered"
    ),
    value = dplyr::if_else(
      in_scope & substantive,
      (as.numeric(raw) - lower) / (upper - lower), NA_real_
    )
  )
}

build_tanzania_attitude_tables <- function() {
  definitions <- read_metadata("tanzania_attitude_items")
  stopifnot(
    nrow(definitions) == 22L,
    !anyDuplicated(definitions[c("source_id", "attitude_id")]),
    !anyDuplicated(definitions$pre_column),
    !anyDuplicated(definitions$post_column),
    all(grepl("^[a-z][a-z0-9]*(_[a-z0-9]+)*$", definitions$attitude_id)),
    all(definitions$poll_id == "tanzania-2015"),
    all(definitions$source_id == "tanzania-2015"),
    all(definitions$group_source_id == "oos-tanzania-groups"),
    all(definitions$missing_codes == "-99;-97;98;99"),
    all(definitions$discussion_round %in% c("round_1", "round_2")),
    all(definitions$group_source_column == dplyr::if_else(
      definitions$discussion_round == "round_1", "group1", "group2"
    ))
  )
  source_files <- read_metadata("source_files")
  waves <- read_metadata("analysis_survey_waves") |>
    dplyr::filter(poll_id == "tanzania-2015")
  stopifnot(
    nrow(waves) == 2L, !anyDuplicated(waves$original_survey_wave),
    setequal(waves$original_survey_wave, c("baseline", "follow_up")),
    all(waves$wave[match(c("baseline", "follow_up"),
                         waves$original_survey_wave)] == c("t0", "t3")),
    all(waves$wave_role[match(c("baseline", "follow_up"),
                              waves$original_survey_wave)] ==
          c("pre_arrival", "follow_up"))
  )
  sources <- source_files |>
    dplyr::filter(source_id %in% c("tanzania-2015", "oos-tanzania-groups"))
  stopifnot(nrow(sources) == 2L, !anyDuplicated(sources$source_id))
  purrr::walk(seq_len(nrow(sources)), function(index) {
    stopifnot(identical(
      digest::digest(file = project_path(sources$path[index]), algo = "sha256"),
      sources$sha256[index]
    ))
  })
  source <- sources[sources$source_id == "tanzania-2015", ]
  group_source <- sources[sources$source_id == "oos-tanzania-groups", ]
  definitions <- definitions |>
    dplyr::mutate(
      source_path = source$path, source_sha256 = source$sha256,
      group_source_path = group_source$path,
      group_source_sha256 = group_source$sha256
    )
  survey <- haven::read_dta(project_path(source$path)) |>
    dplyr::mutate(source_row = dplyr::row_number())
  assignments <- readr::read_tsv(project_path(group_source$path),
    show_col_types = FALSE
  )
  stopifnot(
    nrow(survey) == 2225L, !anyNA(survey$HHID),
    !anyDuplicated(survey$HHID),
    nrow(assignments) == 371L, !anyDuplicated(assignments$HHID),
    !anyNA(assignments), all(assignments$HHID %in% survey$HHID),
    setequal(assignments$group1, 1:25), setequal(assignments$group2, 1:25)
  )
  survey <- dplyr::left_join(survey, assignments,
    by = "HHID", relationship = "one-to-one"
  )
  source_sample <- as.character(haven::as_factor(survey$sample))
  in_scope <- source_sample == "Citizens"
  stopifnot(
    !anyNA(source_sample), sum(in_scope) == 2002L,
    all(in_scope[!is.na(survey$group1)])
  )
  responses <- purrr::map(seq_len(nrow(definitions)), function(index) {
    definition <- definitions[index, ]
    purrr::map(0:1, function(wave) {
      column <- if (wave == 0L) {
        definition$pre_column
      } else {
        definition$post_column
      }
      occasion_name <- if (wave == 0L) "baseline" else "follow_up"
      occasion <- waves[waves$original_survey_wave == occasion_name, ]
      raw <- survey[[column]]
      stopifnot(is.numeric(raw))
      labels <- attr(raw, "labels", exact = TRUE)
      raw_value_label <- if (is.null(labels)) {
        rep(NA_character_, length(raw))
      } else {
        names(labels)[match(as.numeric(raw), labels)]
      }
      scaled <- tanzania_attitude_scale(
        raw, definition$lower, definition$upper, in_scope
      )
      dplyr::bind_cols(
        tibble::tibble(
          poll_id = definition$poll_id, source_id = definition$source_id,
          source_row = survey$source_row,
          source_unit_id = as.character(survey$HHID), source_sample,
          attitude_id = definition$attitude_id,
          source_column = column, source_wave = as.character(wave),
          wave_instance_id = dplyr::if_else(in_scope,
            occasion$wave_instance_id, NA_character_
          ),
          wave = dplyr::if_else(in_scope, occasion$wave, NA_character_),
          wave_role = dplyr::if_else(
            in_scope, occasion$wave_role, NA_character_
          ),
          discussion_round = definition$discussion_round,
          group_id = as.character(survey[[definition$group_source_column]]),
          raw_value_label
        ), scaled
      )
    }) |>
      purrr::list_rbind()
  }) |>
    purrr::list_rbind()
  stopifnot(
    nrow(responses) == 97900L,
    !anyDuplicated(responses[c(
      "source_id", "source_row", "attitude_id", "source_wave"
    )]),
    all(is.na(responses$value) | dplyr::between(responses$value, 0, 1)),
    all(is.na(responses$value[responses$response_status != "answered"]))
  )
  list(tanzania_attitude_definitions = definitions,
       tanzania_attitude_responses = responses)
}
