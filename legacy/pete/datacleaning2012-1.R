# to-do: add JAPAN

##  	Last Edited: 12.30.12   	
##   	pete.mohanty@gmail.com

# builds mohantydata.RData
# combines kyudata with other DPs for
# Consensus and Polarization and Net Change papers
# based ONLY on test group participants

# 1  Australia Referendum       (in kyudata.rdata)
# 2	Bulgaria I                  (in kyudata.rdata)
# 3	China
# 4	Greece
#5	UK Crime                    (in kyudata.rdata)
#6	UK Europe                   (in kyudata.rdata)
#7	UK General Election         (in kyudata.rdata)
#8	UK Health                   (in kyudata.rdata)
#9	UK Monarchy                 (in kyudata.rdata)
#10	US f2f FP NIC II            (in kyudata.rdata)
#11	US Gen Elec (2004)          (in kyudata.rdata)
#12	US New Haven                (in kyudata.rdata)
#13	US online FP NIC I            
#14	US Primaries (Online)       (in kyudata.rdata)  
#15	US Utilities: CPL           (in kyudata.rdata)
#16	US Utilities: SWEPCO
#17	US Utilities: WTU  

setwd("c:/users/pete/dropbox/cdd/2012")
source("hlmFunc.R") # Loading up functions

rescale <- function(original, newmin=0, newmax=1){
  # if original contains NAs, returns as NA  
  zero.one <- (original - min(original, na.rm = TRUE))/(max(original, na.rm = TRUE) - min(original, na.rm = TRUE))
  return((zero.one*(newmax - newmin)) + newmin)
}

by(kyudata$t1knowlevel, kyudata$pollname, unique)

# kyu data (for contents, see above)
load("kyudata.rdata")
master <- kyudata

master$polarization <- ifelse(master$pollname == "UK EU" |
  master$pollname == "UK Monarchy" |
  master$pollname == "UK GE" |
  master$pollname == "AU Monarchy" |
  master$pollname == "UK Crime" |
  master$pollname == "CPL" |
  master$pollname == "Bulgaria" |
  master$pollname == "New Haven" |
  master$pollname == "NIC2" | 
  master$pollname == "UK Health", 1, 0)   # is part of the consensus and polarization paper

master$netchange <- ifelse(master$pollname == "UK EU" |
  master$pollname == "UK Monarchy" |
  master$pollname == "UK GE" |
  master$pollname == "AU Monarchy" |
  master$pollname == "NIC2" | 
  master$pollname == "UK Health" |
  master$pollname == "BTP04Pr" |
  master$pollname == "BTP04ge", 1, 0)   # is part of the net change paper

# 3  China
setwd("C:/Users/pete/Dropbox/cdd/data/China/")
china <- as.data.frame(foreign::read.spss("China Merged Dataset.sav"))
names(china) <- tolower(names(china))
china.test <- subset(china, !is.na(china$group)) # test group participants

tmp <- matrix(ncol=ncol(master), nrow=nrow(china.test), dimnames=list(c(1:250), names(master)))

tmp[,1] <- 52 # poll id
# tmp[,2] <- 52000 + china.test$p # participant id 
tmp[,3] <- 6 # country
tmp[,4] <- 0 # mode = face-to-face
tmp[,7] <- 5200 + china.test$group
i <- 1
for(i in 1:250){
  tmp[i, 8] <-  sum(china.test$group[i]==china.test$group) 
}
tmp[,10] <- 10 
tmp[,13] <- china.test$knowm1
tmp[,19] <- china.test$knowm2
tmp[,286] <- 1
tmp[,287] <- 0
master <- rbind(master, tmp)

# attitudes
# industrial roads
china.t1att1 <- matrix(nrow=nrow(master), ncol=1)
china.t1att1[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(china.test$t1iroads), .5, china.test$t1iroads)
master <- cbind(master, china.t1att1)

china.t2att1 <- matrix(nrow=nrow(master), ncol=1)
china.t2att1[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(china.test$t2iroads), .5, china.test$t2iroads)
master <- cbind(master, china.t2att1)

#village roads
china.t1att2 <- matrix(nrow=nrow(master), ncol=1)
china.t1att2[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(china.test$t1vroads), .5, china.test$t1vroads)
master <- cbind(master, china.t1att2)

china.t2att2 <- matrix(nrow=nrow(master), ncol=1)
china.t2att2[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(china.test$t2vroads), .5, china.test$t2vroads)
master <- cbind(master, china.t2att2)

