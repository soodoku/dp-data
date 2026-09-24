nic2_codes <- function(survey, field, allowed) {
  if (!field %in% names(survey)) stop("Missing source field: ", field)
  value <- as.numeric(unclass(survey[[field]]))
  if (field == "fp3a_s") allowed <- c(allowed, 97)
  if (any(!is.na(value) & !value %in% allowed)) {
    stop("Unreviewed source codes in ", field)
  }
  if (field == "fp3a_s") value[value %in% 97] <- NA_real_
  value
}

nic2_mean <- function(...) {
  value <- rowMeans(cbind(...), na.rm = TRUE)
  value[is.nan(value)] <- NA_real_
  as_historical_float(value)
}

nic2_attitudes <- function(survey, wave) {
  prefix <- if (wave == 1L) "" else "q"
  read <- function(stem, allowed) {
    nic2_codes(survey, paste0(prefix, stem), allowed)
  }
  ten <- function(stem) as_historical_float(read(stem, 0:10) / 10)
  ordered <- function(stem, scores) {
    value <- read(stem, seq_along(scores))
    as_historical_float(scores[value])
  }
  five <- function(stem) ordered(stem, c(1, .75, .5, .25, 0, NA))
  four <- function(stem) ordered(stem, c(1, 2 / 3, 1 / 3, 0, NA))
  paired <- function(stem) {
    side <- read(paste0(stem, "_a"), c(1, 3, 5, 7))
    strength <- read(paste0(stem, "_b"), c(1, 5))
    dplyr::case_when(
      side == 1 & strength == 1 ~ 1,
      side == 1 & strength == 5 ~ .75,
      side == 5 ~ .5,
      side == 3 & strength == 5 ~ .25,
      side == 3 & strength == 1 ~ 0,
      .default = NA_real_
    )
  }
  security_actions <- as_historical_float((
    ten("int1a_a") + ten("int1a_b") +
      ten("int1b_c") + ten("int1b_d")
  ) / 4)
  tibble::tibble(
    environment = nic2_mean(
      ten("fp2a_a"), ordered("wrm2a_s", c(1, 1, .5, 0, 0, NA)),
      ordered("wrm2b_s", c(1, 1, .5, 0, 0, NA)), ten("wrm3_a")
    ),
    security = nic2_mean(ten("fp2b_a"), ten("fp2b_c"), ten("fp2c_a"),
      ten("aid2a_b"), security_actions
    ),
    human_rights = ten("fp2c_b"),
    democracy = nic2_mean(paired("pair3"),
      nic2_mean(ten("pdem1_a"), ten("pdem1_b"), ten("pdem1_c"),
        ten("pdem2_a"), ten("pdem2_b"), ten("pdem2_c")
      ), ten("aid2a_c")
    ),
    multilateralism = nic2_mean(four("fp4b_b"), five("wrm4a_s"),
      (five("mact1_s") - five("mact4_s") + 1) / 2,
      (five("mact2_s") - five("mact5_s") + 1) / 2,
      ten("int1b_c"),
      ordered("int2a", c(0, 1 / 3, 2 / 3, 1, NA)),
      ordered("int2b", c(0, 1 / 3, 2 / 3, 1, NA)),
      ordered("trd1_a", c(.5, 1, 0))
    ),
    internationalism = ordered("fp3a_s", c(0, .25, .5, .75, 1, NA)),
    foreign_aid = ordered("aid1", c(1, NA, 0, NA, .5)),
    global_altruism = nic2_mean(ten("fp2b_d"), ten("fp2c_d"),
      nic2_mean(ten("aid2b_a"), ten("aid2b_b")),
      nic2_mean(four("fp4a_a"), ten("int1a_b")),
      paired("pair1"), paired("pair2")
    ),
    trade = ordered("trd2", c(0, NA, .5, NA, 1))
  )
}

nic2_knowledge_items <- function(survey, wave) {
  prefix <- if (wave == 1L) "" else "q"
  read <- function(stem, allowed) {
    nic2_codes(survey, paste0(prefix, stem), allowed)
  }
  democratic <- read("wrm3_b", 0:10)
  republican <- read("wrm3_c", 0:10)
  closed <- c(aid3 = 1, wrm5 = 3, kno1_a = 4, kno1_b = 1, kno2_a = 3,
    kno2_b = 4, kno3_a = 5, kno3_b = 1, wrm1_b = 1
  )
  items <- purrr::imap(closed, function(correct, stem) {
    as.numeric(read(stem, 1:7) %in% correct)
  })
  cbind(
    democratic = as.numeric(!is.na(democratic) & democratic > 5),
    republican = as.numeric(!is.na(republican) & republican < 5),
    as.matrix(tibble::as_tibble(items))
  )
}

