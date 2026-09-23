#
#   Northern Ireland
#   Open-Ended
#   Last Edited: 5.22.14   
#   Gaurav Sood   
# 

# Set Working dir.
setwd(basedir)
	
# Sourcing libs 
library(goji)
library(car)

# Sourcing common functions
source("func/func.R")
source("cdd/hlmFunc.R")
source("func/polr.func.R")

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
## Import and Merge Data
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nireland_raw <- foreign::read.dta(file="cdd/data/Ireland/orig_data/nireland.dta", convert.dates = TRUE, 
convert.factors = TRUE, missing.type = TRUE, convert.underscore = FALSE, 
warn.missing.labels = FALSE)

## Merging Ireland data with group data
ireland_grp <- read.table("cdd/data/Ireland/groups.csv", 
header=TRUE, sep=",",  stringsAsFactors = default.stringsAsFactors(), na.strings = "NA", strip.white = TRUE, fill = TRUE)
#cserial = X112084; grp variable = N
ireland_grp$cserial <- ireland_grp$X112084

nireland <- merge(nireland_raw, ireland_grp, by="cserial", all.x=T) # Saving all
nireland$grp <- as.numeric(as.factor(nireland$N))
save(nireland, file="cdd/data/Ireland/nireland.rdata")
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##

## Load Data 
load("cdd/data/Ireland/nireland.rdata")

# Filter Variables
# Acceptersacceptndecliners == 1
# Declinersacceptndecliners == 0
# No Show!is.na(noshow) & noshow ==1
# Participant (123)filter =='selected' & !is.na(filter)
# Non Participants!is.na(attend) & attend =='non participant'
# Control Group!is.na(cgq36)

## At t3 - control group (150), and 93 participants again

# All t3 respondents (CG + Part)
nireland$time3r <- as.numeric(!is.na(nireland$time3))

# Control Group (1) Vs. Rest (0)
nireland$control     <- (!is.na(nireland$cgq36))

# T3 Participants (1) Vs. Rest (0)
nireland$t3partgrp <- (nireland$time3r & nireland$control==0)

# Control (0) Vs. All Participants (1); rest = NA
nireland$controlpart <- NA
nireland$controlpart[nireland$control==1] <- 0
nireland$controlpart[!is.na(nireland$attend)  & nireland$attend =='participant'] <- 1

# Control (0) Vs. T3 Participants (1); rest = NA
nireland$t3controlpart <- NA
nireland$t3controlpart[nireland$control==TRUE] <- 1
nireland$t3controlpart[nireland$t3partgrp==TRUE]  <- 0

## Sociodem
## ~~~~~~~~~~~~~~~~~~~~~~ ##

# Males (208) and Females (510) # Gender Missing for Rest

nireland$age<- nireland$t1q2
nireland$ppeduc <- recode(as.numeric(nireland$t1q8), "c(8,9)=NA; c(1)=1; c(2,3)=.66; c(4,5)=.33; c(6,7)=0")

# unionist   
nireland$partisan  <- recode(nireland$t1q34, "'unionist'=1; 'nationalist'=1;'neither'=0; else=NA")

# Catholic (597) and Protestant (231)
#nireland$cathlc
nireland$cathprot<- recode(nireland$religall, "'catholic'=1;'protestant'=0; else=NA")

# relattend  
nireland$relattend <- recode(nireland$t1q33, "c('never', 'hardly ever', 'once a month', 'a few times a year')=1; c('once a week', 'more than once a week')=0; else=NA")
# rel.att  
nireland$relatt    <- recode(nireland$t1q28, "c(0,5)=1; c(5,10)=0; else=NA")


##   Knowledge    ##
## ~~~~~~~~~~~~~~~~~~~~~##

#t1know, t2know, t3know 
#t1q21ans, t2q11ans What percentage of majority-Protestant or majority-Catholic schools in Northern Ireland have at least 10% of the other religion in their enrolment?
#t1q22ans, t2q12ansBy approximately what percentage has the number of children entering Omagh schools increased or decreased over the past five years
#t1q23ans, t2q13ansThe new entitlement framework requires that… 
#t1q24ans, t2q14ansThe new entitlement framework requires that… 
#t1q25ans, t2q15ans Which of the following is true of what pupils in Northern Ireland do after they leave school?
#t1q26ans, t2q16ansWhich of the following is true of current school funding?
#t1q27ans, t2q17ansWhich of the following is true of the employing authority in the schools?

# new vars. for analyses - same name for t3 and cg
# New Var: T1 Know for Parts, T3 for CG
nireland$t2cgknow <- NA
nireland$t2cgknow[!is.na(nireland$controlpart) & nireland$controlpart==1] <- nireland$t1know[!is.na(nireland$controlpart) & nireland$controlpart==1]
nireland$t2cgknow[!is.na(nireland$controlpart) & nireland$controlpart==0] <- nireland$t3know[!is.na(nireland$controlpart) & nireland$controlpart==0]

