#include "__cf_HEMS_v1.h"
#include <math.h>
#include "HEMS_v1_acc.h"
#include "HEMS_v1_acc_private.h"
#include <stdio.h>
#include "slexec_vm_simstruct_bridge.h"
#include "slexec_vm_zc_functions.h"
#include "slexec_vm_lookup_functions.h"
#include "simstruc.h"
#include "fixedpoint.h"
#define CodeFormat S-Function
#define AccDefine1 Accelerator_S-Function
#include "simtarget/slAccSfcnBridge.h"
#ifndef __RTW_UTFREE__  
extern void * utMalloc ( size_t ) ; extern void utFree ( void * ) ;
#endif
boolean_T HEMS_v1_acc_rt_TDelayUpdateTailOrGrowBuf ( int_T * bufSzPtr , int_T
* tailPtr , int_T * headPtr , int_T * lastPtr , real_T tMinusDelay , real_T *
* tBufPtr , real_T * * uBufPtr , real_T * * xBufPtr , boolean_T isfixedbuf ,
boolean_T istransportdelay , int_T * maxNewBufSzPtr ) { int_T testIdx ; int_T
tail = * tailPtr ; int_T bufSz = * bufSzPtr ; real_T * tBuf = * tBufPtr ;
real_T * xBuf = ( NULL ) ; int_T numBuffer = 2 ; if ( istransportdelay ) {
numBuffer = 3 ; xBuf = * xBufPtr ; } testIdx = ( tail < ( bufSz - 1 ) ) ? (
tail + 1 ) : 0 ; if ( ( tMinusDelay <= tBuf [ testIdx ] ) && ! isfixedbuf ) {
int_T j ; real_T * tempT ; real_T * tempU ; real_T * tempX = ( NULL ) ;
real_T * uBuf = * uBufPtr ; int_T newBufSz = bufSz + 1024 ; if ( newBufSz > *
maxNewBufSzPtr ) { * maxNewBufSzPtr = newBufSz ; } tempU = ( real_T * )
utMalloc ( numBuffer * newBufSz * sizeof ( real_T ) ) ; if ( tempU == ( NULL
) ) { return ( false ) ; } tempT = tempU + newBufSz ; if ( istransportdelay )
tempX = tempT + newBufSz ; for ( j = tail ; j < bufSz ; j ++ ) { tempT [ j -
tail ] = tBuf [ j ] ; tempU [ j - tail ] = uBuf [ j ] ; if ( istransportdelay
) tempX [ j - tail ] = xBuf [ j ] ; } for ( j = 0 ; j < tail ; j ++ ) { tempT
[ j + bufSz - tail ] = tBuf [ j ] ; tempU [ j + bufSz - tail ] = uBuf [ j ] ;
if ( istransportdelay ) tempX [ j + bufSz - tail ] = xBuf [ j ] ; } if ( *
lastPtr > tail ) { * lastPtr -= tail ; } else { * lastPtr += ( bufSz - tail )
; } * tailPtr = 0 ; * headPtr = bufSz ; utFree ( uBuf ) ; * bufSzPtr =
newBufSz ; * tBufPtr = tempT ; * uBufPtr = tempU ; if ( istransportdelay ) *
xBufPtr = tempX ; } else { * tailPtr = testIdx ; } return ( true ) ; } real_T
HEMS_v1_acc_rt_TDelayInterpolate ( real_T tMinusDelay , real_T tStart ,
real_T * tBuf , real_T * uBuf , int_T bufSz , int_T * lastIdx , int_T
oldestIdx , int_T newIdx , real_T initOutput , boolean_T discrete , boolean_T
minorStepAndTAtLastMajorOutput ) { int_T i ; real_T yout , t1 , t2 , u1 , u2
; if ( ( newIdx == 0 ) && ( oldestIdx == 0 ) && ( tMinusDelay > tStart ) )
return initOutput ; if ( tMinusDelay <= tStart ) return initOutput ; if ( (
tMinusDelay <= tBuf [ oldestIdx ] ) ) { if ( discrete ) { return ( uBuf [
oldestIdx ] ) ; } else { int_T tempIdx = oldestIdx + 1 ; if ( oldestIdx ==
bufSz - 1 ) tempIdx = 0 ; t1 = tBuf [ oldestIdx ] ; t2 = tBuf [ tempIdx ] ;
u1 = uBuf [ oldestIdx ] ; u2 = uBuf [ tempIdx ] ; if ( t2 == t1 ) { if (
tMinusDelay >= t2 ) { yout = u2 ; } else { yout = u1 ; } } else { real_T f1 =
( t2 - tMinusDelay ) / ( t2 - t1 ) ; real_T f2 = 1.0 - f1 ; yout = f1 * u1 +
f2 * u2 ; } return yout ; } } if ( minorStepAndTAtLastMajorOutput ) { if (
newIdx != 0 ) { if ( * lastIdx == newIdx ) { ( * lastIdx ) -- ; } newIdx -- ;
} else { if ( * lastIdx == newIdx ) { * lastIdx = bufSz - 1 ; } newIdx =
bufSz - 1 ; } } i = * lastIdx ; if ( tBuf [ i ] < tMinusDelay ) { while (
tBuf [ i ] < tMinusDelay ) { if ( i == newIdx ) break ; i = ( i < ( bufSz - 1
) ) ? ( i + 1 ) : 0 ; } } else { while ( tBuf [ i ] >= tMinusDelay ) { i = (
i > 0 ) ? i - 1 : ( bufSz - 1 ) ; } i = ( i < ( bufSz - 1 ) ) ? ( i + 1 ) : 0
; } * lastIdx = i ; if ( discrete ) { double tempEps = ( DBL_EPSILON ) *
128.0 ; double localEps = tempEps * muDoubleScalarAbs ( tBuf [ i ] ) ; if (
tempEps > localEps ) { localEps = tempEps ; } localEps = localEps / 2.0 ; if
( tMinusDelay >= ( tBuf [ i ] - localEps ) ) { yout = uBuf [ i ] ; } else {
if ( i == 0 ) { yout = uBuf [ bufSz - 1 ] ; } else { yout = uBuf [ i - 1 ] ;
} } } else { if ( i == 0 ) { t1 = tBuf [ bufSz - 1 ] ; u1 = uBuf [ bufSz - 1
] ; } else { t1 = tBuf [ i - 1 ] ; u1 = uBuf [ i - 1 ] ; } t2 = tBuf [ i ] ;
u2 = uBuf [ i ] ; if ( t2 == t1 ) { if ( tMinusDelay >= t2 ) { yout = u2 ; }
else { yout = u1 ; } } else { real_T f1 = ( t2 - tMinusDelay ) / ( t2 - t1 )
; real_T f2 = 1.0 - f1 ; yout = f1 * u1 + f2 * u2 ; } } return ( yout ) ; }
static void mdlOutputs ( SimStruct * S , int_T tid ) { real_T gn4om3c2wz ;
real_T gd0x2m2o3c ; real_T tmpForInput [ 12 ] ; int32_T i ; real_T fzcghlzsi3
; real_T b34y54l11z ; real_T tmp [ 2 ] ; real_T tmp_p [ 2 ] ; cdwhiznj1h *
_rtB ; p223m0sdck * _rtP ; f0dojttfnt * _rtX ; nroohmofnr * _rtDW ; _rtDW = (
( nroohmofnr * ) ssGetRootDWork ( S ) ) ; _rtX = ( ( f0dojttfnt * )
ssGetContStates ( S ) ) ; _rtP = ( ( p223m0sdck * ) ssGetModelRtp ( S ) ) ;
_rtB = ( ( cdwhiznj1h * ) _ssGetModelBlockIO ( S ) ) ; gd0x2m2o3c = _rtP ->
P_5 * _rtX -> jnwja2rwxg + _rtB -> gtfkbdikv0 ; _rtB -> gpmtmjom0j = _rtP ->
P_6 * gd0x2m2o3c * _rtP -> P_7 ; _rtB -> kg230gym2k = ( _rtB -> gpmtmjom0j -
_rtB -> kjdhgk3pqh ) * _rtB -> jpwynbz12r ; _rtB -> frxnysql00 = _rtB ->
pwu1itq5mx - _rtB -> kg230gym2k ; _rtB -> f3kcnsclcd = _rtB -> kjdhgk3pqh -
_rtB -> gpmtmjom0j ; _rtB -> gnmqs1ydch = _rtB -> gpmtmjom0j - _rtB ->
la2gnlo0b1 ; if ( ssIsMajorTimeStep ( S ) ) { _rtDW -> mekpt2vbtz = ( _rtB ->
gnmqs1ydch > _rtP -> P_10 ) ; _rtDW -> kblyau214x = ( _rtB -> f3kcnsclcd >
_rtP -> P_11 ) ; } if ( _rtDW -> mekpt2vbtz ) { _rtB -> etanclxwy1 = _rtB ->
pwu1itq5mx - ( _rtB -> gpmtmjom0j - _rtB -> la2gnlo0b1 ) * _rtB -> gvxe2dpqac
; _rtB -> g3nnfm3hhm = _rtB -> etanclxwy1 ; } else { _rtB -> g3nnfm3hhm =
_rtB -> pwu1itq5mx ; } if ( _rtDW -> kblyau214x ) { _rtB -> cgvclqphnb = _rtB
-> frxnysql00 ; } else { _rtB -> cgvclqphnb = _rtB -> g3nnfm3hhm ; }
ssCallAccelRunBlock ( S , 6 , 18 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 19 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 20 , SS_CALL_MDL_OUTPUTS ) ; if ( ssIsSampleHit
( S , 1 , 0 ) ) { _rtDW -> mawsw0wipq = ( ssGetTaskTime ( S , 1 ) >= _rtP ->
P_12 ) ; if ( _rtDW -> mawsw0wipq == 1 ) { _rtB -> j4udpgdqn2 = _rtP -> P_14
; } else { _rtB -> j4udpgdqn2 = _rtP -> P_13 ; } } ssCallAccelRunBlock ( S ,
6 , 22 , SS_CALL_MDL_OUTPUTS ) ; ssCallAccelRunBlock ( S , 6 , 23 ,
SS_CALL_MDL_OUTPUTS ) ; _rtB -> fzigvt5fm5 = 0.0 ; _rtB -> fzigvt5fm5 += _rtP
-> P_16 * _rtX -> nq50sgextr ; ssCallAccelRunBlock ( S , 6 , 25 ,
SS_CALL_MDL_OUTPUTS ) ; if ( ssIsSampleHit ( S , 2 , 0 ) ) {
ssCallAccelRunBlock ( S , 6 , 28 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 30 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 32 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 34 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 36 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 38 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 40 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 42 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 44 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 45 , SS_CALL_MDL_OUTPUTS ) ; tmpForInput [ 0 ]
= _rtB -> jnmyxd4hto ; tmpForInput [ 1 ] = _rtB -> ddar50xq1h ; tmpForInput [
2 ] = _rtB -> ecccz0gtmv ; tmpForInput [ 3 ] = _rtB -> atc5cy1bos ;
tmpForInput [ 4 ] = _rtB -> pd3ojie4co ; tmpForInput [ 5 ] = _rtB ->
iov2omglye ; tmpForInput [ 6 ] = _rtB -> lyewastlme ; tmpForInput [ 7 ] =
_rtB -> hi3bv243lx ; tmpForInput [ 8 ] = _rtB -> kmvjycboaq ; tmpForInput [ 9
] = _rtB -> fktypwj0jf ; tmpForInput [ 10 ] = _rtB -> gssoyguhhp ;
tmpForInput [ 11 ] = _rtB -> aau0xgkyk3 ; fzcghlzsi3 = _rtB -> jnmyxd4hto ;
for ( i = 0 ; i < 11 ; i ++ ) { fzcghlzsi3 += tmpForInput [ i + 1 ] ; } _rtB
-> piwhvvinfa = fzcghlzsi3 ; _rtB -> mketcpinsy = _rtB -> e55gysnzqf * _rtB
-> piwhvvinfa * _rtP -> P_30 ; } { real_T * * uBuffer = ( real_T * * ) &
_rtDW -> f1235sorac . TUbufferPtrs [ 0 ] ; real_T * * tBuffer = ( real_T * *
) & _rtDW -> f1235sorac . TUbufferPtrs [ 1 ] ; real_T simTime = ssGetT ( S )
; real_T tMinusDelay = simTime - _rtP -> P_31 ; gn4om3c2wz =
HEMS_v1_acc_rt_TDelayInterpolate ( tMinusDelay , 0.0 , * tBuffer , * uBuffer
, _rtDW -> cgjcxlp4lt . CircularBufSize , & _rtDW -> cgjcxlp4lt . Last ,
_rtDW -> cgjcxlp4lt . Tail , _rtDW -> cgjcxlp4lt . Head , _rtP -> P_32 , 0 ,
( boolean_T ) ( ssIsMinorTimeStep ( S ) && ( ssGetTimeOfLastOutput ( S ) ==
ssGetT ( S ) ) ) ) ; } _rtB -> bd5ehlnr3q = _rtB -> piwhvvinfa * gn4om3c2wz ;
if ( ssIsSampleHit ( S , 1 , 0 ) ) { if ( ssIsMajorTimeStep ( S ) ) { _rtDW
-> bbw411qcih = ( _rtB -> bd5ehlnr3q > _rtB -> mketcpinsy ) ; _rtDW ->
lmevb21n53 = ( _rtB -> bd5ehlnr3q < _rtB -> n0fafzjqng ) ; } _rtB ->
kytqslxi4u = _rtDW -> bbw411qcih ; _rtB -> n2dm3rouxu = _rtDW -> lmevb21n53 ;
} if ( _rtB -> kytqslxi4u ) { fzcghlzsi3 = _rtB -> mketcpinsy ; } else if (
_rtB -> n2dm3rouxu ) { fzcghlzsi3 = _rtB -> n0fafzjqng ; } else { fzcghlzsi3
= _rtB -> bd5ehlnr3q ; } _rtB -> dtue2rqiah = _rtP -> P_34 * fzcghlzsi3 ;
ssCallAccelRunBlock ( S , 6 , 60 , SS_CALL_MDL_OUTPUTS ) ; _rtB -> l12jfhtbfd
= _rtB -> jkqiwuzpsj - _rtB -> gpmtmjom0j ; _rtB -> bxhswymwff = 0.0 ; _rtB
-> bxhswymwff += _rtP -> P_38 * _rtX -> gjnaexioee ; _rtB -> m2wpweir3p =
_rtB -> jkqiwuzpsj - _rtB -> gpmtmjom0j ; if ( ssIsMajorTimeStep ( S ) ) {
_rtDW -> c5lnahf1b2 = ( _rtB -> m2wpweir3p > _rtP -> P_41 ) ; } if ( _rtDW ->
c5lnahf1b2 ) { _rtB -> kj03li55np = _rtB -> ovnbikxkdd ; } else { _rtB ->
kj03li55np = _rtB -> ostwljb1tq ; } _rtB -> jspp2znuqg = _rtB -> gpmtmjom0j -
_rtB -> hninavuazs ; if ( ssIsMajorTimeStep ( S ) ) { _rtDW -> par5zqfqi2 = (
_rtB -> jspp2znuqg > _rtP -> P_44 ) ; } if ( _rtDW -> par5zqfqi2 ) { _rtB ->
oxz2g2tlch = _rtB -> kj03li55np ; } else { _rtB -> oxz2g2tlch = _rtB ->
mavje20uca ; } if ( ssIsSampleHit ( S , 1 , 0 ) ) { _rtB -> bqvmk2q1qo =
_rtDW -> iij2b13kdq ; } if ( ssIsMajorTimeStep ( S ) ) { _rtDW -> ga1dovpgsw
= ( _rtB -> oxz2g2tlch > _rtP -> P_46 ) ; } if ( _rtDW -> ga1dovpgsw ) { _rtB
-> dgga4p5iyn = _rtB -> bxhswymwff ; } else { _rtB -> dgga4p5iyn = _rtB ->
bqvmk2q1qo ; } if ( ssIsMajorTimeStep ( S ) ) { b34y54l11z = _rtB ->
ndiis3qxlj ; _rtDW -> oqnvwpolab = 0 ; if ( _rtB -> dgga4p5iyn < _rtB ->
ndiis3qxlj ) { b34y54l11z = _rtB -> dgga4p5iyn ; _rtDW -> oqnvwpolab = 1 ; }
_rtB -> dkamuwlkkc = b34y54l11z ; _rtDW -> fopdtcrvj4 = ( _rtB -> l12jfhtbfd
> _rtP -> P_47 ) ; } else { tmp [ 0 ] = _rtB -> ndiis3qxlj ; tmp [ 1 ] = _rtB
-> dgga4p5iyn ; _rtB -> dkamuwlkkc = tmp [ _rtDW -> oqnvwpolab ] ; } if (
_rtDW -> fopdtcrvj4 ) { _rtB -> pn40zmai0u = _rtB -> ndiis3qxlj ; } else {
_rtB -> pn40zmai0u = _rtB -> dkamuwlkkc ; } _rtB -> fid4rd5wmy = _rtB ->
gpmtmjom0j - _rtB -> hninavuazs ; if ( ssIsMajorTimeStep ( S ) ) { _rtDW ->
pvxvhmkh1k = ( _rtB -> fid4rd5wmy > _rtP -> P_48 ) ; } if ( _rtDW ->
pvxvhmkh1k ) { _rtB -> mamesvalut = _rtB -> pn40zmai0u ; } else { _rtB ->
mamesvalut = _rtB -> dkamuwlkkc ; } if ( ssIsSampleHit ( S , 2 , 0 ) ) { _rtB
-> p1bbdaygle = _rtB -> mamesvalut ; } _rtB -> fevocrfqqu = _rtB ->
hninavuazs - _rtB -> gpmtmjom0j ; _rtB -> lyvoerxhuo = _rtB -> p1bbdaygle - (
_rtB -> gpmtmjom0j - _rtB -> jkqiwuzpsj ) * _rtB -> ozlegevot2 ; _rtB ->
ge335amkmt = _rtB -> gpmtmjom0j - _rtB -> jkqiwuzpsj ; if ( ssIsMajorTimeStep
( S ) ) { _rtDW -> fialaijjzy = ( _rtB -> ge335amkmt > _rtP -> P_51 ) ; _rtDW
-> bpq41od5z3 = ( _rtB -> fevocrfqqu > _rtP -> P_52 ) ; } if ( _rtDW ->
fialaijjzy ) { _rtB -> c5cde43kyf = _rtB -> lyvoerxhuo ; } else { _rtB ->
c5cde43kyf = _rtB -> p1bbdaygle ; } if ( _rtDW -> bpq41od5z3 ) { _rtB ->
pb0heui2n3 = _rtB -> p1bbdaygle - ( _rtB -> gpmtmjom0j - _rtB -> hninavuazs )
* _rtB -> keeas2b010 ; _rtB -> ivw1pj5nah = _rtB -> pb0heui2n3 ; } else {
_rtB -> ivw1pj5nah = _rtB -> c5cde43kyf ; } ssCallAccelRunBlock ( S , 6 , 90
, SS_CALL_MDL_OUTPUTS ) ; b34y54l11z = _rtB -> nz1pe5lnx3 - _rtB ->
bxhswymwff ; _rtB -> nm14zer215 = b34y54l11z - _rtB -> key3a4y2xm ; _rtB ->
cptym15qas = _rtB -> h4x0ptb43j * _rtB -> nm14zer215 + _rtB -> ozzt4w1fvm ;
if ( ssIsMajorTimeStep ( S ) ) { _rtDW -> i4fze2li0j = ( _rtB -> nm14zer215 >
_rtP -> P_56 ) ; } if ( _rtDW -> i4fze2li0j ) { _rtB -> g0lecbvjue = _rtB ->
cptym15qas ; } else { _rtB -> g0lecbvjue = _rtB -> ozzt4w1fvm ; } _rtB ->
ogm1md4gl0 = _rtB -> pyxygkchsz - b34y54l11z ; if ( ssIsMajorTimeStep ( S ) )
{ _rtDW -> mv3j500a1h = ( _rtB -> ogm1md4gl0 > _rtP -> P_58 ) ; } if ( _rtDW
-> mv3j500a1h ) { _rtB -> linmtcmkbc = _rtB -> g0lecbvjue ; } else { _rtB ->
linmtcmkbc = _rtB -> cdrkdocned ; } if ( ssIsSampleHit ( S , 2 , 0 ) ) { _rtB
-> es4zscs52p = _rtB -> linmtcmkbc ; ssCallAccelRunBlock ( S , 6 , 106 ,
SS_CALL_MDL_OUTPUTS ) ; } ssCallAccelRunBlock ( S , 6 , 107 ,
SS_CALL_MDL_OUTPUTS ) ; if ( ssIsSampleHit ( S , 1 , 0 ) ) { _rtDW ->
ot3m5z4v0x = ( ssGetTaskTime ( S , 1 ) >= _rtP -> P_59 ) ; if ( _rtDW ->
ot3m5z4v0x == 1 ) { _rtB -> pi5pwvckbo = _rtP -> P_61 ; } else { _rtB ->
pi5pwvckbo = _rtP -> P_60 ; } } ssCallAccelRunBlock ( S , 6 , 109 ,
SS_CALL_MDL_OUTPUTS ) ; ssCallAccelRunBlock ( S , 6 , 110 ,
SS_CALL_MDL_OUTPUTS ) ; if ( ssIsSampleHit ( S , 2 , 0 ) ) {
ssCallAccelRunBlock ( S , 6 , 111 , SS_CALL_MDL_OUTPUTS ) ; } _rtB ->
b5hdtegsex = _rtB -> dtue2rqiah / _rtB -> piwhvvinfa * _rtP -> P_62 ;
ssCallAccelRunBlock ( S , 6 , 114 , SS_CALL_MDL_OUTPUTS ) ; _rtB ->
m20y0zf3fg = ( _rtB -> hdy4jsoy0z - _rtX -> i51cq0dkv3 ) * _rtP -> P_67 *
_rtP -> P_68 ; if ( ssIsMajorTimeStep ( S ) ) { _rtDW -> lkqdm1kqnl = _rtB ->
m20y0zf3fg >= _rtP -> P_69 ? 1 : _rtB -> m20y0zf3fg > _rtP -> P_70 ? 0 : - 1
; } _rtB -> grme0uabjy = _rtDW -> lkqdm1kqnl == 1 ? _rtP -> P_69 : _rtDW ->
lkqdm1kqnl == - 1 ? _rtP -> P_70 : _rtB -> m20y0zf3fg ; ssCallAccelRunBlock (
S , 6 , 123 , SS_CALL_MDL_OUTPUTS ) ; if ( ssIsSampleHit ( S , 2 , 0 ) ) {
_rtB -> djpdizpfkl = _rtP -> P_71 * _rtB -> piwhvvinfa ; } b34y54l11z = _rtP
-> P_73 * _rtX -> nfvcw2iv0m ; _rtB -> mzjnem3qio = _rtP -> P_74 * b34y54l11z
+ _rtP -> P_76 * _rtX -> nqhjedbzwc ; if ( ssIsSampleHit ( S , 1 , 0 ) ) { if
( ssIsMajorTimeStep ( S ) ) { _rtDW -> ccuutqkmvx = ( _rtB -> mzjnem3qio >
_rtB -> djpdizpfkl ) ; _rtDW -> bvmfbs53gp = ( _rtB -> mzjnem3qio < _rtB ->
nnwsloin3y ) ; } _rtB -> fye1ipii2x = _rtDW -> ccuutqkmvx ; _rtB ->
nzlx2yjosi = _rtDW -> bvmfbs53gp ; } if ( _rtB -> fye1ipii2x ) { _rtB ->
fhrmnbyaiy = _rtB -> djpdizpfkl ; } else if ( _rtB -> nzlx2yjosi ) { _rtB ->
fhrmnbyaiy = _rtB -> nnwsloin3y ; } else { _rtB -> fhrmnbyaiy = _rtB ->
mzjnem3qio ; } ssCallAccelRunBlock ( S , 6 , 134 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 135 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 136 , SS_CALL_MDL_OUTPUTS ) ; _rtB ->
mz53fsfqep = ( _rtB -> nz1pe5lnx3 - _rtB -> fzigvt5fm5 ) - _rtB -> bxhswymwff
; ssCallAccelRunBlock ( S , 6 , 138 , SS_CALL_MDL_OUTPUTS ) ; if (
ssIsSampleHit ( S , 2 , 0 ) ) { ssCallAccelRunBlock ( S , 6 , 139 ,
SS_CALL_MDL_OUTPUTS ) ; ssCallAccelRunBlock ( S , 6 , 140 ,
SS_CALL_MDL_OUTPUTS ) ; } if ( ssIsMajorTimeStep ( S ) ) { _rtDW ->
eq00usoq2u = _rtB -> cgvclqphnb >= _rtP -> P_78 ? 1 : _rtB -> cgvclqphnb >
_rtP -> P_79 ? 0 : - 1 ; } _rtB -> c0kpd4dnlq = _rtDW -> eq00usoq2u == 1 ?
_rtP -> P_78 : _rtDW -> eq00usoq2u == - 1 ? _rtP -> P_79 : _rtB -> cgvclqphnb
; if ( ssIsMajorTimeStep ( S ) ) { _rtDW -> nqy040hn30 = _rtB -> c0kpd4dnlq
>= _rtP -> P_80 ? 1 : _rtB -> c0kpd4dnlq > _rtP -> P_81 ? 0 : - 1 ; _rtDW ->
eyri3x40yg = ( _rtB -> grme0uabjy > _rtP -> P_82 ) ; } _rtB -> bkuyvt1zbq =
_rtDW -> nqy040hn30 == 1 ? _rtP -> P_80 : _rtDW -> nqy040hn30 == - 1 ? _rtP
-> P_81 : _rtB -> c0kpd4dnlq ; if ( _rtDW -> eyri3x40yg ) { _rtB ->
lgfcdjl3ff = _rtB -> c0kpd4dnlq ; } else { _rtB -> lgfcdjl3ff = _rtB ->
bkuyvt1zbq ; } if ( ssIsMajorTimeStep ( S ) ) { _rtDW -> k0hk1stcpf = _rtB ->
lgfcdjl3ff >= _rtP -> P_83 ? 1 : _rtB -> lgfcdjl3ff > _rtP -> P_84 ? 0 : - 1
; _rtDW -> ifp5lfxwsx = ( _rtB -> grme0uabjy >= _rtP -> P_85 ) ; } _rtB ->
erjl4cdmk3 = _rtDW -> k0hk1stcpf == 1 ? _rtP -> P_83 : _rtDW -> k0hk1stcpf ==
- 1 ? _rtP -> P_84 : _rtB -> lgfcdjl3ff ; if ( _rtDW -> ifp5lfxwsx ) { _rtB
-> im43bob1pi = _rtB -> erjl4cdmk3 ; } else { _rtB -> im43bob1pi = _rtB ->
lgfcdjl3ff ; } ssCallAccelRunBlock ( S , 6 , 146 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 147 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 148 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 149 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 150 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 151 , SS_CALL_MDL_OUTPUTS ) ; if (
ssIsSampleHit ( S , 1 , 0 ) ) { ssCallAccelRunBlock ( S , 6 , 152 ,
SS_CALL_MDL_OUTPUTS ) ; ssCallAccelRunBlock ( S , 6 , 153 ,
SS_CALL_MDL_OUTPUTS ) ; } ssCallAccelRunBlock ( S , 6 , 154 ,
SS_CALL_MDL_OUTPUTS ) ; ssCallAccelRunBlock ( S , 6 , 155 ,
SS_CALL_MDL_OUTPUTS ) ; ssCallAccelRunBlock ( S , 6 , 156 ,
SS_CALL_MDL_OUTPUTS ) ; _rtB -> eueicpujlu = ( _rtB -> g0hijbe21f - _rtB ->
gpmtmjom0j ) * _rtP -> P_87 ; _rtB -> cwjrav1unz = ( _rtB -> fhrmnbyaiy -
_rtB -> mzjnem3qio ) * _rtP -> P_89 + _rtP -> P_88 * b34y54l11z ; if (
ssIsSampleHit ( S , 2 , 0 ) ) { ssCallAccelRunBlock ( S , 6 , 164 ,
SS_CALL_MDL_OUTPUTS ) ; } _rtB -> ilxvrxnuwn = _rtP -> P_90 * _rtB ->
fhrmnbyaiy ; ssCallAccelRunBlock ( S , 6 , 166 , SS_CALL_MDL_OUTPUTS ) ; if (
ssIsSampleHit ( S , 2 , 0 ) ) { _rtB -> hwbxhxcrlo = _rtB -> ak1wljieek *
_rtB -> piwhvvinfa ; ssCallAccelRunBlock ( S , 6 , 169 , SS_CALL_MDL_OUTPUTS
) ; } if ( ssIsSampleHit ( S , 1 , 0 ) ) { if ( ssIsMajorTimeStep ( S ) ) {
_rtDW -> njeprxispt = ( _rtB -> ilxvrxnuwn > _rtB -> hwbxhxcrlo ) ; } _rtB ->
logzhdpkos = _rtDW -> njeprxispt ; } if ( ssIsSampleHit ( S , 2 , 0 ) ) {
_rtB -> ncy0wstgbj = _rtB -> hwbxhxcrlo * _rtB -> cr2x5evw4s ; } if (
ssIsSampleHit ( S , 1 , 0 ) ) { if ( ssIsMajorTimeStep ( S ) ) { _rtDW ->
i0fptdxivj = ( _rtB -> ilxvrxnuwn < _rtB -> ncy0wstgbj ) ; } _rtB ->
clj2iyn0wm = _rtDW -> i0fptdxivj ; } if ( _rtB -> logzhdpkos ) { _rtB ->
f2coytczc1 = _rtB -> hwbxhxcrlo ; } else if ( _rtB -> clj2iyn0wm ) { _rtB ->
f2coytczc1 = _rtB -> ncy0wstgbj ; } else { _rtB -> f2coytczc1 = _rtB ->
ilxvrxnuwn ; } ssCallAccelRunBlock ( S , 6 , 176 , SS_CALL_MDL_OUTPUTS ) ;
_rtB -> fkx2evmi1i = _rtP -> P_94 * _rtB -> f2coytczc1 ; _rtB -> jk0o4l0a4g =
( ( fzcghlzsi3 - _rtP -> P_93 * _rtB -> mz53fsfqep ) - _rtP -> P_95 *
gd0x2m2o3c * _rtB -> piwhvvinfa ) * ( 1.0 / _rtB -> piwhvvinfa ) ; _rtB ->
omwtsuwqzf = 0.0 ; _rtB -> omwtsuwqzf += _rtP -> P_98 * _rtX -> jenjri3d2q ;
_rtB -> f5okhq4iv4 = 0.0 ; _rtB -> f5okhq4iv4 += _rtP -> P_100 * _rtB ->
omwtsuwqzf ; ssCallAccelRunBlock ( S , 6 , 186 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 187 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 188 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 189 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 190 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 191 , SS_CALL_MDL_OUTPUTS ) ; if (
ssIsMajorTimeStep ( S ) ) { b34y54l11z = _rtB -> b0vgi3txgc ; _rtDW ->
izlhbrja4m = 0 ; if ( _rtB -> fu0awt1dxv < _rtB -> b0vgi3txgc ) { b34y54l11z
= _rtB -> fu0awt1dxv ; _rtDW -> izlhbrja4m = 1 ; } _rtB -> f0cqbyrxpg =
b34y54l11z ; } else { tmp_p [ 0 ] = _rtB -> b0vgi3txgc ; tmp_p [ 1 ] = _rtB
-> fu0awt1dxv ; _rtB -> f0cqbyrxpg = tmp_p [ _rtDW -> izlhbrja4m ] ; } if (
ssIsSampleHit ( S , 1 , 0 ) ) { if ( ssIsMajorTimeStep ( S ) ) { _rtDW ->
fpok2lcutf = ( _rtB -> ivw1pj5nah > _rtB -> f0cqbyrxpg ) ; _rtDW ->
bs2rzcvll0 = ( _rtB -> ivw1pj5nah < _rtB -> cn2aql3lge ) ; } _rtB ->
pttmav2ame = _rtDW -> fpok2lcutf ; _rtB -> kimksfov0q = _rtDW -> bs2rzcvll0 ;
} if ( _rtB -> pttmav2ame ) { _rtB -> eoz01owipv = _rtB -> f0cqbyrxpg ; }
else if ( _rtB -> kimksfov0q ) { _rtB -> eoz01owipv = _rtB -> cn2aql3lge ; }
else { _rtB -> eoz01owipv = _rtB -> ivw1pj5nah ; } ssCallAccelRunBlock ( S ,
6 , 199 , SS_CALL_MDL_OUTPUTS ) ; ssCallAccelRunBlock ( S , 6 , 200 ,
SS_CALL_MDL_OUTPUTS ) ; if ( ssIsSampleHit ( S , 1 , 0 ) ) {
ssCallAccelRunBlock ( S , 6 , 201 , SS_CALL_MDL_OUTPUTS ) ; }
ssCallAccelRunBlock ( S , 6 , 202 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 203 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 204 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 205 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 6 , 206 , SS_CALL_MDL_OUTPUTS ) ; if (
ssIsSampleHit ( S , 2 , 0 ) ) { ssCallAccelRunBlock ( S , 6 , 207 ,
SS_CALL_MDL_OUTPUTS ) ; } UNUSED_PARAMETER ( tid ) ; } static void
mdlOutputsTID3 ( SimStruct * S , int_T tid ) { cdwhiznj1h * _rtB ; p223m0sdck
* _rtP ; _rtP = ( ( p223m0sdck * ) ssGetModelRtp ( S ) ) ; _rtB = ( (
cdwhiznj1h * ) _ssGetModelBlockIO ( S ) ) ; _rtB -> pwu1itq5mx = _rtP -> P_0
; _rtB -> jpwynbz12r = _rtP -> P_1 ; _rtB -> kjdhgk3pqh = _rtP -> P_2 ; _rtB
-> gtfkbdikv0 = _rtP -> P_3 ; _rtB -> gvxe2dpqac = _rtP -> P_8 ; _rtB ->
la2gnlo0b1 = _rtP -> P_9 ; _rtB -> e55gysnzqf = _rtP -> P_17 ; _rtB ->
mcctdf2403 = _rtP -> P_18 ; _rtB -> bagdu0b31r = _rtP -> P_19 ; _rtB ->
prummjnuj1 = _rtP -> P_20 ; _rtB -> dfu4p15aky = _rtP -> P_21 ; _rtB ->
f3c5huxwxf = _rtP -> P_22 ; _rtB -> nztol4et1c = _rtP -> P_23 ; _rtB ->
lqq5ngguxd = _rtP -> P_24 ; _rtB -> gkertcmlkl = _rtP -> P_25 ; _rtB ->
hkh4i3mfij = _rtP -> P_26 ; _rtB -> fktypwj0jf = _rtP -> P_27 ; _rtB ->
gssoyguhhp = _rtP -> P_28 ; _rtB -> aau0xgkyk3 = _rtP -> P_29 ; _rtB ->
n0fafzjqng = _rtP -> P_33 ; _rtB -> ndiis3qxlj = _rtP -> P_35 ; _rtB ->
jkqiwuzpsj = _rtP -> P_36 ; _rtB -> ovnbikxkdd = _rtP -> P_39 ; _rtB ->
ostwljb1tq = _rtP -> P_40 ; _rtB -> hninavuazs = _rtP -> P_42 ; _rtB ->
mavje20uca = _rtP -> P_43 ; _rtB -> keeas2b010 = _rtP -> P_49 ; _rtB ->
ozlegevot2 = _rtP -> P_50 ; _rtB -> h4x0ptb43j = _rtP -> P_53 ; _rtB ->
key3a4y2xm = _rtP -> P_54 ; _rtB -> ozzt4w1fvm = _rtP -> P_55 ; _rtB ->
pyxygkchsz = _rtP -> P_57 ; _rtB -> cdrkdocned = ( _rtB -> pyxygkchsz - _rtB
-> key3a4y2xm ) * _rtB -> h4x0ptb43j + _rtB -> ozzt4w1fvm ; _rtB ->
hdy4jsoy0z = _rtP -> P_65 * _rtP -> P_64 * _rtP -> P_66 ; _rtB -> nnwsloin3y
= _rtP -> P_77 ; _rtB -> g0hijbe21f = _rtP -> P_86 ; _rtB -> ak1wljieek =
_rtP -> P_91 ; _rtB -> cr2x5evw4s = _rtP -> P_92 ; _rtB -> b0vgi3txgc = _rtP
-> P_102 ; _rtB -> cn2aql3lge = _rtP -> P_103 ; UNUSED_PARAMETER ( tid ) ; }
#define MDL_UPDATE
static void mdlUpdate ( SimStruct * S , int_T tid ) { cdwhiznj1h * _rtB ;
p223m0sdck * _rtP ; nroohmofnr * _rtDW ; _rtDW = ( ( nroohmofnr * )
ssGetRootDWork ( S ) ) ; _rtP = ( ( p223m0sdck * ) ssGetModelRtp ( S ) ) ;
_rtB = ( ( cdwhiznj1h * ) _ssGetModelBlockIO ( S ) ) ; if ( ssIsSampleHit ( S
, 2 , 0 ) ) { } { real_T * * uBuffer = ( real_T * * ) & _rtDW -> f1235sorac .
TUbufferPtrs [ 0 ] ; real_T * * tBuffer = ( real_T * * ) & _rtDW ->
f1235sorac . TUbufferPtrs [ 1 ] ; real_T simTime = ssGetT ( S ) ; _rtDW ->
cgjcxlp4lt . Head = ( ( _rtDW -> cgjcxlp4lt . Head < ( _rtDW -> cgjcxlp4lt .
CircularBufSize - 1 ) ) ? ( _rtDW -> cgjcxlp4lt . Head + 1 ) : 0 ) ; if (
_rtDW -> cgjcxlp4lt . Head == _rtDW -> cgjcxlp4lt . Tail ) { if ( !
HEMS_v1_acc_rt_TDelayUpdateTailOrGrowBuf ( & _rtDW -> cgjcxlp4lt .
CircularBufSize , & _rtDW -> cgjcxlp4lt . Tail , & _rtDW -> cgjcxlp4lt . Head
, & _rtDW -> cgjcxlp4lt . Last , simTime - _rtP -> P_31 , tBuffer , uBuffer ,
( NULL ) , ( boolean_T ) 0 , false , & _rtDW -> cgjcxlp4lt . MaxNewBufSize )
) { ssSetErrorStatus ( S , "tdelay memory allocation error" ) ; return ; } }
( * tBuffer ) [ _rtDW -> cgjcxlp4lt . Head ] = simTime ; ( * uBuffer ) [
_rtDW -> cgjcxlp4lt . Head ] = _rtB -> f5okhq4iv4 ; } if ( ssIsSampleHit ( S
, 1 , 0 ) ) { _rtDW -> iij2b13kdq = _rtB -> dgga4p5iyn ; } UNUSED_PARAMETER (
tid ) ; }
#define MDL_UPDATE
static void mdlUpdateTID3 ( SimStruct * S , int_T tid ) { UNUSED_PARAMETER (
tid ) ; }
#define MDL_DERIVATIVES
static void mdlDerivatives ( SimStruct * S ) { cdwhiznj1h * _rtB ; p223m0sdck
* _rtP ; f0dojttfnt * _rtX ; ivmlifeye1 * _rtXdot ; nroohmofnr * _rtDW ;
_rtDW = ( ( nroohmofnr * ) ssGetRootDWork ( S ) ) ; _rtXdot = ( ( ivmlifeye1
* ) ssGetdX ( S ) ) ; _rtX = ( ( f0dojttfnt * ) ssGetContStates ( S ) ) ;
_rtP = ( ( p223m0sdck * ) ssGetModelRtp ( S ) ) ; _rtB = ( ( cdwhiznj1h * )
_ssGetModelBlockIO ( S ) ) ; _rtXdot -> jnwja2rwxg = 0.0 ; _rtXdot ->
jnwja2rwxg += _rtP -> P_4 * _rtX -> jnwja2rwxg ; _rtXdot -> jnwja2rwxg +=
_rtB -> jk0o4l0a4g ; _rtXdot -> nq50sgextr = 0.0 ; _rtXdot -> nq50sgextr +=
_rtP -> P_15 * _rtX -> nq50sgextr ; _rtXdot -> nq50sgextr += _rtB ->
im43bob1pi ; _rtXdot -> gjnaexioee = 0.0 ; _rtXdot -> gjnaexioee += _rtP ->
P_37 * _rtX -> gjnaexioee ; _rtXdot -> gjnaexioee += _rtB -> eoz01owipv ;
_rtXdot -> i51cq0dkv3 = _rtB -> fzigvt5fm5 ; _rtXdot -> nfvcw2iv0m = 0.0 ;
_rtXdot -> nfvcw2iv0m += _rtP -> P_72 * _rtX -> nfvcw2iv0m ; _rtXdot ->
nfvcw2iv0m += _rtB -> eueicpujlu ; _rtXdot -> nqhjedbzwc = 0.0 ; _rtXdot ->
nqhjedbzwc += _rtP -> P_75 * _rtX -> nqhjedbzwc ; _rtXdot -> nqhjedbzwc +=
_rtB -> cwjrav1unz ; _rtXdot -> jenjri3d2q = 0.0 ; _rtXdot -> jenjri3d2q +=
_rtP -> P_96 * _rtX -> jenjri3d2q ; _rtXdot -> jenjri3d2q += _rtP -> P_97 *
_rtB -> fkx2evmi1i ; }
#define MDL_ZERO_CROSSINGS
static void mdlZeroCrossings ( SimStruct * S ) { real_T tmp [ 2 ] ; real_T
tmp_p [ 2 ] ; cdwhiznj1h * _rtB ; p223m0sdck * _rtP ; lz35qxwi3m * _rtZCSV ;
nroohmofnr * _rtDW ; _rtDW = ( ( nroohmofnr * ) ssGetRootDWork ( S ) ) ;
_rtZCSV = ( ( lz35qxwi3m * ) ssGetSolverZcSignalVector ( S ) ) ; _rtP = ( (
p223m0sdck * ) ssGetModelRtp ( S ) ) ; _rtB = ( ( cdwhiznj1h * )
_ssGetModelBlockIO ( S ) ) ; _rtZCSV -> hpllyiqrt1 = _rtB -> gnmqs1ydch -
_rtP -> P_10 ; _rtZCSV -> hif5fqudeo = _rtB -> f3kcnsclcd - _rtP -> P_11 ;
_rtZCSV -> lwrquavdl1 = ssGetT ( S ) - _rtP -> P_12 ; _rtZCSV -> ioxyx5ogvp =
_rtB -> bd5ehlnr3q - _rtB -> mketcpinsy ; _rtZCSV -> hugjvavxzp = _rtB ->
bd5ehlnr3q - _rtB -> n0fafzjqng ; _rtZCSV -> kwwxpeccz5 = _rtB -> m2wpweir3p
- _rtP -> P_41 ; _rtZCSV -> hzrjnrzev1 = _rtB -> jspp2znuqg - _rtP -> P_44 ;
_rtZCSV -> gmjko3mdpx = _rtB -> oxz2g2tlch - _rtP -> P_46 ; tmp [ 0 ] = _rtB
-> ndiis3qxlj ; tmp [ 1 ] = _rtB -> dgga4p5iyn ; _rtZCSV -> ljvzsp3bhz =
muDoubleScalarMin ( _rtB -> dgga4p5iyn , _rtB -> ndiis3qxlj ) - tmp [ _rtDW
-> oqnvwpolab ] ; _rtZCSV -> fammfc51vm = _rtB -> l12jfhtbfd - _rtP -> P_47 ;
_rtZCSV -> omf0yspzfm = _rtB -> fid4rd5wmy - _rtP -> P_48 ; _rtZCSV ->
lwvowe2wmm = _rtB -> ge335amkmt - _rtP -> P_51 ; _rtZCSV -> ppel4ov5pj = _rtB
-> fevocrfqqu - _rtP -> P_52 ; _rtZCSV -> lgdrifiaoq = _rtB -> nm14zer215 -
_rtP -> P_56 ; _rtZCSV -> gawoht4fjf = _rtB -> ogm1md4gl0 - _rtP -> P_58 ;
_rtZCSV -> l2isjsg2jm = ssGetT ( S ) - _rtP -> P_59 ; _rtZCSV -> p1faudjfed =
_rtB -> m20y0zf3fg - _rtP -> P_69 ; _rtZCSV -> ngz3fvaty0 = _rtB ->
m20y0zf3fg - _rtP -> P_70 ; _rtZCSV -> aikipad0my = _rtB -> mzjnem3qio - _rtB
-> djpdizpfkl ; _rtZCSV -> my3u5il1en = _rtB -> mzjnem3qio - _rtB ->
nnwsloin3y ; _rtZCSV -> pmkdy2mz0s = _rtB -> cgvclqphnb - _rtP -> P_78 ;
_rtZCSV -> hm2fhsoicb = _rtB -> cgvclqphnb - _rtP -> P_79 ; _rtZCSV ->
a2xlkx1545 = _rtB -> c0kpd4dnlq - _rtP -> P_80 ; _rtZCSV -> f21ec23dth = _rtB
-> c0kpd4dnlq - _rtP -> P_81 ; _rtZCSV -> k5b5tak1lk = _rtB -> grme0uabjy -
_rtP -> P_82 ; _rtZCSV -> bh0rrfn5aa = _rtB -> lgfcdjl3ff - _rtP -> P_83 ;
_rtZCSV -> b3nqravenj = _rtB -> lgfcdjl3ff - _rtP -> P_84 ; _rtZCSV ->
pdmosgohlb = _rtB -> grme0uabjy - _rtP -> P_85 ; _rtZCSV -> gd4kiu5rur = _rtB
-> ilxvrxnuwn - _rtB -> hwbxhxcrlo ; _rtZCSV -> e1ormy2u14 = _rtB ->
ilxvrxnuwn - _rtB -> ncy0wstgbj ; tmp_p [ 0 ] = _rtB -> b0vgi3txgc ; tmp_p [
1 ] = _rtB -> fu0awt1dxv ; _rtZCSV -> p0u3ocrpac = muDoubleScalarMin ( _rtB
-> fu0awt1dxv , _rtB -> b0vgi3txgc ) - tmp_p [ _rtDW -> izlhbrja4m ] ;
_rtZCSV -> ol11wqsv4y = _rtB -> ivw1pj5nah - _rtB -> f0cqbyrxpg ; _rtZCSV ->
fqhmvousri = _rtB -> ivw1pj5nah - _rtB -> cn2aql3lge ; } static void
mdlInitializeSizes ( SimStruct * S ) { ssSetChecksumVal ( S , 0 , 1260787738U
) ; ssSetChecksumVal ( S , 1 , 3759089553U ) ; ssSetChecksumVal ( S , 2 ,
3248965549U ) ; ssSetChecksumVal ( S , 3 , 4189379001U ) ; { mxArray *
slVerStructMat = NULL ; mxArray * slStrMat = mxCreateString ( "simulink" ) ;
char slVerChar [ 10 ] ; int status = mexCallMATLAB ( 1 , & slVerStructMat , 1
, & slStrMat , "ver" ) ; if ( status == 0 ) { mxArray * slVerMat = mxGetField
( slVerStructMat , 0 , "Version" ) ; if ( slVerMat == NULL ) { status = 1 ; }
else { status = mxGetString ( slVerMat , slVerChar , 10 ) ; } }
mxDestroyArray ( slStrMat ) ; mxDestroyArray ( slVerStructMat ) ; if ( (
status == 1 ) || ( strcmp ( slVerChar , "8.7" ) != 0 ) ) { return ; } }
ssSetOptions ( S , SS_OPTION_EXCEPTION_FREE_CODE ) ; if ( ssGetSizeofDWork (
S ) != sizeof ( nroohmofnr ) ) { ssSetErrorStatus ( S ,
"Unexpected error: Internal DWork sizes do "
"not match for accelerator mex file." ) ; } if ( ssGetSizeofGlobalBlockIO ( S
) != sizeof ( cdwhiznj1h ) ) { ssSetErrorStatus ( S ,
"Unexpected error: Internal BlockIO sizes do "
"not match for accelerator mex file." ) ; } { int ssSizeofParams ;
ssGetSizeofParams ( S , & ssSizeofParams ) ; if ( ssSizeofParams != sizeof (
p223m0sdck ) ) { static char msg [ 256 ] ; sprintf ( msg ,
"Unexpected error: Internal Parameters sizes do "
"not match for accelerator mex file." ) ; } } _ssSetModelRtp ( S , ( real_T *
) & gr2j4ojiru ) ; rt_InitInfAndNaN ( sizeof ( real_T ) ) ; ( ( p223m0sdck *
) ssGetModelRtp ( S ) ) -> P_81 = rtMinusInf ; ( ( p223m0sdck * )
ssGetModelRtp ( S ) ) -> P_83 = rtInf ; } static void
mdlInitializeSampleTimes ( SimStruct * S ) { slAccRegPrmChangeFcn ( S ,
mdlOutputsTID3 ) ; } static void mdlTerminate ( SimStruct * S ) { }
#include "simulink.c"
