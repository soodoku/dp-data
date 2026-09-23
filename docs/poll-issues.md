# Poll-level issue register

Review date: 2026-09-23. Scope: the 34 polls in the current registry, with detailed
coverage of the 23 existing knowledge builds and the UK Health attitude pilot.

## Decision for this pass

Preserve current scoring, sample definitions, and downstream results. This file
records evidence and review tasks; it does not authorize a recode. The provisional
UK Health attitude implementation was set aside. Existing upstream knowledge
changes predate this review and are explicitly identified below; neither adopting
those changes downstream nor reverting them is part of this pass.

A surprising transformation can be deliberate. Before changing it, recover the
fielded questionnaire, codebook, index memorandum, original syntax, and the
specific file version actually used. Distinguish a computational discrepancy
from a direction convention, a different estimand, a sample restriction, or a
label that drifted away from the intended definition. Numerical agreement does
not establish validity, and disagreement does not establish an error.

This is an inventory of currently known issues and coverage gaps, not a claim
that every field or every questionnaire has been audited. “No discrepancy in the
knowledge comparison” does not clear attitudes, demographics, weights, or joins.

## How to read the entries

- **Preserve / review:** an observed behavior or unresolved interpretation. No
  change is made here.
- **Existing upstream divergence:** behavior already present in the maintained
  knowledge build, relative to the immutable deposited battery. Its downstream
  consequences still need separate review.
- **Coverage gap:** the required build, instrument verification, or linkage has
  not been established. This does not mean the data do not exist in the archive.
- **Rejected diagnosis:** additional evidence undermines an earlier proposed
  criticism. Keep that evidence so the same mistake is not repeated.

For each proposed future change, record the exact source/version, field and
question number, current formula, proposed formula, sample and missingness
consequences, before/after numerical values, competing explanations, and the
result of attempting to disprove the concern. Re-run downstream estimates only
after the input-level difference is explained. Preserve old source bytes.

## Evidence and verification boundaries

The numerical overview comes from [knowledge parity](../audit/knowledge_parity.csv),
[score changes](../audit/knowledge_score_changes.csv),
[join checks](../audit/knowledge_join_checks.csv), and the existing
[answer-key sensitivity output](../audit/knowledge_key_sensitivity.csv).
Source checksums and paths are in [survey sources](../metadata/survey_sources.csv),
[source files](../metadata/source_files.csv), and
[item definitions](../metadata/knowledge_items.csv).

Primary materials re-opened in this pass include the UK Health codebook, index
memo and report; UK Crime and UK–EU codebooks; Monarchy codebook; Vermont starred
post questionnaire; Michigan post questionnaire; and the full San Mateo
questionnaire plus its shorter post supplement. Reading a questionnaire verifies
wording and response categories, not necessarily the factual answer key or which
version was administered. Other polls below cite existing audits and name the
instruments that still require a fresh item-by-item review.

Local `vault/` links below require the source archive. Do not quietly replace an
unavailable instrument with a similarly named document. In particular, the UK
Health PDF is a **final project report**, not a complete questionnaire, and the
published San Mateo post document is a short supplement without the relevant
knowledge questions. The limitations are part of the evidence.

## Overview of existing knowledge builds

Counts describe the selected knowledge samples, not the complete fielded samples.
An item difference includes zero-versus-missing differences; it is not necessarily
a changed knowledge score. “Unlinked” is not zero differences.

| Poll | Selected people | Deposited people | Item-wave columns | Differing cells | Gender differences | Comparison |
|---|---:|---:|---:|---:|---:|---|
| uk-health-1998 | 230 | 230 | 12 | 0 | 0 | row-aligned |
| northern-ireland-2007 | 124 | 124 | 14 | 0 | 0 | row-aligned |
| uk-crime-1994 | 299 | 299 | 14 | 0 | 0 | row-aligned |
| uk-eu-1995 | 224 | 224 | 10 | 0 | 0 | row-aligned |
| uk-monarchy-1996 | 258 | 258 | 16 | 58 | 0 | row-aligned |
| uk-general-election-1997 | 275 | 275 | 30 | 0 | 0 | row-aligned |
| cpl-1996 | 216 | 216 | 14 | 0 | 0 | row-aligned |
| swepco-1996 | 232 | 232 | 10 | 0 | 0 | row-aligned |
| wtu-1996 | 230 | 230 | 10 | 0 | 0 | row-aligned |
| australia-republic-1999 | 347 | 347 | 20 | 16 | 0 | row-aligned |
| btp-2007 | 301 | 301 | 16 | 0 | 0 | row-aligned |
| btp-general-election-2004 | 250 | 250 | 18 | 7 | 0 | row-aligned |
| btp-health-education-2005 | 454 | 454 | 12 | 0 | 2 | row-aligned |
| btp-online-primaries-2004 | 328 | 328 | 14 | 25 | 0 | row-aligned |
| bulgaria-crime-2002 | 278 | 278 | 14 | 0 | 0 | row-aligned |
| california-whats-next-2011 | 396 | 401 | 10 | NA | NA | unlinked-sample-difference |
| europolis-2009 | 348 | 348 | 12 | NA | NA | unordered-exact-match |
| nic-1996 | 466 | 466 | 16 | 0 | 0 | row-aligned |
| tomorrows-europe-2007 | 359 | 335 | 22 | NA | NA | unlinked-sample-difference |
| vermont-energy-2007 | 146 | 146 | 18 | 250 | 0 | row-aligned |
| san-mateo-2008 | 239 | 239 | 16 | 113 | 0 | row-aligned |
| michigan-2009 | 310 | 310 | 18 | 294 | 0 | row-aligned |
| denmark-euro-2000 | 359 | 363 | 18 | NA | NA | unlinked-sample-difference |

The 23 builds contain 6,669 participants and 103,116 item-wave responses.
There are 763 reported cell differences among the row-aligned comparisons and
two gender differences. These totals exclude the three unequal-size comparisons
and the unordered Europolis comparison. There are 522 people without known
memberships: UK–EU 4, online primaries 13, Vermont 146, and Denmark 359.

