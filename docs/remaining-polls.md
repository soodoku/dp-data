# Remaining fourteen knowledge batteries

All 23 Cor-Sood batteries now have a build from reviewed poll-level survey
inputs. The fourteen covered here add 4,581 participants to the first nine.
The combined export contains 6,669 participants and 103,116 item-wave responses.
Source evidence determines the recodes; agreement with a deposited file is a
diagnostic, not an answer key.

## Coverage and comparison

Counts describe the selected knowledge sample, not every record in the published
survey. Item differences include a change between zero and missing.
A dash means that respondent-level comparison is not established.

| Poll | Participants | Items per wave | Known groups | Item differences | Comparison |
|---|---:|---:|---:|---:|---|
| Australia republic 1999 | 347 | 10 | 24 | 16 | Missing codes |
| BTP 2007 | 301 | 8 | 20 | 0 | Row-aligned |
| BTP general election 2004 | 250 | 9 | 15 | 7 | Refusals |
| BTP health/education 2005 | 454 | 6 | 30 | 0 | Two gender values differ |
| BTP online primaries 2004 | 328 | 7 | 16 | 25 | Refusals; 13 unknown groups |
| Bulgaria crime 2002 | 278 | 7 | 17 | 0 | Row-aligned |
| California 2011 | 396 | 5 | 25 | 2 | Five blank deposit tail rows |
| Europolis 2009 | 348 | 6 | 25 | - | Unordered exact match |
| NIC 1996 | 466 | 8 | 30 | 0 | Row-aligned |
| Tomorrow's Europe 2007 | 359 | 11 | 18 | - | Deposit has 335 |
| Vermont 2007 | 146 | 9 | 0 | 250 | Revised answer key |
| San Mateo 2008 | 239 | 8 | 26 | 113 | Correct answers and missing codes |
| Michigan 2009 | 310 | 9 | 16 | 294 | Missing responses |
| Denmark 2000 | 359 | 9 | 0 | - | Deposit has 363 |

The comparison code reports no person-level differences or score changes for
the three different-size samples. Europolis compares the multiset of complete
pre/post batteries and gender, including the multiplicity of repeated patterns.
This establishes distributional agreement, not a respondent-level linkage.
For the other polls, row-aligned comparison means the documented source ordering
reconstructs the historical battery ordering; the deposits contain no person IDs.

## Source files and disclosure

Each poll directory includes a survey, variable and value-label dictionaries,
and available original questionnaires or codebooks. Exact source paths and
SHA-256 values are in `metadata/survey_sources.csv`. Denmark has a separate
departure component in `metadata/survey_components.csv`.

Australia, BTP general election, Bulgaria, Europolis, and Vermont retain their
original SPSS or Stata bytes. The other nine publish structured Parquet extracts.
The exclusions enumerate contacts, names, location fields and unreviewed
verbatim responses in `metadata/source_field_exclusions.csv`; Denmark's
departure exclusions are in `metadata/component_field_exclusions.csv`.
All rows and retained values survive extraction. Retained character fields
are BTP 2007's group code and Michigan's five reviewed knowledge responses.
Dictionaries include excluded variable names and labels, but no excluded
response values.

Several archived poll-level files already merge survey waves or contain derived
columns: notably the BTP HLM files and Michigan's `mifin.dta`. This build scores
their original answer fields; it does not yet independently reconstruct those
earlier merges. Publishing these files is not a claim that every source is the
earliest field return. No aggregate such as `polardata` enters the build.

Canonical waves 1 and 2 mean the selected pre- and post-deliberation measurements.
They are not the source's literal wave numbers. California, Europolis,
Tomorrow's Europe, Vermont and Michigan use a source T3 post measurement;
Denmark joins T0 to T2. The item map preserves every original source column;
Denmark's `T2_` prefix identifies the departure file.

## Poll decisions

### Australia republic 1999

The source has 4,659 records. Groups 1 through 24 identify 347 attendees;
group 100 is not applicable. `caseid` is the respondent ID. The ten-item
battery combines six factual items and four proposed-change questions.
The wave-specific `dkchg` flag marks an unknown response across those four
change questions. Raw answers remain available even when the flag overrides
their correctness. Sixteen T2 code-99 responses are missing rather than
incorrect; zero-filled scores are unchanged.

