# Poll-level issue register

Review date: 2026-09-25. Scope: the original 34 analytical polls, with detailed
coverage of the 23 existing knowledge builds and the respondent reconstructions.

## Decision for this pass

Preserve scoring, sample definitions, and downstream results until each proposed
correction has been supported by evidence and explicitly approved by the user.
UKC-01, UKGE-03 and NIC-03 age/mode were approved on 2026-09-24;
SWE-02, AUS-03, AUS-04, WTU-03, UKM-01, UKEU-03, UKEU-04, UKGE-02, UKGE-05, BTPHE-01, BTPHE-03, EURO-04 and NH-06 were approved in subsequent poll reviews.
Other proposals remain unapproved.
This file records evidence and decisions; an unresolved issue does not authorize
a recode. The provisional
UK Health attitude implementation that would change definitions was set aside.
Following historical reconstruction, `make polardata` implements the historical
formulas plus explicitly approved corrections for all 21 polls in scope; see the
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

Corrections will proceed one poll at a time and require the user's approval
before that poll's coding changes. Present the source instrument and original
syntax, current behavior, competing interpretations (including preserving the
current rule), affected respondents and missingness, and measured before/after
aggregate and downstream-estimate differences. Label unresolved evidence and
separate proposed corrections from decisions already approved. Repository
cleanup and descriptive catalog fixes do not authorize scientific recoding.

This is an inventory of currently known issues and coverage gaps, not a claim
that every field or every questionnaire has been audited. “No discrepancy in the
knowledge comparison” does not clear attitudes, demographics, weights, or joins.

## Source-material review after v0.3.0

The [sourced facts](../metadata/poll_facts.csv),
[references](../metadata/poll_references.csv), and
[material coverage](../metadata/poll_material_coverage.csv) cover the original 34 analytical polls. Additional `materials-only` entries
identify event documents without implying respondent-data coverage.
Each fact names its source and locator; each poll folder has a generated
`metadata.json` view. Reported numbers retain their stated populations. This
review changes documentation, not catalog identifiers, scoring, or samples.
Priority questions for the corrections pass include:

- **New Haven:** Farrar and colleagues' published study dates the airport and
  revenue-sharing event to March 1–3, 2002; the archived poll appendix labels it
  2004. The paper distinguishes 1,032 initial interviews, 133 attendees and 132
  analysis cases. Verify fieldwork records before changing the year or linking
  this study to a different New Haven event. Preserve `new-haven-2004` meanwhile.
- **Bulgaria 2007:** the organizer description and executive summary identify
  the National Palace of Culture; the Roma working paper names Park Hotel
  Moskva (PDF p. 4) and calls this the first Bulgarian poll despite the 2002
  event. Both report 255 participants. Check original event records before
  selecting a venue. The two versions of the results announcement are press
  releases, not papers; their distinct original bytes remain available.
- **British event dates:** the UK–EU research account says June 1995 while
  parliamentary testimony says May. The UK general-election draft gives April
  26–28, 1997 and calls April 28 a Sunday, although it was Monday. The UK Health
  report's broadcast dates do not by themselves establish fieldwork dates.
  Check invitations, questionnaires and broadcast records before normalizing.
- **Sample denominators:** NIC 1996's overview reports 459 versus 466 in the
  research account; Denmark's overview gives 384 versus 364 effective
  participants in the paper; San Mateo's report gives 238 versus 239 historical
  analysis records. California sources agree on 412 attendees but differ on
  435 versus 439 acceptances. Reconcile rosters and completion rules before
  treating these differences as data errors.
- **Online study periods and counts:** distinguish recruitment, discussion
  sessions, follow-up surveys and completed-analysis samples. BTP 2007's
  codebook documents 326 people attending all four sessions, of whom 301
  completed the post-survey; these counts describe different stages rather
  than an unexplained discrepancy. The same codebook contains the questionnaire.
  BTP 2005's short appendix date interval should not replace the full online
  treatment period described in its event report.
- **AMR 2024:** sourced methods describe online deliberation, while the current
  catalog labels the poll face-to-face. Published totals also distinguish
  assignment to treatment/control from actual deliberation. Verify the study
  version and population before changing catalog mode or sample counts.

Material gaps remain explicit: finding a paper is not equivalent to finding the
fielded instrument, and a general energy questionnaire is not automatically the
CPL, WTU or SWEPCO instrument. PDF previews retain originals alongside them.
Preview QA and limitations are in
[the conversion ledger](../metadata/document_previews.csv); Word final-view PDFs
can omit comments or tracked deletions retained in the originals.

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

### Shared-material cleanup (2026-09-24)

Content comparisons removed 26 redundant or obsolete originals and their 20 PDF
previews. Seventeen single-event documents moved into 16 materials-only event
folders; the numerical build inputs and original analytical poll definitions
are unchanged. The parent commit `fc82922bcbe24f603181af3ffbe5064013458eb2`
retains all removed versions. The cleanup commit describes the comparisons.

Retained HLM versions contain distinct income harmonization, group-ID collision,
moderator-variable, and variance-definition notes. Retained attitude appendices
include author comments and disagreements. Four poll-detail appendices preserve
different topics, session lengths and source comments. Utility-paper variants
have different numerical tables and therefore remain separate. These differences
are evidence for the poll-by-poll correction review, not grounds for automatic
recoding. The euro evaluation questionnaire remains unattributed: neither its
content nor its old filename establishes that it was fielded in Denmark.

The South Florida healthcare guide has a 2005 copyright, but PBS dates the actual
forum to January 21, 2006, after Hurricane Wilma postponed the October event.
The economics/security guide family appears in PBS's January 2004 ten-city
program; the retained copies bear a 2005 copyright, so exact fielded versions
remain unverified. Local 2005 education/healthcare forums have distinct entries
from the national online study and from the New Haven airport/tax-sharing poll.

### Metadata and online source collection (2026-09-23)

The supplied `meta_data-20260923T233458Z-1-001.zip` contains 113 files,
all byte-identical to the previously extracted metadata members. There are 107
unique file hashes. The bundle catalog records the replacement ZIP checksum and
the previous bundle name/checksum; the member contents have not changed.
Materials are now cataloged under `data/<poll_id>/` or `data/shared/`, with
per-poll manifest references to shared copies. The subsequent cleanup retains
versions with distinct coding evidence and removes verified redundant copies.
Original paths, online URLs, hashes, and comparison uses are in
[the artifact catalog](../metadata/artifacts.csv). Cataloging a document does not
mean its answer keys, sample definition, or recodes have been verified.

The archive contains explicit editorial decisions as well as coding descriptions.
For example, `data/shared/codebooks/attitude_indices/indices-to-drop.docx` calls
for dropping the medical-care quality index and two San Mateo measures, discussing
values and empirical premises. Consult these notes and the successive attitude
appendices before treating missing indices as accidental data loss.

Several downloaded documents require particular care:

- Stanford's “Texas Utility Questionnaires” download is a 57-page compendium:
  **Entergy** (PDF pp. 1–8), **HL&P** (pp. 9–29), **SPS** (pp. 30–38), and
  **TU** (pp. 39–57; versions begin on pp. 39 and 51). The earlier Entergy-only
  description came from its first section and was incomplete. No section has
  been established as the exact CPL, WTU or SWEPCO fielded instrument. No
  response code or answer key is transferred from it.
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
  experiment. It now has its own `new-haven-education-2005` materials-only entry.
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

### UKC-01: Post-wave root-causes index substitutes baseline policing

**Status: approved by the user on 2026-09-24 and implemented.**
This is an attitude index, not knowledge.

The [archived script](https://github.com/soodoku/dp-data/blob/historical-cdd-scripts/legacy/poll_scripts/uk_crime.R)
lines 135–149 describes children, television violence and school discipline, but
line 143 assigns `timchld2r` from `morecop1`. The maintained reconstruction
faithfully reproduces this substitution. The proposed correction replaces only
that component with `timchld2`, preserving available-item averaging, other
components, sample membership, IDs and all other indices.

Evidence checked against the proposed correction:

- The [Stage 2 questionnaire](../data/uk-crime-1994/questionnaires/crime-questionnaire.pdf),
  PDF pages 1–2, identifies the post-weekend instrument and C.1d (parents spending
  time with children), C.1b (television violence), C.1h (school discipline), and
  the distinct C.1j policing item.
- The [codebook](../data/uk-crime-1994/codebook.txt), lines 1691–1727 and
  2050–2068, identifies `TIMCHLD2` as post QQ1d and `MORECOP1` as baseline Q1j.
- [Luskin, Fishkin and Jowell (2002)](../data/uk-crime-1994/papers/british-crime-paper.pdf),
  Appendix B, printed page 487c, lists children, television and school discipline
  under Social Root Causes. Printed page 476 describes averaging appropriately
  oriented items onto [0,1]. Table 4, printed page 477, gives post mean .835,
  matching the candidate after rounding. This is corroboration, not a replication
  of the paper's exact sample: the paper describes 301 participants, the source
  has 300 attendees, and the historical grouped sample has 299. The table's
  printed change sign also appears inconsistent with its displayed means; that
  is a separate reporting caveat.
- The [attitude-index memorandum](../data/shared/codebooks/attitude_indices/past_versions/appendix-attitude-indices-6-07-15-rcl.pdf),
  pages 6–7, independently gives the same three components.

**Scale direction matters.** The questionnaire runs from 1 = very effective to
5 = not at all effective, but the deposited variables already run from
1 = not at all effective to 5 = very effective. Retain `(item - 1) / 4`;
reversing the deposited children item again would introduce a second error.
No supporting rationale for the baseline-policing substitution was found;
authorial intent cannot be established from these materials alone.

[Recorded comparisons](../audit/corrections/uk-crime-1994/) isolate this single
substitution, using the source and definitions at `b3d7a834e959b2992669bcf36d4f4803bd753ff6`:

| Historical sample result | Preserved coding | Proposed coding |
| --- | ---: | ---: |
| Respondents retained | 299 | 299 |
| Observed post index | 299 | 298 |
| Available-observation post mean | 0.825390190 | 0.834871365 |
| Post mean, common 298 respondents | 0.824804251 | 0.834871365 |
| Mean change, common 298 respondents | 0.037891499 | 0.047958613 |

Among the common 298 respondents, 79 scores increase, 62 decrease and 157 are
unchanged; maximum absolute change is .25. Case 10388 (source row 388, group
2711) has all three actual post components missing, but baseline policing = 5.
Its historical post score of 1 becomes missing; the person remains in the data.
The ungrouped attendee's score is unchanged. Among the other 569 source records,
566 previously received a post index from their baseline police answer; all 569
have no observed candidate post index. The all-source respondent layer therefore
also needs the approved correction, not just the 299-row historical export.

**Downstream counterfactuals.** Readers remain pinned to their existing inputs;
these runs measure hypothetical adoption, using paired reconstructed inputs to
isolate UKC-01. Code revisions: dp-distortions
`e51f0700ff22fb792515fc9988c8702d35179617`, dp-deliberately
`c3e2834735a09b89dd21511208826e7de16bbcc8`, dp-learning
`57e83ad7937c9fea01a7bced9ead1b20dd157ab8`.

- dp-distortions changes are confined to the root-causes index's 20 groups.
  Pooled homogenization (pre SD minus post SD) moves .01284935 → .01295037;
  polarization moves −.02221073 → −.02213826. Income and triple-advantage
  results are unchanged. All 28 CR2 tests retain decisions at 10%, 5% and 1%;
  homogenization crosses the 0.1% threshold (p .001044 → .000938).
- dp-deliberately's default paired root-index sample changes 299 → 298, retaining
  20 groups. Mean group homogenization moves .02879762 → .04149673;
  polarization .04022377 → .04920942.
- dp-learning's actual analysis frame is exactly identical (6,013 rows × 20
  columns); its baseline attitudes, knowledge and demographic inputs are unchanged.

The diagnostic executes the actual downstream transformations and CR2 inference;
it does not rerun wild-bootstrap inference. Tiny frozen-versus-reconstructed
numeric representation differences can separately flip zero-threshold frequency
indicators. That sensitivity is not attributed to this correction: both arms here
use the same reconstructed serialization.

Reproduce the proposal without changing production outputs:

```sh
# From dp-data; outputs must be kept outside the production output directory.
Rscript scripts/review_uk_crime_correction.R /tmp/uk-crime-review
# From each respective downstream checkout:
Rscript ../dp-data/scripts/review_uk_crime_downstream.R distortions /tmp/uk-crime-review /tmp/uk-crime-distortions
Rscript ../dp-data/scripts/review_uk_crime_downstream.R deliberately /tmp/uk-crime-review /tmp/uk-crime-deliberately
Rscript ../dp-data/scripts/review_uk_crime_downstream.R learning /tmp/uk-crime-review /tmp/uk-crime-learning
```

The first script asserts stable case IDs and that only `ukcrime.rootcauset2`
changes in the historical poll output. Both review scripts pass lint; all three
downstream modes have been executed. The maintained recode and respondent provenance now use `timchld2` and the
versioned definition `root_causes_t2@ukc-01-v2`. The original benchmarks remain
unchanged; parity checks require the exact recorded correction and reject other
unexplained differences. The review script reproduces all five original
comparison CSVs byte-for-byte after adoption. UKC-02 and UKC-03
remain separate decisions, and are not included in this proposal.

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
that the four legal questions were unasked. The archived script explicitly omits these fields from both `ukcrimen`
(lines 329–334) and `ukcrimekyu` (lines 340–347). This is an export selection,
not evidence that the questions were unasked. Consult the cross-poll knowledge
index memorandum before separately proposing their reinstatement. Compare
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

**UKEU-03 — exclude post-wave “can't choose” and restore the substantive
scale.** **Status: approved by the user on 2026-09-25 and adopted.** The
[codebook](../data/uk-eu-1995/codebook.txt) and retained
[value labels](../data/uk-eu-1995/value-labels.csv) identify `RELEU2` (Q1 SAQ2)
and `LONGPOL2` (Q4 SAQ2) code 6 as “can't choose.” Of 238 attendees, five
selected 6 on `RELEU2`, six on `LONGPOL2`, and two on both: nine distinct people.
All 11 code-6 responses in the 900-row source are in this attendee sample.
The `LONGPOL2` prose note calls “can't choose” code 8, but its own frequency
table reports six code-6 responses, matching the source and value labels.
Neither post field has a code-8 response; `UNITE2` also has no code 8 in the
source. The baseline `RELEU1` and `LONGPOL1` do use code 8 for “can't choose”
(26 and 24 attendees respectively), already treated as missing.

