% this is not a function, it is just a convenience script to run functions over several sessions

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


%%
 bsa_ecg_summarize_many_sessions('C:\Users\kkaduk\Dropbox\promotion\Projects\BodySignal_Pulvinar\Data\')

%%

