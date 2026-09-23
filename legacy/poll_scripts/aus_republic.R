#
#  Australian Referendum
#

# Set Working dir.
setwd(basedir)

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/scripts/hlmFunc.R") # Loading up functions

## SPSS to R, ALL
#australia <- spss("pk/data/orig_files/Australia.sav")
aus <- foreign::read.spss("cdd/data/australia_republic/Australia.sav", use.value.labels = FALSE)
#aus <- subset(aus, !is.na(aus$group)) ## Contains the t1 poll, others are pointless
aus <- as.data.frame(aus)
names(aus) <- tolower(names(aus))

## Poll
aus$numindices <- 5
aus$pollid     <- 26
aus$mode       <- 0
aus$numitems   <- 11
# Specifies whether person was born overseas or australian. 
aus$country1   <- aus$country
aus$country    <- 3
aus$length     <- 2
aus$timebtw    <- NA

## Group
aus$group 	  <- recode(aus$group, "100 = NA")
aus$pollgroup <- pgroup(aus$group, aus$pollid)
aus$groupsize <- grpfun(rep(1, nrow(aus)), aus$pollgroup, fun = "sum")

# CG/Participant
## T3 control group
aus$t3ctrl <- is.na(aus$group)
	
## T3 control group versus Participant
aus$t3ctrl.part <- NA
aus$t3ctrl.part[is.na(aus$group)] <- 0
aus$t3ctrl.part[!is.na(aus$partfull) & as.numeric(aus$partfull) == 1] <- 1
	
## Participant Non-Participant
aus$part.np <- recode(aus$partfull, "c(1, 2) = 1; 0 = 0")
	
# Control Part
aus$ctrl.part <- NA
aus$ctrl.part[!is.na(aus$part.np) & aus$partfull != 2 & !is.na(aus$retmo3) & aus$partfull] <- 1
aus$ctrl.part[!is.na(aus$part.np) & aus$partfull != 2 & !is.na(aus$retmo3) & aus$partfull == 0] <- 0

# Only Interviewed at Time 3, ARCS 

# Weights for aust3
#aust3 <- aus[(is.na(aus$group)),] 
## Weighting # aus$state
aus$weight <- 1
bool <- is.na(aus$group) & !is.na(aus$state3)
aus$weight[bool & aus$state3 == 1]  <- 1.5057 #NSW # Cross-checked census
aus$weight[bool & aus$state3 == 2]  <- 1.0482 #VIC 
aus$weight[bool & aus$state3 == 3]  <- .7937 #QLD
aus$weight[bool & aus$state3 == 4]  <- .3128 #SA
aus$weight[bool & aus$state3 == 5]  <- .3949 #WA
aus$weight[bool & aus$state3 == 6]  <- .1023 #TAS
aus$weight[bool & aus$state3 == 7]  <- .6869 #ACT
aus$weight[bool & aus$state3 == 8]  <- .9061 #NT

# L1 Variables
	#t1know t2know female   minority  ppage educ4 hhincome attextreme highinc t1polint  attextreme readbrief

## Knowledge
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"
 
Check to see that there is no missing on factual items. Assign missing to 0.
Just checking - facts <- (aus$rpfact1 +aus$qrfact1 +aus$pfact1+aus$ggfact1)/4
	
which one of these best describes the current  role of the Queen in relation to the ausn Governor-General: 
Queen appoints the Governor-General only on advice of Prime Minister		qrole1, qrfact1, qrfact2
which one of these best describes how the ausn Prime Minister in the Republic can remove the President: 
Prime Minister could remove the President at any time but must obtain approval from the House of Representatives 
rempres1, rpfact1, rpfact2
Powers of president same relative to current Governor-General prespow1, prespow2 (correct answer = 2, same)
which one of these is true of the  current role of the Governor-General in aus ggrole1, ggfact1, ggfact2
President like Gov. General	PRFACT1
Labor party more in favor of republic	PFACT1 - apparently people were mislead
Labor party more concerned with welfare	WELFACT1
Liberal party closer to business	BUSFACT1
Role of Aden Ridgeway	RFACT1
Role of Jennie George	JGFACT1

qrfact1, rpfact1, ggfact1, prfact1, pfact1, welfact1, busfact1, rfact1, jgfact1, (prespow1 == 2)
Keeping out PFACT
Apparently mislead people in the plenary session
aus$pwfact1 <- as.numeric(aus$prespow1 == 2)
aus$pwfact2 <- as.numeric(aus$prespow2 == 2)
aus$pwfact3 <- nona(as.numeric(aus$prespow3 == 2))
	
