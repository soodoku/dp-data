harmonized_ordinal_rows <- function(people, responses, rules) {
  purrr::map(seq_len(nrow(rules)), function(i) {
    rule <- rules[i, ]
    source <- responses |>
      dplyr::filter(.data$source_column == rule$source_column)
    position <- match(people$respondent_id, source$respondent_id)
    stopifnot(
      nrow(source) == nrow(people),
      !anyNA(position),
      all(is.na(source$raw_text))
    )
    raw <- source$raw_numeric[position]
    code <- rounded_source_code(raw)
    missing <- if (is.na(rule$missing_codes)) {
      numeric()
    } else {
      as.numeric(strsplit(rule$missing_codes, "|", fixed = TRUE)[[1]])
    }
    substantive <- !is.na(code) & code >= rule$min_code &
      code <= rule$max_code
    stopifnot(
      !anyNA(missing),
      all(is.na(code) | substantive | code %in% missing)
    )
    value <- rep(NA_real_, length(code))
    value[substantive] <- if (rule$high_code == rule$max_code) {
      (code[substantive] - rule$min_code) /
        (rule$max_code - rule$min_code)
    } else {
      (rule$max_code - code[substantive]) /
        (rule$max_code - rule$min_code)
    }
    stopifnot(all(is.na(value) | (value >= 0 & value <= 1)))
    tibble::tibble(
      poll_id = people$poll_id,
      respondent_id = people$respondent_id,
      definition_id = rule$definition_id,
      value_numeric = value,
      n_source_fields = 1L,
      n_observed_fields = as.integer(substantive)
    )
  }) |>
    purrr::list_rbind()
}
