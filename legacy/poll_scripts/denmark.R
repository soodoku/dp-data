#
#  Denmark
#  Last Edited: 9.03.13   
#  Gaurav Sood
#

# Set Working dir 
setwd(basedir)

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/hlmFunc.R") 

# Load data
load("cdd/data/Denmark/data/t3denmark.rdata")

## Knowledge
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# pg 121 in the thesis
#As a member of the monetary union Denmark could be fined if the national fiscal deficit is too large (Yes)
den$t0pk1 <- den$t0s_18 == 1 #34
den$t1pk1 <- den$t1s4_1 == 1 #71
den$t2pk1 <- den$t2s4_2 == 1 #80
den$t3pk1 <- den$t3s15_3 == 1 #82

#Denmark can decide its own interest rates if we join the monetary union (No)
den$t0pk2 <- den$t0s_19 == 2 #72
den$t1pk2 <- den$t1s5_1 == 2 #78
den$t2pk2 <- den$t2s5_2 == 2 #82
den$t3pk2 <- den$t3s16_3 == 2 #83

#Denmark can decide its own rates of taxation if we join the single currency (Yes)
den$t0pk3 <- den$t0s_20 == 1 #59
den$t1pk3 <- den$t1s6_1 == 1 #66
den$t2pk3 <- den$t2s6_2 == 1 #83
den$t3pk3 <- den$t3s17_3 == 1 #75

#If we vote yes at the referendum on September 28, the single currency will enter into circulation starting in 2001,
#2004, 2005, or 2007 (2004)
den$t0pk4 <- den$t0s_21 == 2 #48
den$t1pk4 <- den$t1s7_1 == 2 #83
den$t2pk4 <- den$t2s7_2 == 2 #89
den$t3pk4 <- den$t3s18_3 == 2 #88

#If Denmark joins the single currency, the Danish National Bank will be closed down, continue to operate as now,
#or become part of the European Central Bank (become part of ECB)
den$t0pk5 <- den$t0s_22 == 3 #56
den$t1pk5 <- den$t1s8_1 == 3 #55
den$t2pk5 <- den$t2s8_2 == 3 #66
den$t3pk5 <- den$t3s19_3 == 3 #68

#Will the euro coins have a national side (Yes)
den$t0pk6 <- den$t0s_23 == 1 #49
den$t1pk6 <- den$t1s9_1 == 1 #91
den$t2pk6 <- den$t2s9_2 == 1 #94
den$t3pk6 <- den$t3s20_3 == 1 #92

#Is Denmark already involved in a monetary union where the member states help each other in situations of an
#unstable foreign exchange market (Yes)
den$t0pk7 <- den$t0s_24 == 1 #73
den$t1pk7 <- den$t1s10_1 == 1 #78
den$t2pk7 <- den$t2s10_2 == 1 #87
den$t3pk7 <- den$t3s21_3 == 1 #88

### Party Placement
#Movement against the European Union (against)
den$t0ppk1 <- den$t0s_25_01 == 2  #92
den$t1ppk1 <- den$t1s11_1_1 == 2
den$t2ppk1 <- den$t2s11_1_2 == 2
den$t3ppk1 <- den$t3s22_1_3 == 2

#June Movement (against)
den$t0ppk2 <- den$t0s_25_02 == 2  #87
den$t1ppk2 <- den$t1s11_2_1 == 2
den$t2ppk2 <- den$t2s11_2_2 == 2
den$t3ppk2 <- den$t3s22_2_3 == 2

#Social Democrats (for)
den$t0ppk3 <- den$t0s_25_03 == 1  #94
den$t1ppk3 <- den$t1s11_3_1 == 1
den$t2ppk3 <- den$t2s11_3_2 == 1
den$t3ppk3 <- den$t3s22_3_3 == 1

#Social Liberals (for)
den$t0ppk4 <- den$t0s_25_04 == 1  #84
den$t1ppk4 <- den$t1s11_4_1 == 1
den$t2ppk4 <- den$t2s11_4_2 == 1
den$t3ppk4 <- den$t3s22_4_3 == 1

