#
#  Bulgaria
#
# Guess output: up above

# Set Working dir.
setwd(basedir)

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/scripts/hlmFunc.R") # Loading up functions

#########################################################################
## Merge for Participants - Before/After
if(FALSE){
before <- spss("cdd/data/Bulgaria/Bulgaria_Data/bu.before.sav")
names(before) <- paste("t1", names(before), sep = "")
after <-  spss("cdd/data/Bulgaria/Bulgaria_Data/bu.after.sav")
names(after) <- paste("t2", names(after), sep = "")
bu.part <- merge(before, after, by.x = "t1id", by.y = "t2id")
save(bu.part, file = "cdd/data/Bulgaria/Bulgaria_Data/bu.part.rdata", ascii = T)
control <- spss("cdd/data/Bulgaria/Bulgaria_Data/bu.control.sav")
names(control) <- paste("ctrl", names(control), sep = "")
bu.all <- merge(bu.part, control, by.x = "t1id", by.y = "ctrlid", all.y = T, all.x = T)

# Guess
# ~~~~~~~~~~~~~~~~~~~~~~
bu.all$t1q12_1r <- recode(bu.all$t1q12_1, "2 = 1; 1 = 0; 99 = NA")
bu.all$t1q12_2r <- recode(bu.all$t1q12_2, "2 = 1; 1 = 0; 99 = NA")
bu.all$t1q12_3r <- recode(bu.all$t1q12_3, "2 = 1; 1 = 0; 99 = NA")
bu.all$t1q12_4r <- recode(bu.all$t1q12_4, "2 = 1; 1 = 0; 99 = NA")
bu.all$t1q12_5r <- recode(bu.all$t1q12_5, "2 = 0; 99 = NA")
bu.all$t1q12_6r <- recode(bu.all$t1q12_6, "2 = 1; 1 = 0; 99 = NA")
bu.all$t1q12_7r <- recode(bu.all$t1q12_7, "2 = 0; 99 = NA")

bu.all$t2q12_1r <- recode(bu.all$t2q12_1, "2 = 1; 1 = 0; 99 = NA")
bu.all$t2q12_2r <- recode(bu.all$t2q12_2, "2 = 1; 1 = 0; 99 = NA")
bu.all$t2q12_3r <- recode(bu.all$t2q12_3, "2 = 1; 1 = 0; 99 = NA")
bu.all$t2q12_4r <- recode(bu.all$t2q12_4, "2 = 1; 1 = 0; 99 = NA")
bu.all$t2q12_5r <- recode(bu.all$t2q12_5, "2 = 0; 99 = NA")
bu.all$t2q12_6r <- recode(bu.all$t2q12_6, "2 = 1; 1 = 0; 99 = NA")
bu.all$t2q12_7r <- recode(bu.all$t2q12_7, "2 = 0; 99 = NA")

fromlist <- paste0(c(paste0("t1q12_", 1:7), paste0("t2q12_", 1:7)), "r") 
tolist   <- paste0(fromlist, "c")
bu.all[, tolist] <- sapply(bu.all[, fromlist], function(x) nona(x))

bu.all$t1know <- rowMeans(bu.all[, tolist[1:7]])
bu.all$t2know <- rowMeans(bu.all[, tolist[8:14]])

bu.all$caseid <- paste0(53, 10000+seq(1:nrow(bu.all)))
bu.all$female <- as.numeric(bu.all$t1sex == 2)
bu.all$educ4  <- recode(bu.all$t1edu, "0 = NA; c(4, 5) = 0; 3 = .33; 2 = .66; 1 = 1")
bu.all$age    <- bu.all$t1age_full
bu.all$pollid <- 53
bu.all$pollgroup <- pgroup(bu.all$t1group, bu.all$pollid)

bulp <- subset(bu.all, !is.na(bu.all$pollgroup))

bulpk <- c("caseid", tolist, fromlist, "t1know", "t2know", "age", "pollgroup", "educ4","female")

bulirt <- bulp[, bulpk]
write.csv(bulirt, file = "guess/data/bypoll/bulirt.csv")

}
###################################################################################

## SPSS to R, Participants Only
#load("data/CDD/Bulgaria/recoded_bulgaria.rdata")
bulgaria <- foreign::read.spss("cdd/data/Bulgaria/data/bulgaria.sav", to.data.frame  = TRUE)

#L3 Variables
bulgaria$pollid  <- 53
bulgaria$mode    <- 0
bulgaria$country <- 8
bulgaria$length  <- NA
bulgaria$timebtw <- NA

#Caseid
bulgaria$caseid <- paste0(bulgaria$pollid[1], 10000+seq(1:nrow(bulgaria)))

