#
#  UK Crime
#

# Set Working dir.
setwd(basedir)

# Sourcing libs 
library(goji)
library(car)

# Sourcing common functions
source("func/func.R")
source("cdd/hlmFunc.R")

## SPSS to R, ALL
ukcrime <- spss("cdd/data/British Crime/uk-crime.sav")

###********************************************** ########
###FOR PRE-PROCESSING ATT. INDICES - GO TO THE END ####
####********************************************** #####

## Poll Variables
ukcrime$numindices <- 5
ukcrime$pollid     <- 27
ukcrime$country    <- 2
ukcrime$mode       <- 0
ukcrime$numitems   <- 7
ukcrime$caseid     <- 10000 + seq(1, nrow(ukcrime))
ukcrime$length     <- 2
ukcrime$timebtw    <- NA

## Group
ukcrime$pollgroup <- pgroup(ukcrime$group, ukcrime$pollid)
ukcrime$groupsize <- grpfun(rep(1, nrow(ukcrime)), ukcrime$group, fun = "sum")

#L1 Variables: t1know t2know female   minority  ppage educ4 hhincome attextreme highinc t1polint  attextreme readbrief
#sex, age, nonwhite, educ, educ7, eductri, pk1, pk2

## Knowledge
## --------------

# C18b. KW21:  Here is a quick quiz about the British legal system
            
            Do you think that the following statement is true,
            false, or do you not know whether it is true or false?

            Britain has a larger prison population than any other
            country in Western Europe


##Check to see that there is no missing on factual items. Assign missing to 0.
#Just checking - facts <- (ukcrime$rpfact1 +ukcrime$qrfact1 +ukcrime$pfact1+ukcrime$ggfact1)/4

##t1polfacts lfact11, lfact21, lfact31, lfact41, pfact11, pfact21, pfact31, pfact41
#Discard item pcfact41

ukcrime$lfact11cor <- pkcor(ukcrime$lfact11, ukcrime$lfact12)
ukcrime$lfact21cor <- pkcor(ukcrime$lfact21, ukcrime$lfact22)
ukcrime$lfact31cor <- pkcor(ukcrime$lfact31, ukcrime$lfact32)
ukcrime$lfact41cor <- pkcor(ukcrime$lfact41, ukcrime$lfact42)
ukcrime$pfact11cor <- pkcor(ukcrime$pfact11, ukcrime$pfact12)
ukcrime$pfact21cor <- pkcor(ukcrime$pfact21, ukcrime$pfact22)
ukcrime$pfact31cor <- pkcor(ukcrime$pfact31, ukcrime$pfact32)

ukcrime$t1knowcor <- with(ukcrime, rowMeans(cbind(lfact11cor, lfact21cor, lfact31cor, lfact41cor, pfact11cor, pfact21cor, pfact31cor)))
ukcrime$t1know    <- with(ukcrime, rowMeans(cbind(lfact11, lfact21 , lfact31 , lfact41, pfact11, pfact21, pfact31)))
ukcrime$t2know    <- with(ukcrime, rowMeans(cbind(lfact12, lfact22 , lfact32 , lfact42, pfact12, pfact22, pfact32)))

ukcrime$t1knowr <- with(ukcrime, rowMeans(cbind(lfact11, lfact21, lfact31, lfact41)))
ukcrime$t1knowrcor  <- with(ukcrime, rowMeans(cbind(lfact11cor, lfact21cor, lfact31cor, lfact41cor)))
ukcrime$t2knowr <- with(ukcrime, rowMeans(cbind(lfact12, lfact22 , lfact32 , lfact42)))

# Calculate reliability
pksubs <- with(ukcrime, data.frame(lfact12, lfact22 , lfact32 , lfact42, pfact12, pfact22, pfact32))
ltm::cronbach.alpha(pksubs, standardized = FALSE, CI = FALSE, probs = c(0.025, 0.975), B = 1000, na.rm = TRUE)

