source(project_path("R", "analysis_knowledge_responses.R"))
source(project_path("R", "source_questionnaire_presence.R"))
source(project_path("R", "source_australia.R"))
source(project_path("R", "source_new_haven.R"))
source(project_path("R", "source_monarchy.R"))
source(project_path("R", "source_zeguo.R"))
source(project_path("R", "respondent_btp_general.R"))
source(project_path("R", "analysis_attendance.R"))

knowledge_source_presence <- function(items, survey, poll, source_dataset) {
  forms <- items |>
    dplyr::summarise(
      wave_observed = dplyr::if_else(any(
        !is.na(raw_value) | (!is.na(raw_text) & nzchar(trimws(raw_text)))
      ), TRUE, NA),
      .by = c(source_row, wave)
    )
  definitions <- read_metadata("measure_definitions")
  inputs <- read_metadata("measure_inputs")
  targets <- read_metadata("polardata_targets")
  for (wave in unique(forms$wave)) {
    take <- which(forms$wave == wave)
    position <- match(forms$source_row[take], survey$source_row)
    stopifnot(!anyNA(position))
    # Use the same reviewed wave-specific source dependencies as the phase
    # exporter, including nonquiz answers from otherwise blank quizzes.
    target <- dplyr::filter(targets,
      poll_id == poll, legacy_field == paste0(wave, "know")
    )
    selected <- dplyr::filter(definitions,
      poll_id == poll, definition_id %in% target$canonical_definition
    )
    if (nrow(selected)) {
      phase_definitions <- dplyr::filter(definitions,
        poll_id == poll, source_waves %in% selected$source_waves
      )
      fields <- dplyr::filter(inputs,
        poll_id == poll, definition_id %in% phase_definitions$definition_id
      ) |>
        dplyr::pull(source_column) |>
        unique()
      id <- read_metadata("respondent_sources")
      id <- id$id_column[id$poll_id == poll]
      fields <- intersect(
        setdiff(fields, c("source_row", "CASEID", id)),
        names(survey)
      )
      fields <- fields[!grepl(
        "^(FFACT|EFACT|FTFACT|KNOW)[[:alnum:]]*$|^t[0-9]+(know|pk)",
        fields,
        ignore.case = TRUE
      )]
      if (length(fields)) {
        raw <- survey[fields]
        answered <- rowSums(as.data.frame(lapply(raw, function(x) {
          if (is.character(x)) !is.na(x) & nzchar(trimws(x)) else !is.na(x)
        }))) > 0L
        forms$wave_observed[take] <- dplyr::coalesce(
          forms$wave_observed[take],
          dplyr::if_else(answered[position], TRUE, NA)
        )
      }
    }
  }
  reviewed <- c(
    "cpl-1996", "san-mateo-2008", "uk-eu-1995", "uk-health-1998",
    "uk-crime-1994", "uk-general-election-1997", "europolis-2009",
    "tomorrows-europe-2007", "btp-presidential-primaries-2004", "nic2-2003",
    "nic-1996", "zeguo-2005"
  )
  if (poll %in% reviewed) {
    evidence <- questionnaire_form_evidence(survey, poll)
    key <- paste(forms$source_row, forms$wave)
    index <- match(key, paste(evidence$source_row, evidence$wave))
    use <- !is.na(index)
    forms$wave_observed[use] <- evidence$wave_observed[index[use]]
  }
  for (wave in unique(forms$wave)) {
    take <- which(forms$wave == wave)
    index <- match(forms$source_row[take], survey$source_row)
    override <- NULL
    if (poll == "australia-republic-1999" && source_dataset == "historical") {
      evidence <- australia_form_evidence(survey)
      override <- if (wave == "t1") {
        evidence$baseline_observed
      } else {
        evidence$departure_observed
      }
    }
    if (poll == "nic-1996" && wave == "t3") {
      override <- rounded_source_code(survey$PART3) %in% 1
    }
    if (poll == "new-haven-2004" && wave == "t2") {
      override <- new_haven_departure_observed(survey)
    }
    if (poll == "uk-monarchy-1996" && wave == "t2") {
      override <- monarchy_departure_observed(survey)
    }
    if (poll == "zeguo-2005" && wave == "t2") {
      override <- zeguo_departure_observed(survey)
    }
    if (poll == "btp-general-election-2004") {
      override <- btp_general_wave_present(
        survey, if (wave == "t1") "b" else "f"
      )
    }
    if (poll %in% c("wtu-1996", "swepco-1996") && wave == "t2") {
      override <- as.numeric(survey$PART) == 1
    }
    questionnaire <- analysis_attendance_sources()
    questionnaire <- questionnaire[questionnaire$poll_id == poll, ]
    if (nrow(questionnaire)) {
      pattern <- if (wave == "t1") {
        questionnaire$before_pattern
      } else {
        questionnaire$after_pattern
      }
      override <- questionnaire_observed(survey, pattern)
    }
    if (!is.null(override)) forms$wave_observed[take] <- override[index]
  }
  forms
}

apply_knowledge_contract <- function(
  responses, survey, poll, source_dataset = "cor_sood",
  catalog = read_metadata("items")
) {
  original_wave <- responses$wave
  original_item <- responses$item_id
  responses$correct_before_standardization <- responses$correct
  responses$source_dataset <- source_dataset
  responses$wave <- paste0("t", responses$wave)
  bank <- catalog[catalog$poll_id == poll, ]
  if (source_dataset == "historical") {
    for (wave in unique(original_wave)) {
      take <- which(original_wave == wave)
      names <- if (wave == 1L) {
        bank$historical_item_id
      } else {
        dplyr::coalesce(bank$historical_item_id_t2, bank$historical_item_id)
      }
      responses$item_id[take] <- bank$item_id[match(original_item[take], names)]
    }
    if (poll == "nic-1996") responses$wave[original_wave == 2L] <- "t3"
    responses$source_column <- NA_character_
    responses$raw_value <- NA_real_
    responses$raw_text <- NA_character_
    responses$response_status <- "scored"
  } else {
    responses$item_id <- bank$item_id[match(original_item, bank$cor_item_id)]
  }
  stopifnot(!anyNA(responses$item_id))
  responses <- recover_knowledge_raw(responses, catalog)
  forms <- knowledge_source_presence(responses, survey, poll, source_dataset)
  responses <- responses |>
    dplyr::left_join(forms,
      by = c("source_row", "wave"),
      relationship = "many-to-one"
    )
  unavailable <- !responses$wave_observed %in% TRUE
  if (any(responses$correct[unavailable] %in% 1L)) {
    stop("Positive correctness in unavailable source form: ", poll)
  }
  responses$correct[unavailable] <- NA_integer_
  responses$response_status[responses$wave_observed %in% FALSE] <- "wave_absent"
  responses <- enrich_knowledge_responses(responses, catalog)
  responses <- standardize_knowledge_scores(responses)$items
  responses$wave <- original_wave
  responses$item_id <- original_item
  responses$source_dataset <- NULL
  responses
}
