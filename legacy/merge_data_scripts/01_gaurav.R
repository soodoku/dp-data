#
# Aggregate Gaurav DP Polls Data
#	

# Set Working dir.
setwd(basedir)

# Load All of Gaurav data (in pkdat dir.)
for(i in dir("cdd/data/pkdat/")){load(paste0("cdd/data/pkdat/", i))}
	
# R Bind
gaurav1 <- rbind(healthybrits, ausn, monarchyn, ukeun, ukbgen, ukcrimen, eun, cplr, bulgaria.crm, swepcon, wtun, chinan, greecen, nic1n, eu2009)

gaurav1[,c("t1knowr", "grpgainr", "t1knowrcor", "t2knowr")] <- NA
	
# Common Subset
commoncols <- c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems", "pollgroup",
                "groupsize", "avgsd", "numindices", "genvar", "readbrief","t1know",
                "t1knowr", "t1knowcor", "grpgain", "t2know", "ppage", "educ4","minority",
                "hhincome","female","attextreme", "highinc","t1polint", "avgsd2", 
				"grpgain2", "t1knowcor2", "t12know", "t12knowcor", "attextreme2","length",
				"timebtw", "grpgainr", "t1knowrcor", "t2knowr")

gaurav <- subset(gaurav1, select = commoncols)

# Save data
save(gaurav, file = "cdd/data/pkdat/gaurav.Rdata")
