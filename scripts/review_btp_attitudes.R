# Independently reconstruct all BTP 2004/2005 attitude indices.
source("R/paths.R")
for (f in setdiff(
  list.files("R",
    full.names = TRUE,
    pattern = "\\.R$"
  ),
  "R/paths.R"
)) {
  source(f)
}
h <- read_poll_survey("btp-health-education-2005")
g <- read_poll_survey("btp-general-election-2004")
graw <- haven::read_dta("data/btp-general-election-2004/raw-responses.dta")
g <- augment_btp_general_source(g, graw)
full_health <- arrow::read_parquet(project_path(
  "data", "btp-health-education-2005", "source-responses.parquet"
))
selected <- full_health[full_health$filter %in% 1, ]
stopifnot(
  nrow(full_health) == 3298L, nrow(selected) == 454L,
  !anyDuplicated(selected$caseid)
)
position <- match(h$caseid_original, selected$caseid)
stopifnot(!anyNA(position))
stopifnot(
  nrow(h) == 454L, nrow(g) == 299L,
  !anyDuplicated(h$caseid_original), !anyDuplicated(g$caseid_original)
)
for (wave in c("b", "f")) {
  absent <- !btp_general_wave_present(g, wave)
  stopifnot(all(is.na(as.matrix(btp_general_attitudes(g, wave)[absent, ]))))
}
out <- project_path("audit", "btp-attitudes")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
f32 <- function(x) {
  readBin(
    writeBin(as.double(x),
      raw(),
      size = 4
    ),
    what = "double",
    n = length(x),
    size = 4
  )
}
spec <- list(
  reform = c(q3 = "reverse_binary"),
  school_choice = c(
    q7_a = "ten",
    q7_b = "ten"
  ),
  school_funding = c(
    q7_c = "ten",
    q7_d = "ten",
    q7_e = "ten",
    q7_f = "ten",
    q8_f = "ten"
  ),
  standardized_testing = c(
    q4 = "reverse_three",
    q5 = "ten"
  ),
  local_testing = c(q6 = "binary"),
  no_child_left_behind = c(q12 = "reverse_five"),
  government_involvement = c(
    q24a = "five",
    q24f = "five"
  ),
  medical_quality = c(
    q19_d = "ten",
    q19_e = "ten",
    q19_f = "ten"
  ),
  cost_coverage = c(
    q19_a = "ten",
    q19_b = "ten",
    q19_c = "ten",
    q23 = "cost"
  ),
  employer_payment = c(q24b = "five"),
  individual_payment = c(q24c = "five")
)
post <- c(
  q3 = "q3post",
  q7_a = "q7post_a",
  q7_b = "q7post_b",
  q7_c = "q7post_c",
  q7_d = "q7post_d",
  q7_e = "q7post_e",
  q7_f = "q7post_f",
  q8_f = "q8post_f",
  q4 = "q4post",
  q5 = "q5post_m",
  q6 = "q6post",
  q12 = "q12post",
  q24a = "q24apost",
  q24f = "q24fpost",
  q19_d = "q19pos_c",
  q19_e = "q19pos_d",
  q19_f = "q19pos_e",
  q19_a = "q19post",
  q19_b = "q19pos_a",
  q19_c = "q19pos_b",
  q23 = "q23post",
  q24b = "q24bpost",
  q24c = "q24cpost"
)
old <- c(
  reform = "reform",
  school_choice = "fcvsch",
  school_funding = "mmtaxe",
  standardized_testing = "stest",
  local_testing = "testsl",
  no_child_left_behind = "nclb",
  government_involvement = "govinv",
  medical_quality = "medqual",
  cost_coverage = "costcov",
  employer_payment = "emplypay",
  individual_payment = "indivpay"
)
ind <- function(v, rule) {
  v <- as.numeric(v)
  lim <- switch(rule,
    ten = 0:10,
    binary = 1:2,
    reverse_binary = 1:2,
    reverse_three = 1:3,
    cost = 1:3,
    five = 1:5,
    reverse_five = 1:5
  )
  v[!v %in% lim] <- NA
  f32(switch(rule,
    ten = v / 10,
    binary = v - 1,
    reverse_binary = 2 - v,
    reverse_three = (3 - v) / 2,
    cost = c(.5, 1, 0)[v],
    five = (v - 1) / 4,
    reverse_five = (5 - v) / 4
  ))
}
summary <- list()
denominators <- list()
freq <- list()
alternatives <- list()
for (wave in 1:2) {
  current <- btp_health_attitudes(h, wave)
  for (nm in names(spec)) {
    fields <- names(spec[[nm]])
    if (wave == 2) fields <- unname(post[fields])
    stopifnot(all(vapply(fields, function(field) {
      identical(as.numeric(h[[field]]), selected[[field]][position])
    }, logical(1))))
    components <- sapply(
      seq_along(fields),
      function(j) {
        ind(
          h[[fields[j]]],
          spec[[nm]][j]
        )
      }
    )
    if (is.null(dim(components))) components <- matrix(components, ncol = 1)
    count <- rowSums(!is.na(components))
    calc <- rowMeans(components, na.rm = TRUE)
    if (nm %in% c(
      "government_involvement",
      "medical_quality",
      "cost_coverage"
    )) {
      z <- components
      z[is.na(z)] <- 0
      total <- rep(0, nrow(z))
      for (j in seq_len(ncol(z))) total <- f32(total + z[, j])
      calc <- total / count
    }
    calc <- f32(calc)
    calc[is.nan(calc)] <- NA
    observed <- current[[nm]]
    hist <- h[[paste0("t", wave, old[nm])]]
    stopifnot(
      identical(
        is.na(calc),
        is.na(observed)
      ),
      max(abs(calc - observed),
        na.rm = TRUE
      ) == 0
    )
    summary[[length(summary) + 1]] <- data.frame(
      poll = "btp-health-education-2005",
      index = nm,
      wave = wave,
      n = length(calc),
      observed = sum(!is.na(calc)),
      missing = sum(is.na(calc)),
      partial = sum(count > 0 & count < ncol(components)),
      min = min(calc,
        na.rm = TRUE
      ),
      max = max(calc,
        na.rm = TRUE
      ),
      mean = mean(calc,
        na.rm = TRUE
      ),
      current_maxdiff = max(abs(calc - observed),
        na.rm = TRUE
      ),
      historical_maxdiff = max(abs(calc - as.numeric(hist)),
        na.rm = TRUE
      ),
      historical_missing_disagree = sum(is.na(calc) != is.na(hist))
    )
    denominators[[length(denominators) + 1]] <- data.frame(
      poll = "btp-health-education-2005",
      index = nm,
      wave = wave,
      observed_components = as.numeric(names(table(count))),
      people = as.numeric(table(count))
    )
    for (j in seq_along(fields)) {
      vv <- h[[fields[j]]]
      tt <- table(as.numeric(vv), useNA = "always")
      freq[[length(freq) + 1]] <- data.frame(
        poll = "btp-health-education-2005",
        index = nm,
        wave = wave,
        field = fields[j],
        rule = unname(spec[[nm]][j]),
        code = names(tt),
        count = as.numeric(tt)
      )
    }
    if (nm == "school_funding") {
      alt <- f32(rowMeans(components[, 1:4], na.rm = TRUE))
      alt[is.nan(alt)] <- NA
      alternatives[[length(alternatives) + 1]] <- data.frame(
        index = nm,
        wave = wave,
        current_mean = mean(calc,
          na.rm = TRUE
        ),
        alternative_mean = mean(alt,
          na.rm = TRUE
        ),
        changed = sum(abs(calc - alt) > 1e-7,
          na.rm = TRUE
        ),
        new_missing = sum(!is.na(calc) & is.na(alt)),
        alternative = paste(
          "omit Q8f importance item",
          "(different construct, not demonstrated correction)"
        )
      )
    }
  }
}
items <- c(
  services = 42,
  military = 45,
  trade = 48,
  rights = 51,
  health_insurance = 54,
  marriage = 57
)
for (wave in c("b", "f")) {
  current <- btp_general_attitudes(g, wave)
  for (nm in names(items)) {
    field <- paste0("raw_w4", wave, items[nm])
    v <- as.numeric(g[[field]])
    v[!v %in% 1:7] <- NA
    calc <- f32(round((v - 1) / 6, 5))
    observed <- current[[nm]]
    hist <- g[[paste0("w4", wave, items[nm])]]
    stopifnot(
      identical(
        is.na(calc),
        is.na(observed)
      ),
      max(abs(calc - observed),
        na.rm = TRUE
      ) == 0
    )
    summary[[length(summary) + 1]] <- data.frame(
      poll = "btp-general-election-2004",
      index = nm,
      wave = ifelse(wave == "b",
        1,
        2
      ),
      n = length(calc),
      observed = sum(!is.na(calc)),
      missing = sum(is.na(calc)),
      partial = 0,
      min = min(calc,
        na.rm = TRUE
      ),
      max = max(calc,
        na.rm = TRUE
      ),
      mean = mean(calc,
        na.rm = TRUE
      ),
      current_maxdiff = max(abs(calc - observed),
        na.rm = TRUE
      ),
      historical_maxdiff = max(abs(calc - as.numeric(hist)),
        na.rm = TRUE
      ),
      historical_missing_disagree = sum(is.na(calc) != is.na(hist))
    )
    tt <- table(as.numeric(g[[field]]), useNA = "always")
    freq[[length(freq) + 1]] <- data.frame(
      poll = "btp-general-election-2004",
      index = nm,
      wave = wave,
      field = field,
      rule = "1:7 rescale round5 float32",
      code = names(tt),
      count = as.numeric(tt)
    )
  }
}
write.csv(
  do.call(
    rbind,
    summary
  ),
  file.path(
    out,
    "index_summary.csv"
  ),
  row.names = FALSE
)
write.csv(
  do.call(
    rbind,
    denominators
  ),
  file.path(
    out,
    "component_denominators.csv"
  ),
  row.names = FALSE
)
write.csv(
  do.call(
    rbind,
    freq
  ),
  file.path(
    out,
    "response_frequencies.csv"
  ),
  row.names = FALSE
)
write.csv(
  do.call(
    rbind,
    alternatives
  ),
  file.path(
    out,
    "authored_definition_alternatives.csv"
  ),
  row.names = FALSE
)
checks <- list(
  local_control = list(
    pre = "q6",
    post = "q6post",
    codes = 2,
    report = c(
      31,
      38
    )
  ),
  state_control = list(
    pre = "q6",
    post = "q6post",
    codes = 1,
    report = c(
      62,
      56
    )
  ),
  too_much_testing = list(
    pre = "q4",
    post = "q4post",
    codes = 3,
    report = c(
      58,
      65
    )
  ),
  not_enough_testing = list(
    pre = "q4",
    post = "q4post",
    codes = 1,
    report = c(
      14,
      9
    )
  ),
  approve_nclb = list(
    pre = "q12",
    post = "q12post",
    codes = 4:5,
    report = c(
      39,
      31
    )
  ),
  disapprove_nclb = list(
    pre = "q12",
    post = "q12post",
    codes = 1:2,
    report = c(
      53,
      59
    )
  ),
  oppose_vouchers = list(
    pre = "q7_b",
    post = "q7post_b",
    codes = 0:4,
    report = c(
      56,
      61
    )
  ),
  willing_pay = list(
    pre = "q23",
    post = "q23post",
    codes = 1:2,
    report = c(
      52,
      62
    )
  ),
  single_payer = list(
    pre = "q24a",
    post = "q24apost",
    codes = 4:5,
    report = c(
      51,
      57
    )
  ),
  employer = list(
    pre = "q24b",
    post = "q24bpost",
    codes = 4:5,
    report = c(
      51,
      44
    )
  ),
  individual = list(
    pre = "q24c",
    post = "q24cpost",
    codes = 4:5,
    report = c(
      37,
      43
    )
  ),
  medicare = list(
    pre = "q24f",
    post = "q24fpost",
    codes = 4:5,
    report = c(
      58,
      59
    )
  )
)
rpt <- list()
for (nm in names(checks)) {
  for (w in 1:2) {
    for (sel in c("all454", "selected_at_least_three", "full_at_least_three")) {
      z <- checks[[nm]]
      survey <- if (sel == "full_at_least_three") full_health else h
      keep <- if (sel == "all454") {
        rep(TRUE, nrow(survey))
      } else {
        !is.na(survey$stotal) & survey$stotal >= 3
      }
      v <- survey[[z[[if (w == 1) "pre" else "post"]]]][keep]
      rpt[[length(rpt) + 1]] <- data.frame(
        item = nm,
        wave = w,
        sample = sel,
        n = length(v),
        report_percent = z$report[w],
        actual_percent = 100 * mean(v %in% z$codes),
        observed_percent = 100 * sum(v %in% z$codes) / sum(!is.na(v)),
        missing = sum(is.na(v))
      )
    }
  }
}
write.csv(
  do.call(
    rbind,
    rpt
  ),
  file.path(
    out,
    "report_comparison.csv"
  ),
  row.names = FALSE
)

