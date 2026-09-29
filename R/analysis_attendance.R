analysis_attendance_sources <- function() {
  tibble::tibble(
    poll_id = c(
      "btp-2007", "btp-online-primaries-2004",
      "california-whats-next-2011", "denmark-euro-2000",
      "michigan-2009", "northern-ireland-2007", "vermont-energy-2007"
    ),
    id_column = c("CaseID", "id", "id", "delnr", "postit",
                  "cserial", "CASEID"),
    before_pattern = c(
      "^PRE_Q[0-9]", "^b1q[0-9]+(fu)?[a-z]?(_[0-9]+)?$",
      "^q[0-9]+[a-z]{0,2}$",
      "^s_[0-9]", "^q[0-9]+[a-z]{0,2}$", "^t1q[0-9]",
      "^Q[0-9]+[A-Z]?$"
    ),
    after_pattern = c(
      "^POST_Q[0-9]", "^f1q[0-9]+(fu)?[a-z]?(_[0-9]+)?$",
      "^t3q[0-9]+[a-z]{0,2}$",
      "^T2_S[0-9]", "^t3q[0-9]+[a-z]{0,2}$", "^t2q[0-9]",
      "^Q[0-9]+[A-Z]?T3$"
    )
  )
}

attendance_source_rows <- function(people, survey, id_column) {
  if (!all(c("source_row", id_column) %in% names(survey))) {
    stop("Attendance source lacks its original row or ID column.")
  }
  raw_id <- as.character(as.numeric(survey[[id_column]]))
  stopifnot(
    !anyNA(survey$source_row), !anyDuplicated(survey$source_row),
    !anyDuplicated(raw_id[!is.na(raw_id)]),
    !anyNA(people$source_row), !anyDuplicated(people$source_row)
  )
  position <- match(people$source_row, survey$source_row)
  if (anyNA(position) || anyNA(raw_id[position]) ||
        !identical(raw_id[position], as.character(people$respondent_id))) {
    stop("Attendance evidence does not match within-source respondent IDs.")
  }
  survey[position, , drop = FALSE]
}

questionnaire_observed <- function(survey, pattern) {
  fields <- grep(pattern, names(survey), value = TRUE, ignore.case = TRUE)
  derived <- grepl(
    "(cor(rect)?|flag(s)?|recode(d)?|index|score)[0-9]*(_[[:alnum:]]+)?$",
    fields, ignore.case = TRUE
  )
  numeric <- vapply(survey[fields], is.numeric, logical(1))
  fields <- fields[!derived & numeric]
  if (length(fields) < 10L) {
    stop("Too few raw questionnaire fields for reviewed wave presence.")
  }
  rowSums(!is.na(survey[fields])) > 0L
}

primaries_attendance <- function(survey) {
  fields <- paste0("mtg", 1:5)
  stopifnot(all(c(fields, "mtgatt", "trtcont", "expcont") %in%
                  names(survey)))
  meetings <- as.matrix(survey[fields])
  observed <- rowSums(!is.na(meetings))
  attended_count <- rowSums(meetings == 1, na.rm = TRUE)
  no_meetings <- observed == 5L & attended_count == 0L
  authored_count <- as.numeric(survey$mtgatt)
  classification <- as.numeric(survey$trtcont)
  stopifnot(
    all(is.na(meetings) | meetings %in% 0:2),
    all(is.na(authored_count) | authored_count %in% 0:5),
    all(survey$expcont == 1),
    all(is.na(authored_count) | authored_count >= attended_count),
    all(is.na(authored_count) |
          authored_count <= attended_count + 5L - observed),
    all(is.na(classification) | classification %in% 1:6),
    all(is.na(classification) | is.na(authored_count) |
          classification == authored_count + 1L)
  )
  authored_none <- !is.na(authored_count) & authored_count == 0L &
    classification %in% 1
  stopifnot(!any(authored_none & attended_count > 0L))
  authored_count <- as.integer(authored_count)
  attended <- dplyr::case_when(
    attended_count > 0L ~ TRUE,
    no_meetings | authored_none ~ FALSE,
    TRUE ~ NA
  )
  sessions <- authored_count
  sessions[is.na(sessions) & observed == 5L] <- as.integer(
    attended_count[is.na(sessions) & observed == 5L]
  )
  evidence <- dplyr::case_when(
    attended_count > 0L ~ "mtg1:mtg5 records at least one attended session",
    no_meetings ~ "five observed meeting flags record no attended sessions",
    authored_none ~ paste(
      "mtgatt=0 and trtcont=1 explicitly record no attended sessions;",
      "missing individual meeting flags preserved"
    ),
    TRUE ~ "individual session attendance and authored count unresolved"
  )
  list(attended = attended, sessions = sessions, evidence = evidence)
}

