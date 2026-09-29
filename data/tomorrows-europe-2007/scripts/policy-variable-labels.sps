

**************New Values***********
*** All EU 

*38i. Promoting economic growth
*38k. Making our economy competitive in the global arena

compute t3geneconval = mean(t3q38ir, t3q38kr).
Variable Labels t3geneconval 'T3 General Economic Growth Value'.
Execute.

compute t3perseconval = mean(t3q38lr, t3q38or, t3q38jr).
Variable Labels t3perseconval 'T3 Personal Economic Growth Value'.
Execute.

compute t2geneconval = mean(t2q38ir, t2q38kr).
Variable Labels t2geneconval 'T2 General Economic Growth Value'.
Execute.

compute t2perseconval = mean(t2q38lr, t2q38or, t2q38jr).
Variable Labels t2perseconval 'T2 Personal Economic Growth Value'.
Execute.

compute t3t2geneconval = t3geneconval - t2geneconval.
Variable Labels t3t2geneconval 'T3 T2 Diff General Econ Value'.
Execute.

compute t3t2perseconval = t3perseconval - t2perseconval.
Variable Labels t3t2perseconval 'T3 T2 Diff Personal Econ Value'.
Execute.

*38l. Earning as much money as possible
*38o. Being able to retire comfortably        
*38j. Not having to worry about being fired

compute t3protectlessoff = mean(t3q38ar, t3q38br, t3q38dr).
Variable Labels t3protectlessoff 'T3 Protect Less well off Value'.
Execute.

compute t2protectlessoff = mean(t2q38ar, t2q38br, t2q38dr).
Variable Labels t2protectlessoff 'T2 Protect Less well off Value'.
Execute.

compute t3t2protectlessoff =  t3protectlessoff - t2protectlessoff .
Variable Labels t3t2protectlessoff  'T3 T2 Protect Less well off Value'.
Execute.

*38a. Ensuring equal opportunity
*38b. Making sure nobody goes hungry or lacks medical care
*38d. Minimizing the gap between rich and poor

*38n. Having Europe play a larger role in the world
*38m. Helping people in other parts of the world     
* 38e. Keeping prices down 
* t3autonomy t3traditional



************************Diff for 10***************
freq q10at3t2Diff q10bt3t2Diff q10ct3t2Diff q10dt3t2Diff q10et3t2Diff.

compute q10at3t2Diff = t3q10ar - t2q10ar.
compute q10at3t2Diff_r = (q10at3t2Diff + .6)/1.4.
freq q10at3t2Diff_r.

VARIABLE LABELS  q10at3t2Diff_r 'T3 T2 Diff. UN can provide security'.
EXECUTE.

compute q10bt3t2Diff = t3q10br - t2q10br.
compute q10bt3t2Diff_r=(q10bt3t2Diff + .8)/1.7.
freq q10bt3t2Diff_r.

VARIABLE LABELS  q10bt3t2Diff_r 'T3 T2 Diff. US can provide security'.
EXECUTE.

compute q10ct3t2Diff = t3q10cr - t2q10cr.

VARIABLE LABELS  q10ct3t2Diff 'T3 T2 Diff. EU can provide security'.
EXECUTE.

