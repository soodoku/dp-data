#
#  Europolis
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
eu09 <-	foreign::read.spss("cdd/data/eu_2009/europe_data/EUROPOLIS-DATA-NEW-OCT-2010.sav", to.data.frame=TRUE, use.value.labels=FALSE)
names(eu09) <- tolower(names(eu09))

# Subset on participants
eu09 <- subset(eu09, group_t1bis == 1)

#L3 Variables
eu09$pollid <- 71
eu09$mode <- 0
eu09$country <-  0
eu09$length <- NA
eu09$timebtw <- NA

#Caseid
eu09$caseid <- paste0(eu09$pollid, eu09$uniqueid)

## Group
eu09$pollgroup <- paste0(eu09$pollid, eu09$small_groupw3)
eu09$groupsize <- grpfun(rep(1, nrow(eu09)), eu09$pollgroup, fun = "sum")

### SocioDem ###
eu09$ppage 	  	<- 2009 - eu09$age1
eu09$female   	<- as.numeric(eu09$sex1 ==2)
eu09$hhincome 	<- NA
eu09$highinc  	<- NA
eu09$educ4 	  	<- with(eu09, ifelse(educ1==0, ifelse(2010-age1>35, 35, 2010-age1), educ1)/35)
eu09$educollege   <- NA
eu09$minority     <- with(eu09, ifelse(birth1 < 997, ifelse(birth1 > 1, 1, 0), 1) + ifelse(is.na(parentsbirth1), 1, ifelse(parentsbirth1 > 1, 1, 0))) > 0
	
eu09$pminority	<- grpfun(eu09$minority, eu09$pollgroup, fun = "mean")		
eu09$pfemale 	<- grpfun(eu09$female, eu09$pollgroup, fun = "mean")
eu09$varfemale	<- (eu09$pfemale)*(1 - eu09$pfemale)
eu09$phigheduc	<- NA
eu09$vareduc	<- grpfun(eu09$educ4, eu09$pollgroup, fun = "var")
eu09$phighinc	<- NA

## Political Interest and Briefing Material
eu09$t1polint <- NA
eu09$readbrief <- NA

# Knowledge
answer.key <- c(2, 1, 1, 2, 1, 1, 4, 1, 2)
# QUESTION TOPICS: EU, EU, EU, Imm, Imm, Imm, CC, CC, CC
# Note from pete: people know more about immigration than climate change
# Dataset q Numbering doesn't match questionnaire numbering
	
# T1
eu09$t1pk1raw <-	recode(as.numeric(eu09$v1q43), "2=1; c(1, 3, 4) = 0; 5 = NA")
eu09$t1pk2raw <-	recode(as.numeric(eu09$v1q44), "1=1; c(2, 3, 4) = 0; 5 = NA")
#eu09$t1pk3 <-	recode(as.numeric(eu09$v1q45), "2=1; c(1, 3, 4) = 0; 5 = NA") # No such item? weird
eu09$t1pk4raw <-	recode(as.numeric(eu09$v1q46), "2=1; c(1, 3, 4) = 0; 5 = NA")
eu09$t1pk5raw <-	recode(as.numeric(eu09$v1q47), "1=1; c(2, 3, 4) = 0; 5 = NA")
#eu09$t1pk6 <-	recode(as.numeric(eu09$v1q48), "2=1; c(1, 3, 4) = 0; 5 = NA") # No such item? weird
eu09$t1pk7raw <-	recode(as.numeric(eu09$v1q49), "4=1; c(1, 2, 3) = 0; 5 = NA")
eu09$t1pk8raw <-	recode(as.numeric(eu09$v1q50), "1=1; c(2, 3, 4) = 0; 5 = NA")
#eu09$t1pk9 <-	recode(as.numeric(eu09$v1q51), "2=1; c(1, 3, 4) = 0; 5 = NA") # No such item? weird

# T2
eu09$t2pk1raw <-	recode(as.numeric(eu09$v2q43), "2=1; c(1, 3, 4) = 0; 5 = NA")
eu09$t2pk2raw <-	recode(as.numeric(eu09$v2q44), "1=1; c(2, 3, 4) = 0; 5 = NA")
eu09$t2pk3raw <-	recode(as.numeric(eu09$v2q45), "1=1; c(2, 3, 4) = 0; 5 = NA") 
eu09$t2pk4raw <-	recode(as.numeric(eu09$v2q46), "2=1; c(1, 3, 4) = 0; 5 = NA")
eu09$t2pk5raw <-	recode(as.numeric(eu09$v2q47), "1=1; c(2, 3, 4) = 0; 5 = NA")
eu09$t2pk6raw <-	recode(as.numeric(eu09$v2q48), "1=1; c(2, 3, 4) = 0; 5 = NA") 
eu09$t2pk7raw <-	recode(as.numeric(eu09$v2q49), "4=1; c(1, 2, 3) = 0; 5 = NA")
eu09$t2pk8raw <-	recode(as.numeric(eu09$v2q50), "1=1; c(2, 3, 4) = 0; 5 = NA")
eu09$t2pk9raw <-	recode(as.numeric(eu09$v2q51), "2=1; c(1, 3, 4) = 0; 5 = NA") 

