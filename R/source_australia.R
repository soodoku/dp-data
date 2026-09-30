australia_form_evidence <- function(survey) {
  stopifnot(all(c("source_row", "caseid", "part", "partfull") %in%
                  names(survey)),
    !anyNA(survey$source_row), !anyDuplicated(survey$source_row)
  )
  part <- as.numeric(survey$part)
  full <- as.numeric(survey$partfull)
  stopifnot(
    all(is.na(part) | part %in% 0:1),
    all(is.na(full) | full %in% 0:2),
    identical(is.na(part), is.na(full)),
    all(part[!is.na(full)] == as.numeric(full[!is.na(full)] > 0))
  )
  labels <- vapply(survey, function(value) {
    label <- attr(value, "label", exact = TRUE)
    if (is.null(label)) "" else label
  }, character(1))
  fields <- names(survey)[grepl("T2 \\(W", labels)]
  stopifnot(length(fields) == 66L)
  raw <- do.call(cbind, lapply(survey[fields], as.numeric))
  absent <- full %in% c(0, 2)
  unknown <- is.na(full)
  stopifnot(
    all(raw[absent, , drop = FALSE] == 100),
    all(is.na(raw[unknown, , drop = FALSE])),
    all(rowSums(raw[full %in% 1, , drop = FALSE] < 90,
          na.rm = TRUE
        ) > 0)
  )
  before_fields <- names(survey)[grepl("T1 \\(Q", labels)]
  stopifnot(length(before_fields) == 74L)
  before <- do.call(cbind, lapply(survey[before_fields], as.numeric))
  stopifnot(
    all(is.na(before[unknown, , drop = FALSE])),
    all(rowSums(before[!unknown, , drop = FALSE] < 90,
          na.rm = TRUE
        ) > 0)
  )
  tibble::tibble(
    source_row = survey$source_row,
    baseline_observed = dplyr::if_else(unknown, NA, TRUE),
    attended = dplyr::if_else(is.na(part), NA, part == 1),
    departure_observed = dplyr::if_else(is.na(full), NA, full == 1)
  )
}

analysis_australia_presence <- function(participants, survey = NULL) {
  people <- participants |>
    dplyr::filter(
      poll_id == "australia-republic-1999", source_dataset == "historical"
    )
  if (!nrow(people)) return(NULL)
  if (is.null(survey)) survey <- read_poll_survey("australia-republic-1999")
  evidence <- australia_form_evidence(survey)
  position <- match(people$source_row, survey$source_row)
  stopifnot(!anyNA(position))
  known_id <- !is.na(survey$caseid[position])
  stopifnot(all(people$respondent_id[known_id] ==
                  as.character(as.numeric(survey$caseid[position][known_id]))))
  people |>
    dplyr::select("poll_id", "source_dataset", "respondent_id", "source_row") |>
    dplyr::left_join(evidence,
      by = "source_row", relationship = "many-to-one"
    ) |>
    dplyr::select(
      "poll_id", "source_dataset", "respondent_id",
      t1 = "baseline_observed", t2 = "departure_observed"
    ) |>
    tidyr::pivot_longer(c("t1", "t2"),
      names_to = "wave", values_to = "wave_observed"
    )
}
