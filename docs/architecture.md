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
