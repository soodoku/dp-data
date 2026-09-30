read_northern_ireland_codes <- function(path) {
  data <- readr::read_csv(
    path, col_types = readr::cols(.default = readr::col_character()),
    na = c("", "NA"), trim_ws = FALSE,
    locale = readr::locale(encoding = "Windows-1252"),
    show_col_types = FALSE
  )
  extract_northern_ireland_codes(data)
}

extract_northern_ireland_codes <- function(data) {
  columns <- grep(
    "^t[23]\\.q(18|19|20|21)\\.[ab][1-5]\\.(ch|la|monty)$",
    names(data), value = TRUE
  )
  stopifnot(
    "Participant ID" %in% names(data), length(columns) == 240L,
    !anyNA(data[["Participant ID"]]),
    !anyDuplicated(data[["Participant ID"]]),
    all(vapply(data[columns], is.character, logical(1L)))
  )
  data |>
    dplyr::select(respondent_id = "Participant ID", dplyr::all_of(columns)) |>
    tidyr::pivot_longer(
      -"respondent_id",
      names_to = c("wave", "topic", "side", "slot", "coder"),
      names_pattern =
        "^t([23])\\.q(18|19|20|21)\\.([ab])([1-5])\\.(ch|la|monty)$",
      values_to = "raw_code", values_transform = as.character
    ) |>
    dplyr::mutate(dplyr::across(
      c("respondent_id", "wave", "topic", "slot"), as.integer
    ))
}
