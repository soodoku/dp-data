##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~---++
##   ##
##      US Foreign Policy
##Last Edited: 5.23.14   
##   Gaurav Sood##
##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~---++

# Set Working dir.
setwd(basedir)
	
# Sourcing libs 
library(goji)
library(car)

# Sourcing common functions
source("func/func.R")
source("cdd/hlmFunc.R")

# Load data
usfp <- foreign::read.dta("cdd/data/US FP Online/online_data/Jennifer_online_March14.dta")

# Knowledge
# ~~~~~~~~~~~~
#t1 know
usfp$t1kn2<- recode(usfp$qb26, "")
usfp$t1kn3<- recode(usfp$qb18, "")
usfp$t1kn4<- recode(usfp$qb40, "")
usfp$t1kn5<- recode(usfp$qb41, "")
usfp$t1kn6<- recode(usfp$qb42, "")
usfp$t1kn7<- recode(usfp$qb43, "")
usfp$t1kn8<- recode(usfp$qb44, "")
usfp$t1kn9<- recode(usfp$qb45, "")
usfp$t1kn11<- recode(usfp$qb12, "")

gen kn2=1 if qb26==1&part_t1==1
replace kn2=0 if qb26~=1&part_t1==1

gen kn3=1 if qb18==2&part_t1==1
replace kn3=0 if qb18~=2&part_t1==1

gen kn4=1 if qb40==4&part_t1==1
replace kn4=0 if qb40~=4&part_t1==1

gen kn5=1 if qb41==1&part_t1==1
replace kn5=0 if qb41~=1&part_t1==1

gen kn6=1 if qb42==3&part_t1==1
replace kn6=0 if qb42~=3&part_t1==1

gen kn7=1 if qb43==4&part_t1==1
replace kn7=0 if qb43~=4&part_t1==1

gen kn8=1 if qb44==2&part_t1==1
replace kn8=0 if qb44~=2&part_t1==1

gen kn9=1 if qb45==1&part_t1==1
replace kn9=0 if qb45~=1&part_t1==1

gen kn11=1 if qb12==1&part_t1==1
replace kn11=0 if qb12~=1&part_t1==1



gen t2kn2=1 if qaid3==1&t2part==1
replace t2kn2=0 if qaid3~=1&t2part==1

gen t2kn3=1 if qwrm5==3&t2part==1
replace t2kn3=0 if qwrm5~=3&t2part==1

gen t2kn4=1 if qkno1_a==4&t2part==1
replace t2kn4=0 if qkno1_a~=4&t2part==1

gen t2kn5=1 if qkno1_b==1&t2part==1
replace t2kn5=0 if qkno1_b~=1&t2part==1

gen t2kn6=1 if qkno2_a==3&t2part==1
replace t2kn6=0 if qkno2_a~=3&t2part==1

gen t2kn7=1 if qkno2_b==4&t2part==1
replace t2kn7=0 if qkno2_b~=4&t2part==1

gen t2kn8=1 if qkno3_a==5&t2part==1
replace t2kn8=0 if qkno3_a~=5&t2part==1

gen t2kn9=1 if qkno3_b==1&t2part==1
replace t2kn9=0 if qkno3_b~=1&t2part==1

gen t2kn11=1 if qwrm1_b==1&t2part==1
replace t2kn11=0 if qwrm1_b~=1&t2part==1

# Output for pk
# Agg indices
t1raw <- c(paste0("t1q", 14:18, "raw"), "t1q4raw", "t1q5raw", "t1q7raw", "t1q8raw")
t3raw <- c(paste0("t3q", 38:42, "raw"), paste0("t3q", c(10,11,13,14), "raw"))

t1 <- c(paste0("t1q", 14:18, "c"), "t1q4c", "t1q5c", "t1q7c", "t1q8c")
t3 <- c(paste0("t3q", 38:42, "c"), paste0("t3q", c(10,11,13,14), "c"))

usfp[,t1] <- nona(usfp[,t1raw])
usfp[,t3] <- nona(usfp[,t3raw])

usfpirt <- usfp[usfp$t1part==1 & usfp$t2part==1, c(t1, t3, t1raw, t3raw, "female")]

write.csv(usfpirt, file="guess/data/bypoll/usfpirt.csv")



