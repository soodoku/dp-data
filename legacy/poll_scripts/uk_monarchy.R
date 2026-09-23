#
#  British Monarchy
#

# Set Working dir 
setwd(basedir)

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/hlmFunc.R")

## SPSS to R [ALL T1]
monarchy <- spss("cdd/data/British Monarchy/monarchy_final.sav")

## Poll
monarchy$pollid <- 23
monarchy$country <- 2
monarchy$mode <- 0
monarchy$numitems <- 9
monarchy$numindices <- 4
monarchy$caseid <- 1000 + seq(1, nrow(monarchy))
monarchy$length <- NA
monarchy$timebtw <- NA

## Group
monarchy$pollgroup <- pgroup(monarchy$group, monarchy$pollid)
monarchy$groupsize <- grpfun(rep(1,nrow(monarchy)), monarchy$pollgroup, fun="sum")

# Knowledge
#monarchy$knowa1, monarchy$knowb1, monarchy$knowc1, monarchy$knowd1, monarchy$knowe1, monarchy$knowf1, monarchy$knowg1, monarchy$knowh1, monarchy$knowi1
#rowMeans(cbind(monarchy$knowa1, monarchy$knowb1, monarchy$knowc1,  monarchy$knowd1, monarchy$knowe1, monarchy$knowf1, monarchy$knowg1, monarchy$knowh1, monarchy$knowi1))

fromlist <- c("q5a", "r5a", "q5b", "r5b", "q5d", "r5d", "q5g", "r5g")
tolist   <- paste("know", c("a1", "a2", "b1","b2","d1", "d2", "g1", "g2"), sep = "")
monarchy[,tolist] <- sapply(monarchy[,fromlist], function(x) (x == 2)*1)

fromlist <- c("q5c", "q5c", "q5e", "r5e", "q5f", "r5f", "q5h", "r5h")
tolist   <- paste("know", c("c1", "c2", "e1","e2","f1", "f2", "h1", "h2"), sep = "")
monarchy[,tolist] <- sapply(monarchy[,fromlist], function(x) (x == 1)*1)

monarchy$knowi1 <- as.numeric(monarchy$q8a == 5)
monarchy$knowi2 <- as.numeric(monarchy$r8a  == 5)

monarchy$totknow1 = rowMeans(cbind(monarchy$knowa1, monarchy$knowb1, monarchy$knowc1, monarchy$knowd1, monarchy$knowe1 ,monarchy$knowf1 ,monarchy$knowg1 ,monarchy$knowh1 ,monarchy$knowi1 )) 
monarchy$totknow2 = rowMeans(cbind(monarchy$knowa2, monarchy$knowb2, monarchy$knowc2, monarchy$knowd2, monarchy$knowe2,monarchy$knowf2 ,monarchy$knowg2 ,monarchy$knowh2,monarchy$knowi2)) 

monarchy$knowa1cor  <- pkcor(monarchy$knowa1, monarchy$knowa2)
monarchy$knowb1cor  <- pkcor(monarchy$knowb1, monarchy$knowb2)
monarchy$knowc1cor  <- pkcor(monarchy$knowc1, monarchy$knowc2)
monarchy$knowd1cor  <- pkcor(monarchy$knowd1, monarchy$knowd2)
monarchy$knowe1cor  <- pkcor(monarchy$knowe1, monarchy$knowe2)
monarchy$knowf1cor  <- pkcor(monarchy$knowf1, monarchy$knowf2)
monarchy$knowg1cor  <- pkcor(monarchy$knowg1, monarchy$knowg2)
monarchy$knowh1cor  <- pkcor(monarchy$knowh1, monarchy$knowh2)
monarchy$knowi1cor  <- pkcor(monarchy$knowi1, monarchy$knowi2)

monarchy$t1knowcor <- with(monarchy, rowMeans(cbind(knowa1cor, knowb1cor, knowc1cor, knowd1cor, knowe1cor, knowf1cor, 
knowg1cor, knowh1cor, knowi1cor)))
monarchy$t1know <- monarchy$totknow1
monarchy$t2know <- monarchy$totknow2

monarchy$t1knowlevel <- mean(monarchy$t1know)

