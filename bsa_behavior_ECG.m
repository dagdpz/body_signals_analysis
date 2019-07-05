function bsa_behavior_ECG(targetBrainArea)
%targetBrainArea = 'dPul';
%load behavior data of the inactivation session
load(['Y:\Projects\PhysiologicalRecording\Figures\Inactivation_20190124_20190129_20190201_20190207_20190214_20190228_20190314\Behavior_Inactivation_20190502-1403.mat'])

%load the data of the heartrate & heartrate varibility meassure - each
%session & Block
load(['Y:\Projects\PhysiologicalRecording\Data\Cornelius\', 'Structure_HeartrateVaribility_PerSessionPerBlock_Inactivation_',targetBrainArea ])
%% choice bias for each session (post - pre)

%% ECG (pool Blocks)

% graph

for i_sess = 1: numel( data_struct_per_session.targ_targ.combined.go_signal)
choiceBias(i_sess) = data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.true_prop_choice_per_session_left - data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.true_prop_choice_per_session_left;  
Table = struct2table(S_Blocks_ina(i_sess).Block); 
 Block_Task_Injection_Pre = Table(strcmp(Table.Condition, 'pre_task'),:);
 Block_Task_Injection_Post = Table(strcmp( Table.Condition , 'pst_task'),:);
ECG(i_sess) = nanmean(Block_Task_Injection_Pre.mean_R2R_bpm ) - nanmean(Block_Task_Injection_Post.mean_R2R_bpm); 
end

% the size of the dot shows the volume
figure
plot( choiceBias ,ECG, 'o','color',[0 0 0] ,'MarkerSize',10); hold on; 
