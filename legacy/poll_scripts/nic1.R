#
# NIC 1
#

# Set Working dir 
setwd(basedir)

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/hlmFunc.R")

#13 NIC I            
nic1<- foreign::read.spss(paste0(basedir, "cdd/data/NIC 1/nic123_r.sav"), to.data.frame = T)
names(nic1) <- tolower(names(nic1))

# Participants Only
nic1 <- subset(nic1, nic1$part == 1)

## POLL Vars
nic1$numindices <- 9
nic1$pollid     <- 1001
nic1$country    <- 1
nic1$mode       <- 1
nic1$numitems   <- 11
nic1$caseid     #<- nic1$caseid
nic1$length     <- NA
nic1$timebtw    <- NA

## Group
nic1$pollgroup <- pgroup(nic1$rgroup2, 94444+nic1$pollid)
nic1$groupsize <- grpfun(rep(1, nrow(nic1)), nic1$pollgroup, fun = "sum")

# Knowledge
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Wedlock answer: range(nic1$wedlock1[!(nic1$knowwed1+1)==1]): 25 to 40 scored as 1
# from luskin/fishkin 2002
# knowwed1, knowwed2, 
nic1$knowwed3<- nona(as.integer(nic1$knowwed3))

# afdc1, knowafd1, knowafd2, knowafd3
nic1$knowafd3<- nona(as.integer(nic1$knowafd3))

# employment: unemp1, unemp2, unemp3, knowemp1
nic1$knowemp3<- nona(as.integer(nic1$knowemp3))

# trade1: Which country US does most international trade T2 (Q17)
#ffact1, ffact2, ffact3
nic1$ffact3 <- nona(as.integer(nic1$ffact3))

# "troopsa1"   "troopsb1"   "troopsc1"   "troopsd1"
# t1: ftfact11, ftfact21, ftfact31, ftfact41
# t2: "ftfact12" "ftfact22" "ftfact32" "ftfact42"
# t3:  "ftfact13" "ftfact23" "ftfact33" "ftfact43"
nic1$ftfact13 <- nona(as.integer(nic1$ftfact13))
nic1$ftfact23 <- nona(as.integer(nic1$ftfact23))
nic1$ftfact33 <- nona(as.integer(nic1$ftfact33))
nic1$ftfact43 <- nona(as.integer(nic1$ftfact43))

# Which does federal government spent more money?
# "spend1"   efact1, efact2, efact3
nic1$efact3 <- ifelse(is.na(nic1$efact3), 0, as.integer(nic1$efact3))

# Lib/Con Placements
# # "polrep1"    "poldem1"
nic1$repfact1 <- nona(recode(as.integer(nic1$polrep1), "8 = NA") > 4)
nic1$repfact2 <- nona(recode(as.integer(nic1$polrep2), "8 = NA") > 4)
nic1$repfact3 <- nona(recode(as.integer(nic1$polrep3), "8 = NA") > 4)

nic1$demfact1 <- nona(recode(as.integer(nic1$poldem1), "8 = NA") < 4)
nic1$demfact2 <- nona(recode(as.integer(nic1$poldem2), "8 = NA") < 4)
nic1$demfact3 <- nona(recode(as.integer(nic1$poldem3), "8 = NA") < 4)

# Corrected facts
# Correcting T1
nic1$knowwed1cor<- pkcor(nic1$knowwed1, nic1$knowwed3)
nic1$knowafd1cor<- pkcor(nic1$knowafd1, nic1$knowafd3)
nic1$knowemp1cor<- pkcor(nic1$knowemp1, nic1$knowemp3)

nic1$efact1cor<- pkcor(nic1$efact1, nic1$efact3)
nic1$ffact1cor<- pkcor(nic1$ffact1, nic1$ffact3)

nic1$ftfact11cor<- pkcor(nic1$ftfact11, nic1$ftfact13)
nic1$ftfact21cor<- pkcor(nic1$ftfact21, nic1$ftfact23)
nic1$ftfact31cor<- pkcor(nic1$ftfact31, nic1$ftfact33)
nic1$ftfact41cor<- pkcor(nic1$ftfact41, nic1$ftfact43)

