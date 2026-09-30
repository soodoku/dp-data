*** Exploit random group assignment using only sample of deliberation participants

*** Wrinkle to keep in mind throughout this do-file:
*** People were randomly assigned to groups twice, 2 topics discussed each time
*** Hypotheses 1 and 2 were discussed in group 1
*** Hypotheses 3 and 4 were discussed in group 2

*** Merge the pieces
	use "$dta/panel_anonymized.dta", clear
	keep if zdelib==1
	capture drop _*
	mmerge HHID using "$dta/random_group_lists_anonymized.dta", unmatched(none)
	*** Separate moderators' own from 3rd-party answers (for moderators and note-takers separately)
		tempfile own tpr ntpr
		preserve
			use "$dta/moderator_panel_anonymized.dta", clear  
			drop if HHID>999999
			save `own'
		restore
		preserve
			use "$dta/moderator_panel_anonymized.dta", clear  
			drop if HHID<=999999
			rename modH* tprH*
			save `tpr'
			rename tprH* ntprH*
			save `ntpr'
		restore
	*** Match moderators' own replies to their groups
		mmerge group1 using `own', unmatched(master) umatch(mod1) ukeep(modH1* modH2*) 
		mmerge group2 using `own', unmatched(master) umatch(mod2) ukeep(modH3* modH4*) 
	*** Match moderators' 3rd-party reports to their groups
		mmerge group1 using `tpr', unmatched(master) umatch(mod1) ukeep(tprH1* tprH2*) 
		mmerge group2 using `tpr', unmatched(master) umatch(mod2) ukeep(tprH3* tprH4*) 
	*** Match moderators' 3rd-party reports to their groups
		mmerge group1 using `ntpr', unmatched(master) umatch(asst1) ukeep(ntprH1* ntprH2*) 
		mmerge group2 using `ntpr', unmatched(master) umatch(asst2) ukeep(ntprH3* ntprH4*) 

*** Leave-out means
	tokenize 1 1 2 2
	local g = 1
	forval h = 1/4{
		forval t = 0/1{
			bysort 	group``g'': egen gtotH`h'0`t' = sum(H`h'0`t')
			bysort 	group``g'': egen gnH`h'0`t' = count(H`h'0`t')
			gen 	lomH`h'0`t' = (gtotH`h'0`t' - H`h'0`t')/(gnH`h'0`t'-1)
			forval i = 1/9{
				capture bysort 	group``g'': egen gtotH`h'`i'`t' = sum(H`h'`i'`t')
				capture bysort 	group``g'': egen gnH`h'`i'`t' = count(H`h'`i'`t')
				capture gen 	lomH`h'`i'`t' = (gtotH`h'`i'`t' - H`h'`i'`t')/(gnH`h'`i'`t'-1)
			}
		}
		local ++g
	}
	
*** LOMs by demographics
	gen female = 1-male
	sum X1, det
	gen educated = X1>r(p50)
	sum X2, det
	gen rich = X2>r(p50)
	sum X3, det
	gen trusting = X3>r(p50)
	capture drop gtotH* gnH*
	tokenize 1 1 2 2
	local g = 1
	forval h = 1/4{
		foreach var in male female educated rich trusting{
			forval t = 0/1{
				capture drop gn`var' 
				capture drop temp 
				capture drop gtot*
				gen temp = `var'*H`h'0`t'
				bysort 	group``g'': egen gtotH`h'0`t' = sum(temp)
				bysort 	group``g'': egen gn`var' = sum(`var')
				gen 	`var'H`h'0`t' = (gtotH`h'0`t' - H`h'0`t')/(gn`var'-1) if `var'==1
				replace `var'H`h'0`t' = (gtotH`h'0`t')/(gn`var') if `var'==0
				forval i = 1/9{
					capture drop temp
					capture gen temp = `var'*H`h'`i'`t'
					capture bysort 	group``g'': egen gtotH`h'`i'`t' = sum(tempH`h'`i'`t')
					capture gen 	`var'H`h'`i'`t' = (gtotH`h'`i'`t' - H`h'`i'`t')/(gn`var'-1) if `var'==1
					capture replace `var'H`h'`i'`t' = (gtotH`h'`i'`t')/(gn`var') if `var'==0
				}
			}
		}
		local ++g
	}
	
tempfile breakpoint
save `breakpoint'

*************************
*** Moderator effects ***
*************************

*** Suasion
	preserve 

		keep HHID H*01 H*00 modH*00 group1 group2
		drop H5* H6*
		rename H*01 H01* 
		rename H*00 H00*
		rename modH*00 modH00*
		reshape long  H00 H01 modH00 , i(HHID) j(index)
		gen 	group = group1 if index==1 | index==2
		replace group = group2 if index==3 | index==4
		drop group1 group2
		rename modH00 modH

	*** Suasion 1: Leaders' baseline responses don't predict citizens' final views
		eststo Suasion: reghdfe H01 H00 modH, absorb(index) cluster(group)

	*** Suasion 2: Group FEs are insignificant 
		xtreg H01 H00 i.index, i(group) fe 

	restore



*** Put variables on same scale, centered at zero
	foreach var of varlist *11* *12* *21* *25* *26* *36* *41* *46*{
		replace `var'=. if `var'==-99 | `var'==99
		sum `var'
		replace `var' = (`var' - (r(max)+1)/2)/(r(max)-1)
	}

