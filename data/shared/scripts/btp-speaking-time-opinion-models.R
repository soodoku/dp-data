library(foreign)
opmin <- read.dta("nuri/btp_opmin_newsplit_drop.dta", convert.factors = TRUE)

library(car)
opmin$opp3_mindexr <- recode(opmin$opp3_mindex, "'Change in Own Direction'=1; 'No Change'=2; 'Change in Opp Direction'=3")
opmin$opp3_trader <- recode(opmin$opp3_trade, "'Change in Own Direction'=1; 'No Change'=2; 'Change in Opp Direction'=3")

library(MASS)
summary(polr(as.ordered(opp3_govinv)~ ns(t1govinv_minority2) + totalstm_he_i + balance4_he + I(mypool4_he - othpool4_he) + minXbalance4_he + t1know + age + female, data=opmin))
summary(polr(as.ordered(opp3_fcvsch)~ t1fcvsch_minority2 + totalstm_ed_i + balance4_ed + minXbalance4_ed + t1know+ age + female, data=opmin))
summary(polr(as.ordered(opp3_mindex)~ t1mindex_minority2 + totalstm_df_i + balance4_df + minXbalance4_df  + t1know+ age + female, data=opmin))
summary(polr(as.ordered(opp3_trade)~ t1trade_minority2 + totalstm_tr_i + balance4_tr + minXbalance4_tr  + t1know+ age + female, data=opmin))


summary(lm(I(t2govinv - t1govinv) ~ t1govinv_minority2 +  t1fcvsch_minority2 + ns(totalstm_he_i,2) + balance4_he + balance4_ed  + minXbalance4_he +  as.factor(educ) + t1know + age + female, data=opmin))


summary(lm(I(t2fcvsch - t1fcvsch) ~ t1govinv_minority2 +  t1fcvsch_minority2 + totalstm_he_i + balance4_he + balance4_ed  + minXbalance4_he +  as.factor(educ) + t1know + age + female, data=opmin))

summary(lm(I(t2mindex - t1mindex) ~ t1govinv_minority2 +  t1fcvsch_minority2 + totalstm_he_i + balance4_he + balance4_ed  + minXbalance4_he +  as.factor(educ) + t1know + age + female, data=opmin))

summary(lm(I(t2trade - t1trade) ~ t1govinv_minority2 +  t1fcvsch_minority2 + totalstm_he_i + balance4_he + balance4_ed  + minXbalance4_he +  as.factor(educ) + t1know + age + female, data=opmin))

I(mypool4_he - othpool4_he)