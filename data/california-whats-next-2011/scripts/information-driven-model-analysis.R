##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~---++
##   											##
##      California
##		Last Edited: 8.10.14   	
##   	Gaurav Sood								##		
##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~---++

# R3 Changes Made
	# Added indices
	# Coding in indices: where issue positions on all items missing, left as missing
	# IDM for indices

# R2 Changes Made
	# T2/T3 missing: Missing assigned to midpoint
	# Group mean 
		# without the individual
		# Prior version of group mean used unscaled attitude var. It doesn't matter for 'significance'. Just for size of coef. Fixed that.
	# Added 3 more items to t3know (items only asked at t2/t3; realized we didn't need to be bound by whether something asked at t1)

# setwd
	setwd(basedir)

# Sourcing Common Functions
	source("func/func.R")

# Load Data
	ca <- foreign::read.dta("cdd/data/California/data/California_Merged_t1-t2-t3_6-28-11.dta")
	names(ca) <- tolower(names(ca))
	ca <- subset(ca, !is.na(ca$part))

# Knowledge
	#37. Democrats: Which political party holds the majority in the California State Senate, or couldn’t you say about that? (If yes, without naming party, or other) Which party do you have in mind? IF N/A, REFUSED, then 98; IF NO OPINION, then 99.
	#38. Democrats: How about the California State Assembly? Do you know which political party holds the majority there, or couldn’t you say about that? (If yes, without naming party, or other) Which party do you have in mind? IF N/A, REFUSED, then 98; IF NO OPINION, then 99.
	#39. Two-thirds: How large a majority of the State Legislature is needed to approve a proposed constitutional amendment?	a. a simple majority of both houses b. a simple majority of the Assembly and two-thirds of Senate c. two-thirds of both houses d. three-fourths of both houses Or couldn’t you say about that? IF N/A, REFUSED, then 98; IF NO OPINION, then 99.
	#40. Two-thirds: How large a majority of the State Legislature is needed to increase taxess? a. a simple majority of both houses b. a simple majority of the Assembly and two-thirds of Senate  c. two-thirds of both houses d. three-fourths of both houses Or couldn’t you say about that?  IF N/A, REFUSED, then 98; IF NO OPINION, then 99.
	#41. Anyone Registered in CA: Ballot measures can be signed by… a. anyone over 18 years of age b. any citizen over 18 years of age c. only registered voters  d. only registered voters who voted in last election Or couldn’t you say about that?  IF N/A, REFUSED, then 98; IF NO OPINION, then 99.
	
	# Only in T1
	##42. CA: What is the maximum increase in assessed property value when property changes ownership? a. 1%  b. 3%  c. 5%  d. 7%  Or couldn’t you say about that? IF N/A, REFUSED, then 98; IF NO OPINION, then 99.
	##43. NY: The majority of revenue for the State’s General Fund	comes from which of the following? a. Personal Income Tax b. Retail sales and use tax c. Corporation Tax  d. Local Income Tax Or couldn’t you say about that?  IF N/A, REFUSED, then 98; IF NO OPINION, then 99.
	##44. K12: The largest single share of the State’s General Fund goes to which of the following? a. Higher Education b. K through12 education c. Health and Human Services d. State Pensions Or couldn’t you say about that? IF N/A, REFUSED, then 98; IF NO OPINION, then 99.

	# T2 and T3
	# 32.	Which state has the most residents per member of the state legislature?
	# 33.	On average, which state has the highest total tax burden?
	# 34.	In Governor Brown’s most recent budget proposal, the largest single share of spending goes to which of the following?

		ca$t1know1raw <- as.numeric(car::recode(ca$q37, "'Democratic Party'=1;'Republican Party'=0;else=NA"))-1
		ca$t1know2raw <- as.numeric(car::recode(ca$q38, "'Democratic Party'=1;'Republican Party'=0;else=NA"))-1
		ca$t1know3raw <- car::recode(as.numeric(ca$q39), "3=1;c(1,2,4)=0")
		ca$t1know4raw <- car::recode(as.numeric(ca$q40), "3=1;c(1,2,4)=0")
		ca$t1know5raw <- car::recode(as.numeric(ca$q41), "3=1;c(1,2,4)=0")

		ca$t3know1raw <- car::recode(ca$t3q27, "1=1;2=0;else=NA")
		ca$t3know2raw <- car::recode(ca$t3q28, "1=1;c(2,3)=0;else=NA")
		ca$t3know3raw <- car::recode(ca$t3q29, "2=1;c(1,3,4)=0")
		ca$t3know4raw <- car::recode(ca$t3q30, "2=1;c(1,3,4)=0")
		ca$t3know5raw <- car::recode(ca$t3q31, "3=1;c(1,2,4)=0")

		# t3 extra
		ca$t3know6raw <- car::recode(ca$t3q32, "1=1;c(3,2,4)=0")
		ca$t3know7raw <- car::recode(ca$t3q33, "2=1;c(1,3,4)=0")
		ca$t3know8raw <- car::recode(ca$t3q34, "3=1;c(1,2,4)=0")

		t1raw 	<- paste0("t1know", 1:5, "raw")
		t3raw 	<- paste0("t3know", 1:5, "raw")
		
		t33raw 	<- paste0("t3know", 1:8, "raw")

		t1 		<- paste0("t1know", 1:5, "c")
		t3 		<- paste0("t3know", 1:5, "c")
		t33 	<- paste0("t3know", 1:8, "c")
	
		ca[,c(t1,t33)] <- nona(ca[,c(t1raw, t33raw)])

		ca$t1know <- rowMeans(ca[,t1])
		ca$t3know <- rowMeans(ca[,t33])

