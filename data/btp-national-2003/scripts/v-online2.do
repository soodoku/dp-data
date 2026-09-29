/*Environment*/

gen envir1p=qf2a

gen envir2p=1 if qf13==2
replace envir2p=2 if qf13==3
replace envir2p=3 if qf13==1

gen envir3p=1 if qf14==2
replace envir3p=2 if qf14==3
replace envir3p=3 if qf14==1

gen envir4p=qf15a

gen envir23p=(envir2p+envir3p)/2
mvdecode envir2p envir3p envir4p envir23p, mv(-1)

/*replace envir23p=prenvir2 if ~(prenvir2==.)&prenvir3==.
replace prenvir23=prenvir3 if ~(prenvir3==.)&prenvir2==.*/

/*replace prenvir23_r=prenvir2_r if prenvir3_r==.&~(prenvir2_r==.)
replace prenvir23_r=prenvir3_r if prenvir2_r==.&~(prenvir3_r==.)*/

/*US Economic Interests*/

gen usecon1p=qf2b
gen usecon2p=qf2d

/*US Security*/

gen ussec1p=qf2c
gen ussec2p=qf2e
gen ussec3p=qf2g
gen ussec4p=qf25b
gen ussec5p=qf37a
gen ussec6p=qf37b
gen ussec7p=qf37d
gen ussec8p=qf37e
gen ussec9p=qf37f
mvdecode ussec1p ussec2p ussec3p ussec4p ussec5p ussec6p ussec7p ussec8p ussec9p, mv(-1)

gen ussec10p=qf4
gen ussec11p=qf5
mvdecode ussec10p ussec11p, mv(-1)
mvdecode ussec10p ussec11p, mv(6)
omscore ussec10p
omscore ussec11p
drop ussec10p ussec11p
gen ussec10p=rr_ussec10p
gen ussec11p=rr_ussec11p
drop rr_ussec10p rr_ussec11p

/*gen c1=1 if ~(ussec1==.)
gen c2=1 if ~(ussec2==.)
gen c3=1 if ~(ussec3==.)
gen c4=1 if ~(ussec4==.)
gen c5=1 if ~(ussec5==.)
gen c6=1 if ~(ussec6==.)
gen c7=1 if ~(ussec7==.)
gen c8=1 if ~(ussec8==.)
gen c9=1 if ~(ussec9==.)
gen c10=1 if ~(ussec10==.)
gen c11=1 if ~(ussec11==.)
replace c1=0 if ~(c1==1)

replace c2=0 if ~(c2==1)
replace c3=0 if ~(c3==1)
replace c4=0 if ~(c4==1)
replace c5=0 if ~(c5==1)
replace c6=0 if ~(c6==1)
replace c7=0 if ~(c7==1)
replace c8=0 if ~(c8==1)
replace c9=0 if ~(c9==1)
replace c10=0 if ~(c10==1)
replace c11=0 if ~(c11==1)*/

/*gen testc5=ussec5 
replace testc5=0 if ussec5==.
gen testc6=ussec6 
replace testc6=0 if ussec6==.
gen testc7=ussec7 
replace testc7=0 if ussec7==.
gen testc8=ussec8 
replace testc8=0 if ussec8==.
gen testc9=ussec9 
replace testc9=0 if ussec9==.
gen testc10=ussec10 
replace testc10=0 if ussec10==.
gen testc11=ussec11 
replace testc11=0 if ussec11==.*/

gen ussec56789p=(ussec5p+ussec6p+ussec7p+ussec8p+ussec9p)/5

/*gen ussec56789p=(testc5+testc6+testc7+testc8+testc9)/(c5+c6+c7+c8+c9)
gen ussec1011=(testc10+testc11)/2
gen ussec789=(testc7+testc8+testc9)/3*/

/*US Influence*/

gen usinf1p=qf8
gen usinf2p=qf25a
mvdecode usinf1p usinf2p, mv(-1)
mvdecode usinf1p, mv(5)
omscore usinf1p
drop usinf1p
gen usinf1p=rr_usinf1p
drop rr_usinf1


/*Foreign Aid*/

gen foraid1p=1 if qf20==2
replace foraid1p=2 if qf20==3
replace foraid1p=3 if qf20==1

