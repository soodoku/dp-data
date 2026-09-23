#
#  UK EU
#  Last Edited: 5.22.14   
#  Gaurav Sood
#

# Notes
# Eliminated 14 respondents at the end with inapplicable code for all their knowledge answers.

# Set Working dir 
setwd(basedir)

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/hlmFunc.R")

## SPSS to R, ALL 
ukeu <- spss("cdd/data/British Europe/uk-eu.sav")
#ukeu <- subset(ukeu1, ukeu1$part==1)
#ukeu <- spss("data/CDD/UK-EU/ukeu.sav") (This has indices)

## Poll
ukeu$numindices <- 4
ukeu$pollid     <- 20
ukeu$country    <- 2
ukeu$mode       <- 0
ukeu$numitems   <- 5
ukeu$length     <- NA
ukeu$timebtw    <- NA

## Group
ukeu$pollgroup <- pgroup(ukeu$group, ukeu$pollid)
ukeu$groupsize <- grpfun(rep(1, nrow(ukeu)), ukeu$group, fun="sum")

#L1 Variables
#t1know t2know female   minority  ppage educ4 hhincome attextreme highinc t1polint  attextreme readbrief

# Knowledge
# ~~~~~~~~~~~~~~~~~~~~~~~~~~
##Missing in pktot2 - so recoding NAs to 0 and then mean
# pk11 EU has recently expanded to 15
# pk21 Switzerland is to join EU
# pk31 Britains income tax rates decided in Brussels
# pk41 Elections to European Parliament every 5 years
# pk51 Liberal Democrats least in favour of EU
# CONSERV1: How united or divided do you feel each of the three major parties are on their policy towards Europe?
#Libdem1
ukeu$t1conpk <- as.numeric(ukeu$conserv1 > 3 & ukeu$conserv1 < 8)
ukeu$t1libpk <- as.numeric(ukeu$libdem1 < 3)

ukeu$pk12 <- nona(ukeu$pk12)
ukeu$pk22 <- nona(ukeu$pk22)
ukeu$pk32 <- nona(ukeu$pk32)
ukeu$pk42 <- nona(ukeu$pk42)
ukeu$pk52 <- nona(ukeu$pk52)

ukeu$t1pk <- with(ukeu, rowMeans(cbind(pk11, pk31, pk41, pk51, t1conpk, t1libpk)))

##Check to see that there is no missing on factual items. Assign missing to 0.
#rowMeans(cbind(ukeu$pk11, ukeu$pk21, ukeu$pk31, ukeu$pk41, ukeu$pk51), na.rm=TRUE)

ukeu$pk11cor <- pkcor(ukeu$pk11,ukeu$pk12)
ukeu$pk21cor <- pkcor(ukeu$pk21,ukeu$pk22)
ukeu$pk31cor <- pkcor(ukeu$pk31,ukeu$pk32)
ukeu$pk41cor <- pkcor(ukeu$pk41,ukeu$pk42)
ukeu$pk51cor <- pkcor(ukeu$pk51,ukeu$pk52)


ukeu$t1know    <- ukeu$pktot1
knowindex      <- with(ukeu, data.frame(pk11cor, pk21cor, pk31cor, pk41cor, pk51cor))
ukeu$t1knowcor <- rowMeans(knowindex)
ukeu$t2know    <- with(ukeu, rowMeans(cbind(pk12, pk22, pk32, pk42, pk52)))

#Group Gain
ukeu$grpgain <- groupgain(knowindex, ukeu$group, nrow(ukeu), ukeu$numitems, ukeu$groupsize)

## Sociodem
ukeu$minority  <- as.numeric(car::recode(ukeu$ethnic, "c(99,97,8,-1)=NA")!=1)
ukeu$female    <- ukeu$sex

temp <- ukeu$educ
for(i in 1:nrow(ukeu)) {
if(!is.na(ukeu$educ[i])) 
{
if(sum(ukeu$educ[i] == c(0,1,2)) > 0) temp [i] <- 0
if(sum(ukeu$educ[i] == c(3,4,5)) > 0) temp[i] <- .33
if(sum(ukeu$educ[i] == c(6,7,8, 9,10, 12)) > 0) temp[i] <- .66
if(sum(ukeu$educ[i] == c(11)) >0 ) temp[i] <- 1.00
if(sum(ukeu$educ[i] ==c(99,13))>0) temp[i] <- NA
}
}
cor(ukeu$t1know, temp, use="na.or.complete")
cor(ukeu$t2know, temp, use="na.or.complete")