# Does reliability improve post-correction?
with(ukcrime, ltm::cronbach.alpha(cbind(lfact11, lfact21 , lfact31 , lfact41, pfact11, pfact21, pfact31)))
with(ukcrime, ltm::cronbach.alpha(cbind(lfact11cor, lfact21cor, lfact31cor, lfact41cor, pfact11cor, pfact21cor, pfact31cor)))

## Group Gain
knowindex <- with(ukcrime, data.frame(lfact11cor, lfact21cor, lfact31cor, lfact41cor, pfact11cor, pfact21cor, pfact31cor))
ukcrime$grpgain <- with(ukcrime, groupgain(knowindex, group, nrow(ukcrime), numitems, groupsize))

knowindex  <- with(ukcrime, data.frame(lfact11cor, lfact21cor, lfact31cor, lfact41cor))
ukcrime$grpgainr <- with(ukcrime, groupgain(knowindex, group, nrow(ukcrime), numitems, groupsize))

## Other Sociodem
ukcrime$female <- as.numeric(!ukcrime$sex)
ukcrime$educollege <- recode(ukcrime$educ7, "6 = 1; else = 0")

#educ7###EDUCATION
ukcrime$educ4 <- recode(ukcrime$educ7,"c(0, 1) = 0; c(2, 3) = .33; c(4, 5) = .66; 6 = 1")
#cor(ukcrime$t1know,temp, use = "na.or.complete")
cor(ukcrime$t1know,ukcrime$educ4, use = "na.or.complete")

ukcrime$minority <- ukcrime$nonwhite
##Assign missing, DK to NA
ukcrime$income <- NA
ukcrime$hhincome <- NA
ukcrime$highinc  <- NA #70k or above
ukcrime$highknow <- (ukcrime$t1know > fivenum(ukcrime$t1know)[4])
ukcrime$ppage    <- ukcrime$age

# Polint and Readbrief
ukcrime$t1polint <- NA
ukcrime$readbrief <- NA

#Media Consumption Variables:
#READPAP   = Reads daily morning paper at least three times a week (B1a)
#NEWS      = Newspaper normally read by respondent (B1b)
#NEWSTRI   = Trichotomized output for daily morning newspaper consumption
#INTERES3  = Did weekend increase interest in public affairs? (QD22)
##Knowledge over the highest quartile is High Knowledge

## L2 Variables
ukcrime$pminority   <-  with(ukcrime, grpfun(nonwhite, group, fun = "mean"))
ukcrime$pfemale     <-  grpfun(ukcrime$female, ukcrime$group, fun = "mean")
ukcrime$varfemale   <- (ukcrime$female)*(1 - ukcrime$female)
ukcrime$meant1know     <- grpfun(ukcrime$t1know, ukcrime$group, fun = "mean")
ukcrime$meant1know_ind <- with(ukcrime,(meant1know*groupsize - t1know )/(groupsize - 1))
ukcrime$meant2know     <- grpfun(ukcrime$t2know, ukcrime$group, fun = "mean")
ukcrime$phighknow   <- grpfun(ukcrime$highknow, ukcrime$group, fun = "mean")
ukcrime$phigheduc   <- grpfun(ukcrime$educollege, ukcrime$group, fun = "mean")
ukcrime$vareduc     <- grpfun(ukcrime$educ4, ukcrime$group, fun = "var")
ukcrime$phighinc   <- NA

##########################
###########Policy Attitudes
#The items fall naturally into just five multi-item clusters, gauging the extent to which the respondent favoured imposing stricter and more certain punishment, giving
#greater attention to ameliorating the social root causes of crime, relaxing procedural protections for those suspected or accused of crimes, giving the
#police more power and resources, and placing greater emphasis on selfprotection.

#Social Root Causes -> rootcauset1, rootcauset2
#Spend more time with children; Reduce TV violence and crime; Firmer school discipline
cor(cbind(ukcrime$timchld1, ukcrime$violtv1, ukcrime$schdisc1), use = "na.or.complete")

ukcrime$timchld1r <- recode(ukcrime$timchld1, "5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")
ukcrime$violtv1r  <- recode(ukcrime$violtv1,  "5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")
ukcrime$schdisc1r <- recode(ukcrime$schdisc1, "5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")

