
use "$dta/panel_anonymized.dta", clear
	
*** Hetero effects graph
/*
	set scheme plotplain
	twoway	(histogram consump, yaxis(2) lcolor(gs8) fcolor(none))								///
			(lpolyci H311 consump if zinfo==0, yaxis(1) bw(1) lcolor(gs8) fcolor(none))			///
			(lpolyci H311 consump if zinfo==1 & zdelib==0, yaxis(1) bw(1) lcolor(gs8) fcolor(none))	///
			(lpolyci H311 consump if zdelib==1, yaxis(1) bw(1) lcolor(gs8) fcolor(none))		///
			(histogram consump, yaxis(2) lcolor(gs8) fcolor(gs12))								///
			(lpoly   H311 consump if zinfo==0, yaxis(1) bw(1) lwidth(thick) lpattern(shortdash))		///
			(lpoly   H311 consump if zinfo==1 & zdelib==0, yaxis(1) bw(1) lwidth(thick) lpattern(dash) lcolor(navy))		///
			(lpoly   H311 consump if zdelib==1, yaxis(1) bw(1) lwidth(thick) lpattern(solid) lcolor(maroon)),	///
			xtitle("Predicted annual consumption per adult equivalent, PPP dollars")			///
			ytitle("Support for cash, 0 to 10") ytitle("Consumption density", axis(2))			///
			xlabel(5.3 "$200" 6.2 "$500" 6.9 "$1,000" 7.6 "$2,000" 8.5 "$5,000" 9.2 "$10,000")	///
			legend(order(11 "Deliberation" 10 "Information" 9 "Control") ring(0) pos(2))
			graph export "$floats/hetero_cash.pdf", as(pdf) replace   
*/

********************
*** Correlations ***
********************

*** Reg baseline index on covariates
	gen moderator = sample=="Moderators"
	
	forval n = 1/6{
		reg H`n'00 X1 X2 X3 male	//, cluster(VillageID)
		estimates store c`n'
	}
	label variable male 		"Male"
	label variable moderator 	"Moderator"
	
	#delimit ;
	esttab c1 c2 c3 c4 c5 c6 using "$floats/correlations.tex", 										
		f booktabs eqlabels(none) label
		star(* 0.10 ** 0.05 *** 0.01)
		order(male X1 X2 X3)
		keep(male X1 X2 X3)
		nomtitles nodep noobs nonotes nolines nonum									
		cells(b(fmt(%9.3fc) star) se(par)) 
		gaps  				
		stats(N, fmt(%9.0fc) labels("Obs."))	
		replace
		;
	#delimit cr


drop if moderator==1


***************
*** Balance ***
***************

*** All treatment arms in one regression
	gen found = H101!=. & H201!=. & H301!=.
	local i = 1
	foreach var of varlist H100 H200 H300 H400 H500 H600 X1 consumption X3 male age{
		reg `var' zdelib zoinfo zspill if found==1, cluster(VillageID)
		estimates store bal`i'
		local ++i
	}

	/*
	widetable H100 H200 H300 H400 H500 H600 X1 consumption X3, 		///
		file("widebalance")							///
		mtitles(`""Sell""Save""Cash""Services""Transparency""Knowledge""')
	*/
	
	#delimit ;
	esttab bal1 bal2 bal3 bal4 bal5 bal6 using "$floats/balance.tex", 		
		f booktabs eqlabels(none) label
		star(* 0.10 ** 0.05 *** 0.01)
		order(zdelib zoinfo zspill)
		keep(zdelib zoinfo zspill)
		nomtitles nodep noobs nonotes nolines nonum									
		cells(b(star fmt(%9.3fc)) se(par)) 
		gaps  				
		stats(N, fmt(%9.0fc) labels("Obs."))	
		replace
		;
	esttab bal7 bal8 bal9 bal10 bal11 using "$floats/balance_cov.tex", 		
		f booktabs eqlabels(none) label
		star(* 0.10 ** 0.05 *** 0.01)
		order(zdelib zoinfo zspill)
		keep(zdelib zoinfo zspill)
		nomtitles nodep noobs nonotes nolines nonum									
		cells(b(star fmt(%9.3fc)) se(par)) 
		gaps  				
		stats(N, fmt(%9.0fc) labels("Obs."))	
		replace
		;
	#delimit cr