# Misc.
## Briefing Material
# Read Briefing Material
nireland$readbrief <- recode(as.integer(nireland$t2q26), "1=0; 2=.25;3=.50;4=.75;5=1;6=NA")


## Favorability and Beliefs about Community
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ##

# Favorability
#24 16aHow favorably or unfavorably do you feel about Protestants 
#25 16bHow favorably or unfavorably do you feel about Catholics

fav.to<- c("t1favprot", "t2favprot", "t3favprot", "t1favcath", "t2favcath", "t3favcath")
fav.from<- c("t1q16are", "t2q6are", "t3q6are", "t1q16bre", "t2q6bre", "t3q6bre")

names(nireland)[match(fav.from, names(nireland))]<- fav.to

nireland$t1outfav <- with(nireland, ifelse(cathprot==1, t1favprot,  t1favcath))
nireland$t2outfav <- with(nireland, ifelse(cathprot==1, t2favprot,  t2favcath))
nireland$t3outfav <- with(nireland, ifelse(cathprot==1, t3favprot,  t3favcath))

nireland$t1favinout<- with(nireland, out(t1favprot - t1favcath, t1favcath - t1favprot, !is.na(cathprot) & cathprot==0, !is.na(cathprot) & cathprot==1))
nireland$t2favinout <- with(nireland, out(t2favprot - t2favcath, t2favcath - t2favprot, !is.na(cathprot) & cathprot==0, !is.na(cathprot) & cathprot==1))
nireland$t3favinout <- with(nireland, out(t3favprot - t3favcath, t3favcath - t3favprot, !is.na(cathprot) & cathprot==0, !is.na(cathprot) & cathprot==1))

# Beliefs
# Open to reason
#29 18aOpenness of  most Protestants to reason
#30 18bOpenness of  most Catholics to reason

rsn.to<- c("t1rsnprot", "t2rsnprot", "t3rsnprot", "t1rsncath", "t2rsncath", "t3rsncath")
rsn.from<- c("t1q18are", "t2q8are", "t3q8are", "t1q18bre", "t2q8bre", "t3q8bre")

names(nireland)[match(rsn.from, names(nireland))]<- rsn.to

nireland$t1outopen   <- with(nireland, ifelse(cathprot==1, t1rsnprot, t1rsnprot))
nireland$t2outopen   <- with(nireland, ifelse(cathprot==1, t2rsnprot, t2rsncath))
nireland$t3outopen   <- with(nireland, ifelse(cathprot==1, t3rsnprot, t3rsncath))

nireland$t1inopen    <- with(nireland, ifelse(cathprot==0, t1rsnprot, t1rsnprot))
nireland$t2inopen    <- with(nireland, ifelse(cathprot==0, t2rsnprot, t2rsncath))
nireland$t3inopen    <- with(nireland, ifelse(cathprot==0, t3rsnprot, t3rsncath))

nireland$t1rsninout  <- with(nireland, out(t1rsnprot - t1rsncath, t1rsncath - t1rsnprot, !is.na(cathprot) & cathprot==0, !is.na(cathprot) & cathprot==1))
nireland$t2rsninout  <- with(nireland, out(t2rsnprot - t2rsncath, t2rsncath - t2rsnprot, !is.na(cathprot) & cathprot==0, !is.na(cathprot) & cathprot==1))
nireland$t3rsninout  <- with(nireland, out(t3rsnprot - t3rsncath, t3rsncath - t3rsnprot, !is.na(cathprot) & cathprot==0, !is.na(cathprot) & cathprot==1))

# Trustworthy
#31 19aTrustworthiness of most Protestants
#32 19bTrustworthiness of most Catholics

trst.to<- c("t1trstprot", "t2trstprot", "t3trstprot", "t1trstcath", "t2trstcath", "t3trstcath")
trst.from<- c("t1q19are", "t2q9are", "t3q9are", "t1q19bre", "t2q9bre", "t3q9bre")

names(nireland)[match(trst.from, names(nireland))]<- trst.to

nireland$t1outtrust <- with(nireland, ifelse(cathprot==1, t1trstprot, t1trstcath))
nireland$t2outtrust <- with(nireland, ifelse(cathprot==1, t2trstprot, t2trstcath))
nireland$t3outtrust <- with(nireland, ifelse(cathprot==1, t3trstprot, t3trstcath))

nireland$t1intrust <- with(nireland, ifelse(cathprot==0, t1trstprot, t1trstcath))
nireland$t2intrust <- with(nireland, ifelse(cathprot==0, t2trstprot, t2trstcath))
nireland$t3intrust <- with(nireland, ifelse(cathprot==0, t3trstprot, t3trstcath))

