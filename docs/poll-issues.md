# Poll decisions and remaining work

Current register: October 1, 2026. This page states the decisions in force.
The complete source quotations, comparisons, counterfactuals and historical
proposals are preserved in [poll-evidence.md](poll-evidence.md). Older proposals
there do not override later approvals. Each issue below links to that evidence.
The scope is 33 polls with respondent outputs plus Bulgaria 2007, whose source
data remain unavailable. The 16 additional materials-only folders do not imply
completed respondent-level audits.

## Decisions in force

- Preserve every source person and raw answer. Main-analysis eligibility is a
  separate field; source-only records remain available for selection analysis.
- Establish questionnaire presence from actual answers in the relevant form.
  A header, assigned group or derived zero does not establish a returned form.
- Harmonized attendance follows the approved post-completion rule. Preserve the
  original attendance classification and its evidence alongside it.
- `participant` requires observed questionnaires at each collected t0/t1/t2
  stage. Uncollected stages and missing later follow-up do not exclude people.
- Knowledge categories are correct/incorrect/dk. An observed blank receives
  conventional zero credit and the DK-like category; its original blank reason
  remains distinct from explicit DK. Absent forms and invalid items stay missing.
- Retain all-zero scores and wholly blank quizzes within observed forms. Flag
  them for robustness checks; unusual data are not automatically false data.
- Plain attitudes preserve nonresponse. Only explicitly named
  `_midpoint_imputed` variants retain approved historical fills on observed forms.
- Calculate group and poll variables centrally. Use the approved common
  definitions, observed peer denominators and within-poll median classifications.
