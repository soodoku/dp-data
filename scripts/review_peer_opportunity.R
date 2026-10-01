source("R/paths.R")
load_project()

contracts <- read_metadata("respondent_sources")
poll_ids <- contracts$poll_id
fields <- c("grpgain", "grpgain2", "grpgainr", "loggain")
approved_rule <- apply_peer_opportunity_ceiling
previous_rule <- function(gain, scored_items, group) gain

build_with_ceiling_rule <- function(rule) {
  assign("apply_peer_opportunity_ceiling", rule, envir = .GlobalEnv)
  on.exit(assign(
    "apply_peer_opportunity_ceiling", approved_rule, envir = .GlobalEnv
  ))
  purrr::set_names(poll_ids) |>
    purrr::map(build_historical_poll)
}

previous <- build_with_ceiling_rule(previous_rule)
approved <- build_with_ceiling_rule(approved_rule)
benchmark <- readr::read_tsv(project_path(
  "evidence", "benchmarks", "polardata.tab"
), show_col_types = FALSE)
changes <- purrr::imap(approved, function(current, poll_id) {
  before <- previous[[poll_id]]
  stopifnot(identical(current$caseid, before$caseid))
  unchanged_fields <- setdiff(names(current), fields)
  stopifnot(identical(current[unchanged_fields], before[unchanged_fields]))
  dpnum <- contracts$dpnum[match(poll_id, contracts$poll_id)]
  reference <- historical_reference_people(
    benchmark[benchmark$dpnum == dpnum, ], poll_id
  )
  reference <- reference[match(current$caseid, reference$caseid), ]
  purrr::map(fields, function(field) {
    old <- if (field %in% names(before)) before[[field]] else NA_real_
    new <- if (field %in% names(current)) current[[field]] else NA_real_
    changed <- is.na(old) != is.na(new) |
      (!is.na(old) & !is.na(new) & abs(old - new) > 1e-10)
    changed[is.na(changed)] <- FALSE
    stopifnot(all(is.na(old[changed])))
    stopifnot(all(new[changed] == if (field == "loggain") log(0.0001) else 0))
    tibble::tibble(
      status = "approved", poll_id, legacy_field = field,
      caseid = current$caseid,
      historical_value = reference[[field]], previous_value = old,
      approved_value = new
    )[changed, ]
  }) |>
    purrr::list_rbind()
}) |>
  purrr::list_rbind()
stopifnot(!anyDuplicated(changes[c("poll_id", "caseid", "legacy_field")]))
summary <- changes |>
  dplyr::count(.data$poll_id, .data$legacy_field, name = "changed_values")
directory <- project_path("audit", "corrections", "shared-peer-opportunity")
fs::dir_create(directory)
readr::write_csv(changes, file.path(directory, "approved_values.csv"))
readr::write_csv(summary, file.path(directory, "summary.csv"))
print(summary, n = Inf)
message(
  nrow(changes), " changed cells across ",
  nrow(unique(changes[c("poll_id", "caseid")])), " people; ",
  "all other fields remain identical."
)
