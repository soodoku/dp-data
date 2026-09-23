#
#    San Mateo
#    Last Edited: 5.23.14    
#    Gaurav Sood
#

# Set Working dir.
setwd(basedir)

# http://cdd.stanford.edu/polls/california/2008/threshold2008-report.pdf
# Incorrect final averages

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/hlmFunc.R") # Loading up functions

# Load data
sm <-foreign::read.dta("cdd/data/San Mateo/sm_caseid.dta")
names(sm)<- tolower(names(sm))

# Knowledge
# t1
sm$t1q19raw <- sm$q19 == "about 1,000"
sm$t1q20raw <- sm$q20 == "950,000"
sm$t1q21raw <- sm$q21 == "12%"
sm$t1q22raw <- sm$q22 == "$1,700"
sm$t1q23raw <- sm$q23 == "70,000"
sm$t1q24raw <- sm$q24 == "About half"
sm$t1q25raw <- sm$q25 == "25,000"
sm$t1q26raw <- sm$q26 == "more than 75%"

# t2
sm$t2q19raw <- sm$t2q19 == "about 1,000"
sm$t2q20raw <- sm$t2q20 == "5"
sm$t2q21raw <- sm$t2q21 == "12%"
sm$t2q22raw <- sm$t2q22 == "$1,700"
sm$t2q23raw <- sm$t2q23 == "70,000"
sm$t2q24raw <- sm$t2q24 == "About half"
sm$t2q25raw <- sm$t2q25 == "25,000"
sm$t2q26raw <- sm$t2q26 == "5"

t1 <- paste0("t1q", 19:26, "c")
t3 <- paste0("t2q", 19:26, "c")

t1raw <- paste0("t1q", 19:26, "raw")
t3raw <- paste0("t2q", 19:26, "raw")

sm[,t1] <- nona(sm[,t1raw])
sm[,t3] <- nona(sm[,t3raw])

smirt <- sm[,c(t1, t3, t1raw, t3raw, "female")]

write.csv(smirt, file="guess/data/bypoll/smirt.csv")

















