source(project_path("R", "source_australia.R"))
source(project_path("R", "source_new_haven.R"))
source(project_path("R", "source_questionnaire_presence.R"))

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

btp_national_attendance <- function(survey) {
  stopifnot("countmtg" %in% names(survey))
  count <- as.numeric(survey$countmtg)
  stopifnot(all(is.na(count) | count %in% 0:8))
  dplyr::if_else(is.na(count), NA, count > 0)
}

analysis_post_form_evidence <- function(
  people, scores, survey_reader = read_poll_survey
) {
  keys <- c("poll_id", "source_dataset", "respondent_id")
  immediate <- if ("wave_role" %in% names(scores)) {
    scores$wave_role == "post_deliberation"
  } else {
    scores$wave == "t2"
  }
  presence <- scores[immediate %in% TRUE, ] |>
    dplyr::summarise(
      absent_exit = any(wave_observed %in% FALSE),
      observed_exit = any(wave_observed %in% TRUE),
      .by = dplyr::all_of(keys)
    )
  stopifnot(!any(presence$absent_exit & presence$observed_exit))
  unknown <- presence |>
    dplyr::filter(!absent_exit, !observed_exit) |>
    dplyr::inner_join(people, by = keys, relationship = "one-to-one")
  if (nrow(unknown)) {
    polls <- unique(unknown$poll_id)
    supported <- read_metadata("respondent_sources")$poll_id
    polls <- intersect(polls, supported)
    # This bridge only returns reviewed full-form contracts. ACRS-only
    # Australians and sources lacking an immediate wave are not such returns.
    surveys <- stats::setNames(lapply(polls, survey_reader), polls)
    reviewed <- analysis_reviewed_presence(unknown, surveys)
    if (!is.null(reviewed)) {
      empty <- reviewed |>
        dplyr::filter(wave == "t2", !wave_observed %in% TRUE) |>
        dplyr::select(dplyr::all_of(keys))
      stopifnot(!anyDuplicated(empty[keys]))
      position <- match(do.call(paste, empty[keys]),
        do.call(paste, presence[keys])
      )
      stopifnot(!anyNA(position), !any(presence$observed_exit[position]))
      presence$absent_exit[position] <- TRUE
    }
  }
  ni <- people |>
    dplyr::filter(poll_id == "northern-ireland-2007",
      source_dataset == "control"
    )
  if (nrow(ni)) {
    raw <- attendance_source_rows(
      ni, survey_reader("northern-ireland-2007"), "cserial"
    )
    fields <- grep("^t2q[0-9]", names(raw), value = TRUE)
    observed <- questionnaire_form_answers(raw, fields)
    ni_presence <- ni |>
      dplyr::select(dplyr::all_of(keys)) |>
      dplyr::mutate(absent_exit = !observed, observed_exit = observed)
    presence <- presence |>
      dplyr::anti_join(ni_presence, by = keys) |>
      dplyr::bind_rows(ni_presence)
  }
  presence
}

