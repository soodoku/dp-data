#
# TX Utilities: SWEPCO
# Last Edited: 7.28.15
# Gaurav Sood
#

# Set Working dir.
setwd(basedir)
	
# Sourcing libs 
library(goji)
library(car)

# Sourcing common functions
source("func/func.R")
source("cdd/hlmFunc.R")

# Load data
swepco			<- foreign::read.dta(paste0(basedir, "cdd/data/Utilities/swepco/swepco_data/swepco2.dta"))
names(swepco)	<- tolower(names(swepco))	
	
# Participants Only
swepco 		<- subset(swepco, swepco$part==1)
	
## POLL Vars
swepco$numindices <- 7
swepco$pollid     <- 3000
swepco$country    <- 1
swepco$mode       <- 0
swepco$numitems   <- 5
#	swepco$caseid     #<- swepco$caseid
swepco$length     <- NA
swepco$timebtw    <- NA
	
## Group
swepco$pollgroup <- pgroup(swepco$group, swepco$pollid)
swepco$groupsize <- grpfun(rep(1, nrow(swepco)), swepco$pollgroup, fun="sum")
	
# Individual Level
# Sociodem
swepco$ppage	<- swepco$age
swepco$female	<- as.numeric(swepco$gender==2)
swepco$income	<- NA
swepco$hhincome	<- NA 
swepco$highinc	<- NA #70k or above
swepco$minority	<- as.numeric(swepco$race!=4)
swepco$educ4	<- recode(swepco$educ,"c(1,2) = 0; 3=.33; 4=.66; c(5,6)=1;else=NA")
	
# Polint and Readbrief
swepco$t1polint	<- NA
swepco$readbrief	<- NA

# Knowledge
swepco$knowa1cor <- pkcor(swepco$knowa1,swepco$knowa2)
swepco$knowb1cor <- pkcor(swepco$knowb1,swepco$knowb2)
swepco$knowc1cor <- pkcor(swepco$knowc1,swepco$knowc2)
swepco$knowd1cor <- pkcor(swepco$knowd1,swepco$knowd2)
swepco$knowe1cor <- pkcor(swepco$knowe1,swepco$knowe2)

# these knowledge indices match what's presented in "Deliberative Polling and Policy Outcomes: Electric Utility Issues in Texas"
swepco$t1know 		<- with(swepco, rowMeans(cbind(knowa1, knowb1, knowc1, knowd1, knowe1)))
swepco$t2know 		<- with(swepco, rowMeans(cbind(knowa2, knowb2, knowc2, knowd2, knowe2)))
swepco$t1knowlevel	<- mean(swepco$t1know)
	
knowindex      	 	<- with(swepco, data.frame(knowa1cor, knowb1cor, knowc1cor, knowd1cor, knowe1cor))
swepco$t1knowcor 	<- rowMeans(knowindex)
	
#Group Gain
swepco$grpgain <- groupgain(knowindex, swepco$pollgroup, nrow(swepco), swepco$numitems, swepco$groupsize)
	
# Group Level Vars
swepco$pminority		<- NA
swepco$pfemale			<- grpfun(swepco$female, swepco$pollgroup, fun="mean")
swepco$varfemale		<- swepco$pfemale*(1 - swepco$pfemale)
swepco$meant1know		<- grpfun(swepco$t1know, swepco$pollgroup, fun="mean")
swepco$meant1know_ind	<- (swepco$meant1know*swepco$groupsize - swepco$t1know )/(swepco$groupsize - 1)
swepco$meant2know		<- grpfun(swepco$t2know, swepco$pollgroup, fun="mean")
swepco$vareduc			<- grpfun(swepco$educ4, swepco$pollgroup, fun="var")
swepco$phighinc			<- NA
swepco$phighknow		<- NA
swepco$phigheduc 		<- NA
 
# ATTITUDES
#6. Importing Power
swepco$t1att1	<- zero1(ifelse(is.na(swepco$buypwr1), 5, swepco$buypwr1))
swepco$t2att1	<- zero1(ifelse(is.na(swepco$buypwr2), 5, swepco$buypwr2))

#8. Deregulation/Competition is good
swepco$t1att2	<- zero1(ifelse(is.na(swepco$compet1), 5, swepco$compet1))
swepco$t2att2	<- zero1(ifelse(is.na(swepco$compet2), 5, swepco$compet2))
	
#2. Conservation cor(cpl$reduce1,cpl$addfac1, use="na.or.complete")
tmp 			<- zero1(rowMeans(cbind(swepco$addfac1, swepco$reduce1), na.rm=TRUE))
swepco$t1att3	<- ifelse(is.na(tmp), .5, tmp)
tmp				<- zero1(rowMeans(cbind(swepco$addfact2, swepco$reduce2), na.rm=TRUE))
swepco$t2att3	<- ifelse(is.na(tmp), .5, tmp)
	
#3. Helping Low Income Customer cor(cpl$lowinc1,cpl$poor1, use="na.or.complete")
swepco$t1att4 <- with(swepco, rowMeans(cbind(zero1(lowinc1), zero1(poor1)), na.rm=T))
swepco$t2att4 <- with(swepco, rowMeans(cbind(zero1(lowinc2), zero1(poor2)), na.rm=T))
	