# Sociodem
	ca$edu 	  <- car::recode(as.numeric(ca$q58), "c(1,2)=0; 3=.33; 4=.66; c(5,6)=1;8=NA")
	ca$female <- as.numeric(ca$q73=="Female")
	
	# Recoding Hispanic
	ca$hisp <- as.numeric(ca$q70=='Hispanic')

# Policy
	# Props
		# YG	t1 t2/t3 	Sig. 	QText
		#sec3d  28 	s 				Prop1: 	Establishing clear goals for each government program and assessing whether progress is being made toward these goals at least once every ten years.
		#sec3b    	t 		0.100**	Prop2: Requiring the Governor and the Legislature to adopt two-year instead of one-year budgets
		#sec3h    	u 		0.042**	Prop3: Requiring the Governor & the Legislature to publish three and five year budget projections prior to the budget vote each year
		#sec3l    	v 		0.066**	Prop4: Transferring from the state to local governments control and financing of services provided at the local level and requiring minimum standards for delivering them 
		#sec3o    	z 		0.028**	Prop5: Requiring state and local governments to identify policy goals and publish their progress toward meeting them
		#sec3j 10 	aa 		0.029*	Prop6: Requiring legislation creating new programs or tax cuts that cost $25 million or more to indicate how they will be paid for
		
		# -0.035*	c 		Allowing a simple majority of the State Legislature to place a countermeasure to an already qualified initiative on the ballot next to that initiative
		# -0.049*	d 		Allowing the Legislature to amend an initiative that has already passed, subject to a public review and the agreement of the initiative's proponents
		# -0.065**	e 		Allowing the Legislature to amend an initiative that has already passed, subject to a two-thirds vote, even if an initiative’s proponents do not agree with the amendment
		# 0.059**	f 		Allowing an initiative’s proponents to withdraw it after it qualifies for the ballot
		# -0.034**	g 		Requiring all ballot measures that require new expenditures to indicate how they will be paid for
		# 0.031*	h 		Requiring the ballot pamphlet to provide an analysis by the Legislative Analyst of how new initiative programs will likely be paid for
		# 0.072** 	j 		Publishing the top five contributors for and against each ballot measure in the ballot pamphlet
		# -0.154**	n 		Making the State Legislature part-time and paying legislators parttime salaries
		#-0.083**	o 		Reducing the length of the state legislative session and requiring legislators to spend more time in their districts
		# 0.277**	q 		Lengthening Assembly terms from 2 years to 4, and Senate terms from 4 years to 6
		# 0.080**	w 		Allowing local governments to raise taxes for local services in exchange for increased coordination of service delivery and public reporting of performance
		# 0.049*	af 		Applying the sales tax to services as well as goods while reducing the sales tax rate
		# 0.139**	ai 		Reassessing non-residential property more frequently than now
		# 0.106**	am 		Decreasing the super-majority vote required in the Legislature to raise taxes (about 67%) to 55%

		ca$q2r  <- as.numeric(gsub('[^0-9.]', '', ca$q2))
		ca$q4r  <- as.numeric(gsub('[^0-9.]', '', ca$q4))
		ca$q5r  <- as.numeric(gsub('[^0-9.]', '', ca$q5))
		ca$q10r <- as.numeric(gsub('[^0-9.]', '', ca$q10))
		ca$q11r <- as.numeric(gsub('[^0-9.]', '', ca$q11))
		ca$q28r <- as.numeric(gsub('[^0-9.]', '', ca$q28))
	
		# Midpoint imputation on attitude items as directed by Fishkin/Luskin 
		ca$q2r  <- zero1(ifelse(is.na(ca$q2r), 5, ca$q2r))
		ca$q4r  <- zero1(ifelse(is.na(ca$q4r), 5, ca$q4r))
		ca$q5r  <- zero1(ifelse(is.na(ca$q5r), 5, ca$q5r))
		ca$q10r <- zero1(ifelse(is.na(ca$q10r), 5, ca$q10r))
		ca$q11r <- zero1(ifelse(is.na(ca$q11r), 5, ca$q11r))
		ca$q28r <- zero1(ifelse(is.na(ca$q28r), 5, ca$q28r))
	
		fromt2 		<- paste0("t2q2", c("s", "t", "u", "v", "z", "aa", "c", "d", "e", "f", "g", "h", "j", "n", "o", "q", "w", "af", "ai", "am"))
		fromt3   	<- paste0("t3q2", c("s", "t", "u", "v", "z", "aa", "c", "d", "e", "f", "g", "h", "j", "n", "o", "q", "w", "af", "ai", "am")) 
		tot2 		<- paste0("t2q2", c("s", "t", "u", "v", "z", "aa", "c", "d", "e", "f", "g", "h", "j", "n", "o", "q", "w", "af", "ai", "am"), "r")
		tot3   		<- paste0("t3q2", c("s", "t", "u", "v", "z", "aa", "c", "d", "e", "f", "g", "h", "j", "n", "o", "q", "w", "af", "ai", "am"), "r") 
		
		# Without imputation of missing to mid
		#ca[,c(tot2, tot3)]	  <- sapply(ca[,c(fromt2, fromt3)], function(x) zero1(x, 0, 10))
	
		# With imputation of missing to mid
		ca[,c(tot2, tot3)]	  <- sapply(ca[,c(fromt2, fromt3)], function(x) zero1(ifelse(is.na(x), 5, x)))
		
		# Policy Indices (12 total)
		# Sales Taxes: af, ag
		# cor(cbind(ca$t2q2af, ca$t2q2ag), use="na.or.complete")
			ca$t2sales <- rowMeans(cbind(ca$t2q2af, ca$t2q2ag), na.rm=T)
			ca$t3sales <- rowMeans(cbind(ca$t3q2af, ca$t3q2ag), na.rm=T)

		# Openness to New Taxes: ai, am
		# cor(cbind(ca$t2q2ai, ca$t2q2am), use="na.or.complete")
			ca$t2newtax <- rowMeans(cbind(ca$t2q2ai, ca$t2q2am), na.rm=T)
			ca$t3newtax <- rowMeans(cbind(ca$t3q2ai, ca$t3q2am), na.rm=T)

		# taxes-overall: af, ag, ai, am
		# cor(cbind(ca$t2q2af, ca$t2q2ag, ca$t2q2ai, ca$t2q2am), use="na.or.complete")
			ca$t2alltax <- rowMeans(cbind(ca$t2q2af, ca$t2q2ai, ca$t2q2am), na.rm=T)
			ca$t3alltax <- rowMeans(cbind(ca$t3q2af, ca$t3q2ai, ca$t3q2am), na.rm=T)

		# Real estate property reform: ah, ai, aj, ak
		# cor(cbind(ca$t2q2ah, ca$t2q2ai, ca$t2q2aj, ca$t2q2ak), use="na.or.complete")
			ca$t2realest <- rowMeans(cbind(ca$t2q2ah, ca$t2q2ai, ca$t2q2aj, ca$t2q2ak), na.rm=T)
			ca$t3realest <- rowMeans(cbind(ca$t3q2ah, ca$t3q2ai, ca$t3q2aj, ca$t3q2ak), na.rm=T)

		# state budgetary transparency: s, z
		# cor(cbind(ca$t2q2s, ca$t2q2z), use="na.or.complete")
			ca$t2transp <- rowMeans(cbind(ca$t2q2s, ca$t2q2z), na.rm=T)
			ca$t3transp <- rowMeans(cbind(ca$t3q2s, ca$t3q2z), na.rm=T)

		# State Budgetary Accountability: t, u
		# cor(cbind(ca$t2q2t, ca$t2q2u), use="na.or.complete")
			ca$t2account <- rowMeans(cbind(ca$t2q2t, ca$t2q2u), na.rm=T)
			ca$t3account <- rowMeans(cbind(ca$t3q2t, ca$t3q2u), na.rm=T)

		# State Budgetary Transparency/Accountability: s, z, t, u
		# cor(cbind(ca$t2q2s, ca$t2q2z, ca$t2q2t, ca$t2q2u), use="na.or.complete")
			ca$t2budget <- rowMeans(cbind(ca$t2q2s, ca$t2q2z, ca$t2q2t, ca$t2q2u), na.rm=T)
			ca$t3budget <- rowMeans(cbind(ca$t3q2s, ca$t3q2z, ca$t3q2t, ca$t3q2u), na.rm=T)

		# state/loval: v, w
		# cor(cbind(ca$t2q2v, ca$t2q2w), use="na.or.complete")
			ca$t2local <- rowMeans(cbind(ca$t2q2v, ca$t2q2w), na.rm=T)
			ca$t3local <- rowMeans(cbind(ca$t3q2v, ca$t3q2w), na.rm=T)

		# indirect initiative: 2b, 2c, 2d, 2e
		# cor(cbind(ca$t2q2b, ca$t2q2c, ca$t2q2d, ca$t2q2e), use="na.or.complete")
			ca$t2indirect <- rowMeans(cbind(ca$t2q2b, ca$t2q2c, ca$t2q2d, ca$t2q2e), na.rm=T)
			ca$t3indirect <- rowMeans(cbind(ca$t3q2c, ca$t3q2c, ca$t3q2d, ca$t3q2e), na.rm=T)

		# Funding transparency: 2g, 2h, 2j, 2aa, 2ab, 2ac
		# cor(cbind(ca$t2q2g, ca$t2q2h, ca$t2q2j, ca$t2q2aa, ca$t2q2ab, ca$t2q2ac), use="na.or.complete")
			ca$t2fundtrans <- rowMeans(cbind(ca$t2q2g, ca$t2q2h, ca$t2q2j, ca$t2q2aa, ca$t2q2ab, ca$t2q2ac), na.rm=T)
			ca$t3fundtrans <- rowMeans(cbind(ca$t3q2g, ca$t3q2h, ca$t3q2j, ca$t3q2aa, ca$t3q2ab, ca$t3q2ac), na.rm=T)

		# Legislative reform: 2q, 2k, 2n, 2o
		# cor(cbind(ca$t2q2q, ca$t2q2k, ca$t2q2n, ca$t2q2o), use="na.or.complete")
		# FLIP
			ca$t2legreform <- rowMeans(cbind(10 - ca$t2q2q, 10 - ca$t2q2k, ca$t2q2n, ca$t2q2o), na.rm=T)
			ca$t3legreform <- rowMeans(cbind(10 - ca$t3q2q, 10 - ca$t3q2k, ca$t3q2n, ca$t3q2o), na.rm=T)

		# Limiting Legislative Session: 2n, 2o
		# cor(cbind(ca$t2q2n, ca$t2q2o), use="na.or.complete")
			ca$t2session <- rowMeans(cbind(ca$t2q2n, ca$t2q2o), na.rm=T)
			ca$t3session <- rowMeans(cbind(ca$t3q2n, ca$t3q2o), na.rm=T)

		# Impute missing at midpoint for missing
			indices 		<- c("sales", "newtax", "alltax", "realest", "transp", "account", "budget", "local", "indirect", "fundtrans", "legreform", "session") 
			fromt2.index 	<- paste0("t2", indices)
			fromt3.index  	<- paste0("t3", indices) 
			tot2.index 		<- paste0("t2", indices, "r")
			tot3.index   	<- paste0("t3", indices, "r") 
			
		# With imputation of missing to mid
			#ca[,c(tot2.index, tot3.index)]	  <- sapply(ca[,c(fromt2.index, fromt3.index)], function(x) zero1(ifelse(is.na(x), 5, x)))
		
		# Without midpoint imputation
			ca[,c(tot2.index, tot3.index)]	  <- sapply(ca[,c(fromt2.index, fromt3.index)], function(x) zero1(x))
		