### BTP 2007

The source has 1,501 records. `group == 1` selects 301 discussion-treatment
respondents, identified by `CaseID`; `Sgroup` identifies 20 small groups.
The eight PRE/POST factual questions use the questionnaire answer key.
Codes 99, 998 and 999 remain non-substantive. Every scored item and gender
indicator agrees with the deposit.

### BTP general election 2004

The 299-row archived HLM file supplies original answer fields.
`dop4part == 1` and nonmissing source `t1know` and `t2know` select
250 records. This reproduces the archived complete-score selection; it is
not an unrestricted attendee universe. The source remains available for
analyses choosing another inclusion rule.

The nine-item key uses the underlying response codes, not positions in
R factor levels. `caseid_original` identifies respondents and
`smgrpnumber` identifies 15 groups. Seven refusals coded -1 remain missing
instead of incorrect. The zero-filled scores do not change.

### BTP health and education 2005

All 454 records enter the six-item battery. `id` and `group` identify
respondents and 30 groups. Item scores agree with the deposit. Two source
gender values are missing; the deposit records female = 0. The build retains
these as unknown rather than classifying them as male.

### BTP online primaries 2004

`expcont == 1` selects 328 of 1,289 records. The original `id` is unique.
`groupnumc` supplies 315 assignments to 16 groups; 13 people remain in the
knowledge sample without memberships. Twenty-five refusals coded -1 remain
missing. Zero-filled scores are unchanged.

### Bulgaria crime 2002

