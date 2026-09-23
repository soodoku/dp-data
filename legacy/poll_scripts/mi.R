#
#  Michigan
#  Last Edited: 5.23.14   
#  Gaurav Sood
#

# Set Working dir 
setwd(basedir)

# Load libs
library(car)
library(goji)

# Sourcing Common Functions
source("func/func.R")
source("cdd/hlmFunc.R")
source("func/match.R")

# Load data
## T1 
load("cdd/data/Michigan/data/mi.rdata")
load("cdd/data/Michigan/data/nonpart.rdata")

## T2 
load("cdd/data/Michigan/data/arrive.rdata")

## T3
load("cdd/data/Michigan/data/sunday.rdata")

names(sunday)[2] <- "partid"
names(arrive)[2] <- "partid"

sum(duplicated(mi$postit[!is.na(mi$postit)]))
sum(duplicated(sunday$partid))
sum(duplicated(arrive$partid))
nrow(mi[!is.na(mi$postit),])

#Mi - postit
# cbind(mi$postit, arrive$partid)
# cbind(sort(arrive$partid), sort(as.numeric(sunday$partid)))
# David Bell, 301
# Arrival has it, 
 
misunday<- merge(mi, sunday, by.x="postit", by.y="partid") 
misunarrive <- merge(misunday, arrive, by.x="postit", by.y="partid", all.x=T) 
mifin <- plyr::rbind.fill(misunarrive, nonpart)
save(mifin, file="cdd/data/Michigan/data/mifin.rdata", ascii=T)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load data 
load("cdd/data/Michigan/data/mifin.rdata")

#### Qs38-42 in T2/T3 dataset and Q14-18 in T1

mi6 <- mifin[1:310,]

# Knowledge
# ~~~~~~~~~~~~

#t1 know
mi6$t1q14raw <- recode(mi6$q14, "2=1;1=0;99=NA") #2 Republican
mi6$t1q15raw <- recode(mi6$q15, "1=1;2=0;99=NA") #1 Democrat
mi6$t1q16raw <- recode(mi6$q16, "1=1;c(2,3,4)=0;c(98,99)=NA") #1 Oregon
mi6$t1q17raw <- recode(mi6$q17, "1=1;c(2,3,4)=0;c(98,99)=NA") #1 Live in a county
mi6$t1q18raw <- recode(mi6$q18, "3=1;c(1,2,4)=0;c(98,99)=NA") #3 About 40%

# no NA version
t1five <- paste0("t1q", 14:18, "c")
mi6[,t1five]<- nona(mi6[,paste0("t1q", 14:18, "raw")])

# Agg. index
mi6$t1know <- rowMeans(mi6[,t1five])

