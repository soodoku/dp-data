/*This is the West Texas utility data.  It makes some transformations, creates
a codebook, and saves the data as "sasuser.wt"*/

/* This section reads in raw data from wt.dat (Utility poll # 2) which is
   in ascii format.  The new sas data set is sasuser.wt    */

options ls=78;

filename aaa '/home/gov/staff/poll96/utilities/wt/wt.dat';
filename nonpart '/home/gov/staff/poll96/utilities/nonpartdata/wtu.dat';





data a;
 infile aaa lrecl=417 expandtabs;

input

cid  Gender v1-v155;
part=1;   /*gives those who participated in the deliberative part of the
            poll a value of 1 for the "part" variable*/
proc sort; by cid;




data b;
  infile nonpart lrecl=219;
  input cid Gender v1-v80;

part=2;   /*gives those who did not participate in the deliberative part
            of the poll but who were interviewed
            a value of 2 for the "part" variable*/

proc sort; by cid;

data c;
  merge a b; by cid;

data sasuser.wt;
set c;

run;





/*Note:  this program takes sas data set (sasuser.wt), and creates new
	variable names, gives them lables, and then saves the resulting data 
	set as sasuser.wt*/

data a;
  set sasuser.wt;

/* now an array statement to recode existing vars that i will use later to
   more 
   recognizable names. */
Array aaa
	cid  Gender v1-v155;

Array bbb (157)
		caseid gender	
		/*question 1*/  future grow poll needs invest
		/*question 2*/  resch reduce jobs tax lowinc
		/*question 3*/  growto pollto strtto needto invsto
		/*question 4*/  lowest envmt depend renew change
		/*question 5*/   im1 im2 im3 im4
		/*question 6*/     pref pr1 pr2 pr3
		/*questions 7,8*/  costs stsol ltsol
		/*question 9*/ winter summer
		/*question 10*/ wind addfac fuels buypwr envpct build
		/*question 11*/ paywnd payfac paygas paybuy payenv paybld
		/*question 12*/ paytot
		/*questions 13-18*/ cntrct source use rt smog
				    setrt
		/*question 19*/ compet poor impact option ccost serv
				ecodvt demand usage
		/*questions 20-22*/ glwarm airpol polfut


		ideology ownrent whopays whobuys insulate educ age assist 
		employed job manywork typework income
                race zipcode regwt 

		group		
		

		/*post survey questions*/ 
		/*question 1*/  future2 grow2 poll2 needs2 invest2
		/*question 2*/  resch2 reduce2 jobs2 tax2 lowinc2
		/*question 3*/  growto2 pollto2 strtto2 needto2 invsto2
		/*question 4*/  lowest2 envmt2 depend2 renew2 change2
		/*question 5*/   im12 im22 im32 im42
		/*question 6*/     pref2 pr12 pr22 pr32
		/*questions 7,8*/  costs2 stsol2 ltsol2
		/*question 9*/ winter2 summer2
		/*question 10*/ wind2 addfac2 fuels2 buypwr2 envpct2 
				build2
		/*question 11*/ paywnd2 payfac2 paygas2 paybuy2 payenv2
				 paybld2
		/*question 12*/ paytot2
		/*questions 13-18*/ cntrct2 source2 use2 rt2 
				smog2 setrt2
		/*question 19*/ compet2 poor2 impact2 option2 ccost2 
				serv2 ecodvt2 demand2 usage2
		/*questions 20-22*/ glwarm2 airpol2 polfut2
		
		
		/*questions about how successful the Deliberative Town 
			meeting was*/ 
		/*question 23*/ wastetm
		/*question 24*/ grpdisc talking puccomm
		/*question 25*/ glpart glinfl openmind
		/*questions 26-28*/ readmat biasmat biasdisc; 

do i = 1 to 157;
	bbb(i) = aaa(i);
end;



label
part   ='Participant or Non-Participant?'
caseid ='Case Identification Number'	
gender ='Rs Gender'                              /*end*/
future ='Preserve Coal, Natl Gas, Oil for Future'
grow   ='Promote Economic Growth in Community'
poll   ='Reduce Pollution'
needs  ='Ensure Everyone Has Basic Needs Met'
invest ='Minimize Risk When Investing Money'

