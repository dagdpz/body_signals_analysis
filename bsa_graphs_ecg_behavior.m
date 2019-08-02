function bsa_graphs_ecg_behavior(monkey,behavior_Data,targetBrainArea,path_SaveFig)

%% ToDO
% add different variables
%%
%load behavior data of the inactivation session
load(behavior_Data)

%load the data of the heartrate & heartrate varibility meassure - each
load(['Y:\Projects\PhysiologicalRecording\Data\' , monkey ,filesep, 'Structure_HeartrateVaribility_PerSessionPerBlock_Inactivation_',targetBrainArea ])

% load session info
%!!!!!!
%% choice bias for each session (post - pre)
% percentage change between pre & post for each session, pool of pre - pool of post
for i_sess = 1: numel( data_struct_per_session.targ_targ.combined.go_signal)
    %Wich variable should I take? How to take into account fixation?
    %true_prop_choice_per_session_left
    %mean_prop_choice_across_runs_left  - true proportion calculated for
    %each run & mean of these
    DataTab.choiceBias_pre(i_sess)  =  data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_left;
    DataTab.choiceBias_post(i_sess)  =  data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_left;

    DataTab.choiceBias(i_sess)  = data_struct_per_session.targ_targ.combined.go_signal{1,i_sess}.mean_prop_choice_across_runs_left- data_struct_per_session.targ_targ.combined.stim_off{1,i_sess}.mean_prop_choice_across_runs_left;
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
set(gcf,'Name','The choice bias '); hold on; 

for ind_DV = 1:numel(DV)
    ha(ind_DV) = subplot(3,3,ind_DV);
    plot( DataTab.choiceBias , DataTab.([DV{ind_DV},'_prepost']), 'o','color',[0 0 0] ,'MarkerSize',10); hold on;
    %title('Is the choice bias an indicator for the strength of the HR effect?','fontsize',20, 'Interpreter', 'none');
    ylabel( [DV{ind_DV} '(post-pre)'],'fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    xlabel('Proportion choice bias (post-pre)','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
    for ind_Sess = 1: length(DataTab.Session)
        text(DataTab.choiceBias(ind_Sess) , DataTab.([DV{ind_DV},'_prepost'])(ind_Sess),num2str(ind_Sess),'fontsize',10)
    end
end
h = [];
h(1) = figure(1); 
print(h,[path_SaveFig  filesep targetBrainArea '_FreeChoice_ECG' ], '-dpng')
close all;

 
