function [out_cap, Tab_outlier_cap, respQC_table, par, ses, blockMap_table] = ...
    bsa_respiration_analyze_one_session(session_path, pathExcel, settings_filename, varargin)
%bsa_respiration_analyze_one_session  Analyze respiration/CAP for one session.
%
% IMPORTANT INDEXING RULE
% -------------------------------------------------------------------------
% out_cap(k) is indexed by the session/block index k.
%
% This means:
%   out_cap(k) corresponds to ses(k)
%
% It does NOT mean:
%   out_cap(k) is the kth successfully processed physiology block.
%
% Therefore:
%   - tasktype == -2 marks a block as invalid/skipped.
%   - tasktype == -2 does NOT remove the row before alignment.
%   - skipped blocks remain represented in out_cap(k).
%   - trailing skipped blocks are also preserved in numel(out_cap).
%
% After this function:
%   numel(out_cap) == numel(ses.nrblock_combinedFiles)
%   numel(Tab_outlier_cap) == numel(ses.nrblock_combinedFiles)
%
% OUTPUTS:
%   out_cap          - struct array, one element per session/block index
%   Tab_outlier_cap  - struct array, one element per session/block index
%   respQC_table     - block-wise respiration QC summary table
%   par              - parsed input arguments
%   ses              - session metadata
%   blockMap_table   - explicit mapping/QC table for block alignment
%
% Requires:
%   bsa_respiration_analyze_one_run
%   bsa_concatenate_trials_body_signals

warning off;

%% ------------------------------------------------------------------------
% Settings
% -------------------------------------------------------------------------
mfullpath = mfilename('fullpath');
mpathname = fileparts(mfullpath);
settings_path = [mpathname filesep 'settings' filesep settings_filename];
run(settings_path);

%% ------------------------------------------------------------------------
% Parse inputs
% -------------------------------------------------------------------------
def_saveResults = session_path;
def_keepRunFigs = false;
def_dataOrigin  = 'combined';
def_sessionInfo = [];

val_dataOrigin = {'combined','TDT'};
chk_dataOrigin = @(x) any(validatestring(x, val_dataOrigin));
chk_keepRunFigs = @(x) islogical(x) && isscalar(x);

p = inputParser;
addRequired(p, 'session_path', @ischar);
addRequired(p, 'pathExcel', @ischar);
addRequired(p, 'settings_filename', @ischar);
addOptional(p, 'saveResults', def_saveResults, @ischar);
addOptional(p, 'keepRunFigs', def_keepRunFigs, chk_keepRunFigs);
addParameter(p, 'dataOrigin', def_dataOrigin, chk_dataOrigin);
addParameter(p, 'sessionInfo', def_sessionInfo, @isstruct);

parse(p, session_path, pathExcel, settings_filename, varargin{:});
par = p.Results;

if isempty(par.saveResults)
    par.saveResults = session_path;
end

if ~exist(par.saveResults, 'dir')
    mkdir(par.saveResults);
end

%% ------------------------------------------------------------------------
% Session name
% -------------------------------------------------------------------------
session_name_idx = strfind(session_path, '20');
if isempty(session_name_idx)
    error('Could not extract session date from session_path: %s', session_path);
end
session_name = session_path(session_name_idx(1):session_name_idx(1)+7);

%% ------------------------------------------------------------------------
% Session metadata
% -------------------------------------------------------------------------
ses = par.sessionInfo;

if ~isempty(pathExcel)
    excelTable = readtable(pathExcel);

    if sum(excelTable.date == str2double(session_name)) > 0
        idxDate = excelTable.date == str2double(session_name);
        nRowsThisSession = sum(idxDate);

        ses.monkey          = excelTable.monkey(idxDate)';
        ses.date            = excelTable.date(idxDate)';
        ses.experiment      = excelTable.experiment(idxDate)';

        ses.injection       = excelTable.injection(idxDate)';
        ses.brain_area      = excelTable.brain_area(idxDate)';
        ses.hemisphere      = excelTable.hemisphere(idxDate)';
        ses.x_grid          = excelTable.x_grid(idxDate)';
        ses.y_grid          = excelTable.y_grid(idxDate)';
        ses.concentration_mg_ml = excelTable.concentration_mg_ml(idxDate)';
        ses.volume_ul       = excelTable.volume_ul(idxDate)';
        ses.substance       = excelTable.substance(idxDate)';
        ses.depthfromTheTopOfTheGrid = excelTable.depthfromTheTopOfTheGrid_mm(idxDate)';
        ses.injection_method = excelTable.injection_method(idxDate)';
        ses.ePhys           = excelTable.ePhys(idxDate)';

        ses.run             = excelTable.run(idxDate)';
        ses.nrblock_combinedFiles = excelTable.block(idxDate)';
        ses.tasktype_str    = excelTable.task(idxDate)';
        ses.tasktype        = excelTable.tasktype(idxDate)';

        ses.excelRowInSession = 1:nRowsThisSession;
        ses.excelRowInExcel   = find(idxDate)';

        postBlocks = ses.nrblock_combinedFiles(strcmp(ses.injection, 'Post'));
        if ~isempty(postBlocks)
            ses.first_inj_block = min(postBlocks);
        else
            ses.first_inj_block = NaN;
        end
    else
        disp([pathExcel '   Excel-File does not include this date  ' session_name]);
    end