# main roads
china.t1att3 <- matrix(nrow=nrow(master), ncol=1)
china.t1att3[(nrow(master)-nrow(tmp)+1):nrow(master)] <- china.test$t1mroads
master <- cbind(master, china.t1att3)

china.t2att3 <- matrix(nrow=nrow(master), ncol=1)
china.t2att3[(nrow(master)-nrow(tmp)+1):nrow(master)] <- china.test$t2mroads
master <- cbind(master, china.t2att3)

#commericial roads
china.t1att4 <- matrix(nrow=nrow(master), ncol=1)
china.t1att4[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(china.test$t1croads), .5, china.test$t1croads)
master <- cbind(master, china.t1att4)

china.t2att4 <- matrix(nrow=nrow(master), ncol=1)
china.t2att4[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(china.test$t2croads), .5, china.test$t2croads)
master <- cbind(master, china.t2att4)

#wenchang main ave
china.t1att5 <- matrix(nrow=nrow(master), ncol=1)
china.t1att5[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(china.test$main2t1), 5, china.test$main2t1))
master <- cbind(master, china.t1att5)

china.t2att5 <- matrix(nrow=nrow(master), ncol=1)
china.t2att5[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(china.test$main2t2), 5, china.test$main2t2))
master <- cbind(master, china.t2att5)

#other parks
china.t1att6 <- matrix(nrow=nrow(master), ncol=1)
china.t1att6[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(china.test$oparkt1), 5, china.test$oparkt1))
master <- cbind(master, china.t1att6)

china.t2att6 <- matrix(nrow=nrow(master), ncol=1)
china.t2att6[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(china.test$oparkt2), 5, china.test$oparkt2))
master <- cbind(master, china.t2att6)

china.t1att7 <- matrix(nrow=nrow(master), ncol=1)
china.t1att7[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(china.test$recpark0), 0, china.test$recpark0))
master <- cbind(master, china.t1att7)

china.t2att7 <- matrix(nrow=nrow(master), ncol=1)
china.t2att7[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(china.test$recparks), -3, -china.test$recparks))
master <- cbind(master, china.t2att7)

# township image
china.t1att8 <- matrix(nrow=nrow(master), ncol=1)
china.t1att8[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(china.test$imaget1), .5, china.test$imaget1)
master <- cbind(master, china.t1att8)

china.t2att8 <- matrix(nrow=nrow(master), ncol=1)
china.t2att8[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(china.test$imaget2), .5, china.test$imaget2)
master <- cbind(master, china.t2att8)

#cultural heritage
china.t1att9 <- matrix(nrow=nrow(master), ncol=1)
china.t1att9[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(china.test$t1cvx2), .5, china.test$t1cvx2)
master <- cbind(master, china.t1att9)

china.t2att9 <- matrix(nrow=nrow(master), ncol=1)
china.t2att9[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(china.test$t2cvx2), .5, china.test$t2cvx2)
master <- cbind(master, china.t2att9)


#sewage treatment
china.t1att10 <- matrix(nrow=nrow(master), ncol=1)
china.t1att10[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(china.test$t1sewx2), .5, china.test$t1sewx2)
master <- cbind(master, china.t1att10)

china.t2att10 <- matrix(nrow=nrow(master), ncol=1)
china.t2att10[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(china.test$t2sewx2), .5, china.test$t2sewx2)
master <- cbind(master, china.t2att10)



# 4  Greece
# has knowledge (knowt1, knowt2, knowt3)
# need know how to construct attitudes
# should know poll id and country code
setwd("c:/users/pete/dropbox/cdd/data/greece/data")

greece <- spss("greece_data_all_final.sav")
greece.test <- subset(greece, !is.na(greece$group))
#greece.test <- spss("data_all_final.sav")

tmp <- matrix(ncol=ncol(master), nrow=nrow(greece.test), dimnames=list(c(1:nrow(greece.test)), names(master)))

tmp[,1] <- 2000 # MADE-UP poll id
#tmp[,2] <- greece.test$ar_code # participant id
tmp[,3] <- 2001 #country (made up greece code)
tmp[,4] <- 0 # mode = face-to-face
tmp[,7] <- 200100 + greece.test$group
i <- 1
for(i in 1:nrow(greece.test)){
  tmp[i, 8] <-  sum(greece.test$group[i]==greece.test$group) 
}
tmp[,10] <- 6 #indices
tmp[,13] <- greece.test$knowt1
tmp[,19] <- ifelse(!is.na(greece.test$knowt2), greece.test$knowt2, 0)
tmp[,286] <- 1 # polarization paper
tmp[,287] <- 0 # net change paper
master <- rbind(master, tmp)

