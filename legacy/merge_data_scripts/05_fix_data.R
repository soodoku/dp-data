#
# Fix DP Data  	
#

# setwd
setwd(basedir)

# Load dir
library(goji)

# Load data
dpdat <- read.csv("cdd/data/agg/kyudata.csv")

# Att. Indices
# 0 to 1 coding issue
# ~~~~~~~~~~~~~~~~~
# UKHealth
dpdat$ukhealth.t1severi <- zero1(dpdat$ukhealth.t1severi)
dpdat$ukhealth.t2severi <- zero1(dpdat$ukhealth.t2severi)

# WTU 
dpdat$wtu.t1att6 <- zero1(dpdat$wtu.t1att6)
	
# SWEPCO
dpdat$swp.t1att6 <- zero1(dpdat$swp.t1att6)

# Chi
dpdat$chi.t1att2 <- ifelse(dpdat$chi.t1att2 > 1, NA, dpdat$chi.t1att2)

# Check max
# Load secondary data on attitude indices 
metadata <- read.csv("cdd/meta_data/attitude_indices/AllPollIndices.csv")
max(sapply(dpdat[,as.character(metadata$t1var)], max, na.rm = T))
max(sapply(dpdat[,as.character(metadata$t2_t3var)], max, na.rm = T))

# New Labels for the Polls
dpdat$pollname[dpdat$pollname == "UK GE"]        <- "UK General Election"
dpdat$pollname[dpdat$pollname == "AU Monarchy"]  <- "Australia Republic Referendum"
dpdat$pollname[dpdat$pollname == "EU"]           <- "Tomorrow's Europe (EU)"
dpdat$pollname[dpdat$pollname == "CPL"]          <- "Central Power & Light"
dpdat$pollname[dpdat$pollname == "WTU"]          <- "West Texas Utilities"
dpdat$pollname[dpdat$pollname == "SWEPCO"]       <- "Southwestern Electric Power"
dpdat$pollname[dpdat$pollname == "Bulgaria"]     <- "Bulgarian National"
dpdat$pollname[dpdat$pollname == "New Haven"]    <- "New Haven, CT"
dpdat$pollname[dpdat$pollname == "NIC 1"]        <- "National Issues Convention"
dpdat$pollname[dpdat$pollname == "NIC 2"]        <- "National Issues Convention 2"
dpdat$pollname[dpdat$pollname == "China"]        <- "Zeguo Township"
dpdat$pollname[dpdat$pollname == "San Mateo"]    <- "San Mateo, CA"
dpdat$pollname[dpdat$pollname == "BTP 2004 GE"]  <- "By the People 2004 US General Election"
dpdat$pollname[dpdat$pollname == "BTP 2004 Pr."] <- "By the People 2004 US Presidential Primaries"
dpdat$pollname[dpdat$pollname == "BTP 2003"]     <- "By the People: National"
dpdat$pollname[dpdat$pollname == "BTP 2005"]     <- "By the People: Health and Education"
dpdat$pollname[dpdat$pollname == "EU 2009"]      <- "Europolis"

# Take out Greece
dpdat <- subset(dpdat, pollname!="Greece")

# Take out empirical premises etc.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Bulgarian National: Wrongful Conviction
names(dpdat)[grep("bul.", names(dpdat))]
#dpdat <- dpdat[,-c("")]

# CPL, SWEPCO, and WTU: Competition is Good
# names(dpdat)[grep("cpl.", names(dpdat))]; see codebook/scripts for swp and wtu
dpdat <- subset(dpdat, select = -c(cpl.t1compet, cpl.t2compet, swp.t1att2, swp.t2att2, wtu.t1att2, wtu.t2att2))

# San Mateo:
# Attract jobs v. Restrict commuters; Increase public consultation; Housing issue: County level v. state-level
dpdat <- subset(dpdat, select = -c(sm.t1lesscommute, sm.t2lesscommute, sm.t1consult, sm.t2consult, sm.t1countys, sm.t2countys))

# Australia
dpdat <- subset(dpdat, select = -c(aus.autind1, aus.workind1, aus.demind1, aus.tradind1, aus.polind1, aus.autind2, aus.workind2, aus.demind2, aus.tradind2, aus.polind2))

# UK Health
#22,UK Health,11,Doctors Discretion,ukhealth.t1avgdis,ukhealth.t2avgdis
#22,UK Health,11,Patients have more say,ukhealth.t1moresa,ukhealth.t2moresa

# We also need to fix no. of indices vector
# UK Health down to 9
# Australia 2
# CPL, SWEPCO, WTU

# China has only 9 indices because I couldn't replicate 'Recreational Parks' index

# I have vetted stuff till the utilities


# DP Numbering/Bob's Latest Time Wasting Proposal
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dpdat$dpnum <- NA
dpdat$dpnum[dpdat$pollname == "Australia Republic Referendum"] <- 5
dpdat$dpnum[dpdat$pollname == "Bulgarian National"] <- 10
dpdat$dpnum[dpdat$pollname == "By the People 2004 US General Election"] <- 15
dpdat$dpnum[dpdat$pollname == "By the People 2004 US Presidential Primaries"] <- 16
dpdat$dpnum[dpdat$pollname == "By the People: Health and Education"] <- 18
dpdat$dpnum[dpdat$pollname == "By the People: National"] <- 14
dpdat$dpnum[dpdat$pollname == "Central Power & Light"] <- 8
dpdat$dpnum[dpdat$pollname == "Europolis"] <- 11
dpdat$dpnum[dpdat$pollname == "National Issues Convention"] <- 20
dpdat$dpnum[dpdat$pollname == "National Issues Convention 2"] <- 13
dpdat$dpnum[dpdat$pollname == "New Haven, CT"] <- 12
dpdat$dpnum[dpdat$pollname == "San Mateo, CA"] <- 17
dpdat$dpnum[dpdat$pollname == "Southwestern Electric Power"] <- 21
dpdat$dpnum[dpdat$pollname == "Tomorrow's Europe (EU)"] <- 7
dpdat$dpnum[dpdat$pollname == "UK Crime"] <- 6
dpdat$dpnum[dpdat$pollname == "UK EU"] <- 1
dpdat$dpnum[dpdat$pollname == "UK General Election"] <- 4
dpdat$dpnum[dpdat$pollname == "UK Health"] <- 2
dpdat$dpnum[dpdat$pollname == "UK Monarchy"] <- 3
dpdat$dpnum[dpdat$pollname == "West Texas Utilities"] <- 19
dpdat$dpnum[dpdat$pollname == "Zeguo Township"] <- 9

# Write Results
write.csv(dpdat, file = "cdd/data/agg/polardata.csv", row.names = F)