nireland$t1trstinout  <- with(nireland, out(t1trstprot - t1trstcath, t1trstcath - t1trstprot, !is.na(cathprot) & cathprot==0, !is.na(cathprot) & cathprot==1))
nireland$t2trstinout  <- with(nireland, out(t2trstprot - t2trstcath, t2trstcath - t2trstprot, !is.na(cathprot) & cathprot==0, !is.na(cathprot) & cathprot==1))
nireland$t3trstinout  <- with(nireland, out(t3trstprot - t3trstcath, t3trstcath - t3trstprot, !is.na(cathprot) & cathprot==0, !is.na(cathprot) & cathprot==1))

# How do they correlate
with(nireland, cor(cbind(t1favinout, t1rsninout, t1trstinout), use="na.or.complete"))
with(nireland, cor(cbind(t2favinout, t2rsninout, t2trstinout), use="na.or.complete"))
with(nireland, cor(cbind(t3favinout, t3rsninout, t3trstinout), use="na.or.complete"))

# Averaging traits
nireland$t1traitinout <- zero1(with(nireland, rowMeans(cbind(t1rsninout, t1trstinout), na.rm=T)), -1, 1)
nireland$t2traitinout <- zero1(with(nireland, rowMeans(cbind(t2rsninout, t2trstinout), na.rm=T)), -1, 1)
nireland$t3traitinout <- zero1(with(nireland, rowMeans(cbind(t3rsninout, t3trstinout), na.rm=T)), -1, 1)

# Correlation
with(nireland, cor(cbind(t1favinout, t1traitinout), use="na.or.complete"))
with(nireland, cor(cbind(t2favinout, t2traitinout), use="na.or.complete"))
with(nireland, cor(cbind(t3favinout, t3traitinout), use="na.or.complete"))

# New Var: T2 Affect for Parts, T3 for CG
nireland$t2cgoutfav   <- with(nireland, ifelse(controlpart, t2outfav,  t3outfav))
nireland$t2cgoutopen  <- with(nireland, ifelse(controlpart, t2outopen, t3outopen))
nireland$t2cgouttrust <- with(nireland, ifelse(controlpart, t2outtrust, t3outtrust))

nireland$t2cgtrstinout <- with(nireland, ifelse(controlpart, t2trstinout, t3trstinout))
nireland$t2cgrsninout  <- with(nireland, ifelse(controlpart, t2rsninout,  t3rsninout))
nireland$t2cgfavinout  <- with(nireland, ifelse(controlpart, t2favinout,  t3favinout))

## Policy Attitudes   ##
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

e5<-"1=0;2=.25;3=.5;4=.75;5=1;else=NA"
e10r<- "0=1;1=.9;2=.8;3=.7;4=.6;5=.5;6=.4;7=.3;8=.2;9=.1;10=0;else=NA"

## Recoding to 0 to 1
nireland$t2q1ar <- nireland$t2q1a/10
nireland$t2q1br <- nireland$t2q1b/10

## Q 13, 3: Recoding from more at each other's expense (0) to more beneficial (1)
## Q 17, 7: Recoding from more separation (0) to more mixing (1)
fromlist <- c("t1q13a", "t1q13b", "t1q13c", "t2q3a", "t2q3b", "t2q3c", "t3q3a", "t3q3b", "t3q3c",
  "t1q17a", "t1q17b", "t1q17c", "t2q7a", "t2q7b", "t2q7c", "t3q7a", "t3q7b", "t3q7c")
tolist   <- paste(fromlist, "re", sep="")
nireland[,tolist] <- sapply(nireland[,fromlist], function(x) recode(x, e10r))

#All ability school 18 nireland$t2q1cr 
#Religious Homogeneity 19 nireland$t2q2ar
#Inclusive Classrom 20 nireland$t2q4cr
#Consolidating Schools 21  nireland$t2q5gr

#18a (strongly support) b (strongly oppose)
#q1c - Having a system of all-ability schools, all providing the same wide curriculum (0 strongly oppose, 10 strongly support)
nireland$t2q1cr      <- nireland$t2q1c/10
nireland$t2q1cdum    <- recode(nireland$t2q1cr, ".5:1=1; 0:.5=0")
nireland$t2support1c <- as.numeric(nireland$t2q1cr >= .5)
nireland$t2oppose1c  <- as.numeric(nireland$t2q1cr < .5)
nireland$t3q1cr      <- nireland$t3q1c/10
nireland$t3q1cdum    <- recode(nireland$t3q1cr, ".5:1=1; 0:.5=0")

nireland$t1q11cdum <- recode(nireland$t1q11cre, ".5:1=1; 0:.5=0")

