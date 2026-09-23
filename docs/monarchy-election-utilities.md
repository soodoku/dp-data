# Monarchy, General Election, CPL, SWEPCO, and WTU

Five more polls now build from their own survey files. Four reproduce the
deposited scored batteries; Monarchy corrects a T1 field reused at T2.
The deposited files remain unchanged.

| Poll | Source rows × fields | Selected attendees | Groups | Items per wave |
|---|---:|---:|---:|---:|
| UK Monarchy 1996 | 857 × 417 | 258 | 15 | 8 |
| UK General Election 1997 | 1,210 × 568 | 275 | 15 | 15 |
| CPL 1996 | 1,246 × 195 | 216 | 16 | 7 |
| SWEPCO 1996 | 1,478 × 196 | 232 | 14 | 5 |
| WTU 1996 | 1,230 × 196 | 230 | 14 | 5 |

The original surveys, codebooks, variable dictionaries, and value-label
dictionaries are published under each poll's `data/` directory. The source
catalog records ZIP members and hashes. The survey files contain the larger
source samples and fields beyond knowledge; the canonical knowledge tables
currently select attendees only.

## Monarchy: use the actual post-deliberation answer

The archived `uk_monarchy.R` uses `Q5C` for both waves of the Commonwealth
question. The deposited `knowc2raw` reproduces that T1 field exactly.
The original codebook distinguishes the two waves; the survey contains the
post-deliberation answer in `R5C`. The maintained build uses `R5C`.

This changes 58 scored item-wave cells, including changes to or from missing,
and 55 participants' zero-filled T2 scores. Across 258 attendees and eight
items, mean T2 knowledge falls from 79.893% to 79.651%, a decrease of 0.242
percentage points. T1 remains 64.680%. These are battery comparisons, not
re-estimates of the paper's models.

The eight true/false items use correct codes 2, 2, 1, 2, 1, 1, 2, 1; codes 3
and 4 remain non-substantive. The survey also contains a succession question,
but it is not silently added to this eight-item index.

Positive `GROUP` selects 258 attendees in groups 2–16. No original column
uniquely identifies all survey respondents. IDs therefore use
`source-row-<source_row>`, tied to the exact published file. The archived
script's generated ID was also row-based, but used another numeric offset.
Neither is evidence of a cross-file person match. `B25B` records whether a
telephone number was supplied or refused; it contains statuses, not numbers.

## General Election: preserve the documented participant sample

The codebook's `filter == 1` selects 275 attendees. Serial 4416 has a group
assignment but no T2 questionnaire and is excluded by that filter. The source
record is retained in the published survey.

The battery has three factual items and twelve party-placement items. Negative
codes −8 and −9 are missing, not low placements. The historical script also
handles them before scoring; there is no disagreement on that point.
Conservative placements 1–3 and Labour/LibDem placements 5–7 count as correct.
The deposited placement columns contain literal TRUE/FALSE values, which the
comparison reader accepts alongside numeric 0/1. All scored cells and female
indicators agree after reading those values correctly.

## CPL: retain the earlier missing-response codes

The build uses `cpl.sav`, not the later `cpl2.sav`. Both have the same case IDs
in the same order, and attendee knowledge responses agree after replacing
code 99 with missing in the earlier file. The earlier file retains 759 explicit
99 responses across the selected item-wave fields. Its codebook identifies
99 as don't know.

Canonical responses preserve raw 99, leave correctness null, and record
`missing_code = 99`. Only the explicitly zero-filled index counts these
responses as zero. Seven item keys are 3, 3, 2, 2, 1, 0, 2.
All scored cells and female indicators match the deposit.

## SWEPCO and WTU: retain the limits of the available source

The builds use `swepco2.dta` and `wt2.dta`. Earlier portable files exist,
but both haven and foreign fail to read them: haven reports malformed numeric
values at `FEDRCH2`, and foreign reports a portable-file dictionary error.
The readable Stata files already collapse some missing-response codes.
The build records those values as source missing rather than guessing the
original reason. The WTU archive's missing-value script confirms such recoding.

SWEPCO's five correct codes are 1, 3, 1, 2, 1; WTU's are 3, 1, 1, 2, 1.
WTU `USE2 = 4` means wholesale and is a valid incorrect answer, supported by
the codebook and original correctness field. Two attendees, case IDs 20000100
and 20001180, give this answer. The archived R recode omitted that category,
but the deposited battery already scores both correctly as zero.

Both polls' scored batteries and female indicators match their deposits.
Original survey correctness fields independently verify all three utilities'
recodes. Utility samples use `PART == 1` (lowercase in CPL), original case IDs,
and original group assignments. CPL has 16 groups; each other utility has 14.
No absent group number is turned into a synthetic group.

## Checks and scope

Tests verify source-based correctness fields, documented answer keys, missing
codes, sample filters, unique keys, group counts, and invariance to input row
reordering. Every benchmark difference is exported with its source item and
respondent locator. Separate score comparisons quantify the consequences.

All five published surveys contain numeric fields rather than respondent
free text. Review included field names, labels, values, and contact-like
fields; CPL's ZIP field is geography, not a contact number. Publication is
owner-authorized; the source catalog does not invent a reuse license.

Across all nine implemented polls, outputs contain 2,088 participants, 30,944
item-wave responses, 4,176 participant-wave scores, 2,084 memberships, and 144
groups. Four UK–EU attendees still lack known groups. Downstream analyses have
not been switched to these outputs; attitude recodes and the remaining polls
are still pending.
