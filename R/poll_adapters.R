rounded_source_code <- function(x) {
  stopifnot(all(is.na(x) | abs(x - round(x)) < 1e-8))
  round(as.numeric(x))
}

remaining_participants <- function(poll_id, survey) {
  d <- survey |> dplyr::arrange(.data$source_row)
  sex <- function(x) {
    dplyr::if_else(x %in% c(1, 2), as.integer(x == 2), NA_integer_)
  }
  id <- function(x) as.character(rounded_source_code(x))
  out <- switch(poll_id,
    "australia-republic-1999" = {
      d <- d |> dplyr::filter(.data$group %in% 1:24)
      dplyr::transmute(d, source_row,
        respondent_id = id(caseid),
        female = sex(gender), group_id = id(group)
      )
    },
    "btp-2007" = {
      d <- d |> dplyr::filter(.data$group == 1)
      dplyr::transmute(d, source_row,
        respondent_id = id(CaseID),
        female = sex(gender), group_id = Sgroup
      )
    },
    "btp-general-election-2004" = {
      d <- d |> dplyr::filter(
        .data$dop4part == 1, !is.na(.data$t1know), !is.na(.data$t2know)
      )
      dplyr::transmute(d, source_row,
        respondent_id = id(caseid_original),
        female = sex(ppgender), group_id = id(smgrpnumber)
      )
    },
    "btp-health-education-2005" = {
      dplyr::transmute(d, source_row,
        respondent_id = id(id),
        female = sex(gender), group_id = id(group)
      )
    },
    "btp-online-primaries-2004" = {
      d <- d |> dplyr::filter(.data$expcont == 1)
      dplyr::transmute(d, source_row,
        respondent_id = id(id),
        female = sex(ppgender), group_id = id(groupnumc)
      )
    },
    "bulgaria-crime-2002" = {
      d <- d |> dplyr::arrange(.data$id)
      dplyr::transmute(d, source_row,
        respondent_id = id(id),
        female = sex(sex), group_id = id(group0)
      )
    },
    "california-whats-next-2011" = {
      d <- d |> dplyr::filter(.data$t2t3filter == 1, !is.na(.data$part))
      dplyr::transmute(d, source_row,
        respondent_id = id(id),
        female = sex(q73), group_id = id(t3_GroupNumber)
      )
    },
    "europolis-2009" = {
      d <- d |> dplyr::filter(.data$GROUP_T1BIS == 1)
      dplyr::transmute(d, source_row,
        respondent_id = id(UniqueID),
        female = sex(sex1), group_id = id(SMALL_GROUPw3)
      )
    },
    "nic-1996" = {
      d <- d |> dplyr::filter(.data$PART == 1)
      dplyr::transmute(
        d, source_row,
        respondent_id = dplyr::coalesce(
          id(CASEID), paste0("source-row-", source_row)
        ),
        female = sex(rounded_source_code(SEX1)),
        group_id = id(RGROUP2)
      )
    },
    "tomorrows-europe-2007" = {
      d <- d |> dplyr::filter(.data$t3part == 1)
      dplyr::transmute(d, source_row,
        respondent_id = id(v_b),
        female = sex(q35), group_id = id(t3grp)
      )
    },
    "vermont-energy-2007" = {
      d <- d |> dplyr::filter(.data$PART == 1)
      dplyr::transmute(d, source_row,
        respondent_id = id(CASEID),
        female = sex(Q94), group_id = NA_character_
      )
    },
    "san-mateo-2008" = {
      d <- d |>
        dplyr::filter(.data$participant == 1) |>
        dplyr::arrange(.data$PARTICIPANTID)
      dplyr::transmute(d, source_row,
        respondent_id = id(PARTICIPANTID),
        female = as.integer(Female), group_id = id(GRP)
      )
    },
    "michigan-2009" = {
      d <- d |>
        dplyr::filter(!is.na(.data$postit)) |>
        dplyr::arrange(.data$postit)
      dplyr::transmute(d, source_row,
        respondent_id = id(postit),
        female = sex(q43), group_id = id(group_number)
      )
    },
    "denmark-euro-2000" = {
      d <- d |>
        dplyr::filter(!is.na(.data$T2_source_row)) |>
        dplyr::arrange(.data$delnr)
      dplyr::transmute(d, source_row,
        respondent_id = id(delnr),
        female = sex(s_01), group_id = NA_character_
      )
    },
    stop("No participant selection rule for ", poll_id)
  )
  out
}

knowledge_raw_code <- function(poll_id, raw_value, raw_text) {
  numeric <- raw_value
  nic <- poll_id == "nic-1996"
  numeric[nic] <- rounded_source_code(numeric[nic])
  text <- tolower(gsub("[^[:alnum:]]", "", raw_text))
  text[!is.na(text) & text == ""] <- "<blank>"
  dplyr::if_else(is.na(raw_text), as.character(numeric), text)
}

apply_knowledge_overrides <- function(responses, poll_id, survey) {
  if (poll_id != "australia-republic-1999") {
    return(responses)
  }
  flags <- survey |>
    dplyr::select("source_row", "dkchg1", "dkchg2") |>
    dplyr::mutate(dplyr::across(c("dkchg1", "dkchg2"), as.numeric)) |>
    tidyr::pivot_longer(-"source_row", names_to = "flag", values_to = "dk") |>
    dplyr::mutate(wave = as.integer(sub("dkchg", "", .data$flag))) |>
    dplyr::select("source_row", "wave", "flag", "dk")
  responses |>
    dplyr::left_join(
      flags, by = c("source_row", "wave"), relationship = "many-to-one"
    ) |>
    dplyr::mutate(
      override = grepl(
        "^(flagchg|anthem|wdroyal|pargame)", .data$source_column
      ) &
        !is.na(.data$dk) & .data$dk == 1,
      correct = dplyr::if_else(.data$override, NA_integer_, .data$correct),
      response_status = dplyr::if_else(
        .data$override, "non_substantive", .data$response_status
      ),
      missing_code = dplyr::if_else(
        .data$override, paste0(.data$flag, "=1"), .data$missing_code
      )
    ) |>
    dplyr::select(-c("flag", "dk", "override"))
}
