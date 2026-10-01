# AUS-06: retain Queen first when the second preference is missing.
source("R/paths.R")
load_project()

poll_id <- "australia-republic-1999"
survey <- read_poll_survey(poll_id)
names(survey) <- tolower(names(survey))
selected <- which(as.numeric(survey$group) %in% 1:24)
stopifnot(nrow(survey) == 4659L, length(selected) == 347L)
production <- build_australia_individual(survey)
reference <- readr::read_tsv(
  "evidence/benchmarks/polardata.tab",
  show_col_types = FALSE
)
reference <- reference[reference$pollid == 26, ]
reference <- reference[match(survey$caseid[selected], reference$caseid), ]
stopifnot(!anyNA(reference$caseid), !anyDuplicated(reference$caseid))

values <- purrr::map(1:2, function(wave) {
  read <- function(stem) as.numeric(survey[[paste0(stem, wave)]])
  first <- read("firstop")
  second <- read("secop")
  previous_rank <- rep(NA_real_, nrow(survey))
  previous_rank[first %in% 3] <- 0
  previous_rank[second %in% c(3, 97, if (wave == 1L) 100 else 99)] <- .5
  third <- !is.na(first) & !is.na(second) &
    first != 3 & second != 3 & second < 90
  previous_rank[third] <- 1
  approved_rank <- previous_rank
  approved_rank[first %in% 3] <- 0
  ties <- read("tiesbr")
  head <- read("headaus")
  ties[!ties %in% 1:5] <- NA_real_
  head[!head %in% 1:5] <- NA_real_
  average <- function(rank) {
    value <- rowMeans(cbind(rank, (5 - ties) / 4, (head - 1) / 4),
      na.rm = TRUE
    )
    value[is.nan(value)] <- NA_real_
    value
  }
  previous <- average(previous_rank)
  approved <- average(approved_rank)
  actual <- production[[paste0("republican_t", wave, "_midpoint_imputed")]]
  field <- paste0("aus.republican", wave)
  stopifnot(
    identical(is.na(previous), is.na(approved)),
    identical(is.na(actual), is.na(approved)),
    all(abs(actual - approved) < 1e-10, na.rm = TRUE),
    all(abs(reference[[field]] - previous[selected]) < 1e-10),
    sum(abs(approved - previous) > 1e-10, na.rm = TRUE) ==
      c(36L, 13L)[wave],
    sum(abs(approved[selected] - previous[selected]) > 1e-10) ==
      c(11L, 13L)[wave]
  )
  tibble::tibble(
    legacy_field = field, source_row = survey$source_row,
    caseid = as.numeric(survey$caseid),
    historical_sample = seq_len(nrow(survey)) %in% selected,
    first_preference = first, second_preference = second,
    previous_rank = previous_rank, approved_rank = approved_rank,
    previous_value = previous, approved_value = approved
  )
}) |> purrr::list_rbind()

historical <- values[values$historical_sample, ]
changed <- abs(historical$previous_value - historical$approved_value) > 1e-10
stopifnot(length(unique(historical$caseid[changed])) == 21L)
directory <- file.path("audit", "corrections", poll_id)
readr::write_csv(values, file.path(directory, "ranking_source_values.csv"))
approved <- historical |>
  dplyr::transmute(
    legacy_field, caseid,
    historical_value = previous_value, approved_value
  )
path <- file.path(directory, "approved_values.csv")
existing_lines <- readLines(path)
updated_fields <- unique(approved$legacy_field)
keep <- !vapply(
  strsplit(existing_lines, ",", fixed = TRUE),
  function(row) row[1L] %in% updated_fields, logical(1)
)
new_lines <- strsplit(readr::format_csv(approved), "\n", fixed = TRUE)[[1L]]
writeLines(c(existing_lines[keep], new_lines[-1L]), path)
summary <- values |>
  dplyr::group_by(.data$legacy_field, .data$historical_sample) |>
  dplyr::summarise(
    people = dplyr::n(),
    changed = sum(abs(.data$previous_value - .data$approved_value) > 1e-10,
      na.rm = TRUE
    ),
    missingness_changed = sum(
      is.na(.data$previous_value) != is.na(.data$approved_value)
    ),
    previous_mean = mean(.data$previous_value, na.rm = TRUE),
    approved_mean = mean(.data$approved_value, na.rm = TRUE),
    maximum_difference = if (any(is.finite(.data$previous_value))) {
      max(abs(.data$previous_value - .data$approved_value), na.rm = TRUE)
    } else {
      NA_real_
    },
    .groups = "drop"
  )
readr::write_csv(summary, file.path(directory, "ranking_summary.csv"))
print(summary, width = Inf)