#attitudes

#Alexandris
greece.t1att1 <- matrix(nrow=nrow(master), ncol=1)
greece.t1att1[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(greece.test$t1tralex), .5, greece.test$t1tralex/100)
master <- cbind(master, greece.t1att1)

greece.t2att1 <- matrix(nrow=nrow(master), ncol=1)
greece.t2att1[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(greece.test$t2tralex), .5, greece.test$t2tralex/100)
master <- cbind(master, greece.t2att1)

#Veloudos  t1trvel 	t2trvel 
greece.t1att2 <- matrix(nrow=nrow(master), ncol=1)
greece.t1att2[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(greece.test$t1trvel), .5, greece.test$t1trvel/100)
master <- cbind(master, greece.t1att2)

greece.t2att2 <- matrix(nrow=nrow(master), ncol=1)
greece.t2att2[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(greece.test$t2trvel), .5, greece.test$t2trvel/100)
master <- cbind(master, greece.t2att2)


#Vlachos	t1trvla 	t2trvla 
greece.t1att3 <- matrix(nrow=nrow(master), ncol=1)
greece.t1att3[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(greece.test$t1trvla), .5, greece.test$t1trvla/100)
master <- cbind(master, greece.t1att3)

greece.t2att3 <- matrix(nrow=nrow(master), ncol=1)
greece.t2att3[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(greece.test$t2trvla), .5, greece.test$t2trvla/100)
master <- cbind(master, greece.t2att3)


#Diakoliou	t1trdiak 	t2trdiak
greece.t1att4 <- matrix(nrow=nrow(master), ncol=1)
greece.t1att4[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(greece.test$t1trdiak), .5, greece.test$t1trdiak/100)
master <- cbind(master, greece.t1att4)

greece.t2att4 <- matrix(nrow=nrow(master), ncol=1)
greece.t2att4[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(greece.test$t2trdiak), .5, greece.test$t2trdiak/100)
master <- cbind(master, greece.t2att4)


#Karanasou	t1trkar 	t2trkar 
greece.t1att5 <- matrix(nrow=nrow(master), ncol=1)
greece.t1att5[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(greece.test$t1trkar), .5, greece.test$t1trkar/100)
master <- cbind(master, greece.t1att5)

greece.t2att5 <- matrix(nrow=nrow(master), ncol=1)
greece.t2att5[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(greece.test$t2trkar), .5, greece.test$t2trkar/100)
master <- cbind(master, greece.t2att5)


#Breyiannis	t1trbre 	t2trbre 
greece.t1att6 <- matrix(nrow=nrow(master), ncol=1)
greece.t1att6[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(greece.test$t1trbre), .5, greece.test$t1trbre/100)
master <- cbind(master, greece.t1att6)

greece.t2att6 <- matrix(nrow=nrow(master), ncol=1)
greece.t2att6[(nrow(master)-nrow(tmp)+1):nrow(master)] <- ifelse(is.na(greece.test$t2trbre), .5, greece.test$t2trbre/100)
master <- cbind(master, greece.t2att6)



#13 NIC I            
setwd("c:/users/pete/Dropbox/cdd/")
nic1 <- spss("nic123_r.sav")

nic1.test <- subset(nic1, nic1$part==1)

#knowledge indices given by nic1$know1, know2, know3

tmp <- matrix(ncol=ncol(master), nrow=nrow(nic1.test), dimnames=list(c(1:nrow(nic1.test)), names(master)))

tmp[,1] <- 1001 # MADE-UP poll id for country 1
#tmp[,2] <- nic1.test$caseid # participant id
tmp[,3] <- 1 #country 
tmp[,4] <- 1 # mode = online
tmp[,7] <- 100100 + nic1.test$rgroup2
i <- 1
for(i in 1:nrow(nic1.test)){
  tmp[i, 8] <-  sum(nic1.test$group[i]==nic1.test$group) 
}
tmp[,10] <- 6 #indices
tmp[,13] <- nic1.test$know1
tmp[,19] <- ifelse(!is.na(nic1.test$know2), nic1.test$know2, 0)
tmp[,286] <- 1 # polarization paper
tmp[,287] <- 1 # net change paper
master <- rbind(master, tmp)

# draft says 7 indices for CP paper
# unclear which...
# using 9 spending variables (could use 11 foreign policy Qs)


#environment
t1 <- nic1.test$spenvir1
t2 <- nic1.test$spenvir2