# The accompanying Europolis labels are checked without changing orientation.
eu <- read_poll_survey("europolis-2009")
eu_current <- build_europolis_individual(eu)
eu_selected <- eu$GROUP_T1BIS %in% 1
eu_rows <- list()
for (index in c("climate", "immigration")) {
  for (wave in c(1, 3)) {
    field <- paste0("V", wave, if (index == "climate") "Q21" else "Q11_1")
    raw_value <- as.numeric(eu[[field]])
    raw_value[raw_value %in% 997:999] <- NA_real_
    calculated <- if (index == "climate") {
      (10 - raw_value) / 10
    } else {
      (raw_value - 1) / 4
    }
    name <- paste0(index, "_t", if (wave == 1) 1 else 2)
    stopifnot(identical(calculated, eu_current[[name]]))
    for (scope in c("respondent", "aggregate")) {
      keep <- if (scope == "respondent") rep(TRUE, nrow(eu)) else eu_selected
      eu_rows[[length(eu_rows) + 1L]] <- data.frame(
        field, index, scope,
        n = sum(keep), differences = 0L,
        n_missing = sum(is.na(calculated[keep])),
        mean = mean(calculated[keep], na.rm = TRUE)
      )
    }
  }
}
extremity <- rowMeans(abs(cbind(
  eu_current$climate_t1, eu_current$immigration_t1
) - .5), na.rm = TRUE)
extremity[is.nan(extremity)] <- NA_real_
stopifnot(identical(extremity, eu_current$attitude_extremity))
eu_rows[[length(eu_rows) + 1L]] <- data.frame(
  field = "Q21+Q11_1", index = "attitude_extremity", scope = "aggregate",
  n = sum(eu_selected), differences = 0L,
  n_missing = sum(is.na(extremity[eu_selected])),
  mean = mean(extremity[eu_selected], na.rm = TRUE)
)
write.csv(do.call(rbind, eu_rows),
  file.path(out, "europolis_index_checks.csv"),
  row.names = FALSE
)

report_cohort <- !is.na(full_health$stotal) & full_health$stotal >= 3
selected_cohort <- full_health$filter %in% 1
outside_selected <- report_cohort & !selected_cohort
stopifnot(
  sum(report_cohort) == 360L, sum(outside_selected) == 39L,
  all(is.na(full_health$groupnum[outside_selected]))
)
calibration <- arrow::read_parquet(project_path(
  "data", "btp-health-education-2005", "calibration-responses.parquet"
))
stopifnot(identical(calibration, full_health[names(calibration)]))
write.csv(data.frame(
  sample = c(
    "complete_source", "selected", "at_least_three_sessions",
    "selected_at_least_three", "three_sessions_outside_selected"
  ),
  n = c(
    nrow(full_health), nrow(h), sum(report_cohort),
    sum(report_cohort & selected_cohort), sum(outside_selected)
  ),
  missing_group = c(
    sum(is.na(full_health$groupnum)),
    sum(is.na(h$groupnum)), sum(is.na(full_health$groupnum[report_cohort])),
    sum(is.na(full_health$groupnum[report_cohort & selected_cohort])),
    sum(is.na(full_health$groupnum[outside_selected]))
  )
), file.path(out, "sample_summary.csv"), row.names = FALSE)