ukeu$educ4 <- temp
cor(ukeu$t2know, ukeu$educ4, use="na.or.complete")

ukeu$educollege <- 1*(ukeu$educ4==1)
##Assign missing, DK to NA
ukeu$income   <- NA
ukeu$hhincome <- NA
##Knowledge over the highest quartile is High Knowledge
ukeu$highknow <- (ukeu$t1know > fivenum(ukeu$t1know)[4])
##Quantile(ukeu$t1know)[4]
ukeu$highinc <- NA
ukeu$ppage   <- car::recode(ukeu$age, "c(97,98,99)=NA")

# Polint and Read Brief
ukeu$readbrief <- NA
ukeu$t1polint <- car::recode(ukeu$genint, "c(9,-1,8)=NA; 4=1; 3=.66; 2=.33;1=0")

#Media Consumption Variables:
#READNEWS= Do you normally read newspaper at least 3 times a week? (A5a IAQ)
#WHICHPAP= Which paper do you normally read (A5b IAQ)
  
##UK EU Education -> ageeduc, educ

#if(!is.na(monarchy$b12b[i])){
#if(sum(monarchy$b12b[i] == c(4,5,6)) > 0) temp[i] <- .66
#if(sum(monarchy$b12b[i] == c(7,8,9,10,11)) > 0) temp[i] <- 1.00

# Party ID
ukeu$con <- ukeu$ptyalleg==1
ukeu$lab <- ukeu$ptyalleg==2
ukeu$lib <- ukeu$ptyalleg==3

##L2 Variables
ukeu$pfemale   <- grpfun(ukeu$female, ukeu$group, fun="mean")
ukeu$phighknow <- grpfun(ukeu$highknow, ukeu$group, fun="mean")
ukeu$phigheduc <- grpfun(ukeu$educollege, ukeu$group, fun="mean")
ukeu$pminority <-  grpfun(ukeu$minority, ukeu$group, fun="mean")

ukeu$varfemale      <- (ukeu$pfemale)*(1-ukeu$pfemale)
ukeu$meant1know     <- grpfun(ukeu$t1know, ukeu$group, fun="mean")
ukeu$meant1know_ind <-  (ukeu$meant1know*ukeu$groupsize - ukeu$t1know )/ (ukeu$groupsize - 1)
ukeu$meant2know     <- grpfun(ukeu$t2know, ukeu$group, fun="mean")
ukeu$phighinc       <- NA
ukeu$vareduc        <-  grpfun(ukeu$educ4, ukeu$group, fun="var")


######### Attitude #######
##########################
## EU Scope  (cor = .75)
#ukeu$euscope1r <- (ukeu$euscope1)/5
#ukeu$euscope2r <- (ukeu$euscope2)/5
#TRABLOC1= EU should be more than a trading bloc T1 (Q6b SAQ1)
#TRABLOC2= EU should be more than a trading bloc T2 (Q6b SAQ2)
#NOMORE1= EU should be no more than a trading bloc T1 (Q16 SAQ1)
#NOMORE2= EU should be no more than a trading bloc T2 (Q16 SAQ2)
#PASPORT1= Passport controls in EU should be removed T1 (Q17e SAQ1)
#PASPORT2= Passport controls in EU should be removed T2 (Q17e SAQ2)
e5r <-"5=0;4=.25;3=.5;2=.75;1=0;else=NA"
ukeu$trabloc1r <- zero1(car::recode(ukeu$trabloc1, "c(8,9)=NA"))
ukeu$commies1r <- zero1(car::recode(ukeu$commies1, "c(8,9)=NA"))
#ukeu$nomore1r <-  zero1(recode(re(ukeu$nomore1, "c(8,9)=NA"), e5r))
ukeu$pasport1r <- zero1(car::recode(ukeu$pasport1, "c(8,9)=NA"))

ukeu$trabloc2r <- zero1(car::recode(ukeu$trabloc2, "c(8,9)=NA"))
ukeu$commies2r <- zero1(car::recode(ukeu$commies2, "c(8,9)=NA"))
#ukeu$nomore2r <-  zero1(recode(re(ukeu$nomore1, "c(8,9)=NA"), e5r))
ukeu$pasport2r <- zero1(car::recode(ukeu$pasport2, "c(8,9)=NA"))

