#!/bin/bash
dir=$1
site=$2
SYEAR=$3
SMONTH=$4
SDAY=$5
SHOUR=$6
EYEAR=$7
EMONTH=$8
EDAY=${9}
EHOUR=${10}

cat <<EOF > gdas_step3.m
clear;
%========================================================
addr='${dir}/';
file_traj=dir([addr,'${site}_*_step2']);
filenum=size(file_traj,1);

s1=81:-1:1;

Q_sea_f=zeros(filenum, length(s1));
Q_land_f=zeros(filenum, length(s1));
dex_sst_f=zeros(filenum, length(s1));
dex_sst_TET=zeros(filenum, length(s1));
Q_traj=zeros(filenum, 1);
Year_sim=zeros(filenum, 1);      
Month_sim=zeros(filenum, 1);   
Day_sim=zeros(filenum, 1);  
Hour_sim=zeros(filenum, 1);  
for i=1:filenum 
    nametraj=file_traj(i).name;
    trajdir =file_traj(i).folder;
    nametemp=nametraj(isstrprop(nametraj,'digit'));
    yeartemp=str2num(nametemp(1:4));
    monthtemp=str2num(nametemp(5:6));
    daytemp=str2num(nametemp(7:8));
    hourtemp=str2num(nametemp(9:10));
    loadname=strcat(addr,nametraj);
    
    dt1=datenum($SYEAR, $SMONTH, $SDAY, $SHOUR, 0, 0);
    dt2=datenum($EYEAR, $EMONTH, $EDAY, $EHOUR, 0, 0);
    dt3=datenum(yeartemp, monthtemp, daytemp,hourtemp, 0, 0);
    result=load(loadname);
    ss=length(result);
    if ss==0
        result(1:81,1:12)=NaN;
    end
    aa=size(result,2);
    if aa<12
        result(:,end+1)=NaN;
    end

    if ss<81
        result1=zeros(81,12);
        result1(1:(81-ss),1:12)=NaN;
        result1((81-ss+1):81,1:12)=result(1:ss,1:12);
        result=result1;
    end
    n1=1;

    for m=80:-1:1
        Year     = result(m:81,1);
        Month    = result(m:81,2);
        Day      = result(m:81,3);
        Hour     = result(m:81,4);
        Lon      = result(m:81,5);
        Lat      = result(m:81,6);
        bktime   = result(m:81,7);
        Q        = result(m:81,8);
        DQ       = result(m:81,9);
        LSF      = result(m:81,10);
        DEX_sst  = result(m:81,11);
        DEX_LAND = result(m:81,12);
  
        DEX_sst(DEX_sst>100|DEX_sst<0)=NaN;
        DEX_LAND(DEX_LAND>100|DEX_LAND<0)=NaN;
        k=zeros(length(Q),1);

        Q_land = 0.0;
        Q_sea  = 0.0;
        Q_tot  = 0.0;
        DQ(DQ<-10|DQ>25) = 0.0;
        
        if (LSF(1) == 0.0)
           Q_land = 0;
           Q_sea  = Q(1);
           Q_tot  = Q_sea;
        else
           Q_land = Q(1);
           Q_sea  = 0.0;
           Q_tot  = Q_land;
        end
        if (isnan(Q_tot) == 1)
            Q_tot = 0.0;
        end

        for n=2:length(k)
            if DQ(n)>0
                if (LSF(n) == 0.0)
                    Q_sea=Q_sea+DQ(n);
                    Q_tot=Q_tot+Q_sea;
                else
                    Q_land=Q_land+DQ(n);
                    Q_tot=Q_tot+Q_land;
                end
            elseif DQ(n)<=0
                if Q_tot>0
                    Q_land = Q_land+Q_land*DQ(n)/Q_tot;
                    Q_sea  = Q_sea+DQ(n)*Q_sea/Q_tot;
                    Q_tot  = Q_tot+DQ(n);
                else
                    Q_land = 0.0;
                    Q_sea  = 0.0;
                end
            else
            Q_land = Q_land;
            Q_sea  = Q_sea;
            Q_tot  = Q_tot;
            end
        end
        
        Q_sea_f(i,n1)         = Q_sea;
        Q_land_f(i,n1)        = Q_land;

        % only account ocean evap case; neglect land evap!   
         if (LSF(1) == 0.0)
            k(1)=Q(1)*DEX_sst(1);
            if k(1)<0
                k(1)=0;
            end
         else 
            k(1)=0.0;
         end
        if (isnan(k(1)==1))
            k(1)=0.0;
        end

        for s=2:length(k)
            if k(s-1)>0
                if (DQ(s)>=0&&(LSF(s) == 0.0))
                    k(s)=k(s-1)+DQ(s)*DEX_sst(s);
                else
                    k(s)=Q(s).*k(s-1)./Q(s-1);
                end
            else
                if (DQ(s)>=0&&(LSF(s) == 0.0))
                    k(s)=Q(s)*DEX_sst(s);
                else
                    k(s)=0;
                end
                
            end
        end
        dex_sst_f(i,n1)=k(length(k))/Q(length(k));
        k=zeros(length(Q),1);
      %   ! Land (RH estimated dex)+ ocean
        if (LSF(1) == 0.0)
            k(1)=Q(1)*DEX_sst(1);
        else
            k(1)=Q(1)*DEX_LAND(1);
        end
        
        if (k(1)<0||isnan(k(1))||isinf(k(1)))
            k(1)=0.0;
        end
        
        for s=2:length(k)
            if k(s-1)>0
                if DQ(s)>=0
                    if (LSF(s) == 0.0)
                        k(s)=k(s-1)+DQ(s)*DEX_sst(s);
                    else 
                        k(s)=k(s-1)+DQ(s)*DEX_LAND(s);
                    end
                else
                    k(s)=Q(s).*k(s-1)./Q(s-1);    
                end   
                if(isnan(k(s))||k(s)<=0)
                    k(s)=Q(s).*k(s-1)./Q(s-1);
                end    
            else
                if (LSF(s) == 0.0)
                    k(s)=Q(s).*DEX_sst(s);
                else
                    k(s)=Q(s).*DEX_LAND(s);
                end
            end
            if(isnan(k(s))||k(s)<=0)
                k(s)=Q(s).*k(s-1)./Q(s-1);
            end   
        end
        dex_sst_LAND(i,n1)=k(length(k))/Q(length(k));
        if(isnan(dex_sst_LAND(i,n1))||dex_sst_LAND(i,n1)<=0)
        dex_sst_LAND(i,n1)=-9999;
        end
        n1=n1+1;
    end 
  
    Q_traj(i)=result(81,8);
    Year_traj(i)=yeartemp;      
    Month_traj(i)=monthtemp;   
    Day_traj(i)=daytemp;  
    Hour_traj(i)=hourtemp; 
end
    dex_sst_only=dex_sst_f;
    save('$dir/VAPDEX_simulated_${site}.mat','Year_traj', 'Month_traj','Day_traj','Hour_traj','dex_sst_LAND','dex_sst_only','Q_traj','Q_sea_f','Q_land_f')
%save('$dir/Land_sea_${site}.mat','Year_traj', 'Month_traj','Day_traj','Hour_traj','Q_sea_f','Q_land_f')
EOF

