#   														  ##
# Outputting Data for Kyu (Consensus + Net Change)
#

# Set Working dir.
setwd(basedir)

# Load data
# Load agg_data
load("cdd/data/pkdat/agg_data.Rdata")

## Adding Poll Level Indices for Gaurav
setwd("cdd/data/agg/bypoll")
for(i in dir()){load(i)}
setwd(basedir)
	
# Poll level indices
gtemp          <- agg_data
gtemp[,69:293] <- NA

# Assign names
# So that you know which poll the indices came from
names(gtemp)[69:82]		<- paste0("aus.",		names(ausmonkyu)[-(1:42)])
names(gtemp)[83:88]		<- paste0("btp04pr.",	names(btp04kyu)[-(1:42)])
names(gtemp)[89:112]	<- paste0("bulgaria.",	names(bulgariakyu)[-(1:42)])
names(gtemp)[113:130]	<- paste0("chi.",		names(chikyu)[-(1:42)])
names(gtemp)[131:144] 	<- paste0("cpl.",		names(cplkyu)[-(1:42)])
names(gtemp)[145:175]	<- paste0("eu.", 		names(eukyu)[-(1:42)])
names(gtemp)[176:187]	<- paste0("grk.", 		names(grkkyu)[-(1:42)])
names(gtemp)[188:195]	<- paste0("ukmonarchy.", names(monarchykyu)[-(1:42)])
names(gtemp)[196:213]	<- paste0("nic1.", 		names(nic1kyu)[-(1:42)])
names(gtemp)[214:227]	<- paste0("swp.", 		names(swepkyu)[-(1:42)])
names(gtemp)[228:235]	<- paste0("ukbge.", 	names(ukbgekyu)[-(1:42)])
names(gtemp)[236:245]	<- paste0("ukcrime.",	names(ukcrimekyu)[-(1:42)])
names(gtemp)[246:253]	<- paste0("ukeu.",		names(ukeukyu)[-(1:42)])
names(gtemp)[254:275]	<- paste0("ukhealth.",	names(ukhealthkyu)[-(1:42)])
names(gtemp)[276:289]	<- paste0("wtu.",		names(wtukyu)[-(1:42)])
names(gtemp)[290:293]	<- paste0("eu2009.",	names(eu09kyu)[-(1:42)])

# unique(paste0(gtemp$pollid, gtemp$pollname))

# Add the data
gtemp[gtemp$pollid == 26,	69:82] 		<- ausmonkyu[-(1:42)]
gtemp[gtemp$pollid == 95, 83:88]		<- btp04kyu[-(1:42)]
gtemp[gtemp$pollid == 53, 89:112] 	<- bulgariakyu[-(1:42)]
gtemp[gtemp$pollid == 52, 113:130] 	<- chikyu[-(1:42)]
gtemp[gtemp$pollid == 29, 131:144] 	<- cplkyu[-(1:42)]
gtemp[gtemp$pollid == 28, 145:175] 	<- eukyu[-(1:42)]
gtemp[gtemp$pollid == 2000, 176:187] 	<- grkkyu[-(1:42)]
gtemp[gtemp$pollid == 23, 188:195]	<- monarchykyu[-(1:42)]
gtemp[gtemp$pollid == 1001, 196:213]	<- nic1kyu[-(1:42)]
gtemp[gtemp$pollid == 3000, 214:227]	<- swepkyu[-(1:42)]
gtemp[gtemp$pollid == 25, 228:235] 	<- ukbgekyu[-(1:42)]
gtemp[gtemp$pollid == 27, 236:245]	<- ukcrimekyu[-(1:42)]
gtemp[gtemp$pollid == 20, 246:253]	<- ukeukyu[-(1:42)]
gtemp[gtemp$pollid == 22, 254:275]	<- ukhealthkyu[-(1:42)]
gtemp[gtemp$pollid == 986, 276:289] 	<- wtukyu[-(1:42)]
gtemp[gtemp$pollid == 71, 290:293] 	<- eu09kyu[-(1:42)]

## Adding Nuri's Indices agg_nuri_caseid
load("cdd/data/nuri/nurikyu.rdata")
nuri1 			<- nurikyu
# see data.R, line 119
nuri1 			<- subset(nuri1, !(pollid == 94 & (t2know == 0 | is.na(attextreme))))
gtemp[,294:383] <- NA

# Att. indices
nhatt		<- c("t1endexp","t1manvol","t1volloc", "t2endexp","t2manvol","t2volloc")

nic2att		<- c("t1usseca","t1humrh2","t1envir","t1inter","t1multi","t1demo","t1forai1","t1global","t1trade_b", "t2usseca",
				  "t2humrh2","t2envir","t2inter","t2multi","t2demo","t2forai1","t2global","t2trade_b") 

btp03att 	<- c("olt1usseca","olt1humrh2","olt1envir","olt1inter","olt1multi","olt1demo", "olt1forai1", "olt1global","olt1trade", "olt2usseca",
				 "olt2humrh2","olt2envir","olt2inter","olt2multi","olt2demo","olt2forai1", "olt2global","olt2trade") 

btp04att 	<- c("w4b42","w4b45","w4b48","w4b51","w4b54","w4b57", "w4f42","w4f45","w4f48","w4f51","w4f54","w4f57")

btp05att	<- c("t1reform","t1fcvsch","t1mmtaxe","t1stest","t1testsl", "t1nclb", "t1govinv","t1medqual","t1costcov","t1emplypay","t1indivpay", 
				  "t2reform","t2fcvsch","t2mmtaxe", "t2stest","t2testsl", "t2nclb", "t2govinv","t2medqual","t2costcov","t2emplypay","t2indivpay")

smatt 		<-  c("t1more", "t1belowmrkt","t1openspace","t1lesscommute","t1consult","t1countyl","t1countys", "t2more", 
				  "t2belowmrkt","t2openspace","t2lesscommute","t2consult","t2countyl","t2countys")
			
names(gtemp)[294:299] <- paste0("nh.",   nhatt)
names(gtemp)[300:317] <- paste0("nic2.", nic2att)
names(gtemp)[318:335] <- paste0("btp03.", btp03att)
names(gtemp)[336:347] <- paste0("btp04.", btp04att)
names(gtemp)[348:369] <- paste0("btp05.", btp05att)
names(gtemp)[370:383] <- paste0("sm.", 	  smatt)
	
# Data
gtemp[gtemp$pollid == 91, 294:299] <- nuri1[nuri1$pollid == 91, nhatt]
gtemp[gtemp$pollid == 92, 300:317] <- nuri1[nuri1$pollid == 92, nic2att]	
gtemp[gtemp$pollid == 93, 318:335] <- nuri1[nuri1$pollid == 93, btp03att]
gtemp[gtemp$pollid == 94, 336:347] <- nuri1[nuri1$pollid == 94, btp04att]
gtemp[gtemp$pollid == 97, 348:369] <- nuri1[nuri1$pollid == 97, btp05att]
gtemp[gtemp$pollid == 96, 370:383] <- nuri1[nuri1$pollid == 96, smatt]

# Reassign
kyudata <- gtemp

# Save Data
save(kyudata, file = "cdd/data/agg/kyudata.rdata", ascii = TRUE)
write.csv(kyudata, file = "cdd/data/agg/kyudata.csv", eol = "\n", na = "NA", quote = TRUE)