nic1$repfact1cor<- pkcor(nic1$repfact1, nic1$repfact3)
nic1$demfact1cor<- pkcor(nic1$demfact1, nic1$demfact3)

# Correcting Arrival
nic1$knowwed2cor<- pkcor(nic1$knowwed2, nic1$knowwed3)
nic1$knowafd2cor<- pkcor(nic1$knowafd2, nic1$knowafd3)
nic1$knowemp2cor<- pkcor(nic1$knowemp2, nic1$knowemp3)

nic1$efact2cor<- pkcor(nic1$efact2, nic1$efact3)
nic1$ffact2cor<- pkcor(nic1$ffact2, nic1$ffact3)

nic1$ftfact12cor<- pkcor(nic1$ftfact12, nic1$ftfact13)
nic1$ftfact22cor<- pkcor(nic1$ftfact22, nic1$ftfact23)
nic1$ftfact32cor<- pkcor(nic1$ftfact32, nic1$ftfact33)
nic1$ftfact42cor<- pkcor(nic1$ftfact42, nic1$ftfact43)

nic1$repfact2cor<- pkcor(nic1$repfact2, nic1$repfact3)
nic1$demfact2cor<- pkcor(nic1$demfact2, nic1$demfact3)

# Double correcting T1
nic1$knowwed1cor2<- pkcor(nic1$knowwed1cor, nic1$knowwed2)
nic1$knowafd1cor2<- pkcor(nic1$knowafd1cor, nic1$knowafd2)
nic1$knowemp1cor2<- pkcor(nic1$knowemp1cor, nic1$knowemp2)

nic1$efact1cor2<- pkcor(nic1$efact1cor, nic1$efact2)
nic1$ffact1cor2<- pkcor(nic1$ffact1cor, nic1$ffact2)

nic1$ftfact11cor2<- pkcor(nic1$ftfact11cor, nic1$ftfact12)
nic1$ftfact21cor2<- pkcor(nic1$ftfact21cor, nic1$ftfact22)
nic1$ftfact31cor2<- pkcor(nic1$ftfact31cor, nic1$ftfact32)
nic1$ftfact41cor2<- pkcor(nic1$ftfact41cor, nic1$ftfact42)

nic1$repfact1cor2<- pkcor(nic1$repfact1cor, nic1$repfact2)
nic1$demfact1cor2<- pkcor(nic1$demfact1cor, nic1$demfact2)

# Some conv. vecs.
knowbat<- c("knowwed", "knowafd", "knowemp", "efact", "ffact", "ftfact1", "ftfact2", "ftfact3", "ftfact4", "repfact", "demfact")
knowbat1<- paste0(knowbat, "1")
knowbat12<- paste0(knowbat, "2")
knowbat2<- paste0(knowbat, "3")

# Know
# know1, know2, know3
nic1$t1know <- rowMeans(nic1[, knowbat1])
nic1$t12know<- rowMeans(nic1[, knowbat12])
nic1$t2know <- rowMeans(nic1[, knowbat2])
nic1$t1knowlevel<- mean(nic1$t1know)
nic1$t1knowcor<- rowMeans(nic1[, paste0(knowbat1, "cor")])
nic1$t12knowcor<- rowMeans(nic1[, paste0(knowbat12, "cor")])
nic1$t1knowcor2 <- rowMeans(nic1[, paste0(knowbat1, "cor2")])

## Knowledge over the highest quartile is High Knowledge
nic1$highknow <- as.numeric((nic1$t1know > fivenum(nic1$t1know)[4]))

# Group Gain
nic1$grpgain  <- groupgain(nic1[, paste0(knowbat1, "cor")],  nic1$pollgroup, nrow(nic1), nic1$numitems, nic1$groupsize)
nic1$grpgain2 <- groupgain(nic1[, paste0(knowbat12, "cor")],  nic1$pollgroup, nrow(nic1), nic1$numitems, nic1$groupsize)

