#
# Japan Kanagawa
# Last Edited: 9.02.13           
# Gaurav Sood
#

# Note -  JP Not in Mohanty Data

# Set Working dir 
setwd(basedir)

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/hlmFunc.R")

## SPSS to R, Participants Only
jp <- foreign::read.dta("cdd/data/Japan/jpt2t3indices.dta")
load("cdd/data/Japan/t1jp.rdata")

#L3 Variables
jp$pollid <- 70
jp$mode <- 0
jp$country <-  4
jp$length <- NA
jp$timebtw <- NA

# Recoded correct pk 
pkcor <- function(x,y) {
z <- NA
z <- as.numeric(x==y)
z[is.na(z)] <- 0
z
}

# 5 is NA
pkcorrect <- c(3,3,3,3,2,1,3)
jp[,paste0("q", 8:14, "c")] <- NA
jp[,paste0("t2_know_q", 19:25, "c")] <- NA
jp[,paste0("t3_know_q", 19:25, "c")] <- NA

jp$q8c <-  pkcor(jp$q8, pkcorrect[1])
jp$q9c <-  pkcor(jp$q9, pkcorrect[2])
jp$q10c <- pkcor(jp$q10, pkcorrect[3])
jp$q11c <- pkcor(jp$q11, pkcorrect[4])
jp$q12c <- pkcor(jp$q12, pkcorrect[5])
jp$q13c <- pkcor(jp$q13, pkcorrect[6])
jp$q14c <- pkcor(jp$q14, pkcorrect[7])

jp$t2_know_q19c <-  pkcor(jp$t2_know_q19, pkcorrect[1])
jp$t2_know_q20c <-  pkcor(jp$t2_know_q20, pkcorrect[2])
jp$t2_know_q21c <-  pkcor(jp$t2_know_q21, pkcorrect[3])
jp$t2_know_q22c <-  pkcor(jp$t2_know_q22, pkcorrect[4])
jp$t2_know_q23c <-  pkcor(jp$t2_know_q23, pkcorrect[5])
jp$t2_know_q24c <-  pkcor(jp$t2_know_q24, pkcorrect[6])
jp$t2_know_q25c <-  pkcor(jp$t2_know_q25, pkcorrect[7])

jp$t3_know_q19c <-  pkcor(jp$t3_know_q19, pkcorrect[1])
jp$t3_know_q20c <- pkcor(jp$t3_know_q20, pkcorrect[2])
jp$t3_know_q21c <-  pkcor(jp$t3_know_q21, pkcorrect[3])
jp$t3_know_q22c <-  pkcor(jp$t3_know_q22, pkcorrect[4])
jp$t3_know_q23c <-  pkcor(jp$t3_know_q23, pkcorrect[5])
jp$t3_know_q24c <-  pkcor(jp$t3_know_q24, pkcorrect[6])
jp$t3_know_q25c <-  pkcor(jp$t3_know_q25, pkcorrect[7])

jp$t1know <- rowMeans(jp[,paste0("q", 8:14, "c")])
jp$t2know <- rowMeans(jp[,paste0("t2_know_q", 19:25, "c")])
jp$t3know <- rowMeans(jp[,paste0("t3_know_q", 19:25, "c")])

# Save
save(jp, file=paste0(basedir, "pk/hlm_files/jpk.Rdata"))
