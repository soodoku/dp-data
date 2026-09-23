#
#  EU 2007
#  Last Edited: 05.22.14   
#  Gaurav Sood
#

# Set Working dir
setwd(basedir)

# Sourcing Common Functions
library(goji)
library(car)

#source("func/func.R")

## SPSS to R, Participants Only
eu <- foreign::read.spss("cdd/data/EU 2007/eu.sav", use.value.labels = FALSE)
eu <- as.data.frame(eu)
names(eu) <- tolower(names(eu))

## POLL Vars
eu$numindices <- 7
eu$pollid     <- 28
eu$country    <- 0
eu$mode       <- 0
eu$numitems   <- 11
eu$caseid     <- eu$v_b
eu$length     <- 2
eu$timebtw    <- NA

## Group
eu$pollgroup <- pgroup(eu$group, eu$pollid)
eu$groupsize <- grpfun(rep(1, nrow(eu)), eu$pollgroup, fun = "sum")

# Participant Filer
eu$filter    <- !is.na(eu$pollgroup)

#L1 Variables
#t1know t2know female   minority  ppage educ4 hhincome attextreme highinc t1polint  attextreme readbrief sex, age, 

#
# Knowledge Questions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#t1q16cor, t1q17cor, t1q18cor, t1q19cor, t1q20cor, t1q21cor,  t1q22cor,  t1q23cor,  t1q24cor, t1q33a_r, t1q33b_r
#t2q19cor,  t2q20cor , t2q21cor,  t2q22cor , t2q23cor , t2q24cor  , t2q25cor ,  t2q26cor ,  t2q27cor, t2q36ar_r, t2q36br_r
#t3q19cor,  t3q20cor , t3q21cor,  t3q22cor , t3q23cor , t3q24cor  , t3q25cor ,  t3q26cor ,  t3q27cor, t3q36ar_r, t3q36br_r

# Raw with DK/Refused = NA
# ***************************
eu$t1q16  <- recode(eu$q16_1,"c(5,6) = NA")
eu$t1q17  <- recode(eu$q17_1,"c(5,6) = NA")  ## 5,6
eu$t1q18  <- recode(eu$q18_1,"c(5,6) = NA")  ## 5,6
eu$t1q19  <- recode(eu$q19_1,"c(5,6) = NA")  ## 5,6
eu$t1q20  <- recode(eu$q20_1,"c(5,6) = NA")
eu$t1q21  <- recode(eu$q21_1,"c(6,7) = NA")  ## position of correct changed.
eu$t1q22  <- recode(eu$q22_1,"c(6,7) = NA")  ## position of correct changed.
eu$t1q23  <- recode(eu$q23_1,"c(6,7) = NA")
eu$t1q24  <- recode(eu$q24_1,"c(5,6) = NA")  
eu$t1q33a <- zero1(recode(eu$q33a_1,"c(12,13) = NA"))
eu$t1q33b <- zero1(recode(eu$q33b_1,"c(12,13) = NA"))

# 3 Subsets (Raw with DK/REF as NA)
t1raw <- c(paste0("t1q",16:24), "t1q33a", "t1q33b")
t2raw <- c(paste0("t2q",19:27), "t2q36a", "t2q36b")
t3raw <- c(paste0("t3q",19:27), "t3q36a", "t3q36b")

# apply(eu[,t1raw], 2,table)

# Change 99 and 1004 to NA for t2raw and t3raw
eu[,t2raw] <- sapply(eu[,t2raw], function(x) recode(x , "c(24, 44, 99, 1004) = NA"))
eu[,t3raw] <- sapply(eu[,t3raw], function(x) recode(x , "c(24, 44, 99, 1004) = NA"))

# Rescale placement qs 0 to 1
eu$t2q36a <- zero1(eu$t2q36a)
eu$t2q36b <- zero1(eu$t2q36b)

eu$t3q36a <- zero1(eu$t3q36a)
eu$t3q36b <- zero1(eu$t3q36b)

# Correct with NA in there
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
eu$t1q16r  <- ifelse(eu$t1q16 == 3, 1, 0)
eu$t1q17r  <- ifelse(eu$t1q17 == 1, 1, 0)
eu$t1q18r  <- ifelse(eu$t1q18 == 2, 1, 0)
eu$t1q19r  <- ifelse(eu$t1q19 == 4, 1, 0) 
eu$t1q20r  <- ifelse(eu$t1q20 == 1, 1, 0)
eu$t1q21r  <- ifelse(eu$t1q21 == 4, 1, 0) 
eu$t1q22r  <- ifelse(eu$t1q22 == 2, 1, 0) 
eu$t1q23r  <- ifelse(eu$t1q23 == 1, 1, 0)
eu$t1q24r  <- ifelse(eu$t1q24 == 4, 1, 0)
eu$t1q33ar <- ifelse(eu$t1q33a > .5, 1, 0)
eu$t1q33br <- ifelse(eu$t1q33b < .5, 1, 0)

