# Canonical analysis tables

`make analysis` writes seventeen typed Parquet tables and a checksum manifest to
`output/analysis/`. `make check` rebuilds them after the knowledge, respondent,
and historical aggregate exports. Source files and reviewed metadata stay in
`data/` and `metadata/`; downstream projects use the Parquet tables.

| Table | Row unit and key |
| --- | --- |
| `analysis_polls` | One registered poll; `poll_id` |
| `analysis_poll_events` | One sourced timing statement; `poll_id`, `event_id` |
| `analysis_items` | One knowledge question; `poll_id`, `item_id` |
| `analysis_participants` | One source respondent; `poll_id`, `source_dataset`, `respondent_id` |
| `analysis_item_responses` | One answer; participant key, `wave`, `item_id` |
| `analysis_scores` | One respondent-wave score; participant key, `wave` |
| `analysis_attitudes` | One policy measure; `poll_id`, `attitude_id` |
| `analysis_attitude_responses` | One policy response; participant key, `attitude_id`, `wave` |
| `analysis_studies` | One catalog cohort mapped to its underlying study; `poll_id` |
| `analysis_survey_waves` | One survey occasion per catalog cohort; `poll_id`, `wave_instance_id` |
| `analysis_phase_participants` | One source respondent with attendance evidence; participant key |
| `analysis_phase_scores` | One knowledge measurement; participant key, `battery_id`, `wave_instance_id` |
| `analysis_phase_attitudes` | One reviewed paired attitude item; `poll_id`, `attitude_id` |
| `analysis_phase_attitude_responses` | One raw attitude answer; participant key, `attitude_id`, `wave_instance_id` |
| `analysis_phase_item_responses` | One item answer with verified timing; participant key, `battery_id`, `wave_instance_id`, `item_id` |
| `analysis_source_attitude_definitions` | One source attitude field and occasion; `source_id`, `source_column`, `source_wave` |
| `analysis_source_attitude_responses` | One source-row response; `source_id`, `source_row`, `source_column` |

There are respondent records for 33 polls and item responses for 31. The
participant table covers the 21 reviewed historical surveys, 23 Cor–Sood
batteries, five control studies, and the score-only Marousi file. Sixteen
historical and Cor–Sood polls overlap. `source_dataset` distinguishes their
separate person IDs; identical IDs across the deposits do not imply the same
person. Northern Ireland is a verified exception: its Cor–Sood T1/T2 battery
and the T3 survey use the same `cserial` respondent ID for 93 returning
participants. Marousi's recovered raw answers and authored correctness flags
support the phase-item table; its selected item table remains unchanged.
Tanzania retains nine scored knowledge components in its source file, but its
original raw question-and-answer mapping has not been recovered. Its canonical
handoff remains score-only.

`item_id` uses `knowledge_001`, `knowledge_002`, and so on within each poll.
The original baseline source field is `source_column_t1`; for the eight added
arrival-only items this names the earliest fielded source and the coding note
explicitly identifies arrival. Historical and
Cor–Sood battery IDs have their own columns. Four Zeguo questions use a
different historical post-wave ID, recorded in `historical_item_id_t2`.
The item-response table maps each source battery to the canonical ID, retaining
`source_column`, numeric or text answer where available, scored correctness,
and the original adapter’s response status. `response_reason` supplies the
normalized reason; `response_status` preserves the earlier adapter classification
for provenance. Historical raw answers are recovered through verified
question and source-wave mappings; source codes also remain in
`output/respondent/source_responses.parquet`. Score-level `n_observed` retains
the existing completeness convention and may remain null for historical scored
exports; the enriched item rows provide the more detailed response evidence.

