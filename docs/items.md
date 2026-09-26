# Canonical knowledge items

[`metadata/items.csv`](../metadata/items.csv) contains one row per distinct
baseline knowledge question within a poll. The key is `(poll_id, item_id)`;
`item_id` is the lowercased baseline source column. It links the 21 historical
respondent batteries to the 23 Cor--Sood item batteries through
`historical_item_id` and `cor_item_id`. The two sets overlap within 16 polls:
170 historical entries and 177 Cor--Sood entries resolve to 224 distinct
questions in 28 polls. The same question in two *different* polls remains two
records. Wave 2 columns and accepted values remain in
[`metadata/knowledge_items.csv`](../metadata/knowledge_items.csv) and the
historical scoring functions; the catalog does not silently assume identical
wave-specific codes.

`question` is exact only when `wording_source` says `questionnaire` or
`source variable label`; other entries paraphrase archived labels or source
documents. `answer_choices` transcribes archived offered choices when
recoverable; administrative codes such as refused, skipped, and not asked are
excluded;
`correct_codes` records the scored baseline source code or accepted range;
`correct_answer` gives the readable answer. For open responses, `coding_note`
explains the scoring rule and points to its implementation. The Northern
Ireland source labels truncate several choices. Those rows contain a partial
transcription and say so in `coding_note`; their numeric keys are retained.
`source_reference` points to the poll-level file used to reconstruct the
question and choices. Scoring provenance also lives in the two battery tables
and the respondent build code.

The catalog is metadata, so downstream papers can render their item appendix
from it. The test in `tests/testthat/test-canonical-items.R` compares its two
item ID mappings with the scored baseline exports and checks every source
reference. The catalog currently covers the historical and Cor--Sood
knowledge batteries; it does not claim to inventory all attitude or later
control-poll questions. Marousi has aggregate respondent scores but no
recovered person-item responses, so it has no catalog entry here.
