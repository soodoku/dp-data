#
#  CPL
#  Last Edited: 4.05.14   
#  Gaurav Sood
#

# Set Working dir.
setwd(basedir)

# Sourcing libs 
library(goji)
library(car)

# Sourcing common functions
source("func/func.R")
source("cdd/hlmFunc.R")

## SPSS to R, Participants Only
cpl <- foreign::read.spss("cdd/data/Utilities/cpl/cpl2.sav", to.data.frame=TRUE)

#L3 Variables
cpl$pollid  <- 29
cpl$mode    <- 0
cpl$country <-  1
cpl$length  <- NA
cpl$timebtw <- NA

#Caseid
cpl$caseid <- NA
cpl$caseid <-paste(cpl$pollid[1],10000+seq(1,nrow(cpl)), sep="")

## Group
cpl$pollgroup <- pgroup(cpl$group, cpl$pollid)
cpl$groupsize = grpfun(rep(1,length(cpl)), cpl$pollgroup, fun="sum")

### SocioDem ###
cpl$ppage  <- cpl$age
cpl$female  <- as.numeric(cpl$gender ==2)
cpl$hhincome <- cpl$income
cpl$highinc  <- (cpl$hhincome > 4) 
cpl$educ4  <- car::recode(cpl$educ, "c(1,2)=0; 3=.33; 4=.66; c(5,6)=1")
cpl$educollege <- ifelse(cpl$educ4 > .76, 1,0)
cpl$minority <- as.numeric(cpl$race!=4)

cpl$pminority <- grpfun(cpl$minority, cpl$pollgroup, fun="mean")
cpl$pfemale <- grpfun(cpl$female, cpl$pollgroup, fun="mean")
cpl$varfemale <- (cpl$pfemale)*(1 - cpl$pfemale)
cpl$phigheduc <- grpfun(cpl$educollege, cpl$pollgroup, fun="mean")
cpl$vareduc <- grpfun(cpl$educ4, cpl$pollgroup, fun="var")
cpl$phighinc <- grpfun(cpl$highinc, cpl$pollgroup, fun="mean")

## Political Interest and Briefing Material
cpl$t1polint <- NA
cpl$readbrief <- NA

## Knowledge
#source1  = Which sources produces most electricity T1 (Q13)
#knowA1   = Checkpoint:  Did R answer SOURCE1 correctly?
#source2  = Which sources produces most electricity T2 (Q13)
#knowA2   = Checkpoint:  Did R answer SOURCE2 correctly?
#use1     = Which group uses most electricity? T1 (Q14)
#knowB1   = Checkpoint:  Did R answer USE1 correctly?
#use2     = Which group uses most electricity? T2 (Q14)
#knowB2   = Checkpoint:  Did R answer USE2 correctly?
#rt1      = Which group pays highest rate T1 (Q15)
#knowC1   = Checkpoint:  Did R answer RT1 correctly?
#rt2      = Which group pays highest rate T2 (Q15)
#knowC2   = Checkpoint:  Did R answer RT2 correctly?
#smog1    = Which causes the most air emissions T1 (Q16)
#knowD1   = Checkpoint:  Did R answer SMOG1 correctly?
#smog2    = Which causes the most air emissions T2 (Q16)
#knowD2   = Checkpoint:  Did R answer SMOG2 correctly?
#profit1  = Utility profit on fuel T1 (Q17)
#knowF1   = Checkpoint:  Did R answer PROFIT1 correctly?
#profit2  = Utility profit on fuel T2 (Q17)
#knowF2   = Checkpoint:  Did R answer PROFIT2 correctly?
#setrt1   = Agency that sets electric rate T1 (Q18)
#knowE1   = Checkpoint:  Did R answer SETRT1 correctly?
#setrt2   = Agency that sets electric rate T2 (Q18)
#knowE2   = Checkpoint:  Did R answer SETRT2 correctly?
#pctful1  = Percent of bill to pay for fuel T1 (Q19)
#knowG1   = Checkpoint:  Did R answer PCTFUL1 correctly?
#pctful2  = Percent of bill to pay for fuel T2 (Q19)
#knowG2   = Checkpoint:  Did R answer PCTFUL2 correctly?

## Corrected Facts
cpl$knowa1c <- pkcor(cpl$knowa1, cpl$knowa2)
cpl$knowb1c <- pkcor(cpl$knowb1, cpl$knowb2)
cpl$knowc1c <- pkcor(cpl$knowc1, cpl$knowc2)
cpl$knowd1c <- pkcor(cpl$knowd1, cpl$knowd2)
cpl$knowe1c <- pkcor(cpl$knowe1, cpl$knowe2)
cpl$knowf1c <- pkcor(cpl$knowf1, cpl$knowf2)
cpl$knowg1c <- pkcor(cpl$knowg1, cpl$knowg2)

