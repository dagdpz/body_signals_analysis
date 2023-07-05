# body_signals_analysis

Analysis of body signals: ECG, breathing (CAP), PPG

How the different function are related to each other: 

1. extract the ECG, CAP, POX-data from each TDT block & save the structure as mat-file
bsa_batch_processing.m calls  bsa_read_and_save_TDT_data_without_behavior.m

2. Preprocessing

bsa_ecg_analyze_one_session.m calls 
        - bsa_concatenate_trials_body_signals.m
        - bsa_ecg_analyze_one_run.m

bsa_ecg_analyze_one_session.m loads the created mat-file from bsa_read_and_save_TDT_data_without_behavior.m
bsa_ecg_analyze_one_session.m save as mat-file for each session with the following outputs


See also: 
https://github.com/neuromethods/neural-firing-and-cardiac-cycle-duration
