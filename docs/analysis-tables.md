# Canonical analysis tables

`make analysis` writes six typed Parquet tables and a checksum manifest to
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

There are respondent records for 33 polls and item responses for 31. The
participant table covers the 21 reviewed historical surveys, 23 Cor–Sood
batteries, five control studies, and the score-only Marousi file. Sixteen
historical and Cor–Sood polls overlap. `source_dataset` distinguishes their
separate person IDs; identical IDs across the deposits do not imply the same
person. Northern Ireland is a verified exception: its Cor–Sood T1/T2 battery
and the T3 survey use the same `cserial` respondent ID for 93 returning
participants. The score-only Marousi and Tanzania files have no recovered person-item
answers in this export.

`item_id` uses `knowledge_001`, `knowledge_002`, and so on within each poll.
The original baseline source field is `source_column_t1`; historical and
Cor–Sood battery IDs have their own columns. Four Zeguo questions use a
different historical post-wave ID, recorded in `historical_item_id_t2`.
The item-response table maps each source battery to the canonical ID, retaining
`source_column`, numeric or text answer where available, scored correctness,
and response status. The historical scored export lacks its raw answer in this
table; its source fields remain in `output/respondent/source_responses.parquet`.
Its `n_observed` is null because the scored export does not establish which
answers were observed.
The 2019 America in One Room codebook supplies offered choices and keyed answer
text. The retained climate and antimicrobial-resistance reports do not supply
choice labels or readable keyed answers; these are marked missing in the item
catalog, while their scoring codes are preserved.

`wave` is `t1` for baseline, `t2` for immediate follow-up, and `t3` for a later
follow-up in the existing export. This selected-pre/post convention is not
yet a uniform event-phase contract: Marousi's current `t1` is a telephone
pre-arrival score. The agreed replacement uses `t0` for pre-arrival, `t1`
for arrival/start, `t2` for immediate post-deliberation, and `t3`/`t4` for
successive later follow-ups. Original source labels, interview mode,
questionnaire instance and dates/elapsed times remain separate metadata.
See [X-02 and the Marousi bridge](poll-issues.md) for the mapping and migration
requirements. No existing score is renumbered by that investigation.

Readers must select a baseline/outcome pair explicitly. The current desired
dp-learning comparison is arrival-to-exit (`t1` to `t2`); pre-arrival-to-exit
(`t0` to `t2`) is a separate comparison, never an implicit fallback. The source
universe must retain available pre-arrival responses from nonattendees and
people without a group; analysis views select attendees, observed wave pairs
or known memberships as needed. This preserves evidence for selection and
attrition comparisons.

The participant table separates `assignment` from observed `arm`
and `attended`. Invitations were randomized in some studies, but analysis of
attendees is not an intention-to-treat estimate. `small_group_id` identifies a
discussion group when observed; `cluster_id` is the inference cluster and is a
village in Tanzania. Missing values mean the fact was not established in the
available source, not that it did not occur. `panel` identifies the reviewed
historical analysis sample or the study's available T1/T2 panel.
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
The covariate build preserves every participant key and does not impose a
complete-case sample; downstream analyses select the variables they need.

`analysis_scores` averages item correctness over the full fielded battery for
the four item-linked control polls and both deposited historical batteries.
Missing, skipped, and don't-know answers enter that proportion as zero; the
response table preserves their source status. Tanzania's released standardized
index and Marousi's released proportion are marked as source scores with null
item counts. Marousi's recorded zeros are retained exactly; they have not been
interpreted as item-level answers. A downstream project can choose another
scoring rule by grouping `analysis_item_responses`.
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
No missing answer is assigned the scale midpoint.

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
