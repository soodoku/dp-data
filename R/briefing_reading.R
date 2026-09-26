briefing_reading_sources <- list(
  "australia-republic-1999" = list(
    column = "readmat2", missing = c(94, 99, 100, 103)
  ),
  "cpl-1996" = list(column = "readmat", missing = 99),
  "europolis-2009" = list(column = "V2Q63", missing = 997:999),
  "nic-1996" = list(column = "READDIS2", missing = numeric()),
  "nic2-2003" = list(column = "eval5", missing = numeric()),
  "san-mateo-2008" = list(column = "t2q37", missing = numeric()),
  "swepco-1996" = list(column = "READMAT", missing = numeric()),
  "tomorrows-europe-2007" = list(column = "t3q42", missing = numeric()),
  "wtu-1996" = list(column = "READMAT", missing = numeric())
)

build_briefing_reading <- function(people) {
  purrr::imap(briefing_reading_sources, function(spec, poll_id) {
    survey <- read_poll_survey(poll_id)
    identity <- people |>
      dplyr::filter(.data$poll_id == .env$poll_id) |>
      dplyr::arrange(.data$source_row)
    stopifnot(
      nrow(survey) == nrow(identity),
      identical(as.integer(survey$source_row), identity$source_row),
      spec$column %in% names(survey)
    )
    raw <- as.numeric(unclass(survey[[spec$column]]))
    code <- rounded_source_code(raw)
    stopifnot(all(code[!is.na(code)] %in% c(1:5, spec$missing)))
    code[code %in% spec$missing] <- NA_real_
    score <- if (poll_id == "nic-1996") {
      c(0, .33, .33, .66, 1)[code]
    } else {
      (code - 1) / 4
    }
    dplyr::transmute(
      identity,
      poll_id, respondent_id, historical_respondent_id, source_row,
      source_column = spec$column,
      raw_code = raw,
      reading_score = score
    )
  }) |>
    purrr::list_rbind()
}
