# Changelog

## Unreleased

- Use Tanzania's original household identifiers consistently across canonical
  knowledge, attitude and weight tables. Preserve physical source rows, all
  scores and samples, and the IDs in frozen historical comparisons.
- Identify code 98 as an unclassified nonanswer for four Climate baseline/exit
  knowledge fields using reproduced report means and nonanswer percentages.
  Raw answers, scores, samples and follow-up classifications are unchanged.
- Preserve Tanzania's original peer-analysis script and document its 370-person
  eligible cohort separately from the 371 source roster records. Establish the
  deposited general-knowledge index's actual components without adopting it as
  education or changing current numerical outputs.
- Document Marousi's mayor-performance scale gap using five source versions
  and the retained questionnaire; preserve all 271 raw responses.

## 0.4.2

- Restore Northern Ireland's literal argument-coder labels. CSV type inference
  had collapsed 176 comma-separated code sets; source whitespace is also retained.
  Respondent identities, missing slots and all knowledge outputs are unchanged.
- Preserve Denmark's four original questionnaires and readable PDF companions;
  record the later follow-up's verified telephone mode without changing dates,
  scores or cohorts. Preserve its wave crosswalk, two California index drafts
  and Northern Ireland's version 16 coding guide in their poll folders.
- Allow the full CI build and numerical audit up to 60 minutes. The previous
  30-minute limit canceled a run after tests and lint passed, before its final
  metadata verification could finish.

- Use reviewed whole-questionnaire evidence in knowledge scoring. Preserve
  observed blank quizzes as zero; unavailable questionnaires have missing scores.
- Retain verified attendance before inferring nonattendance from absent exits,
  including Australia's nine attendees without exit questionnaires and two
  UK Health attendees without completed post-event questionnaires.
- Preserve Australia's original combined DP codebook and its readable PDF,
  distinguishing it from the separate constitutional-referendum codebook.
- Export 829 source-level attitude definitions and 1,039,910 response rows for
  Denmark, Vermont, Marousi and America in One Room 2024. Retain all source
  people, original identifiers, labels, units and documented interview phases.
- Exclude 372 reviewed attitude nonanswers and 40 invalid Vermont responses
  from numeric values. Preserve 271 Marousi responses with unverified scales
  as unclassified raw responses, with missing numeric values.
- Preserve Marousi's original identifiers separately for telephone, arrival
  and exit while retaining the authored row bridge and its 16 unresolved
  departure-ID conflicts.
- Apply reviewed full-form masks across ten polls and calculate group knowledge
  means and learning opportunity from observed peers. Preserve BTP General
  Election's 299-person group cohort before its 248-person analytical selection.

- Declare complete questionnaire-presence dependencies and use registered source
  column order. Individual recodes support reordered inputs and local subsets
  without changing reviewed values or weakening production identity checks.

- Retain 2,299,630 additional raw questionnaire responses used by the presence
  rules; every existing raw response and reviewed measure value is unchanged.

- Apply 152 codebook-backed CPL nonanswer declarations through a shared
  field-specific registry. Preserve substantive Other codes and dollar amounts;
  raw values and reviewed scores remain unchanged.

## 0.4.1

- Preserve additional poll source versions and 13 unique historical scripts as
  coding evidence, with source dictionaries and readable document companions.
- Retain Denmark's dated later follow-up in the typed wave catalog without
  treating it as an exit interview or scoring it before its keys are reviewed.
- Preserve three additional supplied weight columns from archived BTP Health
  sources, with source identities and undecided analytical use.
- Render wide inventory workbooks across pages at a readable scale, repeating
  study names and headers while preserving original cells and formulas.

## 0.4.0

- Reconcile observed-questionnaire presence across source copies, preserve
  known attendance, and treat UK–EU group99 as unknown membership. Retain
  New Haven's absent exit form and BTP National's explicit nonattendance.
- Preserve both authored Zeguo township-image definitions with distinct names.
- Retain original Bulgaria Crime sources, Australia attendance evidence,
  Europolis's master questionnaire, and a typed New Haven recruitment crosswalk.

- Include Tanzania's borrowing question using its five documented categories,
  and export all 22 policy items with source answers, normalized citizen values,
  discussion-round assignments and verified baseline/follow-up phases. Preserve
  the other 21 items and retain noncitizen source rows without applying citizen
  scales or timing.

- Preserve all 13 supplied weight columns across nine polls in typed tables,
  including source identities, missing values and zero weights. Analytical use
  remains undecided; existing selected analysis weights are unchanged.
- Compare Tomorrow's Europe pre-arrival attitudes with exit in the seven main
  indices, and retain arrival-to-exit definitions in a typed contrast catalog.
  Respondent scores and samples are unchanged.
- Reproduce all 93 climate-report rating means at both waves and their changes,
  documenting its paired-item samples and supplied weights.

- Expose approved within-poll education and income median flags as nullable
  booleans in analysis participant tables. Preserve fixed reference cohorts and
  identify legacy education proxies as source-specific.
- Exclude absent selected interviews from paired panels while retaining people
  and observed waves: 43 Primaries follow-ups, ten California baselines and
  243 Northern Ireland follow-up-only records.

- Define peer learning opportunity as zero at full knowledge through one shared
  rule. This changes 315 derived cells for 107 people across 12 polls; absent
  interviews remain missing. Typed names now describe opportunity and identify
  the exclusion of the focal respondent.
- Treat Tanzania's -99 first-component codes as missing and rebuild the existing
  baseline-control standardized index. Preserve all observed scores and correct
  the one follow-up-only panel flag.

- Order UK Health government/public and doctor-input responses consistently:
  none = 0, some = 0.5, all/most = 1. Recalculate dependent attitude summaries
  without changing participants, knowledge scores or missingness.

- Correct Australia's peer-knowledge denominator from 11 to the 12 scored
  questions. All 347 participants and their individual knowledge scores remain
  unchanged; 346 peer measures and their logs change.

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
