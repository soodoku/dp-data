#Northern Ireland
#8/13/09

#Participants - 124
#At t3 - 93 participants, and 150 post-test control grp are measured
#Group Variable - grp
#Filter variable - many (see below)

###################
###Importing Data

nireland <- read.dta(file="data/CDD/Ireland/orig_data/nireland.dta", convert.dates = TRUE, convert.factors = TRUE,
         missing.type = TRUE,
         convert.underscore = FALSE, warn.missing.labels = FALSE)
names(nireland)

#######Merging Ireland data with group data
ireland_grp <- read.table("data/CDD/Ireland/groups.csv", header=TRUE, sep=",",  stringsAsFactors = default.stringsAsFactors(), na.strings = "NA", strip.white = TRUE, fill = TRUE)
#cserial = X112084
#grp variable = N
ireland_grp$cserial <- ireland_grp$X112084
nireland_merged <- merge(nireland, ireland_grp, by="cserial", all.x=TRUE, all=FALSE)
nireland_merged$grp <- as.numeric(nireland_merged$N)
save(nireland_merged, file="data/CDD/Ireland/Clean/nireland_merged.rdata", ascii=TRUE)

#######Filter Variables
######################

nireland_merged$acceptndecliners == 0 #Accepters
nireland_merged$acceptndecliners == 0 #Decliners
!is.na(noshow) & nireland_merged$noshow ==1 ##No Show
!is.na(attend) & nireland_merged$attend ==1 ##Participant
!is.na(filter) & nireland_merged$filter ==0 #Non Participants

#Creating control group filter

nireland_merged$control <- (!is.na(nireland_merged$cgq36))
##Control Group is only at time 3. Time 3 variable -
nireland_merged$time3r <- as.numeric(!is.na(nireland_merged$time3))


############################################################
###Matching time1, time2, and time3 policy attitude variables

t1q11are t2q1a/10	 t3q1c/10
t1q11bre t2q1b/10	 t3q1d/10
t1q11cre t2q1c/10	t3q1e/10
t1q11dre t2q1d/10	t3q1f/10
t1q11ere t2q1e/10	t3q1g/10
t1q11fre t2q1f/10	t3q2a/10
t1q11gre t2q1gre	t3q2b/10

t1q12are t2q2are	t3q2c/10
t1q12bre t2q2b/10	
t1q12cre t2q2c/10	

t1q13are t2q3are	t3q3a/10
t1q13bre t2q3b/10	t3q3b/10
t1q13cre t2q3c/10	t3q3c/10

t1q14are t2q4are	
t1q14bre t2q4bre	
t1q14cre t2q4cre	 t3q4c/10

t1q15are t2q5are	
t1q15bre t2q5b/10	t3q5b/10
t1q15cre t2q5c/10	
t1q15dre t2q5d/10	
t1q15ere t2q5e/10	
t1q15fre t2q5f/10	
t1q15gre t2q5g/10	 t3q5g/10

t1q16are t2q6are	t3q6a/10
t1q16bre t2q6bre	t3q6b/10

t1q17are t2q7are	t3q7a/10
t1q17bre t2q7b/10	 t3q7b/10
t1q17cre t2q7c/10	t3q7c/10

t1q18are t2q8are	t3q8a/10
t1q18bre t2q8bre	t3q8b/10

t1q19are t2q9are	t3q9a/10
t1q19bre t2q9bre	t3q9b/10

t1q20are t2q10are	
t1q20cre t2q10bre	

###Sociodem
female ==1,0


#Political Knowledge

nireland_merged$t2pk =  rowMeans(cbind(nireland_merged$t2q12ans,  nireland_merged$t2q13ans,  nireland_merged$t2q14ans,  nireland_merged$t2q15ans, nireland_merged$t2q16ans, nireland_merged$t2q17ans), na.rm=TRUE)
save(nireland_merged, file="data/CDD/Ireland/Clean/nireland_merged.rdata", ascii=TRUE)


