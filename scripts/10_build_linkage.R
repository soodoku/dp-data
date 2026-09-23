source("R/paths.R")
source("R/sources.R")
source("R/metadata.R")
source("R/linkage.R")

verify_source_files()
polardata <- read_polardata()

reliability <- linkage_poll_map$file_key |>
  purrr::map(battery_summary) |>
  purrr::list_rbind() |>
  dplyr::left_join(
    dplyr::select(linkage_poll_map, file_key, cor_poll_name, dpnum),
    by = "file_key",
    relationship = "one-to-one"
  ) |>
  dplyr::mutate(
    alpha_change = alpha_t2 - alpha_t1,
    alpha_t2_higher = alpha_t2 > alpha_t1
  )

crosswalk <- make_crosswalk(polardata, reliability)

reliability <- reliability |>
  dplyr::mutate(dplyr::across(dplyr::where(is.double), ~ round(.x, 10)))
crosswalk <- crosswalk |>
  dplyr::mutate(dplyr::across(dplyr::where(is.double), ~ round(.x, 10)))

validated <- dplyr::filter(
  linkage_poll_map,
  match_status == "validated_person_link"
)
respondent_items <- purrr::map2(
  validated$file_key,
  validated$dpnum,
  linked_items_for_poll,
  polardata = polardata
) |>
  purrr::list_rbind() |>
  dplyr::mutate(dplyr::across(dplyr::where(is.double), ~ round(.x, 10)))
knowledge_attitude_panel <- make_knowledge_attitude_panel(
  polardata,
  respondent_items
) |>
  dplyr::mutate(dplyr::across(dplyr::where(is.double), ~ round(.x, 10)))

dir.create(project_path("output", "linkage"),
  recursive = TRUE,
  showWarnings = FALSE
)

readr::write_csv(crosswalk, project_path(
  "output", "linkage",
  "poll_crosswalk.csv"
), na = "")
readr::write_csv(
  reliability,
  project_path("output", "linkage", "knowledge_reliability.csv"),
  na = ""
)
readr::write_csv(
  respondent_items,
  project_path("output", "linkage", "respondent_items.csv"),
  na = ""
)
readr::write_csv(
  knowledge_attitude_panel,
  project_path("output", "linkage", "knowledge_attitude_panel.csv"),
  na = ""
)

summary <- tibble::tibble(
  measure = c(
    "cor_sood_polls", "distortions_polls", "overlapping_polls",
    "distortions_only_polls",
    "cor_sood_only_polls", "validated_person_link_polls", "mean_alpha_t1",
    "mean_alpha_t2",
    "polls_with_higher_t2_alpha", "linked_respondents",
    "linked_attitude_indices",
    "linked_respondent_attitude_rows"
  ),
  value = c(
    nrow(reliability), dplyr::n_distinct(polardata$dpnum),
    sum(!is.na(linkage_poll_map$dpnum)),
    nrow(linkage_missing_polls), sum(is.na(linkage_poll_map$dpnum)),
    nrow(validated),
    mean(reliability$alpha_t1), mean(reliability$alpha_t2),
    sum(reliability$alpha_t2_higher),
    nrow(dplyr::distinct(knowledge_attitude_panel, dpnum, caseid)),
    nrow(dplyr::distinct(knowledge_attitude_panel, dpnum, attitude_index)),
    nrow(knowledge_attitude_panel)
  )
) |>
  dplyr::mutate(value = round(value, 10))
readr::write_csv(summary, project_path("output", "linkage", "summary.csv"))

paths <- list.files(project_path("output", "linkage"),
  pattern = "[.]csv$",
  full.names = TRUE
)
paths <- paths[basename(paths) != "manifest.csv"]
manifest <- purrr::map(paths, function(path) {
  data <- readr::read_csv(path, show_col_types = FALSE)
  tibble::tibble(
    file = basename(path), rows = nrow(data), columns = ncol(data),
    sha256 = digest::digest(file = path, algo = "sha256"),
    basis = "historical-polardata-and-deposited-batteries"
  )
}) |> purrr::list_rbind()
readr::write_csv(manifest, project_path("output", "linkage", "manifest.csv"))
