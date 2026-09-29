***Selecting out Participants, var = weekend****

FILTER OFF.
USE ALL.
SELECT IF  ((weekend=1)).
EXECUTE.

****L3 File****

freq qscore qknowl rscore rknowl.
compute pkscore1 = qscore + rscore.
desc pkscore1.
compute pkscore = (pkscore1 - 2)/16.


compute pollid = 23.
compute country = 1.
compute mode =0.
compute t1knowlevel = mean(pkscore).
compute numitems = 16.

SAVE OUTFILE='C:\Users\Gaurav\Desktop\hlm\British Monarchy\L3-British-Monarchy.sav'
/KEEP = pollid country mode t1knowlevel numitems.

USE ALL.
COMPUTE filter_$=(uniform(1)<=.10).
VARIABLE LABEL filter_$ 'Approximately 10% of the cases (SAMPLE)'.
FORMAT filter_$ (f1.0).
FILTER  BY filter_$.
EXECUTE.


freq weekend.

* Group Variable	group		
* Filter	weekend		
*Support for Monarchy	t1supmon 	t2supmon 
*Monarchy and Populism	t1mpop 	t2mpop 
*Power of Monarchy	t1pwrm 	t2pwrm 
*Reform HOL Index	t1reflor	t2reflor

***Attitude Indices********

Compute SupMonDiff = t2supmon  - t1supmon.
Variable Labels SupMonDiff 'Diff in Support for Monarchy'.
Execute.

Compute MpopDiff =t2mpop  - t1mpop. 
Variable Labels MpopDiff  'Diff Monarchy and Populism'.
Execute.

Compute PrwMonDiff =t2pwrm - t1pwrm.
Variable Labels PrwMonDiff 'Diff Power of Monarchy'.
Execute.

Compute ReflorDiff = t2reflor - t1reflor.
Variable Labels ReflorDiff  'Diff Reform HOL Index'.
Execute.

Compute AbsSupMonDiff = Abs(t2supmon  - t1supmon).
Variable Labels AbsSupMonDiff 'Absolute Diff in Support for Monarchy'.
Execute.

RMV / AbsSupMonDiff_1=SMEAN(AbsSupMonDiff).
freq AbsSupMonDiff_1  AbsSupMonDiff.

Compute AbsMpopDiff =Abs(t2mpop  - t1mpop). 
Variable Labels AbsMpopDiff  'Absolute Diff Monarchy and Populism'.
Execute.

Compute AbsPrwMonDiff =Abs(t2pwrm - t1pwrm).
Variable Labels AbsPrwMonDiff 'Absolute Diff Power of Monarchy'.
Execute.

Compute AbsReflorDiff = Abs(t2reflor - t1reflor).
Variable Labels AbsReflorDiff  'Absolute Diff Reform HOL Index'.
Execute.

*******Sociodem********

*Age agegp agesex ageb.

freq ageb.

****class 

freq class.
desc class.

recode class (2=1) (else=0) into Manual_Job.
Variable Labels Manual_Job 'Manual Job Dummy'.
Execute.

recode class (1=1) (else=0) into NonManual_Job.
Variable Labels NonManual_Job 'Non Manual Job Dummy'.
Execute.

recode class (3=1) (else=0) into Never_Employed.
Variable Labels Never_Employed 'Never Employed Dummy'.
Execute.


***Education

freq educage acquals voquals qualsum.
desc educage.

recode educage (5=SYSMIS) (6=SYSMIS) (else=copy) into educage_R.
variable labels educage_R 'Education Years recoded'.
Execute.

***Religion

freq relig.
desc relig.

recode relig (4=1)(5=1)(else=0) into NonChristian.
Variable Labels NonChristian 'Non Christian Dummy'.
Execute.

recode relig (2=1)(5=SYSMIS)(else=0) into Catholic.
Variable Labels Catholic 'Catholic Dummy'.
Execute.

recode relig (3=1)(5=SYSMIS)(else=0) into OtherChristian.
Variable Labels OtherChristian 'Other Christian -not church of england or catholic- Dummy'.
Execute.

***Marital Status

freq marstat.

recode marstat (3=1)(else=0) into Single_D.
Variable Labels Single_D 'Single Dummy'.
Execute.

recode marstat (1=1)(else=0) into Married_D.
Variable Labels Married_D 'Married Dummy'.
Execute.

recode marstat (2=1)(else=0) into DivorcedSep_D.
Variable Labels DivorcedSep_D 'Divorced or Separated Dummy'.
Execute.

***Race and Ethnicity

freq b16.
desc b16.

recode b16 (1=1)(else=0) into White.
Variable labels White 'White Dummy'.
Execute.

*********Gender

freq sex.

recode sex (2=1)(1=0) into Female.
Variable Labels Female 'Female Dummy'.
Execute.

*b2 economic activity status 

***Chief Income Earner b4 chief income earner

freq b4.
desc b4.

recode b4 (-1=SYSMIS) (1=1) (2=0) into Cie.
Variable Labels Cie 'Chief Income Earner Dummy'.
Execute. 

*b8 supervision status of cie
*b12a highest qualification b12b high

****b5 economic activity status
****b7 employment status

freq b5 b7.
desc b7.

recode b7 (2=1)(4=SYSMIS)(else=0) into SelfEmployed.
Variable Labels SelfEmployed 'Self Employed Dummy'.
execute.

*freq soc Standard Occupational Classification.

desc soc.

recode soc (1=1)(2=1)(3=1)(else=0) into Professional.
Variable Labels Professional 'Professional Dummy'.
Execute.

recode soc (4,5,6,7,8=1)(else=0) into BlueCollar .
Variable Labels BlueCollar 'Blue Collar and Secretarial Dummy'.
Execute.

**Region and Country

freq reg region cntry ident.
freq cntry.
desc cntry.

recode cntry (1=1) (else=0) into England.
Variable Labels England 'England Dummy'.
Execute.

recode cntry (1=0) (else=1) into NonEngland.
Variable Labels NonEngland 'Non England Country Dummy'.
Execute.

******Children in Household

*a3ab (children 0-17)
*a3b_1b (aged under 5)
*a3b_2b , 3b, 4b 
*b3 number of adults 18+

freq child ychild.
desc child.

recode child (1=0)(else=1) into Child_D.
Variable Labels Child_D 'Children less than 18 in Household'.
Execute.

* SupMonDiff MpopDiff PrwMonDiff ReflorDiff 
* AbsSupMonDiff AbsMpopDiff AbsPrwMonDiff  AbsReflorDiff 

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT ReflorDiff 
  /METHOD=ENTER ageb Single_D DivorcedSep_D Female educage_R White NonChristian Manual_Job Never_Employed  SelfEmployed Child_D NonEngland.

freq ageb Single_D DivorcedSep_D Female educage_R White    Manual_Job Never_Employed  SelfEmployed Child_D NonEngland.

* NonChristian  Cie NonManual_Job Catholic OtherChristian



