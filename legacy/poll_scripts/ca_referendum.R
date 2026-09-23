#
# California
# Last Edited: 7.28.14   
# Gaurav Sood
# 

# Set Working dir 
setwd(basedir)

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/hlmFunc.R")

# Load Data
ca <- foreign::read.dta("cdd/data/California/data/California_Merged_t1-t2-t3_6-28-11.dta")
names(ca) <- tolower(names(ca))
ca <- subset(ca, !is.na(ca$part))

# Knowledge
#37. Democrats: Which political party holds the majority in the California State Senate, or couldn’t you say about that? (If yes, without naming party, or other) Which party do you have in mind? IF N/A, REFUSED, then 98; IF NO OPINION, then 99.
#38. Democrats: How about the California State Assembly? Do you know which political party holds the majority there, or couldn’t you say about that? (If yes, without naming party, or other) Which party do you have in mind? IF N/A, REFUSED, then 98; IF NO OPINION, then 99.
#39. Two-thirds: How large a majority of the State Legislature is needed to approve a proposed constitutional amendment?a. a simple majority of both houses b. a simple majority of the Assembly and two-thirds of Senate c. two-thirds of both houses d. three-fourths of both houses Or couldn’t you say about that? IF N/A, REFUSED, then 98; IF NO OPINION, then 99.
#40. Two-thirds: How large a majority of the State Legislature is needed to increase taxess? a. a simple majority of both houses b. a simple majority of the Assembly and two-thirds of Senate  c. two-thirds of both houses d. three-fourths of both houses Or couldn’t you say about that?  IF N/A, REFUSED, then 98; IF NO OPINION, then 99.
#41. Anyone Registered in CA: Ballot measures can be signed by… a. anyone over 18 years of age b. any citizen over 18 years of age c. only registered voters  d. only registered voters who voted in last election Or couldn’t you say about that?  IF N/A, REFUSED, then 98; IF NO OPINION, then 99.

# Only in T1
##42. CA: What is the maximum increase in assessed property value when property changes ownership? a. 1%  b. 3%  c. 5%  d. 7%  Or couldn’t you say about that? IF N/A, REFUSED, then 98; IF NO OPINION, then 99.
##43. NY: The majority of revenue for the State’s General Fundcomes from which of the following? a. Personal Income Tax b. Retail sales and use tax c. Corporation Tax  d. Local Income Tax Or couldn’t you say about that?  IF N/A, REFUSED, then 98; IF NO OPINION, then 99.
##44. K12: The largest single share of the State’s General Fund goes to which of the following? a. Higher Education b. K through12 education c. Health and Human Services d. State Pensions Or couldn’t you say about that? IF N/A, REFUSED, then 98; IF NO OPINION, then 99.

# T2 and T3
# 32.Which state has the most residents per member of the state legislature?
# 33.On average, which state has the highest total tax burden?
# 34.In Governor Brown’s most recent budget proposal, the largest single share of spending goes to which of the following?

ca$t1know1raw <- as.numeric(recode(ca$q37, "'Democratic Party' = 1; 'Republican Party' = 0; else = NA"))-1
ca$t1know2raw <- as.numeric(recode(ca$q38, "'Democratic Party' = 1; 'Republican Party' = 0; else = NA"))-1
ca$t1know3raw <- recode(as.numeric(ca$q39), "3 = 1; c(1, 2, 4) = 0")
ca$t1know4raw <- recode(as.numeric(ca$q40), "3 = 1; c(1, 2, 4)=0")
ca$t1know5raw <- recode(as.numeric(ca$q41), "3 = 1; c(1, 2, 4)=0")

ca$t3know1raw <- recode(ca$t3q27, "1 = 1; 2=0; else = NA")
ca$t3know2raw <- recode(ca$t3q28, "1 = 1; c(2, 3) = 0; else = NA")
ca$t3know3raw <- recode(ca$t3q29, "2 = 1; c(1, 3, 4) = 0")
ca$t3know4raw <- recode(ca$t3q30, "2 = 1; c(1, 3, 4) = 0")
ca$t3know5raw <- recode(ca$t3q31, "3 = 1; c(1, 2, 4) = 0")

t1raw <- paste0("t1know", 1:5, "raw")
t3raw <- paste0("t3know", 1:5, "raw")
t1 <- paste0("t1know", 1:5, "c")
t3 <- paste0("t3know", 1:5, "c")
 
ca[, c(t1,t3)] <- nona(ca[, c(t1raw, t3raw)])

ca$t1know <- rowMeans(ca[, t1])
ca$t3know <- rowMeans(ca[, t3])

# Sociodem
ca$edu   <- recode(as.numeric(ca$q58), "c(1, 2) = 0; 3 = .33; 4 = .66; c(5, 6) = 1; 8 = NA")
ca$female <- as.numeric(ca$q73 == "Female")

# Recoding Hispanic
ca$hisp <- as.numeric(ca$q70 == 'Hispanic')

# Policy
# Props
# YGt1 t2/t3 QText
#sec3d  28 s Prop1: Establishing clear goals for each government program and assessing whether progress is being made toward these goals at least once every ten years.
#sec3b    t Prop2: Requiring the Governor and the Legislature to adopt two-year instead of one-year budgets
#sec3h    u Prop3: Requiring the Governor & the Legislature to publish three and five year budget projections prior to the budget vote each year
#sec3l    v Prop4: Transferring from the state to local governments control and financing of services provided at the local level and requiring minimum standards for delivering them 
#sec3o    z Prop5: Requiring state and local governments to identify policy goals and publish their progress toward meeting them
#sec3j 10 aa Prop6: Requiring legislation creating new programs or tax cuts that cost $25 million or more to indicate how they will be paid for

