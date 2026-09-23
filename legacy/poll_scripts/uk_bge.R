#
# British General Election
#

# Set Working dir 
setwd(basedir)

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/hlmFunc.R")

## SPSS to R, ALL
#ukbge <- spss("pk/data/orig_files/uk-bge.sav")
ukbge <- spss("cdd/data/British General Election/ukbge.sav")

## Poll Variables
ukbge$pollid <- 25
ukbge$country <- 2
ukbge$mode <- 0
ukbge$numitems <- 15
ukbge$caseid <- ukbge$serial
ukbge$numindices <- 4
ukbge$length <- NA
ukbge$timebtw <- NA

## Group Variables
ukbge$pollgroup <- pgroup(ukbge$group, ukbge$pollid)
ukbge$groupsize <- grpfun(rep(1, nrow(ukbge)), ukbge$group, fun = "sum") 

#L1 Variables

# Knowledge
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##Check to see that there is no missing on factual items. Assign missing to 0. 
#two factual knowledge - (all facts)inf3t1  (facts + party placement) inf12t1

ukbge$meanpk1 <- (((ukbge$infcont1 + ukbge$inflabt1 + ukbge$infldt1))*(4/15) + (ukbge$inf3t1)*(3/15))
ukbge$meanpk2 <- (((ukbge$infcont2 + ukbge$inflabt2 + ukbge$infldt2))*(4/15) + (ukbge$inf3t2)*(3/15))
ukbge$diffpk <-  ukbge$meanpk2 - ukbge$meanpk1

ukbge$t1know <- ukbge$meanpk1
ukbge$t2know <- ukbge$meanpk2

#ukbge$t1know <- ukbge$pktot1
#ukbge$t2know <- ukbge$pktot2
##party placement + factual items

###T1 Know
#Inflat1      =  Inflation Has Been < 5%? T1 (Q17a)
#Inflat2      =  Inflation Has Been < 5% T2 (Q17a)
#knowa1       =  Did R Answer INFLAT1 correctly? (1=yes)
#knowa2       =  Did R Answer INFLAT2 Correctly? (1=yes)
#Intrst1      =  Bank of Eng Decides Interest Rt?T1(Q17b)
#Intrst2      =  Bank of Eng Decides Interest Rt T2(Q17b)
#knowb1       =  Did R Answer INTRST1 Correctly? (1=Yes)
#knowb2       =  Did R Answer INTRST2 Correctly? (1=yes)
#Ukempl1      =  Unemployment in UK > Germany T1? (Q17c)
#Ukempl2      =  Unemployment in UK > Germany T2 (Q17c)
#knowc1       =  Did R Answer UKEMPL1 Correctly? (1=Yes)
#knowc2       =  Did R Answer UKEMPL2 Correctly? (1=yes)
#REDSTC1  - The Conservative Party's View:  Government should do nothing to make incomes in  Britain more equal.
#REDSTL1 -Labor, REDSTLD1 - Liberal
#TAXC1, TAXC2 (Q13):  The Conservative Party's View?  Government should spend much less on services like education  and health in order to cut taxes a lot.
#Taxl1
#WAGEC1, WAGEC2 (Q14):  The Conservative Party's View? Government should definitely not introduce a minimum wage because too many low paid workers would then lose their jobs.
#EUC1, EUC2 (Q15):  The Conservative Party's View?  Britain should do much more to keep its distance from  the European Union.
#inf3t1 <- rowMeans(cbind(ukbge$knowa1, ukbge$knowb1, ukbge$knowc1))
#ukbge$infcont1 <- rowMeans(cbind((ukbge$redstc1 > 0 & ukbge$redstc1 < 4),  (ukbge$taxc1 > 0 & ukbge$taxc1 < 4), (ukbge$wagec1 > 0 & ukbge$wagec1 < 4), (ukbge$euc1 > 0 & ukbge$euc1 < 4)))
#ukbge$inflabt1 <- rowMeans(cbind((ukbge$redstl1 > 4) , (ukbge$taxl1 > 4) , (ukbge$wagel1 > 4), (ukbge$eul1 > 4) ))
#ukbge$infldt1 <- mean(rowMeans(cbind((ukbge$redstld1 > 4)   ,(ukbge$taxld1 > 4) ,(ukbge$wageld1 > 4) , (ukbge$euld1 > 4))))

