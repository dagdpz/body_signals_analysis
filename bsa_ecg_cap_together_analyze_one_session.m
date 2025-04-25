function [out,out_cap] = bsa_ecg_cap_together_analyze_one_session(session_path, pathExcel, settings_filename)
% BSA_ECG_CAP_TOGETHER_ANALYZE_ONE_SESSION performs ECG and respiration
% analysis for a single session by combining outputs from separate analysis functions.
%
% INPUTS:
%   session_path        - Path to the session data directory
%   pathExcel           - Path to Excel file with session metadata (e.g. log)
%   settings_filename   - Name of the .m file with monkey/session-specific settings
%
% OUTPUTS:
%   out                 - ECG analysis results (struct array)
%   out_cap             - Respiration (CAP) analysis results (struct array)

% Get the full path of this script and use it to build the settings path
mfullpath = mfilename('fullpath');
mpathname = fileparts(mfullpath);
settings_path = [mpathname filesep 'settings' filesep settings_filename];

% Run the settings file to load configuration (assumes the settings file defines 'Set')
run(settings_path);

% Extract date string from session path (assumes folder ends with 'yyyymmdd')
currDate = session_path(end-7:end);

% Update output save paths with the current session date
Set.path.ecg_save     = [Set.path.ecg_save filesep currDate filesep];
Set.path.cap_save     = [Set.path.cap_save filesep currDate filesep];
Set.path.ecg_cap_save = [Set.path.ecg_cap_save filesep];

%   filePattern = fullfile(Set.path.cap_save, [currDate '_cap.mat']);
%   matchingFiles_cap = dir(filePattern);
%   load([Set.path.cap_save , matchingFiles_cap.name])
% % Run respiration (CAP) analysis
%  if isempty(matchingFiles_cap)
out_cap = bsa_respiration_analyze_one_session(session_path, pathExcel, settings_filename, Set.path.cap_save);
%end
%% ECG file
filePattern = fullfile(Set.path.ecg_save, [currDate 'OverTime_ecg.mat']); %OverTime_ecg
matchingFiles_OverTime_ecg = dir(filePattern);
if ~isempty(matchingFiles_OverTime_ecg)
load([Set.path.ecg_save , matchingFiles_OverTime_ecg.name])

elseif isempty(matchingFiles_OverTime_ecg)
    % Run ECG analysis using a version that includes PoinCare plot features
    out = bsa_ecg_analyze_one_session_NEW_PoinCarePlot(session_path, pathExcel, settings_filename, Set.path.ecg_save);
end

%% Inhalation and exhalation
% Iterate over all blocks of ECG data
for blockNum = [out.nrblock]
        disp(blockNum);

    if ~isempty(blockNum)
    % Preallocate logical arrays to mark R-peaks and RR intervals in inspiratory/expiratory phases
    is_R_peak_insp = zeros(length(out(blockNum).Rpeak_sample), 1);
    is_R_peak_exp  = zeros(length(out(blockNum).Rpeak_sample), 1);
    
    is_RR_insp = zeros(length(out(blockNum).R2R_sample), 1);
    is_RR_exp  = zeros(length(out(blockNum).R2R_sample), 1);
    
    % Loop through each respiratory cycle (inspiration and expiration)
    for currBreath = 1:length(out_cap(blockNum).inspStart_t)
        
        
        % Identify RR intervals that start during inspiration
        idxRpeakInsp = ...
            out(blockNum).R2R_t >= out_cap(blockNum).inspStart_t(currBreath) & ...
            out(blockNum).R2R_t <= out_cap(blockNum).inspEnd_t(currBreath);
        
        % Identify RR intervals that start during expiration
        idxRpeakExp = ...
            out(blockNum).R2R_t >= out_cap(blockNum).expStart_t(currBreath) & ...
            out(blockNum).R2R_t <= out_cap(blockNum).expEnd_t(currBreath);
        
        % Mark corresponding RR intervals
        is_R_peak_insp(idxRpeakInsp) = true;
        is_R_peak_exp(idxRpeakExp) = true;
        is_RR_insp(idxRpeakInsp) = true;
        is_RR_exp(idxRpeakExp) = true;
        
        if ~any(idxRpeakInsp) || ~any(idxRpeakExp)
            continue
        else
            
            % P2T RSA: max RR during expiration - min RR during inspiration
            maxRR_exp(currBreath)  = max( out(blockNum).R2R_t(idxRpeakExp));
            minRR_insp(currBreath) = min( out(blockNum).R2R_t(idxRpeakInsp));
            minHR_insp(currBreath) = 60 ./ minRR_insp(currBreath);  % max HR during inspiration
            maxHR_exp(currBreath)  = 60 ./ maxRR_exp(currBreath);   % min HR during expiration
            
            %for each breath gives you a cycle-by-cycle estimate of RSA amplitude.
            RSA_P2T(currBreath) = maxRR_exp(currBreath) - minRR_insp(currBreath);  % units: seconds (s)
        end
    end
    
if ~isempty(RSA_P2T)
mean_rsa_p2t    = nanmean(RSA_P2T);
sd_rsa_p2t      = nanstd(RSA_P2T);
RSA_P2T_z       = (RSA_P2T - mean_rsa_p2t) / sd_rsa_p2t;
end


    % Assign results to output struct for the current block
    if ~isempty(out(blockNum))
        out(blockNum).is_R_peak_insp = logical(is_R_peak_insp);
        out(blockNum).is_R_peak_exp  = logical(is_R_peak_exp);
        out(blockNum).is_RR_insp     = logical(is_RR_insp);
        out(blockNum).is_RR_exp      = logical(is_RR_exp);
        out(blockNum).maxRR_exp    = maxRR_exp;
        out(blockNum).minRR_insp   = minRR_insp;
        out(blockNum).minHR_insp   = minHR_insp;
        out(blockNum).maxHR_exp    = maxHR_exp;
        out(blockNum).RSA_P2T      = RSA_P2T;
        out(blockNum).RSA_P2T_z      = RSA_P2T_z;
      
        
    else
        out(blockNum).is_R_peak_insp      = [];
        out(blockNum).is_R_peak_exp       = [];
        out(blockNum).is_RR_interval_insp = [];
        out(blockNum).is_RR_interval_exp  = [];
        
        out(blockNum).maxRR_exp    = [];
        out(blockNum).minRR_insp   = [];
        out(blockNum).minHR_insp   = [];
        out(blockNum).maxHR_exp    = [];
        out(blockNum).RSA_P2T      = [];
        out(blockNum).RSA_P2T_z      = [];
        
    end
    
    % Save combined ECG and CAP output for the session
    if ~isempty(matchingFiles_OverTime_ecg)
        save([Set.path.ecg_cap_save currDate '_ecg_cap.mat'], 'out', 'out_cap', 'ses')
    else
        save([Set.path.ecg_cap_save currDate '_ecg_cap.mat'], 'out', 'out_cap')
    end
    end
end
end