## Group
bulgaria$pollgroup <- pgroup(bulgaria$group0, bulgaria$pollid)
bulgaria$groupsize <- grpfun(rep(1, nrow(bulgaria)), bulgaria$pollgroup, fun = "sum")

### SocioDem ###
bulgaria$ppage    <- bulgaria$age_full
bulgaria$female   <- as.numeric(bulgaria$sex == 'Female')
bulgaria$hhincome <- recode(as.integer(bulgaria$incomes), "1 = NA")
bulgaria$highinc  <- (as.integer(bulgaria$hhincome) > 4) 
bulgaria$educ4    <- recode(bulgaria$edu, "0 = NA; c(4, 5) = 0; 3 = .33; 2 = .66; 1 = 1")
bulgaria$educollege <- ifelse(bulgaria$educ4 > .76, 1, 0)
bulgaria$minority   <- as.numeric(bulgaria$ethnos! = 1)

bulgaria$pminority  <- grpfun(bulgaria$minority, bulgaria$pollgroup, fun = "mean")
bulgaria$pfemale    <- grpfun(bulgaria$female, bulgaria$pollgroup, fun = "mean")
bulgaria$varfemale  <- (bulgaria$pfemale)*(1 - bulgaria$pfemale)
bulgaria$phigheduc  <- grpfun(bulgaria$educollege, bulgaria$pollgroup, fun = "mean")
bulgaria$vareduc    <- grpfun(bulgaria$educ4, bulgaria$pollgroup, fun = "var")
bulgaria$phighinc   <- grpfun(bulgaria$highinc, bulgaria$pollgroup, fun = "mean")

## Political Interest and Briefing Material
bulgaria$t1polint  <- NA
bulgaria$readbrief <- NA

## Knowledge
#1/ If a policeman wants to detain a citizen for questioning at any time of the day or night, 
# the citizen does not have the right to refuse 
#2/ The Court has the right to detain suspects as long as needed to prove if they are guilty or not 
#3/ The prosecution has the right to detain suspects, until the crime is solved 
#4/ The Chief Prosecutor is responsible and accountable to Parliament 
#5/ The police do not have the right to use violence against a detainee even if proven that 
# he/she has committed a crime 
#6/ The police has the right to keep you in detention for three days
#7/ A confession is not enough to find the defendant guilty 

# table(bulgaria$q12_1, bulgaria$t1q12_1, useNA = "always")

fromlist <- c("t1q12_1", "t1q12_2", "t1q12_3", "t1q12_4", "t1q12_5", "t1q12_6", "t1q12_7",
  "t2q12_1", "t2q12_2", "t2q12_3", "t2q12_4", "t2q12_5", "t2q12_6", "t2q12_7")
tolist   <- paste(fromlist, "r", sep = "")
bulgaria[,tolist] <- sapply(bulgaria[, fromlist], function(x) nona(x))

# Bulgaria Party Placement (Show declining trends)
# q32 UDF (Right Wing, 6-10) bulgaria$t1udf, 
# q33 BSP (Left Wing, 1-4)

bulgaria$t1q33r <- as.numeric(bulgaria$q33 < 5 & bulgaria$q33 > 0)

bulgaria$t1q32r <- as.numeric(bulgaria$q32 > 5)
bulgaria$t1q33r <- as.numeric(bulgaria$q33 < 5 & bulgaria$q33 > 0)
#pkcor(bulgaria$t1udf, bulgaria$t2udf)

cor(bulgaria$t1udf, bulgaria$t2q12_7r)

paste(bulgaria$t1q12_1r, bulgaria$t2q12_1r)

## Corrected Facts; 10 to 0
bulgaria$t1q12_1rr <- with(bulgaria, t1q12_1r*t2q12_1r)
bulgaria$t1q12_2rr <- with(bulgaria, t1q12_2r*t2q12_2r)
bulgaria$t1q12_3rr <- with(bulgaria, t1q12_3r*t2q12_3r)
bulgaria$t1q12_4rr <- with(bulgaria, t1q12_4r*t2q12_4r)
bulgaria$t1q12_5rr <- with(bulgaria, t1q12_5r*t2q12_5r)
bulgaria$t1q12_6rr <- with(bulgaria, t1q12_6r*t2q12_6r)
bulgaria$t1q12_7rr <- with(bulgaria, t1q12_7r*t2q12_7r)

