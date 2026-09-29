/* DATA CLEANING and PREP SECTION:
CREATES PBS USING:
CRITERIA 3 (15%+ of each party are at opposite extremes (0 or 10))
AND PARTID7 (7 categories of party affiliation, including leaners)

CREATES PBS USING 27 MOST POLARIZED QUESTIONS.
*/

clear all

cd "C:\Users\valen909\Dropbox\Hoover\America1Room\Climate\Data\Full_With_FollowUp"

/* Data set with T1, T2, and T3 for the climate deliberations */
insheet using "9503_A1RCE-FollowUp_20221110.csv", comma

gen delegate = 1 if p_treatment == 1
replace delegate = 0 if p_treatment == 0

/* Also participated in A1R? */
gen a1r_delegate = 1 if delegate2019 == 1
replace a1r_delegate = 0 if delegate2019 !=1

/* Keep only those who were invited and who completed
both the pre and post surveys. Excluding those who only partially
engaged with the experiment */
keep if final_attend == 1 | final_attend == 8
keep if t3qual == 3 /* Invited to T3 Follow-Up and Completed */

/* Varlists 1-5 are all policy questions */
global varlist1 "q0a q0b q0c q1a q1b q1c q1d q1e q2a q2b q2c q3a q3b q4a q4b q4c q4d q4e"
global varlist2 "q5a q5b q5d q5e q5f q5g q5h q5i q5j q5k q5l q5m q5n q5o q5p q5q q5r q5s q5t q5u q5v"
global varlist3 "q6a q6b q6c q6d q6e q6f q7a q7b q7c q7d q7e q8a q8b q8c q8d q8e q9a q9b q9c q9d q9e q9f"
global varlist4 "q10a q10b q10c q10d q10e q10f q10g q11a q11b q12a q12b q13a q13b q13c q13d q14a q14b q14c q14d q14e"
global varlist5 "q10a q10b q10c q10d q10e q10f q10g q11a q11b q12a q12b"
global varlist6 "q13a q13b q13c q13d q14a q14b q14c q14d q14e q15a q15b q15c q15d q15e q15f q15g q15h q15i"

/* Do you consider yourself a Democrat, a Republican, an independent or none of these? */
gen party = 1 if d1 == 1 /* Democrat */
replace party = 2 if d1 == 2 /* Republican */
replace party = 3 if d1 == 3 /* Independent */

replace partyid7 = . if partyid7 == -1

gen lean_democrat = 1 if partyid7>=1 & partyid7<=3
replace lean_democrat = 0 if partyid7>=4 & partyid7<=7

gen lean_republican = 1 if partyid7>=5 & partyid7<=7
replace lean_republican = 0 if partyid7>=1 & partyid7<=4

/* Party Affiliation at Time 1, alternative variables 
1 Democrat
2 Republican
3 Independent
4 None of these
77 DON'T KNOW
98 SKIPPED ON WEB
99 REFUSED
*/
gen democrat_t1 = 1 if d1 == 1
replace democrat_t1 = 0 if d1 == 2 | d1 == 3 | d1 == 4

gen republican_t1 = 1 if d1 == 2 
replace republican_t1 = 0 if d1 == 1 | d1 == 3 | d1 == 4

gen independent_t1 = 1 if d1 == 3
replace independent_t1 = 0 if d1 == 1 | d1 == 2 | d1 == 4

gen female = 1 if gender == 2
replace female = 0 if gender == 1

gen male = 1 if gender == 1
replace male = 0 if gender == 2

/* Metro area vs. non-metro area 
metro = 1 or metro = 0, variable already defined */
gen rural = 1 if metro == 0
replace rural = 0 if metro == 1

gen home_owner = 1 if housing == 1
replace home_owner = 0 if housing == 2 | housing == 3

encode state, gen(state_id)

/* AL stands for an "At Large" district */
gen cong_dist_state = substr(cong_dist, -2, .)
gen cong_dist_num = substr(cong_dist, -7, .)
replace cong_dist_num = substr(cong_dist_num, 1, 2)
replace cong_dist_num = "AL" if cong_dist_num == "e)"
replace cong_dist_num = "" if cong_dist_num == "AL"
destring cong_dist_num, replace
tostring cong_dist_num, replace
replace cong_dist_num = "AL" if cong_dist_num == "."
/* br caseid CONG_DIST cong_dist_state cong_dist_num state state_id */