The archived `uk_eu.R` removes -1/8/9 but leaves post code 6. It therefore
scores “can't choose” as the endpoint 1 and scales the substantive 1–5
responses over [1,6], so code 5 scores .8. The approved correction excludes
6 in those two post items and scales their substantive 1–5 responses over
[1,5], matching the baseline calibration; `UNITE2` is already on [1,5]. The
component direction and available-response mean remain unchanged. Dropping 6
without rescaling was examined as a diagnostic: it changes only nine indices
and lowers the mean from 0.575744 to 0.567076, but leaves code 5 at .8 and
therefore retains the scale distortion. The complete correction changes 211 of
238 indices and raises the mean to 0.653646. All 224 formerly observed indices
remain observed; the other 14 remain missing. No other aggregate field or
sample membership changes. Historical and corrected values for every attendee
are frozen in [`approved_values.csv`](../audit/corrections/uk-eu-1995/approved_values.csv).

On the current UKM- and WTU-corrected baseline, `dp-distortions` changes 13 of
19 CSVs and 16 of 28 paired CR2 inference rows, with no recorded 0.05
threshold crossing. The `dp-learning` analysis frame remains byte-identical
(6,013 rows, 20 columns). In the UK–EU slice of `dp-deliberately`, 153 of 867
metrics change, all for the EU-relations item. These are sensitivity outputs
from current readers, not revised original-paper estimates. A separate scan of
the actual SAQ2 form was not found; the codebook prints question wording,
answer labels and frequencies. Preserve that source-material gap for later
verification without reintroducing code 6 as a substantive answer.

**UKEU-04 — treat inapplicable post EU-scope responses as missing.**
**Status: approved by the user on 2026-09-25 and adopted.** The
[codebook](../data/uk-eu-1995/codebook.txt) and retained
[value labels](../data/uk-eu-1995/value-labels.csv) call `TRABLOC2` (Q6b SAQ2)
and `PASPORT2` (Q17e SAQ2) code -1 “not applicable.” The 900-row source has
676 such responses on each item. Among 238 attendees, the same 14 people have
-1 on both; they also lack the post knowledge interview. Neither post item
contains code 8 in the source, though its value label allows “can't say.”

The archived `uk_eu.R` removes 8/9 but leaves -1. The resulting observed
source range [-1,5] makes each historical component `(raw + 1) / 6`, so the
14 inapplicable pairs become measured index zeros. The approved definition
excludes -1 and scales substantive 1–5 answers over [1,5], matching the
baseline wave. The 14 placeholder zeros become missing, and 209 other
attendee indices change. The old index mean over 238 rows is 0.638305;
the corrected mean over 224 observed rows is 0.517299, so the means have
different denominators. No sample membership or other aggregate field changes.
All 238 historical and approved values are frozen alongside UKEU-03 in
[`approved_values.csv`](../audit/corrections/uk-eu-1995/approved_values.csv).
The raw -1 responses remain available in the source export.

On the UKEU-03-corrected baseline, `dp-distortions` changes 13 of 19 CSVs
and 15 of 28 paired CR2 inference rows, with no recorded 0.05 threshold
crossing. The `dp-learning` analysis frame remains byte-identical (6,013
rows, 20 columns). In the UK–EU slice of `dp-deliberately`, 164 of 867 metrics
change, all for the EU-scope item. These are current-reader sensitivities,
not claims about the original paper's estimates. A standalone SAQ2 scan
remains unavailable; the source codebook prints question wording, labels and
frequencies for both items.

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

**UKM-01 — correct the post-wave Commonwealth field.** **Status: approved
by the user on 2026-09-25 and adopted for the historical nine-item aggregate.**
The archived `uk_monarchy.R` and deposited aggregate reuse baseline `Q5C` in
the T2 score. The existing eight-item knowledge build already uses `R5C`. The
[codebook](../data/uk-monarchy-1996/codebook.pdf) distinguishes
`HEADCOM1`/Q5c from `HEADCOM2`/W5c, and the retained
[variable dictionary](../data/uk-monarchy-1996/variables.csv) identifies
`R5C` as the departure question. Its [value labels](../data/uk-monarchy-1996/value-labels.csv)
retain the same true/false answer scale. The correction substitutes `R5C` for
`Q5C` only in the post battery; it preserves the nine-item denominator, answer
key, 258-person sample and baseline `t1know`.

Among attendees, 58 raw post-item scores differ and 55 `t2know` values change;
mean nine-item T2 knowledge moves from 0.795866 to 0.793712. Joint knowledge
changes for 30 people because the post item also enters the T1-by-T2
correctness product. Ten respondent fields and ten derived fields consequently
change, including 62 `grpgain` differences above the 1e-10 parity tolerance
(one additional row differs only in serialized rounding). All 20 fields and
all 258 before/after respondent values per field are frozen in
[`approved_values.csv`](../audit/corrections/uk-monarchy-1996/approved_values.csv).
The eight-item knowledge output remains on its existing `R5C` definition.

On the current WTU-corrected baseline, `dp-distortions` changes none of its 19
output CSVs or 28 paired CR2 inference rows. The `dp-learning` frame retains
6,013 rows and 21 columns; only 55 UK Monarchy `k2` cells change. Its model
output changes 35 of 69 rows, including the main `k1` estimate from 0.472770
to 0.469307, with no absolute z-statistic crossing 1.96. In the UK Monarchy
slice of `dp-deliberately`, 130 of 816 metrics change, all on the knowledge
aggregate; the event-level fraction-learning estimate moves from 0.763566
to 0.736434. These are sensitivity results from the current downstream
readers, not claims about the original papers' estimates.

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

**UKGE-02 — use the same tax-and-spending question at both waves.**
**Status: approved by the user on 2026-09-25 after reproducing the paper's
policy-attitude table, and adopted.** The raw `TAXR1` and `TAXR2` fields are
Q13, the 1–7 preference between tax cuts and social-service spending. The
historical baseline `ukbge.t1tax` uses `TAXR1`, but the historical post
`ukbge.t2tax` uses `TAXRET2`, Q4c's five-category retrospective judgment of
whether taxes had risen since 1992. The deposited `t2tax` variable is labelled
as a relabel of `txr2re` (the Q13 recode), while its observed values follow
`txr2reco` (the Q4c recode). See the [codebook](../data/uk-general-election-1997/codebook.txt)
and source [variable labels](../data/uk-general-election-1997/variables.csv).
This mismatch could have been deliberate in an intermediate data version, but
it does not define a longitudinal tax-and-spending attitude.

The retained [election paper](../data/uk-general-election-1997/papers/british-election-paper.pdf),
Table 3, explicitly defines “Taxes vs. Spending” as a 1–7 policy attitude. We
independently recalculated all nine policy rows from the deposited raw survey,
using the 275 records with `filter == 1`, substantive codes on each item's
printed scale, separate available-case means by wave, unrounded differences of
those means, and two-sided paired t-tests on complete pairs. **All 18 means and
nine differences reproduce Table 3 at its two-decimal precision.** For Q13 tax,
mean T1 is 5.856 and mean T2 is 5.810, printing as 5.86 and 5.81; their
difference prints as -0.05. The complete-pair t-test uses 270 people and gives
p = 0.7729, printing as the paper's 0.773. The other non-thresholded printed
probabilities also reproduce: redistribution 0.002, minimum wage 0.003, and
tax fairness 0.201. The paper prints 0.001 for the remaining smaller p-values.
The paper describes 276 attendees overall; the deposited file's selected roster
contains 275. The exact source of that one-person count difference remains
unresolved. Reproducing its Table 3 does not settle that separate roster issue
or turn this draft paper into a benchmark for every downstream analysis.

The approved change replaces only the post component with `TAXR2`, retaining
the 275-person sample and Q13's historical seven-category recode and float
storage. Valid post indices rise from 259 to 274. Of the 275 values, 207 change
among jointly observed people and 17 change missingness (16 gain a Q13 response;
one loses a Q4c-only response). Mean `ukbge.t2tax` over available respondents
changes from 0.716216 to 0.801898; these means have different denominators.
All 275 historical and approved values are frozen in
[`approved_values.csv`](../audit/corrections/uk-general-election-1997/approved_values.csv)
alongside the earlier UKGE-03 correction. No other aggregate column changes.
The raw `TAXRET2` values remain in `survey.sav`; the canonical
`source_responses` table now carries `TAXR2` as the post tax-index input rather
than the superseded `TAXRET2` input.

In a read-only current-reader sensitivity, `dp-distortions` changes 12 rows of
its Table 2 and 24 rows of Table 3 without a recorded 0.05 threshold crossing.
Its mean absolute net attitude change moves 0.089099 → 0.088715 and mean gross
change 0.202316 → 0.201775. The `dp-deliberately` audit changes 166 of 36,345
metrics, all on the UK General Election tax item; its paired tax-attitude
change moves -0.096133 → -0.003333 as paired coverage rises from 256 to 270.
These are sensitivities of current readers, not re-estimates of the paper.
A separate scan of the fielded questionnaire was not found; the codebook
transcribes the question wording and response labels.

### UKGE-03: Post Labour minimum-wage knowledge uses the baseline response

**Status: approved by the user on 2026-09-24 and implemented.**
Replace only `wagel1` with `wagel2`
in the post Labour minimum-wage correctness item and rebuild its dependent
knowledge and group variables. Keep the 5–7 correctness range, missing-as-incorrect
rule, baseline scoring, 275-person sample and 15 groups. Do not bundle UKGE-02's
separate tax-construct mismatch.

