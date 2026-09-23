# Historical aggregate lineage

The archived build is a coherent sequence created for a different purpose. It
is preserved as evidence rather than treated as disposable code.

1. `01_gaurav.R` loads poll-level R objects and binds shared variables.
2. `02_nuri.R` harmonizes the second collection of polls and creates group
   summaries.
3. `03_data.R` joins both collections, derives common variables, and applies
   several poll-specific corrections.
4. `04_kyu.R` inserts attitude indices from poll-specific objects into a wide
   aggregate data frame.
5. `05_fix_data.R` standardizes selected indices, removes Greece and specified
   empirical-premise items, assigns display names, and creates `dpnum`.
6. `06_add_more_vars.R` adds poll-specific education and income indicators.

The sequence produces `polardata.csv`. The CDD copy, the Distortions deposit,
and the copies used by `dp-learning` and `dp-knowledge-linkage` have identical
tables after parsing: 6,084 rows, 364 columns, and equal values. Their byte
hashes differ because CSV and TSV serialization differs.

The replacement pipeline will retain the substantive decisions until each is
audited. The main engineering risks are implicit object loading, absolute
working directories, in-place overwrites, positional column assignment, and
recode decisions that exist only in comments.

