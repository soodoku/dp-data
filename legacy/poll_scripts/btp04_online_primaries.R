#
# By the people 2004 Online Primaries
# Last Edited: 7.13.14   
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
source("func/match.R")

# Load data 
btp04 <- foreign::read.dta("cdd/data/BTP/2004OnlinePrimaries/data/2004 online primaries_hlm.dta")
btp04 <- subset(btp04, expcont=="experimental")

# Know
# egen pkind = rowmean(b1q43cor  b1q44cor  b1q45cor  b1q46cor  b1q47cor  b1q48cor  b1q49cor) 
# egen t2pkind = rowmean(f1q43cor  f1q44cor  f1q45cor  f1q46cor  f1q47cor  f1q48cor  f1q49cor ) if nurifilter2==1

btp04$t1know1raw <- recode(as.numeric(btp04$b1q43), "3=1;c(1,2,4,5)=0;6=NA")
btp04$t1know2raw <- recode(as.numeric(btp04$b1q44), "5=1;c(1,2,3,4,6)=0;7=NA")
btp04$t1know3raw <- recode(as.numeric(btp04$b1q45), "4=1;c(1,2,3,5,6)=0;7=NA")
btp04$t1know4raw <- recode(as.numeric(btp04$b1q46), "6=1;c(1,2,3,4,5)=0;7=NA")
btp04$t1know5raw <- recode(as.numeric(btp04$b1q47), "5=1;c(1,2,3,4)=0;6=NA")
btp04$t1know6raw <- recode(as.numeric(btp04$b1q48), "4=1;c(1,2,3,5,6)=0;7=NA")
btp04$t1know7raw <- recode(as.numeric(btp04$b1q49), "3=1;c(1,2,4,5)=0;6=NA")

btp04$t3know1raw <- recode(as.numeric(btp04$f1q43), "3=1;c(1,2,4,5)=0;6=NA")
btp04$t3know2raw <- recode(as.numeric(btp04$f1q44), "5=1;c(1,2,3,4,6)=0;7=NA")
btp04$t3know3raw <- recode(as.numeric(btp04$f1q45), "4=1;c(1,2,3,5,6)=0;7=NA")
btp04$t3know4raw <- recode(as.numeric(btp04$f1q46), "6=1;c(1,2,3,4,5)=0;7=NA")
btp04$t3know5raw <- recode(as.numeric(btp04$f1q47), "5=1;c(1,2,3,4)=0;6=NA")
btp04$t3know6raw <- recode(as.numeric(btp04$f1q48), "4=1;c(1,2,3,5,6)=0;7=NA")
btp04$t3know7raw <- recode(as.numeric(btp04$f1q49), "3=1;c(1,2,4,5)=0;6=NA")


t1raw <- paste0("t1know", 1:7, "raw")
t3raw <- paste0("t3know", 1:7, "raw")
t1 <- paste0("t1know", 1:7, "c")
t3 <- paste0("t3know", 1:7, "c")
 
btp04[,c(t1,t3)] <- nona(btp04[,c(t1raw, t3raw)])

# Compared it to Nuri's pkind and it matches

btp04$edu   <- recode(as.numeric(btp04$ppeduc), "c(3,4,5)=0; c(6,7)=.33; 8=.66; c(9,10,11)=1")
btp04$female  <- abs(btp04$male -1)

btp04irt <- btp04[, c(t1, t3, t1raw, t3raw, "female", "edu")]

write.csv(btp04irt, file="guess/data/bypoll/btp04irt.csv")
