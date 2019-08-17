% this is not a function, it is just a convenience script to run functions over several sessions
%% TODO
% 1) vector with sessions & monkey to have only one line
%%
pathExcel = 'Y:\Logs\Inactivation\Cornelius\Cornelius_Inactivation_log_since201901_1.xlsx';
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

bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190129', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129\bodysignals_without_behavior',pathExcel,settings_filename,'',false,'dataOrigin','TDT');

bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190131', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190131\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190131\bodysignals_without_behavior',pathExcel,settings_filename,'',false,'dataOrigin','TDT');

out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190201',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190201');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190207',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190207');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190214',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190214');
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190216', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190216\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190216\bodysignals_without_behavior',pathExcel,settings_filename,'',false,'dataOrigin','TDT');

out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190227',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190227');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190228',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190228');
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190228', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190228\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190228',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190228');
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190304', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190304\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190304',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190304');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190313',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190313');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190314',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190314');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190403',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190403');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190404',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190404');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190408',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190408');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190424',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190424');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190429',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190429');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190430',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190430');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190508',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190508');
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190509',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190509');

bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190808', 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190808\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190808\bodysignals_without_behavior',pathExcel,settings_filename,'',false,'dataOrigin','TDT');

%% CURIUS
pathExcel = 'Y:\Logs\Inactivation\Curius\Curius_Inactivation_log_since201905.xlsx';
settings_filename = 'bsa_settings_Curius2019.m'; % full path will be complemented in bsa_ecg_analyze_one_session

out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190625',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190625');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190703',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190703');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190701',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190701');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190705',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190705');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190717',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190717');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190719',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190719');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190723',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190723');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190726',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190726');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190729',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190729');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190801',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190801');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190802',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190802');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190804',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190804');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190806',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190806');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190807',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190807');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190808',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190808');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190809',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190809');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190811',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190811');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190813',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190813');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190814',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190814');
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190815',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190815');

out = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190808',pathExcel,settings_filename,'Y:\Projects\PhysiologicalRecording\Data\Curius\20190808');


%% create Table to have the information for a session as overview
session_path = 'Y:\Projects\PhysiologicalRecording\Data\Curius';
pathExcel = 'Y:\Logs\Inactivation\Curius\Curius_Inactivation_log_since201905.xlsx';

session_path = 'Y:\Projects\PhysiologicalRecording\Data\Cornelius';
pathExcel = 'Y:\Logs\Inactivation\Cornelius\Cornelius_Inactivation_log_since201901.xlsx';

bsa_getSummary_SessionInfo(session_path, pathExcel )

%% dorsal pulvinar
monkey = 'Cornelius';

sessions = {
    %'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190111';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190121\bodysignals_without_behavior';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190131\bodysignals_without_behavior';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190213';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190216\bodysignals_without_behavior';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190227';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190304';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190313';

    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior'; 
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129\bodysignals_without_behavior';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190201';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190207';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190214';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190228';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190314'; };
targetBrainArea = 'dPul';
inactivation_sessions = {'20190124' '20190129' '20190201' '20190207' '20190214' '20190228','20190314'};

%% Curius
% MEDIAL Dorsal PUlvinar
monkey = 'Curius';
sessions = {
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190802';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190806';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190808';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190815'
    
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190729';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190801';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190809';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190814';

    };
targetBrainArea = 'dPul';
inactivation_sessions = {'20190729' '20190801' '20190809' '20190814' }; 
%% CURIUS - lateral pulvinar
monkey = 'Curius';
sessions = {
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190717';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190802';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190806';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190808'
    
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190705';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190719';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190723';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190726';

    };
targetBrainArea = 'ldPul';
inactivation_sessions = {'20190705' '20190719' '20190723' '20190726' }; 

%% CURIUS - comparison between medial & lateral dorsal pulvinar
monkey = 'Curius';
sessions = {
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190705';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190719';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190723';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190726';
    
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190729';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190801';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190809';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190814';};
targetBrainArea = 'ldPul_mdPul';
inactivation_sessions = {'20190729' '20190801' '20190809' '20190814' }; 

%%
monkey = 'Curius';
sessions = {
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior'; 
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129\bodysignals_without_behavior';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190201';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190207';
        'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190228';

    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190214';
    'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190314';
    
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190729';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190801';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190809';
    'Y:\Projects\PhysiologicalRecording\Data\Curius\20190814';};
targetBrainArea = 'dPul_Cur_Cor';
inactivation_sessions = {'20190729' '20190801' '20190809' '20190814' }; 


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
monkey = 'Cornelius'; 

addtoDropbox = 'C:\Users\kkaduk\Dropbox\DAG\Kristin\Statistic\body_signal_analysis';
bsa_ecg_summarize_many_sessions('C:\Users\kkaduk\Dropbox\promotion\Projects\BodySignal_Pulvinar\Data\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)

%%
monkey = 'Curius'; 
targetBrainArea = 'dPul_Cur_Cor'; %mdPul %ldPul_mdPul %ldPul
Stats = 0; 
Text = 0; 
path_SaveFig = ['Y:\Projects\PhysiologicalRecording\Figures\',monkey, '\ECG']; 
bsa_graphs_ecg(monkey,targetBrainArea,path_SaveFig, Stats, Text)


%%
monkey = 'Cornelius'; 
targetBrainArea = 'dPul';
path_SaveFig = ['Y:\Projects\PhysiologicalRecording\Figures\',monkey, '\ECG_behavior']; 
behavior_Data = ['Y:\Projects\PhysiologicalRecording\Figures\', monkey,'\behavior\Inactivation_20190124_20190129_20190201_20190207_20190214_20190228_20190314\Behavior_Inactivation_20190502-1403.mat']; 
bsa_graphs_ecg_behavior(monkey,behavior_Data,targetBrainArea,path_SaveFig)