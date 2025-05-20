function [out,Tab_outlier] = bsa_respiration_analyze_one_run(capSignal,settings_path,Fs,TOPLOT,i_block,NrBlock,FigInfo)
%bsa_respiration_analyze_one_run  - analyses ECG in one run/block
%
% USAGE:
% out = bsa_respiration_analyze_one_run(capSignal,settings_path,Fs,1,sprintf('block%02d',r));
%
% INPUTS:
%		capSignal		- ECG
%       settings_path   - full path to mfile with specific session/monkey settings
%		Fs              - sampling rate (Hz)
%       TOPLOT          - plot figure
%       FigInfo         - info for figure
%
% OUTPUTS:
%		out             - see structure
%
% REQUIRES:	Igtools
% needs MATLAB 2014 or later for wavelet toolbox!
%
% See also BSA_ECG_ANALYZE_ONE_SESSION
%
%
% Author(s):	I.Kagan, DAG, DPZ
% URL:		http://www.dpz.eu/dag
%
% Change log:
% 20190226:	Created function (Igor Kagan)
% ...
% $Revision: 1.0 $  $Date: 2019-02-26 14:11:47 $

% ADDITIONAL INFO:
% CAREFUL - the function filtfilt has the same name in the fieldtrip toolbox
%
% https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0140783
% https://github.com/fieldtrip/fieldtrip/blob/master/ft_heartrate.m