# Sociodem
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nic1$ppage<- 1996 - nic1$byear
nic1$female<- as.numeric(as.integer(nic1$sex1) == 2) # Checked via codebook
nic1$income<- NA
nic1$hhincome<- NA 
nic1$highinc<- NA #70k or above
nic1$minority<- as.integer(nic1$race1) != 1
# 4 = High School (checked the codebook)
nic1$educ4<- recode(as.integer(nic1$edlevel1),"c(1, 2, 3) = 0; c(4, 5, 6, 7) = .33; c(8, 9, 10) = .66; c(11, 12, 13) = 1; else = NA")
nic1$educollege<- nic1$educ4 == 1

# Read brief and polint
nic1$t1polint<- zero1(ifelse(nic1$polintr1 > 5, NA, nic1$polintr1))
nic1$readbrief<- zero1(recode(as.integer(nic1$readdis2), "1 = 0; c(2, 3) = .33; 4 = .66; 5 = 1"))

# Group Level Vars
nic1$pminority<- grpfun(nic1$minority, nic1$pollgroup, fun = "mean")
nic1$pfemale<- grpfun(nic1$female, nic1$pollgroup, fun = "mean")
nic1$varfemale<- nic1$pfemale*(1 - nic1$pfemale)
nic1$meant1know<- grpfun(nic1$t1know, nic1$pollgroup, fun = "mean")
nic1$meant1know_ind<- (nic1$meant1know*nic1$groupsize - nic1$t1know )/ (nic1$groupsize - 1)
nic1$meant2know<- grpfun(nic1$t2know, nic1$pollgroup, fun = "mean")
nic1$phighknow<- grpfun(nic1$highknow, nic1$pollgroup, fun = "mean")
nic1$phigheduc<- NA
nic1$vareduc<- grpfun(nic1$educ4, nic1$pollgroup, fun = "var")
nic1$phighinc<- NA

# Attitudes
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# draft says 7 indices for CP paper
# unclear which...
# using 9 spending variables (could use 11 foreign policy Qs)

#environment
nic1$t1att1<- with(nic1, zero1(ifelse(is.na(spenvir1) | spenvir1 >4, 2, spenvir1)))
nic1$t12att1<- with(nic1, zero1(ifelse(is.na(spenvir2) | spenvir2 >4, 2, spenvir2)))
nic1$t2att1<- with(nic1, zero1(ifelse(is.na(spenvir3) | spenvir3 >4, 2, spenvir3)))

#medicare/medicaid
nic1$t1att2<- with(nic1, zero1(ifelse(is.na(spmedic1) | spmedic1 >4, 2, spmedic1)))
nic1$t12att2<- with(nic1, zero1(ifelse(is.na(spmedic2) | spmedic2 >4, 2, spmedic2)))
nic1$t2att2 <- with(nic1, zero1(ifelse(is.na(spmedic3) | spmedic3 >4, 2, spmedic3)))

# law enforcement
nic1$t1att3 <- with(nic1, zero1(ifelse(is.na(splaw1) | splaw1 >4, 2, splaw1)))
nic1$t12att3 <- with(nic1, zero1(ifelse(is.na(splaw2) | splaw2 >4, 2, splaw2)))
nic1$t2att3 <- with(nic1, zero1(ifelse(is.na(splaw3) | splaw3 >4, 2, splaw3)))

# drug rehab
nic1$t1att4 <- with(nic1, zero1(ifelse(is.na(spdrug1) | spdrug1>4, 2, spdrug1)))
nic1$t12att4 <- with(nic1, zero1(ifelse(is.na(spdrug2) | spdrug2>4, 2, spdrug2)))
nic1$t2att4 <- with(nic1, zero1(ifelse(is.na(spdrug3) | spdrug3>4, 2, spdrug3)))