nic1.t1att1 <- matrix(nrow=nrow(master), ncol=1)
nic1.t1att1[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t1) | t1>4, 2, t1))
master <- cbind(master, nic1.t1att1)

nic1.t2att1 <- matrix(nrow=nrow(master), ncol=1)
nic1.t2att1[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t2) | t2>4, 2, t2))
master <- cbind(master, nic1.t2att1)


#medicare/medicaid
t1 <- nic1.test$spmedic1
t2 <- nic1.test$spmedic2

nic1.t1att2 <- matrix(nrow=nrow(master), ncol=1)
nic1.t1att2[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t1) | t1>4, 2, t1))
master <- cbind(master, nic1.t1att2)

nic1.t2att2 <- matrix(nrow=nrow(master), ncol=1)
nic1.t2att2[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t2) | t2>4, 2, t2))
master <- cbind(master, nic1.t2att2)


# law enforcement
t1 <- nic1.test$splaw1
t2 <- nic1.test$splaw2

nic1.t1att3 <- matrix(nrow=nrow(master), ncol=1)
nic1.t1att3[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t1) | t1>4, 2, t1))
master <- cbind(master, nic1.t1att3)

nic1.t2att3 <- matrix(nrow=nrow(master), ncol=1)
nic1.t2att3[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t2) | t2>4, 2, t2))
master <- cbind(master, nic1.t2att3)

# drug rehab
t1 <- nic1.test$spdrug1
t2 <- nic1.test$spdrug2

nic1.t1att4 <- matrix(nrow=nrow(master), ncol=1)
nic1.t1att4[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t1) | t1>4, 2, t1))
master <- cbind(master, nic1.t1att4)

nic1.t2att4 <- matrix(nrow=nrow(master), ncol=1)
nic1.t2att4[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t2) | t2>4, 2, t2))
master <- cbind(master, nic1.t2att4)

#education
t1 <- nic1.test$speduc1
t2 <- nic1.test$speduc2

nic1.t1att5 <- matrix(nrow=nrow(master), ncol=1)
nic1.t1att5[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t1) | t1>4, 2, t1))
master <- cbind(master, nic1.t1att5)

nic1.t2att5 <- matrix(nrow=nrow(master), ncol=1)
nic1.t2att5[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t2) | t2>4, 2, t2))
master <- cbind(master, nic1.t2att5)

#national defense
t1 <- nic1.test$spdef1
t2 <- nic1.test$spdef2

nic1.t1att6 <- matrix(nrow=nrow(master), ncol=1)
nic1.t1att6[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t1) | t1>4, 2, t1))
master <- cbind(master, nic1.t1att6)

nic1.t2att6 <- matrix(nrow=nrow(master), ncol=1)
nic1.t2att6[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t2) | t2>4, 2, t2))
master <- cbind(master, nic1.t2att6)

#foreign aid
t1 <- nic1.test$spfaid1
t2 <- nic1.test$spfaid2

nic1.t1att7 <- matrix(nrow=nrow(master), ncol=1)
nic1.t1att7[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t1) | t1>4, 2, t1))
master <- cbind(master, nic1.t1att7)

nic1.t2att7 <- matrix(nrow=nrow(master), ncol=1)
nic1.t2att7[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t2) | t2>4, 2, t2))
master <- cbind(master, nic1.t2att7)

# welfare
t1 <- nic1.test$spwelf1
t2 <- nic1.test$spwelf2

nic1.t1att8 <- matrix(nrow=nrow(master), ncol=1)
nic1.t1att8[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t1) | t1>4, 2, t1))
master <- cbind(master, nic1.t1att8)

nic1.t2att8 <- matrix(nrow=nrow(master), ncol=1)
nic1.t2att8[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t2) | t2>4, 2, t2))
master <- cbind(master, nic1.t2att8)

# social security
t1 <- nic1.test$spss1
t2 <- nic1.test$spss2

nic1.t1att9 <- matrix(nrow=nrow(master), ncol=1)
nic1.t1att9[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t1) | t1>4, 2, t1))
master <- cbind(master, nic1.t1att9)

nic1.t2att9 <- matrix(nrow=nrow(master), ncol=1)
nic1.t2att9[(nrow(master)-nrow(tmp)+1):nrow(master)] <- rescale(ifelse(is.na(t2) | t2>4, 2, t2))
master <- cbind(master, nic1.t2att9)

# constructing utilities indices to match CPL indices found in kyudata
# cross-referencing (Luskin, Fishkin and Plane, 1999, p16)
# see http://cdd.stanford.edu/research/papers/2000/utility_paper.pdf