gen foraid2p=1 if qf21==2
replace foraid2p=2 if qf21==3
replace foraid2p=3 if qf21==1

gen foraid3p=1 if qf24==2
replace foraid3p=2 if qf24==3
replace foraid3p=3 if qf24==1

/*gen d1=1 if ~(foraid1==.)
gen d2=1 if ~(foraid2==.)
replace d1=0 if ~(d1==1)
replace d2=0 if ~(d2==1)*/

/*gen testd1=foraid1 
replace testd1=0 if foraid1==.
gen testd2=foraid2 
replace testd2=0 if foraid2==.*/

gen foraid12p=(foraid1p+foraid2p)/2

/*gen foraid12=(testd1+testd2)/(d1+d2)*/

/*Global Altruism*/

gen globalt1p=qf2f
gen globalt2p=qf2j
gen globalt3p=qf25d
gen globalt4p=qf25e
mvdecode globalt1p globalt2p globalt3p globalt4p, mv(-1)

gen globalt5p=qf7
mvdecode globalt5p, mv(5)
mvdecode globalt5p, mv(-1)
omscore globalt5p
drop globalt5p
gen globalt5p=rr_globalt5p
drop rr_globalt5

gen globalt6p=qf37b
mvdecode globalt6p, mv(-1)

/*gen e3=1 if ~(globalt3==.)
gen e4=1 if ~(globalt4==.)
replace e3=0 if ~(e3==1)
replace e4=0 if ~(e4==1)

gen teste3=globalt3 
replace teste3=0 if globalt3==.
gen teste4=globalt4 
replace teste4=0 if globalt4==.*/

gen globalt34p=(globalt3p+globalt4p)/2

/*gen globalt34=(teste3+teste4)/(e3+e4)*/

/*Human Rights*/

gen humrht1p=qf2h
gen humrht2p=qf2i
mvdecode humrht1p humrht2p, mv(-1)

/*Internationalism*/

gen inter1p=qf3
mvdecode inter1p, mv(-1)
mvdecode inter1p, mv(6)

gen inter2p=ussec10p
gen inter3p=ussec11p
gen inter4p=foraid1p
gen inter5p=foraid2p

gen inter6p=qf38
gen inter7p=qf39
mvdecode inter6p inter7p, mv(-1)
mvdecode inter6p inter7p, mv(5)
mvdecode inter6p inter7p, mv(6)

/*gen h2=1 if ~(inter2==.)
gen h3=1 if ~(inter3==.)
gen h4=1 if ~(inter4==.)
gen h5=1 if ~(inter5==.)
replace h2=0 if ~(h2==1)
replace h3=0 if ~(h3==1)
replace h4=0 if ~(h4==1)
replace h5=0 if ~(h5==1)

gen testh2=inter2 
replace testh2=0 if testh2==.
gen testh3=inter3 
replace testh3=0 if testh3==.
gen testh4=inter4 
replace testh4=0 if testh4==.
gen testh5=inter5 
replace testh5=0 if testh5==.*/

gen inter23p=(inter2p+inter3p)/2

/*gen inter23=(testh2+testh3)/(h2+h3)*/

/*Multinationalism*/

gen multi1p=qf6
mvdecode multi1p, mv(-1)
mvdecode multi1p, mv(6)

gen multi2p=qf10
mvdecode multi2p, mv(-1)
mvdecode multi2p, mv(5)

omscore multi1p
drop multi1p
gen multi1p=rr_multi1p
drop rr_multi1p

omscore multi2p
drop multi2p
gen multi2p=rr_multi2p
drop rr_multi2p

gen multi3p=qf16
mvdecode multi3p, mv(-1)
mvdecode multi3p, mv(6)
omscore multi3p
drop multi3p
gen multi3p=rr_multi3p
drop rr_multi3p

gen multi4p=qf27
mvdecode multi4p, mv(-1)
mvdecode multi4p, mv(6)
omscore multi4p
drop multi4p
gen multi4p=rr_multi4p
drop rr_multi4p

gen multi5p=qf30
mvdecode multi5p, mv(-1)
mvdecode multi5p, mv(6)
omscore multi5p
drop multi5p
gen multi5p=rr_multi5p
drop rr_multi5p

