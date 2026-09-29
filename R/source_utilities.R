read_utilities_original <- function(poll_id) {
  stopifnot(poll_id %in% c("swepco-1996", "wtu-1996"))
  record <- read_metadata("source_files") |>
    dplyr::filter(source_id == paste0("cdd-", poll_id, "-original-portable"))
  stopifnot(nrow(record) == 1L)
  path <- project_path(record$path)
  stopifnot(digest::digest(file = path, algo = "sha256") == record$sha256)
  lines <- readLines(path, warn = FALSE)
  stopifnot(all(nchar(lines, type = "bytes") == 80L))
  content <- paste0(lines, collapse = "")
  stopifnot(substr(content, 457L, 464L) == "SPSSPORT")
  positions <- gregexpr("*", content, fixed = TRUE)[[1L]]
  tokens <- substring(content, positions, positions + 1L)
  stopifnot(
    identical(tokens[[1L]], "*)"),
    all(tokens[-1L] == "*1"), all(positions[-1L] > 10000L)
  )

  # Stat/Transfer used *1 for missing values; ReadStat expects *.
  # https://pspp.benpfaff.org/manual/portable.html#Portable-File-Structure
  normalized <- gsub("*1", "*.", content, fixed = TRUE)
  starts <- seq.int(1L, nchar(normalized), by = 80L)
  records <- substring(normalized, starts, starts + 79L)
  temporary <- tempfile(fileext = ".por")
  on.exit(unlink(temporary), add = TRUE)
  writeBin(charToRaw(paste0(paste(records, collapse = "\r\n"), "\r\n")),
    temporary
  )
  survey <- haven::read_por(temporary)
  stopifnot(
    nrow(survey) == if (poll_id == "swepco-1996") 1478L else 1230L,
    ncol(survey) == 195L, all(vapply(survey, is.numeric, logical(1))),
    !anyNA(survey$CASEID), !anyDuplicated(survey$CASEID),
    all(survey$PART %in% 1:2)
  )
  survey
}

review_utilities_original <- function(
  poll_id, maintained = read_poll_survey(poll_id)
) {
  original <- read_utilities_original(poll_id)
  stopifnot(
    all(names(original) %in% names(maintained)),
    identical(as.numeric(original$CASEID), as.numeric(maintained$CASEID)),
    setequal(
      setdiff(names(maintained), names(original)), c("source_row", "SETRT")
    ),
    all(is.na(maintained$SETRT))
  )
  collapsed <- purrr::map(names(original), function(field) {
    before <- original[[field]]
    after <- maintained[[field]]
    both <- !is.na(before) & !is.na(after)
    lost <- !is.na(before) & is.na(after)
    stopifnot(
      !any(is.na(before) & !is.na(after)),
      all(abs(before[both] - after[both]) < 2e-12),
      all(before[lost] %in% c(98, 99, 999))
    )
    tibble::tibble(
      poll_id = poll_id, respondent_id = as.character(original$CASEID[lost]),
      source_column = field, original_value = as.numeric(before[lost])
    )
  }) |>
    purrr::list_rbind()
  post_fields <- names(original)[
    grepl("2$", names(original)) & !grepl("^KNOW", names(original))
  ]
  absent <- original$PART == 2L
  stopifnot(
    length(post_fields) == 74L, all(is.na(original[absent, post_fields]))
  )
  list(
    original = original, collapsed = collapsed,
    absent_post_ids = as.character(original$CASEID[absent])
  )
}