The [archived script](https://github.com/soodoku/dp-data/blob/historical-cdd-scripts/legacy/poll_scripts/uk_bge.R)
line 104 assigns `wagel2pk <- nona(wagel1 > 4)`, but line 276 correctly builds
`wagel2raw` from `wagel2`. The [codebook](../data/uk-general-election-1997/codebook.txt),
lines 228–229 and 3595–3636, identifies Labour minimum-wage placement at T1/T2,
Q14. The [election manuscript](../data/uk-general-election-1997/papers/british-election-paper.pdf),
printed pages 6 and 8, describes the seven-point placement scale and Labour's
support for a minimum wage. This manuscript is a draft, not an exact published
replication benchmark.

Crucially, the deposited `survey.sav` variable `wgel2cor` matches the proposed
post scoring for **all 275 attendees**, whereas the historical composite differs
on 54. Its label incorrectly mentions tax and `wagel1`; its actual values support
`wagel2`. The existing raw knowledge battery in `metadata/knowledge_items.csv`
already uses `wagel2`, as does the archived raw export. This correction aligns
the reconstructed composites with that battery and deposited scored item.
Intentional carryover is therefore poorly supported; no rationale for it was found.

**Instrument limitation:** no standalone fielded questionnaire was located in
this poll folder. The codebook transcribes Q14 but contains inconsistent printed
endpoint numbering. Preserve the existing scale/key; the manuscript and deposited
scores corroborate this narrow wave correction without resolving every label typo.

[Recorded comparisons](../audit/corrections/uk-general-election-1997/):

| Historical sample, 275 people | Historical | Proposed |
| --- | ---: | ---: |
| Labour post item correct | 237 | 235 |
| Mean post knowledge | 0.64800000 | 0.64751515 |
| Mean baseline knowledge | 0.54472727 | unchanged |
| Mean pre–post gain | 0.10327273 | 0.10278788 |
| Mean jointly correct knowledge | 0.42909091 | 0.42230303 |

26 post scores rise and 28 fall, each by 1/15. The mean barely changes because
these movements offset. The 28 losses also reduce jointly correct knowledge:
baseline reuse had guaranteed that a previously correct answer remained correct.
All 275 IDs and 15 groups remain, with no missingness changes. Nineteen aggregate
columns change, including score aliases, group means, peer scores and logs.
The audit distinguishes differences above 1e-12 from floating-point residue.

Among the other 935 source records, 721 lose a spurious baseline-derived 1/15
post score. Under the preserved missing-as-incorrect convention their post score
becomes zero, not missing. These are not evidence of observed post interviews;
users must still apply the appropriate sample membership. Across all 1,210
canonical records, 775 post knowledge scores and 749 joint scores change.

**Downstream adoption comparison:** dp-learning revision
`57e83ad7937c9fea01a7bced9ead1b20dd157ab8` was run against paired reconstructed
inputs. Only `k2` changes in its analysis frame (54 values); its baseline predictors
and membership are unchanged. The main model retains 5,827 observations; its
baseline-knowledge coefficient changes .481825 → .478004 and its baseline-knowledge
× BA-or-more interaction changes −.102384 → −.098731. The minority model retains
5,179 observations. The briefing model is identical and has a singular fit in
both arms. Coefficients, standard errors and fit diagnostics are saved in the
comparison directory; these are the actual mixed models, not a full manuscript
or item-latent-model rerun.

The item-linked model is not included: its existing assertion fails for the
unrelated `sm` battery (162 of 239 baseline scores disagree, maximum .75).
This failure occurs before applying UKGE-03; see SM-04 below. The comparison does
not suppress the production assertion or claim to have validated that model.
Existing downstream source pins are unchanged; adoption comparisons do not
silently repoint those repositories.

Implementation versions the six dependent respondent definitions and affected
group/poll measures as `ukge-03-v2`. Frozen approved values cover all 19 changed
aggregate fields and 275 attendees. Comparison checks verify both historical
reference values and exact approved replacements, and reject unreviewed
differences. The five original review CSVs reproduce byte-for-byte after
adoption. Historical benchmarks and the separate raw-item battery remain intact.

Reproduce from dp-data, then from dp-learning respectively:

```sh
Rscript scripts/review_uk_ge_correction.R /tmp/uk-ge-review
Rscript ../dp-data/scripts/review_uk_ge_downstream.R /tmp/uk-ge-review /tmp/uk-ge-learning
```

**UKGE-04 — demographic and missing-code boundaries.** Ethnicity -7 becomes
missing, including two attendees; codes other than 1 become the historical
minority indicator. Age -7 becomes missing. School education is overridden by
higher qualifications; household income's 16 categories collapse to five and
high income means a collapsed category above 2. Source labels and the existing
codebook establish the raw categories; the archived script establishes the
historical transformations. All 35 respondent-field targets match for the 275
attendees at 1e-10, including missingness. This is reproduction evidence, not
an endorsement of the tax mismatch or the cross-wave knowledge dependency.

### UKGE-05: Exclude a source nonparticipant from early group metrics

**Status: approved by the user on 2026-09-25 and adopted.** The original poll
script computes group dispersion and peer gain before the final exported
attendance restriction. One later-excluded source respondent therefore
contributes to these early group calculations. The correction uses the source
`PARTIC == 1` flag for group-metric eligibility, while preserving the raw
group assignment and the same 275 exported respondents. The shared group and
poll functions then recompute the derived metrics. The source
[codebook](../data/uk-general-election-1997/codebook.txt) explicitly identifies
serial 4416 as assigned to a small group but without a T2 questionnaire. In
`survey.sav`, serial 4416 is source row 1, group 9, `PARTIC == 0`, `FILTER == 0`,
and `RECRUIT == 4` (“will go to Manchester”); its post policy and factual
answers are missing. The file has 276 group assignments, 275 participants, and
275 selected rows. The [paper](../data/uk-general-election-1997/papers/british-election-paper.pdf)
reports counting 276 arrivals; that count agrees with assignments but does not
establish whether 4416 attended or how the paper defined its Table 3 sample.
The codebook's participant tabulation is 275. Do not infer attendance from an
assignment or recruitment intent.

Excluding 4416 changes only group 9: `grpgain`, `grpgainr`, `loggain`,
`avgsd`, and `genvar` each change for its 17 selected respondents, with no
missingness change. Across all 275 selected people, mean `grpgain` changes
0.368422 → 0.369915 and mean `avgsd` 0.285585 → 0.285622; the largest
individual absolute changes are 0.029902 and 0.000602 respectively. Mean
`genvar` changes 0.245069 → 0.245237, with maximum absolute change 0.002721.
The frozen historical and approved values are in
[`approved_values.csv`](../audit/corrections/uk-general-election-1997/approved_values.csv).
The exact previous-build comparison finds only these five fields changed for
those 17 people. The historical-benchmark comparison reports 73 changed gain
values because it also contains the separately approved UKGE-03 knowledge
correction; no differences are unexplained.

A read-only `dp-learning` sensitivity changes 17 `heterogeneity` inputs in its
6,013-row analysis frame; it changes no sample membership or other model input.
The main mixed model retains 5,830 observations and its largest fixed-effect
coefficient change is 0.000328; the minority model retains 5,182 and its
largest change is 0.000382. Current `dp-distortions` analysis code reads the
attitude, group-ID, and demographic fields, none of which change here; its
analytical inputs are therefore identical (a code-path inference, not a rerun).
The paper's 276-arrival count remains a separate roster question; it does not
justify counting a record explicitly marked nonparticipant in the participant
group metrics.

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
though the final historical wide table exposes only six attitude pairs. The
[codebook](../data/cpl-1996/codebook.txt) identifies COMPET1 as Q20a, benefits
of competition over regulation. The archived `tx_cpl.R` explicitly gives the
poll seven indices and includes competition in extremity and dispersion;
`05_fix_data.R` later removes the competition attitude columns for CPL, SWEPCO,
and WTU without recomputing those descriptors. The retained cross-poll
[attitude catalog](../data/shared/codebooks/attitude_indices/allpollindices.csv)
lists six exposed CPL indices. This sequence could reflect a deliberate change
in the public attitude battery rather than an accidental omission from the
earlier group metrics.

A six-index counterfactual on the same 216 selected respondents removes only
competition from the original pre-final-rescaling attitude matrix. Competition
is observed for 177 of 216. Relative to the seven-index historical values,
`attextreme` changes for 175 respondents (mean 0.296775 → 0.287434; maximum
absolute change 0.060714), while `meanxtreme`, `avgsd`, and `genvar` change for
all 216 (means 0.296775 → 0.287434, 0.261136 → 0.240753, and 0.184242 →
0.183418 respectively). No missingness changes. The historical `numindices`
remains 7 even though only six pairs are exposed. In a read-only sensitivity
using the current `dp-learning` reader, the 6,013-row analysis frame changes
only its `extremity` (175 CPL values above 1e-10) and `heterogeneity` (all 216
CPL values) inputs; no sample or missingness changes. Thirteen additional
`extremity` cells differ only below 1e-10 because the export and recomputation
have different storage precision. This is an input comparison, not a model
re-estimation. Preserve the seven-index descriptors for now; if six-index
descriptors are needed, define and compare them explicitly
in the expanded schema rather than silently redefining the historical fields.
Codebook 99/999 sentinels are preserved in raw responses and removed where
required for historical scoring.
Dictionary-based `response_status` does not yet encode every codebook sentinel
in these newly added demographic and attitude fields; `n_observed_fields` must
not be used as a scoring denominator or validated response-completeness count.

### CPL-05: Group gain uses a truncated early group-size calculation

The original `tx_cpl.R` passes `rep(1, length(cpl))` to the group-size
helper. For a data frame, `length()` counts columns. Its `cpl2.sav` input has
196 columns; six columns added before this operation make the vector length
202. The public `cpl.sav` has 195 columns, so using its column count would
silently produce a different historical result. The review script reconstructs
the first 202 source rows for this early denominator and all eligible rows for
later group composition. This reproduces the historical gain values.

The checked `cpl2.sav` SHA-256 is
`c29f1d2e2ab4ed10888e1a9857d7e09fe0541bada81e5d25db1d15b914cd11ce`.
Using a 201-row denominator changed 12 exported gain values during validation.
**CPL-05 approved correction.** The archived `grpfun` helper indexes that
202-element vector with the full group-presence vector. Values past source row
202 become missing; its `sum(..., na.rm = TRUE)` then silently excludes them.
The source codebook's `PART` table records 216 participants and 1,030
nonparticipants, and its `GROUP` table gives 16 group counts totaling 216.
Those counts match the full membership counts exactly. Ten groups are
undercounted by the historical calculation (one to three members each).

The diagnostic `scripts/review_cpl_group_gain.R` reproduces the short-vector
indexing and compares the corrected calculation with a separately calculated
mean over the focal respondent's actual peers. They agree within `1e-12`.
It changes only `grpgain`, `grpgainr`, and `loggain`: 132 of 216 participant
values change, with no changes to IDs, membership, missingness, knowledge
scores, or other aggregate fields. Mean gain falls from 0.1549723023 to
0.1540506270; the largest individual decrease is 0.0052910053. Mean log gain
changes from -1.9735843252 to -1.9797921411. All 1,030 other source records
retain missing gain. The correction preserves the existing joint pre-times-post
correctness definition; it does not substitute a baseline-only peer measure.

Evidence and group-level comparisons are in `audit/corrections/cpl-1996/`.
The original `cpl2.sav` version and hash above come from the earlier recorded
source audit; this review directly checks the archived code, current source
membership, and the reproduced 202-row historical calculation, without
re-reading those original file bytes. Stanford's utilities overview and the
retained List–Luskin–Fishkin–McLean paper provide design and data-use context,
but neither is treated as proof of this denominator. This is a computation
issue, not evidence that respondents were miscoded. The paired downstream check
produces byte-identical dp-distortions output CSVs, including all 28 pooled
CR2 estimates, and an exactly identical
dp-learning analysis frame (6,013 rows, 20 columns). The expensive wild
bootstrap was not rerun; the unchanged deterministic inputs and estimates are
recorded in the audit. The current dp-learning peer measure is constructed
separately from baseline items and is unchanged by this correction. The user
approved CPL-05 after reviewing the column-count error and its consequences.
The corrected build uses complete group membership for the denominator and
records `cpl-05-v2` for the three changed derived fields. All 216 historical
and approved values per field are frozen in `approved_values.csv`; the review
script replays both calculations from the retained survey.

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
**Status: approved and adopted two-item correction (SWE-02).** The archived
[`tx_swp.R`](https://github.com/soodoku/dp-data/blob/historical-cdd-scripts/legacy/poll_scripts/tx_swp.R#L92-L96)
forms T1 conservation from `addfac1` and `reduce1`, but asks for nonexistent
`addfact2` alongside `reduce2` at T2. The absent data-frame column contributes
nothing to `cbind`; the deposited T2 index and maintained reconstruction use
`REDUCE2` alone. All 232 historical values reproduce exactly. The WTU script
has the same misspelling, but WTU requires its own review and approval.

The poll-specific [codebook](../data/swepco-1996/codebook.txt) identifies
`REDUCE2` as Q2b, the importance of helping customers use energy more
efficiently to reduce gas and coal use, and `ADDFAC2` as Q10b, the importance
of services and technologies that reduce the need for new generation facilities.
Both are separate 0–10 post questions; the corresponding T1 questions are
already paired in the historical index. The [index memorandum](../data/shared/codebooks/attitude_indices/past_versions/appendix-attitude-indices-6-07-15-rcl.pdf),
PDF page 16, specifies two conservation components for the utility polls.
The [NREL utility report](../data/shared/reports/utilities-nrel-report.pdf)
places SWEPCO with CPL and WTU in this common research design, but does not
verify the exact composite values.

The approved build averages available `ADDFAC2` and `REDUCE2` responses,
then keeps the historical T2 division by 10 and missing-value fill. It leaves
the T1 empirical [3,10] calibration, all other attitude definitions, sample,
knowledge scoring and group-derived descriptors unchanged. Among the 232
attendees, 229 answered `ADDFAC2`, 231 answered `REDUCE2`, and 228 answered
both. Their paired item correlation is 0.271; related wording alone should
not be mistaken for identical measurement. The earlier portable files remain
unreadable, and the archived script's execution provenance is not established.
The codebook and memorandum support the intended components but do not
independently prescribe whether T2 should use empirical calibration instead
of the historical [0,10] scaling. That is a separate specification decision.

[Recorded respondent and downstream comparisons](../audit/corrections/swepco-1996/)
show that only `swp.t2att3` changes: 137 of 232 values, 79 down and 58 up,
with no missingness change. Its mean falls from 0.875862 to 0.853664; the
largest absolute respondent difference is 0.5. The existing attitude catalog
uses this index. In the current dp-distortions build, SWEPCO's poll-level
homogeneity estimate moves 0.028495 to 0.030709 and polarization 0.036791
to 0.032849. Pooled homogeneity moves 0.012950 to 0.013025 and pooled
polarization -0.022138 to -0.022271. Thirteen of 28 CR2 inference rows
change, with no 0.05-threshold crossing in either recorded p-value; the wild
bootstrap was not rerun. dp-learning's analysis frame remains exactly
identical (6,013 by 20), as do dp-deliberately's 210 checked outcome rows.
The approved respondent values are frozen by ID in `approved_values.csv`;
the diagnostic replays the historical one-item formula against production.
Reproduce with:

```sh
Rscript scripts/review_swepco_conservation.R /tmp/swe-review
Rscript ../dp-data/scripts/review_uk_crime_downstream.R distortions /tmp/swe-review /tmp/swe-distortions
Rscript ../dp-data/scripts/review_uk_crime_downstream.R learning /tmp/swe-review /tmp/swe-learning
Rscript ../dp-data/scripts/review_uk_crime_downstream.R deliberately /tmp/swe-review /tmp/swe-deliberately
```

**SWE-03 — low-income index reflects an earlier, documented construct.**
The saved `t1att4`/`t2att4` exactly reproduce `NEEDTO1`/`NEEDTO2` divided by
10, with missing responses filled at 5 before scaling, for all 232 attendees
(two T1 and three T2 fills). The earlier archived
`historical-cdd-scripts:legacy/pete/datacleaning2012.R` explicitly defines this
same item for SWEPCO, CPL and WTU. SWEPCO's codebook identifies `NEEDTO` as Q3d:
meeting everyone's basic needs despite higher costs (the 2012 script's Q3c
comment conflicts with the codebook). A later index memorandum,
[`appendix-attitude-indices-6-07-15-rcl.pdf`](../data/shared/codebooks/attitude_indices/past_versions/appendix-attitude-indices-6-07-15-rcl.pdf),
printed page 17, specifies a different two-item *Helping Low Income Customer*
construct using Q2e `LOWINC` and Q19b `POOR`; a later poll script implements
that pair but does not reproduce the saved aggregate. Replacing the historical
item with this later construct would therefore change the question being
measured, not merely repair a misspelling. Preserve the saved NEEDTO definition;
consider a separately named LOWINC/POOR index if the schema is expanded.
A diagnostic available-item mean of empirically normalized LOWINC/POOR would
change 204 of 232 T1 and 201 of 232 T2 values, but is not an adopted recode;
the exact normalization helper used by the later script has not been recovered.

**SWE-04 — raw-scale research enters normalized extremity.**
**Status: approved by the user on 2026-09-25 and adopted.** The poll script
computes research from `RESCH1`/`FEDRCH1` on the raw 0–10 metric (`FEDRCH1` is
entirely missing) and fills missing means at 5. Its seven-index extremity and
group dispersion include this unscaled research value and competition.
`05_fix_data.R` later rescales the exposed research index to 0–1 and drops
competition without recomputing the descriptors. The historical definitions
reproduce both stages. The codebook explicitly gives Q2a `RESCH1` a 0–10
response scale. An average absolute deviation from .5 across 0–1 indices
should be at most .5; the saved extremity exceeds .5 for 213 of 232 attendees
and exceeds 1 for 147. Correcting only the research input to 0–1, while
retaining the historical seven-index set, changes 221 extremity values and the
group summaries for all 232 attendees (mean extremity 1.161876 to .304303).
The approved rule uses normalized research for extremity and group
variation, while keeping the seven-index battery, 232-person sample, and all
exposed attitude indices. It does not decide whether competition belongs in a
future six-index battery. Historical and approved values for all four changed
fields are frozen by `CASEID` in
[`approved_values.csv`](../audit/corrections/swepco-1996/approved_values.csv).
Renewables use an available raw mean calibrated over [1,10] at T1
and [0,10] at T2; other one-item 0–10 indices use their historical missing
fill of 5. All 39 historical respondent-field targets match for the 232
`PART == 1` attendees at 1e-10.

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

**WTU-03 — absent ADDFACT2 removes the post conservation component.**
**Status: approved by the user on 2026-09-25 and adopted.** As in
SWE-02, `tx_wtu.R` requests nonexistent `addfact2` alongside `reduce2`. The
source and WTU codebook instead contain `ADDFAC2` (Q10b, technologies that
reduce the need for new facilities) and `REDUCE2` (Q2b, reducing coal and gas
through efficient use), both on 0–10 importance scales. The WTU codebook
prints the question wording; no separate WTU questionnaire scan has been found
in the retained source folder or utility archive. The CPL and SWEPCO codebooks
print corresponding wording. CPL labels the efficient-use item Q2c because its
Q2b is federal research; WTU and SWEPCO label it Q2b. All three label the
additional-facilities item Q10b. Each source file contains `ADDFAC2` and
`REDUCE2` with substantive post responses, and none contains `ADDFACT2`.
The CPL script uses both correctly named post fields, whereas WTU and SWEPCO
request `addfact2`; all three scripts pair the two T1 fields. The later index
memorandum's page 16 heads a section for CPL, WTU and SWEPCO and lists two
conservation components, though it dates to 2015 and uses CPL wording. A
[contemporaneous utility-poll report](https://www.osti.gov/servlets/purl/836850)
confirms that all three asked about services and technologies that reduce the
need for additional facilities, but does not specify this composite. The
copied misspelling across WTU and SWEPCO could reflect shared code rather
than independent mistakes; it does not by itself establish the original
analyst's intent.

The historical WTU T2 index uses REDUCE2 alone over empirical [3,10]; T1
averages ADDFAC1/REDUCE1 over [2,10]. Missing indices are filled at .5. Among
230 participants, 227 have observed ADDFAC2 and all 230 have REDUCE2. A
two-item available-response mean calibrated over its observed [1.5,10] range
changes 179 T2 scores (mean 0.759627 to 0.782864; largest absolute change
0.588235), with no sample or other WTU aggregate field change. A separate
theoretical [0,10] calibration changes 180 scores and has mean 0.815435; it
is not part of the proposed correction. The current dp-distortions sensitivity
changes 13 of 19 output CSVs and 16 of 28 paired CR2 inference rows. WTU's
homogeneity estimate moves 0.014766 to 0.027640 and polarization 0.012467 to
0.017519; neither recorded p-value measure crosses 0.05. The current
dp-learning analysis frame remains identical in values and shape
(6,013 rows, 20 columns). The approved production rule averages available
`ADDFAC2` and `REDUCE2`, then scales over the observed [1.5,10] range.
The 230 historical and approved respondent values are frozen in
[`approved_values.csv`](../audit/corrections/wtu-1996/approved_values.csv).
No other WTU aggregate field or sample membership changes.

**WTU-04 — historical low-income index uses a documented earlier construct.**
The `NEEDTO1`/`NEEDTO2` variant, divided by 10 with missing filled at 5, exactly
reproduces the saved aggregate. It is explicit in the earlier archived
`historical-cdd-scripts:legacy/pete/datacleaning2012.R` for WTU as well as
SWEPCO and CPL, and remains commented in the later WTU poll script. The WTU
codebook identifies `NEEDTO` as Q3d, meeting basic needs despite higher costs.
The later script instead uses `LOWINC1`/`POOR1` and reuses the
baseline pair at T2; its active code does not reproduce the saved index.
As with SWE-03, preserve the earlier construct and treat any later low-income
composite as a separately defined candidate, not an automatic replacement.

**WTU-05 — raw-scale research enters normalized extremity.**
**Status: approved by the user on 2026-09-25 and adopted.** As in SWE-04,
the historical seven-index extremity and group dispersion include unscaled
0–10 baseline research and the subsequently removed competition item. The WTU
codebook explicitly gives Q2a `RESCH1` a 0–10 response scale, while the other
six inputs to these calculations are scaled to 0–1. The final research columns
are normalized over [0,10] at T1 and [1,10] at T2, with missing raw means filled
at 5, but extremity and dispersion are not recomputed. Historical extremity
exceeds the .5 maximum of a 0–1-index average deviation for 212 of 230
attendees and exceeds 1 for 137. Dividing only the research input by 10 in the
derived calculations, while retaining all seven indices, changes individual
extremity for 219 attendees and the group extremity, average SD and generalized
variance for all 230; no missingness changes. Mean extremity would move from
1.113256 to .292386, average SD from .600537 to .271398 and generalized
variance from .298721 to .214985. The approved rule uses normalized
research for these descriptors and retains the seven-index battery, 230-person
sample and all exposed attitude indices. Historical and approved values for
all four changed fields are frozen by `CASEID` in
[`approved_values.csv`](../audit/corrections/wtu-1996/approved_values.csv).
Whether competition belongs in a future six-index battery remains a separate
question. Renewables' available raw means are
normalized over [2.5,10] at both waves and missing indices filled at .5.
All 39 historical respondent-field targets match for 230 `PART == 1` attendees
at 1e-10. These calibrations are fixed for source-row subsets; values outside
the attendee calibration population are not silently clipped.

The combined SWE-04 and WTU-05 correction changes only `attextreme`,
`meanxtreme`, `avgsd` and `genvar` in the aggregate; every other poll and
all respondent sample memberships, knowledge scores, and attitude indices
are unchanged. Current dp-learning reads the aggregate fields as `extremity`
and `heterogeneity`: a read-only before/after run changed 440 and 462 frame
values respectively, with no missingness or model-sample change. Its main model
retained 5,830 observations and moved the extremity coefficient from -.00948
to -.06994; its minority model retained 5,182 and moved it from -.01957 to
-.10073. These model changes are consequences, not the justification for the
recode. Current dp-distortions and dp-deliberately read pinned historical
benchmark files, which this correction does not alter.

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

### AUS-02: Aggregate knowledge uses a different battery and flag rule

**Preserve / review.** The 347-person aggregate reconstruction uses 12 items,
whereas AUS-01 concerns the separate ten-item deposited battery. The active
preserved `aus_republic.R` applies `DKCHG1` to four symbolic-change items; its
commented alternative omits the gate and exactly reproduces the aggregate.
Applying the active gate changes 52 baseline/joint scores, by as much as 0.25.
The aggregate's `NUMITEMS = 11` is also inconsistent with its 12-item denominator.
Keep the descriptor and denominator separately rather than forcing agreement.
Issue-specific scores are absent from the final aggregate even though later
syntax constructs them. Check the fielded change-question routing, index memo,
and script/export dates before choosing a version.

### AUS-03: Extremity omissions and a cross-wave ranking typo

**Status: adopted narrow script corrections.** The archived `aus_republic.R`
lowercases every source name, then computes extremity from `workind1`,
`Demind1`, `Tradind1` and `Polind1`. In R, the three capitalized references
resolve to `NULL`; `cbind()` silently omits them. The formula explicitly names
workability, democracy, tradition and politicization. The source
[variable inventory](../data/australia-republic-1999/variables.csv) defines all
four T1 indices, and each reconstructed index matches its deposited score for
all paired attendee values. We now average the available absolute deviations
from 0.5 across those four indices. National autonomy remains excluded from
this individual extremity formula, while the existing five-index group
dispersion and generalized variance remain unchanged. Of 347 attendees, 320
observed extremity scores change and one previously missing score becomes
observed; their group mean `meanxtreme` changes for all 347. The one newly
observed score belongs to CASEID 312 (source row 3714): workability is missing,
tradition is 0.625, and the other two named indices are missing.

The same script's T2 popular-election ranking score reads `firstop3` and
`secop3` only in its don't-know midpoint condition; all its other conditions
read `firstop2` and `secop2`, and the T1/T3 midpoint conditions each use their
own wave. The source variable labels identify distinct T2 (WA5a/b) and T3
(ZA14a/b) questions, with code 97 meaning don't know in both waves. We now
use the T2 responses for the T2 midpoint. Five observed scores change from
0.5 to 0.75, four 0.5 scores become missing, and 22 missing scores become 0.5:
31 of 347 records have a value or missingness change. The 347-person sample,
ranking order, all other wave scores, and AUS-02 knowledge policy stay fixed.
The [frozen comparison](../audit/corrections/australia-republic-1999/approved_values.csv)
records old and corrected values by CASEID for `attextreme`, `meanxtreme` and
`aus.popparl2`; the only other Australia deviations from the historical
aggregate remain the earlier AUS-04 `grpgain`/`loggain` correction.

The folder's `codebook.pdf` is the separate Australian Constitutional Referendum
Study, described there as a 3,400-record survey, while this deliberative-poll
source contains 4,659 rows. It cannot establish these poll-specific question
wordings or recodes. For these corrections we rely on the archived poll script,
labels attached to this poll's `survey.sav`, its reconstructed indices, and the
poll [paper](../data/australia-republic-1999/papers/adp5.pdf). Find the fielded
poll questionnaire before deciding AUS-01 or AUS-02.

### AUS-04: Participant gains now join by source row

**Status: approved and adopted row-alignment correction.** The archived
`aus_republic.R` computes 347 participant gain numerators, but assigns them
through `ifelse` over all 4,659 source rows. R recycles the 347 values before
selecting participants. The deposited gain therefore uses numerator position
`((source_row - 1) %% 347) + 1` and the actual person's joint-knowledge
denominator. The maintained build now joins the already computed numerator to
the participant's `source_row`. It leaves the 12 item answers, group roster,
archived gain formula, `numitems = 11` denominator and all other descriptors
unchanged. The [codebook](../data/australia-republic-1999/codebook.pdf) and
[poll report](../data/australia-republic-1999/papers/adp5.pdf) establish the
sample and small-group context; the archived `groupgain` helper is the direct
formula evidence. The 11-versus-12 denominator still requires separate review.

[Exact values](../audit/corrections/australia-republic-1999/approved_values.csv)
show 342 finite paired changes above 1e-10 and one missingness change in each
of `grpgain` and `loggain`. A misassigned positive infinity disappears in the
corrected values. Finite `grpgain` mean changes from 0.614531 to 0.441952;
the maximum finite paired difference is 5.181818. The diagnostic independently
replays the recycled historical assignment and verifies the deposited values.
`make polardata compare-polardata` reports zero unexplained differences; only
these two aggregate fields change. The recorded dp-distortions output files
(19 of 19) and dp-deliberately's paired outcomes are byte-identical, and
dp-learning's 6,013-by-20 analysis frame is identical. These checks do not
establish effects in downstream analyses that consume `grpgain` directly.
Reproduce the respondent comparison with
`Rscript scripts/review_australia_gain.R`.

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
source `t1know`/`t2know`. That older battery selection depends on derived
source columns. BTPGE-03 below now independently reconstructs the aggregate
from raw answers; neither result reconstructs the earliest field-file merge
or establishes a census of attendees. `caseid_original` and
`smgrpnumber` identify people and 15 groups.

**BTPGE-02 — existing missingness divergence.** Seven code--1 refusals remain
missing rather than incorrect. Zero-filled scores are unchanged. Recheck
[questionnaires.doc](../data/btp-general-election-2004/questionnaires.doc), the
code-to-label map, and the complete-score filter's purpose. Nine-item scoring
must use actual codes, not R factor positions. Do not expand the sample merely
to reconcile the 250-person battery with a smaller aggregate sample.

### BTPGE-03: Raw answers, rounding and the summary sample are now explicit

The aggregate is independently reconstructed from raw answer columns in
`data/btp-general-election-2004/raw-responses.dta`, an unchanged copy of
`data/BTP/2004.GE/2004GE.dta` (2,826 rows). Original `caseid` joins the selected
299-row source's `caseid_original`; transformed selected-source attitude columns
are not used as answers. Attitudes use `round((raw - 1) / 6, 5)` followed by
float32 storage. Exact fractions change values by about 0.000003.

`03_data.R` computes group/poll summaries on 299 people, then drops zero
`t2know` or missing extremity, leaving 246 historical export rows. BTPGE-05
corrects the zero-score sample rule, yielding 248 export rows. The separate
250-person knowledge battery in BTPGE-01 is not this aggregate sample. Group high-income
share uses collapsed income `> 7`; final individual high income uses `> 5`.
Review original sample and income specifications before unifying either pair.

### BTPGE-04: Baseline poll knowledge uses a larger calibration sample

The historical `t1knowlevel = 0.662015497684479` uses 645 complete baseline
batteries from all 2,826 raw records. System missingness removes incomplete
batteries; `w4b62 == -1` also remains missing, whereas refusals in the other eight
items score zero. That distinction excludes two otherwise available batteries.
The descriptor averages float32 nine-item scores, rounds to seven decimals,
and stores float32. Final respondent scoring zero-fills all noncorrect answers.
Keys are 60=1, 61=2, 62/63/64=2, 65=4, 66=2, 68=4, 69=3;
`reagg.txt` explicitly repairs wave-F item 69. Consult the questionnaires,
calibration-universe definition and repair history before changing the descriptor.

### BTPGE-05: Zero correct post answers do not mean the post wave is absent (corrected)

The archived `merge_data_scripts/03_data.R` filters this poll on `t2know == 0`
as well as missing baseline attitude extremity. The 299-row selected source has
33 people with no answers to any of the nine post knowledge items. Their
reconstructed fixed-denominator score is zero, so they remain outside this
historical aggregate sample. Two other people, original case IDs 552 and 585,
answered all nine post items, are marked as participants, and have observed
attitude extremity. Both got zero answers correct. The
[questionnaire](../data/btp-general-election-2004/questionnaires.pdf) explicitly
invites "Don't know" answers for Q60 onward; case 585 also has one refusal.
The archived score filter incorrectly treats these observed zero scores as
absent post surveys. Source rows 52 and 246 correspond to aggregate case IDs
940052 and 940246 in groups 9403 and 9412.

Approved BTPGE-05 selects people with at least one observed post knowledge
response and observed extremity, adding exactly those two cases: 246 historical
export rows become 248, while the 33 with no post knowledge answers remain
excluded. Another 18 people with post knowledge answers lack extremity and
remain excluded. The archived group and poll summaries were computed before
the 246-row filter on all 299 selected source records, so this correction adds
rows without changing existing respondents' scientific values; the export row
number `X` is regenerated. The source identity, group, response count, score,
and inclusion status are frozen in
`audit/corrections/btp-general-election-2004/approved_inclusions.csv`.

### BTPGE-06: Attendance flag conflicts with recorded meetings

Original case ID 91 (aggregate ID 940080, small group 4) is already in the
historical aggregate. Both `survey.dta` and `raw-responses.dta` record
`dop4part = 0` and `dop4 = 0`; the `dop4` value label says “dop participant,
but not in this wave.” Yet both files also record `w4total = 5` and
`w4mtg1` through `w4mtg5` equal to 1, each labeled “attended.” This person
has observed post knowledge and attitudes. The attendance flag and session
records therefore contradict each other for this case; zero in `dop4part`
cannot by itself establish nonattendance. Keep the person in the aggregate
while checking the original session roster, the provenance of these fields,
and any correction history. BTPGE-05 did not change this inclusion, and no
attendance flag or group descriptor is changed here.

## BTP Health and Education 2005 — btp-health-education-2005

### BTPHE-01: Missing gender remains missing (corrected)

All 454 source respondents remain in the sample. CASEID 970104 (group 9707)
and 970404 (group 9727) have missing `gender` in the deposited source. The
historical `gender %in% 2` expression turned those two unknown answers into
`female = 0`, which means male in this binary field. Neither the
[pre](../data/btp-health-education-2005/questionnaire-pre.pdf) nor
[post](../data/btp-health-education-2005/questionnaire-post.pdf) instrument
contains an alternate gender question. The approved recode uses `gender == 2`,
so both derived values are missing. The source observations are untouched.

In group 9707, the female share rises from 8/19 = 0.421052632 to 8/18 =
0.444444444; in group 9727 it rises from 6/16 = 0.375 to 6/15 = 0.4.
The resulting female share, variance and SD change for all 35 respondents in
those two groups; the leave-one-out share changes for 33 observed genders and
becomes missing for the two unknown genders. The combined group entropy also
changes for those 35 rows. The existing centralized leave-one-out and entropy
helpers retain their historical denominator conventions; a separate
cross-poll review of missing-aware group formulas is needed before changing
those shared definitions. Case-level old and new values are frozen in
`audit/corrections/btp-health-education-2005/approved_values.csv`.

### BTPHE-02: Funding index and float storage reproduce the original definition

Pre-questionnaire Q7c–f asks about school-funding proposals even if taxes rise;
Q8f asks the importance of funding among school problems. Historical
`school_funding` averages all five. Combining importance with support may be
intentional; check the index memo's construct and weighting before changing it.
The reconstructed scale matches all 454 source rows.

The `hed_hlm.txt` alpha-generated cost/coverage, medical-quality and
government-involvement scales add components sequentially in float32, then divide
and store float32. Double-precision `rowMeans` differs by up to about 0.00000006.
Each extremity component is also stored as float32 before its final mean.
These storage stages are reproduced, without loosening scoring tolerances.
The BTPHE-01 correction now retains missing gender for two people; missing
race remains missing for six.

### BTPHE-03: Q15 calibration answer key (corrected)

The fielded pre-questionnaire Q15 asks where the United States ranks in math
skills among 29 wealthy industrialized countries. The poll's own education
briefing states 24th of 29, which is in the bottom 10. The source value labels
map "bottom 10" to code 2 and "top 10" to code 3. The archived `btp05.R`
script and the final 454-person knowledge scorer both use code 2. Only the
earlier 3,298-record calibration descriptor `t1knowlevel` treated code 3 as
correct. This was a reversed answer key, not a different scoring construct.

The approved correction changes only that calibration key to code 2. It keeps
the 3,298-record calibration universe, six question keys, available-item
missing policy, zero for all-six-missing, float32 storage and seven-decimal
rounding. The poll descriptor changes from 0.277147799730301 to
0.337037593126297. All 454 participant knowledge scores remain unchanged.
The source answers and identities remain in `calibration-responses.parquet`.
The 20 `genvar` differences against the frozen historical deposit are
preexisting singular covariance exceptions documented in X-09, not effects of
this correction.

## BTP Online Primaries 2004 — btp-online-primaries-2004

**BTPOP-01 — existing missingness and membership qualifications.** `expcont == 1`
selects 328 of 1,289 source records; original `id` is unique. There are 315 known
memberships in 16 groups and 13 people without a known group. Twenty-five code--1
refusals become missing in the existing build; zero-filled scores match.

The source meeting fields narrow this gap. Twelve of the 13 people with
missing `groupnumc` have `mtgatt = 0`. Original ID 908 has `mtgatt = 4`,
`mtg1:5 = 1, 1, 0, 1, 1`, and all seven post knowledge answers observed.
Its `session = 3` and `session_N = 14`, but neither field supplies a verified
final group ID. Among experimental records with both `session` and
`groupnumc` observed, seven have unequal values, including three who
attended at least three meetings. Thus assigning ID 908 to group 3 from
`session` alone could silently replace a later group transfer. This is the
same source file used for the separate presidential-primaries aggregate in
PR-01; that aggregate excludes ID 908 solely because its group is missing.

**Next check:** inspect [questionnaires.doc](../data/btp-online-primaries-2004/questionnaires.doc)
and original assignment/session logs, especially ID 908's final discussion
room. Keep the 328-person knowledge sample intact. Preserve its unknown
group and the 217-person aggregate until group membership can be established
or a separately reviewed missing-group policy is chosen. Keep invitee
assignment, attendance and analytic inclusion distinct.

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

**BGC-02 — civil-liberties index versions differ.** The source labels
`t1clibe`/`t2clibe` as Version E with five variables. The available draft-seven
memo reports Version D with seven items; the preserved R script comments suggest
six. The five-item mean of Q15_1, Q15_3, Q17_1, Q17_2 and Q17_4, excluding
99 and storing the result as float32, reproduces every stored Version E score
and its missingness at both waves. This component selection is an inference
supported by the version label and exact respondent-level reconstruction, not
an explicit formula in the surviving memo. Preserve Version E; find its original
syntax or final index memorandum before changing components. The questionnaire
and earlier drafts should be consulted to assess why Q15_2 was omitted.

**BGC-03 — income factor positions and summary vintage.** The historical R
reader turns income codes 0–6 into factor positions 1–7. It then sets position1
(no answer) missing, leaving observed codes1–6 as values2–7. The historical
individual high-income flag uses this value greater than2 after the final merge;
the group proportion was calculated earlier using greater than4. Preserve both
vintages. Questionnaire question 10 lists raw code 1 as under 50 BGN, 2 as
50–100, 3 as 100–150, 4 as 150–200, 5 as 200–300, and 6 as above 300 BGN
per household member per month. Thus the final individual flag includes raw
codes 2–6 (at least the 50–100 band), while the earlier group share includes
only codes 4–6 (at least the 150–200 band). The source has 278 respondents,
including five code-0 nonanswers; 193 meet the individual threshold and 28 meet
the group threshold. Applying the individual threshold to group shares would
change all 17 groups, raising their shares by 0.412–0.765. The published
`highinc` field has 193 yes values and five missing values, matching those
source counts. The original `vault/cdd/scripts/bulgaria.r` lines 93–104 show
the earlier `>4` rule and group-summary assignment. The questionnaire, labels,
and numerical contrast establish different definitions, but do not establish
whether the later `>2` rule was deliberate. Recover the final merge assignment
and any contemporary income-cutoff note before proposing a unified threshold;
recompute individual and group quantities together, not merely the exported
income code.

**BGC-04 — index sets and reconstruction coverage.** All 51 respondent targets
match all 278 source participants, including missingness, at 1e-10 tolerance.
Historical extremity includes the two-item drug-legalization index alongside the
12 exported attitude indices; dispersion uses only those 12. The death-penalty
item retains the historical four-category mapping 1→1,2→.75,3→.5,4→.25,
which does not reach zero. Check the questionnaire wording and scale origin
before changing either the index set or this endpoint. Knowledge remains the
seven-item fixed-denominator battery, with nonanswers scoring zero.

## California 2011 — california-whats-next-2011

### CA-01: The available source and deposited battery use different samples

The archived `ca_referendum.R` filters `part` to observed values and then
`t2t3filter == 1`. In the available 472-row merged source, that yields 396
people; all 396 have `part == 1`, `t2t3filter == 1`, and unique `id`. No person
with `t2t3filter == 1` is lost because `part` is missing. The separately
published, anonymous `ca.csv` battery has 401 rows. The five-row gap is
therefore not caused by that participation filter. The available source is the
file named `California_Merged_t1-t2-t3_6-28-11.dta`; the battery has no
respondent IDs. A different merged-file version or export may explain the gap,
but the present records cannot identify five individual additions. Do not
manufacture five people or infer a row crosswalk from scores.

### CA-02: Party-control scoring is correct in the current knowledge build

The pre-questionnaire asks which party controls the Senate and Assembly. The
source labels map Republican to code 1 and Democratic to code 2. The departure
questionnaire presents Democratic, Republican and Independent as separate
answers; Democratic is code 1 in that wave. The archived script scores the
departure Senate item `t3q27` as 1→correct, 2→incorrect, and 3→missing,
while its Assembly item scores 3→incorrect. Two of the 396 selected source
people answered Senate code 3. The script's later `nona` step turns missing
item scores to zero, so these two responses still contribute incorrect answers
to the final five-item knowledge score. The current
`metadata/knowledge_items.csv` specifies 3 as incorrect for both items.
This is a wave-specific category ordering and intermediate missing-value
inconsistency, not evidence for changing the final score. No recode is made.
The 396-versus-401 sample gap in CA-01 still prevents case-level comparison
to the deposited battery.

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

### EURO-02: Aggregate identity is distinct from deposited-battery ordering

The 348-person historical aggregate now reconstructs by original `UniqueID` and
`GROUP_T1BIS == 1`; this does not retroactively establish the ordering of the
anonymous deposited battery discussed in EURO-01. Keep those two claims separate.
SPSS user-missing codes 997–999 become explicit missing responses before scoring;
knowledge treats noncorrect answers as zero.

### EURO-03: Structural missingness and demographic meaning are preserved

Historical `t1knowcor` is missing for everyone despite six matched raw baseline/
departure items. Joint-score derivatives remain missing. The early group-gain
numerator uses the uncorrected baseline battery, but normalization by missing
joint knowledge leaves final peer gain missing. Adding joint scores is a new
measurement decision, not a repair required for reconstruction.

`educ4` is actually age at leaving education divided by 35. Ongoing education
(code 0) uses `min(2010 - birth_year, 35)` before division, and `03_data.R`
rounds to two decimals; higher education is `> 0.57`. It is not a four-category
qualification variable. Check the education instrument and index memo before
relabeling or changing that policy. The birthplace correction is EURO-04.

### EURO-04: Unknown birthplace does not establish minority status (corrected)

The archived `eu_2009.R` script explicitly assigned minority = 1 when the
respondent's birthplace or parents' birthplace was missing. The source value
labels identify code 999 as don't know or refusal, not a foreign birthplace.
Of 4,384 source records, five have domestic birth and unknown parents' birth;
two have both answers unknown. Those seven had minority = 1 solely because of
unknown information and now have minority missing. Confirmed foreign birth of
either the respondent or parents still gives minority = 1; both known domestic
answers give 0. The seven IDs and source codes are in
`audit/corrections/europolis-2009/approved_values.csv`.

None of the seven belongs to the 348-person historical aggregate, so its
respondent values, group minority shares and published aggregate numbers are
unchanged. The full-source respondent measure changes for precisely seven
people. This preserves the original source answers and leaves EURO-01's
anonymous battery linkage issue separate.

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

**NIC-02 — eleven-item historical battery reconstructed separately.** The
historical `polardata` battery includes three percentage questions in addition to
the eight closed/placement items. The codebook explicitly defines inclusive
correct ranges: WEDLOCK 25–40, AFDC 1–10, and UNEMP 5–10, in each of three
waves (codebook lines 4916–5668). Recomputing these from raw responses matches
every nonmissing stored correctness code across all 911 source records.
The historical baseline/post scores use waves 1/3; arrival is wave 2. Missing
answers score zero with a fixed denominator of 11. The existing eight-item
knowledge outputs retain their separate definition. SPEND2 code 9 is documented
as missing (line 5545); SPDRUG2 code 9 is likewise missing (line 3635).

### NIC-03: Correct birth-year conversion and event mode upstream

**Status: approved by the user on 2026-09-24 and implemented upstream.**
The age correction is
`age = 1996 - (1900 + BYEAR)`, preserving the existing year reference. This is age
attained during 1996, not exact age at the January event. `dp-data` must own this
recode; downstream readers must consume age directly, with no compensating
NIC-specific inversion. The same poll proposal corrects `mode` from online (1)
to face-to-face (0). Removal of both downstream NIC overrides belongs to the
same adoption, not a later optional cleanup.

The [codebook](../data/nic-1996/codebook.txt), lines 796–825, identifies `BIRTHDY1`
as date of birth and `BYEAR` as year born. BYEAR equals the final two digits of
BIRTHDY1 in 890 of 891 observed source records. The
[archived script](https://github.com/soodoku/dp-data/blob/historical-cdd-scripts/legacy/poll_scripts/nic1.R),
line 151, computes `ppage = 1996 - byear`; line 247 computes a separate
`age = 1996 - ppage`, recovering BYEAR itself. dp-learning repeats that inverse
and calls the result age. For someone born in 1962, upstream exports 1934 and
downstream calls them 62; the proposed year-based age is 34.

The scanned questionnaire was checked, but its identified SAQ2 pages do not
verify the baseline birthdate question. The codebook and respondent-level
birthdate crosscheck establish this proposal's evidence; do not claim that the
fielded baseline questionnaire was recovered.

[Recorded comparisons](../audit/corrections/nic-1996/):

| Historical NIC sample | Current upstream | Proposed upstream |
| --- | ---: | ---: |
| People retained | 466 | 466 |
| Observed ages | 458 | 458 |
| Mean age | 1941.83843 | 41.83843 |

All 458 observed ages fall by exactly 1900; missingness and identity are unchanged.
The age change affects only `ppage` and its dependent `meanage`; the mode
correction changes `mode` for all 466 historical rows. No other aggregate fields
change.
There are 891 observed ages among all 911 source records.

**Mode evidence:** `metadata/polls.csv` already describes NIC as face-to-face.
The [Luskin–Fishkin manuscript](../data/nic-1996/papers/luskin-fishkin-2002.pdf),
PDF pages 4 and 6, describes on-site moderated groups/plenaries and 466
participants arriving in Austin. The incorrect aggregate mode comes from the
NIC constant in `core_poll_constants()`. dp-learning currently forces this
value to zero; correcting it upstream and deleting that override preserves
the mode actually used in its models.

**Separate source anomalies, not silently repaired:** participant CASEIDs
10005580 and 10008740 have BYEAR95; 10008780 has94; 10011470 has96. Their recorded
birthdates agree with those years but their adult-screen flags contradict ages
0–2. CASEID10007590 has BYEAR7 while BIRTHDY1 ends67: the candidate age is89,
although29 would follow the full birthdate. All five passed the adult-screen
question. Nonparticipant10006530 also has BYEAR95. These require instrument and
source-version investigation; the proposed century correction neither imputes
their birth years nor invents additional missingness.

**Downstream comparison:** with dp-learning's existing 16–100 age eligibility,
451 NIC ages are usable under its current mistaken recode. Direct consumption of
the proposed upstream ages makes 454 usable: seven older participants become
eligible and four apparent ages0–2 become ineligible. Merely changing upstream
while retaining the downstream inversion makes all NIC ages fail eligibility.
That is why adoption must remove the reader's inversion at the same time.
The adapted diagnostic removes both NIC age and mode overrides. Production
dp-learning now also consumes the corrected export directly with both overrides
removed. Other existing reader policies remain pending the X-11 migration review.

In paired runs at dp-learning revision
`57e83ad7937c9fea01a7bced9ead1b20dd157ab8`, the main model sample changes
5,827 → 5,830, and its age-per-decade coefficient changes −.006791 → −.003358
(SE .001772 → .001774). The minority model changes 5,179 → 5,182 observations.
The briefing model changes 1,289 → 1,291 and is singular in both arms. These runs
isolate NIC age/mode against the aggregate baseline including the approved Crime
and UK Election corrections; they do not claim a
full manuscript replication. The original diagnostic omitted the item-linked model because of SM-04; the
subsequent production migration resolves that identity issue and runs the model.

Reproduce from dp-data, then dp-learning:

```sh
Rscript scripts/review_nic_age_correction.R /tmp/nic-age-review
Rscript ../dp-data/scripts/review_nic_age_downstream.R /tmp/nic-age-review /tmp/nic-age-learning
```

The same historical script's arrival extremity/dispersion mixes arrival waves for
the first six spending items with baseline foreign aid, welfare and social
security. That separate definition remains unchanged pending instrument and
analysis-specification review; it is not part of this age proposal.

**NIC-04 — missing historical identity and reconstruction coverage.** The
historical export and selected source each contain exactly one missing CASEID.
Canonical identity remains source-scoped; comparison matches the single missing
slot only after asserting its uniqueness on each side and matching the other
465 IDs. This is a within-file historical comparison, not a transferable linkage
key. All 45 respondent-field targets for all 466 historical rows reproduce values
and missingness within the existing 1e-10 tolerance. A second absent identity
must fail comparison. Raw source codes remain unchanged; integer lookup removes
only the SPSS floating-point artifacts below 1e-8. The group and poll derived
fields remain a separate reconstruction stage.

### NIC-05: Arrival gain is sensitive to stored indicator precision

The nine factual indicators stored in the historical SPSS data use a value
approximately `1 + 1e-11` for correct responses; the two placement indicators
use integer one. The arrival joint score therefore slightly exceeds one for
one otherwise all-correct respondent (about `1.00000000000819`). Its historical
gain is zero divided by a small negative denominator, yielding zero. Replacing
all indicators with exact binary integers instead produces `0/0`, changing
missingness. The historical reconstruction retains the documented indicator
storage stage for this calculation. A correction should specify how perfect
scores are treated, compare all arrival gains and missingness, and investigate
the original SPSS export precision before interpreting this as a scoring error.

## Tomorrow's Europe 2007 — tomorrows-europe-2007

**TE-01 — deposited-battery eligibility/order mismatch.** `t3part == 1` yields 359
departure respondents from 3,550 source rows, versus 335 deposited batteries.
The earlier 335-person battery comparison did not establish its selection or
ordering. The aggregate reconstruction below establishes a different, 344-person
sample; it does not resolve anonymous deposited-battery ordering. The departure `t3grp` is observed for
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

### TE-03: Historical aggregate selects 344 people by the earlier group field

The aggregate uses nonmissing `group_no`: 344 of 3,550 source records.
Departure `t3grp` selects 359, with 24 outside the historical sample and nine
historical people absent from that selection. Preserve raw IDs and the earlier
group assignment; changing to departure groups changes the analytic population.
Check attendance/assignment logs and the original merge before choosing a
preferred sample. TE-01 describes the separate 335-row deposited battery.

### TE-04: Two departure indices mix arrival and departure answers

**Status: approved and adopted (TE-04).** The military departure
index historically combined T3Q11a/c with T2Q12a:d. The departure trade
index combined its T3Q7a/d contrast with T2Q8. The corrected build uses
T3Q12a:d and T3Q8 while
preserving weighting, direction, available-item averaging, historical endpoints,
IDs and the 344-person sample. It does not change the downstream wave catalog.

The [questionnaire catalogued as post](../data/tomorrows-europe-2007/questionnaire-post.pdf)
contains trade Q7a/d and Q8 on PDF page 5 and military Q11a/c and Q12a:d on page 7.
The [index memorandum](../data/shared/codebooks/attitude_indices/past_versions/appendix-attitude-indices-6-07-15-rcl.pdf),
PDF page 19, lists those substantive components. No rationale for cross-wave
carryover was found. Observed T3 responses establish that departure versions
exist. Agreement between stored indices and the historical mixed-wave formulas
confirms reconstruction, not that mixed waves were intended.

**Evidence limits:** the questionnaire cover does not explicitly identify its
wave; complete arrival and translated instruments remain unverified. The original
SPSS recode referenced by the archived R script was not located. The memorandum
also describes a different military version subtracting Q11b; a distinct stored
`_f` variant exists. That weighting/specification issue remains separate. The
available attitudes report concerns the T1 whole sample, so it does not validate
the corrected departure means. These limits prevent claiming authorial intent
has been established.

[Recorded comparisons](../audit/corrections/tomorrows-europe-2007/):

| Departure index | Historical observed | Corrected observed | Historical mean | Corrected mean |
| --- | ---: | ---: | ---: | ---: |
| Military | 339 | 334 | .540020 | .537238 |
| Trade | 336 | 332 | .595833 | .610203 |

Military changes 282 jointly observed values and makes five scores missing.
Trade changes 213 jointly observed values, makes seven scores missing and adds
three observed scores. These available-observation means combine value and
missingness changes; respondent-level comparisons retain both explicitly.
All 344 IDs remain. The pension index and its fixed [-1, .875] endpoints remain
unchanged, as do all other aggregate fields.

Among the 3,206 other source records, military changes 22 observed values and
adds one score (23 → 24 observed); trade changes 17 observed values and adds
three scores (20 → 23 observed). These records are outside the historical
sample, not necessarily nonparticipants. Their membership is not reclassified.

**Current downstream impact is zero.** All 19 dp-distortions comparison CSVs,
including its 28 CR2 inference rows, are byte-identical. dp-learning's actual
analysis frame is exactly identical (6,013 × 20). The reason is substantive:
the current attitude catalog uses military T1→T2 and omits trade, so neither
modified T3 field enters those analyses. This does not establish that the
catalog's chosen waves are the desired estimand; see TE-06. Wild-bootstrap
inference was not rerun.

Reproduce the approved correction from dp-data, then the named downstream
repositories. The distortions
and learning modes of the existing review runner accept any paired input bundle:

```sh
Rscript scripts/review_tomorrows_europe_correction.R /tmp/te-review
Rscript ../dp-data/scripts/review_uk_crime_downstream.R distortions /tmp/te-review /tmp/te-distortions
Rscript ../dp-data/scripts/review_uk_crime_downstream.R learning /tmp/te-review /tmp/te-learning
```

### TE-06: Downstream attitude catalog selects baseline-to-arrival waves

The current `attitude-indices.tab` pairs Tomorrow's Europe military
`eu.mil_att_11_12_t1` with `_t2`, and contains no trade entry. The other selected
TE indices also use literal T1/T2 fields. The reconstruction preserves source
wave identities: T1 is baseline, T2 arrival and T3 departure. Before changing
these pairs, verify the intended time contrast in the analysis and original
merge/catalog definitions. Choosing departure would change the estimand and
requires its own numerical comparison and approval. TE-04's departure component
correction must not silently switch the downstream catalog or add an index.

### TE-05: Education, age and exceptional raw codes need instrument review

Q39 category 5 (postgraduate) is made missing before the historical recode
maps categories 4/5/6 to 1; category 6 (doctorate) remains 1. Q36 age category 2,
labeled 25–39, maps to 27; unknown category 6 remains 6. These reproduce the
script but need the original demographic instrument and analyst rationale.
Reviewed exceptional codes are field-specific: `t2q19=6` and `t3q19=0/6`
score incorrect; `t2q24=24/1004` and `t2q27=44/1004` become missing then incorrect;
`t2q11a=8`, `t3q16a=10` and `t3q18c=55` become missing in attitudes.
Do not generalize these allowances to other fields. Preserve raw values while
checking source labels, entry corrections and interview records.

## Vermont Energy 2007 — vermont-energy-2007

### VT-01: Key ambiguity must remain explicit

**Status:** existing upstream divergence; the accepted key remains provisional.

The [starred departure questionnaire](../data/vermont-energy-2007/questionnaire-post-key.doc)
was re-opened in this pass. Q31 marks a 50% reduction in annual electricity-use
growth (code 3), while the archived recode uses code 2. Q32, excluding Hydro
Quebec, marks **both** 15% (code 2) and 25% (code 3). The text extraction preserves
both literal stars. This supports an ambiguity in the supplied key, not a finding
that two factual answers must both be correct. The contemporary [Vermont briefing](../data/vermont-energy-2007/briefing-materials/vermont-energy-briefing.pdf)
("Electricity Savings To-Date," printed p. 54) says efficiency and economic
conditions cut electric-demand growth from 2% to 1%. That is a 50% reduction
in the observed growth rate and supports the magnitude of starred Q31 code 3,
which upstream already uses. Because the briefing attributes the change to both
efficiency and economic conditions, it does not isolate the program's effect.
It also does not resolve the two starred Q32 values or show which Q32 key was
fielded.

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
Q20's source label as 950,000. The
[briefing booklet](../data/san-mateo-2008/briefing-materials/san-mateo-briefing.pdf)
charts a 2007 single-family median of $918,000 without specifying September;
it cannot settle the fielded question's exact September figure. Both $940,000
and $950,000 occupy the same highest answer code 5, and Q26 code 5 is “more
than 75%” in both the questionnaire and stored labels. Thus the label-version
difference alone does not imply a different key. The published
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

### SM-02: IDs and summary batteries follow an earlier analysis stage

Of 1,806 source records, `participant == 1` selects 239. Synthetic historical
IDs `960001:960239` follow ascending `PARTICIPANTID`, not file order. All 16 raw
knowledge-answer columns and historical groups match the archived poll file
under that ordering. Seven-point attitudes round to seven decimals before
float32 storage; direct fractions are numerically different.

Final exports retain four attitudes, but extremity and group dispersion use
seven, including commuting, public consultation and county-versus-state scales
later dropped in `05_fix_data.R`. Do not rebuild summaries from the four final
columns. Check the index-selection rationale before changing the battery.

### SM-03: Baseline knowledge uses the eight questions in the instrument (corrected)

The pre questionnaire asks eight knowledge questions, Q19–Q26. The archived
`legacy/poll_scripts/san_mateo.R` enumerates those eight for both waves, and
respondent scores already divide their correct count by eight. The historical
poll-level baseline descriptor instead divided the eight correct-item indicators
by nine before the float32 person-score and rounded-seven-decimal poll mean.
The deposited `pkind` also increments by 1/9. There is no ninth scored question
or `length()` operation in the reviewed materials.

The [contemporaneous report](../data/san-mateo-2008/reports/san-mateo-results.pdf)
calls this an eight-question index but prints 12.92% before and 28.17% after
deliberation. Among the 239 participants, dividing correct counts by nine
reproduces 12.92422% and 28.17294%; dividing by eight yields 14.53975% and
31.69456%. The report's printed percentages therefore reflect the nine-item
arithmetic despite its eight-item description. This correction to the baseline
poll descriptor does not reproduce those published percentages.

Approved SM-03 retains all 1,806 baseline source records, the same eight answer
keys, missing-as-incorrect scoring and float32/rounding stages, but divides by
eight. `t1knowlevel` changes from 0.1248308 to 0.1404347 for each of the 239
exported participants; no respondent knowledge score or other aggregate field
changes. Case-level values are in
`audit/corrections/san-mateo-2008/approved_values.csv`. Post Q20/Q26 factual
key and instrument-version questions remain separate in SM-01. Five group
covariance exceptions, including two indefinite matrices, remain in X-09.

### SM-04: Anonymous item rows and reconstructed respondents had different order

**Resolved through upstream identity linkage, with no score correction.** During
the UKGE-03 comparison, dp-learning's positional `t1_items_for_poll()` assertion
failed for `sm` (dpnum17): 162 of239 paired T1 item means differed from rebuilt
`t1know`, with maximum difference .75. This occurred before UKGE-03.

The deposited battery follows historical caseid order, while reconstructed
polardata follows source order. Matching by established historical respondent ID
restores zero mismatches. No new identity was inferred from matching scores.
The upstream `respondent_knowledge` export now links canonical item responses
to `people` by poll/source row and includes the historical ID. dp-learning joins
by that ID and consumes explicit `correct_zero_filled`, preserving raw missingness
separately upstream.

All eight T1-linked polls' item cells match their previous batteries exactly.
All2,175 person-level peer-knowledge results match the previous correctly aligned
implementation within1e-12. Shuffling input rows does not alter the join; missing
or duplicate identities fail tests. The previously recorded mismatch remains
in `audit/corrections/uk-general-election-1997/downstream-item-alignment.csv` as
evidence of the old positional failure.

## Michigan 2009 — michigan-2009

**MI-01 — nonresponse versus invalid or ambiguous text.** The current build
selects 310 of 610 merged records using observed `postit`, rather than taking
the first 310 rows. It reports 294 item differences: 291 e/E responses, one F,
and two Senate responses, SC and “same”; zero-filled scores remain unchanged.
The [post questionnaire](../data/michigan-2009/questionnaire-post.doc), re-opened
here, presents free-text party-control questions and explicitly permits respondents
to say they do not know. The same [questionnaire](../data/michigan-2009/questionnaire-post.pdf)
explicitly prints option e as "couldn't say" for Q40, Q41 and Q42, so the 291
e/E tokens are nonresponses, not wrong substantive alternatives. The one F
lies outside the printed a–e choices. The archived `mi.R` later zero-fills
missing item scores, so this typed-missingness correction leaves the final
fixed-denominator knowledge score unchanged. The two Senate free-text tokens
SC and "same" still lack a verified response-sequence interpretation; no
substantive party answer is inferred from them.

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

These polls lie outside the older 23-battery knowledge pipeline. Five now have
independent respondent and aggregate reconstructions; the table distinguishes
that completed work from remaining instrument or coverage questions. Registry
presence is not a claim that every original field-file merge has been recovered.

| Poll | Current issue or boundary | Required evidence before extending the build |
|---|---|---|
| nic2-2003 | All 340 historical participants are now reconstructed from raw NIC2 answers; no matching anonymous deposited item matrix is required for that reconstruction. | Original NIC2 instruments, participant/arm definitions, source IDs and wave merge. |
| btp-national-2003 | All 245 historical participants and aggregate fields are now reconstructed; the 674-person descriptor calibration uses a separate raw source. | National-event instruments and field files; distinguish the national event from later primary/general-election polls. |
| btp-presidential-primaries-2004 | All 217 historical people are reconstructed. PR-02 fixes running peer sums; PR-03 removes duplicate aggregate rows and recomputes six group descriptors. Do not conflate with the online-primaries battery. | Event/mode-specific questionnaires, invitation and attendance records, and ID crosswalk. |
| new-haven-2004 | All 132 historical people are reconstructed from joined pre/mid/post workbook answers. Three birth-year-1890 values are made missing; event year and omitted attendee remain under review. | Original demographic question, raw value and alternate-wave age; respondent linkage and attitude definitions. |
| zeguo-2005 | All 233 historical participants are reconstructed from reviewed merged/pre/post components; three item-coding overrides and 15 numerical covariance exceptions remain explicit. | Original and translated instruments, event date, project-choice scales and respondent/group identifiers. |
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

## NIC2 2003 — nic2-2003

### NIC2-01: Historical identity is now a verified, ID-only bridge

The unchanged `data/nic2-2003/survey.dta` comes from
`data/BTP/2003/nic2.dta` (1,493 rows, 1,357 columns; SHA-256
`565faadfccd42a488891a5b59deb5b5caa390908d3ab8ead6271ffa953cc3b78`).
`casetype == 1` selects all 340 historical people. `nicid` is the immutable raw
ID; group is `9200 + group`. Synthetic aggregate IDs are joined through
`historical-ids.csv`, which contains IDs only, not scores.

The bridge was recovered against archived `nic_1/nic2_caseid.dta` using eight
features: group, age, `qnews1_a/b`, `qnews2_a/b`, and `eval7c/d`. Every selected
person has exactly one match, with no unmatched rows. Independent `t1envir`,
`t1usseca` and `kn2` checks had zero differences. The reproducible bridge helper
rejects ambiguous signatures; production joins use `nicid`. This is an inferred
crosswalk with independent validation, not an assertion that synthetic IDs were
present in the original field file. Retain the archive and inference evidence
before replacing it with any newly recovered roster.

### NIC2-02: Final nested indices differ from earlier draft syntax

Use `NICII_ONLINE_Index_Final_Aug01.doc`, `checking_July27*.do`, the source
variables labeled “UseThisOne”, and the final merge sequence together. The final
environment index equally weights four components: environmental priority,
collapsed mileage, collapsed electricity and warming priority. An earlier draft
instead nests two components into a block and then averages three blocks.
Security combines four priorities with a four-action block; that action block
requires complete answers. An available-item alternative changes 12 baseline
participant values. The reconstructed nine indices preserve the final version;
verify the index memo's missing-item and weighting instructions before revising.

### NIC2-03: Knowledge and group gain have specific storage stages

The 11-item battery includes two party placements (`wrm3_b > 5`, `wrm3_c < 5`)
and keys `aid3=1`, `wrm5=3`, `kno1_a=4`, `kno1_b=1`, `kno2_a=3`,
`kno2_b=4`, `kno3_a=5`, `kno3_b=1`, `wrm1_b=1`; post uses the corresponding
q-prefixed fields. Missing/noncorrect answers score zero. Check `know_final.do`,
`know_checking*.do`, `reagg.txt` and fielded instruments before changing keys.

Raw scales, nested means, each absolute deviation, final extremity, group SDs,
and gain additions preserve Stata float32 storage. Peer-gain contributions add
in the order `kn11`, `kn1a`, `kn1b`, then `kn2:kn9`, rounding after each addition.
Summing in double precision and rounding only at the end changes 112 gain values
by up to about 0.000000041. This is a reproducible arithmetic difference, not a
reason to alter substantive coding or loosen comparison tolerances.

### NIC2-04: Demographic categories and thresholds require separate review

One participant has unlabeled raw education grade 18. Historical `>= 13` treats
it as the highest category; a GED/high-school diploma overrides lower grades to
0.66. Consult the education instrument before treating 18 as missing or a valid
grade. Historical group high-income share uses collapsed income `> 7`; final
individual high income uses `> 6`, affecting 25 people. Preserve both stages
until the intended income definition is established. Briefing exposure uses
`EVAL5`, scaled `(x - 1) / 4`, not similarly named evaluation items.

## BTP National 2003 — btp-national-2003

### BTPN-01: Historical inclusion does not equal the attendance flag

All 245 rows of `2002onlinefp_hlmnew.dta` enter historical `polardata`, including
24 with `attend == 0` and 221 with `attend == 1`. Here `attend == 0` does **not**
mean no discussion: `countmtg` records zero meetings for one person, one meeting
for 15, and two meetings for eight. Every `attend == 1` record has three to eight
meetings. Thus `attend` separates fewer than three sessions from at least three;
all 245 selected records have a post Q20 answer and an assigned group. The
contemporary 2009 report distinguishes post-survey response from session
participation and describes eight available sessions. Dropping all 24 as
"nonattenders" would be factually wrong. Their partial attendance may still
matter when defining a group exposure measure, so preserve the historical
inclusion pending a stated estimand and a direct comparison of group summaries.
The archive's 2002 filename and current 2003 event label need reconciliation.
Unique raw `serial` identifies respondents; synthetic historical IDs
`930001:930245` follow preserved source order, and groups are `9300 + group`.
The independent source build now matches all 45 respondent targets and 39
additional group/poll fields within 1e-10, with exact missingness and no numerical
exceptions. It uses raw qb/qf answers, not stored indices.

### BTPN-02: Support components now use the instrument's full scale (corrected)

The deposited indices mapped support/opposition/equal answers on qb/qf20, 21
and 22 to 0.5/0/0.25 within global altruism (20/21) and democracy (22).
Approved BTPN-02 uses 1/0/0.5 for these three items in both waves. The
following counts identify nonzero components affected by the correction; they
are component counts, not distinct people across all items.

| Wave/item | Nonzero components | Usable answers | Missing answers |
|---|---:|---:|---:|
| Baseline Q20 | 101 | 243 | 2 |
| Baseline Q21 | 113 | 241 | 4 |
| Baseline Q22 | 154 | 232 | 13 |
| Post Q20 | 116 | 242 | 3 |
| Post Q21 | 134 | 240 | 5 |
| Post Q22 | 160 | 237 | 8 |

The fielded [questionnaire](../data/btp-national-2003/questionnaires/btp-national-questionnaire.pdf)
shows that Q20, Q21 and Q22 each offer two opposed statements, equal agreement,
and an unconsidered response. The archived `us_fp_online/scripts/v_online.do`
and `v_online2.do` recode those same three answers to 1, 2 and 3, then use
`(value - 1) / 2`, yielding the full 0, 0.5, 1 scale for both waves. The
[contemporary empirical manuscript](../data/shared/papers/foreign-policy.pdf)
(printed p. 11, PDF p. 12) states that response categories are scored
linearly on a 0–1 scale; its index descriptions (PDF pp. 13–15) include
Q20/Q21 in fighting poverty and suffering and Q22 in promoting democracy.
These are two independent pieces of evidence against half-scaling the items.
Component weighting is a separate issue: the earlier Stata `globalt` index
omits Q20/Q21, while the manuscript includes and pre-averages them. The
deposited index includes them but weights them separately. Neither earlier
formula can be substituted wholesale for the deposited later-stage index.

Holding the deposited index composition and missing-value rules fixed, the
approved removal of the extra `/ 2` changes baseline global altruism for 135 of 245
records and democracy for 154 of 245; post global altruism changes for 153 of
244 nonmissing records and post democracy for 160 of 244. Maximum changes to
each index are 1/6. Rebuilding the complete poll with this one corrected
rule changes only eight exported fields: those four attitude indices,
`attextreme` (196 rows, maximum 0.04761904), `meanxtreme` (245, 0.0179784),
`avgsd` (245, 0.01383719), and `genvar` (245, 0.02815631). It preserves all
245 records, case IDs and missing-value patterns; no other fields change.
Case-level values for all eight fields are in
`audit/corrections/btp-national-2003/approved_values.csv`. The related NIC II
index memo names Q20/Q21 as part
of global altruism and Q22 as part of democracy, but its component weighting
differs from the deposited BTP index. The NIC II memo and
`nic_2/scripts/checking_July27_online.do` are cross-checks, not direct
authority for BTP. Tracing the later BTP index-construction stage and
comparing published summaries remains necessary before any separate change to
component weighting.

### BTPN-03: Eleven-item respondent knowledge and baseline calibration differ

Final respondent knowledge uses climate-policy party placements qb/qf15b
(correct 6–10) and 15c (correct 0–4), plus Q26=1, Q18=2, Q40=4, Q41=1,
Q42=3, Q43=4, Q44=2, Q45=1 and Q12=1. Missing/refused answers score zero
under a fixed denominator of 11. Earlier nine-item scores and general-ideology
Q50/Q51 placements describe other versions and cannot replace these items.

The poll descriptor uses all 674 baseline records of `2002onlinefp.dta`, omitting
missing/negative climate-party answers from each person's denominator while
counting noncorrect factual answers as zero. Each party item has 28 missing/
refusal responses; 29 people have at least one. Float32 person means, their
full-sample average rounded seven decimals, then float32 storage reproduce
`t1knowlevel = 0.359222799539566`. A fixed denominator of 11 instead yields
about 0.357297. `calibration-responses.parquet` retains the 11 raw items and IDs.
Check `know_index_online.do`, `nuri/reagg.txt`, the fielded baseline instrument
and calibration-universe rationale before harmonizing these definitions.

### BTPN-04: Omitted interest and nested weighting need version-specific review

Raw `qb57` is populated for all 245 people, but final aggregate political
interest is missing for everyone. An earlier derived `t1polint` exists; its
presence does not authorize filling the historical omission. Inspect the
question wording, response orientation and merge history before adding it.

Executed environment uses Q2a, Q13, Q14 and Q15a as four components, while the
index memorandum includes a proposed three-component form. Security,
multilateralism, democracy and global altruism also weight component blocks,
not all raw questions equally. Preserve executed weighting pending memo/script
reconciliation. Raw recodes, nested means, extremity and knowledge retain
float32 stages. Peer-gain additions follow `kn11`, Republican, Democratic,
then `kn2:kn9`, rounding each addition. Group high-income share uses early
collapsed income `> 7`; final respondent high income uses `> 5`.
Review `merge02_nuri.R`, `03_data.R` and `06_add_more_vars.R` before combining
those stage-specific definitions in a revised schema.

## BTP Presidential Primaries 2004 — btp-presidential-primaries-2004

### PR-01: Draft counts and recodes are not the executed aggregate definition

The evaluated raw filter selects 217 people. Draft syntax says 223 and then
removes five to obtain 217, an arithmetic inconsistency. Preserve the evaluated
sample while checking session/attendance records. The final extremity measure
uses absolute deviations, not the draft's average of positions. Final income
retains 19 categories and defines high income as `> 11`; the draft's 19-to-11
collapse is not implemented. Later political-interest syntax reverses direction:
higher values mean less interest, unlike earlier `t1polint`. Consult the fielded
questionnaire and final analysis specification before changing any of these
versions; the separate online-primaries battery is not a substitute source.

### PR-02: Peer gain now uses the whole group (corrected)

The historical peer-knowledge numerator used a running sum rather than a
whole-group total. The archived `BTP/2004OnlinePrimaries/btp04primaries.txt`
uses `bysort pollgroup: gen ... = sum(...)`, which makes the result depend on
within-group row order. Other poll blocks in `nuri/reagg.txt` use
`egen ... = sum(...), by(pollgroup)` for group totals.
`data/btp-presidential-primaries-2004/historical-group-order.csv` preserves
case IDs and the recovered historical positions. The seven archived
`b1q43cor_grpsum` through `b1q49cor_grpsum` counters in
`nuri/bypoll/2004.online.primaries.dta` reproduce exactly from raw joint
answers and that order (217 people × seven items). This bridge is retained as
evidence of the deposited arithmetic; the corrected build does not read it.

The [baseline](../data/btp-presidential-primaries-2004/source-materials/baseline-questionnaire.pdf)
and [follow-up](../data/btp-presidential-primaries-2004/source-materials/followup-questionnaire.pdf)
instruments have the seven Q43–Q49 knowledge fields used here. Approved PR-02
holds those item keys, all 217 people in 16 groups, and the self-knowledge
exclusion fixed, but uses each whole group's joint-correct count. `grpgain`,
`grpgainr` and `loggain` each change for 188 unique people; the historical
434-row export contains two copies of each person. Mean `grpgain` increases
0.2023845 and its maximum increase is 0.9333334; historical values range 0–
0.6875 and corrected values 0.07692308–0.9333334. IDs and missingness remain
unchanged. PR-03 subsequently removes the duplicate export rows. Case-level
old/new values are in
`audit/corrections/btp-presidential-primaries-2004/approved_values.csv`.
Downstream model consequences can be assessed separately; they do not decide
which group-total arithmetic is correct. The follow-up questionnaire prints
Q46 twice for different candidate-knowledge questions. Verify the fielded
version and codebook before revising any answer keys.

### PR-03: Duplicate aggregate rows and doubled group counts (corrected)

The archived `BTP/2004OnlinePrimaries/btp04primaries.txt` records a final sample
of 217. The pre-aggregate `pkdat/nuri.Rdata` has 217 poll-ID-95 rows and 217
unique case IDs. `pkdat/agg_data.Rdata` has 434 rows: every person occurs twice
with identical scientific fields and a different export row number `X`.
The duplication appears between those archived stages, near the poll-name
merge in `merge_data_scripts/03_data.R`; the exact lookup contents were not
preserved, so the lookup-key cause remains an inference. The baseline and
follow-up instruments establish the measured items, while these archived
files establish sample cardinality. This is distinct from the 328-person BTP
online-primaries poll.

Approved PR-03 exports one row per primaries person, reducing full polardata
from 6,084 to 5,867 rows without losing a unique person. The canonical 217-person
respondent table and all source answers and group assignments stay fixed.
Group composition is recomputed from unique people. Six fields change for all
217 people: `groupsize` is halved (maximum old/new difference 21), and
`vareduc`, `sdeduc`, `pfemale_ind`, `meant1know_ind`, and
`meant1knowcor_ind` change through their denominators. The largest absolute
changes in those five fields are 0.009804412, 0.01218958, 0.04093567,
0.03781513, and 0.03361345, respectively. Recomputing the unchanged ratios
`meaned` and `phighinc` from undoubled rows also changes 34 and 21 stored
floating-point values by at most 1.11e-16 and 5.55e-17, respectively. No
other scientific field changes; row number `X` is regenerated. Case-level historical and
approved values are in
`audit/corrections/btp-presidential-primaries-2004/approved_values.csv`.
The numerical parity check still validates the historical duplicate pairs,
compares on unique case ID, and rejects unapproved value changes. Any
all-poll analysis that counted historical primaries rows gave this poll twice
the intended weight; analyses using `groupsize` or the five group descriptors
can also move. Re-estimate affected downstream analyses when they adopt this
export. See X-10 for the regenerated `X` field.

## New Haven 2004 — new-haven-2004

### NH-03: The three-wave workbook supplies raw answers and an explicit ID bridge

`source-materials/survey-waves.xlsx` preserves the answer/ID projection of
`NH_Data_pre-mid-post.xls`. Join Pre `ASSIGNED` to Mid/Post `SVY#`; each sheet
has 132 unique matching people and matching group assignments. Source-row order
follows Pre. `historical-ids.csv` links `ASSIGNED` to aggregate IDs using unique
nine-answer baseline Q35:43 signatures in `nh_hlm_smallnew.dta`: all 132 matched,
with independent gender agreement. No derived scores supply the bridge or build.
The remaining fieldwork-year/133-versus-132 discrepancy in NH-02 is not resolved
by this successful reconstruction.

### NH-04: Airport scaling and age remain historical

The airport expansion index maps 0.625 to float32(0.675), affecting 12 baseline
and five post values; the same discontinuity applies at arrival. Inspect the
Q12/Q13 index memo and executed recode before replacing it with an algebraic
scale. Age uses `2002 - birth_year`; three birth-year-1890 records are set missing
in the historical merge. Review the demographic instrument and alternate-wave
records before revising the age rule. The race-refusal correction is NH-06.

### NH-05: Arrival attitudes cannot reuse the baseline recode blindly

The arrival battery has the same three components but preserves raw zero as zero
rather than the algebraic value 1.25. Arrival Q12 don't-know code 6 or system
missingness sets the entire airport index to 0.5; Q13 don't-know contributes a
midpoint component. These rules explain all five arrival-extremity differences
under a naive repeated-wave implementation. Some post raw zeros are also
preserved. Verify literal pre/mid/post questionnaires, routing and split-half
timing before standardizing missingness or response origins across waves.

### NH-06: Race refusal is missing minority status (corrected)

The baseline CATI instrument's Q70 asks racial or ethnic background and labels
code 5 "Refused"; codes 1, 2 and 4 are substantive minority categories, and
code 3 is Caucasian. The historical `Q70 != 3` expression classified four
refusals as minority. The approved recode keeps substantive categories but
makes those four minority values missing. All 132 people remain in the sample.
Case-level old and new values are in
`audit/corrections/new-haven-2004/approved_values.csv`.

The four people are in groups 9103, 9107 and 9115. Group minority shares move
from 1/7 to 0/6, 2/10 to 1/9, and 6/13 to 4/11, respectively; the `pminority`
field changes for all 30 people in those groups. No other aggregate field
changes. In particular, the centralized historical entropy helper divides by
full group size and absorbs missing binary answers into the complementary
category, so its value stays the same. That missing-aware formula issue is
recorded in X-03 and has not been altered as part of this poll correction.

## Zeguo 2005 — zeguo-2005

### ZG-01: Component joins and three item-coding overrides are explicit

The public merged/pre/post projections in `source-materials/` reconstruct the
269-row source. Nonmissing `groupnum` and `preandpost` select 233 people;
aggregate person ID is `52000 + p`, and group is `5200 + groupnum`.
`source-materials/knowledge-reconciliation.csv` records three historical
`post_d3045` correctness overrides: `p=48` and `75` have missing raw answers,
and `p=105` has raw code 1, but all three historically score correct. The merged
version's `d3045p=1` is corroborating version evidence. The fielded
[source questionnaire](../data/zeguo-2005/source-materials/questionnaire.pdf)
Q45 lists answer 3 as plastic products, and the
[research paper](../data/zeguo-2005/papers/china-zeguo-bjps.pdf) explicitly
identifies plastic products as correct. Across all
269 joined source records, the merged file marks all 113 raw post answers of
3 correct; five of six raw answers of 1 incorrect; and these three exceptions
correct. Thus the ordinary key is supported, but the three merged flags could
reflect later manual corrections that did not update the raw POST file. The
ledger changes only historical scores, preserving all raw answers. Original
answer sheets or field-file version history are still needed to decide whether
the three exceptions were verified corrections or coding mistakes. No ZG-01
score has been changed.

### ZG-02: Scale the village-road rating and use post-wave main roads

The fielded translated questionnaire and its alternative both print a 0-10
importance scale for the project ratings. One respondent (`p=50`, source row
147, historical case 52050) answered 4.5 on baseline village-road item
`d2007`; their other two components are 5 and 5. The archived code divided
the ratings by 10 but then reset this one value to 4.5. This produced an
out-of-range index of 1.83333337, which the final individual export blanked
while extremity and group dispersion retained it. ZG-02 scales the recorded
4.5 to 0.45, giving case 52050 a village-road index of about 0.48333332.
The raw answer is unchanged. One formerly missing `chi.t1att2` is now observed;
the case's `attextreme` and `meanxtreme`, `avgsd`, and `genvar` for all 16
members of group 5207 change.

The archived `china_2005.r` also copied baseline `mroads1` into both T1 and
T2 main-roads indices, even though the post questionnaire asks the same
projects and the separate rescaled T2 main-roads index uses `d2015p`-`d2019p`
and `d2022p`. ZG-02 uses those six post ratings in `chi.t2att3`. Its value
changes for 206 of 233 participants, with no missingness change; group and
poll descriptors do not use post attitudes and are unaffected by this second
edit. The six-field person-level comparison is in
`audit/corrections/zeguo-2005/approved_values.csv`; all other fields retain
their historical scoring. The generalized-variance column has platform-dependent
numerical exceptions for the other 15 groups. Group 5207 remains an approved
correction: its rank-deficient covariance matrix also gives platform-dependent
values, so parity verifies the exact corrected input matrix, its rank and
bounded variance against the rebuilt source. The ledger records the macOS
value; the comparison file retains the historical benchmark as its old value.

### ZG-03: Two road indices make covariance numerically singular

The nine-column baseline matrix includes `float(mean(float(ratings / 10)))`
and `float(mean(ratings)) / 10` versions of main roads. They are algebraically
redundant apart from float-storage order. Before ZG-02, all nine reconstructed input columns matched the original
historical matrix bit-for-bit. The approved 4.5 rescaling changes one input
in group 5207. All 16 groups still have rank eight rather than nine; the other
15 retain reviewed platform-sensitive generalized variance; see X-09. Dropping a redundant column
would change the estimand and requires a separately reviewed correction.

## Cross-poll issues for the eventual schema

### X-01: Knowledge eligibility is not the respondent universe

The older `output/respondents.parquet` selects knowledge samples. The respondent
layer now covers all 21 polls in the historical aggregate scope, retains reviewed
source people, and marks each historical analysis sample explicitly. All target
respondent fields and aggregate profiles are reconstructed. This completion does
not mean all 34 registry polls or every earlier field-file merge are reconstructed.

File-scoped source-row IDs remain necessary where raw respondent IDs are missing:
Australia has 3,439 missing `caseid` values among 4,659 source rows; San Mateo has
1,096 missing `PARTICIPANTID` values among 1,806; NIC1 has one missing `CASEID`
among 911; the 857-row Monarchy source has no reviewed original person-ID column.
These records remain in the source universe. Their identity cannot be carried
across unrelated files without a verified crosswalk. Reordering an input cannot
silently assign new identities under its existing source version.

Named sample filters, immutable source IDs and explicit crosswalks now replace
the earlier unknown-membership flags for the historical scope. NIC2 and New Haven
identity bridges, Primaries order evidence and Zeguo component joins are detailed
below. Attendance, assignment, interview completion and analysis eligibility
remain separate concepts; score or weight missingness does not itself delete a
person from the source universe.

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
The centralized `pfemale_ind` helper uses full group size in its leave-one-out
denominator, while `pfemale` omits missing genders; the entropy helper also
divides observed categories by full group size. BTPHE-01 exposes this mismatch
in groups 9707 and 9727; NH-06 shows why the minority entropy can remain
unchanged when refusal is restored to missing. A change to these shared
formulas must be assessed across all polls and frozen separately from the
poll-level source corrections.

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

### X-06: Historical aggregates are comparison evidence, not scoring inputs

The 21-poll reconstruction now computes historical respondent, group and poll
fields from poll sources. The frozen aggregate remains a benchmark for keyed
comparison, not a lookup supplying missing scores. Existing downstream linkage
migration is a separate dependency decision: its old five-output parity does not
by itself validate replacing its aggregate input. Compare the reconstructed
export and numerical exception audit explicitly before changing downstream use.

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

### X-09: Generalized variance has 23 explicitly reviewed numerical exceptions

The current source formula differs from the frozen historical executable's
`genvar` in 23 groups, covering 272 export cells. These are not all negligible
absolute differences, and they are not replaced by benchmark values.

| Poll | Groups | Cells | Largest absolute difference |
|---|---|---:|---:|
| UK–EU 1995 | 2099 | 4 | 0.000063499 |
| BTP Health/Education 2005 | 9713, 9715 | 20 | 0.000209632 |
| San Mateo 2008 | 9601, 9604, 9616, 9617, 9621 | 31 | 0.003464282 |
| Zeguo 2005 | 5201–5206 and 5208–5216 | 217 | 0.001944706 |

Historical generalized variance takes the absolute determinant of a pairwise
covariance matrix and raises it to `1 / (2 * number_of_indices)`. Near-zero
determinants become much larger after this root, magnifying rounding differences.
The original nested calculation is retained in code to preserve its own rounding.
UK–EU group 2099 has N=4, P=4, rank=3; BTP groups 9713 and 9715 have
N/P/rank 11/11/10 and 9/11/8. San Mateo's five groups have N=5–7 and P=7;
Zeguo's 15 numerically excepted groups have N=10–17, P=9 and rank=8.
Group 5207 also has rank eight, but its changed source matrix and `genvar`
are an approved ZG-02 correction rather than a numerical exception.

Two San Mateo matrices also have materially negative eigenvalues. Group 9601
has N=6, five complete rows, pairwise N=5–6, and minimum eigenvalue -0.01431241.
Group 9621 has N=5, four complete rows, pairwise N=4–5, and minimum eigenvalue
-0.01560969. Pairwise deletion can produce indefinite covariance matrices;
these negative eigenvalues are not roundoff. Both matrices additionally have a
near-zero eigenvalue, which explains determinant sensitivity. Historical absolute
determinants hide the sign. Preserve that computation now, but review the
interpretation and missing-data covariance method separately from platform
reproducibility. Do not silently set these values to zero or make the matrices
positive definite.

`metadata/polardata_reviewed_covariances.csv` authorizes only the reviewed
poll/group, exact source attitude-matrix SHA-256 and N/P combination.
`audit/polardata_covariances.csv` reports complete/pairwise sample counts,
eigenvalues, spectral rank, determinant, original/current values and differences.
A reviewed exception also requires a near-zero eigenvalue and both values within
a matrix-specific perturbation envelope. That envelope is a numerical diagnostic,
not a generic tolerance or proof of substantive validity. Unknown groups, changed
source matrices, full-rank cases and out-of-envelope values fail the exception.
The review was measured with R 4.6.0 on macOS arm64, bundled BLAS and LAPACK
3.12.1; portable serialization is pinned, while CI must still check platform
arithmetic. Corrections require source/index and missingness review, not a wider
blanket comparison threshold.

### X-10: Export row numbers are regenerated; scientific comparisons use IDs

The historical `X` column is an export-row artifact with gaps from earlier
filtering/ordering. The reconstructed export numbers rows contiguously in its
current order. `X` is not a respondent identifier and its changes are not score
changes. Meaningful comparisons join on poll and historical `caseid`, with
explicit duplicate multiplicity checks. The 217 duplicated Primaries people
remain duplicated in the historical export, as documented in PR-03; contiguous
row numbering must not be mistaken for deduplication or new respondents.

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

### X-11: Data recoding belongs upstream, not in downstream readers

The user requires poll-specific recodes to live in dp-data, with downstream
repositories consuming defined variables. Moving a transformation must retain
its evidence and before/after checks; copying an unsupported downstream patch
upstream is not scientific validation. Initial migration inventory from
dp-learning's `R/knowledge.R`, `R/sources.R` and recode ledger:

| Current downstream transformation | Upstream disposition / required evidence |
| --- | --- |
| NIC `1996 - ppage` | Implemented upstream as `age@nic-03-v2`; downstream inversion removed (NIC-03). |
| NIC online mode forced to zero | Corrected upstream to face-to-face; downstream override removed (NIC-03). |
| Ages outside16–100 made missing | Preserve raw age and provide an explicit upstream analysis-eligibility/quality field; assess source anomalies separately from exclusion policy. |
| Greece post knowledge zero made missing when baseline is positive | Requires source/instrument evidence for nonresponse; a surprising zero score alone does not establish missingness. Do not promote this heuristic as a verified correction. |
| Greece education code7 made missing | Verify source category labels and export missing-value convention before centralizing. |
| Knowledge rounded to10decimals | Centralize documented numeric storage handling and test exact boundaries; preserve distinct knowledge definitions. |
| Primaries exact duplicate rows dropped | Use upstream canonical person identities and named samples instead of downstream whole-row deduplication (PR-03). |
| Item-battery missing responses counted incorrect | The eight linked T1 batteries now consume upstream `correct_zero_filled`; nullable `correct` and response status remain available. Anonymous latent-model batteries still need migration. |

Model fitting and explicitly chosen estimands remain analysis work. Reader-side
poll repairs, hidden rekeys and missing-value guesses do not. Existing downstream
source pins still select historical inputs; migrating them requires a coherent
upstream contract and exact impact checks, including the known SM-04 linkage
failure. NIC's proposal is the first coordinated reader-removal case, not a
claim that the full downstream migration is already complete. The remaining
scope also includes study-specific recodes in dp-distortions' out-of-sample
pipeline; its 24 frozen inputs are already centralized, but the transformations
must be inventoried and moved with study-level value checks.
