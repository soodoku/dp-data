Merge Data Scripts
-----------------------
1. 01_gaurav.R
	* Collates all the poll level data from cdd/data/pkdat
	* Output: cdd/data/pkdat/gaurav.Rdata

2. 02_nuri.R
	* Fixes nuri_caseid and deposits it at cdd/data/pkdat/nuri.rdata
	* Deposits nurikyu in cdd/data/nuri
	* Patches btp04

3. 03_data.R
	* Input: 
		* cdd/data/pkdat/gaurav.rdata
		* cdd/data/pkdat/nuri.rdata

	* Fixes stuff, aggregates, redoes group and poll level variables (except for attitude)
	* Output: cdd/data/pkdata/agg_data.rdata 

4. 04_kyu.R
	* Input: 
		* cdd/data/pkdata/agg_data.rdata
		* Att. indices from: 
			cdd/data/agg/bypoll/ and
			cdd/data/nuri/nurikyu.rdata
	* Appends Indices to clean core file data
	* Output:
		* cdd/data/agg/kyudata.rdata 

5. 05_fix.R
	* Input: 
		* cdd/data/agg/kyudata.csv
		* cdd/meta_data/attitude_indices/AllPollIndices.csv
	* Function: Fixes, taking out empirical premises etc. 
	* Output: 
		* cdd/data/agg/polardata.csv