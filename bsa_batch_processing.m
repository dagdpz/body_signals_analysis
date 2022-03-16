% this is not a function, it is just a convenience script to run functions over several sessions
%% TODO
% 1) vector with sessions & monkey to have only one line
%%
pathExcel = 'Y:\Logs\Inactivation\Cornelius\Cornelius_Inactivation_log_since201901.xlsx';
settings_filename = 'bsa_settings_Cornelius2019.m';
% Load and save TDT data without behavior
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190201', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior');
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190201', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190201\bodysignals_without_behavior');
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190207', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190207\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190216\bodysignals_without_behavior',pathExcel,settings_filename,'','keepRunFigs',true,'dataOrigin','TDT');


bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190121', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190121\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190121\bodysignals_without_behavior',pathExcel,settings_filename,'',false,'dataOrigin','TDT');

bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190124', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior',pathExcel,settings_filename,'',false,'dataOrigin','TDT');

out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190129',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129');

bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190131', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190131\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190131\bodysignals_without_behavior',pathExcel,settings_filename,'',false,'dataOrigin','TDT');

out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190201',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190201');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190207',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190207');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190214',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190214');
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190216', 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190216\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190216\bodysignals_without_behavior',pathExcel,settings_filename,'',false,'dataOrigin','TDT');

out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190213',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190213');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190227',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190227');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190228',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190228');
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190228', 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190228\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190228',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190228');
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190304', 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190304\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190304',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190304');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190313',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190313');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190314',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190314');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190403',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190403');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190404',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190404');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190408',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190408');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190424',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190424');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190429',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190429');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190430',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190430');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190508',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190508');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190509',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190509');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190813',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190813');

out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190828',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190828');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190904',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190904');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190910',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190910');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190912',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190912');

out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190913',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190913');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20191007',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191007');

out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20191011',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191011');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20191010',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191010');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20191014',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191014');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20191015',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191015');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20191017',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191017');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20191020',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191020');

out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20191021',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191021');

bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190808', 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190808\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190808\bodysignals_without_behavior',pathExcel,settings_filename,'',false,'dataOrigin','TDT');


%% MAGNUS
pathExcel = 'Y:\Logs\Inactivation\Magnus\Magnus_bodySignals_inactivation_log.xlsx';
settings_filename = 'bsa_settings_Magnus2019.m';
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20190131',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20190131');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20190213',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20190213');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20190404',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20190404');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191108',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191108');
%changed task type!!!
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191110',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191110');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191111',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191111');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191113',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191113');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191119',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191119');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191120',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191120');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191121',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191121');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191127',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191127');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191128',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191128');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191204',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191204');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191205',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191205');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191210',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191210');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191211',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191211');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191212',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Magnus\20191212');
out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191213',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191213');


%% BACCHUS
pathExcel = 'Y:\Logs\Phys\Bacchus\Bacchus_bodySignals_ephys_log.xlsx';
settings_filename = 'bsa_settings_Bacchus2019.m';
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20191112',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Bacchus\20191112');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20191113',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Bacchus\20191113');

%% Ephys - ECG-channel 1 
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210720',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210720');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210720',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\CAP\20210720');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211001',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211001');

out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210723',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210723');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210729',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210729');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210730',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210730');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210803',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210803');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210805',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210805');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210806',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210806');



out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210826',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210826');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210827',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210827');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210903',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210903');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210905',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210905');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210906',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210906');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210930',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210930');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211007',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211007');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211012',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211012');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211013',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211013');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211014',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211014');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211019',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211019');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211027',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211027');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211028',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211028');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211014',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211014');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211102',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211102');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211103',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211103');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211111',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211111');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211116',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211116');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211117',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211117');

out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211207',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211207');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211208',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211208');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211214',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211214');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211222',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211222');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20220105',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20220105');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20220106',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20220106');

%out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20220125',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20220125');
%out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20220126',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20220126');

out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20220221',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20220221');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20220222',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20220222');

%% Probl
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210829',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210829');


out_cap = bsa_respiration_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211028',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\CAP\20211028');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210826',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\CAP\20210826');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20210720',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\CAP\20210720');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20211001',pathExcel,settings_filename,'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\CAP\20211001');


