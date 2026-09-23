# 
# Vermont
# Last Edited: 5.23.14   
# Gaurav Sood
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
vt <- foreign::read.spss("cdd/data/Vermont/data/vt.sav", to.data.frame = T)
names(vt) <- tolower(names(vt))
vt <- subset(vt, vt$part == 'Yes')

# Know
# T1
# 77.Is the surcharge Vermonters pay on their electric bills for programs to reduce the need for electricity currently …?  
# 78.What effect has Vermont’s energy efficiency program had on the annual increase in the amount of electricity used by Vermonter’s?  Has it  
# 79.Excluding Hydro Quebec, about what percentage of its electricity Does Vermont currently get from renewable resources?
# 80.And about what percentage of its electricity Does Vermont currently get from the Vermont Yankee nuclear plant?
# 81.About what percentage of its electricity does Vermont currently get from Hydro Quebec?
# 82.Roughly what percentage of Vermont’s electricity is currently generated within Vermont?  
# 83.How do Vermont’s electricity rates compare with those of the rest of New England?  Are they, on average, 
# 84.What is the average electric bill for the typical Vermonter? Is it …
# 85.Does Vermont’s contract with the Vermont Yankee nuclear power plant expire in …

# T3
# 30....38

vt$t1know1raw <- recode(as.numeric(vt$q77), "2 = 1; c(4, 5) = 0; else = NA")
vt$t1know2raw <- recode(as.numeric(vt$q78), "2 = 1; c(1, 3, 5) = 0; else = NA")
vt$t1know3raw <- recode(as.numeric(vt$q79), "3 = 1; c(1, 2, 4) = 0; else = NA")
vt$t1know4raw <- recode(as.numeric(vt$q80), "4 = 1; c(1, 2, 3) = 0; else = NA")
vt$t1know5raw <- recode(as.numeric(vt$q81), "2 = 1; c(3, 1, 4) = 0; else = NA")
vt$t1know6raw <- recode(as.numeric(vt$q82), "3 = 1; c(1, 2, 4) = 0; else = NA")
vt$t1know7raw <- recode(as.numeric(vt$q83), "4 = 1; c(1, 2, 3) = 0; else = NA")
vt$t1know8raw <- recode(as.numeric(vt$q84), "2 = 1; c(1, 3, 4) = 0; else = NA")
vt$t1know9raw <- recode(as.numeric(vt$q85), "2 = 1; c(1, 3, 4) = 0; else = NA")

vt$t3know1raw <- recode(as.numeric(vt$q030t3), "2 = 1; c(1, 3, 4, 5) = 0; else = NA")
vt$t3know2raw <- recode(as.numeric(vt$q031t3), "2 = 1; c(1, 3, 5) = 0; else = NA")
vt$t3know3raw <- recode(as.numeric(vt$q032t3), "3 = 1; c(1, 2, 4) = 0; else = NA")
vt$t3know4raw <- recode(as.numeric(vt$q033t3), "4 = 1; c(1, 2, 3) = 0; else = NA")
vt$t3know5raw <- recode(as.numeric(vt$q034t3), "2 = 1; c(3, 1, 4) = 0; else = NA")
vt$t3know6raw <- recode(as.numeric(vt$q035t3), "3 = 1; c(1, 2, 4) = 0; else = NA")
vt$t3know7raw <- recode(as.numeric(vt$q036t3), "4 = 1; c(1, 2, 3) = 0; else = NA")
vt$t3know8raw <- recode(as.numeric(vt$q037t3), "2 = 1; c(1, 3, 4) = 0; else = NA")
vt$t3know9raw <- recode(as.numeric(vt$q038t3), "2 = 1; c(1, 3, 4) = 0; else = NA")

t1raw <- paste0("t1know", 1:9, "raw")
t3raw <- paste0("t3know", 1:9, "raw")
t1 <- paste0("t1know", 1:9, "c")
t3 <- paste0("t3know", 1:9, "c")
 
vt[, c(t1, t3)] <- nona(vt[, c(t1raw, t3raw)])

vt$edu   <- recode(as.numeric(vt$q86), "c(1,2) = 0; 3 = .33; 4 = .66; c(5, 6) = 1;7 = NA")
vt$female <- as.numeric(as.numeric(vt$q94) == 2)

vtirt <- vt[, c(t1, t3, t1raw, t3raw, "female", "edu")]

write.csv(vtirt, file = "guess/data/bypoll/vtirt.csv")





#Eval Qs
# q040at3  Moderator allowed equal participation
# q040bt3  Small group members participated equally
# q040ct3Moderator influences group with own views
# q040dt3Moderator ensured consideration of opposing arguments
# q040et3Important aspects covered
# q040ft3Learned a lot about people different than me
# q040gt3Briefing document fair

# q039at3  Valuable small group
# q039bt3  Valuable talking outside group
# q039ct3  Valudable event as a whole

