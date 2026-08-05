function [out, Tab_outlier] = bsa_respiration_analyze_one_run(capSignal, settings_path, Fs, TOPLOT, i_block, NrBlock, FigInfo)
% Analyses one capnogram run/block and returns respiration variables plus
% explicit respiration-only QC masks for later cardiorespiratory coupling.%
% USAGE:
% out = bsa_respiration_analyze_one_run(capSignal,settings_path,Fs,1,sprintf('block%02d',r));
%
% INPUTS:
%		capSignal		- capnography 
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
% Respiration-only badBreath criteria hard-coded here:
% affecting    out.resp_qc, out.breathDur_s,  out.respRate_bpm_perBreath, out.inspFrac_perBreath, Tab_outlier.resp_qc_*
%   1) NaN/Inf phase times
%   2) impossible order: inspEnd <= inspStart, expStart < inspEnd, expEnd <= expStart
%   3) respiration rate outside 5-120 breaths/min
%   4) inspiration fraction outside 0.10-0.90
%   5) global 6-MAD outlier in breath duration or respiration rate
%   6) local 6-MAD outlier in breath duration using a 21-breath window

if nargin < 4 || isempty(TOPLOT)
    TOPLOT = true;
end

if nargin < 7 || isempty(FigInfo)
    FigInfo = '';
end

run(settings_path)

capSignal = double(capSignal(:));
Fs = double(Fs);
n_samples = length(capSignal);
t = (0:n_samples-1)' ./ Fs; % first sample is time 0

out = initialize_empty_resp_output();
Tab_outlier = initialize_empty_Tab_outlier();
resp_qc = initialize_empty_resp_qc();

out.hf = [];
Tab_outlier.session_index = i_block;
Tab_outlier.nrblock = NrBlock;
Tab_outlier.nrblock_combinedFiles = NrBlock;
Tab_outlier.durationRun_s = max(t);

% -------------------------------------------------------------------------
% Flip cap signal if needed
% -------------------------------------------------------------------------
if nanmedian(capSignal) <= 0
    capSignal = -capSignal;
end

% -------------------------------------------------------------------------
% KK1: low-amplitude invalid periods
% -------------------------------------------------------------------------

sortedAbs = sort(abs(capSignal), 'descend');
nTop = max(1, round(0.01 * Set.cap.signal_top_percentile * length(sortedAbs)));
topPercentile = sortedAbs(1:nTop);
threshold = Set.cap.fraction_of_top_percentile * nanmedian(topPercentile);

belowThreshold = abs(capSignal) < threshold;
minDurationSamples = round(Set.cap.min_duration_low * Fs);

stats = regionprops(belowThreshold, 'Area', 'PixelIdxList');
longEnoughMask = [stats.Area] >= minDurationSamples;

if any(longEnoughMask)
    indicesToZero = vertcat(stats(longEnoughMask).PixelIdxList);
else
    indicesToZero = [];
end

capSignalRemoved = capSignal;
capSignalRemoved(indicesToZero) = 0;

if isempty(indicesToZero)
    lowAmpSegments_s = [];
else
    lowAmpIdx = unique(indicesToZero(:));
    lowAmpBounds = [1; find(diff(lowAmpIdx) ~= 1) + 1; numel(lowAmpIdx) + 1];
    lowAmpSegments = [lowAmpBounds(1:end-1), lowAmpBounds(2:end) - 1];
    lowAmpSampleRanges = [lowAmpIdx(lowAmpSegments(:, 1)), ...
        lowAmpIdx(lowAmpSegments(:, 2))];
    lowAmpSegments_s = [t(lowAmpSampleRanges(:, 1)), ...
        t(lowAmpSampleRanges(:, 2))];
end
resp_qc.lowAmpSegments_s = lowAmpSegments_s;
resp_qc.nLowAmpSegments = size(lowAmpSegments_s, 1);
if isempty(lowAmpSegments_s)
    resp_qc.durationLowAmp_s = 0;
else
    resp_qc.durationLowAmp_s = ...
        sum(lowAmpSegments_s(:, 2) - lowAmpSegments_s(:, 1));
end

Tab_outlier.resp_qc_lowAmpSegments_s = resp_qc.lowAmpSegments_s;
Tab_outlier.resp_qc_nLowAmpSegments = resp_qc.nLowAmpSegments;
Tab_outlier.resp_qc_durationLowAmp_s = resp_qc.durationLowAmp_s;

% If the remaining signal is too small, return empty outputs but keep QC.
if nanmedian(capSignalRemoved) <= 0.15
    [out, Tab_outlier] = finalize_empty_output( ...
        out, Tab_outlier, resp_qc, Set, i_block, NrBlock);
    Tab_outlier.duration_NotValidSegments_s = max(t);
    return
end

% -------------------------------------------------------------------------
% Smooth and prepare signal
% -------------------------------------------------------------------------
Set.cap.smoothing_window = 0.3;
capFiltered = smooth(capSignalRemoved, round(Set.cap.smoothing_window * Fs));
capFiltered = capFiltered(:);
capFilteredFilled = filloutliers(capFiltered, 'linear', 'movmedian', 1000);
capFiltered_rectified = capFilteredFilled;

% -------------------------------------------------------------------------
% Detect inspiration candidates and expiratory peaks
% -------------------------------------------------------------------------
cap_mode = mode(capFiltered_rectified);
fractionBelowMode = sum(capFiltered_rectified < cap_mode) / length(capFiltered_rectified);

if fractionBelowMode > 0.5
    fraction_of_inspiration = sum(capFiltered_rectified < cap_mode) / length(capFiltered_rectified);
else
    fraction_of_inspiration = 2 * sum(capFiltered_rectified < cap_mode) / length(capFiltered_rectified);
end

fraction_of_inspiration = min(max(fraction_of_inspiration, 0.01), 0.99);
inspiration_threshold = prctile(capFiltered_rectified, 100 * fraction_of_inspiration);
insp_idx = find(capFiltered_rectified < inspiration_threshold); %#ok<NASGU>

MinPeakProminence = nanmedian(capFiltered_rectified) * Set.cap.MinPeakProminenceCoef;

[pks, locs_peak] = findpeaks(capFiltered_rectified, ...
    'MinPeakProminence', MinPeakProminence, ...
    'MinPeakDistance', fix(Set.cap.min_P2P * Fs), ...
    'MinPeakHeight', Set.cap.eP_tc_minpeakheight_med_prop * nanmedian(capFiltered_rectified));

Tab_outlier.NrRpeaks_orig = length(pks);

if numel(locs_peak) < 3
    [out, Tab_outlier] = finalize_empty_output( ...
        out, Tab_outlier, resp_qc, Set, i_block, NrBlock);
    return
end

% Remove peak-amplitude jump outliers using your existing helper.
diff_peaks = [0; abs(diff(pks(:)))];
[~, idx_wo_outliers, ~, idx_outliers, ~] = bsa_remove_outliers(diff_peaks, Set.cap.MAD_sensitivity_p2p_diff);
Tab_outlier.outlier = length(idx_outliers);

capFiltered_pos = max(capFiltered_rectified, 0);
[~, pos_cap_locs] = findpeaks(capFiltered_pos, ...
    'MinPeakProminence', MinPeakProminence, ...
    'MinPeakDistance', fix(Set.cap.min_P2P * Fs), ...
    'MinPeakHeight', Set.cap.eP_tc_minpeakheight_med_prop * nanmedian(capFiltered_pos));

