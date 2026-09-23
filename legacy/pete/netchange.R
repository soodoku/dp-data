#load("c:/users/pete/dropbox/cdd/data/mohantydata.rdata")

load("cdd/kyu/kyudata.rdata")
master <- kyudata
attach(master)

make.netchange.data <- function(t1att, t2att, poll, FP){

  t1att <- ifelse(is.na(t1att), .5, t1att)
  t2att <- ifelse(is.na(t2att), .5, t2att)
  
  net.change <- abs(by(subset(t2att, pollname==poll), subset(pollgroup, pollname==poll), mean) - 
             by(subset(t1att, pollname==poll), subset(pollgroup, pollname==poll), mean))
  salience.T1PK <- mean(subset(t1know, pollname==poll))  
  salience.T1PK.by.group <- by(subset(t1know, pollname==poll), subset(pollgroup, pollname==poll), mean)
  diversity <- by(subset(t1att, pollname==poll), subset(pollgroup, pollname==poll), sd)
  extremity <- abs(.5 - by(subset(t1att, pollname==poll), subset(pollgroup, pollname==poll), mean))
  online <- unique(ifelse(subset(mode, pollname==poll) == 1, 1, 0))
  US <- unique(ifelse(subset(country, pollname==poll) == 1, 1, 0))
  country <- unique(subset(country, pollname==poll))
  
  return(cbind(net.change, salience.T1PK, diversity, extremity, online, US, FP, country, salience.T1PK.by.group))
}  


# UK EU, UK Health, UK Monarchy, UK GE, AU Monarchy, UK Crime, EU, CPL, Bulgaria    
# New Haven, NIC 2, BTP 2003, BTP 2004 GE,  BTP 2004 Pr., San Mateo, BTP 2005, china, greece      
#nic1, swepco, wtu

netchange <- make.netchange.data(aus.autind1, aus.autind2, poll="AU Monarchy", 0)  
netchange <- rbind(netchange, make.netchange.data(aus.demind1, aus.demind2, "AU Monarchy", 0))
netchange <- rbind(netchange, make.netchange.data(aus.polind1, aus.polind2, "AU Monarchy", 0))
netchange <- rbind(netchange, make.netchange.data(aus.tradind1, aus.tradind2, "AU Monarchy", 0))
netchange <- rbind(netchange, make.netchange.data(aus.workind1, aus.workind2, "AU Monarchy", 0))
netchange <- rbind(netchange, make.netchange.data(aus.polind1, aus.polind2, "AU Monarchy", 0))

netchange <- rbind(netchange, make.netchange.data(ukeu.commies1r, ukeu.commies2r, "UK EU", 1))
netchange <- rbind(netchange, make.netchange.data(ukeu.eurelat1g, ukeu.eurelat2g, "UK EU", 1))
netchange <- rbind(netchange, make.netchange.data(ukeu.euscope1g, ukeu.euscope2g, "UK EU", 1))
netchange <- rbind(netchange, make.netchange.data(ukeu.favref1r, ukeu.favref2r, "UK EU", 1))

netchange <- rbind(netchange, make.netchange.data(ukbge.t1eu, ukbge.t2eu, "UK GE", 1))
netchange <- rbind(netchange, make.netchange.data(ukbge.t1tax, ukbge.t2tax, "UK GE", 0))
netchange <- rbind(netchange, make.netchange.data(ukbge.t1redist, ukbge.t2redist, "UK GE", 0))
netchange <- rbind(netchange, make.netchange.data(ukbge.t1wage, ukbge.t1wage, "UK GE", 0))

netchange <- rbind(netchange, make.netchange.data(ukhealth.t1avgdis, ukhealth.t2avgdis, "UK Health", 0))
netchange <- rbind(netchange, make.netchange.data(ukhealth.t1ctexpt, ukhealth.t2ctexpt, "UK Health", 0))
netchange <- rbind(netchange, make.netchange.data(ukhealth.t1dispub, ukhealth.t2dispub, "UK Health", 0))
netchange <- rbind(netchange, make.netchange.data(ukhealth.t1hlthfu, ukhealth.t2hlthfu, "UK Health", 0))
netchange <- rbind(netchange, make.netchange.data(ukhealth.t1moresa, ukhealth.t2moresa, "UK Health", 0))
netchange <- rbind(netchange, make.netchange.data(ukhealth.t1option, ukhealth.t2option, "UK Health", 0))
netchange <- rbind(netchange, make.netchange.data(ukhealth.t1payhlt, ukhealth.t2payhlt, "UK Health", 0))
netchange <- rbind(netchange, make.netchange.data(ukhealth.t1poora, ukhealth.t2poora, "UK Health", 0))
netchange <- rbind(netchange, make.netchange.data(ukhealth.t1preven, ukhealth.t2preven, "UK Health", 0))
netchange <- rbind(netchange, make.netchange.data(ukhealth.t1pritre, ukhealth.t2pritre, "UK Health", 0))
netchange <- rbind(netchange, make.netchange.data(ukhealth.t1severi, ukhealth.t2severi, "UK Health", 0))