#education
nic1$t1att5<- with(nic1, zero1(ifelse(is.na(speduc1) | speduc1>4, 2, speduc1)))
nic1$t12att5 <- with(nic1, zero1(ifelse(is.na(speduc2) | speduc2>4, 2, speduc2)))
nic1$t2att5<- with(nic1, zero1(ifelse(is.na(speduc3) | speduc3>4, 2, speduc3)))

#national defense
nic1$t1att6 <- with(nic1, zero1(ifelse(is.na(spdef1) | spdef1>4, 2, spdef1)))
nic1$t12att6 <- with(nic1, zero1(ifelse(is.na(spdef2) | spdef2>4, 2, spdef2)))
nic1$t2att6 <- with(nic1, zero1(ifelse(is.na(spdef3) | spdef3>4, 2, spdef3)))

#foreign aid
nic1$t1att7 <- with(nic1, zero1(ifelse(is.na(spfaid1) | spfaid1>4, 2, spfaid1)))
nic1$t12att7 <- with(nic1, zero1(ifelse(is.na(spfaid2) | spfaid2>4, 2, spfaid2)))
nic1$t2att7 <- with(nic1, zero1(ifelse(is.na(spfaid3) | spfaid3>4, 2, spfaid3)))

# welfare
nic1$t1att8 <- with(nic1, zero1(ifelse(is.na(spwelf1) | spwelf1>4, 2, spwelf1)))
nic1$t12att8 <- with(nic1, zero1(ifelse(is.na(spwelf2) | spwelf2>4, 2, spwelf2)))
nic1$t2att8 <- with(nic1, zero1(ifelse(is.na(spwelf3) | spwelf3>4, 2, spwelf3)))

# social security
nic1$t1att9 <- with(nic1, zero1(ifelse(is.na(spss1) | spss1>4, 2, spss1)))
nic1$t12att9 <- with(nic1, zero1(ifelse(is.na(spss2) | spss2>4, 2, spss2)))
nic1$t2att9 <- with(nic1, zero1(ifelse(is.na(spss3) | spss3>4, 2, spss3)))

# Att. Extreme and Var
nic1att <- nic1[,c("t1att1", "t1att2", "t1att3", "t1att4", "t1att5", "t1att6", "t1att7","t1att8","t1att9")]
nic2att <- nic1[,c("t12att1", "t12att2", "t12att3", "t12att4", "t12att5", "t12att6", "t1att7","t1att8","t1att9")]

nic1$genvar<- unsplit(lapply(split(nic1att, nic1$pollgroup), genvar),nic1$pollgroup)
nic1$attextreme<- rowMeans(abs(nic1att - .5), na.rm=T)
nic1$attextreme2<- rowMeans(abs(nic2att - .5), na.rm=T)

fromlist    <- names(nic1att)
tolist      <- paste("var", fromlist, sep = "")
nic1[,tolist] <- sapply(nic1[, fromlist], function(x) grpfun(x, nic1$pollgroup, fun = "var"))

nic1$avgsd<- rowMeans(sqrt(nic1[, tolist]))

fromlist    <- names(nic2att)
tolist      <- paste("var", fromlist, sep = "")
nic1[,tolist] <- sapply(nic1[, fromlist], function(x) grpfun(x, nic1$pollgroup, fun = "var"))

nic1$avgsd2<- rowMeans(sqrt(nic1[, tolist]))
nic1$age<- 1996 - nic1$ppage

# Outputting
# ~~~~~~~~~~~~~~~~~~~~~~~~~
# Guess Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 3 Open-ended questions
# knowwed, knowafd, knowemp

knowbat<- c("efact", "ffact", "ftfact1", "ftfact2", "ftfact3", "ftfact4", "repfact", "demfact")
knowbat1<- paste0(knowbat, "1")
knowbat12<- paste0(knowbat, "12")
knowbat2<- paste0(knowbat, "2")
knowbat1cor<- paste0(knowbat, "1cor")
knowbat1raw<- paste0(knowbat, "1raw")
knowbat2raw<- paste0(knowbat, "2raw")

