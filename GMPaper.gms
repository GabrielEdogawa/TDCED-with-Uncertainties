$title   Uncertainty-based T-D Coordinated Economic Dispatch using Linearized AC

$ontext

This is the code for a 2018 General Meeting Paper to be submitted by Gabriel Yin:

"Uncertainty-based Transmission and Distribution Coordinated Economic Dispatch
and Decomposable Solution", 2018 GM Conference.

All rights reserved since 2018 for Gabriel Yin at Southern Methodist University.

Topology data is retreived from the following paper:
A. Kargarian et al. "System of System Based Security-Constrained Unit Commitment
Incorporating Active Distribution Grids", IEEE Trans. on Power Systems, 2014.

Scenario data is retrieved from NREL, whose websites are
https://www.nrel.gov/wind/data-tools.html
https://www.nrel.gov/analysis/data-tools.html

$offtext

* Optimization options
option LP = CPLEX;
option threads = 8;
option reslim = 10e10;
option limrow = 10e3;

********************************************************************************
***************************** Initialization ***********************************
********************************************************************************

* Transmission Sets
Set
         tg      transmission generator  /tg1*tg3/
         tn      transmission node       /tn1*tn6/
         tl      transmission line       /tl1*tl7/
         td      transmission demand     /td1/;

* Distribution Sets
Set
         adg     distribution generator  /adg1/
         adr     distribution renewable  /adr1/
         add     distribution load       /add1*add5/
         adn     distribution node       /adn1*adn9/
         adl     distribution line       /adl1*adl8/;

Set
         bdg     distribution generator  /bdg1/
         bdr     distribution renewable  /bdr1/
         bdd     distribution load       /bdd1*bdd4/
         bdn     distribution node       /bdn1*bdn7/
         bdl     distribution line       /bdl1*bdl6/;

* Miscellaneous Sets
Set
         as      scenario index          /as1*as100/
         bs      scenario index          /bs1*bs100/
         iter    iteration index         /1*150/
         h       hour index              /1*24/
         cutsetA(iter)
         cutsetB(iter);
cutsetA(iter) = no;
cutsetB(iter) = no;

* Topology Mapping
Set
* Transmission Mapping
         mapTSL(tl, tn)  transmission line-sending-node mapping
                 /tl1.tn1, tl2.tn1, tl3.tn2, tl4.tn2, tl5.tn3, tl6.tn4, tl7.tn5/
         mapTRL(tl, tn)  transmission line-receiving-node mapping
                 /tl1.tn2, tl2.tn4, tl3.tn3, tl4.tn4, tl5.tn6, tl6.tn5, tl7.tn6/
         mapTG(tg, tn)   transmission generator-node mapping
                 /tg1.tn1, tg2.tn2, tg3.tn6/
         mapTD(td, tn)   transmission demand-node mapping
                 /td1.tn5/
* Distribution A Mapping
         mapADSL(adl, adn)       Distribution A line-sending-node mapping
                 /adl1.adn1, adl2.adn2, adl3.adn2, adl4.adn7, adl5.adn3, adl6.adn8, adl7.adn4, adl8.adn4/
         mapADRL(adl, adn)       Distribution A line-receiving-node mapping
                 /adl1.adn2, adl2.adn7, adl3.adn3, adl4.adn8, adl5.adn4, adl6.adn9, adl7.adn6, adl8.adn5/
         mapADG(adg, adn)        Distribution A generator-node mapping
                 /adg1.adn8/
         mapADR(adr, adn)        Distribution A renewable-node mapping
                 /adr1.adn5/
         mapADD(add, adn)        Distribution A demand-node mapping
                 /add1.adn2, add2.adn3, add3.adn6, add4.adn7, add5.adn9/
* Distribution B Mapping
         mapBDSL(bdl, bdn)       Distribution B line-sending-node mapping
                 /bdl1.bdn1, bdl2.bdn2, bdl3.bdn3, bdl4.bdn4, bdl5.bdn4, bdl6.bdn6/
         mapBDRL(bdl, bdn)       Distribution B line-receiving-node mapping
                 /bdl1.bdn2, bdl2.bdn3, bdl3.bdn4, bdl4.bdn6, bdl5.bdn5, bdl6.bdn7/
         mapBDG(bdg, bdn)        Distribution B generator-node mapping
                 /bdg1.bdn2/
         mapBDR(bdr, bdn)        Distribution B renewable-node mapping
                 /bdr1.bdn7/
         mapBDD(bdd, bdn)        Distribution B demand-node mapping
                 /bdd1.bdn3, bdd2.bdn5, bdd3.bdn6, bdd4.bdn7/
         tmp     /1*24/;

* Scenario Data for Renewable Generators
* One thing is noteworthy: The data processing and parameter wrapping in GAMS
* is JUST A PIECE OF SHIIIIIT. Try to use external softwares like Python/Pandas or
* even MATLAB to wrap up your data and export them to GAMS.

$set inputdir "C:\Users\GabrielYin\Desktop\GAMS_Codes\GM_Paper\Data"

Table    TotalLoad(as, tmp)
$include "%inputdir%\total_load.txt";
Table    TotalLoad2(bs, tmp)
$include "%inputdir%\total_load2.txt";

Display TotalLoad, TotalLoad2;

Parameter        TotalLoads1(as, h), TotalLoads2(bs, h);

loop(h,
         loop(tmp,
                 if(ord(h) = ord(tmp),
                         loop(as,
                                 TotalLoads1(as, h) = TotalLoad(as, tmp);
                         );
                         loop(bs,
                                 TotalLoads2(bs, h) = TotalLoad2(bs, tmp);
                         );
                 );
                 continue;
         );
);

Display TotalLoads1, TotalLoads2;

Table    ARenew(as, tmp)
$include "%inputdir%\gen1.txt";

Display ARenew;

Parameter        ARG(as, h);

loop(h,
         loop(tmp,
                 if(ord(h) = ord(tmp),
                         loop(as,
                                 ARG(as, h) = ARenew(as, tmp);
                         );
                 );
                 continue;
         );
);

Display ARG;

Table    BRenew(bs, tmp)
$include "%inputdir%\gen2.txt";

Display BRenew;

Parameter        BRG(bs, h);

loop(h,
         loop(tmp,
                 if(ord(h) = ord(tmp),
                         loop(bs,
                                 BRG(bs, h) = BRenew(bs, tmp);
                         );
                 );
                 continue;
         );
);

Display BRG;

Table    Probx(as, tmp)
$include "%inputdir%\ProbA.txt";
Table    Proby(bs, tmp)
$include "%inputdir%\ProbB.txt";

Parameter        ProbA(as), ProbB(bs);
ProbA(as) = Probx(as, '1');
ProbB(bs) = Proby(bs, '1');
Display Probx, Proby, ProbA, ProbB;

* System Configuration

* Transmission system
Table    TLDATA(tl, *)   Transmission Line Data
         X       PLmax
tl1      0.170   200
tl2      0.258   200
tl3      0.037   190
tl4      0.197   200
tl5      0.018   180
tl6      0.037   190
tl7      0.140   180     ;

