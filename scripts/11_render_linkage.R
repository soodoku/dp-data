source("R/paths.R")

dir.create(project_path("output", "linkage", "tables"),
  recursive = TRUE,
  showWarnings = FALSE
)

format_table <- function(data, caption, filename, digits = 3) {
  data |>
    knitr::kable(
      format = "html",
      caption = caption,
      digits = digits,
      escape = TRUE
    ) |>
    kableExtra::kable_styling(
      bootstrap_options = c("striped", "hover", "condensed"),
      full_width = FALSE,
      position = "left"
    ) |>
    kableExtra::save_kable(
      project_path("output", "linkage", "tables", filename),
      self_contained = TRUE
    )
}

reliability <- readr::read_csv(
  project_path("output", "linkage", "knowledge_reliability.csv"),
  show_col_types = FALSE
) |>
  dplyr::transmute(
    Poll = cor_poll_name,
    Respondents = respondents,
    Items = items,
    `T1 alpha` = alpha_t1,
    `T2 alpha` = alpha_t2,
    Change = alpha_change
  )
crosswalk <- readr::read_csv(
  project_path("output", "linkage", "poll_crosswalk.csv"),
  show_col_types = FALSE
) |>
  dplyr::transmute(
    `File key` = file_key,
    `Cor–Sood poll` = cor_poll_name,
    `Distortions poll` = pollname,
    Status = match_status,
    Reason = mismatch_reason
  )

format_table(
  reliability,
  "Knowledge-index reliability at T1 and T2",
  "knowledge-reliability.html"
)
format_table(crosswalk, "Poll linkage audit", "poll-crosswalk.html")
