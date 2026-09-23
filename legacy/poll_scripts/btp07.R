#
# By the people
# Last Edited: 7.13.14   
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
source("func/match.R")

#btp05 <- foreign::read.dta("cdd/data/BTP/2005/data/2005alice.dta")

# Load data 
btp07 <- foreign::read.spss("cdd/data/BTP/2007/data/final.sav", to.data.frame=T)
names(btp07) <- tolower(names(btp07))
btp07 <- subset(btp07, group == "Discussion treatment")

# Know
# [Q19]  About how many Americans are prevented from voting because of criminal convictions, or couldn't you say about that? <1> 50,000 <2> 500,000 <3> 5,000,000 <4> 15,000,000 <99> Couldn't say
# [Q20]  Does "gerrymandering" reshape districts to...? <1>Increase electoral competition <2>Ensure a majority for one party over another <3>Include independents in the primary process <4>Make them much smaller <99>Couldn't say
# [Q21]  Approximately what percentage of eligible American voters actually vote in a given presidential general election, or couldn't you say about that? <1>10% <2>30% <3>50% <4>70% <99>Couldn't say
# [Q22]  Which of the following countries has a system of "compulsory voting," or couldn't you say about that? #<1>Ireland <2>United Kingdom <3>Australia <4>South Korea <99>Couldn't say
# [Q23]  At present, who must register with the selective service system in the US, or couldn't you say about that? <1>Nobody <2>Men between 18 and 25 years old <3>Both men and women between 18 and 25 years old <4>Men and women who receive federal grants for education <99>Couldn't say
# [Q24]  A candidate is elected President of the United States if he or she... <1>Gets more votes than any other candidate <2>Gets a majority of all the votes cast <3>Gets more Electoral College votes than any other candidate <4>Gets a majority of Electoral College votes <99>Couldn't say
# [Q25]  How often are congressional districts redrawn, or couldn't you say about that? <1>Every 5 years <2>Every 10 years <3>Every 15 years <4>Every 20 years <99>Couldn't say
# [Q26]  Which two states have traditionally had the earliest presidential primary events for determining their delegates to the parties' national conventions, or couldn't you say about that? <1>Nevada and South Carolina <2>Iowa and New Hampshire <3>Indiana and New Mexico <4>Wyoming and Delaware <5>Michigan and Florida <99>Couldn't say

btp07$t1know1raw <- recode(as.numeric(btp07$pre_q19), "3=1;c(1,2,4)=0;5=NA")
btp07$t1know2raw <- recode(as.numeric(btp07$pre_q20), "2=1;c(1,3,4)=0;5=NA")
btp07$t1know3raw <- recode(as.numeric(btp07$pre_q21), "3=1;c(1,2,4)=0;5=NA")
btp07$t1know4raw <- recode(as.numeric(btp07$pre_q22), "3=1;c(1,2,4)=0;5=NA")
btp07$t1know5raw <- recode(as.numeric(btp07$pre_q23), "2=1;c(1,3,4)=0;5=NA")
btp07$t1know6raw <- recode(as.numeric(btp07$pre_q24), "4=1;c(1,2,3)=0;5=NA")
btp07$t1know7raw <- recode(as.numeric(btp07$pre_q25), "2=1;c(1,3,4)=0;5=NA")
btp07$t1know8raw <- recode(as.numeric(btp07$pre_q26), "2=1;c(1,3,4,5)=0;6=NA")

btp07$t3know1raw <- recode(as.numeric(btp07$post_q19), "3=1;c(1,2,4)=0;5=NA")
btp07$t3know2raw <- recode(as.numeric(btp07$post_q20), "2=1;c(1,3,4)=0;5=NA")
btp07$t3know3raw <- recode(as.numeric(btp07$post_q21), "3=1;c(1,2,4)=0;5=NA")
btp07$t3know4raw <- recode(as.numeric(btp07$post_q22), "3=1;c(1,2,4)=0;5=NA")
btp07$t3know5raw <- recode(as.numeric(btp07$post_q23), "2=1;c(1,3,4)=0;5=NA")
btp07$t3know6raw <- recode(as.numeric(btp07$post_q24), "4=1;c(1,2,3)=0;5=NA")
btp07$t3know7raw <- recode(as.numeric(btp07$post_q25), "2=1;c(1,3,4)=0;5=NA")
btp07$t3know8raw <- recode(as.numeric(btp07$post_q26), "2=1;c(1,3,4,5)=0;6=NA")

t1raw <- paste0("t1know", 1:8, "raw")
t3raw <- paste0("t3know", 1:8, "raw")
t1 <- paste0("t1know", 1:8, "c")
t3 <- paste0("t3know", 1:8, "c")
 
btp07[,c(t1,t3)] <- nona(btp07[,c(t1raw, t3raw)])

# mean(rowMeans(btp07[btp07$group == "Reading only treatment",t3] - btp07[btp07$group == "Reading only treatment",t1]))
# mean(rowMeans(btp07[btp07$group == "Control group",t3] - btp07[btp07$group == "Control group",t1]))
 
btp07$edu   <- recode(as.numeric(btp07$educ), "c(1,2)=0; c(3,4)=.33; 5=.66; 6=1")
btp07$female  <- as.numeric(btp07$gender == "Female")

btp07irt <- btp07[, c(t1, t3, t1raw, t3raw, "female", "edu")]

write.csv(btp07irt, file="guess/data/bypoll/btp07irt.csv")