nireland$t2q1dr <- nireland$t2q1d/10
nireland$t2q1er <- nireland$t2q1e/10
nireland$t2q1fr <- nireland$t2q1f/10

#Q2. Some people think it is important for children to attend school only with other children of their own religion.  
#  Suppose these people are at one end of a scale, at point 0.  Other people think it is important for children 
#  to attend schools that have a balanced enrolment of Protestant and Catholic pupils.  Suppose these people are at 
#  the other end, at point 10.  People who are exactly in-between are at point 5.  And, of course, other people have 
#  opinions at other points on the scale.  Regarding schools in the Omagh area:

# A.Where would you place your views on this scale?  (q2a)
#19a (people who think that children should attend schools only with other children of their own religion give)b <- 
nireland$t2q2ar <- nireland$t2q2a/10
#q19
nireland$t2q2adum     <- recode(nireland$t2q2ar, ".5:1=1; 0:.5=0")
nireland$t2support2a  <- 1*(nireland$t2q2ar > .5)
nireland$t2oppose2a   <- 1*(nireland$t2q2ar < .5)
nireland$t3q2ar       <- nireland$t3q2a/10
nireland$t3q2adum     <- recode(nireland$t3q2ar, ".5:1=1; 0:.5=0")

nireland$t1q12adum <-  recode(nireland$t1q12are, ".5:1=1; 0:.5=0")

nireland$t2q2br <- nireland$t2q2b/10
nireland$t2q2cr <- nireland$t2q2c/10
nireland$t2q3br <- nireland$t2q3b/10
nireland$t2q3cr <- nireland$t2q3c/10

#q20a Now think about the issue of whether, if schools with different religious compositions enter 
#partnerships, the children from both schools should at least sometimes be taught in the same classroom.  Regardless of your own opinion, what reasons would the people who strongly agree with this give for their position)
#q4 <- And how strongly would you agree or disagree with each of the following statements: If schools of different religious composition enter partnerships, the children from both schools should at least sometimes be taught in the same classroom (1 Disagree, 5 Agree)
#q20
nireland$t2q4cr      <- recode(as.numeric(nireland$t2q4c), e5)
nireland$t2q4cdum    <- recode(nireland$t2q4cr, ".5:1=1; 0:.5=0")
nireland$t2support4c <- 1*(nireland$t2q4cr > .5)
nireland$t2oppose4c  <- 1*(nireland$t2q4cr < .5)
nireland$t3q4cr      <- recode(nireland$t3q4c, e5)
nireland$t3q4cdum    <- recode(nireland$t3q4cr, ".5:1=1; 0:.5=0")

nireland$t1q14cdum <-  recode(nireland$t1q14cr, ".5:1=1; 0:.5=0")

nireland$t2q5br <- nireland$t2q5b/10
nireland$t2q5cr <- nireland$t2q5c/10
nireland$t2q5dr <- nireland$t2q5d/10
nireland$t2q5er <- nireland$t2q5e/10
nireland$t2q5fr <- nireland$t2q5f/10

#q21a Now think about the proposal for schools combining primary and post-primary pupils (for example, ages 7-14).  Regardless of your own opinion, what reasons would the people who strongly support schools combining primary and post-primary pupils
#Q5g Schools combining primary and post-primary pupils (for example, ages 7-14) (1 oppose, 10 support)
nireland$t2q5gr      <- nireland$t2q5g/10
nireland$t2q5gdum    <- recode(nireland$t2q5gr, ".5:1=1; 0:.5=0")
nireland$t2support5g <- 1*(nireland$t2q5gr > .5)
nireland$t2oppose5g  <- 1*(nireland$t2q5gr < .5)
nireland$t3q5gr      <- nireland$t3q5g/10
nireland$t3q5gdum    <- recode(nireland$t3q5gr, ".5:1=1; 0:.5=0")

nireland$t1q15gdum <-  recode(nireland$t1q15gr, ".5:1=1; 0:.5=0")

nireland$t2q7br <- nireland$t2q7b/10
nireland$t2q7cr <- nireland$t2q7c/10

# Fixing Errors that existed in data that I received (Thx. to Nuri)
# ******************************************************************
#t1q14cre" (recode of t1q14c) and "t1q20bre" (recode of t1q20b) are incorrectly recoded. 
# What is currently shown as 0.1 should be coded as 1 (it should be 0, 0.25, 0.5, 0.75, and 1, 
# NOT 0, 0.1, 0.25, 0.5, and 0.75). 

nireland$t1q14cre <- recode(as.numeric(nireland$t1q14c), "1 = 0; 2 = .25; 3 = .5; 4 = .75; 5 = 1; else=NA")
nireland$t1q20bre <- recode(as.numeric(nireland$t1q20b), "1 = 0; 2 = .25; 3 = .5; 4 = .75; 5 = 1; else=NA")


