#
# Add Low/Hi Ed and Low/High Inc. Vars.
#

# setwd
setwd(basedir)

# Load dir
dpdat <- read.csv("cdd/data/agg/polardata.csv")

# Goes from San Mateo to China
# t(table(kyu$educ4, kyu$pollname))/colSums(table(kyu$educ4, kyu$pollname))
# kyu <- subset(kyu, pollname!="China" & pollname!="San Mateo")
# kyu$bettered <- kyu$educ4!=1

dpdat$bettered <- NA
dpdat$bettered[dpdat$pollname == 'Australia Republic Referendum'] <- dpdat$educ4[dpdat$pollname == 'Australia Republic Referendum'] == 1
dpdat$bettered[dpdat$pollname == 'By the People: National']       <- dpdat$educ4[dpdat$pollname == 'By the People: National'] >= .66

dpdat$bettered[dpdat$pollname == 'By the People 2004 US General Election']       <- dpdat$educ4[dpdat$pollname == 'By the People 2004 US General Election'] >= .66
dpdat$bettered[dpdat$pollname == 'By the People 2004 US Presidential Primaries'] <- dpdat$educ4[dpdat$pollname == 'By the People 2004 US Presidential Primaries'] >= .66
dpdat$bettered[dpdat$pollname == 'By the People: Health and Education']          <- dpdat$educ4[dpdat$pollname == 'By the People: Health and Education'] == 1

dpdat$bettered[dpdat$pollname == 'Bulgarian National']           <- dpdat$educ4[dpdat$pollname == 'Bulgarian National'] >= .66
dpdat$bettered[dpdat$pollname == 'Zeguo Township']               <- dpdat$educ4[dpdat$pollname == 'Zeguo Township'] > 0
dpdat$bettered[dpdat$pollname == 'Central Power & Light']        <- dpdat$educ4[dpdat$pollname == 'Central Power & Light'] >= .66
dpdat$bettered[dpdat$pollname == "Tomorrow's Europe (EU)"]       <- dpdat$educ4[dpdat$pollname == "Tomorrow's Europe (EU)"] >= .66
dpdat$bettered[dpdat$pollname == 'New Haven, CT']                <- dpdat$educ4[dpdat$pollname == 'New Haven, CT'] == 1
dpdat$bettered[dpdat$pollname == 'National Issues Convention']   <- dpdat$educ4[dpdat$pollname == 'National Issues Convention'] >= .66
dpdat$bettered[dpdat$pollname == 'National Issues Convention 2'] <- dpdat$educ4[dpdat$pollname == 'National Issues Convention 2'] == 1
dpdat$bettered[dpdat$pollname == 'San Mateo, CA']                <- dpdat$educ4[dpdat$pollname == 'San Mateo, CA'] == 1
dpdat$bettered[dpdat$pollname == 'Southwestern Electric Power']  <- dpdat$educ4[dpdat$pollname == 'Southwestern Electric Power'] >= .66
dpdat$bettered[dpdat$pollname == 'UK Crime']                     <- dpdat$educ4[dpdat$pollname == 'UK Crime'] >= .66
dpdat$bettered[dpdat$pollname == 'UK EU']                        <- dpdat$educ4[dpdat$pollname == 'UK EU'] >= .33
dpdat$bettered[dpdat$pollname == 'UK General Election']          <- dpdat$educ4[dpdat$pollname == 'UK General Election'] >= .33
dpdat$bettered[dpdat$pollname == 'UK Health']                    <- dpdat$educ4[dpdat$pollname == 'UK Health'] >= .66
dpdat$bettered[dpdat$pollname == 'UK Monarchy']                  <- dpdat$educ4[dpdat$pollname == 'UK Monarchy'] >= .33
dpdat$bettered[dpdat$pollname == 'West Texas Utilities']         <- dpdat$educ4[dpdat$pollname == 'West Texas Utilities'] >= .66
dpdat$bettered[dpdat$pollname == 'Europolis']                    <- dpdat$educ4[dpdat$pollname == 'Europolis'] > .57

# Income
# Problems
# Fair bit of missing data. As much as 10%
# Missing entirely on: SWEPCO, WTU, UK Crime, UK EU, UK Monarchy, EU 2007, BTP 2005, 

# cumsum(table(dpdat$hhincome[kyu$pollname == 'AU Monarchy'])/sum(table(dpdat$hhincome[kyu$pollname == 'AU Monarchy'])))

dpdat$highinc <- NA
dpdat$highinc[dpdat$pollname == 'Australia Republic Referendum']               <- dpdat$hhincome[dpdat$pollname == 'Australia Republic Referendum'] > .7
dpdat$highinc[dpdat$pollname == 'By the People: National']                     <- dpdat$hhincome[dpdat$pollname == 'By the People: National'] > 5
dpdat$highinc[dpdat$pollname == 'By the People 2004 US General Election']      <- dpdat$hhincome[dpdat$pollname == 'By the People 2004 US General Election'] > 5
dpdat$highinc[dpdat$pollname == 'By the People 2004 US Presidential Primaries']<- dpdat$hhincome[dpdat$pollname == 'By the People 2004 US Presidential Primaries'] > 11
dpdat$highinc[dpdat$pollname == 'Bulgarian National']                          <- dpdat$hhincome[dpdat$pollname == 'Bulgarian National'] > 2
dpdat$highinc[dpdat$pollname == 'Central Power & Light']                       <- dpdat$hhincome[dpdat$pollname == 'Central Power & Light'] > 4
dpdat$highinc[dpdat$pollname == 'New Haven, CT']                               <- dpdat$hhincome[dpdat$pollname == 'New Haven, CT'] > 5
dpdat$highinc[dpdat$pollname == 'National Issues Convention 2']                <- dpdat$hhincome[dpdat$pollname == 'National Issues Convention 2'] > 6
dpdat$highinc[dpdat$pollname == 'San Mateo, CA']                               <- dpdat$hhincome[dpdat$pollname == 'San Mateo, CA'] > 4
dpdat$highinc[dpdat$pollname == 'UK General Election']                         <- dpdat$hhincome[dpdat$pollname == 'UK General Election'] > 2
dpdat$highinc[dpdat$pollname == 'UK Health']                                   <- dpdat$hhincome[dpdat$pollname == 'UK Health'] > .34

write.csv(dpdat, file = "cdd/data/agg/polardata.csv", row.names = F)
