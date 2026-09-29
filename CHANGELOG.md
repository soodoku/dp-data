# Changelog

## Unreleased

- Retain AMR's original questionnaire, expert answer key, codebooks and paper;
  preserve its verified pre-invitation and post-deliberation measurements in
  phase tables without changing scores or samples. Document the conflicting
  questionnaire options and country-specific weighting requirements.
- Label documented nonanswers in A1R 2019, Northern Ireland's follow-up and six
  climate knowledge items as non-substantive, preserving their zero scores.
  Retain original climate and Tanzania replication scripts as coding evidence.

- Apply the poll-specific corrections documented in `docs/poll-issues.md`, with
  unchanged source answers and independently checked correction values. The
  issue register distinguishes adopted changes, retained definitions, proposed
  corrections and unavailable source evidence; the audit is not yet closed.
- Export 5,869 unique historical poll/person records, removing duplicate
  Primaries rows and retaining two BTP General Election respondents with
  observed exit questionnaires but no correct knowledge answers.
- Use empirical participant medians for high/low education and income, with
  fixed reference populations and the same individual flags in group summaries.
- Calculate female shares among observed peers with a common denominator,
  including respondents whose own gender is missing.
- Put UK Health severity preferences on a fixed scale across waves and rebuild
  individual extremity and group summaries from the corrected indices.
- Derive UK Health degree attainment from its explicit qualification question
  instead of treating A-level school qualifications as a degree.
- Preserve verified survey phases, questionnaire presence, recruitment frames,
  controls and follow-ups in typed Parquet. Add arrival scores for California,
  Europolis, Denmark, Vermont and Michigan, keeping their different batteries
  separate, and publish a typed phase item-response table.
- Identify climate-study completers as completed; distinguish other invitees
  from people known not to have attended.
- Retain the UK Health index memorandum with a PDF preview. Remove the misfiled
  Europolis questionnaire duplicate after checking its content against the
  existing Tomorrow's Europe original and PDF.

## 0.3.0

- Reconstruct all 848 respondent-field targets across the 21 historical polls
  from public poll-level sources, preserving historical recodes and sample stages.
- Build the full 6,084-row, 364-column `polardata` schema and 129-row attitude
  catalog without the vault or frozen aggregates. Export derived measures
  separately with versioned definitions and explicit nonfinite-value status.
- Retain unique people in canonical tables and the historical duplicate
  Primaries rows in the wide export. Regenerate export row numbers.
- Audit 288 generalized-variance differences in 24 groups using unchanged
  source matrices and numerical diagnostics. Preserve historical formulas;
  record coding, source-vintage and covariance concerns for later correction.
- Preserve all existing knowledge, linkage and partial UK Health outputs.
  Downstream input pins remain unchanged.

## 0.2.3

- Centralize all 24 unchanged inputs and supporting documents for the
  dp-distortions out-of-sample study, reusing four existing files. Preserve
  original URLs, access dates and checksums in `metadata/oos_sources.csv`.
- Record the historical benchmark contracts for dp-distortions and dp-deliberately.
- Preserve existing poll recodes, source bytes and analysis outputs.

## 0.2.2

- Publish Northern Ireland argument coder labels without verbatim responses,
  completing the public inputs needed by dp-nireland. Preserve original labels
  and leave paper-specific adjudication and scoring downstream.
- Retain the existing numeric survey and group roster unchanged.

## 0.2.1

- Make the provenance test create its own Git fixture so `make check` also runs
  from a downloaded source archive. Data and recoding behavior are unchanged.

## 0.2.0

- Add a respondent layer retaining 24,361 source records from 16 reviewed polls,
  with original IDs, historical ID aliases, explicit samples and source responses.
- Reconstruct all 308 historical respondent-field targets for eight of the 21
  polardata polls. Preserve historical scoring and document concerns for review.
- Rebuild 71 UK Health respondent and group-summary fields from survey answers.
- Catalog 158 distinct reference files, with material links for all 34 registered
  polls. Preserve document versions and original bytes; share identical copies.
- Remove 329 redundant local vault files and retire the unpacking and inventory
  bootstrap commands. Record surviving copies in the original archive inventory.
- Preserve the 14 existing knowledge and linkage output files byte-for-byte.

Full polardata reconstruction, remaining respondent recodes, later group/poll
measures, and substantive corrections remain unfinished. This release does not
replace downstream historical polardata inputs.

## 0.1.0

- Establish the source catalog, stable poll registry, disclosure gate, and
  downstream export contracts.
- Add immutable public inputs used by `dp-learning`.
- Record checksums for the historical CDD archive bundles without publishing
  unreviewed respondent files.
