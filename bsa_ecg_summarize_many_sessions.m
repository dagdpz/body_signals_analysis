function bsa_ecg_summarize_many_sessions
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

sessions = {
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190111';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190121\bodysignals_without_behavior';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129\bodysignals_without_behavior';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190131\bodysignals_without_behavior';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190201';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190207';
};

inactivation_sessions = {'20190124' '20190129' '20190201' '20190207'};

ind_con = 0;
ind_ina = 0;

for s = 1:length(sessions),
	session_path = sessions{s};
	session_name_idx = strfind(session_path,'201');
	session_name = session_path(session_name_idx(1):session_name_idx(1)+7);

	load([session_path filesep session_name '_ecg.mat']);

    % remove -2: skipped sessions
    ses.type = ses.type(ses.type ~= -2);
    
	rest_idx = find(ses.type == 0 & ~isnan([out.mean_R2R_valid_bpm]'));
    task_idx = find(ses.type == 1 & ~isnan([out.mean_R2R_valid_bpm]'));
	pre_rest_idx = 	rest_idx(rest_idx < ses.first_inj_block);
	pre_task_idx = 	task_idx(task_idx < ses.first_inj_block);
	pst_rest_idx = 	rest_idx(rest_idx >= ses.first_inj_block+5);
	pst_task_idx = 	task_idx(task_idx >= ses.first_inj_block+5);


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
		
	else
		ind_con = ind_con + 1;
		S_con(ind_con) = S_;
	end


	% add blocks for analysis across all blocks from all sessions


	

	

end


figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'

ha(1) = subplot(3,3,1);
plot_one_var_pre_post_rest_task([S_con.mean_R2R_bpm],[S_ina.mean_R2R_bpm]);
title('Mean R2R (bmp)');

ha(2) = subplot(3,3,2);
plot_one_var_pre_post_rest_task([S_con.median_R2R_bpm],[S_ina.median_R2R_bpm]);
title('Median R2R (bmp)');

ha(3) = subplot(3,3,3);
plot_one_var_pre_post_rest_task([S_con.rmssd_R2R_ms],[S_ina.rmssd_R2R_ms]);
title('RMSSD R2R (ms)');

ha(4) = subplot(3,3,4);
plot_one_var_pre_post_rest_task([S_con.std_R2R_bpm],[S_ina.std_R2R_bpm]);
title('SD R2R (bmp)');

ha(5) = subplot(3,3,5);
plot_one_var_pre_post_rest_task([S_con.lfPower],[S_ina.lfPower]);
title('Low freq power');

ha(6) = subplot(3,3,6);
plot_one_var_pre_post_rest_task([S_con.hfPower],[S_ina.hfPower]);
title('High freq power');

ha(7) = subplot(3,3,7);
title('Power spectrum control');

con_b_col = [0.4667    0.6745    0.1882];
con_d_col = [0.0706    0.2118    0.1412];
ina_b_col = [0.5137    0.3804    0.4824];
ina_d_col = [0.3490    0.2000    0.3294];

freq_ = [S_con.freq];
freq = mean([freq_.pre_rest],2);
f = find(freq>0.05 & freq <= 0.6);
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

ylim = get(gca,'Ylim');
line([0.15 0.15],[ylim(1) ylim(2)]);
line([0.5 0.5],[ylim(1) ylim(2)]);


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

ylim = get(gca,'Ylim');
line([0.15 0.15],[ylim(1) ylim(2)]);
line([0.5 0.5],[ylim(1) ylim(2)]);

set(ha([7 8]),'Xlim',[0 0.6]);


function plot_one_var_pre_post_rest_task(S_con,S_ina)

con_b_col = [0.4667    0.6745    0.1882];
con_d_col = [0.0706    0.2118    0.1412];
ina_b_col = [0.5137    0.3804    0.4824];
ina_d_col = [0.3490    0.2000    0.3294];


ig_bar_mean_se(1,[S_con.pre_rest],'sterr','FaceColor',[1 1 1],'EdgeColor',con_b_col);
ig_bar_mean_se(2,[S_con.pst_rest],'sterr','FaceColor',[1 1 1],'EdgeColor',con_d_col);
ig_bar_mean_se(3,[S_con.pre_task],'sterr','FaceColor',con_b_col,'EdgeColor',con_b_col);
ig_bar_mean_se(4,[S_con.pst_task],'sterr','FaceColor',con_d_col,'EdgeColor',con_d_col);

ig_bar_mean_se(6,[S_ina.pre_rest],'sterr','FaceColor',[1 1 1],'EdgeColor',ina_b_col);
ig_bar_mean_se(7,[S_ina.pst_rest],'sterr','FaceColor',[1 1 1],'EdgeColor',ina_d_col);
ig_bar_mean_se(8,[S_ina.pre_task],'sterr','FaceColor',ina_b_col,'EdgeColor',ina_b_col);
ig_bar_mean_se(9,[S_ina.pst_task],'sterr','FaceColor',ina_d_col,'EdgeColor',ina_d_col);

set(gca,'xlim',[0 10],'Xtick',[1:4 6:9],'XTickLabel',{'pre' 'post' 'pre' 'post' 'pre' 'post' 'pre' 'post'});

