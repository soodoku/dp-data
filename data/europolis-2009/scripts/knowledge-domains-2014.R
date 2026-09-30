# europolis PK 5.23.14
# pete.mohanty@gmail.com

library(foreign)
library(ltm)

setwd("c:/users/pete/dropbox/ut/europolis")
EUdata <- read.csv("eurostat eu country data udpated.csv", row.names=1)

europolis <- read.spss("EUROPOLIS-DATA-NEW-OCT-2010.sav", to.data.frame=TRUE, use.value.labels=FALSE)
test.group.participants.dataframe <- subset(europolis, GROUP_T1BIS==1)
attach(test.group.participants.dataframe)


# cleaning functions

rescale <- function(original, newmin=0, newmax=1){
  # if original contains NAs, returns as NA  
  zero.one <- (original - min(original, na.rm = TRUE))/(max(original, na.rm = TRUE) - min(original, na.rm = TRUE))
  return((zero.one*(newmax - newmin)) + newmin)
}

reorient <- function(original){
  return(max(original, na.rm=TRUE) - original)
}


describe <- function(indicators){
  
  indicators <- data.frame(indicators)
  print(paste("overall mean:", mean(as.matrix(indicators), na.rm=TRUE)))
  print(paste("indicator means:", colMeans(indicators)))
  print(paste("overall standard deviation: ", sd(as.matrix(indicators), na.rm=TRUE)))
  print(paste("indicator SDs:", apply(indicators, 2, sd, na.rm=TRUE)))
  print(cor(indicators, use="complete.obs"))
  print(cronbach.alpha(indicators, na.rm=TRUE))
  if(ncol(indicators)>2){
    print(factanal(indicators, 1, rotation="varimax"))
  }
  else{
    print("too few variables for factor analysis (min = 3)")
  }
}

construct <- function(indicators){
  no.missing <- ifelse(is.na(indicators), .5, indicators)
  describe(no.missing)
  return(rowMeans(no.missing))
}



######### POLITICAL KNOWLEDGE ###########

answer.key <- c(2, 1, 1, 2, 1, 1, 4, 1, 2)
# QUESTION TOPICS: EU, EU, EU, Imm, Imm, Imm, CC, CC, CC
# people know more about immigration than climate change
# t.test(rowMeans(T3.PK.corrected[,4:6], rowMeans(T3.PK.corrected[,7:9])))
# t = 3.6448, df = 347, p-value = 0.0003085
T2.PK.responses <- cbind(V2Q43, V2Q44, V2Q45, V2Q46, V2Q47, V2Q48, V2Q49, V2Q50, V2Q51)
T2.PK.corrected <- matrix(ncol=9, nrow=348)
i <- 1
for(i in 1:348){
  T2.PK.corrected[i,] <- T2.PK.responses[i,] == answer.key
}
T2.PK.corrected <- ifelse(is.na(T2.PK.corrected), 0, ifelse(T2.PK.corrected, 1, 0))

etg$T2.PK.EU <- construct(T2.PK.corrected[,1:3])
etg$T2.PK.Imm <- construct(T2.PK.corrected[,4:6])
etg$T2.PK.CC <- construct(T2.PK.corrected[,7:9])
etg$T2.PK <- construct(cbind(T2.PK.corrected[,1], T2.PK.corrected[,3:9]))


T3.PK.responses <- cbind(V3Q43, V3Q44, V3Q45, V3Q46, V3Q47, V3Q48, V3Q49, V3Q50, V3Q51)
T3.PK.corrected <- matrix(ncol=9, nrow=348)
i <- 1
for(i in 1:348){
  T3.PK.corrected[i,] <- T3.PK.responses[i,] == answer.key
}
T3.PK.corrected <- ifelse(is.na(T3.PK.corrected), 0, ifelse(T3.PK.corrected, 1, 0))

etg$T3.PK <- construct(cbind(T3.PK.corrected[,1], T3.PK.corrected[,3:9]))
etg$T3.PK.all9Qs <- construct(T3.PK.corrected)
etg$T3.PK.EU <- construct(T3.PK.corrected[,1:2])
#T3.PK.EU <- rowMeans(T3.PK.corrected[,1:3])
etg$T3.PK.imm <- rowMeans(T3.PK.corrected[,4:6])
etg$T3.PK.cc <- rowMeans(T3.PK.corrected[,7:9])

etg$T3.PK.CC.and.EU <- rowMeans(T3.PK.corrected[,c(1, 3, 7, 8, 9)])
etg$T3.PK.imm.and.EU <- rowMeans(T3.PK.corrected[,c(1, 3, 4, 5, 6)])
