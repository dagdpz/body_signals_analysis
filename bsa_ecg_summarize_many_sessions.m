function bsa_ecg_summarize_many_sessions(path_SaveFig, sessions, inactivation_sessions, targetBrainArea, Path_addtoDropbox, monkey)
%bsa_ecg_summarize_many_sessions  - summarize ECG analysis across several sessions
%
% USAGE:
% bsa_ecg_summarize_many_sessions;
%
% INPUTS:
%
% OUTPUTS:
%
% REQUIRES:	Igtools
%
% See also BSA_ECG_ANALYZE_MANY_SESSIONS
%
%
% Author(s):	I.Kagan, DAG, DPZ
% URL:		http://www.dpz.eu/dag
%
% Change log:
% 20190226:	Created function (Igor Kagan)
% ...
% $Revision: 1.0 $  $Date: 2019-02-26 15:31:09 $

% ADDITIONAL INFO:
% Set sessions and inactivation sessions
% Each session should be processed with bsa_ecg_analyze_one_session -> session_name '_ecg.mat' should exist
%%%%%%%%%%%%%%%%%%%%%%%%%[DAG mfile header version 1]%%%%%%%%%%%%%%%%%%%%%%%%% 
ind_con = 0;
ind_ina = 0;
ind_con_Blocks = 0;
ind_ina_Blocks = 0;
S_Blocks2 = []; 

Table = []; TableBlocks =[]; 
for s = 1:length(sessions),
	session_path = sessions{s};
	session_name_idx = strfind(session_path,'2021');
	session_name = session_path(session_name_idx(1):session_name_idx(1)+7);

	load([session_path filesep session_name '_ecg.mat']);

    % remove -2: skipped sessions
   % ses.type = ses.type(ses.type ~= -2)';
%         if isempty(out(indBlock).mean_R2R_valid_bpm)|| isnan(out(indBlock).mean_R2R_valid_bpm)
%         out(13) = [];
%          disp(sprintf('removed the skipped block %d',num2str()));
%     end
if sum(isnan([out.mean_R2R_valid_bpm])) > 0
    error('one Block has nan-value')
    %out.mean_R2R_valid_bpm{isnan([out.mean_R2R_valid_bpm])}