/*question 2*/
resch  ='Research Even If Higher Elec Rates'
reduce ='Reduce Coal, Natl Gas by Efficient Use'
jobs   ='Number of Jobs Created'
tax    ='Impact on Communitys Tax Base'
lowinc ='Low Income Customers are Treated Fairly'

/*question 3*/ 
growto ='Tradeoff: Eco Growth & Pollution' 
pollto ='Tradeoff: Reduce Pollution & Inc Costs'
strtto ='Tradeoff: Short Term Rate & LT uncert.'
needto ='Tradeoff: Basic Needs Met & Inc Costs'
invsto ='Tradeoff: Min Invest Risk & Low Return'

/*question 4*/
lowest ='Resources With Lowest Cost Electricity'
envmt  ='Resources That Maintain Environment'
renew  ='Renewable Resources such as Wind, Sun'
depend ='Mix of Resources to Reduce Dependence'
change ='Resources that Can Fluctuate w/ Demand'

/*question 5*/ 
im1 ='Most Important Factor (WT, SWEPCO)'
im2 ='Second Most Imp. Factor (WT, SWEPCO)'
im3 ='Third Most Imp. Factor (WT, SWEPCO)'
im4 ='Fourth Most Imp. Factor (WT, SWEPCO)'

/*question 6*/
pref  ='Does R have Pref on Options (WT,SWEPCO)?'
pr1 ='Rs First Preference (WT, SWEPCO)'
pr2 ='Rs Second Preference (WT, SWEPCO)'
pr3 ='Rs Third Preference (WT, SWEPCO)'

/*questions 7*/ 
costs  ='Construction Costs vs Operating Costs'

/*question 8*/
stsol ='Short Term Sol w/Greater Flexibility'
ltsol ='Long Term Sol w/Greater Predictability'


/*question 9*/ 
winter ='Rs Winter Electricity Costs'
summer ='Rs Summer Electricity Costs'

/*question 10*/ 
wind   ='Wind and Solar Power'
addfac ='Reduce Need for Add Electric Facilities' 
fuels  ='Fuels Like Natl Gas, Coal'
buypwr ='Build Facilities/Buy Pwr from Elsewhere' 
envpct ='Additional Environmental Protection'
build  ='Building a Power Plant in W. Texas'

/*question 11*/ 
paywnd ='How Much Pay: Wind and Solar'
payfac ='How Much Pay: Reduce Need Add Facility'
paygas ='How Much Pay: Fuels Like Nat Gas, Coal'
paybuy ='How Much Pay: Buy Power from Elsewhere'
payenv ='How Much Pay: Addl Environment Protect'
paybld ='How Much Pay: Build Power Plant in WT'

/*question 12*/
paytot ='How Much Pay: Total'

/*question 13*/
cntrct ='Contract Length R Prefers if Import Pwr'

/*questions 14-18*/
source ='Which Source Produces CPLs Electricity'
use    ='Which Group Uses the Most Electricity'
rt     ='Which Group Pays the Highest Rate'
smog   ='Which Causes The Most Air Emisssions'
setrt  ='Which Agency Sets Elec Rate (OpenEnded)'

/*question 19*/ 
compet ='Benefits of Competition over Regulation'
poor   ='Low Income Pay More than Fair Share'
impact ='Fuels Have Neg Impact on Environment'
option ='CPL Doing Enough: Renewable, Efficiency'
ccost  ='Customer Costs Decrease w/Competition'
serv   ='Service Improves w/Competition'
ecodvt ='High Electric Bills Hinder Econ. Devt'
demand ='High Electric Bills Discourage Use'
usage  ='Use of Wind, Solar Reduce Future Costs'

/*questions 20-22*/ 
glwarm ='How Serious is Global Warming'
airpol ='How Serious is Air Pollution in Texas'
polfut ='The Future of Air Polution in Texas'
		