"
# Multiplying by one to change boolean to numeric
# Introducing DK Change seems to reduce reliability
aus$flagchg1c <- 1*(aus$flagchg1 == 1  & aus$dkchg1 != 1) # 
aus$anthem1c  <- 1*(aus$anthem1 == 1  & aus$dkchg1 != 1)
aus$wdroyal1c <- 1*(aus$wdroyal1 == 2  & aus$dkchg1 != 1)
aus$pargame1c <- 1*(aus$pargame1 == 1  & aus$dkchg1 != 1)
		
#aus$flagchg1c <- 1*(aus$flagchg1 == 1)
#aus$anthem1c  <- 1*(aus$anthem1 == 1)
#aus$wdroyal1c <- 1*(aus$wdroyal1 == 2)
#aus$pargame1c <- 1*(aus$pargame1 == 1)

# Recoding Var.
# Not Answered assigned 0 # Checked that this is not unit-missing
r2 <- "99 = 0; c(96, 97, 98, 100) = NA"
		
aus$flagchg2c <- 1*(recode(aus$flagchg2, r2) == 1)
aus$anthem2c  <- 1*(recode(aus$anthem2, r2) == 1)
aus$wdroyal2c <- 1*(recode(aus$wdroyal2, r2) == 2)
aus$pargame2c <- 1*(recode(aus$pargame2, r2) == 1)
		
fromlist     <- c("rpfact2", "qrfact2", "ggfact2", "prfact2", "pfact2", "welfact2", "busfact2", "rfact2", "jgfact2")
tolist       <- paste(fromlist, "c", sep="") 
aus[,tolist] <- sapply(aus[,fromlist], function(x) recode(x , "100 = NA"))
		
# No unanswered here..(a little weird)
aus$flagchg3c <- 1*(aus$flagchg3 == 1)
aus$anthem3c  <- 1*(aus$anthem3 == 1)
aus$wdroyal3c <- 1*(aus$wdroyal3 == 2)
aus$pargame3c <- 1*(aus$pargame3 == 1)
		
# Calculate reliability
pksubs <- with(aus, data.frame(qrfact3, rpfact3, ggfact3, prfact3, flagchg3c, anthem3c, wdroyal3c, pargame3c) == 1)
ltm::cronbach.alpha(pksubs, standardized = FALSE, CI = FALSE, probs = c(0.025, 0.975), B = 1000, na.rm = TRUE)

# Mean pk
aus$t1know <- with(aus, rowMeans(cbind(qrfact1, rpfact1, ggfact1, prfact1, welfact1, busfact1, rfact1, jgfact1, flagchg1c, anthem1c, wdroyal1c, pargame1c))) 
aus$t2know <- with(aus, rowMeans(cbind(qrfact2, rpfact2, ggfact2, prfact2, welfact2, busfact2, rfact2, jgfact2, flagchg2c, anthem2c, wdroyal2c, pargame2c ) == 1))
aus$t3know <- with(aus, rowMeans(cbind(qrfact3, rpfact3, ggfact3, prfact3, flagchg3c, anthem3c, wdroyal3c, pargame3c)))
		
# With P fact
aus$t1know.r <- with(aus, rowMeans(cbind(qrfact1, rpfact1, ggfact1, prfact1, pfact1, flagchg1c, anthem1c, wdroyal1c, pargame1c))) 
aus$t2know.r <- with(aus, rowMeans(cbind(qrfact2, rpfact2, ggfact2, as.numeric(prespow2 == 2), prfact2, welfact2, busfact2, rfact2, jgfact2, flagchg2c, anthem2c, wdroyal2c, pargame2c ) == 1))
aus$t3know.r <- with(aus, rowMeans(cbind(qrfact3, rpfact3, ggfact3, prfact3, pfact3, flagchg3c, anthem3c, wdroyal3c, pargame3c)))
		
# Referendum Knowledge
aus$refknow1 <- with(aus, rowMeans(cbind(qrfact1, rpfact1, ggfact1, prfact1, flagchg1c, anthem1c, wdroyal1c, pargame1c)))
aus$refknow2 <- with(aus, rowMeans(cbind(qrfact2, rpfact2, ggfact2, prfact2, flagchg2c, anthem2c, wdroyal2c, pargame2c) == 1))
aus$refknow3 <- with(aus, rowMeans(cbind(qrfact3, rpfact3, ggfact3, prfact3, flagchg3c, anthem3c, wdroyal3c, pargame3c)))
	
# Political Knowledge
aus$polknow1 <- with(aus, rowMeans(cbind(pfact1, welfact1, busfact1, rfact1, jgfact1)))
aus$polknow2 <- with(aus, rowMeans(cbind(pfact2, welfact2, busfact2, rfact2, jgfact2) == 1))
	
