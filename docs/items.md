# Canonical knowledge items

[`metadata/items.csv`](../metadata/items.csv) contains one row per distinct
baseline knowledge question within a poll. The key is `(poll_id, item_id)`;
`item_id` uses the standardized `knowledge_001` prefix within each poll.
`source_column_t1` preserves the original baseline field. The catalog links the 21 historical
respondent batteries to the 23 Cor--Sood item batteries through
`historical_item_id` and `cor_item_id`. The two sets overlap within 16 polls:
170 historical entries and 177 Cor--Sood entries resolve to 224 distinct
questions in 28 polls. The catalog also includes 21 questions from three
additional control polls, for 245 questions in 31 polls altogether. Northern
Ireland's T3 participant and control answers map to its existing seven item IDs.
The same question in
two *different* polls remains two records. Wave 2 columns and accepted values remain in
[`metadata/knowledge_items.csv`](../metadata/knowledge_items.csv) and the
historical scoring functions; the catalog does not silently assume identical
wave-specific codes. Four Zeguo questions have distinct historical post-wave
IDs in `historical_item_id_t2`; the other historical items use their baseline
ID at both waves. The typed downstream copy is
`output/analysis/analysis_items.parquet`.

`question` is exact only when `wording_source` says `questionnaire`,
`verbatim codebook`, or `source variable label`; other entries paraphrase
archived labels or source documents. `answer_choices` transcribes archived
offered choices when
recoverable; administrative codes such as refused, skipped, and not asked are
excluded;
`correct_codes` records the scored baseline source code or accepted range;
`correct_answer` gives the readable answer when recovered. The retained climate
and antimicrobial-resistance reports list the questions but not the offered
choice labels or keyed answer text. Those entries retain the scored code,
mark the unavailable text, and explain the gap in `coding_note`. For open
responses, `coding_note`
explains the scoring rule and points to its implementation. The Northern
Ireland source labels truncate several choices. Those rows contain a partial
transcription and say so in `coding_note`; their numeric keys are retained.
`source_reference` points to the poll-level file used to reconstruct the
question and choices. Scoring provenance also lives in the two battery tables
and the respondent build code.

The catalog is metadata, so downstream papers can render their item appendix
from it. The test in `tests/testthat/test-canonical-items.R` compares its two
item ID mappings with the scored baseline exports and checks every source
reference. The catalog covers the historical, Cor--Sood, and three later
control-poll knowledge batteries; it does not inventory attitude questions.
Marousi and the Tanzania control study have no recovered person-item responses
in the files used for this analysis, so they have no catalog entries here.