Table    TGDATA(tg, *)   Transmission Generator Data
         base    p1      p2      p3      p4      p5      Pmin    Pmax    RU      RD
tg1      428     10.48   12.64   14.80   16.96   19.12   40      36      60      60
tg2      511     22.66   25.18   27.7    30.22   32.74   10      18      40      40
tg3      110     8.25    8.75    9.25    9.75    10.25   0       5       40      40;

Table    TDDATA(td, h)   Transmission Demand Data
         1       2       3       4       5       6       7       8       9       10      11      12      13      14      15      16      17      18      19      20      21      22      23      24
td1      70      67.6    66      62      62      66      69.2    69.6    74      80.8    91.2    94.4    96.8    97.6    99.6    102.4   102.4   98.8    98.4    94.8    94.8    93.2    84      84      ;

* Distribution system A
Table    ADLDATA(adl, *)   Distribution Line Data
         X       R       PLmax   QLmax
adl1     0.19    0.13    60      29.058
adl2     0.21    0.12    30      14.529
adl3     0.21    0.12    30      14.529
adl4     0.19    0.13    20      9.686
adl5     0.20    0.11    40      19.372
adl6     0.19    0.13    20      9.686
adl7     0.18    0.10    30      14.529
adl8     0.18    0.10    20      9.686   ;

Table    ADGDATA(adg, *)   Distribution Generator Data
         base    p1      p2      p3      p4      p5      p6      Pmin    Pmax    RU      RD
adg1     65      3.09    3.27    3.45    3.63    3.81    3.99    0       3       8       8      ;

Parameter    ADDDATA(as, add, h);
ADDDATA(as, 'add1', h) = 0.030 * TotalLoads1(as, h);
ADDDATA(as, 'add2', h) = 0.048 * TotalLoads1(as, h);
ADDDATA(as, 'add3', h) = 0.038 * TotalLoads1(as, h);
ADDDATA(as, 'add4', h) = 0.050 * TotalLoads1(as, h);
ADDDATA(as, 'add5', h) = 0.034 * TotalLoads1(as, h);

* Distribution system B
Table    BDLDATA(bdl, *)   Distribution Line Data
         X       R       PLmax   QLmax
bdl1     0.15    0.09    70      33.901
bdl2     0.20    0.12    90      43.587
bdl3     0.16    0.10    70      33.901
bdl4     0.18    0.11    50      24.215
bdl5     0.18    0.11    40      19.372
bdl6     0.16    0.10    40      19.372;

Table    BDGDATA(bdg, *)   Distribution Generator Data
         base    p1      p2      p3      p4      Pmin    Pmax    RU      RD
bdg1     165.75  5.45    5.75    6.05    6.35    5       5       15      15      ;

Parameter    BDDDATA(bs, bdd, h);
BDDDATA(bs, 'bdd1', h) = 0.132 * TotalLoads2(bs, h);
BDDDATA(bs, 'bdd2', h) = 0.072 * TotalLoads2(bs, h);
BDDDATA(bs, 'bdd3', h) = 0.112 * TotalLoads2(bs, h);
BDDDATA(bs, 'bdd4', h) = 0.084 * TotalLoads2(bs, h);

display ADDDATA, BDDDATA;

Parameter    ADRparm(as, adr, h);
ADRparm(as, 'adr1', h) = ARG(as, h);
Parameter    BDRparm(bs, bdr, h);
BDRparm(bs, 'bdr1', h) = BRG(bs, h);

Scalar   PC      Penalty Cost    /800/;

********************************************************************************
****************************** Problem Setup ***********************************
********************************************************************************

* Setup and solve the initial transmission master problem

Free Variable
         Tobj, Tf(tl,h), APinj(h), BPinj(h), theta(tn,h);

Positive Variable
         Tp(tg, h), Tp1(tg,h), Tp2(tg,h), Tp3(tg,h), Tp4(tg,h), Tp5(tg,h), Tshed(td,h);

Equations
         Tobjective, Tnode1, Tnode2, Tnode3, Tflow, TgenlimU1, TgenlimU2, TgenlimU3, TgenlimU4, TgenlimU5,
         Tgenall, TflowlimU, TflowlimD, RUlim, RDlim, Loadshedlim, APinjlimU, APinjlimD, BPinjlimU, BPinjlimD;

Tobjective..             Tobj =e= sum(h, sum(tg, TGDATA(tg, 'base') +
                                 TGDATA(tg, 'p1') * Tp1(tg,h) + TGDATA(tg, 'p2') * Tp2(tg,h) + TGDATA(tg, 'p3') * Tp3(tg,h) + TGDATA(tg, 'p4') * Tp4(tg,h) + TGDATA(tg, 'p5') * Tp5(tg,h))
                                 + sum(td, PC * Tshed(td,h)));

Tnode1(tn, h)$((ord(tn)<>3) and (ord(tn)<>4))..
                         sum(tg$mapTG(tg, tn), Tp(tg, h))
                         - sum(tl$mapTSL(tl, tn), Tf(tl, h)) + sum(tl$mapTRL(tl, tn), Tf(tl, h)) =e=
                         sum(td$mapTD(td, tn), TDDATA(td, h) - Tshed(td, h));

Tnode2(tn, h)$(ord(tn)=3)..
                         sum(tg$mapTG(tg, tn), Tp(tg, h))
                         - sum(tl$mapTSL(tl, tn), Tf(tl, h)) + sum(tl$mapTRL(tl, tn), Tf(tl, h)) - APinj(h) =e=
                         sum(td$mapTD(td, tn), TDDATA(td, h) - Tshed(td, h));

Tnode3(tn, h)$(ord(tn)=4)..
                         sum(tg$mapTG(tg, tn), Tp(tg, h))
                         - sum(tl$mapTSL(tl, tn), Tf(tl, h)) + sum(tl$mapTRL(tl, tn), Tf(tl, h)) - BPinj(h) =e=
                         sum(td$mapTD(td, tn), TDDATA(td, h) - Tshed(td, h));

Tflow(tl, h)..           Tf(tl, h) =e= (sum(tn$mapTSL(tl, tn), theta(tn,h)) - sum(tn$mapTRL(tl, tn), theta(tn,h))) / TLDATA(tl, 'X');

TflowlimU(tl, h)..       Tf(tl, h) =l= TLDATA(tl, 'PLmax');
TflowlimD(tl, h)..       Tf(tl, h) =g= - TLDATA(tl, 'PLmax');

TgenlimU1(tg, h)..       Tp1(tg, h) =l= TGDATA(tg, 'Pmax');
TgenlimU2(tg, h)..       Tp2(tg, h) =l= TGDATA(tg, 'Pmax');
TgenlimU3(tg, h)..       Tp3(tg, h) =l= TGDATA(tg, 'Pmax');
TgenlimU4(tg, h)..       Tp4(tg, h) =l= TGDATA(tg, 'Pmax');
TgenlimU5(tg, h)..       Tp5(tg, h) =l= TGDATA(tg, 'Pmax');

Tgenall(tg, h)..         Tp(tg, h) =e= TGDATA(tg, 'Pmin') + Tp1(tg,h) + Tp2(tg,h) + Tp3(tg,h) + Tp4(tg,h) + Tp5(tg,h);

