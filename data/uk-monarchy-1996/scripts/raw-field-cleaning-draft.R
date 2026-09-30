##############
##UK_Monarchy_7/15/09
##############
#Filter Variable - If group = -1, Non Participant
#Small Group Variable = group
#PK Variables - monarchy$knowa1, monarchy$knowb1, monarchy$knowc1, 	 monarchy$knowd1, monarchy$knowe1, monarchy$knowf1, monarchy$knowg1, monarchy$knowh1, monarchy$knowi1
#totknow1, totknow2
#Att indices - monarchy$t1supmon, monarchy$t1mpop, monarchy$t1pwrm, monarchy$t1reflor
##Master data does not have the group variable

library(foreign)
monarchy <- read.spss("data/CDD/UK-Monarchy/monarchy_final.sav", use.value.labels = FALSE, to.data.frame = TRUE, trim.factor.names = FALSE, reencode = NA, use.missings = to.data.frame)
names(monarchy) <- tolower(names(monarchy))
#monarchy <-monarchy[!(monarchy$group == -1), ]

monarchy$teleacc <- monarchy$b25a
monarchy$telenum <- monarchy$b25b

#sociodem
monarchy$age <- monarchy$ageb
monarchy$child <- monarchy$a3a
monarchy$childu5 <- monarchy$a3b_1b
monarchy$child511 <- monarchy$a3b_2b
monarchy$child1215 <- monarchy$a3b_3b
monarchy$child1617 <- monarchy$a3b_4b
monarchy$marstat <- monarchy$a4
monarchy$workstat <- monarchy$b2
monarchy$nohouseh <- monarchy$b3
monarchy$incearn <- monarchy$b4
monarchy$wstaoth <- monarchy$b5
monarchy$supstat <- monarchy$b8
monarchy$empsize <- monarchy$b9
monarchy$sempsize <- monarchy$b10
monarchy$ageedu <- monarchy$b11
monarchy$highqual <- monarchy$b12a
monarchy$qualhigh <- monarchy$b12b
monarchy$codering <- monarchy$b14
monarchy$bestdec <- monarchy$b15
monarchy$ethnic <- monarchy$b16
monarchy$religion <- monarchy$b17

monarchy$trustgov <- monarchy$b18a
monarchy$trustjor <- monarchy$b18b
monarchy$trustciv <- monarchy$b18c
monarchy$trustpol <- monarchy$b18d
monarchy$readpap <- monarchy$a5a
monarchy$papread <- monarchy$a5b
monarchy$polinter <- monarchy$a6

##Partisanship 
monarchy$partyid <- monarchy$b1a
monarchy$partycl <- monarchy$b1b
monarchy$partystr <- monarchy$b1c
#Values
monarchy$lesshars <- monarchy$a7d
monarchy$counsup <- monarchy$b19e
monarchy$bornwl <- monarchy$b20a
monarchy$agbornww <- monarchy$b20b
monarchy$aggdluck <- monarchy$b20c
monarchy$betway <- monarchy$b21a
monarchy$agrtrad <- monarchy$b21b
monarchy$leavpast <- monarchy$b21c
monarchy$qualeduc <- monarchy$b22a
monarchy$samequal <- monarchy$b22b
monarchy$parentpy <- monarchy$b22c
monarchy$winequit <- monarchy$b23a
monarchy$notkeepw <- monarchy$b23b
monarchy$keepweal <- monarchy$b23c
monarchy$genchoos <- monarchy$b24a

#BRITAIN EVALUATION VARIABLES:
monarchy$citbrit <- monarchy$b19a
monarchy$ashamed <- monarchy$b19b
monarchy$worldbet <- monarchy$b19c
monarchy$britbet <- monarchy$b19d
monarchy$success <- monarchy$b24b

