# Run from dp-learning with INPUT_DIR OUTPUT_DIR arguments.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 2L)
input <- normalizePath(args[[1]], mustWork = TRUE)
dir.create(args[[2]], recursive = TRUE, showWarnings = FALSE)
output <- normalizePath(args[[2]], mustWork = TRUE)
repo <- normalizePath(getwd())
stopifnot(output != repo, !startsWith(output, paste0(repo, "/")))
for (file in list.files("R", full.names = TRUE)) source(file)
paths <- file.path(
  input, c("historical-polardata.tab", "candidate-polardata.tab")
)
stopifnot(all(file.exists(paths)))
readr::write_csv(tibble::tibble(
  scenario = c("historical", "candidate"),
  sha256 = vapply(paths, digest::digest, "", algo = "sha256", file = TRUE),
  revision = system2("git", c("rev-parse", "HEAD"), stdout = TRUE)
), file.path(output, "downstream-provenance.csv"))
reader <- readLines("R/knowledge.R")
lines <- c(
  "      ppage = dplyr::if_else(nic, 1996 - ppage, ppage),",
  "      mode = dplyr::if_else(nic, 0, mode),"
)
stopifnot(all(vapply(
  lines, function(line) sum(reader == line) == 1L, logical(1)
)))
adapted <- new.env(parent = globalenv())
eval(parse(text = reader[!reader %in% lines]), envir = adapted)
greece <- read_greece()
inputs <- lapply(paths, function(path) {
  dplyr::bind_rows(read_polardata(path), greece)
})
frames <- list(
  historical = analysis_frame(inputs[[1]]),
  candidate_unadapted = analysis_frame(inputs[[2]]),
  candidate_adapted = adapted$analysis_frame(inputs[[2]])
)
stopifnot(all(vapply(frames, function(frame) {
  identical(frame$caseid, frames$historical$caseid)
}, logical(1))))
ages <- purrr::imap_dfr(frames, function(frame, scenario) {
  frame |>
    dplyr::filter(dpnum == 20) |>
    dplyr::transmute(scenario, caseid, age, online)
})
readr::write_csv(ages, file.path(output, "downstream-ages.csv"))
summary <- ages |>
  dplyr::summarise(
    respondents = dplyr::n(), observed_age = sum(!is.na(age)),
    mean_age = if (all(is.na(age))) NA_real_ else mean(age, na.rm = TRUE),
    .by = scenario
  )
readr::write_csv(summary, file.path(output, "downstream-age-summary.csv"))
models <- list(
  main = main_formula, minority = minority_formula, briefing = briefing_formula
)
for (scenario in names(frames)) {
  frame <- frames[[scenario]]
  fits <- purrr::imap_dfr(models, function(formula, name) {
    fit <- fit_knowledge(frame, formula)
    tidy_fit(fit, name) |>
      dplyr::mutate(
        singular = lme4::isSingular(fit),
        convergence_message = paste(
          fit@optinfo$conv$lme4$messages, collapse = "; "
        )
      )
  })
  readr::write_csv(fits, file.path(
    output, paste0("downstream-", scenario, "-models.csv")
  ))
}
