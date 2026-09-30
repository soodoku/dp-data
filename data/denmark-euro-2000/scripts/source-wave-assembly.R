##########################################################
##   													##
##     Denmark Euro Data, Last Edited: 12.3.10  	    ##
##   													##
##########################################################


spss <- function(x){
	library(foreign)
	temp <- read.spss(x, use.value.labels = F, to.data.frame = F, trim.factor.names = TRUE)
	temp <- as.data.frame(temp)
	names(temp) <- tolower(names(temp))
	detach(package:foreign)
	temp
}

setwd("C:/Users/Gaurav/Desktop/R")

t0den <- spss("data/CDD/Denmark/data/t0english.sav")
names(t0den) <- paste("t0", names(t0den), sep="")
save(t0den, file="data/CDD/Denmark/data/t0denmark.rdata", ascii=T)

t1den <- spss("data/CDD/Denmark/data/t1.sav")
names(t1den) <- paste("t1", names(t1den), sep="")
t1den$t1part <- 1
save(t1den, file="data/CDD/Denmark/data/t1denmark.rdata", ascii=T)

t2den <- spss("data/CDD/Denmark/data/t2.sav")
names(t2den) <- paste("t2", names(t2den), sep="")
t2den$t2part <- 1
save(t2den, file="data/CDD/Denmark/data/t2denmark.rdata", ascii=T)

t2ctrl <- spss("data/CDD/Denmark/data/t2ctrl.sav")
names(t2ctrl) <- paste("t2c", names(t2ctrl), sep="")
t2ctrl$t2cpart <- 1
save(t2ctrl, file="data/CDD/Denmark/data/t2ctrl.rdata", ascii=T)

t3den <- spss("data/CDD/Denmark/data/t3.sav")
names(t3den) <- paste("t3", names(t3den), sep="")
t3den$t3part <- 1
save(t3den, file="data/CDD/Denmark/data/t3denmark.rdata", ascii=T)

t0t1den <- merge(t0den, t1den, by.x="t0delnr", by.y="t1delnr", all.x=T, all.y=T)
t0t1t2den <- merge(t0t1den, t2den, by.x="t0delnr",by.y="t2delnr",all.x=T, all.y=T)
#t0t1t2t2cden <- merge(t0t1t2den, t2ctrl, by.x="t0delnr",by.y="t2cpostnr",all.x=T, all.y=T)
den <- merge(t0t1t2den, t3den, by.x="t0delnr",by.y="t3delnr",all.x=T, all.y=T)
save(den, file="data/CDD/Denmark/data/t3denmark.rdata", ascii=T)








