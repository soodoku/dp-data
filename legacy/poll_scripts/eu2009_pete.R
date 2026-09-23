#
# EU 2009
# 

# Load libs 
library(foreign)
library(ltm)

# Set directory

setwd(basedir)
setwd("cdd/data/eu_2009/")
load("europolis test group.rdata")

EUdata <- read.csv("EU27 data.csv", row.names=1)

europolis <- read.spss("EUROPOLIS-DATA-NEW-OCT-2010.sav", to.data.frame = TRUE, use.value.labels = FALSE)
test.group.participants.dataframe <- subset(europolis, GROUP_T1BIS == 1)

europolis.labels <- read.spss("EUROPOLIS-DATA-NEW-OCT-2010.sav", to.data.frame = TRUE, use.value.labels = T)
test.group.with.labels <- subset(europolis.labels, europolis$GROUP_T1BIS == 1)
country <- test.group.with.labels$COUNTRY1

attach(test.group.participants.dataframe)

rescale <- function(original, newmin = 0, newmax = 1){
  # if original contains NAs, returns as NA  
  zero.one <- (original - min(original, na.rm = TRUE))/(max(original, na.rm = TRUE) - min(original, na.rm = TRUE))
  return((zero.one*(newmax - newmin)) + newmin)
}

reorient <- function(original){
  return(max(original, na.rm = TRUE) - original)
}