group  ='Rs Group Number'
 




/*post survey questions*/
	                                            /*end*/
future2 ='Post: Preserve Coal, Gas, Oil for Future'
grow2   ='Post: Promote Econ Growth in Community'
poll2   ='Post: Reduce Pollution'
needs2  ='Post:Ensure Everyone Has Basic Needs Met'
invest2 ='Post: Minimize Risk When Investing Money'

/*question 2*/
resch2  ='Post: Research Even If Higher Elec Rates'
reduce2 ='Post: Reduce Coal, Gas by Cust Efficiecy'
jobs2   ='Post: Number of Jobs Created'
tax2    ='Post: Impact on Communitys Tax Base'
lowinc2 ='Post:Low Inome Customers Treated Fairly'

/*question 3*/ 
growto2 ='Post: Tradeoff: Eco Growth & Pollution' 
pollto2 ='Post: Tradeoff: Reduce Poll & Inc Costs'
strtto2 ='Post: Tradeoff: Sht trm rt & LT uncert.'
needto2 ='Post: Tradeoff: Basic Needs & Inc Costs'
invsto2 ='Post: Tradeoff: Min Risk & Low Return'

/*question 4*/
lowest2 ='Post: Resources With Lowest Cost Elec'  
envmt2  ='Post:Resources That Maintain Environment'
renew2  ='Post: Renewable Resources like Wind, Sun'
depend2 ='Post: Mix of Resources reduce dependence'
change2 ='Post: Resources that can fluctuate w/dem'


/*question 5*/ 
im12 ='Post: Most Important Factor (WT, SWEPCO)'
im22 ='Post: Second Most Imp. Factor (WT, SWEPCO)'
im32 ='Post: Third Most Imp. Factor (WT, SWEPCO)'
im42 ='Post: Fourth Most Imp. Factor (WT, SWEPCO)'

/*question 6*/
pref2  ='Post: Does R have Pref on Options (WT,SWEPCO)?'
pr12 ='Post: Rs First Preference (WT, SWEPCO)'
pr22 ='Post: Rs Second Preference (WT, SWEPCO)'
pr32 ='Post: Rs Third Preference (WT, SWEPCO)'

/*question 7*/ 
costs2  ='Post: Constrctn Costs vs Operating Costs'

/*question 8*/
stsol2 = 'Post: Short Term Sol w/greater flexibility'
ltsol2 = 'Post: Long Term sol w/greater predictability' 

/*question 9*/ 
winter2 ='Post: Rs Winter Electricity Costs'
summer2 ='Post: Rs Summer Electricity Costs'

/*question 10*/ 
wind2   ='Post: Wind and Solar Power'
addfac2 ='Post: Reduce Need for Add Electric Facs' 
fuels2  ='Post: Fuels Like Natl Gas, Coal'
buypwr2 ='Post: Build Facilities/Buy Pwr Elsewhere' 
envpct2 ='Post: Additional Environmental Protectn'
build2  ='Post: Building a Power Plant in W. Texas' 

/*question 11*/ 
paywnd2 ='Post: How Much Pay: Wind and Solar'
payfac2 ='Post: How Much Pay: Reduce Need Add Fac'
paygas2 ='Post: How Much Pay: Natl Gas, Coal'
paybuy2 ='Post: How Much Pay: Buy Power Elsewhere'
payenv2 ='Post: How Much Pay: Addl Environ Protect'
paybld2 ='Post: How Much Pay: Build Plant in W. TX'

/*question 12*/
paytot2 ='Post: How Much Pay: Total'

/*question 13*/
cntrct2 = 'Post: Cntrct length R prefers if Imp pwr'

/*questions 14-18*/
source2 ='Post: The Source of WTU Electricity'
use2    ='Post: Group Uses the Most Electricity'
rt2     ='Post: Group Pays the Highest Rate'
smog2   ='Post: Which Causes Most Air Emisssions'
setrt2  ='Post: Which agency sets electric rates'