# Some correlations
cor(cbind(aus$refknow1, aus$polknow1), use = "na.or.complete")
# Correlation between the two decreases as participants learn one and not the other
cor(cbind(aus$refknow2, aus$polknow2), use = "na.or.complete")
	
## Corrected Facts
## ~~~~~~~~~~~~~~~~~~~~~~~~~
	
common <- c("rpfact", "qrfact", "ggfact", "prfact", "pfact", "welfact",  "busfact", "rfact", "jgfact")
t1list <- c(paste(common, "1", sep = ""), "flagchg1c", "anthem1c", "wdroyal1c", "pargame1c")
t2list <- paste(c(common, c("flagchg", "anthem", "wdroyal", "pargame")), "2c", sep = "")
tolist <- paste(t1list, "cor", sep = "")
aus[, tolist] <- aus[, t1list]*aus[, t2list]
	
aus$refknow1cor <- with(aus, rowMeans(cbind(qrfact1cor, rpfact1cor, ggfact1cor, prfact1cor, flagchg1ccor, anthem1ccor, wdroyal1ccor, pargame1ccor)))

# Guess
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## t1 facts with dk coded as na
	
aus$rpfact1r	<- recode(aus$rempres1,   "2 = 1; 97 = NA; c(1, 3, 4, 96) = 0") #aus$rpfact1
aus$qrfact1r	<- recode(aus$qrole1,     "4 = 1; 97 = NA; c(1, 2, 3, 96) = 0") #aus$qrfact1 
aus$ggfact1r	<- recode(aus$ggrole1,    "4 = 1; 97 = NA; c(1, 2, 3, 96) = 0") #aus$ggfact1
aus$prfact1r	<- recode(aus$presrol1,   "4 = 1; 97 = NA; c(1, 2, 3, 96) = 0") #aus$prfact1
aus$pfact1r		<- recode(aus$party1,     "3 = 1; 97 = NA; c(1, 2, 96) = 0")   #aus$pfact1
aus$welfact1r	<- recode(aus$welfare1,   "3 = 1; c(97, 99) = NA; c(1, 2, 96) = 0")   #aus$welfare1
aus$busfact1r	<- recode(aus$busines1,   "1 = 1; c(97, 99) = NA; c(2, 3, 96) = 0")   #aus$busines1
aus$rfact1r 	<- recode(aus$ridgewy1,   "4 = 1; 97 = NA; c(1, 2, 3, 5) = 0")    #aus$ridgewy1
aus$jgfact1r 	<- recode(aus$jgeorge1,   "4 = 1; 97 = NA; c(1, 2, 3, 5) = 0")    #aus$jgeorge1

aus$flagchg1r <- ifelse(aus$dkchg1 == 1, NA, aus$flagchg1c)
aus$anthem1r  <- ifelse(aus$dkchg1 == 1, NA, aus$anthem1c)
aus$wdroyal1r <- ifelse(aus$dkchg1 == 1, NA, aus$wdroyal1c)
aus$pargame1r <- ifelse(aus$dkchg1 == 1, NA, aus$pargame1c)
		
## t2 facts with dk coded as na
aus$rpfact2r  	<- recode(aus$rempres2,   "2 = 1; c(97, 99) = NA; c(1, 3, 4, 96) = 0")		#aus$rpfact2
aus$qrfact2r  	<- recode(aus$qrole2,     "4 = 1; c(97, 99) = NA; c(1, 2, 3, 96) = 0") 	#aus$qrfact2 
aus$ggfact2r  	<- recode(aus$ggrole2,    "4 = 1; c(97, 99) = NA; c(1, 2, 3, 96) = 0") 	#aus$ggfact2
aus$prfact2r	<- recode(aus$presrol2,   "4 = 1; c(97, 99) = NA; c(1, 2, 3, 96) = 0") 	#aus$prfact2
aus$pfact2r		<- recode(aus$party2,     "3 = 1; c(4, 97, 99) = NA; c(1, 2, 96) = 0")   	#aus$pfact2 
aus$welfact2r	<- recode(aus$welfare2,   "3 = 1; c(97, 99) = NA; c(1, 2, 96) = 0")   	#aus$welfare2
aus$busfact2r	<- recode(aus$busines2,   "1 = 1; c(97, 99) = NA; c(2, 3, 96) = 0")   	#aus$busines2
aus$rfact2r 	<- recode(aus$ridgewy2,   "4 = 1; c(97, 99) = NA; c(1, 2, 3, 5, 96) = 0") #aus$ridgewy2
aus$jgfact2r 	<- recode(aus$jgeorge2,   "4 = 1; c(97, 99) = NA; c(1, 2, 3, 5, 96) = 0")    #aus$jgeorge1

