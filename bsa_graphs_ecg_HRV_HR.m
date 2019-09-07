function bsa_graphs_ecg_HRV_HR(monkey,targetBrainArea,path_SaveFig, Stats,Text)
%Todo:
% How to input better all the different datasets
%USAGE:
% bsa_behavior_ECG(monkey,behavior_Data,targetBrainArea,path_SaveFig);
%
% INPUTS:
%		monkey              - Path to session data
%       behavior_Data       - excel file
%       targetBrainArea     - name of the mfile with specific session/monkey settings
%		path_SaveFig        - see % define default arguments and their potential values
%
% OUTPUTS:
%		display & saves graphs
%
% REQUIRES:	Igtools, ext_sigline
%
%
% Author(s):	I.Kagan, DAG, DPZ
% URL:		http://www.dpz.eu/dag
%
% Change log:
% 20190226:	Created function (Igor Kagan)
% ...
% $Revision: 1.0 $  $Date: 2019-02-26 14:22:52 $

% ADDITIONAL INFO:


close all;
%% dorsal pulvinar
load(['Y:\Projects\PhysiologicalRecording\Data\', monkey, filesep,'AllSessions',filesep,monkey '_Structure_HeartrateVaribility_PerSession_Control_' ,targetBrainArea])
load(['Y:\Projects\PhysiologicalRecording\Data\', monkey, filesep,'AllSessions', filesep,monkey '_Structure_HeartrateVaribility_PerSessionPerBlock_Control_',targetBrainArea ])

load(['Y:\Projects\PhysiologicalRecording\Data\', monkey, filesep,'AllSessions',filesep,monkey '_Structure_HeartrateVaribility_PerSessionPerBlock_Inactivation_',targetBrainArea ])
load(['Y:\Projects\PhysiologicalRecording\Data\', monkey, filesep,'AllSessions',filesep,monkey '_Structure_HeartrateVaribility_PerSession_Inactivation_' ,targetBrainArea])
load(['Y:\Projects\PhysiologicalRecording\Data\', monkey, filesep,'AllSessions',filesep,monkey '_Structure_HeartrateVaribility_PerSessionPerBlock_' ,targetBrainArea])


load(['Y:\Projects\PhysiologicalRecording\Data\', monkey, filesep,'AllSessions',filesep,monkey '_Table_MeanForBlock_Task_Control_',targetBrainArea ]);
load(['Y:\Projects\PhysiologicalRecording\Data\', monkey, filesep,'AllSessions',filesep,monkey '_Table_MeanForBlock_Task_Injection_',targetBrainArea ]);


load(['C:\Users\kkaduk\Dropbox\DAG\Kristin\Statistic\body_signal_analysis\', monkey, filesep,monkey ,'_MultComp_PValues_HeartrateVaribility_PerSession_',targetBrainArea ]);
Tabl_MultComp = struct2table(tabl_MultCom_pValues_Data);
DVs =   unique(Tabl_MultComp.Variable);

NoBlocks = 1;
HR_HRV = 1;
%% HR & HRV in Sessions
% 
con_b_col = abs([0.4667    0.6745    0.1882] ); % light green
con_d_col = abs([0.0706    0.2118    0.1412] );
ina_b_col = abs([0          0.7   0.9]);
ina_d_col = abs([0          0    0.9] );

% get the Variable names of all HRV measurements    
HRV_DVs{2} = DVs{find(sum([strcmp(DVs, 'mean_R2R_bpm') , strcmp(DVs, 'median_R2R_bpm')], 2) == 0)} ;
ix = find(sum([strcmp(DVs, 'mean_R2R_bpm') , strcmp(DVs, 'median_R2R_bpm')], 2) == 0);
for ind = 1: length(ix)
HRV_DVs{ind} = DVs{ix(ind)} ; 
end

DeleteOutlier = 0; 
for ind_DV = 1: length(HRV_DVs)
    
     if HR_HRV
         ln = 0; 
        figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
        set(gcf,'Name',HRV_DVs{ind_DV}); hold on;
        count_con= [0 0 0]; count_ina = [0 0 0];  count_c = 1; count_i = 1;
        for I_Ses = 1: length(S_Blocks2)
            [count_con, count_ina, count_c, count_i] = plot_oneVar_secondVar_pre_post_rest_task(S_Blocks2(I_Ses).Experiment, ...
                [S_Blocks2(I_Ses).mean_R2R_bpm],[S_Blocks2(I_Ses).(HRV_DVs{ind_DV})],count_con, count_ina , count_c, count_i ,DeleteOutlier,...
                ln);
            %[Graph, Ymin ,Ymax] =
            % ylabel('mean R2R (bmp)','fontsize',14,'fontweight','b' );
        end
        
        C1 = struct2cell([S_Blocks2(:).mean_R2R_bpm]);
        Xmin = min([C1{2,:,:}, C1{4,:,:}]);
        Xmax = max([C1{2,:,:}, C1{4,:,:}]);
           
        ylabel(char(HRV_DVs{ind_DV}),'fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        xlabel('heart rate (bpm)','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        %% add the mean for over all sessions to the plot
        S_control = [S_con.(HRV_DVs{ind_DV})]; 
        S_inactivation = [S_ina.(HRV_DVs{ind_DV})]; 
        
        line([Xmin,Xmax],[nanmean([S_control.pre_task]),nanmean([S_control.pre_task])],'color',con_b_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[nanmean([S_control.pst_task]),nanmean([S_control.pst_task])],'color',con_d_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[nanmean([S_inactivation.pre_task]),nanmean([S_inactivation.pre_task])],'color',ina_b_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[nanmean([S_inactivation.pst_task]),nanmean([S_inactivation.pst_task])],'color',ina_d_col,'LineWidth',1.5,'LineStyle','--')

        
        h = [];
        h(1) = figure(1);
        print(h,[path_SaveFig filesep 'HR_HRV' filesep targetBrainArea '_', monkey, '_',  HRV_DVs{ind_DV} '_heartrate' ], '-dpng')
        set(h,'Renderer','Painters');
        set(h,'PaperPositionMode','auto')
        compl_filename =  [path_SaveFig filesep 'HR_HRV' filesep targetBrainArea '_', monkey,'_',   HRV_DVs{ind_DV} '_heartrate.ai'] ;
        print(h,'-depsc',compl_filename);
        close all;
        
        %%
        ln = 1; 

        figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
        set(gcf,'Name',HRV_DVs{ind_DV}); hold on;
        count_con= [0 0 0]; count_ina = [0 0 0];  count_c = 1; count_i = 1;
        for I_Ses = 1: length(S_Blocks2)
            [count_con, count_ina, count_c, count_i] = plot_oneVar_secondVar_pre_post_rest_task(S_Blocks2(I_Ses).Experiment, ...
                [S_Blocks2(I_Ses).mean_R2R_bpm],[S_Blocks2(I_Ses).(HRV_DVs{ind_DV})],count_con, count_ina , count_c, count_i ,DeleteOutlier,...
               ln);
        end
        
        C2 = struct2cell([S_Blocks2(:).(HRV_DVs{ind_DV})]);
        Ymin = log(min([C2{2,:,:}, C2{4,:,:}])) ;
        Ymax = log(max([C2{2,:,:}, C2{4,:,:}])) ;
        set(gca,'ylim',[Ymin Ymax]);

        C1 = struct2cell([S_Blocks2(:).mean_R2R_bpm]);
        Xmin = min([C1{2,:,:},C1{4,:,:}]);
        Xmax = max([C1{2,:,:},C1{4,:,:}]);
        mdl = fitlm([C1{2,:,:},C1{4,:,:}],log([C2{2,:,:}, C2{4,:,:}]),'linear', 'RobustOpts', 'off'); 
        plot(mdl)
        %Fitted line
        y1 = mdl.Coefficients.Estimate(1) +      mdl.Coefficients.Estimate(2)*100; 
        y2 = mdl.Coefficients.Estimate(1) +      mdl.Coefficients.Estimate(2)*110; 
        disp(['For 10bpm: ' , HRV_DVs{ind_DV},' ', num2str(y1 - y2)])
        
        ylabel(['ln ' char(HRV_DVs{ind_DV})],'fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        xlabel('heart rate (bpm)','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        %% add the mean for over all sessions to the plot
%         S_control = [S_con.(HRV_DVs{ind_DV})]; 
%         S_inactivation = [S_ina.(HRV_DVs{ind_DV})]; 
%         
%         line([Xmin,Xmax],[nanmean([S_control.pre_task]),nanmean([S_control.pre_task])],'color',con_b_col,'LineWidth',1.5,'LineStyle','--')
%         line([Xmin,Xmax],[nanmean([S_control.pst_task]),nanmean([S_control.pst_task])],'color',con_d_col,'LineWidth',1.5,'LineStyle','--')
%         line([Xmin,Xmax],[nanmean([S_inactivation.pre_task]),nanmean([S_inactivation.pre_task])],'color',ina_b_col,'LineWidth',1.5,'LineStyle','--')
%         line([Xmin,Xmax],[nanmean([S_inactivation.pst_task]),nanmean([S_inactivation.pst_task])],'color',ina_d_col,'LineWidth',1.5,'LineStyle','--')

        
        h = [];
        h(1) = figure(1);
        print(h,[path_SaveFig filesep 'HR_HRV' filesep targetBrainArea '_', monkey, '_ln_',  HRV_DVs{ind_DV} '_heartrate' ], '-dpng')
        set(h,'Renderer','Painters');
        set(h,'PaperPositionMode','auto')
        compl_filename =  [path_SaveFig filesep 'HR_HRV' filesep targetBrainArea '_', monkey,'_ln_',   HRV_DVs{ind_DV} '_heartrate.ai'] ;
        print(h,'-depsc',compl_filename);
        close all;
     end
end
  
 

function [count_con, count_ina, count_c, count_i] =  plot_oneVar_secondVar_pre_post_rest_task(Experiment, Block,Variable, count_con, count_ina, count_c, count_i,DeleteOutlier,  ln)
%[Graph, Ymin ,Ymax] =

count_con= [0 0 0]; count_ina = [0 0 0];


con_b_col = abs([0.4667    0.6745    0.1882] +count_con); % light green
con_d_col = abs([0.0706    0.2118    0.1412] +count_con);
ina_b_col = abs([0          0.7   0.9] +count_ina);
ina_d_col = abs([0          0    0.9] +count_ina);

if DeleteOutlier
    med = median([Variable.pre_task,Variable.pst_task,Variable.pre_rest,Variable.pst_rest]);
    Variable.pre_task(Variable.pre_task > 4*med ) = nan; 
    Variable.pst_task(Variable.pst_task > 4*med ) = nan; 
    Variable.pre_rest(Variable.pre_rest > 5*med ) = nan; 
    Variable.pst_rest(Variable.pst_rest > 5*med ) = nan; 

    disp('Value above 3* std are changed to nan')
end

if ln 
 Y_pre_task =  log([Variable.pre_task]); 
 Y_pst_task =  log([Variable.pst_task]);
 Y_pre_rest =  log( [Variable.pre_rest]);
 Y_pst_rest =  log([Variable.pst_rest]);

else
 Y_pre_task =  [Variable.pre_task]; 
 Y_pst_task =  [Variable.pst_task];
 Y_pre_rest =  [Variable.pre_rest];
 Y_pst_rest =  [Variable.pst_rest];  
end

if  strcmp(Experiment, 'Control')
    plot(  [Block.pre_task],Y_pre_task, 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',con_b_col,'HandleVisibility','off'); hold on;
    plot(  [Block.pst_task],Y_pst_task, 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',con_d_col,'HandleVisibility','off') ;
    
   % plot(  [Block.pre_rest],Y_pre_rest, 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',con_b_col,'HandleVisibility','off'); hold on;
   % plot(  [Block.pst_rest],Y_pst_rest, 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',con_d_col,'HandleVisibility','off') ;

    count_con = count_con + [0 0.15 0.15];
    text([Block.pre_task],Y_pre_task,num2str(count_c),'fontsize',15)
    text([Block.pst_task],Y_pst_task,num2str(count_c),'fontsize',15)
   % text([Block.pre_rest],Y_pre_rest,num2str(count_c),'fontsize',15)
   % text([Block.pst_rest],Y_pst_rest,num2str(count_c),'fontsize',15)
    count_c = count_c +1;
elseif  strcmp(Experiment, 'Injection')
    
    plot(  [Block.pre_task],Y_pre_task, 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',ina_b_col,'HandleVisibility','off'); hold on;
    plot(  [Block.pst_task],Y_pst_task, 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',ina_d_col,'HandleVisibility','off') ;
   % plot(  [Block.pre_rest],[Variable.pre_rest], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',ina_b_col,'HandleVisibility','off'); hold on;
   % plot(  [Block.pst_rest],[Variable.pst_rest], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',ina_d_col,'HandleVisibility','off') ;

    count_ina = count_ina - [0  0.1 0.1];
    
    text([Block.pre_task],Y_pre_task,num2str(count_i),'fontsize',15)
    text([Block.pst_task],Y_pst_task,num2str(count_i),'fontsize',15)
   % text([Block.pre_rest],[Variable.pre_rest],num2str(count_c),'fontsize',15)
   % text([Block.pst_rest],[Variable.pst_rest],num2str(count_c),'fontsize',15)
    count_i = count_i +1;
    
end



