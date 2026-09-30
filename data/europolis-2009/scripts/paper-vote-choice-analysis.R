##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~---++
##   											##
##      EU DOM
##		Last Edited: 2.25.14   	
##   	Gaurav Sood								##		
##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~---++

# Set directory
	setwd(basedir)

# Load data
	eu2009 <- foreign::read.dta("cdd/data/EU 2009/rcl paper/EU2009_APSA.dta")
	names(eu2009) <- tolower(names(eu2009))

# Participants only
	eu2009			<- subset(eu2009, filter_cg3=="Participant(N=348)")
	eu2009$lr		<- zero1(-1*eu2009$lr, -1, 0)
	eu2009$v1vote2r <- relevel(eu2009$v1vote2, ref=2)
	
# Running multinomial
	library(nnet)
	# Table 6
		t1 <- with(eu2009, multinom(v1vote2r ~ t1immi9b + t1climmid_t1v  + lr))
		t3 <- with(eu2009, multinom(relevel(v3vote2, ref=2) ~ t3immi9b + t3climmid_t1v  + lr))
	
		#t1 <- with(eu2009, glm(v1vote2r=='Greens' ~ t1immi9b + t1climmid_t1v + lr, family="binomial"))
		#t3 <- with(eu2009, glm(v3vote2=='Greens' ~ t3immi9b + t3climmid_t1v + lr, family="binomial"))
		
	# Green Vote
		mean(eu2009$v1vote2=='Greens', na.rm=T)
		mean(eu2009$v3vote2=='Greens', na.rm=T)

	# Predicting how much changes in preferences matter
		mean(predict(t3, type="probs", newdata=data.frame(t3immi9b=eu2009$t1immi9b, t3climmid_t1v=eu2009$t1climmid_t1v)), na.rm=T)
		mean(predict(t1, type="probs", newdata=data.frame(t1immi9b=eu2009$t3immi9b, t1climmid_t1v=eu2009$t3climmid_t1v)), na.rm=T)
		
		# For glm
		#mean(predict(t3, type="response", newdata=data.frame(t3immi9b=eu2009$t1immi9b, t3climmid_t1v=eu2009$t1climmid_t1v)), na.rm=T)
		#mean(predict(t1, type="response", newdata=data.frame(t1immi9b=eu2009$t3immi9b, t1climmid_t1v=eu2009$t3climmid_t1v)), na.rm=T)
		
	# Predict some unusual combinations
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		#Note:  Entries are differences in the predicted probabilities of voting for the given party bloc.  
		#In the first block of columns the difference is between the probability when the row variable is at 
		#its theoretical maximum (1) and the probability when it is at theoretical minimum (0).  In the second, 
		#it is between the probability when the row variable is 2 standard deviations below its mean and the 
		#probability when it is 2 standard deviations above its mean.   Each column gives that difference of 
		#probabilities under the indicated numercial scenario for both of the other regressors.    
	
	# Generate mean-2sd, mean+2sd of a variable
	# If that is below 0 or greater than 1, turn it to 0 and 1
		sd2d <- function(x){
			meanx	<- mean(x, na.rm=T)
			sdx		<- sd(x, na.rm=T)
			
			res <- c(meanx+2*sdx, meanx - 2*sdx)	
			res <- ifelse(res > 1, 1, res)
			res <- ifelse(res < 0, 0, res)
			res
		}

		# Generate mean-2sd, mean-1sd, mean, mean+1sd, mean+2sd of a variable
		# If that is below 0 or greater than 1, turn it to 0 and 1
		sd2d2 <- function(x){
			meanx	<- mean(x, na.rm=T)
			sdx		<- sd(x, na.rm=T)
			
			res <- c(meanx-2*sdx, meanx - sdx, meanx, meanx + sdx, meanx + 2*sdx)	
			res <- ifelse(res > 1, 1, res)
			res <- ifelse(res < 0, 0, res)
			res
		}
		
		#For X1, -2SD cell, difference in probability generated for the following two scenarios -
		#		1)	X1 at 2sd + mean, X2 at -2sd + mean, X3 at -2sd + mean
		#2)	X1 at -2sd + mean, X2 at -2sd + mean, X3 at -2sd + mean
		
		#predict(t3, type="response", newdata=data.frame(t3immi9b=sd2d(eu2009$t3immi9b), t3climmid_t1v=sd2d2(eu2009$t3climmid_t1v)[1], lr=sd2d2(eu2009$lr)[1]))
		
		# For t3 
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			firstdiff <- function(t3, other1, other2, main){
				res <- rep(NA,5)
				for(i in 1:5){
					# res[1,]
					#a 		<- predict(t3, type="probs", newdata=data.frame(t3immi9b=main[1], t3climmid_t1v=other1[i], lr=other2[i]))
					#b 		<- predict(t3, type="probs", newdata=data.frame(t3immi9b=main[2], t3climmid_t1v=other1[i], lr=other2[i]))
					# res[2,]
					#a 		<- predict(t3, type="probs", newdata=data.frame(t3immi9b=other1[i], t3climmid_t1v=main[1], lr=other2[i]))
					#b 		<- predict(t3, type="probs", newdata=data.frame(t3immi9b=other1[i], t3climmid_t1v=main[2], lr=other2[i]))
					#res[3,]
					a 		<- predict(t3, type="probs", newdata=data.frame(t3immi9b=other1[i], t3climmid_t1v=other2[i], lr=main[1]))
					b 		<- predict(t3, type="probs", newdata=data.frame(t3immi9b=other1[i], t3climmid_t1v=other2[i], lr=main[2]))
					res[i] 	<- a - b
				}
				res
			}
		
		# So three runs of 0, 1 and then -2sd to 2sd
			res 		<- data.frame(matrix(ncol=10, nrow=3))
			res[1,1:5]	<- firstdiff(t3, seq(0,1,.25),  seq(0,1,.25), c(1,0))
			res[1,6:10] <- firstdiff(t3, sd2d2(eu2009$t3climmid_t1v), sd2d2(eu2009$lr), sd2d(eu2009$t3immi9b))
			
			res[2,1:5]	<- firstdiff(t3, seq(0,1,.25),  seq(0,1,.25), c(1,0))
			res[2,6:10] <- firstdiff(t3, sd2d2(eu2009$t3immi9b), sd2d2(eu2009$lr), sd2d(eu2009$t3climmid_t1v))
			
			res[3,1:5]	<- firstdiff(t3, seq(0,1,.25),  seq(0,1,.25), c(1,0))
			res[3,6:10] <- firstdiff(t3, sd2d2(eu2009$t3immi9b), sd2d2(eu2009$t3climmid_t1v), sd2d(eu2009$lr))
			
			write.csv(res, file="cdd/data/EU 2009/rcl paper/rest3.csv")
			
		# For t1
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			firstdiff <- function(t1, other1, other2, main){
				# t1 <- t1; other1 <- c(1,0); other2 <- c(1,0); main <- c(1,0)
				res <- rep(NA,5)
				for(i in 1:5){
					#a 		<- predict(t1, type="probs", newdata=data.frame(t1immi9b=main[1], t1climmid_t1v=other1[i], lr=other2[i]))
					#b 		<- predict(t1, type="probs", newdata=data.frame(t1immi9b=main[2], t1climmid_t1v=other1[i], lr=other2[i]))
					#a 		<- predict(t1, type="probs", newdata=data.frame(t1immi9b=other1[i], t1climmid_t1v=main[1], lr=other2[i]))
					#b 		<- predict(t1, type="probs", newdata=data.frame(t1immi9b=other1[i], t1climmid_t1v=main[2], lr=other2[i]))
					a 		<- predict(t1, type="probs", newdata=data.frame(t1immi9b=other1[i], t1climmid_t1v=other2[i], lr=main[1]))
					b 		<- predict(t1, type="probs", newdata=data.frame(t1immi9b=other1[i], t1climmid_t1v=other2[i], lr=main[2]))
					res[i] 	<- mean(a - b, na.rm=T)
				}
				res
			}

		# So three runs of 0, 1 and then -2sd to 2sd
			res 		<- data.frame(matrix(ncol=10, nrow=3))
			res[1,1:5]	<- firstdiff(t1, seq(0,1,.25),  seq(0,1,.25), c(1,0))
			res[1,6:10] <- firstdiff(t1, sd2d2(eu2009$t1climmid_t1v), sd2d2(eu2009$lr), sd2d(eu2009$t1immi9b))
			
			res[2,1:5]	<- firstdiff(t1, seq(0,1,.25),  seq(0,1,.25), c(1,0))
			res[2,6:10] <- firstdiff(t1, sd2d2(eu2009$t1immi9b), sd2d2(eu2009$lr), sd2d(eu2009$t1climmid_t1v))
			
			res[3,1:5]	<- firstdiff(t1, seq(0,1,.25),  seq(0,1,.25), c(1,0))
			res[3,6:10] <- firstdiff(t1, sd2d2(eu2009$t1immi9b), sd2d2(eu2009$t1climmid_t1v), sd2d(eu2009$lr))
			
			write.csv(res, file="cdd/data/EU 2009/rcl paper/rest1.csv")
			
		