#Conservative Party (for)
den$t0ppk5 <- den$t0s_25_05 == 1 #86
den$t1ppk5 <- den$t1s11_5_1 == 1
den$t2ppk5 <- den$t2s11_5_2 == 1
den$t3ppk5 <- den$t3s22_5_3 == 1

#Center Democrats (for)
den$t0ppk6 <- den$t0s_25_06 == 1 #75
den$t1ppk6 <- den$t1s11_6_1 == 1
den$t2ppk6 <- den$t2s11_6_2 == 1
den$t3ppk6 <- den$t3s22_6_3 == 1

#Socialist People's Party (against)
den$t0ppk7 <- den$t0s_25_07 == 2 #68
den$t1ppk7 <- den$t1s11_7_1 == 2
den$t2ppk7 <- den$t2s11_7_2 == 2
den$t3ppk7 <- den$t3s22_7_3 == 2

#Danish People's Party (against)
den$t0ppk8 <- den$t0s_25_08 == 2 #87
den$t1ppk8 <- den$t1s11_8_1 == 2
den$t2ppk8 <- den$t2s11_8_2 == 2
den$t3ppk8 <- den$t3s22_8_3 == 2

#Christian People's Party (against)
den$t0ppk9 <- den$t0s_25_09 == 2 #41
den$t1ppk9 <- den$t1s11_9_1 == 2
den$t2ppk9 <- den$t2s11_9_2 == 2
den$t3ppk9 <- den$t3s22_9_3 == 2

#Liberal Party (for)
den$t0ppk10 <- den$t0s_25_10 == 1 #92
den$t1ppk10 <- den$t1s11_10_1 == 1
den$t2ppk10 <- den$t2s11_10_2 == 1
den$t3ppk10 <- den$t3s22_10_3 == 1

#Progress Party (against)
den$t0ppk11 <- den$t0s_25_11  ==  2 #70
den$t1ppk11 <- den$t1s11_11_1  ==  2
den$t2ppk11 <- den$t2s11_11_2  ==  2
den$t3ppk11 <- den$t3s22_11_3  ==  2

#Unity Party (against)
den$t0ppk12 <- den$t0s_25_12 == 2 #80
den$t1ppk12 <- den$t1s11_12_1 == 2
den$t2ppk12 <- den$t2s11_12_2 == 2
den$t3ppk12 <- den$t3s22_12_3 == 2

#Freedom 2000 (against)
den$t0ppk13 <- den$t0s_25_13 == 2 #65
den$t1ppk13 <- den$t1s11_13_1 == 2
den$t2ppk13 <- den$t2s11_13_2 == 2
den$t3ppk13 <- den$t3s22_13_3 == 2

# Just Party Placement Knowledge
den$t0refpk  <- with(den, rowMeans(cbind(t0pk1, t0pk2, t0pk3, t0pk4, t0pk5, t0pk6, t0pk7), na.rm = T))
den$t1refpk  <- with(den, rowMeans(cbind(t1pk1, t1pk2, t1pk3, t1pk4, t1pk5, t1pk6, t1pk7), na.rm = T))
den$t2refpk  <- with(den, rowMeans(cbind(t2pk1, t2pk2, t2pk3, t2pk4, t2pk5, t2pk6, t2pk7), na.rm = T))
den$t3refpk  <- with(den, rowMeans(cbind(t3pk1, t3pk2, t3pk3, t3pk4, t3pk5, t3pk6, t3pk7), na.rm = T))

# Just Party Placement Knowledge
den$t0partpk <- with(den, rowMeans(cbind(t0ppk1, t0ppk2, t0ppk3, t0ppk4, t0ppk5, t0ppk6, t0ppk7, t0ppk8, t0ppk9, t0ppk10, t0ppk11, t0ppk12, t0ppk13), na.rm = T))
den$t1partpk <- with(den, rowMeans(cbind(t1ppk1, t1ppk2, t1ppk3, t1ppk4, t1ppk5, t1ppk6, t1ppk7, t1ppk8, t1ppk9, t1ppk10, t1ppk11, t1ppk12, t1ppk13), na.rm = T))
den$t2partpk <- with(den, rowMeans(cbind(t2ppk1, t2ppk2, t2ppk3, t2ppk4, t2ppk5, t2ppk6, t2ppk7, t2ppk8, t2ppk9, t2ppk10, t2ppk11, t2ppk12, t2ppk13), na.rm = T))
den$t3partpk <- with(den, rowMeans(cbind(t3ppk1, t3ppk2, t3ppk3, t3ppk4, t3ppk5, t3ppk6, t3ppk7, t3ppk8, t3ppk9, t3ppk10, t3ppk11, t3ppk12, t3ppk13), na.rm = T))

