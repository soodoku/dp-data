#to use this file set the filenames on lines 8 & 9
#then plug in variable names, and recoding values on lines 24-38,44,48-62,66-67 & 70-71

library(foreign)
library(car)
setwd("/Users/seanwestwood/Desktop/dpeval/")
#set filenames
rfile<-"/Users/seanwestwood/Desktop/dpeval/eu09.rdata"
spssfile<-"/Users/seanwestwood/Desktop/dpeval/eu09.sav"

dataset<-NA
####Config stuff
#load dateset
#ds<-load("/Users/seanwestwood/Desktop/dpeval/eu09.rdata")
#dataset<- read.spss("/Users/seanwestwood/Desktop/dpeval/eu09.sav", use.value.labels = FALSE)
#dataset <- as.data.frame(dataset)
#names(dataset) <- tolower(names(dataset))

dataset<-read.csv("/Users/seanwestwood/Desktop/dpeval/eu09.csv")

#save(dataset, file="/Users/seanwestwood/Desktop/dpeval/brazil.rdata", ascii=TRUE)

####set variables
pollid<-"51"
pollCountry<-"4"
pollGroupVariable<-"small_groupw2"
#create age variable from year of birth variable
dataset$age_full <-2009-dataset$age1
pollAgeVariable <-"age_full"
pollSexVariable <-"sex1"
pollSexCodes <- "c(1)=0; c(2)=1" #recode 0=male; 1=femlae
pollIncomeVariable <-"renda_familiar"
pollEducationVariable<-"educ1"
pollEducationCodes<-"0:17 = 0; 18=.33;19:20:21=.66; 22:30=1;else=NA"
pollLowEducCodes <-"0=1; c(.33,.66,1)=0; else=NA" #below highscool = 1
pollRaceVariable <-NA
pollIndiciesList <- c("t3kn_immig","t3kn_eu","t3kn_gw","t3kn_three","t3kn_six")
pollRaceCodes <-NA
pollt1know <-"t1kn"
pollt2know <-"t3kn"
pollMode <- "0" #0=ftf; 1=web
pollLRVariable<-"leftright14"

####Set scaling stuff
#eval variables need to be rescaled; even if no we need to rename and enter NAs for 
#eval vairables not in the dataset, so set eval1-15
rescale <-1
#Indicate the scaleing level for each variable
#use a 0 for variables not in this dataset 
eval5Leval=10

#set variables to the eval questions in the dataset
#use set variable to NA if not in dataset

dataset$eval1t <-dataset$v3q63
dataset$eval2t <-dataset$v3q66_4
dataset$eval3t <-dataset$v3q66_3
dataset$eval4t <-NA
dataset$eval5t <-dataset$v3q66_2
dataset$eval6t <-dataset$v3q65_3
dataset$eval7t <-dataset$v3q65_4
dataset$eval8t <-dataset$v3q65_1
dataset$eval9t <-dataset$v3q65_5
dataset$eval10t <-NA
dataset$eval11t <-dataset$v3q66_1
dataset$eval12t <-NA
dataset$eval13t <-dataset$v3q65_2
dataset$eval14t <-NA
dataset$eval15t <-dataset$v3q65_6

####Average attitude extremity and moderator facets
####Edit for each dataset!
dataset$attextreme <- rowMeans(cbind(abs(dataset$t3kn_immig -.5),abs(dataset$t3kn_eu -.5),abs(dataset$t3kn_gw -.5),abs(dataset$t3kn_three -.5),abs(dataset$t3kn_six -.5)), na.rm=TRUE)
pollModeratorFacets <- c("eval3","eval5") # each (eval3, eval4, eval5, eval12)
####Hold-over variables
####set indicies
#dataset2 <-dataset[,c("t2kn1","t2kn2","t2kn3","t2kn4","t2kn5")]
#dataset$avgsd<- rowMeans(cbind(sqrt(dataset$t2kn1),sqrt(dataset$t2kn2),sqrt(dataset$t2kn3),sqrt(dataset$t2kn4),sqrt(dataset$t2kn5))

dataset$pollid <- pollid
dataset$country <- pollCountry
dataset$mode <- pollMode
dataset$group <- dataset[,pollGroupVariable]
dataset$pollgroup <-paste(pollid,dataset$group, sep="")
for(i in 1:nrow(dataset))
	dataset$caseid[i] <-paste(pollid,10000+i, sep="")