aus$flagchg2r <- ifelse(aus$dkchg2 == 1, NA, aus$flagchg2c)
aus$anthem2r  <- ifelse(aus$dkchg2 == 1, NA, aus$anthem2c)
aus$wdroyal2r <- ifelse(aus$dkchg2 == 1, NA, aus$wdroyal2c)
aus$pargame2r <- ifelse(aus$dkchg2 == 1, NA, aus$pargame2c)
		
## t3 facts with dk coded as na
aus$rpfact3r  <- recode(aus$rempres3, "2 = 1; c(97, 99) = NA; c(1, 3, 4, 96) = 0") #aus$rpfact3
aus$qrfact3r  <- recode(aus$qrole3,   "4 = 1; c(97, 99) = NA; c(1, 2, 3, 96) = 0") #aus$qrfact3 
aus$ggfact3r  <- recode(aus$ggrole3,  "4 = 1; c(97, 99) = NA; c(1, 2, 3, 96) = 0") #aus$ggfact3
aus$prfact3r  <- recode(aus$presrol3, "4 = 1; c(97, 99) = NA; c(1, 2, 3, 96) = 0") #aus$prfact3
aus$pfact3r   <- recode(aus$party3,   "3 = 1; c(97, 99) = NA; c(1, 2, 96) = 0")   #aus$pfact3
#aus$flagchg1r <- aus$flagchg3c # same 
#aus$anthem1r  <- aus$anthem3c
#aus$wdroyal1r <- aus$wdroyal3c
#aus$pargame1r <- aus$pargame3c
		
## Cor Facts with t3 as the correction
aus$rpfact1corr  <- with(aus, rpfact1*rpfact3)
aus$qrfact1corr  <- with(aus, qrfact1*qrfact3)
aus$ggfact1corr  <- with(aus, ggfact1*ggfact3)
aus$prfact1corr  <- with(aus, prfact1*prfact3)
aus$pfact1corr   <- with(aus, pfact1*pfact3)
aus$flagchg1corr <- with(aus, flagchg1c*flagchg3c)
aus$anthem1corr  <- with(aus, anthem1c*anthem3c)
aus$wdroyal1corr <- with(aus, wdroyal1c*wdroyal3c)
aus$pargame1corr <- with(aus, pargame1c*pargame3c)
	
	
# Corrected PK
aus$t1knowcor <- with(aus, rowMeans(cbind(qrfact1cor, rpfact1cor, ggfact1cor, prfact1cor, welfact1cor, busfact1cor, rfact1cor, 
												jgfact1cor,flagchg1ccor,anthem1ccor,wdroyal1ccor,pargame1ccor)))

# Group Gain
temp <- subset(aus, !is.na(aus$group))
knowindex <- with(temp, data.frame(qrfact1cor, rpfact1cor, ggfact1cor, prfact1cor, welfact1cor, 
					busfact1cor, rfact1cor, jgfact1cor,flagchg1ccor,anthem1ccor,wdroyal1ccor,pargame1ccor))
aus$grpgain <- ifelse(is.na(aus$group), NA, with(temp, groupgain(knowindex, group, nrow(temp), numitems, groupsize)))
	
# Issue-Specific 
temp <- subset(aus, !is.na(aus$group))
knowindex <- with(temp, data.frame(qrfact1cor, rpfact1cor, ggfact1cor, prfact1cor, flagchg1ccor, anthem1ccor, wdroyal1ccor, pargame1ccor))
aus$grpgainr <- ifelse(is.na(aus$group), NA, with(temp, groupgain(knowindex, group, nrow(temp), rep(8, nrow(temp)), groupsize)))

# Approval
# Vote vars
# approve3 #1 no, 2 yes
# firstop3, secop3
mean(aus$approve1 == 2, na.rm = T)
mean(aus$approve2 == 2, na.rm = T)
mean(aus$approve3[is.na(aus$group)] == 2)

r1 <- "97 = NA"
# Approve
aus$approve1r <- recode(as.numeric(aus$approve1), r1)
aus$approve2r <- recode(as.numeric(aus$approve2), r1)

aus$approve1rr <- recode(aus$approve1, "1 = -1; 2 = 1; 97 = 0; 98 = NA")
aus$approve2rr <- recode(aus$approve2, "1 = -1; 2 = 1; c(99, 100) = NA")
aus$chgvtr 	   <- aus$approve2rr - aus$approve1rr
	
