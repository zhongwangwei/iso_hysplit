#!/bin/bash
Year=$1
Month=$2
sda=$3
shr=$4
site=$5
IN=$6
OUT=$7
DEXSST=$8
DEXLAND=$9



{
while read f1 f2 f3 f4 f5 f6 f7 f8 f9 f10
do
      echo '@@@@@@@@@@@@@@@@@@@'
      echo 'Year  = '$f1
      echo 'Month = '$f2
      echo 'Day   = '$f3
      echo 'Hour  = '$f4
      echo 'Lon   = '$f5
      echo 'Lat   = '$f6
      echo 'BKtime= '$f7
      echo 'Q     = '$f8
      echo 'DQ    = '$f9
      echo 'LSF   = '$f10
      echo '@@@@@@@@@@@@@@@@@@@'

      date1=${f1}${f2}${f3}_${f4}
      echo $date1
      date2=`./newtime ${date1} ${f7}`
      echo $date2
      YYYY2=`echo ${date2:0:4}`
      Mon2=`echo ${date2:4:2}`
      Day2=`echo ${date2:6:2}`
      Hour2=`echo ${date2:9:2}`

      if [[ ($Hour2 == "00") || ($Hour2 == "03") || ($Hour2 == "06") || ($Hour2 == "09") || ($Hour2 == "12") || ($Hour2 == "15") || ($Hour2 == "18") || ($Hour2 == "21") ]] 
      then
      ###DEX SEA
      cdo seldate,${YYYY2}-${Mon2}-${Day2}T${Hour2}\:00\:00 $DEXSST/DEX_sst_${YYYY2}.nc DEX_sst_temp.nc
      cdo remapnn,lon=${f5}/lat=${f6} DEX_sst_temp.nc DEX_sst_temp2.nc
      k1=`cdo outputf,\%13.6g,1 DEX_sst_temp2.nc`
      rm DEX_sst_temp.nc DEX_sst_temp2.nc
      if [ ! $k1 ]
      then
      echo "-9999" >>DEX_sst
      else
      echo "$k1">>DEX_sst
      fi
      echo 'DEX_sst =' $k1

      ###DEX LAND
      cdo seldate,${YYYY2}-${Mon2}-${Day2}T${Hour2}\:00\:00 $DEXLAND/DEX_Land_${YYYY2}.nc DEX_Land_temp.nc
      cdo remapnn,lon=${f5}/lat=${f6} DEX_Land_temp.nc DEX_Land_temp2.nc
      k2=`cdo outputf,\%13.6g,1 DEX_Land_temp2.nc`
      rm DEX_Land_temp.nc DEX_Land_temp2.nc

      if [ ! $k2 ]
      then
      echo "-9999" >>DEX_LAND
      else
      echo "$k2" >>DEX_LAND
      fi
      echo 'DEX_TET =' $k2
      ###DEX SEA
      else
      echo "-9999" >>DEX_sst
      echo "-9999" >>DEX_LAND
      fi

done
} < $IN/${site}_${Year}${Month}${sda}${shr}_step1

paste $IN/${site}_${Year}${Month}${sda}${shr}_step1 DEX_sst DEX_LAND |column -t >$OUT/${site}_${Year}${Month}${sda}${shr}_step2

rm g g1  *temp* DEX_sst DEX_LAND 
