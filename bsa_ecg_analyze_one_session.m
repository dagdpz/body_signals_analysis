function out = bsa_ecg_analyze_one_session(session_path,varargin)

% p = inputParser;
% 
% def_KeepRunFigs = false;
% val_KeepRunFigs = {false,true};

% defpar = { ...
%     'keep_run_figs',false;...
%     };
% 
% par = struct(varargin{:});
% par = checkstruct

% session_path = 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior'; % ina session 1
% session_path = 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129\bodysignals_without_behavior'; % ina session 2
% session_path = 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190201\bodysignals_without_behavior'; % ina session 3

% session_path = 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190121\bodysignals_without_behavior'; % baseline session 1
% session_path = 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190131\bodysignals_without_behavior'; % baseline session 2


ori_dir = pwd;
warning off;
cd(session_path);

session_name_idx = strfind(session_path,'201');
session_name = session_path(session_name_idx(1):session_name_idx(1)+7);

load([session_path filesep 'bodysignals_wo_behavior.mat']);

Fs = dat.ECG_SR;
ECG = dat.ECG;
n_blocks = length(dat.ECG);
for r = 1:n_blocks, % for each run/block
    disp(sprintf('Processing block %d',r));
    ecgSignal       = double(ECG{r});
    out(r) = bsa_ecg_analyze_one_run(ecgSignal,Fs,1,sprintf('run%02d',r));
    print(out(r).hf,sprintf('run%02d.png',r),'-dpng','-r0');
    close(out(r).hf);
    
end

save out

ig_figure('Name',session_path,'Position',[200 200 900 500],'PaperPositionMode','auto','PaperOrientation','landscape');
subplot(2,1,1);
plot(1:n_blocks,[out.mean_R2R_valid_bpm],'bo','MarkerEdgeColor',[0.4235    0.2510    0.3922]); hold on;
plot(1:n_blocks,[out.median_R2R_valid_bpm],'b.','MarkerFaceColor',[0.4235    0.2510    0.3922],'MarkerSize',6);
ylabel('Mean (o) & median (.) of R2R int.');

subplot(2,1,2);
plot(1:n_blocks,[out.std_R2R_valid_bpm],'bo');
xlabel('blocks');
ylabel('SD of R2R interval');

print(gcf,[session_name '_R2R_TC.pdf'],'-dpdf','-r0');


cd(ori_dir);
warning on;

