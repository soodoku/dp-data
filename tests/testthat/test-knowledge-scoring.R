source(project_path("R", "respondents.R"))

testthat::test_that("fixed batteries retain denominators and form status", {
  items <- rbind(c(1, NA, 0), c(NA, NA, NA), c(0, 0, 0), c(NA, NA, NA))
  observed <- c(TRUE, FALSE, TRUE, TRUE)
  testthat::expect_equal(score_knowledge(items, observed),
    c(1 / 3, NA, 0, 0)
  )
  testthat::expect_equal(score_knowledge(items), c(1 / 3, NA, 0, NA))
  scores <- summarise_historical_knowledge(items, items,
    before_observed = observed, after_observed = observed
  )
  testthat::expect_equal(scores$knowledge_t1, c(1 / 3, NA, 0, 0))
  testthat::expect_equal(scores$knowledge_t2, scores$knowledge_t1)
  testthat::expect_equal(scores$knowledge_joint, scores$knowledge_t1)
  testthat::expect_equal(scores$knowledge_gain, c(0, NA, 0, 0))
  before <- matrix(c(1, NA), nrow = 1)
  after <- matrix(c(NA, 1), nrow = 1)
  joint <- summarise_historical_knowledge(before, after)
  testthat::expect_equal(joint$knowledge_t1, .5)
  testthat::expect_equal(joint$knowledge_t2, .5)
  testthat::expect_equal(joint$knowledge_joint, 0)
  testthat::expect_equal(btp_float_knowledge(before, after), joint)
  testthat::expect_error(score_knowledge(items, rep(FALSE, 4)))
  testthat::expect_error(score_knowledge(matrix(2, 1, 1)))
})

testthat::test_that("reviewed invalid codes stay missing in item matrices", {
  specifications <- list(
    "new-haven-2004" = list(
      waves = c("pre", "mid", "post"), decoder = new_haven_knowledge_items,
      fields = function(wave) paste0(wave, "_q", c(35:37, 39:43)),
      invalid_counts = c(0L, 5L, 30L)
    ),
    "san-mateo-2008" = list(
      waves = 1:2, decoder = san_mateo_knowledge,
      fields = function(wave) paste0(if (wave == 2) "t2" else "", "Q", 19:26),
      invalid_counts = c(0L, 2L)
    ),
    "tomorrows-europe-2007" = list(
      waves = 1:3, decoder = tomorrow_knowledge_items,
      fields = function(wave) {
        if (wave == 1) {
          c(paste0("q", 16:24, "_1"), paste0("q33", c("a", "b"), "_1"))
        } else {
          c(paste0("t", wave, "q", 19:27),
            paste0("t", wave, "q36", c("a", "b")))
        }
      }, invalid_counts = c(0L, 12L, 2L)
    ),
    "zeguo-2005" = list(
      waves = c("pre", "post"), decoder = zeguo_knowledge_items,
      fields = function(wave) paste0(wave, "_d304", 3:6),
      invalid_counts = c(4L, 9L)
    )
  )
  for (poll in names(specifications)) {
    spec <- specifications[[poll]]
    raw <- read_poll_survey(poll)
    original <- raw
    for (i in seq_along(spec$waves)) {
      wave <- spec$waves[i]
      fields <- spec$fields(wave)
      items <- spec$decoder(raw, wave)
      invalid <- purrr::map(fields, function(field) {
        knowledge_invalid_codes(poll, field, raw[[field]])
      }) |> do.call(what = cbind)
      testthat::expect_equal(sum(invalid), spec$invalid_counts[i])
      testthat::expect_true(all(is.na(items[invalid])))
      testthat::expect_true(all(is.na(items) | items %in% 0:1))
    }
    testthat::expect_identical(raw, original)
  }
  raw <- read_poll_survey("new-haven-2004")
  post <- new_haven_knowledge_items(raw, "post")
  observed <- new_haven_departure_observed(raw)
  invalid_only <- rowSums(!is.na(post)) == 0L & observed %in% TRUE
  testthat::expect_equal(which(invalid_only), c(82L, 84L))
  testthat::expect_equal(build_new_haven_individual(raw)$knowledge_t2[
    invalid_only
  ], c(0, 0))
  absent <- raw$assigned == 3124
  testthat::expect_true(all(is.na(post[absent, ])))
  testthat::expect_true(is.na(build_new_haven_individual(raw)$knowledge_t2[
    absent
  ]))
  raw <- read_poll_survey("zeguo-2005")
  path <- project_path("data", "zeguo-2005", "source-materials",
    "knowledge-reconciliation.csv"
  )
  ledger <- readr::read_csv(path, show_col_types = FALSE)
  items <- zeguo_knowledge_items(raw, "post")
  positions <- cbind(
    match(ledger$p, raw$p), match(ledger$item, colnames(items))
  )
  restored <- items[positions]
  testthat::expect_equal(restored, ledger$historical_score)
})