dataset$groupsize <-unsplit(lapply(split(dataset$caseid, dataset$group),length),dataset$group)

#dataset$groupsize <- ave(seq_along(dataset$group), dataset$group, FUN=length)

####pk
dataset$t1know <- dataset[,pollt1know]
dataset$t2know <- dataset[,pollt2know]
dataset$t1knowlevel <- mean(dataset$t1know)
dataset$meant1know <- unsplit(lapply(split(dataset$t1know, dataset$group),mean,na.rm=T),dataset$group)
dataset$meant1know_ind <-((ave(dataset$t1know, dataset$group))*dataset$groupsize - dataset$t1know )/ (dataset$groupsize - 1)
dataset$lowknow <-dataset$t1know <=.3
dataset$plowknowledge <- unsplit(lapply(split(dataset$lowknow, dataset$group),mean,na.rm=T),dataset$group)
dataset$extremist <- recode(dataset[,pollLRVariable],"c(0,1)=1;c(2,3,4,5,6,7,8)=0;c(9,1)=1;else=0") 
dataset$extremeL<-recode(dataset[,pollLRVariable],"c(0,1)=1;else=0")
dataset$extremeR <- recode(dataset[,pollLRVariable],"c(9,1)=1;else=0")

dataset$pextremeL <- unsplit(lapply(split(dataset$extremeL, dataset$group),mean,na.rm=T),dataset$group)
dataset$pextremeR <- unsplit(lapply(split(dataset$extremeR, dataset$group),mean,na.rm=T),dataset$group)
dataset$pextremist <- unsplit(lapply(split(dataset$extremist, dataset$group),mean,na.rm=T),dataset$group)

####Education, Gender, Race, Income and Age
dataset$educ4 <- recode(dataset[,pollEducationVariable],pollEducationCodes)
dataset$loweduc <- recode(dataset$educ4,pollLowEducCodes)
dataset$higheduc <- recode(dataset$educ4,"1=1;c(0,.33,.66)=0;else=NA")
dataset$female<- recode(dataset[,pollSexVariable],pollSexCodes)
dataset$pfemale <- unsplit(lapply(split(dataset$female, dataset$group),mean,na.rm=T),dataset$group)

dataset$minority <- NA
dataset$pminority <-NA
if (!is.na(pollRaceVariable)){
	dataset$minority <- recode(dataset[,pollRaceVariable],pollRacecodes)
	dataset$pminority <- unsplit(lapply(split(dataset$minority, dataset$group),mean,na.rm=T),dataset$group)
	}
dataset$ploweduc <- unsplit(lapply(split(dataset$loweduc, dataset$group),mean,na.rm=T),dataset$group)
dataset$phigheduc <- unsplit(lapply(split(dataset$higheduc, dataset$group),mean,na.rm=T),dataset$group)
#dataset$income <- dataset[,pollIncomeVariable]
#dataset$lowincome <-  (dataset$income < fivenum(dataset$income)[1])
dataset$income <- NA
dataset$lowincome <-  NA
dataset$young <- recode(dataset[,pollAgeVariable],"0:25=1;26:100=0;else=NA")
dataset$pyoung <- unsplit(lapply(split(dataset$young, dataset$group),mean,na.rm=T),dataset$group)
dataset$old <- recode(dataset[,pollAgeVariable],"0:49=0;50:100=1;else=NA")
dataset$pold <- unsplit(lapply(split(dataset$old, dataset$group),mean,na.rm=T),dataset$group)
dataset$age <- dataset[,pollAgeVariable]

####Hold-over variables
sqrtvar <- function (x) {
	n <- length(x)
	ans <- sqrt((det(cov(x, use = "pairwise.complete.obs", method = c("pearson"))))^(1/n))
	ans
}

dataset2 <-dataset[,pollIndiciesList]
dataset$genvar <- unsplit(lapply(split(dataset2, dataset$group), sqrtvar),dataset$group)
dataset$vareduc <-  unsplit(lapply(split(dataset$educ4, dataset$group), function(a) var (c(a), na.rm=TRUE)), dataset$group)
dataset$sdeduc <- sqrt(dataset$vareduc)
dataset$varfemale <- (dataset$pfemale)*(1- dataset$pfemale)
dataset$sdfemale <- sqrt(dataset$varfemale)
#dataset$varage <-  unsplit(lapply(split(dataset$age, dataset$group), function(a) var (c(a), na.rm=TRUE)), dataset$group)
#dataset$sdage <- sqrt(dataset$varage)
#dataset$varincome <-  unsplit(lapply(split(dataset$income, dataset$group), function(a) var (c(a), na.rm=TRUE)), dataset$group)
#dataset$sdincome <- sqrt(dataset$income)
dataset$varage <-  NA
dataset$sdage <- NA
dataset$varincome <-  NA
dataset$sdincome <- NA

