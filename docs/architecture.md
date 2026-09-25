# Source-of-truth architecture

## Boundaries

The repository has three layers.

1. **Sources** are immutable bytes. A correction creates a new source record;
   it never overwrites the original.
2. **Canonical tables** use stable identifiers, explicit missing values, and
   typed schemas. Transformations are functions with tests and ledger entries.
3. **Outputs** are named contracts for downstream repositories. A release tag,
   file checksum, and schema version identify an export completely.

The historical merge scripts are evidence about prior decisions. Their exact
bytes are retained in Git history under the `historical-cdd-scripts` tag and in
the ignored local vault. They do not sit beside the maintained implementation
on `main`. Each replacement transformation needs a parity test that explains
any difference.

Published aggregate files live under `evidence/benchmarks/` and remain comparison
targets for the canonical transformation graph. The historical linkage build is
an explicit exception: `make linkage` reads `polardata.tab` and
`attitude-indices.tab` to preserve the established cross-archive linkage while
the source-based attitude rebuild remains pending. Multi-poll deposits
under `evidence/deposits/` must be unpacked and assigned to poll packages before
their respondent or item data can enter that graph.

## Poll research packages

Reviewed historical material is organized for people who need both data and
the record required to interpret it:

```text
data/<poll_id>/
├── manifest.csv
├── participants.csv
├── questionnaire.pdf
├── codebook.pdf
├── briefing-material.pdf
├── research-design.pdf
├── event-report.pdf
├── paper.pdf
└── original-script.R
```

The central artifact catalog records the original archive path, checksum,
artifact type, license or rights evidence, disclosure decision, and any
redaction lineage. Poll manifests are generated views of that catalog rather
than independent copies.
Published papers are linked rather than copied when redistribution rights are
unclear.

An artifact can be cataloged while remaining in `vault/`. Cataloging means we
know what it is and where it came from; it does not mean that disclosure and
rights review passed. Collection-wide material has a blank `poll_id` by
design. Unresolved poll identity is recorded in `archive_collections.csv`
instead of being silently guessed.

## Canonical tables

The target model separates entities that the wide historical file combines:

| Table | Key | Contents |
|---|---|---|
| `polls` | `poll_id` | Poll identity, place, year, topic, mode |
| `respondents` | `poll_id`, `respondent_id` | Poll-specific de-identified people |
| `items` | `poll_id`, `item_id` | Item text, construct, response scale, key |
| `responses` | `poll_id`, `respondent_id`, `wave`, `item_id` | Item responses in long form |
| `indices` | `poll_id`, `index_id` | Knowledge and attitude index definitions |
| `index_items` | `poll_id`, `index_id`, `item_id` | Versioned index membership and scoring |
| `groups` | `poll_id`, `group_id`, `session_id` | Group and session metadata |
| `memberships` | `poll_id`, `respondent_id`, `session_id`, `group_id` | Fixed or multiple membership |

Legacy numeric IDs remain aliases; they are not primary keys.

## Respondent reconstruction before aggregation

`make respondents` builds the first stage from reviewed public surveys and
versioned definitions. It does not read `polardata`, the archived derived
objects, or the existing knowledge output. `make compare-respondents` is a
separate historical comparison. Both run in `make check`.

The scope is the 21 historical `polardata` polls. The
[source contracts](../metadata/respondent_sources.csv) identify reviewed inputs
and unresolved source versions. The generated
[coverage report](../audit/respondent_coverage.csv) distinguishes source-record
coverage, built definitions, and implemented historical fields. A reviewed
source is not a claim that its respondent recodes are finished.

| New table in `output/respondent/` | Grain and interpretation |
|---|---|
| `people` | One record from a reviewed source, keyed by poll and respondent ID; retains source ID and row locator |
| `sample_memberships` | One person and named sample; `TRUE` included, `FALSE` excluded by that rule, null unresolved |
| `source_responses` | One person and reviewed input field; original numeric/text value, literal wave, response status and missing code |
| `respondent_measures` | One person and versioned definition; value and input-field counts |
| `respondent_memberships` | One documented person/session/group membership; absence does not establish control status |

These exports retain **all rows** of the reviewed sources in scope. A missing or
nonunique source ID gets a file-scoped source-row identifier, with its basis
recorded. This identifies a source record, not a resolved identity across files.
Numeric source IDs use the existing integer tolerance; the immutable source
retains their exact stored representation. A different source version needs
an explicit ID crosswalk. Never join separate polls on respondent ID alone.
`historical_respondent_id` separately records a documented historical `caseid`
alias. Monarchy uses `1000 + source_row`, as prescribed before filtering in
`uk_monarchy.R`; this does not invent an original survey ID. The comparison
requires unique aliases and exact sample-ID agreement before checking values.

The original `output/respondents.parquet` remains the selected knowledge-sample
contract. The new `people` table has a broader universe. Its response table
currently includes registered knowledge inputs for reviewed polls and the
additional inputs of implemented respondent definitions; it is not an export
of every survey column. Source files and their dictionaries retain the rest.
Response status uses both declared missing values and missing ranges. Numeric
category classification tolerates integer storage drift below 1e-8 while
`raw_numeric` retains the original number. Unknown knowledge codes stay marked
`unreviewed-code`; expanding the sample does not silently assign an answer key.
Known group assignments initially follow the reviewed knowledge contracts;
UK–EU also includes the 14 historical attendees excluded from that knowledge
sample. This is not a complete roster reconstruction for every poll.

