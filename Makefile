R = Rscript

.PHONY: tanzania-attitudes weights previews compare-polardata compare-respondents respondents polardata analysis linkage restore package manifests disclosure validate test lint check import-surveys knowledge audit-surveys audit-downstream

restore:
	$(R) -e 'renv::restore(prompt = FALSE)'

package:
	$(R) scripts/build_datapackage.R

manifests:
	$(R) scripts/build_poll_manifests.R

disclosure:
	$(R) scripts/scan_disclosure.R

validate:
	$(R) scripts/validate.R

test:
	$(R) -e 'testthat::test_dir("tests/testthat", reporter = "summary")'
	python3 -m unittest discover -s tests -p 'test_*.py'

lint:
	$(R) -e 'results <- lintr::lint_dir("."); print(results); quit(status = length(results) > 0L)'

import-surveys:
	$(R) scripts/import_surveys.R

audit-surveys:
	$(R) scripts/validate_archive_surveys.R

knowledge:
	$(R) scripts/build_knowledge.R

linkage:
	$(R) scripts/build_linkage.R
	$(R) scripts/render_linkage.R

polardata:
	$(R) scripts/build_polardata.R

compare-polardata:
	$(R) scripts/compare_polardata.R

respondents:
	$(R) scripts/build_respondents.R

analysis:
	$(R) scripts/build_analysis_tables.R

weights:
	$(R) scripts/build_weights.R

tanzania-attitudes:
	$(R) scripts/build_tanzania_attitudes.R

compare-respondents:
	$(R) scripts/compare_respondents.R

check: package manifests validate knowledge linkage polardata compare-polardata respondents analysis weights tanzania-attitudes compare-respondents test lint

audit-downstream:
	$(R) scripts/audit_downstream_sources.R

previews:
	python3 scripts/build_document_previews.py --report /tmp/dp-document-previews.json
