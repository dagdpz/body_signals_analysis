function out = bsa_ecg_analyze_one_session(session_path,varargin)
% E.g.
% out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20190131','Y:\Projects\PhysiologicalRecording\Data\Magnus\20190131');
% out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190207','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190207');
% out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Magnus\20190131\bodysignals_without_behavior','',false,'dataOrigin','TDT');

% session_path = 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior'; % ina session 1
% session_path = 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129\bodysignals_without_behavior'; % ina session 2
% session_path = 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190201\bodysignals_without_behavior'; % ina session 3

% session_path = 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190121\bodysignals_without_behavior'; % baseline session 1
% session_path = 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190131\bodysignals_without_behavior'; % baseline session 2

warning off;

% define default arguments and their potential values
def_saveResults = session_path; % first optional argument (directory to save results, if empty then save to session_path)
def_keepRunFigs = false;        % second optional argument
def_dataOrigin = 'combined';    % third optional argument pair
val_dataOrigin = {'combined','TDT'};
chk_dataOrigin = @(x) any(validatestring(x,val_dataOrigin));
def_sessionInfo = [];

p = inputParser; % in order of arguments
addRequired(p,'session_path',@ischar);
addOptional(p,'saveResults',def_saveResults,@ischar);
addOptional(p,'keepRunFigs',def_keepRunFigs,@islogical);
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

if strcmp(par.dataOrigin, 'TDT'),
    load([session_path filesep 'bodysignals_wo_behavior.mat']);
    Fs = dat.ECG_SR;
    ECG = dat.ECG;
    n_blocks = length(dat.ECG);
else
    combined_matfiles=dir([session_path filesep '*.mat']);
    n_blocks = length(combined_matfiles);
end

disp(['Found ' num2str(n_blocks) ' blocks']);


ses = par.sessionInfo;

% % Magnus 20190131
% ses.first_inj_block = 5;
% ses.type = ... % 1 task, 0 rest
% [
% 1
% 0
% 1
% 0
% ];

% Magnus 20190206
% ses.first_inj_block = 6;
% ses.type = ... % 1 task, 0 rest
% [
% 1
% 0
% 1
% 0
% 1
% 0
% 0
% 1
% 0
% 1
% 0
% 1
% 1
% 1
% 0
% 0
% 0
% 1
% ]; 

% % Magnus 20190208
% ses.first_inj_block = 9;
% ses.type = ... % 1 task, 0 rest
% [
% 1
% 0
% 1
% 0
% 1
% 0
% 1
% 0
% ];


for r = 1:n_blocks, % for each run/block
    
    % first check if to skip the block
    if ~isempty(ses),
        if ses.type(r) == -2,
           disp(sprintf('Skipping block %d',r));
           continue
        end
    end   
     
     disp(sprintf('Processing block %d',r));
     
     if strcmp(par.dataOrigin, 'TDT'),
         ecgSignal   = double(ECG{r});
     else
         ecg = bsa_concatenate_trials_body_signals([session_path filesep combined_matfiles(r).name], 1); % get ecg only
         ecgSignal   = ecg.ECG1;
         Fs          = ecg.Fs;
     end
     out(r) = bsa_ecg_analyze_one_run(ecgSignal,Fs,1,sprintf('block%02d',r));
     print(out(r).hf,sprintf('%sblock%02d.png',[par.saveResults filesep],r),'-dpng','-r0');
     if ~par.keepRunFigs
         close(out(r).hf);
     end
   
   
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