ukcrime$timchld2r <- recode(ukcrime$morecop1, "5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")
ukcrime$violtv2r <- recode(ukcrime$violtv2,   "5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")
ukcrime$schdisc2r <- recode(ukcrime$schdisc2, "5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")

ukcrime$rootcauset1 <- with(ukcrime, rowMeans(cbind(timchld1r, violtv1r, schdisc1r), na.rm = TRUE))
ukcrime$rootcauset2 <- with(ukcrime, rowMeans(cbind(timchld2r, violtv2r, schdisc2r), na.rm = TRUE))

#Police ->policet1, policet2
#More police on the beat; Off-duty police carry guns
ukcrime$morecop1r <- recode(ukcrime$morecop1, "5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")
ukcrime$copgun1r  <- recode(ukcrime$copgun1, "5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")

ukcrime$morecop2r <- recode(ukcrime$morecop2, "5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")
ukcrime$copgun2r  <- recode(ukcrime$copgun2, "5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")

ukcrime$policet1 <- rowMeans(cbind(ukcrime$morecop1r, ukcrime$copgun1r), na.rm = TRUE)
ukcrime$policet2 <- rowMeans(cbind(ukcrime$morecop2r, ukcrime$copgun2r), na.rm = TRUE)

#Punishment ->punisht1, punisht2
#Punishment vs. reform PUNREF1
#Prisons reform, not just punishREFPRIS1
#Tougher sentencesS_TOUGH1
#Stiffer sentences generally     STIFFER1
#More offenders to prison MORPRSN1
#Fewer people to prison  FEWPRIS1
#Only dangerous criminals to prison  PR_ONLY1
#More offenders out of prisonOUTPRSN1
#More offenders: community serv.  COMSERV1
#More offenders: military serv. MILSERV1
#More offenders get training TRAIN1 
#Prison life tougherPTOUGH1
#All murderers life sentence  LIFE1
#Life sentence means lifeLIFMEAN1
#Death most approp. for some crimesDEATH1
#PUNREF1 REFPRIS1S_TOUGH1  FEWPRIS1   PR_ONLY1 OUTPRSN1 COMSERV1 MILSERV1 TRAIN1  PTOUGH1  LIFE1  LIFMEAN1 DEATH1

r5  <- "5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0"
rev5 <- "5 = 0; 4 = .25; 3 = .50; 2 = .75; 1 = 1"

fromlist <- c("punref1", "stiffer1", "morprsn1", "s_tough1", "milserv1", "ptough1", "life1", "lifmean1", "death1",
  "punref2", "stiffer2", "morprsn2", "s_tough2", "milserv2", "ptough2", "life2", "lifmean2", "death2")
tolist   <- paste(fromlist, "r", sep = "")
ukcrime[,tolist] <- sapply(ukcrime[,fromlist], function(x) recode(x, r5))

fromlist <- c("refpris1", "fewpris1", "pr_only1", "outprsn1", "comserv1", "train1",
  "refpris2", "fewpris2", "pr_only2", "outprsn2", "comserv2", "train2")
tolist   <- paste(fromlist, "r", sep = "")
ukcrime[,tolist] <- sapply(ukcrime[, fromlist], function(x) recode(x, rev5))

with(ukcrime, cor(cbind(punref1r, stiffer1r, morprsn1r, refpris1r, s_tough1r, fewpris1r , pr_only1r , outprsn1r , comserv1r, milserv1r, train1r, ptough1r, life1r, lifmean1r , death1r), use = "na.or.complete"))

ukcrime$punisht1 <- with(ukcrime, rowMeans(cbind(punref1r, stiffer1r, morprsn1r, refpris1r, s_tough1r, fewpris1r, pr_only1r, outprsn1r, comserv1r, milserv1r, train1r, ptough1r, life1r , lifmean1r, death1r), na.rm = TRUE))
ukcrime$punisht2 <- with(ukcrime, rowMeans(cbind(punref2r, stiffer2r, morprsn2r, refpris2r, s_tough2r, fewpris2r, pr_only2r, outprsn2r, comserv2r, milserv2r, train2r, ptough2r, life2r, lifmean2r , death2r), na.rm = TRUE))

