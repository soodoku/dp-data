#
# Common Functions 
# 

# Recoder Function

recoder <- function(x, expected.min=0, expected.max){
  y <- eval(parse(text=x))  
  y[y < expected.min | y > expected.max] <- NA # If value exceeds expected max, or is lower than expected min, assign to NA
  name <- paste(x, "r", sep="")
  y01 <- (y - expected.min)/(expected.max - expected.min)
  assign(name, y01, envir = .GlobalEnv)
}

## Function to Correct for Guessing. Codes to 0 if someone is right at t1 but wrong at t2 or t3
pkcor <- function(t1pk, t2pk, t3pk=NULL)
{
  temp <- t1pk
  temp[t1pk==1 & t2pk==0] <- 0  
  temp[t1pk==1 & t3pk==0] <- 0
  temp
}

## same error
same <- function(var1, var2, corr, group){
  var <- as.numeric(var1==var2)
  unsplit(lapply(split(var, group), function(a) mean (c(a), na.rm=TRUE)), group)
}

same.err <- function(var1, var2, corr, group){
  var <- NA
  var[var1!=corr] <- as.numeric(var1==var2)[var1!=corr]
  unsplit(lapply(split(var, group), function(a) mean (c(a), na.rm=TRUE)), group)
}

## Poll Group Maker; Ensures Group has 2 digits, and adds to pollid
pgroup <- function(group, pollid){
  temp <- as.numeric(group); ans <- rep(NA, length(temp))
  for(i in 1:length(temp)){
    if(!is.na(temp[i]) & temp[i] > 0){
      if(temp[i] < 10) { 
        ans[i] <- as.numeric(paste(pollid[1], "0", temp[i], sep=""))
      }
      if(temp[i] >= 10){  ans[i] <- as.numeric(paste(pollid[1], temp[i], sep=""))}
    }
  }
  ans
}

## Function for Group Gain
groupgain <- function(knowindex, group, numrow, numitems, grpsize) 
{
  # Initializing data frame
  groupmean <-  as.data.frame(matrix(rep(0, numrow*length(knowindex)), nrow=numrow, ncol=length(knowindex)))
  # Initializing column with data.frame number of rows
  netmean <-c(rep(0, numrow))
  #For all the knowledge items
  for(i in 1:length(knowindex)) 
  {
    #Group's mean score on the item 
    groupmean[,i] <- unsplit(lapply(split(knowindex[,i], group), function(a) mean (c(a), na.rm=TRUE)), group)
    #For all rows
    for(j in 1:numrow) 
    {
      if(!knowindex[j,i]) #if item not answered correctly, group mean of the jth item
        netmean[j] <- netmean[j] + (groupmean[j,i]*grpsize[j]) /(numitems[j]*(grpsize[j] -1))
      else netmean[j] <- netmean[j] + 0
    }
  }
  netmean
}

## Group Sum, Mean and Variance Functions
grpfun <- function(var, group, fun){
  t.var <- var[!is.na(group)]
  t.grp <- group[!is.na(group)]
  ans <- rep(NA, length(group))
  if(fun=="var") {ans[!is.na(group)] <- unsplit(lapply(split(t.var, t.grp), function(a) var (c(a), na.rm=TRUE)), t.grp)}
  if(fun=="mean"){ans[!is.na(group)] <- unsplit(lapply(split(t.var, t.grp), function(a) mean (c(a), na.rm=TRUE)), t.grp)}
  if(fun=="sum") {ans[!is.na(group)] <- unsplit(lapply(split(t.var, t.grp), function(a) sum (c(a), na.rm=TRUE)), t.grp)}
  ans
}

# Kyu Tester
minmax0 <- function(df) {

  good <- "good"
  bad  <- "bad"
  summary <- NA
  for(i in 1:length(df)){
    if(fivenum(df[,i])[1]==0 & fivenum(df[,i])[5]==1) summary[i] <- good
    else summary[i] <- bad
  }
  summary
}