bulgaria$t1know    <- with(bulgaria, rowMeans(cbind(t1q12_1r, t1q12_2r, t1q12_3r, t1q12_4r, t1q12_5r, t1q12_6r, t1q12_7r)))
bulgaria$t1knowcor <- with(bulgaria, rowMeans(cbind(t1q12_1rr, t1q12_2rr, t1q12_3rr, t1q12_4rr, t1q12_5rr, t1q12_6rr, t1q12_7rr)))
bulgaria$t2know    <- with(bulgaria, rowMeans(cbind(t2q12_1r, t2q12_2r, t2q12_3r, t2q12_4r, t2q12_5r, t2q12_6r, t2q12_7r)))
bulgaria$t1knowlevel <- mean(bulgaria$t1know)
bulgaria$highknow    <- (bulgaria$t1know > fivenum(bulgaria$t1know)[4])
bulgaria$meant1know  <- grpfun(bulgaria$t1know, bulgaria$pollgroup, fun = "mean")
bulgaria$meant2know  <- grpfun(bulgaria$t2know, bulgaria$pollgroup, fun = "mean")
bulgaria$phighknow   <- grpfun(bulgaria$highknow, bulgaria$pollgroup, fun = "mean")
bulgaria$meant1know_ind <- with(bulgaria,(meant1know*groupsize - t1know )/(groupsize - 1))

#Group Gain
bulgaria$numitems <- 7
knowindex <- with(bulgaria, data.frame(t1q12_1rr, t1q12_2rr, t1q12_3rr, t1q12_4rr, t1q12_5rr, t1q12_6rr, t1q12_7rr))
bulgaria$grpgain <- groupgain(knowindex, bulgaria$pollgroup, nrow(bulgaria), bulgaria$numitems, bulgaria$groupsize)

## Arrival Adjusted
bulgaria$t1knowcor2 <- NA
bulgaria$t12know <- NA
bulgaria$t12knowcor <- NA
bulgaria$grpgain2 <- NA

### Attitude #######
bulgaria$numindices <- 5
# t1tghpc, t1clibe, t1dlegal, t1q8_7, t1q8_1, t1q8_8, t1q8_11, t1q10_3, t1q16, t1q21, t1q22, t1q23, t1q19
attlist <- c("t1tghpc", "t1clibe", "t1dlegal", "t1q8_7", "t1q8_1", "t1q8_8", "t1q8_11", "t1q10_3", "t1q16r", 
"t1q21", "t1q23", "t1q22r", "t1q19r")
bulgaria$attextreme <- rowMeans(abs(bulgaria[, attlist]-.5), na.rm = TRUE)
bulgaria$attextreme2 <- NA

# Att var, and sd

vars <- with(bulgaria, data.frame(t1tghpc, t1clibe, t1q8_7, t1q8_1, t1q8_8, t1q8_11, t1q10_3, t1q16r, t1q21, t1q22r, t1q23, t1q19r))

temp <- vars
for(i in 1:length(vars))
{
temp[, i] <- grpfun(vars[, i], bulgaria$pollgroup, fun = "var")
}
bulgaria$avgsd <- rowMeans(sqrt(temp))
bulgaria$avgsd2 <- NA
bulgaria$genvar <- unsplit(lapply(split(vars, bulgaria$pollgroup), genvar),bulgaria$pollgroup)