# Get NAs
pknames <- c("redstc", "taxc", "wagec", "euc", "redstl", "taxl", "wagel", "eul", "redstld", "taxld", "wageld", "euld")
pkt1 <- paste0(pknames, "1")
pkt2 <- paste0(pknames, "2")

ukbge[, c(pkt1, pkt2)] <- sapply(ukbge[, c(pkt1, pkt2)], function(x) car::recode(x, "c(-8, -9) = NA"))

# Validation: summary(ukbge[,pknames])

# Code Placement
# Conservatives
ukbge$redstc1pk <- nona(ukbge$redstc1 > 0 & ukbge$redstc1 < 4)
ukbge$taxc1pk<- nona(ukbge$taxc1 > 0 & ukbge$taxc1 < 4)
ukbge$wagec1pk<- nona(ukbge$wagec1 > 0 & ukbge$wagec1 < 4)
ukbge$euc1pk <- nona(ukbge$euc1 > 0 & ukbge$euc1 < 4)
ukbge$redstc2pk <- nona(ukbge$redstc2 > 0 & ukbge$redstc2 < 4)
ukbge$taxc2pk <- nona(ukbge$taxc2 > 0 & ukbge$taxc2 < 4)
ukbge$wagec2pk<- nona(ukbge$wagec2 > 0 & ukbge$wagec2 < 4)
ukbge$euc2pk <- nona(ukbge$euc2 > 0 & ukbge$euc2 < 4)

# Labor 
ukbge$redstl1pk <- nona(ukbge$redstl1 > 4)
ukbge$taxl1pk <- nona(ukbge$taxl1 > 4)
ukbge$wagel1pk <- nona(ukbge$wagel1 > 4)
ukbge$eul1pk<- nona(ukbge$eul1 > 4) 
ukbge$redstl2pk <- nona(ukbge$redstl2 > 4)
ukbge$taxl2pk <- nona(ukbge$taxl2 > 4)
ukbge$wagel2pk <- nona(ukbge$wagel1 > 4)
ukbge$eul2pk <- nona(ukbge$eul2 > 4) 

# Lib. Dems
ukbge$redstld1pk<- nona(ukbge$redstld1 > 4) 
ukbge$taxld1pk <- nona(ukbge$taxld1 > 4)
ukbge$wageld1pk <- nona(ukbge$wageld1 > 4)
ukbge$euld1pk <- nona(ukbge$euld1 > 4)
ukbge$redstld2pk <- nona(ukbge$redstld2 > 4) 
ukbge$taxld2pk  <- nona(ukbge$taxld2 > 4)
ukbge$wageld2pk  <- nona(ukbge$wageld2 > 4)
ukbge$euld2pk  <- nona(ukbge$euld2 > 4)

# 1 0 Correction
ukbge$knowa1cor <- with(ukbge, pkcor(knowa1, knowa2))
ukbge$knowb1cor <- with(ukbge, pkcor(knowb1, knowb2))
ukbge$knowc1cor <- with(ukbge, pkcor(knowc1, knowc2))
ukbge$redstc1pkcor <- with(ukbge, pkcor(redstc1pk, redstc2pk))
ukbge$taxc1pkcor <- with(ukbge, pkcor(taxc1pk, taxc2pk))
ukbge$wagec1pkcor <- with(ukbge, pkcor(wagec1pk, wagec2pk))
ukbge$euc1pkcor <- with(ukbge, pkcor(euc1pk, euc2pk))
ukbge$redstl1pkcor <- with(ukbge, pkcor(redstl1pk, redstl2pk))
ukbge$taxl1pkcor <- with(ukbge, pkcor(taxl1pk,   taxl2pk))
ukbge$wagel1pkcor <- with(ukbge, pkcor(wagel1pk,  wagel2pk))
ukbge$eul1pkcor     <- with(ukbge, pkcor(eul1pk,    eul2pk))
ukbge$redstld1pkcor <- with(ukbge, pkcor(redstld1pk, redstld2pk))
ukbge$taxld1pkcor   <- with(ukbge, pkcor(taxld1pk,  taxld2pk))
ukbge$wageld1pkcor  <- with(ukbge, pkcor(wageld1pk, wageld2pk))
ukbge$euld1pkcor    <- with(ukbge, pkcor(euld1pk,   euld2pk))