/*question 19*/ 
compet2 ='Post: Benefit Competition over Regulat'
poor2   ='Post: Low Inc. Pay More than Fair Share'
impact2 ='Post: Fuels Have Neg Impact on Environt'
option2 ='Post: CPL Doing Enough-Renew,Efficiency'
ccost2  ='Post: Cust. Cost Decrease w/Competition'
serv2   ='Post: Service Improve w/Competition'
ecodvt2 ='Post: High Elec. Bills Hinder Econ Devt'
demand2 ='Post: High Elec. Bills Discourage Use'
usage2  ='Post: Wind, Solar Reduce Future Costs'

/*questions 20-22*/ 
glwarm2 ='Post: How Serious is Global Warming'
airpol2 ='Post: How Serious Air Pollution in TX'
polfut2 ='Post: Future Air Polution'
		

/*questions about how successful the Deliberative Town 
			meeting was*/ 

/*question 23*/ 
wastetm  ='Overall Success of Town Meeting'

/*question 24*/
grpdisc  ='Value of Group Discussions'
talking  ='Value of Talking outside Discussions'
puccomm  ='Value of Session w/ PUC Commissioners'

/*question 25*/ 
glpart   ='Group Leader allowed Participation'
glinfl   ='Group Leader Influenced Group'
openmind ='Disenters had Good Reasons'

/*questions 26-28*/ 
readmat  ='Time Spent Reading Materials Beforehand'
biasmat  ='Were the Materials Balanced'
biasdisc ='Town Meeting Discussion was Balanced'

ideology ='Liberal/Conservative Political Scale'
ownrent  ='Own or Rent Home'
whopays  ='Who Pays Electric Bill'
whobuys  ='Who Buys Appliances'
insulate ='Who Purchases Insulation'
educ     ='Rs Education'
age      ='Rs Age'
assist   ='Does R Receive Government Assistance'
employed ='Does R Work Outside the Home'
job 	 ='Rs Occupation'
manywork ='Number of Employees at Rs Work'
typework ='Type of Workplace'
income   ='Rs Income'
/*Note: is this individual or Family income?*/
race     ='Rs Race or Ethnicity'
zipcode  ='Rs Zipcode'
regwt	 ='Rs Region';

/*Since the nonparticipants were not given unique case id numbers, the following
  will create a unique case id for each respondent and replace the existing
  caseid variable*/
retain counter;
counter=sum(counter, 1);
caseid=counter;
 

/*This study will keep the group numbers of the different studies
	from combining incorrectly.  100=CPL;  200=WT;  300=SWEPCO*/

group=group+200;

/*The following command will correct the ideology variable so that 
	it goes from 0 (Strong Liberal) to 10 (strong Conservative)
	as per convention.*/

if ideology ne 11 then ideology=(-1)*(ideology)+10;

/*this variable will create a permanent variable to identify which
	study it is (in this case, the WT study).  CPL=1, WTU=2, SWEPCO=3*/

study=2;

/*recoding the case id variable to distinguish which study the respondant
	came from:  1000000s=CPL;  2000000s=WT;   3000000=SWEPCO;*/

caseid=caseid+2000000;

/*recoding the zipcode variable to distinguish which study the respondant
	came froms:  100=CPL;  200s=WT;   300s=SWEPCO*/

zipcode=zipcode+200;

/*This corrects the problem with the "who sets utility rates" question (#18)
	originally, the pre and the post were coded somewhat differently
	in the CPL study,
	this makes the coding of value labels uniform.  After the recodes, 
	for both pre and post, 1=puc; 2=RR comm; 3= TX UC; 4=government;
	5=WT; 6=other; 7=dk*/

if setrt=2 then setrt=8;
if setrt=3 then setrt=9;
if setrt ge 2 then setrt=setrt-2;
if setrt2 ge 2 then setrt2=setrt2-2;