RUlim(tg, h)$(ord(h)>1)..
                         Tp(tg, h) =l= Tp(tg, h-1) + TGDATA(tg, 'RU');
RDlim(tg, h)$(ord(h)>1)..
                         Tp(tg, h) =g= Tp(tg, h-1) - TGDATA(tg, 'RD');

Loadshedlim(td, h)..     Tshed(td, h) =l= TDDATA(td, h);

APinjlimU(h)..            APinj(h) =l= 60;
APinjlimD(h)..            APinj(h) =g= -60;
BPinjlimU(h)..            BPinj(h) =l= 70;
BPinjlimD(h)..            BPinj(h) =g= -70;

Model    TranMaster0      /Tobjective, Tnode1, Tnode2, Tnode3, Tflow, TgenlimU1, TgenlimU2, TgenlimU3, TgenlimU4, TgenlimU5,
                         Tgenall, TflowlimU, TflowlimD, RUlim, RDlim, Loadshedlim, APinjlimU, APinjlimD, BPinjlimU, BPinjlimD/ ;

* Setup the Distribution Subproblems
* This is the version of Linearized Approximation on AC Power FLow.
* Gather-Update-Scatter-Solve Facility is used here to solve distribution subproblems.

* Distribution System A

$ontext
Free Variable
         ADobj, ADf(adl, h), ADQf(adl, h), ADvol(adn, h);

Positive Variable
         ADp(adg, h), ADp1(adg, h), ADp2(adg, h), ADp3(adg, h), ADp4(adg, h), ADp5(adg, h),
         ADp6(adg, h), ADPshedPos(add, h), ADPshedNeg(add, h), ADq(adg, h), ADfplus(adl, h), ADfneg(adl, h),
         ADQfplus(adl, h), ADQfneg(adl, h), ADabsP(adl, h), ADabsQ(adl, h), APinjPenalty(h);

Parameter
         APinjparm(h), ADDDATAs(add, h), ADRs(adr, h);

Equations
         ADobjective, ADnode1(adn, h), ADnode21(adn, h), ADnode22(adn, h), ADgenlimU1(adg, h), ADgenlimU2(adg, h), ADgenlimU3(adg, h),
         ADgenlimU4(adg, h), ADgenlimU5(adg, h), ADgenlimU6(adg, h), ADgenall(adg, h), ADRUlim(adg, h), ADRDlim(adg, h),
         ADLoadshedlimPos(add, h), ADLoadshedlimNeg(add, h), ADPinjPen(h), ADflowlimU(adl, h), ADflowlimD(adl, h);

ADobjective..            ADobj =e= sum(h, sum(adg, ADGDATA(adg, 'base') +
                                 ADGDATA(adg, 'p1') * ADp1(adg,h) + ADGDATA(adg, 'p2') * ADp2(adg,h) +
                                 ADGDATA(adg, 'p3') * ADp3(adg,h) + ADGDATA(adg, 'p4') * ADp4(adg,h) +
                                 ADGDATA(adg, 'p5') * ADp5(adg,h) + ADGDATA(adg, 'p6') * ADp6(adg,h)) + PC * sum(add, ADPshedPos(add,h) + ADPshedNeg(add,h)) + PC * 10 * APinjPenalty(h));

ADnode1(adn, h)$(ord(adn)<>1)..
                         sum(adg$mapADG(adg, adn), ADp(adg, h)) + sum(adr$mapADR(adr, adn), ADRs(adr, h))
                         - sum(adl$mapADSL(adl, adn), ADf(adl, h)) + sum(adl$mapADRL(adl, adn), ADf(adl, h))
                         =e= sum(add$mapADD(add, adn), ADDDATAs(add, h) - ADPshedPos(add, h) + ADPshedNeg(add, h));

ADnode21(adn, h)$(ord(adn)=1)..
                         sum(adg$mapADG(adg, adn), ADp(adg, h)) + APinjparm(h) + APinjPenalty(h)
                         - sum(adl$mapADSL(adl, adn), ADf(adl, h)) + sum(adl$mapADRL(adl, adn), ADf(adl, h))
                         =l= sum(add$mapADD(add, adn), ADDDATAs(add, h) - ADPshedPos(add, h) + ADPshedNeg(add, h));

ADnode22(adn, h)$(ord(adn)=1)..
                         sum(adg$mapADG(adg, adn), ADp(adg, h)) + APinjparm(h) + APinjPenalty(h)
                         - sum(adl$mapADSL(adl, adn), ADf(adl, h)) + sum(adl$mapADRL(adl, adn), ADf(adl, h))
                         =g= sum(add$mapADD(add, adn), ADDDATAs(add, h) - ADPshedPos(add, h) + ADPshedNeg(add, h));

ADgenlimU1(adg, h).. ADp1(adg, h) =l= ADGDATA(adg, 'Pmax');
ADgenlimU2(adg, h).. ADp2(adg, h) =l= ADGDATA(adg, 'Pmax');
ADgenlimU3(adg, h).. ADp3(adg, h) =l= ADGDATA(adg, 'Pmax');
ADgenlimU4(adg, h).. ADp4(adg, h) =l= ADGDATA(adg, 'Pmax');
ADgenlimU5(adg, h).. ADp5(adg, h) =l= ADGDATA(adg, 'Pmax');
ADgenlimU6(adg, h).. ADp6(adg, h) =l= ADGDATA(adg, 'Pmax');

ADgenall(adg, h)..   ADp(adg, h) =e= ADGDATA(adg, 'Pmin') + ADp1(adg,h) + ADp2(adg,h) + ADp3(adg,h) + ADp4(adg,h) + ADp5(adg,h) + ADp6(adg, h);

ADflowlimU(adl, h).. ADf(adl, h) =l= ADLDATA(adl, 'PLmax');
ADflowlimD(adl, h).. ADf(adl, h) =g= - ADLDATA(adl, 'PLmax');

*ADvollimU(adn, h)..  ADvol(adn, h) =l= 1.05;
*ADvollimD(adn, h)..  ADvol(adn, h) =g= 0.95;

ADRUlim(adg, h)$(ord(h)>1)..
                         ADp(adg, h) =l= ADp(adg, h-1) + ADGDATA(adg, 'RU');
ADRDlim(adg, h)$(ord(h)>1)..
                         ADp(adg, h) =g= ADp(adg, h-1) - ADGDATA(adg, 'RD');

ADPinjPen(h)..       APinjPenalty(h) =l= 60;

ADLoadShedlimPos(add, h)..
                         ADPshedPos(add, h) =l= ADDDATAs(add, h);
ADLoadShedlimNeg(add, h)..
                         ADPshedNeg(add, h) =l= ADDDATAs(add, h);


ADvolflow(adl, h)..  sum(adn$mapADSL(adl, adn), ADvol(adn, h)) - sum(adn$mapADRL(adl, adn), ADvol(adn, h))
                         =e= ADLDATA(adl, 'R') * ADabsP(adl, h) + ADLDATA(adl, 'X') * ADabsQ(adl, h);

QflimU(adl, h)..     ADabsQ(adl, h) =l= 0.4863 * ADabsP(adl, h);