##Knowledge over the highest quartile is High Knowledge
monarchy$highknow <- as.numeric(monarchy$t1know > fivenum(monarchy$t1know)[4])

###Group Gain
knowindex <- with(monarchy, data.frame(knowa1cor, knowb1cor, knowc1cor, knowd1cor, knowe1cor, knowf1cor, knowg1cor, 
knowh1cor, knowi1cor))
monarchy$grpgain <- with(monarchy, groupgain(knowindex, pollgroup, nrow(monarchy), numitems, groupsize))

## Sociodem
monarchy$readbrief <- NA

monarchy$t1polint <- car::recode(monarchy$a6, "c(4) = 0; 3 = .33; 2 = .66; 1 = 1; 5 =  NA")

#Ethnic -> b16
monarchy$minority <-  as.numeric (!(monarchy$b16  == 1))
monarchy$female <- as.numeric(!(monarchy$sex  == 1))

temp <- monarchy$b12a
for(i in 1:nrow(monarchy)) {
if(!is.na(monarchy$b12a[i])) 
{
if(sum(monarchy$b12a[i] == c(1,2,3)) > 0) temp [i] <- 0
if(sum(monarchy$b12a[i] == c(4,5)) > 0) temp[i] <- .33
}
if(!is.na(monarchy$b12b[i])){
if(sum(monarchy$b12b[i] == c(4,5,6)) > 0) temp[i] <- .66
if(sum(monarchy$b12b[i] == c(7,8,9,10,11)) > 0) temp[i] <- 1.00
 }
}

###monarchy$educ4<- recode(monarchy$highqual, "c(4) = 1; c(3,5) = .66; c(2) = .33; c(1) = 0")
monarchy$educ4 <- temp
monarchy$educollege <- car::recode(monarchy$educ4, "c(1) = 1; NA = NA; else = 0")

##Income - income increco
monarchy$hhincome <- NA
monarchy$inc70plus <-NA

### table(monarchy$ageb)
#18-19 ; #20-29 ; #30-39 ; #40-49; #50-59 ; #60-69 ; #70-79 ; #80-89

agetemp <- car::recode(monarchy$ageb, "2 = 18.5; 3 = 25; 4 = 35; 5 = 45; 6 = 55;7 = 65;8 = 74; 9 = 83")

monarchy$ppage <- agetemp
monarchy$highinc <- NA


##L2 Variables
monarchy$pfemale <-grpfun(monarchy$female, monarchy$pollgroup, fun = "mean")
monarchy$varfemale  <- monarchy$pfemale*(1 - monarchy$pfemale)
monarchy$meant1know <-grpfun(monarchy$t1know, monarchy$pollgroup, fun = "mean")
monarchy$meant2know <-grpfun(monarchy$t2know, monarchy$pollgroup, fun = "mean")
monarchy$meant1know_ind <-  (monarchy$meant1know*monarchy$groupsize - monarchy$t1know)/(monarchy$groupsize - 1)
monarchy$phighknow <-grpfun(monarchy$highknow, monarchy$pollgroup, fun = "mean")
monarchy$phigheduc <-grpfun(monarchy$educollege, monarchy$pollgroup,fun = "mean")
monarchy$vareduc   <-grpfun(monarchy$educ4, monarchy$pollgroup, fun = "var")

#aggr <- aggregate(monarchy$educollege,list(monarchy$group), var, na.rm = 'TRUE')
#colnames(aggr) <- c("group", "phigheduc")
#monarchy <- merge(monarchy, aggr, by = "group")
#names(monarchy)[names(monarchy)=="phigheduc.y"] = "phigheduc" #renaming columns

monarchy$phighinc <- NA
monarchy$pminority <-  grpfun(monarchy$minority, monarchy$pollgroup, fun = "mean")

###Attitude Indices
#t1supmon,t2supmon Support for Monarchy
#t1mpop, t2mpop Monarchy and the People
#t1pwrm, t2pwrm Power of Monarchy
#t1reflor, t2reflor Reform House of Lords

monarchy$attextreme <- rowMeans(cbind(abs(monarchy$t1supmon -.5), abs(monarchy$t1mpop - .5), 
abs(monarchy$t1pwrm - .5), abs(monarchy$t1reflor - .5)), na.rm = TRUE)