# T3
eu09$t3pk1raw <-	recode(as.numeric(eu09$v3q43), "2=1; c(1, 3, 4) = 0; 5 = NA")
eu09$t3pk2raw <-	recode(as.numeric(eu09$v3q44), "1=1; c(2, 3, 4) = 0; 5 = NA")
eu09$t3pk3raw <-	recode(as.numeric(eu09$v3q45), "1=1; c(2, 3, 4) = 0; 5 = NA") 
eu09$t3pk4raw <-	recode(as.numeric(eu09$v3q46), "2=1; c(1, 3, 4) = 0; 5 = NA")
eu09$t3pk5raw <-	recode(as.numeric(eu09$v3q47), "1=1; c(2, 3, 4) = 0; 5 = NA")
eu09$t3pk6raw <-	recode(as.numeric(eu09$v3q48), "1=1; c(2, 3, 4) = 0; 5 = NA") 
eu09$t3pk7raw <-	recode(as.numeric(eu09$v3q49), "4=1; c(1, 2, 3) = 0; 5 = NA")
eu09$t3pk8raw <-	recode(as.numeric(eu09$v3q50), "1=1; c(2, 3, 4) = 0; 5 = NA")
eu09$t3pk9raw <-	recode(as.numeric(eu09$v3q51), "2=1; c(1, 3, 4) = 0; 5 = NA") 

# Agg indices
t1raw 	<- paste0("t1pk", c(1,2,4,5,7,8), "raw")
t2raw   <- paste0("t2pk", c(1,2,4,5,7,8), "raw")
t3raw 	<- paste0("t3pk", c(1,2,4,5,7,8), "raw")

t1 		<- paste0("t1pk", c(1,2,4,5,7,8))
t2 		<- paste0("t2pk", c(1,2,4,5,7,8))
t3 		<- paste0("t3pk", c(1,2,4,5,7,8))

eu09[,t1] <- nona(eu09[, t1raw])
eu09[,t2] <- nona(eu09[, t2raw])
eu09[,t3] <- nona(eu09[, t3raw])

# Know vars
eu09$t1know		<- rowMeans(eu09[, t1])
eu09$t1knowcor	<- NA
eu09$t2know		<- rowMeans(eu09[, t3])
eu09$t1knowlevel  <- mean(eu09$t1know)
eu09$highknow 	<- (eu09$t1know > fivenum(eu09$t1know)[4])
eu09$meant1know   <- grpfun(eu09$t1know, eu09$pollgroup, fun = "mean")
eu09$meant2know   <- grpfun(eu09$t2know, eu09$pollgroup, fun = "mean")
eu09$phighknow    <- grpfun(eu09$highknow, eu09$pollgroup, fun = "mean")
eu09$meant1know_ind <- with(eu09,(meant1know*groupsize - t1know )/(groupsize - 1))

#Group Gain
eu09$numitems <- 6		
knowindex <- eu09[,t1]
eu09$grpgain <- groupgain(knowindex, eu09$pollgroup, nrow(eu09), eu09$numitems, eu09$groupsize)
	
# Attitude Indices
# ~~~~~~~~~~~~~~~~~~~~~~~
eu09$numindices <- 2
# Reduce illegal immigration
# eu09$sendback <- zero1(eu09$v1q8a, 0, 10) - Only t1 and t4

# Reinforcing border controls
# V1Q11_1;  V2Q11_1;  V3Q11_1;  V4Q11_1

eu09$imm1 <- zero1(eu09$v1q11_1) 
eu09$imm2 <- zero1(eu09$v3q11_1)

# Climate Change
eu09$cc1 <- zero1(eu09$v1q21, 10, 0)
eu09$cc2 <- zero1(eu09$v3q21, 10, 0)

# paste0("v2q27_", c(5, 8, 9))-- only available at t2, and t3: cc2 <- 
# T2.cc.EU.sh.incr.cc.targets <- reorient(rescale(V2Q23))
# T2.cc.min.greenhouse <- reorient(rescale(V2Q24))
# T2.cc.max.country.solo.effort.against.cc <- reorient(rescale(V2Q25))
# T2.cc.energy.efficiency <- rescale(V2Q27_2)
# T2.cc.cap.n.trade <- rescale(V2Q27_7)

##Att. Extremity
eu09$attextreme <- rowMeans(abs(cbind(eu09$cc1, eu09$imm1) - .5), na.rm = TRUE)

##############Attitude Variance
fromlist <- c("cc1", "imm1")
tolist   <- paste("var", fromlist, sep = "")
eu09[,tolist] <- sapply(eu09[,fromlist], function(x) grpfun(x, eu09$pollgroup, fun = "var"))

eu09$avgsd <-  with(eu09, rowMeans(sqrt(cbind(varcc1, varimm1))))

# For arrival - just NA it.
eu09$avgsd2 <- eu09$grpgain2 <-  eu09$t1knowcor2 <- eu09$t12know <- eu09$t12knowcor <- eu09$attextreme2 <- NA

# Genvar
eu09ind <- eu09[, c("cc1","imm1")]
eu09$genvar <- unsplit(lapply(split(eu09ind, eu09$pollgroup), genvar), eu09$pollgroup)

# Guess out
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#eu09irt <- eu09[!is.na(eu09$part),c(t1, t3, t1raw, t3raw, "female")]
#write.csv(eu09irt, file="guess/data/bypoll/eu2009irt.csv")

# PK Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`	
common.cols <- c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems", "pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
			"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", "genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
			"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know", "t12knowcor", "attextreme2", "length", "timebtw")

# Save Data
eu2009 <- eu09[, c(common.cols)]
save(eu2009, file = "cdd/data/pkdat/eu2009.Rdata")
	
## Kyu Data ##
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
eu09kyu <- eu09[, c(common.cols, "cc1", "cc2", "imm1", "imm2")]
save(eu09kyu, file = "cdd/data/agg/bypoll/eu09kyu.rdata")