# Making new vars that span CG and Participants
# *******************************************************
nireland$t1cgq11cr <- with(nireland, ifelse(controlpart, t1q11cre, t3q1cr))
nireland$t1cgq12ar <- with(nireland, ifelse(controlpart, t1q12are, t3q2ar))
nireland$t1cgq14cr <- with(nireland, ifelse(controlpart, t1q14cre, t3q4cr))
nireland$t1cgq15gr <- with(nireland, ifelse(controlpart, t1q15gre, t3q5gr))

nireland$t2cgq1cr <- with(nireland, ifelse(controlpart, t2q1cr, t3q1cr))
nireland$t2cgq2ar <- with(nireland, ifelse(controlpart, t2q2ar, t3q2ar))
nireland$t2cgq4cr <- with(nireland, ifelse(controlpart, t2q4cr, t3q4cr))
nireland$t2cgq5gr <- with(nireland, ifelse(controlpart, t2q5gr, t3q5gr))

# Policy Variable Matchup
qdf <- with(nireland, data.frame(t1q11are, t2q1a, t1q11bre, t2q1b, t1q11cre, t2q1c,t1q11dre, t2q1d, t1q11ere, 
t2q1e, t1q11fre, t2q1f, t1q11gre, t2q1gre, t1q12are, t2q2are,t1q12bre, t2q2b,t1q12cre, t2q2c, 
t1q13are, t2q3are, t1q13bre, t2q3b,t1q13cre, t2q3c,t1q14are, t2q4are, t1q14bre, t2q4bre, t1q14cre, 
t2q4cre, t1q15are, t2q5are,t1q15bre, t2q5b,t1q15cre, t2q5c,t1q15dre, t2q5d, t1q15ere, t2q5e,
t1q15fre, t2q5f,t1q15gre, t2q5g, 
t1favprot, t2favprot, t1favcath, t2favcath, 
t1q17are, t2q7are, t1q17bre, t2q7b, t1q17cre, t2q7c, 
t1rsnprot, t2rsnprot, t1rsncath, t2rsncath, 
t1trstprot, t2trstprot,t1trstcath, t2trstcath,
t1q20are, t2q10are, t1q20bre, t2q10bre))

## Group Variables          ##
## ~~~~~~~~~~~~~~~~~~~~~~~~ ##

# Attitude
nireland$q11cgrp <- with(nireland, grpfun(t1q11cre, grp, fun="mean")) 
nireland$q12agrp <- with(nireland, grpfun(t1q12are, grp, fun="mean")) 
nireland$q14cgrp <- with(nireland, grpfun(t1q14cre, grp, fun="mean")) 
nireland$q15ggrp <- with(nireland, grpfun(t1q15gre, grp, fun="mean")) 

# Prop. in Support
nireland$psupportq1c <- with(nireland, grpfun(t2q1cr, grp, fun="mean")) 
nireland$psupportq2a <- with(nireland, grpfun(t2q2ar, grp, fun="mean"))
nireland$psupportq4c <- with(nireland, grpfun(t2q4cr, grp, fun="mean"))
nireland$psupportq5g <- with(nireland, grpfun(t2q5gr, grp, fun="mean"))

# Group Sociodem
nireland$pcatholic <- with(nireland, grpfun(cathprot, grp, fun="mean"))
nireland$pfem      <- with(nireland, grpfun(female, grp, fun="mean"))

# Group Size
nireland$grpsize   <- grpfun(rep(1, nrow(nireland)), group=nireland$grp, fun="sum")

# Group Knowledge; Mean Knowledge of others
nireland$grppk    <- wirh(nireland, (grpfun(t1know, grp, fun="sum") - t1know)/(grpsize -1))  

# Variance in Grp
#a1 <- sqrt(grpfun(nireland$t1q11cre, nireland$grp, fun="var"))

# Generalized variance
nir1 <- nireland[,c("t1q11cre","t1q12are","t1q14cre","t1q15gre")]
nireland$genvar <- unsplit(lapply(split(nir1, nireland$grp), genvar),nireland$grp)

# Control Group Variables   ##
# ~~~~~~~~~~~~~~~~~~~~~~~~~ ##
#Have you heard anything about the Deliberative Poll on education in Omagh on January 27
# nireland$cgq31 
nireland$cgq31r <- as.numeric(as.character(recode(nireland$cgq31, "'yes'=1; 'no'=0")))

# if yes then go to 35
#How much have you read about the Deliberative Poll in newspapers and magazines?
# nireland$cgq32

# #How much have you seen or heard about the Deliberative Poll on television or radio?
#nireland$cgq33 

# #How much have you talked about the Deliberative Poll with family, friends, or co-workers?
#nireland$cgq34 

