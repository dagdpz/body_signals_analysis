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
bsa_ecg_analyze_one_session.m savse mat-file for each session


See also also related packages: 

https://github.com/neuromethods/neural-firing-and-cardiac-cycle-duration

https://github.com/DamianoAzzalini/HER-preferences

http://marianux.github.io/ecg-kit/

https://python-heart-rate-analysis-toolkit.readthedocs.io/en/latest/index.html

https://sites.google.com/view/tallon-baudry-lab/resources?authuser=0
