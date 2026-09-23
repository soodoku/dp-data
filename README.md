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

## Repository roles

| Location | Role |
|---|---|
| `sources/public/` | Immutable, licensed public inputs |
| `polls/<poll_id>/` | Reviewed poll packages organized by artifact role |
| `metadata/` | Poll registry, source catalog, aliases, recodes, export contracts |
| `datapackage.json` | Frictionless schemas for the tabular metadata |
| `legacy/` | Preserved historical build code, added after source audit |
| `R/`, `scripts/` | Validation and build code |
| `exports/` | Generated, versioned downstream products |
| `vault/` | Ignored local source archive, including restricted files |

The architecture and migration order are documented in
[`docs/architecture.md`](docs/architecture.md).

`metadata/artifacts.csv` is the authoritative artifact catalog. Poll-level
`manifest.csv` files are generated from it, so descriptive metadata is not
maintained twice. A blank `poll_id` denotes a collection-wide artifact rather
than an unknown poll.
