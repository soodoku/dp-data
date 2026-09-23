# Deliberative Poll data

This repository is the source catalog and build system for data shared across
Deliberative Poll research projects. It separates immutable source files from
documented transformations and versioned exports.

The first release establishes provenance before changing any analysis:

- public replication deposits are stored byte-for-byte with checksums;
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

## Reproduce

```sh
make restore
make check
```

`make check` validates the Frictionless Data Package, source checksums,
metadata contracts, tests, and linting. `make inventory` is a local-only task
that rebuilds the CDD vault inventory from the untracked archive.

The five original CDD ZIP exports stay untracked at the repository root.
`make vault` verifies their byte counts and SHA-256 checksums before unpacking
them into the ignored `vault/cdd/` directory. It will stop rather than unpack
an altered or missing bundle.

## Repository roles

| Location | Role |
|---|---|
| `data/<poll_id>/` | Reviewed data and metadata for one poll |
| `evidence/benchmarks/` | Published downstream files used only for parity tests |
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