***compute q10ct3t2Diff_r= (q10ct3t2Diff 

compute q10dt3t2Diff = t3q10dr - t2q10dr.
compute q10dt3t2Diff_r = (q10dt3t2Diff +.8)/1.6.

freq q10dt3t2Diff_r.

VARIABLE LABELS  q10dt3t2Diff_r 'T3 T2 Diff. NATO can provide security'.
EXECUTE.

compute q10et3t2Diff = t3q10er - t2q10er.
compute q10et3t2Diff_r=(q10et3t2Diff +1)/1.9.
freq q10et3t2Diff_r.

VARIABLE LABELS  q10et3t2Diff_r 'T3 T2 Diff. Your country can provide security'.
EXECUTE.

************Like Dislike*****************

compute AvgLikeWesternEUT3T2Diff = AvgLikeWesternEUT3 - AvgLikeWesternEUT2.
freq AvgLikeWesternEUT3T2Diff.

compute t3t2q39krDiff =  t3q39kr - t2q39kr.
VARIABLE LABELS  t3t2q39krDiff 'T3 T2 Diff. EU Like Dislike'.
EXECUTE.

compute t3t2q39jrDiff =  t3q39jr - t2q39jr.
VARIABLE LABELS  t3t2q39jrDiff 'T3 T2 Diff.Russia Like Dislike'.
EXECUTE.

compute t3t2q39irDiff =  t3q39ir - t2q39ir.
VARIABLE LABELS  t3t2q39irDiff 'T3 T2 Diff. Chinese Like Dislike'.
EXECUTE.

compute t3t2q39hrDiff =  t3q39hr - t2q39hr.
VARIABLE LABELS t3t2q39hrDiff  'T3 T2 Diff.  Americans Like Dislike'.
EXECUTE.

compute t3t2q39lrDiff =  t3q39lr -t2q39lr.
VARIABLE LABELS  t3t2q39lrDiff 'T3 T2 Diff.  UN Like Dislike'.
EXECUTE.

************Allowing employers more freedom in hiring and firing increases economic growth **********************

compute t3t2q3aDiff =t3q3ar  - t2q3ar.
VARIABLE LABELS  t3t2q3aDiff 'T3 T2 Diff. Allowing employers more freedom in hiring and firing increases economic growth'.
EXECUTE.

compute t3t2q3bDiff = t3q3br -  t2q3br.
VARIABLE LABELS  t3t2q3bDiff 'T3 T2 Increasing job security allows workers to become more skilled'.
EXECUTE.

compute t3t2q3cDiff =t3q3cr  -t2q3cr.
VARIABLE LABELS  t3t2q3cDiff  'T3 T2 Diff. Allowing employers more freedom in hiring and firing increases the number of jobs.'.
EXECUTE.

***********9c*****************8

compute t3t2q9cDiff= t3q9cr - t2q9cr.
VARIABLE LABELS  t3t2q9cDiff 'T3 T2 Diff. Freer trade leads to lower prices'.
EXECUTE.

**********Values****************

compute t3t2q38eDiff= t3q38er - t2q38er.
VARIABLE LABELS  t3t2q38eDiff 'T3 T2 Diff. Keeping prices down'.
EXECUTE.

compute t3t2q38jDiff= t3q38jr - t2q38jr.
VARIABLE LABELS  t3t2q38jDiff 'T3 T2 Diff. Not having to worry about being fired'.
EXECUTE.

****************Russia Worries**************

compute t3t2q15aDiff = t3q15ar - t2q15ar.
VARIABLE LABELS  t3t2q15aDiff 'T3 T2 Diff. Russia oil worries'.
EXECUTE.

compute t3t2q15bDiff = t3q15br - t2q15br.
VARIABLE LABELS  t3t2q15bDiff 'T3 T2 Diff. Russia eastern europe worries'.
EXECUTE.


freq  t3t2q39lrDiff.
************More recoding*****************

freq q16dt3t2Diff q16et3t2Diff q16gt3t2Diff q16ht3t2Diff q16it3t2Diff.

compute q16dt3t2Diff_r = (q16dt3t2Diff +1)/2.
VARIABLE LABELS  q16dt3t2Diff_r  'T3 T2 Diff. Recoded Adding a Muslim country to the EU would improve the EU’s relations with the Muslim world'.
EXECUTE.

compute q16et3t2Diff_r = (q16et3t2Diff +1)/2.
VARIABLE LABELS  q16et3t2Diff_r 'T3 T2 Diff. Recoded Adding a Muslim country to the EU would make the EU too diverse'.
EXECUTE.

compute q16gt3t2Diff_r = (q16gt3t2Diff +1)/2.
VARIABLE LABELS  q16gt3t2Diff_r 'T3 T2 Diff.  Recoded Adding more countries to the EU would help our economy'.
EXECUTE.

freq q16ht3t2Diff.

freq oldnew.


compute q16ht3t2Diff_r = (q16ht3t2Diff +1)/2.
VARIABLE LABELS  q16ht3t2Diff_r 'T3 T2 Diff.  Recoded Adding more countries to the EU  would help our security'.
EXECUTE.

compute q16it3t2Diff_r = (q16it3t2Diff +1)/2.
VARIABLE LABELS  q16it3t2Diff_r 'T3 T2 Diff.  Recoded Adding more countries to the EU would make it more difficult for the EU to make decisions'.
EXECUTE.

freq t3t2growprosper t3t2protectlwoff t3t2traditional t3t2autonomy.

freq att_migration_t3t2_Diff.
compute att_migration_t3t2_Diff_r = (att_migration_t3t2_Diff +1)/2.
freq att_migration_t3t2_Diff_r.

**********************************Labelling**********88

VARIABLE LABELS  t2q3ar ' T2 Allowing employers more freedom in hiring and firing increases economic growth'.
EXECUTE.

VARIABLE LABELS  t2q3br 'T2 Increasing job security allows workers to become more skilled'.
EXECUTE.

VARIABLE LABELS  t2q3cr 'T2 Allowing employers more freedom in hiring and firing increases the number of jobs'.
EXECUTE.

VARIABLE LABELS  t2q15ar 'T2 important a problem Europe’s dependency on Russian energy supplies'.
EXECUTE.
VARIABLE LABELS  t2q15br 'T2 important a problem Russian interference in Eastern European and Central Asian'.
EXECUTE.

VARIABLE LABELS  t3q15ar 'T3 important a problem Europe’s dependency on Russian energy supplies '.
EXECUTE.
VARIABLE LABELS  t3q15br 'T3 important a problem Russian interference in Eastern European and Central Asian '.
EXECUTE.


VARIABLE LABELS  t3q3ar 'T3 Allowing employers more freedom in hiring and firing increases economic growth'.
EXECUTE.

VARIABLE LABELS  t3q3br 'T3 Increasing job security allows workers to become more skilled'.
EXECUTE.

VARIABLE LABELS  t3q3cr 'T3 Allowing employers more freedom in hiring and firing increases the number of jobs'.
EXECUTE.


VARIABLE LABELS  t2q16dr 'T2 Adding Muslim country to EU would improve relations with Muslim world'.
EXECUTE.

VARIABLE LABELS  t2q16er 'T2 Adding a Muslim country to the EU would make the EU too diverse'.
EXECUTE.

VARIABLE LABELS  t2q16gr 'T2 Adding more countries to the EU would help our economy'.
EXECUTE.

VARIABLE LABELS  t2q16hr 'T2 Adding more countries to the EU  would help our security'.
EXECUTE.

VARIABLE LABELS  t2q16ir  'T2 Adding more countries to the EU would make it more difficult for the EU to make decisions'.
EXECUTE.


VARIABLE LABELS  t3q16dr 'T3 Adding Muslim country to EU would improve relations with Muslim world'.
EXECUTE.

VARIABLE LABELS  t3q16er 'T3 Adding a Muslim country to the EU would make the EU too diverse'.
EXECUTE.

VARIABLE LABELS  t3q16gr 'T3 Adding more countries to the EU would help our economy'.
EXECUTE.

VARIABLE LABELS  t3q16hr 'T3 Adding more countries to the EU  would help our security'.
EXECUTE.

VARIABLE LABELS  t3q16ir  'T3 Adding more countries to the EU would make it more difficult for the EU to make decisions'.
EXECUTE.


VARIABLE LABELS  t3q39lr 'T3 UN Like Dislike'.
EXECUTE.

VARIABLE LABELS  t3q39kr 'T3 EU Like Dislike'.
EXECUTE.

VARIABLE LABELS  t3q39jr 'T3 Russia Like Dislike'.
EXECUTE.

VARIABLE LABELS  t3q39ir 'T3 Chinese Like Dislike'.
EXECUTE.

VARIABLE LABELS t3q39hr  'T3 Americans Like Dislike'.
EXECUTE.

VARIABLE LABELS  t2q39lr 'T2 UN Like Dislike'.
EXECUTE.
VARIABLE LABELS t2q39gr  'T2 Turks Like Dislike'.
EXECUTE.
VARIABLE LABELS t3q39gr  'T3 Turks Like Dislike'.
EXECUTE.
VARIABLE LABELS  t2q39kr 'T2 EU Like Dislike'.
EXECUTE.

VARIABLE LABELS  t2q39jr 'T2 Russia Like Dislike'.
EXECUTE.

VARIABLE LABELS  t2q39ir 'T2 Chinese Like Dislike'.
EXECUTE.

VARIABLE LABELS t2q39hr  'T2 Americans Like Dislike'.
EXECUTE.

VARIABLE LABELS t2q38er  'T2 Keeping prices down - important for themselves or society to have '.
EXECUTE.

VARIABLE LABELS t2q38jr  'T2 Not having to worry about being fired - important for themselves or society to have'.
EXECUTE.

VARIABLE LABELS t3q38er  'T3 Keeping prices down - important for themselves or society to have '.
EXECUTE.
VARIABLE LABELS t3q38jr  'T3 Not having to worry about being fired - important for themselves or society to have'.
EXECUTE.

VARIABLE LABELS t2q10ar  'T2 UN -relied on to protect your country’s peace and security '.
EXECUTE.
VARIABLE LABELS t2q10br  'T2 US -relied on to protect your country’s peace and security'.
EXECUTE.
VARIABLE LABELS t2q10cr  'T2 EU -relied on to protect your country’s peace and security '.
EXECUTE.
VARIABLE LABELS t2q10dr  'T2 NATO- relied on to protect your country’s peace and security'.
EXECUTE.
VARIABLE LABELS t2q10er  'T2 Your Country -relied on to protect your country’s peace and security'.
EXECUTE.

VARIABLE LABELS t3q10ar  'T3 UN -relied on to protect your country’s peace and security '.
EXECUTE.
VARIABLE LABELS t3q10br  'T3 US -relied on to protect your country’s peace and security'.
EXECUTE.
VARIABLE LABELS t3q10cr  'T3 EU -relied on to protect your country’s peace and security '.
EXECUTE.
VARIABLE LABELS t3q10dr  'T3 NATO- relied on to protect your country’s peace and security'.
EXECUTE.
VARIABLE LABELS t3q10er  'T3 Your Country -relied on to protect your country’s peace and security'.
EXECUTE.

VARIABLE LABELS oldnew_mean_by_group  'Proportion of Old EU per group'.
EXECUTE.

VARIABLE LABELS oldnew  'Old EU Dummy'.
EXECUTE.

********SocioDem Variables**********
******************************************

*q35 gender
*q36 age
*q37 marital status
freq q37.
freq q39.
freq q38.
freq q35.

RECODE q38 (1=1) (ELSE=0) INTO q38recode.
VARIABLE LABELS  q38recode 'occupation recode'.
EXECUTE.

RECODE q37  (2=1) (ELSE=0) INTO q37recode.
VARIABLE LABELS  q37recode 'marital recode'.
EXECUTE.
* 
RECODE q38 (1=1) (ELSE=0) INTO q38r.
VARIABLE LABELS  q38r 'occupation recode'.
EXECUTE.

RECODE q37  (2=1) (ELSE=0) INTO q37recode.
VARIABLE LABELS  q37recode 'marital recode'.
EXECUTE.

RECODE q39 (4=1) (5=1) (6=1) (ELSE=0) INTO q39recode.
VARIABLE LABELS  q39recode 'education recode'.
EXECUTE.

freq q39recode.


***********Dependent Variables**********
***********************************************

COMPUTE turkey_att_t3t1change=t3q16br - t1q13b.
EXECUTE.

COMPUTE turkey_att_t3t2change=t3q16br - t2q16br.
EXECUTE.

COMPUTE ukraine_att_t3t1change=t3q16cr - t1q13c.
EXECUTE.

COMPUTE ukraine_att_t3t2change=t3q16cr - t2q16cr.
EXECUTE.

***********Independent Variables**********
***********************************************

***too complex***
*t2q16ir

compute t3t2q16irdiff = t3q16ir - t2q16ir.

*** Russian worry diff***

compute t3t2q15b = t3q15br - t2q15br.

**Migration**

Variable labels Attitude_towards_migration_t3 'Support for Open Migration at t3'.
execute.

Variable labels Attitude_towards_migration_t2 'Support for Open Migration at t2'.
execute.

compute t3t2q7c = t3q7cr - t2q7cr.

************Like Averages***********

freq t3q39ar.
compute AvgLikeWesternEUT3=mean(t3q39ar, t3q39br, t3q39cr,t3q39dr, t3q39fr).
VARIABLE LABELS  AvgLikeWesternEUT3 'Average Like Dislike Western Europe Countries at T3'.
EXECUTE.

compute AvgLikeWesternEUT2=mean(t2q39ar, t2q39br, t2q39cr,t2q39dr, t2q39fr).
VARIABLE LABELS  AvgLikeWesternEUT2 'Average Like Dislike Western Europe Countries at T2'.
EXECUTE.

***********Variable for Like Turks*********************

compute t3t2q39gDiff = t3q39gr -t2q39gr.
VARIABLE LABELS  t3t2q39gDiff 'T3 t2 Diff Like Turks'.
EXECUTE.

freq t2q39g.

**Lot of missing values - 99. So checking whether there is a pattern with missing values.

RECODE t2q39gr (MISSING=1) (ELSE=0) INTO t2q39gMissing.
VARIABLE LABELS  t2q39gMissing 't2q39g Missing'.
EXECUTE.

RECODE t3q39gr (MISSING=1) (ELSE=0) INTO t3q39gMissing.
VARIABLE LABELS  t3q39gMissing 't3q39g Missing'.
EXECUTE.

nomreg t2q39gMissing with oldnew q35 v_q36 q37recode q38recode q39 
/print = paramter summary cps mfi.

freq t2q39gr.
freq t3q39gr.

RECODE t2q39gr (MISSING=.5) (ELSE=copy) INTO t2q39gr_r.
VARIABLE LABELS  t2q39gr_r 't2q39g missing recoded to midpoint'.
EXECUTE.

RECODE t3q39gr (MISSING=.5) (ELSE=copy) INTO t3q39gr_r.
VARIABLE LABELS  t3q39gr_r 't3q39g missing recoded to midpoint'.
EXECUTE.

RECODE t3q39gr_r (MISSING=1) (ELSE=0) INTO t3q39gMissing.
VARIABLE LABELS  t3q39gMissing 't3q39g Missing'.
EXECUTE.

RECODE t2q39gr (MISSING=1) (ELSE=Copy) INTO t239gmissing.
VARIABLE LABELS  t239gmissing 't239gmissing'.
EXECUTE.

* Oldnew comes out as significant so we assign mean of t239g by oldnew to missing values

CROSSTABS
  /TABLES=oldnew BY t2q39gMissing
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

T-TEST GROUPS=oldnew(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=t2q39gr
  /CRITERIA=CI(.9500).

compute t3t1liketurks = t3q39gr - t2q39gr.

*old new by group ratio*

freq t3grp.

AGGREGATE
  /BREAK=t3grp
  /oldnew_mean_by_group=MEAN(oldnew).

compute high_ed_by_group=0.

AGGREGATE
  /BREAK=t3grp
  /high_ed_by_group1=MEAN(q39recode).

AGGREGATE
  /BREAK=t3grp
  /high_know_by_group=FGT(t1knowindnew, .6).

AGGREGATE
  /BREAK=t3grp
  /gender_by_group=mean(q37recode).

AGGREGATE
  /BREAK=t3grp
  /gender_by_group1=FGT(gender_by_group, .6).



* Recoding a binary variable 

RECODE oldnew_mean_by_group (.9 thru 1=1) (ELSE=0) INTO OldnewbygroupBin.
VARIABLE LABELS  OldnewbygroupBin 'Old New By Group Binary'.
EXECUTE.

freq oldnew_mean_by_group.

************

*turkey_att_t3t1change

RECODE turkey_att_t3t1change (.3 thru .75=1) (ELSE=0) INTO turkey_att_t3t1changeR.
VARIABLE LABELS  turkey_att_t3t1changeR 'turkey_att_t3t1changeR'.
EXECUTE.

***************************Value Indices************
******************************************************

split file off.

corr t3q38a  t3q38b t3q38c t3q38d t3q38e t3q38f t3q38g t3q38h t3q38i t3q38j t3q38k t3q38l t3q38m t3q38n t3q38o.
corr t2q38a  t2q38b t2q38c t2q38d t2q38e t2q38f t2q38g t2q38h t2q38i t2q38j t2q38k t2q38l t2q38m t2q38n t2q38o.

corr t3q38er t3q38ir t3q38kr t3q38lr t3q38jr t3q38mr. 

corr t3q38ar t3q38br t3q38dr t3q38mr.

* having europe play a larger role

FACTOR
  /VARIABLES t3q38ar t3q38br t3q38dr t3q38mr
  /MISSING LISTWISE 
  /ANALYSIS t3q38ar t3q38br t3q38dr t3q38mr
  /PRINT INITIAL EXTRACTION
  /CRITERIA FACTORS(1) ITERATE(25)
  /EXTRACTION PAF
  /ROTATION NOROTATE
  /METHOD=CORRELATION.


compute t2growprosper = mean (t2q38ir, t2q38kr, t2q38lr, t2q38nr) .

VARIABLE LABELS t2q38ir  'T2 Values - growprosper Promoting economic growth'.
EXECUTE.

compute q38adiff = t3q38ar - t2q38ar.
VARIABLE LABELS q38adiff   't3 t2 Diff value Ensuring equal opportunity'.
EXECUTE.

compute q38bdiff=t3q38br- t2q38br.
VARIABLE LABELS q38bdiff  't3 t2 Diff value Making sure nobody goes hungry or lacks medical care '.
EXECUTE.

compute q38cdiff=t3q38cr- t2q38cr.
VARIABLE LABELS q38cdiff 't3 t2 Diff value Preserving traditional industries '.
EXECUTE.

compute q38ddiff=t3q38dr- t2q38dr.
VARIABLE LABELS q38ddiff 't3 t2 Diff value Minimizing the gap between rich and poor'.
EXECUTE.

compute q38ediff=t3q38er- t2q38er.
VARIABLE LABELS q38ediff  't3 t2 Diff value Keeping prices down'.
EXECUTE.

compute q38fdiff=t3q38fr- t2q38fr.
VARIABLE LABELS q38fdiff  't3 t2 Diff value Leaving people and companies free to compete economically'.
EXECUTE.

compute q38gdiff=t3q38gr- t2q38gr.
VARIABLE LABELS q38gdiff  't3 t2 Diff value Making ones own choices'.
EXECUTE.

compute q38hdiff=t3q38hr- t2q38hr.
VARIABLE LABELS q38hdiff  't3 t2 Diff value Preserving traditions and customs '.
EXECUTE.

compute q38idiff = t3q38ir- t2q38ir.
VARIABLE LABELS q38idiff   't3 t2 Diff value Promoting economic growth'.
EXECUTE.

compute q38jdiff = t3q38jr- t2q38jr.
VARIABLE LABELS q38jdiff  't3 t2 Diff value Not having to worry about being fired '.
EXECUTE.

compute q38kdiff=t3q38kr- t2q38kr.
VARIABLE LABELS q38kdiff  't3 t2 Diff value Making our economy competitive in the global arena'.
EXECUTE.

compute q38ldiff=t3q38lr- t2q38lr.
VARIABLE LABELS q38ldiff  't3 t2 Diff value Earning as much money as possible'.
EXECUTE.

compute q38mdiff= t3q38mr - t2q38mr.
VARIABLE LABELS q38mdiff  't3 t2 Diff value Helping people in other parts of the world'.
EXECUTE.

compute q38ndiff= t3q38nr - t2q38nr.  
VARIABLE LABELS q38ndiff  't3 t2 Diff value Having Europe play a larger role in the world'.
EXECUTE.

compute q38odiff= t3q38or - t2q38or.  
VARIABLE LABELS q38odiff 't3 t2 Diff value Being able to retire comfortably        '.
EXECUTE.


**** valuediff = q38adiff  q38bdiff  q38cdiff q38ddiff  q38ediff q38fdiff q38gdiff q38hdiff q38idiff  q38jdiff q38kdiff q38ldiff q38mdiff  q38ndiff

VARIABLE LABELS t2q38kr  'T2 Values - Making our economy competitive in the global arena'.
EXECUTE.

VARIABLE LABELS  t2q38lr  'T2 Values - Earning as much money as possible'.
EXECUTE.

VARIABLE LABELS t2q38nr  'T2 Values - Having Europe play a larger role in the world'.
EXECUTE.

compute t2protectlwoff = mean (t2q38ar, t2q38br, t2q38dr, t2q38mr) .

VARIABLE LABELS t2q38ar  'T2 Values - Ensuring equal opportunity'.
EXECUTE.

VARIABLE LABELS  t2q38br  'T2 Values -Making sure nobody goes hungry or lacks medical care'.
EXECUTE.

VARIABLE LABELS  t2q38dr  'T2 Values - Minimizing the gap between rich and poor'.
EXECUTE.

VARIABLE LABELS t2q38mr 'T2 Values - Helping people in other parts of the world'.
EXECUTE.

compute t2traditional = mean (t2q38cr, t2q38hr) .
VARIABLE LABELS  t2q38cr  'T2 Values - autonomy Preserving traditional industries - 38c'.
EXECUTE.

VARIABLE LABELS t2q38hr  'T2 Values - autonomy Preserving traditions and customs 38h'.
EXECUTE.

compute t2autonomy = mean (t2q38fr, t2q38gr) .

VARIABLE LABELS  t2q38fr  'T2 Values - autonomy Leaving people and companies free to compete economically - 38f'.
EXECUTE.

VARIABLE LABELS t2q38gr  'T2 Values - autonomy Making ones own choices 38g'.
EXECUTE.

*********T3 Values**********
******************************

compute t3growprosper = mean (t3q38ir, t3q38kr, t3q38lr, t3q38nr) .

VARIABLE LABELS t3q38ir  'T3 Values - Promoting economic growth'.
EXECUTE.

VARIABLE LABELS t3q38kr  'T3 Values - Making our economy competitive in the global arena'.
EXECUTE.

VARIABLE LABELS  t3q38lr  'T3 Values - Earning as much money as possible'.
EXECUTE.

VARIABLE LABELS t3q38nr  'T3 Values - Having Europe play a larger role in the world'.
EXECUTE.


compute t3protectlwoff = mean (t3q38ar, t3q38br, t3q38dr, t3q38mr) .

VARIABLE LABELS t3q38ar  'T3 Values - Ensuring equal opportunity'.
EXECUTE.

VARIABLE LABELS t3q38br  'T3 Values -Making sure nobody goes hungry or lacks medical care'.
EXECUTE.

VARIABLE LABELS  t3q38dr  'T3 Values - Minimizing the gap between rich and poor'.
EXECUTE.

VARIABLE LABELS t3q38mr  'T3 Values - Helping people in other parts of the world'.
EXECUTE.

compute t3traditional = mean (t3q38cr, t3q38hr) .

VARIABLE LABELS  t3q38cr  'T3 Values - autonomy Preserving traditional industries - 38c'.
EXECUTE.

VARIABLE LABELS t3q38hr  'T3 Values - autonomy Preserving traditions and customs 38h'.
EXECUTE.
compute t3autonomy = mean (t3q38fr, t3q38gr) .

VARIABLE LABELS  t3q38fr  'T3 Values - autonomy Leaving people and companies free to compete economically - 38f'.
EXECUTE.

VARIABLE LABELS t3q38gr  'T3 Values - autonomy Making ones own choices 38g'.
EXECUTE.

*************************

***Sarkozy and Gordon Brown Placement

freq t1q33a t2q36ar t3q36ar.
desc t1q33b t2q36br t3q36br.

recode t1q33a (.6=1)(.7=1)(.8=1)(.9=1)(1=1)(Else=0) into t1q33a_r.
recode t2q36ar (.6=1)(.7=1)(.8=1)(.9=1)(1=1)(Else=0) into t2q36ar_r.
recode t3q36ar (.6=1)(.7=1)(.8=1)(.9=1)(1=1)(Else=0) into t3q36ar_r.

recode t1q33b (0=1)(.1=1)(.2=1)(.3=1)(.4=1)(Else=0) into t1q33b_r.
recode t2q36br (0=1)(.1=1)(.2=1)(.3=1)(.4=1)(Else=0)  into t2q36br_r.
recode t3q36br (0=1)(.1=1)(.2=1)(.3=1)(.4=1)(Else=0)  into t3q36br_r.

desc t1q33a_r t2q36ar_r t3q36ar_r   t1q33b_r t2q36br_r t3q36br_r.

******New Knowledge Index
compute t1knowindnew = mean(t1q16cor, t1q17cor, t1q18cor, t1q19cor, t1q20cor, t1q21cor,  t1q22cor,  t1q23cor,  t1q24cor, t1q33a_r, t1q33b_r).
compute t2knowindnew =mean( t2q19cor,  t2q20cor , t2q21cor , t2q22cor,  t2q23cor , t2q24cor ,  t2q25cor ,  t2q26cor,   t2q27cor,  t2q36ar_r, t2q36br_r).
compute t3knowindnew =mean( t3q19cor,  t3q20cor , t3q21cor,  t3q22cor , t3q23cor , t3q24cor  , t3q25cor ,  t3q26cor ,  t3q27cor, t3q36ar_r, t3q36br_r).
desc t1knowindnew t2knowindnew  t3knowindnew.

compute t3econknowledge = mean(t3q22, t3q23, t3q24).
compute t310bd = mean (t3q10br, t3q10dr).
compute t210bd = mean (t2q10br, t2q10dr).
compute q10bdt3t2Diff = t310bd - t210bd.

COMPUTE turkey_att_t3t1change=t3q16br - t1q13b.
EXECUTE.

COMPUTE ukraine_att_t3t1change=t3q16cr - t1q13c.
EXECUTE.

***********Independent Variables**********
***********************************************
*Variable for Like Turks*

freq t2q39g.

**Lot of missing values - 99. So checking whether there is a pattern with missing values.

RECODE t2q39gr (MISSING=1) (ELSE=0) INTO t2q39gMissing.
VARIABLE LABELS  t2q39gMissing 't2q39g Missing'.
EXECUTE.

RECODE t3q39gr (MISSING=1) (ELSE=0) INTO t3q39gMissing.
VARIABLE LABELS  t3q39gMissing 't3q39g Missing'.
EXECUTE.

nomreg t2q39gMissing with oldnew q35 v_q36 q37recode q38recode q39 
/print = paramter summary cps mfi.

* Oldnew comes out as significant so we assign mean of t239g by oldnew to missing values

CROSSTABS
  /TABLES=oldnew BY t2q39gMissing
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

T-TEST GROUPS=oldnew(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=t2q39gr
  /CRITERIA=CI(.9500).

compute t3t1liketurks = t3q39gr - t2q39gr.

*old new by group ratio*

freq t3grp.

AGGREGATE
  /BREAK=t3grp
  /oldnew_mean_by_group=MEAN(oldnew).

* Recoding a binary variable 

RECODE oldnew_mean_by_group (0 thru .65=0) (ELSE=1) INTO OldnewbygroupBin.
VARIABLE LABELS  OldnewbygroupBin 'Old New By Group Binary'.
EXECUTE.

freq oldnew_mean_by_group.

*value indices*

compute t2growprosper = mean (t2q38ir, t2q38kr, t2q38lr, t2q38nr) .
compute t2protectlwoff = mean (t2q38ar, t2q38br, t2q38dr, t2q38mr) .
compute t2traditional = mean (t2q38cr, t2q38hr) .
compute t2autonomy = mean (t2q38fr, t2q38gr) .

compute t3growprosper = mean (t3q38ir, t3q38kr, t3q38lr, t3q38nr) .
compute t3protectlwoff = mean (t3q38ar, t3q38br, t3q38dr, t3q38mr) .
compute t3traditional = mean (t3q38cr, t3q38hr) .
compute t3autonomy = mean (t3q38fr, t3q38gr) .


**********Interactions with oldnew***********

freq q39r.

compute Oldt3knowindnew = oldnew*t3knowindnew.
VARIABLE LABELS Oldt3knowindnew  'T3 Knowledge Index Interacted with oldnew'.
EXECUTE.

compute OldnewEd = oldnew*q39r.
VARIABLE LABELS OldnewEd  'Education Interacted with oldnew'.
EXECUTE.

compute Oldt3q16dr =oldnew*t3q16dr.
VARIABLE LABELS Oldt3q16dr 'T3 Adding Muslim country to EU would improve relations with Muslim world Interacted with oldnew'.
EXECUTE.

compute Oldt3q16er=oldnew*t3q16er.
VARIABLE LABELS Oldt3q16er  'T3 Adding a Muslim country to the EU would make the EU too diverse Interacted with oldnew'.
EXECUTE.

compute Oldt3q16gr=oldnew*t3q16gr.
VARIABLE LABELS Oldt3q16gr  'T3 Adding more countries to the EU would help our economy Interacted with oldnew'.
EXECUTE.

compute Oldt3q16hr=oldnew*t3q16hr.
VARIABLE LABELS Oldt3q16hr  'T3 Adding more countries to the EU  would help our security Interacted with oldnew'.
EXECUTE.

compute Oldt3q16ir=oldnew* t3q16ir.
VARIABLE LABELS Oldt3q16ir 'T3 Adding more countries to the EU would make it more difficult for the EU to make decisions Interacted with oldnew'.
EXECUTE.

compute OldAttitude_towards_migration_t3 =oldnew*Attitude_towards_migration_t3.
VARIABLE LABELS OldAttitude_towards_migration_t3 'Attitude towards open migration policy at T3 Index Interacted with oldnew'.
EXECUTE.

compute Oldt3q10er=oldnew*t3q10er.
VARIABLE LABELS Oldt3q10er  'T3 Your Country -relied on to protect your country’s peace and security Interacted with oldnew'.
EXECUTE.

compute Oldt3q38er=oldnew* t3q38er.
VARIABLE LABELS Oldt3q38er 'T3 Keeping prices down - important for themselves or society to have  Interacted with oldnew'.
EXECUTE.

compute Oldt3q38mr=oldnew*t3q38mr.
VARIABLE LABELS Oldt3q38mr  'T3 Values - Helping people in other parts of the world Interacted with oldnew'.
EXECUTE.

compute Oldt3q38nr=oldnew*t3q38nr.
VARIABLE LABELS Oldt3q38nr  'T3 Values - Having Europe play a larger role in the world Interacted with oldnew'.
EXECUTE.

compute Oldt3geneconval=oldnew*t3geneconval.
VARIABLE LABELS  Oldt3geneconval  'T3 General Economic Growth Value Interacted with oldnew'.
EXECUTE.

compute Oldt3perseconval=oldnew*t3perseconval.
VARIABLE LABELS Oldt3perseconval  'T3 Personal Economic Growth Value Interacted with oldnew'.
EXECUTE.

compute Oldt3autonomy=oldnew*t3autonomy.
VARIABLE LABELS Oldt3autonomy  'Autonomy Values Index T3 Interacted with oldnew'.
EXECUTE.

compute Oldt3traditional=oldnew* t3traditional.
VARIABLE LABELS Oldt3traditional  'Traditionalism Values Index T3 Interacted with oldnew'.
EXECUTE.

compute Oldt3protectlessoff=oldnew*t3protectlessoff.
VARIABLE LABELS Oldt3protectlessoff  'T3 Protect Less well off Value Interacted with oldnew'.
EXECUTE.

compute Oldt3q39gr=oldnew*t3q39gr.
VARIABLE LABELS Oldt3q39gr  'T3 Turks Like Dislike Interacted with oldnew'.
EXECUTE.


compute Oldtt3q39jr =t3q39jr.
compute Oldt3q15ar = t3q15ar
compute Oldt3q15br  =t3q15br.

freq t3q39jr t3q15ar t3q15br.
freq t3q39j t3q15a t3q15b.

recode t3q39j (99=SYSMIS)(else=copy) into t3q39jr.

recode t3q15a (99=SYSMIS)(else=copy) into t3q15ar.

recode t3q15b (99=SYSMIS)(else=copy) into t3q15br.

freq t3q15ar t3q15br.

freq Oldtt3q39jr Oldt3q15ar Oldt3q15br.

compute Oldt3q39jr=oldnew*t3q39jr.
VARIABLE LABELS Oldt3q39jr  'T3 Russia Like Dislike Interacted with oldnew'.
EXECUTE.

compute Oldt3q15ar=oldnew*t3q15ar.
VARIABLE LABELS Oldt3q15ar  'T3 important a problem Europe’s dependency on Russian energy supplies Interacted with oldnew'.
EXECUTE.

compute  Oldt3q15br=oldnew*t3q15br.
VARIABLE LABELS Oldt3q15br  'T3 important a problem Russian interference in Eastern European and Central Asian Interacted with oldnew'.
EXECUTE.
