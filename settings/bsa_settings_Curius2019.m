% settings for BSA analysis, Cornelius dPul/vPul inactivation - ECG, 2019



% properties for the ECG detection
min_R2R                         = 0.25; % s
eP_tc_minpeakheight_med_prop    = 0.33; % proportion of median of energyProfile_tc for minpeakheight (when periodic, task related movement noise, use ~0.33, otherwise 1)
MAD_sensitivity_p2p_diff        = 3;
hampel_T                        = 4; % threshold for hamplel outlier detection
segment_length                  = 300; % s (set to 0 if no segmentation) -- segment signal prior to wavelet transform
segment_overlap                 = 50;  % s 
minFactor_RS2Mode = 0.66; 
maxFactor_RS2Mode  = 1.5; 

rangeOfInterest = [1 12]; % Hz
% prepare parameters for the wavelet transform: we expect our heart rate to be in certain range
minFreq = rangeOfInterest(1);
maxFreq = rangeOfInterest(2);
scalesPerDecade = 32;