# Mean PK
den$t0know <- with(den, rowMeans(cbind(t0pk1, t0pk2, t0pk3, t0pk4, t0pk5, t0pk6, t0pk7, t0ppk1, t0ppk2, t0ppk3, t0ppk4, t0ppk5, t0ppk6, t0ppk7, t0ppk8, t0ppk9, t0ppk10, t0ppk11, t0ppk12, t0ppk13), na.rm = T))
den$t1know <- with(den, rowMeans(cbind(t1pk1, t1pk2, t1pk3, t1pk4, t1pk5, t1pk6, t1pk7, t1ppk1, t1ppk2, t1ppk3, t1ppk4, t1ppk5, t1ppk6, t1ppk7, t1ppk8, t1ppk9, t1ppk10, t1ppk11, t1ppk12, t1ppk13), na.rm = T))
den$t2know <- with(den, rowMeans(cbind(t2pk1, t2pk2, t2pk3, t2pk4, t2pk5, t2pk6, t2pk7, t2ppk1, t2ppk2, t2ppk3, t2ppk4, t2ppk5, t2ppk6, t2ppk7, t2ppk8, t2ppk9, t2ppk10, t2ppk11, t2ppk12, t2ppk13), na.rm = T))
den$t3know <- with(den, rowMeans(cbind(t3pk1, t3pk2, t3pk3, t3pk4, t3pk5, t3pk6, t3pk7, t3ppk1, t3ppk2, t3ppk3, t3ppk4, t3ppk5, t3ppk6, t3ppk7, t3ppk8, t3ppk9, t3ppk10, t3ppk11, t3ppk12, t3ppk13), na.rm = T))

# Vote for the Euro or Against it
temp <- paste(den$t0s_15, den$t0s_15b, sep = "")
den$vote <- recode(den$t0s_15, "1 = 1; c(2,3,4,5) = 0")
den$vote[temp == '51'] <- 1

# Sociodem
names(den)[(names(den) == "t0s_01")] <- "sex"
den$female <- as.numeric(den$sex == 2)   #1 = Male, 2 = Female

den$age <- 2000 - den$t0s_02

names(den)[(names(den) == "t0s_12")] <- "ppeduc"
#den$age <- 2000 - den$yrborn

# Participant Var
#den$t1part
#den$t2part
#den$t3part

# Save File
save(den, file = "cdd/data/Denmark/den.rdata")

# Guess Out
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
load("cdd/data/Denmark/den.rdata")

den$t0pk1raw <- recode(den$t0s_18, "2 = 0; 3 = NA")
den$t0pk2raw <- recode(den$t0s_19, "1 = 0; 2 = 1; 3 = NA") 
den$t0pk3raw <- recode(den$t0s_20, "2 = 0; 3 = NA")
den$t0pk4raw <- recode(den$t0s_21, "c(1, 3, 4) = 0; 2 = 1; 5 = NA") 
den$t0pk5raw <- recode(den$t0s_22, "c(1, 2) = 0; 3 = 1; 4 = NA")
den$t0pk6raw <- recode(den$t0s_23, "2 = 0; 3 = NA")
den$t0pk7raw <- recode(den$t0s_24, "2 = 0; 3 = NA")

