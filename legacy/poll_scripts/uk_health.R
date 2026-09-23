#
#  British Health
#  Last Edited: 4.05.14
#  Gaurav Sood##
#

# Set Working dir 
setwd(basedir)

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/hlmFunc.R") 

## SPSS to R, Participants Only
#ukhealth <- foreign::read.spss("cdd/data/British Health/health3.sav", to.data.frame=TRUE)
#names(ukhealth) <- tolower(names(ukhealth))

# Data with the indices
ukhealth <- foreign::read.spss("cdd/data/British Health/britishhealth.sav", to.data.frame=TRUE)
names(ukhealth) <- tolower(names(ukhealth))

# Poll
ukhealth$numindices <- 11
ukhealth$pollid     <- 22
ukhealth$country    <- 2
ukhealth$mode       <- 0
ukhealth$numitems   <- 6
ukhealth$caseid     <- ukhealth$serial_a
ukhealth$length     <- NA
ukhealth$timebtw    <- NA

# Group
ukhealth$pollgroup <- pgroup(ukhealth$group, ukhealth$pollid)
ukhealth$groupsize <- grpfun(rep(1, nrow(ukhealth)), ukhealth$pollgroup, fun="sum")

#L1 Variables : t1know t2know female   minority  ppage educ4 hhincome attextreme highinc t1polint  attextreme readbrief