# Group Means
# ~~~~~~~~~~~~~~~~~~~~~
		# Policy Attitudes
			fromt2 		<- paste0("t2q2", c("s", "t", "u", "v", "z", "aa", "c", "d", "e", "f", "g", "h", "j", "n", "o", "q", "w", "af", "ai", "am"), "r")
			tot2 		<- paste0("t2q2", c("s", "t", "u", "v", "z", "aa", "c", "d", "e", "f", "g", "h", "j", "n", "o", "q", "w", "af", "ai", "am"), "grp")

			ca$grpsize 	 <- grpfun(rep(1, nrow(ca)), ca$t3_groupnumber, fun="sum")
			
			#ca[,c(tot2)] <- sapply(ca[,c(fromt2)], function(x) grpfun(x, ca$t3_groupnumber, "mean"))
				
			# Without the individual
			ca[,c(tot2)] <- sapply(ca[,c(fromt2)], function(x) (grpfun(x, ca$t3_groupnumber, "mean")*ca$grpsize - x)/(ca$grpsize -1))

		# Attitude Indices
			fromt2.index 	<- paste0("t2", indices, "r")
			tot2.index  	<- paste0("t2", indices, "grp") 

		# Without the individual
			ca[,c(tot2.index)] <- sapply(ca[,c(fromt2.index)], function(x) (grpfun(x, ca$t3_groupnumber, "mean")*ca$grpsize - x)/(ca$grpsize -1))

