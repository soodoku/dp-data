drop if exp_cond==0&f_resume==.
drop if exp_cond==1&dpoll_n==.

egen t1envmu=mean(t1envir), by(dpoll_no1)
egen t2envmu=mean(t2envir), by(dpoll_no1)

egen t1ussecamu=mean(t1usseca), by(dpoll_no1)
egen t2ussecamu=mean(t2usseca), by(dpoll_no1)

egen t1ussecbmu=mean(t1ussecb), by(dpoll_no1)
egen t2ussecbmu=mean(t2ussecb), by(dpoll_no1)

egen t1usseccmu=mean(t1ussecc), by(dpoll_no1)
egen t2usseccmu=mean(t2ussecc), by(dpoll_no1)

egen t1foraidamu=mean(t1foraida), by(dpoll_no1)
egen t2foraidamu=mean(t2foraida), by(dpoll_no1)

egen t1foraidbmu=mean(t1foraidb), by(dpoll_no1)
egen t2foraidbmu=mean(t2foraidb), by(dpoll_no1)

egen t1globaltamu=mean(t1globalta), by(dpoll_no1)
egen t2globaltamu=mean(t2globalta), by(dpoll_no1)

egen t1globaltbmu=mean(t1globaltb), by(dpoll_no1)
egen t2globaltbmu=mean(t2globaltb), by(dpoll_no1)

egen t1globaltcmu=mean(t1globaltc), by(dpoll_no1)
egen t2globaltcmu=mean(t2globaltc), by(dpoll_no1)

egen t1intermu=mean(t1inter), by(dpoll_no1)
egen t2intermu=mean(t2inter), by(dpoll_no1)

egen t1multimu=mean(t1multi), by(dpoll_no1)
egen t2multimu=mean(t2multi), by(dpoll_no1)

egen t1demomu=mean(t1demo), by(dpoll_no1)
egen t2demomu=mean(t2demo), by(dpoll_no1)

egen t1humrhtamu=mean(t1humrhta), by(dpoll_no1)
egen t2humrhtamu=mean(t2humrhta), by(dpoll_no1)

egen t1humrhtbmu=mean(t1humrhtb), by(dpoll_no1)
egen t2humrhtbmu=mean(t2humrhtb), by(dpoll_no1)

egen t1humrhtcmu=mean(t1humrhtc), by(dpoll_no1)
egen t2humrhtcmu=mean(t2humrhtc), by(dpoll_no1)

egen t1trademu=mean(t1trade), by(dpoll_no1)
egen t2trademu=mean(t2trade), by(dpoll_no1)

gen dev_mid_env=1 if ((t1envmu<.5)&((t2envmu-t1envmu)<0))|((t1envmu>.5)&((t2envmu-t1envmu)>0))
replace dev_mid_env=0 if dev_mid_env~=1

gen dev_mid_usseca=1 if ((t1ussecamu<.5)&((t2ussecamu-t1ussecamu)<0))|((t1ussecamu>.5)&((t2ussecamu-t1ussecamu)>0))
replace dev_mid_usseca=0 if dev_mid_usseca~=1

gen dev_mid_ussecb=1 if ((t1ussecbmu<.5)&((t2ussecbmu-t1ussecbmu)<0))|((t1ussecbmu>.5)&((t2ussecbmu-t1ussecbmu)>0))
replace dev_mid_ussecb=0 if dev_mid_ussecb~=1

gen dev_mid_multi=1 if ((t1multimu<.5)&((t2multimu-t1multimu)<0))|((t1multimu>.5)&((t2multimu-t1multimu)>0))
replace dev_mid_multi=0 if dev_mid_multi~=1

gen dev_mid_demo=1 if ((t1demomu<.5)&((t2demomu-t1demomu)<0))|((t1demomu>.5)&((t2demomu-t1demomu)>0))
replace dev_mid_demo=0 if dev_mid_demo~=1