# Calculate reliability
pksubs <- with(ukbge, data.frame(knowa1, knowb1, knowc1, redstc1pk, taxc2pk,wagec1pk , euc1pk,redstc1pk, taxc1pk, wagec1pk, euc1pk,redstc1pk,taxc1pk,wagec1pk, euc1pk))
ltm::cronbach.alpha(pksubs, standardized = FALSE, CI = FALSE, probs = c(0.025, 0.975), B = 1000, na.rm = TRUE)

ukbge$totpk1cor <- with(ukbge, rowMeans(cbind(knowa1cor, knowb1cor, knowc1cor, redstc1pkcor, taxc1pkcor, 
wagec1pkcor, euc1pkcor , redstl1pkcor, taxl1pkcor, wagel1pkcor, eul1pkcor, 
redstld1pkcor, taxld1pkcor, wageld1pkcor, euld1pkcor)))
ukbge$t2know <- with(ukbge, rowMeans(cbind(knowa2, knowb2, knowc2, redstc2pk, taxc2pk,wagec2pk , euc2pk,redstl2pk, taxl2pk,
wagel2pk,eul2pk,redstld2pk,taxld2pk,wageld2pk, euld2pk)))

#ukbge$t1know <- rowMeans(cbind(ukbge$knowa1, ukbge$knowb1, ukbge$knowc1, ukbge$redstc1pk, ukbge$taxc1pk, ukbge$wagec1pk, ukbge$euc1pk , ukbge$redstl1pk, ukbge$taxl1pk, ukbge$wagel1pk, ukbge$eul1pk, ukbge$redstld1pk, ukbge$taxld1pk, ukbge$wageld1pk, ukbge$euld1pk)))

ukbge$t1knowcor <- ukbge$totpk1cor

#Group Gain
knowindex <- with(ukbge, data.frame(knowa1cor, knowb1cor, knowc1cor, redstc1pkcor, taxc1pkcor, wagec1pkcor, 
euc1pkcor , redstl1pkcor, taxl1pkcor, wagel1pkcor, eul1pkcor, redstld1pkcor, taxld1pkcor, 
wageld1pkcor, euld1pkcor))
ukbge$grpgain <- groupgain(knowindex, ukbge$group, nrow(ukbge), ukbge$numitems, ukbge$groupsize)

## Other Sociodem
# ~~~~~~~~~~~~~~~~~~~~~~~~~~
ukbge$readbrief <- NA

ukbge$t1polint <- car::recode(ukbge$int1, "c(-9, -8) = NA; 5 = 1; 4 = .75; 3 = .50; 2 = .25; 1 = 0")
#Media Consumption Variables:
  #      NewsYN       =  Read Daily AM Paper 3x Week? (QA2a)
    #    NewsP        =  Which Newspaper? (QA2b)

#Political Interest Variables:
        #Care         =  Care Which Party Wins (QA6)
        #int1         =  Interest in Politics Generally T1 (Q1)
        #int2         =  Interest in Politics Generally T2 (Q1)
###int2         =  Interest in Politics Generally T2 (Q1)

ukbge$minority <- as.numeric(!(ukbge$dummyethnic))
#gender 1 = male
ukbge$female <- as.numeric(!(ukbge$gender))

###
#educa --> 0,1,2 = below hs; 3,4 = hs grad
#educb --> 0 = no qual; 1,2,3 = below hs; 4,5,6 = some college; 7,8, 9,10,11 = bs or beyond

temp <- NA
for(i in 1:nrow(ukbge)) {
if(!is.na(ukbge$educa[i])) 
{
if(sum(ukbge$educa[i] == c(0, 1, 2)) > 0) temp [i] <- 0
if(sum(ukbge$educa[i] == c(3, 4)) > 0) temp[i] <- .33
}
if(!is.na(ukbge$educb[i])){
if(sum(ukbge$educb[i] == c(4, 5, 6)) > 0) temp[i] <- .66
if(sum(ukbge$educb[i] == c(7, 8, 9, 10, 11)) > 0) temp[i] <- 1.00
 }
}