e0<-"NA=NA"
e2<-"1=0;2=1;else=NA"
e3<-"1=0;2=.5;3=1;else=NA"
e4<-"1=0;2=.33;3=.66;4=1;else=NA"
e5<-"1=0;2=.25;3=.5;4=.75;5=1;else=NA"
e10<-"1=.1;2=.2;3=.3;4=.4;5=.5;6=.6;7=.7;8=.8;9=.9;10=1;else=NA"

#recode
dataset$eval1 <- recode(dataset$eval1t,e0)
dataset$eval2 <- recode(dataset$eval2t,e0)
dataset$eval3 <- recode(dataset$eval3t,e0)
dataset$eval4 <- recode(dataset$eval4t,e0)
dataset$eval5 <- recode(dataset$eval5t,e0)
dataset$eval6 <- recode(dataset$eval6t,e0)
dataset$eval7 <- recode(dataset$eval7t,e0)
dataset$eval8 <- recode(dataset$eval8t,e0)
dataset$eval9 <- recode(dataset$eval9t,e0)
dataset$eval10 <- recode(dataset$eval10t,e0)
dataset$eval11 <- recode(dataset$eval11t,e0)
dataset$eval12 <- recode(dataset$eval12t,e0)
dataset$eval13 <- recode(dataset$eval13t,e0)
dataset$eval14 <- recode(dataset$eval14t,e0)
dataset$eval15 <- recode(dataset$eval15t,e0)



####Mean moderator score if any are present
#invert eval5 

	dataset$eval5GtoB <-NA
	sv<-eval5Leval

	if(sv=="2")
		dataset$eval5GtoB <- recode(dataset$eval5,"0=1;1=0;else=NA")
	if(sv=="3")
		dataset$eval5GtoB <- recode(dataset$eval5,"0=1;.5=.5;1=0;else=NA")
	if(sv=="4")
		dataset$eval5GtoB <- recode(dataset$eval5,"0=1;1=0;.33=.66;.66=.33;else=NA")
	if(sv=="5")
		dataset$eval5GtoB <- recode(dataset$eval5,"0=1;1=0;.25=.75;.5=.5;.75=.25;else=NA")
	if(sv=="10")
		dataset$eval5GtoB <- recode(dataset$eval5,"0=1;1=0;.1=.9;.2=.8;.3=.7;.4=.6;.5=.5;.6=.4;.7=.3;.8=.2;.9=.1;else=NA")

	
dataset$meanmodscore <-NA


dataset$meanmodscore <-((dataset$eval3 +dataset$eval5GtoB)/2)


dataset$eval15D <- recode(dataset$eval15,"0:.4=0;.5:1=1;else=NA")

####add NAs
dataset$length <-NA
dataset$numindicies <-NA

####Create poll dummy variables
dataset$isbrazil<-0
dataset$isbulgaria <-0
dataset$ischina05 <-0
dataset$iseu09 <-1

####only select variables of interest

eu09 <- dataset[, c("pollid","country","mode","pollgroup","caseid","groupsize","t1know","t2know","t1knowlevel","meant1know","meant1know_ind","plowknowledge","educ4","loweduc","female","pfemale","minority","pminority","ploweduc","income","lowincome","eval1","eval2","eval3","eval4","eval5","eval6","eval7","eval8","eval9","eval10","eval11","eval12","eval13","eval14","eval15","meanmodscore","length","numindicies","genvar","vareduc","sdeduc","varfemale","sdfemale","varage","sdage","varincome","sdincome","eval5GtoB","eval15D","lowknow","extremist","pextremist","higheduc","phigheduc","young","old","pyoung","pold","age","isbrazil","isbulgaria","ischina05","iseu09","pextremeL","pextremeR","extremeR","extremeL")]


####save
save(eu09, file="recoded_eu09.rdata", ascii=TRUE)
summary(eu09)