build_nic2_individual <- function(survey = read_poll_survey("nic2-2003")) {
  before <- nic2_knowledge_items(survey, 1L)
  after <- nic2_knowledge_items(survey, 2L)
  baseline <- nic2_attitudes(survey, 1L)
  post <- nic2_attitudes(survey, 2L)
  read <- function(field, allowed) nic2_codes(survey, field, allowed)
  education <- read("educ_a", 0:18)
  diploma <- read("educ_b", c(1, 5))
  education <- dplyr::case_when(
    diploma == 1 ~ .66, education <= 8 ~ 0,
    education <= 11 ~ .33, education == 12 ~ .66,
    education >= 13 ~ 1, .default = NA_real_
  )
  income <- read("isum", 1:19)
  income_categories <- c(1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9,
    10, 11, 11
  )
  income <- income_categories[income]
  knowledge <- summarise_historical_knowledge(before, after)
  knowledge$knowledge_t1 <- as_historical_float(knowledge$knowledge_t1)
  knowledge$knowledge_t2 <- as_historical_float(knowledge$knowledge_t2)
  knowledge$knowledge_joint <- as_historical_float(knowledge$knowledge_joint)
  knowledge$knowledge_gain <- knowledge$knowledge_t2 - knowledge$knowledge_t1
  knowledge$knowledge_gain_joint <-
    knowledge$knowledge_t2 - knowledge$knowledge_joint
  knowledge$log_knowledge_joint <- historical_log_score(
    knowledge$knowledge_joint
  )
  dplyr::bind_cols(
    dplyr::rename_with(baseline, \(name) paste0(name, "_t1")),
    dplyr::rename_with(post, \(name) paste0(name, "_t2")), knowledge,
    tibble::tibble(
      knowledge_midterm = NA_real_, knowledge_midterm_joint = NA_real_,
      knowledge_joint_midterm = NA_real_, age = read("ppage", 0:110),
      female = as.numeric(read("sex", c(1, 5)) == 5),
      minority = as.numeric(read("race", 1:7) != 1),
      education_four = education,
      education_three = collapse_historical_education(education),
      higher_education = as.numeric(education == 1),
      household_income = income, high_income = as.numeric(income > 6),
      political_interest_t1 = as_historical_float(
        c(1, .66, .33, 0)[read("pint_b", 1:4)]
      ),
      read_briefing = (read("eval5", 1:5) - 1) / 4,
      attitude_extremity = as_historical_float(rowMeans(
        as.matrix(dplyr::mutate(baseline, dplyr::across(
          dplyr::everything(), \(value) as_historical_float(abs(value - .5))
        ))), na.rm = TRUE
      )), attitude_extremity_midterm = NA_real_
    )
  )
}

nic2_identity_bridge <- function(survey, historical) {
  fields <- c("pollgroup", "ppage", "qnews1_a", "qnews1_b", "qnews2_a",
    "qnews2_b", "eval7c", "eval7d"
  )
  selected <- survey[as.numeric(unclass(survey$casetype)) %in% 1, ]
  selected$pollgroup <- 9200 + as.numeric(unclass(selected$group))
  signature <- function(data) {
    stopifnot(all(fields %in% names(data)))
    parts <- lapply(data[fields], function(value) {
      value <- as.numeric(unclass(value))
      ifelse(is.na(value), "missing", as.character(value))
    })
    do.call(paste, c(parts, sep = "|"))
  }
  source_key <- signature(selected)
  historical_key <- signature(historical)
  stopifnot(!anyDuplicated(source_key), !anyDuplicated(historical_key),
    setequal(source_key, historical_key)
  )
  rows <- match(historical_key, source_key)
  tibble::tibble(
    nicid = as.numeric(unclass(selected$nicid))[rows],
    source_caseid = as.numeric(unclass(selected$caseid))[rows],
    historical_caseid = as.numeric(unclass(historical$caseid))
  )
}
