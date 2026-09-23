# Deliberative Poll data

This repository is the source catalog and build system for data shared across
Deliberative Poll research projects. It separates immutable source files from
documented transformations and versioned exports.

The repository establishes provenance before changing any analysis:

- public replication deposits are stored byte-for-byte with checksums;
- all 23 Cor–Sood poll-level scored knowledge batteries are extracted and cataloged;
- the five historical CDD archive bundles are inventoried but remain in a
  local vault while files are reviewed poll by poll;
- poll names and legacy numeric identifiers map to stable `poll_id` values;
- data, questionnaires, codebooks, briefing materials, research designs,
  event reports, papers, and scripts share one artifact contract;
- every recode must have a ledger entry; and
- downstream repositories consume a tagged export and verify its checksum.

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
Vermont's ambiguous answer key. These outputs do not yet rebuild the full
attitude aggregate or the control-arm batteries.

The historical knowledge–attitude linkage is also built here with `make linkage`.
Its five CSV products and checksum manifest live in `output/linkage/`, replacing
the standalone linkage repository. It retains historical `polardata` scores and
links for now; see the [linkage contract](docs/knowledge-build.md#historical-knowledgeattitude-linkage).

Known measurement, sample, linkage, and provenance questions are collected in the
[poll-level issue register](docs/poll-issues.md). It distinguishes documented
choices from unresolved concerns and existing upstream differences; this review
preserves current scores pending instrument-level verification.

## Reproduce

```sh
make restore
make check
```

`make check` validates the Frictionless Data Package, source checksums,
metadata contracts, the survey-based build, historical linkage, item-level comparisons, tests, and linting. `make inventory` is a local-only task
that rebuilds the CDD vault inventory from the untracked archive.

The five original CDD ZIP exports stay untracked at the repository root.
`make vault` verifies their byte counts and SHA-256 checksums before unpacking
them into the ignored `vault/cdd/` directory. It will stop rather than unpack
an altered or missing bundle.

## Repository roles

| Location | Role |
|---|---|
| `data/<poll_id>/` | Reviewed data and metadata for one poll |
| `evidence/benchmarks/` | Published downstream files used only for comparisons |
| `evidence/deposits/` | Immutable public deposits awaiting poll-level extraction |
| `metadata/` | Poll registry, source catalog, aliases, recodes, export contracts |
| `datapackage.json` | Frictionless schemas for the tabular metadata |
| `R/`, `scripts/` | Validation and build code |
| `output/` | Typed Parquet products built from audited poll-level inputs |
| `vault/` | Ignored local source archive, including restricted files |

The architecture and migration order are documented in
[`docs/architecture.md`](docs/architecture.md).

`metadata/artifacts.csv` is the authoritative artifact catalog. Poll-level
`manifest.csv` files are generated from it, so descriptive metadata is not
maintained twice. A blank `poll_id` denotes a collection-wide artifact rather
than an unknown poll.

`LICENSE` covers this repository's code. Data retain the license recorded for
each input in `metadata/source_files.csv`; material without file-level rights
clearance remains in the local vault. Exact historical CDD scripts are retained
in Git history under the `historical-cdd-scripts` tag, not beside the maintained
pipeline on `main`.

The aggregate `polardata` and attitude-index files are validation targets, not
inputs to the canonical build. Canonical long tables will be assembled from
audited poll-level respondent, item, wave, group, and artifact records. Their
released form can be typed Parquet, with small dictionaries and manifests kept
as CSV for inspection and joins.

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
`polardata` or establish a respondent-level join to it. The original CDD
survey files and scripts in the local vault must be audited poll by poll
before the full aggregate is rebuilt. Published aggregates in
`evidence/benchmarks/` remain comparison targets, not build inputs.