/* Household income less than $30,000 */
gen lowinc = 1 if income<7
replace lowinc = 0 if income>=7 & income<=18

gen white = 1 if racethnicity == 1
replace white = 0 if racethnicity>1 & racethnicity<=6

gen hs_or_less = 1 if educ5 == 1 | educ5 == 2
replace hs_or_less = 0 if educ5>=3 & educ5<=5

/* Some college or above */
gen college_grad = 1 if educ5>=3 & educ5<=5
replace college_grad = 0 if educ5 == 1 | educ5 == 2

gen over60 = 1 if age4 == 4
replace over60 = 0 if age4<4

gen married = 1 if marital == 1
replace married = 0 if marital>1 & marital<=6

gen employed = 1 if employ == 1 | employ == 2
replace employed = 0 if employ>=3 & employ<=7

/* How often can you trust the media to report the news fairly?
1 is just about always, 3 is only some of the time, 4 is almost never */
gen trust_media = 1 if pa003>=1 & pa003<=3
replace trust_media = 0 if pa003==4

/* How much would you say you rely on social media for your news on politics and public affairs? */
gen rely_socmedia = m5
replace rely_socmedia = . if rely_socmedia >6

/* On average, on how many of the past 7 days would you say you watched the news on TV? 
If you didn’t watch news on TV at all, just say 0. */
gen watch_tv = m1
replace watch_tv = . if watch_tv >7

/* On average, on how many of the past 7 days did you talk with people about politics and public affairs? 
If you didn’t talk with people about politics and public affairs, just say 0. */
gen talk_politics = m4
replace talk_politics = . if talk_politics >7

/* There were 105 deliberation groups total; some deliberated over 4 weekdays, others deliberated over one weekend.
Participants could choose which arrangement they preferred. */
egen groupid = group(room t2p_option)

bys groupid: gen num_delegates = _N
replace num_delegates = . if delegate == 0 

/* Weekday deliberation (September 14, 16 and 21 and 23, 2022); or weekend deliberation (September 25-26, 2022)? */
gen weekday_delib = 1 if t2p_option == 1
replace weekday_delib = 0 if t2p_option == 2

/* At T3, only subset of the policy questions was asked,
so do the cleaning below only for t1 and t2 AND for t3 later for particular questions */
foreach i of global varlist1 {
    replace `i' = . if `i' == 77 | `i' == 98 | `i' == 99
	replace t2`i' = . if t2`i' == 77 | t2`i' == 98 | t2`i' == 99
}

foreach i of global varlist2 {
    replace `i' = . if `i' == 77 | `i' == 98 | `i' == 99
	replace t2`i' = . if t2`i' == 77 | t2`i' == 98 | t2`i' == 99
}

foreach i of global varlist3 {
    replace `i' = . if `i' == 77 | `i' == 98 | `i' == 99
	replace t2`i' = . if t2`i' == 77 | t2`i' == 98 | t2`i' == 99
}

foreach i of global varlist4 {
    replace `i' = . if `i' == 77 | `i' == 98 | `i' == 99
	replace t2`i' = . if t2`i' == 77 | t2`i' == 98 | t2`i' == 99
}

foreach i of global varlist5 {
    replace `i' = . if `i' == 77 | `i' == 98 | `i' == 99
	replace t2`i' = . if t2`i' == 77 | t2`i' == 98 | t2`i' == 99
}

foreach i of global varlist6 {
    replace `i' = . if `i' == 77 | `i' == 98 | `i' == 99
	replace t2`i' = . if t2`i' == 77 | t2`i' == 98 | t2`i' == 99
}

/* Democrats and Republicans defined by Question w/7 Responses:
PARTYID7: Strong Democrat, Not so strong Democrat, Lean Democrat
Don't Lean/Independent/None
Lean Republican, Not so strong Republican Strong Republican

Using PARTYID3, the same questions met Criteria 3 as when using PARTYID7,
except for Q1D. Q1D met Criteria 3 under PARTYID3 but not PARTYID7. However,
Q1D was NOT used in the actual deliberations. Therefore, we have exact overlap.
*/

