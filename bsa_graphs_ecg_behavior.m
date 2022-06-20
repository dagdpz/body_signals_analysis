function bsa_graphs_ecg_behavior(monkey,behavior_Data,targetBrainArea,path_SaveFig)

%% ToDO
% add different variables
%%
%load behavior data of the inactivation session
load(behavior_Data)

%load the data of the heartrate & heartrate varibility meassure - each
load(['Y:\Projects\PhysiologicalRecording\Data\' , monkey ,filesep,'AllSessions',filesep ,'Structure_HeartrateVaribility_PerSessionPerBlock_Inactivation_',targetBrainArea ])
load(['Y:\Projects\PhysiologicalRecording\Data\' , monkey ,filesep,monkey,'_Table_SessionInfos.mat'])
% load session info
%!!!!!!
%% choice bias for each session (post - pre)
% percentage change between pre & post for each session, pool of pre - pool of post
DataTab = []; 
for i_sess = 1: numel( data_struct_per_session.targ_targ.combined.go_signal)
    %Wich variable should I take? How to take into account fixation?
    %true_prop_choice_per_session_left
    %mean_prop_choice_across_runs_left  - true proportion calculated for
    %each run & mean of these
    SessionInfo = Table_SessionInfo(strcmp(Table_SessionInfo.date , data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.session),:); 
    DataTab.brain_area(i_sess) = SessionInfo.brain_area; 
    DataTab.hemisphere(i_sess) = SessionInfo.hemisphere; 
    DataTab.experiment(i_sess) = SessionInfo.experiment; 
    DataTab.volume_ul(i_sess)  = SessionInfo.volume_ul; 
    DataTab.substance(i_sess)  = SessionInfo.substance; 

    % calculate the choice for target-target trials
    if strcmp(DataTab.hemisphere, 'left')
        DataTab.tar_tar_ipsi_pre(i_sess)  =  data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_left;
        DataTab.tar_tar_ipsi_post(i_sess)  =  data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_left;
        DataTab.tar_tar_contra_pre(i_sess)  =  data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_right;
        DataTab.tar_tar_contra_post(i_sess)  =  data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_right;
        DataTab.tar_tar_fixation_pre(i_sess)  =  data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_fixation;
        DataTab.tar_tar_fixation_post(i_sess)  =  data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_fixation;
        
        DataTab.tar_tar_fixation(i_sess)  = data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_fixation- data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_fixation;
        DataTab.tar_tar_contra(i_sess)    = data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_right- data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_right;
        DataTab.tar_tar_ipsi(i_sess)      = data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_left- data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_left;
    elseif strcmp(DataTab.hemisphere, 'right')
        DataTab.tar_tar_ipsi_pre(i_sess)  =  data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_right;
        DataTab.tar_tar_ipsi_post(i_sess)  =  data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_right;
        DataTab.tar_tar_contra_pre(i_sess)  =  data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_left;
        DataTab.tar_tar_contra_post(i_sess)  =  data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_left;
        DataTab.tar_tar_fixation_pre(i_sess)  =  data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_fixation;
        DataTab.tar_tar_fixation_post(i_sess)  =  data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_fixation;
        
        DataTab.tar_tar_fixation(i_sess)  = data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_fixation- data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_fixation;
        DataTab.tar_tar_contra(i_sess)    = data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_left- data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_left;
        DataTab.tar_tar_ipsi(i_sess)      = data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_right- data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_right;
        
    end
    Table                       = struct2table(S_Blocks_ina(i_sess).Block);
    DataTab.Session(i_sess)     = Table.Date(1);

    Block_Task_Injection_Pre    = Table(strcmp(Table.Condition, 'pre_task'),:);
    Block_Task_Injection_Post   = Table(strcmp( Table.Condition , 'pst_task'),:);
    DV = Block_Task_Injection_Pre.Properties.VariableNames(3:8) ;
    for ind_DV = 1: numel(DV)
        DataTab.([DV{ind_DV},'_prepost'])(i_sess)         = nanmean(Block_Task_Injection_Post.(DV{ind_DV})) - nanmean(Block_Task_Injection_Pre.(DV{ind_DV}));
    end
end
%% GRAPH
% todo: the size of the dot shows the volume, different color a different
% grid hole
figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
set(gcf,'Name','The choice bias: contralesional selection '); hold on; 

for ind_DV = 1:numel(DV)
    ha(ind_DV) = subplot(3,3,ind_DV);
    plot( DataTab.tar_tar_contra , DataTab.([DV{ind_DV},'_prepost']), 'o','color',[0 0 0] ,'MarkerSize',10); hold on;
    %title('Is the choice bias an indicator for the strength of the HR effect?','fontsize',20, 'Interpreter', 'none');
    ylabel( [DV{ind_DV} '(post-pre)'],'fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    xlabel('contralesional selection (post-pre)','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    for ind_Sess = 1: length(DataTab.Session)
        text(DataTab.tar_tar_contra(ind_Sess) , DataTab.([DV{ind_DV},'_prepost'])(ind_Sess),num2str(ind_Sess),'fontsize',10)
    end
end
h = [];
h(1) = figure(1); 
print(h,[path_SaveFig  filesep targetBrainArea '_FreeChoice_Contra_ECG_' ], '-dpng')

%%
figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
set(gcf,'Name','ECG & choice bias: ipsilesional selection '); hold on; 

for ind_DV = 1:numel(DV)
    ha(ind_DV) = subplot(3,3,ind_DV);
    plot( DataTab.tar_tar_ipsi , DataTab.([DV{ind_DV},'_prepost']), 'o','color',[0 0 0] ,'MarkerSize',10); hold on;
    %title('Is the choice bias an indicator for the strength of the HR effect?','fontsize',20, 'Interpreter', 'none');
    ylabel( [DV{ind_DV} '(post-pre)'],'fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    xlabel('ipsilesional selection (post-pre)','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    for ind_Sess = 1: length(DataTab.Session)
        text(DataTab.tar_tar_contra(ind_Sess) , DataTab.([DV{ind_DV},'_prepost'])(ind_Sess),num2str(ind_Sess),'fontsize',10)
    end
end
h = [];
h(1) = figure(1); 
print(h,[path_SaveFig  filesep targetBrainArea '_FreeChoice_Ipsi_ECG' ], '-dpng')

close all;

 
