#
#  WTU
#  Last Edited: 7.28.15
#  Gaurav Sood	
#

# Set Working dir 
setwd(basedir)

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/hlmFunc.R")

# Load data
wtu			<- foreign::read.dta(paste0(basedir, "cdd/data/Utilities/wt/wt_data/wt2.dta"))
names(wtu)	<- tolower(names(wtu))	
	
# Participants Only
wtu 		<- subset(wtu, wtu$part == 1)

## POLL Vars
wtu$numindices <- 7
wtu$pollid     <- 986
wtu$country    <- 1
wtu$mode       <- 0
wtu$numitems   <- 5
#	wtu$caseid     #<- wtu$caseid
wtu$length     <- NA
wtu$timebtw    <- NA
	
## Group
wtu$pollgroup <- pgroup(wtu$group, wtu$pollid)
wtu$groupsize <- grpfun(rep(1, nrow(wtu)), wtu$pollgroup, fun = "sum")
				
# Individual Level
# Sociodem
wtu$ppage	 <- wtu$age
wtu$female	 <- as.numeric(wtu$gender == 2)
wtu$income	 <- NA
wtu$hhincome <- NA 
wtu$highinc	 <- NA #70k or above
wtu$minority <- as.numeric(wtu$race != 4)
wtu$educ4	 <- recode(wtu$educ, "c(1, 2) = 0; 3 = .33; 4 = .66; c(5, 6) = 1; else = NA")

# Polint and Readbrief
wtu$t1polint	<- NA
wtu$readbrief	<- NA
	
# Knowledge
wtu$knowa1cor <- pkcor(wtu$knowa1, wtu$knowa2)
wtu$knowb1cor <- pkcor(wtu$knowb1, wtu$knowb2)
wtu$knowc1cor <- pkcor(wtu$knowc1, wtu$knowc2)
wtu$knowd1cor <- pkcor(wtu$knowd1, wtu$knowd2)
wtu$knowe1cor <- pkcor(wtu$knowe1, wtu$knowe2)
	
# these knowledge indices match what's presented in "Deliberative Polling and Policy Outcomes: Electric Utility Issues in Texas"
wtu$t1know 		<- with(wtu, rowMeans(cbind(knowa1, knowb1, knowc1, knowd1, knowe1)))
wtu$t2know 		<- with(wtu, rowMeans(cbind(knowa2, knowb2, knowc2, knowd2, knowe2)))
wtu$t1knowlevel	<- mean(wtu$t1know)
	
knowindex      	<- with(wtu, data.frame(knowa1cor, knowb1cor, knowc1cor, knowd1cor, knowe1cor))
wtu$t1knowcor 	<- rowMeans(knowindex)
	
#Group Gain
wtu$grpgain <- groupgain(knowindex, wtu$pollgroup, nrow(wtu), wtu$numitems, wtu$groupsize)
	
# Group Level Vars
wtu$pminority		<- NA
wtu$pfemale			<- grpfun(wtu$female, wtu$pollgroup, fun = "mean")
wtu$varfemale		<- wtu$pfemale*(1 - wtu$pfemale)
wtu$meant1know		<- grpfun(wtu$t1know, wtu$pollgroup, fun = "mean")
wtu$meant1know_ind	<- (wtu$meant1know*wtu$groupsize - wtu$t1know )/(wtu$groupsize - 1)
wtu$meant2know		<- grpfun(wtu$t2know, wtu$pollgroup, fun = "mean")
wtu$vareduc			<- grpfun(wtu$educ4, wtu$pollgroup, fun = "var")
wtu$phighinc		<- NA
wtu$phighknow		<- NA
wtu$phigheduc 		<- NA
	
# ATTITUDES
#6. Importing Power
wtu$t1att1	<- zero1(ifelse(is.na(wtu$buypwr1), 5, wtu$buypwr1))
wtu$t2att1	<- zero1(ifelse(is.na(wtu$buypwr2), 5, wtu$buypwr2))

#8. Deregulation/Competition is good
wtu$t1att2	<- zero1(ifelse(is.na(wtu$compet1), 5, wtu$compet1))
wtu$t2att2	<- zero1(ifelse(is.na(wtu$compet2), 5, wtu$compet2))

#2. Conservation cor(cpl$reduce1,cpl$addfac1, use="na.or.complete")
tmp 			<- zero1(rowMeans(cbind(wtu$addfac1, wtu$reduce1), na.rm = TRUE))
wtu$t1att3	<- ifelse(is.na(tmp), .5, tmp)
tmp				<- zero1(rowMeans(cbind(wtu$addfact2, wtu$reduce2), na.rm = TRUE))
wtu$t2att3	<- ifelse(is.na(tmp), .5, tmp)
	
#3. Helping Low Income Customer cor(cpl$lowinc1,cpl$poor1, use="na.or.complete")
#wtu$t1att4 <- zero1(ifelse(is.na(wtu$needto1), 5, wtu$needto1))
#wtu$t2att4 <- zero1(ifelse(is.na(wtu$needto2), 5, wtu$needto2))
wtu$t1att4 <- with(wtu, rowMeans(cbind(zero1(lowinc1), zero1(poor1)), na.rm = T))
wtu$t2att4 <- with(wtu, rowMeans(cbind(zero1(lowinc1), zero1(poor1)), na.rm = T))