aus$approve3r <- NULL
aus$approve3r <- recode(as.numeric(aus$approve3), "c(96,99) = NA")

mean(aus$approve1r == 2, na.rm = T)
mean(aus$approve2r == 2, na.rm = T)
mean(aus$approve3r[is.na(aus$group)] == 2, na.rm = T)
	
fromlist <- c("firstop1", "firstop2", "firstop3", "prespow1", "prespow2", "prespow3", "tiesbr1", "tiesbr2", "tiesbr3")
tolist   <- paste(fromlist, "r", sep = "")
aus[,tolist] <- sapply(aus[,fromlist], function(x) recode(x, r1))
	
cor(aus$prespow3r, aus$prespow3, use = "na.or.complete")

index     <- c("presout", "headaus", "distrac", "pmpower", "prezpow", "repexp", "common", "polstab", "constrd", "moreind", "stanwor", "confron", "stweak", "moredem", "prespol",  "ppchpre",
			   "quedem", "qbritin", "monarch", "polfeel", "brither", "preserv", "majorit")
fromlist     <- paste(index, "1", sep = "")
tolist       <- paste(fromlist, "r", sep = "") 
aus[,tolist] <- sapply(aus[, fromlist], function(x) recode(x , r1))
	
## Tea 2
fromlist     <- paste(index, "2", sep = "")
tolist       <- paste(fromlist, "r", sep = "") 
aus[,tolist] <- sapply(aus[, fromlist], function(x) recode(x , r1))
cor(aus$majorit2r, aus$majorit2, use = "na.or.complete")
	
## Tea 3
fromlist     <- paste(index, "3", sep = "")[1:18]
tolist       <- paste(fromlist, "r", sep = "") 
aus[,tolist] <- sapply(aus[, fromlist], function(x) recode(x , r1))
	
if(FALSE){
	aus$monarch3  <- recode(aus$monarch3, r1)
	aus$polfeel3  <- recode(aus$polfeel3, r1)
	aus$brither3  <- recode(aus$brither3, r1)
	aus$preserv3  <- recode(aus$preserv3, r1)
	aus$majorit3 <- recode(aus$majorit3, r1)
}

## Group
aus$groupsize = ave(seq_along(aus$group), aus$group, FUN=length)
aus$groupsize[is.na(aus$group) | aus$partfull == 0 | aus$group == 100] <- NA
	
aus$papprove.t1 <- grpfun(aus$approve1 == 2, aus$group, fun = "mean")
aus$papprove.t1[aus$partfull == 0] <- NA
aus$papprove.t1.ind <-  (aus$papprove.t1*aus$groupsize - I(aus$approve1 == 2))/(aus$groupsize - 1)
	
aus$papprove.t1r <- grpfun(aus$approve1rr, aus$group, fun = "mean")
aus$papprove.t1r[aus$partfull == 0] <- NA
aus$papprove.t1.indr <-  (aus$papprove.t1*aus$groupsize - I(aus$approve1rr))/(aus$groupsize - 1)

#no to yes = 1; no to non, yes to yes = 0; yes to no = -1
aus$votech <- NA
temp <- paste(aus$approve1r, aus$approve3r)
aus$votech[temp == "1 2"] <- 1
aus$votech[(temp == "1 1" | temp == "2 2")] <- 0
aus$votech[temp == "2 1"] <- -1

# New attitudes

aus$secop3

# Aus. Republic
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Const. items 1
# ---------------------------
# Scored 1 for those ranking Retaining the Queen and the Governor-General third
# as .5 for those ranking that option second or saying DK, 
# and as 0 for those ranking it first.
aus$republic1 <- aus$republic2 <- aus$republic3 <- NA
aus$republic1[!is.na(aus$firstop1) & aus$firstop1 == 3] <- 0
aus$republic1[!is.na(aus$secop1) & (aus$secop1 == 3 | aus$secop1 == 97 | aus$secop1 == 100)] <- .5
aus$republic1[!is.na(aus$firstop1) & !is.na(aus$secop1) &  (aus$secop1!=3 & aus$firstop1!=3 & aus$secop1 < 90)] <- 1

# t2
aus$republic2[!is.na(aus$firstop2) & aus$firstop2 == 3] <- 0
aus$republic2[!is.na(aus$secop2) & (aus$secop2 == 3 | aus$secop2 == 97 | aus$secop2 == 99)] <- .5
aus$republic2[!is.na(aus$firstop2) & !is.na(aus$secop2) &  (aus$secop2!=3 & aus$firstop2!=3 & aus$secop2 < 90)] <- 1