netchange <- rbind(netchange, make.netchange.data(ukmonarchy.t1mpop, ukmonarchy.t2mpop, "UK Monarchy", 0))
netchange <- rbind(netchange, make.netchange.data(ukmonarchy.t1pwrm, ukmonarchy.t2pwrm, "UK Monarchy", 0))
netchange <- rbind(netchange, make.netchange.data(ukmonarchy.t1reflor, ukmonarchy.t2reflor, "UK Monarchy", 0))
netchange <- rbind(netchange, make.netchange.data(ukmonarchy.t1supmon, ukmonarchy.t2supmon, "UK Monarchy", 0))

netchange <- rbind(netchange, make.netchange.data(btp04.w4b42, btp04.w4f42, "BTP 2004 GE", 0)) # services
netchange <- rbind(netchange, make.netchange.data(btp04.w4b45, btp04.w4f45, "BTP 2004 GE", 1)) # UN / NATO
netchange <- rbind(netchange, make.netchange.data(btp04.w4b48, btp04.w4f48, "BTP 2004 GE", 1)) # free trade v protectionism
netchange <- rbind(netchange, make.netchange.data(btp04.w4b51, btp04.w4f51, "BTP 2004 GE", 0)) # security v rights of accused terrorists (no mention of foreign terrorists)
netchange <- rbind(netchange, make.netchange.data(btp04.w4b54, btp04.w4f54, "BTP 2004 GE", 0)) # healthcare 
netchange <- rbind(netchange, make.netchange.data(btp04.w4b57, btp04.w4f57, "BTP 2004 GE", 0)) # gay marriage

netchange <- rbind(netchange, make.netchange.data(nic1.t1att1, nic1.t2att1, "nic1", 1))
netchange <- rbind(netchange, make.netchange.data(nic1.t1att2, nic1.t2att2, "nic1", 1))
netchange <- rbind(netchange, make.netchange.data(nic1.t1att3, nic1.t2att3, "nic1", 1))
netchange <- rbind(netchange, make.netchange.data(nic1.t1att4, nic1.t2att4, "nic1", 1))
netchange <- rbind(netchange, make.netchange.data(nic1.t1att5, nic1.t2att5, "nic1", 1))
netchange <- rbind(netchange, make.netchange.data(nic1.t1att6, nic1.t2att6, "nic1", 1))
netchange <- rbind(netchange, make.netchange.data(nic1.t1att7, nic1.t2att7, "nic1", 1))
netchange <- rbind(netchange, make.netchange.data(nic1.t1att8, nic1.t2att8, "nic1", 1))
netchange <- rbind(netchange, make.netchange.data(nic1.t1att9, nic1.t2att9, "nic1", 1))

netchange <- rbind(netchange, make.netchange.data(nic2.t1demo, nic2.t2demo, "NIC 2", 1))
netchange <- rbind(netchange, make.netchange.data(nic2.t1envir, nic2.t2envir, "NIC 2", 1))
netchange <- rbind(netchange, make.netchange.data(nic2.t1forai1, nic2.t2forai1, "NIC 2", 1))
netchange <- rbind(netchange, make.netchange.data(nic2.t1global, nic2.t2global, "NIC 2", 1))
netchange <- rbind(netchange, make.netchange.data(nic2.t1humrh2, nic2.t2humrh2, "NIC 2", 1))
netchange <- rbind(netchange, make.netchange.data(nic2.t1inter, nic2.t2inter, "NIC 2", 1))
netchange <- rbind(netchange, make.netchange.data(nic2.t1multi, nic2.t2multi, "NIC 2", 1))
netchange <- rbind(netchange, make.netchange.data(nic2.t1trade_b, nic2.t2trade_b, "NIC 2", 1))
netchange <- rbind(netchange, make.netchange.data(nic2.t1usseca, nic2.t2usseca, "NIC 2", 1))

netchange <- rbind(netchange, make.netchange.data(btp04pr.t1mindex, btp04pr.t2mindex, "BTP 2004 Pr.", 0))
netchange <- rbind(netchange, make.netchange.data(btp04pr.t1services, btp04pr.t2services, "BTP 2004 Pr.", 0))
netchange <- rbind(netchange, make.netchange.data(btp04pr.t1trade, btp04pr.t2trade, "BTP 2004 Pr.", 1))

detach(master)
attach(as.data.frame(netchange))

plot(density(netchange[,1]))
# exact model from draft paper
summary(lm(net.change ~ salience.T1PK + diversity + extremity + online + US + FP))

summary(lm(net.change ~ salience.T1PK + diversity + extremity + online+ FP))
summary(lm(net.change ~ salience.T1PK + diversity + extremity + online + factor(country) + FP))

summary(lm(net.change ~ salience.T1PK.by.group + diversity + extremity + online + US + FP))
summary(lm(net.change ~ salience.T1PK.by.group + diversity + extremity + online + factor(country) + FP))



library(lme4)
out <- lmer(net.change ~ salience.T1PK + diversity + extremity + online + FP + (1|country))
out2 <- lmer(net.change ~ salience.T1PK.by.group + diversity + extremity + online + FP + (1|country))

           