ADdecPf(adl, h)..    ADf(adl, h) =e= ADfplus(adl, h) - ADfneg(adl, h);
ADdecQf(adl, h)..    ADQf(adl, h) =e= ADQfplus(adl, h) - ADQfneg(adl, h);
ADabsPf(adl, h)..    ADabsP(adl, h) =e= ADfplus(adl, h) + ADfneg(adl, h);
ADabsQf(adl, h)..    ADabsQ(adl, h) =e= ADQfplus(adl, h) + ADQfneg(adl, h);


Model    ADSubLA         /ADobjective, ADnode1, ADnode21, ADnode22, ADgenlimU1, ADgenlimU2, ADgenlimU3, ADgenlimU4, ADgenlimU5,
         ADgenlimU6, ADgenall, ADRUlim, ADRDlim, ADLoadshedlimPos, ADLoadshedlimNeg, ADPinjPen, ADflowlimU, ADflowlimD/;

Set mattrib / system.GUSSModelAttributes /;

Parameters
         srep(as, mattrib) 'model attributes like modelstat etc.'
         o(*)             'GUSS options' /SkipBaseCase 1/;

Parameter
         ADPshedparmPos(as, add, h), ADPshedparmNeg(as, add, h), ADobjparm(as), ADpparm(as, adg, h);

Parameters
         ADnode1dual(as, adn, h), ADnode21dual(as, adn, h), ADnode22dual(as, adn, h), ADgenlimU1dual(as, adg, h),
         ADgenlimU2dual(as, adg, h), ADgenlimU3dual(as, adg, h), ADgenlimU4dual(as, adg, h), ADgenlimU5dual(as, adg, h),
         ADgenlimU6dual(as, adg, h), ADRUlimdual(as, adg, h), ADRDlimdual(as, adg, h), ADLoadshedlimPosdual(as, add, h), ADLoadshedlimNegdual(as, add, h),
         ADPinjPendual(as, h), ADflowlimUdual(as, adl, h), ADflowlimDdual(as, adl, h);

Set dict /as.                    scenario.       ''
          o.                     opt.            srep
          ADDDATAs.              param.          ADDDATA
          ADRs.                  param.          ADRparm
          ADp.                   level.          ADpparm
          ADPshedPos.            level.          ADPshedparmPos
          ADPshedNeg.            level.          ADPshedparmNeg
          ADobj.                 level.          ADobjparm
          ADnode1.               marginal.       ADnode1dual
          ADnode21.              marginal.       ADnode21dual
          ADnode22.              marginal.       ADnode22dual
          ADgenlimU1.            marginal.       ADgenlimU1dual
          ADgenlimU2.            marginal.       ADgenlimU2dual
          ADgenlimU3.            marginal.       ADgenlimU3dual
          ADgenlimU4.            marginal.       ADgenlimU4dual
          ADgenlimU5.            marginal.       ADgenlimU5dual
          ADgenlimU6.            marginal.       ADgenlimU6dual
          ADRUlim.               marginal.       ADRUlimdual
          ADRDlim.               marginal.       ADRDlimdual
          ADLoadshedlimPos.      marginal.       ADLoadshedlimPosdual
          ADLoadshedlimNeg.      marginal.       ADLoadshedlimNegdual
          ADflowlimU.            marginal.       ADflowlimUdual
          ADflowlimD.            marginal.       ADflowlimDdual
          ADPinjPen.             marginal.       ADPinjPendual
/;

ADDDATAs(add, h) = 0;
ADRs(adr, h) = 0;


Loop(as,
         ADDDATAs(add, h) = ADDDATA(add, as, h);
         ADRs(adr, h) = ADRparm(adr, as, h);

         Solve ADSubLA using LP minimizing ADobj;

         ADobjparm(as) = ADobj.l;
         ADPshedparm(add, h, as) = ADPshed.l(add, h);
         ADpparm(adg, h, as) = ADp.l(adg, h);
         ADPinjdual(adn, h, as) = ADnode2.m(adn, h);
);

Display ADPshedparm, ADobjparm, ADPinjdual, ADpparm;



* Distribution System B
Free Variable
         BDobj, BDf(bdl, h), BDQf(bdl, h), BDvol(bdn, h);

Positive Variable
         BDp(bdg, h), BDp1(bdg, h), BDp2(bdg, h), BDp3(bdg, h), BDp4(bdg, h), BDp5(bdg, h),
         BDp6(bdg, h), BDPshedPos(bdd, h), BDPshedNeg(bdd, h), BDq(bdg, h), BDfplus(bdl, h), BDfneg(bdl, h),
         BDQfplus(bdl, h), BDQfneg(bdl, h), BDabsP(bdl, h), BDabsQ(bdl, h), BPinjPenalty(h);

Parameter
         BPinjparm(h), BDDDATAs(bdd, h), BDRs(bdr, h);

Equations
         BDobjective, BDnode1(bdn, h), BDnode21(bdn, h), BDnode22(bdn, h), BDgenlimU1(bdg, h), BDgenlimU2(bdg, h), BDgenlimU3(bdg, h), BDgenlimU4(bdg, h),
*         BDvolflow, BQflimU, BDabsPf, BDdecPf, BDabsQf, BDdecQf,
         BDgenall(bdg, h), BDRUlim(bdg, h), BDRDlim(bdg, h), BDLoadshedlimPos(bdd, h), BDLoadShedlimNeg(bdd, h),
         BDPinjPen(h), BDflowlimU(bdl, h), BDflowlimD(bdl, h);

BDobjective..            BDobj =e= sum(h, sum(bdg, BDGDATA(bdg, 'base') +
                                 BDGDATA(bdg, 'p1') * BDp1(bdg,h) + BDGDATA(bdg, 'p2') * BDp2(bdg,h) +
                                 BDGDATA(bdg, 'p3') * BDp3(bdg,h) + BDGDATA(bdg, 'p4') * BDp4(bdg,h)) + PC * sum(bdd, BDPshedPos(bdd,h) + BDPshedNeg(bdd,h)) + PC * 10 * BPinjPenalty(h));

BDnode1(bdn, h)$(ord(bdn)<>1)..
                         sum(bdg$mapBDG(bdg, bdn), BDp(bdg, h)) + sum(bdr$mapBDR(bdr, bdn), BDRs(bdr, h))
                         - sum(bdl$mapBDSL(bdl, bdn), BDf(bdl, h)) + sum(bdl$mapBDRL(bdl, bdn), BDf(bdl, h))
                         =e= sum(bdd$mapBDD(bdd, bdn), BDDDATAs(bdd, h) - BDPshedPos(bdd, h) + BDPshedNeg(bdd, h));

BDnode21(bdn, h)$(ord(bdn)=1)..
                         sum(bdg$mapBDG(bdg, bdn), BDp(bdg, h)) + BPinjparm(h) + BPinjPenalty(h)
                         - sum(bdl$mapBDSL(bdl, bdn), BDf(bdl, h)) + sum(bdl$mapBDRL(bdl, bdn), BDf(bdl, h))
                         =l= sum(bdd$mapBDD(bdd, bdn), BDDDATAs(bdd, h) - BDPshedPos(bdd, h) + BDPshedNeg(bdd, h));

