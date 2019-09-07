function [cHRV] = bsa_correct_for_HR(HR,HRV)

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
HR_ref  = 0; 
HR      = 120;
HRV     = 20;
cHRV(1) = HRV/exp((HR_ref - HR)/58.8);
cHRV(2) = HRV/exp(-(HR/58.8));

%% plot the relationship between HR & the factor
%1) How does the exponential part changes by changing the 58.8
HR = 0:200;
HRV    = 20; %0:200; 
HR_exp = exp(-(HR/58.8)); 

HR_exp_38 = exp(-(HR/38.8)); 
HR_exp_78 = exp(-(HR/78.8)); 

figure(1)
plot(HR,HR_exp ); hold on; 
plot(HR,HR_exp_38 )
plot(HR,HR_exp_78 )
HR_ref      =  120;
HR = 0:200;
HR_exp2= exp((HR_ref-HR)/58.8)
plot(HR,HR_exp2 )


xlabel('HR (bpm)');
ylabel('exp(-(HR/58.8))');
%2) equation 8 & 9 give the same result
figure(2)
HR = 0:200;
cHRV   = HRV./exp(-(HR/58.8)); %HRV./exp((0-HR)/58.8); %
plot(HR,cHRV ); hold on
HR     =  120;
HR_ref = 0:200;
cHRV_ref   = HRV./exp((HR_ref-HR)/58.8);
plot(HR_ref,cHRV_ref );
xlabel('HR (bpm)');
ylabel('HRV./exp(-(HR/58.8)))');
title(['HRV = ', num2str(HRV)]);