%% CURIUS
pathExcel = 'Y:\Logs\Inactivation\Curius\Curius_Inactivation_log_since201905.xlsx';
settings_filename = 'bsa_settings_Curius2019.m'; % full path will be complemented in bsa_ecg_analyze_one_session

%% electrophysiology-study
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20210318',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20210318');


%Inactivation study
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190625',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190625');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190703',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190703');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190701',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190701');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190705',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190705');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190717',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190717');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190719',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190719');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190723',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190723');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190726',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190726');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190729',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190729');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190801',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190801');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190802',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190802');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190804',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190804');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190806',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190806');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190807',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190807');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190808',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190808');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190809',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190809');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190811',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190811');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190813',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190813');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190814',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190814');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190815',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190815');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190816',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190816');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190820',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190820');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190821',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190821');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190822',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190822');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190823',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190823');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190826',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190826');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190828',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190828');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190903',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190903');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190905',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190905');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190910',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190910');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190912',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190912');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190913',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190913');


%% respiration
pathExcel = 'Y:\Logs\Inactivation\Curius\Curius_Inactivation_log_since201905.xlsx';
settings_filename = 'bsa_settings_Curius2019.m'; % full path will be complemented in bsa_ecg_analyze_one_session

out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190913',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190913');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190905',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190905');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190820',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190820');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190814',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190814');
%out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190809',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190809');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190801',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190801');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190729',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190729');

out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190912',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190912');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190910',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190910');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190903',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190903');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190815',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190815');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190808',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190808');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190806',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190806');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190802',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190802');

pathExcel = 'Y:\Logs\Inactivation\Cornelius\Cornelius_Inactivation_log_since201901_1.xlsx';
settings_filename = 'bsa_settings_Cornelius2019.m';
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20191010',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191010');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190314',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190314');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190228',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190228');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190214',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190214');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190207',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190207');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190201',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190201');

out_cap = bsa_respiration_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190313',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190313');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190304',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190304');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190227',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190227');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190213',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190213');
out_cap = bsa_respiration_analyze_one_session('Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190216\bodysignals_without_behavior',pathExcel,settings_filename,'',false,'dataOrigin','TDT');
out_cap = bsa_respiration_analyze_one_session('Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190131\bodysignals_without_behavior',pathExcel,settings_filename,'',false,'dataOrigin','TDT');


bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190124', 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190124\bodysignals_without_behavior');
out_cap = bsa_respiration_analyze_one_session('Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190124\bodysignals_without_behavior',pathExcel,settings_filename,'',false,'dataOrigin','TDT');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190129',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190129');

% Magnus
pathExcel = 'Y:\Logs\Inactivation\Magnus\Magnus_bodySignals_inactivation_log.xlsx';
settings_filename = 'bsa_settings_Magnus2019.m';

out_cap = bsa_respiration_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191121',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191121');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191205',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191205');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191210',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191210');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191212',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191212');

out_cap = bsa_respiration_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191113',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191113');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191120',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191120');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191211',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191211');
out_cap = bsa_respiration_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20191213',pathExcel,settings_filename,'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191213');





%     'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191121';
% %     'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191127';
% %      'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191128'
% %      'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191204' 
%     'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191205' 
%     'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191210' 
%     'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191212' 
% 
%     'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191113';
%     'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191120';
%     'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191211';
%     'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191213';

%% create Table to have the information for a session as overview
session_path = 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius';
pathExcel = 'Y:\Logs\Inactivation\Curius\Curius_Inactivation_log_since201905.xlsx';

session_path = 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius';
pathExcel = 'Y:\Logs\Inactivation\Cornelius\Cornelius_Inactivation_log_since201901.xlsx';

bsa_getSummary_SessionInfo(session_path, pathExcel )

%% dorsal pulvinar & VPL 
monkey = 'Bacchus';
sessions = {
    'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210720';
    'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211001';   
    'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20210826';
    'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\ECG\20211028'};
