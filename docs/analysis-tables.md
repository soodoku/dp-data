# Canonical analysis tables

`make analysis` writes six typed Parquet tables and a checksum manifest to
`output/analysis/`. `make check` rebuilds them after the knowledge, respondent,
and historical aggregate exports. Source files and reviewed metadata stay in
`data/` and `metadata/`; downstream projects use the Parquet tables.

| Table | Row unit and key | Rows |
| --- | --- | ---: |
| `analysis_polls` | One registered poll; `poll_id` | 50 |
| `analysis_poll_events` | One sourced timing statement; `poll_id`, `event_id` | 54 |
| `analysis_items` | One knowledge question; `poll_id`, `item_id` | 245 |
| `analysis_participants` | One source respondent; `poll_id`, `source_dataset`, `respondent_id` | 51,681 |
| `analysis_item_responses` | One answer; participant key, `wave`, `item_id` | 750,441 |
| `analysis_scores` | One respondent-wave score; participant key, `wave` | 95,125 |

There are respondent records for 33 polls and item responses for 31. The
participant table covers the 21 reviewed historical surveys, 23 Cor–Sood
batteries, four control studies, and the score-only Marousi file. Sixteen
historical and Cor–Sood polls overlap. `source_dataset` distinguishes their
separate person IDs; identical IDs across the deposits do not imply the same
person. The score-only Marousi and Tanzania files have no recovered person-item
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
follow-up. The participant table separates `assignment` from observed `arm`
and `attended`. Invitations were randomized in some studies, but analysis of
attendees is not an intention-to-treat estimate. `small_group_id` identifies a
discussion group when observed; `cluster_id` is the inference cluster and is a
village in Tanzania. Missing values mean the fact was not established in the
available source, not that it did not occur. `panel` identifies the reviewed
historical analysis sample or the study's available T1/T2 panel.

`analysis_scores` averages item correctness over the full fielded battery for
the three item-linked control polls and both deposited historical batteries.
Missing, skipped, and don't-know answers enter that proportion as zero; the
response table preserves their source status. Tanzania's released standardized
index and Marousi's released proportion are marked as source scores with null
item counts. Marousi's recorded zeros are retained exactly; they have not been
interpreted as item-level answers. A downstream project can choose another
scoring rule by grouping `analysis_item_responses`.

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
