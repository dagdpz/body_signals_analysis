% this is not a function, it is just a convenience script to run functions over several sessions
%% TODO
% 1) vector with sessions & monkey to have only one line
%%
% Load and save TDT data without behavior
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190201', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior');
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190121', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129\bodysignals_without_behavior');
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190201', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190201\bodysignals_without_behavior');
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190207', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190207\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190216\bodysignals_without_behavior','',false,'dataOrigin','TDT');


bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190121', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190121\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190121\bodysignals_without_behavior','',false,'dataOrigin','TDT');

bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190124', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior','',false,'dataOrigin','TDT');

bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190129', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129\bodysignals_without_behavior','',false,'dataOrigin','TDT');

bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190131', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190131\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190131\bodysignals_without_behavior','',false,'dataOrigin','TDT');

 out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190201','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190201');
 out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190207','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190207');
 out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190227','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190227');
 out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190228','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190228');
 bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190228', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190228\bodysignals_without_behavior');
 out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190228','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190228');
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190304', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190304\bodysignals_without_behavior');
 out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190304','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190304');
 out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190313','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190313');
 out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190314','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190314');
  out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190403','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190403');
 out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190404','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190404');
 out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190408','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190408');
  out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190424','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190424');
  out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190429','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190429');
  out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190430','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190430');
   out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190508','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190508');

  out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190509','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190509');

  %% CURIUS
pathExcel = 'Y:\Logs\Inactivation\Curius\Curius_Inactivation_log_since201905.xlsx'; 
    out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190625',pathExcel,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190625');
    out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190703',pathExcel,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190703');

  
  
%% dorsal pulvinar
sessions = {
%'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190111';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190121\bodysignals_without_behavior';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129\bodysignals_without_behavior';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190131\bodysignals_without_behavior';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190201';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190207';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190213';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190214';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190216\bodysignals_without_behavior';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190227';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190228';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190304';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190313';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190314';
};
targetBrainArea = 'dPul'; 
inactivation_sessions = {'20190124' '20190129' '20190201' '20190207' '20190214' '20190228','20190314'};
%% ventral pulvinar
sessions = {
%'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190111';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190403';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190404';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190408';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190424';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190429';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190430';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190508';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190509';

};
inactivation_sessions = {'20190404' '20190408' '20190430' '20190509' };
targetBrainArea = 'vPul'; 


addtoDropbox = 'C:\Users\kkaduk\Dropbox\DAG\Kristin'; 
 bsa_ecg_summarize_many_sessions('C:\Users\kkaduk\Dropbox\promotion\Projects\BodySignal_Pulvinar\Data\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox)

%%
targetBrainArea = 'dPul'; 
bsa_graphs(targetBrainArea)