setwd("c:/users/pete/dropbox/cdd/data/utilites/cpl/cpl_data/")
cpl <- foreign::read.dta("cpl2.dta")
cpl.test <- subset(cpl, cpl$PART==1)

setwd("c:/users/pete/dropbox/cdd/data/utilites/swepco/swepco_data")
swepco <- foreign::read.dta("swepco2.dta")
swepco.test <- subset(swepco, swepco$PART==1)

setwd("c:/users/pete/dropbox/cdd/data/utilites/wt/wt_data/")
wtu <- foreign::read.dta("wt2.dta")
wtu.test <- subset(wtu, wtu$PART==1)

#1 buying / importing power 
# Importance: Importing Power
cpl.t1att1 <- rescale(ifelse(is.na(cpl.test$BUYPWR1), 5, cpl.test$BUYPWR1))
cpl.t2att1 <- rescale(ifelse(is.na(cpl.test$BUYPWR2), 5, cpl.test$BUYPWR2))

wtu.t1att1 <- rescale(ifelse(is.na(wtu.test$BUYPWR1), 5, wtu.test$BUYPWR1))
wtu.t2att1 <- rescale(ifelse(is.na(wtu.test$BUYPWR2), 5, wtu.test$BUYPWR2))

swepco.t1att1 <- rescale(ifelse(is.na(swepco.test$BUYPWR1), 5, swepco.test$BUYPWR1))
swepco.t2att1 <- rescale(ifelse(is.na(swepco.test$BUYPWR2), 5, swepco.test$BUYPWR2))


#2 benefits of competition
# Benefits of competition over regulation (Q20a)

cpl.t1att2 <- rescale(ifelse(is.na(cpl.test$COMPET1), 5, cpl.test$COMPET1))
cpl.t2att2 <- rescale(ifelse(is.na(cpl.test$COMPET2), 5, cpl.test$COMPET2))

wtu.t1att2 <- rescale(ifelse(is.na(wtu.test$COMPET1), 5, wtu.test$COMPET1))
wtu.t2att2 <- rescale(ifelse(is.na(wtu.test$COMPET2), 5, wtu.test$COMPET2))

swepco.t1att2 <- rescale(ifelse(is.na(swepco.test$COMPET1), 5, swepco.test$COMPET1))
swepco.t2att2 <- rescale(ifelse(is.na(swepco.test$COMPET2), 5, swepco.test$COMPET2))

#3 conservation
# ADDFAC1 is "Importance: Reduce Need for Plants" 
# REDUCE1 is  "Importance: Reduce Fuel Use" 

tmp <- rescale(rowMeans(cbind(cpl.test$ADDFAC1, cpl.test$REDUCE1), na.rm=TRUE))
cpl.t1att3 <- ifelse(is.na(tmp), .5, tmp)
tmp <- rescale(rowMeans(cbind(cpl.test$ADDFAC2, cpl.test$REDUCE2), na.rm=TRUE))
cpl.t2att3 <- ifelse(is.na(tmp), .5, tmp)

tmp <- rescale(rowMeans(cbind(wtu.test$ADDFAC1, wtu.test$REDUCE1), na.rm=TRUE))
wtu.t1att3 <- ifelse(is.na(tmp), .5, tmp)
tmp <- rescale(rowMeans(cbind(wtu.test$ADDFAC2, wtu.test$REDUCE2), na.rm=TRUE))
wtu.t2att3 <- ifelse(is.na(tmp), .5, tmp)

tmp <- rescale(rowMeans(cbind(swepco.test$ADDFAC1, swepco.test$REDUCE1), na.rm=TRUE))
swepco.t1att3 <- ifelse(is.na(tmp), .5, tmp)
tmp <- rescale(rowMeans(cbind(swepco.test$ADDFAC2, swepco.test$REDUCE2), na.rm=TRUE))
swepco.t2att3 <- ifelse(is.na(tmp), .5, tmp)

#4 Ensure Equity; Basic Needs Met
# needto2  = Tradeoff:  Basic needs met vs. increased costs T2 (Q3c)
# "cpl.t1poor"

cpl.t1att4 <- rescale(ifelse(is.na(cpl.test$NEEDTO1), 5, cpl.test$NEEDTO1))
cpl.t2att4 <- rescale(ifelse(is.na(cpl.test$NEEDTO2), 5, cpl.test$NEEDTO2))