end

if isempty(ses) || ~isfield(ses, 'nrblock_combinedFiles')
    error('Session metadata ''ses.nrblock_combinedFiles'' is missing. Provide pathExcel or sessionInfo.');
end

%% ------------------------------------------------------------------------
% Valid blocks from Excel/session metadata
% -------------------------------------------------------------------------
% Important:
%   We remove only rows with block == 0 or NaN.
%   We do NOT remove tasktype == -2 rows.
%
% tasktype == -2 is an exclusion flag, not a row-deletion rule.

nBeforeFilter = numel(ses.nrblock_combinedFiles);

idxValidExcel = ses.nrblock_combinedFiles ~= 0 & ...
                ~isnan(ses.nrblock_combinedFiles);

valid_blocks = unique(ses.nrblock_combinedFiles(idxValidExcel));

filtered_ses = ses;
fieldNames = fieldnames(ses);

for iField = 1:numel(fieldNames)
    currentField = fieldNames{iField};

    if isnumeric(ses.(currentField)) || iscell(ses.(currentField))
        if length(ses.(currentField)) == nBeforeFilter
            filtered_ses.(currentField) = ses.(currentField)(idxValidExcel);
        end
    end
end

ses = filtered_ses;

nSessionBlocks = numel(ses.nrblock_combinedFiles);

%% ------------------------------------------------------------------------
% Find files / TDT blocks
% -------------------------------------------------------------------------
if ~strcmp(par.dataOrigin, 'TDT')
    files_to_load = dir([session_path filesep '*.mat']);
    n_blocks = numel(files_to_load);
else
    load([session_path filesep 'bodysignals_wo_behavior.mat']);

    Fs  = dat.ECG_SR;
    ECG = dat.ECG; %#ok<NASGU>
    CAP = dat.CAP;
    POX = dat.POX; %#ok<NASGU>

    n_blocks = numel(dat.ECG);
    disp(['Found ' num2str(n_blocks) ' blocks in ' par.dataOrigin]);
end

out_cap = struct([]);
Tab_outlier_cap = struct([]);
respQC_table = table();

disp(['Found ' num2str(n_blocks) ' blocks as file']);
disp(['Found ' num2str(nSessionBlocks) ' valid session/block rows after removing block == 0 or NaN']);

%% ------------------------------------------------------------------------
% Initialize block map
% -------------------------------------------------------------------------
blockMap = initialize_block_map(nSessionBlocks, session_name, ses);

