#
# By the people 2005
# Last Edited: 7.14.14   
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
btp05 <- foreign::read.dta("cdd/data/BTP/2005/data/btp05_hlm.dta")

# Q15: Where does the US rank among wealthy industrialized nations in the math skills of students? In the top 3 out of 29 countries In the top 10 out of 29 countries In the bottom 10 out of 29 countries In the bottom 3 out of 29 countries Couldn't say
# Q16. Has it become harder or easier in the last few years for foreign workers to get work permits to work legally in the US? harder staying about the same easier Couldn't say
# Q17. Has the gap between minority students and white students in math and reading tests at the elementary school level been …? increasing the last few years staying about the same decreasing the last few years Couldn't say
# Q26. About how many Americans are uninsured? 1 million 25 million 45 million 65 million 85 million Couldn't say
# Q27. Over the next fifty years, do you think the number of Americans over age 65 will…? stay about the same increase by about half double triple Couldn't say
# Q28. What percentage of the uninsured do you think come from low income families? a quarter fifty per cent two thirds ninety per cent Couldn't say

# Know
btp05$t1know1raw <- recode(as.numeric(btp05$q15),   "2=1;c(1,3,4)=0;5=NA")
btp05$t1know2raw <- recode(as.numeric(btp05$q16),   "1=1;c(2,3)=0;4=NA")
btp05$t1know3raw <- recode(as.numeric(btp05$q17),   "1=1;c(2,3)=0;4=NA")
btp05$t1know4raw <- recode(as.numeric(btp05$q26),   "3=1;c(1,2,4,5)=0;6=NA")
btp05$t1know5raw <- recode(as.numeric(btp05$q27),   "3=1;c(1,2,4)=0;5=NA")
btp05$t1know6raw <- recode(as.numeric(btp05$q28),   "3=1;c(1,2,4)=0;5=NA")

btp05$t3know1raw <- recode(as.numeric(btp05$q15post),   "2=1;c(1,3,4)=0;5=NA")
btp05$t3know2raw <- recode(as.numeric(btp05$q16post),   "1=1;c(2,3)=0;4=NA")
btp05$t3know3raw <- recode(as.numeric(btp05$q17post),   "1=1;c(2,3)=0;4=NA")
btp05$t3know4raw <- recode(as.numeric(btp05$q26post),   "3=1;c(1,2,4,5)=0;6=NA")
btp05$t3know5raw <- recode(as.numeric(btp05$q27post),   "3=1;c(1,2,4)=0;5=NA")
btp05$t3know6raw <- recode(as.numeric(btp05$q28post),   "3=1;c(1,2,4)=0;5=NA")

t1raw <- paste0("t1know", 1:6, "raw")
t3raw <- paste0("t3know", 1:6, "raw")
t1 <- paste0("t1know", 1:6, "c")
t3 <- paste0("t3know", 1:6, "c")
 
btp05[,c(t1,t3)] <- nona(btp05[,c(t1raw, t3raw)])

# Compared it w/ t1know and t2know, it matches

btp05$edu   <- recode(as.numeric(btp05$educ), "c(1,2)=0; c(3,4)=.33; 5=.66; 6=1")

btp05irt <- btp05[, c(t1, t3, t1raw, t3raw, "female", "edu")]

write.csv(btp05irt, file="guess/data/bypoll/btp05irt.csv")
