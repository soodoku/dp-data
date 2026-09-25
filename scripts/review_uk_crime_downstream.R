# Run from the downstream checkout to use its normal dependency environment.
# Arguments: distortions|deliberately|learning INPUT_DIR OUTPUT_DIR [INDEX_TSV]
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) %in% 3:4)
mode <- match.arg(args[[1]], c("distortions", "deliberately", "learning"))
repo <- normalizePath(getwd())
input <- normalizePath(args[[2]], mustWork = TRUE)
dir.create(args[[3]], recursive = TRUE, showWarnings = FALSE)
output <- normalizePath(args[[3]], mustWork = TRUE)
stopifnot(!startsWith(output, paste0(repo, "/")), output != repo)
index <- normalizePath(if (length(args) == 4L) {
  args[[4]]
} else {
  "../dp-data/evidence/benchmarks/attitude-indices.tab"
}, mustWork = TRUE)
scenarios <- c("historical", "candidate")
inputs <- file.path(input, paste0(scenarios, "-polardata.tab"))
stopifnot(all(file.exists(inputs)))
write.csv(
  data.frame(
    repository = repo,
    revision = system2("git", "rev-parse HEAD", stdout = TRUE),
    mode = mode
  ), file.path(output, "source-revision.csv"),
  row.names = FALSE
)
write.csv(
  data.frame(
    file = c(inputs, index),
    sha256 = vapply(c(inputs, index), digest::digest, "",
      algo = "sha256", file = TRUE
    )
  ), file.path(output, "input-hashes.csv"),
  row.names = FALSE
)

prepare_input <- function(scenario) {
  root <- file.path(output, scenario)
  dest <- file.path(root, "evidence", "benchmarks")
  dir.create(dest, recursive = TRUE, showWarnings = FALSE)
  stopifnot(file.copy(
    file.path(input, paste0(scenario, "-polardata.tab")),
    file.path(dest, "polardata.tab"),
    overwrite = TRUE
  ))
  stopifnot(file.copy(index, file.path(dest, "attitude-indices.tab"),
    overwrite = TRUE
  ))
  root
}

if (mode == "distortions") {
  stopifnot(file.exists("scripts/01_hom_pol.R"))
  for (scenario in scenarios) {
    root <- prepare_input(scenario)
    for (directory in c("scripts", "data")) {
      dir.create(file.path(root, directory), showWarnings = FALSE)
    }
    file.copy(file.path(repo, "DESCRIPTION"), root, overwrite = TRUE)
    scripts <- c(
      "00_functions.R", "01_hom_pol.R", "02_domination.R",
      "03_se.R", "05_attitude_change.R"
    )
    copied <- file.copy(
      file.path(repo, "scripts", scripts), file.path(root, "scripts"),
      overwrite = TRUE
    )
    stopifnot(all(copied))
    manifest <- read.csv(file.path(repo, "data", "sources.csv"))
    manifest$sha256 <- vapply(file.path(root, manifest$path), digest::digest,
      "",
      algo = "sha256", file = TRUE
    )
    write.csv(manifest, file.path(root, "data", "sources.csv"),
      row.names = FALSE
    )
    Sys.setenv(DP_DATA_ROOT = root)
    setwd(root)
    env <- new.env(parent = globalenv())
    analysis_scripts <- c("01_hom_pol.R", "02_domination.R",
      "05_attitude_change.R"
    )
    for (script in analysis_scripts) {
      sys.source(file.path("scripts", script), envir = env)
    }
    # Evaluate the unchanged CR2 estimator without the costly wild bootstrap.
    expressions <- parse("scripts/03_se.R")
    for (expression in expressions) {
      if (is.call(expression) && identical(expression[[1]], as.name("<-")) &&
            identical(expression[[2]], as.name("infer_mean"))) {
        eval(expression, env)
      }
    }
    library(sandwich)
    library(clubSandwich)
    infer <- function(data, outcomes, dimension) {
      lapply(outcomes, function(outcome) {
        env$infer_mean(data, outcome, if (grepl("freq", outcome)) .5 else 0) |>
          dplyr::mutate(outcome = outcome, dimension = dimension)
      })
    }
    rows <- infer(
      read.csv("tabs/03_hom_pol_by_group_issue.csv"),
      c("homoex", "homofreq", "polarex", "polarfreq"), "all"
    )
    for (dimension in c("educ", "gender", "income", "triple")) {
      data <- read.csv(paste0("tabs/03_dom_", dimension, "_by_group_issue.csv"))
      rows <- c(rows, infer(
        data,
        c(
          "ext_grp", "freqgrp_grp", "ext_dis", "freqdis_grp", "ext_adv",
          "freqadv_grp"
        ), dimension
      ))
    }
    write.csv(dplyr::bind_rows(rows), "tabs/paired_inference.csv",
      row.names = FALSE
    )
    setwd(repo)
  }
}

if (mode == "deliberately") {
  stopifnot(file.exists("R/import.R"))
  for (file in list.files("R", full.names = TRUE)) source(file)
  for (scenario in scenarios) {
    root <- prepare_input(scenario)
    files <- c("polardata.tab", "attitude-indices.tab")
    manifest <- data.frame(
      file = files,
      sha256 = vapply(file.path(root, "evidence", "benchmarks", files),
        digest::digest, "",
        algo = "sha256", file = TRUE
      )
    )
    bundle <- read_distortions(root, manifest)
    for (name in names(bundle$tables)) {
      table <- bundle$tables[[name]]
      if ("event_id" %in% names(table)) {
        bundle$tables[[name]] <- table[table$event_id == "27", , drop = FALSE]
      }
    }
    for (name in c("items", "responses")) {
      table <- bundle$tables[[name]]
      bundle$tables[[name]] <- table[
        table$item_id == "ukcrime.rootcauset1", ,
        drop = FALSE
      ]
    }
    contrasts <- list(
      define_contrast("gender", function(p) p$female == 1,
        function(p) p$female == 0,
        rationale = "Paired UKC-01 diagnostic",
        reference_advantaged = TRUE
      ),
      define_contrast("education", function(p) p$bettered == 0,
        function(p) p$bettered == 1,
        rationale = "Paired UKC-01 diagnostic",
        reference_advantaged = TRUE
      )
    )
    metrics <- outcome_metrics(
      bundle,
      resolve_contrasts(bundle, contrasts), audit_config()
    )
    write.csv(metrics, file.path(root, "paired-outcomes.csv"),
      row.names = FALSE
    )
  }
}

if (mode == "learning") {
  stopifnot(file.exists("R/knowledge.R"))
  for (file in list.files("R", full.names = TRUE)) source(file)
  greece <- read_greece()
  frames <- lapply(inputs, function(path) {
    analysis_frame(dplyr::bind_rows(read_polardata(path), greece))
  })
  stopifnot(identical(frames[[1]], frames[[2]]))
  write.csv(data.frame(
    identical = TRUE, rows = nrow(frames[[1]]), columns = ncol(frames[[1]])
  ), file.path(output, "analysis-frame-comparison.csv"), row.names = FALSE)
}