*****************
*** Attrition ***
*****************

	*** Generate interactions requested by referee 2
		foreach var in X1 X2 X3 male age{
			gen zdelib_`var' = zdelib*`var'
			gen zoinfo_`var' = zoinfo*`var'
			gen zspill_`var' = zspill*`var'
		}
			
	reg found zdelib zoinfo zspill, cluster(VillageID)
	estimates store attrit0
	reg found zdelib zoinfo zspill /*H*00*/ X1 X2 X3 male age, cluster(VillageID)
	estimates store attrit1

	label variable zdelib "Treatment condition: \\ \hspace{.2cm} Info. $+$ deliberation"
	label variable zoinfo "\hspace{.2cm} Info. only"
	label variable zspill "\hspace{.2cm} Spillovers"
	label variable X1 "Baseline covariates \\ \hspace{.2cm} Political knowledge"
	label variable X2 "\hspace{.2cm} Per capita consumption"
	label variable X3 "\hspace{.2cm} Trust in government"
	label variable age "\hspace{.2cm} Age"
	label variable male "\hspace{.2cm} Male"

	#delimit ;
	esttab attrit0 attrit1 using "$floats/attrition.tex", 			
		f booktabs eqlabels(none) label
		star(* 0.10 ** 0.05 *** 0.01)
		order(zdelib zoinfo zspill X1 X2 X3 male age)
		keep(zdelib zoinfo zspill X1 X2 X3 male age)
		nomtitles nodep noobs nonotes nolines nonum									
		cells(b(fmt(%9.3fc) star) se(par)) 
		gaps  				
		stats(N, fmt(%9.0fc) labels("Obs."))	
		replace
		;
	#delimit cr


***********
*** ITT ***
***********

