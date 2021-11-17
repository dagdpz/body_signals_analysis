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
%
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
        
          % delete runs which 
        ses.injection(ses.nrblock_combinedFiles == 0) = num2cell(nan(1,sum(ses.nrblock_combinedFiles == 0)));
        ses.first_inj_block =  min(ses.nrblock_combinedFiles(strcmp(ses.injection , 'Post'))) ;
    else
        disp([pathExcel ,'   Excel-File does not include this date  ' , num2str(session_name)])
    end
end

%%

  if strcmp(par.dataOrigin, 'TDT'),
      load([session_path filesep 'bodysignals_wo_behavior.mat']);
      Fs        = dat.ECG_SR;
      ECG       = dat.ECG;
      CAP       = dat.CAP;
      POX       = dat.POX;

      n_blocks  = length(dat.ECG);
     
       
  else
      combined_matfiles=dir([session_path filesep '*.mat']);
      n_blocks = length(combined_matfiles);
     
               
  end
%% Is there a difference between excel-sheet information & saved data-files?
disp(['Found ' num2str(n_blocks) ' blocks in ' par.dataOrigin]);
if ~isempty(pathExcel) && sum(table.date == str2num(session_name)) > 0
    BlockExcel = sum(~ses.nrblock_combinedFiles == 0 ); 
    disp(['Found ' num2str(BlockExcel ) ' blocks in the excel sheet']);
    if  ~(BlockExcel  ==  n_blocks) %~(sum(~or(ses.nrblock_combinedFiles == 0 ,ses.tasktype == -2))  ==  n_blocks)
        error('Error. Number of blocks to be analyzed from excel-sheet does not match the number of blocks from the TDT-datasets.')
    end
end
    
%%
for i_block = 1: n_blocks, % for each run/block
    NrBlock = [];   
   % get the information about the task or rest
    if ~strcmp(par.dataOrigin, 'TDT'),
        load([session_path filesep combined_matfiles(i_block).name])
        if task.type == Set.task.Type && numel(trial) > Set.task.mintrials % exclude short runs and calibration
            ses.type(i_block)   =    1; % task
        elseif task.type == Set.rest.Type && all(trial(1).task.reward.time_neutral == Set.rest.reward) ;
            ses.type(i_block)   =    0; % rest  
        else
            ses.type(i_block)   =    -2;
        end
        
     NrBlock = combined_matfiles(i_block).name(end-5: end-4);
     NrBlock = str2num(NrBlock);
        % check if the information contained in the behavior-file is the same as in the Excel-sheet input
        if  ~isempty(pathExcel) && sum(table.date == str2num(session_name)) > 0 %&&  ~(ses.type(i_block) == -2)
            
            if ses.type(i_block) == ses.tasktype(ses.nrblock_combinedFiles == NrBlock)
                
            elseif  ses.tasktype(ses.nrblock_combinedFiles == NrBlock) == -2
                disp(['Block ' num2str(NrBlock) ' is excluded because of a -2 in the Excel-sheet'])
                ses.type(i_block) = -2;   
            elseif ses.type(i_block) == -2  && task.type ~= Set.task.Type &&  ses.tasktype(ses.nrblock_combinedFiles == i_block) ~= -2 && numel(trial) > Set.task.mintrials
                disp(['Condition does not match!! Excel-sheet colum tasktype ' num2str(ses.tasktype(ses.nrblock_combinedFiles == NrBlock)  ) ' is not identical with the information from behavior file '  num2str(ses.type(i_block) ) ' in Block ' num2str(i_block)])
                ses.type(i_block) =  ses.tasktype(ses.nrblock_combinedFiles == i_block);
                disp('overwrote the information from behavior file with excel-sheet')
            else
                disp(['Condition does not match!! Excel-sheet colum tasktype' num2str(ses.tasktype(ses.nrblock_combinedFiles == NrBlock)  ) 'is not identical with the information from behavior file'  num2str(ses.type(i_block) ) 'in Block' num2str(i_block)])
            end
        end
        
    else
        if ~isempty(pathExcel) && sum(table.date == str2num(session_name)) > 0
            ses.type  =  table.tasktype(table.date == str2num(session_name))';
            ses.type  =  ses.type(~ses.nrblock_combinedFiles == 0);
        end
    end
    
   
    
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
        OUT = bsa_concatenate_trials_body_signals([session_path filesep combined_matfiles(i_block).name]);
        ecgSignal   = OUT.ECG1;
        capSignal   = OUT.CAP1;
        poxSignal   = OUT.POX1;
        
        Fs          = OUT.Fs;
    end
    
    % respiration
    [ out_cap(i_block), Tab_outlier_cap(i_block) ]= bsa_respiration_analyze_one_run(capSignal,settings_path,Fs,1,i_block,NrBlock);
    print(out_cap(i_block).hf,sprintf('%sblock%02d.png',[par.saveResults filesep 'cap_'],i_block),'-dpng','-r0');
    if ~par.keepRunFigs
        close(out_cap(i_block).hf);
    end
%     %ECG
%     [ out(i_block), Tab_outlier_ecg(i_block) ]= bsa_ecg_analyze_one_run(ecgSignal,settings_path,Fs,1,i_block,NrBlock);
%     print(out(i_block).hf,sprintf('%sblock%02d.png',[par.saveResults filesep 'ecg_'],i_block),'-dpng','-r0');
%     if ~par.keepRunFigs
%         close(out(i_block).hf);
%     end
    
    

end

%save([par.saveResults filesep session_name '.mat'],'out','out_cap','Tab_outlier_ecg','Tab_outlier_cap','par','ses','session_name','session_path');
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


if ~isempty(ses),
   
    for ax = 1:length(ha),
        axes(ha(ax));
        ig_add_vertical_line(ses.first_inj_block -0.5);
        
    end
    
end


print(gcf,[par.saveResults filesep session_name '_B2B_TC.pdf'],'-dpdf','-r0');
warning on;

