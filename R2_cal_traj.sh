#!/bin/bash
#-------------------------------------------------------------
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


  if [ ${mon} -lt 2 ] ; then
    smo1=12
    syr1=`expr $syr - 1`
    if [ ${syr1} -lt 10 ] ; then
      syr1=0${syr1}
    fi
  else
    syr1=$syr
    smo1=`expr ${mon} - 1`
    if [ ${smo1} -lt 10 ] ; then
      smo1=0${smo1}
    fi
  fi

  echo ${syr1}${smo1} ${syr}${mon}
  met1="RP20${syr1}${smo1}.gbl"
  met2="RP20${syr}${mon}.gbl"



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
  echo "2                      ">>CONTROL
  echo "$MET/                  ">>CONTROL
  echo "$met1                  ">>CONTROL
  echo "$MET/                  ">>CONTROL
  echo "$met2                  ">>CONTROL
  echo "$OUT/                  ">>CONTROL
  echo "tdump                  ">>CONTROL
#----------------------------------------------------------
# run the concentration simulation
  if [ -f tdump ];then rm tdump; fi

  ${MDL}/exec/hyts_std
  mv ${OUT}/tdump ${OUT}/${site}_20${syr}${mon}${day}_${hour}
  #cat ${site}_20${syr}${smo}${sda}_${shr}>>${site}_all

#  mv trajplot.ps plot${smo}${sda}.ps
#----------------------------------------------------------
