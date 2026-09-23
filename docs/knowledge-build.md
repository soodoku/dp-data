# Knowledge data from reviewed survey packages

`make knowledge` rebuilds nine knowledge batteries from published poll-level
survey inputs. It produces five typed Parquet tables in `output/`, plus a
checksum manifest. The Cor–Sood batteries are comparison evidence, not build
inputs or a requirement to reproduce a known error.

| Poll | Published survey | Knowledge sample | Items per wave | Groups |
|---|---|---:|---:|---:|
| UK Health 1998 | Original SPSS file: 230 rows, 387 fields | 230 participants | 6 | 15 |
| Northern Ireland 2007 | Structured extract: 868 rows, 448 retained fields plus source row | 124 participants | 7 | 20 |
| UK Crime 1994 | Original SPSS file: 869 rows, 287 fields | 299 participants | 7 | 20 |
| UK–EU 1995 | Original SPSS file: 900 rows, 175 fields | 224 participants | 5 | 15 known |
| UK Monarchy 1996 | Original SPSS file: 857 rows, 417 fields | 258 participants | 8 | 15 |
| UK General Election 1997 | Original SPSS file: 1,210 rows, 568 fields | 275 participants | 15 | 15 |
| CPL 1996 | Original SPSS file: 1,246 rows, 195 fields | 216 participants | 7 | 16 |
| SWEPCO 1996 | Original Stata file: 1,478 rows, 196 fields | 232 participants | 5 | 14 |
| WTU 1996 | Original Stata file: 1,230 rows, 196 fields | 230 participants | 5 | 14 |

The output covers attendees at the pre- and post-deliberation waves. Northern
Ireland's larger source frame retains control and other records for subsequent
work. The current knowledge output does not estimate a treatment effect or
contain the control-wave battery.

## Inputs and provenance

`metadata/survey_sources.csv` identifies the exact original ZIP member and its
SHA-256, the published path, and the import rule. The original data ZIP is
registered in `metadata/source_bundles.csv`. File-level hashes for the published
surveys and dictionaries are in `metadata/source_files.csv`.

UK Health's `survey.sav` preserves the original bytes and value labels.
Its three string fields are poll/group codes. The fields `phone` and
`recnumb` describe telephone ownership and whether a number was recorded or
refused; they do not contain telephone numbers.

Northern Ireland's `survey.parquet` preserves all 868 source rows and every
non-verbatim field, including the original interview date. The 80 excluded fields are enumerated in
`metadata/source_field_exclusions.csv`; their response text remains in the
local archive. A one-based `source_row` links each published row to the original
Stata file. This is a source-row locator, not a respondent identifier. The
conversion retains original numeric missing codes and does not score items.
There are no tagged Stata missing values in this source.

Each poll supplies `variables.csv` and `value-labels.csv`, generated from the
original survey attributes. These preserve labels outside Parquet, which does
not carry haven's labelled-vector attributes. The variable dictionary includes
withheld fields but contains none of their responses. Northern Ireland's
retained numeric fields are stored as float64, the interview date as date32,
and the added source row as int32. The dictionary records the original R
storage types and classes as well as the Parquet types.

These CDD materials are published with the repository owner's authorization.
No CC0 license is inferred from the separate Cor–Sood deposit; the source catalog
records their license as not specified.

## Selection, scoring, and missing values

UK Health uses all 230 source records. `serial_m` is the poll-specific respondent
ID, `group` gives group membership, and `gender` codes 1/2 become female 0/1.
The six factual responses are `sopha` through `sophf` at each wave. The answer
keys agree with the original SPSS variables labeled as item correctness.

Northern Ireland selects `attend == 1`, retains `cserial` as respondent ID, and
orders attendees by that ID to reproduce the historical merge/export order.
The seven item pairs use the recodes in the archived `n_ireland.R`, retained
under the `historical-cdd-scripts` Git tag. T1 and T2 response categories differ
for some questions, so their keys and non-substantive codes are wave-specific.