eu$t2q19r  <- ifelse(eu$t2q19 == 3, 1, 0)
eu$t2q20r  <- ifelse(eu$t2q20 == 1, 1, 0)
eu$t2q21r  <- ifelse(eu$t2q21 == 2, 1, 0)
eu$t2q22r  <- ifelse(eu$t2q22 == 4, 1, 0) 
eu$t2q23r  <- ifelse(eu$t2q23 == 1, 1, 0)
eu$t2q24r  <- ifelse(eu$t2q24 == 4, 1, 0) 
eu$t2q25r  <- ifelse(eu$t2q25 == 2, 1, 0) 
eu$t2q26r  <- ifelse(eu$t2q26 == 1, 1, 0)
eu$t2q27r  <- ifelse(eu$t2q27 == 4, 1, 0)
eu$t2q36ar <- ifelse(eu$t2q36a > .5, 1, 0)
eu$t2q36br <- ifelse(eu$t2q36b < .5, 1, 0)

eu$t3q19r  <- ifelse(eu$t3q19 == 3, 1, 0)
eu$t3q20r  <- ifelse(eu$t3q20 == 1, 1, 0)
eu$t3q21r  <- ifelse(eu$t3q21 == 2, 1, 0)
eu$t3q22r  <- ifelse(eu$t3q22 == 4, 1, 0) 
eu$t3q23r  <- ifelse(eu$t3q23 == 1, 1, 0)
eu$t3q24r  <- ifelse(eu$t3q24 == 4, 1, 0) 
eu$t3q25r  <- ifelse(eu$t3q25 == 2, 1, 0) 
eu$t3q26r  <- ifelse(eu$t3q26 == 1, 1, 0)
eu$t3q27r  <- ifelse(eu$t3q27 == 4, 1, 0)
eu$t3q36ar <- ifelse(eu$t3q36a > .5, 1, 0)
eu$t3q36br <- ifelse(eu$t3q36b < .5, 1, 0)

# Cor with DK/REF as NA
t1redk <- paste0(c(paste0("t1q",16:24), "t1q33a", "t1q33b"), "r")
t2redk <- paste0(c(paste0("t2q",19:27), "t2q36a", "t2q36b"), "r")
t3redk <- paste0(c(paste0("t3q",19:27), "t3q36a", "t3q36b"), "r")

# Correct with no NA
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
eu[, paste0(t1redk, "r")] <- sapply(eu[,t1redk], function(x) nona(x))
eu[, paste0(t2redk, "r")] <- sapply(eu[,t2redk], function(x) nona(x))
eu[, paste0(t3redk, "r")] <- sapply(eu[,t3redk], function(x) nona(x))

# Calculate reliability
pksubs <- eu[,paste0(t3redk, "r")]
ltm::cronbach.alpha(pksubs, standardized = FALSE, CI = FALSE, probs = c(0.025, 0.975), B = 1000, na.rm = TRUE)

# T1 scores with 1 and T1 and 0 at T2/T3/T2 and T3 scored as 0; T2 scores adjusted for T3
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
eu[,paste0(t1redk, "cor2")]   <- eu[,paste0(t1redk, "r")]*eu[,paste0(t2redk, "r")]
eu[,paste0(t1redk, "cor3")]   <- eu[,paste0(t1redk, "r")]*eu[,paste0(t3redk, "r")]
eu[,paste0(t1redk, "cor23")]  <- eu[,paste0(t1redk, "r")]*eu[,paste0(t2redk, "r")]*eu[,paste0(t3redk, "r")]
eu[,paste0(t2redk, "cor")]    <- eu[,paste0(t2redk, "r")]*eu[,paste0(t3redk, "r")]

# Collection of PK vars
eu$t1know     <- rowMeans(eu[, paste0(t1redk, "r")])
eu$t12know    <- rowMeans(eu[, paste0(t2redk, "r")])
eu$t2know     <- rowMeans(eu[, paste0(t3redk, "r")])
eu$t1knowcor  <- rowMeans(eu[, paste0(t1redk, "cor3")])
eu$t12knowcor <- rowMeans(eu[, paste0(t2redk, "cor")])
eu$t1knowcor2 <- rowMeans(eu[, paste0(t1redk, "cor23")])

## Knowledge over the highest quartile is High Knowledge
eu$highknow <- as.numeric((eu$t1know > fivenum(eu$t1know)[4]))

