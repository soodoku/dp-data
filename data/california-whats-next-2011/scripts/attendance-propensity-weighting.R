##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~---++
##   											##
##      California
##		Last Edited: 7..14   	
##   	Gaurav Sood								##		
##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~---++

# setwd
	setwd(basedir)

# Load Data
	ca <- foreign::read.spss("cdd/data/California/ca.match/ca.sav", to.data.frame=T)
	names(ca) <- tolower(names(ca))
	ca <- subset(ca, !is.na(ca$part))

# 
# check: sum(ca$part) = 401

#Estimate a logit equation with following variables; T1 Knowledge Index 
#(kindex), Hispanics (q70), Income (q69), and 4-5 proposal questions (q2,4,5,10,11)

# Recoding
	ca$q2r  <- as.numeric(gsub('[^0-9.]', '', ca$q2))
	ca$q4r  <- as.numeric(gsub('[^0-9.]', '', ca$q4))
	ca$q5r  <- as.numeric(gsub('[^0-9.]', '', ca$q5))
	ca$q10r <- as.numeric(gsub('[^0-9.]', '', ca$q10))
	ca$q11r <- as.numeric(gsub('[^0-9.]', '', ca$q11))

	# Midpoint imputation on attitude items as directed by Fishkin/Luskin 
	ca$q2r  <- ifelse(is.na(ca$q2r), 5, ca$q2r)
	ca$q4r  <- ifelse(is.na(ca$q4r), 5, ca$q4r)
	ca$q5r  <- ifelse(is.na(ca$q5r), 5, ca$q5r)
	ca$q10r <- ifelse(is.na(ca$q10r), 5, ca$q10r)
	ca$q11r <- ifelse(is.na(ca$q11r), 5, ca$q11r)

# Recoding Hispanic
	ca$hisp <- as.numeric(ca$q70=='Hispanic')


# Logistic (with and without income); matching on missing data for income
est  <- glm(part ~ kindex + hisp + as.factor(q69) + q2r + q4r + q5r + q10r + q11r, data=ca, family=binomial(link="logit"))
est2 <- glm(part ~ kindex + hisp + q2r + q4r + q5r + q10r + q11r, data=ca, family=binomial(link="logit"))

# Harvesting Propensity Scores
ca$prop.score <- est$linear.predictors
# This is the same as -
# prop  <- predict(est, type="response"); ca$prop.score <- log(prop/(1-prop))
# ca$prop.score <- predict(est, type="link") # alternative

# For creating one without income
# Creating a weighting scheme for treatment group
# Subclassification, breaking into quintiles (based on what we see in control group) 
# this will eliminate a few of the control group participants
pop.quantiles <- quantile(ca$prop.score[ca$part == 0], probs = seq(0, 1, .2))
ca$quantile   <- cut(ca$prop.score, breaks=pop.quantiles, include.lowest=TRUE)
tbl <- prop.table(xtabs( ~ quantile + part, data=ca), 2)
mult <- tbl[,1] / tbl[,2]

# Assign weights to treat
ca$new.weight <- ifelse(ca$part == 1,  mult[as.integer(ca$quantile)], 1)

# Testing
summary(lm(q4r ~ part, weight=new.weight, data=ca))
summary(lm(q4r ~ part, data=ca))

# # Harvesting Propensity Scores
ca$prop.score <- est2$linear.predictors
# This is the same as -
# prop  <- predict(est, type="response"); ca$prop.score <- log(prop/(1-prop))
# ca$prop.score <- predict(est, type="link") # alternative

# Creating a weighting scheme for treatment group
# Subclassification, breaking into quintiles (based on what we see in control group) 
# this will eliminate a few of the control group participants
pop.quantiles <- quantile(ca$prop.score[ca$part == 0], probs = seq(0, 1, .2))
pop.quantiles[6] <- 2.15 # For it appears we don't want to lose any treatment group people
ca$quantile   <- cut(ca$prop.score, breaks=pop.quantiles, include.lowest=TRUE)
tbl <- prop.table(xtabs( ~ quantile + part, data=ca), 2)
mult <- tbl[,1] / tbl[,2]

# Assign weights to treat
ca$new.weight2 <- ifelse(ca$part == 1,  mult[as.integer(ca$quantile)], 1)

save(ca, file="misc/ca.match/ca.match.rdata")