cpl$t1know <- with(cpl, rowMeans(cbind(knowa1, knowb1, knowc1, knowd1, knowe1, knowf1, knowg1)))
cpl$t1knowcor <- with(cpl, rowMeans(cbind(knowa1c, knowb1c, knowc1c, knowd1c, knowe1c, knowf1c, knowg1c)))
cpl$t2know <- with(cpl, rowMeans(cbind(knowa2, knowb2, knowc2, knowd2, knowe2, knowf2, knowg2)))
cpl$t1knowlevel <- mean(cpl$t1know)
cpl$highknow <- (cpl$t1know > fivenum(cpl$t1know)[4])
cpl$meant1know <- grpfun(cpl$t1know, cpl$pollgroup, fun="mean")
cpl$meant2know <- grpfun(cpl$t2know, cpl$pollgroup, fun="mean")
cpl$phighknow <- grpfun(cpl$highknow, cpl$pollgroup, fun="mean")
cpl$meant1know_ind <- (cpl$meant1know*cpl$groupsize - cpl$t1know )/ (cpl$groupsize - 1)

#Group Gain
cpl$numitems <- 7
knowindex <- with(cpl, data.frame(knowa1c, knowb1c, knowc1c, knowd1c, knowe1c, knowf1c, knowg1c))
cpl$grpgain <- groupgain(knowindex, cpl$pollgroup, nrow(cpl), cpl$numitems, cpl$groupsize)

## Arrival Adjusted
cpl$t1knowcor2 <- NA
cpl$t12know <- NA
cpl$t12knowcor <- NA
cpl$grpgain2 <- NA

# Attitude
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cpl$numindices <- 7

#1. Research cor(cpl$resch1, cpl$fedrch1, use="na.or.complete") 
cpl$t1res <- with(cpl, rowMeans(cbind(zero1(resch1), zero1(fedrch1)), na.rm=T))
cpl$t2res <- with(cpl, rowMeans(cbind(zero1(resch2), zero1(fedrch2)), na.rm=T))
#2. Conservation cor(cpl$reduce1,cpl$addfac1, use="na.or.complete")
cpl$t1cons <- with(cpl, rowMeans(cbind(zero1(addfac1), zero1(reduce1)), na.rm=T))
cpl$t2cons <- with(cpl, rowMeans(cbind(zero1(addfac2), zero1(reduce2)), na.rm=T))
#3. Helping Low Income Customer cor(cpl$lowinc1,cpl$poor1, use="na.or.complete")
cpl$t1poor <- with(cpl, rowMeans(cbind(zero1(lowinc1), zero1(poor1)), na.rm=T))
cpl$t2poor <- with(cpl, rowMeans(cbind(zero1(lowinc2), zero1(poor2)), na.rm=T))
#4. Renewables cor(cbind(cpl$renew1, cpl$wind1), use="na.or.complete") #OPTION1 doesn't load
cpl$t1renew <- with(cpl, rowMeans(cbind(zero1(renew1), zero1(wind1)), na.rm=T))
cpl$t2renew <- with(cpl, rowMeans(cbind(zero1(renew2), zero1(wind2)), na.rm=T))
#5. Fossil Fuels
cpl$t1fossil <- zero1(cpl$fuels1)
cpl$t2fossil <- zero1(cpl$fuels2)
#6. Importing Power
cpl$t1buypwr <- zero1(cpl$buypwr1)
cpl$t2buypwr <- zero1(cpl$buypwr2)
#7. Doesn't work. Test Index: Values or Policy?  Short term v Long term cor(cpl$costs1,cpl$stlteq1, use="na.or.complete") 
#cpl$t1test <- with(cpl, rowMeans(cbind(zero1(costs1), zero1(stlteq1)), na.rm=T))

#8. Deregulation 
cpl$t1compet <- zero1(cpl$compet1)
cpl$t2compet <- zero1(cpl$compet2)

cpl$attextreme <- with(cpl, rowMeans(abs(cbind(t1res, t1cons,t1poor, t1renew, t1fossil,t1buypwr, t1compet) -.5), na.rm=TRUE))

cpl$attextreme2 <- NA

# Att var, and sd

vars <- with(cpl, data.frame(t1res, t1cons, t1poor, t1renew, t1fossil, t1buypwr, t1compet))