/* Criteria 1: More than 50% of each party is on opposite poles. */
/* Criteria 2: More than 50% of each party is on opposite poles AND 15%+ of each party are at opposite extremes. */
/* Criteria 3: 15%+ of each party are at opposite extremes */
/*
Q0A: Criteria 1, Dems 6-10
Q1C: Criteria 3, Dems 6-10
Q1E: Criteria 3, Dems 6-10
Q2A: Criteria 3, Dems 6-10
Q2B: Criteria 3, Dems 6-10
Q2C: Criteria 3, Dems 6-10, Criteria 2, Dems 6-10, Criteria 1, Dems 6-10
Q3A: Criteria 3, Dems 6-10
Q3B: Criteria 3, Dems 6-10
Q5E: Criteria 1, Dems 6-10, Criteria 2, Dems 6-10, Criteria 3, Dems 6-10
Q5F: Criteria 3, Dems 6-10
Q5G: Criteria 3, Dems 6-10
Q5H: Criteria 1, Dems 6-10, Criteria 2, Dems 6-10, Criteria 3, Dems 6-10
Q5I: Criteria 3, Dems 6-10
Q5N: Criteria 1, Dems 6-10, Criteria 2, Dems 6-10, Criteria 3, Dems 6-10
Q5O: Criteria 1, Dems 6-10, Criteria 2, Dems 6-10, Criteria 3, Dems 6-10
Q6A: Criteria 3, Dems 6-10
Q6B: Criteria 3, Dems 6-10
Q6D: Criteria 3, Dems 6-10
Q6E: Criteria 3, Dems 6-10
Q6F: Criteria 3, Dems 6-10
Q7A: Criteria 3, Dems 6-10
Q7D: Criteria 3, Dems 6-10
Q7E: Criteria 3, Dems 6-10
Q8A: Criteria 3, Dems 6-10
Q9A: Criteria 3, Dems 6-10, Criteria 2, Dems 6-10, Criteria 1, Dems 6-10
Q9C: Criteria 3, Dems 0-4, Criteria 2, Dems 0-4, Criteria 1, Dems 0-4
Q9D: Criteria 3, Dems 6-10, Criteria 2, Dems 6-10, Criteria 1, Dems 6-10
Q9E: Criteria 3, Dems 6-10
Q9F: Criteria 3, Dems 6-10
Q10G: Criteria 3, Dems 6-10
Q11A: Criteria 3, Dems 6-10, Criteria 2, Dems 6-10, Criteria 1, Dems 6-10
Q11B: Criteria 3, Dems 6-10
Q12A: Criteria 3, Dems 0-4, Criteria 2, Dems 0-4, Criteria 1, Dems 0-4
Q12B: Criteria 3, Dems 6-10
*/

/* Using the PARTYID3 variable, we had the SAME questions meet criteria 1 and 2
when using the PARTYID7 variable, except Q2B. 11 questions meet criteria 1  and 2
when using PARTYID3 and 10 met criteria 1 and 2 when using PARTYID7:
Q0A: Criteria 1, Dems 6-10
Q2B: Criteria 1, Criteria 2, Dems 6-10
Q2C: Criteria 1, Criteria 2, Dems 6-10
Q5E: Criteria 1, Criteria 2, Dems 6-10
Q5H: Criteria 1, Criteria 2, Dems 6-10
Q5N: Criteria 1, Criteria 2, Dems 6-10
Q5O: Criteria 1, Criteria 2, Dems 6-10
Q9A: Criteria 1, Criteria 2, Dems 6-10
Q9C: Criteria 1, Criteria 2, Dems 0-4
Q9D: Criteria 1, Criteria 2, Dems 6-10
Q11A: Criteria 1, Criteria 2, Dems 6-10
Q12A: Criteria 1, Criteria 2, Dems 0-4
*/

/* Define the PBS using Criteria 3: 27 Questions Included! 
Exclude Q1C Q1E Q11A Q11B Q12A Q12B because they were not actually part of the deliberations 
*/
global varlist_full "q2a q2b q2c q3a q3b q5e q5f q5g q5h q5i q5n q5o q6a q6b q6d q6e q6f q7a q7d q7e q8a q9a q9c q9d q9e q9f q10g"
global varlist_reverse "q2a q2b q2c q3a q3b q5e q5f q5g q5h q5i q5n q5o q6a q6b q6d q6e q6f q7a q7d q7e q8a q9a q9d q9e q9f q10g"
global varlist_correct "q9c"

