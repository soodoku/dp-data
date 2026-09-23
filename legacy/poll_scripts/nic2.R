# 
#  NIC 2
# 

# Set Working dir.
setwd(basedir)

# Load libs 
library(foreign)
library(car)

# Load data
nic2 <- read.spss("cdd/data/nic_2/data/dat2.por", to.data.frame = T)
names(nic2) <- tolower(names(nic2))

# Knowledge
# ------------

# As far as you know, does President Bush want to increase foreign aid, decrease foreign aid, or keep it the same, 
# OR haven't you heard anything about this? - Increase, Decrease, Keep it the same, Haven't heard anything about this

nic2$bush_aid_t1    <- recode(nic2$aid1, "'increased' = 'incr'; 'reduced' = 'decr'; 'kept about the same' = 'same'; else = 'dk'")
nic2$bush_aid_t2    <- recode(nic2$aid3, "'increased' = 'incr'; 'reduced' = 'decr'; 'kept about the same' = 'same'; else = 'dk'")

nic2$mil_budget_t2  <- recode(nic2$kno1_a, "4 = 'corr'; c(1, 2, 3) = 'under'; 5 = 'over'; 6 = 'dk'")

nic2$aid  <- recode(nic2$kno1_b, "1 = 'corr'; c(2, 3, 4, 5) = 'over'; 6 = 'dk'")

nic2$warm <- recode(as.integer(nic2$wrm1_b), "1 = 'human'; 2 = 'natural'; 3 = 'not'; 4 = 'dk'")

temp <- do.call(paste, list(nic2$prtyid_a, nic2$prtyid_b, nic2$prtyid_c, sep = ""))

nic2$rid <- car::recode(as.integer(nic2$party), "c(3, 4, 6, 9, 12)='rep'; c(1, 2, 5, 8, 11) = 'dem'; c(7, 10, 13) = 'ind'; else = NA")

# Save misinformation file
save(nic2, file = "misinformation/data/nic2.rdata")
