function bsa_graphs_ecg(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR,Text)
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

if Stats_beforeComputedWithR == 0
 names = fieldnames(S_ina); 
 DVs =   names(1:6); 
else
load(['C:\Users\kkaduk\Dropbox\DAG\Kristin\Statistic\body_signal_analysis\', monkey, filesep,monkey ,'_MultComp_PValues_HeartrateVaribility_PerSession_',targetBrainArea ]);
Tabl_MultComp = struct2table(tabl_MultCom_pValues_Data);
DVs =   unique(Tabl_MultComp.Variable);
end
NoBlocks = 1;


        if ~exist(path_SaveFig);   mkdir(path_SaveFig); end
        if ~exist([path_SaveFig filesep 'png']);mkdir([path_SaveFig filesep 'png']); end
        if ~exist([path_SaveFig filesep 'ai']);mkdir([path_SaveFig filesep 'ai']); end


 Stat = [];   
  for ind_DV = 1: length(DVs)  
    %% Blocks
    if NoBlocks
        figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
        set(gcf,'Name',DVs{ind_DV}); hold on;
        count_con= [0 0 0]; count_ina = [0 0 0];  count_c = 1; count_i = 1;
        for I_Ses = 1: length(S_Blocks2)
            [count_con, count_ina, count_c, count_i] = plot_oneVar_Block_pre_post_rest_task(S_Blocks2(I_Ses).Experiment, [S_Blocks2(I_Ses).Block],[S_Blocks2(I_Ses).(DVs{ind_DV})],count_con, count_ina , count_c, count_i );
            %[Graph, Ymin ,Ymax] =
            % ylabel('mean R2R (bmp)','fontsize',14,'fontweight','b' );
        end
        
        C1 = struct2cell([S_Blocks2(I_Ses).(DVs{ind_DV})]);
        Ymin = min([C1{:}]);
        Ymax = max([C1{:}]);
        
        line([3.5 3.5],[Ymin Ymax],'Color',[0 0 0],'HandleVisibility','off')
        %text(3.5,Ymax -10,'Inactivation','fontsize',15)
        
        MeanForBlock_Task_Control_Task            = MeanForBlock_Task_Control(strcmp( MeanForBlock_Task_Control.Condition , 'pre_task'),:);
        MeanForBlock_Task_Control_Task            = [MeanForBlock_Task_Control_Task; MeanForBlock_Task_Control(strcmp( MeanForBlock_Task_Control.Condition , 'pst_task'),:)];
        MeanForBlock_Task_Injection_Task          = MeanForBlock_Task_Injection(strcmp( MeanForBlock_Task_Injection.Condition , 'pre_task'),:);
        Table_MeanForBlock_Task_Injection_Task    = [MeanForBlock_Task_Injection_Task; MeanForBlock_Task_Injection(strcmp( MeanForBlock_Task_Injection.Condition , 'pst_task'),:)];
        
        % eine Funktion die zuerst Control plotted se
        VarName = [ 'mean_', DVs{ind_DV}] ;
        plot_oneVarMean_Block_pre_post_rest_task( MeanForBlock_Task_Control_Task.Experiment(1), 1: length(MeanForBlock_Task_Control_Task.NrBlock_BasedCondition),[MeanForBlock_Task_Control_Task.(VarName)]);
        plot_oneVarMean_Block_pre_post_rest_task( Table_MeanForBlock_Task_Injection_Task.Experiment(1), 1: length(Table_MeanForBlock_Task_Injection_Task.NrBlock_BasedCondition),[Table_MeanForBlock_Task_Injection_Task.(VarName)]);
        
        
        Name_DV = strsplit(char(DVs{ind_DV}), '_');
        title(char(DVs{ind_DV}),'fontsize',20, 'Interpreter', 'none');
        ylabel(char(DVs{ind_DV}),'fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        xlabel('Blocks','fontsize',14,'fontweight','b', 'Interpreter', 'none' );
        
        
        
        h = [];
        h(1) = figure(1);
        


        print(h,[path_SaveFig filesep 'png' filesep targetBrainArea '_', monkey, '_',  DVs{ind_DV} '_Blocks_' ], '-dpng')
        set(h,'Renderer','Painters');
        set(h,'PaperPositionMode','auto')
        compl_filename =  [path_SaveFig filesep 'ai' filesep targetBrainArea '_', monkey, '_',  DVs{ind_DV} '_Blocks.ai'] ;
        print(h,'-depsc',compl_filename);
        close all;
    end
    
    
    %% Session - task
    Stat = []; 
    figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
    set(gcf,'Name',DVs{ind_DV});
    [Graph, Ymin ,Ymax] =  plot_one_var_pre_post_rest_task([S_con.(DVs{ind_DV})],[S_ina.(DVs{ind_DV})]);
    % ylabel('mean R2R (bmp)','fontsize',14,'fontweight','b' );
    Name_DV = strsplit(char(DVs{ind_DV}), '_');
    %title(char(DVs{ind_DV}),'fontsize',20, 'Interpreter', 'none');
    ylabel(char(DVs{ind_DV}),'fontsize',26,'fontweight','b' , 'Interpreter', 'none');
    
    max_yValue = Ymax*1.13;  %Ymax+80
    min_yValue = Ymin*0.93;   %Ymax-20
    Y_C(1) = max_yValue -50;
    Y_C(2) = max_yValue -60;
    Y_C(3) = max_yValue -80;
    Y_C(4) = max_yValue -80;
    
    if strcmp(DVs{ind_DV} , 'mean_R2R_bpm')
        yaxis = 'heart rate (bpm)';
        ylabel(yaxis,'fontsize',26,'fontweight','b' , 'Interpreter', 'none');
        max_yValue = Ymax+40;
        min_yValue = Ymin -10;
        Y_C(1) = max_yValue -40;
        Y_C(2) = max_yValue -45;
        Y_C(3) = max_yValue -50;
        Y_C(4) = max_yValue -50;
   elseif    strcmp(DVs{ind_DV} , 'rmssd_R2R_ms')
        yaxis = 'RMSSD of R2R (ms)';
        ylabel(yaxis,'fontsize',26,'fontweight','b' , 'Interpreter', 'none');
        Y_C(1) = max_yValue *0.56;
        Y_C(2) = max_yValue *0.53;
        Y_C(3) = max_yValue *0.5;
        Y_C(4) = max_yValue *0.5;
      elseif    strcmp(DVs{ind_DV} , 'std_R2R_bpm')
        yaxis = 'std of R2R (bpm)';
        ylabel(yaxis,'fontsize',26,'fontweight','b' , 'Interpreter', 'none');
        Y_C(1) = max_yValue *0.56;
        Y_C(2) = max_yValue *0.53;
        Y_C(3) = max_yValue *0.5;
        Y_C(4) = max_yValue *0.5;
    elseif strcmp(DVs{ind_DV} , 'hfPower') && strcmp(monkey , 'Curius')
        Y_C(1) = max_yValue *0.56;
        Y_C(2) = max_yValue *0.53;
        Y_C(3) = max_yValue *0.5;
        Y_C(4) = max_yValue *0.5;
    end
     if min_yValue < 0; min_yValue = 0; end;
        set(gca,'ylim',[min_yValue max_yValue]);
    if Text
       
        
        text(1.5 ,max_yValue -10,'Control','fontsize',20)
        text(1 ,max_yValue -20,'rest','fontsize',15)
        text(3 ,max_yValue -20,'task','fontsize',15)
        
        text(6.5,max_yValue -10,'Injection','fontsize',20)
        text(6 ,max_yValue -20,'rest','fontsize',15)
        text(8 ,max_yValue -20,'task','fontsize',15)
    end
    if Stats_beforeComputedWithR(1) == 1  
        if  Stats_beforeComputedWithR(2)  == 3
        % add STATISTIC: line for the comparison && stars for significance
        Stat = Tabl_MultComp(strcmp(Tabl_MultComp.Variable, DVs{ind_DV}),:);
        Row(1) =find(sum([strcmp(Stat.Comparison1, 'Control,pre,task'), strcmp(Stat.Comparison2, 'Injection,pre,task')],2)== 2);
        Row(2) =find(sum([strcmp(Stat.Comparison1, 'Control,pst,task'), strcmp(Stat.Comparison2, 'Injection,pst,task')],2)== 2);
        Row(3) =find(sum([strcmp(Stat.Comparison1, 'Injection,pre,task'), strcmp(Stat.Comparison2, 'Injection,pst,task')],2)== 2);
        Row(4) =find(sum([strcmp(Stat.Comparison1, 'Control,pre,task'), strcmp(Stat.Comparison2, 'Control,pst,task')],2)== 2);
        
      
    elseif  Stats_beforeComputedWithR(2)  == 2
         Stat = Tabl_MultComp(strcmp(Tabl_MultComp.Variable, DVs{ind_DV}),:);
        Row(1) =find(sum([strcmp(Stat.Comparison1, 'Control,pre'), strcmp(Stat.Comparison2, 'Injection,pre'), strcmp(Stat.Tasktype, 'task') ],2)== 3);
        Row(2) =find(sum([strcmp(Stat.Comparison1, 'Control,pst'), strcmp(Stat.Comparison2, 'Injection,pst'), strcmp(Stat.Tasktype, 'task')],2)== 3);
        Row(3) =find(sum([strcmp(Stat.Comparison1, 'Injection,pre'), strcmp(Stat.Comparison2, 'Injection,pst'), strcmp(Stat.Tasktype, 'task')],2)== 3);
        Row(4) =find(sum([strcmp(Stat.Comparison1, 'Control,pre'), strcmp(Stat.Comparison2, 'Control,pst'), strcmp(Stat.Tasktype, 'task')],2)== 3);
        
    end
    disp(DVs{ind_DV})
        disp(Stat(Row,:)); 
        Contrast(1,:) = [3,8];
        Contrast(2,:) = [4,9];
        Contrast(3,:) = [8,9];
        Contrast(4,:) = [3,4];
        
        for NrContrasts = 1: 4
            ext_sigline(Contrast(NrContrasts,:),char(Stat.Star(Row(NrContrasts))),Y_C(NrContrasts)); hold on;
        end
    end
    h = [];
    h(1) = figure(1);
    print(h,[path_SaveFig filesep 'png' filesep targetBrainArea '_' monkey '_', DVs{ind_DV} '_TaskStats'], '-dpng')
    set(h,'Renderer','Painters');
    set(h,'PaperPositionMode','auto')
    compl_filename =  [path_SaveFig  filesep targetBrainArea '_' monkey, '_' DVs{ind_DV} '_TaskStats.ai'] ;
    print(h,'-depsc',compl_filename);
    close all;
    
    
    %% Session - Rest
    figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
    set(gcf,'Name',DVs{ind_DV});
    [Graph, Ymin ,Ymax] =  plot_one_var_pre_post_rest_task([S_con.(DVs{ind_DV})],[S_ina.(DVs{ind_DV})]);
    % ylabel('mean R2R (bmp)','fontsize',14,'fontweight','b' );
    Name_DV = strsplit(char(DVs{ind_DV}), '_');
   % title(char(DVs{ind_DV}),'fontsize',20, 'Interpreter', 'none');
    ylabel(char(DVs{ind_DV}),'fontsize',20,'fontweight','b' , 'Interpreter', 'none');
    
    
    max_yValue = Ymax*1.13;  %Ymax+80
    min_yValue = Ymin*0.93;   %Ymax-20
    Y_C(1) = max_yValue -  50;
    Y_C(2) = max_yValue -60;
    Y_C(3) = max_yValue -80;
    Y_C(4) = max_yValue -80;
    
    
    if strcmp(DVs{ind_DV} , 'mean_R2R_bpm')
        yaxis = 'heart rate (bpm)';
        ylabel(yaxis,'fontsize',26,'fontweight','b' , 'Interpreter', 'none');
          max_yValue = Ymax+40;
        min_yValue = Ymin -10;
        Y_C(1) = max_yValue -40;
        Y_C(2) = max_yValue -45;
        Y_C(3) = max_yValue -50;
        Y_C(4) = max_yValue -50;
        
    elseif    strcmp(DVs{ind_DV} , 'rmssd_R2R_ms')
        yaxis = 'RMSSD of R2R (ms)';
        ylabel(yaxis,'fontsize',26,'fontweight','b' , 'Interpreter', 'none');
        Y_C(1) = max_yValue *0.56;
        Y_C(2) = max_yValue *0.53;
        Y_C(3) = max_yValue *0.5;
        Y_C(4) = max_yValue *0.5;
     elseif    strcmp(DVs{ind_DV} , 'std_R2R_bpm')
        yaxis = 'std of R2R (bpm)';
        ylabel(yaxis,'fontsize',26,'fontweight','b' , 'Interpreter', 'none');
        Y_C(1) = max_yValue *0.56;
        Y_C(2) = max_yValue *0.53;
        Y_C(3) = max_yValue *0.5;
        Y_C(4) = max_yValue *0.5;    
    elseif strcmp(DVs{ind_DV} , 'hfPower') && strcmp(monkey , 'Curius')
        Y_C(1) = max_yValue *0.56;
        Y_C(2) = max_yValue *0.53;
        Y_C(3) = max_yValue *0.5;
        Y_C(4) = max_yValue *0.5;
    end
      if min_yValue < 0; min_yValue = 0; end;
        set(gca,'ylim',[min_yValue max_yValue]);
    if Text
        text(1.5 ,max_yValue -10,'Control','fontsize',20)
        text(1 ,max_yValue -20,'rest','fontsize',15)
        text(3 ,max_yValue -20,'task','fontsize',15)
        
        text(6.5,max_yValue -10,'Inactivation','fontsize',20)
        text(6 ,max_yValue -20,'rest','fontsize',15)
        text(8 ,max_yValue -20,'task','fontsize',15)
    end
    if Stats_beforeComputedWithR(1) == 1
        
        % add STATISTIC: line for the comparison && stars for significance
        if Stats_beforeComputedWithR(2)  == 3
            Stat = Tabl_MultComp(strcmp(Tabl_MultComp.Variable, DVs{ind_DV}),:);
            Row(1) =find(sum([strcmp(Stat.Comparison1, 'Control,pre,rest'), strcmp(Stat.Comparison2, 'Injection,pre,rest')],2)== 2);
            Row(2) =find(sum([strcmp(Stat.Comparison1, 'Control,pst,rest'), strcmp(Stat.Comparison2, 'Injection,pst,rest')],2)== 2);
            Row(3) =find(sum([strcmp(Stat.Comparison1, 'Injection,pre,rest'), strcmp(Stat.Comparison2, 'Injection,pst,rest')],2)== 2);
            Row(4) =find(sum([strcmp(Stat.Comparison1, 'Control,pre,rest'), strcmp(Stat.Comparison2, 'Control,pst,rest')],2)== 2);
            
        elseif Stats_beforeComputedWithR(2)  == 2
            Stat = Tabl_MultComp(strcmp(Tabl_MultComp.Variable, DVs{ind_DV}),:);
            Row(1) =find(sum([strcmp(Stat.Comparison1, 'Control,pre'), strcmp(Stat.Comparison2, 'Injection,pre'), strcmp(Stat.Tasktype, 'rest') ],2)== 3);
            Row(2) =find(sum([strcmp(Stat.Comparison1, 'Control,pst'), strcmp(Stat.Comparison2, 'Injection,pst'), strcmp(Stat.Tasktype, 'rest')],2)== 3);
            Row(3) =find(sum([strcmp(Stat.Comparison1, 'Injection,pre'), strcmp(Stat.Comparison2, 'Injection,pst'), strcmp(Stat.Tasktype, 'rest')],2)== 3);
            Row(4) =find(sum([strcmp(Stat.Comparison1, 'Control,pre'), strcmp(Stat.Comparison2, 'Control,pst'), strcmp(Stat.Tasktype, 'rest')],2)== 3);
            
        end
    
        disp(DVs{ind_DV})
        disp(Stat(Row,:)); 
        Contrast(1,:) = [1,6];
        Contrast(2,:) = [2,7];
        Contrast(3,:) = [6,7];
        Contrast(4,:) = [1,2];
        
        % Y_C(1) = max_yValue - ( (max_yValue/3) -20);
        % Y_C(2) = max_yValue - ( (max_yValue/3) -40)%60;
        % Y_C(3) = max_yValue - ( (max_yValue/3) -60)%80;
        % Y_C(4) = max_yValue - ( (max_yValue/3) -80)%80;
        
        %Y = [nanmean([S_con.mean_R2R_bpm.pre_rest]),nanmean([S_con.mean_R2R_bpm.pst_rest]),nanmean([S_con.mean_R2R_bpm.pre_task]),nanmean([S_con.mean_R2R_bpm.pst_task])]
        %Y = [200 , 210, 220, 230,200 , 210, 220, 230 ];
        for NrContrasts = 1: 4
            ext_sigline(Contrast(NrContrasts,:),char(Stat.Star(Row(NrContrasts))),Y_C(NrContrasts)); hold on;
        end
    end
    h = [];
    h(1) = figure(1);
    print(h,[path_SaveFig filesep 'png' filesep targetBrainArea '_' monkey, '_', DVs{ind_DV} '_RestStats'], '-dpng')
    set(h,'Renderer','Painters');
    set(h,'PaperPositionMode','auto')
    compl_filename =  [path_SaveFig filesep 'ai' filesep targetBrainArea '_' monkey, '_', DVs{ind_DV} '_RestStats.ai'] ;
    print(h,'-depsc',compl_filename);
    close all;
    
    
    
end

%% overview of all Variables in Bargraphs
figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
set(gcf,'Name',['AcrossSessions: R2R variables', monkey ,targetBrainArea]);

ha(1) = subplot(3,3,1);
BarGraph_one_var_pre_post_rest_task([S_con.mean_R2R_bpm],[S_ina.mean_R2R_bpm]);
title('Mean R2R (bmp)');
ylabel('mean R2R (bmp)','fontsize',14,'fontweight','b' );
text(1.5 ,240,'Control')
text(1 ,220,'rest')
text(3 ,220,'task')

text(6.5,240,'Injection')
set(gca,'ylim',[0 250]);
text(6 ,220,'rest')
text(8 ,220,'task')

ha(2) = subplot(3,3,2);
BarGraph_one_var_pre_post_rest_task([S_con.median_R2R_bpm],[S_ina.median_R2R_bpm]);
title('Median R2R (bmp)');

ha(3) = subplot(3,3,3);
BarGraph_one_var_pre_post_rest_task([S_con.rmssd_R2R_ms],[S_ina.rmssd_R2R_ms]);
title('RMSSD R2R (ms)');

ha(4) = subplot(3,3,4);
BarGraph_one_var_pre_post_rest_task([S_con.std_R2R_bpm],[S_ina.std_R2R_bpm]);
title('SD R2R (bmp)');

ha(5) = subplot(3,3,5);
BarGraph_one_var_pre_post_rest_task([S_con.lfPower],[S_ina.lfPower]);
title('Low freq power');

ha(6) = subplot(3,3,6);
BarGraph_one_var_pre_post_rest_task([S_con.hfPower],[S_ina.hfPower]);
title('High freq power');



%% To understand better the powerspectrum
% % %%Time specifications:
%    Fs = 8000;                   % samples per second
%    dt = 1/Fs;                   % seconds per sample
%    StopTime = 60;             % seconds
%    t = (0:dt:StopTime-dt)';     % seconds
%    %%Sine wave:
%    Fc = 0.05;                     % hertz
%    x = cos(2*pi*Fc*t);
%    % Plot the signal versus time:
%    figure;set(gcf,'Name',num2str(Fc));
%
%    plot(t,x);
%    xlabel('time (in seconds)');
%    title('Signal versus Time');
%    zoom xon;
% %
%%
ha(7) = subplot(3,3,7);
title('Power spectrum control');

con_b_col = [0.4667    0.6745    0.1882];
con_d_col = [0.0706    0.2118    0.1412];
ina_b_col = [0          0.7   0.9];
ina_d_col = [0          0    0.9];


freq_ = [S_con.freq];
freq = mean([freq_.pre_rest],2);
f = find(freq>0.04 & freq <= 0.6);%f = find(freq>0.05 & freq <= 0.6);

movwin = 5;

Pxx_con_ = [S_con.Pxx];
Pxx_con_pre_rest_m = mean([Pxx_con_.pre_rest],2);
Pxx_con_pre_task_m = mean([Pxx_con_.pre_task],2);
Pxx_con_pst_rest_m = mean([Pxx_con_.pst_rest],2);
Pxx_con_pst_task_m = mean([Pxx_con_.pst_task],2);
Pxx_con_pre_rest_se = sterr([Pxx_con_.pre_rest],2);
Pxx_con_pre_task_se = sterr([Pxx_con_.pre_task],2);
Pxx_con_pst_rest_se = sterr([Pxx_con_.pst_rest],2);
Pxx_con_pst_task_se = sterr([Pxx_con_.pst_task],2);

% type = 0;
% ig_errorband(freq(f),Pxx_con_pre_rest_m(f),Pxx_con_pre_rest_se(f),type,'Color',con_b_col,'LineWidth',1);
% ig_errorband(freq(f),Pxx_con_pre_task_m(f),Pxx_con_pre_task_se(f),type,'Color',con_b_col,'LineWidth',3);
% ig_errorband(freq(f),Pxx_con_pst_rest_m(f),Pxx_con_pst_rest_se(f),type,'Color',con_d_col,'LineWidth',1);
% ig_errorband(freq(f),Pxx_con_pst_task_m(f),Pxx_con_pst_task_se(f),type,'Color',con_d_col,'LineWidth',3);


% plot(freq(f),Pxx_con_pre_rest_m(f),'Color',con_b_col,'LineWidth',2); hold on
% plot(freq(f),Pxx_con_pre_task_m(f),'Color',con_b_col,'LineWidth',4);
% plot(freq(f),Pxx_con_pst_rest_m(f),'Color',con_d_col,'LineWidth',2);
% plot(freq(f),Pxx_con_pst_task_m(f),'Color',con_d_col,'LineWidth',4);

plot(freq(f),movingmean(Pxx_con_pre_rest_m(f),movwin,[],[]),'Color',con_b_col,'LineWidth',2); hold on
plot(freq(f),movingmean(Pxx_con_pre_task_m(f),movwin,[],[]),'Color',con_b_col,'LineWidth',4);
plot(freq(f),movingmean(Pxx_con_pst_rest_m(f),movwin,[],[]),'Color',con_d_col,'LineWidth',2);
plot(freq(f),movingmean(Pxx_con_pst_task_m(f),movwin,[],[]),'Color',con_d_col,'LineWidth',4);

ylim_spec_con = get(gca,'Ylim');
line([0.15 0.15],[ylim_spec_con(1) ylim_spec_con(2)]);
line([0.5 0.5],[ylim_spec_con(1) ylim_spec_con(2)]);



ha(8) = subplot(3,3,8);
title('Power spectrum inactivation');

Pxx_ina_ = [S_ina.Pxx];
Pxx_ina_pre_rest_m = mean([Pxx_ina_.pre_rest],2);
Pxx_ina_pre_task_m = mean([Pxx_ina_.pre_task],2);
Pxx_ina_pst_rest_m = mean([Pxx_ina_.pst_rest],2);
Pxx_ina_pst_task_m = mean([Pxx_ina_.pst_task],2);
Pxx_ina_pre_rest_se = sterr([Pxx_ina_.pre_rest],2);
Pxx_ina_pre_task_se = sterr([Pxx_ina_.pre_task],2);
Pxx_ina_pst_rest_se = sterr([Pxx_ina_.pst_rest],2);
Pxx_ina_pst_task_se = sterr([Pxx_ina_.pst_task],2);

plot(freq(f),movingmean(Pxx_ina_pre_rest_m(f),movwin,[],[]),'Color',ina_b_col,'LineWidth',2); hold on
plot(freq(f),movingmean(Pxx_ina_pre_task_m(f),movwin,[],[]),'Color',ina_b_col,'LineWidth',4);
plot(freq(f),movingmean(Pxx_ina_pst_rest_m(f),movwin,[],[]),'Color',ina_d_col,'LineWidth',2);
plot(freq(f),movingmean(Pxx_ina_pst_task_m(f),movwin,[],[]),'Color',ina_d_col,'LineWidth',4);

ylim_spec_ina = get(gca,'Ylim');
line([0.15 0.15],[ylim_spec_ina(1) ylim_spec_ina(2)]);
line([0.5 0.5],[ylim_spec_ina(1) ylim_spec_ina(2)]);

ylim = max(ylim_spec_ina(2),ylim_spec_con(2));
set(ha([7 8]),'Ylim',[0 ylim]);
set(ha([7 8]),'Xlim',[0 0.6]);
set(ha([7 8]),'Xlim',[0 0.6]);

%% save the figure
%for i = 1:12
h(1) = figure(1);
%end
savefig(h, [path_SaveFig filesep targetBrainArea ,'_' monkey '_OverviewBarGraph_Heartratevariability.fig'])
print(h,[path_SaveFig filesep 'png' filesep targetBrainArea,'_', monkey, '_OverviewBarGraph_Heartratevariability'], '-dpng')
set(h,'Renderer','Painters');
set(h,'PaperPositionMode','auto')
compl_filename =  [path_SaveFig filesep 'ai' filesep targetBrainArea,'_', monkey, '_OverviewBarGraph_Heartratevariability.ai'] ;
print(h,'-depsc',compl_filename);




function plot_oneVarMean_Block_pre_post_rest_task(Experiment, Block,Variable)
%[Graph, Ymin ,Ymax] =
con_b_col = [0.4667    0.6745    0.1882];
con_d_col = [0.0706    0.2118    0.1412];
ina_b_col = [0          0.7   0.9];
ina_d_col = [0          0    0.9];

% plot(  1, nanmean([Block.pre_rest]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',con_b_col) ; hold on
% plot(  2, nanmean([Block.pst_rest]), 'o','color', [0 0 0] ,'MarkerSize',20,'markerfacecolor',con_d_col);
if  strcmp(Experiment, 'Control')
    plot(   Block(1:3),Variable(1:3), '-','color',[0 0 0] ,'LineWidth',2,'color',con_b_col, 'DisplayName','Pre Control'); hold on;
    plot(   Block(4:end),Variable(4:end), '-','color',[0 0 0] ,'LineWidth',2,'color',con_d_col, 'DisplayName','Post Control'); hold on;
    %h.Color(4)=0.3;  % 70% transparent
    %p.Color(4)=0.8;  % 70% transparent
    
elseif  strcmp(Experiment, 'Injection')
    plot(   Block(1:3),Variable(1:3), '-','color',[0 0 0] ,'LineWidth',2,'color',ina_b_col, 'DisplayName','Pre Inactivation'); hold on;
    plot(   Block(4:end),Variable(4:end), '-','color',[0 0 0] ,'LineWidth',2,'color',ina_d_col, 'DisplayName','Post Inactivation'); hold on;
    legend('show','Location','best')
end



function [count_con, count_ina, count_c, count_i] =  plot_oneVar_Block_pre_post_rest_task(Experiment, Block,Variable, count_con, count_ina, count_c, count_i)
%[Graph, Ymin ,Ymax] =

count_con= [0 0 0]; count_ina = [0 0 0];


con_b_col = abs([0.4667    0.6745    0.1882] +count_con); % light green
con_d_col = abs([0.0706    0.2118    0.1412] +count_con);
ina_b_col = abs([0          0.7   0.9] +count_ina);
ina_d_col = abs([0          0    0.9] +count_ina);

% plot(  1, nanmean([Block.pre_rest]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',con_b_col) ; hold on
% plot(  2, nanmean([Block.pst_rest]), 'o','color', [0 0 0] ,'MarkerSize',20,'markerfacecolor',con_d_col);
if  strcmp(Experiment, 'Control')
    plot(   1:length([Block.pre_task_idx]),[Variable.pre_task], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',con_b_col,'HandleVisibility','off'); hold on;
    plot(   4:(length([Block.pst_task_idx])+3),[Variable.pst_task], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',con_d_col,'HandleVisibility','off') ;
    count_con = count_con + [0 0.15 0.15];
    text(1:length([Block.pre_task_idx]),[Variable.pre_task],num2str(count_c),'fontsize',15)
    text(4:(length([Block.pst_task_idx])+3),[Variable.pst_task],num2str(count_c),'fontsize',15)
    count_c = count_c +1;
elseif  strcmp(Experiment, 'Injection')
    
    plot(   1:length([Block.pre_task_idx]),[Variable.pre_task], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',ina_b_col,'HandleVisibility','off'); hold on;
    plot(   4:(length([Block.pst_task_idx])+3),[Variable.pst_task], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',ina_d_col,'HandleVisibility','off') ;
    count_ina = count_ina - [0  0.1 0.1];
    
    text(1:length([Block.pre_task_idx]),[Variable.pre_task],num2str(count_i),'fontsize',15)
    text(  4:(length([Block.pst_task_idx])+3),[Variable.pst_task],num2str(count_i),'fontsize',15)
    count_i = count_i +1;
    
end

function [count_con, count_ina, count_c, count_i] =  plot_oneVar_secondVar_pre_post_rest_task(Experiment, Block,Variable, count_con, count_ina, count_c, count_i,DeleteOutlier, S_con,S_ina)
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
% plot(  1, nanmean([Block.pre_rest]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',con_b_col) ; hold on
% plot(  2, nanmean([Block.pst_rest]), 'o','color', [0 0 0] ,'MarkerSize',20,'markerfacecolor',con_d_col);

% line([0,120],[nanmean([S_con.pre_task]),nanmean([S_con.pre_task])])
% plot(  nanmean([S_con.pre_rest]), , '-','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',con_b_col) ; hold on
% plot(  nanmean([S_con.pst_rest]), '-','color', [0 0 0] ,'MarkerSize',20,'markerfacecolor',con_d_col);
% plot(  nanmean([S_con.pre_task]), '-','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',con_b_col);
% plot(  nanmean([S_con.pst_task]), '-','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',con_d_col) ;
% 
% plot(  6, nanmean([S_ina.pre_rest]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',ina_b_col) ;
% plot(  7, nanmean([S_ina.pst_rest]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',ina_d_col) ;
% plot(  8, nanmean([S_ina.pre_task]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',ina_b_col);
% plot(  9, nanmean([S_ina.pst_task]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',ina_d_col) ;
if  strcmp(Experiment, 'Control')
    plot(  [Block.pre_task],[Variable.pre_task], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',con_b_col,'HandleVisibility','off'); hold on;
    plot(  [Block.pst_task],[Variable.pst_task], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',con_d_col,'HandleVisibility','off') ;
    
   % plot(  [Block.pre_rest],[Variable.pre_rest], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',con_b_col,'HandleVisibility','off'); hold on;
   % plot(  [Block.pst_rest],[Variable.pst_rest], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',con_d_col,'HandleVisibility','off') ;

    count_con = count_con + [0 0.15 0.15];
    text([Block.pre_task],[Variable.pre_task],num2str(count_c),'fontsize',15)
    text([Block.pst_task],[Variable.pst_task],num2str(count_c),'fontsize',15)
   % text([Block.pre_rest],[Variable.pre_rest],num2str(count_c),'fontsize',15)
   % text([Block.pst_rest],[Variable.pst_rest],num2str(count_c),'fontsize',15)
    count_c = count_c +1;
elseif  strcmp(Experiment, 'Injection')
    
    plot(  [Block.pre_task],[Variable.pre_task], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',ina_b_col,'HandleVisibility','off'); hold on;
    plot(  [Block.pst_task],[Variable.pst_task], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',ina_d_col,'HandleVisibility','off') ;
   % plot(  [Block.pre_rest],[Variable.pre_rest], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',ina_b_col,'HandleVisibility','off'); hold on;
   % plot(  [Block.pst_rest],[Variable.pst_rest], 'o','color',[0 0 0] ,'MarkerSize',10,'markerfacecolor',ina_d_col,'HandleVisibility','off') ;

    count_ina = count_ina - [0  0.1 0.1];
    
    text([Block.pre_task],[Variable.pre_task],num2str(count_i),'fontsize',15)
    text([Block.pst_task],[Variable.pst_task],num2str(count_i),'fontsize',15)
   % text([Block.pre_rest],[Variable.pre_rest],num2str(count_c),'fontsize',15)
   % text([Block.pst_rest],[Variable.pst_rest],num2str(count_c),'fontsize',15)
    count_i = count_i +1;
    
end






function [Graph, Ymin ,Ymax] = plot_one_var_pre_post_rest_task(S_con,S_ina)

con_b_col = [0.4667    0.6745    0.1882];
con_d_col = [0.0706    0.2118    0.1412];
ina_b_col = [0          0.7   0.9];
ina_d_col = [0          0    0.9];


Con(1,:) = [S_con.pre_rest]; 
Con(2,:) =[S_con.pst_rest]; 
Con(3,:) =[S_con.pre_task]; 
Con(4,:) =[S_con.pst_task]; 
con_b_col_trans = [0.3    0.5   0.3 0.4];
for i = 1: length([S_con.pre_rest])
line(1:2, Con(1:2,i),'Color',con_b_col_trans ); 
line(3:4, Con(3:4,i),'Color',con_b_col_trans ); 

end

ina_b_col_trans = [0    0.5   0.9 0.4];

Ina(1,:) = [S_ina.pre_rest]; 
Ina(2,:) =[S_ina.pst_rest]; 
Ina(3,:) =[S_ina.pre_task]; 
Ina(4,:) =[S_ina.pst_task]; 
for i = 1: length([S_ina.pre_rest])
line(6:7, Ina(1:2,i),'color',ina_b_col_trans )
line(8:9, Ina(3:4,i),'color',ina_b_col_trans )

end
hold on;
MarkerSize_EachSession = 38; 
MarkerSize_AllSession = 30; 

Graph = plot(  1, [S_con.pre_rest], '.','color',con_b_col ,'MarkerSize',MarkerSize_EachSession) ; hold on;
Graph = plot(  2, [S_con.pst_rest], '.','color',con_d_col ,'MarkerSize',MarkerSize_EachSession) ;
Graph = plot(  3, [S_con.pre_task], '.','color',con_b_col ,'MarkerSize',MarkerSize_EachSession);
Graph = plot(  4, [S_con.pst_task], '.','color',con_d_col ,'MarkerSize',MarkerSize_EachSession) ;
for i = 1: length([S_con.pre_rest])
 text(1,Con(1,i),num2str(i),'fontsize',15)
 text(2,Con(2,i),num2str(i),'fontsize',15)
 text(3,Con(3,i),num2str(i),'fontsize',15)
 text(4,Con(4,i),num2str(i),'fontsize',15)
 text(6,Ina(1,i),num2str(i),'fontsize',15)
 text(7,Ina(2,i),num2str(i),'fontsize',15)
 text(8,Ina(3,i),num2str(i),'fontsize',15)
 text(9,Ina(4,i),num2str(i),'fontsize',15)

end

Graph =plot(  6, [S_ina.pre_rest], '.','color',ina_b_col ,'MarkerSize',MarkerSize_EachSession) ;
Graph =plot(  7, [S_ina.pst_rest], '.','color',ina_d_col ,'MarkerSize',MarkerSize_EachSession) ;
Graph =plot(  8, [S_ina.pre_task], '.','color',ina_b_col ,'MarkerSize',MarkerSize_EachSession) ;
Graph =plot(  9, [S_ina.pst_task], '.','color',ina_d_col ,'MarkerSize',MarkerSize_EachSession) ;

line(1:2,[nanmean([S_con.pre_rest]),nanmean([S_con.pst_rest])],'Color',con_b_col_trans,'LineWidth', 4)
line(3:4,[nanmean([S_con.pre_task]),nanmean([S_con.pst_task])],'Color',con_b_col_trans,'LineWidth', 4)
line(6:7,[nanmean([S_ina.pre_rest]),nanmean([S_ina.pst_rest])],'Color',ina_b_col_trans,'LineWidth', 4)
line(8:9,[nanmean([S_ina.pre_task]),nanmean([S_ina.pst_task])],'Color',ina_b_col_trans,'LineWidth', 4)

plot(  1, nanmean([S_con.pre_rest]), 'o','color',[0 0 0] ,'MarkerSize',MarkerSize_AllSession,'markerfacecolor',con_b_col) ; hold on
plot(  2, nanmean([S_con.pst_rest]), 'o','color', [0 0 0] ,'MarkerSize',MarkerSize_AllSession,'markerfacecolor',con_d_col);
plot(  3, nanmean([S_con.pre_task]), 'o','color',[0 0 0] ,'MarkerSize',MarkerSize_AllSession,'markerfacecolor',con_b_col);
plot(  4, nanmean([S_con.pst_task]), 'o','color',[0 0 0] ,'MarkerSize',MarkerSize_AllSession,'markerfacecolor',con_d_col) ;

plot(  6, nanmean([S_ina.pre_rest]), 'o','color',[0 0 0] ,'MarkerSize',MarkerSize_AllSession,'markerfacecolor',ina_b_col) ;
plot(  7, nanmean([S_ina.pst_rest]), 'o','color',[0 0 0] ,'MarkerSize',MarkerSize_AllSession,'markerfacecolor',ina_d_col) ;
plot(  8, nanmean([S_ina.pre_task]), 'o','color',[0 0 0] ,'MarkerSize',MarkerSize_AllSession,'markerfacecolor',ina_b_col);
plot(  9, nanmean([S_ina.pst_task]), 'o','color',[0 0 0] ,'MarkerSize',MarkerSize_AllSession,'markerfacecolor',ina_d_col) ;

C1 = struct2cell(S_con);
C2 = struct2cell(S_ina);

Ymin(1) = min([C1{:}]);
Ymax(1) = max([C1{:}]);
Ymin(2) = min([C2{:}]);
Ymax(2) = max([C2{:}]);
Ymin=   min(Ymin) ;
Ymax=   max(Ymax) ;

hold off;

set(gca,'xlim',[0 10],'Xtick',[1:4 6:9],'XTickLabel',{'pre' 'post' 'pre' 'post' 'pre' 'post' 'pre' 'post'},'fontsize',20);


function [Graph, Ymin ,Ymax] = plot_one_var_EachBlock_pre_post_rest_task(S_con,S_ina)

con_b_col = [0.4667    0.6745    0.1882];
con_d_col = [0.0706    0.2118    0.1412];
ina_b_col = [0          0.7   0.9];
ina_d_col = [0          0    0.9];

plot(  1, nanmean([S_con.pre_rest]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',con_b_col) ; hold on
plot(  2, nanmean([S_con.pst_rest]), 'o','color', [0 0 0] ,'MarkerSize',20,'markerfacecolor',con_d_col);
plot(  3, nanmean([S_con.pre_task]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',con_b_col);
plot(  4, nanmean([S_con.pst_task]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',con_d_col) ;

plot(  6, nanmean([S_ina.pre_rest]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',ina_b_col) ;
plot(  7, nanmean([S_ina.pst_rest]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',ina_d_col) ;
plot(  8, nanmean([S_ina.pre_task]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',ina_b_col);
plot(  9, nanmean([S_ina.pst_task]), 'o','color',[0 0 0] ,'MarkerSize',20,'markerfacecolor',ina_d_col) ;

Graph = plot(  1, [S_con.pre_rest], '.','color',con_b_col ,'MarkerSize',25) ; hold on;
Graph = plot(  2, [S_con.pst_rest], '.','color',con_d_col ,'MarkerSize',25) ;
Graph = plot(  3, [S_con.pre_task], '.','color',con_b_col ,'MarkerSize',25);
Graph = plot(  4, [S_con.pst_task], '.','color',con_d_col ,'MarkerSize',25) ;


Graph =plot(  6, [S_ina.pre_rest], '.','color',ina_b_col ,'MarkerSize',25) ;
Graph =plot(  7, [S_ina.pst_rest], '.','color',ina_d_col ,'MarkerSize',25) ;
Graph =plot(  8, [S_ina.pre_task], '.','color',ina_b_col ,'MarkerSize',25) ;
Graph =plot(  9, [S_ina.pst_task], '.','color',ina_d_col ,'MarkerSize',25) ;

C1 = struct2cell(S_con);
C2 = struct2cell(S_ina);

Ymin(1) = min([C1{:}]);
Ymax(1) = max([C1{:}]);
Ymin(2) = min([C2{:}]);
Ymax(2) = max([C2{:}]);
Ymin=   min(Ymin) ;
Ymax=   max(Ymax) ;

hold off;

set(gca,'xlim',[0 10],'Xtick',[1:4 6:9],'XTickLabel',{'pre' 'post' 'pre' 'post' 'pre' 'post' 'pre' 'post'});

function BarGraph_one_var_pre_post_rest_task(S_con,S_ina)

con_b_col = [0.4667    0.6745    0.1882];
con_d_col = [0.0706    0.2118    0.1412];
ina_b_col = [0          0.7   0.9];
ina_d_col = [0          0    0.9];



ig_bar_mean_se(1,[S_con.pre_rest],'sterr','FaceColor',[1 1 1],'EdgeColor',con_b_col);
ig_bar_mean_se(2,[S_con.pst_rest],'sterr','FaceColor',[1 1 1],'EdgeColor',con_d_col);
ig_bar_mean_se(3,[S_con.pre_task],'sterr','FaceColor',con_b_col,'EdgeColor',con_b_col);
ig_bar_mean_se(4,[S_con.pst_task],'sterr','FaceColor',con_d_col,'EdgeColor',con_d_col);

ig_bar_mean_se(6,[S_ina.pre_rest],'sterr','FaceColor',[1 1 1],'EdgeColor',ina_b_col);
ig_bar_mean_se(7,[S_ina.pst_rest],'sterr','FaceColor',[1 1 1],'EdgeColor',ina_d_col);
ig_bar_mean_se(8,[S_ina.pre_task],'sterr','FaceColor',ina_b_col,'EdgeColor',ina_b_col);
ig_bar_mean_se(9,[S_ina.pst_task],'sterr','FaceColor',ina_d_col,'EdgeColor',ina_d_col);

set(gca,'xlim',[0 10],'Xtick',[1:4 6:9],'XTickLabel',{'pre' 'post' 'pre' 'post' 'pre' 'post' 'pre' 'post'});