#
# Aggregate DP Polls Data (Common Cols.)
#	1. Redo group level variables
#	2. Fix Errors
#

# Set Working dir.
setwd(basedir)

# Sourcing Common Functions
library(goji)

# Load and Merge
load("cdd/data/pkdat/gaurav.Rdata")
load("cdd/data/nuri/nuri.Rdata")

# Issue-specific Knowledge issue
nuri[, c("t1knowr", "t2knowr", "t1knowrcor", "grpgainr")] <- NA
dpoll <- rbind(gaurav, nuri)

# Add Pollnames
# ~~~~~~~~~~~~~~~~~~~
polls <- read.csv("cdd/meta_data/poll_details/pollid_pollname.csv")
agg_data	<- merge(dpoll, polls, by="pollid", all.x=T, all.y=F)

# Straightening out educ4
agg_data$educ4 <- round(agg_data$educ4, 2)

# Number of Issues
#BTP 2005 = 2; New Haven =2; EU =4
agg_data$numissues <- 1
agg_data$numissues[agg_data$pollid == 91] <- 2
agg_data$numissues[agg_data$pollid == 28] <- 4
agg_data$numissues[agg_data$pollid == 97] <- 2

## Nuking out the 112 year olds
agg_data[agg_data$pollid  ==  91 & agg_data$ppage  == 112, ]$ppage <- NA

## Straightening out t1polint
agg_data[agg_data$pollid  == 25,]$t1polint  <- car::recode(agg_data[agg_data$pollid  == 25, ]$t1polint, ".25 = .33; .5 = .66; .75 = 1")

## Group Vars
agg_data$groupsize  <- grpfun(rep(1, nrow(agg_data)), agg_data$pollgroup, fun = "sum")
agg_data$pfemale    <- with(agg_data, grpfun(female,   pollgroup, fun = "mean"))
agg_data$pminority  <- with(agg_data, grpfun(minority, pollgroup, fun = "mean"))
agg_data$varfemale  <- (agg_data$pfemale)*(1- agg_data$pfemale)
agg_data$sdfemale   <- sqrt(agg_data$varfemale)
agg_data$vareduc    <- with(agg_data, grpfun(educ4,      pollgroup, fun = "var"))
agg_data$sdeduc     <- sqrt(agg_data$vareduc)
agg_data$meaned     <- with(agg_data, grpfun(educ4,      pollgroup, fun = "mean"))
agg_data$meanage    <- with(agg_data, grpfun(ppage,      pollgroup, fun = "mean"))
agg_data$phighinc   <- with(agg_data, grpfun(highinc,    pollgroup, fun = "mean"))
agg_data$meanxtreme <- with(agg_data, grpfun(attextreme, pollgroup, fun = "mean")) 

agg_data$pfemale_ind <- (agg_data$pfemale*agg_data$groupsize -  agg_data$female)/(agg_data$groupsize - 1)
	
# ADDING ENTROPY MEASURE
#*************************
grouptropy1 <- unsplit(lapply(split(agg_data$female, agg_data$pollgroup), function(a) entropy(c(a),2)), agg_data$pollgroup)
grouptropy2 <- unsplit(lapply(split(agg_data$minority, agg_data$pollgroup), function(a) entropy(c(a),2)), agg_data$pollgroup)
grouptropy3 <- unsplit(lapply(split(agg_data$educ4, agg_data$pollgroup), function(a) entropy(c(a),4)), agg_data$pollgroup)

agg_data$entropy <- rowSums(cbind(grouptropy1, grouptropy2, grouptropy3), na.rm=T)

## REDO THE GROUP GAIN VARIABLE 
##*******************************
agg_data$grpgain  <- (agg_data$grpgain*agg_data$numitems)/((1 - agg_data$t1knowcor)*agg_data$numitems)
agg_data$grpgain2 <- (agg_data$grpgain2*agg_data$numitems)/((1 - agg_data$t12knowcor)*agg_data$numitems)		
		