gen multi6p=qf28
mvdecode multi6p, mv(-1)
mvdecode multi6p, mv(6)
omscore multi6p
drop multi6p
gen multi6p=rr_multi6p
drop rr_multi6p

gen multi7p=qf31
mvdecode multi7p, mv(-1)
mvdecode multi7p, mv(6)
omscore multi7p
drop multi7p
gen multi7p=rr_multi7p
drop rr_multi7p

gen multi8p=qf29
mvdecode multi8p, mv(-1)
mvdecode multi8p, mv(6)
omscore multi8p
drop multi8p
gen multi8p=rr_multi8p
drop rr_multi8p

/*gen multi9=mact6_s
replace multi9=. if multi9==6
omscore multi9
drop multi9
gen multi9=rr_multi9
drop rr_multi9*/

gen multi10p=qf37e
mvdecode multi10p, mv(-1)

gen multi11p=qf38
mvdecode multi11p, mv(-1)
mvdecode multi11p, mv(5)
mvdecode multi11p, mv(6)

gen multi12p=qf39
mvdecode multi12p, mv(-1)
mvdecode multi12p, mv(5)
mvdecode multi12p, mv(6)

gen multi13p=1 if qf32a==3
replace multi13p=2 if qf32a==1
replace multi13p=3 if qf32a==2

gen multi4_5p=multi4p-multi5p
gen multi6_7p=multi6p-multi7p
/*gen multi8_9p=multi8p-multi9p*/

/*Democracy*/

gen demo1p=qf9
mvdecode demo1p, mv(-1)
mvdecode demo1p, mv(5)
omscore demo1p
drop demo1p
gen demo1p=rr_demo1p
drop rr_demo1p

gen demo2p=1 if qf22==2
replace demo2p=2 if qf22==3
replace demo2p=3 if qf22==1

gen demo3p=qf23a
gen demo4p=qf23b
gen demo5p=qf23c
gen demo6p=qf23d
gen demo7p=qf23e
gen demo8p=qf23f
mvdecode demo3p demo4p demo5p demo6p demo7p demo8p, mv(-1)

gen demo9p=qf25c
mvdecode demo9p, mv(-1)

gen demo10p=ussec5p

gen demo345678p=(demo3p+demo4p+demo5p+demo6p+demo7p+demo8p)/6

/*Trade*/

gen trade1p=multi13p
gen trade2p=qf33
mvdecode trade2p, mv(-1)
mvdecode trade2p, mv(4)

/*Linear Projection to [0,1]*/

gen envir1p_r=envir1p/10
gen envir2p_r=(envir2p-1)/2
gen envir3p_r=(envir3p-1)/2
gen envir4p_r=envir4p/10

gen usecon1p_r=usecon1p/10
gen usecon2p_r=usecon2p/10

gen ussec1p_r=ussec1p/10
gen ussec2p_r=ussec2p/10
gen ussec3p_r=ussec3p/10
gen ussec4p_r=ussec4p/10
gen ussec5p_r=ussec5p/10
gen ussec6p_r=ussec6p/10
gen ussec7p_r=ussec7p/10
gen ussec8p_r=ussec8p/10
gen ussec9p_r=ussec9p/10
gen ussec10p_r=(ussec10p-1)/4
gen ussec11p_r=(ussec11p-1)/4

gen usinf1p_r=(usinf1p-1)/3
gen usinf2p_r=usinf2p/10

gen foraid1p_r=(foraid1p-1)/2
gen foraid2p_r=(foraid2p-1)/2
gen foraid3p_r=(foraid3p-1)/2

gen globalt1p_r=globalt1p/10
gen globalt2p_r=globalt2p/10
gen globalt3p_r=globalt3p/10
gen globalt4p_r=globalt4p/10
gen globalt5p_r=(globalt5p-1)/3
gen globalt6p_r=globalt6p/10

gen humrht1p_r=humrht1p/10
gen humrht2p_r=humrht2p/10

gen inter1p_r=(inter1p-1)/4
gen inter2p_r=(inter2p-1)/4
gen inter3p_r=(inter3p-1)/4
gen inter4p_r=(inter4p-1)/2
gen inter5p_r=(inter5p-1)/2
gen inter6p_r=(inter6p-1)/3
gen inter7p_r=(inter7p-1)/3