`metadata/knowledge_items.csv` records each source column, item and wave,
correct codes (`correct_values`), incorrect codes, and non-substantive codes.
Multiple codes use a pipe delimiter. An observed code
outside these lists stops the build. In `knowledge_responses`, `raw_value`
preserves the original code, `correct` stays null for non-substantive responses,
and `missing_code` distinguishes source codes from a system missing value.
Descriptions come from value-label dictionaries where available and the original
codebooks otherwise. System-missing values in cleaned source files do not reveal
which original nonresponse code was used.

`knowledge_scores` provides `n_items`, `n_observed`, `n_correct`, and
`score_zero_filled`. The last is the historical proportion-correct score:
the numerator is the count correct and the denominator includes the entire
battery. It does not overwrite the response-level missing values.

## Northern Ireland group-file correction

The roster has no header. Its first line, `112084,N`, is a respondent–group
record. The historical script and the current downstream reader use
`header = TRUE` or its default equivalent, consuming that record as column names.

Reading the file with explicit column names yields 124 distinct respondent IDs,
all of which match the 124 attendees. It gives 20 groups and no unmatched
attendee. This build adopts that interpretation. The earlier 123-match audit
described the historical parser's output, not the contents of the roster.

This changes group membership for one participant and leaves all knowledge
items, respondent counts, and knowledge scores unchanged. It may change later
group-level estimates. Downstream analyses have not been switched automatically;
their group-based results need a comparison before adopting this correction.

## Crime and UK–EU source decisions

The [Crime and UK–EU audit](uk-crime-eu.md) records their sample restrictions,
answer keys, and identifiers. Both original SPSS files and original text
codebooks are published. All knowledge responses match the deposited batteries.
The codebook identifies UK–EU group `99` as four attendees whose assignments
were unavailable. They remain in the knowledge sample but have no membership
rows; the build does not invent a sixteenth group.

## Monarchy, General Election, and three utilities

The [five-poll audit](monarchy-election-utilities.md) documents source selection,
answer keys, and the Monarchy correction. Monarchy has no unique source person
ID: `source-row-N` is explicitly a locator within that exact source file, not a
cross-file linkage key. The other four polls retain their original identifiers.

## Output contract

| Table | Rows | Unit |
|---|---:|---|
| `respondents` | 2,088 | Participant within poll |
| `knowledge_responses` | 30,944 | Participant × item × wave |
| `knowledge_scores` | 4,176 | Participant × wave |
| `memberships` | 2,084 | Participant × discussion group |
| `groups` | 144 | Discussion group within poll |

Keys, nullability, and Arrow types are recorded in
`metadata/canonical_columns.csv`. `arm = participant` records observed status;
it does not assert random assignment. Respondent IDs are unique only together
with `poll_id`. `battery_row` is the reconstructed ordering used to check the
deposited battery and must not be used as an ID in another dataset.

The stored `output/manifest.csv` provides the checksum of each exported file.
Consumers should pin a repository commit and verify those checksums. The
attitude-index build and the remaining polls are still pending.

## Reproduction and checks

A checkout contains everything needed for `make restore` followed by
`make check`. Checks rebuild the outputs, compare every scored cell and female indicator
against all nine deposits, enforce keys and group-match counts, test missing and
unknown codes, and round-trip Parquet types and values. Separate source-based
tests verify answer keys, sample restrictions, and the corrected T2 field.
The comparison reports differences rather than requiring zero differences.

With the original ZIPs unpacked into the local vault:

```sh
make import-surveys
make audit-surveys
make check
```

The import verifies original file hashes before copying or converting.
The archive audit checks every retained Northern Ireland value and the original
exact-copy survey bytes against the public files. It also regenerates and compares the
variable and value-label dictionaries. These local checks do not require uploading the archive.

`audit/knowledge_parity.csv`, `audit/knowledge_join_checks.csv`, and
`audit/knowledge_recode_counts.csv` are generated evidence.
`audit/knowledge_differences.csv` identifies changed cells;
`audit/knowledge_score_changes.csv` reports their effects on mean scores. The recode counts
show old values, new scores, missing statuses, and counts for each source item.