#Procedural Rights         -> procrightst1 procrightst2
#Convict innoc. vs. not punish guilty  INNGLT1 
#Police allowed to bend rulesCOPBEND1
#Fewer jury trialsFEWJURY1
#Court rules less on side accusedCTRULES1
#End presumption of innocencePRESUM1
#Silence mentionable in courtMENTSIL1
#Right to silence in police questioningRTSIL1
#Confessions alone not convictCONFESS1


fromlist <- c("innglt1", "copbend1", "fewjury1", "ctrules1", "presum1", "mentsil1",
  "innglt2", "copbend2", "fewjury2", "ctrules2", "presum2", "mentsil2")
tolist   <- paste(fromlist, "r", sep = "")
ukcrime[,tolist] <- sapply(ukcrime[, fromlist], function(x) recode(x, "5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0"))

r5 <- "5 = 0; 4 = .25; 3 = .50; 2 = .75; 1 = 1"
ukcrime$rtsil1r   <- recode(ukcrime$rtsil1, r5)
ukcrime$confess1r <- recode(ukcrime$confess1, r5)
ukcrime$rtsil2r   <- recode(ukcrime$rtsil2, r5)
ukcrime$confess2r <- recode(ukcrime$confess2, r5)

with(ukcrime, cor(cbind(innglt1r, copbend1r, fewjury1r, ctrules1r, presum1r, mentsil1r, rtsil1r, confess1r ), use = "na.or.complete"))
ukcrime$procrightst1 <- with(ukcrime, rowMeans(cbind(innglt1r, copbend1r, fewjury1r, ctrules1r, presum1r, mentsil1r, rtsil1r, confess1r ), na.rm = TRUE))
mean(ukcrime$procrightst1, na.rm = TRUE)

ukcrime$procrightst2 <- with(ukcrime, rowMeans(cbind(innglt2r, copbend2r , fewjury2r, ctrules2r, presum2r, mentsil2r, rtsil2r, confess2r), na.rm = TRUE))

###Self-Protection   -> selfprotectt1, selfprotectt2
#People make property more secure  PROPSEC1
#More Neighborhood Watch schemesWATCH1
#Street patrols vs. policePATROLS1

ukcrime$propsec1r <- recode(ukcrime$propsec1,"5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")
ukcrime$watch1r   <- recode(ukcrime$watch1,"5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")
ukcrime$patrols1r <- recode(ukcrime$patrols1,"5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")

ukcrime$propsec2r <- recode(ukcrime$propsec2,"5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")
ukcrime$watch2r   <- recode(ukcrime$watch2,"5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")
ukcrime$patrols2r <- recode(ukcrime$patrols2,"5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")

ukcrime$selfprotectt1 <- with(ukcrime, rowMeans(cbind(propsec1r, watch1r, patrols1r), na.rm = TRUE))
ukcrime$selfprotectt2 <- with(ukcrime, rowMeans(cbind(propsec2r, watch2r, patrols2r), na.rm = TRUE))
mean(ukcrime$selfprotectt1, na.rm = TRUE)

ukcrime$procrightst1.ind  <- with(ukcrime, (grpfun(procrightst1, pollgroup, fun = "sum") - procrightst1)/groupsize)
ukcrime$policet1.ind      <- with(ukcrime, (grpfun(policet1, pollgroup, fun = "sum") - policet1)/groupsize)
ukcrime$punisht1.ind      <- with(ukcrime, (grpfun(punisht1, pollgroup, fun = "sum") - punisht1)/groupsize)
ukcrime$selfprotectt1.ind <- with(ukcrime, (grpfun(selfprotectt1, pollgroup, fun = "sum") - selfprotectt1)/groupsize)
ukcrime$rootcauset1.ind   <- with(ukcrime, (grpfun(rootcauset1, pollgroup, fun = "sum") - rootcauset1)/groupsize)

# Save file
save(ukcrime, file = "truepk/data/ukcrime.rdata")