#ukbge$educ4 <- recode(ukbge$educa, "c(-9)=NA; 4=1; 3=.66; 2=.33; 1=0")
ukbge$educ4 <- temp
ukbge$educollege <- car::recode(ukbge$educ4, "1 = 1; c(0, .33, .66) = 0; NA = NA")

##Assign missing, DK to NA

##Income - income increco
ukbge$hhincome <- car::recode(ukbge$increco, "-9 = NA; 1 = 1; 2 = 2; 3 = 3; 4 = 4; 5 = 5")

##Knowledge over the highest quartile is High Knowledge
ukbge$highknow    <- (ukbge$t1know > fivenum(ukbge$t1know)[4])
ukbge$highinc     <- car::recode(ukbge$hhincome, "c(1, 2, 3) = 0; c(4, 5) = 1")
ukbge$ppage       <- car::recode(ukbge$age, "-7 = NA")
ukbge$t1knowlevel <- mean(ukbge$t1know)

##L2 Variables
##Ensuring group has 2 digits
ukbge$pfemale    <- grpfun(ukbge$female, ukbge$group, fun = "mean")
ukbge$varfemale  <- ukbge$pfemale*(1 - ukbge$pfemale)
ukbge$meant1know <- grpfun(ukbge$t1know, ukbge$group, fun = "mean")
ukbge$meant1know_ind <-  with(ukbge, (meant1know*groupsize - t1know )/(groupsize - 1))
ukbge$meant2know <-  grpfun(ukbge$t2know, ukbge$group, fun = "mean")
ukbge$phighknow  <-  grpfun(ukbge$highknow, ukbge$group, fun = "mean")
ukbge$phigheduc  <-  grpfun(ukbge$educollege, ukbge$group, fun = "mean")
ukbge$vareduc    <-  grpfun(ukbge$educ4, ukbge$group, fun = "var")
ukbge$phighinc   <-  grpfun(ukbge$highinc, ukbge$group, fun = "mean")
ukbge$pminority  <-  grpfun(ukbge$minority, ukbge$group, fun = "mean")

# Attitudes
# ~~~~~~~~~~~~~~~~~~~~~~~

#Att. Extremity
#t1redist t1tax t1wage t1eu
ukbge$attextreme <- with(ukbge, rowMeans(abs(cbind(t1eu, t1wage, t1tax, t1redist) - .5), na.rm=TRUE))

##Generalized Variance Function
ukbge1 <- ukbge[,c("t1redist", "t1tax", "t1wage", "t1eu")]
ukbge$genvar <- unsplit(lapply(split(ukbge1, ukbge$group), genvar),ukbge$group)

##attitude variance - t1redist t1tax t1wage t1eu
##Redistribution t1redist t2redist; Taxt1taxt2tax; Minimum Waget1wage t2wage; EUt1eut2eu
fromlist       <- c("t1redist", "t1tax", "t1wage", "t1eu")
tolist         <- paste("var", fromlist, sep = "")
ukbge[,tolist] <- sapply(ukbge[,fromlist], function(x) grpfun(x, ukbge$pollgroup, fun = "var"))

ukbge$avgsd <- with(ukbge, rowMeans(sqrt(cbind(vart1redist,  vart1tax,  vart1wage, vart1eu)), na.rm=TRUE))

# Midterm Measurement
ukbge[, c("avgsd2", "grpgain2", "t1knowcor2", "t12know", "t12knowcor", "attextreme2")] <- NA

# Outputting 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Participants Only
ukbgep <- subset(ukbge, ukbge$filter == 1)

# Guess subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ukbgep$knowa1raw <- car::recode(ukbgep$inflat1, "2 = 0; c(-8, -9) = NA")
ukbgep$knowb1raw <- car::recode(ukbgep$intrst1,  "1 = 0; 2 = 1; c(-8, -9) = NA")
ukbgep$knowc1raw <- car::recode(ukbgep$ukempl1, "1 = 0; 2 = 1; c(-8, -9) = NA")
ukbgep$redstc1raw <- (ukbgep$redstc1 < 4)
ukbgep$taxc1raw <- (ukbgep$taxc1 < 4)
ukbgep$wagec1raw <- (ukbgep$wagec1 < 4)
ukbgep$euc1raw <- (ukbgep$euc1 < 4)

