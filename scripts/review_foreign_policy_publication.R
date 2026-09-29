# Compare the published Table 1 trade row with source-backed alternatives.
source("R/paths.R")
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) <= 1L)
out <- if (length(args)) {
  args[[1]]
} else {
  project_path(
    "audit", "foreign-policy-attitudes", "publication"
  )
}
dir.create(out, recursive = TRUE, showWarnings = FALSE)
archive_path <- "data/btp-national-2003/source-materials/publication-survey.dta"
read_data <- function(path) haven::read_dta(project_path(path))
nic <- read_data("data/nic2-2003/survey.dta")
nic <- nic[nic$casetype %in% 1, ]
online <- read_data("data/btp-national-2003/survey.dta")
archive <- read_data(archive_path)
master_path <- "data/btp-national-2003/source-materials/master-survey.sav"
master <- haven::read_sav(project_path(master_path))
names(master) <- tolower(names(master))
stopifnot(
  !anyDuplicated(master$serial),
  identical(as.numeric(master$serial), as.numeric(archive$serial))
)
master_fields <- grep("^q[bf][0-9]", names(archive), value = TRUE)
stopifnot(length(master_fields) == 205L, all(master_fields %in% names(master)))
master_checks <- purrr::map_dfr(master_fields, function(field) {
  original <- as.numeric(master[[field]])
  publication <- as.numeric(archive[[field]])
  tibble::tibble(
    field = field, n = length(original),
    missing_differences = sum(is.na(original) != is.na(publication)),
    value_differences = sum(original != publication, na.rm = TRUE)
  )
})
stopifnot(
  all(master_checks$missing_differences == 0),
  all(master_checks$value_differences == 0)
)
readr::write_csv(master_checks, file.path(out, "master_raw_checks.csv"))
timing_fields <- c(
  "dt_start", "dt_end", "tm_start", "tm_end", "f_dt_st", "f_dt_end",
  "f_tm_st", "f_tm_end", "duration", "f_durat"
)
precision <- purrr::map_dfr(timing_fields, function(field) {
  original <- as.numeric(master[[field]])
  publication <- as.numeric(archive[[field]])
  rounded <- readBin(
    writeBin(original, raw(), size = 4), "double", length(original), size = 4
  )
  tibble::tibble(
    field = field, label = attr(master[[field]], "label"),
    observed = sum(!is.na(original)),
    missing_differences = sum(is.na(original) != is.na(publication)),
    value_differences = sum(original != publication, na.rm = TRUE),
    max_difference = max(abs(original - publication), na.rm = TRUE),
    float32_differences = sum(rounded != publication, na.rm = TRUE)
  )
})
stopifnot(
  all(precision$missing_differences == 0),
  all(precision$float32_differences == 0),
  !any(master$serial[master$dt_start > 20021209] %in% online$serial)
)
readr::write_csv(precision, file.path(out, "source_precision.csv"))
stopifnot(
  nrow(nic) == 340, nrow(online) == 245,
  !anyDuplicated(nic$nicid), !anyDuplicated(online$serial),
  !anyDuplicated(archive$serial)
)
matched <- match(online$serial, archive$serial)
stopifnot(!anyNA(matched), all(archive$exp_cond[matched] == 1))
raw_fields <- c("qb32a", "qb33", "qf32a", "qf33")
raw_checks <- purrr::map_dfr(raw_fields, function(field) {
  current <- as.numeric(online[[field]])
  prior <- as.numeric(archive[[field]][matched])
  tibble::tibble(
    field = field, matched_people = length(matched),
    missingness_differences = sum(is.na(current) != is.na(prior)),
    value_differences = sum(current != prior, na.rm = TRUE)
  )
})
stopifnot(
  all(raw_checks$missingness_differences == 0),
  all(raw_checks$value_differences == 0)
)
score <- function(x, codes, values) values[match(as.numeric(x), codes)]
available_mean <- function(x, y) {
  value <- rowMeans(cbind(x, y), na.rm = TRUE)
  value[is.nan(value)] <- NA_real_
  value
}
components <- function(data, poll) {
  if (poll == "NIC2") {
    pre_wto <- data$trd1_a
    post_wto <- data$qtrd1_a
    pre_nafta <- score(data$trd2, c(1, 3, 5), c(0, .5, 1))
    post_nafta <- score(data$qtrd2, c(1, 3, 5), c(0, .5, 1))
  } else {
    pre_wto <- data$qb32a
    post_wto <- data$qf32a
    pre_nafta <- score(data$qb33, 1:3, c(0, .5, 1))
    post_nafta <- score(data$qf33, 1:3, c(0, .5, 1))
  }
  old_pre_wto <- score(pre_wto, 1:3, c(0, .5, 1))
  old_post_wto <- score(post_wto, 1:3, c(0, .5, 1))
  reviewed_pre_wto <- score(pre_wto, 1:3, c(.5, 1, 0))
  reviewed_post_wto <- score(post_wto, 1:3, c(.5, 1, 0))
  tibble::tibble(
    nafta_pre = pre_nafta, nafta_post = post_nafta,
    old_composite_pre = available_mean(old_pre_wto, pre_nafta),
    old_composite_post = available_mean(old_post_wto, post_nafta),
    reviewed_composite_pre = available_mean(reviewed_pre_wto, pre_nafta),
    reviewed_composite_post = available_mean(reviewed_post_wto, post_nafta),
    reviewed_wto_pre = reviewed_pre_wto, reviewed_wto_post = reviewed_post_wto
  )
}
paired_summary <- function(data, poll, cohort) {
  purrr::map_dfr(c(
    "nafta", "old_composite", "reviewed_composite",
    "reviewed_wto"
  ), function(definition) {
    pre <- data[[paste0(definition, "_pre")]]
    post <- data[[paste0(definition, "_post")]]
    paired <- is.finite(pre) & is.finite(post)
    pre <- pre[paired]
    post <- post[paired]
    n <- length(pre)
    tibble::tibble(
      poll = poll, cohort = cohort, definition = definition, n = n,
      pre_mean = mean(pre), post_mean = mean(post), change = mean(post - pre),
      pre_se = stats::sd(pre) / sqrt(n),
      post_se = stats::sd(post) / sqrt(n),
      change_se = stats::sd(post - pre) / sqrt(n)
    )
  })
}
archive_scores <- components(archive, "BTP")
stopifnot(
  identical(
    is.na(archive_scores$old_composite_pre),
    is.na(archive$t1tradea)
  ),
  identical(
    is.na(archive_scores$old_composite_post),
    is.na(archive$t2tradea)
  ),
  all(archive_scores$old_composite_pre == archive$t1tradea,
    na.rm = TRUE
  ),
  all(archive_scores$old_composite_post == archive$t2tradea,
    na.rm = TRUE
  )
)
summary <- dplyr::bind_rows(
  paired_summary(components(nic, "NIC2"), "NIC2", "current casetype=1"),
  paired_summary(components(online, "BTP"), "BTP", "current 245 records"),
  paired_summary(
    archive_scores[archive$exp_cond %in% 1, ],
    "BTP", "archived exp_cond=1"
  )
)
reproduced <- dplyr::filter(
  summary, definition == "old_composite", cohort != "current 245 records"
)
expected <- matrix(c(
  .492, .478, -.014, .016, .014, .018,
  .348, .396, .047, .019, .019, .020
), nrow = 2, byrow = TRUE)
stopifnot(all(round(as.matrix(reproduced[, 5:10]), 3) == expected))
# The same archived composite also matches Table 2's online post-only row.
post_summary <- purrr::map_dfr(0:1, function(arm) {
  values <- archive_scores$old_composite_post[archive$exp_cond %in% arm]
  values <- values[is.finite(values)]
  tibble::tibble(
    arm = arm, n = length(values), mean = mean(values),
    se = stats::sd(values) / sqrt(length(values))
  )
})
stopifnot(
  all(round(post_summary$mean, 3) == c(.360, .393)),
  all(round(post_summary$se, 3) == c(.020, .018))
)
paper_sample <- archive$exp_cond %in% 1 &
  is.finite(archive_scores$old_composite_pre) &
  is.finite(archive_scores$old_composite_post)