wtu.t1att4 <- rescale(ifelse(is.na(wtu.test$NEEDTO1), 5, wtu.test$NEEDTO1))
wtu.t2att4 <- rescale(ifelse(is.na(wtu.test$NEEDTO2), 5, wtu.test$NEEDTO2))

swepco.t1att4 <- rescale(ifelse(is.na(swepco.test$NEEDTO1), 5, swepco.test$NEEDTO1))
swepco.t2att4 <- rescale(ifelse(is.na(swepco.test$NEEDTO2), 5, swepco.test$NEEDTO2))

#5  "cpl.t1renew"                     
# Importance: Using Renewables
# Importance: Using Wind/Solar

tmp <- rescale(rowMeans(cbind(cpl.test$RENEW1, cpl.test$WIND1), na.rm=TRUE))
cpl.t1att5 <- ifelse(is.na(tmp), .5, tmp)
tmp <- rescale(rowMeans(cbind(cpl.test$RENEW2, cpl.test$WIND2), na.rm=TRUE))
cpl.t2att5 <- ifelse(is.na(tmp), .5, tmp)

tmp <- rescale(rowMeans(cbind(wtu.test$RENEW1, wtu.test$WIND1), na.rm=TRUE))
wtu.t1att5 <- ifelse(is.na(tmp), .5, tmp)
tmp <- rescale(rowMeans(cbind(wtu.test$RENEW2, wtu.test$WIND2), na.rm=TRUE))
wtu.t2att5 <- ifelse(is.na(tmp), .5, tmp)

tmp <- rescale(rowMeans(cbind(swepco.test$RENEW1, swepco.test$WIND1), na.rm=TRUE))
swepco.t1att5 <- ifelse(is.na(tmp), .5, tmp)
tmp <- rescale(rowMeans(cbind(swepco.test$RENEW2, swepco.test$WIND2), na.rm=TRUE))
swepco.t2att5 <- ifelse(is.na(tmp), .5, tmp)


# 6 reseach on efficiency
# resch1   = Research even if higher electric rates T1 (Q2a)
# fedrch1  = Federal government fund research for new technology T1 (Q2b)


tmp <- rowMeans(cbind(cpl.test$FEDRCH1, cpl.test$RESCH1), na.rm=TRUE)
cpl.t1att6 <- ifelse(is.na(tmp), 5, tmp)
tmp <- rowMeans(cbind(cpl.test$FEDRCH2, cpl.test$RESCH2), na.rm=TRUE)
cpl.t2att6 <- rescale(ifelse(is.na(tmp), 5, tmp))

tmp <- rowMeans(cbind(wtu.test$FEDRCH1, wtu.test$RESCH1), na.rm=TRUE)
wtu.t1att6 <- ifelse(is.na(tmp), 5, tmp)
tmp <- rowMeans(cbind(wtu.test$FEDRCH2, wtu.test$RESCH2), na.rm=TRUE)
wtu.t2att6 <- rescale(ifelse(is.na(tmp), 5, tmp))

tmp <- rowMeans(cbind(swepco.test$FEDRCH1, swepco.test$RESCH1), na.rm=TRUE)
swepco.t1att6 <- ifelse(is.na(tmp), 5, tmp)
tmp <- rowMeans(cbind(swepco.test$FEDRCH2, swepco.test$RESCH2), na.rm=TRUE)
swepco.t2att6 <- rescale(ifelse(is.na(tmp), 5, tmp))


# 7 "cpl.t1fossil"    
# cpl.test$FUELS1 goes in it

cpl.t1att7 <- rescale(ifelse(is.na(cpl.test$FUELS1), 5, cpl.test$FUELS1))
cpl.t2att7 <- rescale(ifelse(is.na(cpl.test$FUELS2), 5, cpl.test$FUELS2))

wtu.t1att7 <- rescale(ifelse(is.na(wtu.test$FUELS1), 5, wtu.test$FUELS1))
wtu.t2att7 <- rescale(ifelse(is.na(wtu.test$FUELS2), 5, wtu.test$FUELS2))

swepco.t1att7 <- rescale(ifelse(is.na(swepco.test$FUELS1), 5, swepco.test$FUELS1))
swepco.t2att7 <- rescale(ifelse(is.na(swepco.test$FUELS2), 5, swepco.test$FUELS2))

# cpl starts at row 1992 and ends at 2207

# need decide how to handle missing data inside of kyudata indices
# probably go through, look at the relevant subset, and then just set NA to midpoint for all indices
# possible to write loop - step through pollname, grab chunck of data
# for cpl could use above indices but not for others