cor(cbind(ukeu$trabloc1r, ukeu$pasport1r), use="na.or.complete")
ukeu$euscope1g <- rowMeans(cbind(ukeu$trabloc1r, ukeu$pasport1r), na.rm=T)
ukeu$euscope2g <- rowMeans(cbind(ukeu$trabloc2r, ukeu$pasport2r), na.rm=T)

# Relations with EU (cor = .95)
#ukeu$eurelat1r <- (ukeu$eurelat1)/5
#ukeu$eurelat2r <- (ukeu$eurelat2)/5
#RELEU1= Britains relationship with the European Union T1 (Q1 SAQ1)
#RELEU2= Britains relationship with the European Union T2 (Q1 SAQ2)
#LONGPOL1= Britains long term policy T1 (Q4 SAQ1)
#LONGPOL2= Britains long term policy T2 (Q4 SAQ2)
#UNITE1= Britain should unite fully with EU T1 (Q15 SAQ1)
#UNITE2= Britain should unite fully with EU T2 (Q15 SAQ2)

ukeu$releu1r   <- zero1(car::recode(ukeu$releu1, "c(-1,8,9)=NA"))
ukeu$longpol1r <- zero1(car::recode(ukeu$longpol1, "c(-1,8,9)=NA"))
ukeu$unite1r   <- zero1(car::recode(ukeu$unite1, "c(-1,8,9)=NA"))
ukeu$releu2r   <- zero1(car::recode(ukeu$releu2, "c(-1,8,9)=NA"))
ukeu$longpol2r <- zero1(car::recode(ukeu$longpol2, "c(-1,8,9)=NA"))
ukeu$unite2r   <- zero1(car::recode(ukeu$unite2, "c(-1,8,9)=NA"))

cor(cbind(ukeu$releu1r, ukeu$longpol1r, ukeu$unite1r), use="na.or.complete")
ukeu$eurelat1g <- rowMeans(cbind(ukeu$releu1r, ukeu$longpol1r, ukeu$unite1r), na.rm=T)
ukeu$eurelat2g <- rowMeans(cbind(ukeu$releu2r, ukeu$longpol2r, ukeu$unite2r), na.rm=T)

# Single Variable Index COMMIES1 = EU should include some Eastern European countries T1 (Q14c SAQ1)
#COMMIES1= EU should include some Eastern European countries T1 (Q14c SAQ1)
#COMMIES2= EU should include some Eastern European countries T2 (Q14c SAQ2)
ukeu$commies1r <- zero1(ukeu$commies1)
ukeu$commies2r <- car::recode(ukeu$commies2, "c(-1,8,9)=NA; 1=0; 2=.25; 3=.50; 4=.75; 5=1")

## Favor Referendum - Single Variable (Q10 SAQ1)
ukeu$favref1r <- zero1(ukeu$favref1)
ukeu$favref2r <- car::recode(ukeu$favref2, "c(-1,8,9)=NA; 1=0; 2=.25; 3=.50; 4=.75; 5=1")

ukeu$attextreme <-  with(ukeu, rowMeans(abs(cbind(eurelat1g, euscope1g, commies1r, favref1r) - .5), na.rm=TRUE))

##Generalized Variance Function

ukeu1 <- ukeu[,c("eurelat1g", "euscope1g", "commies1r", "favref1r")]
ukeu$genvar <- unsplit(lapply(split(ukeu1, ukeu$group), genvar),ukeu$group)

##attitude variance - EUrelat1, EUscope1, commies1, favref1
ukeu$vareurelat1 <- grpfun(ukeu$eurelat1g, ukeu$group, fun="var")
ukeu$vareuscope1 <- grpfun(ukeu$euscope1g, ukeu$group, fun="var")
ukeu$varfavref1  <- grpfun(ukeu$favref1r,  ukeu$group, fun="var")
ukeu$varcommies1 <- grpfun(ukeu$commies1r, ukeu$group, fun="var")

ukeu$avgsd <- with(ukeu, rowMeans(sqrt(cbind(varfavref1, vareurelat1, vareuscope1, varcommies1))))

ukeu$t1knowlevel <- mean(ukeu$t1know)

# Midterm Measurement
ukeu[, c("avgsd2", "grpgain2", "t1knowcor2", "t12know", "t12knowcor", "attextreme2")] <- NA

# Save for misinformation
save (ukeu, file="misinformation/data/ukeu.rdata")


# Outputting
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ukeup <- subset(ukeu,ukeu$part==1) 

# Guess Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Taking out responses with 'inapplicable code': 14 of them. 
# People with that code on eusize2 have it for all other questions