ukbgep$redstl1raw <- (ukbgep$redstl1 > 4)
ukbgep$taxl1raw <- (ukbgep$taxl1 > 4)
ukbgep$wagel1raw <- (ukbgep$wagel1 > 4)
ukbgep$eul1raw <- (ukbgep$eul1 > 4) 

ukbgep$redstld1raw <- (ukbgep$redstld1 > 4) 
ukbgep$taxld1raw <- (ukbgep$taxld1 > 4)
ukbgep$wageld1raw <- (ukbgep$wageld1 > 4)
ukbgep$euld1raw <- (ukbgep$euld1 > 4)

ukbgep$knowa2raw <- car::recode(ukbgep$inflat2, "2 = 0; c(-8, -9) = NA")
ukbgep$knowb2raw <- car::recode(ukbgep$intrst2,  "1 = 0; 2 = 1; c(-8, -9)=NA")
ukbgep$knowc2raw <- car::recode(ukbgep$ukempl2, "1 = 0; 2 = 1; c(-8, -9)=NA")

ukbgep$redstc2raw <- (ukbgep$redstc2 < 4)
ukbgep$taxc2raw <- (ukbgep$taxc2 < 4)
ukbgep$wagec2raw <- (ukbgep$wagec2 < 4)
ukbgep$euc2raw <- (ukbgep$euc2 < 4)

ukbgep$redstl2raw <- (ukbgep$redstl2 > 4)
ukbgep$taxl2raw <- (ukbgep$taxl2 > 4)
ukbgep$wagel2raw <- (ukbgep$wagel2 > 4)
ukbgep$eul2raw <- (ukbgep$eul2 > 4) 

ukbgep$redstld2raw <- (ukbgep$redstld2 > 4) 
ukbgep$taxld2raw <- (ukbgep$taxld2 > 4)
ukbgep$wageld2raw <- (ukbgep$wageld2 > 4)
ukbgep$euld2raw <- (ukbgep$euld2 > 4)

ukbgepk <- c("caseid", 
c("knowa1", "knowb1", "knowc1", "redstc1pk", "taxc1pk", "wagec1pk", "euc1pk", "redstl1pk", "taxl1pk", "wagel1pk", "eul1pk", "redstld1pk", "taxld1pk", "wageld1pk", "euld1pk"),
c("knowa2", "knowb2", "knowc2", "redstc2pk", "taxc2pk", "wagec2pk", "euc2pk", "redstl2pk", "taxl2pk", "wagel2pk", "eul2pk", "redstld2pk", "taxld2pk", "wageld2pk", "euld2pk"),
paste0(c("knowa1", "knowb1", "knowc1", "redstc1pk", "taxc1pk", "wagec1pk", "euc1pk", "redstl1pk", "taxl1pk", "wagel1pk", "eul1pk", "redstld1pk", "taxld1pk", "wageld1pk", "euld1pk"), "cor"),
paste0(c("knowa1", "knowb1", "knowc1", "redstc1", "taxc1", "wagec1", "euc1", "redstl1", "taxl1", "wagel1", "eul1", "redstld1", "taxld1", "wageld1", "euld1"), "raw"),
paste0(c("knowa2", "knowb2", "knowc2", "redstc2", "taxc2", "wagec2", "euc2", "redstl2", "taxl2", "wagel2", "eul2", "redstld2", "taxld2", "wageld2", "euld2"), "raw"),
"t1know", "t2know", "age", "pollgroup", "educ4","female")

ukbgeirt <- ukbgep[, ukbgepk]
write.csv(ukbgeirt, file = "guess/data/ukbgeirt.csv")

# PK subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~
ukbgen <- ukbgep[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw")]
save(ukbgen, file = "cdd/pkdat/ukbgen.Rdata", ascii = TRUE)

# Kyu subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~
ukbgekyu <- ukbgep[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw", "t1redist", "t1tax", "t1wage", "t1eu",
"t2redist", "t2tax", "t2wage", "t2eu")]
save(ukbgekyu, file = "cdd/kyu/bypoll/ukbgekyu.rdata", ascii = TRUE)