*** False-relay: regress leaders' summaries on their own views and mean post-treatment responses from participants
	preserve
		keep modH1* modH2* H1* H2* *prH1* *prH2* group*
		rename group1 group
		collapse (mean) modH* H* tpr* ntpr*, by(group)
		tempfile g1
		save `g1'
	restore
		keep modH3* modH4* H3* H4* *prH3* *prH4* group*
		rename group2 group
		collapse (mean) modH* H* tpr* ntpr*, by(group)
		mmerge group using `g1'

	*** reshape long, by index
		rename *1 *_1
		keep group  *11* *12* *21* *25* *26* *36* *41* *46*
		keep group tpr*_1 ntpr*_1 H*_1 mod*0 
		rename tpr*_1 tpr* 
		rename ntpr*_1 ntpr*
		rename mod*0 mod*
		rename H*_1 H*
		reshape long H modH tprH ntprH, i(group) j(index)

		eststo FalseRelay: reghdfe tprH H modH, absorb(group) cluster(group) 
		*eststo FalseRelay: reghdfe tprH H modH, absorb(index group)  


*** Self-censorship: do note-takers 3rd-party reports reflect citizens' views or the moderator's views?
	eststo SelfCensorship: reghdfe ntprH H modH, absorb(group) cluster(group)
	*eststo SelfCensorship: reghdfe ntprH H modH, absorb(index group)  

*** TeX tables
	label variable H "Citizens (after deliberation)"
	label variable modH "Leaders (before deliberation)"
	esttab Suasion SelfCensorship FalseRelay using "$floats/leaders.tex", 			///
		f booktabs eqlabels(none) label se(3) b(3)				///
		mtitles("Citizens (after deliberation)""Leader's report""Note-taker's report")	///
		keep(H modH)	mgroups("Suasion" "Self Censorship" "False Relay", pattern(1 1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))	///
		nodep nonotes nolines noobs  			 				///
		starlevels(* 0.10 ** 0.05 *** 0.01) se gaps replace		///
		stats(N r2, fmt(0 2) labels("Obs.""R-squared"))

*****************
*** H7a & H7d ***
*****************

use `breakpoint', clear

*** Peer effects regressions
	capture mat drop p
	gen lagdep = .
	gen lomall = .
	gen lommale = .
	gen lomrich = .
	gen lomeducated = .
	local t = 0			// Set to 0/1
	forval n = 1/4{
		replace lagdep = H`n'00
		replace lomall = lomH`n'0`t'
		replace lommale = maleH`n'0`t'
		replace lomrich = richH`n'0`t'
		replace lomeducated = educatedH`n'0`t'
		*** 7a Group-level polarization: overall and testing reduced influence of disadvantaged groups
		tokenize a b c d
		local m = 1
		foreach lom in all male rich educated{
			eststo ``m''`n': reg H`n'01 lagdep lom`lom' 
			matrix p = nullmat(p) \ 2*ttail(e(N),abs(_b[lom`lom']/_se[lom`lom']))
			local ++m
		}
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
		local n = 1
		foreach c in a1 b1 c1 d1 a2 b2 c2 d2 a3 b3 c3 d3 a4 b4 c4 d4{
			estimates restore `c'
			estadd scalar qval = q[`n',1]
			local ++n
		}

*** Table
	*label variable lagdep 	"\hline \addlinespace Baseline outcome"
	label variable lomall	"\hline \addlinespace All \\ \hspace{.5cm} Leave-out mean"
	label variable lommale 	"Men only \\ \hspace{.5cm} Leave-out mean"
	label variable lomrich 	"Rich only \\ \hspace{.5cm} Leave-out mean"
	label variable lomeduc 	"Educated only \\ \hspace{.5cm} Leave-out mean"
	esttab a1 a2 a3 a4 using "$floats/polarize`t'.tex", 				///
		f booktabs eqlabels(none) label se(3) b(3)						///
		mtitles("Sell""Save""Cash""Services")							///
		drop(lagdep _cons)												///
		nodep nonotes nolines noobs nonumbers 			 				///
		starlevels(* 0.10 ** 0.05 *** 0.01) se gaps replace				///
		stats(N qval, fmt(0 3 2 2) labels("\hspace{.5cm} Obs." "\hspace{.5cm} BKY (2006) q-value"))																					
	foreach v in b c d{
		esttab `v'1 `v'2 `v'3 `v'4 using "$floats/polarize`t'.tex", 	///
			f booktabs eqlabels(none) label se(3) b(3)					///
			drop(lagdep _cons)											///
			nodep nonotes nolines noobs nonumbers nomtitles 			///
			starlevels(* 0.10 ** 0.05 *** 0.01) se gaps append			///
			stats(N qval, fmt(0 3 2 2) labels("\hspace{.5cm} Obs." "\hspace{.5cm} BKY (2006) q-value"))																					
	}
	

exit