# Outputting
# ~~~~~~~~~~~~~~~~~~~~~~~~~
# PK Subset
# ~~~~~~~~~~~~~~~~
bulgaria.crm <- bulgaria[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw")] 

save(bulgaria.crm, file = "pk/data/bulgaria.crm.Rdata")
save(bulgaria.crm, file = "cdd/pkdat/bulgaria.crm.Rdata")

# Kyu Subset
# ~~~~~~~~~~~~~~~~
#bulgaria$t1q19 <- zero1(bulgaria$t1q19)
#bulgaria$t2q19 <- zero1(bulgaria$t2q19)
vars <- data.frame(bulgaria$t1tghpc, bulgaria$t1clibe, bulgaria$t1q8_7, bulgaria$t1q8_1, bulgaria$t1q8_8, bulgaria$t1q8_11, 
bulgaria$t1q10_3, bulgaria$t1q16, bulgaria$t1q21, bulgaria$t1q22, bulgaria$t1q23, bulgaria$t1q19)
vars2 <- data.frame(bulgaria$t2tghpc, bulgaria$t2clibe, bulgaria$t2q8_7, bulgaria$t2q8_1, bulgaria$t2q8_8, bulgaria$t2q8_11, 
bulgaria$t2q10_3, bulgaria$t2q16, bulgaria$t2q21, bulgaria$t2q22, bulgaria$t2q23, bulgaria$t2q19)
bulgariakyu <- cbind(bulgaria.crm, vars, vars2)
save(bulgariakyu, file = "cdd/kyu/bypoll/bulgariakyu.rdata", ascii = TRUE)

## Bulgaria Evaluation 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
#q36_1p=BSP (L)
#q36_2p = UDF (R)
#q36_3p = NMSII (center)
#q36_4p = MRF (center)
#q36_5p = Other (NA)
#q36_88p = NA (NA)
bulgaria$opinionminority <- NA
for(i in 1:278){
if(bulgaria[i,"q36_1p"] ==1 || bulgaria[i,"q36_1p"] ==2 || bulgaria[i,"q36_2p"] ==1 || bulgaria[i,"q36_2p"] ==2)
bulgaria[i,"opinionminority"] <- 1
else
bulgaria[i,"opinionminority"] <- 0
}

bulgaria$popinionminority <- grpfun(bulgaria$opinionminority, bulgaria$group, fun = "mean")

####Set scaling stuff
#eval variables need to be rescaled; even if no we need to rename and enter NAs for 
#eval vairables not in the dataset, so set eval1-15
rescale <-1
#Indicate the scaleing level for each variable
#use a 0 for variables not in this dataset 
#1=2, 2=3, 3=4, 4=5, 5=10 (levels=levelcode)
eval5Leval=5

#set variables to the eval questions in the dataset
#use set variable to NA if not in dataset

bulgaria$eval1t <-bulgaria$q_40
bulgaria$eval2t <-bulgaria$q34_6
bulgaria$eval3t <-NA
bulgaria$eval4t <-bulgaria$q39_4
bulgaria$eval5t <-bulgaria$q39_3
bulgaria$eval6t <-bulgaria$q38_3p
bulgaria$eval7t <-bulgaria$q38_4p
bulgaria$eval8t <-bulgaria$q38_1p
bulgaria$eval9t <-NA
bulgaria$eval10t <-bulgaria$q39_5
bulgaria$eval11t <-bulgaria$q39_2
bulgaria$eval12t <-bulgaria$q39_1
bulgaria$eval13t <-bulgaria$q38_2p
bulgaria$eval14t <-NA
bulgaria$eval15t <-bulgaria$q38_5p

e0<-"NA=NA"
e2<-"1=0; 2=1; else=NA"
e3<-"1=0; 2=.5; 3=1; else=NA"
e4<-"1=0; 2=.33; 3=.66; 4=1; else=NA"
e5<-"1=0; 2=.25; 3=.5; 4=.75; 5=1; else=NA"
e10<-"1=.1; 2=.2; 3=.3; 4=.4; 5=.5; 6=.6; 7=.7; 8=.8; 9=.9; 10=1; else=NA"

#recode
bulgaria$eval1 <- re(bulgaria$eval1t,e5)
bulgaria$eval2 <- re(bulgaria$eval2t,e5)
bulgaria$eval3 <- re(bulgaria$eval3t,e0)
bulgaria$eval4 <- re(bulgaria$eval4t,e5)
bulgaria$eval5 <- re(bulgaria$eval5t,e5)
bulgaria$eval6 <- re(bulgaria$eval6t,e5)
bulgaria$eval7 <- re(bulgaria$eval7t,e10)
bulgaria$eval8 <- re(bulgaria$eval8t,e10)
bulgaria$eval9 <- re(bulgaria$eval9t,e0)
bulgaria$eval10 <- re(bulgaria$eval10t,e5)
bulgaria$eval11 <- re(bulgaria$eval11t,e5)
bulgaria$eval12 <- re(bulgaria$eval12t,e5)
bulgaria$eval13 <- re(bulgaria$eval13t,e10)
bulgaria$eval14 <- re(bulgaria$eval14t,e0)
bulgaria$eval15 <- re(bulgaria$eval15t,e10)

####Mean moderator score if any are present
#invert eval5 

bulgaria$eval5GtoB <-NA
sv<-eval5Leval

if(sv=="2")
bulgaria$eval5GtoB <- re(bulgaria$eval5,"0=1; 1=0; else=NA")
if(sv=="3")
bulgaria$eval5GtoB <- re(bulgaria$eval5,"0=1; .5=.5; 1=0; else=NA")
if(sv=="4")
bulgaria$eval5GtoB <- re(bulgaria$eval5,"0=1; 1=0; .33=.66; .66=.33; else=NA")
if(sv=="5")
bulgaria$eval5GtoB <- re(bulgaria$eval5,"0=1; 1=0; .25=.75; .5=.5; .75=.25; else=NA")
if(sv=="10")
bulgaria$eval5GtoB <- re(bulgaria$eval5,"0=1; 1=0; .1=.9; .2=.8; .3=.7; .4=.6; .5=.5; .6=.4; .7=.3; .8=.2; .9=.1; else=NA")


bulgaria$meanmodscore <-NA
bulgaria$meanmodscore <-((bulgaria$eval12 + bulgaria$eval4 +bulgaria$eval5GtoB)/3)

bulgaria$eval15D <- NA #re(bulgaria$eval15,"0:.4=0; .5:1=1; else=NA")

####Create poll dummy variables
bulgaria$isbrazil<-0
bulgaria$isbulgaria <-1
bulgaria$ischina05 <-0
bulgaria$iseu09 <-0

bulgaria$selection <- NA

bulgaria.eval <- bulgaria[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw","selection", "eval1","eval2","eval3","eval4","eval5","eval6",
"eval7","eval8","eval9","eval10", "eval11","eval12","eval13","eval14","eval15","meanmodscore","length",
"numindices","genvar","vareduc","varfemale","eval5GtoB","eval15D","opinionminority")]