gen multi1p_r=(multi1p-1)/4
gen multi2p_r=(multi2p-1)/3
gen multi3p_r=(multi3p-1)/4
gen multi4p_r=(multi4p-1)/4
gen multi5p_r=(multi5p-1)/4
gen multi6p_r=(multi6p-1)/4
gen multi7p_r=(multi7p-1)/4
gen multi8p_r=(multi8p-1)/4
gen multi9p_r=(multi9p-1)/4
gen multi10p_r=(multi10p)/10
gen multi11p_r=(multi11p-1)/3
gen multi12p_r=(multi12p-1)/3
gen multi13p_r=(multi13p-1)/2

gen demo1p_r=(demo1p-1)/3
gen demo2p_r=(demo2p-1)/2
gen demo3p_r=demo3p/10
gen demo4p_r=demo4p/10
gen demo5p_r=demo5p/10
gen demo6p_r=demo6p/10
gen demo7p_r=demo7p/10
gen demo8p_r=demo8p/10
gen demo9p_r=demo9p/10
gen demo10p_r=demo10p/10

gen trade1p_r=(trade1p-1)/2
gen trade2p_r=(trade2p-1)/2

/*creating indicator variables*/

gen a1=1 if ~(prenvir1==.)
gen a2=1 if ~(prenvir2==.)
gen a3=1 if ~(prenvir3==.)
gen a4=1 if ~(prenvir4==.)
replace a1=0 if ~(a1==1)
replace a2=0 if ~(a2==1)
replace a3=0 if ~(a3==1)
replace a4=0 if ~(a4==1)
gen a_n=a1+a2+a3+a4

gen b1=1 if ~(usecon1==.)
gen b2=1 if ~(usecon2==.)
replace b1=0 if ~(b1==1)
replace b2=0 if ~(b2==1)
gen b_n=b1+b2

gen c1=1 if ~(ussec1==.)
gen c2=1 if ~(ussec2==.)
gen c3=1 if ~(ussec3==.)
gen c4=1 if ~(ussec4==.)
gen c5=1 if ~(ussec5==.)
gen c6=1 if ~(ussec6==.)
gen c7=1 if ~(ussec7==.)
gen c8=1 if ~(ussec8==.)
gen c9=1 if ~(ussec9==.)
gen c10=1 if ~(ussec10==.)
gen c11=1 if ~(ussec11==.)
replace c1=0 if ~(c1==1)
replace c2=0 if ~(c2==1)
replace c3=0 if ~(c3==1)
replace c4=0 if ~(c4==1)
replace c5=0 if ~(c5==1)
replace c6=0 if ~(c6==1)
replace c7=0 if ~(c7==1)
replace c8=0 if ~(c8==1)
replace c9=0 if ~(c9==1)
replace c10=0 if ~(c10==1)
replace c11=0 if ~(c11==1)
gen c_n=c1+c2+c3+c4+c5+c6+c7+c8+c9+c10+c11




gen d1=1 if ~(usinf1==.)
gen d2=1 if ~(usinf2==.)
replace d1=0 if ~(d1==1)
replace d2=0 if ~(d2==1)
gen d_n=d1+d2

gen e1=1 if ~(foraid1==.)
gen e2=1 if ~(foraid2==.)
gen e3=1 if ~(foraid3==.)
replace e1=0 if ~(e1==1)
replace e2=0 if ~(e2==1)
replace e3=0 if ~(e3==1)
gen e_n=e1+e2+e3


gen f1=1 if ~(globalt1==.)
gen f2=1 if ~(globalt2==.)
gen f3=1 if ~(globalt3==.)
gen f4=1 if ~(globalt4==.)
gen f5=1 if ~(globalt5==.)
gen f6=1 if ~(globalt6==.)
replace f1=0 if ~(f1==1)
replace f2=0 if ~(f2==1)
replace f3=0 if ~(f3==1)
replace f4=0 if ~(f4==1)
replace f5=0 if ~(f5==1)
replace f6=0 if ~(f6==1)
gen f_n=f1+f2+f3+f4+f5+f6



gen g1=1 if ~(humrht1==.)
gen g2=1 if ~(humrht2==.)
replace g1=0 if ~(g1==1)
replace g2=0 if ~(g2==1)
gen g_n=g1+g2