## Normalized genvar <- gaurav1$genvar/gaurav1$numindices
## PK  
agg_data$meant1know 	<- with(agg_data, grpfun(t1know,    pollgroup, fun = "mean"))
agg_data$meant1knowcor  <- with(agg_data, grpfun(t1knowcor, pollgroup, fun = "mean"))
agg_data$t1knowlevelcor <- with(agg_data, grpfun(t1knowcor, pollid, fun = "mean"))
agg_data$meant1know_ind <- (agg_data$meant1know*agg_data$groupsize -  agg_data$t1know )/ (agg_data$groupsize - 1)
agg_data$meant1knowcor_ind <- (agg_data$meant1knowcor*agg_data$groupsize -  agg_data$t1knowcor)/ (agg_data$groupsize - 1)
agg_data$meant2know 	<- grpfun(agg_data$t2know, agg_data$pollgroup, fun = "mean")
agg_data$knowgain 		<- agg_data$t2know - agg_data$t1know
agg_data$knowgain2 		<- agg_data$t2know - agg_data$t1knowcor
agg_data$t2knowlevel 	<- with(agg_data, grpfun(t2know, pollid,fun = "mean"))

logpk <- agg_data$t1knowcor
logpk[agg_data$t1knowcor <= 0] <- .0001
agg_data$logpk <- log(logpk)
	
loggain <- agg_data$grpgain
loggain[agg_data$grpgain <= 0] <- .0001
agg_data$loggain <- log(loggain)
	
agg_data$tobitpk <- as.numeric(agg_data$t1knowcor > .6)

# Issue-specific pk issues
agg_data$t1knowr[!(agg_data$pollname %in% c('AU Monarchy', 'UK Crime'))] <- agg_data$t1know[!(agg_data$pollname %in% c('AU Monarchy', 'UK Crime'))] 
agg_data$t1knowrcor[!(agg_data$pollname %in% c('AU Monarchy', 'UK Crime'))] <- agg_data$t1knowcor[!(agg_data$pollname %in% c('AU Monarchy', 'UK Crime'))] 
agg_data$t2knowr[!(agg_data$pollname %in% c('AU Monarchy', 'UK Crime'))] <- agg_data$t2know[!(agg_data$pollname %in% c('AU Monarchy', 'UK Crime'))] 
	
agg_data$grpgainr[agg_data$pollname %in% c('UK Crime')]     <-  with(agg_data[agg_data$pollname %in% c('UK Crime'), ], (grpgainr*4)/((1 - t1knowcor)*4))
agg_data$grpgainr[agg_data$pollname %in% c('AU Monarchy')]  <-  with(agg_data[agg_data$pollname %in% c('AU Monarchy'), ], (grpgainr*8)/((1 - t1knowcor)*8))
	
agg_data$grpgainr[!(agg_data$pollname %in% c('AU Monarchy', 'UK Crime'))] <- agg_data$grpgain[!(agg_data$pollname %in% c('AU Monarchy', 'UK Crime'))] 
	

agg_data$meant1knowr 	 <- with(agg_data, grpfun(t1knowr,    pollgroup, fun = "mean"))
agg_data$meant1knowrcor  <- with(agg_data, grpfun(t1knowrcor, pollgroup, fun = "mean"))
agg_data$t1knowlevelrcor <- with(agg_data, grpfun(t1knowrcor, pollid, fun = "mean"))
agg_data$knowgainr 		 <- agg_data$t2knowr - agg_data$t1knowr
agg_data$knowgainr2 	 <- agg_data$t2knowr - agg_data$t1knowrcor

# Hack for Nuri's Mess
# BTP 2004 GE
agg_data <- subset(agg_data, !(agg_data$pollid == 94 & (agg_data$t2know == 0 | is.na(agg_data$attextreme))))

# Trinary Education
agg_data$educ3 <- car::recode(agg_data$educ4, "1=1;0=0;NA=NA; else=.5")

# San Mateo seems to be listed as online
agg_data$mode[agg_data$pollname == 'San Mateo'] <- 0

# Save file
save(agg_data, file = "cdd/data/pkdat/agg_data.Rdata")

	
##### ~~~~
# Checking
load("pk/data/hlm_files/agg_data.Rdata")
### Subset of Polls ######
##Readbrief: #28, 92, 96
#t1polint :  #20, 23, 25, 26, 92, 93, 97
	
# Read Brief Data, Pol. Interest Data
intagg <- subset(agg_data, (pollid  ==  20 | pollid  ==  23 | pollid  ==  25 | pollid  ==  26 | pollid  ==  92 | pollid  ==  93  | 
						pollid  ==  97))
briefdata <- subset(agg_data, (pollid  ==  28 | pollid  ==  92 | pollid  ==  96))
