setwd("C:/Users/pete/Dropbox/cdd/data/China/")
china <- as.data.frame(foreign::read.spss("China Merged Dataset.sav"))

# use t2: china05$t2know from rdata and t1: china$KNOWM1 to be consistent with 
# JAMES S. FISHKIN, BAOGANG HE, ROBERT C. LUSKIN AND ALICE SIU*
# Deliberative Democracy in an Unlikely Place: Deliberative Polling in China

setwd("c:/users/pete/dropbox/cdd/data/Utilites/cpl/cpl_data")
cpl <- foreign::read.dta("cpl2.dta")


setwd("c:/users/pete/dropbox/cdd/data/Utilites/swepco/swepco_data")
swepco <- foreign::read.dta("swepco2.dta")

setwd("c:/users/pete/dropbox/cdd/data/Utilites/wt/wt_data")
wtu <- foreign::read.dta("wt2.dta")