# Group Gain
eu$grpgain  <- groupgain(eu[, paste0(t1redk, "r")],  eu$pollgroup, nrow(eu), eu$numitems, eu$groupsize)
eu$grpgain2 <- groupgain(eu[, paste0(t2redk, "cor")],  eu$pollgroup, nrow(eu), eu$numitems, eu$groupsize)

## Sociodem
## ~~~~~~~~~~~~~~~~~~~~~~~~
eu$female  <- eu$q35r
eu$educollege <- recode(eu$q39, "7 = NA; c(4, 5, 6) = 1; c(1, 2, 3) = 0")
eu$educ4 <- recode(eu$q39r, "5 = NA; c(4, 5, 6) = 1; 3 = .66; 2 = .33; 1 = 0")
eu$minority <- NA
eu$income <- NA
eu$hhincome <- NA 
eu$highinc <- NA #70k or above
# q38 - age; Age - eu$q36: #18-24 (1) #25-29 - 2 #40-54 - 3 #55-69- 4 #70+ - 5 #6=DK
agetemp   <- recode(eu$q36, "1 = 21; 2 = 27; 3 = 47; 4 = 62; 5 = 73")
eu$ppage  <- agetemp

eu$t1polint <- NA
eu$readbrief <- recode(eu$t3q42,"5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")

## L2 Variable
eu$pminority  <- NA
eu$pfemale  <- grpfun(eu$female, eu$pollgroup, fun = "mean")
eu$varfemale  <- eu$pfemale*(1 - eu$pfemale)
eu$meant1know  <- grpfun(eu$t1know, eu$pollgroup, fun = "mean")
eu$meant1know_ind <- (eu$meant1know*eu$groupsize - eu$t1know )/ (eu$groupsize - 1)
eu$meant2know   <- grpfun(eu$t2know, eu$pollgroup, fun = "mean")
eu$phighknow  <- grpfun(eu$highknow, eu$pollgroup, fun = "mean")
eu$phigheduc  <- grpfun(eu$educollege, eu$pollgroup, fun = "mean")
eu$vareduc  <- grpfun(eu$educ4, eu$pollgroup, fun="var")
eu$phighinc  <- NA

######Attitudes at t1
#eu$support_eu_membership_t1 ; eu$att_towards_privatization_t1 ; eu$attitude_towards_migration_t1; eu$mil_att_11_12_t1_f ; 
# eu$t1q11b; eu$turkey_enlargement_att_t1 ; eu$eu_veto_support_t1

## Atttidudes at Arrival
# eu$support_eu_membership_t2 ; eu$att_towards_privatization_t2 ; eu$attitude_towards_migration_t2; eu$mil_att_11_12_t2_f ; 
# eu$t2q11br ; #eu$turkey_enlargement_att_t2 ; eu$eu_veto_support_t2

eu1 <- eu[,c("support_eu_membership_t1", "att_towards_privatization_t1", "attitude_towards_migration_t1", 
"mil_att_11_12_t1", "t1q11b", "turkey_enlargement_att_t1", "eu_veto_support_t1")]
eu2 <- eu[,c("support_eu_membership_t2","att_towards_privatization_t2","attitude_towards_migration_t2",
"mil_att_11_12_t2", "t2q11br","turkey_enlargement_att_t2","eu_veto_support_t2")]

eu$genvar<- unsplit(lapply(split(eu1, eu$pollgroup), genvar),eu$pollgroup)
eu$genvar2<- unsplit(lapply(split(eu2, eu$pollgroup), genvar),eu$pollgroup)

##Attitude extremity
eu$attextreme<- rowMeans(abs(eu1 - .5), na.rm = T)
eu$attextreme2<- rowMeans(abs(eu2 - .5), na.rm = T)

## Attitude Variance
#####################

fromlist    <- c(names(eu1), names(eu2))
tolist      <- paste("var", fromlist, sep="")
eu[,tolist] <- sapply(eu[,fromlist], function(x) grpfun(x, eu$pollgroup, fun = "var"))

eu$avgsd <- rowMeans(sqrt(eu[, tolist[1:7]]))
eu$avgsd2 <- rowMeans(sqrt(eu[, tolist[8:14]]))

eu$t1knowlevel <- mean(eu$t1know)

## Participants
eup <- subset(eu, !is.na(eu$pollgroup))

# Guess Subset
  eupk <- c("caseid", t1raw, t2raw, t3raw, t1redk, t2redk, t3redk, paste0(t1redk, "r"), paste0(t2redk, "r"), paste0(t3redk, "r"), 
paste0(t1redk, "cor2"), paste0(t1redk, "cor3"), paste0(t1redk, "cor23"), paste0(t2redk, "cor"), 
"t1know", "t12know", "t2know", "age", "filter", "pollgroup", "ppage", "educ4","female")
euirt <- eup[, eupk]

# Participant Subset
#euirt <- subset(euirt,filter  == 1)

