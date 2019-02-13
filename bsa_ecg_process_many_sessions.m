function bsa_ecg_process_many_sessions

sessions = {
% 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190111';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190121\bodysignals_without_behavior'; % rerun
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior'; % rerun
% 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129\bodysignals_without_behavior';
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190131\bodysignals_without_behavior'; % rerun
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190201'; % rerun
'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190207'; % rerun
};

for s = 1:length(sessions), % for each session
    session_path = sessions{s};
    
switch session_path
    
    case 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190111',
        % Cornelius 20190111 training
ses.first_inj_block = 5;
ses.type = ... % 1 task, 0 rest
[
-2 % skip this block
1
0
1
0
1
1
1
1
1
0
1
];

    case 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190121\bodysignals_without_behavior'
        % Cornelius 20190121 baseline
ses.first_inj_block = 5;
ses.type = ... % 1 task, 0 rest
[
1
0
1
0
1
0
1
0
1
0
1
0
0
1
0
1
0
1
0
1
];
out = bsa_ecg_analyze_one_session(session_path,'',false,'dataOrigin','TDT','sessionInfo',ses);

    case 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190124\bodysignals_without_behavior'
        % Cornelius 20190124
ses.first_inj_block = 3;
ses.type = ... % 1 task, 0 rest
[
1
0
0
1
0
1
0
0
1
0
1
0
1
1
0
1
0
1
];
out = bsa_ecg_analyze_one_session(session_path,'',false,'dataOrigin','TDT','sessionInfo',ses);

    case 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190129\bodysignals_without_behavior'
        % Cornelius 20190129 (block 8 deleted)
ses.first_inj_block = 6;
ses.type = ... % 1 task, 0 rest
[
1
0
1
0
1
0
0

-1
-1
1
0
1
0
1
0
1
0

0
1
1
1
1
0
];
out = bsa_ecg_analyze_one_session(session_path,'',false,'dataOrigin','TDT','sessionInfo',ses);

    case 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190131\bodysignals_without_behavior'
        % Cornelius 20190131 baseline
ses.first_inj_block = 5;
ses.type = ... % 1 task, 0 rest
[
1
0
1
0
0
0
1
0
1
0
1
0
-1
1
];
out = bsa_ecg_analyze_one_session(session_path,'',false,'dataOrigin','TDT','sessionInfo',ses);

    case 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190201'
        % Cornelius 20190201
ses.first_inj_block = 6;
ses.type = ... % 1 task, 0 rest
[
1
0
1
0
1
0
0
1
0
1
0
1
0
1
1
0
1
0
1
1
1
1
0
];
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190201','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190201',false,'sessionInfo',ses);

    case 'Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190207'
        % Cornelius 20190207
ses.first_inj_block = 6;
ses.type = ... % 1 task, 0 rest
[
1
0
1
0
1
0
0
1
1
0
1
0
1
0
1
0
1
0
1
0
1
0
];
out = bsa_ecg_analyze_one_session('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190207','Y:\Projects\PhysiologicalRecording\Data\Cornelius\20190207',false,'sessionInfo',ses);

end % of switch session_path

end % of for each session
        



