% filtering according to https://de.mathworks.com/matlabcentral/answers/270238-how-can-i-filter-ecg-signals-with-high-motion-artifact
% (or see also https://de.mathworks.com/matlabcentral/answers/364788-ecg-signal-artifact-removing)
%%%%%%%%%%%%%%%%%%%%%%%%%[DAG mfile header version 1]%%%%%%%%%%%%%%%%%%%%%%%%%


%{
[remove "{" above to run it for debugging specific blocks]
load('bodysignals_wo_behavior.mat');
Fs = double(dat.ECG_SR);
capSignal = double(dat.ECG{5});
%}


if nargin < 3
    TOPLOT = true;
end


if nargin < 4
    FigInfo = '';
end

run(settings_path)


n_samples       = length(capSignal);
t               = 0:1/Fs:1/Fs*(n_samples-1); % time axis  -> IMPORTANT: first sample is time 0! (not 1/Fs)
B2B_valid =[];
out.hf = [];
% replace your "Tab_outlier = [];" with this full struct init:
Tab_outlier = struct( ...
    'outlier',                   [], ...
    'NrRpeaks_orig',             [], ...
    'outlier_Mode_abs',          [], ...
    'outlier_Mode_pct',          [], ...
    'NrB2B_beforehampel',        [], ...
    'outliers_hampel_abs',       [], ...
    'outliers_delete_abs',       [], ...
    'outliers_hampel_pct',       [], ...
    'NrPeaks_valid',             [], ...
    'NrB2B_valid',               [], ...
    'outliers_all_abs',          [], ...
    'outliers_all_pct',          [], ...
    'median_duration_insp',      [], ...
    'median_duration_exp',       [], ...
    'numSkippedInspSegments',    [], ...
    'skippedInspTimes',          [], ...
    'skippedInspDurations',      [], ...
    'numValidPeaksNoInspEnd',    [], ...
    'validPeaksNoInspEndTimes',  [], ...
    'numValidInsp',              [], ...
    'totalCandidatesInsp',       [], ...
    'numInvalidInsp',            [], ...
    'numInvalidExp',             [], ...
    'B2B_consec',                [], ...
    'durationRun_s',             [], ...
    'duration_NotValidSegments_s',[], ...
    'nrblock',                   [], ...
    'nrblock_combinedFiles',     []  ...
    );

% Step 1: flip cap signal if it's negative, leave the same if it's above zero
% This will keep the signal the same after swapping connectors between TDT
% and capnographic monitor (done by Luba in June 2023)
if median(capSignal) > 0
    % do nothing to the signal
else
    capSignal = (-1)*capSignal;
end

%% KK1 - remove (assign to zero) invalid periods that might have low amplitude fluctuations are not real breathing pattern
% that have some low amplitude fluctuations for the duration of at least min_duration_low seconds
signal_top_percentile = 5; % percent of signal length to calculate amplitude
fraction_of_top_percentile = 0.2; % fraction of top percentile to use as threshold
min_duration_low = 5; % seconds

sortedAbs = sort(abs(capSignal), 'descend'); % Sort by magnitude
nTop = round(0.01*signal_top_percentile * length(sortedAbs));
topPercentile = sortedAbs(1:nTop);

threshold = fraction_of_top_percentile*median(topPercentile);
belowThreshold = abs(capSignal) < threshold;

minDurationSamples = min_duration_low * Fs;

% Vectorized version:
% 1. Create a binary mask for regions below threshold
belowThreshold = abs(capSignal) < threshold;

% 2. Use regionprops to get the lengths of continuous regions
stats = regionprops(belowThreshold, 'Area', 'PixelIdxList');

% 3. Create a mask for regions that are long enough
longEnoughMask = [stats.Area] >= minDurationSamples;

% 4. Get all indices that need to be zeroed out
indicesToZero = vertcat(stats(longEnoughMask).PixelIdxList);

% 5. Zero out the signal in one operation
capSignalRemoved = capSignal;
capSignalRemoved(indicesToZero) = 0;

if median(capSignalRemoved) > 0.15 %KK2 - blocks below this criteria are completly removed from analyses
    %% Smoothing
    Set.cap.smoothing_window = 0.3;
    capFiltered = smooth(capSignalRemoved, round(Set.cap.smoothing_window*Fs))'; % increase smoothing window to .25s; doesn't affect peak detection but is needed for further inspiration / expiration classification
    capFilteredFilled = filloutliers(capFiltered, 'linear', 'movmedian', 1000);
    %windowDuration = 1000 / Fs;
    %capFiltered2 = smoothdata(capSignal, 'sgolay', 1000);
    % any(isnan(capFilteredFilled))
    % figure; hold on;
    % plot(t, capSignal, 'k', 'DisplayName', 'Original Signal');
    % plot(t, capSignalRemoved, 'r', 'DisplayName', 'Smoothed Signal');
    % plot(t, capFilteredFilled, 'b', 'DisplayName', 'Smoothed sgolay');
    % legend;
    % xlabel('Time (s)');
    
    % % problem with saturation in the signal (e.g., signal stuck at 0 for a while)
    % % signalMin = min(capFilteredFilled);
    % % signalRange = range(capFilteredFilled);
    % %
    % % Define threshold close to minimum but not exactly min
    % % flatThreshold = signalMin + 0.01 * signalRange;
    % % flatIdx = capFilteredFilled < flatThreshold;
    % % sum(flatIdx)
    % % capFilteredFilled(flatIdx) = NaN;
    % %
    % % sum(isnan(capFilteredFilled(:)))
    %%
    if 0 % Debug
        figure('Name','Single-sided amplitude spectrum');
        ft_original = fft(capSignal)/n_samples;         % Fourier Transform
        Fv = linspace(0, 1, fix(n_samples/2)+1)*Fn;     % Frequency Vector
        Fv = Fv(Fv<60); % limit to 60 Hz
        
        ft_filtered = fft(ecgFiltered)/n_samples;
        
        plot(Fv, abs(ft_original(1:length(Fv)))*2,'b'); hold on
        plot(Fv, abs(ft_filtered(1:length(Fv)))*2,'g');
        
        grid
        xlabel('Frequency');
        ylabel('Amplitude');
        title('Single-sided amplitude spectrum');
    end
    
    
    %% full  rectification
    % %% Full Rectification of Capnogram Signal
    % The signal is fully rectified using the `ig_fullrectify` function.
    % This ensures all values are positive, making it easier to detect inspiratory phases.
    % capFiltered_rectified = ig_fullrectify(capFilteredFilled); %Luba - why???
    capFiltered_rectified = capFilteredFilled; % IK workaround
    
    %% Detecting Remainders of Inspiration
    % According to Singh, Howe, and Malarvili (2018, J. Breath Res.), inspiration phases
    % are characterized by negative deflections with plateaus in the capnogram.
    
    % Find the mode (most frequently occurring value) of the rectified signal.
    % Flat portions of inspiration are expected to be near this mode.
    cap_mode = mode(capFiltered_rectified);
    %cap_mode = median(capFiltered_rectified);
    
    % Compute the fraction of data points below the mode.
    fractionBelowMode = sum(capFiltered_rectified < cap_mode) / length(capFiltered_rectified);
    
    % If more than 50% of the data points are below the mode, use this fraction directly.
    % Otherwise, double it to emphasize inspiration segments.
    if fractionBelowMode > 0.5 % for meaningful data this parameter will be below 0.5
        fraction_of_inspiration = sum(capFiltered_rectified < cap_mode) / length(capFiltered_rectified);
    else
        fraction_of_inspiration = 2 * sum(capFiltered_rectified < cap_mode) / length(capFiltered_rectified); % find data points below the mode, they are supposed to be inspiration for sure, double them
    end
    
    % Define an inspiration threshold based on the computed fraction.
    % This sets a cut-off below which points are considered part of inspiration.
    inspiration_threshold = prctile(capFiltered_rectified, 100*fraction_of_inspiration);
    %inspiration_threshold = prctile(capFiltered_rectified, 10); % 5th percentile
    
    insp_idx = find(capFiltered_rectified < inspiration_threshold); %% Identify indices of inspiration points (values below the threshold).
    
    %% PREVIOUS VERSION - too simplistic
    %Find the end points of inspiration phases by detecting large gaps (>500 samples).
    insp_end_idx = find(diff(insp_idx)>500);
    % Extract the corresponding times of inspiration end points.
    % These indicate the start of expiration.
    insp_end_t = t(insp_idx(insp_end_idx));
    % Extract signal values at inspiration end points.
    insp_end_sample = capFiltered_rectified(insp_idx(insp_end_idx)); % sample of inspiration ends (the same as expiration starts)
    
    
    
    
    %% PLot the detected inspiration
    % figure; hold on;
    % plot(t, capFiltered, 'b', 'DisplayName', 'Original Signal'); % Raw capnogram
    % plot(t, capFiltered_rectified, 'k', 'DisplayName', 'Rectified Signal'); % Rectified
    % yline(inspiration_threshold, 'r--', 'DisplayName', 'Inspiration Threshold'); % Threshold line
    % scatter(t(insp_idx), capFiltered_rectified(insp_idx), 'g', 'filled', 'DisplayName', 'Detected Inspiration'); % Inspiration points
    % scatter(insp_end_t, capFiltered_rectified(insp_idx(insp_end_idx)), 'bo', 'filled','DisplayName', 'Improved Inhalation End');
    
    
    %% Peak Detection for Expiratory Phases
    % Define the minimum peak prominence based on the median of the rectified signal.
    % This helps filter out small fluctuations and retain significant expiratory peaks.
    
    MinPeakProminence = nanmedian(capFiltered_rectified)* Set.cap.MinPeakProminenceCoef;
    % % Find peaks in the capnogram using three criteria:
    % 1) amplitude of the previous & next minimum
    % 2) Distance between two peaks - required in samples
    % 3) Min Peak height
    [pks,locs_peak]=findpeaks(capFiltered_rectified, ...
        'MinPeakProminence',MinPeakProminence, ...
        'minpeakdistance',fix(Set.cap.min_P2P*Fs), ...
        'minpeakheight',Set.cap.eP_tc_minpeakheight_med_prop*nanmedian(capFiltered_rectified));
    
    
    % find peaks which are next to each other without a minimum
    % locs = [locs_min, locs_peak];
    % locs = sort(locs);
    % [C, il,ilp] = intersect(locs,locs_peak );
    % idx = locs(il(diff(il) == 1)); %shifted!!
    
    % --- Step 2: Estimate min_P2P from initial detections ---
    p2p_intervals_sec = diff(locs_peak) / Fs;
    
    min_peak_height = min(pks);
    max_peak_height = max(pks);
    mean_peak_height = mean(pks);
    %remove peaks which
    %criterium = 'SmallDifference';
    %[data_wo_outliers_p2m,idx_wo_outliers_p2m,outliers_p2m,idx_outliers,thresholdValue_p2m] = bsa_remove_outliers(height_peaks,Set.cap.MAD_sensitivity_p2m_diff,criterium);
    
    % Compute difference between consecutive peak amplitudes
    % Start with 0 so length matches pks
    diff_peaks = [0 abs(diff(pks))];
    
    % Remove outliers based on large amplitude jumps using MAD (Median Absolute Deviation)
    [data_wo_outliers,idx_wo_outliers,outliers,idx_outliers,thresholdValue] = bsa_remove_outliers(diff_peaks,Set.cap.MAD_sensitivity_p2p_diff);
    
    Tab_outlier.outlier = length(idx_outliers);
    Tab_outlier.NrRpeaks_orig       = length(pks);
    
    
    % Estimate the typical (mode) peak-to-peak interval (in samples)
    % using peaks that passed the amplitude difference filter
    appr_cap_peak2peak_n_samples = mode(abs(diff(locs_peak(idx_wo_outliers)))); % rough number of samples between peaks
    
    % Leave only positive values in capFiltered (e.g., ignore downward deflections)
    capFiltered_pos             = max(capFiltered_rectified,0);
    
    % 'threshold' minimum required height difference between a peak and its neighboring points — not the absolute height of the peak.
    % Only consider something a peak if it's at least eps higher than the adjacent samples.
    [~,pos_cap_locs]  = findpeaks(capFiltered_pos,...
        'MinPeakProminence',MinPeakProminence, ...
        'minpeakdistance',fix(Set.cap.min_P2P*Fs), ...
        'minpeakheight',Set.cap.eP_tc_minpeakheight_med_prop*median(capFiltered_pos));
    
    % --- Visualization: Compare peak locations ---
    % figure;
    % plot(t, capFiltered); hold on;
    % plot(t, capFiltered_rectified); hold on;
    % plot(t(pos_cap_locs), capFiltered_pos(pos_cap_locs), 'm^', 'MarkerSize', 8);
    % plot(t(locs_peak), capFiltered_pos(locs_peak), 'b^', 'MarkerSize', 8);
    
    
    % Initialize containers for matched and unmatched cap peaks % IK remove
    % search_segment_n_samples    = fix(appr_cap_peak2peak_n_samples* Set.cap.fraction_B2B_look4peak);
    % maybe_valid_pos_cap_locs    = [];
    % maybe_Invalid_pos_cap_locs    = [];Invalid_peak= []; Minsearch_ranges= [];Maxsearch_ranges= [];
    %
    % for p = 1:length(idx_wo_outliers)
    %
    %     %computed on locs_peak (filtered with idx_wo_outliers) contains your candidate peaks, based on first peak detection.
    %     peak_center = locs_peak(idx_wo_outliers(p));
    %     search_range = peak_center - search_segment_n_samples : peak_center + search_segment_n_samples;
    %     % Check if any cap peak was detected within the search window
    %     idx_overlap = intersect(pos_cap_locs, search_range);
    %
    %     if ~isempty(idx_overlap)
    %         % If overlap exists, store the matching cap peak (last one found in range)
    %         maybe_valid_pos_cap_locs = [maybe_valid_pos_cap_locs idx_overlap(end)];
    %     else
    %         % If no cap peak found in range, log it as invalid
    %         maybe_Invalid_pos_cap_locs = [maybe_Invalid_pos_cap_locs peak_center(end)];
    %         Minsearch_ranges = [Minsearch_ranges min(search_range)];
    %         Maxsearch_ranges = [Maxsearch_ranges max(search_range)];
    %
    %         Invalid_peak = [Invalid_peak, p];
    %     end
    %
    % end
    
    
    maybe_valid_pos_cap_locs = pos_cap_locs;
    
    %% Breathing to breathing intervals
    B2B             = [NaN diff(t(maybe_valid_pos_cap_locs))]; %NaN at the beginning → to keep the vector aligned with original indices
    % B2B             = [diff(t(maybe_valid_pos_cap_locs)) NaN]; %NaN at the beginning → to keep the vector aligned with original indices
    median_B2B      = nanmedian(B2B);
    mode_B2B        = mode(round(B2B,3));
    min_B2B         = min(B2B);
    [hist_B2B,bins] = hist(B2B,[Set.cap.min_P2P:0.1:5]);
    
    
    % invalidate all B2B less than minFactor_B2BMode (e.g. 0.66) of mode and more than maxFactor_B2BMode (e.g. 1.5) of mode
    % idx_valid_B2B         = find((B2B> Set.cap.minFactor_B2BMode*mode_B2B & B2B <  Set.cap.maxFactor_B2BMode *mode_B2B));
    if abs(min_B2B - mode_B2B) <= 0.2  %%KK3
        idx_Invalid_B2B       = find((B2B< Set.cap.minFactor_B2BMode*median_B2B | B2B >  Set.cap.maxFactor_B2BMode *median_B2B));
    else
        idx_Invalid_B2B       = find((B2B< Set.cap.minFactor_B2BMode*mode_B2B | B2B >  Set.cap.maxFactor_B2BMode *mode_B2B));
    end
    
    
    idx_Invalid_B2B       = [1 idx_Invalid_B2B idx_Invalid_B2B-1];
    idx_valid_B2B = setdiff(1:length(B2B),idx_Invalid_B2B);
    
    %% KK4: check each B2B interval for signal drops to add as Invalid_B2B interval which is not detected through the B2B threshold
    flatRangeThreshold = 0.005;  % Max range within flat window
    min_duration_low = 3; % seconds, minimum duration of flat region to be considered as invalid
    minFlatDurationSamples = round(min_duration_low * Fs);
    
    % Preallocate
    is_valid = true(size(idx_valid_B2B));
    idx_Invalid_B2B_FlatRegion = [];
    
    % Process each B2B interval
    for i = 1:length(idx_valid_B2B)
        idx = idx_valid_B2B(i);
        
        if idx >= length(maybe_valid_pos_cap_locs)
            continue;  % Skip last index
        end
        
        % Get segment
        t_start = t(maybe_valid_pos_cap_locs(idx));
        t_end = t(maybe_valid_pos_cap_locs(idx + 1));
        sample_start = max(1, round(t_start * Fs));
        sample_end = min(length(capSignal), round(t_end * Fs));
        segment = capSignal(sample_start:sample_end);
        
        % Find segments where max-min difference is below threshold
        % Using movmax and movmin to get sliding window statistics
        window_ranges = movmax(segment, minFlatDurationSamples) - movmin(segment, minFlatDurationSamples);
        
        % If any window has range below threshold, mark as invalid
        if any(window_ranges < flatRangeThreshold)
            is_valid(i) = false;
            idx_Invalid_B2B_FlatRegion = [idx_Invalid_B2B_FlatRegion, idx];
        end
    end
    
    if 0 % IK remove (KK version)
        windowSize = 100;  % Window size in samples (e.g., 50 ms)
        stepSize = 10;     % Step between sliding windows
        idx_Invalid_B2B_FlatRegion = [];
        is_valid = true(size(idx_valid_B2B));  % Assume all are valid
        
        for i = 1:length(idx_valid_B2B)
            idx =idx_valid_B2B(i);
            
            if idx >= length(maybe_valid_pos_cap_locs)
                continue;  % Skip last index (no next B2B interval)
            end
            
            % Time interval of this B2B
            t_start = t(maybe_valid_pos_cap_locs(idx));
            t_end   = t(maybe_valid_pos_cap_locs(idx + 1));
            
            % Sample indices
            sample_start = max(1, round(t_start * Fs));
            sample_end   = min(length(capSignal), round(t_end * Fs));
            
            segment = capSignal(sample_start:sample_end);
            segment_time = t(sample_start:sample_end);
            
            % Initialize flatness mask
            flatMask = false(1, length(segment));
            
            % Slide a window and mark flat regions
            for j = 1:stepSize:(length(segment) - windowSize + 1)
                window = segment(j : j + windowSize - 1);
                if max(window) - min(window) < flatRangeThreshold
                    flatMask(j : j + windowSize - 1) = true;
                end
            end
            
            % Analyze contiguous flat regions
            flatRegions = regionprops(flatMask, 'PixelIdxList');
            isFlatLongEnough = false;
            
            for r = 1:length(flatRegions)
                regionLength = length(flatRegions(r).PixelIdxList);
                if regionLength >= minFlatDurationSamples
                    isFlatLongEnough = true;
                    fprintf('Flat region detected in B2B #%d: %.2f seconds long\n', ...
                        idx, regionLength / Fs);
                    break;
                end
            end
            
            % Invalidate segment if flat region is long enough
            if isFlatLongEnough
                is_valid(i) = false;
                idx_Invalid_B2B_FlatRegion = [idx_Invalid_B2B_FlatRegion, idx];
                % Plot only the flat region(s) that triggered invalidation
                %     figure;
                %     plot(segment_time, segment, 'Color', [0.1 0.1 0.1]); % light background for full segment
                %     hold on;
                %     for r = 1:length(flatRegions)
                %         idxs = flatRegions(r).PixelIdxList;
                %         if length(idxs) >= minFlatDurationSamples
                %             plot(segment_time(idxs), segment(idxs), 'r', 'LineWidth', 2);  % highlight flat
                %         end
                %     end
                %
                %     title(sprintf('B2B Segment %d - INVALID (flat ≥ 3s)', i), 'Color', 'r');
                %     xlabel('Time (s)');
                %     ylabel('Signal Amplitude');
                %     grid on;
                
                
            end
        end
    end % of IK remove
    
    % idx_valid_B2B_filtered = idx_valid_B2B(is_valid);
    idx_all_Invalid_B2B = unique([idx_Invalid_B2B, idx_Invalid_B2B_FlatRegion]);
    idx_valid_B2B = setdiff(idx_valid_B2B, idx_all_Invalid_B2B);
    
    
    detectedOutliers_mode = (length(idx_Invalid_B2B)/length(B2B))*100;
    detectedOutlier2 = 100-((length(idx_valid_B2B)/length(B2B))*100);
    
   
    
    t_valid_B2B                         = t(maybe_valid_pos_cap_locs(idx_valid_B2B));
    B2B_valid_before_hampel             = B2B(idx_valid_B2B);
    Tab_outlier.NrB2B_beforehampel      = length(B2B_valid_before_hampel);
    
    %% remove outliers from B2B using hampel
    % DX	Window size — the number of neighbors on each side to consider
    %T	Threshold — how many scaled MADs (median absolute deviations) away from the local median a point must be to be considered an outlier
    % [YY,idx_outliers_hampel] = hampel(t_valid_B2B,B2B_valid_before_hampel, Set.cap.hampel_DX, Set.cap.hampel_T);
    
    idx_outliers_hampel = [];
    
    idx_to_delete = [];
    idx_to_delete_after_outliers = [];
    Tab_outlier.outliers_hampel_abs = sum(idx_outliers_hampel);
    
    if sum(idx_outliers_hampel), % there are outliers
        idx_outliers_hampel = find(idx_outliers_hampel); % convert to numbers
        
        for k = 1:length(idx_outliers_hampel),
            idx_to_delete = [idx_to_delete idx_outliers_hampel(k)];
            
            if idx_outliers_hampel(k)+1 <= length(idx_valid_B2B), % outlier not last B2B
                if t_valid_B2B(idx_outliers_hampel(k)+1) - t_valid_B2B(idx_outliers_hampel(k)) < 1.5*mode_B2B,
                    idx_to_delete = [idx_to_delete idx_outliers_hampel(k)+1];
                    idx_to_delete_after_outliers = [idx_to_delete_after_outliers idx_outliers_hampel(k)+1];
                    
                end
                
            end
            
        end
        idx_valid_B2B(idx_to_delete) = []; % delete outliers, and also next B2B after each outlier, if it is consecutive
        
    end
    
    
    Tab_outlier.outliers_delete_abs = length(idx_to_delete);
    Tab_outlier.outliers_hampel_pct = 100- (((length(idx_valid_B2B)+Tab_outlier.outlier_Mode_abs)/length(B2B))*100) ;
    
    %R-peaks
    idx_valid_R     = unique([idx_valid_B2B idx_valid_B2B-1]); % add start of each valid B2B interval to valid R peaks
    R_valid_locs    = maybe_valid_pos_cap_locs(idx_valid_R);
    %B2Binterval
    B2B_Invalid_locs  = maybe_valid_pos_cap_locs(idx_Invalid_B2B);
    B2B_valid_locs  = maybe_valid_pos_cap_locs(idx_valid_B2B);
    B2B_valid       = B2B(idx_valid_B2B);
    
    Tab_outlier.NrPeaks_valid      = length(R_valid_locs);
    Tab_outlier.NrB2B_valid         = length(B2B_valid);
    Tab_outlier.outliers_all_abs    = Tab_outlier.outliers_delete_abs  +   Tab_outlier.outlier_Mode_abs    + Tab_outlier.outlier;
    Tab_outlier.outliers_all_pct    = (Tab_outlier.outliers_all_abs/Tab_outlier.NrRpeaks_orig)*100;
    
    
    
    %% match P2P intervals and expiration / inspiration
    % Extract the time points of possible valid positive capnograph peaks
    validPeakTimes = t(R_valid_locs);
    
    
    t_valid_inspStart = nan(length(validPeakTimes), 1);
    t_valid_inspEnd = nan(length(validPeakTimes), 1);
    t_valid_expStart = nan(length(validPeakTimes), 1);
    t_valid_expEnd = nan(length(validPeakTimes), 1);
    duration_insp_valid = nan(length(validPeakTimes), 1);
    duration_exp_valid = nan(length(validPeakTimes), 1);
    
    % Initialize tracking for skipped inhalation segments
    skippedInspTimes = [];
    skippedInspDurations = [];
    noInspEndCount = 0;
    noInspEndTimes = [];
    % Loop through all possible valid peaks (except the last one)
    maxSegmentDuration = 1.5 * mode_B2B;
    
    
    % === Compute corrected inspiration end (trough) for each breath ===
    corrected_insp_end_t = nan(length(validPeakTimes) - 1, 1);
    corrected_insp_end_idx = nan(length(validPeakTimes) - 1, 1);
    
    for ii = 1:length(validPeakTimes)-1
        currPeakTime = validPeakTimes(ii);
        nextPeakTime = validPeakTimes(ii + 1);
        
        % Get signal region between the two peaks
        segment_idx = find(t >= currPeakTime & t <= nextPeakTime);
        
        % Find the local minimum (trough)
        [~, localMinIdx_rel] = min(capFiltered_rectified(segment_idx));
        localMinIdx_abs = segment_idx(localMinIdx_rel);
        estimatedInspEnd = t(localMinIdx_abs);
        
        % Store in new vectors
        corrected_insp_end_t(ii) = estimatedInspEnd;
        corrected_insp_end_idx(ii) = localMinIdx_abs;
    end
    for ii = 1:length(validPeakTimes)-1 % loop through peaks
        
        currPeakTime = validPeakTimes(ii);
        nextPeakTime = validPeakTimes(ii+1);
        
        
        %% adapt the insp_end_t that they are the minimum = independent of the threshold
        
        % Find the first inspiration end that occurs after the current peak
        nextInspEndId = find(corrected_insp_end_t > currPeakTime & corrected_insp_end_t < nextPeakTime, 1, 'first');
        % If a valid inspiration end is found
        if ~isempty(nextInspEndId)
            inspEndTime = corrected_insp_end_t(nextInspEndId);
            durationExp  =  nextPeakTime - inspEndTime;
            durationInsp  =  inspEndTime - currPeakTime ;
            
            % Sanity check: valid durations
            if durationInsp > Set.cap.min_P2P / 3 && ...
                    durationExp > Set.cap.min_P2P / 3 && ...
                    durationInsp < 1.5 * mode_B2B && ...
                    durationExp < 2 * mode_B2B
                
                
                %             t_valid_expStart(ii)  = currPeakTime;
                %             t_valid_expEnd(ii)    = inspEndTime;
                %             t_valid_inspStart(ii) = inspEndTime;  % inspiration starts here
                %             t_valid_inspEnd(ii)   = nextPeakTime;
                
                t_valid_inspStart(ii)   = currPeakTime;
                t_valid_inspEnd(ii)     = corrected_insp_end_t(nextInspEndId);
                t_valid_expStart(ii)    = corrected_insp_end_t(nextInspEndId); %
                t_valid_expEnd(ii)      = nextPeakTime; % expiration end is next R-peak start
                
                %             t_valid_expEnd(ii)    = inspEndTime;
                
                duration_insp_valid(ii) = durationInsp;
                duration_exp_valid(ii) = durationExp;
                
            else
                % Log skipped segment
                skippedInspTimes(end+1) = currPeakTime;
                skippedInspDurations(end+1) = durationInsp;
            end
        else
            % No inspiration end found — log it
            noInspEndCount = noInspEndCount + 1;
            noInspEndTimes(end+1) = currPeakTime;
        end
        
    end
    
    % After the loop:
    Tab_outlier.median_duration_insp = nanmedian(duration_insp_valid);
    Tab_outlier.median_duration_exp = nanmedian(duration_exp_valid);
    IE_ratio = Tab_outlier.median_duration_insp / Tab_outlier.median_duration_exp;
    
    % After the loop:
    mean_duration_insp = nanmedian(duration_insp_valid);
    mean_duration_exp = nanmedian(duration_exp_valid);
    IE_ratio = mean_duration_insp / mean_duration_exp;
    
    Tab_outlier.numSkippedInspSegments = length(skippedInspTimes);
    Tab_outlier.skippedInspTimes = skippedInspTimes;
    Tab_outlier.skippedInspDurations = skippedInspDurations;
    
    Tab_outlier.numValidPeaksNoInspEnd = noInspEndCount;
    Tab_outlier.validPeaksNoInspEndTimes = noInspEndTimes;
    % Count valid inspiration starts (non-NaN)
    Tab_outlier.numValidInsp = sum(~isnan(t_valid_inspStart));
    
    % Count valid expiration starts (same as valid expirations, since they follow inspiration ends)
    numValidExp = sum(~isnan(t_valid_expStart));
    
    % Total possible (attempted) breaths
    Tab_outlier.totalCandidatesInsp = length(t_valid_inspStart);
    
    % Invalid ones are just the rest
    Tab_outlier.numInvalidInsp = Tab_outlier.totalCandidatesInsp - Tab_outlier.numValidInsp;
    Tab_outlier.numInvalidExp = Tab_outlier.totalCandidatesInsp - numValidExp;
    
    
    
    %% PLot the detected inspiration
    % figure; hold on;
    % plot(t, capFiltered, 'b', 'DisplayName', 'Original Signal'); % Raw capnogram
    % plot(t, capFiltered_rectified, 'k', 'DisplayName', 'Rectified Signal'); % Rectified
    % yline(inspiration_threshold, 'r--', 'DisplayName', 'Inspiration Threshold'); % Threshold line
    % scatter(t(insp_idx), capFiltered_rectified(insp_idx), 'g', 'filled', 'DisplayName', 'Detected Inspiration'); % Inspiration points
    % scatter(insp_end_t, capFiltered_rectified(insp_idx(insp_end_idx)), 'bo', 'filled','DisplayName', 'Improved Inhalation End');
    %
    % % --- Inhalation Segment Points (blue circles) ---
    % for i = 1:length(t_valid_inspStart)
    %     segIdx = find(t >= t_valid_inspStart(i) & t <= t_valid_inspEnd(i));
    %
    %     t_seg = t(segIdx);
    %     y_seg = capFiltered_rectified(segIdx);
    %
    %     if ~isempty(t_seg) && ~isempty(y_seg)
    %         scatter(t_seg(:), y_seg(:), 15, 'b', 'filled'); % Ensure column vectors
    %     end
    % end
    
    
    %%  CALCULATE VARIABLES
    %% amplitude of the peak
    [minimum,locs_min]=findpeaks(-capFiltered,'threshold',eps,'minpeakdistance',fix(Set.cap.min_P2P*Fs),'minpeakheight',Set.cap.eP_tc_minpeakheight_med_prop*median(capFiltered));
    minimum                         = capFiltered(locs_min);
    %height_peaks = abs(minimum)+pks(idx_wo_outliers);
    
    %
    median_B2B_valid        = nanmedian(B2B_valid);
    mode_B2B_valid          = mode(round(B2B_valid,3));
    min_B2B_valid          = min(B2B_valid);
    
    [hist_B2B_valid,bins]   = hist(B2B_valid,[Set.cap.min_P2P:0.1:5]);
    
    B2B_valid_bpm           = 60./B2B_valid;
    B2B_valid_ms            = 1000.*B2B_valid;% sec -> ms
    mean_B2B_valid_bpm      = mean(B2B_valid_bpm);
    median_B2B_valid_bpm    = median(B2B_valid_bpm);
    std_B2B_valid_bpm       = std(B2B_valid_bpm);
    std_B2B_valid_ms        = std(B2B_valid_ms);
    
    
    % find consecutive B2Bs
    if min_B2B_valid == mode_B2B_valid
        idx_valid_B2B_consec = find([NaN diff(t(B2B_valid_locs))]< Set.cap.maxFactor_B2BMode * median_B2B_valid);
    else
        idx_valid_B2B_consec = find([NaN diff(t(B2B_valid_locs))]< Set.cap.maxFactor_B2BMode * mode_B2B_valid);
    end
    B2B_valid_bpm_consec = B2B_valid_bpm(idx_valid_B2B_consec);
    Tab_outlier.B2B_consec = numel(idx_valid_B2B_consec);
    
    % RMSSD ("root mean square of successive differences")
    % the square root of the mean of the squares of the successive differences between ***adjacent*** intervals
    B2B_diff = diff(B2B_valid);
    B2B_bpm_diff = diff(B2B_valid_bpm);
    
    rmssd_B2B_valid_bpm     = sqrt(mean(B2B_bpm_diff(idx_valid_B2B_consec-1).^2));
    rmssd_B2B_valid_ms      = sqrt(mean((1000*B2B_diff(idx_valid_B2B_consec-1)).^2));
    
    B2B_valid_spectrum = false;
    if length(B2B_valid_locs)>1
        B2B_valid_spectrum = true;
        % BPS spectrum
        % https://de.mathworks.com/matlabcentral/answers/143654-need-an-example-for-calculating-power-spectrum-density
        resampling_rate = 5; % Hz
        t_interp = t(B2B_valid_locs(1)):1/resampling_rate:t(B2B_valid_locs(end));
        
        BPS = interp1(t(B2B_valid_locs),B2B_valid,t_interp,'linear');
        
        % compute the PSD, units of Pxx are squared seconds/Hz.
        % [Pxx,freq] = periodogram(BPS-mean(BPS),[],numel(BPS),resampling_rate);
        [Pxx,freq] = periodogram(BPS-mean(BPS),hamming(length(BPS)),512,resampling_rate);
        % [Pxx_w,freq_w] = pwelch(BPS-mean(BPS),[],[],256,resampling_rate);
        
        % convert to ms^2 / Hz
        Pxx = Pxx*1e6;
        
        % compute the power in the various bands...
        vlfPower    = bandpower(Pxx,freq,[0 0.04],'psd'); % units of sec^2
        lfPower     = bandpower(Pxx,freq,[0.04 0.15],'psd'); % units of sec^2
        hfPower     = bandpower(Pxx,freq,[0.15 0.5],'psd'); % units of sec^2
        totPower    = bandpower(Pxx,freq,'psd'); % units of sec^2
        % you can then take the ratio of lf, hf, etc. to totPower * 100 to get the percentages etc.
    end
    
    %% How "much time of the run" was deleted related to the detection of outlier?
    Tab_outlier.durationRun_s                   = max(t);
    Tab_outlier.duration_NotValidSegments_s     = max(t)-sum(B2B(idx_valid_B2B));
    Tab_outlier.nrblock                         = i_block;
    Tab_outlier.nrblock_combinedFiles           = NrBlock;
    if Set.OutlierModus == 1
        display(Tab_outlier)
    end
    
    
    % put data segments around R-peaks together
    %idx_valid_B2B_consec_2 = idx_valid_B2B_consec;
    % while t(end) < t(B2B_valid_locs(idx_valid_B2B_consec_2(end)))+0.5
    %     idx_valid_B2B_consec_2 = idx_valid_B2B_consec_2(1:end-1);
    % end
    % while t(1) > t(B2B_valid_locs(idx_valid_B2B_consec_2(1)))-0.5
    %     idx_valid_B2B_consec_2 = idx_valid_B2B_consec_2(2:end);
    % end
    % cap_data = nan(length(idx_valid_B2B_consec_2), round(Fs));
    % for RpeakNum = 1:length(idx_valid_B2B_consec_2)
    %     curr_t_idx = t > t(B2B_valid_locs(idx_valid_B2B_consec_2(RpeakNum)))-0.5 & ...
    %         t < t(B2B_valid_locs(idx_valid_B2B_consec_2(RpeakNum)))+0.5;
    %     cap_data(RpeakNum,:) = capFiltered(curr_t_idx);
    % end
    % cap_data = single(cap_data);
    
    
     % Replace scattered outputs with single function call
    verbose = true;  % Control flag for text output
    printAnalysisSummary(Tab_outlier, detectedOutliers_mode, detectedOutlier2, IE_ratio, verbose, indicesToZero, capSignal, idx_Invalid_B2B_FlatRegion, t, maybe_valid_pos_cap_locs);
    
    
    if TOPLOT
        
        hf = figure('Name',[FigInfo sprintf('block%02d',i_block),'_', sprintf( 'Nrblock%02d',NrBlock)],'Position',[200 100 1400 1200],'PaperPositionMode', 'auto');
        
        %% single HR-peak
        %     t = t*1000;
        %     plot(t,capSignal,'b'); hold on;
        %     set(gca,'xlim',[172 173]);
        %
        ha1 = subplot(4,4,[1:4]);
        capPlot1 = plot(t,capSignal,'g'); hold on;
        plot(t,capFiltered,'b');
        plot(t(locs_min),capFiltered(locs_min),'bo','MarkerSize',6);
        
        % Add KK1 invalid periods as gray line segments
        if ~isempty(indicesToZero)
            % Find continuous segments
            segments = find(diff([0; indicesToZero; 0]) ~= 1);
            segments = reshape(segments, 2, [])';
            
            % Plot each segment
            for i = 1:size(segments, 1)
                start_idx = indicesToZero(segments(i,1));
                end_idx = indicesToZero(segments(i,2)-1);
                plot(t(start_idx:end_idx), capSignal(start_idx:end_idx), 'Color', [0.5 0.5 0.5], 'LineWidth', 2, 'DisplayName', 'KK1 Invalid Periods');
            end
        end
        
        % Add KK4 flat segments as yellow lines
        if ~isempty(idx_Invalid_B2B_FlatRegion)
            for i = 1:length(idx_Invalid_B2B_FlatRegion)
                idx = idx_Invalid_B2B_FlatRegion(i);
                if idx < length(maybe_valid_pos_cap_locs)
                    t_start = t(maybe_valid_pos_cap_locs(idx));
                    t_end = t(maybe_valid_pos_cap_locs(idx + 1));
                    plot([t_start t_end], [0 0], 'y', 'LineWidth', 2, 'DisplayName', 'KK4 Flat Segments');
                end
            end
        end
        
        plot(t(locs_peak(idx_wo_outliers)),capSignal(locs_peak(idx_wo_outliers)),'ko','MarkerSize',6);
        %idx_Invalid_B2B - after changing the max-values
        % DEBUG plot(t(locs_peak(idx_Invalid_B2B)),capSignal(locs_peak(idx_Invalid_B2B)),'ro','MarkerSize',6);
        % DEBUG plot(t(locs_peak(Invalid_peak)),capSignal(locs_peak(Invalid_peak)),'r*','MarkerSize',6);
        
        % valid R peaks
        plot(t(R_valid_locs),capSignal(R_valid_locs),'mv','MarkerFaceColor',[1 1 1],'MarkerSize',6);
        %valid B2B intervals -> filled TRIANGLE
        plot(t(B2B_valid_locs),capSignal(B2B_valid_locs),'mv','MarkerFaceColor',[1.0000    0.6000    0.7843],'MarkerSize',6);
        plot(t(locs_peak(idx_outliers)),capSignal(locs_peak(idx_outliers)),'bx');
        
        %line for
        plot([t(B2B_valid_locs(idx_valid_B2B_consec)) - B2B_valid(idx_valid_B2B_consec); t(B2B_valid_locs(idx_valid_B2B_consec))], ...
            [capFiltered(B2B_valid_locs(idx_valid_B2B_consec)); capFiltered(B2B_valid_locs(idx_valid_B2B_consec))],'k');
        
        
        
        
        plot([t_valid_inspStart t_valid_inspEnd], [0 0], 'b', 'LineWidth', 3, 'DisplayName', 'Inhalation');
        plot([t_valid_expStart t_valid_expEnd], [.1 .1], 'r', 'LineWidth', 3, 'DisplayName', 'Exhalation');
        set(gca,'Xlim',[0 max(t)]);
        xlabel('Time (s)');
        title(sprintf('NrBlock  %d CAP: %d valid peaks, %d valid P2P intervals',NrBlock, length(R_valid_locs),length(B2B_valid_locs)));
        if isempty(idx_outliers)
            legend({'capSignal','capFiltered','allPeaks','only posPeaks','valid Peaks','valid P2Pinterval'},'location','Best');
        else
            legend({'capSignal','capFiltered','allPeaks','posPeaks','valid Rpeaks','valid P2Pinterval','outlier.diff Peaks','Inhalation'},'location','Best');
        end
        
        
        
        ha3 = subplot(4,4,[9:12]);
        plot(t(B2B_valid_locs),B2B_valid,'m.'); hold on
        set(gca,'Xlim',[0 max(t)]);
        plot(t(B2B_valid_locs(idx_valid_B2B_consec)),B2B_valid(idx_valid_B2B_consec),'k.','MarkerSize',6); hold on
        plot(t(B2B_Invalid_locs),B2B(idx_Invalid_B2B),'r.','MarkerSize',6); hold on %DEBUG
        
        
        
        % plot(t(B2B_valid_locs(idx_valid_B2B_consec)),B2B_valid(idx_valid_B2B_consec) - B2B_diff(idx_valid_B2B_consec-1),'ks','MarkerSize',3);
        plot(t_valid_B2B(idx_to_delete_after_outliers),B2B_valid_before_hampel(idx_to_delete_after_outliers),'cx'); hold on
        plot(t_valid_B2B(idx_outliers_hampel),B2B_valid_before_hampel(idx_outliers_hampel),'rx'); hold on
        
        if B2B_valid_spectrum,
            % plot(t_interp,BPS,'y','Color',[0.4706    0.3059    0.4471]);
        end
        
        set(gca,'Xlim',[0 max(t)]);
        title(sprintf('B2B (s): %d valid, %d consecutive, %d outliers, RMSSD %.3f bpm | %.1f ms',...
            length(B2B_valid_locs),length(idx_valid_B2B_consec),length(unique([idx_outliers_hampel' idx_to_delete_after_outliers])), rmssd_B2B_valid_bpm, rmssd_B2B_valid_ms));
        ylabel('B2B (s)');
        legend({'valid','consecutive','after outliers','hampel outliers'},'location','Best');
        
        
        subplot(4,4,13);
        plot(bins,hist_B2B); hold on;
        plot(median_B2B,0,'rv','MarkerSize',6);
        plot(mode_B2B,0,'mv','MarkerSize',6);
        plot(bins,hist_B2B_valid,'m');
        title(sprintf('%d all B2B, %d valid B2B',length(B2B), length(B2B_valid)));
        xlabel('B2B (s)');
        ylabel('count');
        
        subplot(4,4,14);
        boxplot(B2B_valid_bpm);
        title(sprintf('mean %.1f med %.1f SD %.1f bpm',mean_B2B_valid_bpm,median_B2B_valid_bpm,std_B2B_valid_bpm));
        ylabel('BPM');
        
        subplot(4,4,15);
        plot(B2B_valid_bpm(1:end-1),B2B_valid_bpm(2:end),'k.','MarkerEdgeColor',[0.5 0.5 0.5]); hold on
        plot(B2B_valid_bpm_consec(1:end-1),B2B_valid_bpm_consec(2:end),'m.','MarkerEdgeColor',[0.4235    0.2510    0.3922]);
        
        xlabel('B2B(n)');
        ylabel('B2B(n+1)');
        title('Poincaré plot');
        axis square
        ig_set_xy_axes_equal;
        ig_add_equality_line;
        
        if B2B_valid_spectrum,
            subplot(4,4,16);
            % plot(freq,Pxx,'k'); hold on;
            % plot(freq_w,Pxx_w,'m'); hold on;
            % plot(freq(freq>0 & freq<0.04),Pxx(freq>0 & freq<0.04),'b');
            plot(freq(freq>=0.04 & freq<=0.15),Pxx(freq>=0.04 & freq<=0.15),'r'); hold on
            plot(freq(freq>=0.15 & freq<=0.5),Pxx(freq>=0.15 & freq<=0.5),'g');
            plot(freq(freq>0.5 & freq<=1),Pxx(freq>0.5 & freq<=1),'k');
            set(gca,'Xlim',[0 1]);
            xlabel('Hz');
            ylabel('ms^2 / Hz');
            title(sprintf('[vlf %.3f] lf %.3f hf %.3f',vlfPower,lfPower,hfPower));
        end
        
        
        ax = get(gcf,'Children');
        set(ax,'FontSize',8);
        
        
        out.hf = hf;
        
    end
end

if length(B2B_valid) < Set.B2B_minValidData || isempty(B2B_valid)
    out.Rpeak_t                 = [];
    out.Rpeak_sample            = [];
    out.B2B_t                   = [];
    out.B2B_sample              = [];
    out.B2B_valid               = [];
    out.B2B_valid_bpm           = [];
    out.B2B_valid_ms            = [];
    out.inspStart_t             = [];
    out.inspEnd_t               = [];
    out.expStart_t              = [];
    out.expEnd_t                = [];
    out.duration_insp_valid     = [];
    out.duration_exp_valid      = [];
    out.idx_valid_B2B_consec    = [];
    out.mean_B2B_valid_bpm      = nan;
    out.median_B2B_valid_bpm    = nan;
    out.std_B2B_valid_bpm       = nan;
    out.std_B2B_valid_ms        = nan;
    out.rmssd_B2B_valid_ms      = nan;
    out.rmssd_B2B_valid_bpm     = nan;
    out.Pxx                     = [];
    out.freq                    = [];
    out.vlfPower                = nan;
    out.lfPower                 = nan;
    out.hfPower                 = nan;
    out.totPower                = nan;
    out.nrblock                 = [];
    out.nrblock_combinedFiles   = [];
    % out.ECG_Rpeaks_valid        = [];
    
    Tab_outlier.durationRun_s = nan;
    Tab_outlier.duration_NotValidSegments_s = nan;
    Tab_outlier.durationRun_s  = nan;
    Tab_outlier.nrblock = i_block ;
    Tab_outlier.nrblock_combinedFiles           = NrBlock;
    
    
    
else
    out.Rpeak_t                 = t(R_valid_locs);
    out.Rpeak_sample            = R_valid_locs;
    out.B2B_t                   = t(B2B_valid_locs);
    out.B2B_sample              = B2B_valid_locs;
    out.B2B_valid               = B2B_valid;
    out.B2B_valid_bpm           = B2B_valid_bpm;
    out.B2B_valid_ms            = B2B_valid_ms;
    out.inspStart_t             = t_valid_inspStart; % times of inspiration starts
    out.inspEnd_t               = t_valid_inspEnd; % times of inspiration ends
    out.expStart_t              = t_valid_expStart; % times of expiration starts
    out.expEnd_t                = t_valid_expEnd; % times of expiration ends
    out.duration_insp_valid     = duration_insp_valid;
    out.duration_exp_valid      = duration_exp_valid;
    out.idx_valid_B2B_consec    = idx_valid_B2B_consec; % index into B2B_valid vector!
    out.mean_B2B_valid_bpm      = mean_B2B_valid_bpm;
    out.median_B2B_valid_bpm    = median_B2B_valid_bpm;
    out.std_B2B_valid_bpm       = std_B2B_valid_bpm;
    out.std_B2B_valid_ms        = std_B2B_valid_ms;
    out.rmssd_B2B_valid_ms      = rmssd_B2B_valid_ms;
    out.rmssd_B2B_valid_bpm     = rmssd_B2B_valid_bpm;
    out.Pxx                     = Pxx;
    out.freq                    = freq;
    out.vlfPower                = vlfPower;
    out.lfPower                 = lfPower;
    out.hfPower                 = hfPower;
    out.totPower                = totPower;
    out.nrblock                 = i_block ;
    out.nrblock_combinedFiles   = NrBlock ;
    %out.ECG_Rpeaks_valid        = cap_data; % +/- 500 ms data segments for consecutive R-peaks
end


out.settingsStruct = Set.cap;
out.codeTimestamp  = datestr(now,30);% provenance: yyyymmddTHHMMSS

function printAnalysisSummary(Tab_outlier, detectedOutliers_mode, detectedOutlier2, IE_ratio, verbose, indicesToZero, capSignal, idx_Invalid_B2B_FlatRegion, t, maybe_valid_pos_cap_locs)
if ~verbose
    return
end

fprintf('\n=== Respiration Analysis Summary ===\n');

% Block and Time Information
fprintf('\nBlock Information:\n');
fprintf('  - Current block: %d\n', Tab_outlier.nrblock);
fprintf('  - Combined files block: %d\n', Tab_outlier.nrblock_combinedFiles);
fprintf('  - Total run duration: %.1f s\n', Tab_outlier.durationRun_s);
fprintf('  - Valid data percentage: %.1f%%\n', ...
    (1 - Tab_outlier.duration_NotValidSegments_s/Tab_outlier.durationRun_s)*100);


 % Invalid Segments Analysis
fprintf('\nInvalid Segments Analysis:\n');

% KK1 Low Amplitude Segments
if ~isempty(indicesToZero)
    segments = find(diff([0; indicesToZero; 0]) ~= 1);
    segments = reshape(segments, 2, [])';
    num_segments = size(segments, 1);
    total_duration = length(indicesToZero) / length(capSignal) * 100;
    fprintf('  KK1 Low Amplitude:\n');
    fprintf('    - Number of segments: %d\n', num_segments);
    fprintf('    - Total duration: %.1f%% of signal\n', total_duration);
end

% KK4 Flat Segments
if ~isempty(idx_Invalid_B2B_FlatRegion)
    num_flat_segments = length(idx_Invalid_B2B_FlatRegion);
    total_flat_duration = 0;
    for i = 1:length(idx_Invalid_B2B_FlatRegion)
        idx = idx_Invalid_B2B_FlatRegion(i);
        if idx < length(maybe_valid_pos_cap_locs)
            t_start = t(maybe_valid_pos_cap_locs(idx));
            t_end = t(maybe_valid_pos_cap_locs(idx + 1));
            total_flat_duration = total_flat_duration + (t_end - t_start);
        end
    end
    flat_duration_percent = (total_flat_duration / t(end)) * 100;
    fprintf('  KK4 Flat Segments:\n');
    fprintf('    - Number of segments: %d\n', num_flat_segments);
    fprintf('    - Total duration: %.1f%% of signal\n', flat_duration_percent);
end

% Peak Analysis Summary
fprintf('\nPeak Analysis:\n');
fprintf('  - Total peaks detected: %d\n', Tab_outlier.NrRpeaks_orig);
fprintf('  - Valid peaks: %d\n', Tab_outlier.NrPeaks_valid);
fprintf('  - Consecutive valid peaks: %d\n', Tab_outlier.B2B_consec);
fprintf('  - Invalid peaks: %d (%.1f%%)\n', ...
    Tab_outlier.outliers_all_abs, Tab_outlier.outliers_all_pct);

% B2B and Outlier Analysis
fprintf('\nBreath-to-Breath Analysis:\n');
fprintf('  - Valid B2B intervals: %d\n', Tab_outlier.NrB2B_valid);
fprintf('  - Mode-based outliers: %.1f%%\n', detectedOutliers_mode);
fprintf('  - Hampel-based outliers: %.1f%%\n', detectedOutlier2);
fprintf('  - Deleted outliers: %d\n', Tab_outlier.outliers_delete_abs);

% Breathing Pattern
fprintf('\nBreathing Pattern:\n');
fprintf('  - I:E Ratio: %.2f\n', IE_ratio);
fprintf('  - Median inspiration duration: %.2f s\n', Tab_outlier.median_duration_insp);
fprintf('  - Median expiration duration: %.2f s\n', Tab_outlier.median_duration_exp);



fprintf('\n==============================\n\n');