## UK Health 1998 — uk-health-1998

### UKH-01: Severity direction is documented; do not label it a coding error

**Status:** preserve; rejected diagnosis of an accidental subtraction reversal.

**Evidence rechecked:** the original
[British Health Indices V6 FINAL, section 8](<../vault/cdd/data/british_health/indices/British Health Indices V6 FINAL.doc>)
explicitly specifies `LISTA - SEVERA`. The
[British Health Codebook](<../vault/cdd/data/british_health/British Health Codebook.txt>)
identifies `LISTA1/LISTA2` as Q16A (waiting-list position) and
`SEVERA1/SEVERA2` as Q15A (severity of condition). Each uses five agreement
categories. The memorandum describes the intended contrast and prints its
paired-wave summary. In contrast, the published survey dictionary's
`t1severi`/`t2severi` labels say that 1 corresponds to severity.

**Observed behavior:** after scaling each component from 1–5 to 0–1, the
survey's stored index equals `lista - severa`, requiring both answers. Larger
values consequently indicate more relative agreement with waiting-list priority.
The original memorandum supports this construction; a conflicting later label
is not evidence that the formula should be reversed.

**Consequence:** reversing direction is a substantive reinterpretation. A
fixed-scale reversed-direction candidate differs from the current aggregate in
119 of 204 nonmissing T1 observations and all 204 nonmissing T2 observations.
Those counts combine the direction choice with the scale issue in UKH-02; they
are not counts of errors. No downstream model was re-estimated under that candidate.

**Before any change:** trace how each paper defines the contrast, inspect the
syntax that produced the stored index, and determine whether the label or the
intended interpretation changed between versions. Retain the documented
subtraction unless that review establishes a reason to change it.

### UKH-02: Separate empirical rescaling changes the cross-wave scale

**Status:** preserve / review; transformation confirmed, inferential consequence
not yet evaluated in downstream models.

**Evidence:** [historical merge script 05_fix_data.R](../vault/cdd/merge_data_scripts/05_fix_data.R)
separately applies `zero1()` to `ukhealth.t1severi` and `ukhealth.t2severi`.
Direct reconstruction from raw answers reproduces the aggregate with
`(d - min(d)) / (max(d) - min(d))`, independently in each wave, where
`d = lista - severa` on component 0–1 scales.

| Quantity | T1 | T2 |
|---|---:|---:|
| Nonmissing respondents | 204 | 204 |
| Observed unscaled minimum | -1 | -1 |
| Observed unscaled maximum | 1 | 0.5 |
| Current aggregate mean | 0.4185049020 | 0.5130718954 |
| Candidate fixed-scale mean, `(d + 1) / 2` | 0.4185049020 | 0.3848039216 |
| Observations differing under that candidate | 0 | 196 |

These are **separate-wave available-case means**, not paired-person changes.
The same raw contrast is assigned a different numerical value depending on the
wave's observed range. A fixed-scale candidate retains the documented direction
but changes the normalization. That may affect cross-wave comparisons, while
some within-wave standardized statistics can be invariant to affine changes.
Neither observation settles which normalization the authors intended.

**Before any change:** recover the intended definition of `zero1`, the analysis
population over which it was evaluated, whether wave-specific scaling was an
explicit harmonization choice, and the consequences for paired comparisons,
extremity, within-group dispersion and downstream regression coefficients.
Do not combine a sign change and a normalization change in one unexplained edit.

### UKH-03: Government/public input has a non-monotonic stored recode

**Status:** preserve / review; values verified, original recoding rationale unresolved.

**Primary evidence:** codebook Q18A_A (`INGOVA`) and Q18A_E (`INPUBA`) distinguish
none, some, and all/most input. The V6 index memo, section 11, describes an average
of the two items and says the high end denotes the most say. The
[final project report](<../vault/cdd/data/british_health/uk.health.pdf>), section on
who decides, separately reports these three categories. The raw survey value
labels assign codes 1, 2 and 3 respectively.

**Observed behavior:** in both waves, stored `t?ingova` and `t?inpuba` map raw
codes 1 and 3 to 1, code 2 to 0.5, and special missing codes to missing.
Averaging available stored components exactly reproduces aggregate `t?dispub`.
The archived R script contains later assignments to some T1 components, but its
T1 index assignment is commented out; reading the last component assignment
alone would misdescribe the actual aggregate. Reconstruct the executed dependency
chain before deciding which syntax is authoritative.

| Quantity | T1 | T2 |
|---|---:|---:|
| Nonmissing index observations | 215 | 200 |
| Raw code-1 responses across the two items | 173 | 119 |
| Current index mean | 0.7709302326 | 0.7050000000 |
| Candidate monotonic mean, codes 1/2/3 → 0/0.5/1 | 0.3383720930 | 0.3775000000 |
| Index observations differing under candidate | 126 | 93 |

The response counts count **item answers**, not distinct people. Candidate means
use the same available-item rule and do not change the nonmissing index counts.
They are diagnostic alternatives, not adopted corrections or new paper estimates.
The V6 memo's high component means are consistent with a long-standing construction,
so this should not be dismissed as a new transport or parser error.

**Before any change:** retrieve the original SPSS/Stata recode syntax and all
index-document versions; check whether a non-monotonic or extremity-oriented
construct was deliberate, whether labels were reversed or reused, and which
version generated published tables. Preserve raw answers and the current score.

### UKH-04: Different index versions and orientations coexist

**Status:** preserve / review; not every stored derived field is the aggregate input.

The V6 memo's payer index says 1 means government pays. The historical aggregate
instead matches raw `PAYHLTH` codes 1/2/3 mapped to 0/0.5/1, so its high end means
individual payment. Both are legitimate orientations if named and interpreted
consistently. Compare question Q5 and the survey's derived-field label before
changing a sign based on an index name alone.