#MONARCHY EVALUATION VARIABLES:
monarchy$qletdown <- monarchy$a7a
monarchy$highstan <- monarchy$a7b
monarchy$jourdam <- monarchy$a7c
monarchy$luxury1 <- monarchy$q3a
monarchy$luxury2 <- monarchy$r3a
monarchy$tooeng1 <- monarchy$q3b
monarchy$tooeng2 <- monarchy$r3b
monarchy$benefit1 <- monarchy$q3c
monarchy$benefit2 <- monarchy$r3c
monarchy$propup1 <- monarchy$q3c
monarchy$propup2 <- monarchy$r3d
monarchy$adapt1 <- monarchy$q3d
monarchy$adapt2 <- monarchy$r3e
monarchy$divis1 <- monarchy$q3e
monarchy$divis2 <- monarchy$r3e
monarchy$stuckup1 <- monarchy$q3f
monarchy$stuckup2 <- monarchy$r3f
monarchy$inflpol1 <- monarchy$q3g
monarchy$inflpol2 <- monarchy$r3g

monarchy$proud1 <- monarchy$q6c
monarchy$proud2 <- monarchy$r6c
monarchy$value1 <- monarchy$q6d
monarchy$value2 <- monarchy$r6d
monarchy$survive1 <- monarchy$q10
monarchy$survive2 <- monarchy$r10
monarchy$abovep1 <- monarchy$q13c
monarchy$abovep2 <- monarchy$r13c
monarchy$stay1 <- monarchy$q13g
monarchy$stay2 <- monarchy$r13g
monarchy$intrest1 <- monarchy$q16
monarchy$intrest2 <- monarchy$r16

###Importance of Monarchy Variables:
monarchy$tourist1 <- monarchy$q2a
monarchy$tourist2 <- monarchy$r2a
monarchy$respect1 <- monarchy$q2b
monarchy$respect2 <- monarchy$r2b
monarchy$govabus1 <- monarchy$q2c
monarchy$govabus2 <- monarchy$r2c
monarchy$trade1 <- monarchy$q2d
monarchy$trade2 <- monarchy$r2d
monarchy$present1 <- monarchy$q2e
monarchy$present2 <- monarchy$r2e
monarchy$unite1 <- monarchy$q2f
monarchy$unite2 <- monarchy$r2f
monarchy$stadem1 <- monarchy$q2g
monarchy$stadem2 <- monarchy$r2g
monarchy$help1 <- monarchy$q2h
monarchy$help2 <- monarchy$r2h

###Attitude Toward Future of Monarchy Variables
monarchy$monarch1 <- monarchy$q1
monarchy$monarch2 <- monarchy$r1
monarchy$mix1 <- monarchy$q6a
monarchy$mix2 <- monarchy$r6a
monarchy$retire1 <- monarchy$q6b
monarchy$retire2 <- monarchy$r6b
monarchy$taxes1 <- monarchy$q6e
monarchy$taxes2 <- monarchy$r6e
monarchy$glamour1 <- monarchy$q6f
monarchy$glamour2 <- monarchy$r6f
monarchy$support1 <- monarchy$q7a
monarchy$support2 <- monarchy$r7a
monarchy$public1 <- monarchy$q7b
monarchy$public2 <- monarchy$r7b
monarchy$accept1 <- monarchy$q7c
monarchy$accept2 <- monarchy$r7c
monarchy$sbthron1 <- monarchy$q8b
monarchy$sbthron2 <- monarchy$r8b
monarchy$best1 <- monarchy$q9
monarchy$best2 <- monarchy$r9

monarchy$wantsur1 <- monarchy$q11
monarchy$wantsur2 <- monarchy$r11
monarchy$mpref1 <- monarchy$q12a
monarchy$mpref2 <- monarchy$r12a
monarchy$lpref1 <- monarchy$q12b
monarchy$lpref2 <- monarchy$r12b
monarchy$depend1 <- monarchy$q13a
monarchy$depend2 <- monarchy$r13a
monarchy$fighead1 <- monarchy$q13b
monarchy$fighead2 <- monarchy$r13b
monarchy$morepow1 <- monarchy$q13d
monarchy$morepow2 <- monarchy$r13d
monarchy$hospol1 <- monarchy$q13e
monarchy$hospol2 <- monarchy$r13e
monarchy$combpow1 <- monarchy$q13f
monarchy$combpow2 <- monarchy$r13f
monarchy$referen1 <- monarchy$q15
monarchy$referen2 <- monarchy$r15

