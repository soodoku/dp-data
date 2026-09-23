#
# Aggregate Nuri DP Polls Data
#

# Set Working dir.
setwd(basedir)

# Load libs
library(plyr)

# Load data
# n <- foreign::read.dta("pk/data/nuri/2004GE_hlm.dta")
load("cdd/data/nuri/agg_nuri_caseid.rdata")
nuri1 <- agg_nuri_caseid
#names(nuri1)

# Rename things
names(nuri1)[names(nuri1) == "t1know_cor"]  = "t1knowcor"
names(nuri1)[names(nuri1) == "t12know_cor"] = "t12knowcor"

# Genvar
newhaven <- nuri1[,c("t1endexp","t1manvol","t1volloc")]
nuri1$genvar1 <- unsplit(lapply(split(newhaven, nuri1$pollgroup), genvar),nuri1$pollgroup)

nic2     <- nuri1[,c("t1usseca","t1humrh2","t1envir","t1inter","t1multi","t1demo","t1forai1","t1global","t1trade_b")]
nuri1$genvar2 <- unsplit(lapply(split(nic2, nuri1$pollgroup), genvar),nuri1$pollgroup)

btp03    <- nuri1[,c("olt1usseca","olt1humrh2","olt1envir","olt1inter","olt1multi","olt1demo","olt1forai1", "olt1global","olt1trade")]
nuri1$genvar3 <- unsplit(lapply(split(btp03, nuri1$pollgroup), genvar),nuri1$pollgroup)

btp04    <- nuri1[,c("w4b42","w4b45","w4b48","w4b51","w4b54","w4b57")]
nuri1$genvar4<-unsplit(lapply(split(btp04, nuri1$pollgroup), genvar),nuri1$pollgroup)

btp05    <- nuri1[,c("t1reform","t1fcvsch","t1mmtaxe","t1stest","t1testsl", "t1nclb",  "t1govinv","t1medqual","t1costcov","t1emplypay","t1indivpay")]
nuri1$genvar5<-unsplit(lapply(split(btp05, nuri1$pollgroup), genvar),nuri1$pollgroup)

sanmateo <- nuri1[,c("t1more", "t1belowmrkt","t1openspace","t1lesscommute","t1consult","t1countyl","t1countys")]
nuri1$genvar6 <- unsplit(lapply(split(sanmateo, nuri1$pollgroup), genvar),nuri1$pollgroup)

nuri1$genvar <- NA
nuri1[nuri1$pollid == 91, ]$genvar <- nuri1[nuri1$pollid == 91, ]$genvar1
nuri1[nuri1$pollid == 92, ]$genvar <- nuri1[nuri1$pollid == 92, ]$genvar2
nuri1[nuri1$pollid == 93, ]$genvar <- nuri1[nuri1$pollid == 93, ]$genvar3
nuri1[nuri1$pollid == 94, ]$genvar <- nuri1[nuri1$pollid == 94, ]$genvar4
nuri1[nuri1$pollid == 97, ]$genvar <- nuri1[nuri1$pollid == 97, ]$genvar5
nuri1[nuri1$pollid == 96, ]$genvar <- nuri1[nuri1$pollid == 96, ]$genvar6

nuri1$gensd <- sqrt(nuri1$genvar)

nuri <- nuri1[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems","pollgroup","groupsize", "avgsd","numindices", "genvar","readbrief",
				  "t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority", "hhincome","female","attextreme", "highinc","t1polint", 
				  "avgsd2", "grpgain2", "t1knowcor2", "t12know", "t12knowcor", "attextreme2", "length", "timebtw")]

## Adding data from single files 
## China, BTP 04
btp.pr.04 <- foreign::read.dta("cdd/data/nuri/bypoll/2004.online.primaries.dta")
btp <- btp.pr.04[,c("t1trade", "t1mindex","t1services")]
btp.pr.04$genvar <-unsplit(lapply(split(btp, btp.pr.04$pollgroup), genvar),btp.pr.04$pollgroup)
btp.pr.04$t1knowcor <- btp.pr.04$t1know_cor
btp.pr.04$avgsd2 <- btp.pr.04$grpgain2 <- btp.pr.04$t1knowcor2 <- btp.pr.04$t12know <- btp.pr.04$t12knowcor <- btp.pr.04$attextreme2 <-  NA
btp.pr.04$readbrief <- btp.pr.04$pfemale <- btp.pr.04$varfemale <- btp.pr.04$phighknow <- btp.pr.04$phighinc <- btp.pr.04$pminority <- btp.pr.04$phigheduc <- btp.pr.04$vareduc <-  NA
btp04 <- btp.pr.04[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems","pollgroup","groupsize", "avgsd","numindices",
					"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
					"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
					"t12knowcor", "attextreme2", "length", "timebtw")]

