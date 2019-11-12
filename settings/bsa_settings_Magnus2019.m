% settings for BSA analysis, Cornelius dPul/vPul inactivation - ECG, 2019
Set.task.Type       = 2; 
Set.task.reward     = 2; 
Set.task.mintrials  = 25;  %main task
Set.task2.Type     = 1;
Set.task.mintrials2 = 10; % task which are different from the main task
Set.rest.Type       = 1; 
Set.rest.reward     = [0 0]; 


Set.OutlierModus = 0; 

Set.segment_length                  = 300; % s (Set to 0 if no segmentation) -- segment length prior to wavelet transform
Set.segment_overlap                 = 50;  % s

% Set for wavelet analysis
Set.wv_rangeOfInterest              = [1 12]; % Hz
Set.wv_scalesPerDecade              = 32;

% properties for the ECG R peak detection
Set.min_R2R                         = 0.25; % s
Set.eP_tc_minpeakheight_med_prop    = 0; % proportion of median of energyProfile_tc for minpeakheight (when periodic, task related movement noise, use ~0.33, otherwise 1)
Set.MAD_sensitivity_p2p_diff        = 3; % sensitivity factor for threshold caluclation -  larger value -> less sensitive (i.e. less outliers)
Set.minFactor_R2RMode               = 0.5; % exclude R2R intervals shorter than this
Set.maxFactor_R2RMode               = 1.5;  % exclude R2R intervals longer than this
Set.fraction_R2R_look4peak          = 0.05; % fraction of R2R interval to look for real R peak next to energy timecourse peak 
Set.hampel_T                        = 6; % threshold for hamplel outlier detection
Set.hampel_DX                       = 10; % (# R peaks) half width of hampel window for outlier detection

Set.R2R_minValidData = 100; 