#4. Renewables cor(cbind(cpl$renew1, cpl$wind1), use="na.or.complete") #OPTION1 doesn't load	
tmp <- zero1(rowMeans(cbind(wtu$renew1, wtu$wind1), na.rm = TRUE))
wtu$t1att5 <- ifelse(is.na(tmp), .5, tmp)
tmp <- zero1(rowMeans(cbind(wtu$renew2, wtu$wind2), na.rm = TRUE))
wtu$t2att5 <- ifelse(is.na(tmp), .5, tmp)

#1. Research cor(cpl$resch1, cpl$fedrch1, use="na.or.complete") 	
tmp <- rowMeans(cbind(wtu$fedrch1, wtu$resch1), na.rm = TRUE)
wtu$t1att6 <- ifelse(is.na(tmp), 5, tmp)
tmp <- rowMeans(cbind(wtu$fedrch2, wtu$resch2), na.rm = TRUE)
wtu$t2att6 <- zero1(ifelse(is.na(tmp), 5, tmp))

#5. Fossil Fuels	
wtu$t1att7 <- zero1(ifelse(is.na(wtu$fuels1), 5, wtu$fuels1))
wtu$t2att7 <- zero1(ifelse(is.na(wtu$fuels2), 5, wtu$fuels2))
	
# Attitude Extremity
wtu$attextreme <-  with(wtu, rowMeans(abs(cbind(t1att1, t1att2, t1att3, t1att4, t1att5, t1att6, t1att7) - .5), na.rm = TRUE))
	
##Generalized Variance Function
wtu1 <- wtu[,c("t1att1", "t1att2", "t1att3", "t1att4", "t1att5", "t1att6", "t1att7")]
wtu$genvar <- unsplit(lapply(split(wtu1, wtu$group), genvar),wtu$group)
	
##attitude variance - EUrelat1, EUscope1, commies1, favref1
wtu$vart1att1	<- grpfun(wtu$t1att1,	wtu$group, fun = "var")
wtu$vart1att2	<- grpfun(wtu$t1att2,	wtu$group, fun = "var")
wtu$vart1att3	<- grpfun(wtu$t1att3,	wtu$group, fun = "var")
wtu$vart1att4	<- grpfun(wtu$t1att4,	wtu$group, fun = "var")
wtu$vart1att5	<- grpfun(wtu$t1att5,	wtu$group, fun = "var")
wtu$vart1att6	<- grpfun(wtu$t1att6,	wtu$group, fun = "var")
wtu$vart1att7	<- grpfun(wtu$t1att7,	wtu$group, fun = "var")
	
wtu$avgsd <- with(wtu, rowMeans(sqrt(cbind(vart1att1, vart1att2, vart1att3, vart1att4, vart1att5, vart1att6, vart1att7))))

# Outputting
# ~~~~~~~~~~~~~~~~~~~

# Guess Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
wtu$knowa1raw <- recode(wtu$source1, "3 = 1; c(1, 2, 4, 5, 6) = 0")
wtu$knowb1raw <- recode(wtu$use1,    "1 = 1; c(2, 3) = 0")
wtu$knowc1raw <- recode(wtu$rt1, 	 "1 = 1; c(2, 3) = 0")
wtu$knowd1raw <- recode(wtu$smog1,   "2 = 1; c(1, 3) = 0")
wtu$knowe1raw <- recode(wtu$setrt1,  "1 = 1; c(2, 3, 4, 5, 6) = 0")
	
wtu$knowa2raw <- recode(wtu$source2, "3 = 1; c(1, 2, 4, 5, 6) = 0")
wtu$knowb2raw <- recode(wtu$use2,    "1 = 1; c(2, 3) = 0")
wtu$knowc2raw <- recode(wtu$rt2, 	 "1 = 1; c(2, 3) = 0")
wtu$knowd2raw <- recode(wtu$smog2,   "2 = 1; c(1, 3) = 0")
wtu$knowe2raw <- recode(wtu$setrt2,  "1 = 1; c(2, 3, 4, 5, 6)=0")
		
wtupk <- c("caseid", 
			paste0("know", letters[1:5], "1"),
			paste0("know", letters[1:5], "2"),
			paste0("know", letters[1:5], "1cor"),
			paste0("know", letters[1:5], "1raw"),
			paste0("know", letters[1:5], "2raw"),
			"t1know", "t2know", "age", "pollgroup", "educ4","female")
	
wtuirt <-wtu[, wtupk]
write.csv(wtuirt, file = "guess/data/wtuirt.csv")

# PK Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Midterm Measurement
wtu[, c("avgsd2", "grpgain2", "t1knowcor2", "t12know", "t12knowcor", "attextreme2")] <- NA
	
wtun <- wtu[,  c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
					"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
					"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
					"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
					"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
					"t12knowcor", "attextreme2", "length", "timebtw")]
	
#save(wtun, file=paste0(basedir, "pk/data/wtun.Rdata"))
save(wtun, file = paste0(basedir, "cdd/data/pkdat/wtun.Rdata"))

# Kyu subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~	
wtukyu <- wtu[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
					"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
					"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
					"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
					"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
					"t12knowcor", "attextreme2", "length", "timebtw", 
					"t1att1", "t1att2", "t1att3", "t1att4", "t1att5", "t1att6", "t1att7",
					"t2att1", "t2att2", "t2att3", "t2att4", "t2att5", "t2att6", "t2att7")]
	
save(wtukyu, file = "cdd/data/agg/bypoll/wtukyu.rdata", ascii = TRUE)
	