##Att. Extremity
#library(base)
#ukcrime$attextreme <- rowMeans(cbind(abs(ukcrime$workind1 -.5), abs(ukcrime$Demind1 - .5), abs(ukcrime$Tradind1 - .5), abs(ukcrime$Polind1 - .5)), na.rm = TRUE)

##Income REFUSED/ 98 DON'T KNOW - 987  $70000 OR MORE  -6  $50000-$69999 -5   $40000-$49999  -4   $30000-$39999 -3    $20000-$29999-2 LESS THAN $20000 -1

##Policy Indices
#Social Root Causes -> rootcauset1, rootcauset2
#Police ->policet1, policet2
#Punishment ->punisht1, punisht2
#Procedural Rights         -> procrightst1 procrightst2
#Self-Protection   -> selfprotectt1, selfprotectt2

#################
############## FOR ATTITUDE INDEX CREATION - SEE BELOW ##############
###################

##Generalized Variance
ukcrime1 <- ukcrime[, c("rootcauset1","policet1","punisht1","procrightst1", "selfprotectt1")]
ukcrime$genvar <- unsplit(lapply(split(ukcrime1, ukcrime$group), genvar),ukcrime$group)

##Attitude extremity
ukcrime$attextreme <- with(ukcrime, rowMeans(abs(cbind((rootcauset1 -.5), (policet1 - .5), 
(punisht1 - .5), (procrightst1  - .5), (selfprotectt1  - .5))), na.rm = TRUE))

##############Attitude Variance
##Attitude Variance in groups - ave. produces some weird NAs, so using aggregate

fromlist <- c("rootcauset1", "policet1", "punisht1", "procrightst1", "selfprotectt1")
tolist   <- paste("var", fromlist, sep = "")
ukcrime[,tolist] <- sapply(ukcrime[,fromlist], function(x) grpfun(x, ukcrime$pollgroup, fun = "var"))

ukcrime$avgsd <- rowMeans(sqrt(ukcrime[,tolist]))

ukcrime$t1knowlevel <- mean(ukcrime$t1know)

# Outputting
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Participant Only
ukcrimep <- subset(ukcrime, ukcrime$part == 1 & !is.na(ukcrime$group)) #one respondent with no small group assignment

ukcrimep$lfact11raw <- recode(ukcrimep$kw11, "0 = 1; 1 = 0; c(8,9) = NA")
ukcrimep$lfact21raw <- recode(ukcrimep$kw21, "c(8,9) = NA")
ukcrimep$lfact31raw <- recode(ukcrimep$kw31, "c(8,9) = NA")
ukcrimep$lfact41raw <- recode(ukcrimep$kw41, "0 = 1; 1 = 0; c(8,9) = NA")

ukcrimep$lfact12raw <- recode(ukcrimep$kw12, "0 = 1; 1 = 0; c(8,9) = NA")
ukcrimep$lfact22raw <- recode(ukcrimep$kw22, "c(8,9) = NA")
ukcrimep$lfact32raw <- recode(ukcrimep$kw32, "c(8,9) = NA")
ukcrimep$lfact42raw <- recode(ukcrimep$kw42, "0 = 1; 1 = 0; c(8,9) = NA")

ukcrimep$pfact11raw <- recode(ukcrimep$pkw11, "0 = 1; 1 = 0; c(8,9) = NA")
ukcrimep$pfact21raw <- recode(ukcrimep$pkw21, "0 = 1; 1 = 0; c(8,9) = NA")
ukcrimep$pfact31raw <- recode(ukcrimep$pkw31, "0 = 1; 1 = 0; c(8,9) = NA")

ukcrimep$pfact12raw <- recode(ukcrimep$pkw12, "0 = 1; 1 = 0; c(8,9) = NA")
ukcrimep$pfact22raw <- recode(ukcrimep$pkw22, "0 = 1; 1 = 0; c(8,9) = NA")
ukcrimep$pfact32raw <- recode(ukcrimep$pkw32, "0 = 1; 1 = 0; c(8,9) = NA")

