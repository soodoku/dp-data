read_new_haven_workbook <- function(path) {
  waves <- c("Pre", "Mid", "Post")
  stopifnot(setequal(readxl::excel_sheets(path), waves))
  parts <- purrr::map(waves, function(wave) {
    data <- readxl::read_excel(path, sheet = wave)
    id <- if (wave == "Pre") "ASSIGNED" else "SVY#"
    stopifnot(id %in% names(data), "GRP#" %in% names(data),
      !anyNA(data[[id]]), !anyDuplicated(data[[id]])
    )
    list(id = data[[id]], group = data[["GRP#"]], data = data)
  })
  baseline <- parts[[1]]
  joined <- purrr::map2(parts, waves, function(part, wave) {
    stopifnot(setequal(part$id, baseline$id))
    index <- match(baseline$id, part$id)
    stopifnot(identical(part$group[index], baseline$group))
    questions <- grepl("^Q[0-9]+[A-Z]?$", names(part$data))
    data <- part$data[index, questions]
    names(data) <- paste0(tolower(wave), "_", tolower(names(data)))
    data
  })
  dplyr::bind_cols(tibble::tibble(
    source_row = seq_along(baseline$id), assigned = baseline$id,
    group = baseline$group
  ), joined)
}

new_haven_departure_observed <- function(survey) {
  questions <- c(
    paste0("1", letters[1:8]), as.character(2:45),
    paste0(c(16:19, 25), "a"), paste0("46", letters[1:4]),
    paste0("47", letters[1:9]), as.character(48:51),
    paste0("52", letters[1:4])
  )
  fields <- paste0("post_q", questions)
  stopifnot(
    length(fields) == 78L, !anyDuplicated(fields),
    all(fields %in% names(survey)),
    all(vapply(survey[fields], is.numeric, logical(1)))
  )
  responses <- as.matrix(survey[fields])
  all_zero <- rowSums(!is.na(responses) & responses == 0) == length(fields)
  observed <- rowSums(!is.na(responses) & responses != 0) > 0L
  dplyr::case_when(all_zero ~ FALSE, observed ~ TRUE, TRUE ~ NA)
}
