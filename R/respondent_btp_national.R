btp_national_item <- function(survey, field, rule = "ten") {
  allowed <- switch(rule,
    ten = -2:10,
    agree_five = c(-2:-1, 1:6),
    reverse_five = c(-2:-1, 1:6),
    support = c(-2:-1, 1:4),
    importance = c(-2:-1, 1:5),
    leadership = c(-2:-1, 1:6),
    trade_organization = c(-2:-1, 1:4),
    trade = c(-2:-1, 1:4)
  )
  value <- btp_source_codes(survey, field, allowed)
  value[value < 0 & !is.na(value)] <- NA_real_
  result <- switch(rule,
    ten = value / 10,
    agree_five = c(1, .75, .5, .25, 0, NA_real_)[value],
    reverse_five = c(0, .25, .5, .75, 1, NA_real_)[value],
    support = c(1, 0, .5, NA_real_)[value],
    importance = c(1, 2 / 3, 1 / 3, 0, NA_real_)[value],
    leadership = c(0, 1 / 3, 2 / 3, 1, NA_real_, NA_real_)[value],
    trade_organization = c(.5, 1, 0, NA_real_)[value],
    trade = c(0, .5, 1, NA_real_)[value]
  )
  as_historical_float(result)
}

btp_national_attitudes <- function(survey, wave) {
  item <- function(stem, rule = "ten") {
    btp_national_item(
      survey, paste0(if (wave == 1L) "qb" else "qf", stem),
      rule
    )
  }
  mean_items <- function(...) btp_health_mean(...)
  security_group <- mean_items(
    item("37a"), item("37b"), item("37e"),
    item("37f")
  )
  military_difference <- function(first, second) {
    difference <- item(first, "agree_five") - item(second, "agree_five")
    as_historical_float((difference + 1) / 2)
  }
  poverty_aid <- mean_items(item("25d"), item("25e"))
  poverty_building <- mean_items(item("7", "importance"), item("37b"))
  democracy_group <- mean_items(
    item("23a"), item("23b"), item("23c"),
    item("23d"), item("23e"), item("23f")
  )
  tibble::tibble(
    security = mean_items(
      item("2c"), item("2e"), item("2g"), item("25b"),
      security_group
    ),
    human_rights = item("2h"),
    environment = mean_items(
      item("2a"), item("13", "support"),
      item("14", "support"), item("15a")
    ),
    internationalism = item("3", "reverse_five"),
    multilateralism = mean_items(
      item("10", "importance"),
      item("16", "agree_five"), military_difference("27", "30"),
      military_difference("28", "31"), item("37e"), item("38", "leadership"),
      item("39", "leadership"), item("32a", "trade_organization")
    ),
    democracy = mean_items(
      item("22", "support"), democracy_group, item("25c")
    ),
    foreign_aid = item("24", "support"),
    global_altruism = mean_items(
      item("2f"), item("2j"), poverty_aid,
      poverty_building, item("20", "support"), item("21", "support")
    ),
    trade = item("33", "trade")
  )
}

btp_national_knowledge <- function(survey, wave) {
  prefix <- if (wave == 1L) "qb" else "qf"
  keys <- c(
    `26` = 1, `18` = 2, `40` = 4, `41` = 1, `42` = 3,
    `43` = 4, `44` = 2, `45` = 1, `12` = 1
  )
  factual <- purrr::imap(keys, function(correct, item) {
    value <- btp_source_codes(survey, paste0(prefix, item), -2:6)
    as.numeric(value %in% correct)
  })
  democratic <- btp_source_codes(survey, paste0(prefix, "15b"), -2:10)
  republican <- btp_source_codes(survey, paste0(prefix, "15c"), -2:10)
  tibble::as_tibble(c(list(
    democratic = as.numeric(democratic %in% 6:10),
    republican = as.numeric(republican %in% 0:4)
  ), factual)) |> as.matrix()
}

build_btp_national_individual <- function(
  survey = read_poll_survey("btp-national-2003")
) {
  before <- btp_national_attitudes(survey, 1L)
  after <- btp_national_attitudes(survey, 2L)
  education <- c(0, .33, .66, 1)[btp_source_codes(survey, "ppeducat", 1:4)]
  income <- btp_source_codes(survey, "ppincimp", 1:17)
  income <- c(1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 5:9, 10, 10)[income]
  interest <- btp_source_codes(survey, "qb57", c(-2:-1, 1:4))
  interest[interest < 0 & !is.na(interest)] <- NA_real_
  deviations <- purrr::map_dfc(before, function(value) {
    as_historical_float(abs(value - .5))
  })
  extremity <- as_historical_float(
    rowMeans(as.matrix(deviations), na.rm = TRUE)
  )
  extremity[is.nan(extremity)] <- NA_real_
  dplyr::bind_cols(
    dplyr::rename_with(before, \(name) paste0(name, "_t1")),
    dplyr::rename_with(after, \(name) paste0(name, "_t2")),
    btp_float_knowledge(
      btp_national_knowledge(survey, 1L),
      btp_national_knowledge(survey, 2L)
    ),
    tibble::tibble(
      age = btp_source_codes(survey, "ppage", 18:100),
      female = as.numeric(btp_source_codes(survey, "ppgender", 1:2) == 2),
      minority = as.numeric(btp_source_codes(survey, "ppeth", 1:4) != 1),
      education_four = education,
      education_three = collapse_historical_education(education),
      higher_education = as.numeric(education >= .66),
      household_income = income, high_income = as.numeric(income > 5),
      attitude_extremity = extremity,
      political_interest_t1 = as_historical_float(
        c(1, .66, .33, 0)[interest]
      ),
      read_briefing = NA_real_, knowledge_joint_midterm = NA_real_,
      knowledge_midterm = NA_real_, knowledge_midterm_joint = NA_real_,
      attitude_extremity_midterm = NA_real_
    )
  )
}
