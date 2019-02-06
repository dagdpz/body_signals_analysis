function out = bsa_ecg_analyze_one_session(session_path,varargin)
% E.g.
% out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20190131','Y:\Projects\PhysiologicalRecording\Data\Magnus\20190131');
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

p = inputParser; % in order of arguments
addRequired(p,'session_path',@ischar);
addOptional(p,'saveResults',def_saveResults,@ischar);
addOptional(p,'keepRunFigs',def_keepRunFigs,@islogical);
addParameter(p,'dataOrigin',def_dataOrigin,chk_dataOrigin);

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

for r = 1:n_blocks, % for each run/block
    disp(sprintf('Processing block %d',r));
    
    if strcmp(par.dataOrigin, 'TDT'),
        ecgSignal   = double(ECG{r});
    else
        ecg = bsa_concatenate_trials_body_signals([session_path filesep combined_matfiles(r).name], 1); % get ecg only
        ecgSignal   = ecg.ECG1;
        Fs          = ecg.Fs;
    end
    out(r) = bsa_ecg_analyze_one_run(ecgSignal,Fs,1,sprintf('run%02d',r));
    print(out(r).hf,sprintf('%srun%02d.png',[par.saveResults filesep],r),'-dpng','-r0');
    if ~par.keepRunFigs
        close(out(r).hf);
    end
    
end

save([par.saveResults filesep session_name '_ecg.mat'],'out','par');

ig_figure('Name',session_path,'Position',[200 200 900 500],'PaperPositionMode','auto','PaperOrientation','landscape');
subplot(2,1,1);
plot(1:n_blocks,[out.mean_R2R_valid_bpm],'bo','MarkerEdgeColor',[0.4235    0.2510    0.3922]); hold on;
plot(1:n_blocks,[out.median_R2R_valid_bpm],'b.','MarkerFaceColor',[0.4235    0.2510    0.3922],'MarkerSize',6);
ylabel('Mean (o) & median (.) of R2R int.');

subplot(2,1,2);
plot(1:n_blocks,[out.std_R2R_valid_bpm],'bo');
xlabel('blocks');
ylabel('SD of R2R interval');

print(gcf,[par.saveResults filesep session_name '_R2R_TC.pdf'],'-dpdf','-r0');

warning on;

