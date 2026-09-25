# Run from dp-learning with INPUT_DIR OUTPUT_DIR arguments.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 2L)
input <- normalizePath(args[[1]], mustWork = TRUE)
dir.create(args[[2]], recursive = TRUE, showWarnings = FALSE)
output <- normalizePath(args[[2]], mustWork = TRUE)
repo <- normalizePath(getwd())
stopifnot(output != repo, !startsWith(output, paste0(repo, "/")))
for (file in list.files("R", full.names = TRUE)) source(file)
scenarios <- c("historical", "candidate")
inputs <- file.path(input, paste0(scenarios, "-polardata.tab"))
stopifnot(all(file.exists(inputs)))
readr::write_csv(tibble::tibble(
  scenario = scenarios,
  sha256 = vapply(inputs, digest::digest, "", algo = "sha256", file = TRUE),
  revision = system2("git", c("rev-parse", "HEAD"), stdout = TRUE)
), file.path(output, "downstream-provenance.csv"))
greece <- read_greece()
frames <- lapply(inputs, function(path) {
  analysis_frame(dplyr::bind_rows(read_polardata(path), greece))
})
# The item-linked model requires a separate cross-poll battery alignment check.
cor_dir <- extract_cor_data()
alignment <- purrr::map2_dfr(
  t1_linked_polls$file_key, t1_linked_polls$dpnum,
  function(file_key, dpnum) {
    battery <- read_battery(file.path(cor_dir, paste0(file_key, ".csv")))
    poll <- dplyr::filter(
      read_polardata(inputs[[1]]), .data$dpnum == .env$dpnum
    )
    difference <- rowMeans(battery$t1) - poll$t1know
    tibble::tibble(
      file_key = file_key, n = nrow(poll),
      max_absolute_difference = max(abs(difference)),
      outside_tolerance = sum(abs(difference) >= 1e-7)
    )
  }
)
readr::write_csv(alignment, file.path(output, "downstream-item-alignment.csv"))
stopifnot(identical(frames[[1]]$caseid, frames[[2]]$caseid))
changes <- purrr::map_dfr(names(frames[[1]]), function(field) {
  a <- frames[[1]][[field]]
  b <- frames[[2]][[field]]
  tibble::tibble(
    field = field, values_changed = sum(a != b, na.rm = TRUE),
    missingness_changed = sum(is.na(a) != is.na(b))
  )
})
readr::write_csv(changes, file.path(output, "downstream-frame-changes.csv"))
models <- list(
  main = main_formula, minority = minority_formula,
  briefing = briefing_formula
)
for (i in seq_along(scenarios)) {
  frame <- frames[[i]]
  gains <- poll_gains(frame)
  readr::write_csv(gains, file.path(
    output, paste0("downstream-", scenarios[[i]], "-gains.csv")
  ))
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
    output, paste0("downstream-", scenarios[[i]], "-models.csv")
  ))
}
