##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~---++
##   ##
##      By the people 2004 GE
##Last Edited: 7.14.14   
##   Gaurav Sood##
##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~---++

# Set Working dir 
setwd(basedir)

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/hlmFunc.R")
source("func/match.R")

 
# Load data 
# btp05 <- foreign::read.dta("cdd/data/BTP/2005/data/btp05_hlm.dta")

btp04 <- foreign::read.dta("cdd/data/BTP/2004GE/data/2004 online GE_hlm.dta")
#btp04 <- foreign::read.dta("cdd/data/BTP/2004GE/data/2004GE.dta")



# Q60.  How did John Kerry vote in the Senate on the resolution authorizing President Bush to go to war with Iraq?  Did he …Vote for it Vote against it Not vote on it Don’t know
# Q61.  Which of the following countries now harbors the most Al Qaeda and Taliban fighters? 1.India 2.Pakistan 3.Sri Lanka 4.Indonesia 5.Don’t know
# How about the following statements?  Could you tell us if each is true or false?
# Q62.  Iraq was directly involved in the attacks on the World Trade Center and the Pentagon on 9-11-2001.  True False Don’t know
# Q63.  Large quantities of weapons of mass destruction have been found in Iraq. True False Don’t know
# Q64.  On average, prescription drugs cost more in Canada than in the U.S. True False Don’t know
# Q65.  Which of the following was true of George W. Bush during the Vietnam War? 1.He was drafted but never went to Vietnam  2.He was a decorated officer serving in Vietnam 3.He was ineligible to serve in the military because of a medical deferment 4.He served in the Texas Air National Guard 5.Don’t know
# Q66.  Which of the following was true of John Kerry during the Vietnam War? 1.He was drafted but never went to Vietnam  2.He was a decorated officer serving in Vietnam 3.He was ineligible to serve in the military because of a medical deferment 4.He served in the Massachusetts Air National Guard 5.Don’t know
# Q67.  Which of the Presidential candidates has endorsed all of the recommendations of the 911 commission: Bush but not Kerry Kerry but not Bush Both Kerry and Bush Neither Kerry nor Bush Don’t know  
# Q68.  A major destination for white collar jobs that have gone to other countries is: 1.South Africa 2. Japan 2.Brazil 3.India 4.Don’t know
# Q69.  Which of the following is closest to the number of Americans killed in Iraq since the war began: 100 500 1,000 10,000 Don’t know

# Know
btp04$t1know1raw <- recode(as.numeric(btp04$w4b60), "5=1;c(1,2,3,4,6,7,8)=0;9=NA")
btp04$t1know2raw <- recode(as.numeric(btp04$w4b61), "6=1;c(1,2,3,4,5,7,8)=0;10=NA")
btp04$t1know3raw <- recode(as.numeric(btp04$w4b62), "6=1;c(1,2,3,4,5,7)=0;8=NA")
btp04$t1know4raw <- recode(as.numeric(btp04$w4b63), "6=1;c(1,2,3,4,5,7)=0;8=NA")
btp04$t1know5raw <- recode(as.numeric(btp04$w4b64), "6=1;c(1,2,3,4,5,7)=0;8=NA")
btp04$t1know6raw <- recode(as.numeric(btp04$w4b65), "8=1;c(1,2,3,4,5,6,7)=0;10=NA")
btp04$t1know7raw <- recode(as.numeric(btp04$w4b66), "6=1;c(1,2,3,4,5,7,8)=0;10=NA")
#btp04$t1know7raw <- recode(as.numeric(btp04$w4b67), "3=1;c(1,2,4,5)=0;6=NA")
btp04$t1know8raw <- recode(as.numeric(btp04$w4b68), "8=1;c(1,2,3,5,6,7)=0;10=NA")
btp04$t1know9raw <- recode(as.numeric(btp04$w4b69), "7=1;c(1,2,4,5,6,8)=0;10=NA")

btp04$t3know1raw <- recode(as.numeric(btp04$w4f60), "5=1;c(1,2,3,4,6,7,8)=0;9=NA")
btp04$t3know2raw <- recode(as.numeric(btp04$w4f61), "6=1;c(1,2,3,4,5,7,8)=0;10=NA")
btp04$t3know3raw <- recode(as.numeric(btp04$w4f62), "6=1;c(1,2,3,4,5,7)=0;8=NA")
btp04$t3know4raw <- recode(as.numeric(btp04$w4f63), "6=1;c(1,2,3,4,5,7)=0;8=NA")
btp04$t3know5raw <- recode(as.numeric(btp04$w4f64), "6=1;c(1,2,3,4,5,7)=0;8=NA")
btp04$t3know6raw <- recode(as.numeric(btp04$w4f65), "8=1;c(1,2,3,4,5,6,7)=0;10=NA")
btp04$t3know7raw <- recode(as.numeric(btp04$w4f66), "6=1;c(1,2,3,4,5,7,8)=0;10=NA")
#btp04$31know7raw <- recode(as.numeric(btp04$w4b67), "3=1;c(1,2,4,5)=0;6=NA")
btp04$t3know8raw <- recode(as.numeric(btp04$w4f68), "8=1;c(1,2,3,5,6,7)=0;10=NA")
btp04$t3know9raw <- recode(as.numeric(btp04$w4f69), "7=1;c(1,2,4,5,6,8)=0;10=NA")


t1raw <- paste0("t1know", 1:9, "raw")
t3raw <- paste0("t3know", 1:9, "raw")
t1 <- paste0("t1know", 1:9, "c")
t3 <- paste0("t3know", 1:9, "c")
 
btp04[,c(t1,t3)] <- nona(btp04[,c(t1raw, t3raw)])

# Subsetting as it seems there is missing q issue
btp04 <- subset(btp04, !is.na(t1know) & !is.na(t2know) & dop4part)

# Compared it t1know and t2know it matches

btp04$edu   <- recode(as.numeric(btp04$ppeduc), "c(1,2,3)=0; c(4,5)=.33; 6=.66; c(7,8,9)=1")

btp04irt <- btp04[, c(t1, t3, t1raw, t3raw, "female", "edu")]

write.csv(btp04irt, file="guess/data/bypoll/btp04GEirt.csv")
