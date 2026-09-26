historical_item_matrices <- function(poll_id, survey) {
  item_function <- switch(poll_id,
    "australia-republic-1999" = australia_knowledge_items,
    "btp-general-election-2004" = function(x, wave) {
      btp_general_knowledge(x, if (wave == 1L) "b" else "f")
    },
    "btp-health-education-2005" = btp_health_knowledge,
    "btp-national-2003" = btp_national_knowledge,
    "btp-presidential-primaries-2004" = function(x, wave) {
      primaries_knowledge_items(x, if (wave == 1L) "b1" else "f1")
    },
    "bulgaria-crime-2002" = bulgaria_knowledge_items,
    "cpl-1996" = function(x, wave) utility_knowledge_items(x, poll_id, wave),
    "europolis-2009" = function(x, wave) {
      europolis_knowledge_items(x, if (wave == 1L) 1L else 3L)
    },
    "new-haven-2004" = function(x, wave) {
      new_haven_knowledge_items(x, if (wave == 1L) "pre" else "post")
    },
    "nic-1996" = function(x, wave) {
      nic_knowledge_items(x, if (wave == 1L) 1L else 3L)
    },
    "nic2-2003" = nic2_knowledge_items,
    "san-mateo-2008" = san_mateo_knowledge,
    "swepco-1996" = function(x, wave) utility_knowledge_items(x, poll_id, wave),
    "tomorrows-europe-2007" = function(x, wave) {
      tomorrow_knowledge_items(x, if (wave == 1L) 1L else 3L)
    },
    "uk-crime-1994" = crime_knowledge_items,
    "uk-eu-1995" = eu_knowledge_items,
    "uk-general-election-1997" = election_knowledge_items,
    "uk-health-1998" = historical_health_items,
    "uk-monarchy-1996" = monarchy_knowledge_items,
    "wtu-1996" = function(x, wave) utility_knowledge_items(x, poll_id, wave),
    "zeguo-2005" = function(x, wave) {
      zeguo_knowledge_items(x, if (wave == 1L) "pre" else "post")
    }
  )
  if (is.null(item_function)) stop("No historical item scorer: ", poll_id)
  lapply(1:2, function(wave) item_function(survey, wave))
}

build_historical_items <- function(people) {
  contracts <- read_metadata("respondent_sources")
  polls <- contracts$poll_id[contracts$status == "reviewed-source"]
  purrr::map(polls, function(poll_id) {
    survey <- read_poll_survey(poll_id)
    identity <- people |>
      dplyr::filter(.data$poll_id == .env$poll_id) |>
      dplyr::arrange(.data$source_row)
    stopifnot(
      nrow(survey) == nrow(identity),
      identical(as.integer(survey$source_row), identity$source_row)
    )
    matrices <- historical_item_matrices(poll_id, survey)
    stopifnot(
      identical(dim(matrices[[1]]), dim(matrices[[2]])),
      nrow(matrices[[1]]) == nrow(identity)
    )
    purrr::map2(matrices, 1:2, function(matrix, wave) {
      if (is.null(colnames(matrix))) {
        colnames(matrix) <- paste0("item-", seq_len(ncol(matrix)))
      }
      stopifnot(!anyDuplicated(colnames(matrix)))
      tibble::as_tibble(matrix) |>
        dplyr::mutate(source_row = identity$source_row) |>
        tidyr::pivot_longer(
          -"source_row", names_to = "item_id", values_to = "correct"
        ) |>
        dplyr::mutate(
          poll_id = poll_id,
          respondent_id = identity$respondent_id[
            match(.data$source_row, identity$source_row)
          ],
          historical_respondent_id = identity$historical_respondent_id[
            match(.data$source_row, identity$source_row)
          ],
          wave = as.integer(wave),
          correct = as.integer(.data$correct)
        ) |>
        dplyr::select(
          "poll_id", "respondent_id", "historical_respondent_id",
          "source_row", "item_id", "wave", "correct"
        )
    }) |>
      purrr::list_rbind()
  }) |>
    purrr::list_rbind()
}
