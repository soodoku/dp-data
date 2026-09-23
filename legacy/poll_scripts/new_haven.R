#
# New Hampshire
# Last Edited: 7..14   
# Gaurav Sood
#

# Set Working dir.
setwd(basedir)

# Sourcing libs 
library(goji)
library(car)

# Sourcing common functions
source("func/func.R")
source("cdd/hlmFunc.R")

# Load data
nh <- foreign::read.dta("cdd/data/New Haven/data/nh_data_06_23_07.dta")

nh <- read.csv("cdd/data/New Haven/data/NH_Data_pre-mid-post.csv")

nh <- foreign::read.dta("cdd/data/New Haven/orig/nh_data_06_23_07.dta")

# q35: Which of the following would you say is closest to the population of the greater New Haven region? (correct=3)
# q36: During the 1990's, would you say the rate of job growth in the New Haven region was more, about the same, or less than the rest of the United States? (correct=2)
# q37: Which of the following would you say is the major source of revenue for most town governments in the Greater New Haven region? (correct=2)
# q39: Would you say the population of the city of New Haven increased, stayed the same, or decreased during the 1990's? (correct=3)
# q40: Does Connecticut law allow communities to share property tax revenues? (correct=1)
# q41: Would you say those communities with the most valuable property tend to have the lowest property tax rates, average property tax rates, or the highest property tax rates? (correct=1)
# q42: Which of the following categories would you say the Federal Aviation Authority would use to describe Tweed New Haven Airport? (correct=4)
# q43: Would you say that maintaining Tweed New Haven Airport at its current level of service would require any significant investment? (correct=1)

#The levels of relevant T1 knowledge lend further support. At all three waves, we
#asked the participants whether (1) the region’s population was closest to 250,000,
#350,000, 550,000 or 750,000; (2) its rate of growth in employment during the 1990s was
#more than, about the same as, or less than in the rest of the United States; (3) New
#Haven’s population increased, decreased or did not change during the 1990s; (4) the
#major source of revenue for most of the region’s town governments is sales taxes,
#property taxes, direct state subsidies or direct federal subsidies; (5) state law allows
#communities to share property tax revenues; (6) those communities with the most
#valuable property tend to have the lowest, average or the highest property tax rates; (7)
#the Federal Aviation Authority classiﬁes the regional airport as a major hub, a medium
#hub, a minor hub or not a hub; and (8) maintaining the regional airport at its current
#level of service would require any signiﬁcant investment. The correct answers are (1)
#555,000, (2) less, (3) decreased, (4) property taxes, (5) yes, (6) the lowest, (7) a non-hub,
#and (8) yes. Items (7) and (8) are speciﬁcally relevant to the airport, items (4) – (6)
#speciﬁcally relevant to revenue sharing, and items (1) – (3) generally relevant to the
#politics of the region.

nh$t1know1raw <- recode(nh$q35, "3=1; c(1,2,4)=0; 5=NA") 
nh$t1know2raw <- recode(nh$q36, "2=1; c(1,3,4)=0; 5=NA") 
nh$t1know3raw <- recode(nh$q37, "2=1; c(1,3,4)=0; 5=NA") 
nh$t1know4raw <- recode(nh$q39, "3=1; c(1,2,4)=0; 5=NA") 
nh$t1know5raw <- recode(nh$q40, "1=1; c(2,3,4)=0; 5=NA") 
nh$t1know6raw <- recode(nh$q41, "1=1; c(2,3,4)=0; 5=NA") 
nh$t1know7raw <- recode(nh$q42, "4=1; c(1,2,3)=0; 5=NA") 
nh$t1know8raw <- recode(nh$q43, "1=1; c(2,3,4)=0; 5=NA") 

nh$t2know1raw <- recode(nh$q35, "3=1; c(1,2,4)=0; 5=NA") 
nh$t2know2raw <- recode(nh$q35, "2=1; c(1,3,4)=0; 5=NA") 
nh$t2know3raw <- recode(nh$q35, "2=1; c(1,3,4)=0; 5=NA") 
nh$t2know4raw <- recode(nh$q35, "3=1; c(1,2,4)=0; 5=NA") 
nh$t2know5raw <- recode(nh$q35, "1=1; c(2,3,4)=0; 5=NA") 
nh$t2know6raw <- recode(nh$q35, "1=1; c(2,3,4)=0; 5=NA") 
nh$t2know7raw <- recode(nh$q35, "4=1; c(1,2,3)=0; 5=NA") 
nh$t2know8raw <- recode(nh$q35, "1=1; c(2,3,4)=0; 5=NA") 

# No NA version
t1raw <- paste0("t1know", 1:8, "raw")
t2raw <- paste0("t2know", 1:8, "raw")
t1 <- paste0("t1know", 1:8, "c")
t2 <- paste0("t2know", 1:8, "c")
nh[,t1]<- nona(nh[,t1raw])
nh[,t2]<- nona(nh[,t2raw])

# mean(rowMeans(nh[,t1])): Checks out in the ms.

# Educ

# Age

# Gender
nh$female <- nh$gender==2

nhirt <- mi6[, c(t1, t2, t1raw, t2raw, "female")]

write.csv(nhirt, file="guess/data/bypoll/nhirt.csv")

