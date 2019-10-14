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



        if ~exist([path_SaveFig  filesep 'HR_HRV'], 'dir');   mkdir([path_SaveFig  filesep 'HR_HRV']); end
        if ~exist([path_SaveFig filesep 'HR_HRV' filesep 'png'], 'dir');mkdir([path_SaveFig filesep 'HR_HRV'  filesep 'png']); end
        if ~exist([path_SaveFig filesep 'HR_HRV' filesep 'ai'], 'dir');mkdir([path_SaveFig filesep 'HR_HRV'  filesep 'ai']); end


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

DeleteOutlier = 1; 
for ind_DV =  3: length(HRV_DVs)
    
     if HR_HRV
         ln = 0; correctionFactor = 0; 
        figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
        set(gcf,'Name',HRV_DVs{ind_DV}); hold on;
        count_con= [0 0 0]; count_ina = [0 0 0];  count_c = 1; count_i = 1;
        for I_Ses = 1: length(S_Blocks2)
            [count_con, count_ina, count_c, count_i] = plot_oneVar_secondVar_pre_post_rest_task(S_Blocks2(I_Ses).Experiment, ...
                [S_Blocks2(I_Ses).mean_R2R_bpm],[S_Blocks2(I_Ses).(HRV_DVs{ind_DV})],count_con, count_ina , count_c, count_i ,DeleteOutlier,...
                ln,correctionFactor);
            %[Graph, Ymin ,Ymax] =
            % ylabel('mean R2R (bmp)','fontsize',14,'fontweight','b' );
        end
        
        C1 = struct2cell([S_Blocks2(:).mean_R2R_bpm]);
        Xmin = min([C1{2,:,:}, C1{4,:,:}]);
        Xmax = max([C1{2,:,:}, C1{4,:,:}]);
                 indExp = strcmp([S_Blocks2(:).Experiment], 'Control'); 
                C2 = struct2cell([S_Blocks2(indExp).(HRV_DVs{ind_DV})]);
                C1 = struct2cell([S_Blocks2(indExp).mean_R2R_bpm]);
               
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
        xlabel('heart rate (bpm)','fontsize',20,'fontweight','b', 'Interpreter', 'none' );
        %% add the mean for over all sessions to the plot
        S_control = [S_con.(HRV_DVs{ind_DV})]; 
        S_inactivation = [S_ina.(HRV_DVs{ind_DV})]; 
        
        line([Xmin,Xmax],[nanmean([S_control.pre_task]),nanmean([S_control.pre_task])],'color',con_b_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[nanmean([S_control.pst_task]),nanmean([S_control.pst_task])],'color',con_d_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[nanmean([S_inactivation.pre_task]),nanmean([S_inactivation.pre_task])],'color',ina_b_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[nanmean([S_inactivation.pst_task]),nanmean([S_inactivation.pst_task])],'color',ina_d_col,'LineWidth',1.5,'LineStyle','--')

        
        h = [];
        h(1) = figure(1);
        print(h,[path_SaveFig filesep 'HR_HRV' filesep 'png' filesep targetBrainArea '_', monkey, '_',  HRV_DVs{ind_DV} '_heartrate' ], '-dpng')
        set(h,'Renderer','Painters');
        set(h,'PaperPositionMode','auto')
        compl_filename =  [path_SaveFig filesep 'HR_HRV' filesep 'ai' filesep targetBrainArea '_', monkey,'_',   HRV_DVs{ind_DV} '_heartrate.ai'] ;
        print(h,'-depsc',compl_filename);
        close all;
        
        %% natural logarithmus for the HRV y-axis to determine the correction factor
        ln = 1; 
        figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
        set(gcf,'Name',HRV_DVs{ind_DV}); hold on;
        count_con= [0 0 0]; count_ina = [0 0 0];  count_c = 1; count_i = 1;
        for I_Ses = 1: length(S_Blocks2)
            [count_con, count_ina, count_c, count_i] = plot_oneVar_secondVar_pre_post_rest_task(S_Blocks2(I_Ses).Experiment, ...
                [S_Blocks2(I_Ses).mean_R2R_bpm],[S_Blocks2(I_Ses).(HRV_DVs{ind_DV})],count_con, count_ina , count_c, count_i ,DeleteOutlier,...
               ln, correctionFactor);
        end
        
        
        C2 = struct2cell([S_Blocks2(:).(HRV_DVs{ind_DV})]);
        Ymin = log(min([C2{2,:,:}, C2{4,:,:}])) ;
        Ymax = log(max([C2{2,:,:}, C2{4,:,:}])) ;
        set(gca,'ylim',[Ymin Ymax]);

        C1 = struct2cell([S_Blocks2(:).mean_R2R_bpm]);
        Xmin = min([C1{2,:,:},C1{4,:,:}]);
        Xmax = max([C1{2,:,:},C1{4,:,:}]);
        FitLineTO = 'Control'; 
        if strcmp(FitLineTO, 'AllData')
            %only task,  pre & post, Control and Injection
            mdl = fitlm([C1{2,:,:},C1{4,:,:}],log([C2{2,:,:}, C2{4,:,:}]),'linear', 'RobustOpts', 'off');
            
        elseif strcmp(FitLineTO, 'Control')
            %only task,  pre & post, Control and Injection
            
            indExp = strcmp([S_Blocks2(:).Experiment], 'Injection');
            C2 = struct2cell([S_Blocks2(indExp).(HRV_DVs{ind_DV})]);
            C1 = struct2cell([S_Blocks2(indExp).mean_R2R_bpm]);
            mdl = fitlm([C1{2,:,:},C1{4,:,:}],log([C2{2,:,:}, C2{4,:,:}]),'linear', 'RobustOpts', 'off');
            h = plot(mdl)    ;
            set(h(2:4), 'Color', 'b')
            
            indExp = strcmp([S_Blocks2(:).Experiment], 'Control');
            C2 = struct2cell([S_Blocks2(indExp).(HRV_DVs{ind_DV})]);
            C1 = struct2cell([S_Blocks2(indExp).mean_R2R_bpm]);
            mdl = fitlm([C1{2,:,:},C1{4,:,:}],log([C2{2,:,:}, C2{4,:,:}]),'linear', 'RobustOpts', 'off');
            h = plot(mdl)    ;
            set(h(2:4), 'Color', 'g')
             

            
        end
        correctionFactor = 10/(abs(mdl.Coefficients.Estimate(2)*10));
            disp(['for every 10bpm increase in HR ' , HRV_DVs{ind_DV},' decreases by ', num2str(abs(mdl.Coefficients.Estimate(2)*10))])
            disp([HRV_DVs{ind_DV}, ': the correction factor used in the formula ' num2str(10/(abs(mdl.Coefficients.Estimate(2)*10)))])
            text(Xmin,Ymax ,['for every 10bpm increase in HR ' , HRV_DVs{ind_DV},' decreases by ', num2str(abs(mdl.Coefficients.Estimate(2)*10))],'fontsize',15)
           

        
        title([HRV_DVs{ind_DV}, ': the correction factor  ' num2str(10/(abs(mdl.Coefficients.Estimate(2)*10)))])
        ylabel(['ln ' char(HRV_DVs{ind_DV})],'fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        xlabel('heart rate (bpm)','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        set(gca,'ylim',[0 5])
        h = [];
        h(1) = figure(1);
        print(h,[path_SaveFig filesep 'HR_HRV' filesep 'png' filesep targetBrainArea '_', monkey, '_ln_',  HRV_DVs{ind_DV} '_heartrate' ], '-dpng')
        set(h,'Renderer','Painters');
        set(h,'PaperPositionMode','auto')
        compl_filename =  [path_SaveFig filesep 'HR_HRV' filesep 'ai' filesep targetBrainArea '_', monkey,'_ln_',   HRV_DVs{ind_DV} '_heartrate.ai'] ;
        print(h,'-depsc',compl_filename);
        close all;
        
      %% corrected HRV
      
        ln = 3; 
        figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
        set(gcf,'Name',HRV_DVs{ind_DV}); hold on;
        count_con= [0 0 0]; count_ina = [0 0 0];  count_c = 1; count_i = 1;
        for I_Ses = 1: length(S_Blocks2)
            [count_con, count_ina, count_c, count_i] = plot_oneVar_secondVar_pre_post_rest_task(S_Blocks2(I_Ses).Experiment, ...
                [S_Blocks2(I_Ses).mean_R2R_bpm],[S_Blocks2(I_Ses).(HRV_DVs{ind_DV})],count_con, count_ina , count_c, count_i ,DeleteOutlier,...
                ln, correctionFactor);
            %[Graph, Ymin ,Ymax] =
            % ylabel('mean R2R (bmp)','fontsize',14,'fontweight','b' );
        end
        
        C1 = struct2cell([S_Blocks2(:).mean_R2R_bpm]);
        Xmin = min([C1{2,:,:}, C1{4,:,:}]);
        Xmax = max([C1{2,:,:}, C1{4,:,:}]);
           
        ylabel(['corrected ', char(HRV_DVs{ind_DV})],'fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        xlabel('heart rate (bpm)','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        %% add the mean for over all sessions to the plot

        S_control_HRV = [S_con.(HRV_DVs{ind_DV})]; 
        S_inactivation_HRV = [S_ina.(HRV_DVs{ind_DV})]; 
        S_control_HR = [S_con.mean_R2R_bpm]; 
        S_inactivation_HR = [S_ina.mean_R2R_bpm]; 
        

Y_pre_task_Contr = nanmean(bsa_correct_for_HR( [S_control_HR.pre_task],[S_control_HRV.pre_task], correctionFactor,0));
Y_pst_task_Contr = nanmean(bsa_correct_for_HR( [S_control_HR.pst_task],[S_control_HRV.pst_task], correctionFactor,0));
Y_pre_task_Inac = nanmean(bsa_correct_for_HR( [S_inactivation_HR.pre_task],[S_inactivation_HRV.pre_task], correctionFactor,0));
Y_pst_task_Inac = nanmean(bsa_correct_for_HR( [S_inactivation_HR.pst_task],[S_inactivation_HRV.pst_task], correctionFactor,0));
 hold on; 
        line([Xmin,Xmax],[Y_pre_task_Contr,Y_pre_task_Contr],'color',con_b_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[Y_pst_task_Contr,Y_pst_task_Contr],'color',con_d_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[Y_pre_task_Inac,Y_pre_task_Inac],'color',ina_b_col,'LineWidth',1.5,'LineStyle','--')
        line([Xmin,Xmax],[Y_pst_task_Inac,Y_pst_task_Inac],'color',ina_d_col,'LineWidth',1.5,'LineStyle','--')

        
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
  
 

function [count_con, count_ina, count_c, count_i] =  plot_oneVar_secondVar_pre_post_rest_task(Experiment, Block,Variable, count_con, count_ina, count_c, count_i,DeleteOutlier,  ln, CF)
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
    plot(  [Block.pre_task],Y_pre_task, 'o','color',[0 0 0] ,'MarkerSize',15,'markerfacecolor',con_b_col,'HandleVisibility','off'); hold on;
    plot(  [Block.pst_task],Y_pst_task, 'o','color',[0 0 0] ,'MarkerSize',15,'markerfacecolor',con_d_col,'HandleVisibility','off') ;
    
   % plot(  [Block.pre_rest],Y_pre_rest, 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',con_b_col,'HandleVisibility','off'); hold on;
   % plot(  [Block.pst_rest],Y_pst_rest, 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',con_d_col,'HandleVisibility','off') ;

    count_con = count_con + [0 0.15 0.15];
   % text([Block.pre_task],Y_pre_task,num2str(count_c),'fontsize',15)
   %text([Block.pst_task],Y_pst_task,num2str(count_c),'fontsize',15)
   % text([Block.pre_rest],Y_pre_rest,num2str(count_c),'fontsize',15)
   % text([Block.pst_rest],Y_pst_rest,num2str(count_c),'fontsize',15)
    count_c = count_c +1;
elseif  strcmp(Experiment, 'Injection')
    
    plot(  [Block.pre_task],Y_pre_task, 'o','color',[0 0 0] ,'MarkerSize',15,'markerfacecolor',ina_b_col,'HandleVisibility','off'); hold on;
    plot(  [Block.pst_task],Y_pst_task, 'o','color',[0 0 0] ,'MarkerSize',15,'markerfacecolor',ina_d_col,'HandleVisibility','off') ;
   % plot(  [Block.pre_rest],[Variable.pre_rest], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',ina_b_col,'HandleVisibility','off'); hold on;
   % plot(  [Block.pst_rest],[Variable.pst_rest], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',ina_d_col,'HandleVisibility','off') ;

    count_ina = count_ina - [0  0.1 0.1];
    
   % text([Block.pre_task],Y_pre_task,num2str(count_i),'fontsize',15)
   % text([Block.pst_task],Y_pst_task,num2str(count_i),'fontsize',15)
   % text([Block.pre_rest],[Variable.pre_rest],num2str(count_c),'fontsize',15)
   % text([Block.pst_rest],[Variable.pst_rest],num2str(count_c),'fontsize',15)
    count_i = count_i +1;
    
end