#nireland$cgq35a   How much would you say you have read or heard about issues of education in Northern Ireland in newspapers or magazines or on television or radio?
nireland$cgq35ar <- as.numeric(as.character(recode(nireland$cgq35a, "'nothing at all'=0.0; 'only a little'=.33;  'a great deal'= 1.0;  'somewhat'=.66")))

#nireland$cgq35b   How much would you say you have discussed issues of education in Northern Ireland with family, friends, or co-workers?
nireland$cgq35br <- as.numeric(as.character(recode(nireland$cgq35b, "'nothing at all'=0.0; 'only a little'=.33;  'a great deal'= 1.0;  'somewhat'=.66")))

#nireland$cgq35c   How much would you say you have sought information about issues of education in Northern Ireland in the library or on the internet
nireland$cgq35cr <- as.numeric(as.character(recode(nireland$cgq35c, "'nothing at all'=0.0; 'only a little'=.33;  'a great deal'= 1.0;  'somewhat'=.66")))

nireland$exp   <- with(nireland, rowMeans(cbind(cgq35ar, cgq35br, cgq35cr), na.rm=T))


## Open-Ended Total Responses Recoding     ##
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
from.open <- paste0("t2q",c("18a", "19a", "20a", "21a", "18b", "19b", "20b", "21b"), "nu")
to.open  <- paste0(from.open, "r")
ireland[,to.open] <- sapply(ireland[,from.open], function(x) recode(x, "0=.001; c(4,5)=3"))

# Making new vars that span CG and Participants
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nireland$t2cgq18anu <-  with(nireland, ifelse(controlpart, t2q18anu, t3q18anu))
nireland$t2cgq18bnu <-  with(nireland, ifelse(controlpart, t2q18bnu, t3q18bnu))

nireland$t2cgq19anu <-  with(nireland, ifelse(controlpart, t2q19anu, t3q19anu))
nireland$t2cgq19bnu <-  with(nireland, ifelse(controlpart, t2q19bnu, t3q19bnu))

nireland$t2cgq20anu <-  with(nireland, ifelse(controlpart, t2q20anu, t3q20anu))
nireland$t2cgq20bnu <-  with(nireland, ifelse(controlpart, t2q20bnu, t3q20bnu))

nireland$t2cgq21anu <-  with(nireland, ifelse(controlpart, t2q21anu, t3q21anu))
nireland$t2cgq21bnu<-  with(nireland, ifelse(controlpart, t2q21bnu, t3q21bnu))

# Sums by Policy
nireland$t2cgsum18<- with(nireland, rowSums(cbind(t2cgq18anu, t2cgq18bnu), na.rm=T))
nireland$t2cgsum19<- with(nireland, rowSums(cbind(t2cgq19anu, t2cgq19bnu), na.rm=T))
nireland$t2cgsum20<- with(nireland, rowSums(cbind(t2cgq20anu, t2cgq20bnu), na.rm=T))
nireland$t2cgsum21<- with(nireland, rowSums(cbind(t2cgq21anu, t2cgq21bnu), na.rm=T))

nireland$t3sum18<- with(nireland, rowSums(cbind(t3q18anu, t3q18bnu), na.rm=T))
nireland$t3sum19<- with(nireland, rowSums(cbind(t3q19anu, t3q19bnu), na.rm=T))
nireland$t3sum20<- with(nireland, rowSums(cbind(t3q20anu, t3q20bnu), na.rm=T))
nireland$t3sum21<- with(nireland, rowSums(cbind(t3q21anu, t3q21bnu), na.rm=T))

# Diffs. by Policy
nireland$t2cg18diff <- with(nireland, t2cgq18anu - t2cgq18bnu)
nireland$t2cg19diff <- with(nireland, t2cgq19anu - t2cgq19bnu)
nireland$t2cg20diff <- with(nireland, t2cgq20anu - t2cgq20bnu)
nireland$t2cg21diff <- with(nireland, t2cgq21anu - t2cgq21bnu)

nireland$t3q18diff<- with(nireland, t3q18anu - t3q18bnu) 
nireland$t3q19diff<- with(nireland, t3q19anu - t3q19bnu)
nireland$t3q20diff<- with(nireland, t3q20anu - t3q20bnu)
nireland$t3q21diff<- with(nireland, t3q21anu - t3q21bnu)

# Support/Oppose Diff.
##tester: q <- "q18a"; t2open.s <- nireland$t2q18anu; t3open.s <- nireland$t3q18anu; t2open.o <- nireland$t2q18bnu; t3open.o <- nireland$t3q18bnu; t2att <- nireland$t2q1cdum; t3att <- nireland$t3q1cdum; sup <- "opp"; 
nireland$t2q18supp<- with(nireland, ifelse(t1q11cdum, t2q18anu, t2q18bnu))
nireland$t2q18opp<- with(nireland, ifelse(!t1q11cdum, t2q18anu, t2q18bnu))
nireland$t2q18apdiff<- with(nireland, t2q18supp - t2q18opp)