[Measure definitions](../metadata/measure_definitions.csv) name the scoring,
missingness, denominator, source-wave and calibration policies. Their
[input dependencies](../metadata/measure_inputs.csv) name source fields.
`post_dependent` means any later-wave response enters the formula, including
scores labelled as baseline knowledge but adjusted using post responses.
An explicitly absent historical measure has a constant-missing definition;
an unimplemented measure has no fabricated values. `n_observed_fields` counts
source fields classified as answered; it is **not** a universal scoring
denominator. The scoring rule can deliberately include a non-substantive code
or score a missing knowledge answer as zero. Such historical choices remain
visible in the definitions and issue register.

[The field inventory](../metadata/polardata_fields.csv) assigns every historical
column to respondent data, identifiers, group or poll calculations, poll
metadata, or export artifacts. Aliases are conditional: Australia and UK Crime
retain distinct issue-specific knowledge measures. Use the
[poll-specific targets](../metadata/polardata_targets.csv), not a global column
rename, when producing a future wide `polardata` version. The twelve `grk.*`
columns are entirely missing in the historical benchmark; their poll is outside
this 21-poll scope, so they remain inventoried without invented poll targets.

All 21 historical polls implement their applicable respondent-field targets,
including intentional missing fields. Empirical scale limits and intermediate
storage precision preserve the historical definition. Selecting or reordering
rows cannot recalibrate an individual's score. The separate
[respondent comparison](../audit/respondent_parity.csv) checks values,
missingness and historical sample identities.

`make polardata` computes derived variables after respondent recoding. Each
poll profile specifies the historical sample for each calculation: some early
group summaries include people excluded by later export filters. It writes the
364-column wide export and the source attitude-index catalog under
`output/polardata/`. `derived_measures.parquet` records each derived value by
unique source person, legacy field and definition version. Person-level keys
are needed because peer means and normalized gains can differ within a group.
Its status column identifies missing and infinite historical results.

The wide export preserves the two copies of each of 217 Primaries respondents;
the canonical tables do not duplicate people. `X` is a regenerated export row
number, not an identity. Comparisons join on poll and historical respondent ID
and require duplicated historical records to agree in every other column.
The twelve absent Greek attitude columns remain missing.

Construction never reads the benchmark. `make compare-polardata` separately
checks all fields. Its narrowly reviewed generalized-variance exceptions require
an unchanged source matrix fingerprint and a near-singular covariance with both
values inside the diagnostic perturbation envelope. The audit distinguishes
indefinite covariances from ordinary singularity. Changes outside these checks
fail comparison; benchmark values are never copied into reconstructed outputs.

## Migration order

1. Inventory and hash the archive bundles.
2. Import public deposits in separate commits.
3. Review CDD material poll by poll for rights, disclosure, duplicates, and
   readable formats; commit only approved files.
4. Register variables and index definitions.
5. Reimplement the historical merge as typed transformations with a recode
   ledger and parity tests against `polardata`.
6. Publish a tagged, typed Parquet output.
7. Update one downstream repository at a time to pin that tag and checksum.

The cross-archive linkage now belongs to this repository. Its build, tests, and
five CSV products are maintained here under `output/linkage/`. Frozen output
checksums test parity with the former standalone implementation. Replacing the
historical aggregates with audited poll-level inputs is a subsequent change;
any differences in keys, items, missingness, or derived values must be explained.

Submodules are deliberately avoided. A downstream analysis should be
reproducible from an immutable release artifact even when this repository
continues to evolve.

### Reconstruction steps for each historical poll

1. Trace the final merge backward to the poll script, source version, and index
   definitions. Read the questionnaires and codebook before choosing recodes.
2. Establish source IDs, historical aliases, eligible samples, discussion groups,
   and any export duplication. Keep canonical people unique.
3. Rebuild individual measures from raw answers with explicit code assertions,
   missingness, denominators, wave dependencies, and calibration samples.
4. Register each historical field and its source dependencies. Preserve values
   needed by summaries computed before later recodes or sample exclusions.
5. Compare IDs, samples, missingness, and values against the historical benchmark;
   test stripped derived columns, reordered records, invalid codes, and missing
   inputs. The benchmark supplies no reconstruction values.
6. Record unresolved definitions and suspected errors in `poll-issues.md`, with
   the source evidence, affected counts, and checks needed before correction.
7. Integrate the poll into group/poll summaries and the historical export; rerun
   the full local checks and compare existing downstream outputs.

Poll implementations can proceed independently. Shared registries, exports, and
release gates are integrated centrally to avoid conflicting edits.

## Identified knowledge responses

`make respondents` also builds `output/respondent/respondent_knowledge.parquet`
from the poll sources, existing canonical item definitions and the `people`
identity table. It joins on poll and source row, asserts a unique person per
source record, and exports canonical and historical respondent IDs with each
item/wave. Anonymous battery row order is not a downstream identity contract.

`correct` preserves missingness and `response_status` preserves its meaning.
`correct_zero_filled` explicitly counts missing correctness as zero for the
existing fixed-denominator scoring convention. Consumers choose that defined
field instead of silently replacing missing responses themselves. This export
does not create new answer keys or change sample membership. It covers the
intersection of reconstructed source-person polls and existing knowledge builds.

The canonical battery is not necessarily the historical aggregate battery:
NIC, for example, has distinct eight-item and eleven-item definitions. Before
linking a new poll to an analysis, verify identities, sample and battery definition.
For dp-learning's eight T1-linked polls, every item cell matches the existing
battery; joining by historical respondent ID resolves San Mateo's changed row
order without changing any scores.
