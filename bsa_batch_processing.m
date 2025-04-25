% this is not a function, it is just a convenience script to run functions over several sessions
%% TODO
% 1) vector with sessions & monkey to have only one line
%%
%cmb-File
% 20 Session for the choiceBias
addpath(genpath('C:\Source\MATLAB\Igtools\')) %round2
addpath 'C:\Users\kkaduk\Desktop\Kristin\GitHub\body_signals_analysis'
addpath(genpath('C:\Users\kkaduk\Desktop\Kristin\GitHub\PhysioNet-Cardiovascular-Signal-Toolbox'));
addpath(genpath( 'C:\Users\kkaduk\Desktop\Kristin\GitHub\robust_hrv')); 



%%
pathExcel = 'Y:\Logs\Inactivation\Cornelius\Cornelius_Inactivation_log_since201901_NoCalibration_030524.xlsx';
settings_filename = 'bsa_settings_Cornelius2019.m';
%Test for Pont Care
%out = bsa_ecg_analyze_one_session_NEW_PoinCarePlot('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190214',pathExcel,settings_filename,'Y:\Data\BodySignals\ECG\Cornelius\20190214');
sessionList = [20190124  ,  20190131  20190129, 20190201, 20190207 ,20190213, 20190214,20190215, 20190216,20190227,  20190313,20190314, 20190228 ,   20190304 , 20190403,20190828,20190904, 20190910,20190912,20190913, 20191007, 20191010, 20191011 , 20191014,20190404  ,  20190408  , ...
    20190424 ,   20190429 ,   20190430  ,  20190508   , 20190509   , 20190813  ,  20191013 ,20191015  ,  20191017  ,  20191018  ,  20191020  ,  20191021];
sessionList = [   20191013 ,20191015  ,  20191017  ,  20191018  ,  20191020  ,  20191021];%
sessionList = [     20190214 ];
%Take all sessions from the Excel/File marked as 1
Excel = readtable(pathExcel);
SessionsInExcel = unique(Excel.date);

% Which Sessions are in the Excel-File?
SessionsInExcelStrings = cellstr(num2str(SessionsInExcel));
% Which Sessions should be analyzed from Excel-File?
SessionsInExcel_ForAna = unique(Excel.date(Excel.InaDPul_ECG == 1)).';
SessionsInExcel_ForAna_Str = cellstr(num2str(SessionsInExcel_ForAna));

SessionsForAna = intersect(SessionsInExcel_ForAna, sessionList);

NotInSessionList = setdiff(SessionsInExcel_ForAna, sessionList);
NotInSessionList = [     20191021, 20191018, 20191020, ];
sessionList = [     20190227];

% Problem:    20190404 ,
% Success:  20190304 , 20190408  ,
% Problem witht he session Corcombined2019-01-31_11_block_10 - 20190131 ,
% 20190228  ,b
for currDate = sessionList
    [out] = ...
        bsa_respiration_analyze_one_session(['Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\' num2str(currDate)], pathExcel, settings_filename, ['Y:\Data\BodySignals\CAP\Cornelius\' num2str(currDate)]);
end


for currDate = NotInSessionList
    [out] = ...
        bsa_ecg_analyze_one_session_NEW_PoinCarePlot(['Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\' num2str(currDate)], pathExcel, settings_filename, ['Y:\Data\BodySignals\ECG\Cornelius\' num2str(currDate)]);
end

for currDate = sessionList
    [out_ecg, out_cap] = ...
        bsa_ecg_cap_together_analyze_one_session(['Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\' num2str(currDate)], pathExcel,settings_filename);
end

sessionList = [20190129, 20190201, 20190207 ,20190213, 20190214,20190216,20190227,  20190313,20190314, 20190403,20190828,20190910,20191007, 20191010, 20191011 , 20191014];
% 20190912, 20190913- PBS
% right Inactivation
sessionList = [20190813, 20191014, 20191015, 20191017, 20191018, 20191020, 20191021];
% DPul only TDT  
sessionList = [20190124, 20190131, 20190216,20190228, 20190304 ];
%VPul
sessionList = [20190404, 20190408, 20190424, 20190429, 20190430, 20190508, 20190509];

for sessNum = 1:length(sessionList)
    currSession = num2str(sessionList(sessNum));
    [out] = ...
        bsa_ecg_analyze_one_session(['Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\' num2str(currSession)], pathExcel, settings_filename, ['Y:\Data\BodySignals\ECG\Cornelius\' currSession]);
end

for currDate = NotInSessionList
    %bsa_read_and_save_TDT_data_without_behavior(['Y:\Data\TDTtanks\Cornelius_phys\', currDate], ['Y:\Data\BodySignals\ECG\Cornelius\', currDate]);

    [out] = ...
        bsa_ecg_analyze_one_session_NEW_PoinCarePlot(['Y:\Data\BodySignals\ECG\Cornelius\', num2str(currDate)], pathExcel, settings_filename, ['Y:\Data\BodySignals\ECG\Cornelius\' num2str(currDate)],'keepRunFigs',false,'dataOrigin','TDT');
end


for  currDate = NotInSessionList
    currDate
   % bsa_read_and_save_TDT_data_without_behavior(['Y:\Data\TDTtanks\Cornelius_phys\', currSession], ['Y:\Data\BodySignals\CAP\Cornelius\', currSession]);

    [out] = ...
        bsa_respiration_analyze_one_session(['Y:\Data\BodySignals\CAP\Cornelius\', num2str(currDate)], pathExcel, settings_filename, ['Y:\Data\BodySignals\CAP\Cornelius\' num2str(currDate)],'keepRunFigs',false,'dataOrigin','TDT');
end

% Single Session example
bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Cornelius_phys\20190808', 'Y:\Data\BodySignals\ECG\Cornelius\20190808\bodysignals_without_behavior');
out = bsa_ecg_analyze_one_session('Y:\Data\BodySignals\ECG\Cornelius\20190808\bodysignals_without_behavior',pathExcel,settings_filename,'',false,'dataOrigin','TDT');


%% MAGNUS
pathExcel = 'Y:\Logs\Inactivation\Magnus\Magnus_bodySignals_inactivation_log.xlsx';

settings_filename = 'bsa_settings_Magnus2019.m';
% deteleted data in 20220921
sessionList = [ 20191119,20191205, 20191210, 20191211, 20191212, 20191213,20191120,20191121,20191127, 20191128, 20191204];
sessionList = [ 20191211];
%20191119 - cmb files differ to excel
Excel = readtable(pathExcel);
SessionsInExcel = unique(Excel.date);

% Which Sessions are in the Excel-File?
%SessionsInExcelStrings = cellstr(num2str(SessionsInExcel));
% Which Sessions should be analyzed from Excel-File?
SessionsInExcel_ForAna = unique(Excel.date(Excel.InaDPul_ECG == 1)).';
SessionsInExcel_ForAna_Str = cellstr(num2str(SessionsInExcel_ForAna));

SessionsForAna = intersect(SessionsInExcel_ForAna, sessionList);
sort(SessionsForAna)
NotInSessionList = setdiff(SessionsInExcel_ForAna, sessionList);


for currDate = sessionList
    [out] = ...
        bsa_respiration_analyze_one_session(['Y:\Data\Magnus_phys_combined_monkeypsych_TDT\' num2str(currDate)], pathExcel, settings_filename, ['Y:\Data\BodySignals\CAP\Magnus\' num2str(currDate)]);
end

for currDate = NotInSessionList
    [out_ecg, out_cap] = ...
        bsa_ecg_cap_together_analyze_one_session(['Y:\Data\Magnus_phys_combined_monkeypsych_TDT\' num2str(currDate)], pathExcel,settings_filename);
end


for sessNum = 1:length(sessionList)
    currSession = num2str(sessionList(sessNum));
    [out] = ...
        bsa_ecg_analyze_one_session_NEW_PoinCarePlot(['Y:\Data\Magnus_phys_combined_monkeypsych_TDT\' currSession], pathExcel, settings_filename, ['Y:\Data\BodySignals\ECG\Magnus\' currSession]);
end


for sessNum = 1:length(sessionList)
    currSession = num2str(sessionList(sessNum));
    [out_ecg, out_cap] = ...
        bsa_ecg_analyze_one_session(['Y:\Data\Magnus_phys_combined_monkeypsych_TDT\' currSession], pathExcel, settings_filename);
end

 



for sessNum = 1:length(sessionList)
    currSession = num2str(sessionList(sessNum));
    bsa_read_and_save_TDT_data_without_behavior(['Y:\Data\TDTtanks\Magnus_phys\', currSession], ['Y:\Data\BodySignals\CAP\Cornelius\', currSession]);

    [out] = ...
        bsa_respiration_analyze_one_session(['Y:\Data\BodySignals\CAP\Magnus\', currSession], pathExcel, settings_filename, ['Y:\Data\BodySignals\CAP\Cornelius\' currSession],'keepRunFigs',false,'dataOrigin','TDT');
end

out = bsa_ecg_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20230623',pathExcel,settings_filename,'Y:\Data\BodySignals\ECG\Magnus\20230623');

out_cap = bsa_respiration_analyze_one_session('Y:\Data\Magnus_phys_combined_monkeypsych_TDT\20220921',pathExcel,settings_filename,'Y:\Data\BodySignals\CAP\Magnus\20220921');

%% BACCHUS
pathExcel = 'Y:\Logs\Phys\Bacchus\Bacchus_bodySignals_ephys_log.xlsx';
settings_filename = 'bsa_settings_Bacchus2019.m';
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20191112',pathExcel,settings_filename,'Y:\Data\BodySignals\ECG\Bacchus\20191112');
out = bsa_ecg_analyze_one_session('Y:\Data\Bacchus_phys_combined_monkeypsych_TDT\20191113',pathExcel,settings_filename,'Y:\Data\BodySignals\ECG\Bacchus\20191113');

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

%% electrophysiology-study
out = bsa_ecg_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20210318',pathExcel,settings_filename,'Y:\Data\BodySignals\ECG\Curius\20210318');


%% Inactivation study
pathExcel = 'Y:\Logs\Inactivation\Curius\Curius_Inactivation_log_since201905_NoCalibration.xlsx';
settings_filename = 'bsa_settings_Curius2019.m'; % full path will be complemented in bsa_ecg_analyze_one_session

sessionList = [20190717, 20190729,20190801,20190802,20190806,20190807, 20190808, 20190809, 20190813, 20190814,20190815, 20190820,20190822, 20190826,20190828,20190903, 20190905,20190910, 20190912,  20190913 ];
Excel = readtable(pathExcel);
SessionsInExcel = unique(Excel.date);

% Which Sessions are in the Excel-File?
SessionsInExcelStrings = cellstr(num2str(SessionsInExcel));
% Which Sessions should be analyzed from Excel-File?
SessionsInExcel_ForAna = unique(Excel.date(Excel.InaDPul_ECG == 1)).';
SessionsInExcel_ForAna_Str = cellstr(num2str(SessionsInExcel_ForAna));
sort(SessionsInExcel_ForAna)

SessionsForAna = intersect(SessionsInExcel_ForAna, sessionList);
NotInSessionList = setdiff(SessionsInExcel_ForAna, sessionList);

for currDate = SessionsForAna
    [out_ecg, out_cap] = ...
        bsa_ecg_cap_together_analyze_one_session(['Y:\Data\Curius_phys_combined_monkeypsych_TDT\' num2str(currDate)], pathExcel,settings_filename);
end

for sessNum = 1:length(sessionList)
    currSession = num2str(sessionList(sessNum));
    [out] = ...
        bsa_ecg_analyze_one_session_NEW_PoinCarePlot(['Y:\Data\Curius_phys_combined_monkeypsych_TDT\' currSession], pathExcel, settings_filename, ['Y:\Data\BodySignals\ECG\Curius\' currSession]);
end

%% respiration
pathExcel = 'Y:\Logs\Inactivation\Curius\Curius_Inactivation_log_since201905_NoCalibration.xlsx';
settings_filename = 'bsa_settings_Curius2019.m'; % full path will be complemented in bsa_ecg_analyze_one_session
%20190717, 20190729,
sessionList = [20190801,20190802,20190806,20190807, 20190808, 20190809, 20190813, 20190814,20190815, 20190820,20190822, 20190826,20190828,20190903, 20190905,20190910, 20190912,  20190913 ];

for sessNum = 1:length(sessionList)
    currSession = num2str(sessionList(sessNum));
    [out] = ...
        bsa_respiration_analyze_one_session_NEW(['Y:\Data\Curius_phys_combined_monkeypsych_TDT\' currSession], pathExcel, settings_filename, ['Y:\Data\BodySignals\CAP\Curius\' currSession]);
end

%% create Table to have the information for a session as overview
session_path = 'Y:\Data\BodySignals\ECG\Curius';
pathExcel = 'Y:\Logs\Inactivation\Curius\Curius_Inactivation_log_since201905.xlsx';

session_path = 'Y:\Data\BodySignals\ECG\Cornelius';
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

%
sessions = {
    %'Y:\Data\BodySignals\ECG\Cornelius\20190111';
    % 'Y:\Data\BodySignals\ECG\Cornelius\20190121\bodysignals_without_behavior';%badnoise
    'Y:\Data\BodySignals\ECG\Cornelius\20190131';
    'Y:\Data\BodySignals\ECG\Cornelius\20190213';
    'Y:\Data\BodySignals\ECG\Cornelius\20190216';
    'Y:\Data\BodySignals\ECG\Cornelius\20190227';
    'Y:\Data\BodySignals\ECG\Cornelius\20190304';
    'Y:\Data\BodySignals\ECG\Cornelius\20190313';
   % 'Y:\Data\BodySignals\ECG\Cornelius\20190403';
    % 'Y:\Data\BodySignals\ECG\Cornelius\20190913';
    'Y:\Data\BodySignals\ECG\Cornelius\20191007';
    'Y:\Data\BodySignals\ECG\Cornelius\20191010';
  %  'Y:\Data\BodySignals\ECG\Cornelius\20191014';

    %20190124 20190129 20190201 20190214 20190228 20190314 20190910 20191011
% 20190207 20190828 20190904  
    
    %'Y:\Data\BodySignals\ECG\Cornelius\20191020';
    'Y:\Data\BodySignals\ECG\Cornelius\20190124\';
    'Y:\Data\BodySignals\ECG\Cornelius\20190129';
    %'Y:\Data\BodySignals\ECG\Cornelius\20190129\bodysignals_without_behavior';
    
    'Y:\Data\BodySignals\ECG\Cornelius\20190201';
   % 'Y:\Data\BodySignals\ECG\Cornelius\20190207'; out by Crawfold
    'Y:\Data\BodySignals\ECG\Cornelius\20190214';
    'Y:\Data\BodySignals\ECG\Cornelius\20190228';
    'Y:\Data\BodySignals\ECG\Cornelius\20190314';
    %'Y:\Data\BodySignals\ECG\Cornelius\20190828' ; %%dPul left out by Crawfold
    % 'Y:\Data\BodySignals\ECG\Cornelius\20190904' ; out by Crawfold & was
    % excluded before
    % %%%dPul left, not working
    'Y:\Data\BodySignals\ECG\Cornelius\20190910'; %%%dPul left
    'Y:\Data\BodySignals\ECG\Cornelius\20191011'; %dPul left
    
    %      'Y:\Data\BodySignals\ECG\Cornelius\20191015';%%%dPul right
    %      'Y:\Data\BodySignals\ECG\Cornelius\20191017'; %%%dPul right
    %      'Y:\Data\BodySignals\ECG\Cornelius\20191021'; %%%dPul right
    };
targetBrainArea = 'dPul';
inactivation_sessions = {'20190124' '20190129' '20190201' '20190207' '20190214' '20190228' '20190314' '20190828'  '20190910'   '20191011'};
baseline_sessions =     {'20190131' '20190213' '20190216' '20190227' '20190304' '20190313' '20190403'   '20191007' '20191010' '20191014'};

inactivation_sessions = {'20190124' '20190129' '20190201' '20190207' '20190214' '20190314' '20190910'  '20191011'};
baseline_sessions =     {'20190131' '20190213' '20190216' '20190227' '20190304' '20190313' '20191007' '20191010'};


addtoDropbox = 'C:\Users\kkaduk\Dropbox\PhD\Projects\Monkey_Ina_ECG_Respiration\AGit_ECG_Respiration_Ina\data\PreProcessedData';

bsa_ecg_summarize_many_sessions('Y:\Projects\Pulv_Inac_ECG_respiration\Results\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)
bsa_cap_summarize_many_sessions('Y:\Projects\Pulv_Inac_ECG_respiration\Results\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)



monkey = 'Cornelius';targetBrainArea = 'dPul';
Stats_beforeComputedWithR = 0; 
Text = 0; 
BaselineInjection = 0; 
Experiment = 'Inactivation'; 
path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Results\',monkey,filesep, Experiment '\ECG\',targetBrainArea]; 
bsa_graphs_ecg(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text,BaselineInjection, Experiment)

path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Results\',monkey,filesep, Experiment '\CAP\',targetBrainArea]; 
bsa_graphs_cap(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text,BaselineInjection, Experiment)

%% Plot the difference between Control and Inactivation session
monkey = 'Cornelius'; Experiment = 'Inactivation'; Text = 1; 
targetBrainArea = 'dPul';Stats_beforeComputedWithR = 1; 
path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Results\',monkey,filesep, Experiment '\ECG\',targetBrainArea]; 
bsa_meanHR(monkey,targetBrainArea,path_SaveFig)
bsa_graphs_ecg_HRV_HR(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text)

bsa_graphs_ecg_HR_Respiration(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text)

%% Curius
% MEDIAL Dorsal PUlvinar
monkey = 'Curius';

%20190717 20190802 20190806 20190808 20190813 20190815 20190822 20190903 20190910 20190912
sessions = {
    'Y:\Data\BodySignals\ECG\Curius\20190717';
    'Y:\Data\BodySignals\ECG\Curius\20190802';
    'Y:\Data\BodySignals\ECG\Curius\20190806';
    'Y:\Data\BodySignals\ECG\Curius\20190808';
    'Y:\Data\BodySignals\ECG\Curius\20190813'
   'Y:\Data\BodySignals\ECG\Curius\20190815'
  % 'Y:\Data\BodySignals\ECG\Curius\20190811'
   %% 'Y:\Data\BodySignals\ECG\Curius\20190821'
   'Y:\Data\BodySignals\ECG\Curius\20190822'
    'Y:\Data\BodySignals\ECG\Curius\20190903' %baseline Injection
  %  'Y:\Data\BodySignals\ECG\Curius\20190910' %baseline Injection
  %  'Y:\Data\BodySignals\ECG\Curius\20190912' %baseline Injection

   
  % included by Crawfold: 20190729 20190801 20190809 20190814 20190820 20190826 20190905 20190913
    'Y:\Data\BodySignals\ECG\Curius\20190729';
    'Y:\Data\BodySignals\ECG\Curius\20190801';
    'Y:\Data\BodySignals\ECG\Curius\20190809';
    'Y:\Data\BodySignals\ECG\Curius\20190814';
    'Y:\Data\BodySignals\ECG\Curius\20190820'
    'Y:\Data\BodySignals\ECG\Curius\20190826'
   % 'Y:\Data\BodySignals\ECG\Curius\20190828'
    'Y:\Data\BodySignals\ECG\Curius\20190905'
    'Y:\Data\BodySignals\ECG\Curius\20190913'
    %'Y:\Data\BodySignals\ECG\Curius\20190807' out by Crawfold

    };
targetBrainArea = 'mdPul';

inactivation_sessions =  {'20190729','20190801','20190809','20190814','20190820','20190826','20190905', '20190913'}; 
baseline_sessions =     {'20190717','20190802','20190806','20190808','20190813', '20190815', '20190822','20190903'};

inactivation_sessions =  {'20190729','20190801','20190809','20190814','20190820','20190826', '20190807','20190905', '20190913'}; 
baseline_sessions =     {'20190802','20190804','20190806','20190808','20190811','20190813', '20190815','20190903','20190910', '20190912'};

addtoDropbox = 'C:\Users\kkaduk\Dropbox\PhD\Projects\Monkey_Ina_ECG_Respiration\AGit_ECG_Respiration_Ina\data\PreProcessedData';
bsa_ecg_summarize_many_sessions('Y:\Projects\Pulv_Inac_ECG_respiration\Results\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)
bsa_cap_summarize_many_sessions('Y:\Projects\Pulv_Inac_ECG_respiration\Results\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)

monkey = 'Curius';targetBrainArea = 'mdPul';
Stats_beforeComputedWithR = 1; 
Text = 0; 
BaselineInjection = 0; 
Experiment = 'Inactivation'; 
path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Results\',monkey,filesep, Experiment '\ECG\',targetBrainArea]; 
bsa_graphs_ecg(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text,BaselineInjection, Experiment)
bsa_graphs_ecg_HRV_HR(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text)
bsa_graphs_ecg_HR_Respiration(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text)

path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Results\',monkey,filesep, Experiment '\CAP\',targetBrainArea]; 
bsa_graphs_cap(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text,BaselineInjection, Experiment)




%% MAGNUS
monkey = 'Magnus';
sessions = {
    'Y:\Data\BodySignals\ECG\Magnus\20191121';
%     'Y:\Data\BodySignals\ECG\Magnus\20191127';
%      'Y:\Data\BodySignals\ECG\Magnus\20191128'
%      'Y:\Data\BodySignals\ECG\Magnus\20191204' 
    'Y:\Data\BodySignals\ECG\Magnus\20191205' 
    'Y:\Data\BodySignals\ECG\Magnus\20191210' 
    'Y:\Data\BodySignals\ECG\Magnus\20191212' 

    'Y:\Data\BodySignals\ECG\Magnus\20191113';
    'Y:\Data\BodySignals\ECG\Magnus\20191120';
    'Y:\Data\BodySignals\ECG\Magnus\20191211';
    'Y:\Data\BodySignals\ECG\Magnus\20191213';

    };

baseline_sessions =     {'20191113' '20191120' '20191211' '20191213' }; %
inactivation_sessions = {'20191121'  '20191205' '20191210' '20191212'}; % ''20191127' '20191128'   '20191204'
targetBrainArea = 'dPul';
addtoDropbox = 'C:\Users\kkaduk\Dropbox\DAG\Kristin\Statistic\body_signal_analysis';
bsa_ecg_summarize_many_sessions('Y:\Projects\Pulv_Inac_ECG_respiration\Results\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)
bsa_cap_summarize_many_sessions('Y:\Projects\Pulv_Inac_ECG_respiration\Results\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)

monkey = 'Magnus';targetBrainArea = 'dPul';
Stats_beforeComputedWithR = 1; 
Text = 0; 
BaselineInjection = 0; 
Experiment = 'Inactivation'; 
path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Results\',monkey,filesep, Experiment '\ECG\',targetBrainArea]; 
bsa_graphs_ecg(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text,BaselineInjection, Experiment)
bsa_graphs_ecg_HRV_HR(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text)


path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Results\',monkey,filesep, Experiment '\CAP\',targetBrainArea]; 
bsa_graphs_cap(monkey,targetBrainArea,path_SaveFig, Stats_beforeComputedWithR, Text,BaselineInjection, Experiment)




%% CURIUS - lateral pulvinar
monkey = 'Curius';
sessions = {
    'Y:\Data\BodySignals\ECG\Curius\20190717';
    'Y:\Data\BodySignals\ECG\Curius\20190802';
    'Y:\Data\BodySignals\ECG\Curius\20190806';
    'Y:\Data\BodySignals\ECG\Curius\20190808'
    
    'Y:\Data\BodySignals\ECG\Curius\20190705';
    'Y:\Data\BodySignals\ECG\Curius\20190719';
    'Y:\Data\BodySignals\ECG\Curius\20190723';
    'Y:\Data\BodySignals\ECG\Curius\20190726';

    };
targetBrainArea = 'ldPul';
inactivation_sessions = {'20190705' '20190719' '20190723' '20190726' }; 

%% ventral pulvinar

sessions = {
    %'Y:\Data\BodySignals\ECG\Cornelius\20190111';
    'Y:\Data\BodySignals\ECG\Cornelius\20190403';
    'Y:\Data\BodySignals\ECG\Cornelius\20190404';
    'Y:\Data\BodySignals\ECG\Cornelius\20190408';
    'Y:\Data\BodySignals\ECG\Cornelius\20190424';
    'Y:\Data\BodySignals\ECG\Cornelius\20190429';
    'Y:\Data\BodySignals\ECG\Cornelius\20190430';
    'Y:\Data\BodySignals\ECG\Cornelius\20190508';
    'Y:\Data\BodySignals\ECG\Cornelius\20190509';
    
    };
inactivation_sessions = {'20190404' '20190408' '20190430' '20190509' };
targetBrainArea = 'vPul';
monkey = 'Cornelius'; 

addtoDropbox = 'C:\Users\kkaduk\Dropbox\DAG\Kristin\Statistic\body_signal_analysis';
bsa_ecg_summarize_many_sessions('C:\Users\kkaduk\Dropbox\promotion\Projects\BodySignal_Pulvinar\Data\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)
%bsa_cap_summarize_many_sessions('C:\Users\kkaduk\Dropbox\promotion\Projects\BodySignal_Pulvinar\Data\', sessions, inactivation_sessions, targetBrainArea, addtoDropbox, monkey)

%%
monkey = 'Curius'; 
targetBrainArea = 'ldPul_mdPul';
path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Figures\',monkey, '\ECG_behavior']; 
behavior_Data = ['Y:\Projects\Pulv_Inac_ECG_respiration\Figures\', monkey,'\behavior\Inactivation_20190124_20190129_20190201_20190207_20190214_20190228_20190314\Behavior_Inactivation_20190502-1403.mat']; 
bsa_graphs_ecg_behavior(monkey,behavior_Data,targetBrainArea,path_SaveFig)

%% OUTLIER EVALUATION
monkey = 'Curius';
sessions = {
    'Y:\Data\BodySignals\ECG\Curius\20190802';
    'Y:\Data\BodySignals\ECG\Curius\20190806';
    'Y:\Data\BodySignals\ECG\Curius\20190808';
    'Y:\Data\BodySignals\ECG\Curius\20190815'
   % 'Y:\Data\BodySignals\ECG\Curius\20190821'
   % 'Y:\Data\BodySignals\ECG\Curius\20190822'
    'Y:\Data\BodySignals\ECG\Curius\20190903' %baseline Injection
    'Y:\Data\BodySignals\ECG\Curius\20190910' %baseline Injection
    'Y:\Data\BodySignals\ECG\Curius\20190912' %baseline Injection

    'Y:\Data\BodySignals\ECG\Curius\20190729';
    'Y:\Data\BodySignals\ECG\Curius\20190801';
    'Y:\Data\BodySignals\ECG\Curius\20190809';
    'Y:\Data\BodySignals\ECG\Curius\20190814';
    'Y:\Data\BodySignals\ECG\Curius\20190820'
   %% 'Y:\Data\BodySignals\ECG\Curius\20190826'
   %% 'Y:\Data\BodySignals\ECG\Curius\20190828'
    'Y:\Data\BodySignals\ECG\Curius\20190905'
    'Y:\Data\BodySignals\ECG\Curius\20190913'

    };
targetBrainArea = 'mdPul_AddedSessionNr';
inactivation_sessions = {'20190729' '20190801' '20190809' '20190814' '20190820'  '20190905'  '20190913' }; %'20190828'  


path_SaveFig = ['Y:\Projects\Pulv_Inac_ECG_respiration\Figures\',monkey, '\ECG\',targetBrainArea]; 
bsa_evaluate_outliers(monkey, sessions,targetBrainArea, inactivation_sessions, path_SaveFig )

%%

