# Reconstruct NIC2/BTP attitude indices and compare authored variants.
# Run from the repository root. Outputs are review evidence only.
source("R/paths.R")
load_project()
output <- file.path("audit", "foreign-policy-attitudes")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
f32 <- function(x) {
  binary <- writeBin(as.numeric(x), base::raw(), size = 4)
  readBin(binary, "double", length(x), size = 4)
}
avg <- function(...) {
  z <- rowMeans(cbind(...), na.rm = TRUE)
  z[is.nan(z)] <- NA_real_
  f32(z)
}
results <- list()
denominators <- list()
alternatives <- list()
for (poll in c("nic2-2003", "btp-national-2003")) {
  s <- read_poll_survey(poll)
  if (poll == "nic2-2003") {
    s <- s[s$casetype %in% 1, ]
  }
  stopifnot(nrow(s) == if (poll == "nic2-2003") {
    340L
  } else {
    245L
  })
  id <- if (poll == "nic2-2003") {
    s$nicid
  } else {
    s$serial
  }
  stopifnot(!anyDuplicated(id))
  for (w in 1:2) {
    nic <- poll == "nic2-2003"
    prefix <- if (nic) {
      if (w == 1) {
        ""
      } else {
        "q"
      }
    } else if (w == 1) {
      "qb"
    } else {
      "qf"
    }
    field <- function(n) as.numeric(s[[paste0(prefix, n)]])
    code <- function(n, values) {
      f32(values[match(
        field(n),
        seq_along(values)
      )])
    }
    ten <- function(n) {
      z <- field(n)
      z[!z %in% 0:10] <- NA_real_
      f32(z / 10)
    }
    five <- function(n) code(n, c(1, 0.75, 0.5, 0.25, 0))
    four <- function(n) code(n, c(1, 2 / 3, 1 / 3, 0))
    support <- function(n) code(n, c(1, 0, 0.5))
    pair <- function(n) {
      a <- field(paste0(n, "_a"))
      b <- field(paste0(n, "_b"))
      z <- rep(NA_real_, nrow(s))
      z[a %in% 5] <- 0.5
      z[a %in% 1 & b %in% 1] <- 1
      z[a %in% 1 & b %in% 5] <- 0.75
      z[a %in% 3 & b %in% 1] <- 0
      z[a %in% 3 & b %in% 5] <- 0.25
      z
    }
    if (nic) {
      env <- cbind(ten("fp2a_a"), code("wrm2a_s", c(
        1,
        1, 0.5, 0, 0
      )), code("wrm2b_s", c(
        1, 1, 0.5,
        0, 0
      )), ten("wrm3_a"))
      actions <- cbind(
        ten("int1a_a"), ten("int1a_b"),
        ten("int1b_c"), ten("int1b_d")
      )
      sec <- cbind(
        ten("fp2b_a"), ten("fp2b_c"), ten("fp2c_a"),
        ten("aid2a_b"), f32(rowMeans(actions))
      )
      demo_actions <- cbind(
        ten("pdem1_a"), ten("pdem1_b"),
        ten("pdem1_c"), ten("pdem2_a"), ten("pdem2_b"),
        ten("pdem2_c")
      )
      demo <- cbind(pair("pair3"), avg(demo_actions), ten("aid2a_c"))
      multi <- cbind(
        four("fp4b_b"), five("wrm4a_s"),
        (five("mact1_s") - five("mact4_s") + 1) / 2,
        (five("mact2_s") - five("mact5_s") + 1) / 2,
        ten("int1b_c"), code("int2a", c(0, 1 / 3, 2 / 3, 1)),
        code("int2b", c(0, 1 / 3, 2 / 3, 1)),
        code("trd1_a", c(0.5, 1, 0))
      )
      poverty <- cbind(
        ten("fp2b_d"), ten("fp2c_d"), avg(
          ten("aid2b_a"),
          ten("aid2b_b")
        ), avg(four("fp4a_a"), ten("int1a_b")),
        pair("pair1"), pair("pair2")
      )
      frames <- list(
        environment = env, security = sec,
        human_rights = matrix(ten("fp2c_b")), democracy = demo,
        multilateralism = multi, internationalism = matrix(code(
          "fp3a_s",
          c(0, 0.25, 0.5, 0.75, 1)
        )), foreign_aid = matrix(code(
          "aid1",
          c(1, NA, 0, NA, 0.5)
        )), global_altruism = poverty,
        trade = matrix(code("trd2", c(
          0, NA, 0.5, NA,
          1
        )))
      )
      source_names <- c(
        environment = "envir", security = "usseca",
        human_rights = "humrh2", democracy = "demo",
        multilateralism = "multi", internationalism = "inter",
        foreign_aid = "forai1", global_altruism = "global",
        trade = "trade_b"
      )
      built <- nic2_attitudes(s, w)
    } else {
      env <- cbind(
        ten("2a"), support("13"), support("14"),
        ten("15a")
      )
      actions <- cbind(
        ten("37a"), ten("37b"), ten("37e"),
        ten("37f")
      )
      sec <- cbind(
        ten("2c"), ten("2e"), ten("2g"), ten("25b"),
        avg(actions)
      )
      demo_actions <- sapply(
        paste0("23", letters[1:6]),
        ten
      )
      demo <- cbind(support("22"), avg(demo_actions), ten("25c"))
      multi <- cbind(
        four("10"), five("16"),
        f32((five("27") - five("30") + 1) / 2),
        f32((five("28") - five("31") + 1) / 2), ten("37e"),
        code("38", c(0, 1 / 3, 2 / 3, 1)),
        code("39", c(0, 1 / 3, 2 / 3, 1)), code("32a", c(0.5, 1, 0))
      )
      poverty <- cbind(
        ten("2f"), ten("2j"), avg(
          ten("25d"),
          ten("25e")
        ), avg(four("7"), ten("37b")), support("20"),
        support("21")
      )
      frames <- list(
        environment = env, security = sec,
        human_rights = matrix(ten("2h")), democracy = demo,
        multilateralism = multi, internationalism = matrix(code(
          "3",
          c(0, 0.25, 0.5, 0.75, 1)
        )), foreign_aid = matrix(support("24")),
        global_altruism = poverty, trade = matrix(code(
          "33",
          c(0, 0.5, 1)
        ))
      )
      source_names <- c(
        environment = "envir", security = "usseca",
        human_rights = "humrh2", democracy = "demo",
        multilateralism = "multi", internationalism = "inter",
        foreign_aid = "forai1", global_altruism = "global",
        trade = "trade"
      )
      built <- btp_national_attitudes(s, w)
    }
    for (n in names(frames)) {
      independent <- avg(frames[[n]])
      stopifnot(
        identical(is.na(independent), is.na(built[[n]])),
        max(abs(independent - built[[n]]), na.rm = TRUE) <
          1e-07
      )
      srcfield <- paste0("t", w, source_names[n])
      old <- if (srcfield %in% names(s)) {
        as.numeric(s[[srcfield]])
      } else {
        rep(NA_real_, nrow(s))
      }
      results[[length(results) + 1]] <- data.frame(
        poll, wave = w, index = n, people = nrow(s),
        missing = sum(is.na(independent)),
        mean = mean(independent, na.rm = TRUE),
        min = min(independent, na.rm = TRUE),
        max = max(independent, na.rm = TRUE),
        max_independent_difference = max(
          abs(independent - built[[n]]), na.rm = TRUE
        ),
        source_field = srcfield, source_missing = sum(is.na(old)),
        source_changed = sum(abs(old - independent) > 1e-7, na.rm = TRUE),
        source_mean = mean(old, na.rm = TRUE)
      )
      denominators[[length(denominators) + 1]] <- data.frame(
        poll, wave = w, index = n, id,
        observed_components = rowSums(!is.na(frames[[n]])),
        total_components = ncol(frames[[n]]), current = independent
      )
    }
    variants <- list(
      environment_preaverage = avg(
        env[, 1],
        avg(env[, 2:3]), env[, 4]
      ), environment_memo_three = avg(env[
        ,
        1:3
      ]), security_available = avg(sec[, 1:4], avg(actions)),
      security_all_questions = avg(sec[, 1:4], actions),
      democracy_all_questions = avg(
        demo[, 1], demo_actions,
        demo[, 3]
      ), poverty_memo_v1 = avg(
        poverty[, 1:3],
        avg(poverty[, 5:6]), if (nic) four("fp4a_a") else four("7"),
        if (nic) ten("int1a_b") else ten("37b")
      ), poverty_paper = avg(poverty[
        ,
        1:3
      ], avg(poverty[, 5:6]))
    )
    for (n in names(variants)) {
      ref <- built[[switch(sub("_.*", "", n),
        environment = "environment",
        security = "security",
        democracy = "democracy",
        poverty = "global_altruism"
      )]]
      prop <- variants[[n]]
      alternatives[[length(alternatives) + 1]] <- data.frame(poll,
        wave = w, variant = n, id, current = ref, alternative = prop,
        delta = prop - ref, missing_changed = xor(
          is.na(ref),
          is.na(prop)
        )
      )
    }
  }
}
index_summary <- do.call(rbind, results)
denominator_rows <- do.call(rbind, denominators)
variant_rows <- do.call(rbind, alternatives)
denominator_summary <- denominator_rows |>
  dplyr::group_by(poll, wave, index) |>
  dplyr::summarise(
    partial = sum(
      observed_components > 0 & observed_components < total_components
    ),
    all_missing = sum(observed_components == 0), .groups = "drop"
  )
