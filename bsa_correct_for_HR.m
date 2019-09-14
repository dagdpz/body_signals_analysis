function [cHRV] = bsa_correct_for_HR(HR,HRV, CF, simulation)

% USAGE:
% out = Correct_ForChangesHR(HR,HRV)
%
% INPUTS:
%		HR		- heartrate
%       HRV   - heartrate varibility
%
% OUTPUTS:
%		cHRV             - corrected Heartrate varibility
%
% REQUIRES:	Igtools
%%
%
% Author(s):	K.Kristin, DAG, DPZ
% URL:		http://www.dpz.eu/dag
%
% Change log:
% 20190904:	Created function (Kristin Kaduk)
%

%cHRV(1) = HRV/exp((HR_ref - HR)/58.8);
cHRV = HRV./exp(-(HR/CF));

if simulation
HR_ref  = 0; 

cHRV_sim(1) = HRV(1)/exp((HR_ref - HR(1))/CF);
cHRV_sim(2) = HRV(1)/exp(-(HR(1)/CF));

%% plot the relationship between HR & the factor
%1) How does the exponential part changes by changing the 58.8
HR_sim = 0:200;
%HRV    = 20; %0:200; 
HR_exp = exp(-(HR_sim/CF)); 

HR_exp_58 = exp(-(HR_sim/58.8)); 
%HR_exp_78 = exp(-(HR/78.8)); 

figure(1)
plot(HR_sim,HR_exp ); hold on; 
plot(HR_sim,HR_exp_58 )
%plot(HR,HR_exp_78 )
% HR_ref      =  120;
% HR = 0:200;
% HR_exp2= exp((HR_ref-HR)/58.8)
% plot(HR,HR_exp2 )
xlabel('HR (bpm)');
ylabel('exp(-(HR/CF))');

%2) equation 8 & 9 give the same result
figure(2)
HR_sim = 0:150;
cHRV_sim2   = HRV(1)./exp(-(HR_sim/CF)); %HRV./exp(-(HR/58.8)); HRV./exp((0-HR)/58.8); %
plot(HR_sim,cHRV_sim2 ); hold on
plot(HR(1), HRV(1), 'bo')
plot(HR(1), cHRV(1), 'r.')
plot(HR(1), cHRV(1), 'ro')

ylabel('HRV./exp(-(HR/CF)))');
xlabel('HR (bpm)');

figure(3)
HR_ref_sim = 0:150;
cHRV_ref   = HRV(1)./exp((HR_ref_sim-HR(1))/CF);
plot(HR_ref_sim,cHRV_ref );
%plot(HR(1), HRV(1), 'bo')
%plot(HR(1), cHRV(1), 'r.')
%plot(HR(1), cHRV(1), 'ro')
xlabel('HR (bpm)');
ylabel('HRV./exp((HR_ref_sim-HR(1))/CF)');
title(['HRV = ', num2str(HRV)]);
end