The memo describes multiple expensive-treatment and privatization versions;
source variable labels also describe intermediate composite indices. The archived
R script rebuilds expensive-treatment opposition as the available-item mean of
four components (`treata`, `cthart`, `ctnurs`, `ctbaby`) and privatization opposition
as the available-item mean of three (`ctfert`, `cthosp`, `ctcosm`). A stored survey
index with a similar name may use a different composition or weighting. Equal
names do not establish equal estimands.

All nine final aggregate attitude variables in both waves can be reconstructed
from the 230 raw survey records to absolute tolerance `1e-10`, including the
historical behavior in UKH-01–03. All respondent IDs match `serial_m` and
`serial_a` in this file; this equality must be checked rather than assumed for
other files. Reconstruction is evidence about provenance, not endorsement of
every definition.

| Index suffix | Valid T1 | T1 mean | Valid T2 | T2 mean |
|---|---:|---:|---:|---:|
| payhlt | 204 | 0.1813725490 | 217 | 0.1105990783 |
| poora | 223 | 0.6165919283 | 218 | 0.5493119266 |
| option | 218 | 0.8692660550 | 223 | 0.8878923767 |
| hlthfu | 225 | 0.3304444444 | 222 | 0.3441066066 |
| ctexpt | 225 | 0.6628703704 | 221 | 0.6339555053 |
| pritre | 224 | 0.5338541667 | 217 | 0.4865591398 |
| severi | 204 | 0.4185049020 | 204 | 0.5130718954 |
| preven | 212 | 0.6226415094 | 214 | 0.5876168224 |
| dispub | 215 | 0.7709302326 | 200 | 0.7050000000 |

**Before any change:** give each distinct index definition a versioned identity,
record included items and weights, and determine which definition each downstream
analysis needs. Preserve available-item denominators; do not replace missing
answers with zero merely to simplify an index mean.

### UKH-05: Education is an ordinal school-qualification measure

**Status:** preserve / review of interpretation, not a demonstrated coding defect.

The aggregate `educ4` maps raw `educa` as follows: code 0 → 0 (88 people),
1 → 0.33 (21), 2 → 0.66 (66), 3 → 1 (49), and 4 → 0.66 (4).
Two code -9 responses are missing. The codebook's B11 identifies code 3 as
A-level/S-level/AS-level or equivalent, and code 4 as an overseas school-leaving
qualification. This measure should not silently become a university-degree flag.
`educb`/B12 separately records later qualifications, including degree code 9.

The archived R script contains several abandoned assignments before the final
school-qualification recode. Its factor-level integer conversions must be traced
against the labels used at execution time, not copied as raw numeric-code rules.
**Next check:** identify whether each downstream model uses ordinal attainment,
a degree indicator, or a poll-standardized education score; retain the raw
qualification categories so those choices can be made explicitly.

### UKH-06: Universe, missingness and earliest-source boundaries

The published survey has 230 rows; the codebook prints counts from a larger
fielded universe for some questions. That is evidence of a different file/sample,
not proof that the 230-row survey is corrupted. Its stored indices are derived
columns and should be comparison evidence when reconstructing raw-answer scores.
The six-item knowledge battery currently matches the deposit at both waves.

**Next check:** identify participant/control/initial interview files and the
original wave merge; record eligibility and actual interview completion separately.
All-missing post answers alone do not establish why an interview is absent.
No complete-population claim should be based on the attendee-only knowledge export.

## UK Crime 1994 — uk-crime-1994

### UKC-01: An archived post-wave component reads another item at baseline

**Status:** preserve / review; already cataloged as documented-not-implemented in
[source findings](../metadata/source_findings.csv).

The [archived UK Crime script](../vault/cdd/scripts/uk_crime.R), line 143,
assigns `timchld2r` from `morecop1`, then includes it in `rootcauset2`.
The [codebook](../data/uk-crime-1994/codebook.txt), rechecked here, identifies
`TIMCHLD2` as post-wave QQ1d, time with children, and `MORECOP1` as baseline Q1j,
more police. They differ in both construct and wave.

**Unknown:** whether this script version generated the published aggregate,
whether another script overwrote it, and how many final index observations or
estimates would change. Do not infer the aggregate is wrong from this line alone.
**Next check:** reconstruct the executed `rootcauset2` chain, compare both source
fields respondent by respondent, inspect the index memo's item membership, and
recompute downstream quantities only after establishing the lineage.

### UKC-02: Knowledge sample and respondent-ID conventions

**Status:** preserve; important contract for future broader exports.

The source has 300 attendees but the historical knowledge sample selects 299
with a group assignment. All 869 source records remain available. Current
knowledge scores match the deposit; adding the ungrouped attendee would change
the analysis universe rather than repair the same estimator.
159 raw IDs have floating-point noise up to roughly `1.5e-12`. Current IDs round
within `1e-8`; truncation can collide. Archived generated IDs use `10000 + row`.
**Next check:** provide an explicit legacy-ID crosswalk and retain membership
missingness separately from respondent eligibility. The codebook and
[existing audit](uk-crime-eu.md) support these contracts.

## UK–EU 1995 — uk-eu-1995

**UKEU-01 — preserve sample and unknown-group distinctions.** The survey contains
238 attendees; 14 have all five post knowledge items coded -1, inapplicable.
The current build preserves the historical 224-person knowledge selection.
Its 15 known groups cover 220 people. The [codebook GROUP section](../data/uk-eu-1995/codebook.txt),
re-opened here, explicitly identifies IDs 1008, 3132, 4316 and 5022 as people
without supplied group assignments who were assigned marker 99. Treating 99 as a
sixteenth deliberating group would impose a false shared-group relationship.
Knowledge scores match the deposit; group-based downstream effects of this
membership interpretation have not been re-estimated here.

**Next check:** inspect wave eligibility before expanding the sample, preserve
all 238 source attendees in a broader respondent table, and retain the four
missing group assignments. Review questionnaire-specific negative and refusal
codes separately by wave; do not adopt one cross-poll missing-code list.