gen dev_mid_foraida=1 if ((t1foraidamu<.5)&((t2foraidamu-t1foraidamu)<0))|((t1foraidamu>.5)&((t2foraidamu-t1foraidamu)>0))
replace dev_mid_foraida=0 if dev_mid_foraida~=1

gen dev_mid_foraidb=1 if ((t1foraidbmu<.5)&((t2foraidbmu-t1foraidbmu)<0))|((t1foraidbmu>.5)&((t2foraidbmu-t1foraidbmu)>0))
replace dev_mid_foraidb=0 if dev_mid_foraidb~=1

gen dev_mid_globalta=1 if ((t1globaltamu<.5)&((t2globaltamu-t1globaltamu)<0))|((t1globaltamu>.5)&((t2globaltamu-t1globaltamu)>0))
replace dev_mid_globalta=0 if dev_mid_globalta~=1

gen dev_mid_globaltb=1 if ((t1globaltbmu<.5)&((t2globaltbmu-t1globaltbmu)<0))|((t1globaltbmu>.5)&((t2globaltbmu-t1globaltbmu)>0))
replace dev_mid_globaltb=0 if dev_mid_globaltb~=1

gen dev_mid_globaltc=1 if ((t1globaltcmu<.5)&((t2globaltcmu-t1globaltcmu)<0))|((t1globaltcmu>.5)&((t2globaltcmu-t1globaltcmu)>0))
replace dev_mid_globaltc=0 if dev_mid_globaltc~=1

gen dev_mid_humrhta=1 if ((t1humrhtamu<.5)&((t2humrhtamu-t1humrhtamu)<0))|((t1humrhtamu>.5)&((t2humrhtamu-t1humrhtamu)>0))
replace dev_mid_humrhta=0 if dev_mid_humrhta~=1

gen dev_mid_humrhtb=1 if ((t1humrhtbmu<.5)&((t2humrhtbmu-t1humrhtbmu)<0))|((t1humrhtbmu>.5)&((t2humrhtbmu-t1humrhtbmu)>0))
replace dev_mid_humrhtb=0 if dev_mid_humrhtb~=1

gen dev_mid_humrhtc=1 if ((t1humrhtcmu<.5)&((t2humrhtcmu-t1humrhtcmu)<0))|((t1humrhtcmu>.5)&((t2humrhtcmu-t1humrhtcmu)>0))
replace dev_mid_humrhtc=0 if dev_mid_humrhtc~=1

gen dev_mid_inter=1 if ((t1intermu<.5)&((t2intermu-t1intermu)<0))|((t1intermu>.5)&((t2intermu-t1intermu)>0))
replace dev_mid_inter=0 if dev_mid_inter~=1

gen dev_mid_trade=1 if ((t1trademu<.5)&((t2trademu-t1trademu)<0))|((t1trademu>.5)&((t2trademu-t1trademu)>0))
replace dev_mid_trade=0 if dev_mid_trade~=1

egen t1envgrmu=mean(t1envir) if exp_cond==1
egen t2envgrmu=mean(t2envir) if exp_cond==1

egen t1ussecagrmu=mean(t1usseca) if exp_cond==1
egen t2ussecagrmu=mean(t2usseca) if exp_cond==1

egen t1ussecbgrmu=mean(t1ussecb)if exp_cond==1
egen t2ussecbgrmu=mean(t2ussecb)if exp_cond==1

egen t1foraidagrmu=mean(t1foraida)if exp_cond==1
egen t2foraidagrmu=mean(t2foraida)if exp_cond==1

egen t1foraidbgrmu=mean(t1foraidb)if exp_cond==1
egen t2foraidbgrmu=mean(t2foraidb)if exp_cond==1

egen t1globaltagrmu=mean(t1globalta)if exp_cond==1
egen t2globaltagrmu=mean(t2globalta)if exp_cond==1

