replace envir1p=qfp2a_a if casetype==9
replace envir1p_r=envir1p/10 if casetype==9

egen t2envir_c=rmean(envir1p_r)

replace ussec1p=qfp2b_s if casetype==9
replace ussec1p_r=ussec1p/10
egen ussec678p_r=rmean(ussec6p_r ussec7p_r ussec8p_r)
egen t2ussec_c=rmean(ussec1p_r ussec2p_r ussec3p_r ussec45


egen envtest23_r=rmean(prenvir2_r prenvir3_r) if casetype==1|casetype==9
egen envtest23p_r=rmean(envir2p_r envir3p_r) if casetype==1|casetype==9

 
egen t1envir=rmean(envir1_r envir23_r envir4_r) if casetype==1
egen t2envir=rmean(envir1p_r envir23p_r envir4p_r) if casetype==1

egen t1envirtest=rmean(envir1_r envtest23_r envir4_r) if casetype==1
egen t2envirtest=rmean(envir1p_r envtest23p_r envir4p_r) if casetype==1

egen t1envirtest1=rmean(envir1_r envir2_r envir3_r envir4_r) if casetype==1
egen t2envirtest1=rmean(envir1p_r envir2p_r envir3p_r envir4p_r) if casetype==1

egen t1envir_c=rmean(envir1_r) if casetype==1|casetype==9
egen t2envir_c=rmean(envir1p_r) if casetype==1|casetype==9

US SECURITY:
egen ussec5689_r=rmean(ussec5_r ussec6_r ussec8_r ussec9_r) if casetype==1
egen ussec5689p_r=rmean(ussec5p_r ussec6p_r ussec8p_r ussec9p_r) if casetype==1

egen t1ussec=rmean(ussec1_r ussec2_r ussec3_r ussec4_r ussec5689_r) if casetype==1
egen t2ussec=rmean(ussec1p_r ussec2p_r ussec3p_r ussec4p_r ussec5689p_r) if casetype==1

egen t1ussec_c=rmean(ussec1_r ussec2_r ussec3_r ussec5689_r) if casetype==1|casetype==9
egen t2ussec_c=rmean(ussec1p_r ussec2p_r ussec3p_r ussec5689p_r) if casetype==1|casetype==9

FOREIGN AID:
egen t1foraid=rmean(foraid3_r) if casetype==1
egen t2foraid=rmean(foraid3p_r) if casetype==1

HUMAN RIGHTS:
egen t1humrht=rmean(humrht1_r) if casetype==1
egen t2humrht=rmean(humrht1p_r) if casetype==1

egen t1humrht_c=rmean(humrht1_r) if casetype==1|casetype==9
egen t2humrht_c=rmean(humrht1p_r) if casetype==1|casetype==9

DEMOCRACY:
egen demo345678_r=rmean(demo3_r demo4_r demo5_r demo6_r demo7_r demo8_r) if casetype==1
egen demo345678p_r=rmean(demo3p_r demo4p_r demo5p_r demo6p_r demo7p_r demo8p_r) if casetype==1|casetype==9

egen t1demo=rmean(demo2_r demo345678_r demo9_r) if casetype==1
egen t2demo=rmean(demo2p_r demo345678p_r demo9p_r) if casetype==1

MULTILATERALISM:
egen t1multi=rmean(multi2_r multi3_r multi4_5_r multi6_7_r multi10_r multi11_r multi12_r multi13_r) if casetype==1
egen t2multi=rmean(multi2p_r multi3p_r multi4_5p_r multi6_7p_r multi10p_r multi11p_r multi12p_r multi13p_r) if casetype==1

egen t1multi_c=rmean(multi2_r multi6_7_r multi10_r multi11_r multi12_r) if casetype==1|casetype==9
egen t2multi_c=rmean(multi2p_r multi6_7p_r multi10p_r multi11p_r multi12p_r) if casetype==1|casetype==9

GLOBAL ALTRUISM:

egen globalt34_r=rmean(globlat3_r globalt4_r) if casetype==1
egen globalt78_r=rmean(globalt7_r globalt8_r) if casetype==1
egen globalt56_r=rmean(globalt5_r globalt6_r) if casetype==1

egen globalt34p_r=rmean(globlat3p_r globalt4p_r) if casetype==1|casetype==9
egen globalt78p_r=rmean(globalt7p_r globalt8p_r) if casetype==1|casetype==9
egen globalt56p_r=rmean(globalt5p_r globalt6p_r) if casetype==1|casetype==9

egen t1globalt=rmean(globalt1_r globalt2_r globalt34_r globalt5_r globalt6_r globalt78_r) if casetype==1
egen t2globalt=rmean(globalt1p_r globalt2p_r globalt34p_r globalt5p_r globalt6p_r globalt78p_r) if casetype==1

egen t1globalta=rmean(globalt1_r globalt2_r globalt34_r globalt56_r globalt7_r globalt8_r) if casetype==1
egen t2globalta=rmean(globalt1p_r globalt2p_r globalt34p_r globalt56p_r globalt7p_r globalt8p_r) if casetype==1

egen t1globalt_c=rmean(globalt1_r globalt2_r globalt5_r globalt6_r) if casetype==1|casetype==9
egen t2globalt_c=rmean(globalt1p_r globalt2p_r globalt5p_r globalt6p_r) if casetype==1|casetype==9


INTERNATIONALISM:
egen t1inter=rmean(inter1_r) if casetype==1
egen t2inter=rmean(inter1p_r) if casetype==1

egen t1inter_c=rmean(inter1_r) if casetype==1|casetype==9
egen t2inter_c=rmean(inter1p_r) if casetype==1|casetype==9

TRADE:
egen t1trade=rmean(trade1_r) if casetype==1
egen t2trade=rmean(trade1p_r) if casetype==1

egen t1trade_c=rmean(trade1_r) if casetype==1|casetype==9
egen t2trade_c=rmean(trade1p_r) if casetype==1|casetype==9


ENVIRONMENT REVISION:
egen t1envirtest2=rmean(envir2_r envir3_r envir4_r) if exp_cond==1
egen t2envirtest2=rmean(envir2p_r envir3p_r envir4p_r) if exp_cond==1

drop ussec1_r ussec2_r ussec3_r ussec4_r ussec5_r ussec6_r ussec8_r ussec9_r ussec10_r ussec11_r
drop ussec1p_r ussec2p_r ussedrop foraid1_r foraid2_r foraid3_r
c3p_r ussec4p_r ussec5p_r ussec6p_r ussec8p_r ussec9p_r ussec10p_r ussec11p_r

drop foraid1p_r foraid2p_r foraid3p_r 

GENERATING DIFFERENCES:
gen DIF_envir=t2envir-t1envir
gen DIF_ussec=t2ussec-t1ussec
gen DIF_humrht=t2humrht-t1humrht
gen DIF_multi=t2multi-t1multi
gen DIF_globalt=t2globalt-t1globalt
gen DIF_inter=t2inter-t1inter
gen DIF_foraid=t2foraid-t1foraid
gen DIF_demo=t2demo-t1demo
gen DIF_trade=t2trade-t1trade


GENERATING GROUP MEANS:

egen sumt1envir=sum(t1envir) if casetype==1, by(group)
egen sumt1ussec=sum(t1ussec) if casetype==1, by(group)
egen sumt1foraid=sum(t1foraid) if casetype==1, by(group)
egen sumt1globalta=sum(t1globalta) if casetype==1, by(group)
egen sumt1globalt=sum(t1globalt) if casetype==1, by(group)
egen sumt1humrht=sum(t1humrht) if casetype==1, by(group)
egen sumt1multi=sum(t1multi) if casetype==1, by(group)
egen sumt1inter=sum(t1inter) if casetype==1, by(group)
egen sumt1demo=sum(t1demo) if casetype==1, by(group)
egen sumt1trd=sum(t1trade) if casetype==1, by(group)

gen envircnt=1 if t1envir~=.&casetype==1
egen envir_n=sum(envircnt) if casetype==1, by(group)
gen usseccnt=1 if t1ussec~=.&casetype==1
egen ussec_n=sum(usseccnt) if casetype==1, by(group)
gen foraidcnt=1 if t1foraid~=.&casetype==1
egen foraid_n=sum(foraidcnt) if casetype==1, by(group)
gen globaltacnt=1 if t1globalta~=.&casetype==1
egen globalta_n=sum(globaltacnt) if casetype==1, by(group)
gen globaltcnt=1 if t1globalt~=.&casetype==1
egen globalt_n=sum(globaltcnt) if casetype==1, by(group)
gen humrhtcnt=1 if t1humrht~=.&casetype==1
egen humrht_n=sum(humrhtcnt) if casetype==1, by(group)
gen multicnt=1 if t1multi~=.&casetype==1
egen multi_n=sum(multicnt) if casetype==1, by(group)
gen intercnt=1 if t1inter~=.&casetype==1
egen inter_n=sum(intercnt) if casetype==1, by(group)
gen democnt=1 if t1demo~=.&casetype==1
egen demo_n=sum(democnt) if casetype==1, by(group)
gen tradecnt=1 if t1trade~=.&casetype==1
egen trade_n=sum(tradecnt) if casetype==1, by(group)


gen grp_envir=(sumt1envir-t1envir)/(envir_n-1) if casetype==1
gen grp_ussec=(sumt1ussec-t1ussec)/(ussec_n-1) if casetype==1
gen grp_foraid=(sumt1foraid-t1foraid)/(foraid_n-1) if casetype==1
gen grp_globalt=(sumt1globalt-t1globalt)/(globalt_n-1) if casetype==1
gen grp_globalta=(sumt1globalta-t1globalta)/(globalta_n-1) if casetype==1
gen grp_humrht=(sumt1humrht-t1humrht)/(humrht_n-1) if casetype==1
gen grp_multi=(sumt1multi-t1multi)/(multi_n-1) if casetype==1
gen grp_inter=(sumt1inter-t1inter)/(inter_n-1) if casetype==1
gen grp_demo=(sumt1demo-t1demo)/(demo_n-1) if casetype==1
gen grp_trade=(sumt1trd-t1trade)/(trade_n-1) if casetype==1

gen DIF_env_grp=t1envir-grp_envir if casetype==1
gen DIF_ussec_grp=t1ussec-grp_ussec if casetype==1
gen DIF_foraid_grp=t1foraid-grp_foraid if casetype==1
gen DIF_globalt_grp=t1globalt-grp_globalt if casetype==1
gen DIF_globalta_grp=t1globalta-grp_globalta if casetype==1
gen DIF_humrht_grp=t1humrht-grp_humrht if casetype==1
gen DIF_multi_grp=t1multi-grp_multi if casetype==1
gen DIF_inter_grp=t1inter-grp_inter if casetype==1
gen DIF_demo_grp=t1demo-grp_demo if casetype==1
gen DIF_trd_grp=t1trade-grp_trade if casetype==1

egen t1humrhta=rmean(humrht1_r humrht2_r) if casetype==1
egen t2humrhta=rmean(humrht1p_r humrht2p_r) if casetype==1
gen DIF_humrhta=t2humrhta-t1humrhta if casetype==1