ukeupp    <- subset(ukeup, ukeup$eusize2!=-1)
ukeupp$pk11raw <- car::recode(ukeupp$eusize1, "2=0;c(8,9)=NA")
ukeupp$pk21raw <- car::recode(ukeupp$swiss1,  "1=0;2=1;c(8,9)=NA")
ukeupp$pk31raw <- car::recode(ukeupp$inctax1, "1=0;2=1;c(8,9)=NA")
ukeupp$pk41raw <- car::recode(ukeupp$elect1,  "2=0;c(8,9)=NA")
ukeupp$pk51raw <- car::recode(ukeupp$ptyapp1, "1=0;2=1;c(8,9)=NA")

ukeupp$pk12raw <- car::recode(ukeupp$eusize2, "2=0;c(3,9)=NA")
ukeupp$pk22raw <- car::recode(ukeupp$swiss2,  "1=0;2=1;c(3,9)=NA")
ukeupp$pk32raw <- car::recode(ukeupp$inctax2, "1=0;2=1;c(3,9)=NA")
ukeupp$pk42raw <- car::recode(ukeupp$elect2,  "2=0;c(3,9)=NA")
ukeupp$pk52raw <- car::recode(ukeupp$ptyapp2, "1=0;2=1;c(3,9)=NA")

ukeupk <- c("caseid", 
c("pk11", "pk21", "pk31", "pk41", "pk51"),
c("pk12", "pk22", "pk32", "pk42", "pk52"),
paste0(c("pk11", "pk21", "pk31", "pk41", "pk51"), "cor"),
paste0(c("pk11", "pk21", "pk31", "pk41", "pk51"), "raw"),
paste0(c("pk12", "pk22", "pk32", "pk42", "pk52"), "raw"),
"t1know", "t2know", "age", "pollgroup", "educ4","female")

ukeuirt <- ukeupp[, ukeupk]
write.csv(ukeuirt, file="guess/data/ukeuirt.csv")


# PK Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ukeup[,c("t1knowr", "t1knowrcor","t2knowr","grpgainr")]<- NA
ukeun <- ukeup[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw")]

save(ukeun, file="pk/data/ukeun.Rdata", ascii=TRUE)
save(ukeun, file="cdd/pkdat/ukeun.Rdata", ascii=TRUE)

#Kyu Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
indices <- ukeup[, c("eurelat1g", "euscope1g", "commies1r", "favref1r", "eurelat2g", "euscope2g", "commies2r", "favref2r")]
minmax0(indices)
ukeukyu <- ukeup[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw", "eurelat1g", "euscope1g", 
"commies1r", "favref1r", "eurelat2g", "euscope2g", "commies2r", "favref2r")]
save(ukeukyu, file="cdd/kyu/bypoll/ukeukyu.rdata", ascii=TRUE)

###############################
##   EVALUATION QS       ##
###############################

ukeu$selection <- as.numeric(ukeu$part==1)

e0 <-"NA=NA"
e2 <-"1=0;2=1;else=NA"
e2r <- "1=1;2=0;else=NA"
e3 <-"1=0;2=.5;3=1;else=NA"
e4 <-"1=0;2=.33;3=.66;4=1;else=NA"
e4r <-"1=1;2=.66;3=.33;4=0;else=NA"
e5 <-"1=0;2=.25;3=.5;4=.75;5=1;else=NA"
e5r <-"5=0;4=.25;3=.5;2=.75;1=0;else=NA"
e10 <-"1=.1;2=.2;3=.3;4=.4;5=.5;6=.6;7=.7;8=.8;9=.9;10=1;else=NA"

ukeu$opinionminority <- NA
ukeu$length <- NA

ukeu$eval1 <- ukeu$readbrief
ukeu[, paste("eval", 2:14, sep="")] <- NA
ukeu$eval15 <- re(ukeu$dpint2, e4)
ukeu$meanmodscore <- NA
ukeu$eval5GtoB <-NA 
ukeu$eval15D <- NA

ukeu.eval <- ukeu[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw","selection", "eval1","eval2","eval3","eval4","eval5","eval6",
"eval7","eval8","eval9","eval10", "eval11","eval12","eval13","eval14","eval15","meanmodscore","length",
"numindices","genvar","vareduc","varfemale","eval5GtoB","eval15D","opinionminority")]

save(ukeu.eval, file="dpeval/data/ukeu.eval.rdata", ascii=TRUE)