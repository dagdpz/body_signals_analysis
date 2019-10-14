% settings for BSA analysis, Curius dPul/vPul inactivation - ECG, 2019
%Define different characteristics to identify different conditions
Set.task.Type       = 2; 
Set.task.reward     = 2; 
Set.task.mintrials  = 25;  %main task
Set.task2.Type     = 1;
Set.task.mintrials2 = 10; % task which are different from the main task
Set.rest.Type       = 1; 
Set.rest.reward     = [0 0]; 
Set.R2R_minValidData = 100; 
Set.OutlierModus = 0; 


Set.segment_length                  = 300; % s (Set to 0 if no segmentation) -- segment length prior to wavelet transform
Set.segment_overlap                 = 50;  % s

% Set for wavelet analysis
Set.wv_rangeOfInterest              = [1 12]; % Hz
Set.wv_scalesPerDecade              = 32;
% properties for the ECG R peak detection
Set.min_R2R                         = 0.25; % s
Set.eP_tc_minpeakheight_med_prop    = 0.5; % proportion of median of energyProfile_tc for minpeakheight (when periodic, task related movement noise, use ~0.33, otherwise 1)
Set.MAD_sensitivity_p2p_diff        = 3; % sensitivity factor for threshold caluclation -  larger value  more permissive (i.e. less outliers)
Set.minFactor_R2RMode              = 0.43; % exclude R2R intervals shorter than this factor multiplied with the mode R2R
Set.maxFactor_R2RMode               = 1.5;  % exclude R2R intervals longer than this factor multiplied with the mode R2R
Set.fraction_R2R_look4peak          = 0.05; % fraction of R2R interval to look for real R peak next to energy timecourse peak 
Set.hampel_T                        = 15 ; % threshold for hamplel outlier detection (larger means more permissive, less outliers)
Set.hampel_DX                       = 10; % (# R peaks) half width of hampel window for outlier detection


% properties for the respiration peak detection
Set.cap.min_P2P                         = 2; % s
Set.cap.eP_tc_minpeakheight_med_prop    = 1; % proportion of median of energyProfile_tc for minpeakheight (when periodic, task related movement noise, use ~0.33, otherwise 1)
Set.cap.MAD_sensitivity_p2p_diff        = 4; % sensitivity factor for threshold caluclation -  larger value -> less sensitive (i.e. less outliers)
Set.cap.fraction_R2R_look4peak          = 0.1; % fraction of R2R interval to look for real R peak next to energy timecourse peak 
Set.cap.hampel_T                        = 15 ; % threshold for hamplel outlier detection (larger means more permissive, less outliers)
Set.cap.hampel_DX                       = 10; % (# R peaks) half width of hampel window for outlier detection

Set.R2R_minValidData = 100; 
