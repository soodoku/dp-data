R = Rscript

.PHONY: restore package manifests vault inventory disclosure validate test lint check

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

check: package manifests validate test lint