BDnode22(bdn, h)$(ord(bdn)=1)..
                         sum(bdg$mapBDG(bdg, bdn), BDp(bdg, h)) + BPinjparm(h) + BPinjPenalty(h)
                         - sum(bdl$mapBDSL(bdl, bdn), BDf(bdl, h)) + sum(bdl$mapBDRL(bdl, bdn), BDf(bdl, h))
                         =g= sum(bdd$mapBDD(bdd, bdn), BDDDATAs(bdd, h) - BDPshedPos(bdd, h) + BDPshedNeg(bdd, h));

BDgenlimU1(bdg, h).. BDp1(bdg, h) =l= BDGDATA(bdg, 'Pmax');
BDgenlimU2(bdg, h).. BDp2(bdg, h) =l= BDGDATA(bdg, 'Pmax');
BDgenlimU3(bdg, h).. BDp3(bdg, h) =l= BDGDATA(bdg, 'Pmax');
BDgenlimU4(bdg, h).. BDp4(bdg, h) =l= BDGDATA(bdg, 'Pmax');

BDgenall(bdg, h)..   BDp(bdg, h) =e= BDGDATA(bdg, 'Pmin') + BDp1(bdg,h) + BDp2(bdg,h) + BDp3(bdg,h) + BDp4(bdg,h);

*ADvollimU(adn, h)..  ADvol(adn, h) =l= 1.05;
*ADvollimD(adn, h)..  ADvol(adn, h) =g= 0.95;

BDRUlim(bdg, h)$(ord(h)>1)..
                         BDp(bdg, h) =l= BDp(bdg, h-1) + BDGDATA(bdg, 'RU');
BDRDlim(bdg, h)$(ord(h)>1)..
                         BDp(bdg, h) =g= BDp(bdg, h-1) - BDGDATA(bdg, 'RD');

BDLoadShedlimPos(bdd, h)..
                     BDPshedPos(bdd, h) =l= BDDDATAs(bdd, h);
BDLoadShedlimNeg(bdd, h)..
                     BDPshedNeg(bdd, h) =l= BDDDATAs(bdd, h);

BDvolflow(bdl, h)..  sum(bdn$mapBDSL(bdl, bdn), BDvol(bdn, h)) - sum(bdn$mapBDRL(bdl, bdn), BDvol(bdn, h))
                         =e= BDLDATA(bdl, 'R') * BDabsP(bdl, h) + BDLDATA(bdl, 'X') * BDabsQ(bdl, h);

BQflimU(bdl, h)..    BDabsQ(bdl, h) =l= 0.4863 * BDabsP(bdl, h);

BDdecPf(bdl, h)..    BDf(bdl, h) =e= BDfplus(bdl, h) - BDfneg(bdl, h);
BDdecQf(bdl, h)..    BDQf(bdl, h) =e= BDQfplus(bdl, h) - BDQfneg(bdl, h);
BDabsPf(bdl, h)..    BDabsP(bdl, h) =e= BDfplus(bdl, h) + BDfneg(bdl, h);
BDabsQf(bdl, h)..    BDabsQ(bdl, h) =e= BDQfplus(bdl, h) + BDQfneg(bdl, h);


BDflowlimU(bdl, h).. BDf(bdl, h) =l= BDLDATA(bdl, 'PLmax');
BDflowlimD(bdl, h).. BDf(bdl, h) =l= BDLDATA(bdl, 'PLmax');

BDPinjPen(h)..    BPinjPenalty(h) =l= 70;

Model    BDSubLA         /BDobjective, BDnode1, BDnode21, BDnode22, BDgenlimU1, BDgenlimU2, BDgenlimU3, BDgenlimU4,
*         BDvolflow, BQflimU, BDabsPf, BDdecPf, BDabsQf, BDdecQf,
         BDgenall, BDRUlim, BDRDlim, BDLoadshedlimPos, BDLoadShedlimNeg, BDPinjPen, BDflowlimU, BDflowlimD/;

Parameter
         BDPshedparmPos(bs, bdd, h), BDPshedparmNeg(bs, bdd, h), BDobjparm(bs), BDpparm(bs, bdg, h);

Parameters
         bsrep(bs, mattrib) 'model attributes like modelstat etc.'
         bo(*)             'GUSS options' /SkipBaseCase 1/;

Parameters
         BDnode1dual(bs, bdn, h), BDnode21dual(bs, bdn, h), BDnode22dual(bs, bdn, h), BDgenlimU1dual(bs, bdg, h),
         BDgenlimU2dual(bs, bdg, h), BDgenlimU3dual(bs, bdg, h), BDgenlimU4dual(bs, bdg, h),
         BDRUlimdual(bs, bdg, h), BDRDlimdual(bs, bdg, h), BDLoadshedlimPosdual(bs, bdd, h), BDLoadshedlimNegdual(bs, bdd, h),
         BDPinjPendual(bs, h), BDflowlimUdual(bs, bdl, h), BDflowlimDdual(bs, bdl, h);

Set bdict /bs.                    scenario.       ''
           bo.                    opt.            bsrep
           BDDDATAs.              param.          BDDDATA
           BDRs.                  param.          BDRparm
           BDp.                   level.          BDpparm
           BDPshedPos.            level.          BDPshedparmPos
           BDPshedNeg.            level.          BDPshedparmNeg
           BDobj.                 level.          BDobjparm
           BDnode1.               marginal.       BDnode1dual
           BDnode21.              marginal.       BDnode21dual
           BDnode22.              marginal.       BDnode22dual
           BDgenlimU1.            marginal.       BDgenlimU1dual
           BDgenlimU2.            marginal.       BDgenlimU2dual
           BDgenlimU3.            marginal.       BDgenlimU3dual
           BDgenlimU4.            marginal.       BDgenlimU4dual
           BDRUlim.               marginal.       BDRUlimdual
           BDRDlim.               marginal.       BDRDlimdual
           BDLoadshedlimPos.      marginal.       BDLoadshedlimPosdual
           BDLoadshedlimNeg.      marginal.       BDLoadshedlimNegdual
           BDPinjPen.             marginal.       BDPinjPendual
           BDflowlimU.            marginal.       BDflowlimUdual
           BDflowlimD.            marginal.       BDflowlimDdual
/;

BDDDATAs(bdd, h) = 0;
BDRs(bdr, h) = 0;

*Display BDPshedparmPos, BDPshedparmNeg, BDobjparm, BDpparm, BDRUlimdual, BDRDlimdual, BDRUlimdual, BDRDlimdual, BDnode1dual;



Loop(bs,
         BDDDATAs(bdd, h) = BDDDATA(bs, bdd, h);
         BDRs(bdr, h) = BDRparm(bs, bdr, h);

         Solve BDSubLA using LP minimizing BDobj;

         BDobjparm(bs) = BDobj.l;
         BDPshedparmPos(bs, bdd, h) = BDPshedPos.l(bdd, h);
         BDPshedparmNeg(bs, bdd, h) = BDPshedNeg.l(bdd, h);
         BDpparm(bs, bdg, h) = BDp.l(bdg, h);
         BDPinjdual(bs, bdn, h) = BDnode2.m(bdn, h);
);

