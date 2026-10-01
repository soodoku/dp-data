source("R/paths.R")
load_project()

report <- project_path(
  "data", "a1r-climate-2021", "reports", "climate_results.pdf"
)
source_path <- project_path("data", "a1r-climate-2021", "participants.tab")
source_hash <- tools::md5sum(c(report, source_path))
text_path <- tempfile(fileext = ".txt")
status <- system2(
  "pdftotext", c("-layout", shQuote(report), shQuote(text_path))
)
stopifnot(status == 0L)
text <- paste(readLines(text_path, warn = FALSE), collapse = "\n")
unlink(text_path)
pattern <- paste0(
  "(?m)^\\s*(Q[0-9]+[A-Z])\\s+[^\\n]*?",
  "(-?[0-9]+\\.[0-9]{3})[ \\t]+(-?[0-9]+\\.[0-9]{3})[ \\t]+",
  "(-?[0-9]+\\.[0-9]{3})[ \\t]+\\("
)
printed <- stringr::str_match_all(text, pattern)[[1]]
stopifnot(nrow(printed) == 93L, !anyDuplicated(printed[, 2]))
printed <- tibble::tibble(
  item = printed[, 2], reported_pre = as.numeric(printed[, 3]),
  reported_post = as.numeric(printed[, 4]),
  reported_change = as.numeric(printed[, 5])
)
survey <- readr::read_tsv(source_path, show_col_types = FALSE)
delegates <- survey |> dplyr::filter(FINAL_ATTEND == 8)
stopifnot(nrow(delegates) == 962L, !anyDuplicated(delegates$CaseId))
review <- purrr::map(printed$item, function(item) {
  pre <- as.numeric(delegates[[item]])
  post <- as.numeric(delegates[[paste0("T2", item)]])
  weight <- delegates$WEIGHT1
  stopifnot(
    all(is.na(pre) | pre %in% c(0:10, 77, 88, 98, 99)),
    all(is.na(post) | post %in% c(0:10, 77, 88, 98, 99)),
    all(is.finite(weight) & weight > 0)
  )
  pre[!pre %in% 0:10] <- NA_real_
  post[!post %in% 0:10] <- NA_real_
  paired <- !is.na(pre) & !is.na(post)
  weighted <- function(x, rows) sum(x[rows] * weight[rows]) / sum(weight[rows])
  initial <- weighted(pre, paired)
  later <- weighted(post, paired)
  tibble::tibble(
    item, observed_pre = sum(!is.na(pre)), observed_post = sum(!is.na(post)),
    paired = sum(paired), rebuilt_pre = initial, rebuilt_post = later,
    rebuilt_change = later - initial,
    available_pre = weighted(pre, !is.na(pre)),
    available_post = weighted(post, !is.na(post))
  )
}) |>
  purrr::list_rbind() |>
  dplyr::left_join(printed, by = "item", relationship = "one-to-one")
for (field in c("pre", "post", "change")) {
  stopifnot(all(abs(
    review[[paste0("rebuilt_", field)]] - review[[paste0("reported_", field)]]
  ) <= .00050001))
}
stopifnot(
  sum(grepl("^Q([0-9]|1[0-2])[A-Z]$", review$item)) == 72L,
  identical(source_hash, tools::md5sum(c(report, source_path)))
)
directory <- project_path("audit", "corrections", "a1r-climate-2021")
fs::dir_create(directory)
readr::write_csv(review, file.path(directory, "attitude_report_comparison.csv"))
message(
  "All 93 initial means, 93 post means and 93 changes reproduce within ",
  "printed rounding using item-paired respondents and WEIGHT1. ",
  "This reproduces the report; it does not select analytical weights."
)