###############################
##   EVALUATION QS       ##
###############################

ukbge$selection <- as.numeric(ukbge$filter == 1)

e0 <-"NA=NA"
e2 <-"1=0;2=1;else=NA"
e2r <- "1=1;2=0;else=NA"
e3 <-"1=0;2=.5;3=1;else=NA"
e4 <-"1=0;2=.33;3=.66;4=1;else=NA"
e4r <-"1=1;2=.66;3=.33;4=0;else=NA"
e5 <-"1=0;2=.25;3=.5;4=.75;5=1;else=NA"
e5r <-"1=1;2=.75;3=.5;4=.25;5=0;else=NA"
e10 <-"1=.1;2=.2;3=.3;4=.4;5=.5;6=.6;7=.7;8=.8;9=.9;10=1;else=NA"
############
 #GrpDisc      =  Value of Group Discussions T2 (Q25a)
  #      Talking      =  Value: Talking Outside Group T2 (Q25b)
   #     Experts      =  Value of The Experts Sessions T2 (Q25c)
    #    Pols         =  Value: the Politicians Sessions T2(Q25d)
     #   ModPart      =  Moderator Allowed Participation T2(Q26a)
      #  ModInfl      =  Moderator Influenced Group T2 (Q26b)
       # BiasMat      =  Were the Materials Biased T2 (Q27)
        #DOPint       =  How Interesting was the D.O.P. T2 (Q28)
########################
ukbge$opinionminority <- NA

ukbge$eval1 <- ukbge$readbrief
ukbge$eval2 <- NA
ukbge$eval3 <- NA
ukbge$eval4 <- car::recode(ukbge$modpart, e5)
ukbge$eval5 <- car::recode(ukbge$modinfl, e5)
ukbge$eval6 <- car::recode(ukbge$experts, e3)
ukbge$eval7 <- car::recode(ukbge$pols, e3)
ukbge$eval8 <- car::recode(ukbge$grpdisc, e3)
ukbge$eval9 <- car::recode(ukbge$biasmat,e2)
ukbge$eval10 <- NA
ukbge$eval11 <- NA
ukbge$eval12 <- NA
ukbge$eval13 <- car::recode(ukbge$talking, e3)
ukbge$eval14 <- NA
ukbge$eval15 <- car::recode(ukbge$dopint, e4)
ukbge$meanmodscore <- NA
ukbge$eval5GtoB <-car::recode(ukbge$modinfl, e5r)
ukbge$eval15D <- NA
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


#######################

ukbge.eval <- ukbge[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw", "selection", "eval1","eval2","eval3","eval4","eval5","eval6",
"eval7","eval8","eval9","eval10", "eval11","eval12","eval13","eval14","eval15","meanmodscore","length",
"numindices","genvar","vareduc","varfemale","eval5GtoB","eval15D","opinionminority")]

save(ukbge.eval, file = "dpeval/data/ukbge.eval.rdata", ascii=TRUE)


############################################
####  PK 
################################################


ukbgeirt <- ukbge[, c("pollid","country","age","mode","pollgroup","caseid",
"groupsize","t1know","t2know","t1knowlevel","meant1know","meant1know_ind","educ4", 
"female","pfemale","minority","pminority","income", "knowa1cor", "knowa1","knowa2", 
"knowb1cor", "knowb1","knowb2","knowc1cor", "knowc1","knowc2", "redstc1pkcor", "redstc1pk",
"redstc2pk","taxc1pkcor", "taxc1pk","taxc2pk", "wagec1pkcor", "wagec1pk","wagec2pk","euc1pkcor", 
"euc1pk","euc2pk", "redstl1pkcor", "redstl1pk","redstl2pk","taxl1pkcor", "taxl1pk","taxl2pk", 
"wagel1pkcor", "wagel1pk","wagel2pk","eul1pkcor", "eul1pk","eul2pk", "redstld1pkcor", "redstld1pk",
"redstld2pk","taxld1pkcor", "taxld1pk","taxld2pk", "wageld1pkcor", "wageld1pk","wageld2pk","euld1pkcor", 
"euld1pk","euld2pk")]
save(ukbgeirt, file = "Data/CDD/irt/ukbgeirt.rdata", ascii=TRUE)