##attitude variance - 

vart1supmon <- grpfun(monarchy$t1supmon, monarchy$pollgroup, fun = "var")
vart1mpop   <- grpfun(monarchy$t1mpop, monarchy$pollgroup, fun = "var")
vart1pwrm   <- grpfun(monarchy$t1pwrm, monarchy$pollgroup, fun = "var")
vart1reflor <- grpfun(monarchy$t1reflor, monarchy$pollgroup, fun = "var")

monarchy$avgsd <- rowMeans(cbind(sqrt(vart1supmon), sqrt(vart1mpop) , sqrt(vart1pwrm ),  sqrt(vart1reflor)), na.rm = T)

monarchy1 <- monarchy[,c("t1supmon", "t1mpop", "t1pwrm", "t1reflor")]
monarchy$genvar <- unsplit(lapply(split(monarchy1, monarchy$pollgroup), genvar),monarchy$pollgroup)

# Outputting
## Participants Only
monarchyp <- monarchy[!(monarchy$group == -1), ]

# Guess Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fromlist <- c("q5a", "r5a", "q5b", "r5b", "q5d", "r5d", "q5g", "r5g")
tolist   <- paste0("know", c("a1", "a2", "b1","b2","d1", "d2", "g1", "g2"), "raw")
monarchyp[,tolist] <- sapply(monarchyp[,fromlist], function(x) car::recode(x, "2=1;1=0;c(3,4)=NA"))

fromlist <- c("q5c", "q5c", "q5e", "r5e", "q5f", "r5f", "q5h", "r5h")
tolist   <- paste0("know", c("c1", "c2", "e1","e2","f1", "f2", "h1", "h2"), "raw")
monarchyp[,tolist] <- sapply(monarchyp[,fromlist], function(x) car::recode(x, "1=1;2=0;c(3,4)=NA"))

monarchyp$knowi1raw <- car::recode(monarchyp$q8a, "5=1;c(8,9)=NA;else=0")
monarchyp$knowi2raw <- car::recode(monarchyp$r8a, "5=1;c(8,9)=NA;else=0")

ukmonpk <- c("caseid", 
paste0("know", letters[1:8], "1"),
paste0("know", letters[1:8], "2"),
paste0("know", letters[1:8], "1cor"),
paste0("know", letters[1:8], "1raw"),
paste0("know", letters[1:8], "2raw"),
"t1know", "t2know", "ppage", "pollgroup", "educ4","female")

ukmonirt <- monarchyp[, ukmonpk]
write.csv(ukmonirt, file="guess/data/ukmonirt.csv")

# PK Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Midterm Measurement
monarchyp[, c("avgsd2", "grpgain2", "t1knowcor2", "t12know", "t12knowcor", "attextreme2")] <- NA

monarchyn <- monarchyp[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw")]
save(monarchyn, file="pk/data/monarchyn.Rdata")
save(monarchyn, file="cdd/pkdat/monarchyn.Rdata")

# Kyu Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
monarchykyu <- monarchyp[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw", "t1supmon",
"t2supmon","t1mpop", "t2mpop","t1pwrm", "t2pwrm","t1reflor", "t2reflor")]
save(monarchykyu, file="cdd/kyu/bypoll/monarchykyu.rdata", ascii=TRUE)

##   EVALUATION QS       ##
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

monarchy$selection <- as.numeric(!(monarchy$group == -1))
monarchy$opinionminority <- NA

varlist <- paste("eval", 1:15, sep="")
monarchy[,varlist] <- NA
monarchy$meanmodscore <- NA
monarchy$eval5GtoB <-NA 
monarchy$eval15D <- NA

monarchy.eval <- monarchy[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw","selection", "eval1","eval2","eval3","eval4","eval5","eval6",
"eval7","eval8","eval9","eval10", "eval11","eval12","eval13","eval14","eval15","meanmodscore","length",
"numindices","genvar","vareduc","varfemale","eval5GtoB","eval15D","opinionminority")]

save(monarchy.eval, file="dpeval/data/monarchy.eval.rdata", ascii=TRUE)
