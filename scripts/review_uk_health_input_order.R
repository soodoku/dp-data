# UKH-03/07: independent raw-response reconstruction of the approved ordering.
for (module in c(
  "paths", "sources", "metadata", "poll_sources", "poll_adapters", "knowledge",
  "exports", "respondents", "polardata", "polardata_rebuild"
)) source(file.path("R", paste0(module, ".R")))

survey <- read_poll_survey("uk-health-1998")
stopifnot(nrow(survey) == 230L, !anyDuplicated(survey$serial_m))
case_ids <- as.numeric(survey$serial_m)
group <- as.numeric(survey$group)
source_path <- project_path("data", "uk-health-1998", "survey.sav")
source_hash <- tools::md5sum(source_path)

available_mean <- function(values) {
  result <- rowMeans(as.matrix(values), na.rm = TRUE)
  result[is.nan(result)] <- NA_real_
  result
}
raw_index_matrix <- function(wave, folded) {
  response <- function(stem, categories = 5L) {
    value <- as.numeric(survey[[paste0(stem, wave)]])
    stopifnot(all(is.na(value) | value %in% c(-9, -8, seq_len(categories))))
    value[value %in% c(-9, -8)] <- NA_real_
    (value - 1) / (categories - 1)
  }
  average <- function(stems, reverse = FALSE) {
    values <- vapply(stems, response, numeric(nrow(survey)))
    if (reverse) values <- 1 - values
    available_mean(values)
  }
  input_index <- function(stems) {
    values <- vapply(stems, response, numeric(nrow(survey)), categories = 3L)
    if (folded) values[!is.na(values) & values == 0] <- 1
    available_mean(values)
  }
  result <- cbind(
    payhlt = response("payhlth", 3L), poora = response("poora"),
    option = response("options", 3L),
    hlthfu = average(c("chgp", "chvis", "chmeal", "chstay", "chamb")),
    ctexpt = average(c("treata", "cthart", "ctnurs", "ctbaby"), TRUE),
    pritre = average(c("ctfert", "cthosp", "ctcosm"), TRUE),
    severi = .5 + (response("lista") - response("severa")) / 2,
    preven = response("preva"),
    dispub = input_index(c("ingova", "inpuba")),
    avgdis = input_index(c("ingpa", "indoca")), moresa = response("say")
  )
  colnames(result) <- paste0("ukhealth.t", wave, colnames(result))
  result
}
review_values <- function(folded) {
  baseline <- raw_index_matrix(1L, folded)
  departure <- raw_index_matrix(2L, folded)
  individual <- tibble::as_tibble(cbind(baseline, departure))
  individual$attextreme <- available_mean(abs(baseline - .5))
  individual$meanxtreme <- ave(individual$attextreme, group, FUN = mean)
  individual$avgsd <- individual$genvar <- NA_real_
  for (rows in split(seq_len(nrow(survey)), group)) {
    attitudes <- baseline[rows, , drop = FALSE]
    covariance <- stats::cov(attitudes, use = "pairwise.complete.obs")
    individual$avgsd[rows] <- mean(apply(
      attitudes, 2L, stats::sd, na.rm = TRUE
    ))
    individual$genvar[rows] <- abs(det(covariance))^(1 / (2 * ncol(attitudes)))
  }
  individual
}
previous <- review_values(TRUE)
approved <- review_values(FALSE)
rebuilt <- build_historical_poll("uk-health-1998")
rows <- match(case_ids, rebuilt$caseid)
stopifnot(!anyNA(rows), nrow(rebuilt) == 230L)
fields <- c(
  "ukhealth.t1dispub", "ukhealth.t2dispub", "ukhealth.t1avgdis",
  "ukhealth.t2avgdis", "attextreme", "meanxtreme", "avgsd", "genvar"
)
original <- readr::read_tsv(
  project_path("evidence", "benchmarks", "polardata.tab"),
  show_col_types = FALSE
) |>
  dplyr::filter(.data$dpnum == 2)
original_rows <- match(case_ids, original$caseid)
stopifnot(!anyNA(original_rows), !anyDuplicated(original$caseid))
comparison <- purrr::map(fields, function(field) {
  actual <- rebuilt[[field]][rows]
  expected <- approved[[field]]
  stopifnot(
    identical(is.na(actual), is.na(expected)),
    all(abs(actual - expected) < 1e-10, na.rm = TRUE),
    identical(is.na(previous[[field]]), is.na(expected))
  )
  tibble::tibble(
    legacy_field = field, caseid = case_ids, source_row = survey$source_row,
    historical_value = original[[field]][original_rows],
    previous_value = previous[[field]], approved_value = expected
  )
}) |>
  purrr::list_rbind()
summary <- comparison |>
  dplyr::summarise(
    n_changed = sum(abs(.data$approved_value - .data$previous_value) > 1e-10,
      na.rm = TRUE
    ), missingness_changes = sum(
      is.na(.data$approved_value) != is.na(.data$previous_value)
    ), previous_mean = mean(.data$previous_value, na.rm = TRUE),
    approved_mean = mean(.data$approved_value, na.rm = TRUE),
    max_change = max(
      abs(.data$approved_value - .data$previous_value), na.rm = TRUE
    ),
    .by = "legacy_field"
  )
stopifnot(identical(tools::md5sum(source_path), source_hash))
directory <- project_path("audit", "corrections", "uk-health-1998")
readr::write_csv(
  comparison, file.path(directory, "folded_input_approved_values.csv")
)
readr::write_csv(summary, file.path(directory, "folded_input_summary.csv"))
print(summary, width = Inf)
