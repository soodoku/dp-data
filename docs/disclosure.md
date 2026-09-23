# Disclosure review

The archive is not uniformly de-identified. For example,
`data/new_haven/data/NH_Data_pre-mid-post.csv` contains respondent names,
street addresses, ZIP codes, comments, and telephone numbers. That file stays
in the ignored local vault.

Every historical file receives one of these statuses before publication:

- `approved_public`: rights and disclosure review passed;
- `approved_redacted`: a deterministic redaction is documented and the raw
  file remains in the vault;
- `vault_only`: the file contains direct identifiers or lacks publication
  authority; or
- `review_required`: no publication decision has been made.

Automated searches for identifier-like column names are triage, not clearance.
A human must inspect flagged variables, free text, geographic detail, embedded
documents, and the source agreement. The SHA-256 of every vault file preserves
lineage even when its bytes cannot be public.

