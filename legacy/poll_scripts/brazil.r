#to use this file set the filenames on lines 8 & 9
#then plug in variable names, and recoding values on lines 24-38,44,48-62,66-67 & 70-71

library(foreign)
library(car)
#set filenames
rfile<-"/Udadpeval/brazil.rdata"
spssfile<-"/Users/seanwestwood/Desktop/dpeval/brazil.sav"


####Config stuff
#load dateset
dataset<- read.spss("/Users/seanwestwood/Desktop/dpeval/brazil.sav", use.value.labels = FALSE)
dataset <- as.data.frame(dataset)
names(dataset) <- tolower(names(dataset))

#save(dataset, file="/Users/seanwestwood/Desktop/dpeval/brazil.rdata", ascii=TRUE)

####set variables
pollid<-"50"
pollCountry<-"5"
pollGroupVariable<-"grupo"
pollSexVariable <-"sexo"
pollAgeVariable <-"v74_"
pollSexCodes <- "c(1)=0; c(2)=1" #recode 0=male; 1=femlae
pollIncomeVariable <-"renda_familiar"
pollEducationVariable<-"escolaridade"
pollEducationCodes<-"c(1,2,3) = 0; c(4)=.33; c(5)=.66;c(6)=1"
pollLowEducCodes <-"c(0) = 1; c(.33,.66,1)=0;else=NA" #below highscool = 1
pollRaceVariable <-NA
pollIndiciesList <- c("t2kn1","t2kn2","t2kn3","t2kn4","t2kn5")
pollRaceCodes <-NA
pollt1know <-"t1kn"
pollt2know <-"t2kn"
pollMode <- "0" #0=ftf; 1=web
pollLRVariable<-"leftright14"

####Set scaling stuff
#eval variables need to be rescaled; even if no we need to rename and enter NAs for 
#eval vairables not in the dataset, so set eval1-15
rescale <-1
#Indicate the scaleing level for each variable
#use a 0 for variables not in this dataset 
#1=2, 2=3, 3=4, 4=5, 5=10 (levels=levelcode)
eval5Leval=5

#set variables to the eval questions in the dataset
#use set variable to NA if not in dataset

dataset$eval1t <-dataset$eval12
dataset$eval2t <-dataset$eval10
dataset$eval3t <-dataset$eval8
dataset$eval4t <-dataset$eval5
dataset$eval5t <-dataset$eval7
dataset$eval6t <-NA
dataset$eval7t <-dataset$eval4
dataset$eval8t <-dataset$eval2
dataset$eval9t <-dataset$eval13
dataset$eval10t <-dataset$eval9
dataset$eval11t <-dataset$eval6
dataset$eval12t <-NA
dataset$eval13t <-dataset$eval3
dataset$eval14t <-dataset$eval11
dataset$eval15t <-dataset$eval1

####Average attitude extremity and moderator facets
####Edit for each dataset!
dataset$attextreme <- rowMeans(cbind(abs(dataset$t2kn1 -.5),abs(dataset$t2kn2 -.5),abs(dataset$t2kn3 -.5),abs(dataset$t2kn4 -.5),abs(dataset$t2kn5 -.5)), na.rm=TRUE)
pollModeratorFacets <- 3 #count each (eval3, eval4, eval5, eval12)
####Hold-over variables
####set indicies
#dataset2 <-dataset[,c("t2kn1","t2kn2","t2kn3","t2kn4","t2kn5")]
#dataset$avgsd<- rowMeans(cbind(sqrt(dataset$t2kn1),sqrt(dataset$t2kn2),sqrt(dataset$t2kn3),sqrt(dataset$t2kn4),sqrt(dataset$t2kn5))

dataset$pollid <- pollid
dataset$country <- pollCountry
dataset$mode <- pollMode
dataset$group <- dataset[,pollGroupVariable]
dataset$pollgroup <-paste(pollid,dataset$group, sep = "")
for(i in 1:nrow(dataset))
	dataset$caseid[i] <-paste(pollid,10000+i, sep = "")

dataset$groupsize <- ave(seq_along(dataset$group), dataset$group, FUN=length)

####pk
dataset$t1know <- dataset[,pollt1know]
dataset$t2know <- dataset[,pollt2know]
dataset$t1knowlevel <- mean(dataset$t1know)
dataset$meant1know <- unsplit(lapply(split(dataset$t1know, dataset$group),mean,na.rm=T),dataset$group)
dataset$meant1know_ind <-((ave(dataset$t1know, dataset$group))*dataset$groupsize - dataset$t1know )/ (dataset$groupsize - 1)
dataset$lowknow <-dataset$t1know <=.3
dataset$plowknowledge <- unsplit(lapply(split(dataset$lowknow, dataset$group),mean,na.rm=T),dataset$group)
dataset$opinionminority <- NA#recode(dataset[,pollLRVariable],"c(0,1,2)=1;c(3,4,5,6,7)=0;c(8,9,1)=1;else=NA") #recode
dataset$popinionminority <- NA#ave(as.numeric(dataset$opinionminority),dataset$group)

####Education, Gender, Race, Income and Age
dataset$educ4 <- recode(dataset[,pollEducationVariable],pollEducationCodes)
dataset$loweduc <- recode(dataset$educ4,pollLowEducCodes)
dataset$higheduc <- recode(dataset$educ4,"1=1;0=0;else=NA")
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
dataset$income <- dataset[,pollIncomeVariable]
dataset$lowincome <-  (dataset$income < fivenum(dataset$income)[1])
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

dataset$eval1 <- recode(dataset$eval1t,e5)
dataset$eval2 <- recode(dataset$eval2t,e0)
dataset$eval3 <- recode(dataset$eval3t,e0)
dataset$eval4 <- recode(dataset$eval4t,e0)
dataset$eval5 <- recode(dataset$eval5t,e0)
dataset$eval6 <- recode(dataset$eval6t,e0)
dataset$eval7 <- recode(dataset$eval7t,e0)
dataset$eval8 <- recode(dataset$eval8t,e0)
dataset$eval9 <- recode(dataset$eval9t,e5)
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

	


dataset$meanmodscore <- ((dataset$eval4+dataset$eval5GtoB+dataset$eval12)/3)

dataset$eval15D <- recode(dataset$eval15,"0:.4=0;.5:1=1;else=NA")

####add NAs
dataset$length <-NA
dataset$numindicies <-NA

####Create poll dummy variables
dataset$isbrazil<-1
dataset$isbulgaria <-0
dataset$ischina05 <-0
dataset$iseu09 <-0

####only select variables of interest

brazil <- dataset[, c("pollid","country","mode","pollgroup","caseid","groupsize","t1know","t2know","t1knowlevel","meant1know","meant1know_ind","plowknowledge","educ4","loweduc","female","pfemale","minority","pminority","ploweduc","income","lowincome","eval1","eval2","eval3","eval4","eval5","eval6","eval7","eval8","eval9","eval10","eval11","eval12","eval13","eval14","eval15","meanmodscore","length","numindicies","genvar","vareduc","sdeduc","varfemale","sdfemale","varage","sdage","varincome","sdincome","eval5GtoB","eval15D","lowknow","opinionminority","popinionminority","higheduc","phigheduc","young","old","pyoung","pold","age","isbrazil","isbulgaria","ischina05","iseu09")]



####save
save(brazil, file="recoded_brazil.rdata", ascii=TRUE)
summary(brazil)