targetBrainArea         = 'dPul_VPL';
inactivation_sessions   = {'20210720' '20211001' };
baseline_sessions       = {'20210826' '20211028' };
addtoDropbox = 'C:\Users\kkaduk\Dropbox\PhD\Projects\body_signals_analysis\Statistic';
bsa_ecg_summarize_many_sessions('C:\Users\kkaduk\Dropbox\PhD\Projects\body_signals_analysis\Data\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)

monkey = 'Bacchus';  %Curius
targetBrainArea = 'dPul_VPL'; 
Stats_beforeComputedWithR = 0; 
Text = 1; 
path_SaveFig = ['Y:\Projects\Pulv_distractor_spatial_choice\Results\',monkey, '\ECG\',targetBrainArea];
BaselineInjection = 0; %[5,6,7]; %Settings -> red color circle for baseline Injection sessions
bsa_graphs_ecg(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text,BaselineInjection)

% relationship between HRV and HR
bsa_graphs_ecg_HRV_HR(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text)
%% CAP - 
monkey = 'Bacchus';
sessions = {
    'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\CAP\20210720';
    'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\CAP\20211001';   
    'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\CAP\20210826';
    'Y:\Projects\Pulv_distractor_spatial_choice\Data\Bacchus\CAP\20211028'};
targetBrainArea         = 'dPul_VPL';
inactivation_sessions   = {'20210720' '20211001' };
baseline_sessions       = {'20210826' '20211028' };
addtoDropbox = 'C:\Users\kkaduk\Dropbox\PhD\Projects\body_signals_analysis\Statistic';
bsa_cap_summarize_many_sessions('C:\Users\kkaduk\Dropbox\promotion\Projects\BodySignal_Pulvinar\Data\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)
%%%%%%%%
monkey = 'Bacchus';  %Curius
targetBrainArea = 'dPul_VPL'; 
Stats_beforeComputedWithR = 0; 
Text = 1; 
path_SaveFig = ['Y:\Projects\Pulv_distractor_spatial_choice\Results\',monkey, '\ECG\',targetBrainArea];
BaselineInjection = 0; %[5,6,7]; %Settings -> red color circle for baseline Injection sessions
bsa_graphs_cap(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text,BaselineInjection)

%%
monkey = 'Bacchus'; 
targetBrainArea = 'dPul_VPL';
path_SaveFig = ['Y:\Projects\Pulv_distractor_spatial_choice\Results\',monkey, '\ECG\',targetBrainArea]; 
behavior_Data = ['Y:\Projects\Pulv_Inac_ECG_respiration\Figures\', monkey,'\behavior\Inactivation_20190124_20190129_20190201_20190207_20190214_20190228_20190314\Behavior_Inactivation_20190502-1403.mat']; 
bsa_graphs_ecg_behavior(monkey,behavior_Data,targetBrainArea,path_SaveFig)
%%
monkey = 'Cornelius';

sessions = {
    %'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190111';
   % 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190121\bodysignals_without_behavior';%badnoise
   % 
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190131\bodysignals_without_behavior';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190213';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190216\bodysignals_without_behavior';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190227';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190304';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190313';
   'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190403';
   
% 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190913'; 
 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191007'; 
 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191010'; 
 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191014';
 
 %'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191020';

     'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190124\bodysignals_without_behavior'; 
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190129\bodysignals_without_behavior';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190201';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190207';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190214';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190228';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190314';
    
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190828' ; %%dPul left
   % 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190904' ;
   % %%%dPul left, not working
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190910'; %%%dPul left
     'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191011'; %dPul left
     
  %      'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191015';%%%dPul right
  %      'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191017'; %%%dPul right
  %      'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20191021'; %%%dPul right
        };
targetBrainArea = 'dPul';
inactivation_sessions = {'20190124' '20190129' '20190201' '20190207' '20190214' '20190228','20190314' ,'20190828'  ,'20190910' , '20191011'};
baseline_sessions =     {'20190131' '20190213' '20190216' '20190227' '20190304' '20190313' '20190403'   '20191007' '20191010' '20191014'};

addtoDropbox = 'C:\Users\kkaduk\Dropbox\DAG\Kristin\Statistic\body_signal_analysis';
bsa_ecg_summarize_many_sessions('Y:\Projects\Pulv_Inac_ECG_respiration\Results\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)

monkey = 'Cornelius';targetBrainArea = 'dPul';
Stats_beforeComputedWithR = 1; 
Text = 0; 
BaselineInjection = 0; 
Experiment = 'Inactivation'; 
path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Results\',monkey,filesep, Experiment '\ECG\',targetBrainArea]; 
bsa_graphs_ecg(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text,BaselineInjection, Experiment)

%% Curius
% MEDIAL Dorsal PUlvinar
monkey = 'Curius';
sessions = {
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190802';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190804';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190806';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190808';
   'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190815'
   'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190811'
   'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190813'
   %% 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190821'
   %% 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190822'
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190903' %baseline Injection
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190910' %baseline Injection
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190912' %baseline Injection

    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190729';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190801';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190809';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190814';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190820'
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190826'
   % 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190828'
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190905'
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190913'
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190807'

    };
targetBrainArea = 'mdPul';
inactivation_sessions =  {'20190729','20190801','20190809','20190814','20190820','20190905', '20190913','20190826', '20190807'}; 
baseline_sessions =     {'20190802','20190804','20190806','20190808','20190811','20190813', '20190815','20190903','20190910', '20190912'};

addtoDropbox = 'C:\Users\kkaduk\Dropbox\DAG\Kristin\Statistic\body_signal_analysis';
bsa_ecg_summarize_many_sessions('Y:\Projects\Pulv_Inac_ECG_respiration\Results\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)
bsa_cap_summarize_many_sessions('C:\Users\kkaduk\Dropbox\promotion\Projects\BodySignal_Pulvinar\Data\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)

monkey = 'Curius';targetBrainArea = 'mdPul';
Stats_beforeComputedWithR = 1; 
Text = 0; 
BaselineInjection = 0; 
Experiment = 'Inactivation'; 
path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Results\',monkey,filesep, Experiment '\ECG\',targetBrainArea]; 
bsa_graphs_ecg(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text,BaselineInjection, Experiment)

%% Curius
% MEDIAL Dorsal PUlvinar - different baseline
monkey = 'Curius';
sessions = {   
     'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190802';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190806';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190808';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190815'
   % 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190821'
   % 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190822'
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190903'
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190910'
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190912'
    
    

    };
targetBrainArea = 'Controls_mdPul';
inactivation_sessions = {'20190903' '20190910' '20190912'  }; 


%% CURIUS - lateral pulvinar
monkey = 'Curius';
sessions = {
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190717';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190802';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190806';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190808'
    
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190705';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190719';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190723';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190726';

    };
targetBrainArea = 'ldPul';
inactivation_sessions = {'20190705' '20190719' '20190723' '20190726' }; 
%% CORNELIUS - comparison between NEW AND OLD DATASET... medial & lateral dorsal pulvinar
monkey = 'Cornelius';
sessions = {
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190828';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190904';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190910';
    
    
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190124\bodysignals_without_behavior'; 
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190129\bodysignals_without_behavior';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190201';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190207';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190214';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190228';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190314';
};
targetBrainArea = 'dPul_dPulreplication';
inactivation_sessions = {'20190124' '20190129' '20190201' '20190207' '20190214' '20190228','20190314'};

%%
monkey = 'Cornelius';
sessions = {
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190912';
    
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190828';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190904';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190910';
};
targetBrainArea = 'dPul_replication';
inactivation_sessions = {'20190828' '20190904' '20190910'  }; 


%% comparison between Curius and Cornelius
monkey = 'Curius';
sessions = {
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190124\bodysignals_without_behavior'; 
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190129\bodysignals_without_behavior';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190201';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190207';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190228';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190214';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190314';
    
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190729';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190801';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190809';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190814';};
targetBrainArea = 'dPul_Cur_Cor';
inactivation_sessions = {'20190729' '20190801' '20190809' '20190814' }; 


%% ventral pulvinar

sessions = {
    %'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190111';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190403';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190404';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190408';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190424';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190429';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190430';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190508';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Cornelius\20190509';
    
    };
inactivation_sessions = {'20190404' '20190408' '20190430' '20190509' };
targetBrainArea = 'vPul';
monkey = 'Cornelius'; 

addtoDropbox = 'C:\Users\kkaduk\Dropbox\DAG\Kristin\Statistic\body_signal_analysis';
bsa_ecg_summarize_many_sessions('C:\Users\kkaduk\Dropbox\promotion\Projects\BodySignal_Pulvinar\Data\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)
%bsa_cap_summarize_many_sessions('C:\Users\kkaduk\Dropbox\promotion\Projects\BodySignal_Pulvinar\Data\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)

%% MAGNUS
monkey = 'Magnus';
sessions = {
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191121';
%     'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191127';
%      'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191128'
%      'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191204' 
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191205' 
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191210' 
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191212' 

    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191113';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191120';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191211';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Magnus\20191213';

    };

baseline_sessions =     {'20191113' '20191120' '20191211' '20191213' };
inactivation_sessions = {'20191121'  '20191205' '20191210' '20191212'}; % ''20191127' '20191128'   '20191204'
targetBrainArea = 'dPul';
addtoDropbox = 'C:\Users\kkaduk\Dropbox\DAG\Kristin\Statistic\body_signal_analysis';
bsa_ecg_summarize_many_sessions('Y:\Projects\Pulv_Inac_ECG_respiration\Results\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)

monkey = 'Magnus';targetBrainArea = 'dPul';
Stats_beforeComputedWithR = 1; 
Text = 0; 
BaselineInjection = 0; 
Experiment = 'Inactivation'; 
path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Results\',monkey,filesep, Experiment '\ECG\',targetBrainArea]; 
bsa_graphs_ecg(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text,BaselineInjection, Experiment)



%%
monkey = 'Magnus'; 
targetBrainArea = 'dPul_work'; %mdPul %ldPul_mdPul %ldPul %dPul_Cur_Cor %mdPul_AddedSessionNr
Stats_beforeComputedWithR = 0; %[1,2]; 
Text = 0; 
BaselineInjection = 0; %[5,6,7]; %Settings -> red color circle for baseline Injection sessions
path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Figures\',monkey, '\ECG\',targetBrainArea]; 
bsa_graphs_ecg(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text,BaselineInjection)
%%CAP
bsa_graphs_cap(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text,BaselineInjection)

%%
monkey = 'Curius';  %Curius
targetBrainArea = 'mdPul'; %mdPul %ldPul_mdPul %ldPul %dPul_Cur_Cor
Stats_beforeComputedWithR = 0; 
Text = 0; 

path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Figures\',monkey, '\ECG\',targetBrainArea]; 
bsa_graphs_ecg_HRV_HR(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text)
%%
monkey = 'Curius'; 
targetBrainArea = 'ldPul_mdPul';
path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Figures\',monkey, '\ECG_behavior']; 
behavior_Data = ['Y:\Projects\Pulv_Inac_ECG_respiration\Figures\', monkey,'\behavior\Inactivation_20190124_20190129_20190201_20190207_20190214_20190228_20190314\Behavior_Inactivation_20190502-1403.mat']; 
bsa_graphs_ecg_behavior(monkey,behavior_Data,targetBrainArea,path_SaveFig)

%% OUTLIER EVALUATION
monkey = 'Curius';
sessions = {
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190802';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190806';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190808';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190815'
   % 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190821'
   % 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190822'
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190903' %baseline Injection
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190910' %baseline Injection
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190912' %baseline Injection

    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190729';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190801';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190809';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190814';
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190820'
   %% 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190826'
   %% 'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190828'
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190905'
    'Y:\Projects\Pulv_Inac_ECG_respiration\Data\Curius\20190913'

    };
targetBrainArea = 'mdPul_AddedSessionNr';
inactivation_sessions = {'20190729' '20190801' '20190809' '20190814' '20190820'  '20190905'  '20190913' }; %'20190828'  

path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Figures\',monkey, '\ECG\',targetBrainArea]; 
bsa_evaluate_outliers(monkey, sessions,targetBrainArea, inactivation_sessions, path_SaveFig )

%%
monkey = 'Cornelius'; 
targetBrainArea = 'dPul';
path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Figures\',monkey, '\ECG\',targetBrainArea]; 

bsa_meanHR(monkey,targetBrainArea,path_SaveFig)