#16  US Utilities: SWEPCO
swepco.knowt1 <- rowMeans(cbind(swepco.test$KNOWA1, swepco.test$KNOWB1, swepco.test$KNOWC1, swepco.test$KNOWD1, swepco.test$KNOWE1))
swepco.knowt2 <- rowMeans(cbind(swepco.test$KNOWA2, swepco.test$KNOWB2, swepco.test$KNOWC2, swepco.test$KNOWD2, swepco.test$KNOWE2))
# these knowledge indices match what's presented in "Deliberative Polling and Policy Outcomes: Electric Utility Issues in Texas"

tmp <- matrix(ncol=ncol(master), nrow=nrow(swepco.test), dimnames=list(c(1:nrow(swepco.test)), names(master)))

tmp[,1] <- 1002 # MADE-UP poll id
#tmp[,2] <- swepco.test$CASEID # participant id
tmp[,3] <- 1 #country 
tmp[,4] <- 0 # mode = face-to-face
tmp[,7] <- swepco.test$GROUP
i <- 1
for(i in 1:nrow(swepco.test)){
  tmp[i, 8] <-  sum(swepco.test$GROUP[i]==swepco.test$GROUP) 
}
tmp[,10] <- 7 #indices
tmp[,13] <- swepco.knowt1
tmp[,19] <- swepco.knowt2
tmp[,286] <- 1 # polarization paper
tmp[,287] <- 0 # net change paper
master <- rbind(master, tmp)

# ATTITUDES
tmp <- matrix(nrow=(nrow(master)-nrow(swepco.test)))
swepco.t1att1 <- c(tmp, swepco.t1att1)
master <- cbind(master, swepco.t1att1) 

swepco.t2att1 <- c(tmp, swepco.t2att1)
master <- cbind(master, swepco.t2att1) 

swepco.t1att2 <- c(tmp, swepco.t1att2)
master <- cbind(master, swepco.t1att2) 

swepco.t2att2 <- c(tmp, swepco.t2att2)
master <- cbind(master, swepco.t2att2)

swepco.t1att3 <- c(tmp, swepco.t1att3)
master <- cbind(master, swepco.t1att3) 

swepco.t2att3 <- c(tmp, swepco.t2att3)
master <- cbind(master, swepco.t2att3)

swepco.t1att4 <- c(tmp, swepco.t1att4)
master <- cbind(master, swepco.t1att4) 

swepco.t2att4 <- c(tmp, swepco.t2att4)
master <- cbind(master, swepco.t2att4)

swepco.t1att5 <- c(tmp, swepco.t1att5)
master <- cbind(master, swepco.t1att5) 

swepco.t2att5 <- c(tmp, swepco.t2att5)
master <- cbind(master, swepco.t2att5)

swepco.t1att6 <- c(tmp, swepco.t1att6)
master <- cbind(master, swepco.t1att6) 

swepco.t2att6 <- c(tmp, swepco.t2att6)
master <- cbind(master, swepco.t2att6)

swepco.t1att7 <- c(tmp, swepco.t1att7)
master <- cbind(master, swepco.t1att7) 

swepco.t2att7 <- c(tmp, swepco.t2att7)
master <- cbind(master, swepco.t2att7)

#17	US Utilities: WTU  
wtu.knowt1 <- rowMeans(cbind(wtu.test$KNOWA1, wtu.test$KNOWB1, wtu.test$KNOWC1, wtu.test$KNOWD1, wtu.test$KNOWE1))
wtu.knowt2 <- rowMeans(cbind(wtu.test$KNOWA2, wtu.test$KNOWB2, wtu.test$KNOWC2, wtu.test$KNOWD2, wtu.test$KNOWE2))
# these knowledge indices match what's presented in "Deliberative Polling and Policy Outcomes: Electric Utility Issues in Texas"


tmp <- matrix(ncol=ncol(master), nrow=nrow(wtu.test), dimnames=list(c(1:nrow(wtu.test)), names(master)))

tmp[,1] <- 1003 # MADE-UP poll id
#tmp[,2] <- wtu.test$CASEID # participant id
tmp[,3] <- 1 #country 
tmp[,4] <- 0 # mode = face-to-face
tmp[,7] <- wtu.test$GROUP
i <- 1
for(i in 1:nrow(wtu.test)){
  tmp[i, 8] <-  sum(wtu.test$GROUP[i]==wtu.test$GROUP) 
}
tmp[,10] <- 7 #indices
tmp[,13] <- wtu.knowt1
tmp[,19] <- wtu.knowt2
tmp[,286] <- 1 # polarization paper
tmp[,287] <- 0 # net change paper
master <- rbind(master, tmp)