/*This corrects the problem with the "What group of WTU customers consume the most kilowatt hours of electricity" question.  Somehow, the "wholesale" response seemed to have caused problems.  The Summary Statistics provided by Delta Stratagies have the follwoing pre and post results:
			pre	post
	Residential	27%	33%
	Commercial	17%      6%
	Industrial	49%	54%
	Wholesale	0%	1%
	Don't know	7%	7%

However, the raw data provided by Delta yields the following:
			pre	post
	Residential	27%	33%
	Commercial	17%      6%
	Industrial	49%	54%
	Wholesale	7%	1%
	Don't know	0%	7%
Assuming that the summary results are correct and somehow the data just
 was transposed somehow, the raw data is recoded to reflect the results
 provided by Delta.  This also makes common sense because it seems
 unlikely that 0% would answer don't know to a question before the 
 Town meeting.*/

if use=4 then use=5;

/*Likewise, the pre-survey question for the "Which group pays the higher
rate question" needs to be changed to take account of a similiar
discrepency.*/

if rt=4 then rt=5;

data sasuser.wt;
set a;
drop I cid  v1-v155;	



/* This section takes the renamed variables with their labels amd  changes 
the order of the responses if necessary (ie:  Makes 
the liberal/conservative scale go from Liberal to conservative and not 
conservative to liberal).  It also gives each question value labels.*/
proc format;
	value part 1='1 Participant' 2='2 Non-Participant';
	value study 1='1 CPL' 2='2 WT' 3='3 SWEPCO';
	value gender 1='1 Male' 2='2 Female';
	value tenps 0='0 Not Important' 1='1' 2='2' 3='3' 4='4' 5='5 Average' 
		6='6' 7='7' 8='8' 9='9' 10='10 Extremely'
		11='11 dk';
	value  im 1='1 Lowest Cost' 2='2 Maintain Quality' 
		3='3 Mix of Resources' 4='4 Renewable Resc.' 
		5='5 Change Quantity' 
		6='6 dk' 0='0 NA';
	value pref 0='missing' 1='1 Yes' 2='2 No' 3='3 dk';
	value pr  0='0 NA'
		1='1 Decrease Need' 2='2 Build Fuel Fac.' 
		3='3 Build Renew Fac'
		4='4 Import Power' 5='5 dk';
	value costs 1='1 Higher Costs' 2='2 Lower Costs' 3='3 No Preference'
		4='4 dk';
	value solution 1='1 Yes'  2='2 No'  3='3 dk';
	value mymoney 999='999 missing/dk?';
	value cntrct 1='1 Short Term'  2='2 Long Term'  3='3 Mix' 4='4 dk';
	value source 1='1 Coal'
		2='2 Wind'
		3='3 Natural Gas'
		4='4 Fuel Oil'
		5='5 Nuclear'
		6='6 Solar'
		7='7 dk';
	value gr 1='1 Residential'
		2='2 Commercial'
		3='3 Industrial'
		4='4 Wholesale'
		5='5 dk';
	value smog 1='1 Nuclear'
		2='2 Coal'
		3='3 Natural Gas'
		4='4 dk';
	value setrt 1='1 PUC' /*Public Utility Commission*/
 		2='2 Railroad Comm.'
		3='3 TX Utility Comm.'
		4='4 Government'
		5='5 WTU'
		6='6 Other'
		7='7 dk';
	value disagree 1='1 Agree Strongly'
		2='2 Agree Mildly'
		3='3 Neither'
		4='4 Disagree Mildly'
		5='5 Disagree Strongly'
		6='6 dk';
	value serious 1='1 Not Very Serious'
		2='2 Somewhat Serious'
		3='3 Very Serious'
		4='4 dk';
	value polfut 1='1 Get Better'
		2='2 Stay the Same'
		3='3 Get Worse'
		4='4 dk';
	value wastetm 0='0 Waste of Time'
		1='1' 2='2' 3='3' 4='4' 5='5' 6='6' 7='7' 8='8' 9='9'
		10='10 Extremely Valuable'
		11='11 dk';
	value tmvalue 1='1 Little/No Value'
		2='2 Somewhat Valuable'
		3='3 Very Valuable'
		4='4 dk';
	value readmat 1='1 Just Glanced'
		2='2 Less Than Half'
		3='3 About Half'
		4='4 More Than Half'
		5='5 Most'
		6='6 Other';
	value biasmat 1='1 Mostly Balanced'
		2='2 Favored Positions'
		3='3 dk';
	value biasdisc 1='1 Fair Discussion'
		2='2 Favored Positions'
		3='3 dk';
	value ideology 0='0 Very Liberal' 1='1' 2='2' 3='3' 4='4' 5='5'
		6='6' 7='7' 8='8' 9='9'
		10='10 Very Conservative'
		11='11 dk';
	value ownrent 1='1 Own'
		2='2 Rent'
		3='3 Refused';
	value whopays 1='1 Respondent'
		2='2 Someone Else'
		3='3 Refused';
	value whoxxx 1='1 Respondent'
		2='2 Someone Else'
		3='3 Both'
		4='4 Refused';
	value educ 1='1 0 thru 8th'
		2='2 9 thru 11th'
		3='3 H.S. Graduate'
		4='4 Some College'
		5='5 College Graduate'
		6='6 Post-Grad Work'
		7='7 Refused';
	value yn 1='1 Yes'
		2='2 No'
		3='3 Refused';
	value job 0='0 NA'
		1='1 White Collar/Prof.'
		2='2 Blue Collar'
		3='3 Teacher'
		4='4 Rancher/Farmer'
		5='5 Nurse/Health Care'
		6='6 Clerical/Admin.'
		7='7 Self Employed'
		8='8 Housewife'
		9='9 Unemployed'
		10='10 Retired'
		11='11 Other'
		12='12 Refused';
	value manywork 1='1 less than 5'
		2='2 5-10'
		3='3 11-20'
		4='4 21-30'
		5='5 31-50'
		6='6 51-100'
		7='7 101-200'
		8='8 201-300'
		9='9 301-500'
		10='10 501-1000'
		11='11 Over 1000'
		12='12 dk'
		0='0 NA';
	value typework 0='0 NA'
		1='1 Store'
		2='2 Office'
		3='3 Government'
		4='4 Plant'
		5='5 Other'   /*I think 5 and 6 will be missing*/
		6='6 Refused'
		7='7 School'
		8='8 RV Park/Apartments'
		9='9 Farm/Ranch'
		10='10 Hospital'
		11='11 Hotel/Restaurant'
		12='12 Oil Field'
		13='13 Other'
		14='14 Refused';
	value income 1='1 Less Than $6000'
		2='2 $6000 - 10000'
		3='3 $10001 - 15000'
		4='4 $15001 - 25000'
		5='5 $25001 - 35000'
		6='6 $35001 - 55000'
		7='7 $55001 - 75000'
		8='8 more than $75000'
		9='9 refused';
	value race 1='1 Hispanic'
		2='2 Black'
		3='3 Asian'
		4='4 Anglo'
		5='5 Other'
		6='6 Refused';
	value regwt 1='1 Central'
		2='2 North' 
		3='3 West'
		4='4 Missing/West2?'
		5='5 South';
		/*note that 4 should be a missing response for the 
		  regwt variable above.*/
	value age 725='725 missing/ref?';
					
