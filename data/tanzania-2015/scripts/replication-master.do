set more off, perm
version 12
clear
set type double

*** Set root to your local directory 
	global root 	"/Users/Justin/Dropbox/TZ_Resource_Revenues/Poll/Dataverse"
	global do		"$root/do"
	global dta 		"$root/dta"
	global floats 	"$root/output/floats"

*** Cleaning files: not included in replication files as they contain PII
/*
	do "$dofiles/01 clean moderators.do"
	do "$dofiles/02 clean elites.do"
	do "$dofiles/03 clean baseline.do"
	do "$dofiles/04 consumption predictors.do"
	do "$dofiles/05 consumption model using NPS.do"
	do "$dofiles/06 clean panel.do"
	do "$dofiles/99 Anonymize for dataverse.do"
*/

*** Auxiliary programs
	do "$do/X widetable.do"
	do "$do/X graph colors.do"

*** Main estimates
	do "$do/11 regressions.do"		// Calls "X fdr_sharpened_qvalues.do"
	do "$do/12 sub-hypotheses.do"
	do "$do/13 elite regs.do"

exit