# Save file
save(btp04, file="cdd/data/nuri/bypoll/btp04.rdata", ascii=T)

btp04kyu <- btp.pr.04[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems",
				"pollgroup","groupsize","pfemale", "varfemale", "phighknow","phighinc","pminority", 
				"phigheduc", "vareduc","meant1know","meant1know_ind", "meant2know","avgsd", "numindices", 
				"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
				"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", 
				"t12know", "t12knowcor", "attextreme2", "length", "timebtw", "t1trade", "t1mindex","t1services", 
				"t2trade", "t2mindex","t2services")]
#minmax0(btp.pr.04[, c("t1trade", "t1mindex","t1services", "t2trade", "t2mindex","t2services")])
save(btp04kyu, file = "cdd/data/agg/bypoll/btp04kyu.rdata")	
#china.08  <- read.dta("pk/data/nuri/2008.china.dta")

# Save data
nuri <- rbind(nuri, btp04) #, china.08
#save(nuri, file="pk/data/nuri.Rdata")
save(nuri, file = "cdd/data/pkdat/nuri.Rdata")

# Save for Kyu
indices <- nuri1[,c("t1endexp","t1manvol","t1volloc","t1more", "t1belowmrkt","t1openspace",
					"t1lesscommute","t1consult","t1countyl","t1countys", "t1reform","t1fcvsch","t1mmtaxe","t1stest","t1testsl", "t1nclb", 
					"t1govinv","t1medqual","t1costcov","t1emplypay","t1indivpay","w4b42","w4b45","w4b48","w4b51","w4b54","w4b57",
					"olt1usseca","olt1humrh2","olt1envir","olt1inter","olt1multi","olt1demo","olt1forai1",
					"olt1global","olt1trade", "t1usseca","t1humrh2","t1envir","t1inter","t1multi","t1demo","t1forai1","t1global","t1trade_b")]
	
nurikyu <- nuri1[, c("caseid", "pollid", "country", "mode", "t1knowlevel","numitems","pollgroup","groupsize", "avgsd","numindices",
					"genvar","readbrief","t1know", "t1knowcor", "grpgain", "t2know","ppage","educ4","minority",
					"hhincome","female","attextreme", "highinc","t1polint", "avgsd2", "grpgain2", "t1knowcor2", "t12know",
					"t12knowcor", "attextreme2", "length", "timebtw","t1endexp","t1manvol","t1volloc","t1more", "t1belowmrkt","t1openspace",
					"t1lesscommute","t1consult","t1countyl","t1countys", "t1reform","t1fcvsch","t1mmtaxe","t1stest","t1testsl", "t1nclb", 
					"t1govinv","t1medqual","t1costcov","t1emplypay","t1indivpay","w4b42","w4b45","w4b48","w4b51","w4b54","w4b57",
					"olt1usseca","olt1humrh2","olt1envir","olt1inter","olt1multi","olt1demo","olt1forai1",
					"olt1global","olt1trade", "t1usseca","t1humrh2","t1envir","t1inter","t1multi","t1demo","t1forai1","t1global","t1trade_b",
					"t2endexp","t2manvol","t2volloc","t2more", "t2belowmrkt","t2openspace",
					"t2lesscommute","t2consult","t2countyl","t2countys", "t2reform","t2fcvsch","t2mmtaxe","t2stest","t2testsl", 
					"t2nclb", "t2govinv","t2medqual","t2costcov","t2emplypay","t2indivpay","w4f42","w4f45","w4f48","w4f51","w4f54",
					"w4f57", "olt2usseca","olt2humrh2","olt2envir","olt2inter","olt2multi","olt2demo","olt2forai1",
					"olt2global","olt2trade", "t2usseca","t2humrh2","t2envir","t2inter","t2multi","t2demo","t2forai1","t2global",
					"t2trade_b")]

save(nurikyu, file = "cdd/data/nuri/nurikyu.rdata")