data sasuser.wt2;
  set sasuser.wt;

attrib part format=part.;
attrib study format=study.;
attrib gender format=gender.;
attrib future grow poll needs invest resch reduce jobs tax
	lowinc growto pollto strtto needto invsto lowest envmt 
	depend renew change
	wind addfac fuels buypwr envpct build
	future2 grow2 poll2 needs2 invest2 resch2 
	reduce2 jobs2 tax2 lowinc2 growto2 pollto2 strtto2 needto2
        invsto2 lowest2
	envmt2 depend2 renew2 change2 wind2 addfac2 fuels2 buypwr2 
	envpct2 build2 format=tenps.;
attrib im1 im2 im3 im4 im12 im22 im32 im42 format=im.;
attrib pr1 pr2 pr3 pr12 pr22 pr32 format=pr.;
attrib pref pref2 format=pref.;
attrib costs costs2 format=costs.;
attrib stsol stsol2 ltsol ltsol2 format=solution.;
attrib winter summer winter2 summer2 paywnd payfac paygas paybuy payenv 
	paybld paytot
	paywnd2 payfac2 paygas2 
	paybuy2 payenv2 paybld2 paytot2 format=mymoney.;
attrib cntrct cntrct2 format=cntrct.;
attrib source source2 format=source.;
attrib use use2 rt rt2 format=gr.;
attrib smog smog2 format=smog.;
attrib setrt setrt2 format=setrt.;
attrib compet compet2 poor poor2 impact impact2 option option2 ccost
	ccost2 serv serv2 ecodvt ecodvt2 demand demand2 usage usage2
	glpart glinfl openmind format=disagree.;