temp <- vars
for(i in 1:length(vars))
{
temp[,i] <- grpfun(vars[,i], cpl$pollgroup, fun="var")
}
cpl$avgsd <- rowMeans(sqrt(temp))
cpl$avgsd2 <- NA
cpl$genvar <- unsplit(lapply(split(vars, cpl$pollgroup), genvar),cpl$pollgroup)

# Outputting
# ~~~~~~~~~~~~~~~~~~~~~~~~~
# Participants Only 
cplp <- subset(cpl, !is.na(cpl$group))

# Guess Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cplp$knowa1raw <- car::recode(cplp$source1, "3=1;c(1,2,4,5,6)=0")
cplp$knowb1raw <- car::recode(cplp$use1,    "3=1;c(1,2)=0")
cplp$knowc1raw <- car::recode(cplp$rt1, "2=1;c(1,3)=0")
cplp$knowd1raw <- car::recode(cplp$smog1,   "2=1;c(1,3)=0")
cplp$knowe1raw <- car::recode(cplp$setrt1,  "1=1;c(2,3,4,5,6)=0")
cplp$knowf1raw <- car::recode(cplp$profit1, "0=1;c(1,2,3)=0")
cplp$knowg1raw <- car::recode(cplp$pctful1, "2=1;c(1,3,4,5)=0")

cplp$knowa2raw <- car::recode(cplp$source2, "3=1;c(1,2,4,5,6)=0")
cplp$knowb2raw <- car::recode(cplp$use2,    "3=1;c(1,2)=0")
cplp$knowc2raw <- car::recode(cplp$rt2, "2=1;c(1,3)=0")
cplp$knowd2raw <- car::recode(cplp$smog2,   "2=1;c(1,3)=0")
cplp$knowe2raw <- car::recode(cplp$setrt2,  "1=1;c(2,3,4,5,6)=0")
cplp$knowf2raw <- car::recode(cplp$profit2, "0=1;c(1,2,3)=0")
cplp$knowg2raw <- car::recode(cplp$pctful2, "2=1;c(1,3,4,5)=0")

cplpk <- c("caseid", 
paste0("know", letters[1:7], "1"),
paste0("know", letters[1:7], "2"),
paste0("know", letters[1:7], "1c"),
paste0("know", letters[1:7], "1raw"),
paste0("know", letters[1:7], "2raw"),
"t1know", "t2know", "age", "pollgroup", "educ4","female")

cplirt <-cplp[, cplpk]
write.csv(cplirt, file="guess/data/cplirt.csv")

# PK Subset
# ~~~~~~~~~~~~~~~~~~~~~~
cplr <- cplp[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw")] 

save(cplr, file="pk/data/cplr.Rdata")
save(cplr, file="cdd/pkdat/cplr.Rdata")

### Kyu Data ##
#~~~~~~~~~~~~~~~~~~~~~
cplp$t1cons<- zero1(cplp$t1cons)
vars <- with(cplp, data.frame(t1res, t1cons, t1poor, t1renew, t1fossil, t1buypwr, t1compet))
vars2 <- with(cplp, data.frame(t2res, t2cons, t2poor, t2renew, t2fossil, t2buypwr, t2compet))
cplkyu <- cbind(cplr, vars, vars2)
save(cplkyu, file="cdd/kyu/bypoll/cplkyu.rdata", ascii=TRUE)

## Evaluation ##
################
cpl$selection <- as.numeric(!is.na(cpl$group))
cpl$opinionminority <- NA

cpl$eval1 <- NA
cpl$eval2 <- NA
cpl$eval3 <- NA
cpl$eval4 <- NA
cpl$eval5 <- NA
cpl$eval6 <- NA
cpl$eval7 <- NA
cpl$eval8 <- NA
cpl$eval9 <- NA
cpl$eval10 <- NA
cpl$eval11 <- NA
cpl$eval12 <- NA
cpl$eval13 <- NA
cpl$eval14 <- NA
cpl$eval15 <- NA
cpl$meanmodscore <- NA
cpl$eval5GtoB <-NA 
cpl$eval15D <- NA

cpl.eval <- cpl[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw","selection", "eval1","eval2","eval3","eval4","eval5","eval6",
"eval7","eval8","eval9","eval10", "eval11","eval12","eval13","eval14","eval15","meanmodscore","length",
"numindices","genvar","vareduc","varfemale","eval5GtoB","eval15D","opinionminority")] 

save(cpl.eval, file="dpeval/data/cpl.eval.rdata", ascii=TRUE)
