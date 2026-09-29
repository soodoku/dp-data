gen trade1_rtest=trade1_r
replace trade1_rtest=0 if trd1_a==.&casetype==1

gen trade1p_rtest=trade1p_r
replace trade1p_rtest=0 if qtrd1_a==.&casetype==1

gen t1trade_a=trade1_r 
gen t2trade_a=trade1p_r

gen t1trade_b=trade2_r
gen t2trade_b=trade2p_r

egen t1rade_c=rmean(trade1_r trade2_r)
egen t2trade_c=rmean(trade1p_r trade2p_r)