gen h1=1 if ~(inter1==.)
gen h2=1 if ~(inter2==.)
gen h3=1 if ~(inter3==.)
gen h4=1 if ~(inter4==.)
gen h5=1 if ~(inter5==.)
gen h6=1 if ~(inter6==.)
gen h7=1 if ~(inter7==.)
replace h1=0 if ~(h1==1)
replace h2=0 if ~(h2==1)
replace h3=0 if ~(h3==1)
replace h4=0 if ~(h4==1)
replace h5=0 if ~(h5==1)
replace h6=0 if ~(h6==1)
replace h7=0 if ~(h7==1)
gen h_n=h1+h2+h3+h4+h5+h6+h7


gen i1=1 if ~(multi1==.)
gen i2=1 if ~(multi2==.)
gen i3=1 if ~(multi3==.)
gen i4=1 if ~(multi4==.)
gen i5=1 if ~(multi5==.)
gen i6=1 if ~(multi6==.)
gen i7=1 if ~(multi7==.)
gen i8=1 if ~(multi8==.)
gen i9=1 if ~(multi9==.)
gen i10=1 if ~(multi10==.)
gen i11=1 if ~(multi11==.)
gen i12=1 if ~(multi12==.)
gen i13=1 if ~(multi13==.)
replace i1=0 if ~(i1==1)
replace i2=0 if ~(i2==1)
replace i3=0 if ~(i3==1)
replace i4=0 if ~(i4==1)
replace i5=0 if ~(i5==1)
replace i6=0 if ~(i6==1)
replace i7=0 if ~(i7==1)
replace i8=0 if ~(i8==1)
replace i9=0 if ~(i9==1)
replace i10=0 if ~(i10==1)
replace i11=0 if ~(i11==1)
replace i12=0 if ~(i12==1)
replace i13=0 if ~(i13==1)
gen i_n=i1+i2+i3+i4+i5+i6+i7+i8+i9+i10+i11+i12+i13

gen j1=1 if ~(demo1==.)
gen j2=1 if ~(demo2==.)
gen j3=1 if ~(demo3==.)
gen j4=1 if ~(demo4==.)
gen j5=1 if ~(demo5==.)
gen j6=1 if ~(demo6==.)
gen j7=1 if ~(demo7==.)
gen j8=1 if ~(demo8==.)
gen j9=1 if ~(demo9==.)
gen j10=1 if ~(demo10==.)
gen j11=1 if ~(demo11==.)
replace j1=0 if ~(j1==1)
replace j2=0 if ~(j2==1)
replace j3=0 if ~(j3==1)
replace j4=0 if ~(j4==1)
replace j5=0 if ~(j5==1)
replace j6=0 if ~(j6==1)
replace j7=0 if ~(j7==1)
replace j8=0 if ~(j8==1)
replace j9=0 if ~(j9==1)
replace j10=0 if ~(j10==1)
replace j11=0 if ~(j11==1)
gen j_n=j1+j2+j3+j4+j5+j6+j7+j8+j9+j10+j11

gen k1=1 if ~(trade1==.)
gen k2=1 if ~(trade2==.)
replace k1=0 if ~(k1==1)
replace k2=0 if ~(k2==1)
gen k_n=k1+k2

/*Indices*/

/*Index1:  Environment*/
gen envi_index=(prenvir1_r+prenvir2_r+prenvir3_r+prenvir4_r)/a_n



gen testc5=ussec5_r 
replace testc5=0 if ussec5_r==.
gen testc6=ussec6_r 
replace testc6=0 if ussec6_r==.
gen testc7=ussec7_r 
replace testc7=0 if ussec7_r==.
gen testc8=ussec8_r 
replace testc8=0 if ussec8_r==.
gen testc9=ussec9_r 
replace testc9=0 if ussec9_r==.

gen tetsc56789=(testc5+testc6+testc7+testc8+testc9)/(c5+c6+c7+c8+c9)

gen ussec1011_r=(ussec10_r+ussec11_r)/2
replace ussec1011_r=ussec10_r if ussec11_r==.&~(ussec10_r==.)
replace ussec1011_r=ussec11_r if ussec10_r==.&~(ussec11_r==.)

