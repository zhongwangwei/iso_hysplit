#!/bin/bash
Year=$1
Month=$2
sda=$3
shr=$4
site=$5
IN=$6
OUT=$7
SEALAND=$8
Foring=$9

sed -e '1,7d' < $IN/${site}_${Year}${Month}${sda}_${shr} >temp0
awk '{if ($6=="0" || $6=="3" || $6=="6" ||  $6=="9" || $6=="12" || $6=="15" || $6=="18" || $6=="21") print $0 }' temp0 > temp
#revese line order
tail -r temp > temp2
awk '{for(i=1;i<=NF;i++){tmp=$i;$i-=old[i];old[i]=tmp};print $0}' temp2 > temp3 # i+1 - i


cat temp3 | awk '{print $15}' > delta_q_ver
cat temp2 | awk '{print $11, $10, $9, $15}' | column -t > temp5 #lon lat time Interval specificHumidity

rm landmark Datetime
{
while read f1 f2 f3 f4
do
echo $f1 $f2 $f3 $f4
cdo remapnn,lon=${f1}/lat=${f2} $SEALAND/landsea_${Foring}.nc landsea_temp.nc
k1=`cdo outputf,\%13.6g,1 landsea_temp.nc`
if [ ! $k1 ]
then
echo "-9999" >>landmark

else
echo "$k1">>landmark
fi
echo "${Year}" "${Month}" "${sda}" "${shr}" >>Datetime
done
} < temp5

paste delta_q_ver landmark |column -t > g
paste temp5 g |column -t >g1
paste Datetime g1 |column -t >g2
cat g2 >> $OUT/${site}_${Year}${Month}${sda}${shr}_step1
rm temp *temp* g g1 g2 landmark delta_q_ver temp*
