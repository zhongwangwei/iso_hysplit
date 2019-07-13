#!/bin/bash
simdir=$1
obsdir=$2
site=$3
SYEAR=$4
SMONTH=$5
SDAY=$6
SHOUR=$7
EYEAR=$8
EMONTH=$9
EDAY=${10}
EHOUR=${11}
#if [[ "${site}" == "Mase" ]]; then
#from AM7-PM7
#Sdaytime=
#Edaytime=
#elif [[ "${site}" == "Luancheng" ]]; then
#Sdaytime=
#Edaytime=
#elif [[ "${site}" == "NewHaven" ]]; then
#Sdaytime=
#Edaytime=
#fi


sh Bin_mat.sh
cat <<EOF > gdas_step4.m
clear
%load('${simdir}/Land_sea_${site}.mat')
load('${obsdir}/${site}_obs.mat')
load('${simdir}/VAPDEX_simulated_${site}.mat')
load('${obsdir}/${site}_IsoGSM_UTC.mat')
%[Y,M,D,DEXobs_daily,DEX_std]=dailyaverage(Year(Hour>8&Hour<18),Month(Hour>8&Hour<18),Day(Hour>8&Hour<18),Hour(Hour>8&Hour<18),DEX(Hour>8&Hour<18))
DEX(DEX<0)=NaN;
DEX(DEX>35)=NaN;
SP(SP<0)=NaN;
SP(SP>30)=NaN;
for i=1:length(DEX)
if Rain(i)>0
 for j=-2:1:2
    DEX(i+j)=NaN;
 end
end
end
if Year(1)==2013
%DEX(Hour>=9&Hour<=21)=NaN;

elseif Year(1)==2007
%DEX(Hour<=1|Hour>19)=NaN;

elseif Year(1)==2008
 %DEX(Hour>=8&Hour<=22)=NaN;
end


[Y,M,D,DEXobs_daily]       = dailyweightaverage(Year,Month,Day,Hour,DEX,SP);
[YY,MM,DD,DEXisogsm_daily] = dailyweightaverage(Year_isogsm,Month_isogsm,Day_isogsm,Hour_isogsm,DEX_isogsm,Sp_isogsm);


Year_traj=Year_traj';
Month_traj=Month_traj';
Day_traj=Day_traj';
Hour_traj=Hour_traj';
x5=datenum($SYEAR, $SMONTH, $SDAY, $SHOUR, 0, 0);
x6=datenum($EYEAR, $EMONTH, $EDAY, $EHOUR, 0, 0);
x1 = datenum(Year_traj,Month_traj,Day_traj,Hour_traj,0,0);

x1_isogsm = datenum(YY,MM,DD,0,0,0);
DEXisogsm_daily=DEXisogsm_daily(find(x1_isogsm==x5):find(x1_isogsm==x6))';
x2 = datenum(Y,M,D,0,0,0);
%SPobs_daily=SPobs_daily(find(x2==x5):find(x2==x6),1);
DEXobs_daily=DEXobs_daily(find(x2==x5):find(x2==x6))';


dex_sst_only=dex_sst_only(find(x1==x5):find(x1==x6),:);
dex_sst_LAND=dex_sst_LAND(find(x1==x5):find(x1==x6),:);
Q_traj=Q_traj(find(x1==x5):find(x1==x6),1);

Y1=Year_traj(find(x1==x5):find(x1==x6),1);
M1=Month_traj(find(x1==x5):find(x1==x6),1);
D1=Day_traj(find(x1==x5):find(x1==x6),1);
H1=Hour_traj(find(x1==x5):find(x1==x6),1);

%[Y,M,D,Q_traj_daily,Q_traj_std]=dailyaverage(Y1,M1,D1,H1,Q_traj);

[best_R2,best_RMSD,sfc_mon,RMSD_all,R2_all,I_all,B_all,Y3,M3,D3,DEXtrace_day,sfc_day]=getbesttracer(Y1,M1,D1,H1,dex_sst_LAND,Q_land_f,Q_sea_f,DEXobs_daily,Q_traj);
EOF