# t3
aus$republic3[!is.na(aus$firstop3) & aus$firstop3 == 3] <- 0
aus$republic3[!is.na(aus$secop3) & (aus$secop3 == 3 | aus$secop3 == 97)] <- .5
aus$republic3[!is.na(aus$firstop3) & !is.na(aus$secop3) &  (aus$secop3!=3 & aus$firstop3!=3 & aus$secop3 < 90)] <- 1

# TIESBR1, TIESBR2, TIESBR3
# ----------------
# Reverse code
aus$tiesbr1r <- zero1(recode(aus$tiesbr1, '97 = NA'),  5, 1)
aus$tiesbr2r <- zero1(recode(aus$tiesbr2, 'c(97, 99, 100) = NA'), 5, 1)
aus$tiesbr3r <- zero1(recode(aus$tiesbr3, 'c(97, 99, 100) = NA'), 5, 1)

# HEADAUS1, HEADAUS2, HEADAUS3 
# -----------------------
aus$headaus1r <- zero1(recode(aus$headaus1, '97 = NA'))
aus$headaus2r <- zero1(recode(aus$headaus2, 'c(99, 100) = NA'))
aus$headaus3r <- zero1(recode(aus$headaus3, 'c(99, 100) = NA'))

# Index
with(aus, cor(cbind(republic1, tiesbr1r, headaus1r), use = "na.or.complete"))

aus$republican1 <- with(aus, rowMeans(cbind(republic1, tiesbr1r, headaus1r), na.rm = T))
aus$republican2 <- with(aus, rowMeans(cbind(republic2, tiesbr2r, headaus2r), na.rm = T))
aus$republican3 <- with(aus, rowMeans(cbind(republic3, tiesbr3r, headaus3r), na.rm = T))

# Popular or Parliament
# Scored as 1 for those ranking “A President directly elected by the people” first and “A President appointed by Parliament” third
# .75 for those ranking “A President directly elected by the people” first and “A President appointed by Parliament” second or 
# “A President directly elected by the people” second and “A President appointed by Parliament” third;
# .5 for those not ranking either of those two options or saying DK; 
# .25 for those ranking “A President appointed by Parliament”  first and “A President directly elected by the people” second or 
# “A President appointed by Parliament” second and “A President directly elected by the people” third; 
# and 0 for those ranking “A President appointed by Parliament” first and “A President directly elected by the people” third. 

aus$popparl1 <- aus$popparl2 <- aus$popparl3 <- NA

aus$popparl1[!is.na(aus$firstop1) & !is.na(aus$secop1) & aus$firstop1 == 1 & aus$secop1 == 3] <- 1
aus$popparl1[!is.na(aus$firstop1) & !is.na(aus$secop1) & ((aus$firstop1 == 1 & aus$secop1 == 2) | (aus$secop1 == 1 & aus$firstop1 == 3))] <- .75
aus$popparl1[!is.na(aus$firstop1) & !is.na(aus$secop1) & ((aus$firstop1 == 97 |aus$secop1 == 97) |  (aus$firstop1 == 3 & aus$secop1 == 3))] <- .5
aus$popparl1[!is.na(aus$firstop1) & !is.na(aus$secop1) & ((aus$firstop1 == 2 & aus$secop1 == 1) | (aus$secop1 == 2 & aus$firstop1 == 3))] <- .25
aus$popparl1[!is.na(aus$firstop1) & !is.na(aus$secop1) & aus$firstop1 == 2 & aus$secop1 == 3] <- 0

aus$popparl2[!is.na(aus$firstop2) & !is.na(aus$secop2) & aus$firstop2 == 1 & aus$secop2 == 3] <- 1
aus$popparl2[!is.na(aus$firstop2) & !is.na(aus$secop2) & ((aus$firstop2 == 1 & aus$secop2 == 2) | (aus$secop2 == 1 & aus$firstop2 == 3))] <- .75
aus$popparl2[!is.na(aus$firstop2) & !is.na(aus$secop2) & ((aus$firstop3 == 97 |aus$secop3 == 97) |  (aus$firstop2 == 3 & aus$secop2 == 3))] <- .5
aus$popparl2[!is.na(aus$firstop2) & !is.na(aus$secop2) & ((aus$firstop2 == 2 & aus$secop2 == 1) | (aus$secop2 == 2 & aus$firstop2 == 3))] <- .25
aus$popparl2[!is.na(aus$firstop2) & !is.na(aus$secop2) & aus$firstop2 == 2 & aus$secop2 == 3] <- 0