egen t1globaltbgrmu=mean(t1globaltb)if exp_cond==1
egen t2globaltbgrmu=mean(t2globaltb)if exp_cond==1

egen t1globaltcgrmu=mean(t1globaltc)if exp_cond==1
egen t2globaltcgrmu=mean(t2globaltc)if exp_cond==1

egen t1intergrmu=mean(t1inter)if exp_cond==1
egen t2intergrmu=mean(t2inter)if exp_cond==1

egen t1multigrmu=mean(t1multi)if exp_cond==1
egen t2multigrmu=mean(t2multi)if exp_cond==1

egen t1demogrmu=mean(t1demo)if exp_cond==1
egen t2demogrmu=mean(t2demo)if exp_cond==1

egen t1humrhtagrmu=mean(t1humrhta)if exp_cond==1
egen t2humrhtagrmu=mean(t2humrhta)if exp_cond==1

egen t1humrhtbgrmu=mean(t1humrhtb)if exp_cond==1
egen t2humrhtbgrmu=mean(t2humrhtb)if exp_cond==1

egen t1humrhtcgrmu=mean(t1humrhtc)if exp_cond==1
egen t2humrhtcgrmu=mean(t2humrhtc)if exp_cond==1

egen t1tradegrmu=mean(t1trade)if exp_cond==1
egen t2tradegrmu=mean(t2trade)if exp_cond==1

gen dev_grmu_env=1 if ((t1envmu<t1envgrmu)&((t2envmu-t1envmu)<0))|((t1envmu>t1envgrmu)&((t2envmu-t1envmu)>0))
replace dev_grmu_env=0 if dev_grmu_env~=1

gen dev_grmu_usseca=1 if ((t1ussecamu<t1ussecagrmu)&((t2ussecamu-t1ussecamu)<0))|((t1ussecamu>t1ussecagrmu)&((t2ussecamu-t1ussecamu)>0))
replace dev_grmu_usseca=0 if dev_grmu_usseca~=1

gen dev_grmu_ussecb=1 if ((t1ussecbmu<t1ussecbgrmu)&((t2ussecbmu-t1ussecbmu)<0))|((t1ussecbmu>t1ussecbgrmu)&((t2ussecbmu-t1ussecbmu)>0))
replace dev_grmu_ussecb=0 if dev_grmu_ussecb~=1

gen dev_grmu_multi=1 if ((t1multimu<t1multigrmu)&((t2multimu-t1multimu)<0))|((t1multimu>t1multigrmu)&((t2multimu-t1multimu)>0))
replace dev_grmu_multi=0 if dev_grmu_multi~=1

gen dev_grmu_demo=1 if ((t1demomu<t1demogrmu)&((t2demomu-t1demomu)<0))|((t1demomu>t1demogrmu)&((t2demomu-t1demomu)>0))
replace dev_grmu_demo=0 if dev_grmu_demo~=1

gen dev_grmu_foraida=1 if ((t1foraidamu<t1foraidagrmu)&((t2foraidamu-t1foraidamu)<0))|((t1foraidamu>t1foraidagrmu)&((t2foraidamu-t1foraidamu)>0))
replace dev_grmu_foraida=0 if dev_grmu_foraida~=1

gen dev_grmu_foraidb=1 if ((t1foraidbmu<t1foraidbgrmu)&((t2foraidbmu-t1foraidbmu)<0))|((t1foraidbmu>t1foraidbgrmu)&((t2foraidbmu-t1foraidbmu)>0))
replace dev_grmu_foraidb=0 if dev_grmu_foraidb~=1

gen dev_grmu_globalta=1 if ((t1globaltamu<t1globaltagrmu)&((t2globaltamu-t1globaltamu)<0))|((t1globaltamu>t1globaltagrmu)&((t2globaltamu-t1globaltamu)>0))
replace dev_grmu_globalta=0 if dev_grmu_globalta~=1