analysis_attendance_contract <- function(
  participants, phase_participants, phase_scores,
  survey_reader = read_poll_survey, climate = NULL
) {
  keys <- c("poll_id", "source_dataset", "respondent_id")
  people <- phase_participants
  prior <- rep(FALSE, nrow(people))
  if ("attendance_before_post_rule" %in% names(people)) {
    prior <- !is.na(people$attendance_basis_before_post_rule)
    people$attended[prior] <- people$attendance_before_post_rule[prior]
    people$attendance_evidence[prior] <-
      people$attendance_evidence_before_post_rule[prior]
  }
  stopifnot(!anyDuplicated(people[keys]), !anyDuplicated(participants[keys]))
  people$attendance_basis <- dplyr::case_when(
    is.na(people$attended) ~ "unknown",
    people$source_dataset == "historical" ~ "historical_sample_membership",
    grepl("^Reviewed ", people$attendance_evidence) ~
      "reviewed_attendance_evidence",
    TRUE ~ "retained_source_classification"
  )
  if ("attendance_basis_before_post_rule" %in% names(people)) {
    people$attendance_basis[prior] <-
      people$attendance_basis_before_post_rule[prior]
  }
  australia_rows <- which(people$poll_id == "australia-republic-1999" &
                            people$source_dataset == "historical")
  if (length(australia_rows)) {
    survey <- survey_reader("australia-republic-1999")
    evidence <- australia_form_evidence(survey)
    position <- match(people$source_row[australia_rows], evidence$source_row)
    stopifnot(!anyNA(position))
    attended <- evidence$attended[position]
    known <- !is.na(attended)
    rows <- australia_rows[known]
    stopifnot(!any(!is.na(people$attended[rows]) &
                     people$attended[rows] != attended[known]))
    people$attended[rows] <- attended[known]
    people$attendance_basis[rows] <- "source_indicator"
    people$attendance_evidence[rows] <- paste(
      "part records actual attendance; partfull distinguishes the nine",
      "attendees without an exit questionnaire; roster joins original caseid"
    )
  }
  for (poll in c("cpl-1996", "wtu-1996", "swepco-1996", "europolis-2009")) {
    rows <- which(people$poll_id == poll &
                    people$source_dataset == "historical")
    if (!length(rows)) next
    survey <- survey_reader(poll)
    position <- match(people$source_row[rows], survey$source_row)
    stopifnot(!anyNA(position), !anyDuplicated(position))
    flag_field <- switch(poll,
      "cpl-1996" = "part",
      "europolis-2009" = "GROUP_T1BIS",
      "PART"
    )
    allowed <- if (poll == "europolis-2009") 1:3 else 1:2
    flag <- as.numeric(survey[[flag_field]][position])
    stopifnot(all(flag %in% allowed))
    people$attended[rows] <- flag == 1
    people$attendance_basis[rows] <- "source_indicator"
    people$attendance_evidence[rows] <- if (poll == "europolis-2009") {
      "GROUP_T1BIS: 1 participant; 2 nonparticipant; 3 control; source labels"
    } else {
      "PART: 1 Participant; 2 Non-Participant; source codebook"
    }
  }
  btp_rows <- which(people$poll_id == "btp-national-2003" &
                      people$source_dataset %in% c("historical", "cor_sood"))
  if (length(btp_rows)) {
    survey <- survey_reader("btp-national-2003")
    for (dataset in unique(people$source_dataset[btp_rows])) {
      rows <- btp_rows[people$source_dataset[btp_rows] == dataset]
      raw <- attendance_source_rows(people[rows, ], survey, "serial")
      attended <- btp_national_attendance(raw)
      known <- !is.na(attended)
      people$attended[rows[known]] <- attended[known]
      people$attendance_basis[rows[known]] <- "source_session_records"
      people$attendance_evidence[rows[known]] <- paste(
        "countmtg records sessions attended: zero means no attendance;",
        "one or more establishes attendance; questionnaire answers retained"
      )
    }
  }
  rows <- which(people$poll_id == "zeguo-2005" &
                  people$source_dataset == "historical")
  if (length(rows)) {
    survey <- survey_reader("zeguo-2005")
    position <- match(people$respondent_id[rows], as.character(survey$p))
    stopifnot(!anyNA(position), !anyDuplicated(position))
    returned <- zeguo_departure_observed(survey)[position]
    observed_rows <- rows[returned]
    stopifnot(!any(people$attended[observed_rows] %in% FALSE))
    people$attended[observed_rows] <- TRUE
    people$attendance_basis[observed_rows] <- "observed_post_questionnaire"
    people$attendance_evidence[observed_rows] <- paste(
      "Unique matched onsite POST questionnaire; blank quiz items",
      "do not erase attendance; group assignment is not required"
    )
  }
  rows <- which(people$poll_id == "a1r-climate-2021" &
                  people$source_dataset == "control")
  if (length(rows)) {
    if (is.null(climate)) {
      climate <- readr::read_tsv(project_path(
        "data", "a1r-climate-2021", "participants.tab"
      ), show_col_types = FALSE)
    }
    stopifnot(!anyNA(climate$CaseId), !anyDuplicated(climate$CaseId))
    position <- match(people$respondent_id[rows], as.character(climate$CaseId))
    stopifnot(!anyNA(position), !anyDuplicated(position))
    raw <- climate[position, ]
    sessions <- as.matrix(raw[paste0("SESSION", 1:4)])
    stopifnot(all(is.na(sessions) | sessions %in% 0:1))
    session_count <- rowSums(sessions == 1, na.rm = TRUE)
    complete_sessions <- rowSums(!is.na(sessions)) == 4L
    positive <- session_count > 0L
    negative <- complete_sessions & !positive
    stopifnot(
      !any(positive & people$attended[rows] %in% FALSE),
      !any(negative & people$attended[rows] %in% TRUE)
    )
    people$attended[rows[positive]] <- TRUE
    people$attended[rows[negative]] <- FALSE
    people$attendance_basis[rows[positive | negative]] <-
      "source_session_records"
    people$attendance_evidence[rows[positive | negative]] <- paste(
      "SESSION1:SESSION4 record actual participation; any 1 establishes",
      "attendance, four observed zeros establish no attendance"
    )
    people$sessions_attended[rows[complete_sessions]] <-
      as.integer(session_count[complete_sessions])
    observed <- questionnaire_observed(raw, "^T2Q[0-9]+[A-Z]?$")
    check <- phase_scores |>
      dplyr::filter(
        poll_id == "a1r-climate-2021",
        source_dataset == "control", wave == "t2"
      )
    found <- match(check$respondent_id, people$respondent_id[rows])
    stopifnot(
      !anyNA(found),
      !any(check$wave_observed %in% FALSE & observed[found])
    )
  }
  historical <- people |>
    dplyr::filter(source_dataset == "historical") |>
    dplyr::select(
      "poll_id", "source_row", "attended", "attendance_basis",
      "attendance_evidence"
    )
  stopifnot(!anyDuplicated(historical[c("poll_id", "source_row")]))
  cor_rows <- which(people$source_dataset == "cor_sood" &
                      people$poll_id %in% historical$poll_id)
  if (length(cor_rows)) {
    bridge <- people[cor_rows, c("poll_id", "source_row")] |>
      dplyr::left_join(historical,
        by = c("poll_id", "source_row"), relationship = "one-to-one"
      )
    stopifnot(!anyNA(bridge$attendance_basis))
    known <- !is.na(people$attended[cor_rows]) & !is.na(bridge$attended)
    stopifnot(all(people$attended[cor_rows][known] == bridge$attended[known]))
    fill <- is.na(people$attended[cor_rows]) & !is.na(bridge$attended)
    people$attended[cor_rows[fill]] <- bridge$attended[fill]
    people$attendance_basis[cor_rows[fill]] <- bridge$attendance_basis[fill]
    people$attendance_evidence[cor_rows[fill]] <- paste(
      "Verified same-source row bridge:", bridge$attendance_evidence[fill]
    )
  }
  people$attendance_before_post_rule <- people$attended
  people$attendance_basis_before_post_rule <- people$attendance_basis
  people$attendance_evidence_before_post_rule <- people$attendance_evidence
  exit_presence <- analysis_post_form_evidence(
    people, phase_scores, survey_reader
  )
  people <- people |>
    dplyr::left_join(exit_presence, by = keys, relationship = "one-to-one")
  inferred <- !people$attended %in% FALSE & people$absent_exit %in% TRUE
  people$attended[inferred] <- FALSE
  people$attendance_basis[inferred] <- "inferred_absent_post_questionnaire"
  people$attendance_evidence[inferred] <- paste(
    "Harmonized nonattendance: no answers in the immediate post-deliberation",
    "questionnaire. Prior roster or session classification is retained",
    "in attendance_before_post_rule and its evidence columns."
  )
  people <- people |>
    dplyr::select(-"absent_exit", -"observed_exit") |>
    dplyr::mutate(attendance_status = dplyr::case_when(
      attended %in% TRUE ~ "attended",
      attended %in% FALSE ~ "did_not_attend", TRUE ~ "unknown"
    ))
  position <- match(
    do.call(paste, participants[keys]), do.call(paste, people[keys])
  )
  stopifnot(
    !anyNA(position), !anyNA(people$attendance_basis),
    identical(people[keys], phase_participants[keys]),
    identical(people$panel, phase_participants$panel),
    identical(people$assignment, phase_participants$assignment)
  )
  participants$attended <- people$attended[position]
  participants$attendance_basis <- people$attendance_basis[position]
  for (column in c(
    "attendance_before_post_rule", "attendance_basis_before_post_rule",
    "attendance_evidence_before_post_rule"
  )) participants[[column]] <- people[[column]][position]
  list(participants = participants, phase_participants = people)
}
