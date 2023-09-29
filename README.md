# body_signals_analysis

Analysis of body signals: ECG, breathing (CAP), PPG

How the different function are related to each other: 

1. extract the ECG, CAP, POX-data from each TDT block & save the structure as mat-file
bsa_batch_processing.m calls  bsa_read_and_save_TDT_data_without_behavior.m

2. Preprocessing

bsa_ecg_analyze_one_session.m calls 
        - bsa_concatenate_trials_body_signals.m
        - bsa_ecg_analyze_one_run.m

bsa_ecg_analyze_one_session.m loads created mat-file from bsa_read_and_save_TDT_data_without_behavior.m
bsa_ecg_analyze_one_session.m saves mat-file for each session

## out structure conventions
```
load('Y:\Data\BodySignals\ECG\Magnus\20230531\20230531_ecg.mat'); % example file
ig_add_multiple_vertical_lines(out(1).Rpeak_t,'Color','r'); % all valid R-peaks
ig_add_multiple_vertical_lines(out(1).R2R_t,'Color','b','LineStyle',':'); % all valid R2R intervals (time corresponds to 2nd R-peak in a pair)
hold on; plot(out(1).R2R_t(out(1).idx_valid_R2R_consec),0.5,'go'); % consequtive R2R intervals (i.e. preceeded by a valid interval) 
% [valid_segment_start, valid_segment_start_idx]  = setdiff(out(1).Rpeak_t,out(1).R2R_t);
% plot(valid_segment_start(2:end),0.5,'mv'); % valid segment start
plot(out(1).R2R_t(out(1).idx_valid_R2R_consec - 1),0.5,'bv'); % take only those as good trigger points, because they are preceeded and followed by valid R2R interval

```
![image](https://github.com/dagdpz/body_signals_analysis/assets/9905148/e5de8abc-d0df-46a3-91db-333102992067)


## See also also related packages: 

https://github.com/neuromethods/neural-firing-and-cardiac-cycle-duration

https://github.com/DamianoAzzalini/HER-preferences

http://marianux.github.io/ecg-kit/

https://python-heart-rate-analysis-toolkit.readthedocs.io/en/latest/index.html

https://sites.google.com/view/tallon-baudry-lab/resources?authuser=0

https://github.com/hooman650/BioSigKit - detection of T- and P-waves in human ECG; the paper: https://joss.theoj.org/papers/10.21105/joss.00671

