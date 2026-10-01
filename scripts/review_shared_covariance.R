# X-15: distinguish invalid pairwise covariance from numerical roundoff.
source("R/paths.R")
load_project()

review_shared_covariance <- function() {
  shared_genvar <- historical_genvar
  legacy_genvar <- function(attitudes) {
    covariance <- stats::cov(as.matrix(attitudes),
                             use = "pairwise.complete.obs")
    if (anyNA(covariance)) return(NA_real_)
    determinant <- det(covariance)
    sqrt(sqrt(determinant^2)^(1 / ncol(attitudes)))
  }
  contracts <- read_metadata("respondent_sources")
  benchmark <- readr::read_tsv(project_path(
    "evidence", "benchmarks", "polardata.tab"
  ), show_col_types = FALSE)
  environment <- environment(build_historical_poll)
  on.exit(assign("historical_genvar", shared_genvar, envir = environment))
  assign("historical_genvar", legacy_genvar, envir = environment)
  before <- purrr::map(contracts$poll_id, build_historical_poll)
  assign("historical_genvar", shared_genvar, envir = environment)
  state <- new.env(parent = emptyenv())
  state$baseline_diagnostics <- list()
  state$current_poll <- ""
  original_dispersion <- historical_group_dispersion
  on.exit(assign("historical_group_dispersion", original_dispersion,
                 envir = environment), add = TRUE)
  audited_dispersion <- function(attitudes, group) {
    if (state$current_poll %in% names(state$baseline_diagnostics)) {
      return(original_dispersion(attitudes, group))
    }
    state$baseline_diagnostics[[state$current_poll]] <-
      group_covariance_audit(attitudes, group, state$current_poll)
    original_dispersion(attitudes, group)
  }
  assign("historical_group_dispersion", audited_dispersion, envir = environment)
  after <- purrr::map(contracts$poll_id, function(poll_id) {
    state$current_poll <- poll_id
    build_historical_poll(poll_id)
  })
  assign("historical_group_dispersion", original_dispersion,
         envir = environment)
  evidence <- purrr::map(seq_len(nrow(contracts)), function(index) {
    poll_id <- contracts$poll_id[index]
    a <- before[[index]]
    b <- after[[index]]
    stopifnot(identical(a[setdiff(names(a), "genvar")],
                        b[setdiff(names(b), "genvar")]))
    changed <- !is.na(a$genvar) & is.na(b$genvar)
    stopifnot(identical(a$genvar[!changed], b$genvar[!changed]))
    reference <- historical_reference_people(
      benchmark[benchmark$dpnum == contracts$dpnum[index], ], poll_id
    )
    positions <- match(a$caseid, reference$caseid)
    present <- !is.na(positions)
    historical <- reference$genvar[positions]
    prior_reference <- rep(NA_real_, nrow(a))
    prior_reference[present] <- approved_poll_reference_values(
      poll_id, "genvar", a$caseid[present], historical[present]
    )
    tibble::tibble(
      poll_id, legacy_field = "genvar", caseid = a$caseid,
      source_row = a$source_row, pollgroup = a$pollgroup,
      historical_present = present, historical_value = historical,
      previous_reference = prior_reference, previous_value = a$genvar,
      approved_value = b$genvar
    )[changed, ]
  }) |> purrr::list_rbind()
  stopifnot(
    nrow(evidence) == 1185L,
    nrow(unique(evidence[c("poll_id", "pollgroup")])) == 87L,
    length(unique(evidence$poll_id)) == 10L,
    all(is.na(evidence$approved_value))
  )
  directory <- project_path("audit", "corrections", "shared-covariance")
  fs::dir_create(directory)
  diagnostics <- purrr::list_rbind(state$baseline_diagnostics)
  stopifnot(nrow(diagnostics) == 397L,
            sum(diagnostics$negative_eigenvalues > 0, na.rm = TRUE) == 87L)
  readr::write_csv(diagnostics, file.path(directory, "group_diagnostics.csv"))
  readr::write_csv(evidence, file.path(directory, "approved_values.csv"))
  summary <- evidence |>
    dplyr::summarise(
      groups = dplyr::n_distinct(.data$pollgroup),
      respondents = dplyr::n(),
      previous_mean = mean(.data$previous_value),
      .by = "poll_id"
    )
  readr::write_csv(summary, file.path(directory, "summary.csv"))
  print(summary)
}

review_shared_covariance()