analysis_btp2007_attendance <- function(survey) {
  evaluation_fields <- paste0("POST_Q31", letters[1:6], "_groups")
  activity_fields <- paste0("discuss", 1:4)
  stopifnot(all(c("group", evaluation_fields, activity_fields) %in%
                  names(survey)))
  evaluation <- as.matrix(survey[evaluation_fields])
  experience <- rowSums(
    !is.na(evaluation) & evaluation >= 1 & evaluation <= 5
  ) > 0L
  activity <- as.matrix(survey[activity_fields])
  engaged <- rowSums(!is.na(activity) & activity > 0 & activity < 99) > 0L
  discussion <- survey$group %in% 1
  attended <- dplyr::if_else(discussion & (experience | engaged), TRUE, NA)
  evidence <- dplyr::case_when(
    discussion & experience ~ paste(
      "group=1 discussion sample; observed POST_Q31 moderator/group",
      "experience; codebook PDF p.4 documents selected completers"
    ),
    discussion & engaged ~ paste(
      "group=1 discussion sample; positive logged discuss1:discuss4",
      "activity; codebook PDF p.4 documents selected completers"
    ),
    TRUE ~ "discussion attendance not established from treatment alone"
  )
  list(
    attended = attended, sessions = rep(NA_integer_, nrow(survey)),
    evidence = evidence
  )
}

analysis_onsite_attendance <- function(poll_id, survey, exit_observed) {
  flag <- switch(poll_id,
    "northern-ireland-2007" = dplyr::case_when(
      survey$attend %in% 1 ~ TRUE,
      survey$attend %in% c(2, 3) ~ FALSE, TRUE ~ NA
    ),
    "vermont-energy-2007" = dplyr::case_when(
      survey$PART %in% 1 ~ TRUE, survey$PART %in% 0 ~ FALSE, TRUE ~ NA
    ),
    dplyr::if_else(exit_observed, TRUE, NA)
  )
  evidence <- switch(poll_id,
    "northern-ireland-2007" = "attend records participation status at time 2",
    "vermont-energy-2007" = "PART records participation in deliberations",
    "denmark-euro-2000" = paste(
      "unique departure DELNR join and observed on-site T2_S answers"
    ),
    "michigan-2009" = "observed on-site exit t3q questionnaire answers",
    "california-whats-next-2011" = paste(
      "observed on-site exit t3q answers; pre-event attend flag not used"
    )
  )
  list(
    attended = flag, sessions = rep(NA_integer_, nrow(survey)),
    evidence = rep(evidence, nrow(survey))
  )
}

# Enrich phase tables only. Arrival, exit, treatment assignment and knowledge
# answers are distinct evidence; source IDs are checked within each deposit.
analysis_attendance_evidence <- function(
  participants, scores, survey_reader = read_poll_survey
) {
  ids <- c("poll_id", "source_dataset", "respondent_id")
  stopifnot(
    !anyDuplicated(participants[ids]),
    all(c(ids, "source_row", "attended") %in% names(participants)),
    all(c(ids, "wave", "wave_observed", "score", "n_correct",
          "n_observed") %in% names(scores)),
    is.logical(participants$attended), is.logical(scores$wave_observed)
  )
  people <- participants
  if (!"attendance_evidence" %in% names(people)) {
    people$attendance_evidence <- rep(NA_character_, nrow(people))
  }
  pending <- is.na(people$attendance_evidence)
  people$attendance_evidence[pending] <- dplyr::if_else(
    is.na(people$attended[pending]), "attendance unmeasured or unresolved",
    "existing phase attendance flag; source evidence not yet annotated"
  )
  if (!"sessions_attended" %in% names(people)) {
    people$sessions_attended <- rep(NA_integer_, nrow(people))
  }
  specifications <- analysis_attendance_sources()
  for (i in seq_len(nrow(specifications))) {
    poll <- specifications$poll_id[i]
    rows <- which(people$poll_id == poll &
                    people$source_dataset == "cor_sood")
    if (!length(rows)) next
    survey <- attendance_source_rows(
      people[rows, ], survey_reader(poll), specifications$id_column[i]
    )
    before <- questionnaire_observed(
      survey, specifications$before_pattern[i]
    )
    after <- questionnaire_observed(
      survey, specifications$after_pattern[i]
    )
    attendance <- switch(poll,
      "btp-online-primaries-2004" =
        primaries_attendance(survey),
      "btp-2007" = analysis_btp2007_attendance(survey),
      analysis_onsite_attendance(poll, survey, after)
    )
    people$attended[rows] <- attendance$attended
    people$sessions_attended[rows] <- attendance$sessions
    people$attendance_evidence[rows] <- paste0(
      "Reviewed ", poll, " source_row=", people$source_row[rows],
      "; ", attendance$evidence
    )
    for (wave in c("t0", "t2")) {
      score_rows <- which(scores$poll_id == poll &
                            scores$source_dataset == "cor_sood" &
                            scores$wave == wave)
      position <- match(scores$respondent_id[score_rows],
                        people$respondent_id[rows])
      stopifnot(!anyNA(position))
      observed <- if (wave == "t0") before[position] else after[position]
      if (any(!observed & scores$n_correct[score_rows] > 0, na.rm = TRUE)) {
        stop("Positive quiz score conflicts with absent raw questionnaire.")
      }
      scores$wave_observed[score_rows] <- observed
      absent_rows <- score_rows[!observed]
      scores$score[absent_rows] <- NA_real_
      scores$n_correct[absent_rows] <- NA_integer_
      scores$n_observed[absent_rows] <- 0L
    }
  }
  people$attendance_status <- dplyr::case_when(
    people$attended %in% TRUE ~ "attended",
    people$attended %in% FALSE ~ "did_not_attend", TRUE ~ "unknown"
  )
  people$sessions_attended <- as.integer(people$sessions_attended)
  scores$questionnaire_presence_status <- dplyr::case_when(
    scores$wave_observed %in% TRUE ~ "observed",
    scores$wave_observed %in% FALSE ~ "absent", TRUE ~ "unknown"
  )
  stopifnot(
    nrow(people) == nrow(participants),
    identical(people[ids], participants[ids]),
    !anyNA(people$attendance_status), !anyNA(people$attendance_evidence),
    !anyNA(scores$questionnaire_presence_status),
    all(is.na(people$sessions_attended) | people$sessions_attended >= 0L)
  )
  list(participants = people, scores = scores)
}