maybe_valid_pos_cap_locs = pos_cap_locs(:)';

if numel(maybe_valid_pos_cap_locs) < 3
    [out, Tab_outlier] = finalize_empty_output( ...
        out, Tab_outlier, resp_qc, Set, i_block, NrBlock);
    return
end

% -------------------------------------------------------------------------
% Breath-to-breath intervals and B2B outlier removal
% -------------------------------------------------------------------------
B2B = [NaN, diff(t(maybe_valid_pos_cap_locs))'];
median_B2B = nanmedian(B2B);
mode_B2B = mode(round(B2B(~isnan(B2B)), 3));
min_B2B = min(B2B(~isnan(B2B)));

if abs(min_B2B - mode_B2B) <= 0.2
    idx_Invalid_B2B = find(B2B < Set.cap.minFactor_B2BMode * median_B2B | ...
                           B2B > Set.cap.maxFactor_B2BMode * median_B2B);
else
    idx_Invalid_B2B = find(B2B < Set.cap.minFactor_B2BMode * mode_B2B | ...
                           B2B > Set.cap.maxFactor_B2BMode * mode_B2B);
end

idx_Invalid_B2B = unique([1, idx_Invalid_B2B, idx_Invalid_B2B - 1]);
idx_Invalid_B2B = idx_Invalid_B2B(idx_Invalid_B2B >= 1 & idx_Invalid_B2B <= length(B2B));
idx_valid_B2B_initial = setdiff(1:length(B2B), idx_Invalid_B2B);

% -------------------------------------------------------------------------
% KK4: flat/invalid signal periods within B2B intervals
% -------------------------------------------------------------------------
flatRangeThreshold = 0.005;
min_duration_flat = 3;
minFlatDurationSamples = round(min_duration_flat * Fs);
idx_Invalid_B2B_FlatRegion = [];

for ii = 1:length(idx_valid_B2B_initial)
    idx = idx_valid_B2B_initial(ii);

    if idx <= 1 || idx > length(maybe_valid_pos_cap_locs)
        continue
    end

    sample_start = maybe_valid_pos_cap_locs(idx - 1);
    sample_end   = maybe_valid_pos_cap_locs(idx);
    segment = capSignal(sample_start:sample_end);

    if numel(segment) < minFlatDurationSamples
        continue
    end

    window_ranges = movmax(segment, minFlatDurationSamples) - ...
                    movmin(segment, minFlatDurationSamples);

    if any(window_ranges < flatRangeThreshold)
        idx_Invalid_B2B_FlatRegion = [idx_Invalid_B2B_FlatRegion, idx]; %#ok<AGROW>
    end
end

% Collect deleted/rejected B2B intervals.
idx_B2B_candidates = 2:length(B2B);

idx_deleted_B2B_mode = unique(idx_Invalid_B2B);
idx_deleted_B2B_mode = idx_deleted_B2B_mode( ...
    idx_deleted_B2B_mode >= 2 & idx_deleted_B2B_mode <= length(B2B));

idx_deleted_B2B_flat = unique(idx_Invalid_B2B_FlatRegion);
idx_deleted_B2B_flat = idx_deleted_B2B_flat( ...
    idx_deleted_B2B_flat >= 2 & idx_deleted_B2B_flat <= length(B2B));

idx_deleted_B2B_all = unique([idx_deleted_B2B_mode, idx_deleted_B2B_flat]);
idx_valid_B2B = setdiff(idx_B2B_candidates, idx_deleted_B2B_all);

Tab_outlier.idx_deleted_B2B_all  = idx_deleted_B2B_all;
Tab_outlier.idx_deleted_B2B_mode = idx_deleted_B2B_mode;
Tab_outlier.idx_deleted_B2B_flat = idx_deleted_B2B_flat;
Tab_outlier.outlier_Mode_abs = numel(idx_deleted_B2B_mode);
if isempty(idx_B2B_candidates) || numel(idx_B2B_candidates) == 0
    Tab_outlier.outlier_Mode_pct = NaN;
else
    Tab_outlier.outlier_Mode_pct = ...
        100 * Tab_outlier.outlier_Mode_abs / numel(idx_B2B_candidates);
end
Tab_outlier.outliers_delete_abs = numel(idx_deleted_B2B_all);
Tab_outlier.outliers_all_abs = numel(idx_deleted_B2B_all);
if isempty(idx_B2B_candidates) || numel(idx_B2B_candidates) == 0
    Tab_outlier.outliers_all_pct = NaN;
else
    Tab_outlier.outliers_all_pct = ...
        100 * Tab_outlier.outliers_all_abs / numel(idx_B2B_candidates);
end
Tab_outlier.NrB2B_beforehampel = numel(idx_valid_B2B);

flatSegments_s = [];
for ff = 1:numel(idx_Invalid_B2B_FlatRegion)
    idxFlat = idx_Invalid_B2B_FlatRegion(ff);
    if idxFlat > 1 && idxFlat <= numel(maybe_valid_pos_cap_locs)
        flatSegments_s = [flatSegments_s; ... %#ok<AGROW>
            t(maybe_valid_pos_cap_locs(idxFlat - 1)), ...
            t(maybe_valid_pos_cap_locs(idxFlat))];
    end
end
resp_qc.flatSegments_s = flatSegments_s;
resp_qc.nFlatSegments = size(flatSegments_s, 1);
if isempty(flatSegments_s)
    resp_qc.durationFlat_s = 0;
else
    resp_qc.durationFlat_s = ...
        sum(flatSegments_s(:, 2) - flatSegments_s(:, 1));
end

Tab_outlier.resp_qc_flatSegments_s = resp_qc.flatSegments_s;
Tab_outlier.resp_qc_nFlatSegments = resp_qc.nFlatSegments;
Tab_outlier.resp_qc_durationFlat_s = resp_qc.durationFlat_s;

% Valid cap peaks and B2B variables.
idx_valid_R = unique([idx_valid_B2B, idx_valid_B2B - 1]);
idx_valid_R = idx_valid_R(idx_valid_R >= 1 & idx_valid_R <= numel(maybe_valid_pos_cap_locs));
R_valid_locs = maybe_valid_pos_cap_locs(idx_valid_R);

B2B_valid_locs = maybe_valid_pos_cap_locs(idx_valid_B2B);
B2B_valid = B2B(idx_valid_B2B);

Tab_outlier.NrPeaks_valid = length(R_valid_locs);
Tab_outlier.NrB2B_valid = length(B2B_valid);

% -------------------------------------------------------------------------
% Match valid B2B intervals with inspiration / expiration timing
% -------------------------------------------------------------------------
nBreaths = numel(idx_valid_B2B);

t_valid_inspStart = nan(nBreaths, 1);
t_valid_inspEnd   = nan(nBreaths, 1);
t_valid_expStart  = nan(nBreaths, 1);
t_valid_expEnd    = nan(nBreaths, 1);

duration_insp_valid = nan(nBreaths, 1);
duration_exp_valid  = nan(nBreaths, 1);

corrected_insp_end_t = nan(nBreaths, 1); %#ok<NASGU>
corrected_insp_end_idx = nan(nBreaths, 1); %#ok<NASGU>

skippedInspTimes = [];
skippedInspDurations = [];
noInspEndCount = 0;
noInspEndTimes = [];

for ii = 1:nBreaths
    k = idx_valid_B2B(ii);

    if k <= 1 || k > numel(maybe_valid_pos_cap_locs)
        continue
    end

    currPeakIdx = maybe_valid_pos_cap_locs(k - 1);
    nextPeakIdx = maybe_valid_pos_cap_locs(k);

    currPeakTime = t(currPeakIdx);
    nextPeakTime = t(nextPeakIdx);

    segIdx = currPeakIdx:nextPeakIdx;
    seg = capFiltered_rectified(segIdx);

    [segMin, iMin] = min(seg);
    lowThr = segMin + Set.cap.lowPlateauFrac * range(seg);
    iEnd = find(seg <= lowThr & (1:numel(seg))' >= iMin, 1, 'last');

    if isempty(iEnd)
        iEnd = iMin;
    end

    inspEndIdx = segIdx(iEnd);
    inspEndTime = t(inspEndIdx);

    durationInsp = inspEndTime - currPeakTime;
    durationExp  = nextPeakTime - inspEndTime;

    if durationInsp > Set.cap.min_P2P / 3 && ...
       durationExp  > Set.cap.min_P2P / 3 && ...
       durationInsp < 1.5 * mode_B2B && ...
       durationExp  < 2.0 * mode_B2B

        t_valid_inspStart(ii) = currPeakTime;
        t_valid_inspEnd(ii)   = inspEndTime;
        t_valid_expStart(ii)  = inspEndTime;
        t_valid_expEnd(ii)    = nextPeakTime;

        duration_insp_valid(ii) = durationInsp;
        duration_exp_valid(ii)  = durationExp;
    else
        skippedInspTimes(end+1) = currPeakTime; %#ok<AGROW>
        skippedInspDurations(end+1) = durationInsp; %#ok<AGROW>
    end
end

Tab_outlier.median_duration_insp = nanmedian(duration_insp_valid);
Tab_outlier.median_duration_exp  = nanmedian(duration_exp_valid);
IE_ratio = Tab_outlier.median_duration_insp / Tab_outlier.median_duration_exp;

Tab_outlier.numSkippedInspSegments = numel(skippedInspTimes);
Tab_outlier.skippedInspTimes = skippedInspTimes;
Tab_outlier.skippedInspDurations = skippedInspDurations;
Tab_outlier.numValidPeaksNoInspEnd = noInspEndCount;
Tab_outlier.validPeaksNoInspEndTimes = noInspEndTimes;
Tab_outlier.numValidInsp = sum(~isnan(t_valid_inspStart));
numValidExp = sum(~isnan(t_valid_expStart));
Tab_outlier.totalCandidatesInsp = nBreaths;
Tab_outlier.numInvalidInsp = nBreaths - Tab_outlier.numValidInsp;
Tab_outlier.numInvalidExp  = nBreaths - numValidExp;

% -------------------------------------------------------------------------
% Respiration-only per-breath QC
% -------------------------------------------------------------------------
[resp_qc, Tab_outlier] = compute_respiration_only_qc( ...
    resp_qc, Tab_outlier, ...
    t_valid_inspStart, t_valid_inspEnd, t_valid_expStart, t_valid_expEnd, ...
    lowAmpSegments_s, flatSegments_s);

% -------------------------------------------------------------------------
% Calculate summary variables
% -------------------------------------------------------------------------
B2B_valid_bpm = 60 ./ B2B_valid;
B2B_valid_ms = 1000 .* B2B_valid;
mean_B2B_valid_bpm = nanmean(B2B_valid_bpm);
median_B2B_valid_bpm = nanmedian(B2B_valid_bpm);
std_B2B_valid_bpm = nanstd(B2B_valid_bpm);
std_B2B_valid_ms = nanstd(B2B_valid_ms);

median_B2B_valid = nanmedian(B2B_valid);
mode_B2B_valid = mode(round(B2B_valid(~isnan(B2B_valid)), 3));
min_B2B_valid = min(B2B_valid(~isnan(B2B_valid)));

if min_B2B_valid == mode_B2B_valid
    idx_valid_B2B_consec = find([NaN, diff(t(B2B_valid_locs))'] < ...
        Set.cap.maxFactor_B2BMode * median_B2B_valid);
else
    idx_valid_B2B_consec = find([NaN, diff(t(B2B_valid_locs))'] < ...
        Set.cap.maxFactor_B2BMode * mode_B2B_valid);
end
Tab_outlier.B2B_consec = numel(idx_valid_B2B_consec);

validDiffIdx = idx_valid_B2B_consec - 1;
validDiffIdx = validDiffIdx(validDiffIdx >= 1 & validDiffIdx <= numel(B2B_valid)-1);

B2B_diff = diff(B2B_valid);
B2B_bpm_diff = diff(B2B_valid_bpm);

if isempty(validDiffIdx)
    rmssd_B2B_valid_bpm = NaN;
    rmssd_B2B_valid_ms = NaN;
else
    rmssd_B2B_valid_bpm = sqrt(nanmean(B2B_bpm_diff(validDiffIdx).^2));
    rmssd_B2B_valid_ms = sqrt(nanmean((1000 * B2B_diff(validDiffIdx)).^2));
end

% Respiration spectrum, if possible.
Pxx = [];
freq = [];
vlfPower = NaN;
lfPower = NaN;
hfPower = NaN;
totPower = NaN;

if numel(B2B_valid_locs) > 1
    resampling_rate = 5;
    t_interp = t(B2B_valid_locs(1)):1/resampling_rate:t(B2B_valid_locs(end));

    if numel(t_interp) > 3
        BPS = interp1(t(B2B_valid_locs), B2B_valid, t_interp, 'linear');
        [Pxx, freq] = periodogram(BPS - nanmean(BPS), hamming(length(BPS)), 512, resampling_rate);
        Pxx = Pxx * 1e6;

        vlfPower = bandpower(Pxx, freq, [0 0.04], 'psd');
        lfPower  = bandpower(Pxx, freq, [0.04 0.15], 'psd');
        hfPower  = bandpower(Pxx, freq, [0.15 0.5], 'psd');
        totPower = bandpower(Pxx, freq, 'psd');
    end
end

Tab_outlier.durationRun_s = max(t);
Tab_outlier.duration_NotValidSegments_s = max(t) - nansum(B2B(idx_valid_B2B));
Tab_outlier.session_index = i_block;
Tab_outlier.nrblock = NrBlock;
Tab_outlier.nrblock_combinedFiles = NrBlock;

if isfield(Set, 'OutlierModus') && Set.OutlierModus == 1
    display(Tab_outlier)
end

printAnalysisSummary(Tab_outlier, IE_ratio, true, ...
    indicesToZero, capSignal, idx_Invalid_B2B_FlatRegion, t, maybe_valid_pos_cap_locs);

% -------------------------------------------------------------------------
% Optional diagnostic plot
% -------------------------------------------------------------------------
if TOPLOT

    hf = figure( ...
        'Name', [FigInfo sprintf('block%02d', i_block), '_', sprintf('Nrblock%02d', NrBlock)], ...
        'Position', [100 50 1600 1000], ...
        'PaperPositionMode', 'auto');

    %% --------------------------------------------------------------------
    % Plot 1: signal QC / peak detection / respiratory phases
    % ---------------------------------------------------------------------
    subplot(4,4,1:4)

    h = [];
    lab = {};

    h(end+1) = plot(t, capSignal, 'Color', [0.2 0.7 0.2]); hold on
    lab{end+1} = 'raw CAP signal';

    h(end+1) = plot(t, capFiltered, 'b');
    lab{end+1} = 'filtered CAP signal';

    % ---------------------------------------------------------------------
    % Overlay inspiration and expiration phases
    % ---------------------------------------------------------------------
    yl = ylim;
    yPhase = yl(1) + 0.08 * range(yl);

    firstInspHandle = [];
    firstExpHandle  = [];

    for bb = 1:numel(t_valid_inspStart)

        % Inspiration phase: blue
        if isfinite(t_valid_inspStart(bb)) && isfinite(t_valid_inspEnd(bb)) && ...
                t_valid_inspEnd(bb) > t_valid_inspStart(bb)

            hh = plot([t_valid_inspStart(bb), t_valid_inspEnd(bb)], ...
                      [yPhase, yPhase], ...
                      'b-', 'LineWidth', 2);

            if isempty(firstInspHandle)
                firstInspHandle = hh;
            end
        end

        % Expiration phase: red
        if isfinite(t_valid_expStart(bb)) && isfinite(t_valid_expEnd(bb)) && ...
                t_valid_expEnd(bb) > t_valid_expStart(bb)

            hh = plot([t_valid_expStart(bb), t_valid_expEnd(bb)], ...
                      [yPhase, yPhase], ...
                      'r-', 'LineWidth', 2);

            if isempty(firstExpHandle)
                firstExpHandle = hh;
            end
        end
    end

    if ~isempty(firstInspHandle)
        h(end+1) = firstInspHandle;
        lab{end+1} = 'inspiration phase';
    end

    if ~isempty(firstExpHandle)
        h(end+1) = firstExpHandle;
        lab{end+1} = 'expiration phase';
    end

    % ---------------------------------------------------------------------
    % Peaks
    % ---------------------------------------------------------------------
    if exist('locs_peak', 'var') && ~isempty(locs_peak)
        h(end+1) = plot(t(locs_peak), capSignal(locs_peak), 'kv', ...
            'MarkerFaceColor', [0.5 0.5 0.5]);
        lab{end+1} = 'all detected peaks';
    end

    if exist('pos_cap_locs', 'var') && ~isempty(pos_cap_locs)
        h(end+1) = plot(t(pos_cap_locs), capSignal(pos_cap_locs), 'co');
        lab{end+1} = 'positive CAP peaks';
    end

    if exist('R_valid_locs', 'var') && ~isempty(R_valid_locs)
        h(end+1) = plot(t(R_valid_locs), capSignal(R_valid_locs), 'mv', ...
            'MarkerFaceColor', [1 0.6 0.78]);
        lab{end+1} = 'valid respiratory peaks';
    end

    % ---------------------------------------------------------------------
    % Valid B2B/P2P intervals
    % ---------------------------------------------------------------------
    if exist('idx_valid_B2B', 'var') && ~isempty(idx_valid_B2B)
        yl = ylim;
        yLine = yl(1) + 0.03 * range(yl);

        firstIntervalHandle = [];

        for jj = 1:numel(idx_valid_B2B)
            idxB = idx_valid_B2B(jj);

            if idxB > 1 && idxB <= numel(maybe_valid_pos_cap_locs)
                x1 = t(maybe_valid_pos_cap_locs(idxB - 1));
                x2 = t(maybe_valid_pos_cap_locs(idxB));

                hh = plot([x1 x2], [yLine yLine], 'y-', 'LineWidth', 2);

                if isempty(firstIntervalHandle)
                    firstIntervalHandle = hh;
                end
            end
        end

        if ~isempty(firstIntervalHandle)
            h(end+1) = firstIntervalHandle;
            lab{end+1} = 'valid B2B/P2P interval';
        end
    end

    % ---------------------------------------------------------------------
    % Low-amplitude signal QC segments
    % ---------------------------------------------------------------------
    if ~isempty(lowAmpSegments_s)
        yl = ylim;
        firstPatch = [];

        for ss = 1:size(lowAmpSegments_s,1)
            hp = patch( ...
                [lowAmpSegments_s(ss,1) lowAmpSegments_s(ss,2) lowAmpSegments_s(ss,1) lowAmpSegments_s(ss,2)], ...
                [yl(1) yl(1) yl(2) yl(2)], ...
                [0.7 0.7 0.7], ...
                'FaceAlpha', 0.25, ...
                'EdgeColor', 'none');

            if isempty(firstPatch)
                firstPatch = hp;
            end
        end

        if ~isempty(firstPatch)
            h(end+1) = firstPatch;
            lab{end+1} = 'low-amplitude signal QC segment';
        end
    end

    xlabel('Time [s]')
    ylabel('CAP signal')
    title(sprintf(['QC layer 1: signal/peak/phase detection -> affects Rpeak_t, ', ...
        'B2B candidates, insp/exp phase times, and B2B_valid. Block %d, NrBlock %d'], ...
        i_block, NrBlock), ...
        'Interpreter', 'none');

    if ~isempty(h)
        legend(h, lab, 'Location', 'Best');
    end

    %% --------------------------------------------------------------------
    % Plot 2: B2B/P2P filtering
    % ---------------------------------------------------------------------
    subplot(4,4,5:8)

    h = [];
    lab = {};

    if ~isempty(B2B_valid_locs)
        h(end+1) = plot(t(B2B_valid_locs), B2B_valid, 'm.'); hold on
        lab{end+1} = 'B2B_valid: used for CAP summary variables';
    else
        hold on
    end

    if exist('idx_valid_B2B_consec', 'var') && ~isempty(idx_valid_B2B_consec)
        idxConsec = idx_valid_B2B_consec;
        idxConsec = idxConsec(idxConsec >= 1 & idxConsec <= numel(B2B_valid));

        if ~isempty(idxConsec)
            h(end+1) = plot(t(B2B_valid_locs(idxConsec)), B2B_valid(idxConsec), 'k.');
            lab{end+1} = 'consecutive valid B2B used for RMSSD';
        end
    end

    if exist('idx_deleted_B2B_mode', 'var') && ~isempty(idx_deleted_B2B_mode)
        idxMode = idx_deleted_B2B_mode;
        idxMode = idxMode(idxMode >= 1 & idxMode <= numel(B2B));

        if ~isempty(idxMode)
            h(end+1) = plot(t(maybe_valid_pos_cap_locs(idxMode)), B2B(idxMode), 'rx');
            lab{end+1} = 'rejected by B2B mode/median QC';
        end
    end

    if exist('idx_deleted_B2B_flat', 'var') && ~isempty(idx_deleted_B2B_flat)
        idxFlat = idx_deleted_B2B_flat;
        idxFlat = idxFlat(idxFlat >= 1 & idxFlat <= numel(B2B));

        if ~isempty(idxFlat)
            h(end+1) = plot(t(maybe_valid_pos_cap_locs(idxFlat)), B2B(idxFlat), 'cx');
            lab{end+1} = 'rejected by flat-segment QC';
        end
    end

    xlabel('Time [s]')
    ylabel('B2B [s]')
    title(sprintf(['QC layer 2: B2B/P2P filtering -> affects B2B_valid, ', ...
        'mean/median B2B, SD, RMSSD, LF/HF. %d valid, %d rejected, median %.2f s'], ...
        numel(B2B_valid), numel(idx_deleted_B2B_all), median_B2B_valid), ...
        'Interpreter', 'none');

    if ~isempty(h)
        legend(h, lab, 'Location', 'Best');
    end

    %% --------------------------------------------------------------------
    % Previous diagnostic plot 1: B2B histogram
    % ---------------------------------------------------------------------
    subplot(4,4,9)

    h = [];
    lab = {};

    b2bAll = B2B(idx_B2B_candidates);
    b2bAll = b2bAll(isfinite(b2bAll));

    b2bVal = B2B_valid;
    b2bVal = b2bVal(isfinite(b2bVal));

    if ~isempty(b2bAll)
        minEdge = min(b2bAll);
        maxEdge = max(b2bAll);

        if minEdge == maxEdge
            minEdge = minEdge - 0.5;
            maxEdge = maxEdge + 0.5;
        end

        edges = linspace(minEdge, maxEdge, 30);

        [nAll, cAll] = hist(b2bAll, edges);
        h(end+1) = plot(cAll, nAll, 'Color', [0.5 0.5 0.5]); hold on
        lab{end+1} = 'all candidate B2B';

        if ~isempty(b2bVal)
            [nVal, cVal] = hist(b2bVal, edges);
            h(end+1) = plot(cVal, nVal, 'm');
            lab{end+1} = 'B2B_valid';
        end
    end

    xlabel('B2B [s]')
    ylabel('Count')
    title(sprintf('Diagnostic: B2B distribution. %d candidate, %d valid', ...
        numel(b2bAll), numel(b2bVal)), ...
        'Interpreter', 'none');

    if ~isempty(h)
        legend(h, lab, 'Location', 'Best');
    end

    %% --------------------------------------------------------------------
    % Previous diagnostic plot 2: B2B bpm boxplot
    % ---------------------------------------------------------------------
    subplot(4,4,10)

    h = [];
    lab = {};

    if ~isempty(B2B_valid_bpm)
        boxplot(B2B_valid_bpm(:)); hold on

        h(end+1) = plot(nan, nan, 'b-');
        lab{end+1} = 'boxplot of B2B_valid_bpm';

        h(end+1) = plot(ones(size(B2B_valid_bpm(:))), B2B_valid_bpm(:), 'k.', ...
            'MarkerSize', 4);
        lab{end+1} = 'individual valid breaths';

        ylabel('Breaths/min')
        title(sprintf('Diagnostic: B2B bpm. mean %.1f, median %.1f, SD %.1f', ...
            mean_B2B_valid_bpm, median_B2B_valid_bpm, std_B2B_valid_bpm), ...
            'Interpreter', 'none');
    else
        title('Diagnostic: B2B bpm boxplot. No valid B2B', 'Interpreter', 'none')
    end

    if ~isempty(h)
        legend(h, lab, 'Location', 'Best');
    end

    %% --------------------------------------------------------------------
    % Previous diagnostic plot 3: Poincare plot
    % ---------------------------------------------------------------------
    subplot(4,4,11)

    h = [];
    lab = {};

    if numel(B2B_valid_bpm) >= 2
        xP = B2B_valid_bpm(1:end-1);
        yP = B2B_valid_bpm(2:end);

        h(end+1) = plot(xP, yP, '.', 'Color', [0.45 0.25 0.40]); hold on
        lab{end+1} = 'successive B2B pairs';

        minP = min([xP(:); yP(:)]);
        maxP = max([xP(:); yP(:)]);

        if minP == maxP
            minP = minP - 1;
            maxP = maxP + 1;
        end

        h(end+1) = plot([minP maxP], [minP maxP], 'k:');
        lab{end+1} = 'identity line';

        xlabel('B2B(n) [breaths/min]')
        ylabel('B2B(n+1) [breaths/min]')
        title('Diagnostic: Poincare plot of B2B_valid_bpm', ...
            'Interpreter', 'none')
    else
        title('Diagnostic: Poincare plot. Not enough valid B2B', ...
            'Interpreter', 'none')
    end

    if ~isempty(h)
        legend(h, lab, 'Location', 'Best');
    end

    %% --------------------------------------------------------------------
    % Previous diagnostic plot 4: respiration spectrum
    % ---------------------------------------------------------------------
    subplot(4,4,12)

    h = [];
    lab = {};

    if ~isempty(Pxx) && ~isempty(freq)
        h(end+1) = plot(freq, Pxx, 'k-'); hold on
        lab{end+1} = 'total spectrum';

        idxVLF = freq >= 0 & freq < 0.04;
        idxLF  = freq >= 0.04 & freq < 0.15;
        idxHF  = freq >= 0.15 & freq <= 0.50;

        if any(idxVLF)
            h(end+1) = plot(freq(idxVLF), Pxx(idxVLF), 'b-', 'LineWidth', 1.5);
            lab{end+1} = 'VLF band';
        end

        if any(idxLF)
            h(end+1) = plot(freq(idxLF), Pxx(idxLF), 'r-', 'LineWidth', 1.5);
            lab{end+1} = 'LF band';
        end

        if any(idxHF)
            h(end+1) = plot(freq(idxHF), Pxx(idxHF), 'g-', 'LineWidth', 1.5);
            lab{end+1} = 'HF band';
        end

        xlabel('Hz')
        ylabel('Power')
        title(sprintf('Diagnostic: spectrum. VLF %.1f, LF %.1f, HF %.1f', ...
            vlfPower, lfPower, hfPower), ...
            'Interpreter', 'none');
    else
        title('Diagnostic: respiration spectrum. Not enough valid B2B', ...
            'Interpreter', 'none');
    end

    if ~isempty(h)
        legend(h, lab, 'Location', 'Best');
    end

    %% --------------------------------------------------------------------
    % Plot 3: respiration-only badBreath QC
    % ---------------------------------------------------------------------
    subplot(4,4,13:16)

    h = [];
    lab = {};

    breathIdx = 1:resp_qc.nBreaths;

    if ~isempty(resp_qc.respRate_bpm_perBreath)
        h(end+1) = plot(breathIdx, resp_qc.respRate_bpm_perBreath, 'k.'); hold on
        lab{end+1} = 'all breaths entering respiration-only QC';
    else
        hold on
    end

    if isfield(resp_qc, 'badBreath_detected') && ~isempty(resp_qc.badBreath_detected)
        badDetected = resp_qc.badBreath_detected(:);
    else
        badDetected = resp_qc.badBreath(:);
    end

    badApplied = resp_qc.badBreath(:);

    if any(badDetected)
        h(end+1) = plot(find(badDetected), ...
            resp_qc.respRate_bpm_perBreath(badDetected), ...
            'o', 'Color', [1.0 0.5 0.0], 'MarkerSize', 5);
        lab{end+1} = 'detected by respiration-only badBreath criteria';
    end

    if any(badApplied)
        h(end+1) = plot(find(badApplied), ...
            resp_qc.respRate_bpm_perBreath(badApplied), ...
            'rx', 'MarkerSize', 8, 'LineWidth', 1.5);
        lab{end+1} = 'applied badBreath mask';
    end

    xlabel('Breath number')
    ylabel('Respiration rate [breaths/min]')

    if isfield(resp_qc, 'applyRespBadBreathCriteria') && ...
            ~isempty(resp_qc.applyRespBadBreathCriteria) && ...
            ~resp_qc.applyRespBadBreathCriteria
        qcModeText = 'diagnostic only';
    else
        qcModeText = 'applied to resp_qc summaries';
    end

    title(sprintf(['QC layer 3: respiration-only badBreath QC (%s) -> affects resp_qc fields ', ...
        'and later cardioresp QC; B2B_valid/CAP summary variables unchanged. %d/%d applied bad breaths'], ...
        qcModeText, resp_qc.nBadBreaths, resp_qc.nBreaths), ...
        'Interpreter', 'none');

    if ~isempty(h)
        legend(h, lab, 'Location', 'Best');
    end

    out.hf = hf;
end

% -------------------------------------------------------------------------
% Final output
% -------------------------------------------------------------------------
if numel(B2B_valid) < Set.B2B_minValidData || isempty(B2B_valid)
    [out, Tab_outlier] = finalize_empty_output( ...
        out, Tab_outlier, resp_qc, Set, i_block, NrBlock);
else
    out.Rpeak_t                 = t(R_valid_locs);
    out.Rpeak_sample            = R_valid_locs;
    out.B2B_t                   = t(B2B_valid_locs);
    out.B2B_sample              = B2B_valid_locs;
    out.B2B_valid               = B2B_valid;
    out.B2B_valid_bpm           = B2B_valid_bpm;
    out.B2B_valid_ms            = B2B_valid_ms;
    out.inspStart_t             = t_valid_inspStart;
    out.inspEnd_t               = t_valid_inspEnd;
    out.expStart_t              = t_valid_expStart;
    out.expEnd_t                = t_valid_expEnd;
    out.duration_insp_valid     = duration_insp_valid;
    out.duration_exp_valid      = duration_exp_valid;

    % New respiration-only QC variables
    out.breathDur_s             = resp_qc.breathDur_s;
    out.inspDur_s               = resp_qc.inspDur_s;
    out.expDur_s                = resp_qc.expDur_s;
    out.respRate_bpm_perBreath  = resp_qc.respRate_bpm_perBreath;
    out.inspFrac_perBreath      = resp_qc.inspFrac_perBreath;
    out.meanRespRate_bpm        = resp_qc.meanRespRate_bpm;
    out.medianRespRate_bpm      = resp_qc.medianRespRate_bpm;
    out.medianBreathDur_s       = resp_qc.medianBreathDur_s;
    out.medianInspFrac          = resp_qc.medianInspFrac;
    out.resp_qc                 = resp_qc;

    out.idx_valid_B2B_consec    = idx_valid_B2B_consec;
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
    out.session_index           = i_block;
    out.nrblock                 = NrBlock;
    out.nrblock_combinedFiles   = NrBlock;
end
% -------------------------------------------------------------------------
% Store respiration time series for later RSA visualization
% -------------------------------------------------------------------------
out.resp_plotData = struct();

out.resp_plotData.t_s = t(:);
out.resp_plotData.capSignal_raw = capSignal(:);
out.resp_plotData.capSignal_filtered = capFiltered_rectified(:);

out.resp_plotData.inspStart_s = out.inspStart_t(:);
out.resp_plotData.inspEnd_s   = out.inspEnd_t(:);
out.resp_plotData.expStart_s  = out.expStart_t(:);
out.resp_plotData.expEnd_s    = out.expEnd_t(:);

out.settingsStruct = Set.cap;
out.codeTimestamp = datestr(now, 30);

end

% =========================================================================
% Helper functions
% =========================================================================

function out = initialize_empty_resp_output()
out = struct();
out.hf = [];
out.Rpeak_t = [];
out.Rpeak_sample = [];
out.B2B_t = [];
out.B2B_sample = [];
out.B2B_valid = [];
out.B2B_valid_bpm = [];
out.B2B_valid_ms = [];
out.inspStart_t = [];
out.inspEnd_t = [];
out.expStart_t = [];
out.expEnd_t = [];
out.duration_insp_valid = [];
out.duration_exp_valid = [];
out.idx_valid_B2B_consec = [];
out.mean_B2B_valid_bpm = NaN;
out.median_B2B_valid_bpm = NaN;
out.std_B2B_valid_bpm = NaN;
out.std_B2B_valid_ms = NaN;
out.rmssd_B2B_valid_ms = NaN;
out.rmssd_B2B_valid_bpm = NaN;
out.Pxx = [];
out.freq = [];
out.vlfPower = NaN;
out.lfPower = NaN;
out.hfPower = NaN;
out.totPower = NaN;
out.nrblock = [];
out.nrblock_combinedFiles = [];
out.session_index = [];
out.breathDur_s = [];
out.inspDur_s = [];
out.expDur_s = [];
out.respRate_bpm_perBreath = [];
out.inspFrac_perBreath = [];
out.meanRespRate_bpm = NaN;
out.medianRespRate_bpm = NaN;
out.medianBreathDur_s = NaN;
out.medianInspFrac = NaN;
out.resp_qc = [];
out.resp_plotData = [];
end

function Tab_outlier = initialize_empty_Tab_outlier()
Tab_outlier = struct( ...
    'outlier', [], ...
    'NrRpeaks_orig', [], ...
    'outlier_Mode_abs', [], ...
    'outlier_Mode_pct', [], ...
    'outliers_delete_abs', [], ...
    'NrPeaks_valid', [], ...
    'NrB2B_valid', [], ...
    'outliers_all_abs', [], ...
    'outliers_all_pct', [], ...
    'median_duration_insp', [], ...
    'median_duration_exp', [], ...
    'numSkippedInspSegments', [], ...
    'skippedInspTimes', [], ...
    'skippedInspDurations', [], ...
    'numValidPeaksNoInspEnd', [], ...
    'validPeaksNoInspEndTimes', [], ...
    'numValidInsp', [], ...
    'totalCandidatesInsp', [], ...
    'numInvalidInsp', [], ...
    'numInvalidExp', [], ...
    'B2B_consec', [], ...
    'durationRun_s', [], ...
    'duration_NotValidSegments_s', [], ...
    'session_index', [], ...
    'nrblock', [], ...
    'nrblock_combinedFiles', [], ...
    'idx_deleted_B2B_all', [], ...
    'idx_deleted_B2B_mode', [], ...
    'idx_deleted_B2B_flat', [], ...
    'NrB2B_beforehampel', [], ...
    'resp_qc_nBreaths', [], ...
    'resp_qc_nBadBreaths', [], ...
    'resp_qc_fracBadBreath', [], ...
    'resp_qc_idx_badBreath', [], ...
    'resp_qc_idx_badBreath_nan', [], ...
    'resp_qc_idx_badBreath_order', [], ...
    'resp_qc_idx_badBreath_abs', [], ...
    'resp_qc_idx_badBreath_global', [], ...
    'resp_qc_idx_badBreath_local', [], ...
    'resp_qc_medianRespRate_bpm', [], ...
    'resp_qc_meanRespRate_bpm', [], ...
    'resp_qc_medianBreathDur_s', [], ...
    'resp_qc_medianInspFrac', [], ...
    'resp_qc_lowAmpSegments_s', [], ...
    'resp_qc_flatSegments_s', [], ...
    'resp_qc_nLowAmpSegments', [], ...
    'resp_qc_nFlatSegments', [], ...
    'resp_qc_durationLowAmp_s', [], ...
    'resp_qc_durationFlat_s', []);
end

function resp_qc = initialize_empty_resp_qc()
resp_qc = struct();
resp_qc.badBreath = [];
resp_qc.goodBreath = [];
resp_qc.badBreath_nan = [];
resp_qc.badBreath_order = [];
resp_qc.badBreath_abs = [];
resp_qc.badBreath_global = [];
resp_qc.badBreath_local = [];
resp_qc.breathStart_t = [];
resp_qc.breathEnd_t = [];
resp_qc.breathDur_s = [];
resp_qc.inspDur_s = [];
resp_qc.expDur_s = [];
resp_qc.respRate_bpm_perBreath = [];
resp_qc.inspFrac_perBreath = [];
resp_qc.nBreaths = 0;
resp_qc.nBadBreaths = 0;
resp_qc.fracBadBreath = NaN;
resp_qc.medianRespRate_bpm = NaN;
resp_qc.meanRespRate_bpm = NaN;
resp_qc.medianBreathDur_s = NaN;
resp_qc.medianInspFrac = NaN;
resp_qc.lowAmpSegments_s = [];
resp_qc.flatSegments_s = [];
resp_qc.nLowAmpSegments = 0;
resp_qc.nFlatSegments = 0;
resp_qc.durationLowAmp_s = 0;
resp_qc.durationFlat_s = 0;
end

function [resp_qc, Tab_outlier] = compute_respiration_only_qc(resp_qc, Tab_outlier, inspStart, inspEnd, expStart, expEnd, lowAmpSegments_s, flatSegments_s)

respRateLimits_bpm = [5 120];
inspFracLimits = [0.10 0.90];
globalMadK = 6;
localMadK = 6;
localWindow = 21;
minLocalBreathDurMAD_s = 0.05;

inspStart = inspStart(:);
inspEnd = inspEnd(:);
expStart = expStart(:);
expEnd = expEnd(:);

nBreaths = numel(inspStart);

breathDur_s = expEnd - inspStart;
inspDur_s = inspEnd - inspStart;
expDur_s = expEnd - expStart;
respRate_bpm_perBreath = 60 ./ breathDur_s;
inspFrac_perBreath = (expStart - inspStart) ./ breathDur_s;

badBreath_nan = ...
    isnan(inspStart) | isnan(inspEnd) | isnan(expStart) | isnan(expEnd) | ...
    ~isfinite(inspStart) | ~isfinite(inspEnd) | ~isfinite(expStart) | ~isfinite(expEnd);

badBreath_order = ...
    inspEnd <= inspStart | ...
    expStart < inspEnd | ...
    expEnd <= expStart;

badBreath_abs = ...
    breathDur_s <= 0 | ...
    inspDur_s <= 0 | ...
    expDur_s <= 0 | ...
    respRate_bpm_perBreath < respRateLimits_bpm(1) | ...
    respRate_bpm_perBreath > respRateLimits_bpm(2) | ...
    inspFrac_perBreath < inspFracLimits(1) | ...
    inspFrac_perBreath > inspFracLimits(2) | ...
    ~isfinite(respRate_bpm_perBreath) | ...
    ~isfinite(inspFrac_perBreath);

badBreath_global = false(nBreaths, 1);
validForStats = ~(badBreath_nan | badBreath_order | badBreath_abs);

breathDur_valid = breathDur_s(validForStats);
respRate_valid = respRate_bpm_perBreath(validForStats);

if ~isempty(breathDur_valid)
    medDur = nanmedian(breathDur_valid);
    madDur = nanmedian(abs(breathDur_valid - medDur));
    if isfinite(madDur) && madDur > 0
        badBreath_global = badBreath_global | abs(breathDur_s - medDur) > globalMadK * madDur;
    end
end

if ~isempty(respRate_valid)
    medRate = nanmedian(respRate_valid);
    madRate = nanmedian(abs(respRate_valid - medRate));
    if isfinite(madRate) && madRate > 0
        badBreath_global = badBreath_global | abs(respRate_bpm_perBreath - medRate) > globalMadK * madRate;
    end
end

badBreath_local = false(nBreaths, 1);
if nBreaths >= localWindow
    localMedDur = movmedian(breathDur_s, localWindow, 'omitnan');
    localAbsDev = abs(breathDur_s - localMedDur);
    localMadDur = movmedian(localAbsDev, localWindow, 'omitnan');
    globalDurMAD = nanmedian(abs(breathDur_s - nanmedian(breathDur_s)));

    if ~isfinite(globalDurMAD) || globalDurMAD <= 0
        globalDurMAD = minLocalBreathDurMAD_s;
    end

    localMadDur(localMadDur < minLocalBreathDurMAD_s) = max(globalDurMAD, minLocalBreathDurMAD_s);
    badBreath_local = abs(breathDur_s - localMedDur) > localMadK * localMadDur;
end

badBreath = badBreath_nan | badBreath_order | badBreath_abs | badBreath_global | badBreath_local;
goodBreath = ~badBreath;

resp_qc.badBreath = badBreath;
resp_qc.goodBreath = goodBreath;
resp_qc.badBreath_nan = badBreath_nan;
resp_qc.badBreath_order = badBreath_order;
resp_qc.badBreath_abs = badBreath_abs;
resp_qc.badBreath_global = badBreath_global;
resp_qc.badBreath_local = badBreath_local;
resp_qc.breathStart_t = inspStart;
resp_qc.breathEnd_t = expEnd;
resp_qc.breathDur_s = breathDur_s;
resp_qc.inspDur_s = inspDur_s;
resp_qc.expDur_s = expDur_s;
resp_qc.respRate_bpm_perBreath = respRate_bpm_perBreath;
resp_qc.inspFrac_perBreath = inspFrac_perBreath;
resp_qc.nBreaths = nBreaths;
resp_qc.nBadBreaths = sum(badBreath);
resp_qc.fracBadBreath = mean(badBreath);
resp_qc.medianRespRate_bpm = nanmedian(respRate_bpm_perBreath(goodBreath));
resp_qc.meanRespRate_bpm = nanmean(respRate_bpm_perBreath(goodBreath));
resp_qc.medianBreathDur_s = nanmedian(breathDur_s(goodBreath));
resp_qc.medianInspFrac = nanmedian(inspFrac_perBreath(goodBreath));
resp_qc.lowAmpSegments_s = lowAmpSegments_s;
resp_qc.flatSegments_s = flatSegments_s;
resp_qc.nLowAmpSegments = size(lowAmpSegments_s, 1);
resp_qc.nFlatSegments = size(flatSegments_s, 1);
if isempty(lowAmpSegments_s)
    resp_qc.durationLowAmp_s = 0;
else
    resp_qc.durationLowAmp_s = ...
        sum(lowAmpSegments_s(:, 2) - lowAmpSegments_s(:, 1));
end
if isempty(flatSegments_s)
    resp_qc.durationFlat_s = 0;
else
    resp_qc.durationFlat_s = ...
        sum(flatSegments_s(:, 2) - flatSegments_s(:, 1));
end
resp_qc.medianInspDur_s = nanmedian(inspDur_s(goodBreath));
resp_qc.medianExpDur_s  = nanmedian(expDur_s(goodBreath));
resp_qc.meanInspDur_s = nanmean(inspDur_s(goodBreath));
resp_qc.meanExpDur_s  = nanmean(expDur_s(goodBreath));

Tab_outlier.resp_qc_nBreaths = nBreaths;
Tab_outlier.resp_qc_nBadBreaths = resp_qc.nBadBreaths;
Tab_outlier.resp_qc_fracBadBreath = resp_qc.fracBadBreath;
Tab_outlier.resp_qc_idx_badBreath = find(badBreath);
Tab_outlier.resp_qc_idx_badBreath_nan = find(badBreath_nan);
Tab_outlier.resp_qc_idx_badBreath_order = find(badBreath_order);
Tab_outlier.resp_qc_idx_badBreath_abs = find(badBreath_abs);
Tab_outlier.resp_qc_idx_badBreath_global = find(badBreath_global);
Tab_outlier.resp_qc_idx_badBreath_local = find(badBreath_local);
Tab_outlier.resp_qc_medianRespRate_bpm = resp_qc.medianRespRate_bpm;
Tab_outlier.resp_qc_meanRespRate_bpm = resp_qc.meanRespRate_bpm;
Tab_outlier.resp_qc_medianBreathDur_s = resp_qc.medianBreathDur_s;
Tab_outlier.resp_qc_medianInspFrac = resp_qc.medianInspFrac;
Tab_outlier.resp_qc_lowAmpSegments_s = lowAmpSegments_s;
Tab_outlier.resp_qc_flatSegments_s = flatSegments_s;
Tab_outlier.resp_qc_nLowAmpSegments = resp_qc.nLowAmpSegments;
Tab_outlier.resp_qc_nFlatSegments = resp_qc.nFlatSegments;
Tab_outlier.resp_qc_durationLowAmp_s = resp_qc.durationLowAmp_s;
Tab_outlier.resp_qc_durationFlat_s = resp_qc.durationFlat_s;

end

function [out, Tab_outlier] = finalize_empty_output(out, Tab_outlier, resp_qc, Set, i_block, NrBlock)
out.Rpeak_t = [];
out.Rpeak_sample = [];
out.B2B_t = [];
out.B2B_sample = [];
out.B2B_valid = [];
out.B2B_valid_bpm = [];
out.B2B_valid_ms = [];
out.inspStart_t = [];
out.inspEnd_t = [];
out.expStart_t = [];
out.expEnd_t = [];
out.duration_insp_valid = [];
out.duration_exp_valid = [];
out.idx_valid_B2B_consec = [];
out.mean_B2B_valid_bpm = NaN;
out.median_B2B_valid_bpm = NaN;
out.std_B2B_valid_bpm = NaN;
out.std_B2B_valid_ms = NaN;
out.rmssd_B2B_valid_ms = NaN;
out.rmssd_B2B_valid_bpm = NaN;
out.Pxx = [];
out.freq = [];
out.vlfPower = NaN;
out.lfPower = NaN;
out.hfPower = NaN;
out.totPower = NaN;
out.session_index = i_block;
out.nrblock = NrBlock;
out.nrblock_combinedFiles = NrBlock;
out.breathDur_s = [];
out.inspDur_s = [];
out.expDur_s = [];
out.respRate_bpm_perBreath = [];
out.inspFrac_perBreath = [];
out.meanRespRate_bpm = NaN;
out.medianRespRate_bpm = NaN;
out.medianBreathDur_s = NaN;
out.medianInspFrac = NaN;
out.resp_qc = resp_qc;
out.settingsStruct = Set.cap;
out.codeTimestamp = datestr(now, 30);
Tab_outlier.session_index = i_block;
Tab_outlier.nrblock = NrBlock;
Tab_outlier.nrblock_combinedFiles = NrBlock;
out.resp_plotData = [];
end

function printAnalysisSummary(Tab_outlier, IE_ratio, verbose, indicesToZero, capSignal, idx_Invalid_B2B_FlatRegion, t, maybe_valid_pos_cap_locs)

if ~verbose
    return
end

fprintf('\n=== Respiration Analysis Summary ===\n');

fprintf('\nBlock Information:\n');
fprintf('  - Session index: %d\n', Tab_outlier.session_index);
fprintf('  - Current block: %d\n', Tab_outlier.nrblock);
fprintf('  - Combined files block: %d\n', Tab_outlier.nrblock_combinedFiles);
fprintf('  - Total run duration: %.1f s\n', Tab_outlier.durationRun_s);

if isfinite(Tab_outlier.duration_NotValidSegments_s) && isfinite(Tab_outlier.durationRun_s) && Tab_outlier.durationRun_s > 0
    fprintf('  - Valid data percentage: %.1f%%\n', ...
        (1 - Tab_outlier.duration_NotValidSegments_s / Tab_outlier.durationRun_s) * 100);
end

fprintf('\nInvalid Segments Analysis:\n');

if ~isempty(indicesToZero)
    idx = indicesToZero(:);
    bounds = [1; find(diff(idx) ~= 1) + 1; numel(idx) + 1];
    segments = [bounds(1:end-1), bounds(2:end)-1];
    num_segments = size(segments, 1);
    total_duration = length(indicesToZero) / length(capSignal) * 100;

    fprintf('  KK1 Low Amplitude:\n');
    fprintf('    - Number of segments: %d\n', num_segments);
    fprintf('    - Total duration: %.1f%% of signal\n', total_duration);
end

if ~isempty(idx_Invalid_B2B_FlatRegion)
    num_flat_segments = length(idx_Invalid_B2B_FlatRegion);
    total_flat_duration = 0;

    for i = 1:length(idx_Invalid_B2B_FlatRegion)
        idx = idx_Invalid_B2B_FlatRegion(i);
        if idx > 1 && idx <= length(maybe_valid_pos_cap_locs)
            t_start = t(maybe_valid_pos_cap_locs(idx - 1));
            t_end   = t(maybe_valid_pos_cap_locs(idx));
            total_flat_duration = total_flat_duration + (t_end - t_start);
        end
    end

    flat_duration_percent = (total_flat_duration / t(end)) * 100;

    fprintf('  KK4 Flat Segments:\n');
    fprintf('    - Number of segments: %d\n', num_flat_segments);
    fprintf('    - Total duration: %.1f%% of signal\n', flat_duration_percent);
end

fprintf('\nPeak Analysis:\n');
fprintf('  - Total peaks detected: %d\n', Tab_outlier.NrRpeaks_orig);
fprintf('  - Valid peaks: %d\n', Tab_outlier.NrPeaks_valid);
fprintf('  - Consecutive valid peaks: %d\n', Tab_outlier.B2B_consec);
fprintf('  - Rejected B2B intervals: %d (%.1f%%)\n', ...
    Tab_outlier.outliers_all_abs, Tab_outlier.outliers_all_pct);

fprintf('\nBreath-to-Breath Analysis:\n');
fprintf('  - Valid B2B intervals: %d\n', Tab_outlier.NrB2B_valid);
fprintf('  - Mode/median-based rejected B2B: %d (%.1f%%)\n', ...
    Tab_outlier.outlier_Mode_abs, Tab_outlier.outlier_Mode_pct);
fprintf('  - Total rejected B2B intervals: %d (%.1f%%)\n', ...
    Tab_outlier.outliers_delete_abs, Tab_outlier.outliers_all_pct);

fprintf('\nRespiration-only QC:\n');
fprintf('  - Bad breaths: %d / %d (%.1f%%)\n', ...
    Tab_outlier.resp_qc_nBadBreaths, Tab_outlier.resp_qc_nBreaths, ...
    100 * Tab_outlier.resp_qc_fracBadBreath);
fprintf('  - Median respiration rate: %.2f breaths/min\n', Tab_outlier.resp_qc_medianRespRate_bpm);
fprintf('  - Median inspiration fraction: %.2f\n', Tab_outlier.resp_qc_medianInspFrac);

fprintf('\nBreathing Pattern:\n');
fprintf('  - I:E Ratio: %.2f\n', IE_ratio);
fprintf('  - Median inspiration duration: %.2f s\n', Tab_outlier.median_duration_insp);
fprintf('  - Median expiration duration: %.2f s\n', Tab_outlier.median_duration_exp);

fprintf('\n==============================\n\n');
end