Display BDPshedparmPos, BDPshedparmNeg, BDobjparm, BDPinjdual, BDpparm;




* Revised Master Problem for Transmission System
Parameter
         Aalpha(iter), Balpha(iter), Abeta(iter, h), Bbeta(iter, h);

Free Variable
         TobjRevised, eta;

Equations
         RevisedObj, Acut(iter), Bcut(iter);

RevisedObj..     TobjRevised =e= sum(h, sum(tg, TGDATA(tg, 'base') +
                                 TGDATA(tg, 'p1') * Tp1(tg,h) + TGDATA(tg, 'p2') * Tp2(tg,h) + TGDATA(tg, 'p3') * Tp3(tg,h) + TGDATA(tg, 'p4') * Tp4(tg,h) + TGDATA(tg, 'p5') * Tp5(tg,h))
                                 + sum(td, PC * Tshed(td,h))) + eta;
Acut(cutsetA)..     Aalpha(cutsetA) + sum(h, Abeta(cutsetA, h) * APinj(h)) =l= eta;
Bcut(cutsetB)..     Balpha(cutsetB) + sum(h, Bbeta(cutsetB, h) * BPinj(h)) =l= eta;

Model    TranMasterRevised      /RevisedObj, Acut, Bcut, Tnode1, Tnode2, Tnode3, Tflow, TgenlimU1, TgenlimU2, TgenlimU3, TgenlimU4, TgenlimU5,
                                 Tgenall, TflowlimU, TflowlimD, RUlim, RDlim, Loadshedlim, APinjlimU, APinjlimD, BPinjlimU, BPinjlimD/ ;

********************************************************************************
*************************** Algorithm Procedure ********************************
********************************************************************************


Scalar criterion;
criterion = 1;

Solve TranMaster0 using LP minimizing Tobj;

loop(iter$(criterion=1),

         APinjparm(h) = APinj.l(h);
         BPinjparm(h) = BPinj.l(h);

         Solve ADSubLA using LP scenario dict minimizing ADobj;
         Solve BDSubLA using LP scenario bdict minimizing BDobj;
         Display ADPshedparmPos, ADPshedparmNeg, ADobjparm, ADpparm, ADRUlimdual, ADRDlimdual, ADnode21dual, ADnode22dual;

         Aalpha(iter) = sum(as, ProbA(as) *   sum(h, sum(adn, ADnode1dual(as, adn, h) * sum(add$mapADD(add, adn), ADDDATA(as, add, h)) +
                                                       ADnode21dual(as, adn, h) * sum(add$mapADD(add, adn), ADDDATA(as,add, h)) + ADnode22dual(as, adn, h) * sum(add$mapADD(add, adn), ADDDATA(as, add, h)))
                                                     + sum(adg, ADgenlimU1dual(as, adg, h) * ADGDATA(adg, 'Pmax') + ADgenlimU2dual(as, adg, h) * ADGDATA(adg, 'Pmax') +
                                                       ADgenlimU3dual(as, adg, h) * ADGDATA(adg, 'Pmax') + ADgenlimU4dual(as, adg, h) * ADGDATA(adg, 'Pmax') +
                                                       ADgenlimU5dual(as, adg, h) * ADGDATA(adg, 'Pmax') + ADgenlimU6dual(as, adg, h) * ADGDATA(adg, 'Pmax') +
                                                       ADRUlimdual(as, adg, h) * ADGDATA(adg, 'RU') - ADRDlimdual(as, adg, h) * ADGDATA(adg, 'RD'))
                                                     + sum(add, ADLoadshedlimPosdual(as, add, h) * ADDDATA(as, add, h) - ADLoadshedlimNegdual(as, add, h) * ADDDATA(as, add, h))
                                                     + sum(adl, ADflowlimUdual(as, adl, h) * ADLDATA(adl, 'PLmax') - ADflowlimDdual(as, adl, h) * ADLDATA(adl, 'PLmax'))
                                                     + ADpinjPendual(as, h) * 60   ));

         Balpha(iter) = sum(bs, ProbB(bs) *   sum(h, sum(bdn, BDnode1dual(bs, bdn, h) * sum(bdd$mapBDD(bdd, bdn), BDDDATA(bs, bdd, h)) +
                                                       BDnode21dual(bs, bdn, h) * sum(bdd$mapBDD(bdd, bdn), BDDDATA(bs, bdd, h)) + BDnode22dual(bs, bdn, h) * sum(bdd$mapBDD(bdd, bdn), BDDDATA(bs, bdd, h)))
                                                     + sum(bdg, BDgenlimU1dual(bs, bdg, h) * BDGDATA(bdg, 'Pmax') + BDgenlimU2dual(bs, bdg, h) * BDGDATA(bdg, 'Pmax') +
                                                       BDgenlimU3dual(bs, bdg, h) * BDGDATA(bdg, 'Pmax') + BDgenlimU4dual(bs, bdg, h) * BDGDATA(bdg, 'Pmax') +
                                                       BDRUlimdual(bs, bdg, h) * BDGDATA(bdg, 'RU') - BDRDlimdual(bs, bdg, h) * BDGDATA(bdg, 'RD'))
                                                     + sum(bdd, BDLoadshedlimPosdual(bs, bdd, h) * BDDDATA(bs, bdd, h) - BDLoadshedlimNegdual(bs, bdd, h) * BDDDATA(bs, bdd, h))
                                                     + sum(bdl, BDflowlimUdual(bs, bdl, h) * BDLDATA(bdl, 'PLmax') - BDflowlimDdual(bs, bdl, h) * BDLDATA(bdl, 'PLmax'))
                                                     + BDpinjPendual(bs, h) * 70   ));

*         Abeta(iter, h) = sum(as, ProbA(as) *  sum(adn, ADnode21dual(as, adn, h) * ))


         criterion = 0;
);

display Aalpha,Balpha;
$offtext



Free Variable
         ADobj1, ADf1(as, adl, h);

Positive Variable
         ADp1(as, adg, h), ADp11(as, adg, h), ADp21(as, adg, h), ADp31(as, adg, h), ADp41(as, adg, h), ADp51(as, adg, h),
         ADp61(as, adg, h), ADPshed1(as, add, h), APinjPenaltyPos1(as, h), APinjPenaltyNeg1(as, h);

Equations
         ADobjective1, ADnode11, ADnode211, ADgenlimU11, ADgenlimU21, ADgenlimU31,
         ADgenlimU41, ADgenlimU51, ADgenlimU61, ADgenall1, ADRUlim1, ADRDlim1,
         ADLoadshedlim1, ADflowlimU1, ADflowlimD1;

ADobjective1..            ADobj1 =e= sum(as, ProbA(as) * sum(h, sum(adg, ADGDATA(adg, 'base') +
                                 ADGDATA(adg, 'p1') * ADp11(as,adg,h) + ADGDATA(adg, 'p2') * ADp21(as,adg,h) +
                                 ADGDATA(adg, 'p3') * ADp31(as,adg,h) + ADGDATA(adg, 'p4') * ADp41(as,adg,h) +
                                 ADGDATA(adg, 'p5') * ADp51(as,adg,h) + ADGDATA(adg, 'p6') * ADp61(as,adg,h)) + PC * sum(add, ADPshed1(as,add,h)) + PC * 10 *( APinjPenaltyPos1(as, h) + APinjPenaltyNeg1(as, h) )));