*** Just 6 mean effects
	gen lagdep = .
	label variable lagdep "Baseline outcome"
	capture mat drop p
	forval n = 1/6{
		replace lagdep = H`n'00
		leebounds H`n'01 zdelib if zdelib==1 | z==0
		scalar lower = _b[lower]
		scalar upper = _b[upper]
		reg H`n'01 zdelib zoinfo zspill lagdep, cluster(VillageID)
		estimates store itt`n'
		estadd scalar lower = lower
		estadd scalar upper = upper
		matrix p = nullmat(p) \ 2*ttail(e(N),abs(_b[zdelib]/_se[zdelib]))
	
	*** For referee #2: no lag dep
		reg H`n'01 zdelib zoinfo zspill, cluster(VillageID)

	}

	*** Anderson (2008) code for multiple comparison correction
		preserve
			drop _all
			svmat p
			rename p pval
			do "$do/X fdr_sharpened_qvalues.do"
			rename bky06_qval q
			mkmat q
		restore
	forval n = 1/6{
		estimates restore itt`n'
		estadd scalar qval = q[`n',1]
	}
	
	
	label variable zdelib "Treatment condition: \\ \hspace{.2cm} Info. $+$ deliberation"
	label variable zoinfo "\hspace{.2cm} Info. only"
	label variable zspill "\hspace{.2cm} Spillovers"

	#delimit ;
	esttab itt1 itt2 itt3 itt4 itt5 itt6 using "$floats/itt.tex", 			
		f booktabs eqlabels(none) label
		star(* 0.10 ** 0.05 *** 0.01)
		order(zdelib zoinfo zspill lagdep)
		keep(zdelib zoinfo zspill lagdep)
		nomtitles nodep noobs nonotes nolines nonum									
		cells(b(star fmt(%9.3fc)) se(par)) 
		gaps  				
		stats(qval lower upper N, fmt(3 2 2 %9.0fc) 
			labels(	 "For info $+$ delib.: \\ BKY (2006) q-value""Horowitz-Manski-Lee \\ \hspace{.25cm} Lower bound" 
					"\hspace{.25cm} Upper bound"
					"Obs."))																					
		replace
		;
	#delimit cr
		
***********************
*** ITT w/o lag dep ***
***********************

*** Just 6 mean effects
	capture mat drop p
	forval n = 1/6{
		leebounds H`n'01 zdelib if zdelib==1 | z==0
		scalar lower = _b[lower]
		scalar upper = _b[upper]
		reg H`n'01 zdelib zoinfo zspill, cluster(VillageID)
		estimates store itt`n'
		estadd scalar lower = lower
		estadd scalar upper = upper
		matrix p = nullmat(p) \ 2*ttail(e(N),abs(_b[zdelib]/_se[zdelib]))
	}
	
	*** Anderson (2008) code for multiple comparison correction
		preserve
			drop _all
			svmat p
			rename p pval
			do "$do/X fdr_sharpened_qvalues.do"
			rename bky06_qval q
			mkmat q
		restore
	forval n = 1/6{
		estimates restore itt`n'
		estadd scalar qval = q[`n',1]
	}
	
	
	label variable zdelib "Treatment condition: \\ \hspace{.2cm} Info. $+$ deliberation"
	label variable zoinfo "\hspace{.2cm} Info. only"
	label variable zspill "\hspace{.2cm} Spillovers"

	#delimit ;
	esttab itt1 itt2 itt3 itt4 itt5 itt6 using "$floats/itt_nolagdep.tex", 			
		f booktabs eqlabels(none) label
		star(* 0.10 ** 0.05 *** 0.01)
		order(zdelib zoinfo zspill)
		keep(zdelib zoinfo zspill)
		nomtitles nodep noobs nonotes nolines nonum									
		cells(b(star fmt(%9.3fc)) se(par)) 
		gaps  				
		stats(qval lower upper N, fmt(3 2 2 %9.0fc) 
			labels(	 "For info $+$ delib.: \\ BKY (2006) q-value""Horowitz-Manski-Lee \\ \hspace{.25cm} Lower bound" 
					"\hspace{.25cm} Upper bound"
					"Obs."))																					
		replace
		;
	#delimit cr

*********************************
*** ITT w baseline covariates ***
*********************************

*** Just 6 mean effects
	label variable X1 "Baseline covariates: \\ \hspace{.2cm} Political knowledge"
	label variable X2 "\hspace{.2cm} Per capita consumption"
	label variable X3 "\hspace{.2cm} Trust in government"
	label variable age "\hspace{.2cm} Age"
	label variable male "\hspace{.2cm} Male"
	capture mat drop p
	forval n = 1/6{
		replace lagdep = H`n'00
		reg H`n'01 zdelib zoinfo zspill lagdep X1 X2 X3 male age, cluster(VillageID)
		estimates store itt`n'
		matrix p = nullmat(p) \ 2*ttail(e(N),abs(_b[zdelib]/_se[zdelib]))
	
	}

	*** Anderson (2008) code for multiple comparison correction
		preserve
			drop _all
			svmat p
			rename p pval
			do "$do/X fdr_sharpened_qvalues.do"
			rename bky06_qval q
			mkmat q
		restore
	forval n = 1/6{
		estimates restore itt`n'
		estadd scalar qval = q[`n',1]
	}
	
	#delimit ;
	esttab itt1 itt2 itt3 itt4 itt5 itt6 using "$floats/itt_cov.tex", 			
		f booktabs eqlabels(none) label
		star(* 0.10 ** 0.05 *** 0.01)
		order(zdelib zoinfo zspill lagdep X1 X2 X3 male age)
		keep(zdelib zoinfo zspill lagdep X1 X2 X3 male age)
		nomtitles nodep noobs nonotes nolines nonum									
		cells(b(star fmt(%9.3fc)) se(par)) 
		gaps  				
		stats(qval N, fmt(3 %9.0fc) 
			labels(	"For info $+$ delib.: \\ BKY (2006) q-value"
					"Obs."))																					
		replace
		;
	#delimit cr

**********************
*** HETERO EFFECTS *** 
**********************

*** Generate interactions
	forval n = 1/3{
		gen X`n'zdelib = X`n'*zdelib
	}
	gen malezdelib = male*zdelib
	
	label variable lagdep "Baseline measures: \\ \hspace{.2cm} Baseline outcome"
	label variable male "\hspace{.2cm} Male"
	label variable X1 "\hspace{.2cm} Political knowledge"
	label variable X2 "\hspace{.2cm} Per capita consumption"
	label variable X3 "\hspace{.2cm} Trust in government"

	label variable malez	"(Info. $+$ deliberation) $ \times $ \ldots \\ \hspace{.2cm} Male"
	label variable X1z		"\hspace{.2cm} Political knowledge"
	label variable X2z		"\hspace{.2cm} Per capita consumption"
	label variable X3z		"\hspace{.2cm} Trust in government"

	forval n = 1/6{
		replace lagdep = H`n'00
		reg H`n'01 zdelib zoinfo zspill lagdep male X1 X2 X3 malez X1z X2z X3z, cluster(VillageID)
		estimates store het`n'
	}
	#delimit ;
	esttab het1 het2 het3 het4 het5 het6 using "$floats/hetero.tex", 		
		f booktabs eqlabels(none) label
		star(* 0.10 ** 0.05 *** 0.01)
		order(zdelib zoinfo zspill lagdep male X1 X2 X3 malezdelib X1zdelib X2zdelib X3zdelib)
		keep(zdelib zoinfo zspill lagdep male X1 X2 X3 malezdelib X1zdelib X2zdelib X3zdelib)
		nomtitles nodep noobs nonotes nolines nonum									
		cells(b(star fmt(%9.3fc)) se(par)) 
		gaps  				
		stats(N, fmt(%9.0fc) labels("Obs."))	
		replace
		;
	#delimit cr

		
*** Show results for each sub-index component
	tokenize 5 6 8 6 3 9
	local i = 1
	forval n = 1/6{
		global columns = ""
		forval m = 1/``i''{
			gen itt`n'`m' = .
			if "`n'"=="1" & ("`m'"=="3"|"`m'"=="4"|"`m'"=="5"){
				sum H`n'`m'1 if z==0
			}
			else{				
				sum H`n'`m'0
			}
			replace H`n'`m'0 = H`n'`m'0/r(max)
			replace H`n'`m'1 = H`n'`m'1/r(max)
			replace lagdep = H`n'`m'0
			if "`n'"=="1" & ("`m'"=="3"|"`m'"=="4"|"`m'"=="5"){
				reg H`n'`m'1 zdelib zoinfo zspill, cluster(VillageID)
			}
			else{
				reg H`n'`m'1 zdelib zoinfo zspill lagdep, cluster(VillageID)
			}
			estimates store itt`n'`m'
			global columns = "$columns" + " " + "itt`n'`m'"
		}
		global columns`n' = "$columns"	
		*** Not using anymore: separate table by hypothesis	
			esttab $columns using "$floats/itt`n'.tex", 				///
				f booktabs eqlabels(none) label nodep nonotes nolines 	///
				order(zdelib zoinfo zspill lagdep) nomtitles			///
				starlevels(* 0.10 ** 0.05 *** 0.01) se gaps replace		///
				stats(N, fmt(0) labels(" "))																					
		local ++i
	}
*** Rotate table: code adapted from http://repec.org/bocode/e/estout
	esttab $columns1 $columns2 $columns3 $columns4 $columns5 $columns6, se
	matrix C = r(coefs)
	matrix S = r(stats)
	eststo clear
	local rnames : rownames C
	local models : coleq C
	local models : list uniq models
	local i 0
	foreach name of local rnames {
		local ++i
		local j 0
		capture matrix drop b
		capture matrix drop se
		foreach model of local models {
			local ++j
			matrix tmp = C[`i', 3*`j'-2]
			if tmp[1,1]<. {
				matrix colnames tmp = `model'
				matrix b = nullmat(b), tmp
				matrix tmp[1,1] = C[`i', 3*`j'-1]
				matrix se = nullmat(se), tmp
			}
		}
		ereturn post b
		quietly estadd matrix se
		eststo `name'
	}
	local snames : rownames S
	local i 0
	foreach name of local snames {
		local ++i
		local j 0
		capture matrix drop b
		foreach model of local models {
			local ++j
			matrix tmp = S[`i', `j']
			matrix colnames tmp = `model'
			matrix b = nullmat(b), tmp
		}
		ereturn post b
		eststo `name'
	}

	label variable itt11 "{H1: Sell} \\ \addlinespace Sell gas (vs use for energy)"
	label variable itt12 "Do not subsidize energy"
	label variable itt13 "Extract vs leave in ground"
	label variable itt14 "Sell gas vs fuel (2)"
	label variable itt15 "Don't subsidize energy (2)"

	label variable itt21 "{H2: Save} \\ \addlinespace Strict limits on spending"
	label variable itt22 "Against infrastructure"
	label variable itt23 "Against health \& educ."
	label variable itt24 "Save for future generations"
	label variable itt25 "Save vs spend now"
	label variable itt26 "Don't use gas as collateral"

	label variable itt31 "{H3: Direct distribution} \\ \addlinespace Give money to all"
	label variable itt32 "Give money to needy"
	label variable itt33 "Cash transfers fight poverty"
	label variable itt34 "Transfers $=$ nutrition"
	label variable itt35 "Transfers $=$ accountability"
	label variable itt36 "Cash vs public services"
	label variable itt37 "Cash to child savings accts"
	label variable itt38 "Cash to retirement accts"

	label variable itt41 "{H4: Spend on social services} \\ \addlinespace Roads not important"
	label variable itt42 "Infrastr. not important"
	label variable itt43 "Health \& educ. important"
	label variable itt44 "Social services $=$ growth"
	label variable itt45 "Infrast. $=$ corruption"
	label variable itt46 "Social services vs infrastr."

	label variable itt51 "{H5: Transparency} \\ \addlinespace Publish contracts"
	label variable itt52 "International oversight"
	label variable itt53 "Don't entrust money to govt"

	label variable itt61 "{H6: Knowledge} \\ \addlinespace Heard about gas?"
	label variable itt62 "Where is the gas?"
	label variable itt63 "When was it found?"
	label variable itt64 "Is money already flowing?"
	label variable itt65 "Is gas worth $>$ a hospital?"
	label variable itt66 "...ten hospitals?"
	label variable itt67 "...the entire gov't budget?"
	label variable itt68 "...the entire nat'l economy?"
	label variable itt69 "How much if divided equally?"