den$t0ppk1raw <- recode(den$t0s_25_01, "1 = 0; 2 = 1; 3 = NA")
den$t0ppk2raw <- recode(den$t0s_25_02, "1 = 0; 2 = 1; 3 = NA")
den$t0ppk3raw <- recode(den$t0s_25_03, "2 = 0; 3 = NA")
den$t0ppk4raw <- recode(den$t0s_25_04, "2 = 0; 3 = NA")
den$t0ppk5raw <- recode(den$t0s_25_05, "2 = 0; 3 = NA")
den$t0ppk6raw <- recode(den$t0s_25_06, "2 = 0; 3 = NA")
den$t0ppk7raw <- recode(den$t0s_25_07, "1 = 0; 2 = 1; 3 = NA")
den$t0ppk8raw <- recode(den$t0s_25_08, "1 = 0; 2 = 1; 3 = NA")
den$t0ppk9raw <- recode(den$t0s_25_09, "1 = 0; 2 = 1; 3 = NA")
den$t0ppk10raw <- recode(den$t0s_25_10, "2 = 0; 3 = NA")
den$t0ppk11raw <- recode(den$t0s_25_11, "1 = 0; 2 = 1; 3 = NA")
den$t0ppk12raw <- recode(den$t0s_25_12, "1 = 0; 2 = 1; 3 = NA")
den$t0ppk13raw <- recode(den$t0s_25_13, "1 = 0; 2 = 1; 3 = NA")

den$t2pk1raw <- recode(den$t2s4_2, "2 = 0; 3 = NA")
den$t2pk2raw <- recode(den$t2s5_2, "1 = 0; 2 = 1; 3 = NA") 
den$t2pk3raw <- recode(den$t2s6_2, "2 = 0; 3 = NA")
den$t2pk4raw <- recode(den$t2s7_2, "c(1, 3, 4) = 0; 2 = 1; 5 = NA") 
den$t2pk5raw <- recode(den$t2s8_2, "c(1, 2) = 0; 3 = 1; 4 = NA")
den$t2pk6raw <- recode(den$t2s9_2, "2 = 0; 3 = NA")
den$t2pk7raw <- recode(den$t2s10_2, "2 = 0; 3 = NA")

den$t2ppk1raw <- recode(den$t2s11_1_2, "1 = 0; 2 = 1; 3 = NA")
den$t2ppk2raw <- recode(den$t2s11_2_2, "1 = 0; 2 = 1; 3 = NA")
den$t2ppk3raw <- recode(den$t2s11_3_2, "2 = 0; 3 = NA")
den$t2ppk4raw <- recode(den$t2s11_4_2, "2 = 0; 3 = NA")
den$t2ppk5raw <- recode(den$t2s11_5_2, "2 = 0; 3 = NA")
den$t2ppk6raw <- recode(den$t2s11_6_2, "2 = 0; 3 = NA")
den$t2ppk7raw <- recode(den$t2s11_7_2, "1 = 0; 2 = 1; 3 = NA")
den$t2ppk8raw <- recode(den$t2s11_8_2, "1 = 0; 2 = 1; 3 = NA")
den$t2ppk9raw <- recode(den$t2s11_9_2, "1 = 0; 2 = 1; 3 = NA")
den$t2ppk10raw <- recode(den$t2s11_10_2, "2 = 0; 3 = NA")
den$t2ppk11raw <- recode(den$t2s11_11_2, "1 = 0; 2 = 1; 3 = NA")
den$t2ppk12raw <- recode(den$t2s11_12_2, "1 = 0; 2 = 1; 3 = NA")
den$t2ppk13raw <- recode(den$t2s11_13_2, "1 = 0; 2 = 1; 3 = NA")

den[, c(paste0("t0pk", 1:7), paste0("t0ppk", 1:13))] <- sapply(den[, c(paste0("t0pk", 1:7), paste0("t0ppk", 1:13))], function(x) nona(x))
den[, c(paste0("t2pk", 1:7),paste0("t2ppk", 1:13))]  <- sapply(den[, c(paste0("t0pk", 1:7), paste0("t2ppk", 1:13))], function(x) nona(x))

dkpk <- c(paste0("t0pk", 1:7), paste0("t0ppk", 1:13),
  paste0("t2pk", 1:7), paste0("t2ppk", 1:13),
  paste0(c(paste0("t0pk", 1:7), paste0("t0ppk", 1:13),
  paste0("t2pk", 1:7), paste0("t2ppk", 1:13)), "raw"),
  "t1know", "t2know", "age", "female")

dkp <- subset(den, !is.na(t2part))
dkirt <- dkp[, dkpk]
write.csv(dkirt, file = "guess/data/dkirt.csv")