monarchy$choospm1 <- monarchy$q15
monarchy$choospm2 <- monarchy$r15
monarchy$intnat1 <- monarchy$q17
monarchy$intnat2 <- monarchy$r17
monarchy$headcoe1 <- monarchy$q20
monarchy$headcoe2 <- monarchy$r20

#House of Lords Variables:
monarchy$lords1 <- monarchy$q18
monarchy$lords2 <- monarchy$r18
monarchy$lordvot1 <- monarchy$q19a
monarchy$lordvot2 <- monarchy$r19a
monarchy$lordapp1 <- monarchy$q19b
monarchy$lordapp2 <- monarchy$r19b

#Civic Attitude Variables:
monarchy$democra1 <- monarchy$q21
monarchy$democra2 <- monarchy$r21
monarchy$saygov1 <- monarchy$q22a
monarchy$saygov2 <- monarchy$r22a
monarchy$opinion1 <- monarchy$q22b
monarchy$opinion2 <- monarchy$r22b
monarchy$voices1 <- monarchy$q22c
monarchy$voices2 <- monarchy$r22c
monarchy$inform1 <- monarchy$q22d
monarchy$inform2 <- monarchy$r22d


#Ethnic -> b16
monarchy$minority <-  as.numeric (!(monarchy$b16 ==1))
monarchy$female <- as.numeric(!(monarchy$sex ==1))

#Education b12a, b
monarchy$educa <- monarchy$b12a
monarchy$educb <- monarchy$b12b
save(monarchy, file="data/CDD/UK-Monarchy/clean/ukmonarchy.Rdata", ascii=TRUE)

#####################################
###Political Knowledge################
monarchy$knowa1 <- (monarchy$q5a ==2)
monarchy$knowa2 <- (monarchy$r5a ==2)
monarchy$knowb1 <- (monarchy$q5b ==2)
monarchy$knowb2 <- (monarchy$r5b ==2)
monarchy$knowc1 <- (monarchy$q5c ==1)
monarchy$knowc2 <- (monarchy$r5c ==1)
monarchy$knowd1 <- (monarchy$q5d ==2)
monarchy$knowd2 <- (monarchy$r5d ==2)
monarchy$knowe1 <- (monarchy$q5e ==1)
monarchy$knowe2 <- (monarchy$r5e ==1)

monarchy$knowf1 <- (monarchy$q5f ==1)
monarchy$knowf2 <- (monarchy$r5f ==1)

monarchy$knowg1 <- (monarchy$q5g ==2)
monarchy$knowg2 <- (monarchy$r5g ==2)
monarchy$knowh1 <- (monarchy$q5h ==1)
monarchy$knowh2 <- (monarchy$r5h ==1)
monarchy$knowi1 <- (monarchy$q8a==5)
monarchy$knowi2 <- (monarchy$r8a ==5)

monarchy$totknow1 = rowMeans(cbind(monarchy$knowa1, monarchy$knowb1, monarchy$knowc1, monarchy$knowd1, monarchy$knowe1 ,monarchy$knowf1 ,monarchy$knowg1 ,monarchy$knowh1 ,monarchy$knowi1 )) 
monarchy$totknow2 = rowMeans(cbind(monarchy$knowa2, monarchy$knowb2, monarchy$knowc2, monarchy$knowd2, monarchy$knowe2,monarchy$knowf2 ,monarchy$knowg2 ,monarchy$knowh2,monarchy$knowi2)) 

##########
#Assigning Negative Values as NAs
##IF LOOP CODE

for(i in 1:length(monarchy)) {
if(is.numeric(monarchy[,i]))  monarchy[,i][monarchy[,i] < 0] <- NA
}

save(monarchy, file="data/CDD/UK-Monarchy/clean/ukmonarchy.Rdata", ascii=TRUE)