aus$popparl3[!is.na(aus$firstop3) & !is.na(aus$secop3) & aus$firstop3 == 1 & aus$secop3 == 3] <- 1
aus$popparl3[!is.na(aus$firstop3) & !is.na(aus$secop3) & ((aus$firstop3 == 1 & aus$secop3 == 2) | (aus$secop3 == 1 & aus$firstop3 == 3))] <- .75
aus$popparl3[!is.na(aus$firstop3) & !is.na(aus$secop3) & ((aus$firstop3 == 97 |aus$secop3 == 97) |  (aus$firstop3 == 3 & aus$secop3 == 3))] <- .5
aus$popparl3[!is.na(aus$firstop3) & !is.na(aus$secop3) & ((aus$firstop3 == 2 & aus$secop3 == 1) | (aus$secop3 == 2 & aus$firstop3 == 3))] <- .25
aus$popparl3[!is.na(aus$firstop3) & !is.na(aus$secop3) & aus$firstop3 == 2 & aus$secop3 == 3] <- 0


# Sociodem
# ~~~~~~~~~~~~~~~~~~~~~~~~

aus$female <- aus$gender_d
aus$educollege <- aus$edulev_r
#edulev - 1 = primary, 2 = some high school, 3 = hschool grad, 4 = college, 5 = post grad, 98 = refused
aus$educ4 <- recode(aus$edulev,"98 = NA; 1 = 0; 2 = .33; 3 = .66; c(4, 5) = 1")
#aus$overseas #100 = NA, 97=DK, 1 = Non-English, 2=English Speaking (born overseas) - but not really minority
aus$minority <- as.numeric(aus$overseas < 2)
aus$ppage <- aus$age
	
##Income REFUSED/ 98 DON'T KNOW - 987  $70000 OR MORE  -6  $50000-$69999 -5   $40000-$49999  -4   $30000-$39999 -3    $20000-$29999-2 LESS THAN $20000 -1
##Assign missing, DK to NA
aus$income[(aus$income ==  98) | (aus$income ==  97) ] <- NA
## Fix the Income
aus$hhincome <- aus$income
aus$hhincome <- recode(aus$income,"NA = NA; 1 = .16; 2 = .33; 3 = .50; 4 = .66; 5 = .83; 6 = 1")

# Political Interest -> aus$intpol1  
aus$t1polint <- recode(aus$intpol1,"97 = NA; 1 = 0; 2 = .33; 3 = .66; 4 = 1")
aus$readbrief <- NA

##Knowledge over the highest quartile is High Knowledge
aus$highknow <- (aus$t1know > fivenum(aus$t1know)[4])
aus$highinc <- as.numeric(aus$hhincome > .66) #70k or above

##Att. Extremity
aus$attextreme <- rowMeans(abs(cbind(aus$workind1, aus$Demind1, aus$Tradind1, aus$Polind1) - .5), na.rm=TRUE)

## L2 Variables
fromlist <- c("female", "minority", "educollege", "highinc", "highknow", "t1know", "t2know")
tolist   <- c("pfemale", "pminority", "phigheduc", "phighinc", "phighknow", "meant1know", "meant2know")
aus[,tolist] <- sapply(aus[, fromlist], function(x) grpfun(x, aus$pollgroup, fun = "mean"))
	
aus$varfemale <- (aus$pfemale)*(1- aus$pfemale)
aus$meant1know_ind <- with(aus, (meant1know*groupsize - t1know )/(groupsize - 1))
aus$vareduc <- grpfun(aus$educ4, aus$pollgroup, fun = "var")

##Generalized Variance Function
aus1 <- aus[, c("autind1","workind1","demind1","tradind1", "polind1")]
aus$genvar <- unsplit(lapply(split(aus1, aus$group), genvar),aus$group)

##############Attitude Variance
fromlist <- c("workind1", "demind1", "autind1", "tradind1", "polind1")
tolist   <- paste("var", fromlist, sep = "")
aus[,tolist] <- sapply(aus[,fromlist], function(x) grpfun(x, aus$pollgroup, fun = "var"))

aus$avgsd <-  with(aus, rowMeans(sqrt(cbind(varautind1, varworkind1, vardemind1, vartradind1, varpolind1))))

# Weighted Index
aus$varWorkind1 <- with(aus, grpfun(workind1*t1knowcor, group, fun = "var"))
aus$varDemind1  <- with(aus, grpfun(demind1*t1knowcor, group, fun = "var"))
aus$varAutind1  <- with(aus, grpfun(autind1*t1knowcor, group, fun = "var"))
aus$varTradind1 <- with(aus, grpfun(tradind1*t1knowcor, group, fun = "var"))
aus$varPolind1  <- with(aus, grpfun(polind1*t1knowcor, group, fun = "var"))
aus$avgsd1      <- with(aus, rowMeans(sqrt(cbind(varAutind1, varWorkind1, varDemind1, varTradind1, varPolind1))))

