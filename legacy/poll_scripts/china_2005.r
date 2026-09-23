##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--++
##      China 2005: Zeguo							  ##
##		Last Edited: 4.05.14  	         
##   	Gaurav Sood							  		  ## 
##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--++

# Set Working dir.
	setwd(basedir)

# Load Functions
	source("cdd/hlmFunc.R") 

# Details about the poll
	# Initial Sample: March 2005
	# DP Held: 9 April 2005
	
# Load data
	china 			<- foreign::read.dta(paste0(basedir, "cdd/data/China/2005/China Merged Dataset.dta"))	

	names(china)	<- tolower(names(china))
	china			<- subset(china, !is.na(china$groupnum)) # test group participants
	china			<- subset(china, !is.na(preandpost))
	
# Poll-level variables
	china$pollid	<- 52
	china$caseid	<- 52000 + china$p
	china$country	<- 6
	china$mode		<- 0
	china$numindices <- 9
	china$numitems   <- 4
	china$length     <- 1
	china$timebtw    <- 25 # best guess, based on above

# Group
	china$pollgroup <- 5200 + china$groupnum
	china$groupsize <- grpfun(rep(1, nrow(china)), china$pollgroup, fun="sum")

# Individual Level

	# Sociodem
		china$ppage		<- china$age
		china$female	<- as.numeric(china$gender==2) # compared it to the paper.
		china$income	<- NA
		china$hhincome	<- NA 
		china$highinc	<- NA #70k or above
		china$minority	<- NA
		# 4 = High School (checked via paper)
		china$educ4		<- car::recode(china$education,"c(1,2,3) = 0; c(4)=.33; c(5,6)=.66;c(7)=1;else=NA")
	
	# Knowledge
		# matches with the paper
		# Revenue increase in Zeguo, 2003–2004
		#t1 china$d3043cor #t2 china$d3043p
		
		# Floating population in Zeguo
		# t1 china$d3044cor	# t2 china$d3044p
		
		# Not a major product of Zeguo
		# t1 china$d3045cor	# t2 china$d3045p
		
		# Number of parks in Zeguo
		#t1 china$d3046cor		#t2 china$d3046p

		# Corrected facts
		china$d3043corr 	<- pkcor(china$d3043cor, china$d3043p=='correct')
		china$d3044corr 	<- pkcor(china$d3044cor, china$d3044p=='correct')
		china$d3045corr 	<- pkcor(china$d3045cor, china$d3045p=='correct')
		china$d3046corr		<- pkcor(china$d3046cor, china$d3046p=='correct')
		
		china$t1know		<- china$knowm1
		china$t2know		<- china$knowm2
		china$t1knowcor		<- rowMeans(china[, c("d3043corr", "d3044corr", "d3045corr", "d3046corr")])
		
		## Knowledge over the highest quartile is High Knowledge
		china$highknow <- as.numeric((china$t1know > fivenum(china$t1know)[4]))
		
		# Group Gain
		china$grpgain  <- groupgain(china[, c("d3043corr", "d3044corr", "d3045corr", "d3046corr")],  china$pollgroup, nrow(china), china$numitems, china$groupsize)
	
		china$t1knowlevel	<- mean(china$t1know)
		
# Group Level Vars
		china$pminority			<- NA
		china$pfemale			<- grpfun(china$female, china$pollgroup, fun="mean")
		china$varfemale			<- china$pfemale*(1 - china$pfemale)
		china$meant1know		<- grpfun(china$t1know, china$pollgroup, fun="mean")
		china$meant1know_ind	<- (china$meant1know*china$groupsize - china$t1know )/ (china$groupsize - 1)
		china$meant2know		<- grpfun(china$t2know, china$pollgroup, fun="mean")
		china$phighknow			<- grpfun(china$highknow, china$pollgroup, fun="mean")
		china$phigheduc			<- NA
		china$vareduc			<- grpfun(china$educ4, china$pollgroup, fun="var")
		china$phighinc			<- NA
		china$pminority			<- NA
		
# Read brief and polint
	china$t1polint		<- NA
	china$readbrief		<- NA

