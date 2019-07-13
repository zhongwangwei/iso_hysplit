#!/bin/zsh
#-------------------------------------------------------------

rm *.nc SETUP.CFG *.m Datetime delta_q_ver *.CFG landmark newtime *.o temp temp* CONTROL MESSAGE
ifort times.f newtime.f -o newtime

# set default directory structure

MDL="/Applications/Hysplit4"    #Hysplit model directory; Indeed only 'hyts_std' is required
DEXSST="/Users/wei/OneDrive/2018/Vap-Dex/run/Sourcedata/SEA/S1"
DEXLAND="/Users/wei/OneDrive/2018/Vap-Dex/run/Sourcedata/LAND/S4"

SEALAND="/Users/wei/OneDrive/2018/Vap-Dex/run/Sourcedata"
echo -n "Enter Run Number "
read RunNO


echo -n "Enter which foring data you will use[gdas/R2]: "
read Foring
if [[ ($Foring == "gdas")]] 
then
 MET="/Volumes/wei3/gdas1"      #Foring data directory; MODIFY IT
 echo $MET
elif [[ ($Foring == "R2")]] 
then
 MET="/Volumes/Wei-2/R2"        #Foring data directory; MODIFY IT
else
 echo "Something wrong; EXIT"
 #exit 1
fi
sh Bin_traj.sh
sites="Mase Luancheng NewHaven"
echo $sites
for site in ${sites}
do
echo ${site}
traj_q="/Users/wei/OneDrive/2018/Vap-Dex/run/traj/${site}_trajQ"
echo ${traj_q}
mkdir -p ${traj_q}

traj_LSF="../run/Senoria${RunNO}/${site}_trajLSF"
mkdir -p ${traj_LSF}

traj_dex="../run/Senoria${RunNO}/${site}_trajDEX"
mkdir -p ${traj_dex}

DEX_est="../out/Senoria${RunNO}/${site}_DEX"
mkdir -p ${DEX_est}

if [[ (${site} == "Mase")]];then
startdate=2013-06-01
enddate=2014-08-31
Lon=140.03
Lat=36.05
elif [[ (${site} == "Luancheng")]];then
startdate=2008-04-01
enddate=2008-09-31
Lon=114
Lat=37
elif [[ (${site} == "NewHaven")]];then
startdate=2007-04-01
enddate=2008-06-31
Lon=-72.92
Lat=41.3
fi

sDateTs=`date -j -f "%Y-%m-%d" $startdate "+%s"`
eDateTs=`date -j -f "%Y-%m-%d" $enddate "+%s"`
dateTs=$sDateTs
offset=86400

while [ "$dateTs" -le "$eDateTs" ];do
  date=`date -j -f "%s" $dateTs "+%Y-%m-%d"`
  printf '%s\n' $date
  Year=`echo ${date:0:4}`
  Month=`echo ${date:5:2}`
  Day=`echo ${date:8:2}`

  if [[ ($Foring == "gdas")]]; then
    Hours="00 03 06 09 12 15 18 21"
  elif [[ ($Foring == "R2")]]; then
    Hours="00 06 12 18"
  else
    echo "Something wrong; EXIT"
    exit 1
  fi

  for Hour in ${Hours} ; do 
 #   sh ${Foring}_cal_traj.sh  $Year $Month $Day $Hour $Lat $Lon $site $MDL $MET ${traj_q} 
    sh ${Foring}_step1.sh $Year $Month $Day $Hour $site ${traj_q} ${traj_LSF} ${SEALAND} $Foring
    sh ${Foring}_step2.sh $Year $Month $Day $Hour $site ${traj_LSF} ${traj_dex} ${DEXSST} ${DEXLAND}
  done

  dateTs=$(($dateTs+$offset))
done


done





