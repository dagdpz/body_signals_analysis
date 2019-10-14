function bsa_meanHR(monkey,targetBrainArea,path_SaveFig)
%Todo:
% How to input better all the different datasets
%USAGE:
% bsa_meanHR(monkey,behavior_Data,targetBrainArea,path_SaveFig);
%
% INPUTS:
%		monkey              - Path to session data
%       behavior_Data       - excel file
%       targetBrainArea     - name of the mfile with specific session/monkey settings
%		path_SaveFig        - see % define default arguments and their potential values
%
% OUTPUTS:
%		display average HR for specified sessions
%
% REQUIRES:	
%
%
% Author(s):	K.Kaduk, DAG, DPZ
% URL:		http://www.dpz.eu/dag
%
% Change log:
% 20190904:	Created function (Kristin Kaduk)
% ...
% $Revision: 1.0 $  $Date: 2019-02-26 14:22:52 $

% ADDITIONAL INFO:

load(['Y:\Projects\PhysiologicalRecording\Data\', monkey, filesep,'AllSessions',filesep,monkey '_Structure_HeartrateVaribility_PerSession_Inactivation_' ,targetBrainArea])
load(['Y:\Projects\PhysiologicalRecording\Data\', monkey, filesep,'AllSessions',filesep,monkey '_Structure_HeartrateVaribility_PerSession_Control_' ,targetBrainArea])
load(['Y:\Projects\PhysiologicalRecording\Data\', monkey, filesep,'AllSessions',filesep,monkey '_Structure_HeartrateVaribility_PerSessionPerBlock_' ,targetBrainArea])



%%
DVs =   'mean_R2R_bpm';
Control = [S_con.(DVs)];
Injection = [S_ina.(DVs)];

mean_R2R_task(1) = mean([Control.pre_task]'); 
sd_R2R_task(1) = std([Control.pre_task]'); 

min_R2R_task(1)  = min([Control.pre_task]'); 
max_R2R_task(1)  = max([Control.pre_task]'); 
mean_R2R_rest(1) = mean([Control.pre_rest]'); 
min_R2R_rest(1)  = min([Control.pre_rest]'); 
max_R2R_rest(1)  = max([Control.pre_rest]'); 

mean_R2R_task(2) = mean([Injection.pre_task]'); 
sd_R2R_task(2) = std([Injection.pre_task]'); 

min_R2R_task(2)  = min([Injection.pre_task]'); 
max_R2R_task(2)  = max([Injection.pre_task]'); 
mean_R2R_rest(2) = mean([Injection.pre_rest]'); 
min_R2R_rest(2)  = min([Injection.pre_rest]'); 
max_R2R_rest(2)  = max([Injection.pre_rest]'); 
% graph
figure(1)
h1 = histogram([Control.pre_task],6); hold on; 
h2 =histogram([Injection.pre_task], 6);
text(105,2, ['mean=',num2str(mean_R2R_task)])
text(105,2.5,['sd=',num2str(sd_R2R_task)])

figure(2)
h3 = histogram([Control.pre_rest],6); hold on; 
h4 =histogram([Injection.pre_rest], 6);

   h = [];
        h(1) = figure(1);
 print(h,[path_SaveFig filesep 'png' filesep targetBrainArea '_' monkey '_' 'Histogram_meanHeartrate_pre' ], '-dpng')
        set(h,'Renderer','Painters');
        set(h,'PaperPositionMode','auto')

%% How predictive are the first  Block for the HR in the pre-Blocks?
for i_Sess = 1: length(S_Blocks2)
std_mean_R2R_pre_task(i_Sess) = std(S_Blocks2(i_Sess).mean_R2R_bpm.pre_task); 
diff_to_mean_R2R_pre_task(i_Sess) = mean(S_Blocks2(i_Sess).mean_R2R_bpm.pre_task) - S_Blocks2(i_Sess).mean_R2R_bpm.pre_task(1);

std_mean_R2R_pre_rest(i_Sess) = std(S_Blocks2(i_Sess).mean_R2R_bpm.pre_rest); 
diff_to_mean_R2R_pre_rest(i_Sess) = mean(S_Blocks2(i_Sess).mean_R2R_bpm.pre_rest) - S_Blocks2(i_Sess).mean_R2R_bpm.pre_rest(1); 
end