#However, as Jim indicated, we would like the IDM to be tried on all the proposals that changed significantly. My quick count, noted in my previous email, was about 22.

ca$q2r  <- as.numeric(gsub('[^0-9.]', '', ca$q2))
ca$q4r  <- as.numeric(gsub('[^0-9.]', '', ca$q4))
ca$q5r  <- as.numeric(gsub('[^0-9.]', '', ca$q5))
ca$q10r <- as.numeric(gsub('[^0-9.]', '', ca$q10))
ca$q11r <- as.numeric(gsub('[^0-9.]', '', ca$q11))
ca$q28r <- as.numeric(gsub('[^0-9.]', '', ca$q28))

# Midpoint imputation on attitude items as directed by Fishkin/Luskin 
ca$q2r  <- zero1(ifelse(is.na(ca$q2r), 5, ca$q2r))
ca$q4r  <- zero1(ifelse(is.na(ca$q4r), 5, ca$q4r))
ca$q5r  <- zero1(ifelse(is.na(ca$q5r), 5, ca$q5r))
ca$q10r <- zero1(ifelse(is.na(ca$q10r), 5, ca$q10r))
ca$q11r <- zero1(ifelse(is.na(ca$q11r), 5, ca$q11r))
ca$q28r <- zero1(ifelse(is.na(ca$q28r), 5, ca$q28r))

fromt2 <- paste0("t2q2", c("s", "t", "u", "v", "z", "aa"))
fromt3   <- paste0("t3q2", c("s", "t", "u", "v", "z", "aa")) 
tot2 <- paste0("t2q2", c("s", "t", "u", "v", "z", "aa"), "r")
tot3   <- paste0("t3q2", c("s", "t", "u", "v", "z", "aa"), "r") 

#ca[,c(tot2, tot3)]  <- sapply(ca[,c(fromt2, fromt3)], function(x) zero1(ifelse(is.na(x), 5, x)))
ca[, c(tot2, tot3)]  <- sapply(ca[, c(fromt2, fromt3)], function(x) zero1(x, 0, 10))

# Group Means
fromt2 <- paste0("t2q2", c("s", "t", "u", "v", "z", "aa"))
tot2 <- paste0("t2q2", c("s", "t", "u", "v", "z", "aa"), "grp")

ca[, c(tot2)]  <- sapply(ca[, c(fromt2)], function(x) grpfun(x, ca$t3_groupnumber, "mean"))


# Output for IRT
# T2/T3 Filter
ca <- subset(ca, t2t3filter == 1)

#cairt[402:412,t1raw]
cairt <- ca[, c(t1, t3, t1raw, t3raw, "female", "edu")]

# Rows 461 to 471 are shot
write.csv(cairt, file = "guess/data/bypoll/cairt.csv")

# Reproduce mean diff. on the website
# 0.806 0.847
c(mean(ca$t2q2sr, na.rm = T), mean(ca$t3q2sr, na.rm = T))

# 0.617 0.717
c(mean(ca$t2q2tr, na.rm = T), mean(ca$t3q2tr, na.rm = T))

# 0.736 0.777
c(mean(ca$t2q2ur, na.rm = T), mean(ca$t3q2ur, na.rm = T))

# 0.635 0.69
c(mean(ca$t2q2vr, na.rm = T), mean(ca$t3q2vr, na.rm = T))

# 0.811 0.841
c(mean(ca$t2q2zr, na.rm = T), mean(ca$t3q2zr, na.rm = T))

# 0.850 0.851
c(mean(ca$t2q2aar, na.rm = T), mean(ca$t3q2aar, na.rm = T))

# Analyses/Information Driven Model
with(ca, summary(lm(I(t3q2sr - t2q2sr) ~ I(t2q2sr - t2q2sgrp) + t3know)))
with(ca, summary(lm(I(t3q2tr - t2q2tr) ~ I(t2q2tr - t2q2tgrp) + t3know)))
with(ca, summary(lm(I(t3q2ur - t2q2ur) ~ I(t2q2ur - t2q2ugrp) + t3know)))
with(ca, summary(lm(I(t3q2vr - t2q2vr) ~ I(t2q2vr - t2q2vgrp) + t3know)))
with(ca, summary(lm(I(t3q2zr - t2q2zr) ~ I(t2q2zr - t2q2zgrp) + t3know)))
with(ca, summary(lm(I(t3q2aar - t2q2aar) ~ I(t2q2aar - t2q2aagrp) + t3know)))


with(ca, summary(lm(I(t3q2sr - t2q2sr) ~ I(t2q2sr - t2q2sgrp) + I(t3know - t1know))))
with(ca, summary(lm(I(t3q2tr - t2q2tr) ~ I(t2q2tr - t2q2tgrp) + I(t3know - t1know))))
with(ca, summary(lm(I(t3q2ur - t2q2ur) ~ I(t2q2ur - t2q2ugrp) + I(t3know - t1know))))
with(ca, summary(lm(I(t3q2vr - t2q2vr) ~ I(t2q2vr - t2q2vgrp) + I(t3know - t1know))))
with(ca, summary(lm(I(t3q2zr - t2q2zr) ~ I(t2q2zr - t2q2zgrp) + I(t3know - t1know))))
with(ca, summary(lm(I(t3q2aar - t2q2aar) ~ I(t2q2aar - t2q2aagrp) + I(t3know - t1know))))