describe <- function(indicators){
  
  indicators <- data.frame(indicators)
  print(paste("mean:", colMeans(indicators)))
  print(paste("standard deviation: ", apply(indicators, 2, sd, na.rm=T)))
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

n <- 348 # number of test group participants
id <- c(1:348)
group.number <- SMALL_GROUPw2

rest.of.group <- function(X){
  return(apply(matrix(c(1:n)), 1, 
               function(i){subset(X, (id != id[i] & group.number == group.number[i]))}))
}

euclidean.d <- function(policy.stances){
  
  rest.of.group.stances <- rest.of.group(policy.stances)
  return(apply(matrix(1:n), 1, function(i){
    sqrt(sum((policy.stances[i,] - rest.of.group.stances[[i]])^2))/rest.of.group.n[i]
  }))
}
cc.eucl <- euclidean.d(T2.CC)

distance <- function(issue){
  d <- rowMeans(issue) - as.numeric(matrix(nrow=n, lapply(rest.of.group(issue), mean)))
  return((d^2)^.5)
} # euclidean

gen.sd <- function(X){det(cov(X))^.5} # generalized "standard deviation"

het <- function(issue){
  as.numeric(matrix(lapply(rest.of.group(issue), gen.sd), nrow = n))
} # heterogeneity based on generalized "standard deviation"

# DEPENDENT variables

# reduce illegal immigration
T2.imm.send.them.back <- reorient(rescale(V2Q8b))
T2.imm.reinforce.border <- reorient(rescale(V2Q11_1))
T2.reducing.immigration <- rescale(construct(cbind(T2.imm.send.them.back, T2.imm.reinforce.border)), -1, 1)

T3.imm.send.them.back <- reorient(rescale(V3Q8b))
T3.imm.reinforce.border <- reorient(rescale(V3Q11_1))
T3.reducing.immigration <- rescale(construct(cbind(T3.imm.send.them.back, T3.imm.reinforce.border)), -1, 1)

T2.raw.imm <- cbind(etg$T2.imm.need.skills, etg$T2.imm.need.language, etg$T2.imm.need.money,
                    etg$T2.imm.shouldbe.christian, etg$T2.imm.shouldbe.white, etg$T2.imm.shouldbe.culturally.similar,
                    etg$T2.imm.oppose.healthcare, etg$T2.imm.oppose.schooling, 
                    etg$T2.imm.reinforce.border, etg$T2.imm.penalize.employer, etg$T2.imm.send.them.back)
T2.imm <- ifelse(is.na(T2.raw.imm), .5, T2.raw.imm)
T2.imm <- rescale(T2.imm, -1, 1)

imm.distance <- distance(T2.imm)
imm.het <- het(T2.imm)
imm.het <- ifelse(is.na(imm.het), 0, imm.het)
T2.antiImm <- rowMeans(T2.imm)

T3.raw.imm <- cbind(etg$T3.imm.need.skills, etg$T3.imm.need.language, etg$T3.imm.need.money,
                    etg$T3.imm.shouldbe.christian, etg$T3.imm.shouldbe.white, etg$T3.imm.shouldbe.culturally.similar,
                    etg$T3.imm.oppose.healthcare, etg$T3.imm.oppose.schooling,
                    etg$T3.imm.reinforce.border, etg$T3.imm.penalize.employer, etg$T3.imm.send.them.back)
T3.imm <- ifelse(is.na(T3.raw.imm), .5, T3.raw.imm)
T3.antiImm <- rowMeans(rescale(T3.imm, -1, 1))

antiImm.het <- as.numeric(as.matrix(lapply(rest.of.group(T2.antiImm), sd)))
plot(density(antiImm.het))

cc.het <- as.numeric(as.matrix(lapply(rest.of.group(T2.fight.cc.B), sd)))
plot(density(cc.het))


cor(imm.distance, imm.het)


# CLIMATE CHANGE
T2.cc.renewables <- rescale(V2Q27_5)
T2.cc.conservation.edu <- rescale(V2Q27_8)
T2.cc.use.less.energy <- rescale(V2Q27_9)
T2.cc.max.effort.against.cc <- reorient(rescale(V2Q21))
T2.cc.EU.sh.incr.cc.targets <- reorient(rescale(V2Q23))
T2.cc.min.greenhouse <- reorient(rescale(V2Q24))
T2.cc.max.country.solo.effort.against.cc <- reorient(rescale(V2Q25))
T2.cc.energy.efficiency <- rescale(V2Q27_2)
T2.cc.cap.n.trade <- rescale(V2Q27_7)

T2.CC.raw.B <- rescale(cbind(T2.cc.renewables,
                  T2.cc.conservation.edu,
      T2.cc.use.less.energy,
      T2.cc.max.effort.against.cc,
      T2.cc.EU.sh.incr.cc.targets,
      T2.cc.min.greenhouse,
      T2.cc.max.country.solo.effort.against.cc,
      T2.cc.energy.efficiency, 
      T2.cc.cap.n.trade), -1, 1)

T2.CC.B <- ifelse(is.na(T2.CC.raw.B), 0, T2.CC.raw.B)

# see europolis mpsa 2015 models.r
#cc.distance <- distance(T2.CC)
#cc.distance <- distance(T2.CC.B)
#cc.het <- het(T2.CC.B)
#cc.het <- ifelse(is.na(cc.het), 0, cc.het) # handful (5) of negative generalized variances 
                                           # on the order of 10^-24 (rounding error)
                                           # introduce when no difference of opinion in group
                                          # (i.e., no entropy). overcoded as 0
#cc.het <- cc.het / max.het
#cc.het <- ifelse(cc.het > 1, .75, cc.het) # chase down where those two > 1 came from; rounding error?

#cc.het <- cc.het/det(cov(noise))
plot(density(cc.het))

cor(cc.het, cc.distance) # r = 0.041, p = 0.447

library(bnlearn) # ci.test is conditional independence test
ci.test(T3.fight.cc.B, cc.het, cc.distance)

T2.fight.cc <- rescale(construct(cbind(T2.cc.renewables,
                                       T2.cc.conservation.edu,
                                       T2.cc.use.less.energy,
                                       T2.cc.max.effort.against.cc,
                                       T2.cc.EU.sh.incr.cc.targets,
                                       T2.cc.min.greenhouse,
                                       T2.cc.max.country.solo.effort.against.cc)), -1, 1)

T2.fight.cc.A <- rescale(construct(cbind(T2.cc.renewables,
                                         T2.cc.conservation.edu,
                                         T2.cc.use.less.energy,
                                         T2.cc.max.effort.against.cc,
                                         T2.cc.EU.sh.incr.cc.targets,
                                         T2.cc.min.greenhouse,
                                         T2.cc.max.country.solo.effort.against.cc, 
                                         T2.cc.energy.efficiency)), -1, 1)

T2.fight.cc.B <- rescale(construct(cbind(T2.cc.renewables,
                                         T2.cc.conservation.edu,
                                         T2.cc.use.less.energy,
                                         T2.cc.max.effort.against.cc,
                                         T2.cc.EU.sh.incr.cc.targets,
                                         T2.cc.min.greenhouse,
                                         T2.cc.max.country.solo.effort.against.cc,
                                         T2.cc.energy.efficiency, 
                                         T2.cc.cap.n.trade)), -1, 1)

T2.cc.values.het <- het(cbind(T2.env, T2.econ.conservatism))
T2.env.dist <- matrix(nrow=n)
T2.env.others <- rest.of.group(T2.env)
i <- 1
for(i in 1:n){
  tmp <- T2.env[i] - T2.env.others[[i]]
  T2.env.dist[i] <- (t(tmp) %*% (tmp))^.5
}

T3.cc.renewables <- rescale(V3Q27_5)
T3.cc.conservation.edu <- rescale(V3Q27_8)
T3.cc.use.less.energy <- rescale(V3Q27_9)
T3.cc.max.effort.against.cc <- reorient(rescale(V3Q21))
T3.cc.EU.sh.incr.cc.targets <- reorient(rescale(V3Q23))
T3.cc.min.greenhouse <- reorient(rescale(V3Q24))
T3.cc.max.country.solo.effort.against.cc <- reorient(rescale(V3Q25))
T3.cc.energy.efficiency <- rescale(V3Q27_2)
T3.cc.cap.n.trade <- rescale(V3Q27_7)

T3.fight.cc <- rescale(construct(cbind(T3.cc.renewables,
                                       T3.cc.conservation.edu,
                                       T3.cc.use.less.energy,
                                       T3.cc.max.effort.against.cc,
                                       T3.cc.EU.sh.incr.cc.targets,
                                       T3.cc.min.greenhouse,
                                       T3.cc.max.country.solo.effort.against.cc)), -1, 1)

T3.fight.cc.A <- rescale(construct(cbind(T3.cc.renewables,
                                         T3.cc.conservation.edu,
                                         T3.cc.use.less.energy,
                                         T3.cc.max.effort.against.cc,
                                         T3.cc.EU.sh.incr.cc.targets,
                                         T3.cc.min.greenhouse,
                                         T3.cc.max.country.solo.effort.against.cc,
                                         T3.cc.energy.efficiency)), -1, 1)

T3.fight.cc.B <- rescale(construct(cbind(T3.cc.renewables,
                                         T3.cc.conservation.edu,
                                         T3.cc.use.less.energy,
                                         T3.cc.max.effort.against.cc,
                                         T3.cc.EU.sh.incr.cc.targets,
                                         T3.cc.min.greenhouse,
                                         T3.cc.max.country.solo.effort.against.cc,
                                         T3.cc.energy.efficiency, 
                                         T3.cc.cap.n.trade)), -1, 1)

# independent variables

# demographics

class.p <- (1/0.9792899)*c(mean(class1 == 1, na.rm = TRUE), mean(class1 == 2, na.rm = TRUE), mean(class1 == 3, na.rm=TRUE), mean(class1 == 4, na.rm = TRUE))
class.economic <- reorient(rescale(ifelse(!is.na(class1) & class1 < 5, class1, 
                                          round(rtnorm(1, mean(class1, na.rm = TRUE), sd(class1, na.rm = TRUE), 1, 4), 0)))) 
# randomly assigning 17 missing... used rtnorm since rbinom wrong shape... if class1 reoriented rbinom might work
born.outside.EU <- ifelse(birth1 < 997, ifelse(birth1 > 2, 1, 0), 1)
parents.born.outside.EU <- ifelse(is.na(parentsbirth1), 1, ifelse(parentsbirth1 == 4, 1, 0))
tcn.background <- ifelse(born.outside.EU + parents.born.outside.EU > 0, 1, 0)
imm.background <- ifelse(birth1 < 997, ifelse(birth1 > 1, 1, 0), 1) + ifelse(is.na(parentsbirth1), 1, ifelse(parentsbirth1 > 1, 1, 0))
age <- rescale(2009-age1)
female <- ifelse(sex1  == 2 , 1, 0)
education <- ifelse(educ1 == 0, ifelse(2010-age1>35, 35, 2010-age1), educ1)/35
education <- ifelse(is.na(education), .5, education)
christian <- ifelse(reli1 < 5, 1, 0)
christian <- ifelse(is.na(christian), rbinom(1, 1, mean(christian, na.rm=TRUE)), christian)

demographics <- cbind(class.economic, education, age, imm.background, christian)

det(cor(demographics)) 

#### values ##########
# economic conservatism

T2.laissez.faire <- rescale(V2Q52_1)
T2.growth <- rescale(V2Q52_3)
T2.econ.conservatism <- rescale(construct(cbind(T2.laissez.faire, T2.growth)), -1, 1)

T3.laissez.faire <- rescale(V3Q52_1)
T3.growth <- rescale(V3Q52_3)
T3.econ.conservatism <- rescale(construct(cbind(T3.laissez.faire, T3.growth)), -1, 1)
T3.econ.right <- rescale(construct(cbind(T3.laissez.faire, T3.growth, ifelse(is.na(T4.lr), .5, T4.lr))), -1, 1)

T2.trad <- rescale(ifelse(is.na(V2Q52_2), 5, V2Q52_2), -1, 1)
T3.trad <- rescale(ifelse(is.na(V3Q52_2), 5, V3Q52_2), -1, 1)

# environmentalism
T2.clean.air.water <- rescale(V2Q52_4)
T2.protect.planet <- rescale(V2Q52_5)
T2.env <- rescale(construct(cbind(T2.clean.air.water, T2.protect.planet)), -1, 1)

T3.clean.air.water <- rescale(V3Q52_4)
T3.protect.planet <- rescale(V3Q52_5)
T3.env <- rescale(construct(cbind(T3.clean.air.water, T3.protect.planet)), -1, 1)

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

T2.PK.EU <- construct(T2.PK.corrected[, 1:3])
T2.PK.Imm <- construct(T2.PK.corrected[, 4:6])
T2.PK.CC <- construct(T2.PK.corrected[, 7:9])
T2.PK <- construct(cbind(T2.PK.corrected[, 1], T2.PK.corrected[, 3:9]))

T3.PK.EU <- construct(T3.PK.corrected[, 1:2])

T3.PK.responses <- cbind(V3Q43, V3Q44, V3Q45, V3Q46, V3Q47, V3Q48, V3Q49, V3Q50, V3Q51)
T3.PK.corrected <- matrix(ncol=9, nrow=348)
i <- 1
for(i in 1:348){
  T3.PK.corrected[i,] <- T3.PK.responses[i,] == answer.key
}
T3.PK.corrected <- ifelse(is.na(T3.PK.corrected), 0, ifelse(T3.PK.corrected, 1, 0))
T3.PK <- construct(cbind(T3.PK.corrected[,1], T3.PK.corrected[,3:9]))


# country data
MS.pop <- EUdata$pop2009[COUNTRY1]
MS.ldi <- EUdata$linguistic.diversity.index[COUNTRY1]
MS.immpop.cit <- (EUdata$noncit.perc2009[COUNTRY1] - mean(EUdata$noncit.perc2009))/mean(EUdata$noncit.perc2009)
# MS.immpop.birth <- EUdata$foreignbybirth2009[COUNTRY1]
MS.GDP <- (EUdata$GDPppp2009[COUNTRY1] - 100)/100# per person GDP, originally standardized, EU average = 100
MS.unemploy2009 <- EUdata$u2009[COUNTRY1]
MS.deltaU <- (EUdata$u2009M06[COUNTRY1] - EUdata$u2008M09[COUNTRY1]) # 2.54 change since sept 2008
MS.deltaU <- (MS.deltaU - mean(MS.deltaU))/mean(MS.deltaU)
MS.hdi <- rescale(EUdata$hdi2011[COUNTRY1])
MS.ihdi <- rescale(EUdata$ihdi2011.imputed.malta[COUNTRY1])
MS.EU15 <- EUdata$EU15[COUNTRY1]
MS.YRs.in.EU <- 2009 - EUdata$joinedEU[COUNTRY1]
MS.crime <- rescale(EUdata$crime.per.capita2009[COUNTRY1])
MS.police <- rescale(EUdata$police.per.100k.inhabitents[COUNTRY1])
tmp <- (EUdata$greenhouse.per.capita2009 - mean(EUdata$greenhouse.per.capita2009))/EUdata$greenhouse.per.capita2009
MS.greenhouse.per.capita <- (tmp[COUNTRY1])

climate.facts <- cbind(MS.greenhouse.per.capita, MS.GDP, MS.deltaU)
climate.objective.distance <- euclidean.d(climate.facts)

immigration.facts <- cbind(MS.immpop.cit, MS.deltaU, MS.GDP)
imm.obj.dist <- euclidean.d(immigration.facts)