gen dev_grmu_globaltb=1 if ((t1globaltbmu<t1globaltbgrmu)&((t2globaltbmu-t1globaltbmu)<0))|((t1globaltbmu>t1globaltbgrmu)&((t2globaltbmu-t1globaltbmu)>0))
replace dev_grmu_globaltb=0 if dev_grmu_globaltb~=1

gen dev_grmu_globaltc=1 if ((t1globaltcmu<t1globaltcgrmu)&((t2globaltcmu-t1globaltcmu)<0))|((t1globaltcmu>t1globaltcgrmu)&((t2globaltcmu-t1globaltcmu)>0))
replace dev_grmu_globaltc=0 if dev_grmu_globaltc~=1

gen dev_grmu_humrhta=1 if ((t1humrhtamu<t1humrhtagrmu)&((t2humrhtamu-t1humrhtamu)<0))|((t1humrhtamu>t1humrhtagrmu)&((t2humrhtamu-t1humrhtamu)>0))
replace dev_grmu_humrhta=0 if dev_grmu_humrhta~=1

gen dev_grmu_humrhtb=1 if ((t1humrhtbmu<t1humrhtbgrmu)&((t2humrhtbmu-t1humrhtbmu)<0))|((t1humrhtbmu>t1humrhtbgrmu)&((t2humrhtbmu-t1humrhtbmu)>0))
replace dev_grmu_humrhtb=0 if dev_grmu_humrhtb~=1

gen dev_grmu_humrhtc=1 if ((t1humrhtcmu<t1humrhtcgrmu)&((t2humrhtcmu-t1humrhtcmu)<0))|((t1humrhtcmu>t1humrhtcgrmu)&((t2humrhtcmu-t1humrhtcmu)>0))
replace dev_grmu_humrhtc=0 if dev_grmu_humrhtc~=1

gen dev_grmu_inter=1 if ((t1intermu<t1intergrmu)&((t2intermu-t1intermu)<0))|((t1intermu>t1intergrmu)&((t2intermu-t1intermu)>0))
replace dev_grmu_inter=0 if dev_grmu_inter~=1

gen dev_grmu_trade=1 if ((t1trademu<t1tradegrmu)&((t2trademu-t1trademu)<0))|((t1trademu>t1tradegrmu)&((t2trademu-t1trademu)>0))
replace dev_grmu_trade=0 if dev_grmu_trade~=1

egen vt1envir=var(t1envir), by(dpoll_no1)
egen vt2envir=var(t2envir), by(dpoll_no1)

egen vt1usseca=var(t1usseca) , by(dpoll_no1)
egen vt2usseca=var(t2usseca) , by(dpoll_no1)

egen vt1ussecb=var(t1ussecb), by(dpoll_no1)
egen vt2ussecb=var(t2ussecb), by(dpoll_no1)

egen vt1foraida=var(t1foraida), by(dpoll_no1)
egen vt2foraida=var(t2foraida), by(dpoll_no1)

egen vt1foraidb=var(t1foraidb), by(dpoll_no1)
egen vt2foraidb=var(t2foraidb), by(dpoll_no1)

egen vt1globalta=var(t1globalta), by(dpoll_no1)
egen vt2globalta=var(t2globalta), by(dpoll_no1)

egen vt1globaltb=var(t1globaltb), by(dpoll_no1)
egen vt2globaltb=var(t2globaltb), by(dpoll_no1)

egen vt1globaltc=var(t1globaltc), by(dpoll_no1)
egen vt2globaltc=var(t2globaltc), by(dpoll_no1)

egen vt1inter=var(t1inter), by(dpoll_no1)
egen vt2inter=var(t2inter), by(dpoll_no1)

egen vt1multi=var(t1multi), by(dpoll_no1)
egen vt2multi=var(t2multi), by(dpoll_no1)

egen vt1demo=var(t1demo), by(dpoll_no1)
egen vt2demo=var(t2demo), by(dpoll_no1)