## UK Monarchy 1996 — uk-monarchy-1996

**UKM-01 — existing upstream divergence; re-verify the post-wave field.** The
current build reads post `R5C`; the archived recode and deposited post item
reproduce baseline `Q5C`. The [codebook](../data/uk-monarchy-1996/codebook.doc),
re-opened here, distinguishes `HEADCOM1`/Q5c from `HEADCOM2`/W5c for the
Commonwealth item. Connect those codebook aliases to the concrete source fields
using [variables](../data/uk-monarchy-1996/variables.csv) before adopting a change.
The existing comparison reports 58 differing cells and 55 changed T2 scores;
mean T2 knowledge moves from 79.893% to 79.651% (about -0.242 percentage points).
T1 is unchanged. These are input-score effects, not revised paper estimates.

**UKM-02 — source-scoped identifiers.** The 258 attendees in groups 2–16 have
`source-row-...` identifiers because no source column uniquely identifies the
full file. They are not validated person keys across other files. The eight-item
battery omits an additional succession item; do not add it just because it is
available. Recheck questionnaire version and the intended battery definition.
See the [existing audit](monarchy-election-utilities.md).

## UK General Election 1997 — uk-general-election-1997

**UKGE-01 — preserve eligibility and scale-specific scoring.** `filter == 1`
selects 275 attendees. Serial 4416 has a group but no T2 questionnaire and is
outside that sample. This is an eligibility distinction, not automatically a
missing-record error. Three factual and twelve party-placement items form the
battery. Negative codes -8/-9 are handled as missing; low substantive placements
are not missing. Published TRUE/FALSE item values must be parsed as such.

Existing knowledge and gender comparisons match. Before rebuilding attitudes or
expanding eligibility, re-read [codebook.txt](../data/uk-general-election-1997/codebook.txt)
and the field labels for the filter and each placement scale. The source
codebook was not newly audited item by item in this pass. Preserve party-specific
placement ranges rather than impose a generic “correct category” rule.

## CPL 1996 — cpl-1996

**CPL-01 — preserve missing-code provenance across file versions.** The build
uses `cpl.sav`; the later `cpl2.sav` carries equivalent attendee answers after
759 explicit code-99 responses in the earlier file are treated as missing.
The [codebook](../data/cpl-1996/codebook.txt) identifies 99 as don't know.
Correctness stays missing in response tables; the explicitly named zero-filled
score counts it as zero. Seven-item scores and gender match the deposit for
216 participants in 16 groups.

**Next check:** re-read the missing-code specification and both version
transforms before collapsing response reasons. Wider sample and attitude fields
remain outside this parity result. Evidence is in the existing utilities audit;
this pass did not repeat its entire instrument audit.

## SWEPCO 1996 — swepco-1996

**SWE-01 — early-file readability limits are extraction limits.** The maintained
build uses `swepco2.dta` for 232 participants, five items and 14 groups. Earlier
portable files were unreadable in the prior audit with both haven and foreign;
missing reasons already collapsed in the readable file cannot be recovered by
inventing labels. Scores and gender match the deposit.

Before declaring original missingness unavailable, revisit the earlier portable
files with documented reader versions and inspect the archive's recode syntax.
Re-read [codebook.txt](../data/swepco-1996/codebook.txt) for the actual item scales.
The current result is limited to the readable source, not proof that an earlier
source does not exist.

## WTU 1996 — wtu-1996

**WTU-01 — same early-source limitation as SWEPCO.** `wt2.dta` supplies 230
participants, five items and 14 groups. Earlier portable-file reading failed in
the existing audit. Preserve uncertainty about already-collapsed missing codes.

**WTU-02 — omitted category is not necessarily a deposited-score error.** Raw
`USE2 = 4` denotes wholesale. The archived R recode omits it, but the deposited
battery already treats the two observed cases, 20000100 and 20001180, as incorrect.
Current scores match. Before changing anything, consult the
[codebook](../data/wtu-1996/codebook.txt), original correctness field and executed
script version. This is a useful counterexample to treating every suspicious
historical line as an error in published data.

## Australia republic 1999 — australia-republic-1999

**AUS-01 — existing missingness divergence; score parity.** There are 347 attendees
in groups 1–24 out of 4,659 source rows; group 100 is inapplicable. The ten-item
battery combines six factual items and four proposed-change questions. The
wave-specific `dkchg` flag can override correctness on those four items while
raw answers remain preserved. Sixteen T2 code-99 responses differ from the
binary deposit as missing rather than incorrect; zero-filled scores do not move.

**Next check:** re-read [codebook.doc](../data/australia-republic-1999/codebook.doc)
and locate the exact routing/flag instruction before changing override rules.
Do not interpret zero score differences as equivalence for item-response models,
which may use missingness differently. Instrument review here relies on the
existing audit, not a fresh examination of each question.

## BTP 2007 — btp-2007

**BTP07-01 — selection variables with similar names have different roles.**
`group == 1` selects 301 discussion-treatment respondents from 1,501 records;
`Sgroup` gives the 20 small groups and `CaseID` identifies people. Codes 99, 998,
and 999 are non-substantive. All eight-item scores and gender match the deposit.

**Next check:** consult [codebook.pdf](../data/btp-2007/codebook.pdf), the fielded
PRE/POST questions, and the study assignment documentation before treating the
selection flag as a discussion-group ID or treating attendance as randomized
assignment. The remaining response arms should be represented in a broader
schema, not lost because this knowledge build selects one arm.

## BTP General Election 2004 — btp-general-election-2004

**BTPGE-01 — historical complete-score selection is an explicit dependency.**
The 299-row HLM source selects 250 records using `dop4part == 1` and nonmissing
source `t1know`/`t2know`. This reproduces historical eligibility but still depends
on already-derived source columns. It is not yet an independent reconstruction
of the earliest wave merge or a census of attendees. `caseid_original` and
`smgrpnumber` identify people and 15 groups.

