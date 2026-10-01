source("R/paths.R")
load_project()

read_export <- function(name) {
  arrow::read_parquet(project_path(
    "output", "respondent",
    paste0(name, ".parquet")
  ))
}
parity <- compare_respondent_measures(
  read_export("respondent_measures"), read_export("people"),
  read_export("sample_memberships"),
  readr::read_tsv(project_path("evidence", "benchmarks", "polardata.tab"),
    show_col_types = FALSE
  )
)
readr::write_csv(parity, project_path("audit", "respondent_parity.csv"))
if (any(parity$unexplained_differences != 0)) {
  stop("Respondent reconstruction differs; see audit/respondent_parity.csv")
}
print(parity)