# Guess Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ukcrimepk <- c("caseid", 
c("lfact11", "lfact21", "lfact31", "lfact41", "pfact11", "pfact21", "pfact31"),
c("lfact12", "lfact22", "lfact32", "lfact42", "pfact12", "pfact22", "pfact32"),
paste0(c("lfact11", "lfact21", "lfact31", "lfact41", "pfact11", "pfact21", "pfact31"), "cor"),
paste0(c("lfact11", "lfact21", "lfact31", "lfact41", "pfact11", "pfact21", "pfact31"), "raw"),
paste0(c("lfact12", "lfact22", "lfact32", "lfact42", "pfact12", "pfact22", "pfact32"), "raw"),
"t1know", "t2know", "age", "pollgroup", "educ4","female")
ukcrirt <- ukcrimep[, ukcrimepk]

write.csv(ukcrirt, file = "guess/data/ukcrimeirt.csv")

# PK Subset
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Midterm Measurement
ukcrimep[, c("avgsd2", "grpgain2", "t1knowcor2", "t12know", "t12knowcor", "attextreme2")] <- NA

ukcrimen <- ukcrimep[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw")]
save(ukcrimen, file = "pk/data/ukcrimen.Rdata")
save(ukcrimen, file = "cdd/pkdat/ukcrimen.Rdata")

# Kyu Subset
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ukcrimekyu <- ukcrimep[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw", "rootcauset1",
"policet1","punisht1","procrightst1", "selfprotectt1", "rootcauset2","policet2","punisht2",
"procrightst2", "selfprotectt2")]
save(ukcrimekyu, file = "cdd/kyu/bypoll/ukcrimekyu.rdata")

###############################
##   EVALUATION QS       ##
###############################

ukcrime$selection <- as.numeric(ukcrime$part == 1 & !is.na(ukcrime$group))
e0  <- "NA = NA"
e2  <- "1 = 0; 2 = 1; else = NA"
e2r <- "1 = 1; 2 = 0; else = NA"
e3  < -"1 = 0; 2 = .5; 3 = 1; else = NA"
e4  <- "1 = 0; 2 = .33; 3 = .66; 4 = 1; else = NA"
e4r <- "1 = 1; 2 = .66; 3 = .33; 4 = 0; else = NA"
e5  <- "1 = 0; 2 = .25; 3 = .5; 4 = .75; 5 = 1; else = NA"
e10 <- "1 = .1; 2 = .2; 3 = .3; 4 = .4; 5 = .5; 6 = .6; 7 = .7; 8 = .8; 9 = .9; 10 = 1; else = NA"

########################3

#eval1Amount of briefing materials read
#eval2Amount learned about others
#eval3Moderator gave opportunity for opposing arguments
#eval4Moderator facilitated equal participation
#eval5Personal influence of small group moderator
#eval6Value: plenary w/ experts
#eval7Value: plenary w/ politicians
#eval8Value: small groups
#eval9Balance of briefing docs
#eval10Important aspects covered in small group discussions
#eval11Equal participation
#eval12Moderator and consideration of opposing arguments
#eval13Out-group engagement
#eval14Dominance in group participation
#eval15Interesting/Valuable/enjoyable

ukcrime$opinionminority <- NA


ukcrime$eval1 <- ukcrime$readbrief
ukcrime[, paste(eval, 2:14, sep = "")] <- NA
ukcrime$eval15 <- rowMeans(cbind(recode(ukcrime$partint, e4r), recode(ukcrime$partenj, e4)))
ukcrime$meanmodscore <- NA
ukcrime$eval5GtoB <-NA 
ukcrime$eval15D <- NA

ukcrime.eval <- ukcrime[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw","selection", "eval1","eval2","eval3","eval4","eval5","eval6",
"eval7","eval8","eval9","eval10", "eval11","eval12","eval13","eval14","eval15","meanmodscore","length",
"numindices","genvar","vareduc","varfemale","eval5GtoB","eval15D","opinionminority")]
save(ukcrime.eval, file = "dpeval/data/ukcrime.eval.rdata")
