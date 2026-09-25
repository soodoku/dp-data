R = Rscript

.PHONY: previews compare-polardata compare-respondents respondents polardata linkage restore package manifests disclosure validate test lint check import-surveys knowledge audit-surveys audit-downstream

restore:
	$(R) -e 'renv::restore(prompt = FALSE)'

package:
	$(R) scripts/02_build_datapackage.R

manifests:
	$(R) scripts/05_build_poll_manifests.R

disclosure:
	$(R) scripts/04_scan_disclosure.R

validate:
	$(R) scripts/03_validate.R

test:
	$(R) -e 'testthat::test_dir("tests/testthat", reporter = "summary")'
	python3 -m unittest discover -s tests -p 'test_*.py'

lint:
	$(R) -e 'results <- lintr::lint_dir("."); print(results); quit(status = length(results) > 0L)'

import-surveys:
	$(R) scripts/06_import_surveys.R

audit-surveys:
	$(R) scripts/08_validate_archive_surveys.R

knowledge:
	$(R) scripts/07_build_knowledge.R

linkage:
	$(R) scripts/10_build_linkage.R
	$(R) scripts/11_render_linkage.R

polardata:
	$(R) scripts/12_build_polardata.R

compare-polardata:
	$(R) scripts/15_compare_polardata.R

respondents:
	$(R) scripts/13_build_respondents.R

compare-respondents:
	$(R) scripts/14_compare_respondents.R

check: package manifests validate knowledge linkage polardata compare-polardata respondents compare-respondents test lint

audit-downstream:
	$(R) scripts/09_audit_downstream_sources.R

previews:
	python3 scripts/16_build_document_previews.py --report /tmp/dp-document-previews.json