- Carry reviewed source covariates into missing analytical cells, preserving all
  existing nonmissing values and source identities. This is transport, not a new
  normalization or a change in analytical eligibility ([X-28](#x-28)).

## Decisions still requiring consultation

| Topic | Current treatment | What would change it |
|---|---|---|
| Australia initial none/DK checklist | Preserve the authored symbolic-item scoring; the combined response cannot be separated retrospectively. | Decide how the combined option should enter the construct using the retained fielded checklist and combined DP codebook. See AUS-01 in the evidence. |
| Utility empirical scales | Preserve historical wave calibrations; plain and imputed variants are separately named. Some source-only baseline values fall below zero. | Approve a common-endpoint definition and compare both waves and all dependent summaries; do not clamp values. See CPL-02/06 and WTU/SWEPCO evidence. |
| Northern Ireland argument scoring | Preserve the authored treatment of opposite-side `c` codes and vague code 94. Literal transport is repaired. | Decide the directional/valid-argument definition using the coding guide and paper before changing downstream scoring ([NI-06](#ni-06)). |
| Survey weights | Preserve supplied weights and their population/wave context. No universal weight is selected. | Specify the population and estimand for each weighted analysis. |

## Accepted ambiguities and unavailable evidence

These are explicit limits, not an instruction to keep reopening resolved choices.

| Poll or issue | Current disposition |
|---|---|
| NIC Bosnia | User chose to retain the historical key despite the documented date-sensitive conflict ([NIC-06](#nic-06)). |
| Vermont knowledge | Use the final report's approved 25% key. Keep the double-star and baseline surcharge-unit ambiguities documented ([VT-01](#vt-01)). |
| NIC2 security | Retain the complete action block explicitly marked “Use This One.” Other authored versions remain evidence ([NIC2-02](#nic2-02)). |
| Zeguo attitudes | Retain both Township Image definitions under different names, source-version exceptions and approved reconciliation credits ([ZG-06](#zg-06), [ZG-08](#zg-08)). |
| UK Health screening | Retain false under the literal universal wording and contemporaneous author caveat; printed correctness tables disagree ([UKH-12](#ukh-12)). |
| San Mateo land-use knowledge | Retain the publication-consistent code-5 key; the complete land-area calculation and fielded departure version are not established ([SM-01](#sm-01)). |
| BTP Health/Education report | The retained 358-person weighted archive reproduces fourteen rounded percentages. Four report records and their exclusion rationale remain unidentified; preserve the authored 454-person analysis cohort ([BTPHE-06](#btphe-06)). |
| New Haven | The 132-person analytical sample and 64/68 split are established; the paper's additional attendee lacks an identified roster record ([NH-02](#nh-02)). |
| Denmark and Vermont groups | Keep missing group assignments until a respondent-to-discussion-group roster is recovered. Administrative fields are not substitutes ([DK-07](#dk-07)). |
| Marousi identity | Preserve the authored source-row bridge and wave-specific native IDs. Sixteen conflicting departure IDs remain documented; no forced identity links ([MAR-03](#mar-03)). |
| Bulgaria Crime and Tomorrow's Europe | Preserve executed definitions where final civil-liberties syntax or the earliest migration recode is unavailable. |
| Bulgaria 2007 | No identified respondent dataset; the user stopped further searches. Do not describe this poll as respondent-level audited. |
| Tanzania | Preserve the source roster and weights; withheld raw-cleaning syntax limits independent reconstruction. Do not equate the 371-person roster with the authors' 370-person subgroup. |

## Planned downstream checks

Use `analysis_knowledge_flags` to compare the retained sample with exclusions
of zero exit scores, zeros at either endpoint, and wholly blank batteries.
Keep the person, battery, wave pair and source representation explicit; report
sample sizes, group coverage and estimates with uncertainty. Missing flags are
not negative findings. San Mateo and Zeguo remain in the main data.

Downstream readers must adopt corrected inputs deliberately. `dp-learning`
needs analytical `participant` eligibility and primary attitude definitions;
plain and imputed indices must not enter the same predictor twice. The frozen
benchmark readers in `dp-distortions` and `dp-deliberately` do not automatically
receive current corrections. Compare unchanged model specifications on old and
new inputs; keep the requested `dp-distortions` changes in an unmerged PR.

## Issue index

**Implemented** means an adopted correction or source-preservation change.
**Preserved** means an authored or user-approved definition remains in force.
**Source limit** needs identified evidence, not an invented numerical answer.
**Superseded** identifies an older description replaced by a later decision.
**Verified** records a source check; **Robustness** retains unusual observations.
The detailed entry specifies which fields and versions each status covers.

### UK Health 1998 — uk-health-1998

- <a id="ukh-01"></a> **UKH-01 — Preserved.** [Severity direction is documented; do not label it a coding error](poll-evidence.md#ukh-01).
- <a id="ukh-02"></a> **UKH-02 — Implemented.** [Separate empirical rescaling changes the cross-wave scale](poll-evidence.md#ukh-02).
- <a id="ukh-03"></a> **UKH-03 — Implemented.** [Government/public input has a non-monotonic stored recode](poll-evidence.md#ukh-03).
- <a id="ukh-04"></a> **UKH-04 — Preserved.** [Different index versions and orientations coexist](poll-evidence.md#ukh-04).
- <a id="ukh-05"></a> **UKH-05 — Preserved.** [Education is an ordinal school-qualification measure](poll-evidence.md#ukh-05).
- <a id="ukh-06"></a> **UKH-06 — Source limit.** [Universe, missingness and earliest-source boundaries](poll-evidence.md#ukh-06).
- <a id="ukh-07"></a> **UKH-07 — Implemented.** [Nine selected indices are not the full aggregate inventory](poll-evidence.md#ukh-07).
- <a id="ukh-08"></a> **UKH-08 — Superseded.** [Individual and group high-income fields use different thresholds](poll-evidence.md#ukh-08).
- <a id="ukh-09"></a> **UKH-09 — Implemented.** [Attitude summaries precede the final severity rescaling](poll-evidence.md#ukh-09).
- <a id="ukh-10"></a> **UKH-10 — Preserved.** [Poll-level and respondent-level knowledge have different precision](poll-evidence.md#ukh-10).
- <a id="ukh-11"></a> **UKH-11 — Preserved.** [Adjusted baseline knowledge and peer scores use departure answers](poll-evidence.md#ukh-11).
- <a id="ukh-12"></a> **UKH-12 — Source limit.** [Breast-screening correctness conflicts across source versions](poll-evidence.md#ukh-12).
- <a id="ukh-13"></a> **UKH-13 — Implemented.** [School qualifications were mislabeled as a bachelor's degree](poll-evidence.md#ukh-13).
- <a id="ukh-14"></a> **UKH-14 — Preserved.** [Full attitude battery checked against the source definitions](poll-evidence.md#ukh-14).

### UK Crime 1994 — uk-crime-1994

- <a id="ukc-01"></a> **UKC-01 — Implemented.** [Post-wave root-causes index substitutes baseline policing](poll-evidence.md#ukc-01).
- <a id="ukc-02"></a> **UKC-02 — Preserved.** [Knowledge sample and respondent-ID conventions](poll-evidence.md#ukc-02).
- <a id="ukc-03"></a> **UKC-03 — Source limit.** [Issue-specific knowledge fields are absent from the historical export](poll-evidence.md#ukc-03).
- <a id="ukc-04"></a> **UKC-04 — Preserved.** [All five attitude indices reproduce the published paired means](poll-evidence.md#ukc-04).

### UK–EU 1995 — uk-eu-1995

- <a id="ukeu-01"></a> **UKEU-01 — Implemented.** Keep source people; unavailable departure forms have no score and group 99 is unknown, not a sixteenth discussion group. [Evidence](poll-evidence.md#ukeu-01).
- <a id="ukeu-02"></a> **UKEU-02 — Implemented.** Exclude baseline nonanswers before scaling the two five-category attitudes to their full endpoints. [Evidence](poll-evidence.md#ukeu-02).
- <a id="ukeu-03"></a> **UKEU-03 — Implemented.** Exclude post “can’t choose” responses and restore the five-category EU-relations scale. [Evidence](poll-evidence.md#ukeu-03).
- <a id="ukeu-04"></a> **UKEU-04 — Implemented.** Inapplicable departure responses are missing; observed EU-scope answers use the substantive scale. [Evidence](poll-evidence.md#ukeu-04).
- <a id="ukeu-05"></a> **UKEU-05 — Preserved.** “Other” ethnicity remains observed but cannot establish binary minority status; retain the raw answer. [Evidence](poll-evidence.md#ukeu-05).
- <a id="ukeu-06"></a> **UKEU-06 — Preserved.** [Full four-index attitude review after the approved scale fixes](poll-evidence.md#ukeu-06).
- <a id="ukeu-07"></a> **UKEU-07 — Implemented.** [Whole unavailable departure questionnaires were scored as zero](poll-evidence.md#ukeu-07).

### UK Monarchy 1996 — uk-monarchy-1996

- <a id="ukm-01"></a> **UKM-01 — Implemented.** Use departure R5C, not baseline Q5C, in the nine-item post knowledge battery. [Evidence](poll-evidence.md#ukm-01).
- <a id="ukm-02"></a> **UKM-02 — Preserved.** Keep source-row identities and historical aliases separate; retain the distinct eight- and nine-item batteries. [Evidence](poll-evidence.md#ukm-02).
- <a id="ukm-03"></a> **UKM-03 — Verified.** Authored components and stored precision reproduce both waves; UKM-07 verifies the unusual referendum ordering. [Evidence](poll-evidence.md#ukm-03).
- <a id="ukm-04"></a> **UKM-04 — Superseded.** Expanded-source demographic exceptions were corrected under UKM-06; the old codes are not current derived values. [Evidence](poll-evidence.md#ukm-04).
- <a id="ukm-05"></a> **UKM-05 — Implemented.** Catalog titles distinguish royal-family relations with the public from the powers of the monarchy. [Evidence](poll-evidence.md#ukm-05).
- <a id="ukm-06"></a> **UKM-06 — Implemented.** Exclude demographic nonanswers and preserve open-ended 90+ age without inventing a point age. [Evidence](poll-evidence.md#ukm-06).
- <a id="ukm-07"></a> **UKM-07 — Verified.** All four attitude pairs and their available-component definitions reproduce the source and memo benchmarks. [Evidence](poll-evidence.md#ukm-07).
- <a id="ukm-08"></a> **UKM-08 — Implemented.** The 599 verified absent departure forms have missing items and scores; retain all source people and raw placeholders. [Evidence](poll-evidence.md#ukm-08).

### UK General Election 1997 — uk-general-election-1997

- <a id="ukge-01"></a> **UKGE-01 — Preserved.** Use the documented source eligibility and scale-specific keys; preserve the distinction between selected and source records. [Evidence](poll-evidence.md#ukge-01).
- <a id="ukge-02"></a> **UKGE-02 — Implemented.** Use the same tax-and-spending question at both waves, rather than a different baseline tax question. [Evidence](poll-evidence.md#ukge-02).
- <a id="ukge-04"></a> **UKGE-04 — Implemented.** Preserve reviewed demographic categories and missing codes; X-13 supplies the common income classification. [Evidence](poll-evidence.md#ukge-04).
- <a id="ukge-06"></a> **UKGE-06 — Verified.** All four attitude pairs reproduce the paper; differing appendix question names do not justify replacing the verified fields. [Evidence](poll-evidence.md#ukge-06).
- <a id="ukge-03"></a> **UKGE-03 — Implemented.** [Post Labour minimum-wage knowledge uses the baseline response](poll-evidence.md#ukge-03).
- <a id="ukge-05"></a> **UKGE-05 — Implemented.** [Exclude a source nonparticipant from early group metrics](poll-evidence.md#ukge-05).

### CPL 1996 — cpl-1996

- <a id="cpl-01"></a> **CPL-01 — Verified.** Original missing-code provenance is retained; explicit DK receives conventional zero knowledge credit with its raw reason preserved. [Evidence](poll-evidence.md#cpl-01).
- <a id="cpl-02"></a> **CPL-02 — Preserved.** Keep historical aliases and reviewed empirical calibrations; a common-endpoint alternative requires an explicit decision. [Evidence](poll-evidence.md#cpl-02).
- <a id="cpl-03"></a> **CPL-03 — Preserved.** The authored seven-index summaries retain competition despite the six exposed attitude pairs; do not silently redefine them. [Evidence](poll-evidence.md#cpl-03).
- <a id="cpl-04"></a> **CPL-04 — Implemented.** [Codebook don't-know attitudes no longer count as observed inputs](poll-evidence.md#cpl-04).
- <a id="cpl-06"></a> **CPL-06 — Preserved.** [Utility attitude indices and summary batteries independently reviewed](poll-evidence.md#cpl-06).
- <a id="cpl-05"></a> **CPL-05 — Implemented.** [Group gain uses a truncated early group-size calculation](poll-evidence.md#cpl-05).
- <a id="cpl-12"></a> **CPL-12 — Implemented.** [Source nonanswers in the expanded questionnaire export](poll-evidence.md#cpl-12).

### WTU 1996 — wtu-1996

- <a id="wtu-01"></a> **WTU-01 — Verified.** Original portable nonanswer codes and source identities were recovered and independently checked. [Evidence](poll-evidence.md#wtu-01).
- <a id="wtu-02"></a> **WTU-02 — Verified.** The two disputed responses already receive zero credit under the executed key; no further recode is supported. [Evidence](poll-evidence.md#wtu-02).
- <a id="wtu-03"></a> **WTU-03 — Implemented.** Correct the absent ADDFACT2 reference to documented ADDFAC2 and retain REDUCE2 in conservation. [Evidence](poll-evidence.md#wtu-03).
- <a id="wtu-04"></a> **WTU-04 — Preserved.** Retain the documented earlier low-income construct; the later variant is not an automatic correction. [Evidence](poll-evidence.md#wtu-04).
- <a id="wtu-05"></a> **WTU-05 — Implemented.** Use normalized research values in extremity and shared group summaries. [Evidence](poll-evidence.md#wtu-05).
- <a id="wtu-06"></a> **WTU-06 — Implemented.** Confirmed absent departure questionnaires have missing knowledge scores, without discarding observed blanks or DK responses. [Evidence](poll-evidence.md#wtu-06).
- <a id="wtu-07"></a> **WTU-07 — Implemented.** [Absent departure questionnaires and explicit imputation](poll-evidence.md#wtu-07).

### SWEPCO 1996 — swepco-1996

- <a id="swe-01"></a> **SWE-01 — Verified.** Original portable nonanswer codes were recovered and checked against the maintained survey without changing substantive answers. [Evidence](poll-evidence.md#swe-01).
- <a id="swe-02"></a> **SWE-02 — Implemented.** The conservation index uses both documented post components, ADDFAC2 and REDUCE2. [Evidence](poll-evidence.md#swe-02).
- <a id="swe-03"></a> **SWE-03 — Preserved.** Keep the earlier documented low-income construct; a later authored index is a different definition. [Evidence](poll-evidence.md#swe-03).
- <a id="swe-04"></a> **SWE-04 — Implemented.** Use normalized research values in extremity and shared group summaries. [Evidence](poll-evidence.md#swe-04).
- <a id="swe-05"></a> **SWE-05 — Implemented.** Confirmed nonparticipant departure forms have missing knowledge scores; observed blank quiz items still receive zero credit. [Evidence](poll-evidence.md#swe-05).
- <a id="swe-06"></a> **SWE-06 — Implemented.** [Absent departure questionnaires and explicit imputation](poll-evidence.md#swe-06).

### Australia republic 1999 — australia-republic-1999

- <a id="aus-01"></a> **AUS-01 — Consultation.** The initial checklist combines none and DK. Preserve authored symbolic scoring; the retained DP instrument cannot separate those answers. [Evidence](poll-evidence.md#aus-01).
- <a id="aus-07"></a> **AUS-07 — Implemented.** [Absent and unavailable questionnaires were scored as zero](poll-evidence.md#aus-07).
- <a id="aus-02"></a> **AUS-02 — Implemented.** [Aggregate knowledge uses a different battery and flag rule](poll-evidence.md#aus-02).
- <a id="aus-03"></a> **AUS-03 — Implemented.** [Extremity omissions and a cross-wave ranking typo](poll-evidence.md#aus-03).
- <a id="aus-04"></a> **AUS-04 — Implemented.** [Participant gains now join by source row](poll-evidence.md#aus-04).
- <a id="aus-05"></a> **AUS-05 — Implemented.** [Age refusal no longer counts as age 98 (approved correction)](poll-evidence.md#aus-05).
- <a id="aus-06"></a> **AUS-06 — Implemented.** [A first preference for the Queen survives an unanswered second choice](poll-evidence.md#aus-06).

### BTP 2007 — btp-2007

- <a id="btp07-01"></a> **BTP07-01 — Verified.** Assignment, discussion attendance, post completion and small-group IDs have distinct source meanings; code 99 depends on the question. [Evidence](poll-evidence.md#btp07-01).
- <a id="btp07-02"></a> **BTP07-02 — Verified.** [Fielded keys reproduce the weighted report (checked; no correction)](poll-evidence.md#btp07-02).

### BTP General Election 2004 — btp-general-election-2004

- <a id="btpge-01"></a> **BTPGE-01 — Superseded.** Raw-question reconstruction now replaces reliance on stored knowledge scores; source and selected cohorts remain distinct. [Evidence](poll-evidence.md#btpge-01).
- <a id="btpge-02"></a> **BTPGE-02 — Implemented.** Retain refusal provenance and conventional zero credit within observed forms; whole unavailable forms remain missing. [Evidence](poll-evidence.md#btpge-02).
- <a id="btpge-03"></a> **BTPGE-03 — Implemented.** [Raw answers, rounding and the summary sample are now explicit](poll-evidence.md#btpge-03).
- <a id="btpge-04"></a> **BTPGE-04 — Preserved.** [Baseline poll knowledge uses a larger calibration sample](poll-evidence.md#btpge-04).
- <a id="btpge-05"></a> **BTPGE-05 — Implemented.** [Zero correct post answers do not mean the post wave is absent (corrected)](poll-evidence.md#btpge-05).
- <a id="btpge-06"></a> **BTPGE-06 — Implemented.** [Attendance flag conflicts with recorded meetings](poll-evidence.md#btpge-06).
- <a id="btpge-07"></a> **BTPGE-07 — Implemented.** [Explicitly absent questionnaires remain missing (corrected)](poll-evidence.md#btpge-07).
- <a id="btpge-08"></a> **BTPGE-08 — Preserved.** [All six attitude placements reviewed against raw responses](poll-evidence.md#btpge-08).

### BTP Health and Education 2005 — btp-health-education-2005

- <a id="btphe-01"></a> **BTPHE-01 — Implemented.** [Missing gender remains missing (corrected)](poll-evidence.md#btphe-01).
- <a id="btphe-02"></a> **BTPHE-02 — Preserved.** [Funding index and float storage reproduce the original definition](poll-evidence.md#btphe-02).
- <a id="btphe-03"></a> **BTPHE-03 — Implemented.** [Q15 calibration answer key (corrected)](poll-evidence.md#btphe-03).
- <a id="btphe-04"></a> **BTPHE-04 — Implemented.** [Elementary-school achievement-gap answer key corrected](poll-evidence.md#btphe-04).
- <a id="btphe-05"></a> **BTPHE-05 — Implemented.** [Correct four attitude labels; preserve all numeric definitions](poll-evidence.md#btphe-05).
- <a id="btphe-06"></a> **BTPHE-06 — Source limit.** [Preserve the wider source and identify the report-sample gap](poll-evidence.md#btphe-06).

### BTP Online Primaries 2004 — btp-online-primaries-2004

- <a id="btpop-01"></a> **BTPOP-01 — Source limit.** Attendee 908 has no verified final group; session numbers cannot safely supply it. Later BTPOP-02 handles unavailable follow-up forms. [Evidence](poll-evidence.md#btpop-01).
- <a id="btpop-02"></a> **BTPOP-02 — Implemented.** [Absent follow-up forms are not zero knowledge (corrected)](poll-evidence.md#btpop-02).

### Bulgaria Crime 2002 — bulgaria-crime-2002

- <a id="bgc-01"></a> **BGC-01 — Verified.** The seven-item crime battery belongs to the 2002 event, not the separate 2007 Roma-policy poll. [Evidence](poll-evidence.md#bgc-01).
- <a id="bgc-02"></a> **BGC-02 — Preserved.** Five components reproduce stored Version E exactly; its final authored formula remains unavailable, so retain that definition. [Evidence](poll-evidence.md#bgc-02).
- <a id="bgc-03"></a> **BGC-03 — Implemented.** Use one income classification for individuals and groups; the approved empirical median supersedes both older cutoffs. [Evidence](poll-evidence.md#bgc-03).
- <a id="bgc-04"></a> **BGC-04 — Implemented.** Death-penalty responses use the complete four-category endpoints; preserve the separately documented summary batteries. [Evidence](poll-evidence.md#bgc-04).
- <a id="bgc-05"></a> **BGC-05 — Implemented.** Six attitude catalog labels now describe their actual source questions. [Evidence](poll-evidence.md#bgc-05).
- <a id="bgc-06"></a> **BGC-06 — Implemented.** [Unlabelled ethnicity remains unknown (approved correction)](poll-evidence.md#bgc-06).
- <a id="bgc-08"></a> **BGC-08 — Preserved.** [Complete main attitude and summary-battery review](poll-evidence.md#bgc-08).
- <a id="bgc-07"></a> **BGC-07 — Implemented.** [baseline precedes arrival (resolved 2026-09-28)](poll-evidence.md#bgc-07).

### Bulgaria Roma-policy poll 2007 — bulgaria-2007

- <a id="bg07-01"></a> **BG07-01 — Source unavailable.** Reports are retained, but the 1,344 baseline and 255 event records are unavailable in inspected materials. No respondent-level audit is claimed; further searches were stopped at the user's request. [Evidence](poll-evidence.md#bg07-01).

### California 2011 — california-whats-next-2011

- <a id="ca-01"></a> **CA-01 — Implemented.** [The available source and deposited battery use different samples](poll-evidence.md#ca-01).
- <a id="ca-02"></a> **CA-02 — Verified.** [Party-control scoring is correct in the current knowledge build](poll-evidence.md#ca-02).
- <a id="ca-03"></a> **CA-03 — Implemented.** [The report's eight-question knowledge result is a different measure](poll-evidence.md#ca-03).
- <a id="ca-04"></a> **CA-04 — Implemented.** [Preserve arrival/exit respondents with no telephone baseline (corrected)](poll-evidence.md#ca-04).
- <a id="ca-05"></a> **CA-05 — Implemented.** [Preserve the single out-of-range departure knowledge code](poll-evidence.md#ca-05).
- <a id="ca-06"></a> **CA-06 — Verified.** [Archived eighth-item answer key conflicts with the final report](poll-evidence.md#ca-06).
- <a id="ca-07"></a> **CA-07 — Preserved.** [Archived departure initiative index duplicates a question](poll-evidence.md#ca-07).
- <a id="ca-08"></a> **CA-08 — Implemented.** [Retained arrival and exit policy ratings were missing from typed outputs](poll-evidence.md#ca-08).

### Europolis 2009 — europolis-2009

- <a id="euro-01"></a> **EURO-01 — Preserved.** Score equality alone cannot link people; retain verified source identities and distinguish the recovered arrival form from the misfiled 2007 form. [Evidence](poll-evidence.md#euro-01).
- <a id="euro-02"></a> **EURO-02 — Implemented.** [Aggregate identity is distinct from deposited-battery ordering](poll-evidence.md#euro-02).
- <a id="euro-03"></a> **EURO-03 — Implemented.** [Structural missingness and demographic meaning are preserved](poll-evidence.md#euro-03).
- <a id="euro-04"></a> **EURO-04 — Implemented.** [Unknown birthplace does not establish minority status (corrected)](poll-evidence.md#euro-04).
- <a id="euro-05"></a> **EURO-05 — Preserved.** [Published knowledge results mostly reproduce; three baseline cells do not](poll-evidence.md#euro-05).
- <a id="euro-06"></a> **EURO-06 — Implemented.** [Birth year 1900 is an unsupported age (corrected)](poll-evidence.md#euro-06).
- <a id="euro-07"></a> **EURO-07 — Implemented.** [Make both attitude labels match the numeric direction](poll-evidence.md#euro-07).

### National Issues Convention 1996 — nic-1996

- <a id="nic-01"></a> **NIC-01 — Preserved.** Keep the one missing-ID record under a source-scoped fallback and keep the eight-item battery distinct from the historical eleven-item battery. [Evidence](poll-evidence.md#nic-01).
- <a id="nic-02"></a> **NIC-02 — Verified.** The eleven-item historical battery is reconstructed independently with the documented numeric-answer bounds. [Evidence](poll-evidence.md#nic-02).
- <a id="nic-04"></a> **NIC-04 — Verified.** The unique missing-ID slot has a guarded within-source historical bridge; it is not a transferable person identifier. [Evidence](poll-evidence.md#nic-04).
- <a id="nic-11"></a> **NIC-11 — Implemented.** [Use immediate exit in the analysis pair and retain delayed follow-up](poll-evidence.md#nic-11).
- <a id="nic-03"></a> **NIC-03 — Implemented.** [Correct birth-year conversion and event mode upstream](poll-evidence.md#nic-03).
- <a id="nic-05"></a> **NIC-05 — Implemented.** [Shared peer-opportunity ceiling convention](poll-evidence.md#nic-05).
- <a id="nic-06"></a> **NIC-06 — Preserved.** [Baseline Bosnia answer is date-dependent in the stated rule](poll-evidence.md#nic-06).
- <a id="nic-07"></a> **NIC-07 — Source limit.** [Party-placement percentages need their own analysis definition](poll-evidence.md#nic-07).
- <a id="nic-08"></a> **NIC-08 — Implemented.** [Correct the clear birth-year typo and withhold unsupported ages](poll-evidence.md#nic-08).
- <a id="nic-09"></a> **NIC-09 — Implemented.** [Event-exit extremity and dispersion used three baseline answers](poll-evidence.md#nic-09).
- <a id="nic-10"></a> **NIC-10 — Implemented.** [Cross-poll catalog mislabeled all nine spending questions (corrected)](poll-evidence.md#nic-10).
- <a id="nic-12"></a> **NIC-12 — Implemented.** [Unknown spending attitudes are missing, not neutral (approved)](poll-evidence.md#nic-12).

### Tomorrow's Europe 2007 — tomorrows-europe-2007

- <a id="te-01"></a> **TE-01 — Source limit.** Different source cohorts and anonymous deposited ordering are not interchangeable; retain the verified historical selection. [Evidence](poll-evidence.md#te-01).
- <a id="te-02"></a> **TE-02 — Implemented.** Out-of-range knowledge responses remain raw but have missing item correctness; preserve documented wave-specific scales and source limits. [Evidence](poll-evidence.md#te-02).
- <a id="te-03"></a> **TE-03 — Implemented.** [Historical aggregate selects 344 people by the earlier group field](poll-evidence.md#te-03).
- <a id="te-04"></a> **TE-04 — Implemented.** [Two departure indices mix arrival and departure answers](poll-evidence.md#te-04).
- <a id="te-06"></a> **TE-06 — Implemented.** [Use exit rather than arrival for the main attitude comparison (approved)](poll-evidence.md#te-06).
- <a id="te-07"></a> **TE-07 — Preserved.** [Full attitude battery and source-direction review](poll-evidence.md#te-07).
- <a id="te-05"></a> **TE-05 — Implemented.** [Include postgraduate education and use the source age (corrected)](poll-evidence.md#te-05).
- <a id="te-08"></a> **TE-08 — Implemented.** [Preserve source nonanswers and literal wave identities in transport](poll-evidence.md#te-08).

### Vermont Energy 2007 — vermont-energy-2007

- <a id="vt-02"></a> **VT-02 — Source limit.** Reported discussion groups lack a verified person-to-group roster; retain unknown memberships without a synthetic group. [Evidence](poll-evidence.md#vt-02).
- <a id="vt-01"></a> **VT-01 — Preserved.** [Key ambiguity must remain explicit](poll-evidence.md#vt-01).
- <a id="vt-03"></a> **VT-03 — Implemented.** [The question catalog inherited incorrect choice labels (corrected)](poll-evidence.md#vt-03).

### San Mateo 2008 — san-mateo-2008

- <a id="sm-01"></a> **SM-01 — Source limit.** [Existing key change needs version-specific instrument evidence](poll-evidence.md#sm-01).
- <a id="sm-02"></a> **SM-02 — Preserved.** [IDs and summary batteries follow an earlier analysis stage](poll-evidence.md#sm-02).
- <a id="sm-03"></a> **SM-03 — Implemented.** [Baseline knowledge uses the eight questions in the instrument (corrected)](poll-evidence.md#sm-03).
- <a id="sm-04"></a> **SM-04 — Implemented.** [Anonymous item rows and reconstructed respondents had different order](poll-evidence.md#sm-04).
- <a id="sm-05"></a> **SM-05 — Implemented.** [Housing-income question includes three income groups (catalog corrected)](poll-evidence.md#sm-05).
- <a id="sm-11"></a> **SM-11 — Robustness.** [Blank knowledge batteries and zero scores are retained but flagged](poll-evidence.md#sm-11).
- <a id="sm-08"></a> **SM-08 — Implemented.** [Participant 1467 has no departure questionnaire answers — approved](poll-evidence.md#sm-08).
- <a id="sm-09"></a> **SM-09 — Implemented.** [Preserve scientific source strings, dates and questionnaire headers](poll-evidence.md#sm-09).
- <a id="sm-10"></a> **SM-10 — Implemented.** [Source nonparticipants without departure forms received zero scores](poll-evidence.md#sm-10).

### Michigan 2009 — michigan-2009

- <a id="mi-01"></a> **MI-01 — Implemented.** Preserve explicit DK, invalid codes and ambiguous free text separately; do not invent a party answer for SC or “same.” [Evidence](poll-evidence.md#mi-01).
- <a id="mi-02"></a> **MI-02 — Implemented.** [Nine shared items and the report's eleven items compare different waves](poll-evidence.md#mi-02).
- <a id="mi-03"></a> **MI-03 — Implemented.** [Preserve the single out-of-range arrival placement code](poll-evidence.md#mi-03).
- <a id="mi-04"></a> **MI-04 — Implemented.** [Five arrival factual responses were incorrectly excluded from the public source](poll-evidence.md#mi-04).
- <a id="mi-05"></a> **MI-05 — Implemented.** [Scientific answers were mistaken for nonessential text](poll-evidence.md#mi-05).
- <a id="mi-06"></a> **MI-06 — Implemented.** [Comparable factual and placement knowledge at arrival](poll-evidence.md#mi-06).

### Denmark Euro 2000 — denmark-euro-2000

- <a id="dk-01"></a> **DK-01 — Preserved.** Retain the 359 linked departure interviews; anonymous deposited omissions and extra baseline-only rows do not establish a replacement cohort. [Evidence](poll-evidence.md#dk-01).
- <a id="dk-02"></a> **DK-02 — Verified.** [Independent factual keys and departure estimates agree (checked)](poll-evidence.md#dk-02).
- <a id="dk-03"></a> **DK-03 — Verified.** [Archived zero-filling copied baseline facts into departure columns](poll-evidence.md#dk-03).
- <a id="dk-04"></a> **DK-04 — Source limit.** [The retained English questionnaire is an earlier instrument version](poll-evidence.md#dk-04).
- <a id="dk-05"></a> **DK-05 — Implemented.** [Original arrival source preserved publicly and scored](poll-evidence.md#dk-05).
- <a id="dk-07"></a> **DK-07 — Source limit.** [Discussion-group linkage is still missing after source search](poll-evidence.md#dk-07).
- <a id="dk-06"></a> **DK-06 — Verified.** [Follow-up instrument, keys and participant identities verified](poll-evidence.md#dk-06).

### Northern Ireland 2007 — northern-ireland-2007

- <a id="ni-01"></a> **NI-01 — Implemented.** The downstream reader now retains all 124 source roster mappings, including the formerly lost first record. [Evidence](poll-evidence.md#ni-01).
- <a id="ni-02"></a> **NI-02 — Implemented.** Original questionnaire text and literal coder slots are preserved separately; proposed changes to argument-scoring meaning remain a consultation. [Evidence](poll-evidence.md#ni-02).
- <a id="ni-03"></a> **NI-03 — Verified.** [Knowledge keys reproduce the paper; restore the first question's condition](poll-evidence.md#ni-03).
- <a id="ni-04"></a> **NI-04 — Implemented.** [label follow-up nonanswers explicitly (corrected)](poll-evidence.md#ni-04).
- <a id="ni-05"></a> **NI-05 — Implemented.** [A follow-up-only source is not a selected pre/post panel (corrected)](poll-evidence.md#ni-05).
- <a id="ni-06"></a> **NI-06 — Implemented.** [Preserve literal argument-code sets during CSV import (corrected)](poll-evidence.md#ni-06).

### America in One Room 2019

- <a id="a1r19-01"></a> **A1R19-01 — Implemented.** [attendance and post-survey completion differ (corrected)](poll-evidence.md#a1r19-01).
- <a id="a1r19-02"></a> **A1R19-02 — Implemented.** [preserve documented nonanswer status (corrected)](poll-evidence.md#a1r19-02).
- <a id="a1r19-03"></a> **A1R19-03 — Verified.** [published party means reproduce when a nonresponse code is included (checked; retain missing coding)](poll-evidence.md#a1r19-03).
- <a id="a1r-2019"></a> **A1R-2019 — Implemented.** [recruitment is not a verified invitation](poll-evidence.md#a1r-2019).

### America in One Room Climate 2021

- <a id="a1rc-01"></a> **A1RC-01 — Implemented.** [label the published climate cohort as completed (corrected)](poll-evidence.md#a1rc-01).
- <a id="a1rc-02"></a> **A1RC-02 — Implemented.** [retain observed climate-poll gender in the participant export (corrected)](poll-evidence.md#a1rc-02).
- <a id="a1rc-03"></a> **A1RC-03 — Implemented.** [distinguish factual-item nonanswers from substantive responses (corrected)](poll-evidence.md#a1rc-03).
- <a id="a1rc-04"></a> **A1RC-04 — Verified.** [reproduce the climate report's attitude ratings (checked)](poll-evidence.md#a1rc-04).
- <a id="a1rc-05"></a> **A1RC-05 — Implemented.** [restore the original room-plus-schedule group identity (approved)](poll-evidence.md#a1rc-05).

### Antimicrobial Resistance 2024

- <a id="amr-01"></a> **AMR-01 — Verified.** [six-country knowledge scoring checked against the report](poll-evidence.md#amr-01).
- <a id="amr-02"></a> **AMR-02 — Implemented.** [populate the observed gender field (corrected)](poll-evidence.md#amr-02).
- <a id="amr-03"></a> **AMR-03 — Source limit.** [source ages differ across interviews (retained source limitation)](poll-evidence.md#amr-03).
- <a id="amr-04"></a> **AMR-04 — Implemented.** [preserve verified phases and recovered measurement evidence (implemented)](poll-evidence.md#amr-04).

### Marousi 2006

- <a id="mar-01"></a> **MAR-01 — Implemented.** [derived post knowledge zeros need an item-level and wave bridge](poll-evidence.md#mar-01).
- <a id="mar-02"></a> **MAR-02 — Implemented.** [Original source bridges the report; partial quizzes were zeroed as whole scores](poll-evidence.md#mar-02).
- <a id="mar-03"></a> **MAR-03 — Implemented.** [Publish the original seven-item answers at each verified phase](poll-evidence.md#mar-03).
- <a id="mar-04"></a> **MAR-04 — Source limit.** [Mayor-performance responses lack verified scale instructions](poll-evidence.md#mar-04).

### Tanzania 2015

- <a id="tz-01"></a> **TZ-01 — Preserved.** [group assignment does not by itself establish treatment eligibility](poll-evidence.md#tz-01).
- <a id="tz-02"></a> **TZ-02 — Implemented.** [retain the observed sex field in the participant export (corrected)](poll-evidence.md#tz-02).
- <a id="tz-03"></a> **TZ-03 — Implemented.** [negative missing-component code excluded from the knowledge index](poll-evidence.md#tz-03).
- <a id="tz-04"></a> **TZ-04 — Implemented.** [panel membership requires both selected measurements](poll-evidence.md#tz-04).
- <a id="tz-05"></a> **TZ-05 — Implemented.** [borrowing uses five categories; include it with the other policy items (corrected)](poll-evidence.md#tz-05).
- <a id="tz-06"></a> **TZ-06 — Preserved.** [original subgroup syntax and education label need separate review](poll-evidence.md#tz-06).
- <a id="tz-07"></a> **TZ-07 — Implemented.** [use native household IDs consistently across typed exports](poll-evidence.md#tz-07).
- <a id="tz-08"></a> **TZ-08 — Implemented.** [recognize questionnaires from actual policy answers](poll-evidence.md#tz-08).

### New Haven 2002 — historical ID new-haven-2004

- <a id="nh-02"></a> **NH-02 — Source limit.** [Event year corrected; attendance needs reconciliation](poll-evidence.md#nh-02).
- <a id="nh-03"></a> **NH-03 — Verified.** [The three-wave workbook supplies raw answers and an explicit ID bridge](poll-evidence.md#nh-03).
- <a id="nh-04"></a> **NH-04 — Implemented.** [Airport scaling reviewed; age remains historical](poll-evidence.md#nh-04).
- <a id="nh-05"></a> **NH-05 — Superseded.** [Historical interim attitude rules superseded by NH-08](poll-evidence.md#nh-05).
- <a id="nh-06"></a> **NH-06 — Implemented.** [Race refusal is missing minority status (corrected)](poll-evidence.md#nh-06).
- <a id="nh-07"></a> **NH-07 — Implemented.** [Historical airport index replaced an attainable 0.625 with 0.675](poll-evidence.md#nh-07).
- <a id="nh-08"></a> **NH-08 — Implemented.** [Nonanswers in the three-wave attitude battery](poll-evidence.md#nh-08).
- <a id="nh-09"></a> **NH-09 — Implemented.** [Attitude source statuses now exclude documented don't-know answers](poll-evidence.md#nh-09).
- <a id="nh-10"></a> **NH-10 — Implemented.** [Zero is not an offered knowledge answer](poll-evidence.md#nh-10).

### Shared rules

- <a id="new-01"></a> **NEW-01 — Implemented.** [Newer-poll mode labels and reported sample totals](poll-evidence.md#new-01).
- <a id="x-01"></a> **X-01 — Implemented.** [Knowledge eligibility is not the respondent universe](poll-evidence.md#x-01).
- <a id="x-02"></a> **X-02 — Implemented.** [Preserve literal waves and fieldwork meaning](poll-evidence.md#x-02).
- <a id="x-03"></a> **X-03 — Implemented.** [Typed missingness and explicit denominators](poll-evidence.md#x-03).
- <a id="x-04"></a> **X-04 — Preserved.** [Person-level identity requires more than matching scores](poll-evidence.md#x-04).
- <a id="x-05"></a> **X-05 — Preserved.** [Some poll-level files already contain merges and derived variables](poll-evidence.md#x-05).
- <a id="x-06"></a> **X-06 — Preserved.** [Historical aggregates are comparison evidence, not scoring inputs](poll-evidence.md#x-06).
- <a id="x-07"></a> **X-07 — Verified.** [Audit artifacts can lag a source relocation](poll-evidence.md#x-07).
- <a id="x-08"></a> **X-08 — Preserved.** [Evidence needed before accepting a change](poll-evidence.md#x-08).
- <a id="x-09"></a> **X-09 — Preserved.** [Reviewed covariance exceptions and historical numerical comparisons](poll-evidence.md#x-09).
- <a id="x-10"></a> **X-10 — Verified.** [Export row numbers are regenerated; scientific comparisons use IDs](poll-evidence.md#x-10).
- <a id="x-11"></a> **X-11 — Implemented.** [Data recoding belongs upstream, not in downstream readers](poll-evidence.md#x-11).
- <a id="x-12"></a> **X-12 — Implemented.** [Political interest needs a common direction and an explicit scale](poll-evidence.md#x-12).
- <a id="x-13"></a> **X-13 — Implemented.** [One empirical median definition for individual and group variables](poll-evidence.md#x-13).
- <a id="x-14"></a> **X-14 — Implemented.** [The highest education category is not a uniform degree indicator](poll-evidence.md#x-14).
- <a id="x-15"></a> **X-15 — Implemented.** [Invalid pairwise covariance does not define generalized variance](poll-evidence.md#x-15).
- <a id="x-16"></a> **X-16 — Implemented.** [Repeated phase estimates can be aliases or inconsistent metadata](poll-evidence.md#x-16).
- <a id="x-22"></a> **X-22 — Implemented.** [Complete source-form dependencies and safe local subsets](poll-evidence.md#x-22).
- <a id="x-23"></a> **X-23 — Implemented.** [Questionnaire write-ins were incorrectly classified as nonessential text](poll-evidence.md#x-23).
- <a id="x-24"></a> **X-24 — Implemented.** [Blank source text inflated observed-input counts](poll-evidence.md#x-24).
- <a id="x-25"></a> **X-25 — Source limit.** [Verified public source placement and remaining local source frontier](poll-evidence.md#x-25).
- <a id="x-26"></a> **X-26 — Implemented.** [Complete the distinction between source provenance and contacts](poll-evidence.md#x-26).
- <a id="x-27"></a> **X-27 — Implemented.** [Shared knowledge, questionnaire and participation contracts](poll-evidence.md#x-27).
- <a id="x-28"></a> **X-28 — Implemented.** [Carry reviewed covariates into the full source frame](poll-evidence.md#x-28).

### NIC2 2003 — nic2-2003

- <a id="nic2-01"></a> **NIC2-01 — Verified.** [Historical identity is now a verified, ID-only bridge](poll-evidence.md#nic2-01).
- <a id="nic2-02"></a> **NIC2-02 — Preserved.** [Authored attitude versions reconciled; selected security rule preserved](poll-evidence.md#nic2-02).
- <a id="nic2-03"></a> **NIC2-03 — Preserved.** [Knowledge and group gain have specific storage stages](poll-evidence.md#nic2-03).
- <a id="nic2-04"></a> **NIC2-04 — Source limit.** [Demographic categories and thresholds require separate review](poll-evidence.md#nic2-04).
- <a id="nic2-05"></a> **NIC2-05 — Implemented.** [Six cross-poll attitude names point to the wrong indices (catalog corrected)](poll-evidence.md#nic2-05).

### BTP National 2003 — btp-national-2003

- <a id="btpn-01"></a> **BTPN-01 — Superseded.** [Historical inclusion does not equal the attendance flag](poll-evidence.md#btpn-01).
- <a id="btpn-02"></a> **BTPN-02 — Implemented.** [Support components now use the instrument's full scale (corrected)](poll-evidence.md#btpn-02).
- <a id="btpn-03"></a> **BTPN-03 — Preserved.** [Eleven-item respondent knowledge and baseline calibration differ](poll-evidence.md#btpn-03).
- <a id="btpn-04"></a> **BTPN-04 — Preserved.** [Deliberate nested weighting preserved; version conflicts documented](poll-evidence.md#btpn-04).
- <a id="btpn-05"></a> **BTPN-05 — Implemented.** [Baseline political interest was omitted from the final aggregate](poll-evidence.md#btpn-05).
- <a id="btpn-06"></a> **BTPN-06 — Implemented.** [Terrorism and poverty catalog names were swapped (corrected)](poll-evidence.md#btpn-06).
- <a id="btpn-07"></a> **BTPN-07 — Preserved.** [Original dates and the wider source cohort (source preserved)](poll-evidence.md#btpn-07).

### BTP Presidential Primaries 2004 — btp-presidential-primaries-2004

- <a id="pr-01"></a> **PR-01 — Preserved.** [Draft counts and recodes are not the executed aggregate definition](poll-evidence.md#pr-01).
- <a id="pr-04"></a> **PR-04 — Preserved.** [All three main attitude pairs verified; unconsidered responses excluded](poll-evidence.md#pr-04).
- <a id="pr-02"></a> **PR-02 — Implemented.** [Peer gain now uses the whole group (corrected)](poll-evidence.md#pr-02).
- <a id="pr-03"></a> **PR-03 — Implemented.** [Duplicate aggregate rows and doubled group counts (corrected)](poll-evidence.md#pr-03).

### Zeguo 2005 — zeguo-2005

- <a id="zg-01"></a> **ZG-01 — Preserved.** [Component joins and three item-coding overrides are explicit](poll-evidence.md#zg-01).
- <a id="zg-02"></a> **ZG-02 — Implemented.** [Scale the village-road rating and use post-wave main roads](poll-evidence.md#zg-02).
- <a id="zg-03"></a> **ZG-03 — Superseded.** [Two road indices make covariance numerically singular](poll-evidence.md#zg-03).
- <a id="zg-04"></a> **ZG-04 — Implemented.** [One baseline age is 1; the paired departure age is 33](poll-evidence.md#zg-04).
- <a id="zg-05"></a> **ZG-05 — Implemented.** [The Wenchang Main Avenue slot duplicates the main-roads index](poll-evidence.md#zg-05).
- <a id="zg-06"></a> **ZG-06 — Preserved.** [All nine attitude batteries have been reconstructed and source versions compared](poll-evidence.md#zg-06).
- <a id="zg-07"></a> **ZG-07 — Implemented.** [Thirty-four people have no matched participant departure questionnaire](poll-evidence.md#zg-07).
- <a id="zg-08"></a> **ZG-08 — Preserved.** [Township Image has two authored definitions](poll-evidence.md#zg-08).
- <a id="zg-09"></a> **ZG-09 — Implemented.** [Preserve out-of-range knowledge codes as missing](poll-evidence.md#zg-09).
- <a id="zg-10"></a> **ZG-10 — Robustness.** [Many exit knowledge scores are zero, including wholly blank batteries](poll-evidence.md#zg-10).

<a id="cross-poll-issues-for-the-eventual-schema"></a>
<a id="x-11-data-recoding-belongs-upstream-not-in-downstream-readers"></a>
The [full shared-rule evidence](poll-evidence.md#cross-poll-issues-for-the-eventual-schema)
and [upstream-recoding decision](poll-evidence.md#x-11) retain earlier link targets.