end
    rest_idx = [];   task_idx = []; 
	rest_idx = find(ses.type == 0  ); %& ~isnan([out.mean_R2R_valid_bpm]')
    task_idx = find(ses.type == 1 ); %& ~isnan([out.mean_R2R_valid_bpm]')
    if isempty(ses.first_inj_block)
  
    pre_rest_idx = 	rest_idx;
	pre_task_idx = 	task_idx;
	pst_rest_idx = 	rest_idx;
	pst_task_idx = 	task_idx;
    Experiment_name = ses.brain_area{1};  %'Ephys'; 
    
   
    else
    
    
	pre_rest_idx = 	rest_idx(rest_idx < ses.first_inj_block);
	pre_task_idx = 	task_idx(task_idx < ses.first_inj_block);
	pst_rest_idx = 	rest_idx(rest_idx >= ses.first_inj_block);
	pst_task_idx = 	task_idx(task_idx >= ses.first_inj_block);
    Experiment_name = 'Inactivation'; 

    end
	% for analysis across sessions

	S_.mean_R2R_bpm.pre_rest = mean([out(pre_rest_idx).mean_R2R_valid_bpm]);
	S_.mean_R2R_bpm.pre_task = mean([out(pre_task_idx).mean_R2R_valid_bpm]);
	S_.mean_R2R_bpm.pst_rest = mean([out(pst_rest_idx).mean_R2R_valid_bpm]);
	S_.mean_R2R_bpm.pst_task = mean([out(pst_task_idx).mean_R2R_valid_bpm]);

	S_.median_R2R_bpm.pre_rest = mean([out(pre_rest_idx).median_R2R_valid_bpm]);
	S_.median_R2R_bpm.pre_task = mean([out(pre_task_idx).median_R2R_valid_bpm]);
	S_.median_R2R_bpm.pst_rest = mean([out(pst_rest_idx).median_R2R_valid_bpm]);
	S_.median_R2R_bpm.pst_task = mean([out(pst_task_idx).median_R2R_valid_bpm]);

	S_.rmssd_R2R_ms.pre_rest = mean([out(pre_rest_idx).rmssd_R2R_valid_ms]);
	S_.rmssd_R2R_ms.pre_task = mean([out(pre_task_idx).rmssd_R2R_valid_ms]);
	S_.rmssd_R2R_ms.pst_rest = mean([out(pst_rest_idx).rmssd_R2R_valid_ms]);
	S_.rmssd_R2R_ms.pst_task = mean([out(pst_task_idx).rmssd_R2R_valid_ms]);

	S_.std_R2R_bpm.pre_rest = mean([out(pre_rest_idx).std_R2R_valid_bpm]);
	S_.std_R2R_bpm.pre_task = mean([out(pre_task_idx).std_R2R_valid_bpm]);
	S_.std_R2R_bpm.pst_rest = mean([out(pst_rest_idx).std_R2R_valid_bpm]);
	S_.std_R2R_bpm.pst_task = mean([out(pst_task_idx).std_R2R_valid_bpm]);

	S_.lfPower.pre_rest = mean([out(pre_rest_idx).lfPower]);
	S_.lfPower.pre_task = mean([out(pre_task_idx).lfPower]);
	S_.lfPower.pst_rest = mean([out(pst_rest_idx).lfPower]);
	S_.lfPower.pst_task = mean([out(pst_task_idx).lfPower]);

	S_.hfPower.pre_rest = mean([out(pre_rest_idx).hfPower]);
	S_.hfPower.pre_task = mean([out(pre_task_idx).hfPower]);
	S_.hfPower.pst_rest = mean([out(pst_rest_idx).hfPower]);
	S_.hfPower.pst_task = mean([out(pst_task_idx).hfPower]);


	S_.totPower.pre_rest = mean([out(pre_rest_idx).totPower]);
	S_.totPower.pre_task = mean([out(pre_task_idx).totPower]);
	S_.totPower.pst_rest = mean([out(pst_rest_idx).totPower]);
	S_.totPower.pst_task = mean([out(pst_task_idx).totPower]);


	S_.freq.pre_rest = mean([out(pre_rest_idx).freq],2);
	S_.freq.pre_task = mean([out(pre_task_idx).freq],2);
	S_.freq.pst_rest = mean([out(pst_rest_idx).freq],2);
	S_.freq.pst_task = mean([out(pst_task_idx).freq],2);

	S_.Pxx.pre_rest = mean([out(pre_rest_idx).Pxx],2);
	S_.Pxx.pre_task = mean([out(pre_task_idx).Pxx],2);
	S_.Pxx.pst_rest = mean([out(pst_rest_idx).Pxx],2);
	S_.Pxx.pst_task = mean([out(pst_task_idx).Pxx],2);

if ismember(session_name,inactivation_sessions)
    ind_ina = ind_ina + 1;
    S_ina(ind_ina) = S_;
    %% create a table for Inactivation sessions
    VariableNames = fieldnames(S_ina(ind_ina));
    for indVar =  1 : numel(VariableNames)
        if ~strcmp(VariableNames{indVar}, 'freq') && ~strcmp(VariableNames{indVar}, 'Pxx')
           
        TableInac = stack(struct2table(S_ina(ind_ina).(VariableNames{indVar})),1:4);
        Var = strsplit(char(TableInac.Properties.VariableNames(2)) , '_');
        Injection = []; TaskType = [];
        for i = 1: numel(Var)
            if strcmp(Var(i),  'pre')||strcmp(Var(i),  'pst')
                Injection = [Injection, Var(i)];
            else
                TaskType = [TaskType, Var(i)];
            end
        end
        TableInac.Injection         = Injection';
        TableInac.TaskType          = TaskType';
        TableInac.Properties.VariableNames(2) = {'Values'};
        Experiment    = cell(1, size(TableInac,1))';
        Experiment(:) = VariableNames(indVar);
        TableInac.DependentVariable  = Experiment;       
        Experiment(:) = {Experiment_name};
        TableInac.Experiment         = Experiment;
        Experiment(:) = {session_name};
        TableInac.Date               = Experiment;
        
        Table = [Table ;TableInac];
        S_Blocks2(s).Experiment = {Experiment_name};

        end
    end
    
else
    ind_con = ind_con + 1;
    S_con(ind_con) = S_;
    
    %% create a table for Baseline sessions
    VariableNames = fieldnames(S_con(ind_con));
    for indVar =  1 : numel(VariableNames)
        if ~strcmp(VariableNames{indVar}, 'freq') && ~strcmp(VariableNames{indVar}, 'Pxx')
        TableInac = stack(struct2table(S_con(ind_con).(VariableNames{indVar})),1:4);
        Var = strsplit(char(TableInac.Properties.VariableNames(2)) , '_');
        Injection = []; TaskType = [];
        for i = 1: numel(Var)
            if strcmp(Var(i),  'pre')||strcmp(Var(i),  'pst')
                Injection = [Injection, Var(i)];
            else
                TaskType = [TaskType, Var(i)];
            end
        end
        TableInac.Injection         = Injection';
        TableInac.TaskType          = TaskType';
        TableInac.Properties.VariableNames(2) = {'Values'};
        Experiment    = cell(1, size(TableInac,1))';
        Experiment(:) = VariableNames(indVar);
        TableInac.DependentVariable  = Experiment;
        
        Experiment(:) = {'Control'};
        S_Blocks2(s).Experiment = {'Control'};

        TableInac.Experiment         = Experiment;
        Experiment(:) = {session_name};
        TableInac.Date         = Experiment;

        Table = [Table ;TableInac];
        end
    end
    
end


%% BLOCKS
%add blocks for analysis across all blocks from all sessions
% How many Blocks in this session?
%
S_Blocks = [];Blocks =[];
Blocks = sort([task_idx , rest_idx]);
indBlock = 1;
for iBlock =  1:   length(Blocks) %indBlock =  Blocks

    %check if structure is empty & adapt a different adding mechanism
  %  isempty() 
    NrBlock = Blocks(iBlock);
    
   if  isempty(out(NrBlock).std_R2R_valid_bpm)
   else
    S_Blocks.Block(indBlock).Block = NrBlock;
    S_Blocks.Block(indBlock).NrBlock = indBlock;

    S_Blocks.Block(indBlock).mean_R2R_bpm         = 'NaN';
    S_Blocks.Block(indBlock).median_R2R_bpm       = 'NaN';
    S_Blocks.Block(indBlock).rmssd_R2R_ms         = 'NaN';
    S_Blocks.Block(indBlock).std_R2R_bpm          = 'NaN';
    S_Blocks.Block(indBlock).lfPower                    = 'NaN';
    S_Blocks.Block(indBlock).hfPower                    = 'NaN';
    S_Blocks.Block(indBlock).Injection                  = 'NaN';
    S_Blocks.Block(indBlock).TaskType                   = 'NaN';
    S_Blocks.Block(indBlock).Date                       = 'NaN';
    S_Blocks.Block(indBlock).Experiment                 = 'NaN';
    
    
    
    S_Blocks.Block(indBlock).mean_R2R_bpm            = [out(NrBlock).mean_R2R_valid_bpm];
    S_Blocks.Block(indBlock).median_R2R_bpm          = [out(NrBlock).median_R2R_valid_bpm];
    S_Blocks.Block(indBlock).rmssd_R2R_ms            = [out(NrBlock).rmssd_R2R_valid_ms];
    S_Blocks.Block(indBlock).std_R2R_bpm             = [out(NrBlock).std_R2R_valid_bpm];
    S_Blocks.Block(indBlock).lfPower                 = [out(NrBlock).lfPower];
    S_Blocks.Block(indBlock).hfPower                 = [out(NrBlock).hfPower];
    
    
    if ismember(NrBlock, pre_rest_idx)
        S_Blocks.Block(indBlock).Condition = 'pre_rest';
    elseif ismember(NrBlock, pre_task_idx)
        S_Blocks.Block(indBlock).Condition = 'pre_task';
    elseif ismember(NrBlock, pst_rest_idx)
        S_Blocks.Block(indBlock).Condition =  'pst_rest';
    elseif ismember(NrBlock, pst_task_idx)
        S_Blocks.Block(indBlock).Condition =  'pst_task';
    else
        S_Blocks.Block(indBlock).Condition =  'NaN_NaN';
    end
    

    
    Var = strsplit(char(S_Blocks.Block(indBlock).Condition) , '_');
    
    for i = 1: numel(Var)
        if strcmp(Var(i),  'pre')||strcmp(Var(i),  'pst')
            S_Blocks.Block(indBlock).Injection =  char(Var(i));
        else
            S_Blocks.Block(indBlock).TaskType =  char(Var(i));
        end
    end
    if ismember(session_name,inactivation_sessions)
        S_Blocks.Block(indBlock).Experiment          = 'Injection';
    else
        S_Blocks.Block(indBlock).Experiment         = 'Control';
    end
    S_Blocks.Block(indBlock).Date               = session_name;
   
             indBlock = indBlock +1;

   end %if to detect empty-Blocks

end

if ismember(session_name,inactivation_sessions)
    ind_ina_Blocks = ind_ina_Blocks + 1;
    S_Blocks_ina(ind_ina_Blocks) = S_Blocks;
    %% create a table for Inactivation sessions
    TableBlocks_Inac = [];
    TableBlocks_Inac = struct2table(S_Blocks_ina(ind_ina_Blocks).Block); 
%%
 TableBlocks_Inac.NrBlock_BasedCondition = zeros(size(TableBlocks_Inac,1),1); 
    Var = unique(TableBlocks_Inac.Condition ); 
    
    for indCon =  1: length( Var)
    TableBlocks_Inac.NrBlock_BasedCondition(TableBlocks_Inac(strcmp(TableBlocks_Inac.Condition ,Var(indCon)), :).NrBlock) = ...
         [1: sum(strcmp(TableBlocks_Inac.Condition ,Var(indCon)))]'; 
    end
    TableBlocks = [TableBlocks ;TableBlocks_Inac];
              
else
    ind_con_Blocks = ind_con_Blocks + 1;
    S_Blocks_con(ind_con_Blocks) = S_Blocks;
    
    %% create a table for Control sessions
   TableBlocks_Con = [];

    TableBlocks_Con = struct2table(S_Blocks_con(ind_con_Blocks).Block);
    TableBlocks_Con.NrBlock_BasedCondition = zeros(size(TableBlocks_Con,1),1); 
    Var = unique(TableBlocks_Con.Condition ); 
    
    for indCon =  1: length( Var)
    TableBlocks_Con.NrBlock_BasedCondition(TableBlocks_Con(strcmp(TableBlocks_Con.Condition ,Var(indCon)), :).NrBlock) = ...
         [1: sum(strcmp(TableBlocks_Con.Condition ,Var(indCon)))]'; 
    end
    TableBlocks = [TableBlocks ;TableBlocks_Con];
        
end



    S_Blocks2(s).Block.pre_rest_idx = pre_rest_idx';
    S_Blocks2(s).Block.pre_task_idx = pre_task_idx';
    S_Blocks2(s).Block.pst_rest_idx = pst_rest_idx';
    S_Blocks2(s).Block.pst_task_idx = pst_task_idx';
    
% 
%     S_Blocks2.mean_R2R_bpm.pre_rest = zeros(1,ini );
% 	S_Blocks2.mean_R2R_bpm.pre_task = zeros(1,ini );
% 	S_Blocks2.mean_R2R_bpm.pst_rest = zeros(1,ini );
% 	S_Blocks2.mean_R2R_bpm.pst_task = zeros(1,ini );
%     
    S_Blocks2(s).mean_R2R_bpm.pre_rest = [out(pre_rest_idx).mean_R2R_valid_bpm];
	S_Blocks2(s).mean_R2R_bpm.pre_task = [out(pre_task_idx).mean_R2R_valid_bpm];
	S_Blocks2(s).mean_R2R_bpm.pst_rest = [out(pst_rest_idx).mean_R2R_valid_bpm];
	S_Blocks2(s).mean_R2R_bpm.pst_task = [out(pst_task_idx).mean_R2R_valid_bpm];

	S_Blocks2(s).median_R2R_bpm.pre_rest = [out(pre_rest_idx).median_R2R_valid_bpm];
	S_Blocks2(s).median_R2R_bpm.pre_task = [out(pre_task_idx).median_R2R_valid_bpm];
	S_Blocks2(s).median_R2R_bpm.pst_rest = [out(pst_rest_idx).median_R2R_valid_bpm];
	S_Blocks2(s).median_R2R_bpm.pst_task = [out(pst_task_idx).median_R2R_valid_bpm];

	S_Blocks2(s).rmssd_R2R_ms.pre_rest = [out(pre_rest_idx).rmssd_R2R_valid_ms];
	S_Blocks2(s).rmssd_R2R_ms.pre_task = [out(pre_task_idx).rmssd_R2R_valid_ms];
	S_Blocks2(s).rmssd_R2R_ms.pst_rest = [out(pst_rest_idx).rmssd_R2R_valid_ms];
	S_Blocks2(s).rmssd_R2R_ms.pst_task = [out(pst_task_idx).rmssd_R2R_valid_ms];

	S_Blocks2(s).std_R2R_bpm.pre_rest = [out(pre_rest_idx).std_R2R_valid_bpm];
	S_Blocks2(s).std_R2R_bpm.pre_task = [out(pre_task_idx).std_R2R_valid_bpm];
	S_Blocks2(s).std_R2R_bpm.pst_rest = [out(pst_rest_idx).std_R2R_valid_bpm];
	S_Blocks2(s).std_R2R_bpm.pst_task = [out(pst_task_idx).std_R2R_valid_bpm];

	S_Blocks2(s).lfPower.pre_rest = [out(pre_rest_idx).lfPower];
	S_Blocks2(s).lfPower.pre_task = [out(pre_task_idx).lfPower];
	S_Blocks2(s).lfPower.pst_rest = [out(pst_rest_idx).lfPower];
	S_Blocks2(s).lfPower.pst_task = [out(pst_task_idx).lfPower];

	S_Blocks2(s).hfPower.pre_rest = [out(pre_rest_idx).hfPower];
	S_Blocks2(s).hfPower.pre_task = [out(pre_task_idx).hfPower];
	S_Blocks2(s).hfPower.pst_rest = [out(pst_rest_idx).hfPower];
	S_Blocks2(s).hfPower.pst_task = [out(pst_task_idx).hfPower];


	S_Blocks2(s).totPower.pre_rest = [out(pre_rest_idx).totPower];
	S_Blocks2(s).totPower.pre_task = [out(pre_task_idx).totPower];
	S_Blocks2(s).totPower.pst_rest = [out(pst_rest_idx).totPower];
	S_Blocks2(s).totPower.pst_task = [out(pst_task_idx).totPower];

end

TableBlocks_Control         = TableBlocks(strcmp(TableBlocks.Experiment, 'Control'),:);
TableBlocks_Injection       = TableBlocks(strcmp(TableBlocks.Experiment, 'Injection'),:);
MeanForBlock_Task_Control   = varfun(@mean,TableBlocks_Control,'InputVariables',{'mean_R2R_bpm','median_R2R_bpm','rmssd_R2R_ms', 'std_R2R_bpm', 'lfPower','hfPower'}, 'GroupingVariables',{'NrBlock_BasedCondition','Condition'});
MeanForBlock_Task_Injection = varfun(@mean,TableBlocks_Injection,'InputVariables',{'mean_R2R_bpm','median_R2R_bpm','rmssd_R2R_ms', 'std_R2R_bpm', 'lfPower','hfPower'}, 'GroupingVariables',{'NrBlock_BasedCondition','Condition'});

MeanForBlock_Task_Control.Experiment = repmat(TableBlocks_Control.Experiment(1), size(MeanForBlock_Task_Control,1),1);
MeanForBlock_Task_Injection.Experiment = repmat(TableBlocks_Injection.Experiment(1), size(MeanForBlock_Task_Injection,1),1);

%% save Data-Structures to plot
if ~exist(['Y:\Projects\PhysiologicalRecording\Data\' ,monkey , '\AllSessions'])
 mkdir(['Y:\Projects\PhysiologicalRecording\Data\' ,monkey , '\AllSessions'])
end
save(['Y:\Projects\PhysiologicalRecording\Data\' ,monkey , '\AllSessions\',monkey ,'_Table_HeartrateVaribility_PerSession_' , targetBrainArea ],'Table');
writetable(Table, ['Y:\Projects\PhysiologicalRecording\Data\' ,monkey , '\AllSessions\', monkey, '_Table_HeartrateVaribility_PerSession_', targetBrainArea], 'Delimiter', ' ')

writetable(TableBlocks, ['Y:\Projects\PhysiologicalRecording\Data\' ,monkey , '\AllSessions\' monkey,'_Table_HeartrateVaribility_PerSessionPerBlock_', targetBrainArea], 'Delimiter', ' ')
save(['Y:\Projects\PhysiologicalRecording\Data\' ,monkey , '\AllSessions\', monkey, '_Table_HeartrateVaribility_PerSessionPerBlocks_' , targetBrainArea],'TableBlocks');

save(['Y:\Projects\PhysiologicalRecording\Data\' ,monkey , '\AllSessions\',monkey '_Table_MeanForBlock_Task_Control_', targetBrainArea ],'MeanForBlock_Task_Control');
save(['Y:\Projects\PhysiologicalRecording\Data\' ,monkey , '\AllSessions\',monkey ,'_Table_MeanForBlock_Task_Injection_' , targetBrainArea],'MeanForBlock_Task_Injection');



save(['Y:\Projects\PhysiologicalRecording\Data\' ,monkey , '\AllSessions\',monkey, '_Structure_HeartrateVaribility_PerSession_Control_' , targetBrainArea],'S_con');
save(['Y:\Projects\PhysiologicalRecording\Data\' ,monkey , '\AllSessions\',monkey, '_Structure_HeartrateVaribility_PerSession_Inactivation_' , targetBrainArea],'S_ina');
save(['Y:\Projects\PhysiologicalRecording\Data\' ,monkey , '\AllSessions\',monkey, '_Structure_HeartrateVaribility_PerSessionPerBlock_Control_', targetBrainArea ],'S_Blocks_con');
save(['Y:\Projects\PhysiologicalRecording\Data\' ,monkey , '\AllSessions\',monkey, '_Structure_HeartrateVaribility_PerSessionPerBlock_Inactivation_' , targetBrainArea],'S_Blocks_ina');
save(['Y:\Projects\PhysiologicalRecording\Data\' ,monkey , '\AllSessions\',monkey, '_Structure_HeartrateVaribility_PerSessionPerBlock_', targetBrainArea ],'S_Blocks2');

save([Path_addtoDropbox ,filesep, monkey, filesep ,monkey, '_Table_HeartrateVaribility_PerSession_' , targetBrainArea ],'Table');
writetable(Table, [Path_addtoDropbox ,filesep, monkey, filesep,monkey, '_Table_HeartrateVaribility_PerSession_' , targetBrainArea ], 'Delimiter', ' ')




%% save Table for further statistical analysis
writetable(Table, ['C:\Users\kkaduk\Dropbox\PhD\Projects\body_signals_analysis\Data\', 'Table_HeartrateVaribility_PerSession'], 'Delimiter', ' ')
writetable(TableBlocks, ['C:\Users\kkaduk\Dropbox\PhD\Projects\body_signals_analysis\Data\', 'Table_HeartrateVaribility_PerSessionPerBlock'], 'Delimiter', ' ')



