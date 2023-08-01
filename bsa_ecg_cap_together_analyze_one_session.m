function [out_ecg,out_cap] = bsa_ecg_cap_together_analyze_one_session(session_path, pathExcel, settings_filename)
% bsa_ecg_cap_together_analyze_one_session passes data paths to 
% bsa_ecg_analyze_one_session and bsa_respiration_analyze_one_session.
%
% USAGE:
% out = bsa_respiration_analyze_one_session('Y:\Data\Curius_phys_combined_monkeypsych_TDT\20190625','Y:\Logs\Inactivation\Curius\Curius_Inactivation_log_since201905.xlsx','bsa_settings_Curius2019.m','Y:\Projects\PhysiologicalRecording\Data\Curius\20190625');
% out = bsa_respiration_analyze_one_session(session_path,'',false,'dataOrigin','TDT','sessionInfo',ses);
%
% INPUTS:
%		session_path		- Path to session data
%       pathExcel           - excel file
%       settings_filename   - name of the mfile with specific session/monkey settings
%		varargin (optional) - see % define default arguments and their potential values
%
% OUTPUTS:
%		out                 - see struct

run(settings_filename)

currDate = session_path(end-7:end);

Set.path.ecg_save = ...
    [Set.path.ecg_save filesep currDate filesep];
Set.path.cap_save = ...
    [Set.path.cap_save filesep currDate filesep];
Set.path.ecg_cap_save = ...
    [Set.path.ecg_cap_save filesep];

out_ecg = bsa_ecg_analyze_one_session(session_path, pathExcel,settings_filename, Set.path.ecg_save);

out_cap = bsa_respiration_analyze_one_session(session_path, pathExcel, settings_filename, Set.path.cap_save);

for blockNum = 1:length(out_ecg)

    % preallocate for R peaks in inspiration and expiration
    is_R_peak_insp = zeros(length(out_ecg(blockNum).Rpeak_sample),1);
    is_R_peak_exp = zeros(length(out_ecg(blockNum).Rpeak_sample),1);
    
    is_RR_insp = zeros(length(out_ecg(blockNum).R2R_sample),1);
    is_RR_exp = zeros(length(out_ecg(blockNum).R2R_sample),1);
    
    for currBreath = 1:length(out_cap(blockNum).inspStart_t)
        
        % check if R-peaks belong to a given inspiration / expiration phase
        currInspRpeakIds = ...
            out_ecg(blockNum).Rpeak_t > out_cap(blockNum).inspStart_t(currBreath) & ...
            out_ecg(blockNum).Rpeak_t < out_cap(blockNum).inspEnd_t(currBreath);
        currExpRpeakIds = ...
            out_ecg(blockNum).Rpeak_t > out_cap(blockNum).expStart_t(currBreath) & ...
            out_ecg(blockNum).Rpeak_t < out_cap(blockNum).expEnd_t(currBreath);
        
        is_R_peak_insp(currInspRpeakIds) = true;
        is_R_peak_exp(currExpRpeakIds) = true;
        
    end
    
    if ~isempty(out_ecg(blockNum))
        out_ecg(blockNum).is_R_peak_insp          = is_R_peak_insp;
        out_ecg(blockNum).is_R_peak_exp           = is_R_peak_exp;
    else
        out_ecg(blockNum).is_R_peak_insp          = [];
        out_ecg(blockNum).is_R_peak_exp           = [];
    end
    
    save([Set.path.ecg_cap_save currDate '_ecg_cap.mat'], 'out_ecg', 'out_cap')
end
end