nireland$t2q19supp<- with(nireland, ifelse(t1q12adum,  t2q19anu, t2q19bnu))
nireland$t2q19opp<- with(nireland, ifelse(!t1q12adum, t2q19anu, t2q19bnu))
nireland$t2q19apdiff<- with(nireland, t2q19supp - t2q19opp)

nireland$t2q20supp<- with(nireland, ifelse(t1q14cdum,  t2q20anu, t2q20bnu))
nireland$t2q20opp<- with(nireland, ifelse(!t1q14cdum, t2q20anu, t2q20bnu))
nireland$t2q20apdiff<- with(nireland, t2q20supp - t2q20opp)

nireland$t2q21supp<- with(nireland, ifelse(t1q15gdum,  t2q21anu, t2q21bnu))
nireland$t2q21opp<- with(nireland, ifelse(!t1q15gdum, t2q21anu, t2q21bnu))
nireland$t2q21apdiff<- with(nireland, t2q21supp - t2q21opp)

nireland$t3q18supp <- with(nireland, ifelse(t3q1cdum,  t3q18anu, t3q18bnu))
nireland$t3q18opp <- with(nireland, ifelse(!t3q1cdum, t3q18anu, t3q18bnu))
nireland$t3q18apdiff<- with(nireland, t3q18supp - t3q18opp)

nireland$t3q19supp <- with(nireland, ifelse(t3q2adum,  t3q18anu, t3q18bnu))
nireland$t3q19opp <- with(nireland, ifelse(!t3q2adum, t3q18anu, t3q18bnu))
nireland$t3q19apdiff<- with(nireland, t3q19supp - t3q19opp)

nireland$t3q20supp <- with(nireland, ifelse(t3q4cdum,  t3q18anu, t3q18bnu))
nireland$t3q20opp <- with(nireland, ifelse(!t3q4cdum, t3q18anu, t3q18bnu))
nireland$t3q20apdiff<- with(nireland, t3q20supp - t3q20opp)

nireland$t3q21supp <- with(nireland, ifelse(t3q5gdum,  t3q18anu, t3q18bnu))
nireland$t3q21opp <- with(nireland, ifelse(!t3q5gdum, t3q18anu, t3q18bnu))
nireland$t3q21apdiff<- with(nireland, t3q21supp - t3q21opp)

# T2 CG
nireland$t2cgq18supp<-  with(nireland, ifelse(controlpart, t2q18supp, t3q18supp))
nireland$t2cgq18opp<-  with(nireland, ifelse(controlpart, t2q18opp, t3q18opp))

nireland$t2cgq19supp<-  with(nireland, ifelse(controlpart, t2q19supp, t3q19supp))
nireland$t2cgq19opp<-  with(nireland, ifelse(controlpart, t2q19opp, t3q19opp))

nireland$t2cgq20supp<-  with(nireland, ifelse(controlpart, t2q20supp, t3q20supp))
nireland$t2cgq20opp<-  with(nireland, ifelse(controlpart, t2q20opp, t3q20opp))

nireland$t2cgq21supp<-  with(nireland, ifelse(controlpart, t2q21supp, t3q21supp))
nireland$t2cgq21opp<-  with(nireland, ifelse(controlpart, t2q21opp, t3q21opp))

# Bias. by Policy
nireland$t2cg18bias <- with(nireland, ifelse(t2cgsum18==0, 0, (t2cgq18supp - t2cgq18opp)/t2cgsum18))
nireland$t2cg19bias <- with(nireland, ifelse(t2cgsum19==0, 0, (t2cgq19supp - t2cgq19opp)/t2cgsum19))
nireland$t2cg20bias <- with(nireland, ifelse(t2cgsum20==0, 0, (t2cgq20supp - t2cgq20opp)/t2cgsum20))
nireland$t2cg21bias <- with(nireland, ifelse(t2cgsum21==0, 0, (t2cgq21supp - t2cgq21opp)/t2cgsum21))

nireland$t3q18bias <- with(nireland, ifelse(t3sum18==0, 0, (t3q18supp - t3q18opp)/t3sum18))
nireland$t3q19bias <- with(nireland, ifelse(t3sum19==0, 0, (t3q19supp - t3q19opp)/t3sum19))
nireland$t3q20bias <- with(nireland, ifelse(t3sum20==0, 0, (t3q20supp - t3q20opp)/t3sum20))
nireland$t3q21bias <- with(nireland, ifelse(t3sum21==0, 0, (t3q21supp - t3q21opp)/t3sum21))

