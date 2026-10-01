# Deliberative Poll data

This repository is the source catalog and build system for data shared across
Deliberative Poll research projects. It separates immutable source files from
documented transformations and versioned exports.

The [canonical analysis tables](docs/analysis-tables.md) provide a typed
Parquet handoff: one poll registry, one knowledge-item catalog, keyed
participant records, long item-wave answers, respondent-wave scores, and
source-linked event timing. They cover every poll with available respondent
data, including the control groups and the score-only exceptions. Downstream
projects join and filter these tables for their own analyses.

The repository establishes provenance before changing any analysis:

- public replication deposits are stored byte-for-byte with checksums;
- all 23 Cor–Sood poll-level scored knowledge batteries are extracted and cataloged;
- historical CDD archive members retain their original paths and checksums;
  unique unreviewed files remain in the local vault;
- poll names and legacy numeric identifiers map to stable `poll_id` values;
- data, questionnaires, codebooks, briefing materials, research designs,
  event reports, papers, and scripts share one artifact contract;
- scoring definitions and unresolved recoding questions are recorded; and
- downstream repositories consume a tagged export and verify its checksum.

`metadata/oos_sources.csv` locates the 24 frozen public inputs and supporting
documents used by the dp-distortions out-of-sample study. It retains original
URLs, access dates and SHA-256 hashes; shared files have one physical copy under
`data/<study>/`. Data recoding belongs in dp-data; downstream repositories
consume versioned variables and perform estimation. Existing downstream
recodes, including those in the out-of-sample study, still need migration with
explicit value comparisons; see the [migration inventory](docs/poll-evidence.md#x-11).
Poll-specific surveys and reference materials belong under `data/<poll_id>/`,
with questionnaires, codebooks, briefing materials, reports and papers in the
appropriate poll folder. `data/shared/` is reserved for genuinely cross-poll
materials. Derived typed tables belong under `output/`; original materials are
retained separately so their evidence and the transformations remain traceable.

Blank source license fields mean no license was recorded during this migration;
they do not assign the repository license to third-party materials.

Direct identifiers were found in at least one historical raw file. The archive
therefore cannot be published as an undifferentiated dump. See
[`docs/disclosure.md`](docs/disclosure.md).

The survey-based build covers all 23 knowledge batteries: 6,669 participants,
103,116 item-wave responses, and 406 known discussion groups. Five typed
Parquet tables in `output/` preserve source answers, scoring decisions and
missing values. Group membership is available for 6,147 participants.
The [build notes](docs/knowledge-build.md) describe the output contract.
The [fourteen-poll audit](docs/remaining-polls.md) explains corrected scores,
three unresolved sample-size differences, Europolis's unordered match, and
Vermont's ambiguous answer key. The unified analysis export also includes
the available control-arm item answers. Tanzania retains a released knowledge
index and nine scored components; its original raw item responses have not been
recovered. The canonical handoff remains score-only. The approved correction
treats -99 component codes as missing and rebuilds the existing standardized index.

The historical knowledge–attitude linkage is also built here with `make linkage`.
Its five CSV products and checksum manifest live in `output/linkage/`, replacing
the standalone linkage repository. It retains historical `polardata` scores and
links for now; see the [linkage contract](docs/knowledge-build.md#historical-knowledgeattitude-linkage).

Known measurement, sample, linkage, and provenance questions are collected in the
[poll-level issue register](docs/poll-issues.md). It distinguishes documented
choices from unresolved concerns and existing upstream differences; this review
preserves scores until instrument-level verification and poll-specific approval.

`make respondents` reconstructs all 848 historical respondent-field targets
across 21 polls. It retains every reviewed source record, separates named
samples from people, and records versioned recodes and their raw inputs.
It also exports `output/respondent/historical_knowledge_items.parquet`, with
respondent-linked item correctness at both scoring waves for all 21 polls.
The item means reproduce the corresponding reviewed respondent scores. Marousi
is outside this 21-poll reconstruction; its separately retained original survey
and authored correctness flags support the phase scores and raw seven-item
responses in `analysis_phase_item_responses.parquet`, described in the issue register.
The respondent export also includes `output/respondent/briefing_reading.parquet`:
source-linked reading reports in nine polls, including five whose historical
`readbrief` column was left missing even though the retained survey contains
the response. The export preserves the raw survey code and a documented
zero-to-one ordinal score.
`make polardata` then computes group and poll summaries and exports the full
5,869-row, 364-column export under `output/polardata/`, together
with the 129-row attitude-index catalog and a typed derived-measure table.
Tomorrow's Europe also has explicit pre-arrival-to-exit and arrival-to-exit
pairs in `output/polardata/attitude_contrasts.parquet`.

`make analysis` also exports source-level attitudes for Denmark, Vermont,
Marousi, California and America in One Room 2024: 907 definitions and 1,076,726 response
rows, including recruitment and other source records outside the selected
analysis panels. Raw codes, labels, source identities, interview phases and
units remain available alongside valid numeric values. Percentage and dollar
questions keep their units; unknown scales are not guessed. See the
[analysis-table contract](docs/analysis-tables.md#source-level-attitudes).

`make weights` preserves the 16 supplied weight columns from ten polls under
`output/weights/`. Definitions retain source provenance and documented scope;
values retain every source row, including missing and zero weights. These tables
preserve available weights without deciding how analyses should use them.

`make tanzania-attitudes` exports the 22 reviewed policy questions and their
source responses under `output/tanzania_attitudes/`. The tables preserve raw
answers, five-category borrowing responses, discussion-round assignments and
verified pre-arrival/follow-up timing. Citizen responses receive the documented
zero-to-one scales; elite and moderator source rows remain available without
applying the citizen coding or interview phases.

The frozen historical benchmark contains two copies of each of 217 Primaries
people; the maintained wide export and canonical tables retain one record per
person. Two BTP General Election respondents with observed, entirely incorrect
exit quizzes are restored under the approved questionnaire-presence rule.

The build reads public poll sources, not frozen aggregates or the vault.
`make compare-respondents` and `make compare-polardata` separately test against
historical benchmarks. Documented numerical exceptions concern generalized
variance in 23 groups; the comparison checks the exact source matrices and
numerical diagnostics before accepting those differences. Export row numbers
are regenerated. The approved UK Crime correction replaces a baseline police
item with the post-wave children item. UK Election 1997 now uses the post-wave
Labour minimum-wage placement in post knowledge and its dependent measures.
NIC 1996 age now uses `96 - BYEAR`, and its event mode is in person; raw
birth-year anomalies remain recorded for separate review.
Comparisons verify each approved value
against the reviewed respondent-level evidence and reject unexplained changes.
See the [parity report](audit/polardata_parity.csv),
[covariance audit](audit/polardata_covariances.csv), and
[poll issue register](docs/poll-issues.md) for details.

Other historical coding choices are preserved for later review. The canonical
analysis tables keep overlapping source batteries distinct through
`source_dataset`, so downstream projects can select the reviewed source they
need without implying respondent links that the data do not establish.

## Reproduce

```sh
make restore
make check
```

`make check` validates the Frictionless Data Package, source checksums,
metadata contracts, the survey-based build, historical linkage, item-level
comparisons, respondent and full aggregate reconstruction, tests, and linting.
The original CDD inventory in `audit/cdd_archive_files.csv` preserves every
archive member's original path and hash. Its `retained_path` points to the
surviving copy after deduplication, either under `data/` or in the local vault.
Migration-only import and survey-review commands verify that copy's checksum.
The unpacking and inventory-rebuilding commands have been retired; normal builds
read the registered poll inputs under `data/` and need no archive extraction.
Original bundle checksums remain in `metadata/source_bundles.csv` as provenance.
The disclosure scan, survey import, archive comparison, and downstream source
audit are also migration tools; they can be retired as their source-review work
is completed.

Northern Ireland's paper can run from the public source tree: it uses the complete original
survey, headerless group roster, and `argument-codes.parquet` under
`data/northern-ireland-2007/`. Coder labels retain all response slots and missing
values; adjudication and scoring remain in dp-nireland. The survey retains all 80 original argument-text fields; the separate coding
extract contains coder labels. Original source hashes are recorded in the
artifact catalog.

## Repository roles

| Location | Role |
|---|---|
| `data/<poll_id>/` | Reviewed data and metadata for one poll |
| `evidence/benchmarks/` | Frozen published aggregates for comparisons and historical linkage |
| `evidence/deposits/` | Immutable public deposits awaiting poll-level extraction |
| `metadata/` | Poll registry, source catalog, aliases, recodes, export contracts |
| `metadata/items.csv` | Canonical knowledge-question catalog for the historical, Cor--Sood, and control-poll batteries; see [item catalog guide](docs/items.md) |
| `datapackage.json` | Frictionless schemas for the tabular metadata |
| `R/` | Shared recoding, poll-specific definitions, validation and export functions |
| `scripts/` | Named build and comparison entry points used by the Makefile |
| `output/` | Typed Parquet products built from audited poll-level inputs |
| `vault/` | Local originals awaiting source-version review or poll-folder preservation |

Flat metadata registries remain CSV and are validated against the JSON schemas
in `datapackage.json`. Nested poll metadata is generated as JSON from those
registries. Analysis products use typed Parquet; `metadata/canonical_columns.csv`
defines each field’s type, nullability, key membership and meaning. Audit cell
comparisons with many repeated rows can also use Parquet, with their keys and
value semantics documented in the poll issue ledger.

R modules define functions; build scripts load them through `load_project()`
and call the relevant producer. Common readers and arithmetic belong in the
shared recoding module. Poll modules retain their source columns, answer keys,
missing codes and precision rules. Knowledge and attitude recoding have separate
semantics. Group and poll summaries are calculated after respondent measures.

The architecture and migration order are documented in
[`docs/architecture.md`](docs/architecture.md).

`metadata/artifacts.csv` is the authoritative artifact catalog. Poll-level
`manifest.csv` files are generated from it, so descriptive metadata is not
maintained twice. A blank `poll_id` denotes a collection-wide artifact rather
than an unknown poll. Source materials live in the relevant poll's
`questionnaires/`, `codebooks/`, `briefing-materials/`, `papers/`, `reports/`, or
`design/` directory. Cross-poll references and definition versions with distinct coding evidence
have one copy under `data/shared/`; poll manifests point to that same file.
Original archive paths, download URLs, checksums, and comparison limitations are
recorded in the central catalog. Redundant copies and superseded drafts are removed after comparing their
contents, including comments and coding notes. Git retains removed versions.
Documents tied to one event live in its own folder. Entries whose `collection`
is `materials-only` identify reference materials without claiming that respondent
data or an aggregate build is available.

Each poll folder also contains generated `metadata.json`: the historical catalog
entry, sourced event facts, references, material coverage, and links to local
originals and PDF previews. `metadata/poll_facts.csv` retains conflicting claims
with source locators; it does not revise historical identifiers or scoring.
`metadata/poll_references.csv` distinguishes research papers from press releases,
event reports, instruments, and briefing materials. Coverage in
`metadata/poll_material_coverage.csv` records what was located and what remains
missing among the sources checked. Run `make manifests` to refresh these views.

Office documents retain their originals alongside PDF previews registered in
`metadata/document_previews.csv`. Preview generation requires LibreOffice,
Poppler (`pdfinfo` and `pdftotext`), and `openpyxl` for workbooks. Install the Python
dependency in your environment with `python3 -m pip install openpyxl`, then run
`make previews`. The converter adjusts print layout in temporary workbook copies.
It checks registered hashes and skips unchanged pairs; ordinary `make check`
validates existing previews without regenerating PDFs. Preview conversion is for
reading source documentation and does not feed numerical builds.

`LICENSE` covers this repository's code. Data retain the license recorded for
each input in `metadata/source_files.csv`. Reference materials retain their
source copyrights; `NOASSERTION` means no redistribution license has been
established, not that the material is covered by the repository license.
Original files with contact fields and unique sources awaiting review remain in
the local vault. Exact historical CDD scripts are retained
in Git history under the `historical-cdd-scripts` tag, not beside the maintained
pipeline on `main`.

The frozen aggregate `polardata` and attitude-index files are validation targets.
The current aggregates are rebuilt from poll-level sources with approved
corrections. Canonical respondent, item, wave, group, and score tables are
released as typed Parquet. Small flat dictionaries and manifests remain CSV
for inspection and joins; nested poll metadata uses JSON. Schema definitions
validate types, required values, and keys before writing the Parquet files.

## Cor–Sood knowledge batteries

The 23 files in `data/<poll_id>/knowledge-battery.csv` are exact bytes from
`replication/data.zip` inside the [public Cor–Sood Dataverse deposit](https://doi.org/10.7910/DVN/HZHVCU).
`metadata/knowledge_batteries.csv` records the original ZIP member, paired
pre/post item columns, respondent and item counts, and linkage status. For
some polls the post-deliberation columns are named `t3`; the column map
preserves those names rather than relabeling the actual survey wave.

These files contain scored 0/1 item responses and `female`, but no original
answer choices, respondent IDs, group assignments, or attitudes. A row number
is only an index within that deposited CSV. The files can reproduce the
knowledge-battery analysis; they cannot by themselves regenerate
`polardata` or establish a respondent-level join to it. The retained poll-level
survey files and original coding evidence supply that linkage; the issue
register records remaining source gaps. Published aggregates in
`evidence/benchmarks/` remain comparison targets for the canonical build and
explicit inputs to the historical linkage build.

The canonical item table supplies `question_display`, `answer_choices_display`, and
`correct_answer_display` for publications. These normalize all-capital source labels
to sentence case, with reviewed proper names and abbreviation expansions; original
text and scoring codes remain in their existing fields.