**BTPGE-02 — existing missingness divergence.** Seven code--1 refusals remain
missing rather than incorrect. Zero-filled scores are unchanged. Recheck
[questionnaires.doc](../data/btp-general-election-2004/questionnaires.doc), the
code-to-label map, and the complete-score filter's purpose. Nine-item scoring
must use actual codes, not R factor positions. Do not expand the sample merely
to reconcile the 250-person battery with a smaller aggregate sample.

## BTP Health and Education 2005 — btp-health-education-2005

**BTPHE-01 — existing demographic missingness divergence.** All 454 source rows
enter the six-item battery and 30 groups. Item scores match, but two source gender
values are missing where the deposit records female = 0. That is two unknown
values versus a binary assignment; it is not evidence about those persons' gender.

**Next check:** revisit the original merged-file construction and both
[pre](../data/btp-health-education-2005/questionnaire-pre.doc) and
[post](../data/btp-health-education-2005/questionnaire-post.doc) instruments.
Establish whether another wave supplies these values and whether the deposit's
coding was deliberate. Keep the present upstream/deposit distinction explicit;
do not silently replace downstream values in this documentation pass.

## BTP Online Primaries 2004 — btp-online-primaries-2004

**BTPOP-01 — existing missingness and membership qualifications.** `expcont == 1`
selects 328 of 1,289 source records; original `id` is unique. There are 315 known
memberships in 16 groups and 13 people without a known group. Twenty-five code--1
refusals become missing in the existing build; zero-filled scores match.

**Next check:** inspect [questionnaires.doc](../data/btp-online-primaries-2004/questionnaires.doc)
and original assignment/session logs. Determine whether the 13 missing group
values are true absence, unrecorded assignment, or a merge limitation before
excluding people or creating a synthetic group. Keep invitee assignment,
attendance and analytic inclusion distinct.

## Bulgaria Crime 2002 — bulgaria-crime-2002

**BGC-01 — poll identity is a provenance issue.** The 278-person, seven-item
battery belongs to the October 2002 crime poll, not the distinct 2007 Roma-policy
poll. Current item scores and gender match, with 17 groups. The source archive
contains material for more than one event and must not receive a blanket poll ID.

**Next check:** re-open [questionnaire.doc](../data/bulgaria-crime-2002/questionnaire.doc)
and [knowledge-index.doc](../data/bulgaria-crime-2002/knowledge-index.doc), checking
study date, topic and printed summaries against the source records. The prior
audit made that identification; this pass has not independently re-established
all external event documentation. Preserve the separate 2007 registry entry.

## California 2011 — california-whats-next-2011

**CA-01 — unresolved sample mismatch.** `t2t3filter == 1` with observed `part`
selects 396 of 472 source records, versus 401 deposited batteries. `id` is unique
in that sample; `idnum` is not. Do not manufacture five people or assume a row
link to obtain parity. The prior comparison deliberately reports no person-level
score differences for unequal samples.

**CA-02 — wave-dependent response codes.** The prior audit records Democratic
control as code 2 before and code 1 afterward. Post code 3, Independent, is a
substantive wrong answer; one historical recode excluded it. Re-read the
[pre](../data/california-whats-next-2011/questionnaire-pre.doc),
[post](../data/california-whats-next-2011/questionnaire-post.doc) and
[codebook](../data/california-whats-next-2011/codebook.pdf) together before deciding
whether a changed value is a key error, a questionnaire-version change, or a
sample difference. Quantification against individual deposited rows remains
unestablished. Group membership uses the departure group, not an assumed stable
baseline group.

## Europolis 2009 — europolis-2009

**EURO-01 — distributional parity is not a person link.** `GROUP_T1BIS == 1`
selects 348 of 4,384 source rows. `UniqueID` and `SMALL_GROUPw3` supply people and
25 groups. The six-item pre/post batteries plus gender exactly match the deposit
as a multiset, including repeated-pattern multiplicities; their order does not.
Sorting or matching identical score profiles cannot prove respondent identity.

**Next check:** inspect [codebook.txt](../data/europolis-2009/codebook.txt),
[post questionnaire](../data/europolis-2009/questionnaire-post.doc), and original
exports or scripts with persistent IDs. Preserve 997/998/999 as source missing
reasons. Do not append deposited rows to attitudes using an arbitrary permutation.
No paired person-level difference count is asserted here.

## National Issues Convention 1996 — nic-1996

**NIC-01 — one source-scoped fallback ID and battery definition.** `PART == 1`
selects 466 of 911 records and `RGROUP2` identifies 30 groups. One attendee lacks
`CASEID` and retains a source-row fallback. Eight-item knowledge and gender match
the deposit. A larger aggregate battery is a different measurement definition;
matching poll names does not authorize a person-level join across those scores.

**Next check:** re-read [questionnaire.pdf](../data/nic-1996/questionnaire.pdf),
[codebook.txt](../data/nic-1996/codebook.txt), and original battery definitions.
Determine what identifies the missing-ID attendee in other waves; do not treat
source-row fallback as a transferable ID. Retain raw floating-point codes while
using the documented tolerance for integer lookup.

## Tomorrow's Europe 2007 — tomorrows-europe-2007

**TE-01 — unresolved eligibility/order mismatch.** `t3part == 1` yields 359
departure respondents from 3,550 source rows, versus 335 deposited batteries.
The earlier `group_no` happens to be observed for 335; that coincidence does not
prove the deposited selection or ordering. The departure `t3grp` is observed for
all 359 people across 18 groups.

**TE-02 — response-scale origins and invalid codes.** The existing key accounts
for baseline numeric codes 1–11 representing scale labels 0–10, whereas departure
uses 0–10 directly. Two post Q19 responses with codes 0 or 6 are treated as invalid.
Before adopting any new scoring or sample restriction, re-open the available
[post questionnaire](../data/tomorrows-europe-2007/questionnaire-post.doc), locate
and verify the fielded baseline questionnaire, and recover the original
participant/roster join. A baseline questionnaire is not present in the public
poll package; the baseline scale interpretation still needs that primary-source
check. Person-level deposit comparison remains
unestablished; there is no claimed count of corrected paper estimates.