# attitudes
	# industrial roads
	china$t1att1	<- ifelse(is.na(china$iroads1), .5, china$iroads1)	
	china$t2att1	<- ifelse(is.na(china$iroads2), .5, china$iroads2)
	
	#village roads
	china$t1att2	<- ifelse(is.na(china$vroads1), .5, china$vroads1)	
	china$t2att2	<- ifelse(is.na(china$vroads2), .5, china$vroads2)
	
	# main roads
	china$t1att3	<- ifelse(is.na(china$mroads1), .5, china$mroads1)	
	china$t2att3 	<- ifelse(is.na(china$mroads1), .5, china$mroads1)
	
	#commericial roads
	china$t1att4 <- ifelse(is.na(china$croads1), .5, china$croads1)	
	china$t2att4 <- ifelse(is.na(china$croads2), .5, china$croads2)
	
	#wenchang main ave
	china$t1att5 <- zero1(ifelse(is.na(china$main2t1), 5, china$main2t1))	
	china$t2att5 <- zero1(ifelse(is.na(china$main2t2), 5, china$main2t2))
	
	#other parks
	china$t1att6 <- zero1(ifelse(is.na(china$oparkt1), 5, china$oparkt1))	
	china$t2att6 <- zero1(ifelse(is.na(china$oparkt2), 5, china$oparkt2))
	
	#china.t1att7 <- zero1(ifelse(is.na(china$recpark0), 0, china$recpark0))	
	#china.t2att7 <- zero1(ifelse(is.na(china$recparks), -3, -china$recparks))
	# mean((china$recparkdif), na.rm=T) #this matches with the paper

	# township image
	china$t1att7 <- zero1(ifelse(is.na(china$imaget1), 5, china$imaget1))	 
	china$t2att7 <- zero1(ifelse(is.na(china$imaget2), 5, china$imaget2))
	
	#cultural heritage
	china$t1att8 <- ifelse(is.na(china$cvalues1), .5, china$cvalues1)	
	china$t2att8 <- ifelse(is.na(china$cvalues2), .5, china$cvalues2)
	
	#	sewage treatment
	china$t1att9 <- ifelse(is.na(china$sew1), .5, china$sew1)	
	china$t2att9 <- ifelse(is.na(china$sew2), .5, china$sew2)

	## Attitude Variance
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~

	# Get the vars
	china1 <- china[, paste0("t1att", 1:9)]
	
	fromlist		<- paste0("t1att", 1:9)
	tolist			<- paste("var", fromlist, sep="")
	china[,tolist]	<- sapply(china[,fromlist], function(x) grpfun(x, china$pollgroup, fun="var"))
	
	# SD
	china$avgsd		<- rowMeans(sqrt(china[,tolist]))
	
	# Genvar
	china$genvar	<- unsplit(lapply(split(china1, china$pollgroup), genvar),china$pollgroup)
		
	##Attitude extremity
	china$attextreme	<- rowMeans(abs(china1 - .5), na.rm=T)

	# Midterm Measurement
	china[, c("avgsd2", "grpgain2", "t1knowcor2", "t12know", "t12knowcor", "attextreme2")] <- NA
	
# PK subset
	chinan <- china[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
					"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
					"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
					"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
					"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
					"t12knowcor", "attextreme2", "length", "timebtw")]
	
	save(chinan, file=paste0(basedir, "pk/data/chinan.Rdata"))
	save(chinan, file=paste0(basedir, "cdd/pkdat/chinan.Rdata"))
	
	# Kyu subset
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~	
	chikyu <- china[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
					"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
					"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
					"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
					"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
					"t12knowcor", "attextreme2", "length", "timebtw", 
					"t1att1", "t1att2", "t1att3", "t1att4", "t1att5", "t1att6", "t1att7", "t1att8", "t1att9",
					"t2att1", "t2att2", "t2att3", "t2att4", "t2att5", "t2att6", "t2att7", "t2att8", "t2att9")]
	
	save(chikyu, file="cdd/kyu/bypoll/chikyu.rdata", ascii=TRUE)
	
# DP Eval
	#dataset<-read.csv("/Users/seanwestwood/Desktop/dpeval/china05.csv")
	
	#dataset$eval3t <-dataset$d40505p
	#dataset$eval4t <-dataset$d40502p
	#dataset$eval5t <-dataset$d40505p
	#dataset$eval6t <-dataset$d4048p
	#dataset$eval8t <-dataset$d4047p
	#dataset$eval11t <-dataset$d40503p
	#dataset$eval14t <-dataset$d40506p
	#dataset$eval15t <-dataset$d4049p
	#pollModeratorFacets <- c("eval3","eval5") # each (eval3, eval4, eval5, eval12)
	#dataset$eval15D <- recode(dataset$eval15,"0:.4=0;.5:1=1;else=NA")