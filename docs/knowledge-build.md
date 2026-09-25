# Knowledge data from reviewed survey packages

`make knowledge` rebuilds all 23 knowledge batteries from published poll-level
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

The remaining fourteen polls are documented in the
[poll-by-poll audit](remaining-polls.md), including source selection, scoring
corrections, and unresolved sample and answer-key differences.

The output covers attendees at the pre- and post-deliberation waves. Northern
Ireland's larger source frame retains control and other records for subsequent
work. The current knowledge output does not estimate a treatment effect or
contain the control-wave battery.

## Inputs and provenance

`metadata/survey_sources.csv` and `metadata/survey_components.csv` identify the exact original ZIP member and its
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
preserves the original numeric code; `raw_text` preserves reviewed written
answers. `correct` stays null for non-substantive responses,
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
| `respondents` | 6,669 | Participant within poll |
| `knowledge_responses` | 103,116 | Participant × item × wave |
| `knowledge_scores` | 13,338 | Participant × wave |
| `memberships` | 6,147 | Participant × discussion group |
| `groups` | 406 | Discussion group within poll |

Keys, nullability, and Arrow types are recorded in
`metadata/canonical_columns.csv`. `arm = participant` records observed status;
it does not assert random assignment. Respondent IDs are unique only together
with `poll_id`. `battery_row` is the reconstructed ordering used to check the
deposited battery where alignment is established and must not be used as an ID
in another dataset. It is only local ordering for different-size samples and
Europolis. Canonical waves 1/2 mean selected pre/post measurements, not literal
source wave numbers; source column names remain in the item map.

The stored `output/manifest.csv` provides the checksum of each exported file.
Consumers should pin a repository commit and verify those checksums. The
attitude-index and control-battery builds are still pending.

## Reproduction and checks

A checkout contains everything needed for `make restore` followed by
`make check`. Checks rebuild the outputs, compare every scored cell and female indicator
against deposits where row alignment is established, enforce keys and group-match counts, test missing and
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
The archive audit checks every retained value in all structured extracts and the original
exact-copy survey bytes against the public files. It also regenerates and compares the
variable and value-label dictionaries. These local checks do not require uploading the archive.

`audit/knowledge_parity.csv`, `audit/knowledge_join_checks.csv`, and
`audit/knowledge_recode_counts.csv` are generated evidence.
`audit/knowledge_differences.csv` identifies changed cells;
`audit/knowledge_score_changes.csv` reports their effects on mean scores. The recode counts
show old values, new scores, missing statuses, and counts for each source item.

## Historical knowledge–attitude linkage

`make linkage` reproduces the former standalone linkage build. It reads the
checksummed historical `polardata.tab` and `attitude-indices.tab` under
`evidence/benchmarks/`, plus the 23 deposited `knowledge-battery.csv` files
already cataloged in poll packages. It does not consume the rebuilt canonical
knowledge scores, whose deliberate scoring differences are documented above.

The outputs in `output/linkage/` are `poll_crosswalk.csv`,
`knowledge_reliability.csv`, `respondent_items.csv`,
`knowledge_attitude_panel.csv`, and `summary.csv`. `manifest.csv` records their
shapes, checksums, and historical basis; formatted audit tables are in `tables/`.
`make check` builds these products and tests their exact values against the
pre-migration checksums in `tests/fixtures/linkage_checksums.csv`.

The crosswalk covers 28 polls. Reliability covers 23 polls and 177 items; mean
Cronbach's alpha is 0.495 at T1 and 0.561 at T2. The panel contains six linked
polls, 1,661 respondents, 43 poll-specific attitude indices, and 12,627 rows.
Each panel row is keyed by `dpnum`, `caseid`, and `attitude_index`; item rows are
keyed by `dpnum`, `caseid`, `item_id`, and `wave`.

Deposited item files have no respondent IDs. Positional links require equal
respondent counts and row-by-row agreement in T1 scores, T2 scores, and observed
gender. Other overlaps remain at poll level with mismatch reasons. This
validation preserves the historical linkage rule; it cannot distinguish two
respondents with identical observed validation fields. Missing item responses
are scored zero in this historical bridge; that convention is separate from the
canonical response tables' missingness policy. T1/T2 attitude values and group
identifiers are retained from the historical aggregate.