# t2
mi6$t2q38raw <- recode(clean(mi6$t2q38), 'c("houseofrep", "rep", "repbulican",  "republican", "republicans", "repubs", "gop", "rethuglican", "r", "rpublicans")=1; 
c("cantrecall", "", "cantsay", "couldntsay", "donotknow", "dontcare", "dontknow", "dontknowcantrememeber", "idk", "idontknow", "n", "na", "next", "no", "noidea", "notsure", "unsure", "unknown", "so")=NA') #2 Republican

mi6$t2q38raw[grep("don", mi6$t2q38raw)] <- NA
mi6$t2q38raw[grep("cou", mi6$t2q38raw)] <- NA
mi6$t2q38raw[!is.na(mi6$t2q38raw) & mi6$t2q38raw!=1] <- 0
mi6$t2q38raw <- as.numeric(mi6$t2q38raw)

mi6$t2q39raw <- recode(clean(mi6$t2q39), 'c("houseofrep", "replubican", "republic", "republivan", "rep", "repbulican",  "republican", "republicans", "repubs", "gop", "rethuglican", "r", "rpublicans")=0; 
   c("cantrecall", "", "cantremember", "dk", "iignoredit", "cantsay", "couldntsay", "donotknow", "dontcare", "dontknow", "dontknowcantrememeber", "idk", "idontknow", "n", "na", "next", "no", "noidea", "notsure", "unsure", "unknown", "so")=NA') #2 Republican

mi6$t2q39raw[grep("don", mi6$t2q39raw)] <- NA
mi6$t2q39raw[!is.na(mi6$t2q39raw) & mi6$t2q39raw!="0"] <- 1
mi6$t2q39raw <- as.numeric(mi6$t2q39raw)

mi6$t2q40raw <- as.numeric(recode(mi6$t2q40, "'a'=1;c('b','c','d', 'C', 'e')=0;'NA'=NA"))#1 Oregon
mi6$t2q41raw <- as.numeric(recode(mi6$t2q41, "'a'=1;c('b','c','d', 'E', 'e')=0;'NA'=NA")) #1 Live in a county
mi6$t2q42raw <- as.numeric(recode(mi6$t2q42, "'c'=1;c('a','b','d', 'D', 'e')=0;'NA'=NA")) #3 About 40%

# no NA version
t2five <- paste0("t2q", 38:42, "c")
mi6[,t2five]<- nona(mi6[,paste0("t2q", 38:42, "raw")])

# t3
mi6$t3q38raw <- recode(clean(mi6$t3q38), 'c("houseofrep", "repgop", "repub","republic", "republicanparty", "rep", "repbulican",  "republican", "republicans", "repubs", "gop", "rethuglican", "r", "rpublicans")=1; 
c("cantrecall", "", "unknow", "nest", "cantsay", "couldntsay", "donotknow", "dontcare", "dontknow", "dontknowcantrememeber", "idk", "idontknow", "n", "na", "next", "no", "noidea", "notsure", "unsure", "unknown", "so")=NA') #2 Republican

mi6$t3q38raw[grep("don", mi6$t3q38raw)] <- NA
mi6$t3q38raw[grep("cou", mi6$t3q38raw)] <- NA
mi6$t3q38raw[!is.na(mi6$t3q38raw) & mi6$t3q38raw!=1] <- 0
mi6$t3q38raw <- as.numeric(mi6$t3q38raw)

mi6$t3q39raw <- recode(clean(mi6$t3q39), 'c("houseofrep", "reb", "repgop", "repub","republic", "repiblican", "republicanparty", "rep", "repbulican",  "republican", "republicans", "repubs", "gop", "rethuglican", "r", "rpublicans")=0; 
c("cantrecall", "", "cannotsay", "38", "sc", "unknow", "nest", "cantsay", "couldntsay", "donotknow", "dontcare", "dontknow", "dontknowcantrememeber", "idk", "idontknow", "n", "na", "next", "no", "noidea", "notsure", "unsure", "unknown", "so")=NA') #2 Republican

mi6$t3q39raw[grep("don", mi6$t3q39raw)] <- NA
mi6$t3q39raw[!is.na(mi6$t3q39raw) & mi6$t3q39raw!="0"] <- 1
mi6$t3q39raw <- as.numeric(mi6$t3q39raw)

mi6$t3q40raw <-  as.numeric(recode(mi6$t3q40, "c('a', 'A')=1; c('b','c','d', 'B', 'C', 'e', 'E')=0;'NA'=NA")) #1 Oregon
mi6$t3q41raw <-  as.numeric(recode(mi6$t3q41, "c('a', 'A')=1; c('b', 'B', 'c', 'C', 'd', 'D', 'E', 'e')=0;'NA'=NA")) #1 Live in a county
mi6$t3q42raw <-  as.numeric(recode(mi6$t3q42, "c('c', 'C')=1; c('a', 'A', 'b', 'B', 'd', 'D', 'e', 'E', 'F')=0;'NA'=NA")) #3 About 40%

# no NA version
t3five <- paste0("t3q", 38:42, "c")
mi6[,t3five]<- nona(mi6[,paste0("t3q", 38:42, "raw")])

### Party Placement
 #t2q6t3q6 
#t2q7t3q7 D (1 to 3 D)
#t2q8t3q8 R (5 to 7 R)
#t2q9t3q9  
#t2q10t3q10 D (5 to 7 D)
#t2q11t3q11 R (1 to 3 R)
#t2q12t3q12 
#t2q13t3q13 D (1 to 3 D)
#t2q14t3q14 R (5 to 7 R)

a <- "c(1,2,3)= 1; c(4,5,6,7)=0; c(98,99)=NA"
b <- "c(1,2,3,4)= 0; c(5,6,7)=1; c(98,99)=NA"
mi6$t2q7c <- recode(mi6$t2q7, a)
mi6$t3q7c <- recode(mi6$t3q7, a)
mi6$t2q8c <- recode(mi6$t2q8, b)
mi6$t3q8c <- recode(mi6$t3q8, b)

mi6$t2q10raw<- recode(mi6$t2q10, b)
mi6$t3q10raw<- recode(mi6$t3q10, b)
mi6$t1q4raw<- recode(mi6$q4, b)

mi6$t2q11raw<- recode(mi6$t2q11, a)
mi6$t3q11raw<- recode(mi6$t3q11, a)
mi6$t1q5raw <- recode(mi6$q5, a)

mi6$t2q13raw <- recode(mi6$t2q13, a)
mi6$t3q13raw<- recode(mi6$t3q13, a)
mi6$t1q7raw <- recode(mi6$q7, a)

mi6$t2q14raw <- recode(mi6$t2q14, b)
mi6$t3q14raw <- recode(mi6$t3q14, b)
mi6$t1q8raw <- recode(mi6$q8, b) 

# no NA version
place <- c("t1q4c", "t1q5c", "t1q7c", "t1q8c", paste0(c("t2q", "t3q"), rep(c(10,11,13,14),each=2), "c"))
mi6[,place]<- nona(mi6[,c("t1q4raw", "t1q5raw", "t1q7raw", "t1q8raw", paste0(c("t2q", "t3q"), rep(c(10,11,13,14),each=2), "raw"))])

mi6$t2place <- rowMeans(cbind(mi6$t2q7c, mi6$t2q8c, mi6$t2q10c, mi6$t2q11c, mi6$t2q13c, mi6$t2q14c))
mi6$t3place <- rowMeans(cbind(mi6$t3q7c, mi6$t3q8c, mi6$t3q10c, mi6$t3q11c, mi6$t3q13c, mi6$t3q14c))

## Only t1 items placement
mi6$t1place <- with(mi6, rowMeans(cbind(t1q4c, t1q5c, t1q7c, t1q8c)))
mi6$t2placesub<- with(mi6, rowMeans(cbind(t2q10c, t2q11c, t2q13c, t2q14c)))
mi6$t3placesub<- with(mi6, rowMeans(cbind(t3q10c, t3q11c, t3q13c, t3q14c)))

mi6$t2know2 <- with(mi6, rowMeans(cbind(t2q38c, t2q39c, t2q40c, t2q41c, t2q42c, t2q7c, t2q8c, t2q10c, t2q11c, t2q13c, t2q14c)))
mi6$t3know2 <- with(mi6, rowMeans(cbind(t3q38c, t3q39c, t3q40c, t3q41c, t3q42c, t3q7c, t3q8c, t3q10c, t3q11c, t3q13c, t3q14c)))

### Net placement plus pk, each time point
mi6$t1knownet <- with(mi6, rowMeans(cbind(t1q14c, t1q15c, t1q16c, t1q17c, t1q18c, t1q4c,  t1q5c,  t1q7c,  t1q8c)))
mi6$t2knownet <- with(mi6, rowMeans(cbind(t2q38c, t2q39c, t2q40c, t2q41c, t2q42c, t2q10c, t2q11c, t2q13c, t2q14c)))
mi6$t3knownet <- with(mi6, rowMeans(cbind(t3q38c, t3q39c, t3q40c, t3q41c, t3q42c, t3q10c, t3q11c, t3q13c, t3q14c)))


# Output for pk
# Agg indices
t1raw <- c(paste0("t1q", 14:18, "raw"), "t1q4raw", "t1q5raw", "t1q7raw", "t1q8raw")
t3raw <- c(paste0("t3q", 38:42, "raw"), paste0("t3q", c(10,11,13,14), "raw"))

t1 <- c(paste0("t1q", 14:18, "c"), "t1q4c", "t1q5c", "t1q7c", "t1q8c")
t3 <- c(paste0("t3q", 38:42, "c"), paste0("t3q", c(10,11,13,14), "c"))

mi6[,t1] <- nona(mi6[,t1raw])
mi6[,t3] <- nona(mi6[,t3raw])

mi6$female <- mi6$q43==2

miirt <- mi6[, c(t1, t3, t1raw, t3raw, "female")]

write.csv(miirt, file="guess/data/bypoll/miirt.csv")



# Analyses
# Outputting the Knowledge gain
quesv <- c("Majority party in the Michigan State Senate", "Majority party in the Michigan State House of Representatives", "State similar unemployment rate to MI","Eligibility condition if 48-month limit reached for the Family Independence Program","Percentage of African American children in Michigan live in poverty", "pk index", "Dem - Standard of living","Rep - Standard of living","Dem - Taxes","Rep - Taxes","Dem - Unemployment","Rep - Unemployment","placement pk", "placement pk with t1 items only", "net pk index", "net pk with t1 place only")

pkfun <- function(x,y,z){
if(sum(x)>0){
yx <- t.test(y,x, alternative="greater",  conf.level = 0.95, paired = T)
zy <- t.test(z,y, alternative="greater",  conf.level = 0.95, paired = T)
zx <- t.test(z,x, alternative="greater",  conf.level = 0.95, paired = T)
round(c(mean(x), mean(y), mean(y-x), yx$p.value, mean(z), zy$est, zy$p.val, zx$est, zx$p.val),3)
}
else {
zy <- t.test(z,y, alternative="greater",  conf.level = 0.95, paired = T)
round(c(0, mean(y), 0, 0, mean(z), zy$est, zy$p.val, 0, 0),3)
}
}

# Output
t.test(mi6$t3q38c, mi6$t2q38c)
res <- NA
res <- data.frame(quesv=quesv, t1=NA, t2=NA, difft2t1=NA, pt1t2=NA, t3=NA, difft3t2=NA, pt3t2=NA, difft3t1=NA, pt3t1=NA)
res[1,(2:10)] <- pkfun(mi6$q14c, mi6$t2q38c, mi6$t3q38c)
res[2,(2:10)] <- pkfun(mi6$q15c, mi6$t2q39c, mi6$t3q39c)
res[3,(2:10)] <- pkfun(mi6$q16c, mi6$t2q40c, mi6$t3q40c)
res[4,(2:10)] <- pkfun(mi6$q17c, mi6$t2q41c, mi6$t3q41c)
res[5,(2:10)] <- pkfun(mi6$q18c, mi6$t2q42c, mi6$t3q42c)
res[6,(2:10)] <- pkfun(mi6$t1know, mi6$t2know, mi6$t3know)
res[7,(2:10)] <- pkfun(0, mi6$t2q7c, mi6$t3q7c)
res[8,(2:10)] <- pkfun(0, mi6$t2q8c, mi6$t3q8c)
res[9,(2:10)] <- pkfun(mi6$q4c, mi6$t2q10c, mi6$t3q10c)
res[10,(2:10)] <- pkfun(mi6$q5c, mi6$t2q11c, mi6$t3q11c)
res[11,(2:10)] <- pkfun(mi6$q7c, mi6$t2q13c, mi6$t3q13c)
res[12,(2:10)] <- pkfun(mi6$q8c, mi6$t2q14c, mi6$t3q14c)
res[13,(2:10)] <- pkfun(0, mi6$t2place, mi6$t3place)
res[14,(2:10)] <- pkfun(mi6$t1place, mi6$t2placesub, mi6$t3placesub)
res[15,(2:10)] <- pkfun(0, mi6$t2know2, mi6$t3know2)
res[16,(2:10)] <- pkfun(mi6$t1knownet, mi6$t2knownet, mi6$t3knownet)

write.table(res, sep=",", col.names=T, row.names=F, file="cdd/data/Michigan/pkmi.csv")


# Previous Work

mi6$t2q38c <- mi6$t2q39c <-  mi6$t3q38c <- mi6$t3q39c <- 0 #Declaring some vars

# t2 know
mi6$t2q38c[grep("R", mi6$t2q38)] <- 1
mi6$t2q39c[grep("D", mi6$t2q39)] <- 1
mi6$t2q39c[grep("Don", mi6$t2q39)] <- 0
mi6$t2q40c <- (mi6$t2q40=="a")
mi6$t2q40c[is.na(mi6$t2q40c)] <- 0
mi6$t2q41c <- (mi6$t2q41=="a")
mi6$t2q41c[is.na(mi6$t2q41c)] <- 0
mi6$t2q42c <- (mi6$t2q42=="c")
mi6$t2q42c[is.na(mi6$t2q42c)] <- 0

mi6$t2know <- rowMeans(cbind(mi6$t2q38c, mi6$t2q39c, mi6$t2q40c, mi6$t2q41c, mi6$t2q42c))

mi6$t3q38c[grep("R", mi6$t3q38)] <- 1
mi6$t3q39c[grep("D", mi6$t3q39)] <- 1
mi6$t3q39c[grep("Don", mi6$t3q39)] <- 0
mi6$t3q40c <- (mi6$t3q40=="a")
mi6$t3q41c <- (mi6$t3q41=="a")
mi6$t3q42c <- (mi6$t3q42=="c")

mi6$t3know <- rowMeans(cbind(mi6$t3q38c, mi6$t3q39c, mi6$t3q40c, mi6$t3q41c, mi6$t3q42c))