## Vermont Energy 2007 — vermont-energy-2007

### VT-01: Key ambiguity must remain explicit

**Status:** existing upstream divergence; the accepted key remains provisional.

The [starred departure questionnaire](../data/vermont-energy-2007/questionnaire-post-key.doc)
was re-opened in this pass. Q31 marks a 50% reduction in annual electricity-use
growth (code 3), while the archived recode uses code 2. Q32, excluding Hydro
Quebec, marks **both** 15% (code 2) and 25% (code 3). The text extraction preserves
both literal stars. This supports an ambiguity in the supplied key, not a finding
that two factual answers must both be correct. The fielded version and contemporaneous
briefing sources remain necessary evidence.

Current upstream accepts both starred Q32 answers. Relative to the deposit, the
existing build reports 250 changed item-wave cells, 53 changed baseline scores
and 79 changed departure scores. Means are 23.2116% → 22.2222% at baseline and
62.9376% → 60.1218% at departure. These changes predate this pass.

| Current sensitivity scenario | Baseline mean | Departure mean |
|---|---:|---:|
| Both starred Q32 responses | 22.2222% | 60.1218% |
| Only 15% | 21.0046% | 57.0015% |
| Only 25% | 20.2435% | 56.4688% |

All scenarios retain the current Q31 efficiency key and nine-item denominator.
The departure spread is 3.6530 percentage points. These scenarios do not resolve
which answer was intended or quantify downstream model effects.

**Before any change:** locate the final administered key, inspect annotation
history and contemporaneous briefing facts, and reconcile baseline Q77 value
labels that the previous audit reports as belonging to the next question. Preserve
the published deposit and present upstream behavior until this is reviewed.

**VT-02 — group roster gap.** `PART == 1` selects 146 of 750 source rows, but no
verified group roster is attached. This is a missing verified linkage, not proof
that discussions had no groups. Search original session materials before making
that assertion; do not substitute a single synthetic group.

## San Mateo 2008 — san-mateo-2008

### SM-01: Existing key change needs version-specific instrument evidence

**Status:** existing upstream divergence, with a newly documented instrument
version qualification. No score changed in this pass.

The prior audit reports that two post-wave recodes compare labelled answers with
literal text `"5"`; underlying code 5 yields 111 additional correct responses
(46 for Q20 and 65 for Q26), plus two changes to missing for invalid codes.
There are 113 changed cells, 92 changed post scores, and a mean increase from
25.8891% to 31.6946%, or 5.8054 percentage points. Those are current audit outputs,
not a new independent factual-key determination.

This pass inspected the full
[San Mateo DP Questionnaire 3-12-08 FINAL](<../vault/cdd/data/san_mateo/San Mateo DP Questionnaire 3-12-08 FINAL.doc>):
Q20 is September 2007 median single-family house price and lists **$940,000**
at code 5; Q26 lists **more than 75%** at code 5. The earlier narrative describes
Q20's source label as 950,000. The difference in the textual amount requires
version reconciliation even if code 5 remains the same. The published
[post supplement](../data/san-mateo-2008/questionnaire-post.doc) is short and does
not contain these knowledge questions; its filename alone cannot corroborate them.

**Before any change:** identify the actual administered wave-specific instrument,
compare original source labels and correctness fields, inspect the archived recode,
and verify the factual keys against the applicable briefing material. Do not
claim the post supplement independently confirms Q20/Q26. Retain current scores
and qualify the prior “confirmed by questionnaires” wording in any future review.

**SM-02 — identity and earlier source.** The maintained build selects 239
participants from an earlier 1,806-row file, sorts unique `PARTICIPANTID`, and uses
26 `GRP` values. `RESPNUM` is not unique; the later 239-row analysis file is not the
same provenance layer. Preserve both distinctions when rebuilding the wave merge.

## Michigan 2009 — michigan-2009

**MI-01 — nonresponse versus invalid or ambiguous text.** The current build
selects 310 of 610 merged records using observed `postit`, rather than taking
the first 310 rows. It reports 294 item differences: 291 e/E responses, one F,
and two Senate responses, SC and “same”; zero-filled scores remain unchanged.
The [post questionnaire](../data/michigan-2009/questionnaire-post.doc), re-opened
here, presents free-text party-control questions and explicitly permits respondents
to say they do not know. That does **not by itself establish** the meaning of each
transcribed letter. e/E's treatment must also be checked against the coding sheet,
source labels and the historical export convention. “Same” may depend on a prior
answer; do not infer that dependency without the original response sequence.

**Next check:** recheck all accepted text aliases against contemporaneous coding
instructions, retaining raw text and rejecting unknown tokens. `postit` identifies
people and `group_number` gives 16 groups. The published source is already merged
`mifin.dta`; reproducing its earlier merge is a separate unresolved task.

## Denmark Euro 2000 — denmark-euro-2000

**DK-01 — unresolved four-person difference and absent verified roster.** The
baseline has 1,702 rows, the departure file 359, and all 359 departure `DELNR`
values uniquely match nonmissing baseline `delnr`. There are 363 deposited
batteries. The baseline's 390 nonmissing participant identifiers do not provide
four extra departure interviews; an archived joined object also has 359.
Nine-item measurements join source T0 to T2. No verified discussion-group roster
is currently attached.

**Next check:** re-read [questionnaire.pdf](../data/denmark-euro-2000/questionnaire.pdf)
with both component dictionaries, inspect export dates and join exclusions, and
locate the deposited sample's provenance. Do not fill the count difference by
joining missing IDs or replicating rows. No person-level deposit differences or
changed-score counts are established for this unequal sample.

## Northern Ireland 2007 — northern-ireland-2007

