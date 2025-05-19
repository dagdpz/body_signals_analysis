function out_cap = bsa_respiration_analyze_one_session(session_path,pathExcel,settings_filename,varargin)
%bsa_ecg_analyze_one_session  - analyzing ECG in one session (in multiple runs/blocks)
%
% USAGE:
%out = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190625','Y:\Logs\Inactivation\Curius\Curius_Inactivation_log_since201905.xlsx','bsa_settings_Curius2019.m','Y:\Projects\PhysiologicalRecording\Data\Curius\20190625');
% out = bsa_respiration_analyze_one_session(session_path,'',false,'dataOrigin','TDT','sessionInfo',ses);
%
% INPUTS:
%		session_path		- Path to session data
%       pathExcel           - excel file
%       settings_filename   - name of the mfile with specific session/monkey settings
%		varargin (optional) - see % define default arguments and their potential values
%
% OUTPUTS:
%		out                 - see struct
%
% REQUIRES:	Igtools, bsa_concatenate_trials_body_signals, bsa_ecg_analyze_one_run
%
% See also BSA_ECG_ANALYZE_ONE_RUN, BSA_ECG_ANALYZE_MANY_SESSIONS
%
%20211001
% Author(s):	I.Kagan, DAG, DPZ
% URL:		http://www.dpz.eu/dag
%
% Change log:
% 20190226:	Created function (Igor Kagan)
% ...
% $Revision: 1.0 $  $Date: 2019-02-26 14:22:52 $

% ADDITIONAL INFO:
% What is the function doing?
%1) loads the created mat-file from bsa_read_and_save_TDT_data_without_behavior.m
%2) bsa_concatenate_trials_body_signals
%3) bsa_ecg_analyze_one_run -> preprocessing the ECG, create R-R intervals
%4) Plot & save as PDFs
%%%%%%%%%%%%%%%%%%%%%%%%%[DAG mfile header version 1]%%%%%%%%%%%%%%%%%%%%%%%%%

warning off;

% make settings work from any computer (settings_path relative to location of bsa toolbox)
mfullpath = mfilename('fullpath');
mpathname = fileparts(mfullpath);
settings_path = [mpathname filesep 'settings' filesep settings_filename];
run(settings_path);


% define default arguments and their potential values
def_saveResults = session_path; % 1st optional argument (directory to save results, if empty then save to session_path)
def_keepRunFigs = false;        % 2nd optional argument
val_keepRunFigs = {'keepRunFigs',true};
chk_keepRunFigs = @(x) islogical(x);
def_dataOrigin  = 'combined';    % 3rd optional argument pair
val_dataOrigin  = {'combined','TDT'};
chk_dataOrigin  = @(x) any(validatestring(x,val_dataOrigin));
def_sessionInfo = [];           % 4 optional argument pair (can be defined in bsa_ecg_analyze_many_sessions)

p = inputParser; % in order of arguments
addRequired(p, 'session_path',@ischar);
addRequired(p, 'pathExcel',@ischar);
addRequired(p, 'settings_filename',@ischar);

addOptional(p, 'saveResults',def_saveResults,@ischar);
addOptional(p, 'keepRunFigs',def_keepRunFigs,chk_keepRunFigs);
addParameter(p,'dataOrigin',def_dataOrigin,chk_dataOrigin);
addParameter(p,'sessionInfo',def_sessionInfo,@isstruct);

parse(p,session_path,pathExcel,settings_path,varargin{:});
par = p.Results;

if isempty(par.saveResults),
    par.saveResults = session_path;
end

session_name_idx = strfind(session_path,'20');
session_name = session_path(session_name_idx(1):session_name_idx(1)+7);


if ~exist(par.saveResults,'dir'),
    mkdir(par.saveResults);
end

ses = par.sessionInfo;