foreach i of global varlist_full {
    gen `i'_is = .
	gen t2`i'_is = .
	gen t3`i'_is = .
}

/* Some scores are 77, 88, or 99 if data are missing. Only include scores
0 through 10 in our index */

/* Scores on the left are Republican, so we
must move them to the right */
foreach i of global varlist_reverse {
    replace `i'_is = 0 if `i' == 10
	replace `i'_is = 1 if `i' == 9
	replace `i'_is = 2 if `i' == 8
	replace `i'_is = 3 if `i' == 7
	replace `i'_is = 4 if `i' == 6
	replace `i'_is = 5 if `i' == 5
	replace `i'_is = 6 if `i' == 4
	replace `i'_is = 7 if `i' == 3
	replace `i'_is = 8 if `i' == 2
	replace `i'_is = 9 if `i' == 1
	replace `i'_is = 10 if `i' == 0
replace `i'_is = . if t3`i' == 77 | t3`i' == 98 | t3`i' == 99
	
	replace t2`i'_is = 0 if t2`i' == 10
	replace t2`i'_is = 1 if t2`i' == 9
	replace t2`i'_is = 2 if t2`i' == 8
	replace t2`i'_is = 3 if t2`i' == 7
	replace t2`i'_is = 4 if t2`i' == 6
	replace t2`i'_is = 5 if t2`i' == 5
	replace t2`i'_is = 6 if t2`i' == 4
	replace t2`i'_is = 7 if t2`i' == 3
	replace t2`i'_is = 8 if t2`i' == 2
	replace t2`i'_is = 9 if t2`i' == 1
	replace t2`i'_is = 10 if t2`i' == 0
replace t2`i'_is = . if t2`i' == 77 | t2`i' == 98 | t2`i' == 99
	
	replace t3`i'_is = 0 if t3`i' == 10
	replace t3`i'_is = 1 if t3`i' == 9
	replace t3`i'_is = 2 if t3`i' == 8
	replace t3`i'_is = 3 if t3`i' == 7
	replace t3`i'_is = 4 if t3`i' == 6
	replace t3`i'_is = 5 if t3`i' == 5
	replace t3`i'_is = 6 if t3`i' == 4
	replace t3`i'_is = 7 if t3`i' == 3
	replace t3`i'_is = 8 if t3`i' == 2
	replace t3`i'_is = 9 if t3`i' == 1
	replace t3`i'_is = 10 if t3`i' == 0
replace t3`i'_is = . if t3`i' == 77 | t3`i' == 98 | t3`i' == 99
}

/* Scores on the right are Republican */
foreach i of global varlist_correct {
    replace `i'_is = `i'
	replace t2`i'_is = t2`i'
	replace t3`i'_is = t3`i'
replace t3`i'_is = . if t3`i' == 77 | t3`i' == 98 | t3`i' == 99
}

/* Note: Some people do not answer all of the questions! */
egen ideology_score1 = rowmean(q2a_is q2b_is q2c_is q3a_is q3b_is q5e_is q5f_is q5g_is q5h_is q5i_is q5n_is q5o_is q6a_is q6b_is q6d_is q6e_is q6f_is q7a_is q7d_is q7e_is q8a_is q9a_is q9c_is q9d_is q9e_is q9f_is q10g_is)
egen ideology_score2 = rowmean(t2q2a_is t2q2b_is t2q2c_is t2q3a_is t2q3b_is t2q5e_is t2q5f_is t2q5g_is t2q5h_is t2q5i_is t2q5n_is t2q5o_is t2q6a_is t2q6b_is t2q6d_is t2q6e_is t2q6f_is t2q7a_is t2q7d_is t2q7e_is t2q8a_is t2q9a_is t2q9c_is t2q9d_is t2q9e_is t2q9f_is t2q10g_is)
egen ideology_score3 = rowmean(t3q2a_is t3q2b_is t3q2c_is t3q3a_is t3q3b_is t3q5e_is t3q5f_is t3q5g_is t3q5h_is t3q5i_is t3q5n_is t3q5o_is t3q6a_is t3q6b_is t3q6d_is t3q6e_is t3q6f_is t3q7a_is t3q7d_is t3q7e_is t3q8a_is t3q9a_is t3q9c_is t3q9d_is t3q9e_is t3q9f_is t3q10g_is)

gen ideology_diff1_2 = ideology_score2 - ideology_score1
gen ideology_diff1_3 = ideology_score3 - ideology_score1

global varlist_t3 "t3q0a t3q0b t3q0c t3q1a t3q1b t3q1c t3q1d t3pa006 t3q13d t3q32 t3elect3a t3elect3e t3elect3h"

foreach i of global varlist_t3 {
	replace `i' = . if `i' == 77 | `i' == 98 | `i' == 99
}