**NI-01 — source roster versus paper reader.** The headerless roster contains
124 mappings, beginning with respondent 112084 in group N. The preserved
`dp-nireland` reader interprets that first record as column headings and uses
123 mappings, leaving one participant ungrouped. Upstream knowledge uses all
124 roster records. The seven-item knowledge battery matches its deposit;
that says nothing about the clustering effect of the paper's missing assignment.

**Current action:** preserve the paper's behavior during relocation; it reproduced
all existing outputs. **Next check:** inspect the actual roster and codebook,
confirm that 112084 is an attendee in group N in the original membership record,
then separately compare cluster counts, standard errors, degrees of freedom and
intervals. Do not combine that analysis with changing open-ended coding.

**NI-02 — measurement and disclosure are separate from knowledge transport.**
The paper's adjudicated argument codes, coder disagreements, response slots,
administration universe and verbatim text are not replaceable by the upstream
knowledge score. The questionnaire and coding scheme must be consulted for those
constructs. A redacted numeric survey can match analytical fields while omitting
80 verbatim fields; field coverage is a separate contract. Census workbooks and
coding materials moved to the external vault retain their original bytes.
See [dp-nireland data documentation](../../dp-nireland/docs/data.md).

## Polls outside the 23-battery canonical build

These entries are explicit coverage gaps, not findings that existing recodes are
wrong. Each poll needs its own questionnaire/version inventory before a new build
or a revised coding decision. Registry presence is not a claim of complete data.

| Poll | Current issue or boundary | Required evidence before extending the build |
|---|---|---|
| nic2-2003 | No matching deposited Cor–Sood item matrix in the linkage crosswalk; historical aggregates are not a substitute for raw response provenance. | Original NIC2 instruments, participant/arm definitions, source IDs and wave merge. |
| btp-national-2003 | Full poll-level knowledge/attitude build not established by the 23-battery pipeline. | National-event instruments and field files; distinguish the national event from later primary/general-election polls. |
| btp-presidential-primaries-2004 | Registry entry must not be conflated with the online-primaries battery. | Event/mode-specific questionnaires, invitation and attendance records, and ID crosswalk. |
| new-haven-2004 | Legacy ledger records an implausible age of 112; this is a prior recode requiring its source record and intended handling to be recovered. | Original demographic question, raw value and alternate-wave age; respondent linkage and attitude definitions. |
| zeguo-2005 | No full source build here; the historical China/Zeguo archive requires poll/version assignment. | Original and translated instruments, event date, project-choice scales and respondent/group identifiers. |
| marousi-2006 | Public participants file came from an existing derived 2014 analysis object, not an independently rebuilt item-level source. It has scores, groups and demographics but no item responses. | [Questionnaire](../data/marousi-2006/questionnaire.pdf), original field returns, scoring syntax and group roster. Audit the downstream convention treating T2 zeros as missing before generalizing it; it is not justified by the numeric value alone. |
| bulgaria-2007 | Distinct Roma-policy event; it must not inherit the 2002 crime battery merely because files share an archive directory. | Roma-policy questionnaire, actual event date and source-file provenance. |
| tanzania-2015 | Public source is available, but full canonical arm, village, questionnaire and measurement integration is not built here. | Village-randomization protocol, information versus deliberation arms, instruments and cluster IDs. Preserve the current downstream specification until audited. |
| america-in-one-room-2019 | Downstream scoring is reproducible from the unchanged deposit; upstream has not independently reconstructed all measurement and sample decisions. | Fielded factual battery, contemporaneous answer key, invitation versus attendance status, uninvited controls and both source weights. The Paris Agreement item must be interpreted at the fieldwork date, not under today's ratification status. |
| a1r-climate-2021 | Three-wave source and weights exist, but upstream respondent-wave eligibility and attrition tables are not complete. | All wave instruments, stable IDs, assignment and attendance, panel filters and follow-up weights. Preserve actual wave identities instead of calling every later wave “post.” |
| amr-2024 | Six-country numeric data exist; country-specific measurement equivalence, attendance versus assignment and weight definitions need explicit source contracts. | Country/language instruments, randomization and attendance records, coding instructions, stable IDs and weighting documentation. Published count parity alone does not validate every recode. |

The four newer control-study files and Marousi are already byte-identical between
`dp-learning`'s former local inputs and their upstream copies. That migration
reproduced all 11 result tables. It does not constitute an independent audit of
the experiments, answer keys, causal claims, weighting, or original field-file merges.

## Cross-poll issues for the eventual schema

### X-01: Knowledge eligibility is not the respondent universe

Current respondent exports select knowledge samples. A comprehensive service
needs all reviewed source people, separate eligibility/assignment/attendance
fields, explicit interview completion, and named analysis samples. Preserve each
historical sample as a view. Missing a group, a post interview, a score or a weight
must not silently delete the person from the master respondent table.

### X-02: Preserve literal waves and fieldwork meaning

Current knowledge waves 1/2 denote selected pre/post measurements. Several
sources use T3 for the later measurement, and Denmark uses T0/T2. Keep literal
source wave, ordering and analytical role separately. Date fields are not
interchangeable with waves. Review questionnaires before equating two fields
that merely share a suffix.

### X-03: Typed missingness and explicit denominators

Missing, inapplicable, refused, don't know, invalid, not asked and absent interview
are different states. A zero-filled knowledge score may deliberately count some
missing answers as incorrect; preserve that as a named scoring policy while
retaining raw response reasons. Partial attitude-index means have changing
observed denominators. Neither policy should be silently generalized to the other.

### X-04: Person-level identity requires more than matching scores

The deposited battery files lack respondent IDs. Six historical links validate
counts, rowwise pre/post scores and observed gender. Those checks cannot
separate people sharing all validation fields. Europolis distributional agreement
is an especially clear case where person-level links are not established.
Keep linkage basis, unresolved matches, and source-scoped IDs in the schema.

### X-05: Some poll-level files already contain merges and derived variables

Reading a poll's HLM or combined survey file removes dependence on a cross-poll
aggregate but does not reproduce the original field-file merge. Record the actual
provenance frontier. Never label this complete raw-to-paper reproducibility until
the earlier component joins, eligibility filters and recodes are reconstructed.