The 278-row, seven-item crime battery belongs to the October 2002 poll, not
the 2007 Roma-policy poll. The crime questionnaire and the archived knowledge
index document identify this battery; the index document's means also match
the reconstructed scores. The event date is confirmed by
[Stanford's crime-poll record](https://deliberation.stanford.edu/news/deliberative-pollingr-crime-bulgaria).

The registry retains the distinct 2007 poll. The mixed Bulgaria archive
collection has no blanket poll assignment. The 2002 directory contains the
unchanged deposited battery, original survey and crime questionnaire.
`id` identifies respondents and `group0` identifies 17 groups.
All scored items and gender indicators match the deposit.

### California 2011

`part == 1` marks 412 of 472 source records; `t2t3filter == 1` selects
396 of them. The source `id` is complete and unique in this sample; `idnum`
is not. The build uses departure `t3_GroupNumber` and baseline gender. The
401-row deposited battery has five entirely missing rows at the end. Its
first 396 rows align with the selected source in order, including missingness.
The original deposit is kept intact; those five rows are excluded only from
the comparison.

Democratic control is code 2 at baseline but code 1 in the post questionnaire.
Post code 3 (Independent) is a substantive wrong answer for both party-control
questions. The historical battery marks it missing for departure Senate in
two rows, while the maintained build scores it incorrect. Both zero-filled
scores are unchanged. The 16 source participants excluded by `t2t3filter`
remain a separate sample-policy question.

### Europolis 2009

`GROUP_T1BIS == 1` selects 348 of 4,384 records. `UniqueID` is the
source identifier and `SMALL_GROUPw3` supplies 25 groups. SPSS declares
997, 998 and 999 as user-missing codes; the raw codes survive and correctness
is missing. The six-item pre/post batteries and gender agree exactly as a
multiset with the deposit. Available IDs and alternative archived files do
not establish the deposit's row ordering.

### NIC 1996

`PART == 1` selects 466 of 911 records and `RGROUP2` supplies 30 groups.
One attendee lacks `CASEID`; the explicit `source-row-1` fallback keeps
that attendee and does not imply a cross-file person identifier. Small SPSS
floating-point deviations are rounded for ID and answer-code lookup only,
with a tolerance below 1e-8; raw answer values remain unchanged.
All eight scored items at both waves and gender match the deposit.

### Tomorrow's Europe 2007

`t3part == 1` identifies 359 departure respondents in the 3,550-row source.
All have departure group `t3grp`, covering 18 groups. The earlier
`group_no` exists for only 335 of these respondents, the size of the deposit.
That coincidence does not prove the deposited sample or its ordering.
The build retains the full departure sample.

The two party-placement items have different numeric origins: the baseline
uses codes 1 through 11 for labels 0 through 10; the departure uses 0 through
10 directly. The key accounts for this shift. Two departure Q19 responses
with out-of-questionnaire codes 0 or 6 are invalid/missing rather than
substantive wrong answers.

### Vermont 2007

`PART == 1` selects 146 of 750 records. `CASEID` identifies respondents.
No verified group field or roster is available, so the build creates no
memberships.

The original starred departure questionnaire marks 50% (code 3) as the
efficiency answer; the archived recode instead uses 20% (code 2).
The renewable-energy question has two starred answers, 15% and 25%.
The current key accepts both and explicitly retains that ambiguity. This is
a provisional interpretation of the supplied key, not an independent
resolution of the factual question. The source's baseline Q77 value labels
also appear to describe the next question; the questionnaire supplies its
actual surcharge response scale.

Together these decisions change 250 item-wave cells. Mean zero-filled
knowledge falls from 23.21% to 22.22% at baseline and from 62.94% to 60.12%
at departure. These changes are conditional on accepting both starred
renewables answers. The build also exports `audit/knowledge_key_sensitivity.csv`:

| Renewables key | Baseline mean | Departure mean |
|---|---:|---:|
| Both starred answers | 22.22% | 60.12% |
| Only 15% | 21.00% | 57.00% |
| Only 25% | 20.24% | 56.47% |

All three scenarios retain the corrected efficiency key and the nine-item
zero-filled denominator. The departure mean varies by 3.65 percentage points
across these interpretations; the original materials do not resolve which
star was intended.

### San Mateo 2008

The build uses the earlier 1,806-row `smdp 3-18-08.dta`, not the reduced
239-row `sm_caseid` analysis file. `participant == 1` selects 239 people.
`PARTICIPANTID` is unique; `RESPNUM` is not. Sorting the former reconstructs
the battery order, and `GRP` supplies 26 groups.

The archived post-wave recode compares two labelled answers with the text
"5". Their labels instead describe 950,000 and more than 75%.
The underlying code 5 is correct on both questions, as confirmed by the
questionnaires and source correctness fields. The correction recovers 111
correct responses (46 on Q20 and 65 on Q26). Two out-of-range responses
become missing. Baseline scores are unchanged; 92 participants' post scores
rise, and the mean rises from 25.89% to 31.69%, or 5.81 percentage points.

### Michigan 2009

Observed `postit` selects 310 of the 610 merged records. This agrees with
the historical first-310-row selection but does not depend on input order.
`postit` and `group_number` provide respondent IDs and 16 groups.

Five departure knowledge answers are text. The published extract retains
their reviewed responses, and the item key enumerates accepted spellings.
Lookup removes case and punctuation but preserves the original `raw_text`.
An unseen response stops the build instead of becoming an implicit zero.
Among the 294 differences, 291 e/E responses mean "couldn't say", one F is
invalid, and two written Senate responses ("SC" and "same") are ambiguous.
These become missing, leaving zero-filled scores unchanged.

### Denmark 2000

The baseline file has 1,702 rows; the departure file has 359. All 359
departure `DELNR` values match distinct nonmissing baseline `delnr`
values. The join never matches missing IDs and asserts its cardinality.
The baseline has 390 nonmissing participant identifiers; it does not
supply another four departure interviews. The archived joined R object
also has 359 departure respondents, so the deposit's 363 remains unresolved.

The output uses nine items at T0 and T2 and baseline gender. No verified
group roster is available. Both source extracts, their separate dictionaries,
and the English questionnaire are published.

## Consequences for downstream users

The source build is available for every deposited knowledge battery, but it
does not yet rebuild the full attitude aggregate, every control battery, or
every original field-file merge. Group analyses must account for 522 missing
memberships: 4 UK-EU, 13 online primaries, 146 Vermont and 359 Denmark.

The new differences change measurement inputs; they are not revised estimates
from the Cor-Sood paper or the convergence papers. Those models have not been
rerun here, and no downstream repository has been switched automatically.
Consumers should pin this repository's commit, join on original identifiers
where available, and retain the sample and answer-key qualifications above.