aus$t1knowlevel <- mean(aus$t1know)

# Midterm Measurement
aus[, c("avgsd2", "grpgain2", "t1knowcor2", "t12know", "t12knowcor", "attextreme2")] <- NA

	
# Save All
save(aus, file = "cdd/data/Australia Constitution/aus.Rdata")

# Load All
load("cdd/data/Australia Constitution/aus.Rdata")

## Participants Only
aus$refknow1cor <- with(aus, rowMeans(cbind(qrfact1cor, rpfact1cor, ggfact1cor, prfact1cor, flagchg1ccor, anthem1ccor, wdroyal1ccor, pargame1ccor)))
ausp <- subset(aus, !is.na(aus$group) & (aus$group != 100))

# Does reliability improve post-correction?
with(ausp, ltm::cronbach.alpha(cbind(qrfact1, rpfact1, ggfact1, prfact1, flagchg1c, anthem1c, wdroyal1c, pargame1c), na.rm=T))
with(ausp, ltm::cronbach.alpha(cbind(qrfact1cor, rpfact1cor, ggfact1cor, prfact1cor, flagchg1ccor, anthem1ccor, wdroyal1ccor, pargame1ccor), na.rm=T))
with(ausp, ltm::cronbach.alpha(cbind(qrfact1, rpfact1, ggfact1, prfact1, welfact1, busfact1, rfact1, jgfact1, flagchg1c, anthem1c, wdroyal1c, pargame1c), na.rm=T))
with(ausp, ltm::cronbach.alpha(cbind(qrfact1cor, rpfact1cor, ggfact1cor, prfact1cor, welfact1cor, busfact1cor, rfact1cor, jgfact1cor, flagchg1ccor, anthem1ccor, wdroyal1ccor, pargame1ccor), na.rm=T))

# Issue-specific know vars.
ausp$t1knowr <- ausp$refknow1
ausp$t2knowr <- ausp$refknow2
ausp$t1knowrcor <- ausp$refknow1cor

# Guess Subset
# ~~~~~~~~~~~~~~~~~~~~~~
auspk <- c(paste0(c("rp", "qr", "gg", "pr", "r", "jg", "p", "bus", "wel"), "fact1"), "flagchg1c", "anthem1c", "wdroyal1c", "pargame1c", 
				   paste0(c("rp", "qr", "gg", "pr", "r", "jg", "p", "bus", "wel"), "fact2"), "flagchg2c", "anthem2c", "wdroyal2c", "pargame2c",
				   paste0(c(paste0(c("rp", "qr", "gg", "r", "pr", "jg", "p", "bus", "wel"), "fact1"), "flagchg1", "anthem1", "wdroyal1", "pargame1"), "r"),
				   paste0(c(paste0(c("rp", "qr", "gg", "r", "pr", "jg", "p", "bus", "wel"), "fact2"), "flagchg2", "anthem2", "wdroyal2", "pargame2"), "r"),
					"t1know", "t2know", "age", "pollgroup", "educ4","female")
		
ausirt <- ausp[, auspk]
write.csv(ausirt, file = "guess/data/bypoll/ausirt.csv")
		
# PK Subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`	
common.cols <- c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems", "pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
			"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", "genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
			"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know", "t12knowcor", "attextreme2", "length", "timebtw")

ausn <- ausp[, common.cols]  

# Save Data
#save(ausn, file="pk/data/ausn.Rdata")
save(ausn, file = "cdd/pkdat/ausn.Rdata")
	
## Kyu Data ##
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ausmonkyu <- ausp[, c(common.cols, "autind1","workind1","demind1", "tradind1", "polind1", "autind2","workind2", "demind2","tradind2","polind2",
								   "popparl1", "popparl2", "republican1", "republican2")]
save(ausmonkyu, file = "cdd/kyu/data/bypoll/ausmonkyu.rdata")

	

##   EVALUATION QS  	     ##
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
aus$selection <- !is.na(aus$group) & (aus$group != 100)
eval.cols <- c("eval1", "eval2", "eval4", "eval5","eval6","eval7","eval8", "eval9","eval10","eval11", "eval12", "eval13", "eval14", "eval15", "meanmodscore", "eval5GtoB", "eval15D", "opinionminority")
aus[, eval.cols] <- NA
	
aus.eval <- aus[, c(common.cols, eval.cols)]
#save(aus.eval, file="dpeval/data/aus.eval.rdata", ascii=TRUE)
	
