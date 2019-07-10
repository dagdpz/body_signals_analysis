% settings for BSA analysis, Curius dPul/vPul inactivation - ECG, 2019



set.segment_length                  = 300; % s (set to 0 if no segmentation) -- segment length prior to wavelet transform
set.segment_overlap                 = 50;  % s

% set for wavelet analysis
set.wv_rangeOfInterest              = [1 12]; % Hz
set.wv_scalesPerDecade              = 32;

% properties for the ECG R peak detection
set.min_R2R                         = 0.25; % s
set.eP_tc_minpeakheight_med_prop    = 0.33; % proportion of median of energyProfile_tc for minpeakheight (when periodic, task related movement noise, use ~0.33, otherwise 1)
set.MAD_sensitivity_p2p_diff        = 3; % sensitivity factor for threshold caluclation -  larger value -> less sensitive (i.e. less outliers)
set.minFactor_R2RMode               = 0.66; % exclude R2R intervals shorter than this
set.maxFactor_R2RMode               = 3;  % exclude R2R intervals longer than this
set.fraction_R2R_look4peak          = 0.05; % fraction of R2R interval to look for real R peak next to energy timecourse peak 
set.hampel_T                        = 4; % threshold for hamplel outlier detection
set.hampel_DX                       = 10; % (# R peaks) half width of hampel window for outlier detection