gen tetsc789=(testc7+testc8+testc9)/(c7+c8+c9)

replace foraid12_r=foraid1_r if foraid2_r==.&~(foraid1_r==.)
replace foraid12_r=foraid2_r if foraid1_r==.&~(foraid2_r==.)

replace globalt34_r=globalt3_r if globalt4_r==.&~(globalt3_r==.)
replace globalt34_r=globalt4_r if globalt3_r==.&~(globalt4_r==.)

gen testh2=inter2_r 
replace testh2=0 if inter2_r==.
gen testh3=inter3_r 
replace testh3=0 if inter3_r==.
gen testh4=inter4_r 
replace testh4=0 if inter4_r==.
gen testh5=inter5_r 
replace testh5=0 if inter5_r==.

gen test=(testh2+testh3+testh4+testh5)/(h2+h3+h4+h5)
gen test1=(testh2+testh3)/(h2+h3)


gen test=(testh4+testh5)/(h4+h5)

gen inter23_r=(inter2_r+inter3_r)/2
replace inter23_r=inter3_r if inter2_r==.&~(inter3_r==.)
replace inter23_r=inter2_r if inter3_r==.&~(inter2_r==.)

gen int2345=(inter2+inter3+inter4+inter5)/4
gen int23=(inter2+inter3)/4

omscore demo1
drop demo1
gen demo1=rr_demo1
drop demo1_r
gen demo1_r=(demo1-1)/3

gen inter6a=inter6
replace inter6a=2 if inter6==3
replace inter6a=3 if inter6==2

gen inter7a=inter7
replace inter7a=2 if inter7==3
replace inter7a=3 if inter7==2

gen inter6a_r=(inter6a-1)/3
gen inter7a_r=(inter7a-1)/3

gen multi4_5_r=(multi4_5+4)/8
gen multi6_7_r=(multi6_7+4)/8
gen multi8_9_r=(multi8_9+4)/8

/*INDEX*/

/*environment*/
gen a23=1 if a2==1|a3==1
replace a23=0 if a23==.

gen test_a_1=prenvir1_r
replace test_a_1=0 if prenvir1_r==.
gen test_a_23=prenvir23_r
replace test_a_23=0 if prenvir23_r==.
gen test_a_4=prenvir4_r
replace test_a_4=0 if prenvir4_r==.
gen index1=(test_a_1+test_a_23+test_a_4)/(a1+a23+a4)
replace index1=. if prenvir1_r==.&prenvir23_r==.&prenvir4_r==.

gen test_a_2=prenvir2_r
replace test_a_2=0 if prenvir2_r==.
gen test_a_3=prenvir3_r
replace test_a_3=0 if prenvir3_r==.

gen index2=(test_a_1+test_a_2+test_a_3+test_a_4)/(a1+a2+a3+a4)
replace index2=. if prenvir1_r==.&prenvir2_r==.&prenvir3_r==.&prenvir4_r==.

/*us economic interests*/
gen test_b_1=usecon1_r
replace test_b_1=0 if usecon1_r==.
gen test_b_2=usecon2_r
replace test_b_2=0 if usecon2_r==.

gen index3=(test_b_1+test_b_2)/(b1+a2)

/*us security*/
gen test_c_1=ussec1_r
replace test_c_1=0 if ussec1_r==.
gen test_c_2=ussec2_r
replace test_c_2=0 if ussec2_r==.
gen test_c_3=ussec3_r
replace test_c_3=0 if ussec3_r==.
gen test_c_4=ussec4_r
replace test_c_4=0 if ussec4_r==.
gen test_c_56789=ussec56789_r
replace test_c_56789=0 if ussec56789_r==.
gen test_c_1011=ussec1011_r
replace test_c_1011=0 if ussec1011_r==.

gen c56789=1 if ~(ussec56789_r==.)
replace c56789=0 if (ussec56789_r==.)

gen c1011=1 if ~(ussec1011_r==.)
replace c1011=0 if (ussec1011_r==.)

gen index4=(test_c_1+test_c_2+test_c_3+test_c_4+test_c_56789+test_c_1011)/(c1+c2+c3+c4+c56789+c1011)