The bridge supports descriptive knowledge–attitude analysis. The older archive
lacks the control-arm and session-roster fields needed for the full causal
multiple-membership model. Downstream consumers should pin an upstream revision
and verify `manifest.csv`; a later source-based rebuild must explain any changes.

Reference manuscripts: [Cor and Sood](https://gsood.com/research/papers/guess.pdf)
(MD5 `3e80da54bdfaba3d5c7f9fa3a4303b4a`) and
[Luskin, Sood, Fishkin, and Hahn](https://gsood.com/research/papers/DeliberativeDistortions.pdf)
(MD5 `d1e62fbd13340ee1d75791a115f2ab59`). The reliability checks reproduce the
rounded values on page 17 of the Cor–Sood manuscript.


## Historical aggregate reconstruction

Release `v0.1.0` preserves the aggregate and historical linkage before source
reconstruction. `make polardata` begins the next stage: reproducing existing
values from reviewed poll-level responses. Poll-specific corrections require
user approval based on evidence in the [issue register](poll-issues.md); a broader
schema remains a later stage.
New discrepancies or questionable definitions discovered while building must be
recorded there with source/version, code location, affected records, numerical
impact, plausible explanations and the evidence still needed. Matching the old
aggregate does not clear a definition for substantive use. A failed parity check
is an investigation trigger; do not update the benchmark to make it pass.

The full build writes `output/polardata/polardata.parquet` and `polardata.tab`
with 6,084 rows and the 364 historical columns, plus the 129-row attitude catalog
and typed derived measures. All 21 polls build from public source materials;
`make compare-polardata` evaluates historical agreement separately. Generalized
variance has explicitly audited numerical exceptions in 24 groups, and export
row numbers are regenerated. Approved UKC-01 replaces baseline policing with the
post-wave children item in the UK Crime root-causes index. Comparison checks
verify the exact approved respondent values against the retained review evidence;
the original historical benchmark is unchanged. See the [architecture](architecture.md) and
[poll issue register](poll-issues.md) for samples, historical quirks and
comparison rules. No downstream consumer is switched by this release.
Historical benchmarks, canonical knowledge tables and linkage outputs remain
unchanged.

### UK Health worked example

The earlier `output/polardata/uk-health-1998.parquet` remains a regression
fixture produced from source: 230 rows and 73 columns. The following details
explain that subset; the full export includes the remaining registered fields.

`dpnum` is integer 2 and `caseid` is the survey's numeric `serial_m`, verified
equal to `serial_a`, unique and nonmissing. The 22 attitude columns are doubles, use
exact historical names `ukhealth.t{1,2}{suffix}` and take values in [0, 1] or
missing. Source wave suffixes 1 and 2 are retained. Their definitions are:

| Suffix | Raw source stems, separately in each wave | Historical formula |
|---|---|---|
| payhlt | payhlth | Three-category scaling; higher means individual payment |
| poora | poora | Five-category scaling; higher means more priority to the poor |
| option | options | Three-category scaling; higher means spending more |
| hlthfu | chgp, chvis, chmeal, chstay, chamb | Available-item mean of five-category scores |
| ctexpt | treata, cthart, ctnurs, ctbaby | Available-item mean of reversed five-category scores |
| pritre | ctfert, cthosp, ctcosm | Available-item mean of reversed five-category scores |
| severi | lista, severa | Scaled lista minus scaled severa, then empirical min–max scaling within each wave over all 230 source records with both answers |
| preven | preva | Five-category scaling; higher means more priority to prevention |
| dispub | ingova, inpuba | Available-item mean after mapping raw 1 and 3 to 1, raw 2 to 0.5 |
| avgdis | ingpa, indoca | Same folded recode and available-item mean, for doctor input |
| moresa | say | Five-category scaling; higher means more patient say |

Ordinary k-category scaling is `(raw - 1) / (k - 1)`; reversal is `1 - score`.
Raw -9 (not answered) and -8 (cannot choose), plus system missing values, become
missing. Any other unreviewed code stops the build. Available-item means use
only observed components; all-missing rows remain missing. The severity contrast
requires both components. Original raw missing codes remain in the immutable
survey and its dictionaries; this historical-format output does not distinguish
them. Denominator expansion belongs to the later schema review.

The builder reads original response fields from the public survey, not its stored
indices. The codebook and V6 index memo were consulted; their differences from the
historical aggregate remain recorded under UKH-01–04. In particular, the severity
direction, wave-specific rescaling, and non-monotonic discretion map are reproduced
without being endorsed or corrected. The supplied survey is already a merged
participant file; reconstructing its earlier field-file merge remains unfinished.

The comparison joins on unique `caseid` within dpnum 2 and requires the same 230
IDs on both sides. No unmatched or duplicated IDs are allowed. All 71 reconstructed non-key
columns must have identical missingness and values within absolute tolerance
`1e-10` before an output is written. `audit/polardata_parity.csv` records counts,
missingness differences, numerical differences and maximum absolute error for
each field. The benchmark is read only for this check; it supplies no rebuilt
values. A Parquet round trip must preserve values and types exactly.


The 23 demographic and attitude-summary fields preserve these historical definitions:

| Fields | Sources and definitions |
|---|---|
| female, minority | Numeric 0/1 from gender == 2 and ethnic != 1; the reviewed sample has only substantive codes 1:2 and 1:8 |
| ppage | Numeric age in years; all 230 are observed adults |
| educ4 | B11 educa codes 0/1/2/3/4 map to 0/.33/.66/1/.66; two -9 responses missing |
| educ3, bettered | Numeric 0/.5/1 from educ4 (intermediate categories collapse to .5); logical educ4 >= .66; preserve missingness |
| hhincome, highinc | Numeric (income - 1)/15 for bands 1:16, with -9/-8/-7 missing; logical final flag hhincome > .34 |
| pollgroup, groupsize | Numeric 2200 + source group (1:15); number of surveyed people in that group, including those with missing demographic answers |
| pfemale, pminority | Available-case group means of female and minority |
| varfemale, sdfemale | pfemale*(1-pfemale) and its square root; Bernoulli population variance convention |
| vareduc, sdeduc | Within-group sample variance of observed educ4, denominator n-1, and its square root |
| meaned, meanage | Available-case group means of educ4 and ppage |
| phighinc | Available-case group mean of the earlier flag hhincome > .8; deliberately preserves the historical difference from final highinc pending UKH-08 |
| pfemale_ind | (pfemale*groupsize-female)/(groupsize-1); all group sizes exceed one and gender is complete |
| attextreme | Available-item mean of abs(index-.5) over the 11 T1 indices before severity rescaling |
| meanxtreme | Available-case group mean of that historical attextreme |
| avgsd | Mean of the 11 within-group sample SDs using those same early index versions |

All group summaries are doubles repeated for members of the same discussion
group. There are 15 groups with 13–17 respondents each. The codebook's A1/A2,
B11/B17/B18 and Q18/Q23 items, the V6 index memo, the poll script, and merge
scripts 03/05/06 establish the definitions and assignment order. Issues UKH-07–10
record the retained index inventory, differing income thresholds, attitude-summary
versions and the knowledge-precision question. This output replaces the
initial attitudes-only partial file; no old values are dropped or revised.
Entropy, generalized variance and remaining poll descriptors are still outside
this partial reconstruction.


The next 26 fields reproduce historical knowledge and peer quantities from the
six raw Q9A–F responses. Keys are false/true/true/false/false/false (numeric
0/1/1/0/0/0) in both waves. Raw -9/-8/-1 and system missing score zero, preserving
the original six-item denominator. Other codes stop the build. These keys match
all stored correctness fields after the historical missing-to-zero conversion;
the Q9E printed-codebook conflict remains unresolved under UKH-12.

| Fields | Historical definition |
|---|---|
| t1know, t2know | Proportion correct among all six items in the respective wave |
| t1knowcor | Mean of itemwise T1-correct × T2-correct; uses departure answers to revise baseline correctness |
| grpgain | Across items not correct under that joint-wave rule, mean of other group members' joint-wave correctness; missing when no such items remain |
| meant1know, meant2know, meant1knowcor | Group means of the corresponding respondent scores, including zero-filled answers |
| meant1know_ind, meant1knowcor_ind | (group mean × group size - own score)/(group size - 1) |
| t1knowlevel | Poll mean after rounding individual T1 scores to two decimals and converting to 32-bit floating point, reproducing stored hknow1 exactly (UKH-10) |
| t1knowlevelcor, t2knowlevel | Poll means of unrounded t1knowcor and t2know |
| knowgain, knowgain2 | t2know minus t1know, or minus t1knowcor |
| logpk, loggain | Natural log of t1knowcor or grpgain, replacing only nonpositive values with .0001; preserve missing values |
| tobitpk | Numeric indicator t1knowcor > .6 |
| t1knowr, t2knowr, t1knowrcor, grpgainr | Historical UK Health aliases of t1know, t2know, t1knowcor and grpgain |
| meant1knowr, meant1knowrcor, t1knowlevelrcor | Aliases of the corresponding means without r |
| knowgainr, knowgainr2 | Aliases of knowgain and knowgain2 |

All 26 columns are doubles. The peer calculation follows `groupgain()` in the
archived `hlmFunc.R`, then its normalization in `03_data.R`. For a respondent
with an incorrect joint-wave answer, their contribution to that item's group
correctness sum is zero; dividing that sum by group size minus one therefore
excludes self. Averaging across only that person's incorrect joint-wave items
reproduces the merged `grpgain`. Twelve people have no such items and retain a
missing gain; fourteen have observed zero gains. No gain is imputed for a missing
denominator. UKH-11 records the interpretation and post-wave dependence.

Neither the aggregate nor stored survey scores/correctness fields supply these
rebuilt values. Tests remove the stored fields and require unchanged results,
check correctness against the archived fields separately, and verify all 230
reconstructed rounded scores against stored `hknow1`. The 32-bit conversion
reproduces the observed numeric representation; the original command that created
that representation remains unverified. Numeric parity does not adjudicate the
answer-key conflict or justify treating an adjusted score as a baseline-only
measure. Those investigations remain separate from reproduction.


## Broader respondent layer

The original knowledge outputs keep their existing samples and scoring rules.
`make respondents` creates separate tables in `output/respondent/` for all
reviewed source records within the 21-poll historical scope, covering all 848
historical respondent-field targets. Definitions preserve historical coding
except for explicitly approved corrections. UK Crime
`root_causes_t2@ukc-01-v2` uses only post-wave children, television and school
discipline responses; available-component averaging and the historical sample
are unchanged. Its raw input links and observed-component counts reflect these
three post-wave fields.
See the [stage contracts](architecture.md#respondent-reconstruction-before-aggregation),
[coverage](../audit/respondent_coverage.csv), and
[historical comparison](../audit/respondent_parity.csv).

UK–EU's source has 900 rows. Its historical `part == 1` view contains 238 people,
including the 14 excluded from the 224-person knowledge battery. `caseid`
identifies all 238 historical records exactly. Known group assignments cover
234 of those attendees; marker 99 remains unresolved for four. All source rows
remain in the broader table, including the 662 nonattendees; exclusion from an
attendance sample does not establish randomized control assignment.

Historical UK–EU formulas use raw factual responses with keys 1/2/2/1/2 for
`eusize`, `swiss`, `inctax`, `elect`, and `ptyapp`. Noncorrect and missing answers
score zero with a five-item denominator. The corrected baseline is the mean
of itemwise T1–T2 correctness products. Age, education, sex, ethnicity, political
interest, eight attitude measures, and their individual transformations follow
`uk_eu.R` and the later merge scripts. Explicitly absent fields stay missing.
The surprising attitude normalizations and ethnicity exclusion are preserved
and detailed in [UKEU-02–05](poll-issues.md#uk–eu-1995--uk-eu-1995).