variant_summary <- dplyr::summarise(
  dplyr::group_by(
    variant_rows,
    poll, wave, variant
  ),
  changed = sum(abs(delta) > 1e-07, na.rm = TRUE),
  missing_changed = sum(missing_changed), current_mean = mean(current,
    na.rm = TRUE
  ), alternative_mean = mean(alternative, na.rm = TRUE),
  maximum_difference = max(abs(delta), na.rm = TRUE), .groups = "drop"
)
security <- subset(
  variant_rows,
  poll == "nic2-2003" & variant == "security_available" & abs(delta) > 1e-7
)
survey <- read_poll_survey("nic2-2003")
security <- do.call(rbind, lapply(seq_len(nrow(security)), function(i) {
  row <- security[i, ]
  prefix <- if (row$wave == 1) {
    ""
  } else {
    "q"
  }
  fields <- paste0(prefix, c(
    "int1a_a", "int1a_b", "int1b_c",
    "int1b_d"
  ))
  raw <- as.data.frame(survey[survey$nicid %in% row$id, fields])
  names(raw) <- c("democracy", "aid", "cooperation", "intelligence")
  cbind(row, raw)
}))
stopifnot(nrow(security) == 15L, !any(security$missing_changed))
paired_summary <- dplyr::summarise(
  dplyr::group_by(
    dplyr::filter(tidyr::pivot_wider(
      dplyr::select(
        denominator_rows,
        poll, wave, index, id, current
      ),
      names_from = wave, values_from = current,
      names_prefix = "wave_"
    ), !is.na(wave_1), !is.na(wave_2)),
    poll, index
  ),
  people = dplyr::n(), baseline_mean = mean(wave_1),
  exit_mean = mean(wave_2), .groups = "drop"
)
outputs <- list(
  index_summary = index_summary, denominator_summary = denominator_summary,
  variant_summary = variant_summary, nic2_security_alternative = security,
  paired_summary = paired_summary
)
for (name in names(outputs)) {
  readr::write_csv(outputs[[name]], file.path(output, paste0(
    name,
    ".csv"
  )))
}
message("All 36 index-wave comparisons match production within 1e-7.")