# T2/T3 Filter
	ca <- subset(ca, t2t3filter==1)

# Analyses/Information Driven Model
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	# Att. by item
	# Mean Diff. + Regression
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		# 0.806 0.847
		round(mean(ca$t2q2sr - ca$t3q2sr),3)
		with(ca, summary(lm(I(t3q2sr - t2q2sr) ~ I(t2q2sr - t2q2sgrp) + t3know)))

		# 0.617 0.717
		round(mean(ca$t2q2tr - ca$t3q2tr),3)
		with(ca, summary(lm(I(t3q2tr - t2q2tr) ~ I(t2q2tr - t2q2tgrp) + t3know)))

		# 0.736 0.777
		round(mean(ca$t2q2ur - ca$t3q2ur),3)
		with(ca, summary(lm(I(t3q2ur - t2q2ur) ~ I(t2q2ur - t2q2ugrp) + t3know)))

		# 0.635 0.69
		round(mean(ca$t2q2vr - ca$t3q2vr), 3)
		with(ca, summary(lm(I(t3q2vr - t2q2vr) ~ I(t2q2vr - t2q2vgrp) + t3know)))

		# 0.811 0.841
		round(mean(ca$t2q2zr - ca$t3q2zr), 3)
		with(ca, summary(lm(I(t3q2zr - t2q2zr) ~ I(t2q2zr - t2q2zgrp) + t3know)))

		# 0.850 0.851
		round(mean(ca$t2q2aar - ca$t3q2aar), 3)
		with(ca, summary(lm(I(t3q2aar - t2q2aar) ~ I(t2q2aar - t2q2aagrp) + t3know)))

		# c
		round(mean(ca$t3q2cr - ca$t2q2cr), 3)
		with(ca, summary(lm(I(t3q2cr - t2q2cr) ~ I(t2q2sr - t2q2cgrp) + t3know)))
		
		#d 
		round(mean(ca$t3q2dr - ca$t2q2dr), 3)
		with(ca, summary(lm(I(t3q2dr - t2q2dr) ~ I(t2q2tr - t2q2dgrp) + t3know)))
		
		#e
		round(mean(ca$t3q2er - ca$t2q2er), 3)
		with(ca, summary(lm(I(t3q2er - t2q2er) ~ I(t2q2er - t2q2egrp) + t3know)))
		
		# f
		round(mean(ca$t3q2fr - ca$t2q2fr), 3)
		with(ca, summary(lm(I(t3q2fr - t2q2fr) ~ I(t2q2fr - t2q2fgrp) + t3know)))
		
		# g
		round(mean(ca$t3q2gr - ca$t2q2gr), 3)
		with(ca, summary(lm(I(t3q2gr - t2q2gr) ~ I(t2q2gr - t2q2ggrp) + t3know)))
		
		# h
		round(mean(ca$t3q2hr - ca$t2q2hr), 3)
		with(ca, summary(lm(I(t3q2hr - t2q2hr) ~ I(t2q2hr - t2q2hgrp) + t3know)))

		# j
		round(mean(ca$t3q2jr - ca$t2q2jr), 3)
		with(ca, summary(lm(I(t3q2jr - t2q2jr) ~ I(t2q2jr - t2q2jgrp) + t3know)))

		# n
		round(mean(ca$t3q2nr - ca$t2q2nr), 3)
		with(ca, summary(lm(I(t3q2nr - t2q2nr) ~ I(t2q2nr - t2q2ngrp) + t3know)))

		# o
		round(mean(ca$t3q2or - ca$t2q2or), 3)
		with(ca, summary(lm(I(t3q2or - t2q2or) ~ I(t2q2or - t2q2ogrp) + t3know)))

		# q
		round(mean(ca$t3q2qr - ca$t2q2qr), 3)
		with(ca, summary(lm(I(t3q2qr - t2q2qr) ~ I(t2q2qr - t2q2qgrp) + t3know)))

		# w
		round(mean(ca$t3q2wr - ca$t2q2wr), 3)
		with(ca, summary(lm(I(t3q2wr - t2q2wr) ~ I(t2q2wr - t2q2wgrp) + t3know)))
		
		# af
		round(mean(ca$t3q2afr  - ca$t2q2afr), 3)
		with(ca, summary(lm(I(t3q2afr - t2q2afr) ~ I(t2q2afr - t2q2afgrp) + t3know)))

		# ai
		round(mean(ca$t3q2air - ca$t2q2air), 3)
		with(ca, summary(lm(I(t3q2air - t2q2air) ~ I(t2q2air - t2q2aigrp) + t3know)))
		
		# am
		round(mean(ca$t3q2amr - ca$t2q2amr), 3)
		with(ca, summary(lm(I(t3q2amr - t2q2amr) ~ I(t2q2amr - t2q2amgrp) + t3know)))

	# Att. indices
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		# Policy Indices (12 total)
		# Sales Taxes: af, ag
			round(mean(ca$t3salesr - ca$t2salesr, na.rm=T), 3)
			with(ca, summary(lm(I(t3salesr - t2salesr) ~ I(t2salesr - t2salesgrp) + t3know)))

		# Openness to New Taxes: ai, am
			round(mean(ca$t3newtaxr - ca$t2newtaxr, na.rm=T), 3)
			with(ca, summary(lm(I(t3newtaxr - t2newtaxr) ~ I(t2newtaxr - t2newtaxgrp) + t3know)))

		# taxes-overall: af, ag, ai, am
			round(mean(ca$t3alltaxr - ca$t2alltaxr, na.rm=T), 3)
			with(ca, summary(lm(I(t3alltaxr - t2alltaxr) ~ I(t2alltaxr - t2alltaxgrp) + t3know)))

		# Real estate property reform: ah, ai, aj, ak
			round(mean(ca$t3realestr - ca$t2realestr, na.rm=T), 3)
			with(ca, summary(lm(I(t3realestr - t2realestr) ~ I(t2realestr - t2realestgrp) + t3know)))

		# state budgetary transparency: s, z
			round(mean(ca$t3transpr - ca$t2transpr, na.rm=T), 3)
			with(ca, summary(lm(I(t3transpr - t2transpr) ~ I(t2transpr - t2transpgrp) + t3know)))

		# State Budgetary Accountability: t, u
			round(mean(ca$t3accountr - ca$t2accountr, na.rm=T), 3)
			with(ca, summary(lm(I(t3accountr - t2accountr) ~ I(t2accountr - t2accountgrp) + t3know)))

		# State Budgetary Transparency/Accountability: s, z, t, u
			round(mean(ca$t3budgetr - ca$t2budgetr, na.rm=T), 3)
			with(ca, summary(lm(I(t3budgetr - t2budgetr) ~ I(t2budgetr - t2budgetgrp) + t3know)))

		# state/loval: v, w
			round(mean(ca$t3localr - ca$t2localr, na.rm=T), 3)
			with(ca, summary(lm(I(t3localr - t2localr) ~ I(t2localr - t2localgrp) + t3know)))

		# indirect initiative: 2b, 2c, 2d, 2e
			round(mean(ca$t3indirectr - ca$t2indirectr, na.rm=T), 3)
			with(ca, summary(lm(I(t3indirectr - t2indirectr) ~ I(t2indirectr - t2indirectgrp) + t3know)))

		# Funding transparency: 2g, 2h, 2j, 2aa, 2ab, 2ac
			round(mean(ca$t3fundtransr - ca$t2fundtransr, na.rm=T), 3)
			with(ca, summary(lm(I(t3fundtransr - t2fundtransr) ~ I(t2fundtransr - t2fundtransgrp) + t3know)))

		# Legislative reform: 2q, 2k, 2n, 2o
			round(mean(ca$t3legreformr - ca$t2legreformr, na.rm=T), 3)
			with(ca, summary(lm(I(t3legreformr - t2legreformr) ~ I(t2legreformr - t2legreformgrp) + t3know)))

		# Limiting Legislative Session: 2n, 2o
			round(mean(ca$t3sessionr - ca$t2sessionr, na.rm=T), 3)
			with(ca, summary(lm(I(t3sessionr - t2sessionr) ~ I(t2sessionr - t2sessiongrp) + t3know)))
