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
load(['Y:\Projects\Pulv_Inac_ECG_respiration\Results\', monkey, filesep,'Inactivation\ECG\AllSessions',filesep,monkey '_MatStruc_HR_HRV_PerSession_Control_' ,targetBrainArea])
load(['Y:\Projects\Pulv_Inac_ECG_respiration\Results\', monkey, filesep,'Inactivation\ECG\AllSessions', filesep,monkey '_MatStruc_HR_HRV_PerSessionPerBlock_Control_',targetBrainArea ])

load(['Y:\Projects\Pulv_Inac_ECG_respiration\Results\', monkey, filesep,'Inactivation\ECG\AllSessions',filesep,monkey '_MatStruc_HR_HRV_PerSessionPerBlock_Inactivation_',targetBrainArea ])
load(['Y:\Projects\Pulv_Inac_ECG_respiration\Results\', monkey, filesep,'Inactivation\ECG\AllSessions',filesep,monkey '_MatStruc_HR_HRV_PerSession_Inactivation_' ,targetBrainArea])
load(['Y:\Projects\Pulv_Inac_ECG_respiration\Results\', monkey, filesep,'Inactivation\ECG\AllSessions',filesep,monkey '_MatStruc_HR_HRV_PerSessionPerBlock_' ,targetBrainArea])


load(['Y:\Projects\Pulv_Inac_ECG_respiration\Results\', monkey, filesep,'Inactivation\ECG\AllSessions',filesep,monkey '_Table_MeanForBlock_Task_Control_',targetBrainArea ]);
load(['Y:\Projects\Pulv_Inac_ECG_respiration\Results\', monkey, filesep,'Inactivation\ECG\AllSessions',filesep,monkey '_Table_MeanForBlock_Task_Injection_',targetBrainArea ]);

if Stats == 0
    names = fieldnames(S_ina);
    DVs =   names(1:6);
else
    load(['C:\Users\kkaduk\Dropbox\DAG\Kristin\Statistic\body_signal_analysis\', monkey, filesep, 'Stats', filesep,monkey ,'_' targetBrainArea, '_ECG_Anova_PostHoc_EffectSize_PerSession' ]);
    Tabl_MultComp = struct2table(emmeans_contrasts);
    DVs =   unique(Tabl_MultComp.depVar);
end


NoBlocks = 1;
HR_HRV = 1;



if ~exist([path_SaveFig  filesep 'HR_HRV'], 'dir');   mkdir([path_SaveFig  filesep 'HR_HRV']); end
if ~exist([path_SaveFig filesep 'HR_HRV' filesep 'png'], 'dir');mkdir([path_SaveFig filesep 'HR_HRV'  filesep 'png']); end
if ~exist([path_SaveFig filesep 'HR_HRV' filesep 'ai'], 'dir');mkdir([path_SaveFig filesep 'HR_HRV'  filesep 'ai']); end


%% HR & HRV in Sessions
%
con_b_col = abs([0.4667    0.6745    0.1882] ); % light green
con_d_col = abs([0.0706    0.2118    0.1412] );
ina_b_col = abs([0          0.7   0.9]);
ina_d_col = abs([0          0    0.9] );

%get the Variable names of all HRV measurements
if Stats
    HRV_DVs{2} = DVs{find(sum([strcmp(DVs, 'mean_R2R_bpm') , strcmp(DVs, 'median_R2R_bpm') , strcmp(DVs, 'rmssd_R2R_ms_Adj') , strcmp(DVs, 'std_R2R_bpm_Adj')], 2) == 0)} ;
    ix = find(sum([strcmp(DVs, 'mean_R2R_bpm') , strcmp(DVs, 'median_R2R_bpm'), strcmp(DVs, 'rmssd_R2R_ms_Adj') , strcmp(DVs, 'std_R2R_bpm_Adj') ], 2) == 0);
    for ind = 1: length(ix)
        HRV_DVs{ind} = DVs{ix(ind)} ;
    end
    st = 3;
    Experiment = 'Inactivation';
    
else
    HRV_DVs = fieldnames(S_con );
    for ind = 5: length(HRV_DVs)
        HRV_DVs{ind} = [];
    end
    st = 1;
    Experiment = 'Ephys';
end

DeleteOutlier = 0;
for ind_DV =  st: length(HRV_DVs)
    
    if HR_HRV
        ln = 0; correctionFactor = 0;
        figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
        ha(1) = subplot(2,2,1);
        
        set(gcf,'Name',HRV_DVs{ind_DV}); hold on;
        count_con= [0 0 0]; count_ina = [0 0 0];  count_c = 1; count_i = 1;
        if strcmp(HRV_DVs{ind_DV}, 'rmssd_R2R_ms')
            for I_Ses = 1: length(S_Blocks2)
                [count_con, count_ina, count_c, count_i] = plot_oneVar_secondVar_pre_post_rest_task(S_Blocks2(I_Ses).Experiment, ...
                    [S_Blocks2(I_Ses).mean_R2R_ms],[S_Blocks2(I_Ses).(HRV_DVs{ind_DV})],count_con, count_ina , count_c, count_i ,DeleteOutlier,...
                    ln,correctionFactor);
            end
                    xlabel('R-R interval (ms)','fontsize',20,'fontweight','b', 'Interpreter', 'none' );
            max_xValue = 700; min_xValue = 250; set(gca,'xlim',[min_xValue max_xValue]);

        elseif  strcmp(HRV_DVs{ind_DV}, 'std_R2R_bpm')
            for I_Ses = 1: length(S_Blocks2)
                [count_con, count_ina, count_c, count_i] = plot_oneVar_secondVar_pre_post_rest_task(S_Blocks2(I_Ses).Experiment, ...
                    [S_Blocks2(I_Ses).mean_R2R_bpm],[S_Blocks2(I_Ses).(HRV_DVs{ind_DV})],count_con, count_ina , count_c, count_i ,DeleteOutlier,...
                    ln,correctionFactor);
            end
                    xlabel('heart rate (bpm)','fontsize',20,'fontweight','b', 'Interpreter', 'none' );

        end
         
        
        if strcmp(monkey, 'Cornelius') || strcmp(monkey, 'Magnus') && strcmp (Experiment, 'Inactivation') && strcmp(HRV_DVs{ind_DV}, 'rmssd_R2R_ms')
            set(gca,'ylim',[0 25])
        elseif strcmp(HRV_DVs{ind_DV}, 'std_R2R_bpm')
            set(gca,'ylim',[0 25])
        end

        C1 = struct2cell([S_Blocks2(:).mean_R2R_bpm]);
        Xmin = min([C1{2,:,:}, C1{4,:,:}]);
        Xmax = max([C1{2,:,:}, C1{4,:,:}]);
        indExp = strcmp([S_Blocks2(:).Experiment], 'Control');
        C2 = struct2cell([S_Blocks2(indExp).(HRV_DVs{ind_DV})]);
        C1 = struct2cell([S_Blocks2(indExp).mean_R2R_bpm]);
        
        if strcmp(monkey , 'Curius') && strcmp(Experiment , 'Inactivation')
            max_xValue =700; min_xValue = 250;            set(gca,'xlim',[min_xValue max_xValue]);
             if strcmp(HRV_DVs{ind_DV}, 'rmssd_R2R_ms')
            max_yValue = 110; min_yValue = 0; set(gca,'ylim',[min_yValue max_yValue]);
             end
        end


%                 FitLineTO = 'Control';
% 
%           if strcmp(FitLineTO, 'AllData')
%             %only task,  pre & post, Control and Injection
%             mdl = fitlm([C1{2,:,:},C1{4,:,:}],log([C2{2,:,:}, C2{4,:,:}]),'linear', 'RobustOpts', 'off');
%             
%         elseif strcmp(FitLineTO, 'Control')
%             %only task,  pre & post, Control and Injection
%             
%             indExp = strcmp([S_Blocks2(:).Experiment], 'Inactivation');
%             C2 = struct2cell([S_Blocks2(indExp).(HRV_DVs{ind_DV})]);
%             C1 = struct2cell([S_Blocks2(indExp).mean_R2R_bpm]);
%             mdl = fitlm([C1{2,:,:},C1{4,:,:}],[C2{2,:,:}, C2{4,:,:}],'linear', 'RobustOpts', 'off');
%             h = plot(mdl)    ;
%             set(h(2:4), 'Color', 'b')
%             correctionFactor_Ina = 10/(abs(mdl.Coefficients.Estimate(2)*10));
%             
%             
%             indExp = strcmp([S_Blocks2(:).Experiment], 'Control');
%             C2 = struct2cell([S_Blocks2(indExp).(HRV_DVs{ind_DV})]);
%             C1 = struct2cell([S_Blocks2(indExp).mean_R2R_bpm]);
%             mdl = fitlm([C1{2,:,:},C1{4,:,:}],[C2{2,:,:}, C2{4,:,:}],'linear', 'RobustOpts', 'off');
%             h = plot(mdl)    ;
%             set(h(2:4), 'Color', 'g')
%             
%             
%             
%         end
%                 correctionFactor_Ctr = 10/(abs(mdl.Coefficients.Estimate(2)*10));
%         disp(['for every 10bpm increase in HR ' , HRV_DVs{ind_DV},' decreases by ', num2str(abs(mdl.Coefficients.Estimate(2)*10))])
%         disp([HRV_DVs{ind_DV}, ': the correction factor used in the formula ' num2str(10/(abs(mdl.Coefficients.Estimate(2)*10)))])
%         text(100,20 ,['for every 10bpm increase in HR ' , HRV_DVs{ind_DV},' decreases by ', num2str(abs(mdl.Coefficients.Estimate(2)*10))],'fontsize',15)
%         title([HRV_DVs{ind_DV}, ': the correction factor  ' num2str(10/(abs(mdl.Coefficients.Estimate(2)*10)))])

        %
        %                 start_point = rand(1, 3);
        % model = @expfun;
        % est = fminsearch(model, start_point);
        % x = [C1{2,:,:},C1{4,:,:}]
        % y = [C2{2,:,:}, C2{4,:,:}]
        %                 f = fit(x,y,'exp1')
        %
        %                 g = fittype('a*exp(-(-x-c)/b)');
        %                % f0 = fit([C1{2,:,:},C1{4,:,:}],[C2{2,:,:}, C2{4,:,:}],g)'StartPoint',[[ones(size([C1{2,:,:},C1{4,:,:}])), -exp(-[C1{2,:,:},C1{4,:,:}])]\[C2{2,:,:}, C2{4,:,:}]; 1]);
        %
        %                % f0 = fit([C1{2,:,:},C1{4,:,:}],[C2{2,:,:}, C2{4,:,:}], 'StartPoint', [][])
        %
        %
        %                     model_exp=  @(phi,t) phi(1)*(exp((phi(2).*t) -phi(3))+phi(3));
        %     % [beta1_percCorrect_expfit,PSI1_percCorrect_expfit,stats1_percCorrect_expfit,b1_percCorrect_expfit]  =  nlmefit(Matrix_Percentage_Corr_Incor_Difference_perWager(:,3),Matrix_Percentage_Corr_Incor_Difference_perWager(:,2),Matrix_Percentage_Corr_Incor_Difference_perWager(:,1),[],model_exp,phi0_exp);
        %
        %                 mdl = fitlm([C1{2,:,:},C1{4,:,:}],log([C2{2,:,:}, C2{4,:,:}]),'linear', 'RobustOpts', 'off');
        
        
        ylabel(char(HRV_DVs{ind_DV}),'fontsize',20,'fontweight','b', 'Interpreter', 'none' );
        %% add the mean for over all sessions to the plot
        S_control = [S_con.(HRV_DVs{ind_DV})];
        S_inactivation = [S_ina.(HRV_DVs{ind_DV})];
        
        line([Xmin,Xmax],[nanmean([S_control.pre_task]),nanmean([S_control.pre_task])],'color',con_b_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[nanmean([S_control.pst_task]),nanmean([S_control.pst_task])],'color',con_d_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[nanmean([S_inactivation.pre_task]),nanmean([S_inactivation.pre_task])],'color',ina_b_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[nanmean([S_inactivation.pst_task]),nanmean([S_inactivation.pst_task])],'color',ina_d_col,'LineWidth',1.5,'LineStyle','--')
        box on;
        
        %
        %         h = [];
        %         h(1) = figure(1);
        %         print(h,[path_SaveFig filesep 'HR_HRV' filesep 'png' filesep targetBrainArea '_', monkey, '_',  HRV_DVs{ind_DV} '_heartrate' ], '-dpng')
        %         set(h,'Renderer','Painters');
        %         set(h,'PaperPositionMode','auto')
        %         compl_filename =  [path_SaveFig filesep 'HR_HRV' filesep 'ai' filesep targetBrainArea '_', monkey,'_',   HRV_DVs{ind_DV} '_heartrate.ai'] ;
        %         print(h,'-depsc',compl_filename);
        %         close all;
        
        %% natural logarithmus for the HRV y-axis to determine the correction factor
        ln = 1;
        ha(2) = subplot(2,2,2);
        %figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
        set(gcf,'Name',HRV_DVs{ind_DV}); hold on;
        count_con= [0 0 0]; count_ina = [0 0 0];  count_c = 1; count_i = 1;
        for I_Ses = 1: length(S_Blocks2)
            [count_con, count_ina, count_c, count_i] = plot_oneVar_secondVar_pre_post_rest_task(S_Blocks2(I_Ses).Experiment, ...
                [S_Blocks2(I_Ses).mean_R2R_bpm],[S_Blocks2(I_Ses).(HRV_DVs{ind_DV})],count_con, count_ina , count_c, count_i ,DeleteOutlier,...
                ln, correctionFactor);
        end
        if strcmp(monkey, 'Cornelius') || strcmp(monkey, 'Magnus') && strcmp (Experiment, 'Inactivation') && strcmp(HRV_DVs{ind_DV}, 'rmssd_R2R_ms')
        set(gca,'ylim',[0 25])
        end
        
        C2 = struct2cell([S_Blocks2(:).(HRV_DVs{ind_DV})]);
        Ymin = log(min([C2{2,:,:}, C2{4,:,:}])) ;
        Ymax = log(max([C2{2,:,:}, C2{4,:,:}])) ;
        set(gca,'ylim',[Ymin Ymax]);
        
        C1 = struct2cell([S_Blocks2(:).mean_R2R_bpm]);
        Xmin = min([C1{2,:,:},C1{4,:,:}]);
        Xmax = max([C1{2,:,:},C1{4,:,:}]);
        
          if strcmp(monkey , 'Curius') && strcmp(Experiment , 'Inactivation')
            max_xValue = 140; min_xValue = 85;
           % max_yValue = 110; min_yValue = 0;
            set(gca,'xlim',[min_xValue max_xValue]);
           % set(gca,'ylim',[min_yValue max_yValue]);
        end
        FitLineTO = 'Control';
        if strcmp(FitLineTO, 'AllData')
            %only task,  pre & post, Control and Injection
            mdl = fitlm([C1{2,:,:},C1{4,:,:}],log([C2{2,:,:}, C2{4,:,:}]),'linear', 'RobustOpts', 'off');
            
        elseif strcmp(FitLineTO, 'Control')
            %only task,  pre & post, Control and Injection
            
            indExp = strcmp([S_Blocks2(:).Experiment], 'Inactivation');
            C2 = struct2cell([S_Blocks2(indExp).(HRV_DVs{ind_DV})]);
            C1 = struct2cell([S_Blocks2(indExp).mean_R2R_bpm]);
            mdl = fitlm([C1{2,:,:},C1{4,:,:}],log([C2{2,:,:}, C2{4,:,:}]),'linear', 'RobustOpts', 'off');
            h = plot(mdl)    ;
            set(h(2:4), 'Color', 'b')
            correctionFactor_Ina = 10/(abs(mdl.Coefficients.Estimate(2)*10));
            
            
            indExp = strcmp([S_Blocks2(:).Experiment], 'Control');
            C2 = struct2cell([S_Blocks2(indExp).(HRV_DVs{ind_DV})]);
            C1 = struct2cell([S_Blocks2(indExp).mean_R2R_bpm]);
            mdl = fitlm([C1{2,:,:},C1{4,:,:}],log([C2{2,:,:}, C2{4,:,:}]),'linear', 'RobustOpts', 'off');
            h = plot(mdl)    ;
            set(h(2:4), 'Color', 'g')
            
            
            
        end
        correctionFactor_Ctr = 10/(abs(mdl.Coefficients.Estimate(2)*10));
        disp(['for every 10bpm increase in HR ' , HRV_DVs{ind_DV},' decreases by ', num2str(abs(mdl.Coefficients.Estimate(2)*10))])
        disp([HRV_DVs{ind_DV}, ': the correction factor used in the formula ' num2str(10/(abs(mdl.Coefficients.Estimate(2)*10)))])
        text(Xmin,Ymax ,['for every 10bpm increase in HR ' , HRV_DVs{ind_DV},' decreases by ', num2str(abs(mdl.Coefficients.Estimate(2)*10))],'fontsize',15)
        
        correctionFactor_Ina = correctionFactor_Ctr;
        
        title([HRV_DVs{ind_DV}, ': the correction factor  ' num2str(10/(abs(mdl.Coefficients.Estimate(2)*10)))])
        ylabel(['ln ' char(HRV_DVs{ind_DV})],'fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        xlabel('heart rate (bpm)','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        set(gca,'ylim',[0 5])
        box on;
        
        %         h = [];
        %         h(1) = figure(1);
        %         print(h,[path_SaveFig filesep 'HR_HRV' filesep 'png' filesep targetBrainArea '_', monkey, '_ln_',  HRV_DVs{ind_DV} '_heartrate' ], '-dpng')
        %         set(h,'Renderer','Painters');
        %         set(h,'PaperPositionMode','auto')
        %         compl_filename =  [path_SaveFig filesep 'HR_HRV' filesep 'ai' filesep targetBrainArea '_', monkey,'_ln_',   HRV_DVs{ind_DV} '_heartrate.ai'] ;
        %         print(h,'-depsc',compl_filename);
        %         close all;
        
        %% corrected HRV
        ha(3) = subplot(2,2,3);
        
        ln = 3;
        %figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
        set(gcf,'Name',HRV_DVs{ind_DV}); hold on;
        count_con= [0 0 0]; count_ina = [0 0 0];  count_c = 1; count_i = 1;
        
        for I_Ses =  find(strcmp([S_Blocks2(:).Experiment], 'Control'))
            
            [count_con, count_ina, count_c, count_i] = plot_oneVar_secondVar_pre_post_rest_task(S_Blocks2(I_Ses).Experiment, ...
                [S_Blocks2(I_Ses).mean_R2R_bpm],[S_Blocks2(I_Ses).(HRV_DVs{ind_DV})],count_con, count_ina , count_c, count_i ,DeleteOutlier,...
                ln, correctionFactor_Ctr);
        end
        for I_Ses =find(strcmp([S_Blocks2(:).Experiment], 'Inactivation'))
            [count_con, count_ina, count_c, count_i] = plot_oneVar_secondVar_pre_post_rest_task(S_Blocks2(I_Ses).Experiment, ...
                [S_Blocks2(I_Ses).mean_R2R_bpm],[S_Blocks2(I_Ses).(HRV_DVs{ind_DV})],count_con, count_ina , count_c, count_i ,DeleteOutlier,...
                ln, correctionFactor_Ina);
        end
        C1 = struct2cell([S_Blocks2(:).mean_R2R_bpm]);
        Xmin = min([C1{2,:,:}, C1{4,:,:}]);
        Xmax = max([C1{2,:,:}, C1{4,:,:}]);
        if strcmp(monkey , 'Curius') && strcmp(Experiment , 'Inactivation')
            max_xValue = 140; min_xValue = 85;
           % max_yValue = 110; min_yValue = 0;
            set(gca,'xlim',[min_xValue max_xValue]);
           % set(gca,'ylim',[min_yValue max_yValue]);
        end
        ylabel(['corrected ', char(HRV_DVs{ind_DV})],'fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        xlabel('heart rate (bpm)','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        %% add the mean for over all sessions to the plot
        
        S_control_HRV = [S_con.(HRV_DVs{ind_DV})];
        S_inactivation_HRV = [S_ina.(HRV_DVs{ind_DV})];
        S_control_HR = [S_con.mean_R2R_bpm];
        S_inactivation_HR = [S_ina.mean_R2R_bpm];
        
        Y_pre_task_Contr = nanmean(bsa_correct_for_HR( [S_control_HR.pre_task],[S_control_HRV.pre_task], correctionFactor_Ctr,0));
        Y_pst_task_Contr = nanmean(bsa_correct_for_HR( [S_control_HR.pst_task],[S_control_HRV.pst_task], correctionFactor_Ctr,0));
        Y_pre_task_Inac = nanmean(bsa_correct_for_HR( [S_inactivation_HR.pre_task],[S_inactivation_HRV.pre_task], correctionFactor_Ina,0));
        Y_pst_task_Inac = nanmean(bsa_correct_for_HR( [S_inactivation_HR.pst_task],[S_inactivation_HRV.pst_task], correctionFactor_Ina,0));
        hold on;
        line([Xmin,Xmax],[Y_pre_task_Contr,Y_pre_task_Contr],'color',con_b_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[Y_pst_task_Contr,Y_pst_task_Contr],'color',con_d_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[Y_pre_task_Inac,Y_pre_task_Inac],'color',ina_b_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[Y_pst_task_Inac,Y_pst_task_Inac],'color',ina_d_col,'LineWidth',1.5,'LineStyle','--')

        box on;
        
        
        %% plot the corrected HRV- data
        ha(4) = subplot(2,2,4);
        if strcmp(HRV_DVs{ind_DV}, 'rmssd_R2R_ms')
            BarGraph_one_var_pre_post_rest_task([S_con.rmssd_R2R_ms_Adj], [S_ina.rmssd_R2R_ms_Adj]);    
        elseif  strcmp(HRV_DVs{ind_DV}, 'std_R2R_bpm')
            BarGraph_one_var_pre_post_rest_task([S_con.std_R2R_bpm], [S_ina.std_R2R_bpm]);
        end
        ylabel(['adjusted ', char(HRV_DVs{ind_DV})],'fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        
        %         if  strcmp(HRV_DVs{ind_DV}, 'adjusted rmssd_R2R_ms')
        %             set(gca,'ylim',[0 400])
        %         elseif strcmp(HRV_DVs{ind_DV}, 'adjusted std_R2R_bpm')
        %             set(gca,'ylim',[0 600])
        %         end
        %
        h = [];
        h(1) = figure(1);
        print(h,[path_SaveFig filesep 'HR_HRV' filesep 'png' filesep targetBrainArea '_', monkey, '_corrected',  HRV_DVs{ind_DV} '_heartrate' ], '-dpng')
        set(h,'Renderer','Painters');
        set(h,'PaperPositionMode','auto')
        compl_filename =  [path_SaveFig filesep 'HR_HRV' filesep 'ai' filesep targetBrainArea '_', monkey,'_corrected',   HRV_DVs{ind_DV} '_heartrate.ai'] ;
        print(h,'-depsc',compl_filename);
        close all;
        
    end
end

function BarGraph_one_var_pre_post_rest_task( S_con,S_ina)
MarkerSize_EachSession = 15;

con_b_col = [0.4667    0.6745    0.1882];
con_d_col = [0.0706    0.2118    0.1412];
ina_b_col = [0          0.7   0.9];
ina_d_col = [0          0    0.9];



ig_bar_mean_se(1,[S_con.pre_rest],'sterr','FaceColor',con_b_col,'EdgeColor',con_b_col);
plot(  1, [S_con.pre_rest], '.','color',[0 0 0 ] ,'MarkerSize',MarkerSize_EachSession) ; hold on;

ig_bar_mean_se(2,[S_con.pst_rest],'sterr','FaceColor',con_d_col,'EdgeColor',con_d_col);
plot(  2, [S_con.pst_rest], '.','color',[0 0 0 ] ,'MarkerSize',MarkerSize_EachSession) ; hold on;

ig_bar_mean_se(3,[S_con.pre_task],'sterr','FaceColor',con_b_col,'EdgeColor',con_b_col);
plot(  3, [S_con.pre_task], '.','color',[0 0 0 ] ,'MarkerSize',MarkerSize_EachSession) ; hold on;

ig_bar_mean_se(4,[S_con.pst_task],'sterr','FaceColor',con_d_col,'EdgeColor',con_d_col);
plot( 4, [S_con.pst_task], '.','color',[0 0 0 ] ,'MarkerSize',MarkerSize_EachSession) ; hold on;


ig_bar_mean_se(6,[S_ina.pre_rest],'sterr','FaceColor',ina_b_col,'EdgeColor',ina_b_col);
plot( 6, [S_ina.pre_rest], '.','color',[0 0 0 ] ,'MarkerSize',MarkerSize_EachSession) ; hold on;

ig_bar_mean_se(7,[S_ina.pst_rest],'sterr','FaceColor',ina_d_col,'EdgeColor',ina_d_col);
plot(  7, [S_ina.pst_rest], '.','color',[0 0 0 ] ,'MarkerSize',MarkerSize_EachSession) ; hold on;

ig_bar_mean_se(8,[S_ina.pre_task],'sterr','FaceColor',ina_b_col,'EdgeColor',ina_b_col);
plot(  8, [S_ina.pre_task], '.','color',[0 0 0 ] ,'MarkerSize',MarkerSize_EachSession) ; hold on;

ig_bar_mean_se(9,[S_ina.pst_task],'sterr','FaceColor',ina_d_col,'EdgeColor',ina_d_col);
plot(  9, [S_ina.pst_task], '.','color',[0 0 0 ] ,'MarkerSize',MarkerSize_EachSession) ; hold on;


set(gca,'xlim',[0 10],'Xtick',[1:4 6:9],'XTickLabel',{'pre' 'post' 'pre' 'post' 'pre' 'post' 'pre' 'post'}, 'FontSize', 15);
function [count_con, count_ina, count_c, count_i] =  plot_oneVar_secondVar_pre_post_rest_task(Experiment, Block,Variable, count_con, count_ina, count_c, count_i,DeleteOutlier,  ln, CF)
%[Graph, Ymin ,Ymax] =
markerSize = 12; 
count_con= [0 0 0]; count_ina = [0 0 0];


con_b_col = abs([0.4667    0.6745    0.1882] +count_con); % light green
con_d_col = abs([0.0706    0.2118    0.1412] +count_con);
ina_b_col = abs([0          0.7   0.9] +count_ina);
ina_d_col = abs([0          0    0.9] +count_ina);

if DeleteOutlier
    med = median([Variable.pre_task,Variable.pst_task,Variable.pre_rest,Variable.pst_rest]);
    
    Variable.pre_task(Variable.pre_task > 4*med ) = nan;
    Variable.pst_task(Variable.pst_task > 4*med ) = nan;
    Variable.pre_rest(Variable.pre_rest > 4*med ) = nan;
    Variable.pst_rest(Variable.pst_rest > 4*med ) = nan;
    if sum(isnan([ Variable.pre_task,Variable.pst_task,Variable.pre_rest , Variable.pst_rest])) > 0
        disp('Value above 4* std are changed to nan')
    end
end

if ln == 1
    Y_pre_task =  log([Variable.pre_task]);
    Y_pst_task =  log([Variable.pst_task]);
    Y_pre_rest =  log( [Variable.pre_rest]);
    Y_pst_rest =  log([Variable.pst_rest]);
    
elseif ln == 0
    Y_pre_task =  [Variable.pre_task];
    Y_pst_task =  [Variable.pst_task];
    Y_pre_rest =  [Variable.pre_rest];
    Y_pst_rest =  [Variable.pst_rest];
else
    Y_pre_task = bsa_correct_for_HR( [Block.pre_task],[Variable.pre_task], CF,0);
    Y_pst_task = bsa_correct_for_HR( [Block.pst_task],[Variable.pst_task], CF,0);
    Y_pre_rest = bsa_correct_for_HR( [Block.pre_rest],[Variable.pre_rest], CF,0);
    Y_pst_rest = bsa_correct_for_HR( [Block.pst_rest],[Variable.pst_rest], CF,0);
    
end

if  strcmp(Experiment, 'Control')
    plot(  [Block.pre_task],Y_pre_task, 'o','color',con_b_col ,'MarkerSize',markerSize,'markerfacecolor',con_b_col,'HandleVisibility','off'); hold on;
    plot(  [Block.pst_task],Y_pst_task, 'o','color',con_d_col ,'MarkerSize',markerSize,'markerfacecolor',con_d_col,'HandleVisibility','off') ;
    
   %  plot(  [Block.pre_rest],Y_pre_rest, 'o','color',con_b_col ,'MarkerSize',markerSize,'markerfacecolor',con_b_col,'HandleVisibility','off'); hold on;
   %  plot(  [Block.pst_rest],Y_pst_rest, 'o','color',con_d_col ,'MarkerSize',markerSize,'markerfacecolor',con_d_col,'HandleVisibility','off') ;
    
    count_con = count_con + [0 0.15 0.15];
    % text([Block.pre_task],Y_pre_task,num2str(count_c),'fontsize',15)
    %text([Block.pst_task],Y_pst_task,num2str(count_c),'fontsize',15)
    % text([Block.pre_rest],Y_pre_rest,num2str(count_c),'fontsize',15)
    % text([Block.pst_rest],Y_pst_rest,num2str(count_c),'fontsize',15)
    count_c = count_c +1;
elseif  strcmp(Experiment, 'Inactivation')
    
    plot(  [Block.pre_task],Y_pre_task, 'o','color',ina_b_col ,'MarkerSize',markerSize,'markerfacecolor',ina_b_col,'HandleVisibility','off'); hold on;
    plot(  [Block.pst_task],Y_pst_task, 'o','color',ina_d_col ,'MarkerSize',markerSize,'markerfacecolor',ina_d_col,'HandleVisibility','off') ;
   % plot(  [Block.pre_rest],Y_pre_rest, 'o','color',ina_b_col ,'MarkerSize',markerSize,'markerfacecolor',ina_b_col,'HandleVisibility','off'); hold on;
   % plot(  [Block.pst_rest],Y_pst_rest, 'o','color',ina_d_col ,'MarkerSize',markerSize,'markerfacecolor',ina_d_col,'HandleVisibility','off') ;
    
    count_ina = count_ina - [0  0.1 0.1];
    
    % text([Block.pre_task],Y_pre_task,num2str(count_i),'fontsize',15)
    % text([Block.pst_task],Y_pst_task,num2str(count_i),'fontsize',15)
    % text([Block.pre_rest],[Variable.pre_rest],num2str(count_c),'fontsize',15)
    % text([Block.pst_rest],[Variable.pst_rest],num2str(count_c),'fontsize',15)
    count_i = count_i +1;
    
elseif  strcmp(Experiment, 'Both')
    plot(  [Block.pre_task],Y_pre_task, 'o','color',[0 0 0] ,'MarkerSize',15,'markerfacecolor',con_b_col,'HandleVisibility','off'); hold on;
    plot(  [Block.pst_task],Y_pst_task, 'o','color',[0 0 0] ,'MarkerSize',15,'markerfacecolor',con_d_col,'HandleVisibility','off') ;
   % plot(  [Block.pre_task],Y_pre_task, 'o','color',[0 0 0] ,'MarkerSize',15,'markerfacecolor',ina_b_col,'HandleVisibility','off'); hold on;
  %  plot(  [Block.pst_task],Y_pst_task, 'o','color',[0 0 0] ,'MarkerSize',15,'markerfacecolor',ina_d_col,'HandleVisibility','off') ;
    % plot(  [Block.pre_rest],[Variable.pre_rest], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',ina_b_col,'HandleVisibility','off'); hold on;
    
    count_con = count_con + [0 0.15 0.15];
    
    
end