*** After this must delete first \addlinespace & last row
	esttab using "$floats/ittall.tex", 						///
		f booktabs eqlabels(none) label se(3) b(3)				///
		nodep nonotes nolines noobs nonumbers nomtitles 		///
		starlevels(* 0.10 ** 0.05 *** 0.01) se gaps replace		


*label var `var' `"\hspace{0.1cm} `: variable label `var''"'


*** Sum stats/balance/diff-in-diff by indicator
	gen x = .
	gen y = uniform()
	tokenize 5 6 8 6 3 9	
	local i = 1
	forval n = 1/6{
		forval m = 1/``i''{
			sum H`n'`m'1
			gen x`n'`m'0 = (H`n'`m'0 - (r(max)+r(min))/2)/((r(max)-r(min))/1)
			gen x`n'`m'1 = (H`n'`m'1 - (r(max)+r(min))/2)/((r(max)-r(min))/1)
			if "`n'"=="1" & ("`m'"=="3"|"`m'"=="4"|"`m'"=="5") {
				replace x`n'`m'0 = 1
				gen Dx`n'`m' = x`n'`m'1 
			}
			else{
				gen Dx`n'`m' = x`n'`m'1 - x`n'`m'0
			}
			replace x = 1
			label var x `"`: variable label itt`n'`m''"'
			*** Delib
				eststo D0: reg x`n'`m'0 x 	if zdelib==1, nocons cluster(VillageID)
				eststo D1: reg x`n'`m'1 x	if zdelib==1, nocons cluster(VillageID)
				eststo DD: reg Dx`n'`m' x	if zdelib==1, nocons cluster(VillageID)
			*** Info
				eststo I0: reg x`n'`m'0 x	if zoinfo==1, nocons cluster(VillageID)
				eststo I1: reg x`n'`m'1 x	if zoinfo==1, nocons cluster(VillageID)
				eststo ID: reg Dx`n'`m' x	if zoinfo==1, nocons cluster(VillageID)
			*** Control
				eststo C0: reg x`n'`m'0 x	if z==0, nocons cluster(VillageID)
				eststo C1: reg x`n'`m'1 x	if z==0, nocons cluster(VillageID)
				eststo CD: reg Dx`n'`m' x	if z==0, nocons cluster(VillageID)
			*** Balance
				replace  x = zoinfo
				eststo BI: reg x`n'`m'0 x 	if zoinfo==1 | z==0, cluster(VillageID)
				replace  x = zdelib
				eststo BD: reg x`n'`m'0 x 	if zdelib==1 | z==0, cluster(VillageID)
			*** Diff-in-diff
				replace  x = zoinfo
				eststo DiDI: reg Dx`n'`m' x 	if zoinfo==1 | z==0, cluster(VillageID)
				replace  x = zdelib
				eststo DiDD: reg Dx`n'`m' x 	if zdelib==1 | z==0, cluster(VillageID)
			if "`n'"=="1" & ("`m'"=="3"|"`m'"=="4"|"`m'"=="5") {
				eststo D0: reg x`n'`m'0 y 	if zdelib==1, nocons cluster(VillageID)
				eststo I0: reg x`n'`m'0 y	if zoinfo==1, nocons cluster(VillageID)
				eststo C0: reg x`n'`m'0 y	if z==0, nocons cluster(VillageID)
				eststo BI: reg x`n'`m'0 y 	if zoinfo==1 | z==0, cluster(VillageID)
				eststo BD: reg x`n'`m'0 y 	if zdelib==1 | z==0, cluster(VillageID)
			}
			if "`n'"=="1" & "`m'"=="1"{ 
				esttab C0 C1 CD I0 I1 ID D0 D1 DD BI BD DiDI DiDD using "$floats/sum_long.tex",			///
					f booktabs eqlabels(none) label nodep noobs nonotes nolines nonum order(x) keep(x)		///
					starlevels(* 0.10 ** 0.05 *** 0.01) se gaps replace nomtitles b(%4.2f) se(%4.2f)											
					/*mgroups("Control" "Information" "Info. $+$ Deliberation" "Balance" "Diff-in-Diff", pattern(1 0 0 1 0 0 1 0 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))*/ 
			}
			else{
				esttab C0 C1 CD I0 I1 ID D0 D1 DD BI BD DiDI DiDD using "$floats/sum_long.tex",			///
					f booktabs eqlabels(none) label nodep noobs nonotes nolines nonum order(x) keep(x)		///
					starlevels(* 0.10 ** 0.05 *** 0.01) se gaps append nomtitles b(%4.2f) se(%4.2f)										
			}
		}
		local ++i
	}
	

exit

