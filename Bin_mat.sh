#!/bin/bash
cat <<EOF > dailyaverage.m
function [Y1,M1,D1,variable,variable_std,a]=dailyaverage(Year,Month,Day,Hour,Data1)
yy = datenum(Year, Month, Day, 0, 0, 0);
count=unique(yy);
a=zeros(length(count),1);
variable=zeros(length(count),1);
variable_std=zeros(length(count),1);
for i=1:length(count)
variable(i)=nanmean(Data1(yy==count(i)));
variable_std(i)=nanstd(Data1(yy==count(i)));
a(i)=length(Data1(yy==count(i)));
end
a=a';
variable_std=variable_std';
[Y1,M1,D1]=datevec(count);
if D1(1)-Day(1)==0
fprintf( 'date OK\n')
else
fprintf('Warning\n')
end
end
EOF


cat <<EOF > dailyweightaverage.m
function [Y1,M1,D1,weightted]=dailyweightaverage(Year,Month,Day,Hour,Data1,weight)
yy = datenum(Year, Month, Day, 0, 0, 0);
Data2=Data1.*weight;
count=unique(yy);

for i=1:length(count)
variable(i)=sum(Data2(yy==count(i)&~isnan(Data2)));
variable1(i)=sum(weight(yy==count(i)&~isnan(Data2)));
weightted(i)=variable(i)/variable1(i);
end

%variable_std=variable_std';
[Y1,M1,D1]=datevec(count);
if D1(1)-Day(1)==0
fprintf( 'date OK\n')
else
fprintf('Warning\n')
end
end
EOF


cat <<EOF >monthlyaverage.m
function [Y1,M1,variable,variable_std]=monthlyaverage(Year,Month,Day,Hour,Data1)
yy = datenum(Year, Month, 0, 0, 0, 0);

count=unique(yy);

for i=1:length(count)
variable(i)=nanmean(Data1(yy==count(i)));
variable_std(i)=nanstd(Data1(yy==count(i)));
end
variable=variable';
variable_std=variable_std';

[Y1,M1]=datevec(count);
if M1(1)-Month(1)==0
fprintf( 'date OK\n')
else
fprintf('Warning\n')
M1=M1+1;
i=find(M1>12);
Y1(i)=Y1(i)+1;
M1(i)=M1(i)-12;
if M1(1)-Month(1)==0;
fprintf( 'date corrected\n');
end
end
end
EOF

cat <<EOF >monthlysum.m
function [Y1,M1,variable]=monthlysum(Year,Month,Day,Hour,Data1)
 yy = datenum(Year, Month, 0, 0, 0, 0);

count=unique(yy); 

 for i=1:length(count)
variable(i)=nansum(Data1(yy==count(i)));
 end
variable=variable';


[Y1,M1]=datevec(count);
if M1(1)-Month(1)==0
fprintf( 'date OK\n')
else
fprintf('Warning\n')
M1=M1+1;
i=find(M1>12);
Y1(i)=Y1(i)+1;
M1(i)=M1(i)-12;
if M1(1)-Month(1)==0;
fprintf( 'date corrected\n');
end
end


end

EOF


cat <<EOF > getbesttracer.m
function [best_R2,best_RMSD,sfc_mon,RMSD_all,R2_all,I_all,B_all,Y3,M3,D3,DEXtrace_day,sfc_day]=getbesttracer(Y1,M1,D1,H1,dex_sim,land,sea,DEXobs_daily,Q_traj)

dex_sim(dex_sim<=0)=NaN;
Dx_trace(:,1)  = dex_sim	(:,	1*4	)	;
Dx_trace(:,2)  = dex_sim	(:,	2*4	)   ;
Dx_trace(:,3)  = dex_sim	(:,	3*4	)   ;
Dx_trace(:,4)  = dex_sim	(:,	4*4	)   ;
Dx_trace(:,5)  = dex_sim	(:,	5*4	)   ;
Dx_trace(:,6)  = dex_sim	(:,	6*4   )   ;
Dx_trace(:,7)  = dex_sim	(:,	7*4	)   ;
Dx_trace(:,8)  = dex_sim	(:,	8*4)	;
Dx_trace(:,9)  = dex_sim	(:,	9*4	)	;
Dx_trace(:,10) = dex_sim	(:,	10*4)	;
Dx_trace(:,11) = dex_sim	(:,	11*4	)	;
Dx_trace(:,12) = dex_sim	(:,	12*4	)	;
Dx_trace(:,13) = dex_sim	(:,	13*4  )	;
Dx_trace(:,14) = dex_sim	(:,	14*4	)	;
Dx_trace(:,15) = dex_sim	(:,	15*4  )	;
Dx_trace(:,16) = dex_sim	(:,	16*4 	)	;
Dx_trace(:,17) = dex_sim	(:,	17*4	)	;
Dx_trace(:,18) = dex_sim	(:,	18*4	)	;
Dx_trace(:,19) = dex_sim	(:,	19*4	)	;
Dx_trace(:,20) = dex_sim	(:,	20*4	)	;