%% ------------------------------------------------------------------------
% Loop over blocks/files
% -------------------------------------------------------------------------
for f = 1:n_blocks

    if ~strcmp(par.dataOrigin, 'TDT')
        NrBlock = str2double(files_to_load(f).name(end-5:end-4));
        sourceFile = files_to_load(f).name;
    else
        NrBlock = dat.blockname(f);
        sourceFile = ['TDT_block_' num2str(NrBlock)];
    end

    BlockExcel = numel(unique(ses.nrblock_combinedFiles));
    disp(['Found ' num2str(BlockExcel) ' unique blocks as Excel-file']);

    if ~ismember(NrBlock, valid_blocks)
        disp(['Block ' num2str(NrBlock) ' is not listed as valid block in Excel/session metadata. Skipping file.']);
        continue;
    end

    i_ses = find(ses.nrblock_combinedFiles == NrBlock);

    if isempty(i_ses)
        disp('Block from file not included in the Excel-file');
        continue;
    elseif numel(i_ses) > 1
        Nr_SameBlock = numel(i_ses);
    else
        Nr_SameBlock = 1;
    end

    for i = 1:Nr_SameBlock

        % This is the key change:
        % k is the session/block index.
        % out_cap(k) corresponds to ses(k).
        k = i_ses(i);

        blockMap(k).encounteredFile = true;
        blockMap(k).source_file = sourceFile;
        blockMap(k).NrBlock_file = NrBlock;

        %% ------------------------------------------------------------
        % Task/rest type from behavior or Excel/TDT
        % -------------------------------------------------------------
        if ~strcmp(par.dataOrigin, 'TDT')
            load([session_path filesep files_to_load(f).name]);

            if task.type == Set.task.Type && numel(trial) > Set.task.mintrials
                ses.tasktype_beh(k) = 1;
            elseif task.type == Set.rest.Type && all(trial(1).task.reward.time_neutral == Set.rest.reward)
                ses.tasktype_beh(k) = 0;
            else
                ses.tasktype_beh(k) = -2;
            end
        else
            if ~isempty(pathExcel) && exist('excelTable', 'var') && ...
                    sum(excelTable.date == str2double(session_name)) > 0
                ses.tasktype_beh(k) = ses.tasktype(k);
            else
                ses.tasktype_beh(k) = NaN;
            end
        end

        ses.type(k) = ses.tasktype_beh(k);

        blockMap(k).tasktype_beh = ses.tasktype_beh(k);

        %% ------------------------------------------------------------
        % Check task/rest consistency with Excel
        % -------------------------------------------------------------
        if ~isempty(pathExcel) && exist('excelTable', 'var') && ...
                sum(excelTable.date == str2double(session_name)) > 0

            if ses.tasktype_beh(k) == ses.tasktype(k) && ...
                    (ses.tasktype_beh(k) == 1 || ses.tasktype_beh(k) == 0)
                % OK: Excel and behavior agree, and the block is task/rest.

            elseif ses.tasktype(k) == -2
                % Excel has priority. This block is excluded.
                disp(['Block ' num2str(NrBlock) ' is excluded because of a -2 in the Excel-sheet']);
                ses.type(k) = -2;
                blockMap(k).skip_reason = 'excel_tasktype_minus2';

            elseif ses.tasktype_beh(k) == -2
                % Behavior indicates invalid block.
                disp(['Conditions do not match Excel-sheet column tasktype ' ...
                    num2str(ses.tasktype(k)) ...
                    ' is not identical with the information from behavior file ' ...
                    num2str(ses.tasktype_beh(k)) ...
                    ' in Block ' num2str(NrBlock)]);

                ses.type(k) = -2;
                blockMap(k).skip_reason = 'behavior_tasktype_minus2';

            else
                % Mismatch, but not automatically skipped in the old logic.
                info.folderPath = ['Y:\Data\BodySignals\ECG\' ses.monkey{1}];
                info.monkey = ses.monkey{1};
                info.session = num2str(ses.date(1));
                info.Nrblock = num2str(NrBlock);
                info.i_block = num2str(k);
                info.taskType_Excel = num2str(ses.tasktype(k));
                info.taskType_Behavior = num2str(ses.tasktype_beh(k));
                info.errorMessage = 'TaskType do not match - behav vs. excel!';

                if exist('writeLogEntry', 'file') == 2
                    writeLogEntry(info);
                end

                disp(['Conditions do not match!!! Excel-sheet column tasktype ' ...
                    num2str(ses.tasktype(k)) ...
                    ' is not identical with the information from behavior file ' ...
                    num2str(ses.tasktype_beh(k)) ...
                    ' in Block ' num2str(NrBlock)]);

                blockMap(k).skip_reason = 'tasktype_mismatch_not_auto_skipped';
            end
        end

        blockMap(k).type_final = ses.type(k);

        %% ------------------------------------------------------------
        % Skip invalid blocks
        % -------------------------------------------------------------
        if ~isempty(ses)
            if ses.type(k) == -2 || isnan(ses.type(k))
                disp(sprintf('Skipping block %d', k)); %#ok<DSPS>

                if isempty(blockMap(k).skip_reason)
                    blockMap(k).skip_reason = 'type_final_minus2_or_nan';
                end

                blockMap(k).processed = false;
                blockMap(k).has_out_cap = false;
                continue;
            end
        end

        disp(sprintf('Processing block %d', k)); %#ok<DSPS>

        %% ------------------------------------------------------------
        % Load signals
        % -------------------------------------------------------------
        if strcmp(par.dataOrigin, 'TDT')
            % Use file/TDT index f for the signal source.
            % The output is still saved to out_cap(k), where k is session row.
            capSignal = double(CAP{f});
        else
            OUT = bsa_concatenate_trials_body_signals([session_path filesep files_to_load(f).name]);
            capSignal = OUT.CAP1;
            Fs = OUT.Fs;
        end

        %% ------------------------------------------------------------
        % Respiration analysis for this run/block
        % -------------------------------------------------------------
        [out_tmp, tab_tmp] = ...
            bsa_respiration_analyze_one_run( ...
                capSignal, settings_path, Fs, Set.Plot, k, NrBlock, ses.monkey{1});

        out_cap = assign_struct_element_compatible(out_cap, k, out_tmp, nSessionBlocks);
        Tab_outlier_cap = assign_struct_element_compatible(Tab_outlier_cap, k, tab_tmp, nSessionBlocks);

        %% ------------------------------------------------------------
        % Add explicit metadata to processed outputs
        % -------------------------------------------------------------
        out_cap(k).processed = true;
        out_cap(k).skip_reason = '';
        out_cap(k).session_index = k;
        out_cap(k).nrblock = NrBlock;
        out_cap(k).nrblock_combinedFiles = ses.nrblock_combinedFiles(k);
        out_cap(k).tasktype_excel = ses.tasktype(k);
        out_cap(k).tasktype_beh = ses.tasktype_beh(k);
        out_cap(k).type = ses.type(k);

        Tab_outlier_cap(k).processed = true;
        Tab_outlier_cap(k).skip_reason = '';
        Tab_outlier_cap(k).session_index = k;
        Tab_outlier_cap(k).nrblock = NrBlock;
        Tab_outlier_cap(k).nrblock_combinedFiles = ses.nrblock_combinedFiles(k);
        Tab_outlier_cap(k).tasktype_excel = ses.tasktype(k);
        Tab_outlier_cap(k).tasktype_beh = ses.tasktype_beh(k);
        Tab_outlier_cap(k).type = ses.type(k);

        blockMap(k).processed = true;
        blockMap(k).has_out_cap = true;
        blockMap(k).skip_reason = '';

        %% ------------------------------------------------------------
        % Save individual block figure
        % -------------------------------------------------------------
        if isfield(out_cap(k), 'hf') && ~isempty(out_cap(k).hf)
            print(out_cap(k).hf, ...
                sprintf('%sblock%02d_NrBlock%02d.png', ...
                [par.saveResults filesep 'cap_'], k, NrBlock), ...
                '-dpng', '-r0');
        end

        if ~par.keepRunFigs && isfield(out_cap(k), 'hf') && ...
                ~isempty(out_cap(k).hf)
            if isvalid(out_cap(k).hf)
                close(out_cap(k).hf);
            end
        end

        if ~exist(par.saveResults, 'dir')
            mkdir(par.saveResults);
        end

        fileName = fullfile(par.saveResults, ...
            sprintf('cap_block%02d_NrBlock%02d_N.png', k, NrBlock));

        if isfield(out_cap(k), 'hf') && ~isempty(out_cap(k).hf)
            if isvalid(out_cap(k).hf)
                print(out_cap(k).hf, fileName, '-dpng', '-r300');
            end
        end
    end
end

%% ------------------------------------------------------------------------
% Ensure full-length output arrays
% -------------------------------------------------------------------------
% This is the key final step:
% skipped trailing blocks are now represented.
%
% After this:
%   numel(out_cap) == nSessionBlocks
%   numel(Tab_outlier_cap) == nSessionBlocks

out_cap = ensure_full_length_out_cap(out_cap, nSessionBlocks, blockMap, ses);
Tab_outlier_cap = ensure_full_length_tab_outlier(Tab_outlier_cap, nSessionBlocks, blockMap, ses);

%% ------------------------------------------------------------------------
% Make block mapping table
% -------------------------------------------------------------------------
blockMap_table = make_blockMap_table(blockMap, ses, session_name);

disp('Block mapping summary:')
disp(blockMap_table)

%% ------------------------------------------------------------------------
% Respiration QC summary across blocks
% -------------------------------------------------------------------------
respQC_table = make_respQC_table_from_out_cap(out_cap, ses);
disp(respQC_table);

%% ------------------------------------------------------------------------
% Save CAP output
% -------------------------------------------------------------------------
save([par.saveResults filesep session_name '_cap.mat'], ...
    'out_cap', ...
    'Tab_outlier_cap', ...
    'respQC_table', ...
    'blockMap_table', ...
    'par', ...
    'ses', ...
    'session_name', ...
    'session_path');

%% ------------------------------------------------------------------------
% Session-level respiration plot
% -------------------------------------------------------------------------
if ~isempty(out_cap)
    make_session_respiration_plot(out_cap, ses, nSessionBlocks, session_path, par.saveResults, session_name);
end

warning on;

end

%% =========================================================================
% Local helper: initialize block map
% =========================================================================
function blockMap = initialize_block_map(nSessionBlocks, session_name, ses)

emptyMap = struct();
emptyMap.session_name = session_name;
emptyMap.session_index = NaN;
emptyMap.excelRowInSession = NaN;
emptyMap.excelRowInExcel = NaN;
emptyMap.NrBlock_excel = NaN;
emptyMap.NrBlock_file = NaN;
emptyMap.run = NaN;
emptyMap.tasktype_excel = NaN;
emptyMap.tasktype_beh = NaN;
emptyMap.type_final = NaN;
emptyMap.encounteredFile = false;
emptyMap.processed = false;
emptyMap.has_out_cap = false;
emptyMap.skip_reason = '';
emptyMap.source_file = '';

blockMap = repmat(emptyMap, 1, nSessionBlocks);

for k = 1:nSessionBlocks
    blockMap(k).session_index = k;
    blockMap(k).NrBlock_excel = get_numeric_ses_value(ses, 'nrblock_combinedFiles', k);
    blockMap(k).run = get_numeric_ses_value(ses, 'run', k);
    blockMap(k).tasktype_excel = get_numeric_ses_value(ses, 'tasktype', k);

    if isfield(ses, 'excelRowInSession')
        blockMap(k).excelRowInSession = get_numeric_ses_value(ses, 'excelRowInSession', k);
    else
        blockMap(k).excelRowInSession = k;
    end

    if isfield(ses, 'excelRowInExcel')
        blockMap(k).excelRowInExcel = get_numeric_ses_value(ses, 'excelRowInExcel', k);
    end

    if blockMap(k).tasktype_excel == -2
        blockMap(k).skip_reason = 'excel_tasktype_minus2_not_yet_encountered';
    else
        blockMap(k).skip_reason = 'not_yet_encountered';
    end
end

end

%% =========================================================================
% Local helper: ensure full-length out_cap
% =========================================================================
function out_cap = ensure_full_length_out_cap(out_cap, nSessionBlocks, blockMap, ses)

requiredFields = { ...
    'processed', ...
    'skip_reason', ...
    'session_index', ...
    'nrblock', ...
    'nrblock_combinedFiles', ...
    'tasktype_excel', ...
    'tasktype_beh', ...
    'type', ...
    'mean_B2B_valid_bpm', ...
    'median_B2B_valid_bpm', ...
    'std_B2B_valid_ms', ...
    'std_B2B_valid_bpm', ...
    'rmssd_B2B_valid_ms', ...
    'lfPower', ...
    'hfPower', ...
    'resp_qc', ...
    'hf'};

if isempty(out_cap)
    out_cap = make_default_out_cap_struct();
    out_cap = repmat(out_cap, 1, nSessionBlocks);
else
    out_cap = add_missing_fields(out_cap, requiredFields);
end

if numel(out_cap) < nSessionBlocks
    emptyOut = make_empty_like(out_cap);
    for k = (numel(out_cap) + 1):nSessionBlocks
        out_cap(k) = emptyOut;
    end
end

for k = 1:nSessionBlocks

    if isempty(out_cap(k).processed)
        out_cap(k).processed = false;
    end

    if isempty(out_cap(k).skip_reason)
        out_cap(k).skip_reason = blockMap(k).skip_reason;
    end

    if isempty(out_cap(k).session_index)
        out_cap(k).session_index = k;
    end

    if isempty(out_cap(k).nrblock)
        out_cap(k).nrblock = blockMap(k).NrBlock_excel;
    end

    if isempty(out_cap(k).nrblock_combinedFiles)
        out_cap(k).nrblock_combinedFiles = blockMap(k).NrBlock_excel;
    end

    if isempty(out_cap(k).tasktype_excel)
        out_cap(k).tasktype_excel = blockMap(k).tasktype_excel;
    end

    if isempty(out_cap(k).tasktype_beh)
        out_cap(k).tasktype_beh = blockMap(k).tasktype_beh;
    end

    if isempty(out_cap(k).type)
        if isfield(ses, 'type') && numel(ses.type) >= k
            out_cap(k).type = ses.type(k);
        else
            out_cap(k).type = blockMap(k).type_final;
        end
    end
end

end

%% =========================================================================
% Local helper: ensure full-length Tab_outlier_cap
% =========================================================================
function Tab_outlier_cap = ensure_full_length_tab_outlier(Tab_outlier_cap, nSessionBlocks, blockMap, ses)

requiredFields = { ...
    'processed', ...
    'skip_reason', ...
    'session_index', ...
    'nrblock', ...
    'nrblock_combinedFiles', ...
    'tasktype_excel', ...
    'tasktype_beh', ...
    'type'};

if isempty(Tab_outlier_cap)
    Tab_outlier_cap = make_default_tab_outlier_struct();
    Tab_outlier_cap = repmat(Tab_outlier_cap, 1, nSessionBlocks);
else
    Tab_outlier_cap = add_missing_fields(Tab_outlier_cap, requiredFields);
end

if numel(Tab_outlier_cap) < nSessionBlocks
    emptyTab = make_empty_like(Tab_outlier_cap);
    for k = (numel(Tab_outlier_cap) + 1):nSessionBlocks
        Tab_outlier_cap(k) = emptyTab;
    end
end

for k = 1:nSessionBlocks

    if isempty(Tab_outlier_cap(k).processed)
        Tab_outlier_cap(k).processed = false;
    end

    if isempty(Tab_outlier_cap(k).skip_reason)
        Tab_outlier_cap(k).skip_reason = blockMap(k).skip_reason;
    end

    if isempty(Tab_outlier_cap(k).session_index)
        Tab_outlier_cap(k).session_index = k;
    end

    if isempty(Tab_outlier_cap(k).nrblock)
        Tab_outlier_cap(k).nrblock = blockMap(k).NrBlock_excel;
    end

    if isempty(Tab_outlier_cap(k).nrblock_combinedFiles)
        Tab_outlier_cap(k).nrblock_combinedFiles = blockMap(k).NrBlock_excel;
    end

    if isempty(Tab_outlier_cap(k).tasktype_excel)
        Tab_outlier_cap(k).tasktype_excel = blockMap(k).tasktype_excel;
    end

    if isempty(Tab_outlier_cap(k).tasktype_beh)
        Tab_outlier_cap(k).tasktype_beh = blockMap(k).tasktype_beh;
    end

    if isempty(Tab_outlier_cap(k).type)
        if isfield(ses, 'type') && numel(ses.type) >= k
            Tab_outlier_cap(k).type = ses.type(k);
        else
            Tab_outlier_cap(k).type = blockMap(k).type_final;
        end
    end
end

end

%% =========================================================================
% Local helper: default out_cap placeholder
% =========================================================================
function s = make_default_out_cap_struct()

s = struct();
s.processed = false;
s.skip_reason = '';
s.session_index = [];
s.nrblock = [];
s.nrblock_combinedFiles = [];
s.tasktype_excel = [];
s.tasktype_beh = [];
s.type = [];

s.mean_B2B_valid_bpm = [];
s.median_B2B_valid_bpm = [];
s.std_B2B_valid_ms = [];
s.std_B2B_valid_bpm = [];
s.rmssd_B2B_valid_ms = [];
s.lfPower = [];
s.hfPower = [];

s.resp_qc = [];
s.hf = [];

end

%% =========================================================================
% Local helper: default Tab_outlier_cap placeholder
% =========================================================================
function s = make_default_tab_outlier_struct()

s = struct();
s.processed = false;
s.skip_reason = '';
s.session_index = [];
s.nrblock = [];
s.nrblock_combinedFiles = [];
s.tasktype_excel = [];
s.tasktype_beh = [];
s.type = [];

end

%% =========================================================================
% Local helper: add missing fields to struct array
% =========================================================================
function S = add_missing_fields(S, requiredFields)

for iField = 1:numel(requiredFields)
    fieldName = requiredFields{iField};

    if ~isfield(S, fieldName)
        for k = 1:numel(S)
            S(k).(fieldName) = [];
        end
    end
end

end

%% =========================================================================
% Local helper: make empty struct with same fields
% =========================================================================
function sEmpty = make_empty_like(S)

fieldNames = fieldnames(S);
sEmpty = struct();

for iField = 1:numel(fieldNames)
    sEmpty.(fieldNames{iField}) = [];
end

end

%% =========================================================================
% Local helper: make block map table
% =========================================================================
function blockMap_table = make_blockMap_table(blockMap, ses, session_name)

n = numel(blockMap);

Session = repmat({session_name}, n, 1);
SessionIndex = nan(n, 1);
ExcelRowInSession = nan(n, 1);
ExcelRowInExcel = nan(n, 1);
NrBlock_Excel = nan(n, 1);
NrBlock_File = nan(n, 1);
Run = nan(n, 1);
Tasktype_Excel = nan(n, 1);
Tasktype_Behavior = nan(n, 1);
Type_Final = nan(n, 1);
EncounteredFile = false(n, 1);
Processed = false(n, 1);
HasOutCap = false(n, 1);
SkipReason = cell(n, 1);
SourceFile = cell(n, 1);

for k = 1:n
    SessionIndex(k) = blockMap(k).session_index;
    ExcelRowInSession(k) = blockMap(k).excelRowInSession;
    ExcelRowInExcel(k) = blockMap(k).excelRowInExcel;
    NrBlock_Excel(k) = blockMap(k).NrBlock_excel;
    NrBlock_File(k) = blockMap(k).NrBlock_file;
    Run(k) = blockMap(k).run;
    Tasktype_Excel(k) = blockMap(k).tasktype_excel;
    Tasktype_Behavior(k) = blockMap(k).tasktype_beh;

    if isfield(ses, 'type') && numel(ses.type) >= k
        Type_Final(k) = ses.type(k);
    else
        Type_Final(k) = blockMap(k).type_final;
    end

    EncounteredFile(k) = blockMap(k).encounteredFile;
    Processed(k) = blockMap(k).processed;
    HasOutCap(k) = blockMap(k).has_out_cap;
    SkipReason{k} = blockMap(k).skip_reason;
    SourceFile{k} = blockMap(k).source_file;
end

blockMap_table = table( ...
    Session, ...
    SessionIndex, ...
    ExcelRowInSession, ...
    ExcelRowInExcel, ...
    NrBlock_Excel, ...
    NrBlock_File, ...
    Run, ...
    Tasktype_Excel, ...
    Tasktype_Behavior, ...
    Type_Final, ...
    EncounteredFile, ...
    Processed, ...
    HasOutCap, ...
    SkipReason, ...
    SourceFile);

end

%% =========================================================================
% Local helper: make respiration QC table
% =========================================================================
function respQC_table = make_respQC_table_from_out_cap(out_cap, ses)

nOutCap = numel(out_cap);

blockNum = (1:nOutCap)';

processed = false(nOutCap, 1);
skip_reason = cell(nOutCap, 1);
nrblock_combinedFiles = nan(nOutCap, 1);
tasktype_excel = nan(nOutCap, 1);
tasktype_beh = nan(nOutCap, 1);
type_final = nan(nOutCap, 1);

nBreaths = nan(nOutCap, 1);
nBadBreaths = nan(nOutCap, 1);
fracBadBreath = nan(nOutCap, 1);

medianRespRate_bpm = nan(nOutCap, 1);
meanRespRate_bpm = nan(nOutCap, 1);
medianBreathDur_s = nan(nOutCap, 1);
medianInspFrac = nan(nOutCap, 1);

nLowAmpSegments = nan(nOutCap, 1);
nFlatSegments = nan(nOutCap, 1);
durationLowAmp_s = nan(nOutCap, 1);
durationFlat_s = nan(nOutCap, 1);

for b = 1:nOutCap

    if isfield(out_cap(b), 'processed') && ~isempty(out_cap(b).processed)
        processed(b) = out_cap(b).processed;
    end

    if isfield(out_cap(b), 'skip_reason') && ~isempty(out_cap(b).skip_reason)
        skip_reason{b} = out_cap(b).skip_reason;
    else
        skip_reason{b} = '';
    end

    if isfield(out_cap(b), 'nrblock_combinedFiles') && ~isempty(out_cap(b).nrblock_combinedFiles)
        nrblock_combinedFiles(b) = out_cap(b).nrblock_combinedFiles;
    elseif isfield(ses, 'nrblock_combinedFiles') && numel(ses.nrblock_combinedFiles) >= b
        nrblock_combinedFiles(b) = ses.nrblock_combinedFiles(b);
    end

    if isfield(out_cap(b), 'tasktype_excel') && ~isempty(out_cap(b).tasktype_excel)
        tasktype_excel(b) = out_cap(b).tasktype_excel;
    elseif isfield(ses, 'tasktype') && numel(ses.tasktype) >= b
        tasktype_excel(b) = ses.tasktype(b);
    end

    if isfield(out_cap(b), 'tasktype_beh') && ~isempty(out_cap(b).tasktype_beh)
        tasktype_beh(b) = out_cap(b).tasktype_beh;
    elseif isfield(ses, 'tasktype_beh') && numel(ses.tasktype_beh) >= b
        tasktype_beh(b) = ses.tasktype_beh(b);
    end

    if isfield(out_cap(b), 'type') && ~isempty(out_cap(b).type)
        type_final(b) = out_cap(b).type;
    elseif isfield(ses, 'type') && numel(ses.type) >= b
        type_final(b) = ses.type(b);
    end

    if ~isfield(out_cap(b), 'resp_qc') || isempty(out_cap(b).resp_qc)
        continue
    end

    rq = out_cap(b).resp_qc;

    if isfield(rq, 'nBreaths')
        nBreaths(b) = rq.nBreaths;
    end
    if isfield(rq, 'nBadBreaths')
        nBadBreaths(b) = rq.nBadBreaths;
    end
    if isfield(rq, 'fracBadBreath')
        fracBadBreath(b) = rq.fracBadBreath;
    end
    if isfield(rq, 'medianRespRate_bpm')
        medianRespRate_bpm(b) = rq.medianRespRate_bpm;
    end
    if isfield(rq, 'meanRespRate_bpm')
        meanRespRate_bpm(b) = rq.meanRespRate_bpm;
    end
    if isfield(rq, 'medianBreathDur_s')
        medianBreathDur_s(b) = rq.medianBreathDur_s;
    end
    if isfield(rq, 'medianInspFrac')
        medianInspFrac(b) = rq.medianInspFrac;
    end
    if isfield(rq, 'nLowAmpSegments')
        nLowAmpSegments(b) = rq.nLowAmpSegments;
    end
    if isfield(rq, 'nFlatSegments')
        nFlatSegments(b) = rq.nFlatSegments;
    end
    if isfield(rq, 'durationLowAmp_s')
        durationLowAmp_s(b) = rq.durationLowAmp_s;
    end
    if isfield(rq, 'durationFlat_s')
        durationFlat_s(b) = rq.durationFlat_s;
    end
end

respQC_table = table( ...
    blockNum, ...
    processed, ...
    skip_reason, ...
    nrblock_combinedFiles, ...
    tasktype_excel, ...
    tasktype_beh, ...
    type_final, ...
    nBreaths, ...
    nBadBreaths, ...
    fracBadBreath, ...
    medianRespRate_bpm, ...
    meanRespRate_bpm, ...
    medianBreathDur_s, ...
    medianInspFrac, ...
    nLowAmpSegments, ...
    nFlatSegments, ...
    durationLowAmp_s, ...
    durationFlat_s);

end

%% =========================================================================
% Local helper: session-level plot
% =========================================================================
function make_session_respiration_plot(out_cap, ses, n_blocks, session_path, saveResults, session_name)

blks = 1:n_blocks;
taskMFC = [0.3922 0.4745 0.6353];
restMFC = [1 1 1];

if ~isempty(ses) && isfield(ses, 'type')
    rest_idx = find(ses.type == 0);
    task_idx = find(ses.type == 1);
else
    task_idx = [];
    rest_idx = blks;
    restMFC = [0.8 0.8 0.8];
end

% Keep only indices that exist in out_cap.
rest_idx = rest_idx(rest_idx <= numel(out_cap));
task_idx = task_idx(task_idx <= numel(out_cap));

ig_figure('Name', [session_path '->' saveResults], ...
    'Position', [200 200 900 900], 'PaperPositionMode', 'auto');

ha(1) = subplot(4,1,1);
plot_resp_field(rest_idx, out_cap, 'mean_B2B_valid_bpm', 'bo', restMFC); hold on;
plot_resp_field(task_idx, out_cap, 'mean_B2B_valid_bpm', 'bo', taskMFC);
plot_resp_field(rest_idx, out_cap, 'median_B2B_valid_bpm', 'bs', restMFC);
plot_resp_field(task_idx, out_cap, 'median_B2B_valid_bpm', 'bs', taskMFC);
ylabel('Mean (o) & med (s) of B2B (bpm)');

ha(2) = subplot(4,1,2);
plot_resp_field(rest_idx, out_cap, 'rmssd_B2B_valid_ms', 'bo', restMFC); hold on;
plot_resp_field(task_idx, out_cap, 'rmssd_B2B_valid_ms', 'bo', taskMFC);
ylabel('RMSSD of B2B interval (ms)');

ha(3) = subplot(4,1,3);
plot_resp_field(rest_idx, out_cap, 'std_B2B_valid_bpm', 'bo', restMFC); hold on;
plot_resp_field(task_idx, out_cap, 'std_B2B_valid_bpm', 'bo', taskMFC);
ylabel('SD of B2B interval (bpm)');

ha(4) = subplot(4,1,4);
plot_resp_field(rest_idx, out_cap, 'lfPower', 'ro', restMFC); hold on;
plot_resp_field(task_idx, out_cap, 'lfPower', 'ro', taskMFC);
plot_resp_field(rest_idx, out_cap, 'hfPower', 'go', restMFC);
plot_resp_field(task_idx, out_cap, 'hfPower', 'go', taskMFC);
legend({'lf rest','lf task','hf rest','hf task'}, 'location', 'Best');
xlabel('blocks');
ylabel('LF and HF power (ms^2)');

if ~isempty(ses) && isfield(ses, 'experiment') && ...
        ~(strcmp(ses.experiment(1), 'ephys')) && ...
        isfield(ses, 'first_inj_block') && ~isnan(ses.first_inj_block)
    for ax = 1:length(ha)
        axes(ha(ax)); %#ok<LAXES>
        ig_add_vertical_line(ses.first_inj_block - 0.5);
    end
end

print(gcf, [saveResults filesep session_name '_B2B_TC.pdf'], '-dpdf', '-r0');
close(gcf);

end

%% =========================================================================
% Local helper: safe plotting of one numeric out_cap field
% =========================================================================
function plot_resp_field(idx, out_cap, fieldName, markerSpec, markerFaceColor)

if isempty(idx)
    return
end

y = nan(size(idx));

for k = 1:numel(idx)
    b = idx(k);

    if b <= numel(out_cap) && isfield(out_cap(b), fieldName) && ...
            ~isempty(out_cap(b).(fieldName))
        y(k) = out_cap(b).(fieldName);
    end
end

plot(idx, y, markerSpec, ...
    'MarkerEdgeColor', [0.4235 0.2510 0.3922], ...
    'MarkerFaceColor', markerFaceColor);

end

%% =========================================================================
% Local helper: get numeric session value safely
% =========================================================================
function val = get_numeric_ses_value(ses, fieldName, k)

val = NaN;

if ~isfield(ses, fieldName)
    return
end

x = ses.(fieldName);

if isnumeric(x) || islogical(x)
    if numel(x) >= k
        val = double(x(k));
    end
elseif iscell(x)
    if numel(x) >= k
        tmp = x{k};
        if isnumeric(tmp) || islogical(tmp)
            val = double(tmp);
        elseif ischar(tmp)
            val = str2double(tmp);
        end
    end
end

end
%% =========================================================================
% Local helper: assign struct element with compatible fields
% =========================================================================
function S = assign_struct_element_compatible(S, k, value, nTotal)
% ASSIGN_STRUCT_ELEMENT_COMPATIBLE
%
% MATLAB requires all elements of a struct array to have identical fields.
% This helper makes sure that S and value have the same fields before:
%
%   S(k) = value
%
% This is needed because the first processed block defines many fields,
% while skipped blocks/placeholders may initially have no fields.

if isempty(S)
    emptyValue = make_empty_like(value);
    S = repmat(emptyValue, 1, nTotal);
end

% Add fields from value to S if S does not have them.
valueFields = fieldnames(value);
S = add_missing_fields(S, valueFields);

% Add fields from S to value if value does not have them.
SFields = fieldnames(S);
value = add_missing_fields(value, SFields);

% If S is still shorter than needed, extend it.
if numel(S) < nTotal
    emptyS = make_empty_like(S);
    for ii = (numel(S) + 1):nTotal
        S(ii) = emptyS;
    end
end

S(k) = value;

end