write.csv(euirt, file = "guess/data/bypoll/euirt.csv")

# PK subset
# ~~~~~~~~~~~~~~~~~~~~~~
eun <- eup[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw")]

save(eun, file = "pk/data/eun.Rdata")
save(eun, file = "cdd/pkdat/eun.Rdata")

# Kyu Data ##
# ~~~~~~~~~~~~~~~~~~~~~~`
eu2kyu <- eup[,c("support_eu_membership_t2","att_towards_privatization_t2","attitude_towards_migration_t2","mil_att_11_12_t2", 
"t2q11br","turkey_enlargement_att_t2","eu_veto_support_t2", "pay_for_pension_1_t2_r","free_trade_index_t2",
"general_enlargement_att_f_t2","eu_level_decision_making_t2","t2q16jr")]
eu3kyu <- eup[,c("support_eu_membership_t3","att_towards_privatization_t3","attitude_towards_migration_t3","mil_att_11_12_t3", 
"t3q11br","turkey_enlargement_att_t3","eu_veto_support_t3", "pay_for_pension_1_t3_r","free_trade_index_t3",
"general_enlargement_att_f_t3","eu_level_decision_making_t3","t3q16jr")]

eukyu <- eup[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw", "support_eu_membership_t1", "att_towards_privatization_t1", 
"attitude_towards_migration_t1", "mil_att_11_12_t1", "t1q11b", "turkey_enlargement_att_t1", "eu_veto_support_t1", 
"support_eu_membership_t2","att_towards_privatization_t2","attitude_towards_migration_t2","mil_att_11_12_t2",
"t2q11br","turkey_enlargement_att_t2","eu_veto_support_t2", "pay_for_pension_1_t2_r","free_trade_index_t2",
"general_enlargement_att_f_t2","eu_level_decision_making_t2","t2q16jr","support_eu_membership_t3",
"att_towards_privatization_t3","attitude_towards_migration_t3","mil_att_11_12_t3", 
"t3q11br","turkey_enlargement_att_t3","eu_veto_support_t3", "pay_for_pension_1_t3_r","free_trade_index_t3",
"general_enlargement_att_f_t3","eu_level_decision_making_t3","t3q16jr")]

save(eukyu, file="cdd/kyu/eukyu.rdata", ascii=TRUE)

###########################
### Evaluation Questions
############################
eu$selection <- as.numeric(!is.na(eu$pollgroup))
#Age
#ExtrmeL (left extremity)
#ExtrmeR (right extremity)
#PextrmeL
#PextrmeR
#Extmremist
#Pextremist

e0 <-"NA = NA"
e2 <-"1=0;2=1;else = NA"
e2r <- "1=1;2=0;else = NA"
e3 <-"1=0;2=.5;3=1;else = NA"
e4 <-"1=0;2=.33;3=.66;4=1;else = NA"
e4r <-"1=1;2=.66;3=.33;4=0;else = NA"
e5 <-"1=0;2=.25;3=.5;4=.75;5=1;else = NA"
e5r <-"1=1;2=.75;3=.5;4=.25;5=0;else = NA"
e10 <-"1=.1;2=.2;3=.3;4=.4;5=.5;6=.6;7=.7;8=.8;9=.9;10=1;else = NA"


########################
eu$opinionminority <- NA

eu$eval1 <- recode(eu$t3q43, e5)
eu$eval2 <- recode(eu$t3q41f, e5r)
eu$eval3 <- recode(eu$t3q41a, e5r)
eu$eval4 <- NA
eu$eval5 <- recode(eu$t3q41c, e5r)
eu$eval6 <- recode(eu$t3q40c, e10)
eu$eval7 <- recode(eu$t3q40d, e10)
eu$eval8 <- recode(eu$t3q40a, e10)
eu$eval9 <- recode(eu$t3q44, e2r)
eu$eval10 <- recode(eu$t3q41e, e5r)
eu$eval11 <- recode(eu$t3q41b, e5r)
eu$eval12 <- recode(eu$t3q41d, e5r)
eu$eval13 <- recode(eu$t3q40b, e10)
eu$eval14 <- NA
eu$eval15 <- recode(eu$t3q40e, e10)
eu$meanmodscore <- NA
eu$eval5GtoB <-recode(eu$t3q41c, e5)
eu$eval15D <- NA

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


eu.eval <- eu[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw","selection", "eval1","eval2","eval3","eval4","eval5","eval6",
"eval7","eval8","eval9","eval10", "eval11","eval12","eval13","eval14","eval15","meanmodscore","length",
"numindices","genvar","vareduc","varfemale","eval5GtoB","eval15D","opinionminority")]

save(eu.eval, file="dpeval/data/eu.eval.rdata", ascii=TRUE)