# T1
# TROOPSA1: ftfact1
nic1$ftfact11raw <- recode(round(nic1$troopsa1), "8 = NA") # Iraq
nic1$ftfact21raw <- recode(round(nic1$troopsb1), "8 = NA") # Somalia
nic1$ftfact31raw <- recode(round(nic1$troopsc1), "1 = 0; 0 = 1; 8 = NA") # Rwanda
nic1$ftfact41raw <- recode(round(nic1$troopsd1), "8 = NA")# Boston

# EFACT1: SPEND1
nic1$efact1raw <- recode(round(nic1$spend1), "c(1, 2, 4) = 0; 8 = NA")

# FFACT1: TRADE1
nic1$ffact1raw <- recode(round(nic1$trade1), "c(2, 3, 4) = 0; 8 = NA")

# RD Facts
nic1$repfact1raw <- recode(as.integer(nic1$polrep1), "8 = NA") > 4
nic1$demfact1raw <- recode(as.integer(nic1$poldem1), "8 = NA") < 4

# T2
# Troops
nic1$ftfact12raw <- recode(round(nic1$troopsa2), "8 = NA")
nic1$ftfact22raw <- recode(round(nic1$troopsb2), "8 = NA")
nic1$ftfact32raw <- recode(round(nic1$troopsc2), "1 = 0; 0 = 1; 8 = NA")
nic1$ftfact42raw <- recode(round(nic1$troopsd2), "8 = NA")

# EFACT1: SPEND1
nic1$efact2raw <- recode(round(nic1$spend2), "c(1, 2, 4) = 0; 8 = NA")

# FFACT1: TRADE1
nic1$ffact2raw <- recode(round(nic1$trade2), "c(2, 3, 4) = 0; 8 = NA")

# RD Facts
nic1$repfact2raw <- recode(as.integer(nic1$polrep2), "8 = NA") > 4
nic1$demfact2raw <- recode(as.integer(nic1$poldem2), "8 = NA") < 4

# T3
# Troops
nic1$ftfact13raw <- recode(round(nic1$troopsa3), "8 = NA")
nic1$ftfact23raw <- recode(round(nic1$troopsb3), "8 = NA")
nic1$ftfact33raw <- recode(round(nic1$troopsc3), "1 = 0; 0 = 1; 8 = NA")
nic1$ftfact43raw <- recode(round(nic1$troopsd3), "8 = NA")

# EFACT1: SPEND1
nic1$efact3raw <- recode(round(nic1$spend3), "c(1, 2, 4) = 0; 8 = NA")

# FFACT1: TRADE1
nic1$ffact3raw <- recode(round(nic1$trade3), "c(2, 3, 4) = 0; 8 = NA")

# RD Facts
nic1$repfact3raw <- recode(as.integer(nic1$polrep3), "8 = NA") > 4
nic1$demfact3raw <- recode(as.integer(nic1$poldem3), "8 = NA") < 4

# name vector
nic1k <- c("caseid", 
knowbat1,
knowbat2,
knowbat1cor,
knowbat1raw,
knowbat2raw,
"t1know", "t2know", "age", "pollgroup", "educ4","female")

nic1irt <- nic1[, nic1k]
write.csv(nic1irt, file = "guess/data/bypoll/nic1irt.csv")

# PK subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nic1n <- nic1[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw")]

# Save File
save(nic1n, file = "pk/data/nic1n.Rdata")
save(nic1n, file = "cdd/pkdat/nic1n.Rdata")

# Kyu subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~
nic1kyu <- nic1[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw", 
"t1att1", "t1att2", "t1att3", "t1att4", "t1att5", "t1att6", "t1att7", "t1att8", "t1att9",
"t2att1", "t2att2", "t2att3", "t2att4", "t2att5", "t2att6", "t2att7", "t2att8", "t2att9")]

save(nic1kyu, file="cdd/kyu/bypoll/nic1kyu.rdata", ascii = TRUE)
