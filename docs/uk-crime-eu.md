# UK Crime and UK–EU source audit

The survey build reproduces all 6,426 deposited item-wave responses for these
two polls, including their missing values and female indicators. It uses raw
answers from the poll-level SPSS files; the deposited batteries are validation
targets only.

## Published sources

| Poll | Original ZIP member | Rows | Fields |
|---|---|---:|---:|
| UK Crime 1994 | `data/british_crime/crime_data/uk-crime.sav` | 869 | 287 |
| UK–EU 1995 | `data/british_europe/uk-eu.sav` | 900 | 175 |

Each poll directory contains the unchanged `survey.sav`, the original
`codebook.txt`, and generated `variables.csv` and `value-labels.csv`.
The source catalog records hashes and the original archive paths.
The Crime SPSS file has variable labels but no value labels, so its value-label
table is empty; category meanings are in the original codebook.

Both surveys contain numeric fields only. UK–EU's `givenum` records whether
a telephone number was given or refused, not the number itself. Its `intname`
contains numeric interviewer codes, not names; the codebook confirms that
coding. Dates and all other source values remain unchanged in the SPSS file.
UK–EU's SPSS user-missing declarations are retained. Scoring reads numeric
codes explicitly so those declarations cannot erase the original code.

## UK Crime: 299 participants and 20 groups

The archived script selects `part == 1` and an observed group assignment.
The source has 300 attendees, one of whom lacks a group. The maintained
knowledge build keeps the historical 299-person sample; all 869 records remain
in the published source, including that attendee and the nonparticipants.

The seven items are the four `kw` questions and the first three `pkw`
questions at each wave. Codes 8 and 9 remain missing correctness values.
The original correctness fields independently confirm the answer keys for
substantive answers.

`caseid` is unique, but 159 values contain floating-point noise of at most
1.5 × 10^-12. Truncation would create duplicate IDs. The build checks that every
ID is within 10^-8 of an integer, rounds it, checks uniqueness, and uses its
character representation. These IDs equal the original source-row numbers.
The archived script instead assigns `10000 + source_row`; that historical
ID must not be joined directly to the upstream ID without the documented
conversion. Row order is pinned to `source_row` for battery validation.

## UK–EU: 224 participants, 15 known groups

The source has 238 attendees. Fourteen have all five post-wave knowledge
responses coded -1, which the codebook labels inapplicable. The archived
script excludes them using `eusize2 != -1`; the maintained build reproduces
that 224-person knowledge sample without deleting their source records.

The items are `eusize`, `swiss`, `inctax`, `elect`, and `ptyapp`.
Codes 8/9 at T1 and 3/9 at T2 remain missing correctness values. Answer keys
agree with the source correctness fields for substantive answers.
`caseid` supplies the respondent identifier; source order supplies the
deposited battery order.

The codebook's GROUP section explicitly says that IDs 1008, 3132, 4316,
and 5022 lacked group assignments and were given code 99 to mark attendance.
They remain in the knowledge outputs, contributing 40 item-wave rows, but
have no membership rows. The result is 220 known memberships in 15 groups,
not 224 memberships in 16 groups.

This interpretation changes group metadata, not knowledge scores. It does
not establish the effect on any published group-based estimate. Downstream
repositories remain unchanged pending that comparison.

## Checks

`make check` validates every deposited scored cell and female indicator,
sample sizes, ID uniqueness, group counts, unknown response codes, and typed
Parquet round trips. Tests reject fractional or duplicated Crime IDs and
unrecognized UK–EU group codes, retain the four unmatched attendees, verify
the 14 excluded batteries, and reproduce the result after reordering inputs.

`make import-surveys` verifies original hashes and copies the reviewed
surveys and codebooks. `make audit-surveys` compares the published surveys
and generated dictionaries against the local archive. Generated parity,
join, and recode-count checks are in `audit/`.