# Total
nireland$t2tot   <-  with(nireland, rowSums(cbind(t2q18anu, t2q18bnu, t2q19anu,t2q19bnu, t2q20anu, t2q20bnu, t2q21anu, t2q21bnu), na.rm=T))
nireland$t3tot   <-  with(nireland, rowSums(cbind(t3q18anu, t3q18bnu, t3q19anu,t3q19bnu, t3q20anu, t3q20bnu, t3q21anu, t3q21bnu), na.rm=T))
nireland$t2cgtot <-  with(nireland, ifelse(controlpart, t2tot, t3tot))

##Getting q text for another file and merging it with results file
#n.ireland.indices <- read.csv("Ireland/data/n.ireland.indices.csv", header=T)

## Save Stuff
save(nireland, file="Ireland/data/nireland.rdata")      ## Saving in Diff. Directory

# Guess Output
# ~~~~~~~~~~~~~~~~~~~~~~~~~
load("Ireland/data/nireland.rdata")
#t1q21ans, t2q11ans What percentage of majority-Protestant or majority-Catholic schools in Northern Ireland have at least 10% of the other religion in their enrolment?
#t1q22ans, t2q12ansBy approximately what percentage has the number of children entering Omagh schools increased or decreased over the past five years
#t1q23ans, t2q13ansThe new entitlement framework requires that… 
#t1q24ans, t2q14ansThe new entitlement framework requires that… 
#t1q25ans, t2q15ans Which of the following is true of what pupils in Northern Ireland do after they leave school?
#t1q26ans, t2q16ansWhich of the following is true of current school funding?
#t1q27ans, t2q17ansWhich of the following is true of the employing authority in the schools?

nireland$t1q21raw <- recode(as.numeric(nireland$t1q21), "4=1;c(1,2,3,5)=0;c(9,10)=NA")
nireland$t1q22raw <- recode(as.numeric(nireland$t1q22), "4=1;c(1,2,3,5)=0;c(9,10)=NA")
nireland$t1q23raw <- recode(as.numeric(nireland$t1q23), "1=1;c(2,3,4,5)=0;c(9,10)=NA")
nireland$t1q24raw <- recode(as.numeric(nireland$t1q24), "4=1;c(1,2,3,5)=0;c(9,10)=NA")
nireland$t1q25raw <- recode(as.numeric(nireland$t1q25), "3=1;c(1,2,4,5)=0;c(9,10)=NA")
nireland$t1q26raw <- recode(as.numeric(nireland$t1q26), "1=1;c(2,3,4,5)=0;c(9,10)=NA")
nireland$t1q27raw <- recode(as.numeric(nireland$t1q27), "4=1;c(1,2,3,5)=0;c(9,10)=NA")

nireland$t2q11raw <- recode(as.numeric(nireland$t2q11), "3=1;c(1,2,4)=0;c(5,6,9,10)=NA") # this is correct; 5-10%
nireland$t2q12raw <- recode(as.numeric(nireland$t2q12), "4=1;c(1,2,3,5)=0;c(6,9,10)=NA")
nireland$t2q13raw <- recode(as.numeric(nireland$t2q13), "1=1;c(2,3,4)=0;c(5,6,9,10)=NA")
nireland$t2q14raw <- recode(as.numeric(nireland$t2q14), "4=1;c(1,2,3)=0;c(5,6,9,10)=NA")
nireland$t2q15raw <- recode(as.numeric(nireland$t2q15), "3=1;c(1,2,4)=0;c(5,6,9,10)=NA")
nireland$t2q16raw <- recode(as.numeric(nireland$t2q16), "1=1;c(2,3)=0;c(4,5,6,9,10)=NA")
nireland$t2q17raw <- recode(as.numeric(nireland$t2q17), "4=1;c(1,2,3)=0;c(5,6,9,10)=NA")

nireland$educ4 <- nireland$ppeduc

irepk <- c(paste0("t1q2", 1:7, "ans"),
paste0("t2q1", 1:7, "ans"),
paste0("t1q2", 1:7, "raw"),
paste0("t2q1", 1:7, "raw"),
"t1know", "t2know", "age", "educ4","female")

irep <- subset(nireland, controlpart==1)

ireirt <-irep[, irepk]
ireirt[, paste0("t1q2", 1:7, "ans")] <- (ireirt[, paste0("t1q2", 1:7, "ans")]=="correct")*1
write.csv(ireirt, file="guess/data/bypoll/ireirt.csv")

## GET OPEN-ENDED NOW ##
##***********************************
load("data/CDD/Ireland/open.c.rdata")
nireland <- merge(nireland, open.c, by.x="cserial", by.y="Participant.ID", all.x=T, all.y=F)
save(nireland, file="Ireland/data/nireland.rdata")