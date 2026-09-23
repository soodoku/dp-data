R = Rscript

.PHONY: linkage restore package manifests vault inventory disclosure validate test lint check import-surveys knowledge audit-surveys audit-downstream

restore:
	$(R) -e 'renv::restore(prompt = FALSE)'

package:
	$(R) scripts/02_build_datapackage.R

manifests:
	$(R) scripts/05_build_poll_manifests.R

vault:
	$(R) scripts/00_unpack_vault.R

inventory:
	$(R) scripts/01_build_archive_inventory.R

disclosure:
	$(R) scripts/04_scan_disclosure.R

validate:
	$(R) scripts/03_validate.R

test:
	$(R) -e 'testthat::test_dir("tests/testthat", reporter = "summary")'

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

check: package manifests validate knowledge linkage test lint

audit-downstream:
	$(R) scripts/09_audit_downstream_sources.R