gen test_c_789=ussec789_r
replace test_c_789=0 if (ussec789_r==.)
gen c789=1 if ~(ussec789_r==.)
replace c789=0 if (ussec789_r==.)

gen index5=(test_c_1+test_c_2+test_c_3+test_c_4+test_c_789+test_c_1011)/(c1+c2+c3+c4+c789+c1011)

gen test_c_5=ussec5_r
replace test_c_5=0 if ussec5_r==.
gen test_c_6=ussec6_r
replace test_c_6=0 if ussec6_r==.
gen test_c_7=ussec7_r
replace test_c_7=0 if ussec7_r==.
gen test_c_8=ussec8_r
replace test_c_8=0 if ussec8_r==.
gen test_c_9=ussec9_r
replace test_c_9=0 if ussec9_r==.
gen test_c_10=ussec10_r
replace test_c_10=0 if ussec10_r==.
gen test_c_11=ussec11_r
replace test_c_11=0 if ussec11_r==.

gen index6=(test_c_1+test_c_2+test_c_3+test_c_4+test_c_5+test_c_6+test_c_7+test_c_8+test_c_9+test_c_10+test_c_11)/(c1+c2+c3+c4+c5+c6+c7+c8+c9+c10+c11)

/*us influence*/
gen test_d_1=usinf1_r
replace test_d_1=0 if usinf1_r==.
gen test_d_2=usinf2_r
replace test_d_2=0 if usinf2_r==.

gen index7=(test_d_1+test_d_2)/(d1+d2)

/*foreign aid*/
gen test_e_1=foraid1_r
replace test_e_1=0 if foraid1_r==.
gen test_e_2=foraid2_r
replace test_e_2=0 if foraid2_r==.
gen test_e_3=foraid3_r
replace test_e_3=0 if foraid3_r==.
gen test_e_12=foraid12_r
replace test_e_12=0 if foraid12_r==.

gen e12=1 if ~(foraid12_r==.)
replace e12=0 if foraid12_r==.

gen index8=(test_e_12+test_e_3)/(e1+e12+e3)

gen index9=(test_e_1+test_e_2+test_e_3)/(e1+e2+e3)

/*global altruism*/
gen test_f_1=globalt1_r
replace test_f_1=0 if globalt1_r==.
gen test_f_2=globalt2_r
replace test_f_2=0 if globalt2_r==.
gen test_f_3=globalt3_r
replace test_f_3=0 if globalt3_r==.
gen test_f_4=globalt4_r
replace test_f_4=0 if globalt4_r==.
gen test_f_5=globalt5_r
replace test_f_5=0 if globalt5_r==.
gen test_f_6=globalt6_r
replace test_f_6=0 if globalt6_r==.

gen test_f_34=globalt34_r
replace test_f_34=0 if globalt34_r==.

gen f34=1 if ~(globalt34_r==.)
replace f34=0 if globalt34==.

gen index10=(test_f_1+test_f_2+test_f_34+test_f_5+test_f_6)/(f1+f2+f34+f5+f6)
gen index11=(test_f_1+test_f_2+test_f_3+test_f_4+test_f_5+test_f_6)/(f1+f2+f3+f4+f5+f6)

/*human rights*/
gen test_g_1=humrht1_r
replace test_g_1=0 if humrht1_r==.
gen test_g_2=humrht2_r
replace test_g_2=0 if humrht2_r==.

gen index12=(test_g_1+test_g_2)/(g1+g2)

/*internationalism*/
gen test_h_1=inter1_r
replace test_h_1=0 if inter1_r==.
gen test_h_2=inter2_r
replace test_h_2=0 if inter2_r==.
gen test_h_3=inter3_r
replace test_h_3=0 if inter3_r==.
gen test_h_4=inter4_r
replace test_h_4=0 if inter4_r==.
gen test_h_5=inter5_r
replace test_h_5=0 if inter5_r==.
gen test_h_6=inter6_r
replace test_h_6=0 if inter6_r==.
gen test_h_7=inter7_r
replace test_h_7=0 if inter7_r==.

gen test_h_2345=inter2345_r
replace test_h_2345=0 if inter2345_r==.

gen test_h_23=inter23_r
replace test_h_23=0 if inter23_r==.

gen h2345=1 if ~(inter2345_r==.)
replace h2345=0 if inter2345_r==.

