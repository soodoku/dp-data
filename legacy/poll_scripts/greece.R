# 
# Greece
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
greece<- foreign::read.spss("cdd/data/Greece/data/Greece_data_all_final.sav", to.data.frame=T)
names(greece)<- tolower(names(greece))
greece <- subset(greece, !is.na(greece$group))

## POLL Vars
greece$numindices <- 6
greece$pollid     <- 2000
greece$country    <- 2001
greece$mode       <- 0
greece$numitems   <- 11
greece$caseid     <- 79999 + 1:nrow(greece)
greece$length     <- 2
greece$timebtw    <- NA

## Group
greece$pollgroup <- pgroup(greece$group, greece$pollid)
greece$groupsize <- grpfun(rep(1, nrow(greece)), greece$pollgroup, fun = "sum")

# Knowledge
# #Q1: Current Mayor (Fill in Blank)
#kq1_t1  kq1_t2   kq1_t3 
#   kq2popt1 kq2popt2 kq2popt3
#   kq5pert1 kq5pert2 kq5pert3 
#kq3store kq3stor0 kq3stor1 
#   kq4waste kq4wast0 kq4wast1
#   kq6trant kq6tran0 kq6tran1
#   kq7metro kq7metr0 kq7metr1
#knowt1 knowt3


#Q2: Marousi Population (40,000, 70,000, 100,000, or 130,000)
#Q3: Number of Stores at The Mall (50, 200, 350, or 500)
#Q4: Average waste production per resident (50, 250, 450, or 650 kilos)
#Q5: Percentage of Immigrants in Marousi (%- 5, 10, 15, or 20)
#Q6: Coverage of Municipal Transportation Network (%- 30, 50, 70, or 90)
#Q7: Number of people using the metro line (100,000, 200,000, 300,000 or 400,000)

#2. Left/Right Placement of Parties Questions
#1.Where would you place PASOK? (Left)
# greece$t2q11, greece$t3q11
#2.Where would you place ND? (Right) 
# greece$t2q12, greece$t3q12

# 1. Where would you place: Alexandris (5 – not included), Veloudos (Left), Vlahos (Right), Diakoliou (Left), Karanasou (Left), Bregiannis (Left)
# greece$t2q13_2, greece$t2q13_3, greece$t2q13_4, greece$t2q13_5
# greece$t3q13_2, greece$t3q13_3, greece$t3q13_4, greece$t3q13_5

# Candidate placement on the issue
#Where would you place each candidate of the following issues? 
#1. Some people think that the municipality of Marousi should take the lead in protecting the local environment (left). Others think that protecting the environment should be left to the national government or individual action (right). 
#Alexandris (left), Veloudos (left), Vlahos (midpoint, not included), Diakoliou (left), Karanasou (left), Bregiannis (left)

#2. Some people think that the best way to fight local unemployment is for the Marousi government to hire more people (left). Others think that it is for the Marousi government to promote investment creating jobs in the private sector (right). 
#Alexandris (midpoint, not included), Veloudos (left), Vlahos (right), Diakoliou (left), Karanasou (left), Bregiannis (left)

#3. Some people think that the best way to improve local transportation is for the Marousi govenment to build more and better roads (left). Others think it is for the Marousi  government to invest in more public transportation (right).  
#Alexandris (midpoint, not included), Veloudos (midpoint, not included), Vlahos (midpoint, not included), Diakoliou (left), Karanasou (midpoint, not included), Bregiannis (midpoint, not included)

#4. Some people think that the Marousi  government should help integrate immigrants into the community (left).  Others think that immigrants should just get ahead on their own (right).  
#Alexandris (left), Veloudos (left), Vlahos (left), Diakoliou (left), Karanasou (left), Bregiannis (left)

#t3q5_1, t3q5_2, t3q5_4, t3q5_5, t3q5_6
#t3q6_2, t3q6_3, t3q6_4, t3q6_5, t3q6_6
#t3q7_4, 
#t3q8_1, t3q8_2, t3q8_3, t3q8_4, t3q8_5, t3q8_6

greece$t1know<- greece$knowt1
#greece$t2know <- ifelse(!is.na(greece$knowt2), greece$knowt2, 0)
greece$t2know<- ifelse(!is.na(greece$knowt3), greece$knowt3, 0)
greece$t1knowcor <- greece$t1know - abs(rnorm(nrow(greece), .07, .02))

## Knowledge over the highest quartile is High Knowledge
greece$highknow <- as.numeric((greece$t1know > fivenum(greece$t1know)[4]))

# Group Gain
greece$grpgain  <- NA

# Poll-level Know
greece$t1knowlevel <- mean(greece$t1know)


## Sociodem
## ~~~~~~~~~~~~~~~~~~~~~~~~
greece$female<- as.numeric(greece$gender==0) # from paper
greece$educollege<- greece$educolle
greece$educ4<- car::recode(greece$educ,"8 = NA; c(6, 7) = 1; 5 = .66; 4 = .33; c(1, 2, 3) = 0")
greece$minority<- NA
greece$income<- NA
greece$hhincome<- zero1(car::recode(as.numeric(greece$inc),"9 = NA"))
greece$highinc<- car::recode(as.numeric(greece$inc),"9 = NA; 6 = 1; c(1, 2, 3, 4, 5) = 0") 
greece$ppage<- greece$age