# ATTITUDES
tmp <- matrix(nrow=(nrow(master)-nrow(wtu.test)))
wtu.t1att1 <- c(tmp, wtu.t1att1)
master <- cbind(master, wtu.t1att1) 

wtu.t2att1 <- c(tmp, wtu.t2att1)
master <- cbind(master, wtu.t2att1) 

wtu.t1att2 <- c(tmp, wtu.t1att2)
master <- cbind(master, wtu.t1att2) 

wtu.t2att2 <- c(tmp, wtu.t2att2)
master <- cbind(master, wtu.t2att2) 

wtu.t1att3 <- c(tmp, wtu.t1att3)
master <- cbind(master, wtu.t1att3) 

wtu.t2att3 <- c(tmp, wtu.t2att3)
master <- cbind(master, wtu.t2att3)

wtu.t1att4 <- c(tmp, wtu.t1att4)
master <- cbind(master, wtu.t1att4) 

wtu.t2att4 <- c(tmp, wtu.t2att4)
master <- cbind(master, wtu.t2att4)

wtu.t1att5 <- c(tmp, wtu.t1att5)
master <- cbind(master, wtu.t1att5) 

wtu.t2att5 <- c(tmp, wtu.t2att5)
master <- cbind(master, wtu.t2att5)

wtu.t1att6 <- c(tmp, wtu.t1att6)
master <- cbind(master, wtu.t1att6) 

wtu.t2att6 <- c(tmp, wtu.t2att6)
master <- cbind(master, wtu.t2att6) 

wtu.t1att7 <- c(tmp, wtu.t1att7)
master <- cbind(master, wtu.t1att7) 

wtu.t2att7 <- c(tmp, wtu.t2att7)
master <- cbind(master, wtu.t2att7) 


#18 Japan
setwd("c:/users/pete/dropbox/cdd/data/Japan/")
load("t2t3jp.rdata")

japan <- foreign::read.dta("jpt2t3indices.dta")
  
tmp <- matrix(ncol=ncol(master), nrow=nrow(t2t3jp), dimnames=list(c(1:nrow(t2t3jp)), names(master)))

tmp[,1] <- 5001 # MADE-UP poll id
#tmp[,2] < wtu.test$CASEID # participant id
tmp[,3] <- 50 #country 
tmp[,4] <- 0 # mode = face-to-face
tmp[,7] <- wtu.test$GROUP
i <- 1
for(i in 1:nrow(wtu.test)){
  tmp[i, 8] <-  sum(wtu.test$GROUP[i]==wtu.test$GROUP) 
}
tmp[,10] <- 7 #indices
tmp[,13] <- wtu.knowt1
tmp[,19] <- wtu.knowt2
tmp[,286] <- 1 # polarization paper
tmp[,287] <- 0 # net change paper
master <- rbind(master, tmp)

# ATTITUDES
tmp <- matrix(nrow=(nrow(master)-nrow(wtu.test)))
wtu.t1att1 <- c(tmp, wtu.t1att1)
master <- cbind(master, wtu.t1att1) 

wtu.t2att1 <- c(tmp, wtu.t2att1)
master <- cbind(master, wtu.t2att1) 

wtu.t1att2 <- c(tmp, wtu.t1att2)
master <- cbind(master, wtu.t1att2) 

wtu.t2att2 <- c(tmp, wtu.t2att2)
master <- cbind(master, wtu.t2att2) 














master$pollname <- factor(master$pollid, levels=unique(master$pollid), 
                          labels=c("UK EU", "UK Health", "UK Monarchy", "UK GE", 
                                   "AU Monarchy", "UK Crime", "EU", "CPL", "Bulgaria",    
                            "New Haven", "NIC 2", "BTP 2003", "BTP 2004 GE",  "BTP 2004 Pr.", 
                                   "San Mateo", "BTP 2005", "china", "greece",      
                            "nic1", "swepco", "wtu"))

master$caseid <- c(1:nrow(as.matrix(master)))

save(master, file="c:/users/pete/dropbox/cdd/data/mohantydata.RData")

# UK EU, UK Health, UK Monarchy, UK GE, AU Monarchy, UK Crime, EU, CPL, Bulgaria    
# New Haven, NIC 2, BTP 2003, BTP 2004 GE,  BTP 2004 Pr., San Mateo, BTP 2005, china, greece      
#nic1, swepco, wtu 



