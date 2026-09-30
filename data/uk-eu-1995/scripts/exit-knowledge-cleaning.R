##Notes
#From Dataset -> Europe_2
#PK Variables - T1 - pk11, pk21, pk31, pk41, pk51, pktot1; T2 -  pk12, pk22, pk32, pk42, pk52, pktot2cor [Missing converted to zero]
#Filter = (part ==1)
#Group Variable - group
#Att. indices - eurelat1, euscope1, commies1, favref1 (For Creation of these indices - look at the do files by Alice)

##############
##UK_EU _Clean_7/15/09
##############

library(foreign)
ukeu <- read.spss("data/CDD/UK-EU/uk-eu.sav", use.value.labels = FALSE)
ukeu <- as.data.frame(ukeu)
names(ukeu) <- tolower(names(ukeu))
save(ukeu, file="data/CDD/UK-EU/Clean/ukeu_clean.Rdata", ascii=TRUE)

#Load File

load("data/CDD/UK-EU/Clean/ukeu_clean.Rdata")

##Check to see that there is no missing on factual items. Assign missing to 0.

##Missing in pktot2 - so recoding NAs to 0 and then mean

ukeu[ukeu$part ==1,]$pk12[is.na(ukeu[ukeu$part ==1,]$pk12)] <- 0
ukeu[ukeu$part ==1,]$pk22[is.na(ukeu[ukeu$part ==1,]$pk22)] <- 0
ukeu[ukeu$part ==1,]$pk32[is.na(ukeu[ukeu$part ==1,]$pk32)] <- 0
ukeu[ukeu$part ==1,]$pk42[is.na(ukeu[ukeu$part ==1,]$pk42)] <- 0
ukeu[ukeu$part ==1,]$pk52[is.na(ukeu[ukeu$part ==1,]$pk52)] <- 0

ukeu$pktot2cor <- NA 
ukeu[ukeu$part ==1,]$pktot2cor <- rowMeans(cbind(ukeu[ukeu$part ==1,]$pk12, ukeu[ukeu$part ==1,]$pk22, ukeu[ukeu$part ==1,]$pk32, ukeu[ukeu$part ==1,]$pk42, ukeu[ukeu$part ==1,]$pk52))

save(ukeu, file="data/CDD/UK-EU/Clean/ukeu_clean.Rdata", ascii=TRUE)