%% which run is task and which is rest? information stored in the excel-sheet or behavior file
%% which run is task and which is rest? information stored in the excel-sheet (manual input) and behavior file
% excel file will have a priority so that one can manually exclude some runs
if ~isempty(pathExcel)
    table = readtable(pathExcel);
    if  sum(table.date == str2num(session_name)) > 0
        ses.monkey          =   table.monkey(table.date == str2num(session_name))';
        ses.date            =   table.date(table.date == str2num(session_name))';
        ses.experiment      =   table.experiment(table.date == str2num(session_name))';
        
        ses.injection       =   table.injection(table.date == str2num(session_name))';
        ses.brain_area      =   table.brain_area(table.date == str2num(session_name))';
        ses.hemisphere      =   table.hemisphere(table.date == str2num(session_name))';
        ses.x_grid          =   table.x_grid(table.date == str2num(session_name))';
        ses.y_grid          =   table.y_grid(table.date == str2num(session_name))';
        ses.concentration_mg_ml          =   table.concentration_mg_ml(table.date == str2num(session_name))';
        ses.volume_ul       =   table.volume_ul(table.date == str2num(session_name))';
        ses.substance       =   table.substance(table.date == str2num(session_name))';
        ses.depthfromTheTopOfTheGrid      =   table.depthfromTheTopOfTheGrid_mm(table.date == str2num(session_name))';
        ses.injection_method              =   table.injection_method(table.date == str2num(session_name))';
        ses.ePhys           =   table.ePhys(table.date == str2num(session_name))';
        
        ses.run             =   table.run(table.date == str2num(session_name))';
        ses.nrblock_combinedFiles =   table.block(table.date == str2num(session_name))';
        ses.tasktype_str    =   table.task(table.date == str2num(session_name))';
        ses.tasktype        =   table.tasktype(table.date == str2num(session_name))';
        
        %Similar to the  delete runs which
        ses.first_inj_block =  min(ses.nrblock_combinedFiles(strcmp(ses.injection , 'Post'))) ;
        ses.nrblock_combinedFiles(ses.nrblock_combinedFiles == 0) = [];
        
    else
        disp([pathExcel ,'   Excel-File does not include this date  ' , num2str(session_name)])
    end
end

%% What happens when no Block is recorded for a run - remove this rows from the Excel
% Blocks with entry 0 in the Excel are invalid, & No-Entry?
idx = ses.nrblock_combinedFiles ~=0 & ~isnan(ses.nrblock_combinedFiles);
[valid_blocks, valid_idx] = unique(ses.nrblock_combinedFiles(idx));

% all valid entries of the excel sheet %ses = ses(valid_idx);
filtered_ses = ses;

% Get the names of all fields in the structure
fieldNames = fieldnames(ses);

% Iterate through each field
for i = 1:length(fieldNames)
    currentField = fieldNames{i};
    % Check if the current field is an array (numeric or cell) and has the same number of elements as 'nrblock_combinedFiles'
    if isnumeric(ses.(currentField)) || iscell(ses.(currentField))
        if length(ses.(currentField)) == length(ses.nrblock_combinedFiles)
            % Apply the unique indices to filter the field
            filtered_ses.(currentField) = ses.(currentField)(idx);
        end
    end
end

ses = filtered_ses;

%% no matter if we are loading TDT or combined files, have one parameter (f.e. files_to_load) contating all files in that folder
if ~strcmp(par.dataOrigin, 'TDT'),
    files_to_load = dir([session_path filesep '*.mat']);
    n_blocks = numel(files_to_load);
    
else
    load([session_path filesep 'bodysignals_wo_behavior.mat']);
    
    Fs        = dat.ECG_SR;
    ECG       = dat.ECG;
    CAP       = dat.CAP;
    POX       = dat.POX;
    
    n_blocks  = numel(dat.ECG);
    disp(['Found ' num2str(n_blocks) ' blocks in ' par.dataOrigin]);
end
i_block=0;

disp(['Found ' num2str(n_blocks) ' blocks as file' ]);