ADnode11(as, adn, h)$(ord(adn)<>1)..
                         sum(adg$mapADG(adg, adn), ADp1(as, adg, h)) + sum(adr$mapADR(adr, adn), ADRparm(as, adr, h))
                         - sum(adl$mapADSL(adl, adn), ADf1(as,adl, h)) + sum(adl$mapADRL(adl, adn), ADf1(as,adl, h))
                         =e= sum(add$mapADD(add, adn), ADDDATA(as,add, h) - ADPshed1(as,add, h));

ADnode211(as, adn, h)$(ord(adn)=1)..
                         sum(adg$mapADG(adg, adn), ADp1(as, adg, h)) + APinj(h) + APinjPenaltyPos1(as, h) - APinjPenaltyNeg1(as, h) +
                         sum(adr$mapADR(adr, adn), ADRparm(as, adr, h)) - sum(adl$mapADSL(adl, adn), ADf1(as,adl, h)) + sum(adl$mapADRL(adl, adn), ADf1(as,adl, h))
                         =e= sum(add$mapADD(add, adn), ADDDATA(as,add, h) - ADPshed1(as,add, h));

ADgenlimU11(as, adg, h).. ADp11(as, adg, h) =l= ADGDATA(adg, 'Pmax');
ADgenlimU21(as, adg, h).. ADp21(as, adg, h) =l= ADGDATA(adg, 'Pmax');
ADgenlimU31(as, adg, h).. ADp31(as, adg, h) =l= ADGDATA(adg, 'Pmax');
ADgenlimU41(as, adg, h).. ADp41(as, adg, h) =l= ADGDATA(adg, 'Pmax');
ADgenlimU51(as, adg, h).. ADp51(as, adg, h) =l= ADGDATA(adg, 'Pmax');
ADgenlimU61(as, adg, h).. ADp61(as, adg, h) =l= ADGDATA(adg, 'Pmax');

ADgenall1(as, adg, h)..   ADp1(as, adg, h) =e= ADGDATA(adg, 'Pmin') + ADp11(as, adg,h) + ADp21(as, adg,h) + ADp31(as, adg,h) + ADp41(as, adg,h) + ADp51(as, adg,h) + ADp61(as, adg, h);

ADflowlimU1(as, adl, h).. ADf1(as, adl, h) =l= ADLDATA(adl, 'PLmax');
ADflowlimD1(as, adl, h).. ADf1(as, adl, h) =g= - ADLDATA(adl, 'PLmax');

*ADvollimU(adn, h)..  ADvol(adn, h) =l= 1.05;
*ADvollimD(adn, h)..  ADvol(adn, h) =g= 0.95;

ADRUlim1(as, adg, h)$(ord(h)>1)..
                         ADp1(as, adg, h) =l= ADp1(as, adg, h-1) + ADGDATA(adg, 'RU');
ADRDlim1(as, adg, h)$(ord(h)>1)..
                         ADp1(as, adg, h) =g= ADp1(as, adg, h-1) - ADGDATA(adg, 'RD');

ADLoadShedlim1(as, add, h)..
                         ADPshed1(as, add, h) =l= ADDDATA(as, add, h);






Free Variable
         BDobj1, BDf1(bs, bdl, h);

Positive Variable
         BDp1(bs, bdg, h), BDp11(bs, bdg, h), BDp21(bs, bdg, h), BDp31(bs, bdg, h), BDp41(bs, bdg, h),
         BDPshed1(bs, bdd, h), BPinjPenaltyPos1(bs, h), BPinjPenaltyNeg1(bs, h);

Equations
         BDobjective1, BDnode11, BDnode211, BDgenlimU11, BDgenlimU21, BDgenlimU31,
         BDgenlimU41, BDgenall1, BDRUlim1, BDRDlim1,
         BDLoadshedlim1, BDflowlimU1, BDflowlimD1;

BDobjective1..            BDobj1 =e= sum(bs, ProbB(bs) * sum(h, sum(bdg, BDGDATA(bdg, 'base') +
                                 BDGDATA(bdg, 'p1') * BDp11(bs,bdg,h) + BDGDATA(bdg, 'p2') * BDp21(bs,bdg,h) +
                                 BDGDATA(bdg, 'p3') * BDp31(bs,bdg,h) + BDGDATA(bdg, 'p4') * BDp41(bs,bdg,h)
                                + PC * sum(bdd, BDPshed1(bs,bdd,h)) + PC * 10 *( BPinjPenaltyPos1(bs, h) + BPinjPenaltyNeg1(bs, h) ))));

BDnode11(bs, bdn, h)$(ord(bdn)<>1)..
                         sum(bdg$mapBDG(bdg, bdn), BDp1(bs, bdg, h)) + sum(bdr$mapBDR(bdr, bdn), BDRparm(bs, bdr, h))
                         - sum(bdl$mapBDSL(bdl, bdn), BDf1(bs,bdl, h)) + sum(bdl$mapBDRL(bdl, bdn), BDf1(bs,bdl, h))
                         =e= sum(bdd$mapBDD(bdd, bdn), BDDDATA(bs,bdd, h) - BDPshed1(bs,bdd, h));

BDnode211(bs, bdn, h)$(ord(bdn)=1)..
                         sum(bdg$mapBDG(bdg, bdn), BDp1(bs, bdg, h)) + BPinj(h) + BPinjPenaltyPos1(bs, h) - BPinjPenaltyNeg1(bs, h)
                         - sum(bdl$mapBDSL(bdl, bdn), BDf1(bs,bdl, h)) + sum(bdl$mapBDRL(bdl, bdn), BDf1(bs,bdl, h))
                         =e= sum(bdd$mapBDD(bdd, bdn), BDDDATA(bs,bdd, h) - BDPshed1(bs,bdd, h));

BDgenlimU11(bs, bdg, h).. BDp11(bs, bdg, h) =l= BDGDATA(bdg, 'Pmax');
BDgenlimU21(bs, bdg, h).. BDp21(bs, bdg, h) =l= BDGDATA(bdg, 'Pmax');
BDgenlimU31(bs, bdg, h).. BDp31(bs, bdg, h) =l= BDGDATA(bdg, 'Pmax');
BDgenlimU41(bs, bdg, h).. BDp41(bs, bdg, h) =l= BDGDATA(bdg, 'Pmax');

BDgenall1(bs, bdg, h)..   BDp1(bs, bdg, h) =e= BDGDATA(bdg, 'Pmin') + BDp11(bs, bdg,h) + BDp21(bs, bdg,h) + BDp31(bs, bdg,h) + BDp41(bs, bdg,h);

BDflowlimU1(bs, bdl, h).. BDf1(bs, bdl, h) =l= BDLDATA(bdl, 'PLmax');
BDflowlimD1(bs, bdl, h).. BDf1(bs, bdl, h) =g= - BDLDATA(bdl, 'PLmax');