### X-06: Historical aggregates remain an explicit temporary dependency

`output/linkage/` currently reads historical `polardata` and attitude-index maps,
by deliberate choice. All five outputs match the old standalone implementation.
The canonical knowledge build does not consume these aggregates. Replacing the
linkage inputs requires an audited attitude build and explicit differences;
renaming directories or changing schemas does not remove this dependency.

### X-07: Audit artifacts can lag a source relocation

The older downstream inventory and porting-review tables describe files before
the `dp-learning`/`dp-nireland` relocations. The optional source-audit script also
still contains a text comparison to the former local Northern Ireland roster.
Its tracked-file inventory rejects files deleted in an uncommitted working tree.
Refresh that audit after the source migrations are committed and adapt the
obsolete roster comparison to the external source contract. This is tooling
maintenance, not a respondent-data or estimate change; do not present the old
inventory as an up-to-date dependency census.

### X-08: Evidence needed before accepting a change

For each numbered concern, the next review should append: the exact instrument
version and question wording/response order; the codebook and executed syntax;
the authors' documented rationale or remaining uncertainty; counts of affected
people and cells, by wave and sample; the old and candidate values on the same
people; downstream estimates with unchanged and changed sample definitions
separated; a rejected-alternative explanation; and an explicit decision to
preserve, relabel, revise, or leave unresolved. A monotonic scale that looks
intuitive is not sufficient evidence to replace a deliberate transformation.

## Reproduce the UK Health observations without changing outputs

From the repository root, the following R code reads the pinned survey and the
historical comparison file only. It reconstructs the existing behavior, asserts
ID and missingness alignment, and prints the index counts and means. It writes
no canonical table and adopts no alternative score.

```r
x <- haven::read_sav('data/uk-health-1998/survey.sav', user_na=TRUE)
a <- readr::read_tsv('evidence/benchmarks/polardata.tab',show_col_types=FALSE)
a <- a[a$dpnum==2,];stopifnot(identical(as.numeric(x$serial_m),a$caseid))
for(w in 1:2) {
 rec <- function(stem,k=5,rev=FALSE) {v<-as.numeric(x[[paste0(stem,w)]]);v[!v%in%seq_len(k)]<-NA_real_;v<-(v-1)/(k-1);if(rev)1-v else v}
 avg <- function(stems,rev=FALSE) rowMeans(sapply(stems,rec,rev=rev),na.rm=TRUE)
 d<-rec('lista')-rec('severa')
 fold<-function(stem){v<-as.numeric(x[[paste0(stem,w)]]);ifelse(v%in%c(1,3),1,ifelse(v==2,.5,NA_real_))}
 rebuilt<-list(payhlt=rec('payhlth',3),poora=rec('poora'),option=rec('options',3),hlthfu=avg(c('chgp','chvis','chmeal','chstay','chamb')),ctexpt=avg(c('treata','cthart','ctnurs','ctbaby'),TRUE),pritre=avg(c('ctfert','cthosp','ctcosm'),TRUE),severi=(d-min(d,na.rm=TRUE))/diff(range(d,na.rm=TRUE)),preven=rec('preva'),dispub=rowMeans(cbind(fold('ingova'),fold('inpuba')),na.rm=TRUE))
 for(n in names(rebuilt)){v<-rebuilt[[n]];b<-a[[paste0('ukhealth.t',w,n)]];stopifnot(identical(is.na(v),is.na(b)),all(abs(v-b)<1e-10,na.rm=TRUE));cat(w,n,sum(!is.na(b)),mean(b,na.rm=TRUE),'\n')}
}
cat('education school qualification raw-code frequencies by historical index\n');print(table(as.numeric(x$educa),a$educ4,useNA='always'))
```

The counts for UKH-02 and UKH-03 can be reproduced with these additional
read-only comparisons after the preceding setup:

```r
for(w in 1:2) {
 value <- function(n,k=5) {v<-as.numeric(x[[paste0(n,w)]]);v[!v%in%seq_len(k)]<-NA_real_;(v-1)/(k-1)}
 d <- value('lista')-value('severa');h <- a[[paste0('ukhealth.t',w,'severi')]]
 fixed <- (d+1)/2; reverse <- (1-d)/2
 stopifnot(isTRUE(all.equal((d-min(d,na.rm=TRUE))/diff(range(d,na.rm=TRUE)),h,check.attributes=FALSE)))
 cat('severity wave',w,'valid',sum(!is.na(h)),'raw range',range(d,na.rm=TRUE),'historical mean',mean(h,na.rm=TRUE),'fixed same-direction mean',mean(fixed,na.rm=TRUE),'fixed same-direction different',sum(abs(h-fixed)>1e-10,na.rm=TRUE),'reverse-direction different',sum(abs(h-reverse)>1e-10,na.rm=TRUE),'\n')
 raw <- cbind(as.numeric(x[[paste0('ingova',w)]]),as.numeric(x[[paste0('inpuba',w)]]));raw[!raw%in%1:3]<-NA_real_
 folded<-raw;folded[raw%in%c(1,3)]<-1;folded[raw%in%2]<-.5
 existing<-rowMeans(folded,na.rm=TRUE);monotone<-rowMeans((raw-1)/2,na.rm=TRUE);h<-a[[paste0('ukhealth.t',w,'dispub')]]
 stopifnot(isTRUE(all.equal(existing,h,check.attributes=FALSE)))
 cat('discretion wave',w,'valid',sum(!is.na(h)),'raw none',sum(raw==1,na.rm=TRUE),'historical mean',mean(h,na.rm=TRUE),'monotone mean',mean(monotone,na.rm=TRUE),'different',sum(abs(h-monotone)>1e-10,na.rm=TRUE),'\n')
}
```

No issue in this register is an instruction to overwrite current scores. Review
and any approved behavioral change belong in a separate, testable commit.