Knowledge uses its own convention, separate from attitude imputation.
`knowledge_response` is `correct`, `incorrect`, or `dk`; explicit “don't know,”
“cannot say,” and equivalent documented labels map to `dk`. The original code
and `source_response_label` are retained. `response_reason` distinguishes a
blank, refusal, inapplicable question, absent questionnaire, and unresolved
source code. Those cases are not relabeled `dk`. The reviewed response-code
dictionary can supply a `response_reason` without a label when an observed code
is demonstrably outside the offered options; this preserves the absence of an
original source label rather than inventing one. Where a source preserves only
correctness, a zero cannot establish whether the person attempted the question.
The separate integer `correct` column counts DK, refusals and reviewed blanks
as zero within an observed questionnaire. Invalid responses, absent questionnaires
and unresolved cases remain missing. This item-level zero filling does not change total scores,
which already count those nonanswers as zero. No guessing adjustment is imposed
in this data layer.

For `guess::fit_item_lca()` or `guess::fit_person_lca()`, map `correct` to 1,
`incorrect` to 0, and `dk` to the explicit `"dk"` category, and pass
`na_as = "missing"`. The package otherwise interprets `NA` as DK by default.
The binary correctness column cannot recover which zeros were explicit DK;
use the trichotomy and retain the reason for excluded responses. Guessing
adjustment and its assumptions remain downstream analysis choices.
The 2019 America in One Room codebook supplies offered choices and keyed answer
text. The recovered climate preparation script supplies Q19–Q24 options, keys
and nonanswer labels; equivalent missing-code documentation for Q17/Q18 remains
unavailable. AMR's recovered questionnaire, expert answer table and harmonized
codebooks supply all six items' options and keyed text. Its questionnaire Q21
copies the preceding question's options, but the expert table and codebook agree
on the infection-prevention options and key 5. Existing scoring is preserved;
[Poll issues](poll-issues.md#amr-04--preserve-verified-phases-and-recovered-measurement-evidence-implemented)
records the source conflict and remaining evidence gaps.

Attitude indices in the respondent layer distinguish missing-preserving values
from imputed derivatives by name: `research_t2` and
`research_t2_midpoint_imputed`, for example. The suffix applies throughout the
poll builders wherever nonresponse is replaced by a midpoint. Metadata specify
whether the fill occurs before or after scaling; the imputed result therefore
need not equal 0.5. Both variants remain missing for an absent departure
questionnaire. Historical aggregate mappings explicitly select the authored
imputed version. Available-component means and substantive neutral answers are
not themselves midpoint imputation.

The selected-wave tables retain the historical analysis labels: `t1` and
`t2` mean the selected initial and later scores. These do not consistently mean
arrival and exit. Use `analysis_phase_scores` for event timing: `t0` means
pre-arrival or pre-start, `t1` arrival/start, `t2` immediate post-deliberation,
and `t3` onward later follow-ups. New Haven's measurement after its first session
is `interim_1`. NIC's original T2 is exit and T3 is a ten-month follow-up.
Tanzania's telephone reinterview is weeks later and is classified as follow-up.
Original survey labels and legacy score labels remain separate columns.

`analysis_phase_item_responses` maps existing item responses to their documented
survey occasions and adds the verified arrival batteries. California and Europolis
retain both common and expanded batteries; Michigan has separate four-placement
three-wave and six-placement arrival/exit batteries. Select `battery_id` explicitly
before comparing phases. The source files retain people outside each existing
analytical cohort, and California's separate eight-item output still covers its
broader 412-person source cohort. Questionnaire absence yields null correctness
and scores; blank items within an observed form score zero. Marousi remains
score-only here. AMR now contributes 4,838 phase scores and 29,028 item responses:
2,419 people at both pre-invitation t0 and event-end t2. The version 2 paper
establishes those occasions; no arrival measurement, exact interview dates or
survey mode is inferred. All existing AMR answers and numerical scores are unchanged.

Readers must select a baseline/outcome pair explicitly. Arrival-to-exit (`t1` to `t2`) and pre-arrival-to-exit (`t0` to `t2`) are
distinct comparisons, never implicit substitutes for one another. The source
universe must retain available pre-arrival responses from nonattendees and
people without a group; analysis views select attendees, observed wave pairs
or known memberships as needed. This preserves evidence for selection and
attrition comparisons.

The participant table separates `assignment`, the retained source category
`arm`, and event attendance `attended`. Both participant tables carry the same
`attended` and nonnullable `attendance_basis` on their shared person keys.
Attendance can be observed or inferred; the basis makes that distinction explicit.
In America in One Room 2019, `assignment = recruitment`
identifies the baseline recruitment sample; NORC later subsampled this frame for
invitations. Its nonattenders are `recruitment_nonattender`, since individual
invitation status is not established. In the climate study, baseline treatment
respondents were invited to register. The 962 who completed the event and post
survey are `completed`; the other 7,018 remain `invited_noncompleter`. Their
`SESSION1`–`SESSION4` records establish some attendance for 184 and no attendance
for 426 with four observed zeros. The other 6,408 have no session records and
no observed answers in the raw immediate post questionnaire; their nonattendance
is inferred, with `attendance_basis = inferred_absent_post_questionnaire`.
Positive session evidence takes precedence over an absent post questionnaire.
Controls retain `attended = FALSE`, and documented completers retain
`attended = TRUE`; assignment, completion category and panel inclusion do not
change.
AMR retains 1,280 attendees and 1,139 controls; the paper's 1,847 invited
nonattenders are absent from its deposit. These rows therefore cannot identify
a full invitation intention-to-treat effect. Its supplied weights apply within
country × arm, as the original deposit README specifies; they do not define a
pooled six-country population weight. Invitations were randomized in some
studies, but analysis of attendees is not an intention-to-treat estimate.
`small_group_id` identifies a
discussion group when observed; `cluster_id` is the inference cluster and is a
village in Tanzania. Missing values mean the fact was not established in the
available source, not that it did not occur. `panel` requires both selected
comparison scores and retains the original sample restrictions. It does not
define eligibility for every phase contrast. Tanzania respondent `1323`
(`HHID == 240301`) has only a follow-up score and is outside the paired panel;
the person and observed follow-up remain. The corrected panel has 1,857 people.
For Cor–Sood respondents, group IDs come from the reviewed
`output/memberships.parquet` on the same `(poll_id, respondent_id)` key. That
source supplies 6,147 memberships across 21 polls, including BTP online
primaries, BTP 2007, Michigan, and California, which are absent from the
historical group-analysis sample. Denmark and Vermont have no verified group
roster; 13 BTP online-primary respondents also lack an assignment.

The participant table includes age in years, education (0 = below secondary
completion, .5 = secondary/some college, 1 = degree or higher), minority status,
attitude extremity, and self-reported briefing reading on a 0–1 scale. Age and
education are harmonized for the historical surveys and seven additional polls
with discussion groups. Historical age values can represent category midpoints.
Briefing reading covers twelve of those polls and refers to reading before
discussion, recalled afterward. Michigan's letter-coded reading answers are
categorical survey responses; unrecognized codes remain missing. Attitude
extremity and minority status retain the historical definitions and coverage.
The schema and recode ledger record source fields, category mappings, and sources.
UK Health's `ba` flag uses the separate B12 degree question (`educb == 9`),
with nonresponse missing. Its B11 school-qualification scale is not a degree
measure and must not be interpreted as one; the empirical-median education
classification is also a separate measure. This correction yields 32 degree
holders among 229 observed answers, with all 230 historical participants retained.
The covariate build preserves every participant key and does not impose a
complete-case sample; downstream analyses select the variables they need.

`analysis_scores` averages item correctness over the full fielded battery for
the four item-linked control polls and both deposited historical batteries.
Missing, skipped, and don't-know answers enter that proportion as zero; the
response table preserves their source status. Documented nonanswers now use
`non_substantive` for America in One Room 2019 codes −8/77/98/99 (13,709 cells),
Northern Ireland follow-up codes 9/10 (356), and climate Q19–Q24 codes 77/98/99
(16,580). Each count applies separately to the selected-wave and phase item
tables. Raw codes, correctness, scores, denominators and people are unchanged.

Tanzania's released standardized index is marked as a source score with null
item counts. Its first component contains −99 values that entered the original
standardization numerically. TZ-03 documents the reproduced calculation and a
proposed zero recode with recalibration; this numerical correction has not been
applied. The current source indices remain unchanged. Marousi preserves
its original telephone proportion at t0 and computes arrival/exit proportions
from seven authored correctness flags. Individual blanks/DK count wrong;
seventeen absent exit questionnaires have missing scores. All 146 grouped
people remain and 129 have both arrival and exit questionnaires. The full
1,275-person original source is retained in `data/marousi-2006/survey.sav`;
the existing grouped canonical view is not the full recruitment universe.
A downstream project can choose another scoring rule by grouping `analysis_item_responses`.
Northern Ireland's T3 battery contributes seven items for 93 returning
participants and 150 controls. These controls were first interviewed at T3;
they have no T1 or T2 knowledge scores. The control comparison for that poll
therefore uses the T3 cross-section, while its T1/T2 participant battery remains
in the Cor–Sood source rows. The 93 returning participants can be linked across
these waves by `(poll_id, respondent_id)` after restricting the source datasets.

The poll table adds event country, city, month, and exact dates only when the
reviewed per-poll JSON facts support them. `analysis_poll_events` retains every
reported timing statement and its `reference_id`. A complex or partial report
may have only its original text or month; null dates are intentional. The New
Haven timing statement says 2002 but the registry identifies the poll as 2004,
so `year_conflict` flags that row and the poll's typed event date stays null.
`place` describes the study's geographic scope; `event_country` and `city`
describe a single venue where identifiable. For multi-country online AMR,
event country and city are null; respondent country is in the participant table.

Join `analysis_participants` to `analysis_scores` by its three-part participant
key, then filter `wave`. Join to `analysis_item_responses` by that same key;
join either long table to `analysis_items` by `(poll_id, item_id)` and to
`analysis_polls` by `poll_id`. The build rejects duplicate keys, orphan item
responses, and item IDs absent from the catalog. `output/analysis/manifest.csv`
records row counts, schemas, and SHA-256 hashes for every table.

## Baseline policy attitudes

`analysis_attitudes.parquet` defines policy measures and their source columns,
response bounds, labels, and evidence. `analysis_attitude_responses.parquet`
has one row per canonical participant, measure, and wave, keyed by `poll_id`,
`source_dataset`, `respondent_id`, `attitude_id`, and `wave`. The initial release
covers baseline (`t1`) in 28 polls, including control respondents where present.
Values are on a 0–1 scale; refusal, no-opinion, and out-of-range codes are missing.
Single-item attitudes keep nonanswers missing. Historical composite indices may use
explicitly named `_midpoint_imputed` variants; plain alternatives remain in
`output/respondent/respondent_measures.parquet`. The canonical baseline catalog
identifies every such variant by name and construction, rather than silently
substituting a midpoint.

The 21 earlier polls retain the existing policy indices and their documented
construction in the rebuilt polardata. The seven additional polls use individual
policy responses listed in `metadata/attitude_items.csv`: BTP 2007's 14 reform
proposals; four policy self-placements in the online primaries; California's 27
reform proposals; Michigan's eight spending and assistance preferences; Northern
Ireland's 14 school-organization preferences; 47 America in One Room proposals;
and 60 climate and energy proposals. Candidate/party placements, factual answers,
perceptions of other respondents' views, and evaluations of deliberation are not
included. These are policy measures, not a common latent attitude scale; the
number and aggregation of measures differ across polls. Source endpoints determine
scaling, not the observed sample minimum and maximum.

Downstream analyses can calculate extremity as the average absolute distance from
0.5 across observed measures. For group disagreement, calculate the mean absolute
difference across distinct respondent pairs separately for each measure, then
average across measures with at least two observed responses. Select the analysis
participants before calculating group measures. This statistic is unchanged by
reversing a scale and does not require an invertible covariance matrix. Average
within-group standard deviation is an alternative dispersion summary. Both
summaries give each available policy measure equal weight within its poll; neither
requires assigning a shared left–right direction to different policy questions.

The phase exports separate event timing from the historical selected-wave names.
`analysis_phase_participants` retains the available recruitment frame, including
Marousi's 1,275 telephone respondents. Its existing 146 grouped respondents retain
their original keys and covariates. Additional respondents have source-based keys;
unknown attendance stays unknown rather than being inferred from a missing group.
`analysis_phase_scores` uses the evidence in `metadata/analysis_phase_roles.csv`:
`t0` is pre-arrival, `t1` arrival, `t2` immediate exit, and `t3` a later follow-up.
Original score labels and timing evidence accompany every score. New Haven's
questionnaire after its first deliberative session is `interim_1`, not arrival.
NIC's second source wave is immediate exit, while its third is a ten-month
follow-up. An arrival questionnaire is not established for NIC.

A blank knowledge battery within an observed questionnaire scores zero. A wholly
absent questionnaire scores missing. When the available fields cannot establish
questionnaire presence, `wave_observed` is missing: a downstream phase comparison
must not silently treat that uncertainty as either an observed zero or absence.
Identifiers and generated correctness flags cannot establish questionnaire
presence. Source batteries remain separate; equal numerical ranges do not make
different batteries interchangeable. Unverified timing is excluded from these
phase exports, while all historical selected-wave exports remain available.

These exports support descriptive paired changes and pre-arrival selection
comparisons. The source data do not generally identify selection-adjusted causal
effects. In Marousi, sixteen exit codes disagree with telephone IDs in the original
merge; the authored row associations are preserved, and paired comparisons remain
conditional on that unresolved linkage. Unknown attendance and unknown discussion
groups must remain visible in downstream coverage and uncertainty reports.


## Study identity, survey occasions, and evidence

The phase tables use schema version 2. `metadata/canonical_columns.csv` specifies
each Arrow type, nullability, and key; the writer rejects missing required fields,
duplicate keys, and a failed Parquet round trip. Dates use `date32`, counts use
`int32`, scores use `float64`, and attendance/questionnaire presence use nullable
booleans alongside explicit status strings. Unknown is never an implicit false.

`analysis_studies` maps catalog/cohort `poll_id` to underlying `study_id`.
Both 2004 Primaries IDs refer to `btp-primaries-2004`; their overlapping respondents
must not be treated as independent studies. The original IDs and projections
remain available for reproducing historical sample choices. The reviewed learning
sample uses confirmed attendees with observed pre/post questionnaires: 239 pairs,
of whom 238 have known discussion groups. Its 217-person historical counterpart
is an overlapping subset, not a control arm.

`analysis_survey_waves` separates `original_survey_wave`, canonical `wave` and
`wave_role`, and `wave_instance_id`. Multiple survey occasions can share a phase;
readers must choose an occasion explicitly rather than average or overwrite them.
`temporal_order` records order, not elapsed time. Interview `mode`, nullable
`date_start`/`date_end`, `timing_status`, source fields, and the report or instrument
citation are carried in the typed table. A documented pre-start design does not
assert that individual first-meeting timestamps were recovered.

California, Europolis, Denmark, Vermont and Michigan's retained arrivals now
have `availability = score_exported`. Michigan has only arrival placement items,
not its five telephone factual questions; its four-item common and six-item
arrival/exit batteries remain separate from the selected-wave nine-item battery.
`battery_scope` records these distinctions. Exported coverage does not establish
that every person completed every wave or that discussion-group IDs are known.

`analysis_phase_participants` adds `attendance_status`, `attendance_evidence`,
and nullable `sessions_attended`. The common attendance helper runs after
questionnaire presence is established. Unknown attendance becomes inferred
nonattendance only when an immediate post-deliberation (`t2`) questionnaire is
absent; missing knowledge items within a returned form and missing later (`t3`)
follow-up do not trigger this rule. Positive attendance evidence is retained
even when exit is absent. Explicit source indicators take precedence: CPL, WTU
and SWEPCO use `PART`, and Europolis uses labeled `GROUP_T1BIS`. Zeguo uses a
matched onsite POST form, so p36 and p211 are attendees despite lacking groups,
and p90 remains an attendee despite a blank knowledge battery.

Seven Cor–Sood cohorts use source attendance
flags, session records, logged participation, or observed onsite exit answers.
An online follow-up questionnaire alone does not establish attendance: 78 online
Primaries respondents attended no meetings, and 46 of those filled a post survey.
Scheduled sessions do not count as attended sessions. Other unannotated source
flags and unresolved attendance are explicitly described in the evidence field.
Sixteen additional overlapping historical/Cor source cohorts use the verified
`(poll_id, source_row)` identity bridge. Both adapters read the same retained
survey; this is not a positional join between independent deposits. The bridge
transfers known attendance without merging records or changing cohort membership.
The remaining unknown classifications stay explicit.

`analysis_phase_scores.questionnaire_presence_status` distinguishes `observed`,
`absent`, and `unknown`. Presence uses raw questionnaire answers, excluding IDs
and generated correctness flags. California has 386 observed telephone interviews
in its 396-person source cohort; the remaining ten pre-arrival questionnaires
are absent. All 396 exit questionnaires are observed, including four with blank
knowledge batteries. Blanks in an observed quiz score zero; absent questionnaires
remain missing. AMR has 46 observed interviews whose six knowledge responses are
all missing in the harmonized deposit. Other questionnaire answers establish
presence, so these scores remain zero. Because the source collapsed don't-know
and other nonanswers to missing, those records do not prove literal blank forms.
The phase extension preserves selected-wave numerical values. Separately,
source-backed response-status corrections and recovered item descriptions update
the selected-wave metadata without changing scores or samples.

The phase item table also retains Tomorrow’s Europe’s original T2 arrival
answers and New Haven’s Mid answers after the first discussion session. Their
canonical phases are `t1` and `interim_1`, respectively. Every observed-wave
score reproduces from these answers. Tomorrow’s Europe’s source records with
unknown arrival-form presence retain nullable correctness and the unknown
presence flag; they are not treated as observed wrong answers. Exposing an
intermediate questionnaire changes neither attendance nor the analytical cohort.

## Paired source attitudes

`analysis_phase_attitudes` and `analysis_phase_attitude_responses` expose all
47 reviewed America in One Room 2019 items and all 72 reviewed Climate 2021
items at pre-arrival (`t0`) and immediate exit (`t2`). They preserve all
3,842 and 8,814 source records, respectively, including controls and records
without a post questionnaire. The `source_dataset` key names the source battery;
it does not classify a person as a control or attendee. Join participant keys
to `analysis_phase_participants` for the retained arm, attendance basis and group.
The verified survey occasions remain in `analysis_survey_waves`. These tables
do not yet expose Climate's later follow-up attitudes or historical composite
indices; the existing baseline tables retain their established coverage.

Each item keeps its source column, raw numeric code, original value label when
available, fixed endpoints and source direction. Increasing values can mean
greater support, agreement, worry, importance or willingness; the table does
not turn these into a shared ideological direction. Substantive integer
responses from 0 through 10 are divided by 10. A genuine source response of
5 is 0.5; missing answers are never assigned that value.

`response_status` distinguishes `answered`, documented `non_substantive`,
`invalid_response`, `blank` within an observed questionnaire, `source_missing`
when questionnaire presence is unknown, and `absent_form` when independent
presence evidence establishes absence. Invalid and nonanswer codes remain in
`raw_value` while `value` is missing. America in One Room's five multiple-response
codes (`-8`) are invalid, and its source labels are retained. Climate's
nonanswer labels are not independently recoverable, so labels remain null.
No guessing adjustment, weights, attendance inference or group summaries are
applied. Pre-event answers never depend on the person's post-event response.

## Source-level attitudes

`analysis_source_attitude_definitions` and `analysis_source_attitude_responses`
preserve the reviewed attitude fields in four additional polls. Definitions
are specific to a source field and interview occasion. They do not assert that
similarly numbered questions across waves measure the same thing.

| Poll | Definitions | Response rows |
| --- | ---: | ---: |
| Denmark 2000 | 164 | 120,554 |
| Vermont 2007 | 243 | 182,250 |
| Marousi 2006 | 248 | 316,200 |
| America in One Room 2024 | 174 | 420,906 |
| Total | 829 | 1,039,910 |

Every source row is retained, including recruitment respondents and people
outside the selected knowledge panels. `source_id` and `source_row` identify
the physical record; `source_unit_id` preserves the original identifier for
that wave. Definitions identify its column in `source_unit_id_column`.
Canonical `source_dataset` and `respondent_id` are supplied only where the
existing source bridge establishes a match. Denmark's separate control source
has no established panel link or canonical interview occasion, so these fields
remain missing rather than asserting that its identifiers match the main survey.

Marousi uses `P_Q1_0` for telephone, `AR_CODE` for arrival and `F_CODE` for exit
source identifiers. Its canonical identity continues to follow the existing
authored row alignment. Sixteen conflicting departure identifiers remain
visible; publishing the original wave identifiers does not resolve those links.

`raw_value` and `source_response_label` preserve the source response.
`response_status` distinguishes an answer, DK, refusal, other documented
nonanswer, invalid response, blank observed form, absent form and missing source
with unknown form presence. `value` is missing for all nonanswers and invalid
responses. The 271 Marousi responses whose scale is not established remain
`unclassified_response`, with missing numeric values. Vermont's 40 out-of-range
responses remain `invalid_response`; their original codes are retained.

`unit`, `minimum` and `maximum` describe the source scale. `normalized_value`
is supplied only when a reviewed numeric scale has two fixed endpoints.
Nominal categories are not converted into an ordered scale. Vermont's
percentage responses keep a 0–100 scale, where 99 can be a genuine answer;
dollar willingness-to-pay responses keep dollars and have no invented upper
endpoint. Ratings, thermometers and monetary values are not pooled into a
common attitude index. No midpoint imputation, weights or group summaries are
applied in these tables.

## Whole questionnaires and observed peers

Questionnaire presence uses reviewed administrative indicators and the complete
question blocks, including nonknowledge answers. An observed questionnaire with
an unanswered quiz follows the knowledge rule: reviewed blanks and DK score
zero. An absent or unavailable questionnaire has missing knowledge scores and
item correctness. A questionnaire with no retained answers and no return
indicator remains of unknown presence. Attendance is a separate variable;
positive attendance evidence takes precedence over an absent exit questionnaire.

A shared source-form helper now applies these rules to CPL, UK Crime, UK Health,
UK General Election, Europolis, Tomorrow's Europe, BTP Presidential Primaries,
NIC, NIC2 and Zeguo. Australia additionally uses its explicit original attendance
and questionnaire-return classifications. Source-row joins are checked against
respondent identity within each file; equal physical row numbers in two files
are not a crosswalk.

Group and poll knowledge summaries exclude unavailable scores. Leave-one-out
peer means use the number of peers with an observed value for the relevant
item or score, removing the focal respondent only when their value is observed.
They remain missing if no peer value is observed. Peer learning opportunity
also requires the focal response; unavailable focal questionnaires do not become
zero opportunity. The reviewed zero-at-ceiling convention remains in force.
These are summaries of observed peers, with no assumption that unavailable
questionnaires contain incorrect answers. BTP General Election retains its
299-person source cohort for group calculations before exporting the selected
248-person panel; a downstream recalculation on 248 people is a different
population.
