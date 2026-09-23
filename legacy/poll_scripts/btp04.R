#
# BTP 2004
# Last Edited: 9.03.13  
# Gaurav Sood
#

# Set Working dir.
setwd(basedir)
	
# Sourcing libs 
library(goji)
library(car)

# Sourcing common functions
source("func/func.R")
source("cdd/hlmFunc.R")

# Load data
btp04 <- foreign::read.dta("cdd/data/BTP/2004.GE/2004GE.dta")
#btp04 <- subset(btp04, !is.na(btp04$w4cond)) # All cases for w4
# Control group and participants
btp04 <- subset(btp04, btp04$dop4 == "dop participant in this wave" | btp04$dop4 == "control case in this wave")
btp04 <- subset(btp04, !is.na(btp04$w4bend))

#sum(is.na(btp04$w4bend)[btp04$dop4part])
#sum([!btp04$dop4part])

#btp04 <- subset(btp04, btp04$dop4part == 1)

## Poll
btp04$numindices <- 5
btp04$pollid     <- 94
btp04$mode       <- 0
btp04$numitems   <- 9
btp04$country    <- 1


## Knowledge
##~~~~~~~~~~~~~~~~~~~~~~~~

#Information
#1.b260cor:How did John Kerry vote in the Senate on the resolution authorizing President Bush to go to war with Iraq? (Voted for); 
#2. b261cor:Which of the following countries now harbors the most Al Qaeda and Taliban fighters? (Pakistan); 
#3.b268cor:A major destination of white collar jobs that have gone to other countries is? (India); 
#4.b269cor:Which of the following is closest to the number of Americans killed in Iraq since the war began? (1000)

btp04$w4b60c <- nona(btp04$w4b60 == "vote for it") #w4b60r
btp04$w4b61c <- nona(btp04$w4b61 == "pakistan")  #w4b61r
btp04$w4b68c <- nona(btp04$w4b68 == "india")  #w4b68r
btp04$w4b69c <- nona(btp04$w4b69 == "1,000")  #w4b69r

btp04$w4f60c <- nona(btp04$w4f60 == "vote for it") #w4f60r
btp04$w4f61c <- nona(btp04$w4f61 == "pakistan") #w4f61r
btp04$w4f68c <- nona(btp04$w4f68 == "india")  #w4f68r
btp04$w4f69c <- nona(btp04$w4f69 == "1,000")  #w4f69r

btp04$t1pk   <-  with(btp04, rowMeans(cbind(w4b60c, w4b61c, w4b68c, w4b69c)))
btp04$t2pk   <-  with(btp04, rowMeans(cbind(w4f60c, w4f61c, w4f68c, w4f69c)))

# Corrected
btp04$w4b60cor <- pkcor(btp04$w4b60c, nona(btp04$w4f60r))
btp04$w4b61cor <- pkcor(btp04$w4b61c, nona(btp04$w4f61r))
btp04$w4b68cor <- pkcor(btp04$w4b68c, nona(btp04$w4f68r))
btp04$w4b69cor <- pkcor(btp04$w4b69c, nona(btp04$w4f69r))

btp04$t1pkcor   <-  with(btp04, rowMeans(cbind(w4b60cor, w4b61cor, w4b68cor, w4b69cor)))
#Misinformation 
#1. b262cor: True or false - "Iraq was directly involved in the attacks on the WTC and the Pentagon on 9-11 2001" (False);
#2. b263cor: True or false - "Large quantities of weapons of mass destruction have been found in Iraq" (False); 
#3. b264cor:True or false - "On average, prescription drugs cost more in Canada than in the US" (False); 
#4.b265cor:Which of the following was true of George W. Bush during the Vietnam War? (served in the TX Air National Guard);  
#1. He was drafted but never went to Vietnam; 
#2.He was a decorated officer serving in Vietnam
#3.He was ineligible to serve in the military because of a medical deferment 
#4.He served in the Texas Air National Guard
#5.b266cor:Which of the following was true of John Kerry during the Vietnam War? (decorated officer serving in Vietnam); 
#1.He was drafted but never went to Vietnam 
#2.He was a decorated officer serving in Vietnam
#3.He was ineligible to serve in the military because of a medical deferment 
#4.He served in the Massachusetts Air National Guard
#Which of the Presidential candidates has endorsed all of the recommendations of the 911 commission:
#Bush but not Kerry Kerry but not Bush Both Kerry and Bush Neither Kerry nor Bush

btp04$w4b62m <- nona(btp04$w4b62 == "true")  #w4b62r

btp04$w4b63m <- nona(btp04$w4b63 == "true") #w4b63r
btp04$w4b64m <- nona(btp04$w4b64 == "true")  #w4b64r
btp04$w4b65m <- nona(btp04$w4b65 == "he was ineligible to serve in the military because of a medi" | 
btp04$w4b65 == "he was a decorated officer serving in vietnam")  #w4b65r
btp04$w4b65dm <- nona(btp04$w4b65 == "he was drafted but never went to vietnam")
btp04$w4b66m <- nona(btp04$w4b66 == "he was drafted but never went to vietnam" | 
btp04$w4b66 == "he served in the massachusetts air national guard")  #w4b66r
btp04$t1mpk   <-  with(btp04, rowMeans(cbind(w4b62m, w4b63m, w4b64m, w4b65m, w4b66m)))

btp04$w4f62m <- nona(btp04$w4f62 == "true")  #w4b62r
btp04$w4f63m <- nona(btp04$w4f63 == "true") #w4b63r
btp04$w4f64m <- nona(btp04$w4f64 == "true")  #w4b64r

sum(btp04$w4b66m[btp04$dop4part == 1] - nona(as.numeric(btp04$w4f66 == "he was drafted but never went to vietnam" | 
btp04$w4f66 == "he served in the massachusetts air national guard"))[btp04$dop4part == 1])
## Sociodem
#Race
btp04$minority <- (btp04$ppeth!="white, non-hispanic")
#Gender
btp04$female <- btp04$ppgender == "female"
#Age
btp04$ppage
#Education
btp04$ppeducat
#Education in 4
btp04$ppeducat
#

btp04$pid3 <- recode(btp04$w4b76, "'democrat'='dem'; 'republican'='rep'; 'independent'='ind'; else=NA") #(rep/dem)
levels(btp04$w4b76)

btp04$w4b77 #(lib/con)
btp04$w4b79 #(religious service)
btp04$w4q80 #(bible)
# Party ID
sum(btp04$rep, na.rm=T)
sum(btp04$dem, na.rm=T)
btp04$indep
#Vote
btp04$w4bvote
# Turnout
btp04$w4bturnout

cbind(btp04$w4f76, btp04$w4b76)

table(btp04$w4b76, btp04$t1pk)

# Save file
save(btp04, file = "misinformation/data/btp04.rdata")