Q_land_f(:,1)  = land	(:,	1*4)	;
Q_land_f(:,2)  = land	(:,	2*4)   ;
Q_land_f(:,3)  = land	(:,	3*4	)   ;
Q_land_f(:,4)  = land	(:,	4*4)   ;
Q_land_f(:,5)  = land	(:,	5*4	)   ;
Q_land_f(:,6)  = land	(:,	6*4	)   ;
Q_land_f(:,7)  = land	(:,	7*4	)   ;
Q_land_f(:,8)  = land	(:,	8*4	)	;
Q_land_f(:,9)  = land	(:,	9*4	)	;
Q_land_f(:,10) = land	(:,	10*4	)	;
Q_land_f(:,11) = land	(:,	11*4	)	;
Q_land_f(:,12) = land	(:,	12*4	)	;
Q_land_f(:,13) = land	(:,	13*4	)	;
Q_land_f(:,14) = land	(:,	14*4	)	;
Q_land_f(:,15) = land	(:,	15*4	)	;
Q_land_f(:,16) = land	(:,	16*4	)	;
Q_land_f(:,17) = land	(:,	17*4	)	;
Q_land_f(:,18) = land	(:,	18*4	)	;
Q_land_f(:,19) = land	(:,	19*4)	;
Q_land_f(:,20) = land	(:,	20*4)	;


Q_sea_f(:,1)  = sea	(:,	1*4)	;
Q_sea_f(:,2)  = sea	(:,	2*4	)   ;
Q_sea_f(:,3)  = sea	(:,	3*4	)   ;
Q_sea_f(:,4)  = sea	(:,	4*4	)   ;
Q_sea_f(:,5)  = sea	(:,	5*4)   ;
Q_sea_f(:,6)  = sea	(:,	6*4)   ;
Q_sea_f(:,7)  = sea	(:,	7*4	)   ;
Q_sea_f(:,8)  = sea	(:,	8*4	)	;
Q_sea_f(:,9)  = sea	(:,	9*4	)	;
Q_sea_f(:,10) = sea	(:,	10*4	)	;
Q_sea_f(:,11) = sea	(:,	11*4	)	;
Q_sea_f(:,12) = sea	(:,	12*4)	;
Q_sea_f(:,13) = sea	(:,	13*4)	;
Q_sea_f(:,14) = sea	(:,	14*4	)	;
Q_sea_f(:,15) = sea	(:,	15*4	)	;
Q_sea_f(:,16) = sea	(:,	16*4	)	;
Q_sea_f(:,17) = sea	(:,	17*4	)	;
Q_sea_f(:,18) = sea	(:,	18*4	)	;
Q_sea_f(:,19) = sea	(:,	19*4	)	;
Q_sea_f(:,20) = sea	(:,	20*4)	;


%  decide R2 and DEXtrace length
[Y11,M11,R2_length,tem]=monthlyaverage(Y1,M1,D1,H1,dex_sim	(:,	12	));
R2=zeros(length(R2_length),1);
R=zeros(length(R2_length),1);
RMSD=zeros(length(R2_length),1);
DEXtrace=zeros(length(R2_length),1);

for i=1:20
m=Dx_trace(:,i);
m(m<0)=NaN;
[Y3,M3,D3,DEXtrace_temp]=dailyweightaverage(Y1,M1,D1,H1,m,Q_traj);
DEXtrace_temp=DEXtrace_temp';
DEXtrace_temp(DEXtrace_temp<=0)=NaN
yy = datenum(Y3, M3, 0, 0, 0, 0);
count=unique(yy);
R2t=zeros(length(count),1);
Rt=zeros(length(count),1);
RMSDt=zeros(length(count),1);
for j=1:length(count)
k1=DEXobs_daily(yy==count(j));
k2=DEXtrace_temp(yy==count(j));

[RMSD_temp,I_temp,B_temp,R2_temp,R_temp]=modelperformance(k1(k1>0&k2>0),k2(k1>0&k2>0));
R2t(j)=R2_temp;
Rt(j)=R_temp;
RMSDt(j)=RMSD_temp;
end