# Phase presence comes from reviewed full questionnaires and completion fields.
# Use it in the selected tables without dropping earlier records or attendance.
reconcile_analysis_presence <- function(
  participants, scores, items, phase_participants, phase_scores
) {
  person_keys <- c("poll_id", "source_dataset", "respondent_id")
  wave_keys <- c(person_keys, "wave")
  presence <- phase_scores |>
    dplyr::filter(grepl(":knowledge$", battery_id)) |>
    dplyr::transmute(
      poll_id, source_dataset, respondent_id, wave = original_score_wave,
      wave_observed
    )
  stopifnot(!anyDuplicated(presence[wave_keys]))
  absence <- presence |>
    dplyr::filter(wave_observed %in% FALSE) |>
    dplyr::transmute(
      poll_id, source_dataset, respondent_id, wave, absent = TRUE
    )
  update_scores <- scores |>
    dplyr::left_join(absence, by = wave_keys, relationship = "one-to-one")
  absent_score <- update_scores$absent %in% TRUE
  stopifnot(all(
    is.na(update_scores$score[absent_score]) |
      update_scores$score[absent_score] == 0
  ))
  update_scores$score[absent_score] <- NA_real_
  update_scores$n_correct[absent_score] <- NA_integer_
  update_scores$n_observed[absent_score] <- 0L
  update_scores$absent <- NULL

  update_items <- items |>
    dplyr::left_join(absence, by = wave_keys, relationship = "many-to-one")
  absent_item <- update_items$absent %in% TRUE
  stopifnot(all(
    is.na(update_items$correct[absent_item]) |
      update_items$correct[absent_item] == 0L
  ))
  update_items$correct[absent_item] <- NA_integer_
  update_items$response_status[absent_item] <- "wave_absent"
  update_items$absent <- NULL

  paired <- function(data) {
    data |>
      dplyr::filter(wave %in% c("t1", "t2"), is.finite(score)) |>
      dplyr::summarise(
        paired = all(c("t1", "t2") %in% wave),
        .by = dplyr::all_of(person_keys)
      )
  }
  update_panel <- function(people, eligibility) {
    result <- people |>
      dplyr::left_join(eligibility,
        by = person_keys, relationship = "one-to-one"
      ) |>
      dplyr::mutate(panel = panel & dplyr::coalesce(paired, FALSE)) |>
      dplyr::select(-"paired")
    stopifnot(
      nrow(result) == nrow(people),
      identical(result[person_keys], people[person_keys]),
      identical(result$attended, people$attended)
    )
    result
  }
  phase_eligibility <- phase_scores |>
    dplyr::filter(grepl(":knowledge$", battery_id)) |>
    dplyr::transmute(
      poll_id, source_dataset, respondent_id, wave = original_score_wave,
      score = dplyr::if_else(wave_observed %in% FALSE, NA_real_, score)
    ) |>
    paired()
  stopifnot(
    identical(update_scores[wave_keys], scores[wave_keys]),
    identical(update_items[c(wave_keys, "item_id")],
      items[c(wave_keys, "item_id")]
    ),
    identical(update_items$raw_value, items$raw_value),
    identical(update_items$raw_text, items$raw_text)
  )
  list(
    participants = update_panel(participants, paired(update_scores)),
    scores = update_scores, items = update_items,
    phase_participants = update_panel(phase_participants, phase_eligibility)
  )
}