attrib readmat format=readmat.;
attrib biasmat format=biasmat.;
attrib biasdisc format=biasdisc.;
attrib glwarm glwarm2 airpol airpol2 format=serious.;
attrib polfut polfut2 format=polfut.;
attrib wastetm format=wastetm.;
attrib grpdisc talking puccomm format=tmvalue.;
attrib ideology format=ideology.;
attrib ownrent format=ownrent.;
attrib whopays format=whopays.;
attrib whobuys insulate format=whoxxx.;
attrib educ format=educ.;
attrib employed assist format=yn.;
attrib job format=job.;
attrib manywork format=manywork.;
attrib typework format=typework.;
attrib income format=income.;
attrib race format=race.;
attrib regwt format=regwt.;
attrib age format=age.;

proc contents data=sasuser.wt;
proc freq; tables 
		/*demographic variables*/
		study
		caseid 
		part
		group gender ideology ownrent whopays whobuys insulate 
		educ age assist
		employed job manywork typework income
		race zipcode regwt	
		

		/*pre survey questions*/
		/*question 1*/  future grow poll needs invest
		/*question 2*/  resch reduce jobs tax lowinc
		/*question 3*/  growto pollto strtto needto invsto
		/*question 4*/  lowest envmt depend renew change
		/*question 5*/   im1 im2 im3
		/*question 6*/     pref pr1 pr2 pr3
		/*questions 7,8*/  costs stsol ltsol
		/*question 9*/ winter summer
		/*question 10*/ wind addfac fuels buypwr envpct build
		/*question 11*/ paywnd payfac paygas paybuy payenv paybld
		/*question 12*/ paytot
		/*questions 13-18*/ cntrct source use rt smog 
				    setrt
		/*question 19*/ compet poor impact option ccost serv
				ecodvt demand usage
		/*questions 20-22*/ glwarm airpol polfut
		
		
		/*post survey questions*/
		/*question 1*/ future2 grow2 poll2 needs2 invest2
		/*question 2*/ resch2  reduce2 jobs2 tax2 lowinc2
		/*question 3*/ growto2 pollto2 strtto2 needto2 invsto2
		/*question 4*/ lowest2 envmt2 depend2 renew2 change2
		/*question 5*/ im12 im22 im32
		/*question 6*/ pref2 pr12 pr22 pr32
		/*questions 7,8*/ costs2 stsol2 ltsol2
		/*question 9*/ winter2 summer2
		/*question 10*/ wind2 addfac2 fuels2 buypwr2 envpct2
				build2
		/*question 11*/ paywnd2 payfac2 paygas2 paybuy2 payenv2
				paybld2
		/*question 12*/ paytot2
		/*questions 13-18*/ cntrct2
				source2 use2 rt2 smog2 
			        setrt2 
		/*question 19*/ compet2 poor2 impact2 option2 ccost2
				serv2 ecodvt2 demand2 usage2
		/*questions 20-22*/ glwarm2 airpol2 polfut2
		/*questions about how successful the Deliberative Town 
			meeting was*/  /*another 60 variables...*/
		/*question 23*/ wastetm
		/*question 24*/ grpdisc talking puccomm
		/*question 25*/ glpart glinfl openmind
		/*questions 26-28*/ readmat biasmat biasdisc
		/ missprint;
	/*the last command "missprint" includes missing values in the printout.
	  currently, there are no such missing values.*/
run;