save(bulgaria.eval, file="dpeval/data/bulgaria.eval.rdata", ascii=TRUE)


##################
# Attitude Indices
##################

## 99 to NA
no99 <- function(x){
for(i in 1:length(x)){
x[,i][x[,i]==99] <- NA
}
x
}
#no99(cbind(t1q8_3, t1q8_4, t1q8_5, t1q8_6))
# Attitude Indices

#t1tghpc, t1clibe, t1dlegal, t1q8_7, t1q8_1, t1q8_8, t1q8_11, t2q10_3, t1q16, t1q21, t1q22, t1q23, t1q19
#Tougher Punishment: t1tghpc
#Civil Liberties: t1clibe
#Drug Legalization: t1dlegal
#Social Root Causes: t1q8_7
#Economic Root Causes: t1q8_1
#Rehabilitation: t1q8_8
#Steamlining:  t1q8_11
#Penalty for Drug Taking: t2q10_3
#Vigilatism: t1q16
#Institutional Change: t1q21
#Independence of Investigation Service: t1q22
#Place of Prosecution: t1q23
#Death Penalty: t1q19

# Tougher Punishment
# Q8_3, Q8_4, Q8_5, Q8_6
with(bulgaria, cor(no99(data.frame(t1q8_3, t1q8_4, t1q8_5, t1q8_6)), use="na.or.complete"))
#bulgaria$t1tghpc <- with(bulgaria, rowMeans(no99(data.frame(t1q8_3, t1q8_4, t1q8_5, t1q8_6)), na.rm=T))
#Civil Liberties
#Q8_9, Q15_1, Q15_2, Q15_3, Q17_1, Q17_2, Q17_3, Q17_4
with(bulgaria, cor(no99(data.frame(t1q8_9, t1q15_1, t1q15_2, t1q15_3, t1q17_1, t1q17_2, t1q17_3, t1q17_4)), use="na.or.complete"))
#with(bulgaria, rowMeans(no99(data.frame(t1q8_9, t1q15_1, t1q15_2, t1q15_3, t1q17_1, t1q17_2, t1q17_3, t1q17_4)), na.rm=T))
#bulgaria$t1clibe <- with(bulgaria, rowMeans(no99(data.frame(t1q15_1, t1q15_2, t1q15_3, t1q17_1, t1q17_2, t1q17_4)), na.rm=T), use="na.or.complete")
#7. DRUG LEGALIZATION
#Q10_1, Q10_2
with(bulgaria, cor(no99(data.frame(t1q10_1, t1q10_2)), use="na.or.complete"))
#bulgaria$t1dlegal <- with(bulgaria, rowMeans(no99(data.frame(t1q10_1, t1q10_2)), na.rm=T), use="na.or.complete"))

# 4.ATTITUDE TOWARD PRISONS
#Q25_2, Q25_3, Q25_4
with(bulgaria, cor(no99(data.frame(t1q25_2, t1q25_3)), use="na.or.complete"))
with(bulgaria, rowMeans(no99(data.frame(t1q25_2, t1q25_3)), na.rm=T))
#5. LESS RESTRICTIONS ON CUSTODY
#Q14_1, Q14_2, Q14_3, Q25_5
with(bulgaria, cor(no99(data.frame(t1q14_1, t1q14_2, t1q14_3, t1q25_5)), use="na.or.complete"))
with(bulgaria, cor(no99(data.frame(t1q14_1, t1q14_3, t1q25_5)), use="na.or.complete"))
#9. ANTI-AUTHORITARIAN
#Q25_9,Q26_2,Q26_3,Q26_4,Q26_5
with(bulgaria, cor(no99(data.frame(t1q25_9, t1q26_2, t1q26_3, t1q26_4, t1q26_5)), use="na.or.complete"))
