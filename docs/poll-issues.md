# Poll-level issue register

Review date: 2026-09-23. Scope: the 34 polls in the current registry, with detailed
coverage of the 23 existing knowledge builds and the respondent reconstructions.

## Decision for this pass

Preserve current scoring, sample definitions, and downstream results. This file
records evidence and review tasks; it does not authorize a recode. The provisional
UK Health attitude implementation that would change definitions was set aside.
After the preservation release `v0.1.0`, `make polardata` implements only the
unchanged historical formulas for the UK Health fields currently reconstructed; see the
[reconstruction contract](knowledge-build.md#historical-aggregate-reconstruction).
Existing upstream knowledge changes predate this review and are explicitly identified below; neither adopting
those changes downstream nor reverting them is part of this pass.

A surprising transformation can be deliberate. Before changing it, recover the
fielded questionnaire, codebook, index memorandum, original syntax, and the
specific file version actually used. Distinguish a computational discrepancy
from a direction convention, a different estimand, a sample restriction, or a
label that drifted away from the intended definition. Numerical agreement does
not establish validity, and disagreement does not establish an error.

Coding errors are plausible and should be expected in a pipeline of this size.
The original analysts' expertise is a reason to investigate their intent carefully,
not a reason to dismiss evidence of an error. Record newly discovered concerns
here as the poll-to-aggregate build proceeds, even when parity passes. Keep the
observed behavior separate from the suspected cause and proposed remedy.
A reproduction commit preserves the historical definition; a later correction
commit needs instrument evidence, assessed alternatives, and quantified effects.

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

### Metadata and online source collection (2026-09-23)

The supplied `meta_data-20260923T233458Z-1-001.zip` contains 113 files,
all byte-identical to the previously extracted metadata members. There are 107
unique file hashes. The bundle catalog records the replacement ZIP checksum and
the previous bundle name/checksum; the member contents have not changed.
Materials are now cataloged under `data/<poll_id>/` or `data/shared/`, with
per-poll manifest references to shared copies. Distinct versions are retained.
Original paths, online URLs, hashes, and comparison uses are in
[the artifact catalog](../metadata/artifacts.csv). Cataloging a document does not
mean its answer keys, sample definition, or recodes have been verified.

The archive contains explicit editorial decisions as well as coding descriptions.
For example, `data/shared/codebooks/attitude_indices/indices-to-drop.docx` calls
for dropping the medical-care quality index and two San Mateo measures, discussing
values and empirical premises. Consult these notes and the successive attitude
appendices before treating missing indices as accidental data loss.

Several downloaded documents require particular care:

- Stanford's “Texas Utility Questionnaires” download identifies **Entergy** in
  its header. It is a related-event instrument, not an established CPL, WTU or
  SWEPCO instrument. No response code or answer key is transferred from it.
- The Zeguo results download explicitly identifies **February 2008**, not the
  2005 infrastructure poll. Its manifest marks it as a different-event reference;
  it must not be used as a numerical parity target for `zeguo-2005`.
- The Bulgaria crime results identify **12–13 October 2002**, despite a later
  website publication date. The separate Roma results describe April 2007.
  Event identity comes from the document, not the website date.
- NIC II has separate T2 face-to-face treatment and control questionnaires. The
  online document identifies itself as a Phase 2 follow-up for experimental and
  control groups. Keep these modes, phases and samples distinct when mapping
  the two foreign-policy polls.
- The 2005 health/education report discusses both online deliberation and local
  face-to-face events. The archived `briefing_materials/newhaven.pdf` is an
  **October 2005 education forum**, not the New Haven airport/revenue-sharing
  experiment. It remains a shared background reference, without that poll link.
- The Tomorrow's Europe paper describes 362 attendees and three survey waves,
  whereas historical polardata includes 344. The general-election online report
  describes about 200 deliberators and 700 controls; other manuscripts and source
  extracts use different counts. These are sample/version reconciliation tasks,
  not evidence that a respondent should be added or dropped.

Published tables can check sample sizes, item proportions, direction and scale,
and sometimes index means. Before turning any table into an automated benchmark,
establish the exact cohort, wave, weights, missing-value rule and rounding.
Agreement with a paper using the same historical scoring is useful but is not an
independent validation of that scoring. No estimates change in this source pass.

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

All nine attitude indices selected by the downstream index list, in both waves,
can be reconstructed
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

### UKH-07: Nine selected indices are not the full aggregate inventory

**Status:** preserve / review; the earlier description of nine “final aggregate”
indices was too broad and has been corrected here.

`attitude-indices.tab` selects nine indices for UK Health. The actual historical
`polardata.tab` retains 11 in both waves, including `ukhealth.t{1,2}avgdis`
(doctor discretion) and `ukhealth.t{1,2}moresa` (patients' say), and `numindices`
remains 11. The UK Health section of
[05_fix_data.R](../vault/cdd/merge_data_scripts/05_fix_data.R) lists those two
indices in comments and says the number should fall to nine, but contains no
executed deletion or count update for them. A selected analysis battery and
an aggregate's complete inventory can legitimately differ; the comments alone
do not settle whether the retained fields or count were unintended.

The V6 memo sections 12–13 and codebook Q18A_B/Q18A_D and Q23_B define the added
constructs. Raw `say` uses 1 strongly disagree through 5 strongly agree;
`(say - 1) / 4` exactly reconstructs `moresa`. Doctor discretion averages available
`ingpa` and `indoca` components. Like UKH-03, both components reproduce the stored
index only with codes 1 and 3 mapped to 1 and code 2 mapped to 0.5. Codebook and
memo describe none/some/all-or-most say, so the rationale for folding remains
unresolved. The four added aggregate columns now reproduce exactly.

| Doctor discretion | T1 | T2 |
|---|---:|---:|
| Nonmissing respondents | 216 | 218 |
| Historical mean | 0.7731481481 | 0.7786697248 |
| Diagnostic monotonic-map mean | 0.7592592593 | 0.7511467890 |
| Respondents changing under diagnostic map | 5 | 8 |

**Before changing:** verify which battery each paper uses, whether `numindices`
means stored or selected indices, recover the original component syntax, and
check the fielded instruments and index versions. Do not drop the two fields or
replace the folded map while reproducing the historical aggregate.

### UKH-08: Individual and group high-income fields use different thresholds

**Status:** preserve / review; assignment sequence and numerical difference verified.

Codebook B18 defines 16 household-income bands before tax. In this participant
file, `(income - 1) / 15`, with raw -9/-8/-7 missing, reconstructs `hhincome`
for 206 respondents. The [poll script](../vault/cdd/scripts/uk_health.R) uses
`hhincome > .8`; [03_data.R](../vault/cdd/merge_data_scripts/03_data.R) computes
`phighinc` from that flag. Then
[06_add_more_vars.R](../vault/cdd/merge_data_scripts/06_add_more_vars.R) changes
individual `highinc` to `hhincome > .34` without recomputing `phighinc`.

The early threshold selects raw bands 14–16 (35,000 and above), while the final
threshold selects bands 7–16 (15,000 and above). The high-income count rises from
22 to 97 among 206 observed people: 75 individual flags differ. All 230 stored
group shares match the early threshold. Recomputing them from final `highinc`
would change all 15 discussion groups, hence all 230 group-share entries.
These are income bands, not cardinal income or necessarily a percentile cut.

**Before changing:** recover why thresholds were revised and which definition
was intended for individual and group covariates. Check paper definitions and
whether deliberately distinct constructs were given similar names. Compare
estimates separately under each threshold and under a consistent group/individual
pair; do not silently harmonize them. Both vintages are now explicitly preserved
in the source build. Missing income remains missing, and group means omit it.

### UKH-09: Attitude summaries precede the final severity rescaling

**Status:** preserve / review; a reproducible sequence, not yet a judged correction.

The poll script computes `attextreme` as the available-item mean of
`abs(index - .5)` over **11** T1 indices, with severity still equal to
`scaled lista - scaled severa`. It computes `avgsd` as the mean of the 11
within-group sample standard deviations. `03_data.R` then computes the group
mean `meanxtreme`. Later, `05_fix_data.R` rescales the exported severity column
without recomputing these summaries. Replaying that order reconstructs all three
fields for every respondent.

Using the 11 final exported T1 columns instead would change `attextreme` for
203 people: its mean becomes 0.2584546160 rather than 0.3034622428; the maximum
absolute individual difference is 0.1428571429. This diagnostic changes only the
severity version, not the number of indices. Applying a nine-index definition
would be another separate decision. No downstream models were refitted.

**Before changing:** establish the intended neutral point of the difference
index, which index versions entered the published summaries, and whether
extremity and dispersion were intentionally retained from the earlier scale.
The zero of a contrast need not share the .5 midpoint of an ordinary 0–1 item.
Compare downstream effects while separating scale, midpoint, item membership,
and missing-component denominators. Historical summaries remain unchanged.

### UKH-10: Poll-level and respondent-level knowledge have different precision

**Status:** numerical representation reproduced; preserve / review the intended
precision and original generating command.

The archived poll script sets `t1knowlevel <- mean(hknow1)`, using the survey's
stored score, but separately computes respondent `t1know` from six correctness
indicators. The aggregate constant is 0.657782610279062, matching the stored-score
mean. The mean of final respondent `t1know` is 0.657971014492754. At tolerance
`1e-10`, stored `hknow1` and final `t1know` differ for 171 people, with maximum
absolute difference 0.003333350022634. The source dictionary labels `hknow1` as a
proportion correct with display format F9.2. That format is evidence to inspect,
not proof that display rounding caused every underlying value difference.

**Before changing:** compare raw answers, stored correctness fields and both
score distributions; recover the score-generation and export precision rules.
Determine whether the poll mean deliberately used a published rounded measure.
Do not replace it with the mean of reconstructed individual scores solely because
that is convenient.

**Reconstruction follow-up:** rounding the six-item raw-answer T1 score to two
decimals, then representing it as a 32-bit floating-point value, matches all 230
stored `hknow1` values exactly. Rounding alone leaves maximum error
`1.66893e-8`. Averaging the reproduced representation matches `t1knowlevel`
within `4.5e-16`. The codebook summary also prints the seven rounded values
0/.17/.33/.50/.67/.83/1. This establishes a source-only numerical reconstruction,
now implemented, but does not establish which original command or export step
introduced the precision. The input key remains subject to UKH-12.

### UKH-11: Adjusted baseline knowledge and peer scores use departure answers

**Status:** preserve / review interpretation; the adjustment is explicit in the
original code, not a newly discovered accidental multiplication.

The [poll script](../vault/cdd/scripts/uk_health.R) labels a guessing adjustment:
a T1-correct/T2-incorrect answer becomes incorrect at T1. It computes itemwise
`T1 correct * T2 correct`, then averages all six items as `t1knowcor`.
The [helper](../vault/cdd/scripts/hlmFunc.R) and
[merge](../vault/cdd/merge_data_scripts/03_data.R) use the same jointly correct
items to compute and normalize `grpgain`. No new adjustment is introduced here.

There are 104 correct-to-incorrect item transitions across 74 people. The mean
baseline score falls from 0.6579710145 to 0.5826086957 under the documented rule.
Mean unadjusted gain is 0.0789855072; mean adjusted gain is 0.1543478261.
Unadjusted gain is negative for 45 people; adjusted gain is nonnegative by
construction because `T1 correct * T2 correct <= T2 correct` item by item.
These are properties of the measurement definition, not evidence of a treatment
effect or a determination that the adjustment is inappropriate.

`grpgain` is the mean of other group members' jointly correct responses over
items the focal person did not answer correctly under the joint-wave rule.
It is not a realized before/after change in the group's average score.
Twelve respondents have all six jointly correct answers, making the normalized
denominator zero; the historical export has missing `grpgain` and `loggain`
for them. Fourteen have observed zero `grpgain`. The log transformation replaces
these zeros with .0001 before taking logs; 13 zero adjusted-baseline scores
receive the analogous treatment in `logpk`.

**Missingness:** 184 T1 item responses across 99 people and 151 T2 responses
across 70 people are nonresponse or system missing and are scored zero in this
historical definition. Two respondents (source IDs 3809 and 4307) have all six
T2 raw answers system missing, yet their scores remain zero in the 230-person
universe. Establishing whether these represent absent interviews needs the wave
roster; all-missing answers alone do not settle the reason.

**Before changing:** recover the authors' guessing/forgetting rationale and the
paper's definitions. Check whether any model treats `t1knowcor` or its peer
counterpart as information measured only before deliberation; both depend on
T2. Assess nonresponse, interview absence, zero-denominator selection and log
replacement separately. Compare downstream samples and estimates under explicit
alternatives, retaining the original definition until that review is complete.

### UKH-12: Breast-screening correctness conflicts across source versions

**Status:** preserve / investigate source and key versions; no rekeying authorized.

Codebook Q9E asks whether all British women can get free breast cancer screening
on the NHS. The printed T1 `SOPHE1` table has 669 true and 181 false responses;
its `ANSWERE1` table counts 669 correct. The printed T2 tables similarly count
125 true responses and 125 correct. Thus those printed correctness counts align
with true as the key, for samples of 955 initially and 231 at departure.

The actual 230-person `britishhealth.sav` used by the historical aggregate and
published as `data/uk-health-1998/survey.sav` labels the correctness fields
0 incorrect / 1 correct and instead codes **false** as correct in both waves.
Cross-tabs of raw answer against stored correctness show:

| Wave | False, scored correct | True, scored incorrect | Nonresponse/system missing |
|---|---:|---:|---:|
| T1 | 43 | 164 | 23 |
| T2 | 85 | 124 | 21 |

This is more than the different total sample counts: the mapping from raw answer
to correctness differs. The preserved key reproduces every stored correctness
field (with missing scored zero), the deposited battery and historical scores.
A diagnostic rekey to true would change the six-item score for 207 T1 and 209
T2 respondents. Means would move from 0.6579710145 to 0.7456521739 at T1 and
from 0.7369565217 to 0.7652173913 at T2. Those are hypothetical score differences,
not corrected results; adjusted scores and downstream models have not been
re-estimated under that candidate.

**Before changing:** recover the fielded wording, contemporaneous briefing and
screening-eligibility information, codebook revision dates and original key
syntax. Determine whether the printed tables contain an error, the key was
subsequently revised, or the documents describe different question versions.
Another visible codebook anomaly labels both ANSWERB1 categories with code 0;
this cautions against treating a printed table as an infallible executed key.
Neither the historical stored key nor the printed key should prevail solely
because it reproduces a convenient benchmark. Preserve false for reproduction
until independent source evidence and numerical consequences are assessed.

## UK Crime 1994 — uk-crime-1994

### UKC-01: An archived post-wave component reads another item at baseline

**Status:** preserved and parity-confirmed; cataloged in
[source findings](../metadata/source_findings.csv).

The [archived UK Crime script](../vault/cdd/scripts/uk_crime.R), line 143,
assigns `timchld2r` from `morecop1`, then includes it in `rootcauset2`.
The [codebook](../data/uk-crime-1994/codebook.txt), rechecked here, identifies
`TIMCHLD2` as post-wave QQ1d, time with children, and `MORECOP1` as baseline Q1j,
more police. They differ in both construct and wave.

The maintained reconstruction now reproduces all 37 historical respondent
fields, including this post index, for all 299 selected people. This establishes
that the baseline-policing substitution is consistent with the deposited values;
it does not establish the substantive reason for that substitution.

A diagnostic replacement of `morecop1` by `timchld2`, holding the other two
components and the available-item averaging rule fixed, changes 141 jointly
observed values and one missingness status. The post-index mean changes from
0.8253902 to 0.8348714 over its available observations; the largest jointly
observed individual change is 0.25. This candidate is **not adopted**. Inspect
the index memorandum and the published article's item membership and scale
direction, establish the rationale or transcription history, and then evaluate
downstream consequences before proposing a correction.

### UKC-02: Knowledge sample and respondent-ID conventions

**Status:** preserve; important contract for future broader exports.

The source has 300 attendees but the historical knowledge sample selects 299
with a group assignment. All 869 source records remain available. Current
knowledge scores match the deposit; adding the ungrouped attendee would change
the analysis universe rather than repair the same estimator.
159 raw IDs have floating-point noise up to roughly `1.5e-12`. Current IDs round
within `1e-8`; truncation can collide. Archived generated IDs use `10000 + row`.
The respondent layer now provides the explicit `historical_respondent_id`
alias while retaining the original raw identifier, all 869 source records and
separate historical/knowledge memberships. The codebook and
[existing audit](uk-crime-eu.md) support these contracts.

### UKC-03: Issue-specific knowledge fields are absent from the historical export

**Preserve / review.** The archived script computes four-item legal knowledge
as `t1knowr`, `t2knowr` and `t1knowrcor`, separately from the seven-item overall
knowledge score. In the deposited polardata, all 299 UK Crime values of those
three fields and `knowgainr`/`knowgainr2` are missing. The ordinary seven-item
fields are observed and reproduced exactly.

The new respondent definitions preserve those five export fields as explicit
constant missing values; they do not alias them to overall knowledge or infer
that the four legal questions were unasked. Trace the object saved by the
historical script through the merge/export versions and consult the cross-poll
knowledge index memorandum before reinstating an issue-specific score. Compare
sample, item count, missingness and downstream effects in a correction pass.

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

**UKEU-02 — preserve baseline scale compression; investigate missing-code
normalization.** The 900-row `survey.sav` contains `commies1` codes 1–5 plus
12 code-9 nonanswers and `favref1` codes 1–5 plus four code-9 nonanswers. The
archived `uk_eu.R` first creates a missing-cleaned `commies1r`, then overwrites
it with `zero1(ukeu$commies1)`; it likewise applies `zero1` directly to
`favref1`. The historical participant values match `(raw - 1) / 8` exactly,
consistent with normalization across the full 900 records including code 9.
All 238 attendees answered both items with substantive codes, but their
resulting scores run only from 0 to .5. Fixed [1,9] calibration in the new
historical definition reproduces this behavior without re-estimating bounds
when selecting rows. For the wider source sample, the historical formula also
maps code-9 nonanswers to 1; the response table still flags them as missing.

The codebook's Q14c SAQ1 (`COMMIES1`) and Q10 SAQ1 (`FAVREF1`) distinguish
five substantive ordered categories from not-answered code 9. A hypothetical
[1,5] normalization would change 228 and 235 of the 238 participant values,
respectively, by up to .5, with no participant-level missingness change. It
would also change extremity, variances and downstream attitude effects.
Do not apply that change yet: recover the original `zero1` implementation and
reader behavior at the script's execution date, the actual SAQ instruments,
and any index-direction memorandum. An intentional scaling choice or a
historical reader treating labelled missing codes differently remains a rival
explanation. The codebook also says the supplier collapsed “can't choose”
with the midpoint for `FAVREF`; the separated original responses cannot be
recovered from this file. Rescaling cannot undo that prior collapse.

**UKEU-03 — preserve post-wave “can't choose” in the EU-relations index.**
`RELEU2` (Q1 SAQ2) and `LONGPOL2` (Q4 SAQ2) label code 6 “can't choose,” with
five and six such answers among attendees. `uk_eu.R` removes -1/8/9 but not 6,
then normalizes these two fields over [1,6]; `UNITE2` uses [1,5]. The average
matches every nonmissing historical `ukeu.eurelat2g` value. Thus code 6 enters
as the endpoint 1, and substantive code 5 enters the first two components as
.8. The corresponding baseline components use [1,5]. A sensitivity calculation
that treats code 6 as missing and scales substantive 1–5 answers over [1,5]
changes 211 of the 238 participant values, with no index-level missingness
changes and maximum absolute change 1/3. This is diagnostic only. Check the
actual T2 form, the codebook's inconsistent LONGPOL2 note referring to code 8,
the response-label revisions and intended index polarity before deciding
whether the difference is a coding error, source-version mismatch, or intended
handling of uncertainty. Review the baseline/post comparability of the index.

**UKEU-04 — preserve inapplicable post responses in the EU-scope index.**
For `trabloc2`/`pasport2`, `uk_eu.R` removes 8/9 but leaves -1. The observed
full-source range is [-1,5], so the historical components are `(raw + 1) / 6`.
The 14 attendees without a post knowledge interview also have inapplicable
responses here, which become index value zero rather than missing. This
explains why `ukeu.euscope2g` has 238 nonmissing participant values while the
other post attitude indices have at most 224. Recode -1 as missing and normalize
substantive 1–5 responses only in a diagnostic calculation: 14 index values
become missing and 209 remaining values change, by up to 1/3. Check Q6b and
Q17e SAQ2 against wave-completion records and the original SPSS import behavior.
Do not silently substitute the knowledge sample or equate zero with a measured
opinion. The historical definition and raw -1 values are preserved separately.

**UKEU-05 — preserve the ethnicity exclusion and education threshold.** The
codebook's B14 IAQ ethnicity question calls code 8 “Other,” with 19 source
records and five attendees. `uk_eu.R` explicitly excludes 8 along with
97/99/-1 before `ethnic != 1`, leaving 233 historical minority values. This
could reflect intentional exclusion of an ambiguous category; it should not
be changed just because the label appears substantive. Recover the original
response categories and any coding note, assess which respondents would enter
the denominator, and compare group shares before proposing a recode. Likewise,
`educ4` maps school qualifications 0/1/2 to 0, 3/4/5 to .33, 6/7/8/9/10/12 to
.66, degree category 11 to 1, and other category 13 to missing. The later merge
sets `bettered` to `educ4 >= .33` for this poll (90 of 230 nonmissing attendee
values). It is not a uniform college-degree indicator across polls.

The new respondent build reconstructs all 35 applicable UK–EU historical
respondent fields, including aliases and seven deliberately missing fields.
It uses all 900 source rows and separately verifies the 238-person historical
sample; the old 224-person knowledge outputs are unchanged. These parity checks
establish reproduction, not questionnaire validity or downstream robustness.

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
full file. They are not validated person keys across other files. The archived
`uk_monarchy.R` explicitly generates `caseid = 1000 + source_row` before
filtering `GROUP != -1`; these aliases identify all 258 historical rows exactly.
They are stored separately from source identity. The eight-item knowledge export
omits succession (`Q8A`/`R8A`, correct code 5), whereas the historical aggregate
script explicitly includes it in its nine-item denominator. The new historical
respondent definitions reproduce that nine-item battery and its baseline Q5C
reuse. The existing eight-item knowledge export remains unchanged; changing
either contract requires assessing the intended battery against the instrument.
See the [existing audit](monarchy-election-utilities.md).

**UKM-03 — attitude construction and numeric precision.** The archived
`British Monarchy Indices_final draft.doc` identifies the four composites and
their constituents. The support index uses Q1/Q11/Q9/Q14 and their R counterparts;
the people index uses 6A/6B/6E/6F/7A/7B; power uses 15/13D; Lords reform uses
18/19A/19B. Available-component means preserve missingness. The referendum
field is Q14/R14, not the Q15 alias in the archived clean script: raw field
labels and the stored referendum component establish the mapping. Codes 1–4
map to 0/.333/1/.667. Both recoded components and final composite values carry
32-bit float precision. These choices reproduce all eight historical attitude
columns and individual extremity for 258 attendees within 1e-10. The original
command that produced the stored float representation remains unverified.
Before changing direction, rounding or nonresponse handling, reconcile the
questionnaire's referendum ordering with the index memo and source labels.

**UKM-04 — expanded-source recodes are not automatically valid demographics.**
The archived age recode specifies midpoints only for AGEB 2–9 and leaves codes
10 and 11 unchanged. Three and five nonattendees respectively retain those
numeric codes in the historical-definition output. A6 code 6 also passes
through unchanged for one nonattendee; B12A code 6 passes through the education
recoder unless the qualification override applies. No attendee has these three
source-code exceptions. Review the original response labels before producing
corrected age, interest or education measures for the expanded population.
Do not interpret the retained 10/11 age codes as years without that review.

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

**UKGE-02 — the pre/post tax indices measure different questions.** The raw
`taxr1` field is Q13, preferences over tax cuts versus social-service spending.
Historical `t1tax` maps codes 1–7 to 0/.17/.33/.5/.67/.83/1, stored as floats.
Historical `t2tax`, however, is labelled “t2 relabel txr2re - tax index”; the
intermediate `txr2reco` is labelled “recoded taxret2”. `taxret2` is Q4c, whether
the overall level of taxes had gone up or down since the 1992 election. The
[codebook](../data/uk-general-election-1997/codebook.txt), TAXRET1/TAXRET2 entry,
confirms its five categories. Mapping codes 1–5 to 0/.25/.5/.75/1 and -8/-9 to
missing reproduces all 275 historical post values: 259 observed and 16 missing.
Using the analogous preference field `taxr2` instead would change 207 jointly
observed values and 17 missingness indicators. That alternative is not applied.
Before correction, establish the intended longitudinal construct from both
questionnaires and the original index specification; then recompute affected
attitude change, dispersion and downstream estimates in a separate version.

**UKGE-03 — Labour minimum-wage placement reuses the baseline response.**
`uk_bge.R` assigns `wagel2pk <- nona(wagel1 > 4)`. The new historical recode
preserves this literal dependency in post knowledge and joint-correct knowledge;
its metadata identifies both as dependent on T1 and T2. Substituting `wagel2`
would change 54 of 275 binary post items. Review Q14 and executed scoring syntax
before deciding that this is an unintended copy error; quantify composite and
model changes separately before adoption. The historical baseline mean also
weights a float32 factual subscale with three party-placement subscales. This
rounding is reproduced from raw answers, not copied from stored indices.

**UKGE-04 — demographic and missing-code boundaries.** Ethnicity -7 becomes
missing, including two attendees; codes other than 1 become the historical
minority indicator. Age -7 becomes missing. School education is overridden by
higher qualifications; household income's 16 categories collapse to five and
high income means a collapsed category above 2. Source labels and the existing
codebook establish the raw categories; the archived script establishes the
historical transformations. All 35 respondent-field targets match for the 275
attendees at 1e-10, including missingness. This is reproduction evidence, not
an endorsement of the tax mismatch or the cross-wave knowledge dependency.

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

**CPL-02 — historical IDs and staged normalization.** `tx_cpl.R` generates
`paste0(29, 10000 + source_row)` before retaining nonmissing groups. These aliases
match all 216 historical attendees. The new respondent table retains all 1,246
source rows and keeps original survey IDs separate. Attitude components use
full-source empirical bounds: 0–10 except POOR/COMPET 1–5 and FUELS2 1–10.
T1 conservation is an available mean of scaled ADDFAC1/REDUCE1, then scaled
again using attendee bounds .05–1 in the Kyu export. Individual extremity was
already computed using the first version. The maintained recode fixes these
historical bounds so changing the supplied row subset cannot change a score.
Review the intended common metric and both wave instruments before replacing
these calibrations with theoretical endpoints. All 39 respondent-field targets
match for 216 attendees, including missingness, at 1e-10.

**CPL-03 — removed competition item still enters extremity.** The poll script
uses seven baseline indices, including COMPET1, in `attextreme`.
`05_fix_data.R` later removes the competition columns without recomputing
extremity. The maintained recode therefore retains COMPET1 as a dependency even
though the final historical wide table exposes only six attitude pairs. Before
correction, decide whether the intended extremity definition should follow the
final attitude battery or the earlier seven-index specification; quantify both
versions without silently dropping the component. Codebook 99/999 sentinels are
preserved in raw responses and removed where required for historical scoring.
Dictionary-based `response_status` does not yet encode every codebook sentinel
in these newly added demographic and attitude fields; `n_observed_fields` must
not be used as a scoring denominator or validated response-completeness count.

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

**SWE-02 — conservation's post component is absent under the script's name.**
`tx_swp.R` refers to `addfact2`, but the survey contains ADDFAC2, not ADDFACT2.
In `cbind`, the absent `$addfact2` contributes no column. Consequently the
historical post index uses REDUCE2 alone. The maintained historical recode
names REDUCE2 explicitly and reproduces all 232 values. The pre index averages
ADDFAC1 and REDUCE1 and normalizes the attendee mean over [3,10]; the post index
normalizes REDUCE2 over [0,10]. Check Q2 item wording and the intended pair in
[codebook.txt](../data/swepco-1996/codebook.txt) before adding ADDFAC2. The absent
field is a source-code defect; whether the intended corrected index should
retain the same empirical normalization requires a separate decision.

**SWE-03 — low-income index reflects an earlier script version.** Historical
`t1att4`/`t2att4` reproduce NEEDTO1/NEEDTO2, the 0–10 basic-needs/cost tradeoff,
with missing responses filled at 5. The archived script's active LOWINC/POOR
composite does not reproduce the saved aggregate. The corresponding WTU script
retains the NEEDTO variant as commented code. This is evidence of a script-vintage
difference, not grounds to change the historical data. Consult the questionnaire,
index specification and an executed-script version before choosing a corrected
construct. The maintained recode identifies NEEDTO inputs explicitly.

**SWE-04 — extremity precedes research scaling and competition removal.** The
poll script computes research from RESCH1/FEDRCH1 on the raw 0–10 metric (FEDRCH1
is entirely missing) and fills missing means at 5. Its seven-index extremity
includes this unscaled research value and competition. `05_fix_data.R` later
rescales research to 0–1 and drops competition without recomputing extremity.
The historical definitions reproduce both stages. Renewables use an available
raw mean calibrated over [1,10] at T1 and [0,10] at T2; other one-item 0–10
indices use their historical missing fill of 5. All 39 respondent-field targets
match for the 232 PART==1 attendees at 1e-10. Review the intended extremity
metric before changing it, and recompute downstream group dispersion separately.

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

**WTU-03 — absent ADDFACT2 removes the post conservation component.** As in
SWE-02, `tx_wtu.R` uses `addfact2` although the source field is ADDFAC2. The
historical post index is therefore REDUCE2 alone, normalized over attendee
bounds [3,10]. The pre index averages ADDFAC1/REDUCE1 over [2,10]. Missing
indices are filled at .5. These fixed ranges reproduce the saved values; using
the apparent intended two-item post mean would change 179 jointly observed
participant scores (maximum absolute difference about .588235). Do not make
that substitution before checking both questionnaire items and index intent.

**WTU-04 — historical low-income index uses NEEDTO at each wave.** The commented
NEEDTO1/NEEDTO2 variant in `tx_wtu.R`, scaled over [0,10] with missing filled at
5, exactly reproduces the aggregate. Its active alternative uses LOWINC1/POOR1
and reuses the baseline pair at T2; that active code does not reproduce the
saved historical index. The codebook identifies NEEDTO as the importance of
meeting basic needs despite higher costs. Review the intended construct and
script vintage before treating either alternative as an approved correction.

**WTU-05 — preserve the order of extremity and export transformations.** As in
SWE-04, extremity retains seven indices, unscaled 0–10 baseline research, and
the subsequently removed competition item. The final research columns are
normalized over [0,10] at T1 and [1,10] at T2, with missing raw means filled at
5. Renewables' available raw means are normalized over [2.5,10] at both waves
and missing indices filled at .5. All 39 respondent-field targets match for 230
PART==1 attendees at 1e-10. These calibrations are fixed for source-row subsets;
values outside the attendee calibration population are not silently clipped.
Questionnaire review must precede a change to theoretical scale endpoints,
missing-value imputation or the final extremity battery.

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
[San Mateo DP Questionnaire 3-12-08 FINAL](<../data/san-mateo-2008/questionnaire-pre.doc>):
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
The maintained paper now reads the public numeric survey, source roster and
`data/northern-ireland-2007/argument-codes.parquet`. The latter retains all
65,760 coder-slot records for 274 respondents, including missing labels;
`R/argument_codes.R` selects the 240 coder fields from the original `fin.csv`
and excludes verbatim responses. No codes are normalized or adjudicated upstream.
All 19 pinned downstream numerical outputs match after changing these readers.
The paper still preserves the first-roster-row issue in NI-01. The old vault
inventory remains historical provenance, not a required runtime input list.
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

### NH-02 — Event year and attendance need reconciliation

**Preserve / review.** Farrar et al., *Disaggregating Deliberation's Effects*
(BJPS 2010, DOI 10.1017/S0007123409990433), pp. 338–339, identifies deliberations
on **1–3 March 2002**, an initial interview sample of **1,032**, and **133**
attendees. The historical poll-details appendix and current registry label this
poll **2004**, and the historical analysis has **132** people. The online LSE
PDF matches both archived copies byte-for-byte; it is not new contrary evidence
from a different paper version.

Preserve the current ID and cohort while checking raw fieldwork dates, the
airport/revenue-sharing questionnaire, group assignment and completeness filters.
Establish which attendee is excluded and why. The paper's split-half experiment
has three measurement occasions: match the historical pre/post columns to those
occasions before comparing its Tables 1 and 3. Do not use the similarly named
October 2005 New Haven education briefing as this event's instrument. Any future
year correction needs an explicit registry/alias change, separately from any
sample correction and its consequences for estimates.

### NEW-01 — Newer-poll mode labels and reported sample totals

**Preserve / review.** The registry currently labels both `a1r-climate-2021`
and `amr-2024` as face-to-face. Stanford's climate/energy project page, the
NORC October 2021 methods report and the 2025 *Scaling Dialogue* paper describe
online deliberation. The AMR paper, version 2 (14 May 2026, DOI
10.12688/wellcomeopenres.24803.2), likewise describes facilitated online groups
in June–August 2024. Its 2,419-person randomized total includes intervention and
controls; it is not a deliberator-only count. The downloaded AMR final report's
cover says June 2026 although its URL filename says July 2026.

Review source event IDs and treatment/attendance definitions, then correct mode
metadata in a separate correction commit. Before validating any reported gains,
match country, weighting, analysis sample and wave. For the climate experiment,
the one-year follow-up is a separate wave from immediate post-deliberation.
No mode label, sample or score is changed by this source collection.

## Cross-poll issues for the eventual schema

### X-01: Knowledge eligibility is not the respondent universe

The original `output/respondents.parquet` selects knowledge samples. The new
`output/respondent/people.parquet` retains all 24,361 records from the 16 reviewed
sources in the historical 21-poll scope. A comprehensive service
needs all reviewed source people, separate eligibility/assignment/attendance
fields, explicit interview completion, and named analysis samples. Preserve each
historical sample as a view. Missing a group, a post interview, a score or a weight
must not silently delete the person from the master respondent table.

The expanded universe exposes missing identity information: Australia has
3,439 missing `caseid` values among 4,659 source rows; San Mateo has 1,096 missing
`PARTICIPANTID` values among 1,806 rows; NIC1 has one missing `CASEID` among
911 rows; and no reviewed original respondent-ID column has been established
for the 857-row Monarchy source. File-scoped source-row IDs preserve all these
records. They cannot support cross-file identity joins until an instrument,
roster or original merge establishes a crosswalk. Reordering source rows must
not silently create a new version under the same source ID. For polls other
than UK Health, UK–EU, UK Monarchy, the 1997 UK election, CPL, WTU and SWEPCO,
historical sample membership remains explicitly
unknown; no aggregate row order is used to invent identity.

The five historical polls without a reviewed respondent source have concrete
next investigations:

- **Zeguo 2005:** `china_2005.r` reads `China Merged Dataset.dta`, filters on
  `groupnum` and `preandpost`, and constructs `caseid` from `p`. Reconcile the
  archived SAV/DTA versions, translated instruments and filter coding before
  assigning a reviewed public input or claiming coverage.
- **New Haven 2004:** `new_haven.R` overwrites the same object from three
  successive inputs, ending with `orig/nh_data_06_23_07.dta`. Identify the
  executed version and multiwave IDs before using an earlier CSV or DTA.
- **NIC2 2003:** `nic2.R` targets misinformation and `dat2.por`; that script
  alone does not establish the Nuri aggregate's respondent/attitude formulas.
  Recover the executed scoring syntax and match it to the fielded wave files.
- **BTP National 2003:** `us_fp.R` mixes R and Stata statements and includes
  empty recodes. Recover the executed online source and Nuri syntax, with the
  correct national-event instruments and sample restrictions.
- **BTP Presidential Primaries 2004:** `04_kyu.R` combines Nuri objects and
  `btp04kyu` names that can be confused with the general-election and separate
  online-primaries material. Establish event/mode, source file and identity
  before selecting a public source. Similar names are not a valid crosswalk.

The other eight reviewed polls' remaining respondent recodes are marked
`not-yet-reconstructed` in the field-target registry; that is unfinished work,
not a finding that the underlying sources or formulas are unavailable.

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
