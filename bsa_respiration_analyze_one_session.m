function out = bsa_respiration_analyze_one_session(session_path,varargin)
%bsa_respiration_analyze_one_session  - analyzing ECG in one session (in multiple runs/blocks)
%
% USAGE:
% out = bsa_respiration_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20190131','Y:\Projects\PhysiologicalRecording\Data\Magnus\20190131');
% out = bsa_respiration_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190221','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190221');
% out = bsa_respiration_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190304','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190304');

% out = bsa_respiration_analyze_one_session(session_path,'',false,'dataOrigin','TDT','sessionInfo',ses);
%
% INPUTS:
%		session_path		- Path to session data
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

% define default arguments and their potential values
def_saveResults = session_path; % 1st optional argument (directory to save results, if empty then save to session_path)
def_keepRunFigs = false;        % 2nd optional argument
def_dataOrigin = 'combined';    % 3rd optional argument pair
val_dataOrigin = {'combined','TDT'};
chk_dataOrigin = @(x) any(validatestring(x,val_dataOrigin));
def_sessionInfo = [];           % 4 optional argument pair (can be defined in bsa_ecg_analyze_many_sessions)

p = inputParser; % in order of arguments
addRequired(p, 'session_path',@ischar);
addOptional(p, 'saveResults',def_saveResults,@ischar);
addOptional(p, 'keepRunFigs',def_keepRunFigs,@islogical);
addParameter(p,'dataOrigin',def_dataOrigin,chk_dataOrigin);
addParameter(p,'sessionInfo',def_sessionInfo,@isstruct);

parse(p,session_path,varargin{:});
par = p.Results;

if isempty(par.saveResults),
    par.saveResults = session_path;
end

session_name_idx = strfind(session_path,'201');
session_name = session_path(session_name_idx(1):session_name_idx(1)+7);


if ~exist(par.saveResults,'dir'),
   mkdir(par.saveResults); 
end

ses = par.sessionInfo;

%% which run is task and which is rest? information stored in the excel-sheet or behavior file

pathExcel = 'Y:\Logs\Inactivation\Cornelius\Cornelius_Inactivation_log_since201901.xlsx'; 
table = readtable(pathExcel);
  ses.injection       =   table.injection(table.date == str2num(session_name))'
  ses.run             =   table.run(table.date == str2num(session_name))'
  ses.block           =   table.block(table.date == str2num(session_name))'
  ses.tasktype_str    =   table.task(table.date == str2num(session_name))'
  ses.brain_area      =   table.target(table.date == str2num(session_name))'
  ses.dosage          =   table.dosage(table.date == str2num(session_name))'
  
  ses.injection(ses.block == 0) = num2cell(nan(1,sum(ses.block == 0))); 
  ses.first_inj_block =  min(ses.block(strcmp(ses.injection , 'Post'))) 
  
  if strcmp(par.dataOrigin, 'TDT'),
      load([session_path filesep 'bodysignals_wo_behavior.mat']);
      Fs        = dat.ECG_SR;
      ECG       = dat.ECG;
      CAP       = dat.CAP;
      POX       = dat.POX;

      n_blocks  = length(dat.ECG);
      ses.type  =   table.tasktype(table.date == str2num(session_name))';
      ses.type  =  ses.type(~ses.block == 0); 
       
  else
      combined_matfiles=dir([session_path filesep '*.mat']);
      n_blocks = length(combined_matfiles);
      
      for indBlock = 1: n_blocks
          load([session_path filesep combined_matfiles(indBlock).name])
          if task.type == 2 && all(trial(1).task.reward.time_neutral > [0.15 0.15])%&& numel(trial) > 10
              ses.type(indBlock)   =    1;
          elseif task.type == 1 && all(trial(1).task.reward.time_neutral == [0 0]) %&& numel(trial) > 10;
              ses.type(indBlock)   =    0;
          else
              ses.type(indBlock)   =    -2;
          end
          
      end
      
  end

disp(['Found ' num2str(n_blocks) ' blocks in the TDT-Dataset']);
disp(['Found ' num2str(sum(~ses.block == 0)) ' blocks in the excel sheet']);
if  ~sum(~ses.block == 0) ==  n_blocks
      error('Error. \Number of Block to be anlyzed from excel-sheet does not match the number of Blocks from the TDT-datasets.')