egen vt1humrhta=var(t1humrhta), by(dpoll_no1)
egen vt2humrhta=var(t2humrhta), by(dpoll_no1)

egen vt1humrhtb=var(t1humrhtb), by(dpoll_no1)
egen vt2humrhtb=var(t2humrhtb), by(dpoll_no1)

egen vt1humrhtc=var(t1humrhtc), by(dpoll_no1)
egen vt2humrhtc=var(t2humrhtc), by(dpoll_no1)

egen vt1trade=var(t1trade), by(dpoll_no1)
egen vt2trade=var(t2trade), by(dpoll_no1)

gen venvir=1 if vt2envir>vt1envir
replace venvir=0 if venv~=1

gen vusseca=1 if vt2usseca>vt1usseca
replace vusseca=0 if vusseca~=0

gen vussecb=1 if vt2ussecb>vt1ussecb
replace vussecb=0 if vussecb~=0

gen vforaida=1 if vt2foraida>vt1foraida
replace vforaida=0 if vforaida~=1

gen vforaidb=1 if vt2foraidb>vt1foraidb
replace vforaidb=0 if vforaidb~=1

gen vglobalta=1 if vt2globalta>vt1globalta
replace vglobalta=0 if vglobalta~=1

gen vglobaltb=1 if vt2globaltb>vt1globaltb
replace vglobaltb=0 if vglobaltb~=1

gen vglobaltc=1 if vt2globaltc>vt1globaltc
replace vglobaltc=0 if vglobaltc~=1

gen vinter=1 if vt2inter>vt1inter
replace vinter=0 if vinter~=1

gen vmulti=1 if vt2multi>vt1multi
replace vmulti=0 if vmulti~=1

gen vdemo=1 if vt2demo>vt1demo
replace vdemo=0 if vdemo~=1

gen vhumrhta=1 if vt2humrhta>vt1humrhta
replace vhumrhta=0 if vhumrhta~=1

gen vhumrhtb=1 if vt2humrhtb>vt1humrhtb
replace vhumrhtb=0 if vhumrhtb~=1

gen vhumrhtc=1 if vt2humrhtc>vt1humrhtc
replace vhumrhtc=0 if vhumrhtc~=1

gen vtrade=1 if vt2trade>vt1trade
replace vtrade=0 if vtrade~=1


egen tag_grp=tag(dpoll_no1)
drop if tag_grp==0

gen agg_dev_mid=(dev_mid_env+dev_mid_usseca+dev_mid_multi+dev_mid_demo+dev_mid_foraida+dev_mid_globalta+dev_mid_humrhtb+dev_mid_inter+dev_mid_trade)/9 if dpoll_no~=.
gen agg_dev_grmu=(dev_grmu_env+dev_grmu_usseca+dev_grmu_multi+dev_grmu_demo+dev_grmu_foraida+dev_grmu_globalta+dev_grmu_humrhtb+dev_grmu_inter+dev_grmu_trade)/9 if dpoll_no~=.
gen agg_var=(venvir+vusseca+vforaida+vglobalta+vinter+vmulti+vdemo+vhumrhta+vtrade)/9 if dpoll_no~=.

egen total_mid=rsum(dev_mid_env dev_mid_usseca dev_mid_multi dev_mid_demo dev_mid_foraida dev_mid_globalta dev_mid_humrhtb dev_mid_inter dev_mid_trade) if dpoll_no~=.
egen test=sum(total_mid)


gen agg_dev_grmu=(dev_grmu_env+dev_grmu_usseca+dev_grmu_multi+dev_grmu_demo+dev_grmu_foraida+dev_grmu_globalta+dev_grmu_humrhtb+dev_grmu_inter+dev_grmu_trade)/9 if dpoll_no~=.
gen agg_var=(venvir+vusseca+vforaida+vglobalta+vinter+vmulti+vdemo+vhumrhta+vtrade)/9 if dpoll_no~=.