#4. Renewables cor(cbind(cpl$renew1, cpl$wind1), use="na.or.complete") #OPTION1 doesn't load
tmp <- zero1(rowMeans(cbind(swepco$renew1, swepco$wind1), na.rm=TRUE))
swepco$t1att5 <- ifelse(is.na(tmp), .5, tmp)
tmp <- zero1(rowMeans(cbind(swepco$renew2, swepco$wind2), na.rm=TRUE))
swepco$t2att5 <- ifelse(is.na(tmp), .5, tmp)
	
#1. Research cor(cpl$resch1, cpl$fedrch1, use="na.or.complete") 
tmp <- rowMeans(cbind(swepco$fedrch1, swepco$resch1), na.rm=TRUE)
swepco$t1att6 <- ifelse(is.na(tmp), 5, tmp)
tmp <- rowMeans(cbind(swepco$fedrch2, swepco$resch2), na.rm=TRUE)
swepco$t2att6 <- zero1(ifelse(is.na(tmp), 5, tmp))
	
#5. Fossil Fuels
swepco$t1att7 <- zero1(ifelse(is.na(swepco$fuels1), 5, swepco$fuels1))
swepco$t2att7 <- zero1(ifelse(is.na(swepco$fuels2), 5, swepco$fuels2))

# Attitude Extremity
swepco$attextreme <-  with(swepco, rowMeans(abs(cbind(t1att1, t1att2, t1att3, t1att4, t1att5, t1att6, t1att7) - .5), na.rm=TRUE))
	
##Generalized Variance Function
swepco1 <- swepco[,c("t1att1", "t1att2", "t1att3", "t1att4", "t1att5", "t1att6", "t1att7")]
swepco$genvar <- unsplit(lapply(split(swepco1, swepco$group), genvar),swepco$group)
	
##attitude variance - EUrelat1, EUscope1, commies1, favref1
swepco$vart1att1	<- grpfun(swepco$t1att1,	swepco$group, fun="var")
swepco$vart1att2	<- grpfun(swepco$t1att2,	swepco$group, fun="var")
swepco$vart1att3	<- grpfun(swepco$t1att3,	swepco$group, fun="var")
swepco$vart1att4	<- grpfun(swepco$t1att4,	swepco$group, fun="var")
swepco$vart1att5	<- grpfun(swepco$t1att5,	swepco$group, fun="var")
swepco$vart1att6	<- grpfun(swepco$t1att6,	swepco$group, fun="var")
swepco$vart1att7	<- grpfun(swepco$t1att7,	swepco$group, fun="var")
	
swepco$avgsd <- with(swepco, rowMeans(sqrt(cbind(vart1att1, vart1att2, vart1att3, vart1att4, vart1att5, vart1att6, vart1att7))))
	
# Outputting
# Guess Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
swepco$knowa1raw <- recode(swepco$source1, "1=1;c(2,3,4,5,6)=0")
swepco$knowb1raw <- recode(swepco$use1,    "3=1;c(1,2)=0")
swepco$knowc1raw <- recode(swepco$rt1, 	"1=1;c(2,3)=0")
swepco$knowd1raw <- recode(swepco$smog1,   "2=1;c(1,3)=0")
swepco$knowe1raw <- recode(swepco$setrt1,  "1=1;c(2,3,4,5,6)=0")
	
swepco$knowa2raw <- recode(swepco$source2, "1=1;c(2,3,4,5,6)=0")
swepco$knowb2raw <- recode(swepco$use2,    "3=1;c(1,2)=0")
swepco$knowc2raw <- recode(swepco$rt2, 	"1=1;c(2,3)=0")
swepco$knowd2raw <- recode(swepco$smog2,   "2=1;c(1,3)=0")
swepco$knowe2raw <- recode(swepco$setrt2,  "1=1;c(2,3,4,5,6)=0")
	
swepcopk <- c("caseid", 
			paste0("know", letters[1:5], "1"),
			paste0("know", letters[1:5], "2"),
			paste0("know", letters[1:5], "1cor"),
			paste0("know", letters[1:5], "1raw"),
			paste0("know", letters[1:5], "2raw"),
			"t1know", "t2know", "age", "pollgroup", "educ4","female")
	
swpirt <-swepco[, swepcopk]
write.csv(swpirt, file="guess/data/swpirt.csv")

# Pk Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Midterm Measurement
swepco[, c("avgsd2", "grpgain2", "t1knowcor2", "t12know", "t12knowcor", "attextreme2")] <- NA
	
swepcon <-swepco[,  c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
					"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
					"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
					"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
					"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
					"t12knowcor", "attextreme2", "length", "timebtw")]
	
#save(swepcon, file=paste0(basedir, "pk/data/swepcon.Rdata"))
save(swepcon, file=paste0(basedir, "cdd/data/pkdat/swepcon.Rdata"))
	
	
# Kyu subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~	
swepkyu <- swepco[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
					"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
					"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
					"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
					"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
					"t12knowcor", "attextreme2", "length", "timebtw", 
					"t1att1", "t1att2", "t1att3", "t1att4", "t1att5", "t1att6", "t1att7",
					"t2att1", "t2att2", "t2att3", "t2att4", "t2att5", "t2att6", "t2att7")]
	
save(swepkyu, file="cdd/data/agg/bypoll/swepkyu.rdata", ascii=TRUE)