BDRUlim1(bs, bdg, h)$(ord(h)>1)..
                         BDp1(bs, bdg, h) =l= BDp1(bs, bdg, h-1) + BDGDATA(bdg, 'RU');
BDRDlim1(bs, bdg, h)$(ord(h)>1)..
                         BDp1(bs, bdg, h) =g= BDp1(bs, bdg, h-1) - BDGDATA(bdg, 'RD');

BDLoadShedlim1(bs, bdd, h)..
                         BDPshed1(bs, bdd, h) =l= BDDDATA(bs, bdd, h);

free variable
         obj1;

Equation
         objective1;

objective1..              obj1 =e= Tobj + ADobj1 + BDobj1;


Model overall /Tobjective, Tnode1, Tnode2, Tnode3, Tflow, TgenlimU1, TgenlimU2, TgenlimU3, TgenlimU4, TgenlimU5,
            Tgenall, TflowlimU, TflowlimD, RUlim, RDlim, Loadshedlim, APinjlimU, APinjlimD, BPinjlimU, BPinjlimD,
               ADobjective1, ADnode11, ADnode211, ADgenlimU11, ADgenlimU21, ADgenlimU31,
         ADgenlimU41, ADgenlimU51, ADgenlimU61, ADgenall1, ADRUlim1, ADRDlim1,
         ADLoadshedlim1, ADflowlimU1, ADflowlimD1,
               BDobjective1, BDnode11, BDnode211, BDgenlimU11, BDgenlimU21, BDgenlimU31,
         BDgenlimU41, BDgenall1, BDRUlim1, BDRDlim1,
         BDLoadshedlim1, BDflowlimU1, BDflowlimD1,
                 objective1    /;

solve overall min obj1 use lp;

scalar mm1, mm2, mm3, mm4, mm5, mm6;

parameter
         pinj(h);

mm1 = sum(as, sum(h, APinjPenaltyPos1.l(as, h)));
mm2 = sum(as, sum(h, APinjPenaltyNeg1.l(as, h)));
mm3 = sum(bs, sum(h, BPinjPenaltyPos1.l(bs, h)));
mm4 = sum(bs, sum(h, BPinjPenaltyNeg1.l(bs, h)));

mm5 = sum(as, sum(add, sum(h, ADPshed1.l(as, add, h))));
mm6 = sum(bs, sum(bdd, sum(h, BDPshed1.l(bs, bdd, h))));

pinj(h) = APinj.l(h) + BPinj.l(h);

display mm1, mm2, mm3, mm4, mm5, mm6, pinj;

scalar
         LMPPA, LMPPB;

LMPPA = (1/24) * sum(h, sum(tn, Tnode2.m(tn, h)));
LMPPB = (1/24) * sum(h, sum(tn, Tnode3.m(tn, h)));

display LMPPA, LMPPB;


Parameter ADDemands(h), BDDemands(h);

ADDemands(h) = sum(as, ProbA(as) * sum(add, ADDDATA(as, add, h))) - 33;
BDDemands(h) = sum(bs, ProbB(bs) * sum(bdd, BDDDATA(bs, bdd, h))) - 44;

Equation
         Tnodei2(tn, h), Tnodei3(tn, h);


Tnodei2(tn, h)$(ord(tn)=3)..
                         sum(tg$mapTG(tg, tn), Tp(tg, h))
                         - sum(tl$mapTSL(tl, tn), Tf(tl, h)) + sum(tl$mapTRL(tl, tn), Tf(tl, h)) - ADDemands(h) =e=
                         sum(td$mapTD(td, tn), TDDATA(td, h) - Tshed(td, h));

Tnodei3(tn, h)$(ord(tn)=4)..
                         sum(tg$mapTG(tg, tn), Tp(tg, h))
                         - sum(tl$mapTSL(tl, tn), Tf(tl, h)) + sum(tl$mapTRL(tl, tn), Tf(tl, h)) - BDDemands(h) =e=
                         sum(td$mapTD(td, tn), TDDATA(td, h) - Tshed(td, h));

Model isoTran /Tobjective, Tnode1, Tnodei2, Tnodei3, Tflow, TgenlimU1, TgenlimU2, TgenlimU3, TgenlimU4, TgenlimU5,
              Tgenall, TflowlimU, TflowlimD, RUlim, RDlim, Loadshedlim, APinjlimU, APinjlimD, BPinjlimU, BPinjlimD/ ;

solve isoTran use lp min Tobj;

parameter
         LMPA(h), LMPB(h);

LMPA(h) = sum(tn, Tnodei2.m(tn, h));
LMPB(h) = sum(tn, Tnodei3.m(tn, h));

display LMPA, LMPB;





Positive Variable
         Pinj_A(h)
Equation
         ADnode21i;

ADnode21i(as, adn, h)$(ord(adn)=1)..
                         sum(adg$mapADG(adg, adn), ADp1(as, adg, h)) + LMPA(h) * Pinj_A(h) + APinjPenaltyPos1(as, h) - APinjPenaltyNeg1(as, h) +
                         sum(adr$mapADR(adr, adn), ADRparm(as, adr, h)) - sum(adl$mapADSL(adl, adn), ADf1(as,adl, h)) + sum(adl$mapADRL(adl, adn), ADf1(as,adl, h))
                         =e= sum(add$mapADD(add, adn), ADDDATA(as,add, h) - ADPshed1(as,add, h));

Model isoDistA /ADobjective1, ADnode11, ADnode21i, ADgenlimU11, ADgenlimU21, ADgenlimU31,
         ADgenlimU41, ADgenlimU51, ADgenlimU61, ADgenall1, ADRUlim1, ADRDlim1,
         ADLoadshedlim1, ADflowlimU1, ADflowlimD1/;

solve isoDistA use lp min ADobj1;


Positive Variable
         Pinj_B(h)
Equation
         BDnode21i;

BDnode21i(bs, bdn, h)$(ord(bdn)=1)..
                         sum(bdg$mapBDG(bdg, bdn), BDp1(bs, bdg, h)) + LMPB(h) * Pinj_B(h) + BPinjPenaltyPos1(bs, h) - BPinjPenaltyNeg1(bs, h)
                         - sum(bdl$mapBDSL(bdl, bdn), BDf1(bs,bdl, h)) + sum(bdl$mapBDRL(bdl, bdn), BDf1(bs,bdl, h))
                         =e= sum(bdd$mapBDD(bdd, bdn), BDDDATA(bs,bdd, h) - BDPshed1(bs,bdd, h));

Model isoDistB /BDobjective1, BDnode11, BDnode21i, BDgenlimU11, BDgenlimU21, BDgenlimU31,
         BDgenlimU41, BDgenall1, BDRUlim1, BDRDlim1,
         BDLoadshedlim1, BDflowlimU1, BDflowlimD1/;

solve isoDistB use lp min BDobj1;


display Pinj_A.l, Pinj_B.l;

scalar
         perA, perB;

perA = (1/24) * sum(h, Pinj_A.l(h) / ADDemands(h));
perB = (1/24) * sum(h, Pinj_B.l(h) / ADDemands(h));

display perA, perB;
