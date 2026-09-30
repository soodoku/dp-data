# Poll-level issue register

Initial review: 2026-09-25; latest evidence update: 2026-09-29. Scope: the
original 34 analytical polls, with detailed coverage of the 23 existing knowledge
builds and the respondent reconstructions.

## Decision for this pass

Preserve scoring, sample definitions, and downstream results until each proposed
correction has been supported by evidence and explicitly approved by the user.
Approved corrections and their evidence are recorded in the corresponding
poll entries below and in the recode ledger. Proposals remain unapproved until
a poll-specific decision is recorded.
This file records evidence and decisions; an unresolved issue does not authorize
a recode. UK Health's approved severity and input-order corrections are adopted;
its other authored index variants remain preserved.
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

## Current decisions and source limits

As of September 29, 2026, the UK–EU scales, Texas absent-form scores and
Australia item count are corrected. The user has also approved the ordered UK
Health input scales, Tanzania missing-component and paired-panel corrections,
and a shared zero-at-ceiling peer-opportunity convention. For education, the
user chose the approved within-poll median classification instead of imposing
a common degree interpretation on different source qualifications.

| Poll / issue | Current decision |
| --- | --- |
| UK–EU UKEU-02 | Approved and implemented: substantive five-point baseline scales, missing nonanswers and six rebuilt respondent/group fields. The retained review script and approved-value tables quantify the changes. |
| Australia AUS-02 | Approved and implemented: match the peer denominator and `numitems` to the twelve items actually scored: 346 peer measures and logs change; individual knowledge scores do not. The separate routing ambiguity remains unresolved. |
| NIC NIC-05 / shared peer opportunity | User clarified that the construct is opportunity to learn from peers: zero when the focal person knows all items or peers know none of the missed items. Implemented centrally across polls: 107 formerly missing ceiling measures become zero, NIC's existing zero remains zero, and absent interviews remain missing. |
| Tanzania TZ-03/04 | Approved and implemented: treat the −99 component as missing, rebuild the existing baseline-control standardization, and require both scores for the panel flag. All observed scores remain available; one panel flag changes. |
| SWEPCO SWE-05 / WTU WTU-06 | Approved and implemented upstream: 2,246 absent post scores and 11,230 post item-correctness cells per corresponding table become missing; six dependent respondent measures per person are missing. Baseline and attendee scores are unchanged. |
| UK Election / X-14 | Approved: use relative education based on the within-poll median. Preserve source qualifications; do not treat nonselection of a degree as proof of no degree. Typed participant tables expose the approved median flags. |
| Climate A1RC-05 | Approved and implemented: follow the original script’s room-plus-schedule group identity, restoring105 groups. Individual scores and samples are unchanged; group and peer measures change. |
| Shared invalid knowledge responses | Approved and implemented: invalid item correctness remains missing, with raw codes retained. This applies to documented multiple responses and questionnaire-backed out-of-range codes; DK remains zero. Fixed-denominator battery scores are unchanged. |

UK Health's government/public-input and doctor-discretion indices (UKH-03/07)
now follow the approved order: none = 0, some = 0.5, all/most = 1, at both waves.
This changes 126/93 and 5/8 indices, respectively, plus dependent attitude
summaries. The questionnaire and index memo define higher values as more say;
all 230 respondents and existing missingness are preserved.

Missing evidence is a different completion state from an unapplied correction.
Bulgaria 2007 still has no identified respondent dataset, so it cannot be
called respondent-level audited. Other documented gaps include anonymous
battery identity bridges (Europolis and Tomorrow's Europe), group rosters
(Denmark and Vermont), original wave returns and keys (Marousi), and withheld
raw-to-derived cleaning syntax (Tanzania). Poll entries specify what evidence
would resolve each gap; numerical agreement does not remove these limitations.

Accepted preservation decisions remain in force, including NIC's Bosnia item
and Vermont's report-based key. Source-dependent interpretations such as
UK–EU ethnicity “Other,” Zeguo's publication-consistent correction flags and
UK Health's breast-screening wording remain documented without speculative
recodes. This is an inventory of decisions and limits, not a declaration that
all 34 polls or every field have been fully audited.

## Attitude audit boundary and downstream consumers

The completed source-to-score pass covers all 129 main index pairs across the
21 historical polardata polls, plus the broader summary batteries described
below. It checks item identity, source direction, scale, nonanswers, component
rules and selected waves against the available instruments, codebooks, original
syntax and published benchmarks. Approved corrections are applied; unresolved
choices and source gaps remain explicit. This is not a claim that every fielded
questionnaire, raw-file merge, or variable in all 34 analytical polls has been
verified. In particular, Zeguo's absence and definition findings and the utility
attitude policies below remain open despite completed reconstruction.
Substantive attitude corrections include UK Crime's post root-causes input,
UK Election's tax question, UK–EU scale/nonanswer handling, UK Health's severity
and input-order indices, Texas conservation/research inputs, Australia's
extremity/ranking inputs, NIC event-exit inputs, New Haven nonanswers and value
substitution, Bulgaria's death-penalty scale, Tomorrow's Europe departure inputs,
and BTP National/Zeguo scaling or source-selection corrections. The poll entries
below retain the instrument evidence and numerical consequences.

| Polls reviewed | Main pairs | Coverage and evidence boundary |
| --- | ---: | --- |
| UK Health | 9 | All 11 summary indices at both waves checked; preserve documented payer orientation and authored weighting/battery variants (UKH-04/14). |
| UK Crime | 5 | Both waves and baseline extremity checked; all ten published means reproduced. The questionnaire scan is partial; the codebook supplies remaining wording (UKC-04). |
| UK–EU | 4 | Both waves and baseline extremity checked after approved scale fixes. No standalone SAQ recovered; FAVREF's merged neutral/nonanswer category cannot be separated (UKEU-06). |
| UK Monarchy | 4 | Both waves checked against codebook/memo; paired benchmarks reproduced and catalog titles corrected (UKM-07). |
| UK Election | 4 | Both waves checked; all eight published item means reproduced. The appendix's conflicting question names do not override the instrument and actual paired fields (UKGE-06). |
| CPL, WTU, SWEPCO | 18 | Six pairs and seven-index baseline summaries per poll checked against original frequencies and codebooks. Exact fielded forms are not identified; missing-item fills and empirical calibration remain separate decisions (CPL-06). |
| Australia | 2 | Main pairs and five original summary batteries checked; 33 of 34 printed item means reproduced. Queen-first correction adopted; exit form and knowledge-routing evidence remain incomplete (AUS-06). |
| BTP General Election | 6 | All placements and source labels checked at both waves; absent forms and label/code distinctions preserved (BTPGE-08). |
| BTP Health/Education | 11 | All 22 series checked and four titles corrected; the wider 360-attendee source still does not reproduce the report percentages (BTPHE-05/06). |
| Bulgaria Crime | 12 | Both waves and the additional drug-legalization summary index checked. Version E civil-liberties syntax remains missing; preserve the executed definition (BGC-08). |
| Europolis | 2 | Both waves and baseline extremity checked; titles corrected to match direction, paired climate means reproduced. The fielded-form/version gap remains (EURO-07). |
| NIC | 9 | All three source waves checked; approved nonanswer correction adopted. Main attitude comparison remains initial to later follow-up, not immediate exit (NIC-12). |
| Tomorrow's Europe | 7 | All 31 retained series and baseline/arrival extremity checked. Main initial-to-exit and supplemental arrival-to-exit contrasts explicit; earliest migration recode remains unavailable (TE-06/07). |
| San Mateo | 4 | Main pairs and seven-index summaries checked. Preserve the larger summary battery and documented source/report differences (SM-02). |
| NIC2 and BTP National | 18 | Nine pairs per poll checked against original versions and component rules. NIC2 security's authored missing-item choice remains open; the older trade publication definition now reproduces (NIC2-02). |
| BTP Presidential Primaries | 3 | All main pairs checked; unconsidered responses excluded from substantive input counts without changing scores (PR-04). |
| New Haven | 2 | Both main indices and the third summary index checked at Pre/Mid/Post; Mid follows the first discussion session, not arrival (NH-08). |
| Zeguo | 9 | All indices checked against merged and raw source versions; original correction flags preserved. Unmatched departures and the Township Image alternative remain decisions (ZG-06–08). |

The table counts the main catalog once: the two Primaries catalog IDs share a
source and are not two independent attitude studies. Evidence from a codebook
or authored recode is identified as such; it is not described as a recovered
fielded form. Published mean agreement supports a source/version bridge but
does not independently validate every original coding decision.

### Remaining attitude decisions and evidence gaps

These are bounded next actions, not permission to recode:

| Issue | Remaining decision or evidence |
| --- | --- |
| WTU/SWEPCO absent departure attitudes | Approved September 29 and implemented: both plain and explicitly midpoint-imputed departure indices remain missing for 1,000 WTU and 1,246 SWEPCO absent forms. See WTU-07/SWE-06 and X-03. |
| Utility observed-form scoring | Plain indices now preserve all-component nonresponse; explicitly named `_midpoint_imputed` variants retain authored fills. Historical aggregates explicitly select those variants. Empirical wave calibrations remain a separate unresolved choice. |
| NIC2 security | Current source marks the complete four-action block “Use This One”; an available-action version is also authored. Switching changes 12 baseline and three exit scores, with no final missingness change. Choose the intended missing-item policy explicitly (NIC2-02). |
| Climate discussion groups | ROOM alone yields 58 labels; ROOM × T2P_OPTION yields the original script's 105 groups. Forty-seven reused labels combine different schedules for 862 of 962 completers. Approved September 29: upstream now uses the original script’s room-plus-schedule identity (A1RC-05). |
| Zeguo unmatched departures | Approved September 29 and implemented: 34 unmatched departures are missing in both attitude variants and post-dependent knowledge. All 233 historical people remain; observed blank quiz items still score zero. Do not borrow the unlinked NP32 block (ZG-07). |
| Zeguo Township Image | Current Q25/Q31 and the paper's Q8/Q9/Q25/Q27 battery are different authored definitions. The alternative changes 161 baseline and 169 post scores, 160 extremities and all 233 repeated group summaries. Its 176-person means still do not exactly match the paper; preserve current values pending the definition decision (ZG-08). |
| Published-result bridges | NIC2/BTP trade means and standard errors now reproduce under the older publication composite and cohort; current NAFTA-only scoring is preserved. BTPHE report percentages still need report-era sample/index/weight syntax (NIC2-02, BTPHE-06). |
| Original source records | Bulgaria 2007 has no recovered respondent data. Other limits include Bulgaria Crime Version E syntax, earliest TE migration recoding, fielded-form versions, anonymous phase links, group rosters and Marousi's conflicting departure IDs. These require source evidence, not an arbitrary numerical choice. |
| Analytical weights and downstream adoption | Supplied weights are retained but no universal weight is selected. Frozen downstream benchmarks still require explicit adoption and estimate comparisons; canonical baseline predictors do not define the full attitude inventory. |

Preserved authored choices—UK Health's alternatives, BTPHE's inclusion of school
funding importance, wider summary batteries and nested weighting—are not
outstanding demonstrated errors. Their evidence remains available for a later
substantive redefinition. Accepted NIC Bosnia, Vermont key and UK–EU Other
classification decisions are not reopened by this attitude pass.

The actual downstream readers determine the remaining audit inventory:

| Consumer | Actual attitude inputs | Current boundary |
| --- | --- | --- |
| dp-distortions main | 129 paired indices across 21 polls; 5,867 deduplicated people and 397 groups. `data/sources.csv` pins dp-data revision `bce1e0e3aea578b71090dde5348ca66ccb778048`, `evidence/benchmarks/polardata.tab` and `attitude-indices.tab`. | These are frozen historical benchmarks, so corrected upstream outputs and median flags do not automatically enter the results. Audit the 129 definitions and selected wave pairs before replacing pins; compare every affected downstream estimate. |
| dp-distortions OOS | Tanzania now reads dp-data's typed 22-item attitude outputs (371 grouped people; 360 borrowing pairs), pinned at `3e7673bfbde9ba1bda03681dff5ad981be8edfba` in merged dp-distortions PR #4. A1R 2019 (47 paired items; 523 completed delegates) and Climate 2021 (72 paired items; 962 completed delegates) still read upstream raw files. | Tanzania source-item selection, missing codes, scales and wave provenance are upstream; its prior 21-item respondent values and group metrics reproduce exactly. Estimation remains downstream. A1R and Climate recodes still need typed upstream adoption. A1R's local education reference uses 523 completers, whereas the approved upstream reference uses 526 attendees. |
| dp-deliberately | Hash-pinned historical benchmark polardata and index dictionary from dp-data v0.2.2. | Corrected respondent outputs do not automatically enter this adapter either. Preserve its explicit membership/estimand choices while comparing the upstream data replacement. |
| dp-learning analysis tables | 303 selected baseline indices/responses across 28 polls. | This predictor table is not the inventory of attitudes available in the source files or other downstream repositories. Its absence of post-wave rows is not evidence that those responses are unavailable. |

An earlier comparison, before TE-06 and NIC-12, on the same 5,867 unique
historical respondents found 3,572 changed attitude values in 26 selected wave columns, covering 19 of the
129 index pairs and 11 polls. This uses absolute tolerance 1e-10, treats changes
in missingness as differences, and holds the frozen catalog's wave selections
fixed. It excludes the two additional BTP General Election respondents restored
upstream. The affected polls are Australia, Bulgaria Crime, BTP National, New
Haven, SWEPCO, UK Crime, UK–EU, UK Election, UK Health, WTU and Zeguo. These are
input differences, not a claimed rerun of downstream model estimates.

Tomorrow's Europe now uses the approved pre-arrival-to-exit comparison for all
seven main attitude indices (TE-06). The typed contrast catalog also preserves
arrival-to-exit comparisons. Source T1/T2/T3 correspond to canonical t0/t1/t2;
the change affects seven catalog endpoints and no respondent values. Downstream
readers pinned to the historical catalog still require explicit adoption.

Accepted preservation choices are not unresolved coding errors. Examples are
the historical descriptor batteries that contain more indices than the final
attitude catalog and the reviewed nested weights/missing-component rules.
Remaining evidence gaps include Bulgaria 2002's final civil-liberties Version E
specification and Bulgaria 2007's missing respondent data. Any additional source
or proposed correction must trace the consumer's item/phase to the fielded question, substantive and
nonanswer codes, direction, bounds, component weights and questionnaire presence;
then compare individual scores and dependent group/poll summaries. Passing
historical parity alone is insufficient.

## Source-material review after v0.3.0

The [sourced facts](../metadata/poll_facts.csv),
[references](../metadata/poll_references.csv), and
[material coverage](../metadata/poll_material_coverage.csv) cover the original 34 analytical polls. Additional `materials-only` entries
identify event documents without implying respondent-data coverage.
Each fact names its source and locator; each poll folder has a generated
`metadata.json` view. Reported numbers retain their stated populations. This
review changes documentation, not catalog identifiers, scoring, or samples.
Priority questions for the corrections pass include:

- **New Haven:** Farrar and colleagues' published study and the baseline CATI
  questionnaire date the airport and revenue-sharing event to March 1–3, 2002;
  the archived poll appendix labels it 2004. The catalog year is corrected to
  2002 while its historical `new-haven-2004` ID is retained. The paper
  distinguishes 1,032 initial interviews, 133 attendees and 132 analysis
  cases; the omitted attendee remains unresolved.
- **Bulgaria 2007:** the organizer description and executive summary identify
  the National Palace of Culture; the Roma working paper names Park Hotel
  Moskva (PDF p. 4) and calls this the first Bulgarian poll despite the 2002
  event. Both report 255 participants. Check original event records before
  selecting a venue. The two versions of the results announcement are press
  releases, not papers; their distinct original bytes remain available.
  The retained [Kim, Fishkin and Luskin (2018) article](../data/bulgaria-2007/papers/intergroup-contact-deliberative-contexts-2018.pdf)
  identifies 230 non-Roma participants (printed p. 1036) and explains that 25
  Roma participants were excluded from that article's analysis (note 2,
  p. 1046). Together they account for the 255 attendees; the 230 is not an
  alternative attendance total. It reports national face-to-face baseline
  interviews and interviews immediately after the April 2007 event. The paper
  supplies no respondent dataset. The retained archive inventory and current
  source catalog have not yielded this poll's data; the Bulgarian crime files
  concern the separate 2002 event. Stanford's [official data-request page](https://deliberation.stanford.edu/tools-resources/data)
  provides a [request form](https://forms.gle/1qiDNqwWMNECz3RWA). Recovery should
  seek all 1,344 baseline respondents, linked post-event records for all 255
  attendees, group assignments and coding documentation. No request has been
  submitted and respondent-level auditing remains blocked by the missing data.
  A renewed September29 search checked six Dataverse queries, OSF/Zenodo,
  current Stanford/organizer pages and recovered archived2007/2019/2020
  Stanford pages. No respondent package was found in those inspected sources;
  archived links led to reports, press material or the general data-request page.
  This is a bounded search result, not proof that no package exists. ICPSR and
  the full publisher page returned403; some broader archive queries failed.
  The needed files remain the linked1344-person baseline and255-person event
  cohort, original variable dictionary and attendance/group IDs.
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
- **AMR 2024:** the recovered version 2 paper establishes pre-invitation baseline
  and event-end measurements, now preserved as t0 and t2. AMR-04 documents the
  phase mapping, recovered questionnaire and codebooks, and conflicting Q21
  options. The retained 1,280 attendees and 1,139 controls omit 1,847 invited
  nonattenders; they do not constitute the complete randomized invitation cohort.

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
version was administered. The 21-poll attitude coverage table above records the
completed source-to-score pass and its remaining instrument limits; poll entries identify which checks
use full forms, codebooks, authored syntax or published benchmarks.

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
| california-whats-next-2011 | 396 | 401 | 10 | 2 | 0 | row-aligned-after-blank-tail |
| europolis-2009 | 348 | 348 | 12 | NA | NA | unordered-exact-match |
| nic-1996 | 466 | 466 | 16 | 0 | 0 | row-aligned |
| tomorrows-europe-2007 | 359 | 335 | 22 | NA | NA | unlinked-sample-difference |
| vermont-energy-2007 | 146 | 146 | 18 | 250 | 0 | row-aligned |
| san-mateo-2008 | 239 | 239 | 16 | 113 | 0 | row-aligned |
| michigan-2009 | 310 | 310 | 18 | 294 | 0 | row-aligned |
| denmark-euro-2000 | 359 | 363 | 18 | NA | NA | unlinked-sample-difference |

The 23 builds contain 6,669 participants and 103,116 item-wave responses.
There are 1,212 reported cell differences among the row-aligned comparisons and
two gender differences. These totals include California after its five blank
deposit rows are excluded from comparison; they exclude the two remaining
unequal-size comparisons and the unordered Europolis comparison. There are 522 people without known
memberships: UK–EU 4, online primaries 13, Vermont 146, and Denmark 359.

## UK Health 1998 — uk-health-1998

### UKH-01: Severity direction is documented; do not label it a coding error

**Status:** preserve; rejected diagnosis of an accidental subtraction reversal.

**Evidence rechecked:** the original
[British Health Indices V6 FINAL, section 8](../data/uk-health-1998/codebooks/british-health-indices-v6.pdf)
explicitly specifies `LISTA - SEVERA`. The
[British Health Codebook](../data/uk-health-1998/codebooks/uk-health-codebook.txt)
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

**Status: fixed-scale correction approved on 2026-09-28.** Both waves now use
the same possible difference range, [-1, 1], mapped to [0, 1]. The documented
`lista - severa` direction is retained. The observations below describe the
historical behavior and the approved alternative.

**Evidence:** [historical merge script 05_fix_data.R](https://github.com/soodoku/dp-data/blob/historical-cdd-scripts/legacy/merge_data_scripts/05_fix_data.R)
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

**Approved resolution:** use `(d + 1) / 2` in both waves. A difference of zero
therefore scores 0.5 at both interviews instead of 0.5 initially and 2/3 at
departure. Baseline severity scores do not change; 196 departure scores change
with identical missingness and sample membership. Independent calculations from
the raw item answers are retained in
`audit/corrections/uk-health-1998/approved_values.csv`. The dependent summary
correction is recorded in UKH-09. No sign reversal or change to the other
attitude items is included. Downstream estimates require regeneration before
claiming that their results are unchanged.

### UKH-03: Government/public input has a non-monotonic stored recode

**Status: ordered response correction approved on 2026-09-28 and implemented.**
Both waves now map none/some/all-or-most say to 0/0.5/1. The historical
folded construction below remains documented as the behavior being replaced.

**Primary evidence:** codebook Q18A_A (`INGOVA`) and Q18A_E (`INPUBA`) distinguish
none, some, and all/most input. The V6 index memo, section 11, describes an average
of the two items and says the high end denotes the most say. The
[final project report](../data/uk-health-1998/reports/uk-health-final-report.pdf), section on
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
| Historical folded mean | 0.7709302326 | 0.7050000000 |
| Approved ordered mean, codes 1/2/3 → 0/0.5/1 | 0.3383720930 | 0.3775000000 |
| Index observations changed | 126 | 93 |

The response counts count **item answers**, not distinct people. The approved
scores use the same available-item denominator: 215 baseline and 200 departure
indices remain observed. The memo's high historical means are consistent with
long-standing folding; this is an approved correction to the ordering of the
construct, not a new import error. Raw responses and stored source indices
remain unchanged.

Together with the doctor-input correction in UKH-07, this changes four index
columns and the dependent shared summaries. Individual baseline extremity
changes for 13 people; group mean extremity changes for 170 people in 11 groups;
average within-group standard deviation and generalized variance change for all
230 people in 15 groups. The sample, missingness and prior UKH-02 severity
correction remain unchanged. The review script
[`scripts/review_uk_health_input_order.R`](../scripts/review_uk_health_input_order.R)
reconstructs all 11 baseline indices directly from raw answers for the previous
and approved definitions. Its independent values are in
[`folded_input_approved_values.csv`](../audit/corrections/uk-health-1998/folded_input_approved_values.csv),
with means and change counts in
[`folded_input_summary.csv`](../audit/corrections/uk-health-1998/folded_input_summary.csv).
The earlier severity audit remains separately preserved.

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
then-historical behavior in UKH-01–03. The following table is the original
pre-correction comparison, not the current severity or government-input scores;
UKH-14 records the current full-battery review. All respondent IDs match `serial_m` and
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

**Status: all 11 aggregate indices retained; doctor-input ordering corrected
with approval on 2026-09-28.** The nine selected attitude indices remain a
separate analysis selection.

`attitude-indices.tab` selects nine indices for UK Health. The actual historical
`polardata.tab` retains 11 in both waves, including `ukhealth.t{1,2}avgdis`
(doctor discretion) and `ukhealth.t{1,2}moresa` (patients' say), and `numindices`
remains 11. The UK Health section of
[05_fix_data.R](https://github.com/soodoku/dp-data/blob/historical-cdd-scripts/legacy/merge_data_scripts/05_fix_data.R) lists those two
indices in comments and says the number should fall to nine, but contains no
executed deletion or count update for them. A selected analysis battery and
an aggregate's complete inventory can legitimately differ; the comments alone
do not settle whether the retained fields or count were unintended.

The V6 memo sections 12–13 and codebook Q18A_B/Q18A_D and Q23_B define the added
constructs. Raw `say` uses 1 strongly disagree through 5 strongly agree;
`(say - 1) / 4` exactly reconstructs `moresa`. Doctor discretion averages available
`ingpa` and `indoca` components. Like UKH-03, both components reproduce the stored
historical index only with codes 1 and 3 mapped to 1 and code 2 mapped to 0.5.
The approved correction follows the codebook and memo: none = 0, some = 0.5,
and all or most = 1 in both waves. The other indices and their membership are
unchanged.

| Doctor discretion | T1 | T2 |
|---|---:|---:|
| Nonmissing respondents | 216 | 218 |
| Historical mean | 0.7731481481 | 0.7786697248 |
| Approved ordered mean | 0.7592592593 | 0.7511467890 |
| Respondents changed | 5 | 8 |

The correction retains 216 baseline and 218 departure observations, averaging
available GP and hospital-doctor answers. It does not delete doctor discretion
or patients' say, change `numindices`, or reinterpret which battery a published
analysis used. The historical reason for folding is not recovered; the user
approved the ordered definition supported by Q18A_B/Q18A_D and V6 section 12.
The resulting shared-summary changes and reproducible evidence are in UKH-03.

### UKH-08: Individual and group high-income fields use different thresholds

**Status: corrected under the approved shared median rule (X-13).** The
historical discrepancy below explains the change; it is no longer pending.

Codebook B18 defines 16 household-income bands before tax. In this participant
file, `(income - 1) / 15`, with raw -9/-8/-7 missing, reconstructs `hhincome`
for 206 respondents. The [poll script](https://github.com/soodoku/dp-data/blob/historical-cdd-scripts/legacy/poll_scripts/uk_health.R) uses
`hhincome > .8`; [03_data.R](https://github.com/soodoku/dp-data/blob/historical-cdd-scripts/legacy/merge_data_scripts/03_data.R) computes
`phighinc` from that flag. Then
[06_add_more_vars.R](https://github.com/soodoku/dp-data/blob/historical-cdd-scripts/legacy/merge_data_scripts/06_add_more_vars.R) changes
individual `highinc` to `hhincome > .34` without recomputing `phighinc`.

The early threshold selects raw bands 14–16 (35,000 and above), while the final
threshold selects bands 7–16 (15,000 and above). The high-income count rises from
22 to 97 among 206 observed people: 75 individual flags differ. All 230 stored
group shares match the early threshold. Recomputing them from final `highinc`
would change all 15 discussion groups, hence all 230 group-share entries.
These are income bands, not cardinal income or necessarily a percentile cut.

**Approved resolution (2026-09-28):** compute the empirical income median among
the 230 unique historical participants, excluding the 24 missing incomes.
The observed median is income band 6, or 1/3 on the retained scaled variable.
Strictly above that cutoff selects 97 people, the same people as the later
individual flag. Group shares now use that individual flag: all 15 groups
change from their earlier high-income definition. Missing income remains
missing and group means omit it. The raw income bands and historical benchmark
remain unchanged; the build no longer carries a second group-only cutoff.

### UKH-09: Attitude summaries precede the final severity rescaling

**Status: correction approved with UKH-02 on 2026-09-28.** Summaries now use
the corrected respondent indices, including severity on its fixed [0, 1] scale.

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

**Approved resolution:** retain all 11 baseline indices and their available-item
rules, with the neutral zero difference mapped to 0.5 by the corrected severity
scale. Compute individual extremity from those respondent values, then calculate
group extremity and dispersion in the existing shared aggregation step. This
changes individual extremity for 203 people, and group mean extremity, average
standard deviation and generalized variance for all 230 people in 15 groups.
Missingness and sample membership are unchanged. The independent expected
values and summary are in `audit/corrections/uk-health-1998/`. These severity-only historical comparisons exclude the later approved
government/public and doctor-input correction; its additional effects are
recorded separately in UKH-03/07.

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

The [poll script](https://github.com/soodoku/dp-data/blob/historical-cdd-scripts/legacy/poll_scripts/uk_health.R) labels a guessing adjustment:
a T1-correct/T2-incorrect answer becomes incorrect at T1. It computes itemwise
`T1 correct * T2 correct`, then averages all six items as `t1knowcor`.
The [helper](https://github.com/soodoku/dp-data/blob/historical-cdd-scripts/legacy/poll_scripts/hlmFunc.R) and
[merge](https://github.com/soodoku/dp-data/blob/historical-cdd-scripts/legacy/merge_data_scripts/03_data.R) use the same jointly correct
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

**Recovered primary materials (2026-09-27).** The original
[authored codebook](../data/uk-health-1998/codebooks/uk-health-codebook.txt)
is now retained in the poll folder. Its opening caveat, credited to Dennis L.
Plane, explicitly discusses this ambiguity: age-limited eligibility makes the
universal wording technically false, while true may have been anticipated by
the question writers. This is contemporaneous evidence that the discrepancy
was recognized, not grounds to characterize it as a newly discovered typo.
The modification date printed in the header is incomplete and is not repaired
by guessing. The catalog now uses the exact Q9E wording, “can get,” rather than
its earlier “receive” paraphrase; the maintained numeric false key is unchanged.

A [28 July 1997 parliamentary answer](https://hansard.parliament.uk/commons/1997-07-28/debates/a6279af3-c4f9-4f6a-88c7-99d8153691da/BreastCancer%28Screening%29)
identifies routine NHS breast screening's target group as women aged 50–64.
This supports reading the universal statement literally as false. It does not
establish the poll's administered instructions or intended distinction between
screening and diagnostic care. The author’s caveat and the printed versus SAV
key conflict remain explicit; no raw answers, scores or aggregate values change.

The [final project report](../data/uk-health-1998/reports/uk-health-final-report.pdf)
by Alison Park, Roger Jowell and Suzi McPherson has also been recovered locally,
replacing external-only report availability. The archive file had a 128-byte
MacBinary header and five padding bytes; the readable PDF preserves its
52,603-byte data fork exactly, and extracted text matches the wrapped source.
Both hashes and the extraction details are registered in the material catalog.
The 17-page retained PDF ends at the bibliography even though its contents list
an appendix; do not claim that the missing questionnaire appendix is recovered.
The original archive bytes remain untouched.

### UKH-13: School qualifications were mislabeled as a bachelor's degree

**Status: approved and implemented 2026-09-28.**
The canonical analysis participant builder previously derived `ba` from
`educ3 == 1`.
For UK Health this is `educa == 3`: A/S/AS-level school qualifications in
codebook B11, not a degree. The separate B12 `educb` question explicitly
identifies degree/higher degree as code 9. Its nonanswer is -9. Reconstructing
degree status from this answer exactly reproduces the source's authored
`degree` variable, including its one missing value, for all 230 participants.

The previous flag identified 49 degree holders; the explicit source question
identifies 32. Twenty-three previous positives report no degree; six previous
negatives report a degree. Two previously missing school-based flags have an
observed no-degree answer, and one previous negative has a missing degree answer.
The approved correction changes 29 observed binary values and three missingness
statuses. It preserves all person identities, school-qualification answers and
the separately approved empirical-median education flag. A-level qualifications,
degree attainment and relative education are distinct measures and must not
share an unsupported degree label. The three-category education proxy and any
downstream description of it need their own source-based harmonization review.
This degree-flag correction leaves those categories unchanged.

Evidence: `data/uk-health-1998/codebooks/uk-health-codebook.txt` B11/B12 and
DEGREE sections (lines 1424–1526), `survey.sav` fields `educa`, `educb`, `degree`,
and the historical participant transformation. `R/analysis_covariates.R` now
uses the raw B12 answer for this degree flag, including its missing value,
after the generic historical proxy assignment. The 230 keyed before/after
values are in `audit/corrections/uk-health-1998/degree_values.csv`.

### UKH-14: Full attitude battery checked against the source definitions

**Status: reviewed; no additional numerical correction.** The review covers all
11 indices at both waves, including `avgdis` and `moresa`, which are not among
the nine main catalog indices. Direct reconstruction from all 230 source records
matches every current value and missing-value pattern within `1e-12`, and the
11-index baseline extremity calculation also matches. This includes the approved
fixed severity scale and ordered government/public and doctor-input recodes;
it does not reinstate their historical versions.

The [V6 index memorandum](../data/uk-health-1998/codebooks/british-health-indices-v6.pdf),
[source codebook](../data/uk-health-1998/codebooks/uk-health-codebook.txt), raw
variable labels and archived `uk_health.R` supply the item definitions:

| Index | Components at each wave | High end / rule |
| --- | --- | --- |
| `payhlt` | PAYHLTH | Individual payment; 1/2/3 → 0/.5/1 |
| `poora` | POORA | Priority for poorer people's health |
| `option` | OPTIONS | More patient choice; 1/2/3 → 0/.5/1 |
| `hlthfu` | CHGP, CHVIS, CHMEAL, CHSTAY, CHAMB | Support for patient charges |
| `ctexpt` | TREATA, CTHART, CTNURS, CTBABY | Opposition to cuts; reverse each item, equal available-item weights |
| `pritre` | CTFERT, CTHOSP, CTCOSM | Opposition to privatization; reverse each item |
| `severi` | LISTA, SEVERA | Relative waiting-list priority; `(LISTA_scaled - SEVERA_scaled + 1) / 2`, both required |
| `preven` | PREVA | Priority for prevention |
| `dispub` | INGOVA, INPUBA | Government/public input: none 0, some .5, all/most 1 |
| `avgdis` | INGPA, INDOCA | Doctor input: none 0, some .5, all/most 1 |
| `moresa` | SAY | More say for patients |

Other five-category items use their substantive endpoints, not observed sample
minima/maxima. Source nonanswers are missing. Composite means use available
components and remain missing when none is observed. Severity remains missing
for the 19 people at each wave with only one of its two components observed.
Observed baseline/exit counts and partial-component counts for every index are
in [`attitude_coverage.csv`](../audit/corrections/uk-health-1998/attitude_coverage.csv);
[`attitude_paired_means.csv`](../audit/corrections/uk-health-1998/attitude_paired_means.csv)
uses the same complete pair within each index.

The apparent discrepancies with the memo are substantive versions, already
identified in UKH-04. The archived R comment explicitly gives payer's direction
as government 0 / individual 1. For expensive treatments, it explicitly rebuilds
four equal components and notes an imperfect match with the memo's block-weighted
version. Substituting the latter would change 143 baseline and 138 exit values.
The memo prints both two- and three-item privatization versions; the current
three-item version reproduces its paired means (.53594 → .48578). Substituting
the two-item version would change 189 baseline and 173 exit values and introduce
three and one additional missing scores, respectively. These alternatives are
quantified in [`attitude_preserved_variants.csv`](../audit/corrections/uk-health-1998/attitude_preserved_variants.csv)
and remain unapplied. The nine-index catalog and eleven-index summary battery
also remain distinct. The [final report](../data/uk-health-1998/reports/uk-health-final-report.pdf),
PDF p. 4, places the initial questionnaire before invitation and the repeat at
the end of the weekend: t0 → t2, not arrival → exit.

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

### UKC-04: All five attitude indices reproduce the published paired means

**Status: reviewed; no additional numerical correction.** The codebook, raw
labels, retained stage-two questionnaire pages and the paper's Appendix B
(printed p. 487) establish these item sets at both waves:

| Index | Components | Direction |
| --- | --- | --- |
| Root causes | TIMCHLD, VIOLTV, SCHDISC | Greater effectiveness of addressing root causes |
| Policing | MORECOP, COPGUN | More police resources/powers |
| Punishment | PUNREF, STIFFER, MORPRSN, REFPRIS, S_TOUGH, FEWPRIS, PR_ONLY, OUTPRSN, COMSERV, MILSERV, TRAIN, PTOUGH, LIFE, LIFMEAN, DEATH | More punitive; reverse REFPRIS, FEWPRIS, PR_ONLY, OUTPRSN, COMSERV, TRAIN |
| Procedural restrictions | INNGLT, COPBEND, FEWJURY, CTRULES, PRESUM, MENTSIL, RTSIL, CONFESS | More restrictions on suspects' protections; reverse RTSIL and CONFESS |
| Self-protection | PROPSEC, WATCH, PATROLS | Greater support/effectiveness |

All substantive codes 1–5 map to 0–1 before those documented reversals. The
stored agreement/effectiveness items already reverse the printed response
order; reversing them again from the form alone would be an error. PUNREF's
endpoints are reform versus punishment, and INNGLT's are the relative seriousness
of convicting the innocent versus releasing the guilty. Nonanswers are missing,
not zero; each index averages available components. The corrected post root-causes
index uses TIMCHLD2, as approved in UKC-01.

Independent calculations match all ten current index-wave columns and baseline
extremity for all 869 source rows, including missingness, within `1e-12`. Among
the unchanged 299 historical respondents, the index-specific paired means are:

| Index | Pairs | Baseline | Exit |
| --- | ---: | ---: | ---: |
| Root causes | 298 | .786913 | .834871 |
| Policing | 299 | .647993 | .585702 |
| Punishment | 299 | .596650 | .537426 |
| Procedural restrictions | 298 | .445300 | .406284 |
| Self-protection | 299 | .695931 | .662068 |

All ten means round to [Table 4](../data/uk-crime-1994/papers/british-crime-paper.pdf),
printed p. 477. Its negative sign on root-causes change contradicts its own
increasing means; it does not justify reversing the source index. Full-source
and historical counts, missingness and partial denominators are retained in
[`attitude_coverage.csv`](../audit/corrections/uk-crime-1994/attitude_coverage.csv)
and paired values in [`attitude_paired_means.csv`](../audit/corrections/uk-crime-1994/attitude_paired_means.csv).
The [questionnaire scan](../data/uk-crime-1994/questionnaires/crime-questionnaire.pdf)
is partial: its eight PDF pages do not preserve every printed question page.
The [codebook](../data/uk-crime-1994/codebook.txt) supplies the remaining wording
and category definitions. The source interview pair remains t0 → t2. Differences
between the paper's 301 attendees, 300 source attendees and 299 grouped people
are documented sample boundaries, not silently repaired here.

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

**UKEU-02 — baseline nonanswers compressed two attitude scales (approved
and implemented).** The 900-row `survey.sav` contains `commies1` codes 1–5 plus
12 code-9 nonanswers and `favref1` codes 1–5 plus four code-9 nonanswers.
The [codebook](../data/uk-eu-1995/codebook.txt), Q14c SAQ1 and Q10 SAQ1,
labels code 9 “Not answered.” The SPSS file itself declares user-missing
codes 8/9 for `commies1` and −1/8/9 for `favref1`. All 238 attendees answered
both questions substantively, but the historical baseline scales use [1,9],
so substantive responses occupied only 0–.5. The wider source sample's nonanswers
became 1. At post, the same five substantive categories map to 0–1.

The archived `uk_eu.R`, dated May 22, 2014, first cleans `commies1` at line 158,
then overwrites it with `zero1(ukeu$commies1)` at line 195. Line 199 also passes
raw `favref1` to `zero1`; lines 196/200 explicitly clean and map the post
categories to 0/.25/.5/.75/1. The author's earliest public
[`zero1` source](https://github.com/soodoku/goji/blob/d6d6b5401de909d6873d8c2dd70b1b4fb23bc646/R/zero1.R),
June 19, 2015, defaults to the observed minimum and maximum, ignoring only R
missing values. It has no rule for SPSS missing labels or a half-width baseline
scale. Applied to the retained numeric codes, its formula reproduces both
historical baseline variables exactly for all 900 people. That public version
postdates the script: the exact 2014 installed helper and import wrapper have
not been recovered.

The codebook's opening note describes two original deposits: `europe.por`
retains nonopinion response codes; `europe_2.por` codes them missing. This
establishes a source-version distinction, not recovery of the second file or
proof of the original import settings. The retained
[attitude-constraint paper](../data/uk-eu-1995/papers/deliberation-attitude-constraint.pdf),
PDF p.30, independently places the Eastern European membership question on a
five-point agreement scale. Together with the raw missing declarations and
explicit post recode, the evidence supports correcting nonanswer handling,
rather than treating code 9 as a substantive endpoint.

The approved correction maps baseline substantive codes 1–5 to 0–1 and code 9
to missing, retaining direction and every other response rule. It recomputes
the dependent extremity and group summaries with their existing populations.
The [review script](../scripts/review_uk_eu_baseline_scale.R) uses the retained
SPSS file and direct formulas. It reconstructs the old calibration independently
and checks the corrected production values; it does not download `goji` or
replace production functions during the review. Its
[approved person-level values](../audit/corrections/uk-eu-1995/baseline_scale_approved_values.csv)
and [summary](../audit/corrections/uk-eu-1995/baseline_scale_summary.csv)
record these six changes among the 238 historical participants:

| Field | Changed values | Historical mean | Approved mean |
| --- | ---: | ---: | ---: |
| `ukeu.commies1r` | 228 | .272584 | .545168 |
| `ukeu.favref1r` | 235 | .370273 | .740546 |
| `attextreme` | 218 | .191877 | .216912 |
| `meanxtreme` | 222 | .191877 | .216912 |
| `avgsd` | 238 | .181248 | .237930 |
| `genvar` | 238 | .139597 | .197419 |

No participant missingness, identity, sample, knowledge score or other aggregate
field changes in this comparison. The approved table also preserves the frozen
benchmark's `historical_value` separately from the reconstructed `current_value`:
four historical generalized-variance values already differed because of the
reviewed singular-covariance calculation. The corrected inputs also leave group
2099 singular: four respondents, four attitude indices and covariance rank three.
Linux verification identified four generalized-variance discrepancies; all other
234 approved variance values matched. The numerical audit therefore checks the
corrected input matrix separately from the historical matrix. It requires its
exact input fingerprint, dimensions, singularity, a bounded floating-point
perturbation and agreement with a fresh calculation on the current machine.
This preserves the formula and does not relax comparisons for other groups or
fields. Across all 900 source respondents, 855
`commies1r` values change, including 12 becoming missing; 886 `favref1r` values
change, including four becoming missing; and 822 extremity values change,
including two becoming missing. The affected nonanswers belong to nonattendees.

The mismatch can manufacture apparent attitude change: 95 attendees give the
same substantive answer above code 1 at both waves for `commies`, and 101 do so
for `favref`, yet their historical post scores were higher. For example, raw code 3
scores .25 before and .5 after; the approved scale scores both .5. This is a
measurement mismatch even when the respondent has not changed an answer.

**Approved on September 28, 2026:** production now uses the fixed [1,5] scale
and reviewed missing codes in both waves. The three respondent definitions and
the dependent group summaries use version `ukeu-02-v2`. The codebook also says
SCPR collapsed “can't choose” with the midpoint for `FAVREF` before delivery.
Those separated responses cannot be recovered; the approved correction preserves
that merged midpoint. Other ethnicity remains unknown under UKEU-05. No
attendance, membership, knowledge score or historical sample rule changes.

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

**UKEU-05 — preserve unknown minority status for “Other.”** The codebook's
B14 IAQ asks, “In which of these groups do you consider you belong?” It labels
code 1 White; named categories include Black Caribbean, Black African, Indian,
Bangladeshi and Chinese. Code 8 is simply “Other,” with 19 source records and
five attendees. SPSS declares −1/99/97 missing but not code 8. Thus “Other” is
an observed answer; its content still does not identify whether the respondent
belongs in a binary white/nonwhite classification.

The archived `uk_eu.R`, line 82, explicitly excludes 8 alongside 97/99/−1 before
`ethnic != 1`. The five affected attendees are CASEID 328 (group 3), 4121
(group 1), 4135 (group 7), 4316 (unknown-group marker 99), and 4326 (group 6).
The current minority variable has 233 observed attendee values: 220 White and
13 in named nonwhite categories. All original ethnicity answers remain retained.
No fielded IAQ, write-ins or coding note identifying the content of “Other” was
recovered. Treating every code 8 as minority solely because it differs from 1
is therefore a rejected correction candidate; preserve unknown classification.
A modern definition based on “White British” would also change the construct:
the source's category is White, without that nationality qualifier.

The historical education threshold is separate. `educ4` maps school
qualifications 0/1/2 to 0, 3/4/5 to .33, 6/7/8/9/10/12 to .66, degree category
11 to 1, and other category 13 to missing. The later merge historically set
`bettered` to `educ4 >= .33` for this poll (90 of 230 nonmissing attendee values).
X-13 now applies the approved empirical median rule. Its median is 0, so strictly
above the median selects the same 90 people here. Neither definition is a
uniform college-degree indicator across polls.

The new respondent build reconstructs all 35 applicable UK–EU historical
respondent fields, including aliases and seven deliberately missing fields.
It uses all 900 source rows and separately verifies the 238-person historical
sample; the old 224-person knowledge outputs are unchanged. These parity checks
establish reproduction, not questionnaire validity or downstream robustness.

### UKEU-06: Full four-index attitude review after the approved scale fixes

**Status: reviewed; no further numerical correction.** The source codebook and
raw labels support four five-point policy indices at both waves: EU relations
(`RELEU`, `LONGPOL`, `UNITE`), EU scope (`TRABLOC`, `PASPORT`), Eastern European
membership (`COMMIES`) and referendum support (`FAVREF`). High values mean more
integration, broader common scope, support for accession and support for a
referendum, respectively. These are not uniformly pro-EU statements: referendum
support remains its own construct.

Each substantive 1–5 scale uses `(answer - 1) / 4`. Composite indices average
available components and are missing when all components are missing. The
approved UKEU-02–04 corrections remain in force. Baseline nonanswer codes 8/9
and post inapplicable/nonanswer codes are excluded as documented; baseline
TRABLOC and PASPORT contain no -1 cases. Post RELEU/LONGPOL code 6 is missing,
whereas UNITE's substantive middle category is retained. FAVREF's code 3 combines
neutral and can't-choose responses in the deposited source, so those answers
cannot be separated; the midpoint remains preserved, not newly imputed.

Independent reconstruction matches all eight index-wave columns and baseline
extremity across 900 source people, including missingness, within `1e-12`.
Historical attitude coverage remains 238 people; observed baseline/exit counts
are 238/224 for relations, 237/224 for scope, 238/221 for accession and 238/224
for referendum. The paired means are .569568 → .653646 (224 pairs),
.494955 → .518498 (223), .545249 → .540724 (221), and .741071 → .806920
(224), respectively. Full coverage and exact paired results are in
[`attitude_coverage.csv`](../audit/corrections/uk-eu-1995/attitude_coverage.csv)
and [`attitude_paired_means.csv`](../audit/corrections/uk-eu-1995/attitude_paired_means.csv).

The [paper](../data/uk-eu-1995/papers/deliberation-attitude-constraint.pdf), PDF
p. 8, supports initial-to-exit timing (t0 → t2), but its factor-derived batteries
are not these four policy indices; their published summaries are not a valid
like-for-like numerical benchmark. No standalone SAQ scans were recovered.
The [codebook](../data/uk-eu-1995/codebook.txt) provides question wording and
frequencies, including the unrecoverable FAVREF collapse. Group marker 99 remains
unknown, not a demonstrated sixteenth discussion group. UKEU-01's 220 known-group
people concern the 224-person knowledge subset, not all 238 attitude records.

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
respondent definitions retain that nine-item battery, with the approved UKM-01
correction replacing baseline Q5C reuse with departure R5C. The existing
eight-item knowledge export remains unchanged. Any further battery change
requires assessing its intended content against the instrument.
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
The archived age recode specified midpoints only for AGEB 2–9 and left codes
10 and 11 unchanged. Three and five nonattendees respectively retained those
numeric codes. A6 code 6 also passed through unchanged for one nonattendee;
B12A code 6 passed through the education recoder unless the qualification
override applied. No attendee had these three source-code exceptions. The
source-label review and approved corrections are recorded in UKM-06 below;
these exceptions no longer describe the maintained respondent output.

**UKM-05 — two catalog titles describe the wrong constructs (corrected).**
The archived cross-poll files call `ukmonarchy.t1mpop` “Powers of the Monarchy”
or “Power of Monarchy.” The reconstructed index behind that field instead
averages Q6A/B/E/F and Q7A/B: royal-family contact with ordinary people,
retirement and taxes, glamour, popular support and the public's say in
succession. The retained [codebook](../data/uk-monarchy-1996/codebook.pdf)
describes these items. The separate `ukmonarchy.t1pwrm` index uses Q15
(appointing a prime minister) and Q13D (more powers for the Queen). Thus
“Powers” is misleading for `t1mpop`, irrespective of the original authors'
preferred title. The original [index memo](../data/uk-monarchy-1996/codebooks/british-monarchy-indices-final.pdf),
INDEX 3, explicitly calls `t1pwrm`/`t2pwrm` “POWER OF MONARCHY”; the retained
cross-poll appendix also places these two questions under “Powers of the
Monarchy.” This resolves the previously preserved “Rules and limits” title.
The generated catalog now calls `t1pwrm` “Powers of the Monarchy” and `t1mpop`
“Royal Family and the Public.” No field link, response, index value, sample
or aggregate number changes.

**UKM-07 — all four main attitude indices independently verified.** The
2026-09-28 review reconstructs both waves from the raw survey, response labels,
codebook and original index memo: support for monarchy (Q/R1, 11, 9, 14), royal
family and public (Q/R6A/B/E/F, 7A/B), monarchy powers (Q/R15, 13D), and Lords
reform (Q/R18, 19A/B). All 2,064 respondent-index-wave values and missingness
patterns match, retaining 258 people and 15 groups. Available-item averaging
is supported by the memo's paired benchmarks: support .6646761 → .6335781
(N=255); public .5892280 → .6246447 (258); powers .391 → .4335 (250); Lords
.6095041 → .6477273 (242). The unusual referendum order—code 3 definitely
not, code 4 probably not—is verified by source labels; reversing these codes
would introduce an error. Initial household interviews precede invitation and
briefing materials; the comparison is pre-arrival to exit, not arrival to exit.
Per-wave counts and paired comparisons are retained in
`audit/corrections/uk-monarchy-1996/attitude_wave_review.csv` and
`attitude_paired_review.csv`. These checks support the existing available-item
estimand; they do not establish that missing components are random.

**UKM-06 — nonresponse codes in expanded demographics (approved correction).**
The retained `value-labels.csv` establishes `AGEB=11` as refused, `AGEB=10`
as 90+, `A6=6` as not answered, `B12A=6` as not answered and `B16=8` as
refused. The preceding recode retained age 11 for five source records and age 10
for three 90+ records, political interest 6 for one record, education 6 for one
record (with both collapsed education and higher-education flags consequently
misleading), and minority=1 for one ethnicity refusal. The affected source rows
are age: 97/141/225/322/481 (refused), 320/325/509 (90+); interest: 447;
education: 509, whose `B12B=14` is also not answered; ethnicity: 59.

All are nonattendees (`GROUP=-1`), so the 258-person historical aggregate is
unchanged. They are nevertheless present in the expanded respondent exports.
Approved correction: map explicit nonresponse to missing, and retain the 90+
raw band without pretending it establishes a point age. Do not substitute an
invented midpoint into group means. Preserve current midpoints for observed
AGEB 2–9, questionnaire answers, source identities and sample contracts.

Qualification nonresponse must be handled at the component level. `B12B=14`
occurs at source rows 431, 509 and 754. Rows 431 and 754 have an observed
`B12A=1` (no school qualifications); row 754 is an attendee in group 11. Keep
that observed school-education information. Only row 509 has both education
components unanswered (`B12A=6`, `B12B=14`) and currently acquires the out-of-range
education value 6. Converting every qualification refusal into wholly missing
education would incorrectly discard a valid answer for an attendee.

No exact-age field is available to recover the three 90+ ages: `AGEGP` and
`AGESEX` are further age bands, and `EDUCAGE` is school-leaving age. Keep the
source's open-ended 90+ category for future band-based analysis, while leaving
point age missing. This differs from refusal, even though both lack a usable
point age. Raw response codes preserve that distinction.

The user approved the ethnicity-refusal correction, then explicitly approved
the age, political-interest and education corrections on 2026-09-27. The
correction changes 13 derived cells across ten nonattendees: eight ages, one
political-interest value, one minority flag and three education measures. The
separately harmonized political-interest measure already excludes codes 5/6
and therefore needs no numerical change. Raw responses and all sample and
identity contracts remain intact. The rebuilt export confirms exactly these 13 numeric changes and 5,142
definition-version updates (six measures across 857 source records). All seven
other respondent tables, every aggregate output and every canonical analysis
output are byte-identical to the preceding version. Both respondent and
aggregate parity comparisons have zero unexplained differences. The focused
regression test passes 22 assertions, including preservation of valid school
answers and the full attendee demographic values. No model was rerun.

**UKM-08 — absent departure forms incorrectly scored zero (corrected).**
The source `WEEKEND` field is labeled “attended weekend”: 258 records have
code 1 and 599 have code -1. All 61 raw departure-question fields (`R1` through
`R22D`, selected by `^R[0-9]`) equal -1 for every one of those 599 records:
36,539 placeholders and no observed post answers. All 258 attendees have
recorded values across that block. This establishes whole-form absence using
the source participation cohort and the full questionnaire, rather than
inferring it from quiz correctness or group assignment.

The retained [codebook](../data/uk-monarchy-1996/codebook.pdf), PDF page 6,
reports 599 nonparticipants and 258 participants. Pages 83 (`LINETH2`/W5a)
and 92 (`LINETHR2`/W8a) explicitly label the 599 absent departure responses
“Non-participant.” That analytical codebook uses 101; the maintained raw file
uses -1. The evidence agrees on the cohort and missing interview, not on a
shared numeric sentinel. The raw R-block is the source departure instrument,
corresponding to the codebook's post self-completion W-block; the registered
comparison remains pre-arrival to immediate exit (`t0` to `t2`).

Previously, the historical item recoder compared -1 to each answer key and
returned nine zeros. Canonical presence could then treat these literal numeric
placeholders as evidence of an observed interview. The user-authorized common
absent-questionnaire rule now applies through one shared
`monarchy_departure_observed()` source helper, used by the respondent recoder
and phase presence reader. It accepts the documented -1 placeholders or missing
values, rejects a nonparticipant row containing an actual departure answer,
and retains observed-form blanks as zero-scored quiz omissions. A participant
with an entirely unobserved form remains unresolved rather than automatically
being labeled absent. Source row subsets and reordered rows use the same rule.

For the full 857-person source, nine departure item scores become missing for
599 nonparticipants (5,391 cells). Six post-dependent respondent measures become
missing for those same people (3,594 cells): departure knowledge, joint
knowledge, both gains, log joint knowledge and the high-joint-knowledge flag.
In each canonical selected/phase table, 599 departure scores and their 5,391
item scores likewise become missing; `n_correct` is missing and `n_observed`
is zero for the absent interview. Raw -1 codes remain available. Existing
attendance inference classifies those 599 unknown attendance records as false,
with its explicit absence-inference basis. All people, baseline answers and
scores, group assignments and panel flags are retained.

Independent before/after comparison verifies that every field for all 258
historical attendees is identical. The 258-person historical aggregate and
the corresponding Cor cohort are unchanged; this correction removes invented
outcomes from the wider nonparticipant source. Focused tests cover the full
61-field absence evidence, contradictory observed answers, an observed form
with a blank nine-item quiz, row subsets and order changes, canonical presence,
and all six missing post-dependent measures.

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

A renewed extreme-age check found serial 6206 with raw `AGE=96`, labelled age
in years (QA3), and no special meaning for code 96. This is a nonparticipant
(`filter=0`, `PARTIC=0`). A high age alone does not justify a missing-value recode;
preserve this observed age.

**UKGE-04 — demographic and missing-code boundaries.** Ethnicity -7 becomes
missing, including two attendees; codes other than 1 become the historical
minority indicator. Age -7 becomes missing. School education is overridden by
higher qualifications; household income's 16 categories collapse to five and
historical individual high income meant a collapsed category above 2. X-13 now
uses the approved empirical median rule, with the same individual flag feeding
group shares. Source labels and the existing
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

**UKGE-06 — all four main attitude indices verified; archived appendix names
two different questions.** The 2026-09-28 independent reconstruction reproduces
all 2,200 values, including missingness, for 275 people in 15 groups. The paired
source fields are REDSTR1/2 (Q12, income equality), TAXR1/2 (Q13, taxes versus
public-service spending), WAGER1/2 (Q14, minimum wage), and EUR1/2 (Q15, European
integration). Seven substantive categories use the maintained 0/.17/.33/.5/.67/
.83/1 mapping; −8 and −9 remain missing. Available-case raw means reproduce
all eight Table 3 entries in *The British General Election Deliberative Poll*:
5.15 → 5.46; 5.86 → 5.81; 5.76 → 5.41; 3.78 → 4.57. Paired samples are
263, 270, 253 and 228, respectively; sample-specific comparisons are retained
in `audit/corrections/uk-general-election-1997/attitude_paper_review.csv`.

The archived `appendix-attitude-indices-6-07-15-rcl.pdf`, PDF p. 1, instead
names five-category REDIST and TAXRICH questions for the first two indices.
REDIST has no corresponding paired field; TAXRICH is a different pair about
wealthy people paying more taxes. The actual paired source fields, instrument
and Table 3 agree, so this appendix mismatch does not justify substituting
questions or changing score bounds. The initial January household interview
preceded invitation and the April event: these are pre-arrival-to-exit changes.
The existing 276 published attendees versus 275 deposited eligible records
remains a roster discrepancy, not permission to invent a person. All numerical
recodes and eligibility rules are preserved.

## CPL 1996 — cpl-1996

**CPL-01 — preserve missing-code provenance across file versions.** The build
uses `cpl.sav`; the later `cpl2.sav` carries equivalent attendee answers after
759 explicit code-99 responses in the earlier file are treated as missing.
The [codebook](../data/cpl-1996/codebook.txt) identifies 99 as don't know.
Correctness stays missing in response tables; the explicitly named zero-filled
score counts it as zero. Seven-item scores and gender match the deposit for
216 participants in 16 groups.

The 2026-09-28 attitude review also compared all 21 attitude dependencies used
by the maintained indices and summaries across the full 1,246 source rows in
`cpl.sav` and `cpl2.sav`. Substantive values and source identities agree after
99 is treated as missing. This is not a claim that every field in the two source
versions is equivalent; unused ranking and employment fields differ separately.

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
The CPL-04 transport correction below now classifies code 99 in the reviewed
attitude dependencies. This does not certify every demographic or unused source
field, and `n_observed_fields` is not a scoring denominator.

### CPL-04: Codebook don't-know attitudes no longer count as observed inputs

**Status: authorized transport-consistency correction.** The original CPL
source has no embedded value labels for these fields, but the retained
[codebook](../data/cpl-1996/codebook.txt) explicitly labels 99 as DK. All 22
component-wave frequency tables, including both competition questions, agree
with the raw source. The 21 dependencies exported for the six paired indices
and seven-index baseline summary contain 1,001 code-99 answers across 498 source
people. Previously these were marked `answered` despite already being excluded
from the numerical indices. They now have `response_status = non-substantive`
and `missing_code = 99`. Valid zero and ten ratings remain substantive.

Exactly 1,180 `n_observed_fields` records decrease; every numeric measure, raw
value, source/historical identifier and sample remains unchanged. Independent
before/after records are retained in
`audit/corrections/cpl-1996/attitude_input_status.csv` and
`audit/corrections/cpl-1996/observed_input_counts.csv`. This correction does not
replace the historical available-component mean with a fixed denominator.

### CPL-06: Utility attitude indices and summary batteries independently reviewed

The read-only 2026-09-28 review independently reconstructed every component,
all six attitude pairs, and the seven-index baseline summary for CPL, WTU and
SWEPCO. Raw-to-output checks cover all 1,246/1,230/1,478 source people and
216/230/232 selected people in 16/14/14 groups, respectively. Source and
historical IDs, membership, individual extremity, group mean extremity, average
SD and generalized variance reproduce, including the approved X-15 missing
values for invalid pairwise covariance. No new selected attitude-score recode
is supported by this pass. Available-component and missing counts for both
waves and populations are in `audit/utility-attitude-coverage.csv`.

| Index | CPL components | WTU/SWEPCO components and retained policy |
| --- | --- | --- |
| Research | RESCH and FEDRCH, each divided by ten, then available mean | Available mean of RESCH/FEDRCH; FEDRCH is wholly absent in these two sources, so the observed index uses RESCH alone. All-missing input is filled as raw five before calibration. |
| Conservation | ADDFAC and REDUCE, divided by ten, then available mean; baseline export has the additional .05–1 attendee calibration | ADDFAC and REDUCE available mean; the approved post typo correction is retained. WTU baseline/post minima 2/1.5; SWEPCO 3/0; maximum ten. All-missing input is filled as .5 after calibration. |
| Low-income support | Mean of LOWINC/10 and (POOR−1)/4 | NEEDTO/10, with missing filled as raw five; the earlier construct remains the approved definition. |
| Renewables | RENEW and WIND, divided by ten, then available mean | RENEW and WIND available mean; WTU minimum 2.5 at both waves; SWEPCO minimum 1/0; maximum ten. All-missing input is filled as .5 after calibration. |
| Fossil fuels | FUELS baseline /10; post (FUELS−1)/9 | FUELS/10, with missing filled as raw five. |
| Imported power | BUYPWR/10 | BUYPWR/10, with missing filled as raw five. |

Each baseline summary also includes COMPET, mapped (COMPET−1)/4. CPL missing
competition stays missing; the historical WTU/SWEPCO raw-five fill maps to one,
not the scale midpoint. Those observed-form missing-item choices, the seventh
summary index, nested available means and historical wave calibrations are
preserved. Applying attendee calibrations outside the historical sample yields
three negative CPL baseline conservation values, five WTU conservation/seven
renewables values and 13 SWEPCO conservation/four renewables values. These are
expanded-source historical transformations, not evidence to clamp answers or
silently replace the approved selected-sample metric.

**Rejected direction concern.** Although the CPL POOR prompt lists agreement
first, its frequency-table labels explicitly code strong disagreement as one
and strong agreement as five. The maintained positive direction is correct for
that source. An October 2006 index memo gives reversed POOR means (3.42/3.25
versus raw 2.578125/2.752525); it also reproduces several means only when DK is
temporarily coded eleven. Neither feature licenses reversing or treating DK as
substantive in the maintained source. The codebook and both source versions
agree on its actual response values.

**Evidence boundary.** All 58 component-wave frequency tables across the three
polls agree with the original raw values, including DK counts; the retained
codebooks supply question wording and numerical direction. The 57-page utility
questionnaire compendium has no verified section for these three polls, so this
is not a claim of complete fielded-instrument verification. The earlier broad
index memo, later six-index catalog and executed scripts describe distinct
batteries. No supplied survey-weight field was identified in these raw surveys;
this pass preserves the existing unweighted summaries and does not decide a
weighted estimand. T1 is the telephone interview before invitation and T2 the
post-meeting questionnaire, supported by the codebook and utilities design
report; separate exact CPL event-date bounds remain documented in poll facts.

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

**SWE-01 — original portable missing codes recovered.**
**Status: verified source recovery; no numerical recode.** The maintained
attendee build has 232 people, five items and 14 groups. The original archive
also retains 1,478 source records, including 1,246 nonparticipants, in
`vault/cdd/data/Utilities/swepco/swepco_data/swepco.por` (652,062 bytes;
SHA256 `728cbb5976bb64022a60008041db37d28f171f878b453207562626c29e4161d6`)
and `swepco2.por` (638,860 bytes; SHA256
`24f76c8bafc3b8122da56a7fa45bc260378c092128594e80a2b594b7f305afe0`).
Both hashes match [the archive inventory](../audit/cdd_archive_files.csv).

These are genuine SPSS portable files with 80-character records and a
`SPSSPORT` tag. The original haven/foreign failures are reproducible, but do
not establish unavailable data. Stat/Transfer wrote numeric missing tokens as
`*1`; [GNU PSPP's portable-format documentation](https://pspp.benpfaff.org/manual/portable.html)
describes an asterisk followed by one character, generally a period but
possibly another character. Replacing only `*1` with `*.` in scratch copies
allows pyreadstat 1.3.4 and haven 2.5.5 to decode 1,478 rows by 195 raw or
196 cleaned fields. These readers share ReadStat, so their agreement is not
an independent parser implementation. A separate reviewer reran the recovery
and comparisons. CASEID values, order and uniqueness match the maintained
`survey.dta`; all 289,688 cleaned cells match its values and missingness
within 2e-12. The extra cleaned `SETRT` field is entirely missing.

The raw-to-clean comparison confirms 14,774 code-98/99/999 cells collapsed to
missing, with no changed substantive value. The archived `missingvalues.sas`
provides the corresponding cleaning rules; each missing reason still requires
the field's own codebook label. For the five attendee knowledge items at both
waves, [the codebook](../data/swepco-1996/codebook.txt) Q14–18 explicitly labels
99 as DK: 436 cells across 200 attendees, 312 baseline and 124 post. All
2,320 historical attendee item correctness cells and 464 scores independently
reproduce from the original codes. Together with WTU-01, this recovers 845 DK
cells without changing knowledge correctness or scores. There are no embedded
value-label maps in these portable dictionaries; labels come from the retained
codebooks. The [original raw portable file](../data/swepco-1996/source-materials/survey-original.por)
is now retained unchanged with the
[original missing-value recode](../data/swepco-1996/scripts/original-missing-values.sas)
and [source construction script](../data/swepco-1996/scripts/original-survey-construction.sas).
Its 195 numeric fields are a subset of the maintained public survey's 196;
all previously observed values and respondent identities agree. Dictionary
traversal confirms there are no author, document, or other unique identifying
strings. The additional recovered values are exclusively numeric nonanswer
codes. The cleaned portable copy is redundant with the maintained DTA and is
not added as another public duplicate.

Run `Rscript scripts/review_utilities_sources.R` to reproduce this comparison
using only repository files. The bounded reader in
[R/source_utilities.R](../R/source_utilities.R) checks the registered source
hash and fixed-width structure, changes only the missing-token suffix in a
temporary copy, and deletes that copy after reading. Source bytes remain
unchanged. Its outputs retain [summary counts](../audit/corrections/utilities-source-recovery/summary.csv),
[all recovered attendee DK cells](../audit/corrections/utilities-source-recovery/nonanswers.csv),
and [all absent post-form identities](../audit/corrections/utilities-source-recovery/absence.csv).
Neither the maintained survey nor any production response, score, attendance,
or aggregate table changes in this source-recovery step. SWE-05 subsequently
corrected knowledge scores for these absent post forms.
The separate proposal to remove imputed post attitude scores remains
unapproved; it is not part of that knowledge correction.

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
not be mistaken for identical measurement. SWE-01 now recovers the earlier
portable files; the archived script's execution provenance is not established.
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

**SWE-05 — nonparticipants receive scores for absent post forms.**
**Status: user-approved correction, implemented upstream.**
The original portable files and [codebook](../data/swepco-1996/codebook.txt)
identify 1,246 `PART = 2` nonparticipants. Every one of 74 direct post fields
is system-missing in every original nonparticipant record, unlike code-99 DK
within an observed form. Original SAS construction reads their baseline-only
nonparticipant input. The [utilities paper](../data/shared/papers/utilities-paper.pdf),
PDF pages 4 and 6, describes baseline telephone interviews followed by
end-of-event participant questionnaires and defines nonparticipants as
interviewees who did not participate. This establishes absent post forms
rather than merely an unanswered five-item quiz; it does not establish a
randomized control assignment.

Before correction, each of `analysis_scores` and `analysis_phase_scores`
contained 1,246 post rows with `score = 0`, `n_correct = 0`, `n_items = 5` and
missing `n_observed`. Phase `wave_observed` was missing. Each of the selected
and phase item tables had 6,230 `correct = 0` cells labeled `scored` for
these forms; `historical_knowledge_items` also had 6,230 zeros, not missing.
Examples are CASEIDs 30002330, 30002340 and 30002350. `panel` is already
FALSE; `attended` remains unknown despite the explicit nonparticipant label.

The approved correction starts in `utility_knowledge_items`: only verified
`PART == 2` post forms receive wholly missing item rows. Present-form blanks
and DK answers retain zero correctness. The shared knowledge summary accepts
whole missing waves, rejects partially missing scored rows, and propagates
absence through post scores, joint scores, gains, and their transformations.
The shared group-gain calculation still requires complete scores within observed
groups; all these nonparticipants have no group and cannot affect attendee peers.
Canonical item status is `wave_absent`, correct counts and scores are missing,
`n_observed` is zero, and phase presence is FALSE.

SWEPCO changes 6,230 post item cells in each historical, selected and phase item
table and 1,246 post scores in each selected/phase score table. Across SWEPCO and
WTU, 13,476 respondent measure values become missing: six dependent measures
for each of 2,246 absent forms. Of these nonparticipants, 1,127 in SWEPCO and
796 in WTU had positive baseline scores; the fabricated post zeros therefore
created 1,923 apparent knowledge losses. Their changes are now missing because
no post interview is observed. All baseline values, attendee scores, raw source
values, participant identities, memberships and Texas aggregate values remain
unchanged. The existing attendance field is unchanged; the correction records
verified questionnaire absence directly. The source review script and
[absence evidence](../audit/corrections/utilities-source-recovery/absence.csv)
retain every affected source identity.

## WTU 1996 — wtu-1996

**WTU-01 — original portable missing codes recovered.**
**Status: verified source recovery; no numerical recode.** The maintained
attendee build has 230 people, five items and 14 groups. The original archive
retains 1,230 source records in
`vault/cdd/data/Utilities/wt/wt_data/wt.por` (545,626 bytes; SHA256
`5fd9f3b1b01eff7abbf4d9c7271959b8188e55360d5997e6527ad3019c4dd082`)
and `wt2.por` (534,064 bytes; SHA256
`44ef3e3af149bb16d8dde864bf75f41eaf2985cc7ad46daf6a6d4db245d14492`).
Both hashes match [the archive inventory](../audit/cdd_archive_files.csv).
The same verified missing-token normalization and reader checks as SWE-01
recover 1,230 rows by 195 raw or 196 cleaned fields. CASEIDs match exactly;
all 241,080 cleaned cells agree with maintained `survey.dta` within 2e-12,
including missingness. The extra cleaned `SETRT` field is entirely missing.
The raw-to-clean comparison confirms 12,823 code-98/99/999 cells collapsed to
missing, with no changed substantive value; the archived `missingvalues.sas`
records the cleaning rule. Do not assign a common reason to all such codes.

[The codebook](../data/wtu-1996/codebook.txt) Q14–18 labels knowledge code 99
as DK. Recovery identifies 409 attendee item cells across 170 people, 306
baseline and 103 post. All 2,300 historical attendee item correctness cells
and 460 scores independently reproduce from raw codes. SWEPCO and WTU
therefore supply 845 verified attendee DK cells in total. Original portable
bytes remain immutable. The [original raw portable file](../data/wtu-1996/source-materials/survey-original.por),
[missing-value recode](../data/wtu-1996/scripts/original-missing-values.sas), and
[source construction script](../data/wtu-1996/scripts/original-survey-construction.sas)
are retained in this poll's folder. The same field and dictionary review as
SWE-01 finds no new fields or unique identifying strings beyond the existing
public survey. The repository-only reader and review script described there
reproduce all WTU comparisons and audit outputs. Production values remain
unchanged. The separate 1,000-row absent-post score problem is recorded in WTU-06.

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

**WTU-06 — nonparticipants receive scores for absent post forms.**
**Status: user-approved correction, implemented upstream.**
The recovered original portable files and [codebook](../data/wtu-1996/codebook.txt)
identify 1,000 `PART = 2` nonparticipants. All 74 direct post fields are
system-missing in every original record; source SAS construction uses their
baseline-only nonparticipant input. The shared paper and design evidence in
SWE-05 support absent post forms, not observed blank quizzes or assigned
controls. CASEIDs 20002310, 20002320 and 20002330 are examples.

The shared upstream correction described in SWE-05 makes 1,000 post scores
and correct counts missing in each selected/phase score table, with zero
observed items and phase presence FALSE. The 5,000 corresponding correctness
cells become missing in each historical, selected and phase item table;
canonical status is `wave_absent`. Six dependent respondent measures per person
also become missing. All 230 attendees, baseline values, source identities,
item denominators, raw responses and WTU aggregate values are retained.
Unanswered items within an observed form still score zero. The original source
and reproducible identity-level evidence are retained as described in WTU-01.

### WTU-07 / SWE-06: Absent departure questionnaires and explicit imputation

**Approved and implemented September 29, 2026.** The rule uses the same questionnaire-
presence evidence as the approved knowledge correction and removes six imputed departure
attitudes for each of the 1,000 WTU and 1,246 SWEPCO nonparticipants. The original
portable files contain no observed value in any of the 81 fields ending in `2`
for these people; the 230 WTU and 232 SWEPCO attendees have observed post forms.
Those 81 fields include the broader retained post block, whereas WTU-06's 74
count refers to the direct post fields in its original knowledge audit.

An executed candidate build changes exactly 6,000 WTU and 7,476 SWEPCO
`respondent_measures.value_numeric` cells to missing. WTU research was 4/9 and
its other five indices were .5; all six SWEPCO indices were .5. Every other
column, person, baseline value, knowledge value and observed-form attitude is
identical. CPL is unchanged. Synthetic checks also retain the historical
item-imputation policy for an observed questionnaire whose attitude answers
are all missing, and reject a claimed absent form with an observed post answer.

All thirteen canonical analysis Parquet files are byte-identical, as are the
historical aggregate outputs. Thus the current main inputs to dp-learning,
dp-distortions and dp-deliberately are unchanged; no model rerun is needed to
establish that input conservation. This does not endorse imputing omitted
attitude items within an observed form, which remains a separate authored
policy. The retained summaries and full-table comparisons are the
`attitude_absence_*.csv` files in `audit/corrections/utilities-source-recovery/`.
The archived comparisons describe the isolated absence correction. The subsequent
user-approved naming change exposes plain indices with missingness preserved and
separate `_midpoint_imputed` variants (X-03); common attendance inference is a
separate schema change, so the archived byte-identity claim does not describe
the combined build.

## Australia republic 1999 — australia-republic-1999

**AUS-01 — existing missingness divergence; score parity.** There are 347 attendees
in groups 1–24 out of 4,659 source rows; group 100 is inapplicable. The ten-item
battery combines six factual items and four proposed-change questions. The
wave-specific `dkchg` flag can override correctness on those four items while
raw answers remain preserved. Sixteen T2 code-99 responses differ from the
binary deposit as missing rather than incorrect; zero-filled scores do not move.

**Rechecked 2026-09-28:** the 16 differences are four exit symbolic-change
items for each of CASEID 240, 312, 1512 and 1526. All are raw code 99, labeled
not answered. The item table preserves that nonresponse status, while the
fixed-denominator score already counts them as incorrect. This is not an
unresolved score discrepancy. The routing issue is separate: baseline DKCHG=1
combines none and don't know, whereas exit DKCHG=1 means nothing will change.
All 52 flagged baseline respondents and 37 flagged exit respondents have four
literal no codes, but the available file cannot establish whether these are
answers or generated routing defaults. The retained constitutional-referendum
study codebook concerns a different survey; it is not the fielded DP instrument.
Do not equate missing item answers and substantive no-change responses.

### AUS-02: Aggregate knowledge uses a different battery and flag rule

**Preserve / review.** The 347-person aggregate reconstruction uses 12 items,
whereas AUS-01 concerns the separate ten-item deposited battery. The active
preserved `aus_republic.R` applies `DKCHG1` to four symbolic-change items; its
commented alternative omits the gate and exactly reproduces the aggregate.
Applying the active gate changes 52 baseline/joint scores, by as much as 0.25.
The aggregate's `NUMITEMS = 11` is also inconsistent with its 12-item denominator.
Issue-specific scores are absent from the final aggregate even though later
syntax constructs them. Check the fielded change-question routing, index memo,
and script/export dates before choosing a version.

**Count correction approved and implemented 2026-09-28.** Previously,
`build_australia_derived()` multiplied the 12-item peer measure by `12/11`
and published `numitems=11`. It now derives the count from the scored matrix
and omits that multiplier. The original `aus_republic.R` sets the count to 11
at line 27 but supplies 12 columns to the knowledge matrix at line 237;
`hlmFunc.R` line 51 divides each accumulated contribution by that count.
AUS-04 corrected row alignment, not this mismatch. Setting the count to 12
and removing the extra multiplier changes 346 `grpgain` values and their
346 `loggain` values, preserving the one missing case and all 347 people.
Mean peer knowledge changes from 0.4419517 to 0.4051223; the maximum changes
from 0.8571429 to 0.7857143. Individual knowledge scores do not change.

This correction does not require merging the ten- and twelve-item definitions.
The latter includes two additional office-holder questions about Aden Ridgeway
and Jennie George. Their correct-answer proportions reproduce the retained
report's rounded 46/58 and 63/69 baseline/exit percentages. The original script
also explicitly excludes a party question and discusses the change gate's
reliability. These are documented battery choices; the unresolved part is the
fielded QC4/WC4 routing instruction, not whether twelve columns are eleven.
The source answers, individual scores and all 347 participants are unchanged; the corrected peer fields use definition
version `aus-02-v3`. The review script preserves all previously approved
Australia comparisons and records the corrected item count as well.

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
poll [paper](../data/australia-republic-1999/papers/adp5.pdf). The initial
telephone questionnaire has now been recovered (AUS-06); the exit instrument
and the exact source transformation behind the routing defaults remain needed
to settle the separate AUS-01/AUS-02 routing question.

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
formula evidence. AUS-02 subsequently corrects the 11-versus-12 denominator;
the figures in this paragraph describe the earlier row-alignment correction.

The earlier row-alignment correction produced 342 finite paired changes above
1e-10 and one missingness change in each
of `grpgain` and `loggain`. A misassigned positive infinity disappears in the
corrected values. Finite `grpgain` mean changes from 0.614531 to 0.441952;
the maximum finite paired difference is 5.181818. The diagnostic independently
replays the recycled historical assignment and verifies the deposited values.
`make polardata compare-polardata` reports zero unexplained differences; only
these two aggregate fields change. The recorded dp-distortions output files
(19 of 19) and dp-deliberately's paired outcomes are byte-identical, and
dp-learning's 6,013-by-20 analysis frame is identical. These checks do not
establish effects in downstream analyses that consume `grpgain` directly.
The [current approved values](../audit/corrections/australia-republic-1999/approved_values.csv)
include the subsequent AUS-02 denominator correction: 346 finite changes from
the frozen historical gain, with one missingness change. The separate
[item-count comparison](../audit/corrections/australia-republic-1999/item_count_values.csv)
isolates AUS-02 from the earlier row-alignment correction. Reproduce both
comparisons with `Rscript scripts/review_australia_gain.R`.

### AUS-05: Age refusal no longer counts as age 98 (approved correction)

`data/australia-republic-1999/value-labels.csv` explicitly labels `age=98`
“REFUSED.” The preceding `build_australia_individual()` retained that value
as a year age.
Fourteen source records are affected; three are among the 347 attendees:
CASEID 199 (source row 3638, group 2), 648 (row 4020, group 18), and 1226
(row 4419, group 10). The other eleven belong to inapplicable group 100.
This is an explicit refusal code, not evidence of unusually old respondents.

Approved correction: make these ages missing while retaining raw code 98.
The central group-summary stage will recompute mean age using observed ages;
no group formula belongs in this poll's respondent recoder. Preserve the
347-person sample, knowledge, attitudes, education and other demographic
values. A renewed source-level review confirms the existing central mean helper
already omits missing ages. Only these three group means change:

| Group | People | Age responses after correction | Previous mean age | Corrected mean age |
|---|---:|---:|---:|---:|
| 2602 | 17 | 16 | 47.1176470588 | 43.9375000000 |
| 2610 | 14 | 13 | 48.5000000000 | 44.6923076923 |
| 2618 | 12 | 11 | 44.1666666667 | 39.2727272727 |

That is three attendee age cells and 43 repeated group-mean cells. Across the
full source, 14 refusal ages become missing; the other eleven remain
outside the attendee panel. Education code 98, income codes 97/98 and political
interest code 97 already become missing. `overseas=100` is inapplicable for
native-born respondents to the follow-up about whether their overseas birthplace
was English-speaking; its existing nonminority coding is a construct choice,
not evidence of an unanswered ethnicity question. These adjacent fields are
unchanged by the age correction.

The separate constitutional-referendum `codebook.pdf` cannot establish
this deliberative poll's field meanings; the actual poll-source value labels
provide the refusal evidence. The user approved this age correction on
2026-09-27. Raw responses and membership remain intact; the independently
frozen comparison covers all 347 participant ages and group means.
Age-based downstream summaries or regressions may change because three
attendee ages now correctly lack an observed value. Preserving participation
does not guarantee an unchanged complete-case sample in an age-adjusted
model. No paper or downstream model is rerun as part of this correction.

The rebuilt respondent export confirms all 14 age refusals become missing;
all other respondent values are unchanged by AUS-05. Exactly three `ppage`
and 43 `meanage` cells change in the wide aggregate, and the same 43 means
change in the typed derived table. The age definition is versioned
`aus05-v2`, as is the centrally generated mean age. All other polls, raw
response tables, identities, membership and knowledge tables remain
unchanged. Current canonical analysis outputs are byte-identical. Both
respondent and aggregate comparisons have zero unexplained differences.
The existing frozen comparison rows were preserved verbatim, with 694
age/group-mean rows appended; no prior correction values were rewritten.

### AUS-06: A first preference for the Queen survives an unanswered second choice

**Approved and implemented.** The [initial telephone questionnaire](../data/australia-republic-1999/questionnaires/t1-questionnaire.pdf),
Newspoll job 990906, p.2 A6(a/b), asks which of three constitutional options the
respondent most prefers, then which of the remaining two comes next. Code 3
is keeping the Queen and Governor General. The archived `aus_republic.R`
lines 330–341 and the attitude appendix (PDF pp.9–10) say Queen first scores
0, second or don't know .5, and third 1. The script assigned first-place 0
before applying the second-choice missing-code rule, which overwrote that
known first preference with .5. The corrected rule gives a stated first
preference priority. It retains all other authored midpoint rules, the
popular-versus-parliament ranking, and the available-component mean of rank,
constitutional ties and an Australian head of state.

Among the same 347 people, 11 baseline and 13 exit republican-index values
change, affecting 21 distinct people. Baseline changes all have first=3,
second=97; exit changes have first=3 and second=97 (six people) or 99 (seven).
The mean baseline index falls from 0.6707492795 to 0.6654658982; the mean exit
index falls from 0.7509606148 to 0.7435158501. The largest reductions are 1/6
at baseline and .5 at exit: case 307 has only the rank component observed
at exit. Both indices remain observed for all 347 people. Across all 4,659
source rows, 36 baseline and 13 exit values change. Raw responses, identities,
groups, all missingness patterns and other measures remain fixed. Reproduce
the independent raw calculation with `Rscript scripts/review_australia_ranking.R`;
[full source evidence](../audit/corrections/australia-republic-1999/ranking_source_values.csv),
[summary](../audit/corrections/australia-republic-1999/ranking_summary.csv) and
[approved historical values](../audit/corrections/australia-republic-1999/approved_values.csv)
preserve both sides of the correction without relying on overwritten outputs.

**Downstream point-estimate check.** With `dp-learning` commit `2880c14`,
the corrected baseline policy indices change ten individual extremity values
and 143 repeated group-disagreement and standard-deviation values, across ten
Australian groups. One of the eleven index changes leaves absolute distance
from .5 unchanged. None becomes missing. The attitude models retain all 8,350
people, including 344 Australians; the demographic model on that same sample
is unchanged. In the main attitude model, the extremity coefficient moves from
0.01688996 to 0.01636405 and disagreement from −0.09785503 to −0.09941042. In
the standard-deviation sensitivity model, the corresponding coefficients move
from 0.01746649 to 0.01694281 and −0.11227705 to −0.11373790. The
[frame comparison](../audit/corrections/australia-republic-1999/ranking_learning_frame_changes.csv),
[model samples](../audit/corrections/australia-republic-1999/ranking_learning_model_samples.csv)
and [point estimates](../audit/corrections/australia-republic-1999/ranking_learning_model_estimates.csv)
record this isolated check. No bootstrap intervals or manuscript were rebuilt
for this increment; the paper remains explicitly pinned to pre-AUS-06
`dp-data` commit `f22f17f` until its next coordinated update.

**Broader attitude review.** Both main indices at both waves were independently
reconstructed from raw questions, with exact agreement before the approved
change. The five original summary batteries—autonomy, workability, democracy,
tradition and politicization—also reproduce their deposited indices, including
missingness, at both waves. Their baseline/exit observed counts are respectively
347/346, 346/346, 343/344, 346/344 and 340/346. They deliberately differ from the
two policy indices: [Jim's source memo](../data/australia-republic-1999/codebooks/jim-australia-indices.pdf)
distinguishes empirical premises from policy preferences and proposes ranking
questions for the latter. This exploratory memo is not evidence that every
suggested index was adopted. AUS-03's four-index extremity and the retained
five-index group dispersion definitions stay fixed; AUS-06 changes neither.
The [paper](../data/australia-republic-1999/papers/adp5.pdf), Table 1 (PDF p.19),
reproduces 33 of 34 raw-item means at its printed two decimals. Baseline PMPOWER
is 2.424615 (2.42), versus printed 2.43: this small tabulation/version discrepancy
provides no justified recode. Valid first-choice proportions also reproduce the
paper's shift toward parliamentary appointment. The paper does not print the
ranking composite and therefore cannot validate its chosen intermediate spacing.

The retained questionnaire uses opposite printed Likert numbering from the
revised SAV labels. Reversing the already recoded source again would be wrong.
The newly recovered initial instrument establishes baseline wording and routing;
no exit questionnaire was recovered. The broader knowledge-routing issue remains
separate, and the unrelated constitutional-referendum codebook remains unsuitable
as a substitute for the fielded DP questionnaire.

## BTP 2007 — btp-2007

**BTP07-01 — selection variables with similar names have different roles.**
`group == 1` selects 301 discussion-treatment respondents from 1,501 records;
`Sgroup` gives the 20 small groups and `CaseID` identifies people. Codes 99, 998,
and 999 are non-substantive in the knowledge battery. The briefing-reading
field is different: its code 99 means “all or nearly all” and remains substantive.
All eight-item scores and gender match the deposit.

The original [codebook.pdf](../data/btp-2007/codebook.pdf), PDF page 4
(printed page 3), explains the selected cohort: 326 people attended all four
sessions, and 301 of them completed the post-survey. Across all attendance
levels, 771 attended at least one discussion and 695 treatment respondents
completed a post-survey. The published 1,501-row source contains 301 discussion
participants, 700 primary controls, 200 reading-only controls and 300 post-only
controls. Thus assignment, attendance and analysis inclusion are distinct;
`group == 1` is not a census of everyone who attended any discussion.

### BTP07-02: Fielded keys reproduce the weighted report (checked; no correction)

The PRE questionnaire on codebook PDF pages 78–79 (printed pages 77–78) and
POST questionnaire on PDF pages 88–89 (printed pages 87–88) support all eight
current Q19–Q26 keys: `3, 2, 3, 3, 2, 4, 2, 2`. These identify five million
Americans barred from voting because of criminal convictions; gerrymandering
to ensure one party a majority; approximately 50% presidential-election turnout;
Australia's compulsory voting; selective-service registration for men aged
18–25; a majority of Electoral College votes; redistricting every ten years;
and Iowa/New Hampshire as the traditional earliest primary events. Both waves
use the same question meanings and choices. There are zero disagreements with
the author's `PRE_Q19COR:PRE_Q26COR` and `POST_Q19COR:POST_Q26COR` columns across
all 301 selected people and 4,816 item scores.

Using the source `weight`, the [event report](../data/btp-2007/reports/btp-2007-results.pdf),
PDF page 2, is reproduced: selective-service knowledge rises from 59.78086% to
81.07762% (reported 60% to 81%), and compulsory-voting knowledge rises from
12.56398% to 28.62159% (reported 13% to 29%). The eight-item mean rises from
43.91037% to 54.68859%, a 10.77822 percentage-point gain (reported 11 points).
Unweighted means differ because the report uses the source survey weights;
this is not evidence that the keys or selected cohort are wrong.

CaseID 2392, source row 295, group `4_6`, has all eight POST knowledge answers
coded 998 (Skipped). It nevertheless answers preceding POST questions and has
POST start/end timestamps. This is a skipped battery inside an observed
questionnaire, not an absent questionnaire; preserve the existing fixed-battery
zero-filled score. All 300 post-only controls have PRE knowledge code 999
(T2 only group), and none is included in the current participant export.

The full 1,501-row source and selected 301 people contain no nonresponse codes
in birth year, gender, race, education or political interest. Income is not
currently exported as a derived measure. Its code 15 is explicitly "Prefer
not to say" in `value-labels.csv`: 211 source records, including 49 selected
participants. A future income measure must treat 15 as missing rather than
as the highest income band. This does not require a change to current outputs.

**Remaining scope:** represent the other response arms and unexported
demographics in a broader schema while retaining raw codes. There is currently
no standalone BTP 2007 respondent recoder or `polardata` block; its participant
battery is built by the adapter in `R/poll_adapters.R`.

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
250-person knowledge battery in BTPGE-01 is not this aggregate sample. Historical
group high-income share used collapsed income `> 7`, while final individual
high income used `> 5`. X-13 now uses a single participant-median cutoff for both
flags and group shares. The group composition population remains documented
separately from the median reference population; normalization does not merge
those sample definitions.

### BTPGE-04: Baseline poll knowledge uses a larger calibration sample

The historical `t1knowlevel = 0.662015497684479` uses 645 complete baseline
batteries from all 2,826 raw records. System missingness removes incomplete
batteries; `w4b62 == -1` also remains missing, whereas refusals in the other eight
items score zero. That distinction excludes two otherwise available batteries.
The descriptor averages float32 nine-item scores, rounds to seven decimals,
and stores float32. Final respondent scoring zero-fills noncorrect answers
within an observed questionnaire; approved BTPGE-07 leaves absent entire
questionnaires missing.
Keys are 60=1, 61=2, 62/63/64=2, 65=4, 66=2, 68=4, 69=3;
`reagg.txt` explicitly repairs wave-F item 69. Consult the questionnaires,
calibration-universe definition and repair history before changing the descriptor.

### BTPGE-05: Zero correct post answers do not mean the post wave is absent (corrected)

The archived `merge_data_scripts/03_data.R` filters this poll on `t2know == 0`
as well as missing baseline attitude extremity. The 299-row selected source has
33 people with no answers to any of the nine post knowledge items. Their
pre-BTPGE-07 reconstructed fixed-denominator score was zero. The approved
absence correction now leaves that score missing; they remain outside this
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

### BTPGE-07: Explicitly absent questionnaires remain missing (corrected)

Both `survey.dta` and the ID-matched `raw-responses.dta` carry the completion
status `w4comsta`: 3 means follow-up only; 2 means baseline only (retained
`value-labels.csv`, lines 201–205). Thirteen of the 299 selected-source people
are follow-up only and have all 137 baseline questionnaire fields missing,
including their baseline interview dates. Thirty-three are baseline only and
have all 137 follow-up fields missing. These administrative flags independently
confirm absence of the questionnaire rather than merely absence of correct
answers. All 46 have `dop4part=1`; missing interviews do not prove nonattendance.

The former respondent scorer filled noncorrect items with zero without
separating an absent entire wave. Historical analysis exports therefore
contained 46 artificial zero wave scores, with response status `scored` and
`n_observed` missing. The user approved BTPGE-07: leave absent-wave item
correctness and whole-wave scores missing; require both waves for joint
knowledge and gains. Keep incorrect, don't-know and unanswered items within
an observed questionnaire on the existing fixed-denominator zero-scoring rule. The two
observed post zeros restored by BTPGE-05 (original IDs 552/585) remain zero.

The rebuilt respondent exports have these verified changes:

| Respondent measure | Values becoming missing |
|---|---:|
| Baseline knowledge | 13 |
| Post knowledge | 33 |
| Joint knowledge | 46 |
| Knowledge gain | 46 |
| Gain over joint knowledge | 46 |
| Log joint knowledge | 46 |
| High joint-knowledge flag | 46 |

This is 276 respondent-measure cells, 414 item cells (9 × 46), and 46 historical
analysis wave scores. All 46 people are already outside the 248-person analysis
panel; the separate 250-person CorSood battery has no absent questionnaires.
Neither panel membership nor the independently calibrated `t1knowlevel`
(645 complete batteries from 2,826 raw rows, value 0.662015497684479) changes.

Group and post/joint poll summaries currently use all 299 source people before
filtering. Removing artificial zeros changes baseline group means in 10 groups
(153 selected rows), joint group means in 14 groups (222 rows), and post group
means in 13 groups (206 rows). Joint and post poll means change for all 248
exported rows: joint mean 0.5882572 → 0.695213 and post mean
0.7186919 → 0.807853. Related issue-specific aliases carry the same definition
and must agree. The before/after build confirms the existing peer-gain helper
gives no selected-row changes; missing-aware leave-one-out denominators remain
a separate central formula decision. The comparison verifies exactly these
ten changed aggregate summary fields across the same 248 BTP records; every other aggregate field
and every other poll is identical. The whole aggregate retains 5,869 rows and
364 columns. Case-level summary changes are frozen in
`audit/corrections/btp-general-election-2004/approved_values.csv`.

Seven respondent definitions are versioned `@btpge-07-v2` and name
`w4comsta` as an availability input, not an extra knowledge item. Historical
analysis responses use `wave_absent` for the 414 absent item cells; the 46
wave scores and correct counts remain missing, with `n_observed=0`. Other
historical waves retain their existing unknown observed-answer count. The
helper rejects unknown completion codes and contradictions with observed
questionnaire fields; it ignores precomputed `_cor` columns, which themselves
retain artificial zeros for absent waves. Original source bytes are unchanged.
Group and poll formulas remain centralized and unchanged.

The `dp-learning` attendee panel is identical before and after this correction
(all 10,598 records). Its older `R/knowledge.R` reader takes `group_k1` from
`meant1know_ind`, so 153 BTP group-covariate cells change in that input. The
newer core reader recomputes group knowledge from the unchanged attendee panel.
No downstream models or papers were re-estimated; unchanged attendee inputs
do not establish unchanged estimates for readers of the corrected summaries.

### BTPGE-08: All six attitude placements reviewed against raw responses

The six historical indices are single self-placements, not the larger composites
in the newly preserved [authored Wave 4 memo](../data/btp-general-election-2004/codebooks/online-poll-indices-wave-4.pdf).
The [questionnaire](../data/btp-general-election-2004/questionnaires.pdf),
source value labels and original answers agree on these endpoints in both waves:

| Item | Score 0 | Score 1 |
| --- | --- | --- |
| Q42 services/taxes | Fewer services/lower taxes | More services/higher taxes |
| Q45 military intervention | Intervene on our own | Obtain international approval |
| Q48 trade | Pursue free trade | Protect US industries |
| Q51 rights/security | Ensure constitutional rights | Find every potential terrorist |
| Q54 health insurance | Government plan | Individuals/employers |
| Q57 marriage | Allow same-sex marriage | Constitutional prohibition |

`review_btp_attitudes.R` independently reconstructs all twelve wave/index series
from the original raw file joined by case ID, including the historical five-decimal
rounding and float32 storage. Every value and missingness pattern matches both the
maintained builder and selected-source historical fields. The 299 source people,
248-person aggregate selection and separate 250-person battery are preserved.
The twelve observed-answer counts are in `audit/btp-attitudes/index_summary.csv`.

Source codes -4 through -1, 9 and system missing remain missing attitudes. The
questionnaire prints “haven't thought much” in the eighth response position,
but the deposited value labels encode it as 9; code 8 is labeled blank and does
not occur in these selected raw fields. A printed response position is not a
source numeric code. The thirteen absent baselines and 33 absent exits have no
observed attitude scores. No midpoint is inserted for nonanswers or absent forms.

The memo includes broader multilateralism, trade, taxation and health composites.
Replacing the six historical placements with those composites would change the
construct, rather than repair a demonstrated coding error. The public event
report also uses a different approximately 200-person deliberator sample and
reports different items; its percentages do not establish a replacement key for
these six placements. No numerical attitude correction is indicated by this
review. BTPGE-06's contradictory attendance flag remains a separate documented
source conflict; this audit does not change the preserved membership decision.

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
changed for those 35 rows at the respondent-correction stage. The entropy
comparison is now superseded by the separately approved shared correction in
X-03. The leave-one-out helper still retains its historical denominator and
needs its own assessment. Case-level old and new values from BTPHE-01 are frozen in
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
rounding. At BTPHE-03, the poll descriptor changed from 0.277147799730301 to
0.337037593126297, while all 454 participant knowledge scores stayed unchanged.
The later BTPHE-04 correction below changes Q17 in both scoring universes.
The source answers and identities remain in `calibration-responses.parquet`.
The 20 `genvar` differences against the frozen historical deposit are
preexisting singular covariance exceptions documented in X-09, not effects of
this correction.

### BTPHE-04: Elementary-school achievement-gap answer key corrected

Both the [pre-questionnaire](../data/btp-health-education-2005/questionnaire-pre.pdf)
and [post-questionnaire](../data/btp-health-education-2005/questionnaire-post.pdf),
PDF page 4, ask Q17: “Has the gap between minority students and white students
in math and reading tests at the elementary school level been …?” The choices
are increasing the last few years, staying about the same, decreasing the last
few years, and couldn't say. The source value labels map these to codes 1, 2,
3 and 7, respectively. The former key credited code 1, increasing, in both
waves; the archived `btp05.R` does the same. The stored `q17r` and `q17postr`
correctness fields also credit only code 1. This discrepancy is inherited from
the original scoring, rather than introduced by the modernized script.

The poll's [education briefing](../data/btp-health-education-2005/briefing-materials/btp2005-education.pdf),
PDF page 2, discusses minority pupils catching up with white pupils in reading
and mathematics at the elementary-school level. Its next section also describes
the gap closing slightly according to recent studies. The population, subjects
and school level match Q17. The discussion disputes whether No Child Left Behind
caused the improvement; that causal disagreement does not reverse the stated
direction of the gap. Thus code 3, decreasing, is the supported answer from the
participant briefing. The [event results report](../data/btp-health-education-2005/reports/btp-health-education-results.pdf)
does not print Q17 correctness percentages or a separate answer key, so it
cannot independently settle this discrepancy. Its 360-person online cohort
attended at least three sessions; the maintained source includes all 454
attendees. Do not force report denominators onto the current sample.

| Q17 response | Baseline, 454 people | Departure, 454 people |
|---|---:|---:|
| Increasing, former keyed answer | 151 | 138 |
| Decreasing, approved keyed answer | 90 | 142 |
| Correctness cells that flip | 241 | 280 |

The approved correction changes only this key and flips 521 item cells across
345 distinct people. The six-item score mean moves from 37.481645% to 35.242291%
at baseline and from 41.005874% to 41.152717% at departure; mean gain moves from
3.524229 to 5.910426 percentage points. It retains the same 454-person cohort,
six-item denominator, missingness policy and other five keys. Group and poll
quantities are recalculated centrally after respondent scoring.

The separate 3,298-record calibration source has 933 increasing and 704
decreasing answers. Under its existing available-item scoring rule, changing
Q17 alone affects 1,637 calibration scores. Its poll descriptor moves from
0.337037593126297 (after BTPHE-03) to 0.32561150193214417. The available-item
rule, all-missing zero convention and historical float storage are unchanged
in this correction. Dependent individual, group and poll fields are covered
by the complete before/after build and the frozen case-level comparisons in
`audit/corrections/btp-health-education-2005/approved_values.csv`.

The user approved code 3 at both waves and in calibration. The shared
respondent scorer supplies the key to the calibration step; the item-level
key registry and canonical catalog also use code 3. Seven respondent
definitions and their dependent aggregate aliases are versioned
`@btphe-04-v2`; affected group and poll definitions use `btphe-04-v2`. Source
responses and deposited historical scored batteries remain unchanged, so their
old key is still available for comparison. No group or poll formula changes
are part of this correction.

The full output comparison confirms 1,304 changed respondent-measure values:

| Respondent measure | Changed values |
|---|---:|
| Baseline knowledge | 241 |
| Departure knowledge | 280 |
| Joint knowledge | 126 |
| Knowledge gain | 301 |
| Gain over joint knowledge | 218 |
| Log joint knowledge | 126 |
| High joint-knowledge flag | 12 |

Exactly 26 fields change in the historical aggregate: 12 individual aliases
and 14 centrally calculated knowledge summaries, gains and calibration fields.
The full aggregate keeps 5,869 rows and 364 columns. Every other field and every
other poll is identical. IDs, memberships, raw source responses and briefing
reading exports are byte-identical. `field_changes.csv` in the same correction
folder records changes against the original benchmark, including earlier gender
corrections; `approved_values.csv` preserves the original benchmark values.

Both historical and reconstructed Cor–Sood analysis representations contain
the same corrected Q17 responses: 241 baseline and 280 departure item and
wave-score changes in each representation. These are duplicate representations
of the same 454 people, not 908 different participants. Correct-count changes
follow the new key; observed-response counts and missingness do not change.
The committed `dp-learning` reader at `829face` still selects the same 10,598
people. Only BTP knowledge inputs change, for 345 people (241 baseline and 280
departure scores). No downstream models or papers were re-estimated.

### BTPHE-05: Correct four attitude labels; preserve all numeric definitions

A component-by-component review of both questionnaires, source code labels,
raw responses and the preserved [historical index script](../data/btp-health-education-2005/source-materials/historical-index-recoding.txt)
finds four misleading catalog labels. These are label corrections only:

| Historical label | Reviewed label | What is scored |
| --- | --- | --- |
| Charter Schools vs. Vouchers | Support for Charter Schools and Vouchers | Mean support for both Q7a charter schools and Q7b vouchers; neither item is reversed |
| Willing to Pay More For Better Health Coverage | Health Care Costs and Coverage | Mean importance of insurance cost, uninsured Americans and prescription costs (Q19a–c), plus willingness to pay more for wider coverage (Q23) |
| Quality of Medical Care | Importance of Improving Medical Care | Mean importance of improving medical errors, malpractice and quality for insured people (Q19d–f), not an assessment of current quality |
| No Child Left Behind | Opposition to No Child Left Behind | Q12 code 1 is strongly disapprove and scores 1; code 5 is strongly approve and scores 0 |

The remaining seven constructs were also reviewed: reform of the existing
school system (Q3, higher = reform); school funding (Q7c–f plus Q8f, higher =
support/importance); standardized testing (Q4/Q5, higher = more testing);
local control of testing (Q6, higher = local); government involvement (Q24a/f,
higher = support for single payer/Medicare–Medicaid funding); employer coverage
(Q24b, higher = support); individual coverage (Q24c, higher = support).
The irregular post field names `q5post_m`, `q19post` and `q19pos_a` through
`q19pos_e` match the question labels and were checked individually.

All 22 wave/index series reproduce exactly from independently specified component
formulas, including the original stored values and missingness. The 454-person
sample is unchanged. All respondents have substantial observed questionnaire
content in both waves: at least 18 of the 23 attitude input fields are nonmissing.
An isolated nonanswer is omitted from its attitude mean; an entirely missing
index stays missing. There is no fixed-denominator missing-as-zero attitude
rule. `alpha`'s sequential float32 addition is retained, with division by the
number of observed components, not the nominal number of questions.

The public review script `scripts/review_btp_attitudes.R` produces per-index
counts and means, component-denominator counts, raw-response frequencies,
alternative-definition comparisons and the report comparisons below in
`audit/btp-attitudes/`. Of the multi-item scores, 36 baseline and 24 post funding
indices use fewer than five components; 40 baseline and 31 post cost/coverage
indices use fewer than four. These are the documented available-item means,
not newly discovered coding errors.

Rejected candidate: the printed Q4 questionnaire lists “too much” first, but
actual numeric labels are 1 = not enough, 2 = about right, 3 = too much. The
current reversal therefore correctly aligns Q4 with Q5's higher = more testing.
Q24 likewise has numeric agreement codes opposite to the printed option order.
Changing those formulas using printed list positions would introduce errors.

BTPHE-02 remains an authored construct choice: Q8f measures importance of school
funding, whereas Q7c–f measure support for tax-financed proposals. Omitting Q8f
would change 366 baseline and 371 post values and make three additional scores
missing in each wave. Means would change .65371145 to .61448633 before and
.65306107 to .62244444 after. This is a narrower four-item construct, not a
verified correction; preserve the original five-item definition pending a
substantive decision. The approved Q17 knowledge correction is untouched.

### BTPHE-06: Preserve the wider source and identify the report-sample gap

The public [complete source projection](../data/btp-health-education-2005/source-responses.parquet)
retains all 3,298 rows from `data/BTP/2005/data/2005alice.dta`, original SHA256
`fdff148b90c33fdb98d122b281f3077495564cec0bcabbfee5424b69fc172c95`.
It preserves every source column except `username`, `city` and `zip`, and adds
`source_row` as a stable row identifier (735 columns total). Questionnaire
verbatim responses Q44/Q45 are retained. The accompanying variable dictionary and existing `value-labels.csv` preserve
source coding. The full-source value labels are byte-identical to the existing
file, which is reused rather than duplicated. Original case IDs contain 202 missing entries
and one repeated nonmissing ID, so they are not a unique full-file row key.
No source rows are deduplicated. The selected `filter == 1` subset contains exactly
454 unique IDs; all current participant attitude inputs match it exactly by ID.

The earlier `calibration-responses.parquet` has only eight columns: row ID,
case ID and six baseline knowledge questions. It cannot support the attitude,
attendance or report-sample checks now made reproducible from the wider source.
The new source does not replace the selected respondent build or expand any
analysis sample.

The [event report](../data/btp-health-education-2005/reports/btp-health-education-results.pdf),
p. 4, describes 360 participants attending at least three discussions. The
wider source has exactly 360 people with `stotal >= 3`, all assigned treatment;
only 321 belong to the selected 454-person dataset. The other 39 have missing
`groupnum`, despite observed questionnaire answers and recorded attendance.
Thus the report and current
aggregate have different selection rules. Even the full-source 360 do not
reproduce all reported percentages: NCLB approval is 29.44% before and 29.44%
after (report 39% and 31%); local control of testing is 27.22% and 33.33%
(report 31% and 38%). The 454-person sample gives 27.75% and 28.63% NCLB
approval. Simply selecting three-session attendees does not close this gap.

These comparisons retain don't-know responses in the denominator and also show
results excluding system missingness. No survey-weight field is present in the
recovered full file. A report-era extract, weighting file or author analysis
specification is needed to establish the remaining difference. Do not change
source answers, reverse established labels, or silently substitute a new sample
to force report agreement. The report bridge is unresolved; the independent
questionnaire-to-current-score review above is complete for all eleven indices.


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

The retained [questionnaires.pdf](../data/btp-online-primaries-2004/questionnaires.pdf)
contains the seven Q43–Q49 factual questions used in the existing key; this
does not identify ID 908's final discussion room. **Next check:** find original
assignment/session logs, especially for ID 908. Keep the 328-person knowledge
sample intact. Preserve its unknown
group and the 217-person aggregate until group membership can be established
or a separately reviewed missing-group policy is chosen. Keep invitee
assignment, attendance and analytic inclusion distinct.

### BTPOP-02: Absent follow-up forms are not zero knowledge (corrected)

The selected-wave tables previously assigned zero post knowledge and `panel = TRUE`
to 43 of the 328 experimental records whose follow-up form is absent. In
`data/btp-online-primaries-2004/survey.parquet`, all 43 have `compf1 = 2`
(no completed February follow-up; `variables.csv` and `value-labels.csv`) and no
answers across any of the 115 `f1q` questionnaire fields. This is evidence of
an absent form, not an inference from blank knowledge items.

The shared presence step now makes these 43 selected post scores missing and
labels their 301 item cells `wave_absent`, matching the existing phase tables.
Their raw records and attendance are retained: 11 attended a session and 32 did
not. The selected paired cohort falls from 328 to 285, including 239 attendees
instead of 250. Its unweighted mean gain changes from 0.027439 to 0.092231;
among attendees it changes from 0.092571 to 0.110580. These are changes in the
observed comparison sample, not treatment-effect estimates. Completed forms
with unanswered knowledge items still receive zero for those items. Unknown
form presence does not become verified absence. This does not resolve the
missing discussion group in BTPOP-01 or change the historical aggregate sample.

## Bulgaria Crime 2002 — bulgaria-crime-2002

**BGC-01 — poll identity is a provenance issue.** The 278-person, seven-item
battery belongs to the October 2002 crime poll, not the distinct 2007 Roma-policy
poll. Current item scores and gender match, with 17 groups. The source archive
contains material for more than one event and must not receive a blanket poll ID.

The retained [questionnaire.pdf](../data/bulgaria-crime-2002/questionnaire.pdf)
asks about crime and includes the seven true/false items. The
[knowledge-index.pdf](../data/bulgaria-crime-2002/knowledge-index.pdf) prints
278 observations and means .4316547 before and .524666 after. The
[event report](../data/bulgaria-crime-2002/reports/bulgaria-crime-results.pdf)
names the Fighting Crime in Bulgaria event on October 12–13, 2002. These
independent materials resolve the event identity. Preserve the separate 2007
registry entry.

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

**BGC-03 — income factor positions and summary vintage; corrected.** The
historical reader maps income codes 1–6 to factor positions 2–7 and makes code
0 (no answer) missing. The final merge marked positions greater than 2 as
individual `highinc`, while the earlier group `phighinc` calculation used
positions greater than 4. [Questionnaire Q10](../data/bulgaria-crime-2002/questionnaire.pdf)
lists raw code 1 as under 50 BGN, 2 as 50–100, 3 as 100–150, 4 as 150–200,
5 as 200–300, and 6 as above 300 BGN per household member per month. The
later individual cutoff therefore included raw codes 2–6, including 50–100;
the group cutoff included only codes 4–6, starting at 150–200. The source has
278 people: five no answers, 193 above the later individual cutoff, and 28
above the earlier group cutoff. The stored `phighinc` in all 17 groups matches
the earlier rule. The user's initial approval selected raw codes 4–6 as one
common individual/group definition. That correction changed 165 individual
flags from 1 to 0, preserved all five missing values, and left `phighinc`
unchanged. The later X-13 approval supersedes that fixed cutoff with the
empirical participant median. It selects 84 people as high income, compared
with the historical 193 and the earlier corrected 28; 109 flags differ from
the historical benchmark. Group shares use the same median-based individual
flags, with missingness unchanged. The earlier approval snapshot remains in
`audit/corrections/bulgaria-crime-2002/approved_values.csv`.

**BGC-04 — index sets and reconstruction coverage.** All 51 respondent targets
match all 278 source participants, including missingness, at 1e-10 tolerance.
Historical extremity includes the two-item drug-legalization index alongside the
12 exported attitude indices; dispersion uses only those 12. The death-penalty
item historically mapped 1→1, 2→.75, 3→.5, 4→.25, never reaching zero.
The questionnaire's Q20 asks agreement that the
death penalty is the only appropriate punishment for certain crimes; the source
stores this as `q19`/`q19p`, with 1 = strongly agree through 4 = strongly
disagree. The stored `t1q19r`/`t2q19r` labels call the result a 0–1 scale, but
all 243/255 substantive source answers exactly match 1/.75/.5/.25. The
approved BGC-04 correction maps the four ordered answers to equally spaced
endpoints (1, 2/3, 1/3, 0) in both waves. It changes 131 baseline and 170
departure respondent scores, lowering the observed-item means from .737654 to
.650206 and from .617647 to .490196, respectively. Missingness and the
278-person sample are unchanged. The baseline correction also changes 131
respondent extremity scores and, through the central group formulas, all 278
`meanxtreme` and `avgsd` values and 263 `genvar` values. Case-level before/after
values for the six affected wide fields are recorded in
[`audit/corrections/bulgaria-crime-2002/approved_values.csv`](../audit/corrections/bulgaria-crime-2002/approved_values.csv).
The historical mapping is preserved there for review. Knowledge remains the
seven-item fixed-denominator battery, with nonanswers scoring zero.
The mean across Bulgaria groups of the death-penalty post-minus-baseline
index moves from −.11919 to −.15892; the same 17 groups remain. A paired run
of dp-learning's main mixed model on the same 5,728 observations changes its
fixed-effect estimates by at most .000855 (the extremity coefficient moves
from −.075410 to −.074556). Downstream consumers of the two attitude columns
or the three derived group fields will see the corrected values.

**BGC-05 — six archived attitude labels are shifted (catalog corrected).**
The two retained cross-poll index files pair six Bulgaria source fields with
names belonging to different questions. Both call source `q10_3` “Legalizing
Drugs,” but the [questionnaire](../data/bulgaria-crime-2002/questionnaire.pdf)
Q10(3) and the source variable label ask about **penalties for drug taking**.
Source `q16` asks whether people should take the law into their own hands;
`q21`, `q22` and `q23` ask about institutional change, investigation-service
independence and the place of prosecution. Source `q19` asks about the death
penalty. The questionnaire's printed question numbers differ from some source
field numbers, so the wording and source variable labels establish these
matches, not the number alone.

The generated `attitude-indices` catalog now uses those six topic names in
the same order as the source fields. The source files in `data/shared/` retain
their original bytes as historical evidence. This is a label correction only:
the 129 index rows, field mappings, respondent answers, scores and aggregate
numbers were unchanged by that label edit. The separate BGC-04 scale correction
was subsequently approved and changes the values described above.

### BGC-06: Unlabelled ethnicity remains unknown (approved correction)

The [questionnaire](../data/bulgaria-crime-2002/questionnaire.pdf), Q7 on PDF
page 2, asks ethnicity and offers four responses: 1 Bulgarian, 2 Turkish,
3 Roma and 4 Other. The deposited `value-labels.csv` labels only these four
codes. Source IDs 1614 and 1018, rows 277 and 278, instead have `ethnos=0`.
The present and original `Bulgaria.R` scorers use `ethnos != 1`, making both
people minority=1. An unlabelled code outside the offered categories does
not establish an observed non-Bulgarian ethnicity.

This is not a diagnosed refusal code: the original registered SPSS file has
neither `na_values` nor `na_range` for ethnicity. Its checksum is the same as
the public exact-copy `survey.sav`; zero was not introduced by the modernized
pipeline. Independent original before- and after-discussion SPSS and Stata
files also retain zero for these two people. The original script has no
explicit zero-to-ethnicity instruction or explanation of these final two
records. Other demographics are observed: ID 1614 is female, age 42, with
high-school education; ID 1018 is female, age 45, with primary education.

Do not fill the missing meaning from a national-file ID match. The national
1,035-person file contains an ID 1018 with age 62, high-school education,
a different income band and retired status. Those differences mean an ID
match alone is not a validated identity bridge. ID 1614 is absent from that
national file. The attendee-return sources are the relevant evidence here.

**Approved correction:** leave the two derived minority flags missing, preserve
raw zero, and leave valid Other code 4 unchanged. This recognizes unknown
ethnicity without inventing which unrecorded answer was given. All 278 people
and group memberships remain. Under the existing central mean helper, groups
5310 and 5316, each containing 17 people, move from 3/17 minority
(0.1764705882352941) to 2 known minorities among 16 observed ethnicities
(0.125). Two person flags and 34 repeated group shares change.

Before the separately approved shared correction, the historical entropy
helper used the full group denominator
for the binary complement, so the BGC-06 respondent correction alone leaves its minority component at
0.672294817075638 in both groups. That is not evidence that unknown ethnicity
was incorporated correctly into diversity by the inherited formula. The
separately approved shared correction in X-03 handles entropy centrally; no
formula is patched inside this poll's recode. The user approved the respondent correction on 2026-09-27. It changes
two person flags and 34 group-share cells while preserving all 278 people,
raw zeros and every prior correction. The shared entropy correction is a
separate, explicitly authorized change; its comparisons follow in X-03.

### BGC-08: Complete main attitude and summary-battery review

All twelve main indices at both waves were independently reconstructed from
raw responses for the same 278 people in 17 groups, matching every value and
missingness pattern. The full extremity battery additionally includes drug
legalization (Q10_1/Q10_2); its reconstruction also matches. The review covered
tougher punishment (Q8_3:6), the five-item Version E civil-liberties index,
media violence (Q8_7), economic causes (Q8_1), rehabilitation (Q8_8), faster
trials (Q8_11), drug penalties (Q10_3), vigilantism (Q16), institutional change
(Q21), independent investigation (Q22), prosecutorial accountability (Q23)
and the already corrected death-penalty scale (Q19).

The retained [Version 7 index memo](../data/bulgaria-crime-2002/codebooks/bulgaria-indices-v7.pdf)
supplies paired numerical benchmarks and deliberate categorical choices. The
original Word document is retained alongside its PDF preview. In particular Q23 combines
executive and judicial accountability at 0 and Parliament at 1; it is not an
accidental uneven ordinal scale. The drug-legalization component reproduces the
memo's 0.1087786 → 0.1603053 paired means (262 people), despite its misleading
“more restrictions” heading: the actual questions and scoring favor legalization.
Q16 runs toward *opposition* to taking the law into one's own hands; its neutral
topic label must not be interpreted as the direction of increasing scores.

The retained English questionnaires are annotated drafts whose numbering and
four-category agreement layout differ from the final five-category source.
They establish wording, but directly substituting their printed numbers for the
final source codes would introduce errors. The known Version E versus Version D
civil-liberties choice (BGC-02) remains preserved; the specific Version E source
syntax was not recovered. No further numerical change is justified by this
review. Baseline and exit retain the already verified pre-invitation and
post-event timing; later sampling or group formulas are not redefined here.

## California 2011 — california-whats-next-2011

### CA-01: The available source and deposited battery use different samples

The archived `ca_referendum.R` filters `part` to observed values and then
`t2t3filter == 1`. The available 472-row merged source has 412 people with
`part == 1`, matching the [event report](../data/california-whats-next-2011/reports/california-report.pdf)
and [Stanford event record](https://deliberation.stanford.edu/news/people-whats-next-california).
The second filter keeps 396 people, all with unique `id`; the other 16 have
`t2t3filter` missing even though each has at least one departure knowledge
answer. The separate deposited `ca.csv` battery has 401 rows, but rows 397–401
are entirely missing across all 11 columns. They are blank padding, not five
additional people. The first 396 deposited rows align in order with the 396
selected source records: gender and all ten item values and missingness agree
except for the two already documented Senate code-3 responses in CA-02. The
comparison strips only this verified blank tail; the original deposit remains
unchanged and retains its 401-row provenance. The 16 excluded source records
all lack `t2_ParticipantNumber`, `t2_GroupNumber`, and answers to all 116 `t2q*`
arrival fields, while each has 104–132 observed `t3q*` departure fields.
Eleven answered all five departure knowledge items. These 16 explain the gap
between the report's 412 attendees and the 396 paired arrival/departure source
records. Their missing arrival wave and group identity explain the historical
`t2t3filter`; they are not evidence that the deposit contains those records.
Retain the 396-person group aggregate. A separate T1/T3 respondent analysis
could include some of the 16 only under an explicit sample and missing-group
policy.

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
After removing CA-01's five all-missing tail rows for comparison only, the
396 source people align in order with the deposit. Exactly two item cells differ:
source IDs 321 and 438 answered departure Senate code 3, scored incorrect in
the maintained build and missing in the deposit. Both fixed-denominator scores
are unchanged. The audit now reports these item differences directly.

### CA-03: The report's eight-question knowledge result is a different measure

The [event report](../data/california-whats-next-2011/reports/california-report.pdf)
reports eight arrival/departure questions (source `t2q27:t2q34` and
`t3q27:t3q34`). The [departure questionnaire](../data/california-whats-next-2011/questionnaire-post.pdf)
supplies their wording and response choices: Senate majority, Assembly
majority, legislative majority for a constitutional amendment, legislative
majority for a tax increase, who may sign a ballot-measure petition, the state
with most residents per legislator, the state with highest total tax burden,
and the largest category in Governor Brown's proposed budget. The correct
source codes are 1, 1, 2, 2, 3, 1, 2, 2 at each wave. On 417 source records
(`part == 1` for 412, plus five with an arrival participant number but missing
`part` and `id`), their item-correct counts are 316, 290, 258, 253, 263, 259,
128, 150 at arrival and 355, 334, 339, 362, 292, 330, 206, 307 at departure.
These exactly reproduce the report's 16 item counts. Dividing the totals by
417 × 8 gives 57.5% and 75.7% when rounded as in the report, an 18.2-point
increase. This identifies a source cohort that reproduces the published table;
the retained material does not explain why its implied denominator is 417
while the report and event record describe 412 attendees. The five extra
records have arrival roster numbers 131, 180, 388, 398, and 484, with no `id`
or observed participation flag; together they contribute 17 correct arrival
answers and no correct departure answers. All five have no answers across
all 132 departure questionnaire fields and no departure roster or group number.
Following the user's participation rule, they are nonparticipants, not
participants with zero departure knowledge. They are excluded from the new
participant measure. `audit/california_report_reproduction.csv` preserves the
417-record arithmetic solely to explain the published table.

The maintained five-item battery instead compares phone T1 `q37:q41` with
departure `t3q27:t3q31` for 396 retained people, of whom 386 have
observed telephone and departure forms (CA-04). T1's additional factual
questions differ from the arrival/departure items 32–34. The eight-item
arrival/departure result is therefore a separate measure and should not be
substituted into the historical five-item or 396-person group aggregate. It
is now exported as `california_knowledge_responses` and
`california_knowledge_scores` for the 412 flagged participants, retaining
source rows, full-questionnaire wave availability, and paired membership. The
16 participants without arrival questionnaires have missing arrival scores;
absence of an entire questionnaire is not scored as incorrect answers. The
396 with both questionnaires score 1,900/3,168 (60.0%) at arrival and
2,430/3,168 (76.7%) at departure, a 16.7-point increase. All 412 have some
filled departure questionnaire fields; two have no recorded answers in the
eight-item battery, but are not confused with the five wholly absent departure
questionnaires. Within an observed questionnaire, item nonresponse retains the
fixed-denominator zero scoring convention. The item keys and exact departure
wording are in `metadata/california_knowledge_items.csv`.

### CA-04: Preserve arrival/exit respondents with no telephone baseline (corrected)

Ten of the 396 retained respondents have no telephone baseline form: source IDs
599, 647, 711, 722, 724, 729, 872, 882, 887 and 888. In
`data/california-whats-next-2011/survey.parquet`, all 70 baseline questionnaire
fields and the baseline interview date and attendance fields are missing for
these people. Each has `fromt2t3 = 1`, `t2t3filter = 1` and `part = 1`, together
with answered arrival and departure forms. They are different from the five
all-missing deposited tail rows in CA-01.

The shared presence step now makes their ten selected baseline scores missing
and labels the corresponding 50 item cells `wave_absent`. The selected
telephone-to-exit paired cohort falls from 396 to 386; its unweighted mean gain
changes from 0.213636 to 0.200000. All 396 people and their attendance remain,
and these ten remain available for arrival-to-exit comparisons. No raw answer,
item key, historical aggregate sample, or observed-form blank-item score changes.

### CA-05: Preserve the single out-of-range departure knowledge code

Source row 447, ID 526, has `t3q33 = 0`. The departure questionnaire Q33
(PDF pp.17–18) asks which state has the highest total tax burden and offers
California, New York, Massachusetts, Oregon and “Couldn't say,” coded1:5.
Zero is outside every offered option. The person's arrival answer is2 and
other departure answers establish an observed form, but neither permits
reconstructing the intended answer. Preserve raw0 and map correctness to missing under the user-approved global
invalid-response rule; classify it `invalid_response`, with no trichotomy category and no fabricated
source label. `metadata/knowledge_response_codes.csv` records the field-specific
reason and evidence. The separate eight-item report-battery export also maps this invalid code to
missing correctness. Fixed-denominator knowledge scores, attendance and all
samples are unchanged.

## Europolis 2009 — europolis-2009

**EURO-01 — distributional parity is not a person link.** `GROUP_T1BIS == 1`
selects 348 of 4,384 source rows. `UniqueID` and `SMALL_GROUPw3` supply people and
25 groups. The six-item pre/post batteries plus gender exactly match the deposit
as a multiset, including repeated-pattern multiplicities; their order does not.
Sorting or matching identical score profiles cannot prove respondent identity.

The retained [codebook.txt](../data/europolis-2009/codebook.txt) describes the
source waves and their response labels, but contains no deposited-battery row
identifier. The archive's `eu_2009/questionnaires/T3 Questionnaires/T3 questionnaire_EN.doc`
was misfiled: it is a content duplicate of the
[Tomorrow's Europe 2007 post questionnaire](../data/tomorrows-europe-2007/questionnaire-post.pdf),
not a different Europolis draft. Its Q43–Q50 ask about briefing, sessions and
event evaluation, while the Europolis source `V3Q43`–`V3Q50` and published
knowledge report describe EU institutions, immigration and energy facts.

The duplicate DOC was created October 8, 2007 and modified October 13, 2007.
The correct-folder copy was subsequently saved in February 2008; both report
an October 13, 2007 printing date. Their binary hashes differ, but their Word
main-text streams are identical (31,606 characters), both have no comments,
footnotes, endnotes or textboxes, and the only header-text difference is a
cached page number (21 versus 9). The two 21-page PDFs have identical page
content streams and image bytes. The duplicate Europolis DOC and PDF were
removed after this comparison; the canonical Tomorrow's Europe pair remains.
[The existing source-findings register](../metadata/source_findings.csv), row
`europolis-misfiled-questionnaire`, retains the archive path and removed hashes;
Git retains the removed files.

The misfiled form cannot validate Europolis answers or supply a person link.
**Next check:** find the fielded Europolis questionnaire and original exports
or scripts with persistent IDs. Preserve 997/998/999 as source missing reasons.
Do not append deposited rows to attitudes using an arbitrary permutation.
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
rounds to two decimals; historical higher education used `> 0.57`. X-13 now
uses the empirical participant median, also 0.57 for this cohort. It is not a four-category
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


### EURO-05: Published knowledge results mostly reproduce; three baseline cells do not

The [Europolis research paper](../data/europolis-2009/papers/europolis-research-paper.pdf)
(Table 2, printed p. 11) and the [event knowledge report](../data/europolis-2009/reports/europolis-knowledge.pdf)
(p. 1) define six knowledge items asked at the initial interview (Q43, Q44,
Q46, Q47, Q49, Q50) and three first asked on arrival (Q45, Q48, Q51). The
source has 348 participants (`GROUP_T1BIS == 1`), matching the paper's
participant count. Score a correct answer as one and every other response,
including 997–999, as zero, with a fixed six- or nine-item denominator. This
matches the report's explicit inclusion of declined answers among incorrect
responses. The archived `eu_2009.R` script and maintained respondent build
use the six common items at baseline and departure.

| Index | Source extract, percent | Published, percent |
| --- | ---: | ---: |
| Six-item initial interview | 19.7318 | 19.8 |
| Six-item arrival | 27.7778 | 27.8 |
| Six-item departure | 36.3027 | 36.3 |
| Nine-item arrival | 29.6296 | 29.6 |
| Nine-item departure | 37.8033 | 37.8 |

The published initial-interview Q44, Q47 and Q50 percentages imply respectively
41, 77 and 159 correct answers out of 348. This source file has 40, 76 and
160. The other three initial-interview items round to the published values.
The three one-answer differences net to one more correct response in the
publication, which is sufficient to account for 19.8% versus 19.7% after
rounding the six-item index. The report's departure Q48 value is 56.6%,
matching 197/348 in the source; the paper prints 56.7%. The source does not
contain an exact publication-era extract or a documented account of those
small differences. Do not recode individual answers to force the published
means. A historical extract, item tabulations or author analysis code would
be needed to establish whether these are source-version differences or
reporting errors.

The [paper appendix](../data/europolis-2009/design/europolis-research-appendix.pdf)
(appendix A, Table 2) also reports baseline/departure climate question Q21
means of .587/.671 using paired observations. Among the 334 participants
with both responses observed, the maintained Q21 orientation gives
.58653/.67066, reproducing those figures after rounding. This checks the
Q21 direction but does not justify replacing the historical one-item climate
measure with the paper's two-item climate index. Likewise the paper's
immigration index contains nine items; the historical aggregate uses Q11_1.
The published means validate question selection and scoring at the sample
level, not a respondent-order link for the anonymous battery in EURO-01.

### EURO-06: Birth year 1900 is an unsupported age (corrected)

**Status: approved by the user on 2026-09-26 and corrected upstream.** The
[source codebook](../data/europolis-2009/codebook.txt) labels `age1` as year
of birth and records seven values of 1900 among 4,384 people, but does not
declare a missing code for this field. There are no years from 1901 through
1913; the next earliest is 1914. In 2009, the seven 1900 entries become age
109, an implausible concentration beyond the rest of the observed age range.
The correction treats these seven birth years as unknown in the *derived age*
measure, while leaving the raw answers and education recode unchanged. One
affected person is in the 348-person historical aggregate: source `UniqueID`
300005619, exported case 71300005619, group 7125. Their `ppage` becomes
missing and that 17-person group's `meanage` falls from 51.70588 to 48.125
(16 observed ages). The sample and all other respondent fields remain fixed.
The historical script's `2009 - age1` calculation and the codebook's failure
to mark 1900 missing are recorded as contrary evidence; no individual birth
year is inferred from other demographics.
The [approved age values](../audit/corrections/europolis-2009/approved_age_values.csv)
record all 348 respondent ages and group means. Parity checks find one new
missing age and 17 changed group-mean cells, with zero unexplained differences.
The current `dp-learning` analysis frame already excludes ages above 100, so
its paired main model is unchanged at 5,850 observations and identical
coefficients when this correction is applied on top of ZG-04. This supplies
evidence to remove that downstream age filter after the upstream correction
is adopted. `dp-distortions` does not use these fields; `dp-deliberately`
imports the newly missing age.

### EURO-07: Make both attitude labels match the numeric direction

The climate item Q21 places combating climate change at 0 and protecting the
economy at 10. The maintained `(10 - response) / 10` score is therefore higher
for prioritizing climate action. Rename “Combatting Climate Change” to
“Priority for Combating Climate Change.” Immigration Q11_1 asks about stronger
border controls: code 1 favors them strongly and code 5 opposes them strongly.
The maintained `(response - 1) / 4` score is higher for opposition. Rename
“Stricter Immigration Control” to “Opposition to Stronger Border Controls.”
These are factual label corrections with no numerical reversal.

The retained source codebook, SAV labels and event attitude report Q11/Q21 agree
on these meanings. Independent reconstruction checks all four wave/index series
for all 4,384 source rows, the 348 historical participants and their baseline
extremity, with no value or missingness discrepancies. Missing codes 997–999
remain explicit nonresponse reasons. Results are retained in
`audit/btp-attitudes/europolis_index_checks.csv`.

As documented in EURO-05, the appendix's 334 paired Q21 observations reproduce
.587/.671 after rounding (.58652695/.67065868). The standalone attitude report
uses the opposite climate orientation and gives .414/.329; the paired-data
complements are .41347305/.32934132. For immigration the report gives support
means .712/.656, versus paired-data support .71716418/.65597015. These small
report/source differences do not establish different respondent recodes. Keep
current values and the separate fielded-questionnaire gap in EURO-01; neither a
label repair nor source-value parity establishes that the misfiled form is valid.


## National Issues Convention 1996 — nic-1996

### NIC-11: Use immediate exit in the analysis pair and retain delayed follow-up

**Approved and corrected (September 28, 2026).** The historical aggregate's
`t2know` uses source Time 3, not immediate exit. The codebook opening paragraphs
identify source Time 1 as the initial November 1995–January 1996 household survey,
Time 2 as the event questionnaire plus contemporaneous nonattendee telephone
interviews, and Time 3 as a separate follow-up. The NIC paper (PDF p. 19,
printed p. 18) places that last interview about ten months after the January
1996 event, following the presidential election. Source Time 2 is **not arrival**.

The canonical analysis item and score tables now use source Time 1/2 for their
initial/exit pair and retain source Time 3 separately. Canonical phase labels
remain t0/t2/t3. The same eleven items, existing correctness rules, source-row
identity bridge and respondent IDs are preserved. The aggregate `polardata`
and its historical respondent outputs remain unchanged; its historical pair
continues to mean source Time 1/3 and must not be described as immediate exit.
The eight-item Cor–Sood source remains a separate battery.

For source Time 3, `PART3` establishes whether the interview occurred. The 524
of 911 source records without that interview now have missing analysis scores,
not zero. This includes 79 of the 466 attendees. Individual unanswered items
within an observed interview continue to score zero. Raw answers and literal
source columns accompany all three eleven-item batteries in the analysis table.

Among the 466 historical attendees, the documented phase-presence rules identify
461 observed baseline questionnaires and 460 observed exit questionnaires;
456 have both. The other ten must not supply a zero for an unobserved interview.
The dp-learning main estimate now uses these 456 pairs. Retention uses the 383
attendees with observed baseline, exit and delayed follow-up, holding people and
questions fixed across all three measurements. This addresses composition changes
within that comparison, not possible differences between returners and attriters.
All non-NIC analysis rows are unchanged.


**NIC-01 — one source-scoped fallback ID and battery definition.** `PART == 1`
selects 466 of 911 records and `RGROUP2` identifies 30 groups. One attendee lacks
`CASEID` and retains a source-row fallback. Eight-item knowledge and gender match
the deposit. A larger aggregate battery is a different measurement definition;
matching poll names does not authorize a person-level join across those scores.

The missing `CASEID` also persists in the original 911-row
`Master_nic_123.sav`, `Data_revised/nic123_r.sav`, `nic123_2_r.sav`, and the
codebook's corrected-date `iaqdate.sav` in the archived NIC source collection.
None supplies a transferable ID for that attendee. The fallback identifies a
row in this source only; the eight-item deposit remains anonymously ordered.
This closes the candidate ID recovery from those archived exports without
inventing a cross-file match. Retain raw floating-point codes while using the
documented tolerance for integer lookup. The eleven-item distinction is NIC-02.

**NIC-02 — eleven-item historical battery reconstructed separately.** The
historical `polardata` battery includes three percentage questions in addition to
the eight closed/placement items. The codebook explicitly defines inclusive
correct ranges: WEDLOCK 25–40, AFDC 1–10, and UNEMP 5–10, in each of three
waves (codebook lines 4916–5668). Recomputing these from raw responses matches
every nonmissing stored correctness code across all 911 source records.
The historical selected baseline/post scores use source waves 1/3. Source wave 2
is immediate exit, and source wave 3 is a ten-month follow-up; the older
arrival label was incorrect (see X-02). Missing
answers score zero with a fixed denominator of 11. The existing eight-item
knowledge outputs retain their separate definition. SPEND2 code 9 is documented
as missing (line 5545); SPDRUG2 code 9 is likewise missing (line 3635).

The [NIC paper](../data/nic-1996/papers/nic-paper.pdf) Table 4 (printed
p. 29) provides a third definition to keep distinct: its "Information
Summary" reproduces from the **nine factual items**, excluding the two party
placements. The maintained source recodes give 0.433476 at baseline and
0.518598 at immediate exit for all 466 participants, and 0.551536 at follow-up for
the 387 participants with `PART3 == 1`; the paper reports .43, .52 and .55.
The eleven-item means for those same wave samples are 0.465275, 0.546820 and
0.574818. The published summary's nine-item construction is inferred from
these exact comparisons; the paper does not supply its analysis code. All
nine baseline factual-item percentages round to the paper's Table 4 values,
including the historically scored Bosnia item discussed in NIC-06.

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

The source anomalies noted during NIC-03 have since been reviewed and
corrected as NIC-08 below. The original NIC-03 comparison files and script
reproduce the prior century correction; their candidate values precede NIC-08.

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

The same historical script mixed source T2 answers for the first six spending
items with baseline foreign aid, welfare and Social Security. NIC-09 subsequently
corrected that separate definition after user approval, using all nine source
T2 answers. NIC-11 establishes that T2 is immediate exit, not arrival. Those
corrections are distinct from the earlier age proposal documented here.

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

### NIC-05: Shared peer-opportunity ceiling convention

**Status: user clarified the estimand; shared correction adopted.** The measure
is opportunity to learn from peers on questions the respondent missed. The user
specified zero when the respondent already knows every scored item, as well as
when peers know none of the missed items. The earlier proposal to treat NIC's
zero as an error and replace it with missing is superseded: a conditional mean
over no missed items is undefined, but zero is the selected substantive
convention for this opportunity measure.

The original inconsistency arose from floating-point storage. Nine NIC factual
indicators use approximately `1 + 1e-11` for correct answers. Their joint score
slightly exceeds one for CASEID 10013620 in group 3 (source row 824), giving zero
divided by a tiny negative number rather than `0/0`. This is `grpgain2`, using
source T2 immediate exit and T3 follow-up; it is not an observed knowledge gain.
The historical zero now agrees with the explicit convention and stays zero.

Across 21 reconstructed polls and 24 implemented wave-pair definitions, 108
people have the all-correct pattern. The central rule changes missing measures
for 107 people across 12 polls to zero; NIC's one value stays zero. Counting
legacy copies and logarithms, 315 cells change. All non-ceiling values, individual
knowledge scores, source answers, group assignments and samples are unchanged.
An absent questionnaire, unavailable battery or missing peer group remains
missing. A valid peer group must contain another respondent. The rule identifies
the ceiling from the observed item matrix, allowing only the documented tiny
binary-storage offset, rather than guessing from an aggregate score near one.

The existing log transformation retains its 0.0001 floor, so new zero opportunity
values have log value −9.210340372. This is a legacy transformation convention,
not a claim that the natural logarithm of zero is finite. Typed measure names
now say peer learning opportunity and identify the exclusion of the focal
respondent; definition version is `peer-opportunity-v2`.
The [exact comparison](../audit/corrections/shared-peer-opportunity/approved_values.csv)
separates frozen historical, previously corrected and newly approved values.
`Rscript scripts/review_peer_opportunity.R` checks all other reconstructed fields
for exact equality with the ceiling rule disabled.

### NIC-06: Baseline Bosnia answer is date-dependent in the stated rule

**Disposition (2026-09-26): The user chose to preserve historical scoring and move on.** The date-sensitive discrepancy remains documented here; no Bosnia item or downstream knowledge score is changed.

The [NIC paper](../data/nic-1996/papers/nic-paper.pdf) (printed p. 14) states
that a baseline answer of "yes, U.S. ground troops had been sent to Bosnia"
was correct only for interviews after December 15, 1995; before that date,
"no" was correct. The [source codebook](../data/nic-1996/codebook.txt)
(lines 5418–5449) explicitly says stored `FTFACT41` is coded incorrectly and
repeats the date rule. `TROOPSD1` is Q18d of the baseline self-administered
questionnaire. The current historical recode and `FTFACT41` both score `yes`
as correct for every person, including interviews before the cutoff.

The public 911-row [survey](../data/nic-1996/survey.parquet) contains
`DATEDUN1`, the questionnaire-completion date. Read as MMDDYY within the
November 4, 1995–January 18, 1996 field period, 447 of 466 participants have
a valid date: 344 before December 15, four on December 15 and 99 after it.
Among the 344 before the cutoff, 225 answered yes, 56 no, 40 do not know,
and 23 have no recorded answer. Applying the paper's rule to these clearly
dated people alone reverses 281 item scores. If all other scores are kept as
historically stored, baseline Bosnia correctness falls from 329/466 = 70.6%
to 160/466 = 34.3%, and the fixed-denominator eleven-item baseline knowledge
mean falls by 169/(466 × 11) = 0.03297. Nineteen dates are missing or outside
the field window; four are on the cutoff, for which the paper does not give an
hour-level rule. Do not infer their answers from an unreliable `IAQDATE1`:
the codebook (lines 766–771) documents mixed formats, wrong years and
ambiguous interview dates. It names a separate corrected IAQ date file, but
the public questionnaire-completion date suffices for the 281 clear reversals.

The paper's Table 1 and Table 4 nevertheless print baseline Bosnia at 0.71,
which matches the stored 329/466 and conflicts with its prose and the codebook
warning. This is an author-analysis conflict, not a reason to overwrite source
answers. Keep the historical knowledge definition identifiable. Before making
a canonical correction, choose the policy for December 15 and missing/invalid
dates; then compare respondent knowledge, group/poll derivatives and downstream
readers. The questionnaire's Q18d wording and source codes support the date
interpretation, but no publication-era analysis code resolving this conflict
has been located.

### NIC-07: Party-placement percentages need their own analysis definition

The paper's Table 4 prints Democratic-party placement correctness of .59,
.79 and .64 at baseline, immediate exit and follow-up. Source Time 2 is the
event-exit interview, as established in NIC-11. The archived `nic1.R` and
maintained eleven-item build define a correct placement as `POLDEM` in 1:3 in
every wave. On the paper's participant samples, that gives .594, .661 and
.615. Code 4 is explicitly "moderate middle of road" in the codebook
(lines 5994–6049), so adding it to the liberal side merely to approximate the
paper's immediate-exit value would change the substantive definition; it would also
raise baseline and follow-up proportions to .706 and .801. The paper's 0.79
immediate-exit figure appears in the earlier Luskin–Fishkin manuscript as well, but
neither version specifies a wave-specific cutoff or a different source
extract. Preserve the consistent 1:3 recode until original tabulations or
analysis code explain the discrepancy. This item is outside the nine-fact
"Information Summary" reproduced in NIC-02.

### NIC-08: Correct the clear birth-year typo and withhold unsupported ages

**Status: approved by the user on 2026-09-26 and implemented upstream.** The
[codebook](../data/nic-1996/codebook.txt) calls `BYEAR` the two-digit birth
year and `BIRTHDY1` the date of birth. Across all 911 source rows, 890 of
891 observed year pairs agree. Participant CASEID 10007590 is the sole
mismatch: BYEAR is 07 while the birthdate ends 67. Its age is now 29, not 89.
Five other records have BYEAR94–96, producing ages 0–2 under the NIC-03
century rule: participants 10005580, 10008740, 10008780 and 10011470, plus
nonparticipant 10006530. Their `BDAYRTE1` flags say birth before November 1,
1977, but five other source records with ordinary adult birth years contradict
that flag, so it does not establish exact ages. For three of the four
participants, the recorded birthdate equals the interview date. The remaining
birthdate could in principle refer to an exceptionally old adult, but the
century is unverified. All five unsupported ages are now missing rather than
assigned a guessed birth year. `AGE18UP1` counts adults in the household and
was not used as an age-screen flag.

The full-source respondent export changes six ages. The 466-person historical
sample retains its members and IDs; five `ppage` cells change, observed ages
fall from 458 to 454, and their mean moves from 41.83843 to 42.06608. Group
`meanage` changes for 77 rows in groups 5, 11, 17, 18 and 30. No other
aggregate field changes. The nonparticipant mean moves from 48.78291 to
48.89352, which rounds to the paper's 48.89, but the corrected participant
mean still differs from its 42.40. The paper's Table 1 (printed p. 19)
gives an overall age range of 19–94; it does not provide respondent-level
age processing. The 911-row source checks, versioned approved values and
respondent/aggregate comparisons are in
[audit/corrections/nic-1996/](../audit/corrections/nic-1996/).

The historical score definition remains `age@nic-03-v2` in the earlier
comparison; the reviewed respondent value is `age@nic-08-v3`. The latter is
computed upstream, so downstream readers must not repair these cases again.

### NIC-09: Event-exit extremity and dispersion used three baseline answers

**Status: corrected upstream after user approval.** The maintained event-exit
measure now uses all nine T2 Q19 answers. The historical values remain in the
frozen benchmark and the paired
[approved values](../audit/corrections/nic-1996/approved_values.csv).

The historical `attextreme2` and `avgsd2` construction takes event-exit answers
for environment, Medicare, law enforcement, drug rehabilitation, education
and defense, but takes **baseline** answers for foreign aid, welfare and Social
Security. The three event-exit fields `SPFAID2`, `SPWELF2` and `SPSS2` exist in the
source. The [codebook](../data/nic-1996/codebook.txt) explicitly labels them
T2 Q19g–i, and the scanned
[SAQ2 questionnaire](../data/nic-1996/questionnaire.pdf) asks all nine spending
items together at Q19 (printed p. 10, PDF p. 12). The printed instrument has
too much 3, too little 1, about right 2 and don't know 8. The revised source
already reverses the substantive direction, as verified in NIC-12; this does
not alter the identification of the nine contemporaneous items. There is no
instrument-level reason to splice Q19g–i from baseline into the event-exit index.

Among 466 participants, replacing only those three inputs with their T2
answers changes 284 `attextreme2` values after the documented code lookup.
Mean event-exit extremity becomes .287911 rather than .293753. The mean changes
in 29 of 30 discussion groups, ranging from −.043651 to +.038194. All 30
group `avgsd2` values change, so 466 exported group-dispersion cells differ;
the unweighted mean across group values becomes .304624 rather than .302913,
with group changes from −.042435 to +.028653. Among all 911 source records,
595 respondent event-exit-extremity values change.
The source has floating-point category artifacts near integer codes; these
counts use the maintained integer-tolerance lookup, not literal float equality.
The 466-person sample, missingness and all raw answers are unchanged. A direct
before/after build changes only `attextreme2` and `avgsd2` among NIC's 90
historical aggregate fields; across the complete 5,869-row `polardata`, these
are the only two columns with value changes at 1e-10 tolerance. The public
source-response table gains 2,733 rows (the three newly used T2 columns for
all 911 source people); every previously exported response retains its raw
value and missingness. This exit-only correction leaves baseline predictors
unchanged. The derived `avgsd2` version was `nic-09-v2` at this step; the later
NIC-12 nonresponse correction supersedes it with `nic-12-v2` and separately
changes baseline attitude predictors. These numerical comparisons describe the
NIC-09 step, before NIC-12. Source T2 is event exit, not arrival; the earlier
arrival terminology was incorrect (see NIC-11's verified timing).

### NIC-10: Cross-poll catalog mislabeled all nine spending questions (corrected)

The archived `allpollindices.csv` assigns NIC 1996's `nic1.t1att1:9` names
such as “Fighting Terrorism,” “Internationalism,” and “Liberalizing Trade.”
Its empirical-premises companion calls these indices the same as NIC2's.
That description does not match the retained
[NIC codebook](../data/nic-1996/codebook.txt): source `SPENVIR`, `SPMEDIC`,
`SPLAW`, `SPDRUG`, `SPEDUC`, `SPDEF`, `SPFAID`, `SPWELF`, and `SPSS` are the
nine parts of Q19 asking whether spending is too much, too little or about
right, at all three waves. The maintained [respondent
recode](../R/respondent_nic.R) maps those nine sources in order to
`nic1.t1att1:9` and the corresponding delayed-follow-up fields. The questionnaire
also prints them together as Q19. The foreign-policy names belong to a
different poll and cannot describe these source answers.

The generated `attitude-indices` table now names all nine rows “Spending on”
their actual subjects, including environment. Both archived cross-poll files
remain unchanged. Field links, respondent values, scores, group/poll
descriptors, sample and historical wide output are unchanged. This is a
catalog correction, separate from the approved NIC-09 event-exit-wave recode.


### NIC-12: Unknown spending attitudes are missing, not neutral (approved)

**Approved by the user and implemented on September 28, 2026.** The nine
spending questions distinguish a substantive “about right” answer from “don't
know” and an absent answer. The former remains .5; unknown answers no longer
receive the same value. At all three source waves, the maintained revised
source codes 1/2/3 map to 0/.5/1, while code 8, the documented
`SPDRUG2` code 9 and system missing map to missing. Unexpected codes still
fail the field-specific source assertions. The raw source columns, all 911 source people, the 466-person
historical sample, identities and discussion groups are unchanged.

The retained [codebook](../data/nic-1996/codebook.txt) describes `SPENVIR`,
`SPMEDIC`, `SPLAW`, `SPDRUG`, `SPEDUC`, `SPDEF`, `SPFAID`, `SPWELF` and `SPSS`.
The [event questionnaire](../data/nic-1996/questionnaire.pdf), Q19 on PDF
page 12, explicitly distinguishes “about right” from “don't know.” The
historical `nic1.R` first replaced missing attitudes with the midpoint. That
was a deliberate executed rule; this approved correction changes its treatment
of nonresponse rather than claiming that the source script accidentally
selected the wrong item.

**Direction crosscheck: do not reverse the revised source again.** The
original `vault/cdd/data/nic_1/Master_nic_123.sav` labels 1 “too little” and
3 “too much”; `SPENVIR2` has 292 code-1 and 50 code-3 responses, and
`SPMEDIC2` has 229 and 109. The revised `Data_revised/nic123_r.sav` reverses
those counts: 50/292 and 109/229. Its companion `nic123_2_r.sav` explicitly
labels 1 “Too much/decrease,” 2 “About right,” 3 “Too little/increase,” and
8 as missing. Eight of the nine printed exit codebook distributions already
match the revised source literally; the environment entry retains the old
1/3 direction. This isolated stale codebook entry does not justify reversing
the already revised source. `Files_revised.txt` identifies revised originals
but does not explicitly document the spending reversal. The retained source
versions and their labels supply the direct evidence; the numerical
correction here changes only nonresponse treatment. The original master file's
value-label text has damaged suffixes. Exact labels, code frequencies and
SHA-256 hashes for all nine exit items in the three versions are retained in
`audit/corrections/nic-1996/exit_direction_source_versions.csv`; the clearly
labeled revised companion corroborates the direction independently.

| Source wave | Newly missing indices, all 911 people | Newly missing indices, 466 historical participants | Participants with all nine missing |
| --- | ---: | ---: | ---: |
| 1: pre-arrival | 940 | 375 | 11 |
| 2: event exit | 2,927 | 387 | 17 |
| 3: delayed follow-up | 4,789 | 784 | 81 |

The historical main attitude catalog still compares source waves 1 and 3.
Thus its 18 wide attitude fields lose 1,159 imputed midpoints; no observed
substantive answer changes. This correction does **not** silently replace
that follow-up contrast with an exit contrast. NIC-11's canonical knowledge
comparison remains initial-to-exit, with follow-up retained separately.

Baseline and exit attitude extremity now average absolute distance from .5
across observed spending answers. An all-missing battery yields missing.
Among historical participants, baseline extremity changes for 123 observed
values and becomes missing for 11; exit extremity changes for 124 observed
values and becomes missing for 17. Available-case means change from .304721
to .338068 and .287911 to .319420, respectively; the denominators change.
NIC-09's source-wave correction remains applied. Its earlier comparison
numbers precede this separate missing-answer correction.

The shared layer recomputes `meanxtreme`, `avgsd` and `avgsd2` for all 466
historical rows. Their respondent-weighted means change, respectively,
.304721 to .338114, .325492 to .332677, and .304513 to .311343. The 20
respondent definitions and these three derived definitions are versioned
`nic-12-v2`. The intermediate, unchanged-formula `genvar` mean would change
from .247991 to .229228; that intermediate result is retained in the NIC-12
ledger to distinguish the source correction from the subsequent shared fix.

**Shared covariance correction approved separately (X-15):** after removing
imputed midpoints, baseline pairwise covariance matrices are not positive
semidefinite in 13 of NIC's 30 groups (minimum eigenvalue approximately
−.019641). The corresponding counts are eight groups at exit and six at
follow-up. The historical absolute-determinant calculation hides this failure.
Under the approved shared rule, baseline generalized variance is missing for
197 NIC participants in those 13 groups; it retains the calculated value for
the remaining 269 people. All polls use `covariance-validity-v2` for this
derived definition. No imputation, complete-case substitution or poll-specific
covariance formula has been introduced.

The current dp-learning analysis recomputes baseline extremity and group
absolute disagreement from canonical attitude answers; its active models do
not use historical `genvar`. On the maintained 30-poll frame (after restoring
the Climate completion-label bridge), NIC retains 456 baseline/exit knowledge
pairs. NIC-12 changes 129 of their baseline extremity values, six to missing,
and their group disagreement/SD values. The attitude-model sample changes from
8,356 to 8,350 (NIC 446 to 440); point estimates for extremity change .0196871
to .0168900 and disagreement −.1005786 to −.0978550. These isolate NIC-12 on
the same intended knowledge panel. They are point-fit comparisons, not updated
uncertainty claims. The actual rebuilt canonical frame exactly matches the
independently constructed candidate; knowledge outcomes and other model inputs
are preserved. Shared X-15 does not affect these active models. The separate
full downstream rebuild also incorporates earlier approved upstream changes. The
point estimates, sample counts and changed inputs are retained in
`audit/corrections/nic-1996/attitude_missing_learning_*.csv`; the consumer
revision was `ba4e7d58e67476f90b5cc875be16b8bfc1e9e08a`, with the Climate
completion predicate corrected in memory for both comparison stages.

Reproduce the independent raw-response calculation with
[`scripts/review_nic_attitude_missing.R`](../scripts/review_nic_attitude_missing.R).
It checks all 24 affected aggregate fields against the maintained builder,
without using the attitude recoder to calculate expected answers. The
[approved values](../audit/corrections/nic-1996/attitude_missing_approved_values.csv)
retain frozen historical, previous and approved values for each source row;
[aggregate changes](../audit/corrections/nic-1996/attitude_missing_summary.csv)
and [source coverage](../audit/corrections/nic-1996/attitude_missing_source_summary.csv)
separate the 466-person historical sample from all 911 source people.

## Tomorrow's Europe 2007 — tomorrows-europe-2007

**TE-01 — deposited-battery eligibility/order mismatch.** `t3part == 1` yields 359
departure respondents from 3,550 source rows, versus 335 deposited batteries.
The earlier 335-person battery comparison did not establish its selection or
ordering. The aggregate reconstruction below establishes a different, 344-person
sample; it does not resolve anonymous deposited-battery ordering. The departure `t3grp` is observed for
all 359 people across 18 groups.

**TE-02 — response-scale origins and invalid codes.** The existing key accounts
for baseline numeric codes 1–11 representing scale labels 0–10, whereas departure
uses 0–10 directly. The available
[post questionnaire](../data/tomorrows-europe-2007/questionnaire-post.pdf)
lists Q19 (official EU candidate) choices 1–4 and couldn't say 99. Among the
344 historical respondents, exactly one has source `t3q19 = 0` and one has 6;
both have stored `t3q19cor = 0`. The approved shared invalid-code rule now
makes canonical item correctness missing, preserves raw0/6 and records
`invalid_response`; the fixed-denominator score retains the stored result.
Neither supports a new substantive answer category.
Before adopting any new scoring or sample restriction, locate
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

### TE-06: Use exit rather than arrival for the main attitude comparison (approved)

The user approved replacing the seven Tomorrow's Europe catalog endpoints with
exit scores, retaining the initial baseline and every existing index definition.
The historical catalog paired source T1 with T2. The retained
[research paper](../data/tomorrows-europe-2007/papers/tomorrows-europe-research-paper.pdf),
PDF p.4, explicitly identifies T1 as the initial interview, T2 as arrival and T3
as the end of the event. It distinguishes preparation-period change from change
during the deliberative weekend. The historical catalog therefore stopped before
deliberation, despite the consumer's pre-/post-deliberation interpretation.

`metadata/attitude_index_wave_fixes.csv` records the seven expected historical
endpoints and their approved T3 replacements. `R/attitude_catalog.R` applies
these after the existing label corrections and asserts the archived mappings.
The other 122 index pairs are unchanged. No source response, reconstructed index,
respondent, group or missingness changes: the same 344 people and 18 groups remain.
The separately typed `attitude_contrasts` table records seven primary initial-to-
exit comparisons (canonical t0 to t2) and seven supplemental arrival-to-exit
comparisons (t1 to t2), with original wave-instance IDs and wide score columns.
Only these 14 contrasts have that table's explicit reviewed timing contract; it
does not certify the timing of every other catalog entry. The supplemental pairs
support later homogenization, polarization and domination analyses during the
event without replacing the primary comparison or constructing a new index.

Independent reconstruction of all seven indices at all three waves from raw
answers matches the corrected output, including missingness, within 1e-10.
The retained post-form question numbers are Q1 (EU membership), Q4 (pensions
privatization), Q7c (migration), Q11a/c and Q12a:d (military), Q11b (pacifism),
Q16b (Turkey) and Q18a:d (veto). The corresponding baseline Turkey and veto
fields use Q13b and Q15a:d. The form's cover does not explicitly identify its
wave; the research paper supplies the timing evidence. The retained attitude
report describes all 3,550 baseline records and is not an exit validation sample.

Using the consumer's available-wave group formulas over the same 126 group–issue
pairs gives:

| Measure | Historical baseline–arrival | Approved baseline–exit | Supplemental arrival–exit |
| --- | ---: | ---: | ---: |
| Mean homogenization | .021944 | .031966 | .010022 |
| Mean polarization | -.043319 | -.026990 | .001491 |
| Homogenization frequency | .738095 | .730159 | .515873 |
| Polarization frequency | .379032 | .419355 | .544715 |

Polarization excludes groups whose initial mean is exactly neutral, leaving
124, 124 and 123 defined pairs respectively. These are descriptive counterfactual
comparisons on corrected inputs, not re-estimated downstream paper results.
Changing the compared wave also changes item-specific complete-pair membership;
`wave_common_people.csv` separately holds respondents observed at all three waves
fixed within each index. For migration, those 319 people change by -.08856 before
arrival and +.06426 during the event, for -.02429 from baseline to exit.
The exact columns, observed counts, paired results and group-level calculations
are retained in `audit/corrections/tomorrows-europe-2007/wave_*.csv`.

The military `_f` variant remains separate. Each stored `_f` value is exactly the
stored military index minus the separate pacifist response; this changes its
construct, range and missingness. The catalog continues to use the existing
non-`_f` definition at all waves, including the approved TE-04 departure correction.
Trade remains outside the seven-index selection. Neither specification choice
is silently bundled into the timing correction. Downstream frozen benchmark pins
must be updated explicitly before their reported results reflect this change.

### TE-07: Full attitude battery and source-direction review

**Status: reviewed; no additional score correction.** Independent raw-response
reconstruction covers all 31 series: seven main indices at each of source T1,
T2 and T3 (EU membership, privatization, migration, military, pacifism, Turkey
accession and veto), plus five additional indices at T2 and T3 (pension payment,
trade, general enlargement, decision-making level and enlargement limits). It
checks every series for all 3,550 source rows and the 344 historical respondents, and separately checks
the baseline and arrival extremity summaries. All 64 checks match values and
missingness; none of the reconstructed indices is outside [0,1]. Coverage,
observed counts and means are retained in
[`attitude_index_checks.csv`](../audit/corrections/tomorrows-europe-2007/attitude_index_checks.csv)
and [`attitude_index_coverage.csv`](../audit/corrections/tomorrows-europe-2007/attitude_index_coverage.csv).
The nested weighting of the selected military index remains authored behavior;
the separate `_f` variant and omission of trade from the main catalog remain
explicit choices. TE-04's departure-item correction and TE-06's initial-to-exit
contrast remain in force.

The original [policy codebook workbook](../data/tomorrows-europe-2007/codebooks/policy-codebook-rev2.xls)
([PDF preview](../data/tomorrows-europe-2007/codebooks/policy-codebook-rev2.pdf))
and [SPSS variable-label syntax](../data/tomorrows-europe-2007/scripts/policy-variable-labels.sps)
are now retained unchanged. The workbook's PolicyIndices sheet supplies the
battery definitions and variants. Syntax lines 398–403 label the derived
arrival/exit migration variables as support for open migration. These sources
must be read together with the printed post questionnaire, whose Q7 response
order appears opposite to the already coded source values.

The research paper's Appendix H provides an independent check of that apparent
reversal: among 348 people with both answers, current migration means are
.8196839080 initially and .7909482759 at exit, reproducing the printed .820 and
.791. Reversing the post score would instead produce .2090517241. These 348
people are within the 359 source T3 participants and are not the historical
344-person grouped selection. Exact results are in
[`attitude_migration_paper_comparison.csv`](../audit/corrections/tomorrows-europe-2007/attitude_migration_paper_comparison.csv).
Thus a blind post-wave reversal is rejected. The earliest raw-to-coded migration
step has not been recovered: the retained syntax starts after the Q7cr variables
exist. The printed-form discrepancy remains a documented source-version gap,
not a license to overwrite the stored and published direction.

### TE-05: Include postgraduate education and use the source age (corrected)

**Status: approved by the user on 2026-09-26 and implemented upstream.** The
[source value labels](../data/tomorrows-europe-2007/value-labels.csv) identify
Q39 code 5 as "some postgraduate," between "university degree" (4) and
"postgraduate degree" (6). The original `vault/cdd/scripts/eu_2007.R`
classified codes 4/5/6 as university-or-above in `educollege`, but its
four-level `educ4` recode put `5 = NA` before a conflicting `4/5/6 = 1`.
The archived source variable `q39recode` also includes all code-5 records in
its university-or-above category. The [research paper](../data/tomorrows-europe-2007/papers/tomorrows-europe-research-paper.pdf)
(printed p. 5) defines the education indicator as university education or
more. The corrected respondent recode maps Q39 codes 4, 5 and 6 to 1 and
keeps code 7 (no answer) missing. In the 3,550-row source, 77 people have
code 5; 17 of them are in the unchanged 344-person aggregate sample. For
that sample, `educ4`, `educ3` and `bettered` each gain 17 observed values
(326 to 343), across ten groups.

The same source labels define Q36 code 2 as ages 25–39. The original script's
comment says 25–29 and maps the entire category to 27. The source also
contains `v_q36` (birth year) and `age`: all 3,533 observed source ages equal
`2007 - v_q36` and fall within their Q36 bands. The 17 Q36 "don't know"
records have missing source age; the previous reconstruction incorrectly
assigned them age 6. The corrected respondent value uses the source `age`,
checks it against birth year and the Q36 band, and leaves those 17 missing.
All 344 aggregate respondents have source age: 326 `ppage` values change and
its sample mean moves from 43.18023 to 45.00000. The full-source respondent
export changes 3,267 observed ages and marks the 17 unsupported ages missing.

Group calculations remain in the later derived stage. `meanage` changes for
all 344 rows in 18 groups. `meaned`, `vareduc` and `sdeduc` change on 194
rows in ten groups; `entropy` changes on 174 rows in nine groups. These and
the four respondent fields above are the only new changes to the historical
wide export; the earlier TE-04 military and trade corrections remain as
approved. [Approved respondent and group values](../audit/corrections/tomorrows-europe-2007/approved_values.csv)
record each old and new value, and both parity comparisons report zero
unexplained differences.

The downstream comparison used identical source code and inputs except for
the two paired aggregate files. `dp-learning` changes 326 age cells and 17
education cells in its analysis frame. Its main mixed model adds those 17
people (5,832 to 5,849 observations): the heterogeneity coefficient moves
from .0070214 to .0033871 and the age-per-decade coefficient from -.0030590
to -.0032097. Running the age and education changes separately shows that
education supplies the 17 extra observations and most of the heterogeneity
change; age alone keeps 5,832 observations. In `dp-distortions`, four of 19
result CSVs change: the two education subgroup tables, their 70 existing
Tomorrow's Europe group-index rows, and six pooled education inference rows.
No group-index pair is added or lost. The `dp-deliberately` importer receives
the same 326 changed ages and 17 newly observed education indicators.
The comparison does not rerun any publication-era model.

The other exceptional raw codes remain field-specific and historically
reviewed in the historical scorer: `t2q19=6` and `t3q19=0/6` contribute zero;
`t2q24=24/1004` and `t2q27=44/1004` become missing then incorrect;
`t2q11a=8`, `t3q16a=10` and `t3q18c=55` become missing in attitudes.
The baseline questionnaire and the original participant/roster join are still
needed for TE-01 and TE-02; this correction does not change their status.

### TE-08: Preserve source nonanswers and literal wave identities in transport

The numerical recoders already omit non-substantive attitude responses, but
`source_responses` labeled some of those raw codes as answered. Consequently,
`respondent_measures.n_observed_fields` overstated the number of substantive
inputs without changing the measure itself. The review covers all 31 exported
attitude measures and their 85 distinct input fields: 15 baseline, 35 arrival
and 35 exit fields across all 3,550 source respondents.

The corrected source transport recognizes these previously mislabeled cells:

| Source evidence | Cells changing answered to non-substantive |
| --- | ---: |
| Baseline labels “No opinion” and “REF” | 1,872 |
| Code 99 in reviewed arrival/exit attitude fields | 422 |
| Documented invalid attitude codes: `t2q11a=8`, `t3q16a=10`, `t3q18c=55` | 3 |
| Code 99 in eleven arrival knowledge/placement fields | 844 |
| Documented invalid arrival knowledge codes: `t2q19=6`, `t2q24=24/1004`, `t2q27=44/1004` | 12 |
| **Total** | **3,153** |

The three invalid attitude codes occur once each. Invalid arrival knowledge
counts are respectively 1, 1/4 and 1/5. The paired exit questions already classify
these codes as non-substantive in `metadata/knowledge_items.csv`; arrival now
reuses those exact response-status definitions. That transport review did not change scored correctness. The subsequent
shared invalid-code rule makes the12 canonical arrival item correctness values
missing while preserving raw codes and fixed-denominator scores. Incorrect
answers, verified don’t-know responses and reviewed blanks within an observed
questionnaire retain their separate zero-scoring convention. No sample changes.

An inventory of all 29 retained poll-level value-label dictionaries found exact
“No opinion” labels in Tomorrow's Europe, California, BTP 2007 and Vermont,
and exact “REF” labels only in Tomorrow's Europe. Adding those exact normalized
labels to the existing nonanswer dictionary changes only Tomorrow's Europe among
the 21 active respondent builds. Neutral substantive answers such as “neither
favor nor oppose” remain answered. Numeric code 99 and the three invalid attitude
codes are handled only in the explicitly reviewed Tomorrow's Europe fields;
there is no global assumption that 99 is missing.

Raw `source_wave` now reflects the original field names: `q..._1` is T1,
`t2q...` is T2 and `t3q...` is T3. This adds labels to 344,350 previously
unlabeled source cells, including the arrival knowledge fields and exit briefing
question. The five undated demographic source fields remain unlabeled. These
literal source waves are separate from the canonical phase names t0 = pre-arrival,
t1 = arrival and t2 = exit; the existing historical knowledge pair still maps
source T1/T3 and its `source_wave_label()` behavior is unchanged.

Across the complete respondent exports, exactly 3,153 response-status and
missing-code cells change for 1,329 people. The attitude-only repair reduces
3,145 observed-input counts across 33 definitions; adding arrival knowledge
reduces another 777 counts (259 people × three knowledge definitions). In total,
3,922 `n_observed_fields` cells change across 36 definitions, with a maximum
reduction of eleven inputs. Each missing-code field retains the original raw
code rather than imputing a reason or value.

The before/after comparison verifies every raw number, raw text, respondent ID,
row order, definition ID, numerical score and `n_source_fields` is identical.
Every other poll is identical. Only response statuses, missing codes, literal
source waves and observed-input counts change. Field/code counts and affected
measure counts are retained in
`audit/corrections/tomorrows-europe-2007/source_status_changes.csv`,
`source_wave_changes.csv` and `observed_count_changes.csv`; the all-poll label
inventory is retained alongside them. Functional tests independently check
substantive scale bounds in all 85 attitude fields, the eleven arrival knowledge
fields, their wave identities and observed-component denominators.


## Vermont Energy 2007 — vermont-energy-2007

### VT-01: Key ambiguity must remain explicit

**Status:** VT-01 now uses the final report's 25% key with the user's approval;
the instrument ambiguity remains documented below.

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

Before this correction, upstream accepted both starred Q32 answers. Relative
to the deposit, that build reported 250 changed item-wave cells, 53 changed
baseline scores and 79 changed departure scores. Means were 23.2116% → 22.2222% at baseline and
62.9376% → 60.1218% at departure. These changes predate this pass.

| Key sensitivity scenario | Baseline mean | Departure mean |
|---|---:|---:|
| Both starred Q32 responses | 22.2222% | 60.1218% |
| Only 15% | 21.0046% | 57.0015% |
| Only 25% | 20.2435% | 56.4688% |

All scenarios retain the current Q31 efficiency key and nine-item denominator.
The departure spread is 3.6530 percentage points. These scenarios do not resolve
which answer was intended or quantify downstream model effects.

**Remaining evidence gap:** recover the final administered key or scoring
instructions to resolve the double-star ambiguity. The source-label and Q77
unit discrepancies below remain unresolved; the approved Q32 scoring decision
does not resolve them. The published deposit remains preserved.

The retained [pre questionnaire](../data/vermont-energy-2007/questionnaire-pre.pdf)
labels its surcharge item Q80 and its efficiency-impact item Q81; these map to
source `Q77` and `Q78`, respectively. Source `Q77`'s variable label names the
surcharge, but its value labels ("almost no impact," "reduced by 20%," etc.)
belong to the next efficiency item. They are misattached dictionary labels,
not evidence that source `Q77` holds efficiency answers. The pre Q80 choice
printed as "about .005 cents per kilowatt hour" is also not the same unit as
the starred [post Q30](../data/vermont-energy-2007/questionnaire-post-key.pdf)
choice "about half a cent per kilowatt hour" (both choice 2). The pre text
may be a draft/unit typo; the retained materials do not establish what was
read to baseline respondents. Preserve the current choice-2 key and raw
answers until the administered baseline form or interviewer instructions are
found. Do not rewrite the deposited SPSS labels as if they were fielded text.

**Final-report comparison and approved decision (2026-09-27).** The retained
[final report](../data/vermont-energy-2007/reports/vermont-final-report.pdf),
Figure 84 (printed p. 138, PDF p. 139), reports 11% correct before and 28%
after for this exact question. Only code 3 (25%) reproduces those figures:
16/146 = 10.9589% at baseline and 41/146 = 28.0822% at departure. Code 2
alone gives 26/146 = 17.8082% and 48/146 = 32.8767%; accepting both gives
42/146 = 28.7671% and 89/146 = 60.9589%. This reproduction supports following
the report's scoring; it does not independently resolve what the wording means.

A temporary LibreOffice conversion of the original `.doc` to `.docx` exposes
both stars as ordinary live text, with no tracked insertions, deletions or
comments. The [briefing](../data/vermont-energy-2007/briefing-materials/vermont-energy-briefing.pdf),
Figure D (printed p. 5, PDF p. 15), shows 2006 consumption shares of 12%
Other Hydro, 8% Other Renewables and 27% Hydro Quebec. The first two total
20% of all electricity, midway between the offered 15% and 25%. Removing
Hydro Quebec from the denominator as well gives 20/73 = 27.3973%, closer
to 25%; this is a possible interpretation, not a recovered scoring instruction.
The newly retained [April 2007 Energy Digest](../data/vermont-energy-2007/reports/vermont-energy-digest-2007.pdf),
printed p. 8 (PDF p. 10), reports 14% from in-state renewables in 2005. Its
geographic coverage and year differ from the briefing chart, so it does not
independently establish that 15% answers the fielded question.

The user approved following the final report for now and retaining these
ambiguities in the notes. The maintained T1 and departure knowledge rule is
therefore **25% only**, with 15% a substantive incorrect answer rather than
missing. This changes exactly 26 baseline and 48 departure item scores and
person-wave nine-item scores, each by -1/9. The mean nine-item score moves
from 22.2222% to 20.2435% at baseline and from 60.1218% to 56.4688% at
departure. The 146-person cohort, raw answers, response missingness, nine-item
denominator and all other item keys are unchanged. Q31 still uses 50% for
energy-efficiency impact. The retained `.doc`, report, briefing and background
report remain in the Vermont poll folder. Consumers of Vermont's scored
knowledge answers, including `dp-learning`'s attendee panel, will receive the
new scores. A before/after check of that panel retains all 10,598 people and
changes scores for 68 Vermont people (26 at baseline and 48 at departure;
six change at both waves). Every other poll is identical. Pooled estimates
using those scores will need rebuilding; their effects have not been estimated
in this source-coding pass.

**VT-02 — group roster gap.** `PART == 1` selects 146 of 750 source rows, but no
verified group roster is attached. This is a missing verified linkage, not proof
that discussions had no groups. Search original session materials before making
that assertion; do not substitute a single synthetic group.

### VT-03: The question catalog inherited incorrect choice labels (corrected)

The baseline SAV dictionary attaches efficiency-program choices to `Q77`, the
surcharge question, and reuses the renewables percentages for `Q80`, `Q81` and
`Q82`. The maintained catalog had copied those labels, so its displayed answers
were incorrect even though the numeric scoring keys were already right. Direct
comparison of the retained pre and departure questionnaires establishes:

| Source columns | Item | Questionnaire choices | Correct code and baseline display |
|---|---|---|---|
| Q77 / Q030T3 | Surcharge | Baseline: zero, .005, .02, .5, .75 cents/kWh | 2: about .005 cents/kWh |
| Q80 / Q033T3 | Vermont Yankee supply | 5%, 10%, 20%, 33% | 4: 33% |
| Q81 / Q034T3 | Hydro Quebec supply | 15%, 33%, 45%, 60% | 2: 33% |
| Q82 / Q035T3 | Generation within Vermont | 12%, 33%, 55%, 72% | 3: 55% |

Sources: [baseline questionnaire](../data/vermont-energy-2007/questionnaire-pre.pdf)
Q80/Q83–Q85, PDF pp. 7–8; [departure questionnaire](../data/vermont-energy-2007/questionnaire-post-key.pdf)
Q30/Q33–Q35, PDF pp. 11–13. The catalog now displays these baseline choices and
correct-answer labels, with explicit questionnaire locators. It preserves the
baseline surcharge wording rather than silently substituting departure units:
post Q30 offers zero, half a cent, two cents, five cents and seven-and-a-half
cents. The separate unit ambiguity in VT-01 remains unresolved.

Rate-comparison Q83 / Q036T3 has a genuine wave-specific ordering change:
baseline Q86 codes 1/2 mean 10%/20% higher, while departure Q36 codes 1/2 mean
20%/10% higher. The catalog retains the baseline ordering and documents the
departure difference. Correct code 4 means roughly 10% lower at both waves.
This does not authorize changing raw answers or interpreting all departure
codes through baseline choice labels.

The source SAV and `value-labels.csv` retain their original bytes as evidence.
Only catalog metadata and its generated display fields change; responses,
answer keys, scores, samples, group variables and all other polls are unchanged.

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

The canonical Q26 catalog summary previously omitted most of the question's
substantive categories. The March 12 questionnaire and the
[results report](../data/san-mateo-2008/reports/san-mateo-results.pdf),
Table 2, ask about land in **agricultural use, watershed, open space, wetlands,
or parks**; `metadata/items.csv` now gives that full wording. The report's
Q26 correct-answer rates are 5.86% before and 27.20% after, exactly 14/239
and 65/239 source respondents selecting code 5. This reproduces the
publication-era key choice, but is not an independent geographic fact check.
The briefing booklet's land-use chart separates agriculture/rangeland (40%)
from open space (33%), totaling about 73%. It does not clearly explain why
the keyed response is “more than 75%”; watershed or other land categories may
cross the threshold, but no reviewed source establishes that allocation.
Preserve code 5 pending a fielded key or a source calculation using the full
question definition. The Q20 catalog also now distinguishes source-label
$950,000 from questionnaire $940,000; both are code 5, so no score changes.

The renewed extreme-age check confirms source rows 1383 and 1559 report Q129
birth years 1911 and 1910, yielding ages 97 and 98 in 2008. Both are
nonparticipants. These derived ages are not the source's refusal codes;
preserve the reported birth years and derived ages.

### SM-02: IDs and summary batteries follow an earlier analysis stage

Of 1,806 source records, `participant == 1` selects 239. Synthetic historical
IDs `960001:960239` follow ascending `PARTICIPANTID`, not file order. The sample
uses 26 `GRP` values. `RESPNUM` is not unique, and the later 239-row analysis file
is a different provenance layer; neither is a substitute for this ID bridge. All 16 raw
knowledge-answer columns and historical groups match the archived poll file
under that ordering. Seven-point attitudes round to seven decimals before
float32 storage; direct fractions are numerically different.

Final exports retain four attitudes, but extremity and group dispersion use
seven, including commuting, public consultation and county-versus-state scales
later dropped in `05_fix_data.R`. Do not rebuild summaries from the four final
columns. Check the index-selection rationale before changing the battery.

The 2026-09-28 attitude review independently decoded the original
`smdp 3-18-08.dta` and compared every source answer for both waves with the
maintained projection. All four main-catalog indices reproduce exactly on the
same 239 people and 26 groups:

| Main index | Source fields | Scoring direction | Observed before / after / paired |
|---|---|---|---:|
| More housing | Q1 / t2Q1 | 1 = create more housing; 7 = restrict; reverse to 0–1 | 226 / 238 / 225 |
| Below-market housing | Q4 / t2Q4 | 1 = require below-market homes; 7 = market rate only; reverse | 231 / 234 / 226 |
| Open-space rezoning | Q2 / t2Q2 | 1 = developed areas; 7 = rezoned open space | 230 / 235 / 226 |
| County coordination | Q8 / t2Q8 | 1 = local control; 7 = county coordination | 228 / 236 / 225 |

The [baseline instrument](../data/san-mateo-2008/questionnaire-pre.pdf),
pp. 1–3, and stored post value labels agree on these endpoints and the neutral
category 4. The [results report](../data/san-mateo-2008/reports/san-mateo-results.pdf)
prints the same core questions in its before/after tables. The short retained
post supplement supplies additional questions, not independent wording for the
core post battery. All seven component indices in both waves, all 1,806 source
respondents' baseline extremity, and the selected group average SD and mean
extremity reproduce from their source answers with the documented float32
rounding. Consultation's two substantive post zeros remain observed; missing
answers are not converted to neutral attitudes.

The original `02_nuri.R`/`04_kyu.R` merge and `reagg.txt` use all seven indices
for summaries; `05_fix_data.R` subsequently removes the commuting, consultation
and county-versus-state columns. The retained
[drop memo](../data/shared/codebooks/attitude_indices/indices-to-drop.pdf)
explicitly treats consultation as a value and county-versus-state as an empirical
premise; it does not provide the commuting exclusion's rationale. Preserve the
existing seven-index summaries and four-index main analysis rather than silently
substituting one for the other. X-15 makes two invalid San Mateo covariance
matrices missing; X-09 retains three valid, numerically sensitive San Mateo exceptions as separate limitations.

The report's Q2 post table has one 1.50 response (0.4%) absent from both the
retained original Stata file's raw and authored recoded fields. No respondent
identity for that response is established, so no value is imputed from the report.
Many report category percentages reproduce with denominator 239 despite its
prose saying 238; this does not identify which attendee, if any, should be excluded.
The case-level scale and missingness check found no new numerical correction.
Exact main-index counts and ranges are retained in
`audit/san-mateo-new-haven-attitude-coverage.csv`.

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

### SM-05: Housing-income question includes three income groups (catalog corrected)

The [baseline questionnaire](../data/san-mateo-2008/questionnaire-pre.pdf), Q24,
PDF p. 7, asks about the combined share of new households with **low, very low
and extremely low incomes**. The catalog paraphrase omitted the third group.
It now includes all three and cites the questionnaire directly. The correct
numeric code remains 3 (about half); no scores or raw answers change.

Across the eight catalog rows, the damaged source-text spelling `couldnÆt` is
rendered as `couldn’t`. The stored nonresponse codes remain 6 for seven items
and 5 for Q25, even though the printed baseline questionnaire uses 99.
These source and instrument codes must not be silently substituted for each
other. The retained `questionnaire-post.pdf` is the five-page onsite attitudes
supplement, with no knowledge battery; it cannot verify departure choice order.
The previously documented Q20 price-version and Q26 land-use questions remain
unchanged. Original questionnaires and source dictionaries are preserved.

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
substantive party answer is inferred from them. Specifically, post ID 406
answers `SC` to both Q38 (Michigan State Senate) and Q39 (State House); the
deposited battery has incorrect for Q38 and missing for Q39. Post ID 503
answers `same` to Q38 and "don't know" to Q39; the deposit again has incorrect
for Q38 and missing for Q39. The maintained typed build leaves all three `SC`
or `same` cells missing. The post questionnaire puts Q38 first in this
party-control pair, so `same` cannot be resolved from an immediately preceding
party-control answer.

**Next check:** recheck all accepted text aliases against contemporaneous coding
instructions, retaining raw text and rejecting unknown tokens. `postit` identifies
people and `group_number` gives 16 groups. The published source is already merged
`mifin.dta`; reproducing its earlier merge is a separate unresolved task.

### MI-02: Nine shared items and the report's eleven items compare different waves

The [baseline questionnaire](../data/michigan-2009/questionnaire-pre.pdf),
PDF pages 2 and 4, contains four party-placement items (Q4/Q5 on taxes and
spending; Q7/Q8 on government intervention against unemployment) and five
factual items (Q14–Q18). The [departure questionnaire](../data/michigan-2009/questionnaire-post.pdf),
PDF pages 3–4 and 11, contains the corresponding placement Q10/Q11/Q13/Q14
and factual Q38–Q42, plus two standard-of-living placement items Q7/Q8.
Those additional items ask where the Democratic and Republican parties sit
between government ensuring everyone has a job and a certain standard of
living (1) and everyone trying to get ahead on their own (7). Correct sides
are 1–3 for Democrats and 5–7 for Republicans. These two items were collected
at arrival and departure, not in the telephone baseline.

The [final report](../data/michigan-2009/reports/michigan-final-report.pdf),
PDF/printed page 13, explicitly marks the standard-of-living pair as
"Question at arrival, before deliberations." The archived
`historical-cdd-scripts:legacy/poll_scripts/mi.R` separately defines
`t1knownet`/`t2knownet`/`t3knownet` using the nine shared items and
`t2know2`/`t3know2` using eleven arrival/departure items. Its exported battery
uses the nine-item telephone-baseline/departure comparison. Adding the two
arrival items to that baseline score would mix measurements from different
waves; retain the existing battery and represent an eleven-item comparison
as a separate definition if it is added.

The 310 selected people have unique `postit` values, and none has all nine
raw baseline or departure knowledge responses missing. Raw factual correct
counts, in the report's question order, are 81/137/14/34/86 before and
134/165/25/57/90 after. The fixed-denominator five-item means are
22.70968% and 30.38710%, reproducing the report's 22.7% and 30.4%.
The existing nine-item means are 34.15771% and 43.94265%.

Using arrival Q7/Q8 plus the four shared baseline placement items gives a
six-item placement mean of 54.08602%; the six departure items give 61.82796%
when missing responses score zero. Equal weighting of the factual and
placement domain means gives 38.39785% and 46.10753%, consistent with the
report's overall 38.4% and 46.1%. An equal-weight eleven-item score instead
gives 39.82405% and 47.53666%. Equal domain weighting is therefore a numerical
explanation of the published overall index, not a reason to change our
existing nine-item measure. The report's departure placement mean is 61.9%,
rather than this zero-filled reconstruction's 61.82796%; its exact item
missingness/denominator convention remains unverified. Do not describe this
as an exact reproduction of every reported placement estimate or assume the
archived eleven-item `rowMeans` definition is the report's overall index.

**Decision:** no scientific correction is justified by the nine-versus-eleven
count. Keep the current shared-item battery and preserve raw arrival/departure
answers for a separately defined extension.

### MI-03: Preserve the single out-of-range arrival placement code

Source row83, ID501, has `t2q10 = 9`. Q10 places the Democratic Party on
the tax-and-spending scale: the instrument offers1:7 and99 (“No opinion”),
not9 (departure questionnaire PDFp.3; arrival counterpart documented in MI-02).
The person's baseline answer is1 and departure answer5; these do not recover
what was intended at arrival. Preserve raw9 and map correctness to missing under the user-approved global
invalid-response rule; classify it `invalid_response`, with no trichotomy category or invented source
label. It appears twice in the phase table because the same source item belongs
to two explicitly distinct placement batteries. Both item rows retain their
identity and have missing correctness. No knowledge score, sample, or attitude response changes.

## Denmark Euro 2000 — denmark-euro-2000

**DK-01 — the deposited battery includes baseline-only rows and omits one
departure respondent.** The baseline has 1,702 rows, the departure file 359,
and all 359 departure `DELNR` values uniquely match nonmissing baseline
`delnr`. There are 363 deposited battery rows. Comparing the nine T0 and nine
T2 correctness cells in their original sequence matches 358 rebuilt people
exactly, including baseline gender. Five deposited rows are inserted at rows
93, 109, 130, 154 and 264; all have T2 answers missing. Their nine T0 cells
and gender match baseline records with `delnr` 103, 120, 142, 166 and 281,
respectively. The latter four signatures are unique in the baseline. Row 93
also matches one baseline record with no `delnr`, but its position between
matched identifiers 102 and 104 supports 103. None of these five identifiers
appears in the 359-row departure file. Conversely, baseline `delnr` 203
(source row 836) has a matched departure interview and a unique complete
18-cell signature, but no deposited row. Thus five baseline-only insertions
and one omitted departure row explain the net four-row difference. The
anonymous deposit does not prove why those choices were made or provide an
independent ID bridge for row 93.

The maintained paired build keeps the 359 documented departure interviews;
it does not add rows without a T2 interview or drop `delnr` 203 to imitate the
deposit. Nine-item measurements join source T0 to T2. An archived joined object
also has 359 departure respondents. The contemporary
[study](../data/denmark-euro-2000/papers/deliberative-democracy-euro.pdf)
reports 364 event participants in its recruitment table, a different count
from both the available T2 file and the anonymous battery; the event count
cannot identify the missing or extra rows. No verified discussion-group roster
is attached. DK-02–04 below complete the questionnaire, dictionary and published
key checks. The remaining provenance task is to recover the deposited battery's
exact source version and inclusion rule before changing eligibility. The 358
exact matches do not establish a score comparison for the six nonmatching
records; preserve the documented 359 departure interviews.

### DK-02: Independent factual keys and departure estimates agree (checked)

The nine-item battery retains six factual questions and three party-position
questions. The source dictionaries identify each question by its label and
meaning; join baseline `delnr` to departure `DELNR`, not source-row position.
There are 390 unique nonmissing baseline participant numbers and 359 unique
departure numbers. Every departure number matches exactly one baseline row;
31 numbered baseline records have no departure record. Preserve the 359-pair
selection in DK-01; neither the paper's 364 attendees nor the anonymous
363-row battery supplies identities for additional departure interviews.

The factual keys are independently printed in
[Deliberative Democracy and the Euro](../data/denmark-euro-2000/papers/deliberative-democracy-euro.pdf),
Table 9, PDF page 19 / printed page 279, and
[How Deliberation Makes Better Citizens](../data/denmark-euro-2000/papers/how-deliberation-makes-better-citizens.pdf),
Table 7, PDF page 15 / printed page 545. The following counts refer to the
359 paired people. Explicit don't-know answers count as noncorrect in these
percentages; system missing answers are excluded from the item percentage,
as distinct from the fixed-denominator respondent index.

| Question meaning | T0 / T2 fields | Correct code / answer | T0 correct / denominator | T2 correct / denominator | T2 percent; paper percent |
| --- | --- | --- | --- | --- | --- |
| Denmark could be fined for an excessive fiscal deficit as a monetary-union member | `s_18` / `S4_2` | 1 / true | 148/359 | 284/357 | 79.55182%; 80% |
| Denmark could decide its own interest rates after joining | `s_19` / `S5_2` | 2 / false | 265/359 | 293/357 | 82.07283%; 82% |
| Denmark could decide its own tax rates after joining | `s_20` / `S6_2` | 1 / true | 230/359 | 295/357 | 82.63305%; 83% |
| Year euro circulation would begin in Denmark following a yes vote | `s_21` / `S7_2` | 2 / 2004 | 185/359 | 317/357 | 88.79552%; 89% |
| Fate of the Danish National Bank after joining | `s_22` / `S8_2` | 3 / become part of the European Central Bank | 212/359 | 235/355 | 66.19718%; 66% |
| Whether euro coins would have a national side | `s_23` / `S9_2` | 1 / yes | 190/359 | 335/356 | 94.10112%; 94% |

The additional factual currency-cooperation item `s_24` / `S10_2`, omitted
from the inherited nine-item battery, scores yes: 298/359 (83.00836%) before
and 307/354 (86.72316%) after, consistent with the papers' 83% and 87%.
The six retained baseline percentages are 41.22563%, 73.81616%, 64.06685%,
51.53203%, 59.05292% and 52.92479%. The papers report 41%, 73%, 64%, 51%,
59% and 53%; two baseline figures do not round identically. Their participant
sample is not identical to the available 359 departure records, and their
note gives item N between 354 and 364. Do not claim exact reproduction of
those two baseline estimates or change a key to force agreement.

The maintained party fields are `s_25_07` / `S11_7_2` (Socialist People's
Party), `s_25_09` / `S11_9_2` (Christian People's Party) and `s_25_11` /
`S11_11_2` (Progress Party). All use code 2, Recommend No; codes 1 and 3 mean
Recommend Yes and Don't know. Their baseline counts for codes 1/2/3 are
63/270/26, 137/165/57 and 47/275/37; departure counts for 1/2/3/system-missing
are 14/321/13/11, 51/265/29/14 and 23/305/23/8. These are the archived
`denmark.R` keys. In particular, do not reverse the Christian People's Party
key based on an assumption about a generally pro-EU party: Jann Sjursen's
[6 September 2000 parliamentary speech](https://www.folketingstidende.dk/samling/19991/lovforslag/L288/19991_L288_BEH3_M103_referat.pdf),
printed page 9624, argues that Denmark should retain the krone and remain
outside the euro.

Across all 6,462 maintained item cells, direct raw-field reconstruction finds
zero differences from exported raw values or typed correctness. Baseline has
503 explicit don't-know item responses and no system-missing cells; departure
has 184 explicit don't-know and 48 system-missing cells. Codes 3, 4 and 5 are
question-specific don't-know choices, not universal missing codes. The
fixed-nine-item means are 60.04333% and 82.01795%.

Departure ID 321 (departure source row 296; baseline source row 1346) has all
nine maintained departure knowledge answers missing, but 41 other departure
answers observed, including the Liberal Party recommendation. This is a
partially answered questionnaire, not an absent departure interview. Its
current zero-filled nine-item departure score remains zero; retain the raw
missingness and do not infer nonattendance from this score alone.

### DK-03: Archived zero-filling copied baseline facts into departure columns

Line 238 of `historical-cdd-scripts:legacy/poll_scripts/denmark.R` assigns to
`t2pk1:t2pk7` but reads `t0pk1:t0pk7` on the right-hand side, while correctly
reading T2 party-position columns. This overwrites the seven zero-filled departure factual correctness columns
with baseline correctness.
The preceding `t2pk*raw` recodes use genuine departure answers, so the raw
columns are distinct from the overwritten columns. Earlier `t2know` is
calculated before the overwrite; do not assume every archived summary was
affected.

On the available 359 paired people, executing that assignment would replace
916 of 2,513 seven-item departure correctness cells, affecting 336 people.
The per-item differences are 178, 106, 105, 154, 147, 161 and 65. The correctly
zero-filled seven-fact departure mean is 82.21250%; copied baseline facts
would give 60.80382%. Within the six facts retained in our nine-item battery,
851 cells across 333 people differ, and 300 people's fixed-nine-item departure
scores would differ. The current pipeline reconstructs correctness directly
from T2 raw answers and avoids this statement; the zero-difference check in
DK-02 confirms it does not copy T0 into T2. Record this as a genuine historical
script error already avoided by reconstruction, not a proposed change to
current outputs. The anonymous deposited raw battery cannot establish which
execution produced other archived nonraw columns.

### DK-04: The retained English questionnaire is an earlier instrument version

The [retained questionnaire](../data/denmark-euro-2000/questionnaire.pdf)
is visibly provisional: PDF page 1 says background questions will probably
be placed at the end; page 7 describes one section as work in progress.
Its page 2 gives four choices for the fiscal-deficit and monetary-policy
items, including an undecided-policy alternative; the actual T0/T2 source
labels give three choices (true, false, don't know). Page 3 gives circulation
years 2001/2004/2007/2010, whereas the source and both papers give
2001/2004/2005/2007. It also adds a museum alternative to the National Bank
item and says coins and bills, while the source asks about coins only.
Page 4 orders party names differently from the source field numbers and
omits the source's thirteenth party, Freedom 2000. Do not replace source
labels or remap codes using this earlier questionnaire. The papers and
actual source dictionaries substantiate the retained keys; obtaining the
final fielded forms remains an instrument-provenance task.

The catalog's `knowledge_004` question text is now corrected to preserve the
actual task: which circulation year follows a yes vote, with four dated
alternatives. Its earlier paraphrase asked whether circulation would begin in
2001, changing it into a yes/no question while retaining a four-choice response
schema. The complete departure `S7_2` label and Table 9's wording support the
restored year-choice question. Key 2 / 2004 and every numeric response, score,
respondent and membership remain unchanged; only item catalog descriptions
and their generated analysis export change.

The selected 359 people's source gender codes are 206 male and 153 female;
there are no invalid codes or missing gender, and age from `2000 - s_02`
ranges from 18 to 88. Other demographics are not currently exported as
derived Denmark measures. Source education code 10 means refusal (four
full-source people, zero selected); income-status codes 2 and 3 mean don't
know and refusal (267/76 full-source people, 39/12 selected). Preserve those
missing states in any future demographic expansion. Full-source row 1430,
with no participant number, has birth year 1987, implying age 13 despite
the adult recruitment wording. It is outside the paired sample; flag its
age for source verification rather than guessing a replacement birth year.

**Decision:** preserve current eligibility, nine-item keys and typed missingness.
The newly identified copy error is absent from current outputs. Resolve the
remaining anonymous-battery and final-instrument provenance limitations with
additional source versions or logs, rather than changing people or codes to
match aggregate counts.

### DK-05: Original arrival source preserved publicly and scored

The original `data/Denmark/data/t1.sav` is now retained byte-for-byte as
`data/denmark-euro-2000/arrival.sav`. Its 121,960 bytes have SHA-256
`0bf7c28c4bc93c80e62244ec02b3764ba15e735684d4cebefc7eace2b67deeb9`.
The source has 363 respondents, 93 fields and unique `DELNR` identifiers.
All 363 identifiers match recruitment records; 358 match departure records.
The arrival factual fields `S4_1` through `S9_1` and party placements
`S11_7_1`, `S11_9_1`, `S11_11_1` correspond to the existing nine-item
recruitment/departure battery. The original labels and missing-value attributes
remain in the SAV; `arrival-variables.csv` and `arrival-value-labels.csv`
provide inspectable dictionaries. Three questionnaire verbatim fields are
retained under the user's approval: another party description, the most
important theme for one's euro position, and a description of the public debate.
They are questionnaire responses, not contact fields.

The survey-component registry and archive inventory now resolve this source
inside the public poll folder. The initial preservation left scoring unchanged.
The 2026-09-28 phase build now exports arrival item responses and scores for
358 matched people; departure ID 203 has no arrival record and remains missing.
The original selected-wave scores and respondent memberships are unchanged.
The source timing remains grounded in `deliberative-democracy-euro.pdf`,
PDF pages 7 and 19, which distinguish recruitment, beginning-of-event and
end-of-event measurements. Both the source and arrival build are public and
require no local vault; X-02 gives the report comparisons and sample boundary.

## Northern Ireland 2007 — northern-ireland-2007

**NI-01 — source roster versus paper reader (corrected downstream).** The
headerless roster contains 124 mappings, beginning with respondent 112084 in
group N. The former `dp-nireland` reader interpreted that first record as column
headings and used 123 mappings, leaving this attendee as a singleton cluster.
Upstream knowledge uses all 124 roster records. `dp-nireland` commit `cc60d58`
now reads dp-data's typed memberships and checks all 124 mappings. Only
respondent 112084 changes group membership; point estimates, coded responses
and analysis sample sizes remain the same. The paper's rebuilt results have one
fewer cluster in affected comparisons, changing CR2 standard errors, degrees
of freedom, intervals and p-values; no reported p-value crosses 0.05 and no
confidence interval changes whether it includes zero. The seven-item knowledge
battery still matches its deposit, a separate check from group membership.

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
The first-roster-row issue was subsequently corrected as described in NI-01.
The old vault inventory remains historical provenance, not a required runtime
input list.
See [dp-nireland data documentation](../../dp-nireland/docs/data.md).

### NI-03: Knowledge keys reproduce the paper; restore the first question's condition

**Status:** source audit checked; catalog wording corrected, scoring preserved.
The original `historical-cdd-scripts:legacy/poll_scripts/n_ireland.R`, lines
95/503, preserves the full first question: “What percentage of
majority-Protestant or majority-Catholic schools in Northern Ireland have at
least 10% of the other religion in their enrolment?” The maintained catalog
had shortened this to the share of schools that were mostly Protestant or
Catholic, omitting the mixed-enrolment condition and changing the question's
meaning. `metadata/items.csv` now restores the script's wording, independently
confirmed by the Political Studies paper, PDF p.8, Table 1, and the event
report, PDF p.34 (printed p.32). No numeric item response or answer key changes.

The dictionaries establish a real option-order change: at baseline, code 1 is
“more than 50%” and code 4 is “5-10%”; at departure the first of those choices
is absent and “5-10%” is code 3. Therefore keys 4 and 3 are the same substantive
answer. Do not unify their raw code numbers. The seven baseline keys remain
4/4/1/4/3/1/4 and departure keys3/4/1/4/3/1/4. The other correct answers are a
10% decrease in entering pupils; at least 24 subject choices for 14-year-olds;
one third applied subjects; approximately three quarters of grammar pupils
going to university; greater funding for older pupils; and the board of
governors as voluntary grammar teachers' employer. These meanings are printed
in the paper and report, rather than inferred from matching the scored deposit.

For all 124 `attend==1` source respondents, their IDs exactly match the 124-row
roster. The seven raw-answer counts reproduce all 14 rounded proportions in
the paper's Table 1:

| Item | Correct baseline / 124 | Correct departure / 124 | Baseline % | Departure % |
| --- | ---: | ---: | ---: | ---: |
| Mixed enrolment | 30 | 44 | 24.19355 | 35.48387 |
| Falling enrolment | 23 | 59 | 18.54839 | 47.58065 |
| Subject choices | 26 | 93 | 20.96774 | 75.00000 |
| Applied subjects | 36 | 78 | 29.03226 | 62.90323 |
| Grammar/university | 36 | 54 | 29.03226 | 43.54839 |
| Funding by age | 28 | 98 | 22.58065 | 79.03226 |
| Employing authority | 10 | 11 | 8.06452 | 8.87097 |

Mean knowledge is 0.2177419355 before and 0.5034562212 after, a gain of
0.2857142857, reproducing the printed 0.218/0.503/0.286. All 1,736 source
item cells agree with the authored correct/incorrect flags; the complete
attendee batteries have no system-missing responses, though explicit don't
know/no-answer codes are present and preserved in the response-status layer.
All 124 attendee ages are observed, range 24–59, mean 40.69354839. Eight
attendees report education “other answers” and one has system missing;
these are not an ordered qualification and remain missing in the existing
canonical education recode.

The earlier event report uses a different analytical version: its Appendix A
knowledge index has N = 121 and means 0.215/0.498 (PDF p.43, printed p.41), and
its Appendix B participant age also has N = 121 (PDF p.44, printed p.42).
Those figures should not be imposed on the later 124-person paper dataset.
The report's seven percentages are not reproduced by the 124-person source,
but the later paper's 14 item percentages and mean scores are. No identity
bridge for the earlier 121-person analysis has been established; do not drop
three current respondents to force that match. Raw age and education coding,
all scores, memberships and the existing sample remain unchanged.

### NI-04 — label follow-up nonanswers explicitly (corrected)

The retained [value labels](../data/northern-ireland-2007/value-labels.csv),
`t3q11` through `t3q17`, identify codes 9 and 10 as nonanswers. These appeared as
`answered` in 356 follow-up item cells. They now use `non_substantive`, with
356 changed cells in each of the selected-wave and phase tables. Raw responses,
zero correctness, scores, follow-up participants and controls remain unchanged.
This correction does not merge the follow-up comparison with the event-exit wave.

### NI-05: A follow-up-only source is not a selected pre/post panel (corrected)

The separate `control` source contains 243 follow-up-only records: 93 attendees
and 150 controls. Their selected-table wave is `t3`; no initial or event-exit
score is available within that source. Its adapter nevertheless set every
`panel` flag to true. The shared rule now makes all 243 flags false in both
participant tables, while preserving every person, attendance label and
follow-up score. The 124 paired Cor–Sood respondents are unchanged.

Ninety-three follow-up IDs overlap the Cor–Sood attendee source, but this change
does not create a cross-source baseline linkage or claim that the follow-up
records are unusable. `panel` means the selected comparison panel within a
source, subject to its original sample restrictions; eligibility for a different
phase contrast must use that contrast's observed scores. Missing optional
follow-ups therefore do not remove otherwise observed initial/exit pairs.

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
| new-haven-2004 | All 132 historical people are reconstructed from joined pre/mid/post workbook answers. Three birth-year-1890 refusals are made missing; the event year is corrected to 2002. The paper reports 133 attendees but analyzes 132, matching the reconstructed group-size split; the one-person exclusion reason remains unknown. | Attendee roster and sample rule; remaining arrival-wave response rules. |
| zeguo-2005 | All 233 historical participants are reconstructed from reviewed merged/pre/post components; three historical knowledge-item overrides remain explicit. The corrected Wenchang source makes all 16 group covariance matrices full rank, removing 15 obsolete numerical exceptions. | Original and translated instruments, event date, project-choice scales and respondent/group identifiers. |
| marousi-2006 | The recovered 1,275-row authored source now supplies telephone, arrival and departure scores with explicit questionnaire presence. MAR-02 corrects partial quizzes previously zeroed as whole scores and retains the verified 146-person historical identity bridge; 159 people have observed event questionnaires. | Original separate wave returns and full factual-key documentation would independently verify the authored merge and keys. Preserve absent questionnaires as missing and blanks within observed questionnaires as incorrect. |
| bulgaria-2007 | Distinct Roma-policy event; it must not inherit the 2002 crime battery merely because files share an archive directory. | Roma-policy questionnaire, actual event date and source-file provenance. |
| tanzania-2015 | Citizens, arms and village clusters are retained. TZ-03 excludes the negative missing sentinel and rebuilds the standardized index; TZ-04 corrects the one follow-up-only panel flag. TZ-01 retains the separate treatment-eligibility ambiguity. | The index and panel corrections are approved. The deposited master explicitly withholds raw-to-derived cleaning scripts, so a redacted recode or author clarification would establish how the sentinel arose. Preserve routing-related missingness and distinguish recorded groups from verified assignment. |
| america-in-one-room-2019 | The attendance flag now uses the source group roster: 526 attended, of whom 523 completed the post survey. Downstream scoring is reproducible from the unchanged deposit; upstream has not independently reconstructed all measurement and sample decisions. See A1R19-01. | Fielded factual battery, remaining answer-key evidence, uninvited controls and both source weights. The Paris Agreement item must be interpreted at the fieldwork date, not under today's ratification status. |
| a1r-climate-2021 | The eight knowledge keys reproduce all 16 published weighted before/after percentages. The 962-person published completion cohort is explicitly labeled completed; other invitees are not labeled nonattenders. See resolved A1RC-01. | Preserve completion separately from unknown attendance among other invitees; retain all three wave identities and seek fielded instruments and follow-up eligibility rules. |
| amr-2024 | All 4,838 scores and 29,028 item responses reproduce the source; verified t0/t2 phases are retained. Recovered expert keys and codebooks support existing scoring. The Tanzania gain is 3.5 points rather than the report summary's 3.6; AMR-01 and AMR-04 document this discrepancy and the Q21 source conflict. | Recover local-language field forms and the 1,847 invited nonattenders omitted from the deposit. Use weights within country × arm; do not infer full invitation ITT from the attendee/control extract. |

The four newer control-study files and Marousi are already byte-identical between
`dp-learning`'s former local inputs and their upstream copies. That migration
reproduced all 11 result tables. It does not constitute an independent audit of
the experiments, answer keys, causal claims, weighting, or original field-file merges.

### A1R19-01 — attendance and post-survey completion differ (corrected)

The [NORC methods report](../data/america-in-one-room-2019/design/a1r-2019-norc-methods.pdf),
page 3 and Table 1, reports 526 attendees, including 523 who completed the
post-event questionnaire. In `participants.tab`, 526 treatment records have a
nonmissing `GROUP`; 523 of those have `POST == 1`. Source rows 805, 1650 and
2965 have `GROUP` 5, 25 and 4 respectively, but `POST == 0` and no delegate
weight or post answers. The former analysis builder used `POST == 1` for both
attendance and panel status. It therefore marked these three attendees as
nonattenders and discarded their observed group numbers. The builder now uses
`GROUP` for treatment attendance and small-group membership, while `POST`
continues to define post-survey completion. This changes only three
participant-level labels and group IDs; it does not alter any questionnaire
response, knowledge key, score or paired pre/post survey sample. It does change
the baseline attendance comparison in `dp-learning`: attended count 523 → 526
with mean seven-item score 0.457798 → 0.458175; invited nonattender count
2,218 → 2,215 with mean 0.378333 → 0.378136. Paired attendee comparisons
still use the 523 post-survey completers, so those estimates are unchanged.

The seven factual answers in `metadata/items.csv` match the codebook options.
The Paris Agreement key is option 4, “All of the above.” This is consistent
with the September 2019 field dates: [Russia accepted on 7 October 2019 and
Turkey ratified in 2021; Iran had signed but not ratified](https://treaties.un.org/Pages/showDetails.aspx?objid=0800000280458f37).
Do not re-key this item using countries' later treaty status.

### A1R19-02 — preserve documented nonanswer status (corrected)

The [original codebook](../data/america-in-one-room-2019/codebooks/a1r_codebook.tab),
PK and T2PK sections, identifies −8, 77, 98 and 99 as nonanswers. The canonical
item tables previously labeled 13,709 such cells `answered`. They now use
`response_status = non_substantive` in both the selected-wave and phase tables,
with 13,709 changed cells in each table. Raw codes, zero correctness, scores,
denominators and respondent samples are unchanged.

### A1R19-03 — published party means reproduce when a nonresponse code is included (checked; retain missing coding)

The actual downstream attitude analysis uses 47 policy items for 523 completed
delegates in 40 groups. All 94 pre/post fields have substantive codes 0–10 and
midpoint 5, and each pair has the same question wording apart from apostrophe
formatting. The methods report distinguishes 526 attendees from 523 completed
post-event questionnaires. The existing completion restriction is supported.

The retained paper, `data/america-in-one-room-2019/papers/a1r-2019-paper.pdf`,
Tables 1–4, supplies 92 party-specific means for 23 of these policy items.
Complete substantive pairs reproduce 88 means to two decimal places, or one
where only one is printed. Table 1 displays two-decimal values with a trailing
zero; the comparison uses their two-decimal granularity.
The remaining four are the two Republican means for refugee restrictions (Q2A)
and the Paris Agreement (Q3A). Including the post-wave code −8 as a numeric
rating reproduces all four printed means:

| Item | Valid paired N | Correct initial / post means | N including −8 | Initial / post means including −8 |
| --- | ---: | --- | ---: | --- |
| Refugee restrictions (Q2A) | 126 | 7.023810 / 4.825397 | 127 | 7.047244 / 4.724409 |
| Paris Agreement (Q3A) | 108 | 3.759259 / 4.657407 | 109 | 3.724771 / 4.541284 |

Table 1 (PDF p.8, printed p.1471) reports 7.050 and 4.720; Table 2
(PDF p.9, printed p.1472) reports 3.7 and 4.54. The codebook explicitly labels
−8 as “Multiple responses” for `T2Q2A` and `T2Q3A` (lines 3945 and 4080).
Physical source row 2953 has `D1=2`, `GROUP=3`, `Q2A=10`, `T2Q2A=-8`;
row 1779 has `D1=2`, `GROUP=29`, `Q3A=0`, `T2Q3A=-8`.
These identities use one-based data rows excluding the header. Reproduction
restricts `CONDITION=1`, `POST=1`, nonmissing `GROUP`, `D1=2`, and valid
initial/post substantive responses; the comparison then admits post −8.

This is numerical evidence consistent with including a nonresponse code in the
published calculation, not recovery of the authors' analysis code. Keep the
current downstream rule excluding −8, 77, 98 and 99. Five −8 post-policy cells
occur across three people, all Republicans. The other cells are row 1779's
`T2Q2B` and `T2Q6C`, and row 1944's `T2Q6F`. Their codebook labels also identify
multiple responses. No recode is needed to imitate the publication.

All ten immigration support percentages in the retained executive summary
(PDF p.2) reproduce with support defined as 6–10 and unweighted valid-response
denominators. The paper's foreign-policy Table 5 is outside this numerical
comparison; checking scales for all 47 items does not establish reproduction
of every published statistic. Comparison files are retained under
`audit/corrections/america-in-one-room-2019/`.

One completer (source row 2944, group 26) gives “no opinion” on all 47 post
policy items but answers other post questions (`T2Q1=6`, `T2PK1=1`, `T2D1=1`).
Retain this person with missing policy attitudes: the questionnaire is observed.
Across the 49,162 item-wave cells, there are 47,009 valid responses, five multiple
responses, 1,980 no-opinion responses and 168 skipped responses. The current
reader handles these correctly. No person, answer, scale or weight is changed.

### A1RC-01 — label the published climate cohort as completed (corrected)

The [NORC methods report](../data/a1r-climate-2021/design/a1r-climate-methods.pdf),
Table 1 and its footnotes, counts 1,021 treatment respondents who attended at
least two virtual events and were invited to the post survey. Of these, 962
completed the post survey and all four sessions. The source file has 962
`P_DELEGATE == 1` rows. A further 59 have `FINAL_ATTEND` codes 5–7: six
attended four sessions, 45 attended two or three, and eight attended two or
three. Together with the 962 code-8 cases, these reproduce 1,021. Session
flags show 1,146 treatment respondents attended at least one session; some
other noncompleters have assigned `ROOM` values but no recorded session.
Two `FINAL_ATTEND == 10` cases (IDs 23725 and 27194) show two or three
recorded sessions yet are outside NORC's 1,021-person post-invitation count;
the file does not explain their exclusion. Therefore simply testing whether
the session sum is at least two would produce 1,023, not the reported 1,021.
The user approved labeling the existing 962-person cohort **completed**, rather
than expanding the analytical cohort or adding separate session and eligibility
fields. The participant export now uses `arm == "completed"` for these 962
people and `arm == "invited_noncompleter"` for the other 7,018 treatment-frame
respondents. The existing `panel` indicator remains unchanged: 962 completed
delegates and 671 controls have paired surveys. All response values, scores,
weights, group identities and paired-analysis membership remain unchanged.

The common `attended` field remains true for the 962 completers, whose actual
attendance is documented by the report, and false for the 834 uninvited controls.
It is null for the other 7,018 invitees: not completing the study does not establish
nonattendance. This deliberately leaves their attendance unclassified in the
canonical analytical view; source session records remain available unchanged.
The phase view records their attendance status as unknown. Downstream readers
must accept the explicit completed arm and describe the climate baseline
comparison as completers versus other invitees, not attendees versus nonattenders.
The previous comparison's people and scores do not change. Their mean baseline
eight-item score is 0.685551 for the 962 completers; the alternative source cohorts
would be 0.679726 for 1,021 report-qualified people and 0.656959 for all 1,146
people with recorded sessions, but neither is substituted into the current analysis.

The [knowledge report](../data/a1r-climate-2021/reports/a1r-climate-knowledge.pdf)
lists eight before/after correct-response percentages. Restricting to the 962
complete delegates, the source `Q17:Q24` and `T2Q17:T2Q24` answers scored by
the keys in `metadata/items.csv` reproduce all 16 percentages to one decimal
place using `WEIGHT1`. For example, Net Zero is 68.3% → 80.1% and fossil
fuels is 54.0% → 64.5%. The unweighted percentages do not match. `WEIGHT2`
also does not match; `WEIGHT1` is the report's relevant national weight for
this comparison. The later `T3` questionnaire is a distinct follow-up wave.

### A1RC-02 — retain observed climate-poll gender in the participant export (corrected)

The climate source has baseline `GENDER` code 1 or 2 for all 8,814 people.
Its follow-up `T3GENDER` agrees with baseline for all 1,590 rows where it is
observed. The publicly retained [2019 America in One Room
codebook](../data/america-in-one-room-2019/codebooks/a1r_codebook.tab)
labels the same AmeriSpeak `GENDER` field 1 male and 2 female; NORC's later
[AmeriSpeak profile codebook](https://amerispeak.norc.org/content/dam/amerispeak/supporting-documents/Amerispeak%20Profile%20Data%20Codebook.pdf)
uses the same two-code direction. The 2021 poll-specific value-label file is
not retained, so these related primary sources establish the direction rather
than a direct 2021 label. The participant export previously set `female`
missing for every climate respondent. It now maps `GENDER == 2` to one,
with assertions for the observed codes and cross-wave agreement. No
attendance flag, response, score, sample or weight changes. Current
`dp-learning` climate analyses do not use `female` as a covariate.

### A1RC-03 — distinguish factual-item nonanswers from substantive responses (corrected)

The recovered [original preparation script](../data/a1r-climate-2021/scripts/replication-data-preparation.do),
lines 355–399, records Q19–Q24 options and nonanswer labels: 77 “Couldn't say,”
98 “SKIPPED ON WEB” and 99 “REFUSED.” Across all three retained waves, 16,580
item cells in each of the selected-wave and phase tables change from `answered`
to `non_substantive`. Every raw code, correctness value, score, denominator and
person remains unchanged. The catalog keeps offered response 77 among the
options and records administrative codes 98/99 in the coding note.

This evidence applies to Q19–Q24. The script does not supply the corresponding
missing-code labels for Q17/Q18; do not extend those labels by analogy. Their
existing scoring is retained pending a fielded instrument or explicit codebook.

A renewed public-source search on September29 checked the twelve-file
[replication deposit](https://doi.org/10.7910/DVN/IIOG1S), its DDI variable
metadata, the journal’s online supplement and official Stanford/NORC materials.
The deposit contains no questionnaire or codebook; all six Q17/Q18 source-wave
fields have no category labels in its variable metadata. Actual codes are
1,2,3,77,98;99 does not occur in those fields. The retained
[NORC methods report](../data/a1r-climate-2021/design/a1r-climate-methods.pdf),
PDFp.7, establishes that Stanford received final questionnaires in both
programming and simple Word formats, plus SPSS/Stata/CSV data. The precise
missing evidence is therefore a delivered questionnaire or labeled source
file, rather than a claim that the study never documented these questions.
No request has been sent. Do not borrow Q19–Q24’s labels for Q17/Q18.

### A1RC-04 — reproduce the climate report's attitude ratings (checked)

The retained `data/a1r-climate-2021/reports/climate_results.pdf` reports 93
rating items, including all 72 items used by the downstream attitude analysis.
For the 962 respondents coded `FINAL_ATTEND == 8`, all 93 initial means,
93 later means and 93 changes reproduce within the report's three-decimal
rounding. Reproduction requires each item's respondents with substantive
answers at both waves and the supplied `WEIGHT1`. Separate available-wave
samples do not generally reproduce those printed means. Codes 77, 88, 98 and
99 are excluded from the 0–10 substantive range; observed source values remain
unchanged.

`scripts/review_climate_attitudes.R` extracts the printed values and checks
all 279 comparisons; `audit/corrections/a1r-climate-2021/attitude_report_comparison.csv`
retains the observed-wave and paired counts, reproduced statistics and reported
values. Independent Python calculations also reproduce the paired weighted
means. This identifies how the report was calculated; it does not select
weights or a missing-data convention for future analyses. No attitude recode
is adopted from this comparison.

### A1RC-05 — restore the original room-plus-schedule group identity (approved)

Before this correction, `R/analysis_tables.R` set climate `small_group_id` to `ROOM` alone.
Among the 962 completed delegates, there are 58 distinct room labels but 105
room-by-`T2P_OPTION` combinations. Forty-seven room labels occur in both
schedules, affecting 862 people. Consequently, using room alone combines
participants who deliberated in separate sessions.

The original authors' retained preparation script explicitly states that there
were 105 groups across weekday and weekend schedules and constructs
`egen groupid = group(room t2p_option)`; see
`data/a1r-climate-2021/scripts/replication-data-preparation.do`, lines 137–139.
The current `dp-distortions` OOS adapter already combines these two fields.
The approved upstream correction uses the same composite identity and preserves
all people, answers, weights and eligibility. The effect on analyses consuming
upstream group membership is quantified below. On September 29 the user directed
us to defer to the original script. Both canonical participant tables now use
`ROOM_T2P_OPTION`, with nonmissing room and a verified schedule required for
completers. The frozen comparison remains evidence of the before/after change;
the downstream manuscript has not been regenerated for this correction.

**Executed counterfactual, September 29, 2026.** The candidate starts from
dp-data `8bcd1de` and changes only `small_group_id` for the 962 completers in
each of `analysis_participants` and `analysis_phase_participants`. All thirteen
analysis schemas and every other column are identical; all other upstream
output files are unchanged apart from the two file hashes in the manifest.
The schedules contain 537 and 425 completers. Current group sizes of 7–35 become
2–18. Room-only grouping incorrectly counts 4,197 pairs of people from different
schedules as groupmates. The candidate IDs and an independently reconstructed
mapping yield exactly the same partition.

Using the current dp-learning code at `2880c14`, all eight mixed-model samples
stay unchanged. The core sample remains 8,486 people, while its group count
increases from 576 to 623. Among the 962 Climate completers, 862 group sizes,
851 leave-one-out knowledge means and 803 leave-one-out female shares change.
The pooled core coefficient on peers' initial knowledge moves from .109899 to
.107743. The Climate-only peer-knowledge association moves from .006653 to
.052641; both group-bootstrap intervals include zero. These are associations,
not estimates of causal peer effects.

The individual scores are unchanged, so Climate's mean gain remains
.122011 (12.2011 percentage points). With 999 bootstrap draws, its group-based
95% interval changes from [.108432, .135611] to [.111078, .134601]. The unweighted
completer-minus-control gain difference remains .093137, with its interval
changing from [.074394, .111273] to [.076753, .110378]. All 962 completers and
671 controls remain in that comparison. The 845-person three-wave retention
sample and its mean gains also remain unchanged, while its group count and
uncertainty change. Existing weighted-control comparisons were checked without
selecting a new weighting policy.

These are isolated comparisons of the current and proposed group definitions,
not a regenerated paper. All mixed-model point fits converge; their full
regression bootstrap has not been rerun. The Climate gain, peer, control and
retention comparisons use 999 draws each. Exact results, membership mappings,
all-column comparisons and input provenance are in
`audit/corrections/a1r-climate-2021/`. The retained `learning-impact.R` reproduces
the downstream comparison from either the pre-correction or corrected data and
the stated learning revision, writing only to the requested evidence directory.
It reconstructs the room-only comparison from raw fields when necessary:

```sh
Rscript audit/corrections/a1r-climate-2021/learning-impact.R \
  /path/to/dp-data /path/to/dp-learning /tmp/climate-group-review
```

It uses dp-learning's existing dependencies. The group-membership correction is adopted. Its regression checks compare every
completed delegate against the independently reconstructed membership mapping
and require 105 groups with sizes 2–18. No knowledge or attitude score changes.

### AMR-01 — six-country knowledge scoring checked against the report

The [final report](../data/amr-2024/reports/amr-final-report.pdf), Knowledge
Gains, reports six questions in six countries. The source has 2,419 unique IDs,
each observed at `Time` 0 and 1: 1,280 attendees and 1,139 controls. Independent
scoring reproduces all 4,838 canonical scores and all 29,028 raw and scored item
responses. IDs, country, arm, weight, gender and education are stable across waves.
There are no duplicate person-wave keys.

Using the supplied `Weight` within each country's attendee arm gives these
mean gains in percentage points:

| Country | Unrounded gain | Gain to one decimal |
| --- | ---: | ---: |
| Brazil | 7.101298 | 7.1 |
| Colombia | 7.107786 | 7.1 |
| India | 17.502200 | 17.5 |
| Indonesia | 6.966793 | 7.0 |
| Nigeria | 30.645253 | 30.6 |
| Tanzania | 3.499111 | 3.5 |

The Tanzania result falls below the report summary's stated range of 3.6–7.1
points for Tanzania, Colombia, Brazil and Indonesia (printed p.50; PDF p.52). Preserve the source calculation rather than alter scores to match
that summary. Nigeria's superbug item gains 44.1 points, India's infection
prevention item gains 24.9, and Brazil's statements-about-antibiotics item gains
16.3, matching the highlighted item results. Tanzania's first-item change is
−1.463932 points. Its separately rounded endpoints are 45.7% and 44.3%; their
difference gives the report's −1.4 rather than the unrounded change rounded
to −1.5.

The recovered [deposit README](../data/amr-2024/codebooks/deposit-readme.md)
limits each weight to its `weight_group`, defined by country and arm. These
are twelve separate weighting populations, not a supplied pooled six-country
population weight. The canonical fields retain country, arm and the unchanged
weight; analyses must select the relevant population before applying it.

The [version 2 paper](../data/amr-2024/papers/amr-paper-v2.xml), Table 3,
reproduces all six country-by-arm counts. Table 4 reports 3,127 invitations
and 1,280 attendees. The 1,847 invited nonattenders are absent from this deposit.
Current attendance labels match the reported attendee sample, but these records
cannot identify a full invitation intention-to-treat effect. No individual
assignment or attendance category is changed by this audit.

### AMR-02 — populate the observed gender field (corrected)

The two-wave source contains a stable binary `gender` for all 2,419 IDs:
1,229 have code 0 and 1,190 have code 1. Applying the source `Weight` to
`gender == 1` closely matches the [final report's](../data/amr-2024/reports/amr-final-report.pdf)
female percentages by country and arm. For example, the report gives Brazil
control 50.6% and treatment 51.3%; the source gives 50.6% and 51.2% at one
decimal from its published weight values. India control and treatment give
30.8% and 32.5%, versus the report's 30.6% and 32.5%; the small control
rounding gap does not change the code direction. The participant export had
set `female` missing for every AMR respondent despite this observed field.
It now maps code 1 to one and code 0 to zero, with assertions that gender is
binary and stable across waves. No response, score, sample or weight changes.
The current `dp-learning` AMR analyses do not use `female` as a covariate, so
their present numerical results are unchanged; future analyses can use the
source-backed demographic field.

### AMR-03 — source ages differ across interviews (retained source limitation)

Four Indonesian control respondents have inconsistent source ages: `ID_c_91`
48 to 47, `ID_c_116` 53 to 51, `ID_c_156` 45 to 49, and `ID_c_165` 41 to 40.
Their source education, weight, country and treatment category remain constant.
The current canonical AMR analysis does not export age, so this changes no
current value or estimate. Preserve both source values. Before adding age,
consult the original field returns; baseline age is the natural measurement
for a baseline covariate, but neither interview is proven correct by this file.

### AMR-04 — preserve verified phases and recovered measurement evidence (implemented)

The [version 2 paper](../data/amr-2024/papers/amr-paper-v2.xml)
([DOI 10.12688/wellcomeopenres.24803.2](https://doi.org/10.12688/wellcomeopenres.24803.2)),
Methods, places baseline interviews before random assignment and invitation.
Its design description places the final questionnaire at the end of deliberation.
Source `Time == 0` therefore maps to t0 (`pre_arrival`), and `Time == 1` to t2
(`post_deliberation`). The phase tables now retain 4,838 scores and 29,028 item
responses for 2,419 people, with 2,419 scores per wave. No separate arrival
measurement is established. Timing is `documented_design`; exact interview
dates, individual lags and survey mode remain unknown. Online deliberation does
not itself establish survey mode. All selected-wave scores, answers and samples
are unchanged numerically.

The [English questionnaire and extended data](../data/amr-2024/questionnaires/survey-and-extended-data.pdf),
expert Table 18 (PDF pp.39–40), supports keys 4/4/5/5/4/5. The recovered
[PDF codebook](../data/amr-2024/codebooks/harmonized-codebook.pdf),
`knowledge_1` through `knowledge_6` (PDF pp.32–35), and
[workbook codebook](../data/amr-2024/codebooks/harmonized-codebook.xlsx)
agree. These sources now supply the catalog's answer options and keyed text.
They establish harmonized coding, not the equivalence of unrecovered
local-language field forms.

There is a source-document conflict: questionnaire Q21 (PDF p.11) asks about
infection prevention but repeats the preceding question's antibiotic-use options.
Expert Table 18 and the codebook instead list animal vaccination, handwashing,
influenza vaccination, hygienic food preparation and “all of the above.” They
agree on key 5. Preserve that key and all scores, record both versions, and seek
the fielded forms before attributing the copied options to respondents.

All six knowledge responses are missing in the harmonized source for 46
person-interviews: 13 control baseline, 17 control post, nine attendee baseline
and seven attendee post. This does not establish that respondents literally
left every item blank: the questionnaire offers don't know, and the harmonized
deposit collapses that response and other nonanswers to missing. Other survey
answers establish that all 46 questionnaires were observed. Their knowledge
scores remain zero under the approved rule. Form-presence checks use actual
questionnaire answers, excluding IDs, demographics, arm labels and weights;
a wholly unobserved synthetic form remains unknown rather than becoming an
observed zero. Original missingness reasons cannot be recovered from this deposit.

### MAR-01 — derived post knowledge zeros need an item-level and wave bridge

The public `participants.csv` is a 146-person projection of a 2014 derived
analysis object. It has 15 groups but does not itself contain knowledge-item
answers, original `knowt3` values or independent field-return IDs. The original
merged SPSS source has now been recovered and compared in MAR-02 below. The archived
`legacy/poll_scripts/greece.R` sets `t2know` to `knowt3` when observed and to
zero when `knowt3` is missing. Thus the exported zero combines genuine
zero-correct scores with source missingness, without a flag that separates
them. The `t1know` mean is 0.35812, with two zeros; the `t2know` mean is
0.35910, with 27 zeros. All 27 have an observed `attextreme2`, but that field
summarizes arrival attitudes, so it does not establish completion of the
T3 knowledge battery. Dropping all 27 zeros raises the `t2know` mean to
0.44058 among 119 people; this is a sensitivity calculation, not a recode.

The retained [knowledge distribution](../data/marousi-2006/knowledge-item-distributions.pdf)
labels its seven-item factual index T3 and counts 138 people, only one with a
zero. Its printed frequencies imply mean 0.42754, matching the 42.8% post
factual-knowledge result in the [contemporaneous paper](../data/marousi-2006/papers/returning-deliberative-democracy-athens.pdf),
Table 4. The paper distinguishes 153 arrival respondents from 138 final
questionnaires. It reports 39.4% before, whereas the 146-person file's
baseline mean is 35.8%. At the initial audit these count and mean differences established a version or
cohort discrepancy but did not identify which exported zeros represented
blank items or absent questionnaires. MAR-02 below now separates all 27 using
the original responses. The historical participant file remains an unchanged comparison source.
The user-approved MAR-02 correction is applied in the canonical analysis
scores; no row is dropped to force a report match.

### MAR-02 — Original source bridges the report; partial quizzes were zeroed as whole scores

**Status:** investigated and user-approved on 2026-09-27; implemented in
`R/analysis_tables.R` and rebuilt canonical analysis scores. The user's
scoring instruction is explicit: an individual blank
or don't-know item counts as wrong, including a wholly blank quiz within an
otherwise observed questionnaire. An entirely absent questionnaire is a
separate wave state; do not infer absence merely from a quiz score or blank
quiz items.

**Wave names agreed with the user.** Marousi's canonical descriptions use
t0 for telephone/pre-arrival, t1 for arrival, and t2 for post-deliberation.
The source file calls them T1/T2/T3. Keep original field identifiers as
provenance and translate explicitly; source T3 here is not a later follow-up.

| Canonical wave | Role | Source wave and index fields |
| --- | --- | --- |
| t0 | Pre-arrival telephone interview | T1: `KNOWT1`, revised `KNOWT1_2`; `P_` responses |
| t1 | Arrival / start of deliberation | T2: `KNOWT2`, revised `KNOWT2_2`; `AR_` responses |
| t2 | Post-deliberation | T3: `KNOWT3`, revised `KNOWT3_2`; `F_` responses |

There is no established later follow-up in this recovered Marousi source.
The bridge CSV uses phase names such as `telephone_score_revised` and
`departure_factual_correct_count`; the frequency transcription preserves
`source_wave = T3` with `canonical_wave_id = t2` and
`wave_role = post_deliberation`. Existing historical files and canonical
exports other than the explicitly migrated Marousi scores retain their
existing selected-pre/post labels. A general schema
should identify each questionnaire instance, its role and chronological order,
its original source label, and its date or elapsed time when established.
Multiple pre-event measurements and multiple follow-ups require distinct
instance IDs with the same role. Use t3/t4 for successive later follow-ups
where present, recording their
dates or time since deliberation. These labels identify follow-up order,
not a fixed interval shared by every poll. For multiple pre-arrival
measurements, use
distinct instances such as t0_1/t0_2 with role `pre_arrival`; keep t1/t2
as the arrival/post-deliberation anchors. Missing phases do not cause later
phases to be renumbered, and an online poll does not acquire an invented
arrival questionnaire.

The same canonical phases must mean the same thing across polls: t0 is
pre-arrival, t1 arrival/start, and t2 immediate post-deliberation. Telephone
is an interview mode, not the definition of t0. A downstream service must
select its intended pair explicitly; the user's current dp-learning
convention is arrival-to-exit (t1 to t2), with telephone/pre-arrival-to-exit
(t0 to t2) a separate available comparison. If a poll lacks t1, mark that
comparison unavailable rather than substituting t0. Marousi's previous
score-only export labeled its telephone baseline t1. The approved build now
retains that telephone value as t0, adds arrival as t1, and rebuilds exit as
t2. This explicit migration preserves the meanings of all three measurements.

Preserve the full recovered 1,275-row source frame, including people who
never attended, and every available pre-arrival response. The 146-person
grouped view and any paired-wave view are analysis samples, not the source
universe. Separate invitation/assignment, attendance, questionnaire presence,
and known group membership. This allows comparison of pre-arrival answers
between attendees and nonattendees, and analysis of post-wave attrition;
it does not by itself establish causal selection bias. Unestablished
attendance remains unknown, and nonattendance must not erase t0 responses.

**Recovered source and identity bridge.** The original
`vault/cdd/data/Greece/data/Greece_data_all_final.sav` is now retained unchanged
as public `data/marousi-2006/survey.sav`, with `variables.csv` and
`value-labels.csv` alongside it:
1,275 source rows, 1,026 columns, SHA-256
`cc79623a9432a5d4d0bc9b8c3ff1ea3eebaa5021799c80631048f261ca9a651f`,
matching its archive inventory. The July 5, 2006 snapshot
`vault/cdd/data/Archive/cddrep-jul-5-2006.zip` also contains the original
293-column `Greece/2006/data_all_final.sav` (SHA-256
`a55261bc6e7a6d896f2f57524f35a055f9b55ac3575dfbd099e100fd6458c373`),
whose raw fields match the expanded source by stable baseline ID. This
establishes an early source snapshot; no separate wave returns or original
merge instructions were found in its Greece subtree. The expanded file
contains telephone `P_`, arrival `AR_`,
departure `F_` responses, stable baseline `P_Q1_0`, wave codes, flags and both
original and revised knowledge indices. Keep the authored merged source rows;
do not generate an identity join from equal scores.

Applying the original script's nonmissing `GROUP` filter selects exactly the
146 exported records. Original filtered row order reproduces synthetic
historical `caseid = 79999 + row`, `pollgroup = 200000 + GROUP`, age, female,
original telephone `KNOWT1`, and the old departure formula
`ifelse(is.na(KNOWT3), 0, KNOWT3)` with zero discrepancies. Baseline `P_Q1_0`
is unique across all 1,275 source rows. This is a verified bridge to the
**existing authored source rows**, not proof that every original cross-wave
merge is correct. The [numeric source bridge](../audit/corrections/marousi-2006/source_bridge.csv)
retains source row, all three IDs, group, wave flags, old/revised indices,
seven-item correct counts, blank/DK counts and observed raw-wave field counts.
It includes unasked source rows whose stored revised scores can be zero;
those zeros are not automatically observed measurements.

**Report reconstruction.** Seven factual items are mayor's name, population,
number of Mall stores, waste per resident, immigrant share, municipal-bus
coverage and Metro users. The retained telephone questionnaire locates them
at Q18 and Q27–31/Q33; Q32 merely asks whether the respondent heard about the
Metro tender and is not part of this battery. The original authored
correctness fields are `KQ1_T3`, `KQ2POPT3`, `KQ3STOR0`, `KQ4WAST0`,
`KQ5PERT3`, `KQ6TRAN0`, `KQ7METR0` at departure, with analogous telephone
and arrival fields. Counting correct flags over seven, with individual missing
flags wrong, reproduces revised `KNOWT1_2`, `KNOWT2_2`, `KNOWT3_2` within
float32 storage precision (maximum difference 2.55e-8). This checks scoring
construction; it does not independently establish every substantive factual
key. The printed instrument lacks a full answer key, so those original keys
are preserved rather than invented from the aggregate targets.

The [distribution PDF](../data/marousi-2006/knowledge-item-distributions.pdf),
p.1, explicitly labels the factual T3 index revised, with missing/don't-know
answers wrong. Its eight-bin distribution for zero through seven correct is
1/21/29/35/33/17/2/0, N = 138. Source `T3PART == 1` selects exactly 138 records
and revised `KNOWT3_2` matches every frequency. The
[paper](../data/marousi-2006/papers/returning-deliberative-democracy-athens.pdf),
Table 4, PDF/printed p.17, explicitly treats unanswered and don't-know
knowledge items as incorrect. On those same source rows:

| Source wave / index | Total correct | Denominator | Mean correct |
| --- | ---: | ---: | ---: |
| Telephone t0 / source `KNOWT1_2` | 348 | 138 × 7 | 36.024845% |
| Arrival t1 / source `KNOWT2_2` | 381 | 138 × 7 | 39.440994% |
| Post-deliberation t2 / source `KNOWT3_2` | 413 | 138 × 7 | 42.753623% |

Arrival-to-departure gain is 32/966 = 3.312629 percentage points. A paired
t test on these 138 revised source scores gives p = 0.01714023, reproducing the
paper's 39.4/42.8/+3.3/p = 0.017. The original telephone index does not reproduce
its before figure. Thus a report-compatible **arrival-to-departure** measure
and the current **telephone-to-departure** measure require distinct wave
labels. Table 4 does not explicitly print its N or source variable names;
the joint means, exact post histogram and p-value establish the recovered
construction, not a license to rename the telephone wave as arrival.
The distribution file is only T3, not a set of individual T1/T2 records.
Its full frequency transcription is in
[report distributions](../audit/corrections/marousi-2006/report_distributions.csv).

Dropping people cannot repair the older export: all 146 contain only 367 post
correct answers, fewer than the report's 413 even before any exclusion. Its
maximum possible unweighted 138-person post mean is 37.991718%; its maximum
telephone-baseline mean on 138 rows is 37.267081%, also below 39.4. This rules
out sample exclusion, absent-quiz zeros and rounding as a complete explanation.

**Which zeros are wrong, and why?** All 27 exported departure zeros originate
in missing original `KNOWT3`; none is a literal observed zero in that index.
Ten have `T3PART == 1`, an observed departure ID, 25–114 observed raw
`F_` questionnaire fields, and 1–6 blank factual items. They answered other
knowledge items correctly. Treating a missing whole original index as zero
lost those correct answers. The revised seven-item scores are:

| Historical caseid | Source baseline ID | Correct /7 | Blank quiz items | DK quiz items |
| --- | ---: | ---: | ---: | ---: |
| 80000 | 30154 | 2/7 | 1 | 3 |
| 80012 | 7889 | 3/7 | 1 | 0 |
| 80020 | 7336 | 3/7 | 1 | 0 |
| 80037 | 11816 | 1/7 | 1 | 5 |
| 80054 | 30592 | 1/7 | 6 | 0 |
| 80060 | 5215 | 5/7 | 1 | 1 |
| 80061 | 31650 | 3/7 | 2 | 0 |
| 80075 | 13799 | 4/7 | 1 | 1 |
| 80113 | 4934 | 1/7 | 1 | 0 |
| 80117 | 16892 | 1/7 | 4 | 1 |

These ten add 24 recovered correct answers. Every other observed departure
score in the current export agrees with the revised source to storage
precision. The other 17 zeros have missing `F_CODE`, missing `T3PART`, and
**all 115 departure source fields missing**, including the ID; the
answer-only check separately finds all 114 departure fields missing. This independently
establishes absent departure records in the merged source; the diagnosis is
not based on all seven quiz items being blank. Keep their telephone responses,
arrival responses and memberships, and set a missing departure score and
false paired-panel flag. All 146 grouped people retain their row and membership.
A legitimate all-wrong departure quiz still scores zero: the report includes
one, source ID 31916, outside this grouped export.

The exact post-score bridge is:

| Step | People in denominator | Correct answers | Mean post score |
| --- | ---: | ---: | ---: |
| Current grouped export, missing whole indices filled 0 | 146 | 367 | 35.909980% |
| Recover correct answers in ten partial quizzes, retaining 17 absent-wave zeros for diagnosis only | 146 | 391 | 38.258317% |
| Use observed departure questionnaires among the same grouped people | 129 | 391 | 43.300111% |
| Include nine observed departures without a recorded group, matching report cohort | 138 | 413 | 42.753623% |

The nine additional departures contribute 22 correct answers. Do not invent
nine group assignments or alter the current grouped sample to make its mean
42.8%. A full respondent/wave export can preserve these questionnaires with
unknown group, while group analyses need an explicit membership requirement.
The [approved comparison](../audit/corrections/marousi-2006/approved_values.csv)
freezes all 146 historical telephone/post scores, approved post scores and
reasons. Ten substantive post scores change, seventeen become missing and
119 agree within original float32 precision; exact integer-over-seven
reconstruction can remove those original storage-rounding differences.

**The report comparison itself counts five absent arrival waves as zero.**
Source wave flags count 153 arrival and 138 departure, with 132 flagged at both,
21 arrival-only and 6 departure-only. One of the six departure-only flags,
source row 117 / baseline ID 14825, nevertheless has 67 raw arrival answers
and revised arrival score 5/7, despite missing `AR_CODE` and `T2PART`. Thus a
wave flag or ID alone does not reliably establish absence. Using actual raw
arrival responses finds 133 observed arrival questionnaires among the 138
reported departures. The other five (source IDs 32832/33909/21434/31916/30357)
have all 102 arrival source fields absent, including the ID (all 101
answer-only fields absent), but stored revised `KNOWT2_2 == 0`.
Those stored zeros enter the reconstruction of 39.4% before and p = 0.017 above.
For the 133 with actual answers at both waves, corresponding means are
40.923738% arrival and 43.179377% departure, gain 2.255639 percentage points;
the analogous paired test gives p = 0.07901303. This is a precise source-level
replication diagnostic, not a paper/model revision or authorization to change
its claims. An absent arrival questionnaire must not be confused with a
partially answered or wholly blank quiz in an otherwise observed questionnaire.
The current telephone baseline is unaffected by this report-arrival issue.

**Original cross-wave IDs need further verification.** All 153 observed
`AR_CODE` values agree with same-row baseline `P_Q1_0`. All 138 `F_CODE`
values are unique, but 16 differ from same-row baseline IDs (15 inside the
current 146 grouped people). They are other valid baseline IDs and form two
ascending-code chains. For example, source row 2 is baseline/arrival 8805
but departure 9046; baseline 9046 is another source row/group. The discrepancy
is present in all four earlier `data_all_final` SAV/DTA variants: joining
by unique baseline ID gives zero differences across 293 raw columns,
including every departure code. It therefore predates the modern pipeline;
no source return or linkage instruction establishes whether the departure
code or the original merged association is wrong. Preserve the authored
merged-row association and both IDs. Do not reassociate entire departure
waves merely by matching `F_CODE` to baseline IDs. Reproducing the report
alone does not validate those 16 source joins.

**Other batteries remain separate.** The distribution file's two absolute
party placements plus five candidate placements reproduce the paper's
36.3% pooled departure result. Its 17-unit absolute issue-placement index
averages 33.248083%, which does not match the paper's 34.2%; the label excludes
candidate midpoint placements, and relative issue scores use 42/43-unit
versions. These are scoring/version questions for other measures, not a
reason to change the seven-item factual denominator. No new positional
measure or key is adopted here.

**Approved implementation.** All 146 current people and memberships remain.
The canonical reader verifies the original grouped row-order bridge against
historical case IDs, group IDs and baseline/old post scores. Questionnaire
presence uses the full raw arrival/exit answer fields excluding ID-only
columns. Seven authored binary correctness flags determine each observed
arrival/exit score, with individual blanks and don't-know answers wrong.
The ten false zeros recover 24 correct answers; seventeen entirely absent
exits have missing score/correct count, zero observed items, and `panel = FALSE`.
An observed all-wrong quiz remains a measured zero. The paired count is 129.

Canonical knowledge scores now expose t0 telephone, t1 arrival and t2 exit,
146 rows per phase. Telephone values remain numerically unchanged; arrival
is separately named, and all 146 grouped arrival questionnaires are observed.
Stable exported respondent IDs remain the historical case IDs, with verified
original source-row locations and preserved group IDs. The complete original
1,275-person source, including nonattendees and nine departures without a
known group, is publicly retained unchanged; the canonical grouped analysis
view still contains 146 people. No group assignments or disputed departure
identity links are invented. Historical `participants.csv` is unchanged and
the old downstream zero-score heuristic is recorded as superseded.

The report reconstruction, including its five absent-arrival zeros, remains
an audit benchmark rather than a redefinition of observed arrival responses.
Other polls' scores and the historical 21-poll polardata are unchanged. Current
dp-learning excludes this `score_only` source; admitting it or fitting a new
comparison is a separate downstream analysis decision.

### MAR-03: Publish the original seven-item answers at each verified phase

The phase-item export now retains all 1,275 original source rows, seven items
and three phases: 26,775 rows. The selected 146-person score-only view and
its historical IDs remain unchanged. The broader phase view retains 159 people
with positive attendance evidence, 154 observed arrival forms and 138 observed
exit forms. Telephone forms are observed for all 1,275 source records. The
existing participant and score tables are unchanged; item availability does
not automatically add people to a downstream analysis cohort.

`metadata/marousi_knowledge_items.csv` identifies every raw response and authored
correctness field, telephone question number, offered/source-coded responses,
wave role and identity basis. The seven preserved source keys are 1/2/2/3/1/4/4.
Every raw response and source correctness flag is checked against the public
`data/marousi-2006/survey.sav`; recomputed phase scores agree within the original
float32 tolerance. The retained telephone questionnaire supplies exact wording.
Arrival/exit field labels identify matching topics but do not establish verbatim
fielded wording or independently verify substantive factual keys.

Raw answers, source labels, canonical correctness, DK and questionnaire presence
are distinct fields. A declared DK is scored zero and labeled `dk`. Six telephone
responses labeled only `na` are scored zero under the approved observed-form rule,
with `unclassified_nonanswer` retained rather than inventing DK or refusal. An
observed blank quiz item scores zero; an absent questionnaire has missing item
correctness. Invalid nonmissing codes would remain missing. The mayor question
asks for an open name: its two source-coded categories are not two offered
choices and must not imply a 50 percent guessing probability.

The authored row linkage is preserved. Sixteen departure IDs disagree with
baseline IDs; matching departure IDs to other baseline rows changes sixteen
scores and would move grouped arrival/exit gain from 2.547 to 2.088 percentage
points while increasing the paired count from 129 to 130. Original wave returns
or merge instructions are required before changing that linkage. Equal scores
or a report target do not supply identity evidence.

Marousi's original numeric SPSS source is unchanged. Four malformed variable
labels and six value-label names contain legacy Windows-1252 bytes. A nullable
`label_encoding` source setting now repairs only invalid UTF-8 label attributes,
preserving valid strings, response values and all other attributes. The ordinary
survey import recreates both UTF-8 dictionaries exactly; all 1,026 numeric fields
across 1,275 source records remain identical. No other source opts into this
encoding repair. The canonical item catalog gains seven definitions and the
phase-item table gains 26,775 responses; other analytical outputs are unchanged.

### TZ-01 — group assignment does not by itself establish treatment eligibility

The retained `participants.dta` has 2,225 rows: 2,002 labelled citizens, 121
elites and 102 moderators. Of the citizens, 2,001 have a recorded treatment
assignment (`z`), and 401 have `zdelib=1`. The separate
`tanzania_groups.tab` has 371 unique citizen IDs, each with group assignments
for both rounds. Exactly 370 are among the 401 assigned to deliberation; the
other 31 assigned citizens lack group rows. The remaining grouped person,
`HHID=240301`, has `z`, `zdelib` and the other arm flags missing. They have
round-1 group 24 and round-2 group 13. All 25 issue-rating fields selected
by the current out-of-sample reader are observed for this person at post,
and none at baseline. This supports preserving their recorded post answers
but does not establish how they entered the event sample. The
[working paper](../data/tanzania-2015/papers/tanzania-working-paper.pdf),
section 3.2, says 401 were invited and 370 complied in 25 groups. Its 370
therefore matches the intersection of the assignment and group files, while
the extra group row has no verified treatment-arm status.

The current `dp-distortions` out-of-sample reader explicitly retains all 371
grouped rows, including the one with missing assignment. A future canonical
upstream membership table should keep the literal group record and the
assignment status as separate fields. Determine whether `240301` was a late
attendee, a nonrandom participant, or an erroneous roster entry from the
original event and randomization records before changing the analysis sample.
Do not infer invitation or eligibility solely from a group number.

### TZ-02 — retain the observed sex field in the participant export (corrected)

The retained `participants.dta` contains a binary `male` field for 2,001 of
2,002 citizen records: 949 have code 1, 1,052 have code 0, and one is missing.
The [final report](../data/tanzania-2015/reports/tanzania-final-report.pdf),
Appendix B, Table B1, reports “Male” for 2,001 people with mean 0.474. The
source gives 949/2,001 = 0.47426, independently checking the field and its
direction. The canonical participant export previously set `female` missing
for all 2,002 citizens. It now maps `male == 0` to one and `male == 1` to zero,
while leaving the one unknown response missing. An assertion rejects any
unexpected observed source code. This only fills the existing sex-derived
field; it does not change source answers, arm assignment, group membership,
sample, knowledge index, or any historical aggregate. A rebuilt-table comparison
finds exactly 2,001 changed `female` cells, all in Tanzania, and no other
participant-column differences. The current `dp-learning` control analysis
excludes Tanzania from its item-based control panel, and its attendee model
requires proportion-correct scores that Tanzania does not have. The current
`dp-distortions` Tanzania reader uses its own source fields, so these existing
results do not change. The unresolved roster question in TZ-01 remains separate.

### TZ-03 — negative missing-component code excluded from the knowledge index

The first scored knowledge component, `H610` at baseline and `H611` at follow-up,
contains −99 alongside 0 and 1: 173 baseline and 25 follow-up records have −99.
The retained [original regression script](../data/tanzania-2015/scripts/replication-regressions.do),
line 452, identifies this component as “Heard about gas?” The
[working paper](../data/tanzania-2015/papers/tanzania-working-paper.pdf), PDF p.50,
and [appendix](../data/tanzania-2015/reports/tanzania_appendix.pdf), PDF p.11,
print H5_4: what respondents have heard about Tanzania's gas discoveries and
whether extraction or export has begun. The questionnaire labels code 99
“DON'T KNOW.” The conversion from that raw field to the derived −99/0/1
component has not been recovered; the code-number correspondence is not proven.
This is now a documented deposit boundary: the retained
[replication master](../data/tanzania-2015/scripts/replication-master.do), lines
12–20, explicitly excludes seven cleaning scripts because they contain personally
identifying information, including the baseline and panel cleaning scripts.
The public Dataverse V1.0 inventory contains 11 files: the master, three analysis
scripts, three auxiliary programs, three derived datasets, and the
[README](../data/tanzania-2015/design/replication-readme.txt). None supplies that
missing raw-to-derived recode. Recovering it requires a separately shared,
redacted recode or clarification from the authors; another search of this
same deposit cannot establish the conversion.

The numerical defect is independently reproducible: −99 enters the index as an
extremely low number rather than an incorrect answer or missing value. Rebuilding
all nine components with their baseline-control means and standard deviations,
averaging each respondent's available standardized components, then standardizing
that composite against baseline controls reproduces `H600` and `H601` to within
1.05e−14. This establishes that the extreme code affects the stored index;
it is not merely an unusual unused source value.

**Approved correction:** the user chose to treat −99 as missing, not as an
incorrect answer. The component is excluded from the available-component mean;
all other components and routing-related missingness retain their existing
rules. The build rejects any other nonbinary substantive component code.
Item means and sample standard deviations, followed by the composite mean and
sample standard deviation, are fitted on the same 1,000 baseline controls and
used for both waves. No calibration uses follow-up outcomes.

There are 173 affected baseline and 25 affected follow-up component values.
The affected people still have five to eight other baseline components and four
to eight other follow-up components. No score or paired respondent is lost:
2,001 baseline and 1,858 follow-up scores remain observed, with 1,857 pairs.
Recalibration changes all 3,859 observed scores. Holding the old calibration
fixed would change only the 198 directly affected scores. The unadjusted
paired deliberation-minus-control difference in mean gains changes from
0.208856 to 0.341257 standardized units; under fixed old calibration it would
be 0.216270. These are diagnostic contrasts, not the paper's adjusted or
clustered estimates. Recalibration changes the scale as well as individual
component contributions.

The earlier zero-coding alternative would produce 0.347182 and is retained as
**not adopted**, not silently substituted for the missing treatment. The
withheld raw-to-derived recode still prevents proving how the −99 values arose.
The source DTA and deposited H600/H601 remain unchanged comparison evidence.
The canonical source catalog now identifies the nine components actually used
in each reconstructed score rather than claiming to read H600/H601 directly.

The retained [review script](../scripts/review_tanzania_knowledge.R) independently
reproduces the deposited indices and both alternatives. The
[approved missing-treatment values](../audit/corrections/tanzania-2015/missing_values.csv),
[component counts](../audit/corrections/tanzania-2015/missing_components.csv) and
[calibrations](../audit/corrections/tanzania-2015/calibrations.csv) preserve the
old and corrected calculation. No standard proportion-correct interpretation
is imposed on this standardized index.

### TZ-04 — panel membership requires both selected measurements

Source `HHID == 240301`, canonical respondent `1323`, has missing baseline
`H600` and observed follow-up `H601`, but `analysis_participants.panel` was true.
The user-approved rule requires both selected measurements, reducing the panel
count from 1,858 to 1,857 while retaining all 2,002 people and the observed
follow-up. This is separate from TZ-01's unresolved treatment eligibility:
a group assignment does not supply a missing baseline or establish an arm.
The shared paired-analysis rule is distinct from deleting a respondent from the
source data. The same [review script](../scripts/review_tanzania_knowledge.R)
checks this identity and records the old and corrected panel counts in the
[audit summary](../audit/corrections/tanzania-2015/summary.csv).

### TZ-05 — borrowing uses five categories; include it with the other policy items (corrected)

The user approved adding `H260/H261` as the twenty-second policy item. The
question asks whether Tanzania should borrow against expected oil and gas
revenue and spend sooner, despite having to repay more than the amount
borrowed. Both released wave fields label five substantive categories:
1 strongly supportive, 2 supportive, 3 neutral, 4 opposed, and 5 strongly
opposed. The retained final report, printed p.64, Appendix H question 3,
explicitly describes the identical borrowing question as using a 1–5 scale
similar to the citizen instrument in Appendix G. All observed values in the
released pair are 1–5. The later journal supplement, printed p.5, instead marks
H2_6 with two asterisks, which its legend defines as seven categories. That
annotation remains conflicting evidence; it does not justify moving the
observed neutral category from 3 to 4.

`metadata/tanzania_attitude_items.csv` records all 22 semantic item names,
original wave columns, endpoints, source directions, missing codes and the
relevant group assignment. `make tanzania-attitudes` exports typed definitions
and long responses under `output/tanzania_attitudes/`. The source bytes remain
unchanged. All 2,225 original rows and both waves are retained, producing
97,900 response records. The 2,002 citizens receive the reviewed scales and
canonical `t0` household-baseline and `t3` delayed-follow-up labels. The 121
elites and 102 moderators retain their raw values and sample labels but have
`out_of_scope` status, missing normalized values, and no citizen phase labels.
Their separate designs have not been assumed equivalent to the citizen study.

For citizens, the fixed source endpoints map to 0–1 in the original direction;
borrowing therefore runs from strong support at 0 to strong opposition at 1,
with neutral at 0.5. System missing remains missing. The inherited OOS
exclusion set is −99, −97, 98 and 99: released DTA labels identify −99 as
no opinion/don’t know and −97 as refusal; the journal appendix's response-scale
legends on printed pp.1–2 specify 98 as refusal and 99 as no opinion. Among the
prior 21 items in the grouped cohort, only ten explicit −99 cells occur, all
in baseline H430/H440; the other three codes do not occur. Nonresponses are
never assigned midpoint or zero. No survey weight is applied. Original HHID,
physical source row, source hash, raw response and available value label remain
available alongside the normalized value.

The 371-person recorded group roster is preserved, including TZ-01's person
with no baseline or verified treatment assignment. The two roster columns
span four topical discussions: `group1` covers extraction/sales and
saving/spending; `group2` covers household transfers and public spending.
The preanalysis plan says reassignment occurred after the first day; the later
working paper, section 3.2, says after the second of four rounds. The earlier
final report's claim of reassignment after each round conflicts with these
sources. A recorded group is not treated as proof of invitation or attendance.
The final report, printed p.10, places telephone follow-up between May and July
2015. These are delayed outcomes, not immediate exit questionnaires.

Against the existing `dp-distortions` OOS reader, every one of the 15,582 long
response records for the prior 21 items has the identical normalized value,
missingness, HHID, item and group assignment. Those items retain 7,530 paired
respondent-item observations. Borrowing adds 360 paired responses across all
25 first-assignment groups (370 observed baseline and 361 observed follow-up),
raising the total to 7,890 and the group-item count from 525 to 550. This is an
approved expansion of the measured item set, not a change to any of the prior
21 items or the respondent cohort. Under the existing paired OOS calculations,
Tanzania's mean homogenization changes from −0.005110639 to −0.007462469;
mean directional polarization from −0.038309424 to −0.039400307; absolute
polarization from −0.007626856 to −0.005084460; and gender domination from
−0.005371478 to −0.007219525. These are item-set sensitivity comparisons,
not new causal estimates. Analytical weighting remains undecided (X15).

### NH-02 — Event year corrected; attendance needs reconciliation

Farrar et al., *Disaggregating Deliberation's Effects*
(BJPS 2010, DOI 10.1017/S0007123409990433), pp. 338–339, identifies deliberations
on **1–3 March 2002**, an initial interview sample of **1,032**, and **133**
attendees. The historical poll-details appendix labels this poll **2004**,
and the historical analysis has **132** people. The online LSE
PDF matches both archived copies byte-for-byte; it is not new contrary evidence
from a different paper version.

The baseline CATI script supplies an independent date check: its header is
January 17, 2002, and its invitation says the event begins on Friday, March 1.
March 1 was Friday in 2002 and Monday in 2004. This supports the paper's
2002 date for the airport/revenue-sharing event. The catalog year is corrected
to 2002, retaining the historical `new-haven-2004` ID and source paths.
This changes metadata only, not respondent values, aggregate fields, or sample.
The paper itself distinguishes attendance from its analysis sample: it reports
133 people showed up, then Table 1 analyzes 132, split 64 A-first and 68
R-first. The reconstructed workbook has 132 people in 16 groups; groups 1–8
contain 64 and groups 9–16 contain 68. These counts corroborate the analysis
cohort without identifying the extra attendee or proving the group numbers'
assignment labels. The one-person exclusion reason still needs a roster or
documented sample rule.

Preserve the current ID and cohort while checking group assignment and
completeness filters.
Establish which attendee is excluded and why. The paper's split-half experiment
has three measurement occasions: match the historical pre/post columns to those
occasions before comparing its Tables 1 and 3. Do not use the similarly named
October 2005 New Haven education briefing as this event's instrument. Any future
ID change needs a separately reviewed registry/alias change, apart from any
sample correction and its consequences for estimates.

### NEW-01 — Newer-poll mode labels and reported sample totals

**Both mode corrections approved by the user on 2026-09-26 and implemented.**
The historical registry labeled both
`a1r-climate-2021` and `amr-2024` as face-to-face. For the
2021 climate poll, Stanford's [event page](https://deliberation.stanford.edu/news/america-one-room-climate-and-energy), the
[NORC October 2021 methods report](../data/a1r-climate-2021/design/a1r-climate-methods.pdf)
and the [2025 *Scaling Dialogue* paper](../data/a1r-climate-2021/papers/a1r-climate-paper.pdf)
describe online deliberation. NORC calls the event virtual, distinguishes its
invited delegates from the control group, and says both surveys were offered
by web. The approved catalog change is `face-to-face` to `online` for this
poll only; no response, weight, wave, sample, score or aggregate changes. The
separate 2019 America in One Room event was face-to-face and retains its label.

The [AMR paper, version 2](https://pmc.ncbi.nlm.nih.gov/articles/PMC12891964/)
(14 May 2026, DOI 10.12688/wellcomeopenres.24803.2) and the
[final report](../data/amr-2024/reports/amr-final-report.pdf) describe online
small-group deliberation and online plenaries in six countries during 2024.
The report calls this a six-country online experiment and identifies the
Stanford Online Deliberation Platform. Some recruitment occurred in person or
by phone; that does not make the deliberation face-to-face. The deposited file
has 2,419 unique IDs, each with a pre and post row; its group flags yield
1,280 intervention and 1,139 control people. The intervention/control counts
match all six country rows in the paper's Table 3, as well as the totals.
Only the intervention group deliberated. The approved AMR edit changes its
catalog mode from `face-to-face` to `online`, not its group flags, sample,
scores, country assignments or weights. The report's cover says June 2026
although its URL filename says July 2026; neither is the 2024 event year.

Review AMR treatment/attendance definitions and country-specific instruments
separately before changing any respondent data. Before validating reported gains,
match country, weighting, analysis sample and wave. For the climate experiment,
the one-year follow-up is a separate wave from immediate post-deliberation.
The AMR sample and scores are unchanged by this mode correction.

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

### NIC2-02: Authored attitude versions reconciled; security choice remains open

**Review of all nine indices (2026-09-28).** The 340 historical participants
are `casetype == 1` among 1,493 source records; each has a unique `nicid`.
The unprefixed items are the pre-arrival baseline; `q`-prefixed counterparts
are exit. These are not arrival-to-exit contrasts. Independent reconstruction
of every index at both waves reproduces the maintained builder exactly.
BTP National was reviewed alongside NIC2 because their common index memos
and paper describe the same constructs. This confirms the implemented formulas;
it does not settle disagreements among authored versions.

The original [February memo](../data/nic2-2003/codebooks/foreign-policy-indices-february.pdf),
[final August memo](../data/nic2-2003/codebooks/foreign-policy-indices-august.pdf),
and [July 27 syntax](../data/nic2-2003/scripts/checking-july27.do) are now public
alongside their unchanged originals. The companion online scripts are under
`data/btp-national-2003/scripts/`. The memos are stored once and registered to
both polls. The [comparative manuscript](../data/shared/papers/foreign-policy.pdf)
is a separate source of evidence, not an automatic override of deposited data.

The table uses common questionnaire numbers; the reproducible review maps
these to each survey's raw field names. `mean` excludes missing components
unless the complete-action rule below applies. All components are first
oriented and scaled to [0, 1]. DK, refused and unconsidered attitudes are
missing, not zero. A wholly missing index remains missing. Paired contrasts
require both members; one missing member does not become zero.

| Index | Maintained definition | Evidence and disposition |
| --- | --- | --- |
| Environment | mean(Q2a, Q13, Q14, Q15a) | Four equal components match the stored final scores and Table 1 (.778/.771). The February memo and paper prose instead pre-average Q13/Q14; the August heading omits Q15a. July syntax contains the four-item candidate. Preserve the executed definition; these are competing authored versions. |
| Security | mean(Q2c, Q2e, Q2g, Q25b, mean(Q37a, Q37b, Q37e, Q37f)) | The four actions deliberately form one block. NIC2 requires all four action answers; BTP uses available actions. NIC2 missing-item choice remains open below. |
| Human rights | Q2h | One 0–10 priority, divided by ten. Q2i is listed among candidate material, not the selected final index. Verified and preserved. |
| Democracy | mean(Q22, mean(Q23a:Q23f), Q25c) | Six actions deliberately form one block in both memo and paper. NIC2 combines statement and strength into 0/.25/.5/.75/1; no strength for a chosen side is missing. Preserve. BTP's approved stance-scale correction is BTPN-02. |
| Multilateralism | mean(Q10, Q16, (Q27−Q30+1)/2, (Q28−Q31+1)/2, Q37e, Q38, Q39, Q32a) | Eight components in final memo and source. Paper prose omits Q10. Leadership runs US alone=0, allies=1/3, allies with UN=2/3, UN=1. “Nobody” is missing explicitly in paper note 13. Preserve. |
| Internationalism | reverse(Q3) | Disagreement with isolationism increases the score through five positions 0/.25/.5/.75/1. Verified and preserved. |
| Foreign aid | Q24 | Increase=1, same=.5, reduce=0. NIC2 raw codes are 1/5/3; BTP 1/3/2. Final source fields are `t1forai1/t2forai1`; `foraid` is an older composite. Verified and preserved. |
| Global altruism | mean(Q2f, Q2j, mean(Q25d,Q25e), mean(Q7,Q37b), Q20, Q21) | Six blocks match July `globalta`, final source, and NIC2 Table 1 (.589/.683). August instead groups Q20/Q21 and separates Q7/Q37b; February/paper omit Q7/Q37b. Preserve executed version; do not flatten the blocks. |
| Trade | Q33 (NIC2 `trd2`) | Repeal NAFTA=0, retain=.5, extend=1; DK missing. Fielded question and final `trade_b` agree. The August heading names `trd1_a` while its body lists both items. Preserve direct NAFTA coding; Table 1 discrepancy remains below. |

**Security: an unresolved choice between authored missing-item policies.** The
four action questions concern encouraging democracy in Middle Eastern
countries (Q37a/`int1a_a`), increasing aid to countries that breed terrorists
(Q37b/`int1a_b`), working with other countries (Q37e/`int1b_c`), and improving
intelligence (Q37f/`int1b_d`). Requiring a complete block keeps the same four
policy tools in this component for every included person; averaging available
answers retains information from people who omitted one or more tools.
Neither rationale makes the other authored version an obvious typo.

Current `t1usseca/t2usseca` are explicitly labeled **“Use This One.”** The
available-action alternative instead reproduces `t1ussec/t2ussec` for all 340
people at both waves. July syntax uses `rmean`; the paper's missing-item rule
and note 11 also describe averaging answered items. Its rounded baseline .800
matches the alternative mean .8002529, versus current .8012463. However, rounded
publication agreement cannot establish whether a later author intentionally
selected the complete block. The August memo says AVG without prescribing a
minimum number answered. Its August 1, 2004 footer and the paper PDF's 2006
creation date do not date the source variable's preference label.

Available-action scoring changes 12 baseline and three exit values, without
changing any final missingness or the 340-person sample. The baseline mean
moves .8012463 → .8002529; the exit mean remains .8211593 because the three
changes cancel. Maximum individual changes are .086666644 and .058333337.
Exact IDs, raw answers, old scores and alternatives are in
`audit/foreign-policy-attitudes/nic2_security_alternative.csv`. **Preserve the
current complete-block version until the user chooses a missing-item policy
or further provenance establishes which authored version should govern.**

**Trade: publication bridge resolved September29; final source definition preserved.**
The maintained NAFTA-only means among complete pairs remain NIC2
.6135531→.5824176 (273people) and BTP .4615385→.5461538 (130people).
The paper’s measurement prose (PDFp.15, printedp.14) describes NAFTA alone,
but its Table1 (PDFp.35, printedp.34) corresponds to an older available-item
mean of **two** questions: NAFTA and the trade-organization question. In that
older composite, the latter’s raw categories are mapped in numerical order:
bilateral agreements=0, WTO=.5, leave things unchanged=1. The later authored
ordering instead gives bilateral agreements=.5, WTO=1 and unchanged=0.
These are different definitions; the published table is not a check of the
maintained single-item measure.

For NIC2, current raw fields `trd1_a/qtrd1_a` and `trd2/qtrd2`, restricted to
`casetype=1`, reproduce the old composite’s327 paired people: baseline
.4915902141, exit .4778287462 and change−.0137614679. Their standard errors
are .01574119, .01353419 and .01784271. All six statistics round to Table1.
No weighting or alternate NIC2 source file is required.

BTP’s unchanged [publication-era source](../data/btp-national-2003/source-materials/publication-survey.dta)
(original `Jennifer_online_March14.dta`) contains674 coded respondents.
Select `exp_cond=1` and paired values of the same two-item composite:216 people,
means .3483796296→.3958333333, change .0474537037, and standard errors
.019327, .019080 and .019933. These six statistics also round to Table1.
Its stored `t1tradea/t2tradea` agree exactly with independently recoded raw
components on every source row, including missingness. Table2’s online post
means and standard errors reproduce too: treatment .393/.018 (236observed),
control .360/.020 (182observed).

All245 current BTP serials uniquely match this file, and all980 corresponding
raw trade answers agree, including missingness. The paired publication sample
contains215 current people plus serial214, whose four raw answers are2 and
whose old composite is.5 at both waves. Omitting214 yields .3476744→.3953488;
this explains the residual discrepancy after matching the older definition.
The source audit now establishes an exact cohort bridge: the earlier file has
246 treatment respondents with timed completed post interviews;245 have a
recorded discussion group, and their serials exactly equal the current source.
Serial214 lacks both group assignment and meeting count. Retained
`group_level_analysis.do`, line2, explicitly drops treatment respondents without
a group. This supports a deliberate group-analysis restriction, although the
exact final-file generation script remains unavailable. Do not reinstate214
as an attendee merely because the post form exists: the legacy `attend=1`
flag also appears for all391 missing-meeting-count records, including every
control, and therefore supplies no independent attendance proof.

The separate attendance audit finds source serial134 (historical930160) has
`countmtg=0`, despite a completed post form and recorded group. The other244
retained people have positive meeting counts. The24 source `attend=0` records
include this person and23 people who attended one or two meetings; that flag
therefore represents a stricter attendance threshold. Both canonical tables
currently classify all245 as attendees by historical sample membership. The
proposal presented to the user is to classify134 as a nonattendee, preserve
all245 people and questionnaires, and make downstream attendee analyses exclude
known nonattendees. An explicit attendee filter would change dp-learning’s main
sample8486→8485; changing the upstream flag alone currently has no effect because
its historical-cohort reader ignores that flag. No attendance or sample change
is adopted before this decision.
The full earlier source is retained for that investigation, with source-bundle
and archive-path provenance in the poll manifest. It is a separate source
version, not a replacement for the final survey.

The [reproduction script](../scripts/review_foreign_policy_publication.R) uses
public poll-folder inputs, asserts all twelve Table1 values and four Table2
mean/SE values, and writes [comparisons and keyed cohort evidence](../audit/foreign-policy-attitudes/publication/).
This resolves the publication bridge without adopting its old category order,
adding a person to production, or modifying any knowledge, attitude, demographic,
group, weight or downstream result. Current questionnaire-backed NAFTA-only
coding remains the intended final definition.

**Missingness and reproducible coverage.** NIC2 missing baseline/exit counts
are environment 0/0, security 0/0, human rights 0/0, democracy 0/0,
multilateralism 0/0, internationalism 2/4, foreign aid 25/2, global altruism
0/0 and trade 63/11. These are missing final indices; partially answered
component blocks are separately counted in `denominator_summary.csv`.
Run `Rscript scripts/review_foreign_policy_attitudes.R` from the repository
root to rebuild the index, denominator, authored-alternative and paired-sample
CSVs under `audit/foreign-policy-attitudes/`. `index_evidence.csv` records the
question mapping and disposition. The script asserts identity uniqueness,
retained sample counts, matching missingness and numerical agreement with the
maintained builders; counterfactuals never overwrite respondent outputs.

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
individual high income uses `> 6`, affecting 25 people. Those competing stages
are superseded by the approved shared median rule below. Briefing exposure uses
`EVAL5`, scaled `(x - 1) / 4`, not similarly named evaluation items.

**Income reconciliation (2026-09-28; approved shared normalization).** The
original group definition used $70,000+ while the later individual flag used
$60,000+. The source and scripts establish a change between analysis stages,
not an isolated typo. The user first approved matching the $70,000+ group
threshold, then superseded that choice with the empirical within-poll median
rule for education and income in X-13. The retained income categories and
missingness do not change. One centrally defined individual flag now feeds the
group share; the group calculation has no separate income cutoff.

The education-grade-18 question remains a source-label limitation: three source
records, including one historical participant, contain 18, while the dictionary
labels end at 17. The original response is retained. The median-based flag places
that participant above the observed reference median of 15 without assigning a
new qualification label. Separately, race and Hispanic ethnicity are distinct
source questions: ten white Hispanic historical people have `minority=0` under
the current race-only construct. That is a definition boundary, not evidence of
a missing-value or computational error.

### NIC2-05: Six cross-poll attitude names point to the wrong indices (catalog corrected)

The archived `allpollindices.csv` and its empirical-premises companion pair
`nic2.t1humrh2` with “Increasing Foreign Aid,” `t1multi` with
“Internationalism,” `t1inter` with “Multilateralism,” `t1global` with
“Promoting Democracy,” `t1demo` with “Fighting Poverty and Suffering,” and
`t1forai1` with “Human Rights.” The retained
[source dictionary](../data/nic2-2003/variables.csv) explicitly labels each
of these baseline and post fields “Use This One,” with the opposite topic
mapping. The maintained respondent build reconstructs human rights from
`fp2c_b`, foreign aid from `aid1`, democracy from `pair3` and democracy-policy
items, and the other named constructs from their corresponding answers in the
[treatment questionnaire](../data/nic2-2003/questionnaires/nic2-treatment-questionnaire.pdf).
Thus the field meanings are supported by both the final source labels and the
underlying questions; the cross-poll catalog links are the discrepancy.

The generated `attitude-indices` table now names these six rows by the source
fields they actually link. Both archived cross-poll files retain their original
bytes. The nine NIC2 index rows and their field links, all respondent values,
scores and aggregate numbers are unchanged. The index memo's prose is useful
for defining constructs but its old field links must not be treated as a
verified source mapping. This catalog correction does not settle the separate
NIC2-02 formula-version or NIC2-04 demographic questions.

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

### BTPN-04: Deliberate nested weighting preserved; version conflicts documented

The review in NIC2-02 covers every one of the nine BTP National attitude
indices at baseline (`qb`) and exit (`qf`), including endpoint, direction,
missing-answer and nested-denominator checks. All 245 historical source people
have unique `serial` IDs; no additional attendance or complete-case filter is
introduced. Independent reconstruction reproduces the maintained scores
exactly. The only differences from deposited final indices are those expected
from the already-approved BTPN-02 support-scale correction.

The common [February](../data/nic2-2003/codebooks/foreign-policy-indices-february.pdf)
and [August](../data/nic2-2003/codebooks/foreign-policy-indices-august.pdf) memos
are registered for both polls, without duplicate copies. Original online
syntax is preserved in `data/btp-national-2003/scripts/`: `checking-july27-online.do`,
`v-online.do`, `v-online2.do`, and `trade-august01.do`. These are historical
evidence, not scripts executed by the modern production pipeline.

Security's four policy tools and democracy's six actions form explicit
subscales; equal weighting of every raw question would change the construct.
The paper explains this pre-averaging and reports trying alternatives in note
12. BTP security averages available action answers. The separate NIC2 choice
between complete and available action blocks is not silently imposed on BTP.
Environment and global altruism have genuine disagreements among memo,
syntax and paper prose; the per-index table in NIC2-02 records their distinct
versions and why the executed definitions are preserved.

The [comparative manuscript](../data/shared/papers/foreign-policy.pdf), Table 1,
reports online democracy means .511/.536 and poverty means .448/.478. The
deposited half-scaled versions give .509/.536 and .446/.478; approved BTPN-02
full-scale versions give .596/.626 and .491/.533. The paper's described linear
0–1 scoring supports the corrected endpoints, but these corrected scores do
not reproduce its table. Environment means .68565/.71462 round to the paper's
.686/.715, while pre-averaging Q13/Q14 as the prose says gives .675/.699.
Thus neither the paper prose nor rounded table is a sufficient reason to
replace the deposited block weights. The approved support-scale correction
stands; exact paper analysis syntax is still needed to resolve the version
history. The NAFTA means also fail the paper comparison even within paired
respondents; NIC2-02 gives the exact counts and values. No further recode is
authorized by these discrepancies alone.

Missing final indices at baseline/exit are environment 0/1, security 0/1,
human rights 0/2, democracy 0/1, multilateralism 0/1, internationalism 4/6,
foreign aid 41/25, global altruism 0/1 and trade 95/65. Missing components are
excluded from attitude means; they are not scored zero. Partial-block counts,
all 18 index-wave summaries, paired-sample means and numerical authored-version
comparisons are reproducible with `scripts/review_foreign_policy_attitudes.R`.

Raw recodes, nested means, extremity and knowledge retain float32 stages.
Peer-gain additions follow `kn11`, Republican, Democratic, then `kn2:kn9`,
rounding each addition. The approved shared median rule in X-13 replaces
historical income cutoffs with one individual flag that also feeds group
shares; it does not change the nested attitude weighting.

The income thresholds are also consistently stage-specific in both BTP
online polls. Among these 245 selected people, source `inc60plus` equals
`ppincimp >= 13` exactly (86 people, $60,000+); final individual `highinc`
uses `ppincimp >= 12` (117 people, $50,000+); the early group input for
`phighinc` uses `ppincimp >= 14` (55 people, $75,000+). All 15 stored group
shares therefore differed from the share of members marked `highinc`. X-13 has
superseded those competing cutoffs with the approved within-poll median flag,
used for both individuals and group shares. The original threshold comparisons
remain historical evidence; they are not a pending choice in the current build.

### BTPN-05: Baseline political interest was omitted from the final aggregate

**Approved by the user and corrected upstream in PR #36.** The 245 selected source records
all answer `qb57`, which the source dictionary labels as interest in U.S.
politics. Its response labels run from 1 “very interested” through 4 “not at
all interested.” Mapping those codes to 1, .66, .33 and 0, then storing a
32-bit float, reproduces all 245 source `t1polint` values exactly. Counts by
raw code are 73, 122, 42 and 8. The source mean of the derived scale is
0.68318. The historical `polardata` export nevertheless has `t1polint`
missing for all 245 people. The archived `03_data.R` comments list poll 93
among those with political interest, and the
[2009 analysis](../data/btp-national-2003/papers/refined-or-biased-opinions-2009.pdf)
uses baseline political interest for the 2002–03 online foreign-policy poll.
These checks support a dropped export field, not an invented response.

The retained [questionnaire](../data/btp-national-2003/questionnaires/btp-national-questionnaire.pdf)
identifies itself as a Phase 2 follow-up and does not contain baseline Q57.
It cannot independently confirm that item's exact fielded wording or routing;
the source dictionary and response labels provide those details. The approved
edit derives `political_interest_t1` from raw `qb57`, then exports it as
`t1polint`. It leaves all 245 people, their groups, raw answers, knowledge,
attitudes and centrally computed group/poll descriptors unchanged. The
case-level comparison is in
`audit/corrections/btp-national-2003/approved_values.csv`. No current
`dp-learning`, `dp-distortions` or `dp-deliberately` model references this
field directly, but future consumers would see observed values instead of
missing values. The rebuilt aggregate retains its 5,869 rows and 364 columns;
only these 245 `t1polint` cells differ from the previous export. The respondent
measure export replaces 245 missing historical definitions with 245 observed
`btpn-05-v2` definitions, and the raw-response export gains exactly 245
`qb57` rows. Preserve the frozen historical benchmark as the old value.

### BTPN-06: Terrorism and poverty catalog names were swapped (corrected)

The archived cross-poll catalog calls `btp03.olt1usseca` “Fighting Poverty and
Suffering” and `btp03.olt1global` “Fighting Terrorism,” with the same mismatch
at post. The [source dictionary](../data/btp-national-2003/variables.csv)
labels `t1usseca`/`t2usseca` Fighting Terrorism and `t1global`/`t2global`
Fighting Poverty and Suffering. The maintained respondent build uses the
source's security questions, including weapons and terrorism priorities, for
the former, and food, medical aid and world-poverty questions for the latter.
The retained [follow-up questionnaire](../data/btp-national-2003/questionnaires/btp-national-questionnaire.pdf)
confirms those question topics. This is a two-name catalog swap, not evidence
that the underlying indices were numerically exchanged.

The generated `attitude-indices` table now names both rows by their actual
source fields. The archived cross-poll files retain their original bytes.
Field links, all respondent values, scores, aggregate numbers and sample
membership are unchanged. BTPN-02's component-weighting issue remains
separate.

### BTPN-07: Original dates and the wider source cohort (source preserved)

The original `source-materials/master-survey.sav` preserves all 674 source
respondents: 372 experimental and 302 control records. All have baseline
answers; 246 experimental and 219 control respondents have post questionnaires.
The remaining 126 experimental and 83 control respondents have absent post
forms, not zero knowledge. These source-arm labels do not establish randomized
allocation between arms; documented random assignment to discussion groups is
not equivalent evidence.

The public publication-era Stata file has the same IDs in the same order.
All 205 numbered raw questionnaire fields (138,170 cells), including all
22 maintained knowledge input fields, agree exactly. Its four YYYYMMDD date
fields lost precision when stored as float32: 396 baseline-start, 381
baseline-end, 213 post-start and 214 post-end values differ by one unit.
Every observed Stata date equals the original rounded to float32; time-of-day
and duration values agree exactly. Use the unchanged SPSS source for recorded
dates, rather than treating the rounded Stata values as exact dates. The
comparison is reproducible in `scripts/review_foreign_policy_publication.R`
and `audit/foreign-policy-attitudes/publication/source_precision.csv`.

Twenty-four original baseline dates are after December 9, 2002, the earliest
reported session-start date: 23 controls and experimental serial 652. None
belongs to the maintained 245-person cohort. Serial 652 attended three sessions
but has no post form; its first attended session is not known. This does not
establish an erroneous pre-arrival classification for the current cohort.
Preserve individual timing uncertainty outside it. The publication describes
completing the initial questionnaire before discussion (retained
`data/shared/papers/foreign-policy.pdf`, PDF p. 10).

Neither source replaces the current 245-person dataset. The broader source
also has 45 fewer post respondents than the 2009 paper reports, so its 465 post
forms should not be presented as complete recovery of every published record.
No questionnaire answer, attendance flag, score or aggregate changes here.

## BTP Presidential Primaries 2004 — btp-presidential-primaries-2004

### PR-01: Draft counts and recodes are not the executed aggregate definition

The evaluated raw filter selects 217 people. Draft syntax says 223 and then
removes five to obtain 217, an arithmetic inconsistency. Preserve the evaluated
sample while checking session/attendance records. The final extremity measure
uses absolute deviations, not the draft's average of positions. Final income
retains 19 categories and historically defined high income as `> 11`; the
draft's 19-to-11 collapse is not implemented. The approved X-13 empirical
median rule now defines both individual high income and group shares from the
retained income categories. Later political-interest syntax reverses direction:
higher values mean less interest, unlike earlier `t1polint`. Consult the fielded
questionnaire and final analysis specification before changing any of these
versions; the separate online-primaries battery is not a substitute source.

The literal source counts resolve the draft sample arithmetic but do not
settle its intended estimand. Among 1,289 source rows, 328 are assigned to
treatment, 315 of those have a valid group, 222 also attended at least three
meetings, and 217 of those answered at least one post Q43–Q49 knowledge item.
The draft's “223 then drop five to 217” is a count typo: 222 minus five is
217. The [2009 online-poll analysis](../data/btp-national-2003/papers/refined-or-biased-opinions-2009.pdf)
reports 284 people completing the pre-
and post-surveys for this event, a broader population than the later
three-meeting, knowledge-answer aggregate. Preserve the 217-person
historical selection rather than conflating the two samples.

The income conflict is exact. In the selected 217 people, source
`inc60plus` is identical to `ppincimp >= 13` (78 people, $60,000+). The final
individual `highinc` uses `ppincimp >= 12` (106 people, $50,000+); the
earlier `highinc` in the draft and the group input for `phighinc` use
`ppincimp >= 14` (54 people, $75,000+). Codes 12 and 13 contain 28 and 24
people respectively. All 16 stored `phighinc` group shares differ from the
share of members marked `highinc`. The same three thresholds appear in BTP
National, arguing against a one-off typographical slip. X-13 has since replaced
these competing individual/group cutoffs with one approved within-poll median
flag. The historical comparisons remain evidence of the earlier stages, not a
pending threshold decision or separate cutoffs in the maintained group summaries.

The baseline questionnaire Q18 offers “very,” “somewhat,” “not very” and
“not at all” interested, coded 1–4. Among the 217 selected people the counts
are 68, 112, 33 and four. Source `t1polint` is a binary very-interested flag
and equals `b1q18 == 1`; the final aggregate maps Q18 to 0, .33, .66, 1,
so its larger values mean *less* interest. The separate upstream
`political_interest_t1_harmonized` maps the directly observed ordinal
answers to a 0–1 higher-more scale. These are three different definitions;
the harmonized column does not justify silently rewriting the historical one.

### PR-04: All three main attitude pairs verified; unconsidered responses excluded

Both fielded questionnaires support the retained directions. Q2 asks about
sharing control of Iraq and is reversed on the 1–5 scale; Q3 asks about
unilaterally invading and is forward on 1–5; Q29 asks about UN approval and is
forward on 1–7. Higher values of their available-component mean indicate more
multilateralism; a wholly missing battery remains missing. Q25 runs toward more
public services; Q31 runs toward protecting US industries. The catalog's
“Free Trade” is a topic label, not a claim that higher values favor freer trade.
The three seven-point questions retain their stored float32 mapping
0/.167/.333/.5/.667/.833/1. Refused/not-asked −1/−2 remain missing.

Independent reconstruction reproduces every one of the six wave-index fields
against the original stored indices for all 1,289 source people, the expanded
respondent measures and the 217 historical selected people. Baseline extremity
also reproduces for all 217. The 19 checks and missing/component coverage are
retained in `audit/primaries-attitudes/index_checks.csv` and
`audit/primaries-attitudes/index_coverage.csv`. No attitude-score, person or group
change is supported by this review.

**Typed-status correction only.** Q2/Q3 code six explicitly means “haven't
thought much about that”; the numeric attitude recoder already excludes it.
Exactly 138 source responses (52/41 baseline and 27/18 follow-up) across 92
people were incorrectly marked `answered`. The shared exact-label classifier
now marks them `non-substantive`, preserves raw six and records its missing
reason. Exactly 177 measure input counts decrease. Code eight is the nonanswer
for the seven-point questions and is already missing in the supplied source.
The same exact-label rule corrects 358 BTP National and 848 NIC2 source statuses,
with 451/1,760 input counts decreasing; all numeric measures remain unchanged.
The rule recognizes only the three unambiguous labels ending “that,” “this” or
“it,” and does not guess at corrupt labels ending in a trailing eight or at
codes with conflicting labels.

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

## New Haven 2002 — historical ID new-haven-2004

## NH-03: The three-wave workbook supplies raw answers and an explicit ID bridge

`source-materials/survey-waves.xlsx` preserves the answer/ID projection of
`NH_Data_pre-mid-post.xls`. Join Pre `ASSIGNED` to Mid/Post `SVY#`; each sheet
has 132 unique matching people and matching group assignments. Source-row order
follows Pre. `historical-ids.csv` links `ASSIGNED` to aggregate IDs using unique
nine-answer baseline Q35:43 signatures in `nh_hlm_smallnew.dta`: all 132 matched,
with independent gender agreement. No derived scores supply the bridge or build.
The 133-versus-132 attendance distinction in NH-02 is not resolved by this
successful reconstruction.

### NH-04: Airport scaling reviewed; age remains historical

The historical airport expansion index mapped 0.625 to float32(0.675), affecting
12 baseline and five post values; the same discontinuity applied at arrival.
The instrument, index memo and published means were reviewed under NH-07, and
the replacement was removed. Age uses `2002 - birth_year`; three birth-year-1890
records are set missing in the historical merge. The baseline CATI script's
Q62 explicitly instructs interviewers to record 1890 for a refusal, and the
source has exactly three such values. The missing-age recode is therefore
supported; no age correction is proposed. The corrected catalog year and
remaining attendance question are in NH-02. The race-refusal correction is NH-06.

### NH-05: Historical interim attitude rules superseded by NH-08

The historical Mid battery used the same three components but preserved raw zero
as zero rather than the algebraic value 1.25. Mid Q12 don't-know code 6 or system
missingness set the entire airport index to 0.5; Q13 don't-know contributed a
midpoint component. These rules explained five interim-extremity differences
under a naive repeated-wave implementation. Some post raw zeros were also
preserved. These are historical comparison rules, not the maintained recode:
the approved NH-08 correction now treats codes 0 and 6 as missing in all three
waves. `new_haven_attitudes()` applies that reviewed rule to Pre, Mid and Post.
The Mid questionnaire followed the first deliberative session and is labeled
`interim_1`, not arrival, in the canonical phase catalog (X-02).

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
changed at this respondent-correction stage. The former historical entropy
helper divided by full group size and absorbed missing binary answers into
the complementary category, leaving its value unchanged. The separately
approved shared entropy correction in X-03 now supersedes that diversity
calculation; the NH-06 respondent values and participation remain preserved.

### NH-07: Historical airport index replaced an attainable 0.625 with 0.675

**Status: approved correction.** The fielded
[baseline CATI questionnaire](../data/new-haven-2004/source-materials/baseline-cati.txt)
asks Q12 whether commercial passenger service should expand and Q13 whether
it should end, each on the same five-point agree/disagree scale. The
[attitude-index memo](../data/shared/codebooks/attitude_indices/past_versions/attitude-indices.pdf)
describes the index as the difference between expanding and ending, with
unknown answers at the midpoint. Scaling each 1–5 answer to 1–0, taking
`(expanded - ended)/2 + 0.5`, and applying the separately reviewed arrival
unknown rule yields 0.625 for 12 baseline, 12 arrival and five departure
answers. The historical recode instead replaces every exact 0.625 with 0.675.
The latter is not a possible value of the stated difference of two five-point
items. This appears to be a manual recode mistake; the archived indexed values
and maintained code confirm it is historical, not an import error. No raw
response, sample or other index rule was changed.

The [published study](../data/new-haven-2004/papers/disaggregating-deliberation-27s-effects-28lsero-29.pdf)
(text on printed p. 341; Table 1 on p. 342) explicitly defines the expanding-minus-ending
score on a -1 to 1 scale and reports full-sample T1/T2/T3 means of
0.540/0.415/0.434. Converting the corrected 0–1 index back to that scale
gives 0.53977/0.41477/0.43371, matching all three published means after
rounding. The historical 0.675 replacement gives 0.54886/0.42386/0.43750,
which round to 0.549/0.424/0.438. This independent publication comparison
supports the approved removal under the historical neutral-imputation rule.
The proposed missing-value policy in NH-08 changes the denominators and no
longer reproduces the published wave means.

The approved build retains all 132 people. Only eight historical
wide fields change: 12 `nh.t1endexp`, five `nh.t2endexp`, 12 baseline
`attextreme`, 12 arrival `attextreme2`, and the affected group descriptors
`meanxtreme` (73 rows), `avgsd` (67), `avgsd2` (62) and `genvar` (73). Their
group calculations stay in the central derived stage. The case-level historical
and corrected values are in
`audit/corrections/new-haven-2004/approved_values.csv`. The current
`dp-learning` main mixed model retains 5,850 observations; its heterogeneity
coefficient moves from 0.002743934 to 0.004060487 and its extremity
coefficient from -0.06758994 to -0.06774958. In the paired
`dp-distortions` run, all 19 result CSVs change: New Haven group/issue rows
and pooled summaries. Nineteen of 28 pooled inference rows change; for the
pooled gender `ext_grp` result, one reference tie changes eligibility and the
pair count moves from 2,437 to 2,436. These consequences are reported to
size the review, not as evidence that the historical or corrected score is
more correct.

### NH-08: Nonanswers in the three-wave attitude battery

**Approved by the user and corrected upstream in PR #38.** The retained
[field questionnaire](../data/new-haven-2004/source-materials/field-questionnaire.pdf)
prints agreement codes 1–5 and code 6 for “don't know” on Q12–Q13 and
Q20–Q23. It offers no code 0. The public three-wave workbook records 64
baseline, 25 arrival and 29 departure answers of 6 on these six items. It
also has two arrival Q12 zeros (historical cases 910013 and 910039), one
arrival Q20 zero (910110), and one person's six departure items all zero
(910042). No baseline item has zero. The raw answers and all 132 respondent
identities remain unchanged.

The historical recode inserts the neutral response 3 for code 6, system
missing and most zero codes; a special arrival path instead turns zero into
an extreme score. It also forces the whole airport index to neutral when
arrival Q12 is unknown. Neither 0 nor 6 is an expressed middle attitude.
The corrected recode therefore makes both codes missing. Each three-wave
attitude index is observed only when all its component answers are in 1–5;
baseline and arrival extremity are observed only when all three indices are.
This leaves respectively 122/120/122 observed airport indices at baseline/
arrival/departure, 113/126/124 mandatory-sharing indices, and 107/125/126
voluntary-sharing indices. The baseline three-index extremity is observed
for 100 rather than 132 people; arrival extremity for 114 rather than 132.
The six all-zero departure answers for case 910042 now yield three missing
indices rather than artificial neutral scores.

Relative to the preceding `polardata` release, exactly 566 New Haven cells
change, with the same 132 rows and 364 columns: 10/19/25 baseline and
10/8/6 departure airport/mandatory/voluntary indices become missing;
32 baseline and 18 arrival extremity values become missing. The central
group stage recalculates `meanxtreme`, `avgsd` and `genvar` for 118 people
in 14 groups, and arrival `avgsd2` for 84 people in 10 groups. These four
group descriptors retain their existing observed-answer formulas. In the
long respondent measures, 128 numeric values become missing; nine raw-zero
statuses change from `answered` to `non-substantive`, and six source-input
counts decrease. The later NH-09 source-response review found that code 6
was still classified as substantive in the typed raw-response table despite
being excluded by the corrected attitude formulas; that status/count inconsistency
is corrected separately. The case-level reviewed-value ledger retains the frozen historical values;
aggregate and respondent parity have zero unexplained differences.

The [published study](../data/new-haven-2004/papers/disaggregating-deliberation-27s-effects-28lsero-29.pdf)
Table 1 reports airport means of 0.540/0.415/0.434 at baseline/arrival/
departure and an arrival voluntary-sharing-versus-local-control mean of
0.041 on a -1 to 1 scale. The prior corrected build using neutral
imputation reproduced those rounded means. The corrected complete-case
airport means become 0.588/0.477/0.473, and the arrival voluntary-sharing
mean becomes 0.050, among those with all contributing answers observed.
Thus the paper used the neutral-imputation stage; it does not establish that
unknown answers express neutral attitudes. This change alters denominators,
so the complete-case means are not direct attempts to reproduce Table 1.
An arrival-specific instrument or coding instruction assigning substantive
meaning to zero would warrant revisiting this decision.

### NH-09: Attitude source statuses now exclude documented don't-know answers

**Status: authorized transport-consistency correction; approved index values are
preserved.** The field questionnaire labels code 6 “don't know” on Q12–Q13 and
Q20–Q23. The three-wave workbook has 118 such answers: 64 Pre, 25 Mid and 29
Post, across 43 people. The maintained index formula already excludes codes 0
and 6 under NH-08, but `source_response_rows()` explicitly classified only zero
as non-substantive for these fields. The workbook's value-label projection is
empty, so code 6 fell through to `answered` and a missing `missing_code`.

The corrected rule applies only to these six attitude questions in their three
waves. Exactly 118 source-response statuses become `non-substantive` and their
`missing_code` becomes `6`. The nine zero statuses remain non-substantive.
Exactly 122 `n_observed_fields` values decrease on the same 43 people: airport
before/after 10/9; mandatory sharing 19/7; voluntary sharing 25/5; baseline
extremity 32; and interim extremity 15. These counts describe substantive input
fields, not a new scoring denominator. Every affected measure value was already
missing, and all numeric index values, participant identities, groups, sample
flags and raw bytes remain unchanged. The keyed before/after evidence is
`audit/corrections/new-haven-2004/source_response_statuses.csv` and
`audit/corrections/new-haven-2004/observed_input_counts.csv`.

The independent 2026-09-28 attitude audit covered both main indices and the
third index used in summaries. For each wave, let agreement be `(5 - answer)/4`
for answers 1–5, otherwise missing. Airport is
`(agreement_Q12 - agreement_Q13)/2 + 0.5`; mandatory-versus-voluntary sharing is
`(agreement_Q23 - (agreement_Q21 + agreement_Q22)/2)/2 + 0.5`;
voluntary-versus-local control is
`((agreement_Q21 + agreement_Q22)/2 - agreement_Q20)/2 + 0.5`.
The main mandatory-sharing index increases toward mandatory sharing, as named
in the authored `man_df_avg_volinc` field; the published study describes the
reverse contrast. Reflecting a scale is not a source-scoring error.

| Index | Pre observed | Mid observed | Post observed | Main Pre/Post paired |
|---|---:|---:|---:|---:|
| Airport | 122 | 120 | 122 | 114 |
| Mandatory versus voluntary | 113 | 126 | 124 | 106 |
| Voluntary versus local control (summary only) | 107 | 125 | 126 | Not in main catalog |

Every index value and missingness pattern reproduces independently from the
workbook, with explicit assigned-ID joins and matching groups across sheets.
All 132 people and 16 groups remain. The main catalog's historical `t2` fields
come from the workbook's **Post**, the original T3 weekend-end measurement.
The paper, PDF p. 8, places Mid/T2 **after the first deliberative session**;
current phase metadata correctly labels it `interim_1`, not arrival. Original
source `notes.txt` independently specifies complete analyses of T1–T3 only.
The 2002 event date and the unresolved 133-versus-132 attendance issue remain
as documented in NH-02.

Baseline and interim extremity retain NH-08's complete-three-index rule (100 and
114 observed people); group SDs retain observed-answer sample SDs averaged
across all three indices. All 16 baseline and interim group SDs and the baseline
group mean extremities reproduce independently. The January CATI draft numbers
revenue questions differently from the final field questionnaire; matching
question numbers across those instrument versions is not justified. The workbook,
final field instrument and authored variables identify the maintained questions.
No new numerical attitude correction or summary-battery substitution is proposed. Main-index counts and ranges are in
`audit/san-mateo-new-haven-attitude-coverage.csv`.

### NH-10: Zero is not an offered knowledge answer

The workbook records30 departure knowledge zeros across five people, in
Q35–Q37/Q39–Q43. Both the field form and CATI factual counterparts start
option codes at1; neither offers0. Under the approved global invalid-code
rule these30 item responses now have missing correctness and an explicit
`invalid_response` reason; raw0 remains preserved. DK options remain separate
and score zero. The existing fixed-denominator knowledge scores do not change.

One person, source assignedID3124 (historical910042), has all78 departure
fields zero, including questions with no substantive0 option. That person has
filled baseline and interim forms, so there is evidence of actual participation.
Treating the whole departure questionnaire as absent is a separate classification
currently presented to the user: it would make the departure score missing,
retain attendance, and remove the person from paired departure analyses.
The paired New Haven cohort would move132→131 and its mean gain
22.25379→22.80534 percentage points; current dp-learning’s main sample would
move8486→8485. This is not the separate133-versus-132 attendance discrepancy
in NH-02. No whole-form or sample change is adopted merely from the invalid-item
classification.

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

The published paper supplies a version check: its Table 5 reports a T2 correct
share of 0.494 for Q45 among 235 matched respondents. The merged `d3045p`
flags yield 116/235 = 0.493617, whereas scoring only the raw POST answers
yields 113/235 = 0.480851. The other three T2 item shares from the same 235
records round to the paper's 0.315, 0.528 and 0.362. Thus the publication
used a scoring stage consistent with the three merged flags; it does not prove
what those people actually answered. Preserve the historical flags until the
original answer sheets or a documented correction log can resolve that question.

### ZG-02: Scale the village-road rating and use post-wave main roads

The fielded translated questionnaire and its alternative both print a 0-10
importance scale for the project ratings. One respondent (`p=50`, source row
147, historical case 52050) has a merged value of 4.5 on baseline village-road item
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
`audit/corrections/zeguo-2005/approved_values.csv`; all other fields retained
their historical scoring at this stage. The original covariance matrices were
rank deficient and produced platform-dependent generalized variance. The later
approved Wenchang correction (ZG-05) restores full rank in all 16 groups and
removes those numerical exceptions. The comparison file retains the historical
benchmark as its old value.

### ZG-03: Two road indices make covariance numerically singular

The historical nine-column baseline matrix included
`float(mean(float(ratings / 10)))` and `float(mean(ratings)) / 10` versions of
main roads. They are algebraically redundant apart from float-storage order.
Before ZG-02, all nine reconstructed input columns matched the original
historical matrix bit-for-bit. The approved 4.5 rescaling changed one input in
group 5207. All 16 historical covariance matrices had rank eight rather than
nine. The original script labeled `t1att5` Wenchang Main Avenue but assigned
`main2t1`, the same six-project index already used in `t1att3`. ZG-05 corrected
that source-field error using the project 6 responses and published Wenchang
results. All 16 corrected matrices have rank nine. The centrally computed
group-dispersion formula is unchanged; the 15 Zeguo numerical exceptions in
X-09 are no longer needed.

### ZG-04: One baseline age is 1; the paired departure age is 33

**Status: approved by the user on 2026-09-26 and corrected upstream.** The fielded
[questionnaire](../data/zeguo-2005/source-materials/questionnaire.pdf) asks age
directly. In the merged source, participant `p=125` (aggregate case 52125,
group 5204) has baseline `Age=1` and departure `____1p=33`. This is the only
baseline age below 16 among the 269 merged source records. The participant
has a valid pre/post match and remains in the 233-person aggregate sample.
The historical export carried `ppage=1`. The corrected respondent build uses
33 for this case only, with assertions on both recorded answers. The group's
`meanage` changes from 38.92308 to 41.38462 for its 14 members (13 observed
ages). No membership or other respondent field changes.
The approved-value ledger records all 233 `ppage` and 233 `meanage` values.
The parity comparisons find one changed age and 14 changed group-mean cells,
with zero unexplained differences.

The paired ages support using 33 for this person but do not make the post
field a universal replacement: among 210 nonmissing pairs, 156 are identical
and 188 differ by at most one year. The post field itself includes values 1
and 445 for two other participants. Inspect the original questionnaire or
answer sheet for `p=125` if available, then review a case-specific correction
against the paired report; do not overwrite all baseline ages with post ages.
The downstream `dp-learning` reader currently removes ages below 16. Its
analysis frame previously made this person's age missing; it now sees 33. A
paired run of the current main mixed model adds one observation (5,849 to
5,850), with the heterogeneity coefficient moving from .003498077 to
.002743934 and the age-per-decade coefficient from -.003229041 to -.003300206.
`dp-distortions` scripts do not use `ppage` or `meanage`; the
`dp-deliberately` importer receives this corrected age. The single upstream
repair did not settle policy for every other age. EURO-06 subsequently resolved
the remaining Europolis anomaly, and X-11 records removal of the downstream
clipping rule in favor of corrected upstream ages and an assertion.

### ZG-05: The Wenchang Main Avenue slot duplicates the main-roads index

**Approved by the user on 2026-09-26 and corrected upstream.** The original `china_2005.r` labels
`t1att5` and `t2att5` as Wenchang Main Avenue but reads `main2t1` and
`main2t2`. The source variable dictionary defines `main2t1` as the average
of projects 15–19 and 22, and its baseline values equal the `mroads1` index
already used for `t1att3` after rescaling. The fielded
[questionnaire](../data/zeguo-2005/source-materials/questionnaire.pdf)
lists **project 6** as Wenchang Main Avenue on a 0–10 importance scale; its
literal responses are `d2006` and `d2006p`.

The [published study](../data/zeguo-2005/papers/china-zeguo-bjps.pdf),
Table 4, reports 160 paired Wenchang ratings with baseline/departure means
0.825/0.924. The 160 people with both `d2006` and `d2006p` observed give
0.825/0.92375 after division by ten, matching that table. In the historical
233-person aggregate sample, replacing only the Wenchang slot with Q6/10
and retaining the original midpoint fallback for missing answers would
change 175 baseline and 199 departure slot values; 59 baseline and 23
departure Q6 answers are missing. The corresponding means over all 233
people would move from 0.60674 to 0.73219 at baseline and 0.61245 to
0.87725 at departure. The published paired means have a different denominator
and must not be compared directly to those full-sample means.

This is evidence of a wrong source-field selection, not a reason to alter
the group-dispersion formula poll by poll. Replacing the duplicated slot
makes all 16 nine-index group covariance matrices full rank; the historical
matrices all had rank eight. In the paired corrected build, only
six wide fields change: 175 `chi.t1att5`, 199 `chi.t2att5`, 172
`attextreme`, and the centrally derived `meanxtreme`, `avgsd` and `genvar`
for all 233 selected people. No sample or missingness changes. The current
`dp-learning` mixed model retains 5,850 observations; its heterogeneity
coefficient moves from 0.004060487 to 0.02556485 and its extremity
coefficient from -0.06774958 to -0.07214343. Fifteen of 21 paired
`dp-distortions` result CSVs and 19 of 28 pooled inference rows change;
pooled gender comparisons lose one eligible pair under the revised group
mean. These consequences do not determine correctness. The corrected source
fields are `d2006` and `d2006p`; the sample, missing-answer fallback, and
centrally derived group-dispersion formula are unchanged.

### ZG-06: All nine attitude batteries have been reconstructed and source versions compared

**Reviewed; existing approved corrections and historical missing-answer rules
preserved.** The independent
[reproducer](../audit/corrections/zeguo-2005/reproduce.py) reads repository poll
files and current exports, without the private vault or production scoring
helpers. Run `python3 audit/corrections/zeguo-2005/reproduce.py` from any working
directory. Its 107 comparisons cover all 18 attitude fields and their observed
component counts for 269 source people, the 233 selected participants, baseline
extremity, and the means and dispersion in all 16 groups. Every comparison has
zero unexplained differences. All current attitude values are within 0–1 and all
16 baseline covariance matrices have rank nine. Detailed results are retained in
`index_checks.csv`, `index_coverage.csv` and `group_checks.csv` in that directory.

The [fielded questionnaire](../data/zeguo-2005/source-materials/questionnaire.pdf),
project-rating section Q6–35, specifies 0 as unimportant, 10 as most important,
5 as the midpoint and 98 as don't know. Every included project is scored in the
same direction. The modern build uses the authored merged rating fields, where
98 has already become missing, rather than silently substituting the earlier
PRE/POST field files. The current available-component means are:

| Historical catalog index | Project questions, both waves | Source/instrument assessment |
| --- | --- | --- |
| Industrial roads | 14, 20, 21 | Matches published Appendix A |
| Village roads | 7, 10, 11 | Matches Appendix A; approved merged Q7 rescaling retained |
| Main roads | 15–19, 22 | Matches Appendix A; approved departure-wave selection retained |
| Commercial roads | 12, 13 | Matches Appendix A |
| Wenchang Main Avenue | 6 | Matches the questionnaire and Appendix A; ZG-05 retained |
| Other parks | 24, 28, 29 | Matches Appendix A |
| Township image | 25, 31 | Historical authored variant; published definition differs, ZG-08 |
| Cultural heritage | 25, 32 | Matches Appendix A |
| Sewage treatment | 30, 33–35 | Matches Appendix A |

The available-component denominator and historical midpoint fallback for an
all-missing battery remain unchanged. Seven indices first store rating/10 and
then the mean as float32; Other Parks and Township Image store the raw mean as
float32 and then divide by ten. These storage-order differences are reproduced,
not treated as alternative substantive scales. The baseline summary is the
equal-weight mean of nine absolute distances from .5; group SDs use sample SDs,
and generalized variance uses the shared reviewed covariance rule. Project
investment costs printed in the questionnaire are context, not index weights.

The [published paper](../data/zeguo-2005/papers/china-zeguo-bjps.pdf), Table 4 and
Appendix A (printed pp. 441, 447–448), supplies definition and denominator checks.
For seven indices, paired nonmissing ratings among the 235 matched source people
reproduce both the reported N and the means rounded to three decimals. The
corrected Village Roads baseline mean is .587975 rather than the printed .597;
this is not a reason to undo the approved ZG-02 scale correction. Township Image
has the separate version gap in ZG-08. The paper also includes a tenth,
single-project Recreational Park index, Q26. The archived `china_2005.r` explicitly
comments that slot out; the historical nine-index catalog is a subset, not a
claim to contain every published index. The paired publication denominator
does not justify changing the full-sample midpoint policy.

The one-time independent archive comparison in `archive_projection_parity.csv`
records the SHA256 hashes of the original PRE SAV, POST SAV and merged DTA. All
54, 63 and 939 retained numeric columns, respectively, match the public
projections exactly, including source row order. Numeric strings in the merged
DTA were compared after parsing numbers and its blank/dot missing tokens.
`source_hashes.csv` pins the repository inputs and instrument/paper used by the
repeatable audit. The two archived `r_recode_eval` files concern evaluation and
demographics; they do not establish how the project-rating edits were made.

`raw_merged_rating_versions.csv` preserves twelve differences between the
original PRE/POST ratings and the authored merged version after original 98
codes are treated as missing. They involve baseline p50/Q7 (4 to 4.5), p2/Q27
(5 to 5.5), and departure p21, p39, p67 and p217. They are not newly applied
recodes or verified answer-sheet corrections. The merged values remain in use;
original answer sheets or a correction/version log would be needed to choose
between these stages. This qualification also applies to ZG-01's three knowledge
overrides. The March 2005 initial survey and April 9 departure questionnaire are
supported by the paper; the archived `timebtw=25` remains explicitly a best guess,
not an independently verified person-level interview interval. No new score,
cohort, identity or timing recode was applied in this audit.

### ZG-07: Thirty-four people have no matched participant departure questionnaire

**Approved and implemented September 29, 2026.** For 34 of the
269 baseline source people, both `pp` (participant number at T2) and
`preandpost` are missing, there is no matching participant POST source record,
and all thirty merged departure project ratings and the four joined departure
knowledge answers are missing. All 269 baseline IDs occur in the PRE file, so
there is no symmetric unmatched-PRE case. Seven of the 242 POST IDs are outside
the 269-person baseline universe; the audit does not invent a match for them or
add them to the historical panel. A PRE identity by itself does not establish
an observed questionnaire: p166's original PRE row has every field except
`source_row` and `p` missing. Its baseline questionnaire presence remains unknown;
the post-only candidate does not extend the absence rule to that ambiguous
baseline score. The 34 people are outside the 233-person main
sample and already have `panel=FALSE` in both canonical participant views.

The former respondent layer gave each of these 34 people all nine departure
attitudes at .5 and departure knowledge at zero. The adopted rule leaves
their baseline measurements and source rows intact and marks the absent
participant departure measurements missing in both plain and imputed variants. That means 34 changes for each of
the nine post attitude fields and each of six post-dependent knowledge fields:
`knowledge_t2`, `knowledge_joint`, `knowledge_gain`, `knowledge_gain_joint`,
`log_knowledge_joint` and `high_knowledge_joint`. Current gains range from −1 to
0; current joint-log values are −9.210340371976182. Exact IDs and current values
are retained in `absent_departure_current_values.csv`.

Propagation would make 34 departure scores and their zero `n_correct` values
missing in each of `analysis_scores` and `analysis_phase_scores`. Each item view
has 136 departure correctness values currently zero; these would become
missing, with `response_status` changing from `scored` to `wave_absent`.
The same 136 zero correctness values in `historical_knowledge_items` would
become missing. Phase score/item presence would change from unknown to false,
and the phase score's questionnaire-presence label from unknown to
`absent`. In each score view, 34 `n_observed` counts would change from missing
to zero, following the shared absent-form convention. The four-item battery
size, source response values and identities would remain unchanged.
`absent_departure_proposed_changes.csv` records these fields separately rather
than summing duplicated exports. The executed isolated candidate uses the
verified POST identity rather than a blank-quiz predicate. Its actual table
comparison is retained in
`absent_departure_executed_changes.csv`; per-person propagation and the p90
presence-only changes are retained in `absent_departure_executed_values.csv`.
It preserves every matched POST numerical value, every baseline value, all 233
main participants and their group summaries, all existing panel flags and all
other polls' exported values. These checks do not establish unchanged downstream
phase estimates. The absence correction is now adopted. The archived comparison isolates that
correction from the subsequent explicit imputation variants and common attendance
provenance changes.

This is distinct from an observed questionnaire with nonanswers. Participant
**p90** has a verified POST record, filled demographics, 28 explicit project
98 codes and two blank project items. Its four quiz answers are blank. The
adopted rule therefore retains zero quiz scores and explicitly named midpoint-
imputed attitudes for p90; its plain all-missing attitudes remain missing, and it
must not be masked by an all-missing-battery predicate. Its phase
questionnaire presence was previously unknown. The adopted rule marks its
verified matched POST as observed: one phase score presence and its label, and
four phase item presence flags change, without changing p90's numerical scores.
This may affect downstream phase coverage or phase-pair eligibility even though
the 233-person main analysis inputs stay unchanged. Fourteen baseline rows also
lack all substantive project ratings, but their PRE records are retained; rating
missingness alone is not evidence of an absent whole questionnaire.

The downstream counterfactual confirms that distinction. The `dp-learning`
main attendee frame is identical, but the available Zeguo t0-to-t2 phase pairs
increase from 232 to 233 when p90's matched departure is recognized. Their mean
gain changes from .1163793103 to .1115879828: p90 has baseline knowledge 1 and
departure knowledge 0. Across all 269 source people, departure coverage changes
from 234 observed, 35 unknown and zero absent to 235 observed, zero unknown and
34 absent. These are consequences of the unadopted candidate, not new source
answers or authorization to change the published data.

The merged file also contains a **separate nonparticipant block**: 32 populated
`np` records co-located with baseline p1–33, including 30 rows with an ordinary
matched participant POST record and p29/p31 among the unmatched rows. The
dictionary labels its demographics as nonparticipant responses. These cannot
be borrowed to fill participant departure values: for example, p2's baseline
record is female, age 61, whereas its co-located nonparticipant record is male,
age 21. There is no verified crosswalk identifying these as the same people.
`nonparticipant_block_identity_caution.csv` retains the public numeric evidence.
The proposal leaves that block untouched and makes no claim that every possible
nonparticipant follow-up source is absent. No absence repair has been adopted.

### ZG-08: Township Image has two authored definitions

**Unresolved source-definition choice; no correction adopted.** The archived
`china_2005.r`, lines 129–130, explicitly selects `imaget1`/`imaget2`; the merged
dictionary describes its image index as Q25 (Wenchang Park second stage) and Q31
(Demonstrative Street). The current build reproduces that historical choice.
The published Appendix A instead lists **Q8 Bridge, Q9 Fuxing Road east end,
Q25 Wenchang Park second stage and Q27 Urban environmental constructions**.
The merged file also contains `image3t1`/`image3t2`, explicitly labeled as the
available mean of 8, 9, 25 and 27, and all their values independently reproduce
that four-project definition. Thus both versions are authored source evidence;
the published title alone does not authorize silently replacing the historical
construct.

With the current float32(raw mean)/10 storage order and midpoint fallback
preserved, adopting the published four-project definition would change 186
baseline and 171 departure image values in the 269-person respondent layer,
and 184 baseline extremities. In the main 233-person sample it would change
161 `chi.t1att7`, 169 `chi.t2att7` and 160 `attextreme` values; `meanxtreme`,
`avgsd` and `genvar` would each change for all 233 people. For example, p15's
baseline image value would move from 1 to .6333333492279053, while p262's
would move from .5 to 1. Exact old/proposed values are retained in
`township_image_proposal.csv` and `township_image_derived_proposal.csv`; the
selected-field scope is in `township_image_selected_impact.csv`. No source
response, sample membership or other attitude definition would change.

The four-project version reproduces the paper's paired **N=176**, but its
baseline/departure means are .656321/.609967 rather than the printed .663/.618.
The two-project historical version gives N=138 and .621014/.539855. These are
paired observed means without midpoint substitution; they are not full-sample
means. `published_index_comparison.csv` retains this discrepancy and the other
nine-index comparisons. The appendix supports an alternative construct, while
the unreproduced published means remain a separate source-version limitation.
The user's choice between preserving the historical construct and adopting the
published four-project definition is still required before a numerical change.

### ZG-09: Preserve out-of-range knowledge codes as missing

Both retained questionnaire versions, PDFp.8, offer substantive1:4 andDK5
forQ43–Q45, and substantive1:5 andDK6 forQ46. Q46’s “zero parks” answer
is code1, not0. The raw PRE/POST versions retain13 responses outside those
ranges across10 people: preQ43=6 (p269), preQ45=0 (p34,p226), preQ46=0
(p69); postQ43/Q44=6 (p153), postQ45=6 (p165,p196,p201), postQ46=0
(p100,p151,p153), and postQ46=98 (p201). Neither form gives these codes a
knowledge-response meaning. Code98 is labeled DK on earlier project-rating
scales; that label cannot be transferred to a different question by analogy.

The approved global rule now gives all13 item responses missing correctness
with `invalid_response`, preserving raw codes and leaving verified DK5/6
at zero. Twelve cells concern nine historical aggregate people; p269 is outside
that233-person sample. The Q45 source-reconciliation overrides for p48/75/105
are separate and unchanged. Fixed-denominator individual scores and historical
aggregate outputs remain unchanged. Item-specific peer opportunities can change
when invalid focal responses or invalid peer answers are excluded; these are
missing observations, not known wrong answers.


## A1R/Climate paired attitude source audit (implemented September 29, 2026)

The existing baseline reader correctly scales every observed reviewed rating:
180,574 A1R cells across 47 items and 528,840 Climate cells across 60 items
have zero differences from independent raw-source reconstruction. It previously
exposed no paired exit rows. The new paired phase tables expose all 47 A1R
and 72 Climate items using the same verified pre-arrival/immediate-exit
occasions as knowledge. Existing baseline tables and all numeric scores remain
unchanged. No source answer or item polarity is recoded.

Across all source records, the added exit coverage contains 61,159 substantive
A1R answers and 92,910 substantive answers to Climate's existing 60 items.
Twelve additional Climate items (Q0A:C, Q1A:E, Q11A:B, Q12A:B) supply
99,373 substantive baseline answers and 19,052 exit answers. These twelve
have 10,993 complete item pairs among the 962 completers. The retained
results report identifies their worry, agreement and willingness directions;
Q2–Q9 ratings express support and Q10 importance. No common ideological
polarity is imposed. Missingness is determined within each item's own wave.

All 94 A1R source fields match their field-specific codebook categories,
including endpoints 0=oppose, 5=middle, 10=favor, 77=no opinion, 98=skipped
and 99=refused. Five observed post codes -8 retain their original “Multiple
responses” labels and map to missing, not to midpoint. For all 144 Climate
fields, observed substantive codes are 0:10 and observed nonanswers are 77/98.
The authored script documents the broader nonanswer set 77/88/98/99; labels
are not invented. All raw values survive in the typed phase responses.

A separate authored-script error is explicitly rejected for upstream adoption:
`data/a1r-climate-2021/scripts/replication-data-preparation.do`, line 277,
masks baseline ideology components when the person's T3 answer is 77/98/99.
Within its 1,419 completed-follow-up records, this discards 1,602 baseline
components across 504 people and changes 488 ideology scores. Removing only
that cross-wave mask changes the mean from 3.694652439 to 3.701763039, with
a maximum individual change of 2.672727273. The canonical baseline reader
does not copy this error; neither does the paired exporter. Do not infer that
all authored script operations are valid merely because the script reproduces.

Evidence is retained in `audit/attitude-definition-review/a1r-climate-paired/`;
source-based tests independently compare every raw and scaled paired response.
No participant, attendance, group, knowledge score or historical aggregate
changes. Downstream adoption of these paired attitudes is a separate comparison.

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

On 2026-09-27 the user requested phase-based descriptions: t0 is pre-arrival,
t1 arrival, t2 post-deliberation, and t3/t4 later follow-ups when present.
Marousi's recovered source T1/T2/T3 maps to canonical t0/t1/t2, as documented
in MAR-02. Preserve original source wave labels separately. Each questionnaire
instance also needs its role, chronological order, and date/elapsed time when
known; multiple pre-event surveys or follow-ups cannot be distinguished by a
single generic pre/post flag. Numbered instances t0_1/t0_2 distinguish multiple
pre-arrival surveys. Preserve missing phases and do not invent arrival waves
for online polls. Existing exports still use their reviewed historical wave
contracts; this naming decision is not a silent renumbering of their values.


These are cross-poll phases, not whichever two measurements a reader selects.
A telephone interview before arrival is t0 even when it is the only available
baseline. Interview mode is separate metadata. t1 is arrival/start and t2 is
immediate post-deliberation; t3/t4 identify successive later follow-ups, whose
actual dates or elapsed times must also be recorded. Multiple pre-arrival
instances share phase t0 and have distinct instance IDs, so readers do not
confuse phase with the questionnaire instance.

Downstream analyses must request their comparison explicitly, for example
`baseline_wave = t1`, `outcome_wave = t2` for an
arrival-to-exit contrast, or t0 to t2 for the current dp-learning main
pre-arrival-to-exit contrast. Missing t1
makes the former comparison unavailable; it does not relabel t0. Existing
selected-pre/post exports therefore need a reviewed mapping before they can
claim this standardized contract.

Retain all available pre-arrival respondents and their answers, including
nonattendees and people without a discussion group. Preserve invitation,
assignment, attendance, questionnaire presence, group membership and
analysis eligibility separately. Participant, paired-wave and group-analysis
filters are named views over the source universe. Pre-arrival data can then
support selection and attrition comparisons without rebuilding discarded
records. MAR-02 supplies a concrete 1,275-row source bridge for this requirement.


**Pre-arrival coverage audit (updated 2026-09-28).** At least 33 of the original 34
analytical catalog IDs retain a confirmed pre-arrival or online pre-start
measurement, representing 32 distinct studies because the two Primaries IDs
share a raw source. This counts retained source data, not verified coverage
in the current canonical score export. Original wave suffixes are not evidence
of phase. For online studies, a separately collected questionnaire before
the discussion experiment counts as pre-start; a survey administered at the
start of deliberation would instead be t1.

| Confirmed retained source IDs | Timing evidence |
| --- | --- |
| uk-crime-1994; uk-eu-1995; uk-monarchy-1996; uk-general-election-1997; uk-health-1998 | Household interviews precede invitation/weekend; UK Health final report PDF p.4 and UK–EU attitude-constraint paper PDF p.8; original poll surveys/codebooks retained. |
| cpl-1996; wtu-1996; swepco-1996 | Recruitment telephone interviews precede invitation; per-poll recruitment facts and retained survey/codebooks. |
| nic-1996 | Initial household interviews before Austin event; NIC research recruitment account and 911-row source. |
| australia-republic-1999 | Initial telephone survey before weekend; `papers/adp5.pdf`, methods. |
| denmark-euro-2000 | Telephone recruitment August 1–8 before August 26–27 event; per-poll timing/recruitment facts and 1,702-row baseline. |
| nic2-2003 | Telephone interview before Philadelphia; shared `reports/foreign-policy-report.pdf`, PDF p.2; 1,493-row source retains attendance/recruitment categories. |
| btp-national-2003 | Initial online questionnaire followed by four weeks of discussions; shared `papers/foreign-policy.pdf`, PDF p.10. |
| btp-online-primaries-2004; btp-presidential-primaries-2004 | Separate pre-experiment questionnaire/control measurements; shared `papers/presidential-nomination.pdf`, PDF pp.6–7 and shared 1,289-row source. |
| btp-general-election-2004 | Baseline before five-week discussion experiment; `reports/online-election-results.pdf`, PDF p.1. |
| btp-health-education-2005 | Pre-experiment questionnaire before five-week discussions; `reports/btp-health-education-results.pdf`, PDF p.4. |
| new-haven-2004 | Telephone interview before March 2002 weekend; retained paper PDF p.8 and Pre/Mid/Post workbook. Historical ID retains 2004. |
| zeguo-2005 | March baseline before April 9 event; `papers/china-zeguo-bjps.pdf`, PDF p.3. |
| marousi-2006 | Telephone, arrival and exit are separate authored source waves; MAR-02. |
| tomorrows-europe-2007 | First-contact baseline distinct from arrival/exit; TE-06 and retained research/multiwave material. |
| northern-ireland-2007 | Early-January initial interviews before invitation to January 27 event; `papers/northern-ireland-paper.pdf`, PDF p.3. |
| vermont-energy-2007 | Telephone recruitment before weekend; per-poll recruitment facts and 750-row source. |
| btp-2007 | Baseline before agreement/four-week discussion experiment; `codebook.pdf`, PDF pp.3–4. |
| san-mateo-2008 | Baseline ends with invitation to a future event; `questionnaire-pre.pdf`, PDF p.9. |
| europolis-2009 | April telephone recruitment before May event; per-poll recruitment facts/CORDIS account. |
| michigan-2009 | Telephone baseline distinct from arrival/exit; MI-02 and 610-row source. |
| california-whats-next-2011 | Telephone baseline distinct from arrival/exit; CA-03 and 472-row source. |
| tanzania-2015 | Household baseline before assignment/event; working paper sections 3.1–3.2. |
| america-in-one-room-2019 | July 9–August 5 baseline before September 19–22 event; `design/a1r-2019-norc-methods.pdf`, PDF pp.3–4. |
| a1r-climate-2021 | August baseline before September online events; `design/a1r-climate-methods.pdf`, PDF p.3. |
| bulgaria-crime-2002 | National survey before invitations; contemporary account and original national-survey source establish the baseline; BGC-07. |
| amr-2024 | Baseline before random assignment and invitation; version 2 paper `papers/amr-paper-v2.xml`, Methods. Final measurement is at event end; AMR-04. |

The remaining coverage questions are not established absences. Bulgaria
2007 documents 1,344 before-event interviews in its report (PDF p.2), but that
raw respondent dataset has not been identified. Bulgaria Crime 2002 was initially unresolved; BGC-07 below establishes its
pre-arrival baseline using contemporary reporting and the original national
survey. AMR 2024 now has verified pre-invitation and event-end phases for
2,419 people; exact interview dates and individual lags remain unavailable.

At least 22 confirmed IDs retain recruitment respondents/nonattendees, and
four more retain broader online controls/calibration populations (BTP 2007,
General Election and both Primaries IDs). Present UK Health, New Haven,
BTP National and BTP Health/Education sources are restricted cohorts; Zeguo's
exact nonattendee-roster coverage is unclassified. Full-source retention does
not establish attendance or invitation for every row. Historical canonical
people outside the reviewed aggregate panel currently have unknown attendance;
absence of group membership must not turn them into known nonattendees.

This count covers the active original 34-ID audit. The 50-entry catalog also
includes 16 materials-only events, and nine additional OOS study IDs exist
outside that catalog. They have not been classified by this coverage audit.

#### X-02 source and cohort verification (2026-09-27)

This review checks the actual questionnaires, papers, reports and recoding
functions underlying the phase catalog. It does not treat a variable suffix,
an existing metadata assertion or the phrase "before and after" as sufficient
evidence of pre-arrival timing. Page references below are PDF page numbers
unless explicitly described otherwise. `t0` means before arrival or, for an
online study, before the discussion experiment starts; it does not establish
that every respondent completed an interview or subsequently participated.

The proportion-correct phase export now covers **32 catalog IDs representing 31
distinct studies**, including AMR's verified t0/t2 measurements. The online and
historical Presidential Primaries IDs are
two projections of the same experiment. Tanzania adds one study with a
standardized knowledge index rather than a proportion-correct battery: across
both scales there are **33 IDs and 32 distinct studies**. The original alphabetical
review covered 14 IDs/13 studies; the Michigan-through-Zeguo review below covered
17 additional IDs, including Tanzania. BGC-07 and AMR-04 supply the two later
verified studies. These are exported study/phase
coverage counts, not the broader retained-source count above and not counts
of complete respondent panels.

The first 14 IDs have design evidence for pre-arrival/pre-start measurement:
A1R Climate, America in One Room, Australia, BTP 2007, BTP General Election,
BTP Health/Education, BTP National, both Primaries projections, California,
CPL, Denmark, Europolis and Marousi. Their specific source locators remain in
`metadata/analysis_phase_roles.csv` and the retained-source table above.
BTP General Election's source `w4bstart/w4bend` dates establish the baseline
fieldwork interval, but individual first-discussion timestamps have not been
located. Its classification is supported by the experiment design rather
than a respondent-by-respondent comparison to each person's first meeting.
For every poll, interview mode, attendance, questionnaire presence and phase
are separate facts.

**Independently checked timing and raw-field mappings.** "Direct" denotes an
explicit recruitment sequence, invitation or measurement-design description,
not exact timestamps for every respondent. "Cross-poll direct" denotes an
explicit account identifying that poll within a common design. A source wave
can be genuine even where only some respondents have answers to it.

| Poll | Actual selected source fields and timing evidence | Confidence and other retained phases |
| --- | --- | --- |
| Michigan 2009 | `data/michigan-2009/questionnaire-pre.pdf`, pp.1/7: telephone interview followed by invitation to the future November 13–15 event. Baseline `q14:q18`, `q4/q5/q7/q8`; departure `t3q38:t3q42`, `t3q10/t3q11/t3q13/t3q14`. | Direct pre-arrival. Arrival `t2q*` exists; only partial common knowledge coverage, described below. |
| New Haven, March 2002 | `data/new-haven-2004/papers/disaggregating-deliberation-27s-effects-28lsero-29.pdf`, p.8: T1 initial telephone interview, T2 written questionnaire **after the first deliberative session**, T3 at weekend end. `R/source_new_haven.R` joins the authored `Pre/Mid/Post` workbook sheets; facts are `pre/mid/post_q35/q36/q37/q39:q43`. | Direct pre-arrival. Mid is `interim_1`, not arrival. The folder/historical label2004 does not change the documented2002 event date. |
| NIC 1996 | `data/nic-1996/codebook.txt`, opening paragraphs: initial household interviews November 4, 1995–January 18, 1996; source T2 combines event-exit participants and contemporaneous telephone nonparticipants. `papers/nic-paper.pdf`, p. 19: source T3 about ten months later after the presidential election. `R/respondent_nic.R` reads suffixes1/2/3 for `WEDLOCK/AFDC/UNEMP/SPEND/TRADE/TROOPSA:TROOPSD/POLREP/POLDEM`. | Direct initial-interview baseline. SourceT2 is exit, not arrival; source T3 is follow-up. Historical `knowledge_midterm` exposes source T2 at canonical t2; its original selected endpoint is source T3/canonical t3. No separate arrival questionnaire is established. |
| NIC2, 2003 | `data/shared/reports/foreign-policy-report.pdf`, p.2, visually checked because scanned: forty-minute telephone interview **before coming to Philadelphia**, repeated at the end of two days. `R/respondent_nic2.R` reads baseline `wrm3_b/c,aid3,wrm5,kno1_a/b,kno2_a/b,kno3_a/b,wrm1_b`, then the same stems prefixed`q`. | Direct pre-arrival. No separate arrival measurement identified in reviewed materials. |
| Northern Ireland 2007 | `data/northern-ireland-2007/papers/northern-ireland-paper.pdf`, p.3: early-January initial interviews precede invitation to January 27 event. `reports/northern-ireland-final-report.pdf`, pp.8–9: questionnaires repeated at5:15pm, event end. Fields `t1q21:t1q27` then `t2q11:t2q17`. `papers/fishkin-deep-divides.pdf`, p.11: telephone T3 about a month later, including `t3q13:t3q19`. | Direct pre-arrival. T2 is exit and T3 follow-up; morning registration does not establish an arrival questionnaire. |
| San Mateo 2008 | `data/san-mateo-2008/questionnaire-pre.pdf`, p.9: last interview question followed by invitation to future March 15–16 assembly and promised arrival arrangements. `R/respondent_san_mateo.R` uses `Q19:Q26` then `t2Q19:t2Q26`. | Direct pre-arrival. No separate arrival knowledge measurement identified. The retained post PDF is an attitudes supplement, not the departure knowledge instrument; see SM-05. |
| SWEPCO 1996 | `data/shared/papers/utilities-paper.pdf`, p.4: telephone survey before invitation, same questionnaire at event end; explicitly identifies CPL/WTU/SWEPCO as first three polls. `R/respondent_utilities.R` reads `SOURCE/USE/RT/SMOG/SETRT` with suffixes1/2. | Direct pre-arrival. The paper establishes timing more precisely than the codebook's "pre-meeting" label alone. No separate arrival wave identified. |
| Tanzania 2015 | `data/tanzania-2015/papers/tanzania-working-paper.pdf`, p.13: household baseline before information video and subsequent invitation to deliberation. p.15/printedp.14: telephone follow-up measures effects **weeks rather than hours** after treatment. Selected indices `H600/H601`. | Direct pretreatment baseline. H601 is later follow-up, not onsite exit. This audit maps it to canonical t3 with role`follow_up`; neither index value nor its original selected-wave label changes. |
| Tomorrow's Europe 2007 | `data/tomorrows-europe-2007/papers/tomorrows-europe-research-paper.pdf`, pp.2/4: first-contact interview before invitation, arrival T2, endT3. Baseline `q16_1:q24_1,q33a_1/q33b_1`; departure `t3q19:t3q27,t3q36a/b`; arrival corresponding`t2q*`. | Direct pre-arrival. Arrival already appears in historical phase scores as canonical t1 via`knowledge_midterm`; it is not an absent phase. Standard item export still omits those arrival item rows. |
| UK Crime 1994 | `data/uk-crime-1994/papers/british-crime-paper.pdf`, pp.9–10: initial household interview/self-completion before invitation/weekend; same self-completion at very end. `R/respondent_crime.R` uses `kw1:kw4,pkw1:pkw3` with source suffixes1/2. | Direct pre-arrival. No separate arrival questionnaire identified. |
| UK EU 1995 | `data/uk-eu-1995/papers/deliberation-attitude-constraint.pdf`, p.8: household baseline/self-completion followed by invitation to later weekend, explicitly including Europe1995. `R/respondent_eu.R`: `eusize/swiss/inctax/elect/ptyapp`, suffixes1/2. | Cross-poll direct pre-arrival. No separate arrival questionnaire identified. |
| UK Election 1997 | `data/uk-general-election-1997/papers/british-election-paper.pdf`, pp.3–4: January initial interviews/recruitment precede April 26–28 weekend; text explicitly calls initial interview "time1". `R/respondent_election.R`: `inflat/intrst/ukempl` and twelve party-placement answers, suffixes1/2. | Direct pre-arrival. No separate arrival questionnaire identified. |
| UK Health 1998 | `data/uk-health-1998/reports/uk-health-final-report.pdf`, p.4: household interview/self-completion establishes benchmark **before invitation**; questionnaire repeated at weekend end. `R/respondent_health.R`: `sopha:sophf`, suffixes1/2. | Direct pre-arrival. An arrival briefing video is documented; that does not establish an arrival knowledge questionnaire. |
| UK Monarchy 1996 | `data/uk-eu-1995/papers/deliberation-attitude-constraint.pdf`, p.8: Monarchy 1996 explicitly included among five polls sharing household-baseline-before-invitation design; p.24 identifies its sample. `R/respondent_monarchy.R`: `Q5A:Q5H,Q8A` then `R5A:R5H,R8A` for historical scoring. | Cross-poll direct pre-arrival, not a monarchy-specific timestamp check. No separate arrival questionnaire identified. |
| Vermont 2007 | `data/vermont-energy-2007/reports/vermont-final-report.pdf`, p.12: initial interview T1, arrival T2, departure T3. `questionnaire-pre.pdf`, p.10: invitation follows last question. Maintained baseline `Q77:Q85`; departure `Q030T3:Q038T3`. | Direct pre-arrival. Full nine-item arrival counterpart`Q030T2:Q038T2` retained, with146 respondents having an answer; now scored in the phase export. |
| WTU 1996 | `data/shared/papers/utilities-paper.pdf`, p.4: telephone interview before invitation and questionnaire repeated at event end. `R/respondent_utilities.R`: `SOURCE/USE/RT/SMOG/SETRT`, suffixes1/2. | Direct pre-arrival. No separate arrival questionnaire identified. |
| Zeguo 2005 | `data/zeguo-2005/papers/china-zeguo-bjps.pdf`, p.3: March 2005 initial survey before April 9 event. `R/respondent_zeguo.R` reads reconstructed `pre_d3043:pre_d3046` and `post_d3043:post_d3046` components, retaining the explicit knowledge-reconciliation ledger. | Direct initial-survey baseline. No separate arrival knowledge questionnaire identified; source-version reconciliation remains separate from timing. |

"No separate arrival identified" is a limit of the retained evidence reviewed,
not proof that no such questionnaire was ever administered. Conversely, a
missing published arrival score can be our extraction limitation even when
original answers remain in the repository. Do not move pre-arrival scores to
t1 merely to make a requested arrival-to-exit comparison available.

**Verified arrival answers now scored in the phase view (2026-09-28).**
The five retained sources below now have `score_exported` status. Existing
selected-wave scores remain unchanged; new phase scores use explicit battery
identities and questionnaire-presence evidence.

| Poll | Recovered source and coverage | Required distinction before scoring |
| --- | --- | --- |
| California 2011 | `data/california-whats-next-2011/survey.parquet`: arrival`t2q27:t2q34`. First five are counterparts of current telephone`t1`/departure shared bank; all eight form the separate report battery in`metadata/california_knowledge_items.csv`. Reports/questionnaires remain under that poll folder; CA-03 gives item wording and count checks. | Keep five-common-item and eight-report-item definitions separate. The existing eight-item supplemental export is not a silent replacement for the five-item selected-wave bank. |
| Europolis 2009 | `data/europolis-2009/survey.sav`: six common arrival `V2Q43/V2Q44/V2Q46/V2Q47/V2Q49/V2Q50`; three arrival-only `V2Q45/V2Q48/V2Q51`. `reports/europolis-knowledge.pdf`, p. 1; research-paper Table 2/printed p. 11; EURO-05. | Six-item baseline/arrival/exit comparisons and nine-item arrival/exit comparisons have different denominators and coverage. Preserve the three one-answer baseline publication discrepancies rather than recoding to match the paper. The former questionnaire-post.pdf was a misfiled content duplicate of Tomorrow’s Europe 2007 and has been removed (EURO-01); actual V2/V3 source labels and the knowledge report establish this battery. Metadata preserves abbreviated source distractor labels for V2Q48/V2Q51 instead of inventing their missing wording. |
| Denmark 2000 | `data/denmark-euro-2000/arrival.sav`:363 unique`DELNR`, linked to baseline`delnr`;358 overlap the current departure IDs. Nine arrival fields`S4_1:S9_1,S11_7_1,S11_9_1,S11_11_1`. Paper`data/denmark-euro-2000/papers/deliberative-democracy-euro.pdf`, Table 9/PDF p. 19; DK-02 distinguishes the current359 departure records. | The original arrival file and dictionaries are now public; DK-05 records exact-byte preservation. The arrival scores now join by DELNR; 358 of the 359 existing phase participants
have an arrival form, and DELNR 203 remains missing. Do not equate363 arrival IDs,359 departure IDs and358 overlap, or infer missing identities from the anonymous deposited battery. |
| Vermont 2007 | `data/vermont-energy-2007/survey.sav`: all nine`Q030T2:Q038T2`, with146 respondents having at least one answer. Final-report PDF p. 12 explicitly identifies arrival. | Use the reviewed report-based keys, including VT-01's renewables decision, while retaining the instrument ambiguity; do not alter keys simply to expose the wave. |
| Michigan 2009 | `data/michigan-2009/survey.parquet`: four common arrival placements`t2q10/t2q11/t2q13/t2q14`, plus arrival-only standard-of-living placements`t2q7/t2q8`. There are no arrival factual counterparts`t2q38:t2q42`. Final report PDF p. 13 marks the two added placements as arrival. | This is **partial** arrival coverage, not the complete current nine-item bank. The two added items have196/209 correct responses; dividing by310 reproduces report63.2%/67.4%. Report11-item baseline combines telephone facts/four placements with two arrival-only placements. Do not silently turn that mixed-time bank into a uniform baseline. |

**Completed upstream implementation: arrival comparisons.** `R/analysis_arrivals.R`
adds the five-question California, six-question Europolis, nine-question Denmark
and nine-question Vermont arrival scores to their existing comparable batteries.
Michigan receives a separate four-placement battery at telephone, arrival and
exit; its absent arrival factual questions are not borrowed from telephone or
scored as incorrect. Separate expanded batteries retain California's eight
arrival/exit items, Europolis's nine, and Michigan's six placements. The latter
two added Michigan placement questions never enter a telephone comparison.

The arrival expansion preserved the 115,707 original phase-score rows and added
17,439 rows, including explicit absent-wave records. AMR-04 subsequently adds
4,838 unchanged source scores, bringing current phase-score coverage to 137,984
rows. The typed `analysis_phase_item_responses` table now contains 936,138 rows:
the earlier 867,004 mapped records, including 133,869 added arrival item/battery
rows, plus 29,028 AMR responses and40,106 intermediate Tomorrow’s Europe/New Haven
responses. Documented nonanswer-status corrections change
status labels, not the underlying responses or numerical scores.
Its key includes source cohort, respondent, battery, original survey instance,
and canonical question ID. Multiple batteries can reuse an item without implying
that their denominators or populations are interchangeable. The question catalog
adds eight arrival-only questions with their wording, keys and retained sources.
Score-only Marousi measurements remain explicitly score-only. AMR contributes
verified pre-invitation and event-end measurements, with no arrival wave inferred.

| Source cohort | Retained people | Observed arrival forms | Comparable battery |
| --- | ---: | ---: | --- |
| California Cor-Sood | 396 | 396 | Five common items; separate eight-item arrival/exit battery |
| Europolis historical recruitment source | 4,384 | 348 | Six common items; separate nine-item arrival/exit battery |
| Europolis Cor-Sood | 348 | 348 | Same source answers with the separate source-cohort identity retained |
| Denmark Cor-Sood | 359 | 358 | Nine common factual/party-placement items |
| Vermont Cor-Sood | 146 | 146 | Nine common items using the approved final-report key |
| Michigan Cor-Sood | 310 | 309 | Four common placements; separate six-placement arrival/exit battery |

Michigan source ID 5000 (source row 306) has no answers anywhere in its arrival
questionnaire; both arrival scores remain missing. Denmark's DELNR 203 has no
matched arrival record. The other five records among Denmark's 363 raw arrival
IDs remain in the preserved source, outside the existing 359-person analytical
cohort. California's previously approved 412-person eight-item export also remains
available unchanged; the new common phase view retains its existing 396 people.
No source person is silently added to or removed from a previously defined cohort.

The independent count checks reproduce Europolis six-item arrival 27.7778%,
nine-item arrival 29.6296% and nine-item exit 37.8033%. California's 396-person
eight-item totals are 1,900 correct arrival answers and 2,430 correct exit answers,
matching CA-03. Michigan's two added arrival items have 196 and 209 correct
responses, matching MI-02. Denmark's six arrival facts reproduce Table 9's
71%, 78%, 66%, 83%, 55% and 91% when computed over each item's observed responses
(358–361 responses in the 363-row source); the canonical score instead retains
the established fixed-nine-item denominator within an observed questionnaire.

These additions enable new comparisons upstream. A downstream analysis must
choose its comparable battery and source cohort explicitly; publication-era
item discrepancies, unknown group assignments and the accepted Vermont key
ambiguity remain documented above. They are not grounds to recode respondents
until a report is reproduced by construction.

Tomorrow's Europe is not in this missing-arrival list: its arrival score is
already exposed in `analysis_phase_scores`, although arrival item responses
are now exposed individually in the common phase item table. The transport
adds39,050 Tomorrow’s Europe arrival item rows (3,550 source people ×11 items)
and1,056 New Haven interim item rows (132 ×8). All337 source-observed arrival
scores and all132 interim scores reconstruct exactly; all existing score and
participant tables remain byte-identical. The3,213 source records with unknown
arrival-form presence retain that uncertainty and missing item correctness;
no missing form is represented as eleven wrong answers. These are source-scope
rows, not3,550 event attendees. Original placement codes are shifted only for
Tomorrow’s Europe’s verified telephone-versus-event scale convention. Reviewed
invalid arrival codes become nullable correctness under the shared rule; a
missing fielded arrival form still prevents inventing response labels for
undocumented categories. New Haven's Mid and NIC's source
T2 must not be added as arrival. NI's later telephone reinterview is follow-up,
not a missing arrival wave.

**Attendance corrections in the additional phase view.** The current repair
separates event attendance from assigned discussion group and completed post
questionnaire, while preserving historical selected-wave exports. For the
seven reviewed CorSood projections, attendance/presence evidence is:

| Source projection | Evidence and resulting classification |
| --- | --- |
| BTP 2007 |301 selected`group==1` respondents. Codebookp.4 defines this group as post-completers attending all four sessions.300 have substantive`POST_Q31a_groups:POST_Q31f_groups` event evaluations. CaseID 2392 instead has`discuss3==1` and`dtime3==45.80426`, positive actual discussion activity. Scheduled`S1:S4` times alone are not attendance evidence. |
| Online Primaries 2004 |328 experimental-arm respondents include250 actual meeting attendees and 78 nonattendees. Source`mtg1:mtg5` and`mtgatt` establish attendance independently of`groupnumc`;46 nonattendees still have a filled post questionnaire. Post answers therefore cannot serve as an attendance flag. |
| California 2011 |396 current selected respondents are known attendees and have observed departure questionnaires.386 have an observed telephone baseline; ten have a wholly absent telephone baseline. Keep their missing baseline presence distinct from the separate arrival questionnaire and from attendance. |
| Denmark 2000 |359 current selected departure respondents; DK-02 supplies unique identity linkage and questionnaire evidence. ID 321 has all nine facts blank but41 other departure answers, so its observed-wave knowledge score remains zero. |
| Northern Ireland 2007 |124 currently selected participants. Retain event-exitT2 separately from laterT3 participant/control interviewing. The source/report roster counts are not silently substituted for the selected extract. |
| Vermont 2007 |146 selected participants with source attendance flag; their arrival/departure observations remain separate from telephone baseline presence. |
| Michigan 2009 |310 selected respondents identified by observed`postit`, not the first310 source rows; preserve independent questionnaire presence and 16 discussion-group identities. |

This changes the phase-view description of attendance and wave availability;
it does not make an experimental-arm nonattendee into an attendee because a
post form or assigned group exists. Whole absent questionnaires are missing,
while wrong, don't-know and unanswered items inside an observed questionnaire
retain the bank's documented fixed-denominator scoring. Keep positive evidence
and unknown presence separate; missing source answers alone do not establish
nonattendance.

**Main Primaries cohort and duplicate correction approved and implemented.**
The previous main known-group online projection has 315 people: 249 meeting
attendees and 66 nonattendees. Its historical Primaries 217-person projection
is a subset of those same 315 people, not a second study, and aligned item
scores are identical.
Both project from the same original survey, SHA-256
`c51aa34b351e1e1726658f6adb415a3743bd2b4cd53e1d71222a857de98b9ebe`.
The upstream phase catalog records their shared study identity and explicit
attendance evidence. The historical main aggregate remains a preserved source
projection; changing the downstream main reader is a separately authorized
analysis correction, not a rewrite of those historical source answers.

The measured online mean knowledge gain, in percentage points, is
`4.62585034` for all 315 known-group experimental-arm respondents,
`9.35169248` for 249 attendees, and `11.16446579` for 238 attendees with an
observed post questionnaire and known group. These are different samples,
not alternative answer keys. The full experimental arm has 250 attendees;
the main known-group projection contains 249. Neither a positive post score
nor a filled post form substitutes for meeting attendance.

The user approved replacing the main reader's two Primaries projections with
one study and selecting actual attendees with observed baseline and departure
questionnaires: **239 paired attendees**, of whom **238 have known discussion
groups**. The one paired attendee without a group remains eligible for paired
person-level analysis and is excluded only from an analysis requiring a group.
The 217-person historical subset does not contribute a second copy of its
people or an additional study. The downstream reader consumes upstream typed
study identities, attendance and questionnaire-presence fields; it must not
recreate these facts from group assignment or a positive quiz score. The
percentage-point comparisons above document the previous known-group sample
choices; they are not an unmeasured gain estimate for all 239 pairs. The current
`dp-learning` `R/learning.R` implements this selection using the upstream phase
tables: it requires observed t0/t2 questionnaires and attendance, removes the
historical alias of the same study, and asserts one poll per study in the final
panel. The cohort correction is therefore implemented, not pending. The sample
comparisons above distinguish its attendance and questionnaire requirements;
they do not attribute the change in a pooled model estimate to each requirement
separately. Answer keys remain unchanged.

The Denmark arrival file is now retained publicly as
`data/denmark-euro-2000/arrival.sav`, with registered source and dictionaries
(see DK-05). The phase build now exports its verified arrival scores and item
responses; the earlier `source_exists_but_not_exported` status is superseded.
The 363 arrival identities and their 358 overlaps with departure records remain
distinct from a complete three-wave analysis sample.

### X-03: Typed missingness and explicit denominators

**Explicit imputation names (approved September 29, 2026).** Across poll builders,
an attitude measure that substitutes a midpoint for nonresponse has a separate
snake_case name ending in `_midpoint_imputed`, after its wave suffix. For example,
`research_t2` preserves an all-missing attitude index, whereas
`research_t2_midpoint_imputed` retains the authored midpoint substitution.
For WTU/SWEPCO and Zeguo, partial indices still average available components:
this does not fill every omitted component or treat a substantive neutral
answer as missing. Australia separately retains authored midpoint assignments
inside its ranking component only in the explicitly imputed variant.
Whole absent departure questionnaires remain missing in both variants.

The metadata identify the source fields, stage of imputation and calibration.
In particular, WTU departure research fills raw 5 before the fixed [1,10]
rescaling, producing 4/9 rather than 0.5. WTU/SWEPCO conservation and renewables
fill 0.5 after calibration. Zeguo fills 0.5 after its project-index calculation.
Historical aggregate mappings and attitude-extremity calculations explicitly
select the authored imputed variants; missing-preserving indices are independently
available for new analyses. Completeness counts continue to count substantive
source responses, not imputed values.



**Global attitude-path check.** A source-code replay across all 21 reconstructed
polls found four with nonresponse midpoint assignments: WTU, SWEPCO, Zeguo and
Australia. The first three have 42 wave-specific indices; Australia adds four
ranking variants. Its plain versions exclude ranking codes 97 (DK), 99 (not
answered) and 100 (not applicable), while retaining the known Queen-first rank
component of zero and averaging available republican components. Among the 347
historical Australian participants, plain versus imputed scores differ for 30
baseline and 35 post popular-preference indices (now missing), and 17 baseline
and 61 post republican indices (different available-component means). All 46
explicit imputed variants reproduce the previous authored values outside the
approved absent-form correction.

The additional canonical readers contain 174 baseline items across seven polls
and use bounded rescaling without a midpoint fill; Tanzania's 22 attitude items
also retain nonresponse as missing. NIC2 and BTP National/Health midpoint mappings
are substantive response categories, not DK replacements. Michigan has no retained
value-label dictionary, so this review establishes its implemented no-fill rule,
not the meaning of every original code. This is coverage of all implemented
attitude paths, not a claim that missing source records have been recovered for
all 34 registered polls.

The canonical attitude catalog retains 303 entries: 23 baseline IDs now name
the imputation explicitly, with all 865,934 existing response values preserved.
The downstream `dp-learning` attitude-summary function returns identical values
for all 51,924 source-scoped respondent records. Historical replay scripts select
the explicit imputed variants so that earlier approved corrections remain
independently reproducible.

**Source-label repair (2026-09-28).** The shared response reader previously used
only SPSS/Stata missing-value declarations. Explicit value labels such as
“Don't know” or “Refused” could therefore appear as `answered` when the source
had not also declared their numeric codes missing. The reader now recognizes
an exact list of unambiguous nonanswer labels, after removing parentheses and
original numeric label prefixes. Conflicting labels for the same field/code,
merged neutral/don't-know categories, and substantive sentences containing
“don't know” remain unchanged. Raw codes are retained.

| Poll | Responses relabeled non-substantive | Measure completeness counts updated |
| --- | ---: | ---: |
| BTP Health and Education | 387 | 472 |
| BTP National | 90 | 129 |
| BTP Presidential Primaries | 5,178 | 7,022 |
| Bulgaria Crime | 1,043 | 1,070 |
| Tomorrow's Europe | 2,035 | 2,133 |
| UK Health | 885 | 761 |
| UK Monarchy | 1,251 | 1,517 |
| **Total** | **10,869** | **13,104** |

The [field/code counts](../audit/corrections/shared-response-status/field_counts.csv)
make the changes inspectable. `n_observed_fields` counts substantive inputs to
a measure, so its changes can outnumber changed source responses when a source
field enters several measures. All raw values, numeric respondent measures,
knowledge correctness, scores, people, aggregate outputs, and all 13 canonical
analysis Parquet tables remain identical to the preceding build. This repairs
explicit source labels; it does not claim to recover every unlabelled sentinel.

Interview presence is assessed separately. Primaries respondents 950382 and
950534 have `compf1 == 1` (completed follow-up) despite no substantive answers in
the selected batteries. National source respondent 364 (historical ID 930087)
has a recorded interview from January 16, 2003, 06:15:13 to 06:24:59 and a
positive recorded duration. These records retain observed follow-up status.
The shared phase reader uses those source completion flags or recorded interview
times to fill unknown presence; noncompletion alone does not establish absence.
It does not alter attendance. Independent enumeration verifies all 244 National
and 745 Primaries interviews supported by these fields were already marked
observed before this repair. No new presence flags are introduced.


Missing, inapplicable, refused, don't know, invalid, not asked and absent interview
are different states. A zero-filled knowledge score may deliberately count some
missing answers as incorrect; preserve that as a named scoring policy while
retaining raw response reasons. Partial attitude-index means have changing
observed denominators. Neither policy should be silently generalized to the other.
The former `pfemale_ind` helper used full group size in its leave-one-out
denominator, while `pfemale` omitted missing genders. The former entropy helper
also divided observed categories by full group size. BTPHE-01 exposed this mismatch
in groups 9707 and 9727; NH-06 showed why minority entropy could remain
unchanged when refusal was restored to missing. The approved shared corrections
below now use observed answers, with cross-poll comparisons recorded separately
from the respondent-level source corrections.

**Observed-peer denominator correction (accepted and implemented 2026-09-28).**
Direct enumeration of every person's other group members identified
194 incorrect observed peer shares under the former formula in 14 groups:
Zeguo 78 values in six groups, NIC 1996 83 in six groups, and BTP Health and
Education 33 in two groups. The other 18 reconstructed polls agree within
`1e-10`. This comparison preserves each poll's composition population, including
the full 299 source records used for BTP General Election's group summaries.

For example, Zeguo group 5216 has one woman, seven men and two missing genders.
For the woman (historical ID 52097, source ID 97), the old formula is
`((1/8)*10 - 1)/9 = 1/36`, about 0.02778. Her seven peers with observed gender
are all male, so their observed female share is zero. The implemented shared rule
is `(observed female count - focal female contribution) / observed peer count`.
It yields missing if no peer gender is observed. Missing focal gender supplies
no subtraction from either observed count; it does not prevent describing the
other respondents. That additionally supplies peer shares for 16 previously
missing cases (eight Zeguo, six NIC, two BTP Health and Education). All 5,869
exported person identities remain unchanged. Historical and corrected values
are within [0, 1]; this was a denominator error, not an observed range violation.
The maximum change among previously observed values is 1/36. Neither the
individual gender recodes nor the inclusive group female shares change.
The independently enumerated peer counts and approved values are retained in
`audit/corrections/shared-peer-composition/`. The user noted the missingness
assumption behind group means. These are means among observed peers. Interpreting
them as the entire group's mean requires the unobserved peers to have the same
mean as the observed peers; MCAR within a group is sufficient but stronger than
this mean-equality requirement. Missingness counts remain part of the evidence.

A fresh check of the 21-poll reconstructed aggregate on 2026-09-27 also
identifies an absent-category problem. `historical_entropy(value, 4L)` indexes
four observed frequencies without supplying zero counts for unobserved
education categories. With only one, two or three observed categories it
returns missing. The final `rowSums(..., na.rm=TRUE)` then silently omits the
education component. This occurs in 185 of the 397 recognized discussion
groups, containing 2,511 people. These groups have observed education; this
is not a claim that education was entirely unanswered. For example, three
equally frequent observed categories have Shannon entropy `log2(3)`, about
1.584963 bits, but the historical helper returns missing. An unobserved
fourth category should contribute zero, not make the component unavailable.

The binary missing-denominator problem can also manufacture diversity: for
`c(1, 1, NA)` the historical helper returns 0.918296 bits although the two
observed answers are identical. It treats the unknown person's share as the
other category. An observed-answer denominator would give zero, while keeping
the unknown person's answer missing. Which respondents belong in the summary
and how much information a component requires must be made explicit; unknown
answers do not establish a complementary demographic category.

These were reproduced behaviors of the inherited shared helper. The prior
`tests/testthat/test-polardata-derived.R` intentionally preserved them for
reconstruction parity; the approved correction replaces those expectations
with mathematical and missingness checks. The original
`historical-cdd-scripts:legacy/merge_data_scripts/03_data.R` likewise sums
components with missing removal. Correcting the shared formulas requires one
versioned cross-poll comparison, with component coverage recorded; it must
not be folded silently into any of the respondent corrections above.

**Shared entropy correction approved on 2026-09-27.** The user explicitly
requested the shared fix. `R/polardata_derived.R` now computes Shannon entropy
in bits from every observed rounded category frequency divided by the number
of answered values. Missing answers are excluded from both category counts
and denominator; an absent category contributes zero. A component with no
answers remains missing. The combined field remains the sum of available
marginal gender, minority and education entropies, with an entirely unknown
combined score missing. It is not a joint entropy, a standardized index, or a
claim that every poll measures the same education construct. Existing rounding
to two decimals and all respondent input coding are preserved.

An independent reference calculation captured each poll's actual composition
universe before editing the helper. BTP General Election 2004 computes its
composition on 299 source people before exporting 248; that population remains
unchanged. Recalculating from the final export alone would wrongly change 14
of its 15 group scores. Using the actual 299-person summary population changes
only four groups (9403, 9410, 9413, 9415), containing 54 exported people. The
other 20 poll composition builders use their selected respondent populations.
Across all 21 reconstructed polls, the rebuilt output matches the independent
reference: 245 of 397 group scores change beyond the existing 1e-10 comparison
tolerance, repeated over 3,436 of 5,869 exported people; no
respondent, membership or non-entropy field changes from this shared fix.

The earlier 185-group / 2,511-person absent-category diagnostic used only
exported people. Matching the actual producer populations establishes 184
groups / 2,506 exported people with observed education whose component was
omitted. This refines the diagnostic count; it does not change a poll's sample.
Coverage is recorded explicitly: 363 groups have all three observed components,
34 have two. Retaining the historical available-component sum does not make
those totals equally complete; the component audit makes that distinction
visible. The all-components-unknown and unassigned-group boundaries are tested
synthetically, since no current exported group has wholly unknown components.

Europolis needs a distinct interpretation: source `educ1` asks the age at
completing full-time education. The maintained school-leaving-age proxy,
including its existing still-studying conversion, yields 23 rounded values
across 348 attendees, rather than four qualification categories. The old helper
silently used only its first four observed frequencies. All 25 Europolis group
scores change when every observed value is counted. Group 711 has 12 observed
education answers among 14 people across seven values: its education component
changes from 1.292089 to 2.625815 bits. Group 7125 reaches 3.5 education bits
(16 observed answers, 12 values); combined entropy reaches 5.278967 bits in
group 7124. A four-category ceiling would be inappropriate for this existing
proxy. No binning or new education recode is imposed by the arithmetic fix;
comparability or an alternative qualification measure needs its own review.

The new definition is `entropy-observed-v2` for every poll. The independently
calculated [frozen comparisons](../audit/corrections/shared-entropy/approved_values.csv)
retain immutable historical, preceding-release and approved values for all
5,869 identities, including NIC's missing historical ID and the two previously
approved BTPGE additions absent from the original benchmark. The [component
audit](../audit/corrections/shared-entropy/group_components.csv) records source
and exported group sizes, observed counts, category counts, coverage and each
old/new component. Prior poll correction snapshots are preserved as evidence;
the shared entropy comparison supersedes only their entropy values.
The separate leave-one-out missing-answer denominator issue in `pfemale_ind`
remains for its own shared assessment; no leave-one-out formula is changed here.

There are also 230 final-digit differences in 15 other group scores, at most
4.4408920985006262e-16, from calculating both binary probabilities directly
rather than using one probability's complement. Thus 3,666 exported entropy
values differ at the bit level, of which 3,436 exceed the existing 1e-10
tolerance. The frozen comparison retains both kinds of changes; the 245-group
figure describes differences above tolerance, not every changed text line.

The source rebuild matches the frozen reference for every identity. Source and
Data Package validation, mathematical boundary tests, all 21 frozen comparisons,
representative source-built poll regressions, provenance checks and lint pass.
Aggregate parity has zero unexplained differences. The shared change leaves
all respondent tables byte-identical to the BGC-06 commit. At initial validation,
canonical analysis exports were byte-identical to the preceding main version.
PR #69 subsequently added demographic covariates while this correction was
being prepared. Rebuilding the combined analysis exports propagates exactly
five approved missing-value corrections: the three AUS-05 refused ages and
the two BGC-06 unlabelled ethnicities. Every other participant field and all
other analysis tables remain unchanged; entropy does not enter these exports.
No model or paper results were rerun.

#### Separate knowledge and attitude conventions (implemented September 29, 2026)

Knowledge responses now retain a nullable `correct` / `incorrect` / `dk`
classification, raw answer, source label and separate `response_reason` in both
canonical item tables. Only documented DK/cannot-say equivalents become `dk`.
Refusal, blank, combined nonanswer categories and absent questionnaires are not
silently relabeled DK. Reviewed nonanswers within an observed questionnaire score
zero in the separate integer `correct` field; an absent questionnaire remains
missing. Enrichment preserves every person/battery score total. This policy is
separate from attitude scoring: plain attitude indices preserve nonresponse, and
authored midpoint-imputed alternatives carry `_midpoint_imputed` in their names.

`metadata/knowledge_response_codes.csv` records field-specific evidence where
retained value labels alone are insufficient. Denmark's separate arrival and
exit dictionaries, California and Michigan's questionnaires, and the NIC
codebook resolve source-wave response options. These sources preserve DK for
subsequent guessing adjustment without imposing that adjustment upstream.
`guess` consumers should use the trichotomy and `na_as = "missing"`; the
package's default otherwise interprets missing inputs as DK.

Remaining source limitations are explicit. Climate Q17/Q18 lack independently
verified missing-code documentation. New Haven's combined baseline no-response/
DK categories cannot be split retrospectively; its post Q36 field form and CATI
instrument disagree about whether “same” was offered, with no observed terminal
code 4 to resolve the discrepancy. California `t3q33 = 0` (source row 447,
ID 526) and Michigan `t2q10 = 9` (source row 83, ID 501) are now classified
as invalid responses outside the offered options; CA-05 and MI-03 document
why their intended answers remain unrecoverable. Previously cleaned system-missing or score-only data cannot recreate a
lost distinction between a blank and DK. No answer key changes are made here.

All historical `output/polardata/` files remain byte-identical. Running the
current dp-learning readers against the old and rebuilt upstream tables gives
identical 10,272-row attendee panels and identical 8,486-row main model frames,
including attitude and peer-knowledge predictors. Attendance and phase-specific
analyses can change: ZG-07 documents the additional verified returned questionnaire
and its effect on the phase gain. UKM-08 removes fabricated departure scores
for 599 nonparticipants; it leaves all 258 attendees unchanged.

**Invalid responses (approved September 29).** The user chose missing rather
than zero for invalid item responses. The shared knowledge standardizer now
maps every documented `invalid_response` to missing correctness, including
A1R2019's multiple-response code−8 and the questionnaire-backed California/
Michigan out-of-range codes above. Raw codes and reasons remain intact; DK
continues to score zero. This does not classify undocumented codes by analogy.
The existing fixed-denominator battery scores are preserved: item correctness
missingness and the established aggregate scoring convention are separate.
Peer item calculations must exclude invalid item observations rather than
mistake them for a wrong answer or an opportunity to learn.
The [cell comparison](../audit/corrections/shared-response-status/invalid_response_cells.csv)
records97 selected item cells,112 phase item cells and one supplemental
California item cell. These views repeat the same107 underlying source answers;
Michigan’s single answer also belongs to two phase batteries. New Haven adds30
invalid departure answers and Zeguo adds13 invalid answers across both waves.
The remaining sweep adds Tomorrow’s Europe’s two invalid exit answers and
San Mateo’s two invalid exit answers in both historical and Cor–Sood projections,
plus12 newly exposed Tomorrow’s Europe arrival answers. The latter had no
previous canonical item row; their blank `old_correct` in the comparison means
not previously exposed, not a previously observed zero. All score tables
and historical polardata files remain byte-identical. The main score-based dp-learning predictors are unchanged by these additional
invalid-code rules. Zeguo has invalid baseline items, so item-level peer
calculations must honor their missing correctness; downstream verification is
recorded with this correction. The downstream reader had been filling missing
item correctness with zero before peer and guessing calculations. Removing
those fills changes20 Zeguo peer predictors, with no new missing peer values.
The item model remains8369 people across27 polls and623 groups; its peer
coefficient moves from−0.0891 to−0.0890. The score-based main model and its
8486-person cohort are unchanged. Case-level changes and fitted model points
are retained beside the invalid-response cell comparison.

#### Shared attendance classification (approved September 29, 2026)

The user approved treating an absent immediate post-deliberation questionnaire
as evidence of nonparticipation, with the inference clearly distinguished from
an observed participation record. `analysis_attendance_contract()` applies this
rule after independently established questionnaire presence. It fills unknown
attendance only: a positive session or attendance record takes precedence over
an absent exit form. Missing later follow-up, unassigned discussion groups and
blank knowledge items within a returned form do not establish nonattendance.
Both selected and phase participant tables now carry matching `attended` and
nonnullable `attendance_basis`; assignment, source arm, panel, person identity
and questionnaire responses remain separate and unchanged by this helper.

| Source evidence | Classification change |
| --- | --- |
| CPL `part`; WTU/SWEPCO `PART`, codebooks label 1 participant and 2 nonparticipant | 1,030 CPL, 1,000 WTU and 1,246 SWEPCO previously unknown records become false with `source_indicator`. |
| Europolis `GROUP_T1BIS`, retained value labels 1 participant, 2 nonparticipant, 3 control | 4,036 previously unknown records become false with `source_indicator`; participation is not inferred from group assignment. |
| Zeguo uniquely matched onsite POST forms (ZG-07) | 34 absent forms imply false; p36 and p211 have returned forms and become true despite missing groups. The returned blank-quiz p90 remains true. All 36 remain outside the existing paired panel. |
| Climate `SESSION1`–`SESSION4` and substantive raw `T2Q*` answers | Of 7,018 invited noncompleters, 184 have recorded attendance and become true; 426 have four observed zero session flags and become false. The remaining 6,408 have no session records or post-questionnaire answers and become inferred false. |
| BTP General Election verified absent post forms and no stronger attendance classification | 33 previously unknown records become inferred false; known attendees with absent post forms remain attendees. |
| Marousi full recruitment questionnaires | 1,116 phase-only records without either event questionnaire become inferred false; observed arrival or exit evidence retains true attendance. |

Climate's 184 partial/completed-session attendees comprise 123 with one recorded
session, 22 with two, 33 with three and six with four. They retain
`arm = invited_noncompleter` and `panel = FALSE`. All 962 documented completers
and 834 controls retain their attendance classifications. `FINAL_ATTEND` is
not given invented code labels: the actual session fields establish positive
participation, and raw post-response fields independently establish absence.
This prevents the completion label from circularly defining questionnaire
absence or erasing partial attendance.

The historical and Cor adapters were independently rerun against the same
`read_poll_survey()` inputs. Every one of the 4,705 Cor identities in the 16
shared polls has the exact source row used by the historical adapter, including
polls whose selection sorts source IDs. This bridge transfers known attendance
only; no score-based linkage, cross-file row matching or pooled duplicate person
is introduced. Twenty-eight Cor records whose historical attendance remains
unknown remain unknown (24 Tomorrow's Europe and four BTP General Election).
Seven other Cor cohorts retain their already reviewed source attendance evidence;
the selected table now receives that evidence too, eliminating the previous
1,964 selected-versus-phase attendance disagreements.

Against the pre-change canonical tables, this attendance-only helper fills
21,639 previously unknown selected classifications (6,749 true and 14,890 false)
and 20,791 previously unknown phase classifications (4,863 true and 15,928 false).
No known true/false value changes. Counts refer to source-scoped records, not
unique people pooled across overlapping deposits. The differing totals reflect
Marousi's additional phase-only recruitment records and the previous selected/
phase inconsistency. Every prior panel flag, assignment, group, person key and
non-attendance covariate is identical. Focused tests cover source indicators,
partial participation, later-wave absence, returned blank quizzes, conflicting
presence evidence and verified identity bridges. These classification changes
are separate from the approved Texas, Zeguo and UK Monarchy absent-questionnaire score changes.

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

The older downstream inventory and porting-review tables described files before
the `dp-learning`/`dp-nireland` relocations. The 2026-09-28 refresh updates the
tracked-file inventory and fixes the optional text comparison to the removed
local Northern Ireland roster: it records local/upstream presence and leaves
text equality missing when the local copy is absent. An absent upstream file
still fails. These artifacts describe file presence, not a complete proof of
runtime dependencies or adoption of current canonical measures. No respondent
data or estimates change through this tooling repair.

### X-08: Evidence needed before accepting a change

For each numbered concern, the next review should append: the exact instrument
version and question wording/response order; the codebook and executed syntax;
the authors' documented rationale or remaining uncertainty; counts of affected
people and cells, by wave and sample; the old and candidate values on the same
people; downstream estimates with unchanged and changed sample definitions
separated; a rejected-alternative explanation; and an explicit decision to
preserve, relabel, revise, or leave unresolved. A monotonic scale that looks
intuitive is not sufficient evidence to replace a deliberate transformation.

### X-09: Generalized variance has six remaining reviewed numerical exceptions

Before X-15, the source formula differed from the frozen historical executable's
`genvar` in eight numerically sensitive groups, covering 55 export cells. X-15
now makes the two indefinite San Mateo cases missing (11 cells), leaving six
reviewed numerical exceptions covering 44 cells. These are not all negligible
absolute differences, and they are not replaced by benchmark values.

| Poll | Groups | Cells | Largest absolute difference |
|---|---|---:|---:|
| UK–EU 1995 | 2099 | 4 | 0.000063499 |
| BTP Health/Education 2005 | 9713, 9715 | 20 | 0.000209632 |
| San Mateo 2008 (pre-X-15 inventory) | 9601, 9604, 9616, 9617, 9621 | 31 | 0.003464282 |

Historical generalized variance takes the absolute determinant of a pairwise
covariance matrix and raises it to `1 / (2 * number_of_indices)`. Near-zero
determinants become much larger after this root, magnifying rounding differences.
The original nested calculation is retained in code to preserve its own rounding.
UK–EU group 2099 has N=4, P=4, rank=3; BTP groups 9713 and 9715 have
N/P/rank 11/11/10 and 9/11/8. San Mateo's five groups have N=5–7 and P=7.
The 15 historical Zeguo exceptions were removed after ZG-05 replaced the
duplicated main-roads slot with the Wenchang project rating, making all 16
group matrices full rank.

Two San Mateo matrices also have materially negative eigenvalues. Group 9601
has N=6, five complete rows, pairwise N=5–6, and minimum eigenvalue -0.01431241.
Group 9621 has N=5, four complete rows, pairwise N=4–5, and minimum eigenvalue
-0.01560969. Pairwise deletion can produce indefinite covariance matrices;
these negative eigenvalues are not roundoff. Both matrices additionally have a
near-zero eigenvalue, which explains determinant sensitivity. Historical absolute
determinants hide the sign. The user-approved X-15 rule now returns missing
for these matrices and the other materially indefinite matrices across polls.
The remaining valid, numerically singular cases retain the historical arithmetic;
these values are not silently set to zero or made positive definite.

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
| Ages outside16–100 made missing | Zeguo age 1 and Europolis age 109 were reviewed using paired answers and the birth-year distribution (ZG-04 and EURO-06). Corrected derived ages now range from 18 to 98; `dp-learning` PR #4 removes the reader-side clipping and retains an assertion. Raw answers remain available upstream. |
| Greece post knowledge zero made missing when baseline is positive | Superseded by MAR-02's source-backed questionnaire-presence rule: absent forms remain missing, while blank answers within observed forms score zero. The old zero-score heuristic is not the maintained rule. |
| Greece education code7 made missing | Verify source category labels and export missing-value convention before centralizing. |
| Knowledge rounded to10decimals | Centralize documented numeric storage handling and test exact boundaries; preserve distinct knowledge definitions. |
| Primaries exact duplicate rows dropped | Use upstream canonical person identities and named samples instead of downstream whole-row deduplication (PR-03). |
| Item-battery missing responses counted incorrect | The eight linked T1 batteries now consume upstream `correct_zero_filled`; nullable `correct` and response status remain available. Anonymous latent-model batteries still need migration. |

Model fitting and explicitly chosen estimands remain analysis work. Reader-side
poll repairs, hidden rekeys and missing-value guesses do not. Existing downstream
source pins still select historical inputs; migrating them requires a coherent
upstream contract and exact impact checks. SM-04 resolved the positional-link
failure through verified historical IDs. NIC's correction was the first coordinated reader-removal case, not a
claim that the full downstream migration is already complete. The remaining
scope also includes study-specific recodes in dp-distortions' out-of-sample
pipeline; its 24 frozen inputs are already centralized, but the transformations
must be inventoried and moved with study-level value checks.

### X-12: Political interest needs a common direction and an explicit scale

Nine polls have an observed baseline political-interest question in their
historical aggregate. Raw question codes do not share an orientation, and
`t1polint` is not a reliable cross-poll scale: the BTP Presidential Primaries
aggregate scores “very interested” as 0 and “not at all interested” as 1,
while BTP National 2003 uses the opposite direction. The primaries source's
earlier stored `t1polint` is a **binary** very-interested flag, so it is not
an independent copy of either four-category scale. UK General Election 1997
has five substantive categories, but its historical score collapses them
to four levels. UK Monarchy source code 6 means “not answered”; the historical
recoder retained it, but the approved UKM-06 correction now makes it missing.
It does not enter the common 0–1 measure.

The versioned `political_interest_t1_harmonized` respondent measure uses raw
baseline answers and fixed questionnaire endpoints. Zero denotes least
interested, one most interested, and intermediate categories receive equal
ordinal spacing. The explicit rules and source references are in
`metadata/harmonized_ordinal_measures.csv`:

| Poll | Raw question | Least interested code | Most interested code | Categories |
| --- | --- | ---: | ---: | ---: |
| UK–EU 1995 | `genint` | 1 | 4 | 4 |
| UK Monarchy 1996 | `A6` | 4 | 1 | 4 |
| UK General Election 1997 | `int1` | 1 | 5 | 5 |
| Australia Republic 1999 | `intpol1` | 1 | 4 | 4 |
| NIC 1996 | `POLINTR1` | 1 | 4 | 4 |
| NIC2 2003 | `pint_b` | 4 | 1 | 4 |
| BTP National 2003 | `qb57` | 4 | 1 | 4 |
| BTP Presidential Primaries 2004 | `b1q18` | 4 | 1 | 4 |
| BTP Health and Education 2005 | `q40` | 1 | 4 | 4 |

The retained questionnaires, codebooks or source value labels establish these
endpoint codes. Australia's source dictionary identifies `intpol1` as QD1 and
labels all four categories, but the retained constitutional-study codebook is
for a different survey and does not verify this fielded DP question; the QD1
instrument has not been located. BTP National's retained PDF is a later
follow-up and does not show baseline Q57; its source variable/value labels
and the published analysis remain the evidence for that item (BTPN-05).
The new measure is separate from the
historical `t1polint` and changes no `polardata` cell. It has 12,018 rows
over the nine full reviewed source files, with 7,859 substantive answers.
The original 959,020 respondent-measure identities and numeric values remain
identical. Source-response status changes from `answered` to
`non-substantive` for exactly 25 explicitly labeled nonanswers: 18 UK General
Election, four BTP Presidential Primaries, two UK Monarchy and one NIC.
Their corresponding original `n_observed_fields` counts change from one to
zero; raw responses and historical scores do not change. A common
direction and range do not establish equal psychometric meaning across
different wording or response counts. Any within-poll z-score needs a
separately named definition and a fixed reference sample; it is not folded
into this scale or implemented by a downstream reader.


**Phase-export implementation (2026-09-27).** The two additional analysis
exports preserve historical selected-wave tables and provide reviewed phase
roles, original score labels, timing evidence and nullable questionnaire
presence. NIC's codebook opening paragraphs describe T2 as event-exit surveys
plus 172 contemporaneous telephone interviews with nonattendees. The NIC paper
PDF p.19 dates T3 about ten months later, after the presidential election.
Accordingly the historical eleven-item source-T2 measure maps to t2, source T3
to t3, and no NIC arrival measurement is established. New Haven's paper PDF
p.8 places its Mid survey after the first deliberative session: retain it as
interim_1 rather than calling it arrival. These change timing metadata, not
answers or existing selected-wave score values.

Questionnaire presence requires positive evidence from actual answer fields,
not identifiers or generated correctness flags. Five NIC records have CASEID
as their only nonmissing baseline measure input, with generated source flags
present but all original baseline answers absent. Their baseline presence
remains unknown; neither zero-filling nor group assignment establishes an
interview. Denmark departure respondent 321 has all nine quiz fields blank but
41 other questionnaire answers: its observed questionnaire retains score zero.
Marousi's recruitment export retains 1,275 telephone records, with 159
respondents having arrival or exit questionnaire evidence and 1,116 with
unknown attendance. No attendance classification relies solely on a group.


### A1R-2019: recruitment is not a verified invitation

The NORC methodological report, printed page 6 ("Sample Selection from
AmeriSpeak"), says treatment-frame baseline respondents were only potentially
eligible for the event. NORC subsequently selected a subset to receive invitations,
using willingness and demographic quotas. `CONDITION == 1` therefore identifies
the recruitment frame, not a verified invitation for every respondent. The report
is retained at `data/america-in-one-room-2019/design/a1r-2019-norc-methods.pdf`.

Corrected the analysis participant and phase participant labels: the 2,215
nonattenders in this frame are `recruitment_nonattender`, and the frame's
`assignment` is `recruitment`. Attendees remain `attended`; controls remain
`control`. This changes no attendance decisions, respondent membership, scores,
weights, or outcomes. Individual invitation status among these nonattenders
cannot be inferred from the available frame indicator. An invitation-effect
analysis needs the actual invitation records and follow-up outcomes, together
with the selection probabilities used at each recruitment stage.

The climate study differs. Its NORC report, printed pages 4–6, says treatment-frame
baseline respondents were invited to register. Tables 2 and 3 document electronic
briefing materials sent to registered delegates on September 8, 2021 (registered
before September 2), plus printed materials if requested. Registration and
materials receipt are not equivalent to attendance, and receipt by every invitee
is not established. The report is retained at
`data/a1r-climate-2021/design/a1r-climate-methods.pdf`. The later A1RC-01 correction labels this study's noncompleters
`invited_noncompleter`; their invitation is documented but nonattendance is not. Neither study's current analysis scores contain exit
knowledge observations for its nonattender group. Zero gain would be an imputation,
not an observed outcome. Invitation or materials could induce learning without
attendance, violating the exclusion restriction for an instrument intended to
identify the effect of attendance alone. An effect of invitation, if identifiable,
would include such learning.


### BGC-07: baseline precedes arrival (resolved 2026-09-28)

The 278-row paired `survey.sav` has discussion groups for every respondent
(`group0`, 17 groups), complete pre/post knowledge batteries, and `_merge=3`
throughout. This is an attendee-only merged file. Full group coverage does not
establish that its initial answers were collected on arrival. The uppercase
`GROUP` in the original returns instead labels occupation.

Kultura, issue 38, 25 October 2002, printed p.5, retained in
`reports/kultura-2002-10-25.pdf`, describes this specific crime event. The first
two paragraphs of the methodological account state that debates began with
interviews of a nationally representative sample and that, after the initial
interview, respondents were invited to gather for discussions. This is direct
event-specific evidence for a pre-arrival initial interview. It corroborates
the organizers' sequence in `reports/bulgaria-crime-results.pdf`, p.1: baseline
survey, invitation, briefing materials, weekend, repeated questionnaire.

The original `recruitment.sav` has 1,035 respondents and 136 fields;
`attendee-baseline.sav` has 278 respondents and 137 fields. Both are exact copies
of retained archive files. Across all 119 shared Q-prefixed columns, every
attendee baseline answer vector appears in the national survey. This links the
analytical baseline to the initial national questionnaire without relying on
potentially incompatible IDs. It does not itself establish a unique respondent
identity bridge for adding the other national respondents to an analysis panel.

Classify the analytical baseline as t0/pre_arrival and the repeated questionnaire
as t2/post_deliberation in both historical and Cor-Sood views. Do not invent an
arrival wave, individual interview dates, or survey mode. Existing scores and
main analysis samples are unchanged. The phase outputs now include these known
interview stages. Original recruitment respondents are preserved for later
identity/attendance reconciliation; their missing event status is not inferred
from an ID mismatch. Exact material-receipt dates remain unavailable, but the
organizers describe briefing after the initial survey and invitation.


### X-13: One empirical median definition for individual and group variables

**Status: approved by the user on 2026-09-28.** High/low education and income
now use each poll's observed participant median. The reference population is
its unique `historical-polardata` participants, excluding missing responses.
Values strictly above that median are high; values at or below it are low.
Tied categories are never split, so the groups need not be equally large.
If no reference value is observed, the flag remains missing. A source record
outside the reference population is scored against that same fixed cutoff;
changing row order or selecting a discussion group does not redefine it.

Normalization follows the poll-specific source recodes. Reviewed ordered
education and income values remain available. Australia, New Haven, NIC2 and
San Mateo retain finer ordered education distinctions for this comparison
rather than collapsing college and graduate education first; the exact source
codes, missing codes and reviewed ordering are in
`metadata/education_normalization.csv`. New Haven's trade/technical category
retains its reviewed placement with some college. NIC2 retains the existing
diploma/GED override and does not invent a label for raw education code 18.
For the remaining polls the existing reviewed education ordering is used.

This replaces separate cutoffs for individual income and group income shares.
The older mismatch occurred in UK Health, UK Election, New Haven, NIC2, BTP
National, BTP General Election and BTP Presidential Primaries. For example,
UK Election used £20,000+ for individuals and £32,000+ for groups; the two BTP
National/Primaries individual flags used $50,000+ while their group shares used
$75,000+. These repeated differences reflect historical analysis stages, not
proof of independent typographical errors. The user chose a common definition
and separate normalization rather than retaining the conflicting stages.

Group summaries use the normalized individual flags and their documented
composition populations; they never recalculate a median within a group.
Existing group membership and missing-answer denominator rules are preserved.
The reviewed-US composition population can include source participants outside
the final wide export, so its population remains distinct from the fixed
median reference population. Knowledge scores, source answers, ordered
education/income values, ages, attitudes and sample memberships are unchanged
by this normalization. `highinc`, `bettered` and `phighinc` remain wide-export
aliases; their canonical definitions are versioned as poll-median definitions.

The independently derived expected values in
`audit/corrections/shared-demographic-medians/approved_values.csv` compare
against the original benchmark by poll and historical identity. These are
normalization choices; downstream estimates using either binary flag must be
regenerated and described using the new definitions. No downstream reader
should recreate its own income or education cutoff.

### X-14: The highest education category is not a uniform degree indicator

**Status: relative-education comparison approved by the user on 2026-09-28;
UK Health corrected in UKH-13.** The analysis
builder's fallback `ba = 1(education == 1)` gives a common degree label to
different education constructs. The downstream `dp-learning` models also label
the highest `educ3` category "BA or more" independently of `ba`. Correcting the
degree flag therefore does not correct those model labels or their categories.
Keep reported qualifications, an explicitly defined degree indicator, and
within-poll relative education separate.

The three older British polls ask for a single highest qualification, not every
qualification held. A degree response establishes affirmative degree evidence;
a professional or nursing response does not establish that the person lacks a
degree. These differences are not sufficient evidence of three coding typos.

| Poll | Current highest-category positives | Explicit degree responses | Evidence and interpretation |
| --- | ---: | ---: | --- |
| UK Monarchy 1996 | 47 | 24 | `codebook.pdf`, page 16, B12b; raw `B12B == 10`. The other 23 are teaching (5), nursing (4), or professional qualifications (14). One attendee's `B12B == 14` is unanswered despite an observed school-qualification response. No separately documented degree flag was found. |
| UK Election 1997 | 50 | 19 | `codebook.txt`, lines 1182–1204, B12b; raw `educb == 9`. The other 31 are nursing (9), professional (14), or other technical/business qualifications (8). The instrument says to select the qualification the respondent considers highest, with explicit tie-breaking instructions. |
| UK Crime 1994 | 43 | 29 | `codebook.txt`, lines 748–797, B12 and EDUC7; raw `educ == 11`. The source explicitly calls EDUC7 category 6 "Degree or equivalent," including three teaching and 11 professional qualifications. The broader grouping is intentional. |

For UK Election, the stored but undocumented source field `educolle` exactly
matches `educb == 9` across all 1,210 source respondents. It is corroborating
evidence for an explicit-degree-response rule, not a separately asked degree
question. It also turns ten qualification nonanswers into zero, including five
attendees (IDs 8720, 3423, 1823, 4024, 419); preserve these as missing. The proposed
highest-degree-response rule gives 19 positive, 251 negative, and five missing
attendee responses. Relative to the current proxy, 31 positive values become
negative, five negative values become missing, and one missing value becomes
negative (ID 1717 has an observed no-qualification response). That explicit-degree-
response proposal was not adopted: the user chose within-poll relative education for the comparison instead. It remains historical
evidence about why the degree proxy is not uniform, not an outstanding
authorization to turn ambiguous qualifications into negative degree answers.
The ordered education variable and approved median classification are preserved.

Other source-specific limitations also need explicit treatment before calling
this a uniform degree measure:

- Australia: 141 of 184 top-category respondents report the inseparable
  college/technical/university category; 43 report a postgraduate degree.
  The broader category does not identify bachelor's-degree completion.
- NIC2: 112 of 272 top-category respondents report some college (codes 13–15),
  159 report undergraduate/postgraduate education (16–17), and one has code 18,
  whose label remains unavailable. Do not invent a meaning for code 18.
- Europolis: education records age at leaving full-time education. Six top
  values arise from age 35 or the current-student imputation capped at 35;
  neither establishes a degree. This is a schooling-duration measure.
- Zeguo: two respondents report "University." The recovered category label
  does not explicitly establish completion or degree attainment.

These counts refer to unique historical-polardata participants. No degree
recodes for these additional polls have been applied. Their raw answers and
the approved relative-education normalization remain available for review.

The typed analysis participant tables now expose `education_above_median` and
`income_above_median` as nullable booleans, taken directly from the approved
respondent measures for the 21 historical polls. The reference population and
classifications in X-13 are unchanged: removing an absent questionnaire from a
particular comparison does not redefine the cutoff. All source respondents
retain their classification against that fixed reference, where their ordered
value is observed. Missing income sources remain missing. For the 16 Cor–Sood
polls read from those same source surveys, the flags are joined through verified
source-row identities; all 4,705 records match.
Overlapping deposits are not pooled or matched on coincident ID strings. Sources
without an approved classification remain missing. The retained legacy `ba` and
`education` fields are explicitly described as source-specific proxies, not
uniform credentials.
Downstream models still need to adopt the relative fields before their education
coefficients or labels can be described as above-median comparisons.

**A1R 2019: retain the attendee-median definition when it yields no split
(approved).** The released `participants.tab` contains four-level `EDUC4`,
not the finer `EDUC` variable described in `codebooks/a1r_codebook.tab`.
The reference is the 526 unique attendees (`CONDITION == 1` and nonmissing
`GROUP`), before any knowledge-outcome or paired-questionnaire restriction.
Their category counts are 7 below high school, 44 high-school graduates,
206 with some college, and 269 with a bachelor's degree or more. The median
is therefore category 4, the highest available category. Strictly above the
median is false for every attendee. Applying the same cutoff to all 3,842
source respondents also gives 3,842 false values; no observed education is
missing. The helper preserves missing education if present and uses one
reference record per source person even when canonical views overlap.

The approved choice is to retain this definition and omit A1R's binary
above-median education-gap estimate because the indicator has no variation.
No respondent, raw education category, score or other comparison is dropped.
Suggested table note: “A1R 2019 is omitted from the relative-education gap
comparison because its attendee median is the highest category in the available
education measure; no respondent is strictly above that median.” This is not
an instruction to replace the median with a college threshold or to divide
respondents who share the same reported education category.

## Supplied survey weights: analytical use remains undecided

The typed weight export retains 13 supplied numeric weight columns from nine
polls, with every source row preserved, including missing and zero weights.
`metadata/survey_weights.csv` records the original column names, available
labels, identity fields, documented scope and evidence. The two Parquet tables
under `output/weights/` separate definitions from values. Their authoritative
identity is the registered source ID and SHA256 plus physical source row;
original respondent IDs and wave values are retained separately. No weight is
normalized, pooled, selected as a default, or substituted into an analysis.
The existing analysis weight field and all estimates remain unchanged.

- Climate 2021: `WEIGHT1`, `WEIGHT2`, `T3WEIGHT1`, and `T3WEIGHT2` remain
  separate. The first two each contain 1,633 observed values, and the T3
  variants each contain 1,419. The retained NORC methods report, printed p.7,
  distinguishes national normalization from normalization for California,
  Texas, and the rest of the United States. It does not establish an identical
  construction for the T3 variants; their source names remain explicit.
- A1R 2019: `WEIGHT_CONTROL` has 844 observed values and `WEIGHT_DELEGATE`
  has 523. Both are retained for all 3,842 source rows, with source-row identity.
- AMR 2024: `Weight` and its `weight_group` context are retained for all
  4,838 source rows keyed by `ID` and `Time`. The 12 contexts are country by
  treatment/control group. The authors' retained README says weights are valid
  within those contexts. Each person's supplied value happens to agree across
  the two waves; this does not justify discarding wave provenance or pooling
  the contexts.
- BTP 2007 `weight`: 1,501 observed values in 1,501 rows; Europolis `WEIGHT`:
  4,384 in 4,384; Michigan `weight`: 610 in 610, including zero; NIC2 `sampwt`:
  881 in 1,493; Tanzania `weight`: 2,001 in 2,225; Tomorrow's Europe `wmid1`:
  3,550 in 3,550. Their precise population and wave scopes are not inferred
  from their names. NIC2 uses the complete original `caseid` for optional unit
  identity; `nicid` is missing for 998 source records.

The export contains 61,541 weight-row records, of which 25,236 have observed
values. Source bytes remain unchanged. Exact source-to-Parquet comparison
checks every value, missingness, source-row identity, minima, maxima and zeros.
Choosing weights for a particular population, wave contrast or estimand is a
separate, unresolved analytical decision.

### X-15: Invalid pairwise covariance does not define generalized variance

**Approved by the user and implemented on September 28, 2026.** The group
generalized-variance calculation formerly took the absolute determinant of a
pairwise-complete covariance matrix, then its `1/(2*p)` power. Each covariance
can use a different set of respondents. The resulting matrix can therefore
have materially negative eigenvalues and fail to represent a joint covariance
matrix; this is explicitly documented in [R's covariance reference](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/cor.html).
Taking an absolute determinant conceals the failure. Even a positive determinant
is insufficient: a matrix can have two negative eigenvalues. This is a defect
in the interpretation of the shared group statistic, not in any respondent's
attitude answer.

The shared `historical_genvar()` now returns missing if the covariance matrix
is undefined or has an eigenvalue below its negative numerical tolerance. The
production calculation and diagnostics share the existing scale- and
dimension-dependent tolerance, `64 * machine_epsilon * p * max(abs(eigenvalues))`.
This distinguishes material incompatibility from rounding near zero. Valid
matrices retain the exact preceding determinant arithmetic, including singular
matrices. No nearest-positive-definite projection, imputation, complete-case
substitution, or poll-specific rule is introduced.

After the approved NIC missing-answer correction, 87 of 397 baseline group
matrices in ten polls are materially indefinite. The correction makes generalized
variance missing for 1,185 exported people; no other field changes at this step.
The source-matrix inventory covers 1,196 people in those groups, but includes
11 BTP General Election records outside the maintained export. Comparing by
retained respondent identity avoids overstating the exported impact.

| Poll | Invalid baseline groups | Exported generalized-variance cells made missing |
| --- | ---: | ---: |
| BTP General Election 2004 | 3 | 21 |
| BTP Health/Education 2005 | 14 | 193 |
| BTP National 2003 | 9 | 141 |
| Bulgaria Crime 2002 | 15 | 243 |
| CPL 1996 | 4 | 52 |
| New Haven 2002 | 3 | 16 |
| NIC 1996 | 13 | 197 |
| NIC2 2003 | 7 | 95 |
| San Mateo 2008 | 9 | 75 |
| UK Health 1998 | 10 | 152 |

Individual attitude scores, ordinary item SDs and their group average, respondent
identities, group assignments and sample flags are preserved. A regression that
requires generalized variance would lose these observations unless it explicitly
chooses another estimator; these missing values must not be called zero
disagreement. This correction does not resolve the broader choice of a
missing-data covariance estimator.

All exported instances of `group_baseline_attitude_generalized_variance` use
definition version `covariance-validity-v2`. The independently reconstructed
prior calculation and corrected output are compared by
[`scripts/review_shared_covariance.R`](../scripts/review_shared_covariance.R).
The [case-level ledger](../audit/corrections/shared-covariance/approved_values.csv)
retains frozen historical values, preceding approved references, preceding
calculated values and the approved missing values. It overlays only the reviewed
respondent/field cells in historical parity, leaving unrelated discrepancies
visible. Meaningful regression cases include incompatible matrices with either
determinant sign, valid singular matrices, scale changes and roundoff. X-09's
remaining numerical exceptions are distinct from this scientific correction.


### Additional definition evidence, September 29, 2026

An independent source-to-output replay of Bulgaria Crime and the three utility
polls passes42 measure comparisons. For Bulgaria, all255 nonempty subsets of
eight candidate civil-liberties questions were tested at each wave. Only
Q15_1, Q15_3, Q17_1, Q17_2 and Q17_4 reproduce every Version E score and missing
value at both waves. This establishes the numerical definition among the tested
unweighted available-item means; it does not recover the authors’ final
construction syntax or rationale. Five retained draft memos contain no Version E
formula. The six-item R expression is commented out, while Version D is an earlier
seven-item definition. Preserve the maintained five-item Version E. Exact
subset matches and rejected alternatives are in
`audit/attitude-definition-review/bulgaria-crime-2002/`.

Utilities’ empirical calibration has explicit authored evidence:
`historical-cdd-scripts:legacy/pete/datacleaning2012.R`, lines41–45, defines
observed-minimum/maximum rescaling and later calls it separately by wave after
PART==1 selection. That script establishes an intentional transformation;
it is not the exact final recipe for every corrected index. Fixed0–10 scaling
would change, for example, SWEPCO’s paired conservation gain from10.71 to3.17
percentage points in the232-person explicitly midpoint-imputed series. This
is a different metric, not evidence of a typo, and is not adopted. Source
bounds and all paired alternatives are in
`audit/attitude-definition-review/utilities/`. Original WTU/SWEPCO SAS Q2 input
lists and codebooks omit FEDRCH while listing RESCH, REDUCE, JOBS, TAX and
LOWINC, strengthening the evidence that their research index legitimately
uses RESCH alone. Exact fielded forms remain unrecovered.

### X-16: Repeated phase estimates can be aliases or inconsistent metadata

The historical and Cor-Sood source views can describe the same people and
question battery. Comparing aggregate scores alone does not establish an alias.
The September 30 audit reconstructs respondent IDs from each primary survey,
checks source rows and every raw item, and compares correctness, attendance,
phase scores and group partitions. Six-item and expanded nine-item Europolis
views each match exactly across the two sources. Six further paired batteries
are exact aliases: BTP Health/Education (454), Bulgaria Crime (278), CPL (216),
UK Crime (299), UK Election (275), and UK Health (228). The phase estimator
selects one historical copy of each verified alias while preserving both source
representations upstream. Removing aliases must not shift bootstrap seeds for
retained estimates merely by renumbering estimation strata.

Different numbers require explanation, not automatic deduplication. BTP General
Election's historical view includes two people absent from the Cor-Sood view:
source rows 74/80, original IDs 2526/91. Australia uses ten versus twelve items,
NIC eight versus eleven, and UK Monarchy eight versus nine. These are different
cohorts or batteries and remain distinct.

WTU, SWEPCO and San Mateo require a presence correction rather than a recruitment
explanation. Their differing paired counts (225/230, 225/232 and 214/238) come
from the same raw source people. The Cor-Sood view leaves questionnaire presence
unknown when the selected quiz is blank; the historical view has broader
questionnaire evidence. The 5/7/24 extra people have observed scores and matching
raw items. Verify the nonquiz evidence before harmonizing presence; apply the
approved rule that blank knowledge items in an observed form score zero, while
an absent form remains unmeasured. No presence correction is adopted by this
alias-only selection change.

Two matching-score copies also differ in group metadata. Tomorrow's Europe's
`group_no` and `t3grp` disagree on source rows 1103, 1107, 1167, 3297 and 3451.
The authored fields may distinguish assigned and realized groups; source syntax
and group provenance must resolve that interpretation. UK–EU has four source
records assigned code 99: the historical view clusters them as group 2099 while
the Cor-Sood view leaves group missing. Establish the original unknown-group
meaning before rebuilding shared group measures. Neither group difference is
resolved by score agreement or by silently choosing the narrower sample.

The source comparisons and primary-ID/item verification are retained in
`audit/phase-source-aliases/`. These findings concern phase-source selection and
metadata; they do not change individual knowledge scores or establish that all
questionnaire definitions have been independently verified.