end
    
%%
for r = 1:n_blocks, % for each run/block
    
    % first check if to skip the block
    if ~isempty(ses),
        if ses.type(r) == -2 || isnan(ses.type(r)) ,
           disp(sprintf('Skipping block %d',r));
           continue
        end
    end   
     
     disp(sprintf('Processing block %d',r));
     
     if strcmp(par.dataOrigin, 'TDT'),
         ecgSignal   = double(ECG{r});
         capSignal   = double(CAP{r});
         poxSignal   = double(POX{r});

     else
         OUT = bsa_concatenate_trials_body_signals([session_path filesep combined_matfiles(r).name]); % get ecg only
         ecgSignal   = OUT.ECG1;
         capSignal   = OUT.CAP1;
         poxSignal   = OUT.POX1;

         Fs          = OUT.Fs;
     end
     
     %ECG
     out(r) = bsa_ecg_analyze_one_run(ecgSignal,Fs,1,sprintf('block%02d',r));
     print(out(r).hf,sprintf('%sblock%02d.png',[par.saveResults filesep],r),'-dpng','-r0');
     if ~par.keepRunFigs
         close(out(r).hf);
     end
    % respiration
        out(r) = bsa_respiration_analyze_one_run(capSignal,Fs,1,sprintf('block%02d',r));

end

save([par.saveResults filesep session_name '_ecg.mat'],'out','par','ses','session_name','session_path');


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


ig_figure('Name',[session_path '->' par.saveResults],'Position',[200 200 900 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
ha(1) = subplot(4,1,1);
plot(blks(rest_idx),[out(rest_idx).mean_R2R_valid_bpm],'bo','MarkerEdgeColor',[0.4235    0.2510    0.3922],'MarkerFaceColor',restMFC); hold on;
plot(blks(task_idx),[out(task_idx).mean_R2R_valid_bpm],'bo','MarkerEdgeColor',[0.4235    0.2510    0.3922],'MarkerFaceColor',taskMFC);
plot(blks(rest_idx),[out(rest_idx).median_R2R_valid_bpm],'bs','MarkerEdgeColor',[0.4235    0.2510    0.3922],'MarkerFaceColor',restMFC);
plot(blks(task_idx),[out(task_idx).median_R2R_valid_bpm],'bs','MarkerEdgeColor',[0.4235    0.2510    0.3922],'MarkerFaceColor',taskMFC);
ylabel('Mean (o) & med (s) of R2R (bpm)');

ha(2) = subplot(4,1,2);
plot(blks(rest_idx),[out(rest_idx).rmssd_R2R_valid_ms],'bo','MarkerFaceColor',restMFC); hold on;
plot(blks(task_idx),[out(task_idx).rmssd_R2R_valid_ms],'bo','MarkerFaceColor',taskMFC);
ylabel('RMSSD of R2R interval (ms)');

ha(3) = subplot(4,1,3);
plot(blks(rest_idx),[out(rest_idx).std_R2R_valid_bpm],'bo','MarkerFaceColor',restMFC);  hold on;
plot(blks(task_idx),[out(task_idx).std_R2R_valid_bpm],'bo','MarkerFaceColor',taskMFC);
ylabel('SD of R2R interval (bpm)');

ha(4) = subplot(4,1,4);
plot(blks(rest_idx),[out(rest_idx).lfPower],'ro','MarkerFaceColor',restMFC); hold on;
plot(blks(task_idx),[out(task_idx).lfPower],'ro','MarkerFaceColor',taskMFC); 
plot(blks(rest_idx),[out(rest_idx).hfPower],'go','MarkerFaceColor',restMFC);
plot(blks(task_idx),[out(task_idx).hfPower],'go','MarkerFaceColor',taskMFC);
legend({'lf rest','lf task','hf rest','hf task'},'location','Best');
xlabel('blocks');
ylabel('LF and HF power (ms^2)');


if ~isempty(ses),
   
    for ax = 1:length(ha),
        axes(ha(ax));
        ig_add_vertical_line(ses.first_inj_block -0.5);
        
    end
    
end


print(gcf,[par.saveResults filesep session_name '_R2R_TC.pdf'],'-dpdf','-r0');

warning on;

