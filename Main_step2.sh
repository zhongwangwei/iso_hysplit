#!/bin/zsh
rm *.m

RunNO=6
site=Luancheng
#site=NewHaven
#site=Mase
DEX_est="../out/Senoria${RunNO}/${site}_DEX"
traj_dex="../run/Senoria${RunNO}/${site}_trajDEX"
obsdir="../../run/observation"
#sh BinScripts.sh
if [[ "${site}" == "Mase" ]]; then
    SYEAR=2013
    SMONTH=6
    SDAY=20
    SHOUR=0
    EYEAR=2014
    EMONTH=6
    EDAY=20
    EHOUR=0
elif [[ "${site}" == "Luancheng" ]]; then
    SYEAR=2008
    SMONTH=04
    SDAY=01
    SHOUR=0
    EYEAR=2008
    EMONTH=08
    EDAY=30
    EHOUR=0
elif [[ "${site}" == "NewHaven" ]]; then
    SYEAR=2007
    SMONTH=04
    SDAY=01
    SHOUR=0
    EYEAR=2008
    EMONTH=05
    EDAY=30
    EHOUR=0
fi
sh gdas_step3.sh ${traj_dex} ${site} $SYEAR $SMONTH $SDAY $SHOUR $EYEAR $EMONTH $EDAY $EHOUR
matlab -nodesktop -nosplash  -r "run ./gdas_step3.m;quit;"

sh gdas_step4.sh ${traj_dex} ${obsdir} ${site} $SYEAR $SMONTH $SDAY $SHOUR $EYEAR $EMONTH $EDAY $EHOUR
#matlab -nodesktop -nosplash  -r "run ./gdas_step4.m;quit;"
matlab   -r "run ./gdas_step4.m;"