# Polint and Readbrief
greece$t1polint <- NA
greece$readbrief <- NA

## L2 Variable
greece$pminority  <- NA
greece$pfemale  <- grpfun(greece$female, greece$pollgroup, fun = "mean")
greece$varfemale  <- greece$pfemale*(1 - greece$pfemale)
greece$meant1know  <- grpfun(greece$t1know, greece$pollgroup, fun = "mean")
greece$meant1know_ind <- (greece$meant1know*greece$groupsize - greece$t1know )/ (greece$groupsize - 1)
greece$meant2know   <- grpfun(greece$t2know, greece$pollgroup, fun = "mean")
greece$phighknow  <- grpfun(greece$highknow, greece$pollgroup, fun = "mean")
greece$phigheduc  <- grpfun(greece$educollege, greece$pollgroup, fun = "mean")
greece$vareduc  <- grpfun(greece$educ4, greece$pollgroup, fun="var")
greece$phighinc  <- NA

# Attitudes
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Alexandris
greece$t1att1  <- ifelse(is.na(greece$t1tralex), .5, greece$t1tralex/100)
greece$t12att1 <- ifelse(is.na(greece$t2tralex), .5, greece$t2tralex/100)
greece$t2att1  <- ifelse(is.na(greece$t3tralex), .5, greece$t3tralex/100)

#Veloudos  t1trvel t2trvel 
greece$t1att2  <- ifelse(is.na(greece$t1trvel), .5, greece$t1trvel/100)
greece$t12att2 <- ifelse(is.na(greece$t2trvel), .5, greece$t2trvel/100)
greece$t2att2  <- ifelse(is.na(greece$t3trvel), .5, greece$t3trvel/100)

#Vlachost1trvla t2trvla 
greece$t1att3  <- ifelse(is.na(greece$t1trvla), .5, greece$t1trvla/100)
greece$t12att3 <- ifelse(is.na(greece$t2trvla), .5, greece$t2trvla/100)
greece$t2att3  <- ifelse(is.na(greece$t3trvla), .5, greece$t3trvla/100)

#Diakoliout1trdiak t2trdiak
greece$t1att4  <- ifelse(is.na(greece$t1trdiak), .5, greece$t1trdiak/100)
greece$t12att4 <- ifelse(is.na(greece$t2trdiak), .5, greece$t2trdiak/100)
greece$t2att4  <- ifelse(is.na(greece$t3trdiak), .5, greece$t3trdiak/100)

#Karanasout1trkar t2trkar 
greece$t1att5  <- ifelse(is.na(greece$t1trkar), .5, greece$t1trkar/100)
greece$t12att5 <- ifelse(is.na(greece$t2trkar), .5, greece$t2trkar/100)
greece$t2att5  <- ifelse(is.na(greece$t3trkar), .5, greece$t3trkar/100)

#Breyiannist1trbre t2trbre 
greece$t1att6  <- ifelse(is.na(greece$t1trbre), .5, greece$t1trbre/100)
greece$t12att6 <- ifelse(is.na(greece$t2trbre), .5, greece$t2trbre/100)
greece$t2att6  <- ifelse(is.na(greece$t3trbre), .5, greece$t3trbre/100)

# Att. Extreme and Var
greece1 <- greece[,c("t1att1", "t1att2", "t1att3", "t1att4", "t1att5", "t1att6")]
greece2 <- greece[,c("t12att1", "t12att2", "t12att3", "t12att4", "t12att5", "t12att6")]

greece$genvar <- unsplit(lapply(split(greece1, greece$pollgroup), genvar),greece$pollgroup)
greece$attextreme <- rowMeans(abs(greece1 - .5), na.rm = T)
greece$attextreme2 <- rowMeans(abs(greece2 - .5), na.rm = T)

fromlist    <- names(greece1)
tolist      <- paste("var", fromlist, sep = "")
greece[, tolist] <- sapply(greece[, fromlist], function(x) grpfun(x, greece$pollgroup, fun = "var"))

greece$avgsd <- rowMeans(sqrt(greece[, tolist[1:6]]))

# Midterm Measurement
greece[, c("avgsd2", "grpgain2", "t1knowcor2", "t12know", "t12knowcor")] <- NA

# Save File
# PK subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~
greecen <- greece[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw")]

# Save File
save(greecen, file = "cdd/pkdat/greecen.Rdata")

# Kyu subset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~
grkkyu <- greece[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
"t12knowcor", "attextreme2", "length", "timebtw", 
"t1att1", "t1att2", "t1att3", "t1att4", "t1att5", "t1att6", 
"t2att1", "t2att2", "t2att3", "t2att4", "t2att5", "t2att6")]

save(grkkyu, file = "cdd/kyu/bypoll/grkkyu.rdata", ascii = TRUE)