R2=[R2,R2t];
R=[R,Rt];
RMSD=[RMSD,RMSDt];
end

R2=R2(:,2:21);
R=R(:,2:21);
RMSD=RMSD(:,2:21);
best_R2=zeros(length(count),1);
best_R=zeros(length(count),1);
best_RMSD=zeros(length(count),1);
best_location=zeros(length(count),1);
best_tracer=0;
best_land=0;
best_sea=0;

for k=1:length(count)
[num, idx] = max(R2(k,1:20));
[num1, idx1] = max(abs(R(k,1:20)));

[x, y] = ind2sub(size(R2(k,1:20)),idx);
best_R2(k)=num;
best_R(k)=num1;
best_location(k)=y;
best_RMSD(k)=RMSD(k,y);
yy = datenum(Y1,M1,0,0,0,0);
count=unique(yy);
m=Dx_trace(:,1:20);

k3=m(yy==count(k),best_location(k));
best_tracer=[best_tracer;k3];

n=Q_land_f(:,1:20);
k5=n(yy==count(k),best_location(k));
best_land=[best_land;k5];


o=Q_sea_f(:,1:20);
k6=o(yy==count(k),best_location(k));
best_sea=[best_sea;k6];
%k6=k5(:,best_location(k));
%best_sfc=[best_sfc;k6];
clearvars k3
clearvars k5
clearvars k6
end
best_tracer=best_tracer(2:length(best_tracer));
best_sea=best_sea(2:length(best_sea));
best_land=best_land(2:length(best_land));
[Y3,M3,D3,DEXtrace_day]=dailyweightaverage(Y1,M1,D1,H1,best_tracer,Q_traj);
DEXtrace_day=DEXtrace_day';
%best_sea(best_sea>50|best_sea<-10)=NaN;
%best_land(best_land>50|best_land<-10)=NaN;
%best_sea(best_tracer==0)=NaN;
%best_land(best_tracer==0)=NaN;
[Y3,M3,D3,best_sea_day,DEXtrace_temp_std]=dailyaverage(Y1,M1,D1,H1,best_sea);
[Y3,M3,D3,best_land_day,DEXtrace_temp_std]=dailyaverage(Y1,M1,D1,H1,best_land);

%best_sea_day=best_sea_day+(SPobs_daily-Q_traj_daily);
sfc_day=(best_land_day)./(best_land_day+best_sea_day);
sfc_day(sfc_day>1|sfc_day<0)=NaN;
%[Y4,M4,sfc_mon,stda]=monthlyaverage(Y3,M3,D3,0,sfc_day);
[Y4,M4,land_mon,stda]=monthlyaverage(Y3(DEXobs_daily>0&DEXtrace_day>0),M3(DEXobs_daily>0&DEXtrace_day>0),D3(DEXobs_daily>0&DEXtrace_day>0),0,best_land_day(DEXobs_daily>0&DEXtrace_day>0));
[Y4,M4,sea_mon,stda]=monthlyaverage(Y3(DEXobs_daily>0&DEXtrace_day>0),M3(DEXobs_daily>0&DEXtrace_day>0),D3(DEXobs_daily>0&DEXtrace_day>0),0,best_sea_day(DEXobs_daily>0&DEXtrace_day>0));
sfc_mon=land_mon./(land_mon+sea_mon);
count1 = datenum(Y3,M3,D3,0,0,0);
count2 = unique(count1); 
interval1=count2;
[RMSD_all,I_all,B_all,R2_all,R_all]=modelperformance(DEXobs_daily(DEXobs_daily>0&DEXtrace_day>0),DEXtrace_day(DEXobs_daily>0&DEXtrace_day>0));
end
EOF

cat <<EOF > modelperformance.m
function [RMSD,I,B,R2,R1]=modelperformance(k1,k2)
%k1:obs
%k2:sim
RMSD=(((nansum((k1-k2).^2)))./length(k2)).^0.5;%RMSD
I=1-((nansum((k1-k2).^2)))./(nansum(((abs(k2-nanmean(k1)))+abs(k1-nanmean(k1))).^2));
B=nansum(k2-k1)/length(k2);
R1=(nansum(((k1-nanmean(k1)).*(k2-nanmean(k2)))))./sqrt((nansum((k2-nanmean(k2)).^2)).*(nansum((k1-nanmean(k1)).^2)));
R2=R1*R1;
end
EOF