/* Larger value means higher level of WORRY about climate change 
Question wording:
Q0A: How worried are you about the current condition of the natural environment in your local area?
Q0B: How worried are you about the current condition of the natural environment in the United States?
Q0C: How worried are you about the current condition of the natural environment of the earth as a whole?
*/
egen worry_score1 = rowmean(q0a q0b q0c)
egen worry_score2 = rowmean(t2q0a t2q0b t2q0c)
egen worry_score3 = rowmean(t3q0a t3q0b t3q0c)

gen worry_diff1_2 = worry_score2 - worry_score1
gen worry_diff1_3 = worry_score3 - worry_score1

/* Larger value means more agreement with established BELIEF about climate change
Question wording:
Q1A: Our planet is experiencing an increase in global temperatures that will greatly harm our quality of life.
Q1B: Rising temperatures are caused by human activities that emit greenhouse gases, like carbon dioxide and methane, which trap heat in the atmosphere and warm the earth’s climate.
Q1C: Failure to address these issues (rising temperatures) will threaten human life on earth within the next century.
Q1D: In order to stop the increase in global temperatures, humans must stop adding to the total amount of climate-heating gases in the atmosphere (reach Net Zero).
*/
egen belief_score1 = rowmean(q1a q1b q1c q1d)
egen belief_score2 = rowmean(t2q1a t2q1b t2q1c t2q1d)
egen belief_score3 = rowmean(t3q1a t3q1b t3q1c t3q1d)

gen belief_diff1_2 = belief_score2 - belief_score1
gen belief_diff1_3 = belief_score3 - belief_score1

/* Climate Knowledge */
/* Knowledge of Climate Facts
Q19	Which of the following best describes Net Zero?	1	Capturing fossil fuels emissions with a special net in the atmosphere
		2	Storing emissions underground
		3	Not adding to the total amount of climate-heating gases in the atmosphere
		4	Using the same amount of renewable energy and fossil fuels so we don’t use too much from one source of energy
		77	Couldn’t say
		98	SKIPPED ON WEB
		99	REFUSED
Q20	What is the name of a method by which government can encourage emitters to reduce the amount of greenhouse gases they emit?	1	Carbon pricing
		2	Carbon capture
		3	Carbon sequestration
		4	Carbon coin
		77	Couldn’t say
		98	SKIPPED ON WEB
		99	REFUSED
Q21	Which of the following emit greenhouse gas emissions?	1	Methane
		2	Coal
		3	Oil
		4	Natural gas
		5	All of the above
		77	Couldn’t say
		98	SKIPPED ON WEB
		99	REFUSED
Q22	Which country emits the most greenhouse gas emissions?	1	China
		2	US
		3	Japan
		4	Brazil
		77	Couldn’t say
		98	SKIPPED ON WEB
		99	REFUSED
Q23	The term ‘fossil fuels’ refers to which of the following energy source?	1	Hydrocarbons
		2	Biofuels
		3	New generation nuclear
		4	Hydrogen
		77	Couldn’t say
		98	SKIPPED ON WEB
		99	REFUSED
Q24	Which international agreement is about climate change?	1	Paris Agreement
		2	Trans-Pacific Partnership
		3	United Nations Relief Partnership
		4	G20 Agreement on Pillars One and Two
		77	Couldn’t say
		98	SKIPPED ON WEB
		99	REFUSED
*/
gen q19_correct = 1 if q19 == 3
replace q19_correct = 0 if q19 !=3

gen q20_correct = 1 if q20 == 1
replace q20_correct = 0 if q20 !=1

gen q21_correct = 1 if q21 == 5
replace q21_correct = 0 if q21 !=5

gen q22_correct = 1 if q22 == 1
replace q22_correct = 0 if q22 !=1

gen q23_correct = 1 if q23 == 1
replace q23_correct = 0 if q23 !=1

gen q24_correct = 1 if q24 == 1
replace q24_correct = 0 if q24 !=1

gen climate_knowledge1 = (q19_correct + q20_correct + q21_correct + q22_correct + q23_correct +q24_correct)/6

/* For t2 */
gen t2q19_correct = 1 if t2q19 == 3
replace t2q19_correct = 0 if t2q19 !=3

gen t2q20_correct = 1 if t2q20 == 1
replace t2q20_correct = 0 if t2q20 !=1

gen t2q21_correct = 1 if t2q21 == 5
replace t2q21_correct = 0 if t2q21 !=5

gen t2q22_correct = 1 if t2q22 == 1
replace t2q22_correct = 0 if t2q22 !=1

