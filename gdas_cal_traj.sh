#!/bin/bash
#-------------------------------------------------------------
# Modify it !!!
  olvl=500
  run=-240.0
  ztop=10000.0
#--------------------------------------------------------------
# set model simulation variables

  yr=$1
  syr=`echo ${yr:2:4}`
  mon=$2
  day=$3
  hour=$4
  olat=$5
  olon=$6
  site=$7
  MDL=$8
  MET=$9
  OUT=${10}

  pyr=`echo "$yr-1" | bc`
  psyr=`echo ${pyr:2:4}`

  if [ $mon -eq 1 ];then
     pmonyr="dec${psyr}"
     monyr="jan${syr}"
  elif [ $mon -eq 2 ];then
     pmonyr="jan${syr}"
     monyr="feb${syr}"
  elif [ $mon -eq 3 ];then
     pmonyr="feb${syr}"
     monyr="mar${syr}"
  elif [ $mon -eq 4 ];then
     pmonyr="mar${syr}"
     monyr="apr${syr}"
  elif [ $mon -eq 5 ];then
     pmonyr="apr${syr}"
     monyr="may${syr}"
  elif [ $mon -eq 6 ];then
     pmonyr="may${syr}"
     monyr="jun${syr}"
  elif [ $mon -eq 7 ];then
     pmonyr="jun${syr}"
     monyr="jul${syr}"
  elif [ $mon -eq 8 ];then
     pmonyr="jul${syr}"
     monyr="aug${syr}"
  elif [ $mon -eq 9 ];then
     pmonyr="aug${syr}"
     monyr="sep${syr}"
  elif [ $mon -eq 10 ];then
     pmonyr="sep${syr}"
     monyr="oct${syr}"
  elif [ $mon -eq 11 ];then
     pmonyr="oct${syr}"
     monyr="nov${syr}"
  else
     pmonyr="nov${syr}"
     monyr="dec${syr}"
  fi

  day1=`echo "$day-1+1" | bc`

# determine the correct meteorology week

  if [ $day1 -le 7 ];then
     met1="gdas1.${pmonyr}.w4"
     met2="gdas1.${pmonyr}.w5"
     met3="gdas1.${monyr}.w1"
  elif [[($day1 -gt 7) && ($day1 -le 14) ]] ; then
     met1="gdas1.${pmonyr}.w5"
     met2="gdas1.${monyr}.w1"
     met3="gdas1.${monyr}.w2"
  elif [[($day1 -gt 14) && ($day1 -le 21) ]] ; then
     met1="gdas1.${monyr}.w1"
     met2="gdas1.${monyr}.w2"
     met3="gdas1.${monyr}.w3"
  elif [[($day1 -gt 21) && ($day1 -le 28) ]] ; then
     met1="gdas1.${monyr}.w2"
     met2="gdas1.${monyr}.w3"
     met3="gdas1.${monyr}.w4"
  else
     met1="gdas1.${monyr}.w3"
     met2="gdas1.${monyr}.w4"
     met3="gdas1.${monyr}.w5"
  fi


#----------------------------------------------------------
# basic simulation loop

#----------------------------------------------------------
# set up control file for dispersion/concentration simulation
  echo "$syr $mon $day $hour   " >CONTROL
  echo "1                      ">>CONTROL
  echo "$olat $olon $olvl      ">>CONTROL
  echo "$run                   ">>CONTROL
  echo "0                      ">>CONTROL
  echo "$ztop                  ">>CONTROL
  echo "3                      ">>CONTROL
  echo "$MET/                  ">>CONTROL
  echo "$met1                  ">>CONTROL
  echo "$MET/                  ">>CONTROL
  echo "$met2                  ">>CONTROL
  echo "$MET/                  ">>CONTROL
  echo "$met3                  ">>CONTROL
  echo "$OUT/                  ">>CONTROL
  echo "tdump                  ">>CONTROL
#----------------------------------------------------------
# run the concentration simulation
  if [ -f tdump ];then rm tdump; fi

  ${MDL}/exec/hyts_std
  #${MDL}/exec/trajplot ${OUT}/tdump
  mv ${OUT}/tdump ${OUT}/${site}_20${syr}${mon}${day}_${hour}
  #cat ${site}_20${syr}${smo}${sda}_${shr}>>${site}_all

#  mv trajplot.ps plot${smo}${sda}.ps
#----------------------------------------------------------