cohort <- tibble::tibble(
  serial = as.numeric(archive$serial),
  archived_treatment = archive$exp_cond %in% 1,
  paper_paired_trade = paper_sample,
  current_source = archive$serial %in% online$serial,
  discussion_group_recorded = !is.na(archive$dpoll_no),
  post_completed = stats::complete.cases(archive[c(
    "f_dt_st", "f_tm_st", "f_dt_end", "f_tm_end", "f_durat"
  )]) & archive$f_durat > 0,
  meetings_attended = as.integer(archive$countmtg),
  authored_attend = as.integer(archive$attend)
)
group_cohort <- with(
  cohort,
  archived_treatment & discussion_group_recorded & post_completed
)
stopifnot(setequal(cohort$serial[group_cohort], online$serial))
meeting_counts <- dplyr::count(
  cohort, current_source, meetings_attended,
  authored_attend
)
readr::write_csv(meeting_counts, file.path(out, "meeting_counts.csv"))
readr::write_csv(summary, file.path(out, "comparison.csv"))
readr::write_csv(raw_checks, file.path(out, "raw_join_checks.csv"))
readr::write_csv(post_summary, file.path(out, "table2_comparison.csv"))
readr::write_csv(cohort, file.path(out, "cohort.csv"))
print(summary, n = Inf, width = Inf)
print(post_summary)
cat("All rounded published means, differences and SEs matched.\n")
print(cohort[cohort$paper_paired_trade & !cohort$current_source, ])
changes <- purrr::map_dfr(c("NIC2", "BTP"), function(poll) {
  data <- if (poll == "NIC2") nic else online
  values <- components(data, poll)
  purrr::map_dfr(c("pre", "post"), function(wave) {
    current <- values[[paste0("nafta_", wave)]]
    alternative <- values[[paste0("old_composite_", wave)]]
    tibble::tibble(
      poll = poll, wave = wave, people = nrow(data),
      changed_observed_values = sum(current != alternative, na.rm = TRUE),
      previously_missing_now_observed = sum(
        is.na(current) & !is.na(alternative)
      ),
      previously_observed_now_missing = sum(
        !is.na(current) & is.na(alternative)
      ),
      max_observed_change = max(abs(current - alternative), na.rm = TRUE)
    )
  })
})
readr::write_csv(changes, file.path(out, "definition_changes.csv"))

paths <- c(
  archive_path, master_path, "data/nic2-2003/survey.dta",
  "data/btp-national-2003/survey.dta", "data/shared/papers/foreign-policy.pdf"
)
hashes <- tibble::tibble(
  path = paths, bytes = as.numeric(file.info(project_path(paths))$size),
  sha256 = purrr::map_chr(project_path(paths), digest::digest,
    file = TRUE, algo = "sha256", serialize = FALSE
  )
)
readr::write_csv(hashes, file.path(out, "source_hashes.csv"))