gen t2q23_correct = 1 if t2q23 == 1
replace t2q23_correct = 0 if t2q23 !=1

gen t2q24_correct = 1 if t2q24 == 1
replace t2q24_correct = 0 if t2q24 !=1

gen climate_knowledge2 = (t2q19_correct + t2q20_correct + t2q21_correct + t2q22_correct + t2q23_correct +t2q24_correct)/6

/* For t3 */
gen t3q19_correct = 1 if t3q19 == 3
replace t3q19_correct = 0 if t3q19 !=3

gen t3q20_correct = 1 if t3q20 == 1
replace t3q20_correct = 0 if t3q20 !=1

gen t3q21_correct = 1 if t3q21 == 5
replace t3q21_correct = 0 if t3q21 !=5

gen t3q22_correct = 1 if t3q22 == 1
replace t3q22_correct = 0 if t3q22 !=1

gen t3q23_correct = 1 if t3q23 == 1
replace t3q23_correct = 0 if t3q23 !=1

gen t3q24_correct = 1 if t3q24 == 1
replace t3q24_correct = 0 if t3q24 !=1

gen climate_knowledge3 = (t3q19_correct + t3q20_correct + t3q21_correct + t3q22_correct + t3q23_correct +t3q24_correct)/6

gen climate_knowledge_diff1_2 = 100*(climate_knowledge2 - climate_knowledge1)/6
gen climate_knowledge_diff1_3 = 100*(climate_knowledge3 - climate_knowledge1)/6

/* 
[I have opinions about politics that are worth listening to.] To what extent do you disagree/agree…
*/
gen worth_listening1 = q13d if q13d<=10
gen worth_listening2 = t2q13d if t2q13d<=10
gen worth_listening3 = t3q13d if t3q13d<=10

gen worth_listening_diff1_2 = worth_listening2 - worth_listening1
gen worth_listening_diff1_3 = worth_listening3 - worth_listening1

/*
T3ELECT3E	Climate change	0	0 – Of no importance at all
		1	1
		2	2
		3	3
		4	4
		5	5 – In the middle
		6	6
		7	7
		8	8
		9	9
		10	10 – Extremely important
*/
gen importance_climate3 = t3elect3e if t3elect3e<=10

/*
T3ELECT3H	Crime	0	0 – Of no importance at all
		1	1
		2	2
		3	3
		4	4
		5	5 – In the middle
		6	6
		7	7
		8	8
		9	9
		10	10 – Extremely important
*/
gen importance_crime3 = t3elect3h if t3elect3h<=10

/*
T3ELECT3A	Threats to democracy	0	0 – Of no importance at all
		1	1
		2	2
		3	3
		4	4
		5	5 – In the middle
		6	6
		7	7
		8	8
		9	9
		10	10 – Extremely important
*/
gen importance_democracy3 = t3elect3a if t3elect3a<=10

/*
What is your preference for the outcome of the 2022 congressional elections?	
	1	Democratic control
	2	Republican control
	3	One party controls House, other controls the Senate
	4	No preference
	77	DON'T KNOW
	98	SKIPPED ON WEB
	99	REFUSED
*/
gen congress_pref3 = t3elect4 if t3elect4 <=4
gen congress_pref_dem3 = 1 if t3elect4 == 1
replace congress_pref_dem3 = 0 if t3elect4 > 1 & t3elect4 <=4
replace congress_pref_dem3 = 0 if t3elect4 == 77 | t3elect4 == 98 | t3elect4 == 99

gen congress_pref_rep3 = 1 if t3elect4 == 2
replace congress_pref_rep3 = 0 if t3elect4 == 1
replace congress_pref_rep3 = 0 if t3elect4 >2 & t3elect4 <=4
replace congress_pref_rep3 = 0 if t3elect4 == 77 | t3elect4 == 98 | t3elect4 == 99

/*
There are a range of reasons why people do or do not vote. We’re interested in hearing from voters and non-voters. How likely are you to vote in the upcoming November elections?
1	Definitely will vote
2	Probably will vote
3	Probably will not vote
4	Definitely will not vote
5	I already voted

Create definition below because otherwise 94% say they are likely to vote (1, 2, or 5)
*/
gen definitely_vote3 = 1 if t3q32==1 | t3q32 == 5
replace definitely_vote3 = 0 if t3q32==2 | t3q32==3 | t3q32==4


save climate_data_foranalyses_27items.dta, replace
