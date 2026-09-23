
# Set dir 
setwd(basedir)

# Load libs
library(car)
library(goji)

# Load data
load("cdd/data/eu_2007/eu_5_25_08.rdata")

eu2007test <- subset(eu2007, !is.na(eu2007$group_no))

eu2007test$support_eu_membership_t3 - eu2007test$support_eu_membership_t2 

proEU.t1 <- ifelse(is.na(eu2007test$support_eu_membership_t1), .5, eu2007test$support_eu_membership_t1)
proEU.t2 <- ifelse(is.na(eu2007test$support_eu_membership_t2), .5, eu2007test$support_eu_membership_t2)
proEU.t3 <- ifelse(is.na(eu2007test$support_eu_membership_t3), .5, eu2007test$support_eu_membership_t3)

plot(density(proEU.t1))
lines(density(proEU.t2), lty = 2)
lines(density(proEU.t3), lty = 3)

by(proEU.t3, eu2007test$group_no, var)

moreEUdecisions.t3 <- ifelse(is.na(eu2007test$eu_level_decision_making_t3), .5, 
                             eu2007test$eu_level_decision_making_t3)
moreEUdecisions.t2 <- ifelse(is.na(eu2007test$eu_level_decision_making_t2), .5, 
                             eu2007test$eu_level_decision_making_t2)

plot(density(moreEUdecisions.t2))
lines(density(moreEUdecisions.t3), lty = 2)

# more variation than the general pro EU question
# but more topics in this index than europolis so prob need make new index

# mean of 17 a,b,c,d,e,f,g,h,i
# Let’s start with a scale of 0 to 10, where 0 means that the individual member states make all the decisions, 10 means that the EU makes all the decisions, and 5 is exactly in the middle.  Higher numbers mean more coordination between countries, while lower numbers mean more independent decision making by individual countries.  
# 17a. Immigration
#17b. International trade   
#17c. Employment
#17d. Pensions
#17e. Military action
#17f. Climate change
#17g. Foreign aid
#17h. Taxation
#17i. Energy supply"

# FIXING COUNTRY


length(apply(eu2007test[, c(394:396, 398:406, 408:409, 411:414, 417, 419:424)], 2, sum))
# appears that there are no dummies for germany or greece
# "el" seems to be lithuania

sort(table(eu2007test$v_a)) # country variable
sort(apply(eu2007test[, c(394:396, 398:406, 408:409, 411:414, 417, 419:424)], 2, sum))

# 42 seems to be greece; 20 seems to be germany

codes <- c("cy", "ee", "lu", "mt","gr", "si",
           "ie", "bg", "lv", "sk", "fi", "Q",
           "at", "dk", "se", "be", "li", "hu", 
           "cz", "pt", "nl", "ro", "es", "pl", 
           "gb", "it", "de", "fr") # renaming lithuania LI
eu2007test.country <- codes[match(eu2007test$v_a, c(10,32,34,38,37,42,8,31,36,
                                                   41, 6,21,3, 12, 14,1,4, 35,
                                                   13, 33, 11, 40,  5, 39,
                                                   9, 22, 20, 7))]
                            
# there are 28 countries in v_a (not 27)
# there are two countries with n = 8
# finland is one of them; finland is country code 6
# country code 21 is unknown
# ni (northern ireland?) may have been coded separately
# (not super likely since the variable 'ni' has n = 0)
# the variable may also have captured dual or non-citizenship in some fashion
# or no response...
# coding the mystery country ( / category) "Q"
# 28 categories in sample as a whole too; n = 78 responses for code 21 (including test group)
nats <- as.numeric(as.matrix(lapply(by(eu2007test.country, eu2007test$gr, unique), length)[eu2007test$gr])) 
change <- moreEUdecisions.t3 - moreEUdecisions.t2

y <- (moreEUdecisions.t3 - .5)*2
lagged <- (moreEUdecisions.t2 - .5)*2

summary(lm(y ~ lagged + nats * eu2007test$oldt3pkindexnew))

extremity <- y^2
lagged.x <- lagged^2
lagged.group.x <- as.numeric(as.matrix(by(lagged.x, eu2007test$group_no, mean)[eu2007test$group_no]))^2
  
lagged.grouplevel.x <- as.numeric(as.matrix(by(lagged.x, eu2007test$group_no, mean)))^2
nats.grouplevel <- as.numeric(as.matrix(lapply(by(eu2007test.country, eu2007test$gr, unique), length))) 
cor(lagged.grouplevel.x, nats.grouplevel) # r =  -0.5284

barplot(by(lagged, eu2007test.country, mean)) # very prounced country to country differences
barplot(by(lagged.x, eu2007test.country, mean))


# interesting
summary(lm(extremity ~ nats))
summary(lm(extremity ~ lagged.x + nats + eu2007test$oldt3pkindexnew))
# but weakened slightly...
summary(lm(extremity ~ lagged.x + nats + eu2007test$oldt3pkindexnew + 
              + lagged.group.x))
cor(lagged.group.x, nats) #-0.48 at individual level

summary(lm(extremity ~ lagged.x + eu2007test$oldt3pkindexnew + 
             + lagged.group.x))


