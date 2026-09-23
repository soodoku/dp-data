R = Rscript

.PHONY: restore package inventory validate test lint check

restore:
	$(R) -e 'renv::restore(prompt = FALSE)'

package:
	$(R) scripts/02_build_datapackage.R

inventory:
	$(R) scripts/01_build_archive_inventory.R

validate:
	$(R) scripts/03_validate.R

test:
	$(R) -e 'testthat::test_dir("tests/testthat", reporter = "summary")'

lint:
	$(R) -e 'results <- lintr::lint_dir("."); print(results); quit(status = length(results) > 0L)'

check: package validate test lint