# Knowledge: sopha1, sophb1, sophc1, sophd1, sophe1, sophf1 ##
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~```````

fromlist <- c("answera2", "answerb2", "answerc2", "answerd2", "answere2", "answerf2")
tolist   <- paste(fromlist, "cor", sep="")
ukhealth[,tolist] <- sapply(ukhealth[,fromlist], function(x) nona(x=='correct'))

fromlist <- c("answera1", "answerb1", "answerc1", "answerd1", "answere1", "answerf1")
tolist   <- paste(fromlist, "r", sep="")
ukhealth[,tolist] <- sapply(ukhealth[,fromlist], function(x) nona(x=='correct'))

# Corrected Facts; 10 to 00
ukhealth$answera1cor <- with(ukhealth, answera1r*answera2cor)
ukhealth$answerb1cor <- with(ukhealth, answerb1r*answerb2cor)
ukhealth$answerc1cor <- with(ukhealth, answerc1r*answerc2cor)
ukhealth$answerd1cor <- with(ukhealth, answerd1r*answerd2cor)
ukhealth$answere1cor <- with(ukhealth, answere1r*answere2cor)
ukhealth$answerf1cor <- with(ukhealth, answerf1r*answerf2cor)

knowindex           <- with(ukhealth, data.frame(answera1cor, answerb1cor, answerc1cor, answerd1cor, answere1cor, answerf1cor))

# Calculate reliability
pksubs <- with(ukhealth, data.frame(answera2cor, answerb2cor, answerc2cor, answerd2cor, answere2cor, answerf2cor))
ltm::cronbach.alpha(pksubs, standardized = FALSE, CI = FALSE, probs = c(0.025, 0.975), B = 1000, na.rm = TRUE)


ukhealth$t1knowcor<- rowMeans(knowindex)
ukhealth$t1know<- with(ukhealth, rowMeans(cbind(answera1r, answerb1r, answerc1r, answerd1r, answere1r, answerf1r)))
ukhealth$t2know<- with(ukhealth, rowMeans(cbind(answera2cor, answerb2cor, answerc2cor, answerd2cor, answere2cor, answerf2cor)))

#Group Gain
ukhealth$grpgain    <- groupgain(knowindex, ukhealth$pollgroup, nrow(ukhealth), ukhealth$numitems, ukhealth$groupsize)


## Sociodem
## ~~~~~~~~~~~~~~~~~~
ukhealth$female   <- 1*(ukhealth$gender=='female')
ukhealth$minority <- 1*(ukhealth$ethnic !='white')
ukhealth$ppage    <- ukhealth$age

#Education educa educb 
ukhealth$educar <- recode(as.integer(ukhealth$educa), "c(1,2)=NA")
ukhealth$educbr <- recode(as.integer(ukhealth$educb), "c(1,2)=NA")

# Education
temp <- rep(NA, nrow(ukhealth))
# No Qualification or GCSE grades D-G, NVQ 1
temp[as.integer(ukhealth$educa) %in% c(3,4) | as.integer(ukhealth$educb)%in% c(3,4,5)]  <- 0
# A or SVQ 3 level
temp[as.integer(ukhealth$educa) %in% c(6,7) | as.integer(ukhealth$educb) %in% c(6,7,8)]  <- .33#HS
# Nursing Certification etc.
temp[as.integer(ukhealth$educb) %in% c(9,10,11)]   <- .66
temp[as.integer(ukhealth$educb)==12] <- 1#Degree 

temp <- rep(NA, nrow(ukhealth))
for(i in 1:nrow(ukhealth)) {
if(!is.na(ukhealth$educa[i])) 
{
if(ukhealth$educa[i] %in% c(1,2,3)) temp [i] <- 0
if(ukhealth$educa[i] == 4) temp[i] <- .33
}
if(!is.na(ukhealth$educb[i])){
if(ukhealth$educb[i] %in% c(0,1,2,3)) temp[i] <- 0
if(ukhealth$educb[i] %in% c(4))   temp[i] <- .33
if(ukhealth$educb[i] %in% c(5, 6, 7, 8, 10, 11)) temp[i] <- .66
if(ukhealth$educb[i] %in% c(9)) temp[i] <- 1.00
 }
}

temp <- recode(ukhealth$educar, "3=.00; 4=.33; c(5,7)=.66; 6=1")

cor(ukhealth$t1know,temp, use="na.or.complete")
cor(ukhealth$t2know,temp, use="na.or.complete")
  
#ukhealth$educ4 <- re(ukhealth$educb,"c(-9,-1,11,12) = NA; 0=0; c(1,2,3)=.33; c(4,5)=.66; c(6,7,8)=3; c(9,10)=1")
ukhealth$educ4 <- temp
cor(ukhealth$t1know,ukhealth$educ4, use="na.or.complete")

#Media Consumption Variables:
#newsyn= Read daily morning paper at least 3 times a week? (A5A)
#newsp = Which newspaper? (A5B)

ukhealth$educollege <- recode(as.integer(ukhealth$educb), "12=1; NA=NA; else=0")
ukhealth$t1polint <- NA
ukhealth$readbrief <- NA
ukhealth$hhincome <- zero1(recode(as.integer(ukhealth$income), "c(1,2,3,4)=NA"))
ukhealth$highinc <- as.numeric(ukhealth$hhincome > .8)
ukhealth$highknow <- (ukhealth$hknow1 > fivenum(ukhealth$hknow1)[4])

#L2 Variables
#pollgroup groupsize pfemale phighknow phighinc pminority phigheduc meant1know meant2know sqrtavgvar genvar

fromlist <- c("minority", "female", "highknow", "highinc")
tolist   <- paste("p", fromlist, sep="")
ukhealth[,tolist] <- sapply(ukhealth[,fromlist], function(x) grpfun(x, ukhealth$pollgroup, fun="mean"))

ukhealth$varfemale<- (ukhealth$pfemale)*(1 - ukhealth$pfemale)
ukhealth$meant1know     <- grpfun(ukhealth$hknow1, ukhealth$group, fun="mean")
ukhealth$meant1know_ind <- with(ukhealth, (meant1know*groupsize - t1know )/(groupsize - 1))
ukhealth$meant2know<- grpfun(ukhealth$hknow2, ukhealth$group, fun="mean")
ukhealth$phigheduc<- grpfun(ukhealth$educollege, ukhealth$group, fun="mean")
ukhealth$vareduc<- grpfun(ukhealth$educ4, ukhealth$group, fun="var")


##Attitudes    ##
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

e3r <-"1=1;2=.5;3=0;else=NA"

# Single Item. Healthcare Payer (0=govt pays, 1= indiv). payhlth1= R's views on paying for health care T1 (Q5). 
ukhealth$t1payhlt <- recode(as.integer(ukhealth$payhlth1), "c(1,2,3)=NA; 4=0; 5=.5; 6=1")
ukhealth$t2payhlt <- recode(as.integer(ukhealth$payhlth2), "c(1,2,3)=NA; 4=0; 5=.5; 6=1")

# Single Item. Priority to Poor. Single Item, poorA1 = Treating the poor T1 (Q17A)
ukhealth$t1poora <- recode(as.integer(ukhealth$poora1), "c(1,2,3)=NA;4=0;5=.25;6=.50;7=.75;8=1")
ukhealth$t2poora <- recode(as.integer(ukhealth$poora2), "c(1,2,3)=NA;4=0;5=.25;6=.50;7=.75;8=1")

# Single Item. Options (1=spend more, 0= spend less). options1= Government options T1 (Q2)
ukhealth$t1option <- recode(as.integer(ukhealth$options1), "c(1,2,3)=NA;6=1;5=.5;4=0")
ukhealth$t2option <- recode(as.integer(ukhealth$options2), "c(1,2,3)=NA;6=1;5=.5;4=0")

#Healthcare Funding Optionst1hlthfu t2hlthfu 
# t1chvis; original: chvis1, chvis2 = Charges for your GP visiting you at home T1 (Q22_B) 
# t1chgp;  original: chgp1, chgp2 
# recode(as.integer(ukhealth$chgp1), "c(1,2,3)=NA;4=0;5=.25;6=.5;7=.75;8=1")
# t1chmeal; original: chmeal1, chmeal2  = Charges for hospital meals T1 (Q22_C) 
# t1chstay; original: chstay1, chstay2  = Charges for accomodation in hospital T1 (Q22_D)
# t1chamb;  original: chamb1, chamb2   = Charges for non-emergency ambulance T1 (Q22_E)

with(ukhealth, cor(cbind(t1chgp, t1chvis, t1chmeal, t1chstay, t1chamb), use="na.or.complete"))

ukhealth$t1hlthfu <- with(ukhealth, rowMeans(cbind(t1chgp, t1chvis, t1chmeal, t1chstay, t1chamb), na.rm=T))
ukhealth$t2hlthfu <- with(ukhealth, rowMeans(cbind(t2chgp, t2chvis, t2chmeal, t2chstay, t2chamb), na.rm=T))

#Cutting Expensive Treatmentst1ctexpt t2ctexpt (cor = .96) Not Exact
ukhealth$t1ctexpt <- with(ukhealth, rowMeans(cbind(t1treata, t1cthart, t1ctnurs, t1ctbaby), na.rm=T))
ukhealth$t2ctexpt <- with(ukhealth, rowMeans(cbind(t2treata, t2cthart, t2ctnurs, t2ctbaby), na.rm=T))

#Privatizing Some Treatmentst1pritre t2pritre 
#ctfert1= Cut down on fertility treatment T1 (Q21_A), (W21_A)
#cthosp1  = Cut down on hospice care for terminal T1 (Q21_B), (W21_B)
#ctcosm1  = Cut down on cosmetic surgery T1 (Q21_C), (W21_C)

ukhealth$t1pritre <- with(ukhealth, rowMeans(cbind(t1ctfert, t1cthosp, t1ctcosm), na.rm=T))
ukhealth$t2pritre <- with(ukhealth, rowMeans(cbind(t2ctfert, t2cthosp, t2ctcosm), na.rm=T)) 

#waiting listt1wl t2wl 
#PRSMOKB1, AGEA1, (CANNOT
#rowMeans(cbind(zero1(re(ukhealth$prsmoka1, "c(-1,-8,-9)=NA")), zero1(re(ukhealth$agea1, "c(-1,-8,-9)=NA"))), na.rm=T)
#
#rowMeans(cbind(recode(re(ukhealth$prsmoka1, "c(-1,-8,-9)=NA"), "1=0; 2=.5; 3=1"), recode(re(ukhealth$agea1, 
#"c(-1,-8,-9)=NA"), "1=0; 2=.5; 3=1")), na.rm=T)

#Priority Based On Severitysevera1, severa2,recoded: t1severa t2severa (doesn't match but doesn't make sense otherwise)
#priority to preventionpreva1, preva2,     recoded: t1preven t2preven 
#quality of life would benefit most from treatmentlifea1, lifea2, recoded:t1qoflif t2qoflif 

#DISCRETION: PUBLIC & GOV’Tt1dispub t2dispub recode(re(ukhealth$inpuba1, "c(-1,-8,-9)=NA"), e3r),
ukhealth$t1ingova  <- recode(as.integer(ukhealth$ingova1), "c(1,2,3)=0;4=1;5=.5;6=0")
#ukhealth$t1inhma  <- recode(as.integer(ukhealth$inhma1),  "c(1,2,3)=0;4=1;5=.5;6=0")
ukhealth$t1inpuba  <- recode(as.integer(ukhealth$inpuba1),  "c(1,2,3)=0;4=1;5=.5;6=0")

#ukhealth$t1dispub <- with(ukhealth, rowMeans(cbind(t1ingova, t1inpuba), na.rm=T))
ukhealth$t2dispub  <- with(ukhealth, rowMeans(cbind(t2ingova, t2inpuba), na.rm=T))

#Doctors Discretiont1avgdis t2avgdis (doesn't match exact, cor = .8)
#Patients have more saysay1, say2, recoded:t1moresat2moresa


## Attitude Extremity 
##
t1att     <- c("t1payhlt", "t1poora", "t1option", "t1hlthfu", "t1ctexpt", "t1pritre", "t1severi", "t1preven", 
   "t1dispub", "t1avgdis", "t1moresa")

ukhealth$attextreme <- rowMeans(abs(ukhealth[,t1att] - .5), na.rm=T)

## Generalized Variance 
##

ukhealth$genvar <- unsplit(lapply(split(ukhealth[,t1att], ukhealth$group), genvar),ukhealth$group)

# Var. in Attitudes##
#*************************
tolist   <- paste("var", t1att, sep="")
ukhealth[,tolist] <- sapply(ukhealth[,t1att], function(x) grpfun(x, ukhealth$pollgroup, fun="var"))
ukhealth$avgsd <- rowMeans(sqrt(ukhealth[,tolist]))

#L3 Variables
#pollid country mode t1knowlevel numitems
ukhealth$t1knowlevel <- mean(ukhealth$hknow1)

# Midterm Measurement
ukhealth[, c("avgsd2", "grpgain2", "t1knowcor2", "t12know", "t12knowcor", "attextreme2")] <- NA

# Participants Only
ukhealthp <- subset(ukhealth, ukhealth$group > 0)


# Guess Subset
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ukhpk <- c("caseid", paste0("answer", letters[1:6], 1),
 paste0("answer", letters[1:6], "1r"),
 paste0("answer", letters[1:6], "1cor"),
 paste0("soph", letters[1:6], "1"), 
 paste0("soph", letters[1:6], "2"),
 paste0("answer", letters[1:6], "2"),
 paste0("answer", letters[1:6], "2cor"),
  "t1know", "t2know", "age", "pollgroup", "educ4","female")
ukhirt <- ukhealth[, ukhpk]
save(ukhirt, file="guess/data/ukhirt.rdata")


# Save data
healthybrits <- ukhealthp[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw")]
save(healthybrits, file="pk/data/healthybrits.Rdata")
save(healthybrits, file="cdd/pkdat/healthybrits.Rdata")

#load("pk/data/hlm_files/healthybrits.Rdata")
## Kyu Data ## 
indices <- ukhealthp[, c("t1payhlt", "t1poora", "t1option", "t1hlthfu", "t1ctexpt", "t1pritre", 
"t1severi", "t1preven", "t1dispub", "t1avgdis", "t1moresa", "t2payhlt", "t2poora", "t2option", 
"t2hlthfu", "t2ctexpt", "t2pritre", "t2severi", "t2preven", "t2dispub", "t2avgdis", "t2moresa")]
minmax0(indices)
ukhealthkyu <- ukhealthp[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw", "t1payhlt", "t1poora", "t1option", "t1hlthfu", "t1ctexpt", 
"t1pritre", "t1severi", "t1preven", "t1dispub", "t1avgdis", "t1moresa", "t2payhlt", "t2poora", "t2option", 
"t2hlthfu", "t2ctexpt", "t2pritre", "t2severi", "t2preven", "t2dispub", "t2avgdis", "t2moresa")]
save(ukhealthkyu, file="cdd/kyu/ukhealthkyu.rdata")

###############################
##   EVALUATION QS       ##
###############################

ukhealth$selection <- as.numeric(ukhealth$group > 0)
e0 <-"NA=NA"
e2 <-"1=0;2=1;else=NA"
e2r <- "1=1;2=0;else=NA"
e3 <-"1=0;2=.5;3=1;else=NA"
e4 <-"1=0;2=.33;3=.66;4=1;else=NA"
e5 <-"1=0;2=.25;3=.5;4=.75;5=1;else=NA"
e5r <-"1=1;2=.75;3=.5;4=.25;5=0;else=NA"
e10 <-"1=.1;2=.2;3=.3;4=.4;5=.5;6=.6;7=.7;8=.8;9=.9;10=1;else=NA"

##################
ukhealth$opinionminority <- NA

ukhealth$eval1 <- ukhealth$readbrief
ukhealth$eval2 <- NA
ukhealth$eval3 <- re(ukhealth$modpart, e5)
ukhealth$eval4 <- NA
ukhealth$eval5 <- re(ukhealth$modinfl, e5)
ukhealth$eval6 <- re(ukhealth$experts, e3)
ukhealth$eval7 <- re(ukhealth$pols, e3)
ukhealth$eval8 <- re(ukhealth$grpdisc,e3)
ukhealth$eval9 <- re(ukhealth$biasmat, e2r)
ukhealth$eval10 <- NA
ukhealth$eval11 <- NA
ukhealth$eval12 <- NA
ukhealth$eval13 <- re(ukhealth$talking, e3)
ukhealth$eval14 <- NA
ukhealth$eval15 <- re(ukhealth$dopint, e4)
ukhealth$meanmodscore <- NA
ukhealth$eval5GtoB <- re(ukhealth$modinfl, e5r)
ukhealth$eval15D <- NA

#######################

ukhealth.eval <- ukhealth[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw","selection", "eval1","eval2","eval3","eval4","eval5","eval6",
"eval7","eval8","eval9","eval10", "eval11","eval12","eval13","eval14","eval15","meanmodscore","length",
"numindices","genvar","vareduc","varfemale","eval5GtoB","eval15D","opinionminority")]

save(ukhealth.eval, file="dpeval/data/ukhealth.eval.rdata")