for f=1:n_blocks
    if ~strcmp(par.dataOrigin, 'TDT'),
        NrBlock = files_to_load(f).name(end-5: end-4);
        NrBlock = str2num(NrBlock);
    else
        NrBlock = dat.blockname(f);
    end
    BlockExcel_uniqu = length(unique(ses.nrblock_combinedFiles)); % count unique blocks
    BlockExcel = length(unique(ses.nrblock_combinedFiles)); % count unique blocks
    disp(['Found ' num2str(BlockExcel) '  blocks as Excel-file' ]);
    disp(['Found ' num2str(BlockExcel_uniqu) ' unique blocks as Excel-file' ]);
    
    
    if ~ismember(NrBlock,valid_blocks)
        continue; % skip this block
        %Make a Note into the LogFile
        info.folderPath = ['Y:\Data\BodySignals\ECG\' ses.monkey{1}];
        info.monkey = ses.monkey{1};
        info.session = num2str(ses.date(1));
        info.Nrblock =num2str(NrBlock);
        info.i_block =num2str(i_block);
        info.taskType_Excel = '-2';
        info.taskType_Behavior = '-2';
        info.errorMessage = 'File/NrBlock is not listed in Excel-File';
        writeLogEntry(info)
    end
    
    i_ses = find(ses.nrblock_combinedFiles == NrBlock);% index for session excel table entries;
    
    %% what happens if there are 2 files with the same block?? Error! because i_sess has two entries
    
    if isempty(i_ses)
        disp('Block from File not included in the Excel-File')
    elseif numel(i_ses) > 1
        Nr_SameBlock = numel(i_ses);
    else
        Nr_SameBlock = 1;
    end
    
    for i = 1:Nr_SameBlock
        
        i_block=i_block+1; % for data storage;
        
        if ~strcmp(par.dataOrigin, 'TDT'),
            %Load behavioral file
            load([session_path filesep files_to_load(f).name])
            % get the tasktype (rest/task) from behavioral file
            if task.type == Set.task.Type && numel(trial) > Set.task.mintrials % exclude short runs and calibration
                ses.tasktype_beh(i_block)   =    1; % task
            elseif task.type == Set.rest.Type && all(trial(1).task.reward.time_neutral == Set.rest.reward)
                ses.tasktype_beh(i_block)   =    0; % rest
            else
                ses.tasktype_beh(i_block)   =   -2;
            end
            
        else
            if ~isempty(pathExcel) && sum(table.date == str2num(session_name)) > 0
                ses.tasktype_beh(i_block)  =  ses.tasktype(ses.nrblock_combinedFiles == NrBlock) ; %ses.type(~ses.nrblock_combinedFiles == 0);
            end
        end
        ses.type(i_block) = ses.tasktype_beh(i_block);
        %  Check entry between behavioral file and excel
        if  ~isempty(pathExcel) && sum(table.date == str2num(session_name)) > 0 %&&  ~(ses.type(i_block) == -2)
            
            if ses.tasktype_beh(i_block) == ses.tasktype(i_ses(i)) && (ses.tasktype_beh(i_block) == 1 || ses.tasktype_beh(i_block) == 0)
                % conditions in the Excel bodysignals table and behavioral
                % file match and are either task or rest - don't need to do
                % anything, proceed with subsequent analysis as it is
            elseif  ses.tasktype(i_ses(i)) == -2
                % this block is marked as -2 (to skip) in the Excel
                % bodysignals table - in this case the table has a priority
                % and the current block is skipped
                disp(['Block ' num2str(NrBlock) ' is excluded because of a -2 in the Excel-sheet'])
                ses.type(i_block) = -2;
            elseif ses.tasktype_beh(i_block) == -2
                % This block is assigned with -2 and is either a short task
                % block, calibration, or a rest with reward (which
                % shouldn't happen) and is going to be excluded
                disp(['Conditions do not match Excel-sheet column tasktype ' num2str(ses.tasktype(ses.nrblock_combinedFiles == NrBlock)  ) ' is not identical with the information from behavior file '  num2str(ses.tasktype_beh(i_block) ) ' in Block ' num2str(NrBlock)]);
                ses.tasktype(i_block) = -2;
            elseif ses.tasktype_beh(i_block) == -2  && task.type ~= Set.task.Type &&  ses.tasktype(ses.nrblock_combinedFiles == i_block) ~= -2 && numel(trial) > Set.task.mintrials
                disp(['Conditions do not match Excel-sheet column tasktype ' num2str(ses.tasktype(ses.nrblock_combinedFiles == NrBlock)  ) ' is not identical with the information from behavior file '  num2str(ses.tasktype_beh(i_block) ) ' in Block ' num2str(NrBlock)]);
                ses.type(i_block) =  ses.tasktype(ses.nrblock_combinedFiles == i_block);
                disp('Overwrote the information from behavior file with Excel-sheet');
            else
                
                info.folderPath = ['Y:\Data\BodySignals\ECG\' ses.monkey{1}];
                info.monkey = ses.monkey{1};
                info.session = num2str(ses.date(1));
                info.Nrblock =num2str(NrBlock);
                info.i_block =num2str(i_block);
                info.taskType_Excel = num2str(ses.tasktype(i_ses(i)));
                info.taskType_Behavior = num2str(ses.tasktype_beh(i_block));
                info.errorMessage = 'TaskType do not match - behav vs. excel!';
                
                writeLogEntry(info)
                
                disp(['Conditions do not match!!! Excel-sheet colum tasktype ' num2str(ses.tasktype(ses.nrblock_combinedFiles == NrBlock)  ) ' is not identical with the information from behavior file'  num2str(ses.tasktype_beh(i_block) ) ' in Block' num2str(NrBlock)]);
                
            end
        end %close if for check
        
        
        %% first check if to skip the block
        if ~isempty(ses),
            if ses.type(i_block) == -2 || isnan(ses.type(i_block)) ,
                disp(sprintf('Skipping block %d',i_block));
                continue
            end
        end
        
        disp(sprintf('Processing block %d',i_block));
        
        if strcmp(par.dataOrigin, 'TDT'),
            ecgSignal   = double(ECG{i_block});
            capSignal   = double(CAP{i_block});
            poxSignal   = double(POX{i_block});
            
        else
            OUT = bsa_concatenate_trials_body_signals([session_path filesep files_to_load(f).name]);
            ecgSignal   = OUT.ECG1;
            capSignal   = OUT.CAP1;
            poxSignal   = OUT.POX1;
            
            Fs          = OUT.Fs;
        end
        
        % respiration
        [ out_cap(i_block), Tab_outlier_cap(i_block) ]= bsa_respiration_analyze_one_run(capSignal,settings_path,Fs,Set.Plot,i_block,NrBlock, ses.monkey{1});
        if  ~isempty(out_cap(i_block).hf)
            print(out_cap(i_block).hf, sprintf('%sblock%02d_NrBlock%02d.png', [par.saveResults filesep 'cap_'], i_block, NrBlock),'-dpng','-r0');
        end
        if ~par.keepRunFigs
            close(out_cap(i_block).hf);
        end
        
        
        % Ensure save directory exists
        if ~exist(par.saveResults, 'dir')
            mkdir(par.saveResults);
        end
        
        % Construct file name safely
        fileName = fullfile(par.saveResults, sprintf('cap_block%02d_NrBlock%02d_N.png', i_block, NrBlock));
        
        % Check if figure handle is valid before saving
        if  ~isempty(out_cap(i_block).hf)
            if isvalid(out_cap(i_block).hf)
                print(out_cap(i_block).hf, fileName, '-dpng', '-r300');
            end
        else
            warning('Figure handle for block %d is invalid', i_block);
        end
    end %%More than one of the same Block Number, but different runs
    
end % all files

save([par.saveResults filesep session_name '_cap.mat'],'out_cap','Tab_outlier_cap','par','ses','session_name','session_path');

%
blks = 1:n_blocks;
taskMFC = [0.3922    0.4745    0.6353];
restMFC = [1 1 1];

if ~isempty(ses)
    rest_idx = find(ses.type == 0);
    task_idx = find(ses.type == 1);
else
    task_idx = [];
    rest_idx = blks;
    restMFC = [0.8 0.8 0.8];
end

%
% ig_figure('Name',[session_path '->' par.saveResults],'Position',[200 200 900 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
% ha(1) = subplot(4,1,1);
% plot(blks(rest_idx),[out(rest_idx).mean_R2R_valid_bpm],'bo','MarkerEdgeColor',[0.4235    0.2510    0.3922],'MarkerFaceColor',restMFC); hold on;
% plot(blks(task_idx),[out(task_idx).mean_R2R_valid_bpm],'bo','MarkerEdgeColor',[0.4235    0.2510    0.3922],'MarkerFaceColor',taskMFC);
% plot(blks(rest_idx),[out(rest_idx).median_R2R_valid_bpm],'bs','MarkerEdgeColor',[0.4235    0.2510    0.3922],'MarkerFaceColor',restMFC);
% plot(blks(task_idx),[out(task_idx).median_R2R_valid_bpm],'bs','MarkerEdgeColor',[0.4235    0.2510    0.3922],'MarkerFaceColor',taskMFC);
% ylabel('Mean (o) & med (s) of R2R (bpm)');
%
% ha(2) = subplot(4,1,2);
% plot(blks(rest_idx),[out(rest_idx).rmssd_R2R_valid_ms],'bo','MarkerFaceColor',restMFC); hold on;
% plot(blks(task_idx),[out(task_idx).rmssd_R2R_valid_ms],'bo','MarkerFaceColor',taskMFC);
% ylabel('RMSSD of R2R interval (ms)');
%
% ha(3) = subplot(4,1,3);
% plot(blks(rest_idx),[out(rest_idx).std_R2R_valid_bpm],'bo','MarkerFaceColor',restMFC);  hold on;
% plot(blks(task_idx),[out(task_idx).std_R2R_valid_bpm],'bo','MarkerFaceColor',taskMFC);
% ylabel('SD of R2R interval (bpm)');
%
% ha(4) = subplot(4,1,4);
% plot(blks(rest_idx),[out(rest_idx).lfPower],'ro','MarkerFaceColor',restMFC); hold on;
% plot(blks(task_idx),[out(task_idx).lfPower],'ro','MarkerFaceColor',taskMFC);
% plot(blks(rest_idx),[out(rest_idx).hfPower],'go','MarkerFaceColor',restMFC);
% plot(blks(task_idx),[out(task_idx).hfPower],'go','MarkerFaceColor',taskMFC);
% legend({'lf rest','lf task','hf rest','hf task'},'location','Best');
% xlabel('blocks');
% ylabel('LF and HF power (ms^2)');
%
%
% if ~isempty(ses),
%
%     for ax = 1:length(ha),
%         axes(ha(ax));
%         ig_add_vertical_line(ses.first_inj_block -0.5);
%
%     end
%
% end
%
%
% print(gcf,[par.saveResults filesep session_name '_R2R_TC.pdf'],'-dpdf','-r0');


%respiration

ig_figure('Name',[session_path '->' par.saveResults],'Position',[200 200 900 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
ha(1) = subplot(4,1,1);
plot(blks(rest_idx),[out_cap(rest_idx).mean_B2B_valid_bpm],'bo','MarkerEdgeColor',[0.4235    0.2510    0.3922],'MarkerFaceColor',restMFC); hold on;
plot(blks(task_idx),[out_cap(task_idx).mean_B2B_valid_bpm],'bo','MarkerEdgeColor',[0.4235    0.2510    0.3922],'MarkerFaceColor',taskMFC);
plot(blks(rest_idx),[out_cap(rest_idx).median_B2B_valid_bpm],'bs','MarkerEdgeColor',[0.4235    0.2510    0.3922],'MarkerFaceColor',restMFC);
plot(blks(task_idx),[out_cap(task_idx).median_B2B_valid_bpm],'bs','MarkerEdgeColor',[0.4235    0.2510    0.3922],'MarkerFaceColor',taskMFC);
ylabel('Mean (o) & med (s) of B2B (bpm)');

ha(2) = subplot(4,1,2);
plot(blks(rest_idx),[out_cap(rest_idx).rmssd_B2B_valid_ms],'bo','MarkerFaceColor',restMFC); hold on;
plot(blks(task_idx),[out_cap(task_idx).rmssd_B2B_valid_ms],'bo','MarkerFaceColor',taskMFC);
ylabel('RMSSD of B2B interval (ms)');

ha(3) = subplot(4,1,3);
plot(blks(rest_idx),[out_cap(rest_idx).std_B2B_valid_bpm],'bo','MarkerFaceColor',restMFC);  hold on;
plot(blks(task_idx),[out_cap(task_idx).std_B2B_valid_bpm],'bo','MarkerFaceColor',taskMFC);
ylabel('SD of B2B interval (bpm)');

ha(4) = subplot(4,1,4);
plot(blks(rest_idx),[out_cap(rest_idx).lfPower],'ro','MarkerFaceColor',restMFC); hold on;
plot(blks(task_idx),[out_cap(task_idx).lfPower],'ro','MarkerFaceColor',taskMFC);
plot(blks(rest_idx),[out_cap(rest_idx).hfPower],'go','MarkerFaceColor',restMFC);
plot(blks(task_idx),[out_cap(task_idx).hfPower],'go','MarkerFaceColor',taskMFC);
legend({'lf rest','lf task','hf rest','hf task'},'location','Best');
xlabel('blocks');
ylabel('LF and HF power (ms^2)');


if ~isempty(ses) && ~(strcmp(ses.experiment(1) , 'ephys')),
    
    for ax = 1:length(ha),
        axes(ha(ax));
        ig_add_vertical_line(ses.first_inj_block -0.5);
        
    end
    
end


print(gcf,[par.saveResults filesep session_name '_B2B_TC.pdf'],'-dpdf','-r0');
close(gcf)
warning on;