gen h23=1 if ~(inter23_r==.)
replace h23=0 if inter23_r==.

gen index13=(test_h_1+test_h_2345+test_h_6+test_h_7)/(h1+h2345+h6+h7)
gen index14=(test_h_1+test_h_23+test_h_6+test_h_7)/(h1+h23+h6+h7)
gen index15=(test_h_1+test_h_2+test_h_3+test_h_4+test_h_5+test_h_6+test_h_7)/(h1+h2+h3+h4+h5+h6+h7)
gen index16=(test_h_1+test_h_2+test_h_3+test_h_6+test_h_7)/(h1+h2+h3+h6+h7)

/*multinationalism*/
gen test_i_1=multi1_r
replace test_i_1=0 if multi1_r==.
gen test_i_2=multi2_r
replace test_i_2=0 if multi2_r==.
gen test_i_3=multi3_r
replace test_i_3=0 if multi3_r==.
gen test_i_4_5=multi4_5_r
replace test_i_4_5=0 if multi4_5_r==.
gen test_i_6_7=multi6_7_r
replace test_i_6_7=0 if multi6_7_r==.
gen test_i_8_9=multi8_9_r
replace test_i_8_9=0 if multi8_9_r==.
gen test_i_10=multi10_r
replace test_i_10=0 if multi10_r==.
gen test_i_11=multi11_r
replace test_i_11=0 if multi11_r==.
gen test_i_12=multi12_r
replace test_i_12=0 if multi12_r==.
gen test_i_13=multi13_r
replace test_i_13=0 if multi13_r==.

gen i4_5=1 if ~(multi4_5_r==.)
replace i4_5=0 if multi4_5_r==.
gen i6_7=1 if ~(multi6_7_r==.)
replace i6_7=0 if multi6_7_r==.
gen i8_9=1 if ~(multi8_9_r==.)
replace i8_9=0 if multi8_9_r==.

gen index17=(test_i_1+test_i_2+test_i_3+test_i_4_5+test_i_6_7+test_i_8_9+test_i_10+test_i_11+test_i_12+test_i_13)/(i1+i2+i3+i4_5+i6_7+i8_9+i10+i11+i12+i13)

/*democracy*/
gen test_j_1=demo1_r
replace test_j_1=0 if demo1_r==.
gen test_j_2=demo2_r
replace test_j_2=0 if demo2_r==.
gen test_j_3=demo3_r
replace test_j_3=0 if demo3_r==.
gen test_j_4=demo4_r
replace test_j_4=0 if demo4_r==.
gen test_j_5=demo5_r
replace test_j_5=0 if demo5_r==.
gen test_j_6=demo6_r
replace test_j_6=0 if demo6_r==.
gen test_j_7=demo7_r
replace test_j_7=0 if demo7_r==.
gen test_j_8=demo8_r
replace test_j_8=0 if demo8_r==.
gen test_j_9=demo9_r
replace test_j_9=0 if demo9_r==.
gen test_j_10=demo10_r
replace test_j_10=0 if demo10_r==.
gen test_j_11=demo11_r
replace test_j_11=0 if demo11_r==.

gen test_j_3456789=demo3456789_r
replace test_j_3456789=0 if demo3456789_r==.

gen j3456789=1 if ~(demo3456789_r==.)
replace j3456789=0 if demo3456789_r==.

gen index18=(test_j_1+test_j_2+test_j_3456789+test_j_10+test_j_11)/(j1+j2+j3456789+j10+j11)
gen index19=(test_j_1+test_j_2+test_j_3+test_j_4+test_j_5+test_j_6+test_j_7+test_j_8+test_j_9+test_j_10+test_j_11)/(j1+j2+j3+j4+5+j6+j7+j8+j9+j10+j11)

/*free trade*/
gen test_k_1=trade1_r
replace test_k_1=0 if trade1_r==.
gen test_k_2=trade2_r
replace test_k_2=0 if trade2_r==.

gen index20=(test_k_1+test_k_2)/(k1+k2)


gen testindex=(test_j_1+test_j_2+test_j_3+test_j_4+test_j_5+test_j_6+test_j_7+test_j_8+test_j_9+test_j_10+test_j_11)/j_n











































