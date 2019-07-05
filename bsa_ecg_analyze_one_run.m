function out = bsa_ecg_analyze_one_run(ecgSignal,Fs,TOPLOT,FigInfo)
%bsa_ecg_analyze_one_run  - analyses ECG in one run/block
%
% USAGE:
% out = bsa_ecg_analyze_one_run(ecgSignal,Fs,1,sprintf('block%02d',r));
%
% INPUTS:
%		ecgSignal		- ECG
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
ecgSignal = double(dat.ECG{5});
%}


if nargin < 3,
    TOPLOT = true;
end


if nargin < 4,
    FigInfo = '';
end

n_samples       = length(ecgSignal);
t               = 0:1/Fs:1/Fs*(n_samples-1); % time axis  -> IMPORTANT: first sample is time 0! (not 1/Fs)

% properties for the ECG detection
min_R2R                         = 0.25; % s
eP_tc_minpeakheight_med_prop    = 0.33; % proportion of median of energyProfile_tc for minpeakheight (when periodic, task related movement noise, use ~0.33, otherwise 1)
MAD_sensitivity_p2p_diff        = 3;
hampel_T                        = 4; % threshold for hamplel outlier detection
segment_length                  = 300; % s (set to 0 if no segmentation) -- segment signal prior to wavelet transform
segment_overlap                 = 50;  % s 


ecgSignal = detrend(ecgSignal);
%% create a butterworth filter order selection
Fn  = Fs/2;                                                 % Nyquist Frequency (Hz)
Wp  = 40/Fn;                                                % Passband Frequency (Normalised)
Ws  = 100/Fn;                                               % Stopband Frequency (Normalised)
Rp  = 1;                                                    % Passband Ripple (dB)
Rs  = 150;                                                  % Stopband Ripple (dB)
[n,Wn]  = buttord(Wp,Ws,Rp,Rs);                             % Filter Order
[z,p,k] = butter(n,Wn);
[sos,g] = zp2sos(z,p,k);

% Filter debug
% freqz(sos,512,Fs);
% title(sprintf('n = %d Butterworth Lowpass Filter',n))

% Filter raw ECG using filtfilt from Matlab
ecgFiltered = filtfilt(sos, g, ecgSignal); 


% Bandbass to isolate artifact
% Wp  = [20 40]/Fn;                                             % Passband Frequency (Normalised)
% Ws  = [15 50]/Fn;                                             % Stopband Frequency (Normalised)
% Rp  = 1;                                                      % Passband Ripple (dB)
% Rs  = 50;                                                     % Stopband Ripple (dB)
% [n,Wn]  = buttord(Wp,Ws,Rp,Rs);                               % Filter Order
% [z,p,k] = butter(n,Wn);
% [sos,g] = zp2sos(z,p,k);
% 
% freqz(sos,512,Fs);
% title(sprintf('n = %d Butterworth Filter',n))
% 
% ecgFiltered_artifact = filtfilt(sos, g, ecgSignal); 


if 0 % Debug
    figure ('Name','Single-sided amplitude spectrum');
    ft_original = fft(ecgSignal)/n_samples;         % Fourier Transform
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


rangeOfInterest = [1 12]; % Hz
% prepare parameters for the wavelet transform: we expect our heart rate to be in certain range
minFreq = rangeOfInterest(1);
maxFreq = rangeOfInterest(2);
scalesPerDecade = 32;

waveName = {'morl', []};
% we ignore components outside of the doubled range of interest
sca = wavelet_init_scales(minFreq/2, 2*maxFreq, scalesPerDecade);

if ~segment_length || t(end) < segment_length, % process entire block at once - can be very slow for large blocks
    sig = struct('val',ecgFiltered, 'period', 1/Fs);
       
    energyProfile_tc = get_energy_profile(sig,waveName,sca);
    n_segments = 0;
    
else % chop to segments
    n_segment = round2(segment_length*Fs,2); % round to even
    n_overlap = round2(segment_overlap*Fs,2);
    % energyProfile_tc = zeros(1,n_samples);
    
    seg_ind = buffer(1:n_samples,n_segment,n_overlap,'nodelay');
    n_segments = size(seg_ind,2);
    disp(sprintf('chopping to %d segments of %.1f s with %.1f s overlap',n_segments,segment_length,segment_overlap));
    for s = 1:n_segments, % for each segment
        ind = seg_ind(:,s);
        ind = ind(ind>0); % only important for the last segment
        sig = struct('val',ecgFiltered(ind), 'period', 1/Fs);
        energyProfile_tc_segm = get_energy_profile(sig,waveName,sca);
        if s == 1, % first segment
            energyProfile_tc = energyProfile_tc_segm(1:end - n_overlap/2);
        elseif s<n_segments,
            energyProfile_tc = [energyProfile_tc energyProfile_tc_segm(n_overlap/2+1:end - n_overlap/2)];
        else % last segment
            energyProfile_tc = [energyProfile_tc energyProfile_tc_segm(n_overlap/2+1:end)];
        end
        
%         if s == size(seg_ind,2)-1, % one before last segment
%             ind_last = seg_ind(:,s+1);
%             ind_last = ind_last(ind_last>0);
%             if numel(ind_last) < fix(segment_length*Fs)/3, % last segment is shorter than 1/3 of desired segment length
%                 ind = [ind; ind_last]; % add last short segment to the previous segment
%             end
%         end
        
    end
end
    




% Find spectrum of energyProfile
% ft_energyProfile_tc = fft(energyProfile_tc - mean(energyProfile_tc))/n_samples;         % Fourier Transform
% Fv = linspace(0, 1, fix(n_samples/2)+1)*Fn;     % Frequency Vector
% Fv = Fv(Fv<60); % limit to 60 Hz
% figure; plot(Fv, abs(ft_energyProfile_tc(1:length(Fv)))*2,'b'); hold on

% Filter energyProfile
% [z p k] = butter(4, [2 10]/(Fs/2), 'stop');
% [sos,g]=zp2sos(z,p,k); % Convert to 2nd order sections form
% freqz(sos,512,Fs); % check filter
% energyProfile_tc_filt = filtfilt(sos, g, energyProfile_tc); 

% all kinds of smoothing attempts
% energyProfile_tc_smoothed = smooth(energyProfile_tc,fix(Fs))';
% energyProfile_tc_smoothed_1 = smooth(energyProfile_tc,fix(Fs)/2,'loess')';
% plot(t,energyProfile_tc_smoothed,'g'); hold on
% plot(t,energyProfile_tc_smoothed_1,'k'); hold on
% plot(t,energyProfile_tc - energyProfile_tc_smoothed,'r');

range_energyProfile_tc = max(energyProfile_tc) - min(energyProfile_tc);
[pks,locs]=findpeaks(energyProfile_tc,'threshold',eps,'minpeakdistance',fix(min_R2R*Fs),'minpeakheight',eP_tc_minpeakheight_med_prop*median(energyProfile_tc));


diff_peaks = [0 abs(diff(pks))];


% remove outliers based on the difference between peaks
[data_wo_outliers,idx_wo_outliers,outliers,idx_outliers,thresholdValue] = bsa_remove_outliers(diff_peaks,MAD_sensitivity_p2p_diff);


appr_ecg_peak2peak_n_samples = mode(abs(diff(locs(idx_wo_outliers)))); % rough number of samples between ecg R peaks

%% ??
ecgFiltered_pos = max(ecgFiltered,0);
[pos_ecg_pks,pos_ecg_locs]=findpeaks(ecgFiltered_pos,'threshold',eps,'minpeakdistance',fix(min_R2R*Fs));

% find ecg peaks closest (in time) to valid energyProfile_tc peaks, within search_segment_n_samples
search_segment_n_samples = fix(appr_ecg_peak2peak_n_samples/20);

%% seems to be an important step
maybe_valid_pos_ecg_locs = [];
for p = 1:length(idx_wo_outliers)
    idx_overlap = intersect( pos_ecg_locs, locs(idx_wo_outliers(p))-search_segment_n_samples : locs(idx_wo_outliers(p))+search_segment_n_samples );
    
    if ~isempty(idx_overlap)
        maybe_valid_pos_ecg_locs = [maybe_valid_pos_ecg_locs idx_overlap(end)];
    end
    
end

%% R2R intervals
R2R             = [NaN diff(t(maybe_valid_pos_ecg_locs))]; % 
median_R2R      = median(R2R);
mode_R2R        = mode(R2R);
[hist_R2R,bins] = hist(R2R,[min_R2R:0.01:1]);


% invalidate all R2R less than 0.66 of mode and more than 1.5 of mode
idx_valid_R2R = find((R2R>0.66*mode_R2R & R2R<1.5*mode_R2R));

t_valid_R2R = t(maybe_valid_pos_ecg_locs(idx_valid_R2R));
R2R_valid_before_hamplel = R2R(idx_valid_R2R);

%% remove outliers from R2R
%That is, a data point is declared an outlier and replaced if it lies more 
% than some number t of MAD scale estimates from the median of its neighbors; 
% the replacement value used in this procedure is the median.
% [YY, I, Y0, LB, UB, ADX, NO] = hampel(X, Y, DX, T, varargin)
% Why T =10? 
% why hampel_T of 4?
[YY,idx_outliers_hampel] = hampel(t_valid_R2R,R2R_valid_before_hamplel,10,hampel_T);
idx_to_delete = [];
idx_to_delete_after_outliers = [];

if sum(idx_outliers_hampel), % there are outliers
    
    idx_outliers_hampel = find(idx_outliers_hampel); % convert to numbers
    for k = 1:length(idx_outliers_hampel),
        idx_to_delete = [idx_to_delete idx_outliers_hampel(k)];
        
        if idx_outliers_hampel(k)+1 <= length(idx_valid_R2R), % outlier not last R2R
            if t_valid_R2R(idx_outliers_hampel(k)+1) - t_valid_R2R(idx_outliers_hampel(k)) < 1.5*mode_R2R,
                idx_to_delete = [idx_to_delete idx_outliers_hampel(k)+1];
                idx_to_delete_after_outliers = [idx_to_delete_after_outliers idx_outliers_hampel(k)+1];
                
            end
            
        end
        
    end
    idx_valid_R2R(idx_to_delete) = []; % delete outliers, and also next R2R after each outlier, if it is consecutive
    
end

%R-peaks
idx_valid_R = unique([idx_valid_R2R idx_valid_R2R-1]); % add start of each valid R2R interval to valid R peaks
R_valid_locs = maybe_valid_pos_ecg_locs(idx_valid_R);
%R2Rinterval
R2R_valid_locs  = maybe_valid_pos_ecg_locs(idx_valid_R2R);
R2R_valid       = R2R(idx_valid_R2R);

%%  CALCULATE VARIABLES
median_R2R_valid        = median(R2R_valid);
mode_R2R_valid          = mode(R2R_valid);
[hist_R2R_valid,bins]   = hist(R2R_valid,bins);

R2R_valid_bpm           = 60./R2R_valid;
mean_R2R_valid_bpm      = mean(R2R_valid_bpm);
median_R2R_valid_bpm    = median(R2R_valid_bpm);
std_R2R_valid_bpm       = std(R2R_valid_bpm);


% find consecutive R2Rs
idx_valid_R2R_consec = find([NaN diff(t(R2R_valid_locs))]<1.5*mode_R2R_valid);
R2R_valid_bpm_consec = R2R_valid_bpm(idx_valid_R2R_consec);

% RMSSD ("root mean square of successive differences")
% the square root of the mean of the squares of the successive differences between ***adjacent*** intervals
R2R_diff = diff(R2R_valid);
R2R_bpm_diff = diff(R2R_valid_bpm);

rmssd_R2R_valid_bpm     = sqrt(mean(R2R_bpm_diff(idx_valid_R2R_consec-1).^2));
rmssd_R2R_valid_ms      = sqrt(mean((1000*R2R_diff(idx_valid_R2R_consec-1)).^2));

R2R_valid_spectrum = false;
if length(R2R_valid_locs)>1,
    R2R_valid_spectrum = true;
    % BPS spectrum
    % https://de.mathworks.com/matlabcentral/answers/143654-need-an-example-for-calculating-power-spectrum-density
    resampling_rate = 5; % Hz
    t_interp = t(R2R_valid_locs(1)):1/resampling_rate:t(R2R_valid_locs(end));

    BPS = interp1(t(R2R_valid_locs),R2R_valid,t_interp,'linear');

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

% output

if length(R2R_valid) < 100,
    out.Rpeak_t                 = NaN;
    out.Rpeak_sample            = NaN;
    out.R2R_t                   = NaN;
    out.R2R_sample              = NaN;   
    out.R2R_valid               = NaN;
    out.R2R_valid_bpm           = NaN;
    out.idx_valid_R2R_consec    = NaN;
    out.mean_R2R_valid_bpm      = NaN;
    out.median_R2R_valid_bpm    = NaN;
    out.std_R2R_valid_bpm       = NaN;
    out.rmssd_R2R_valid_ms      = NaN;
    out.rmssd_R2R_valid_bpm     = NaN;
    out.Pxx                     = NaN;
    out.freq                    = NaN;
    out.vlfPower                = NaN;
    out.lfPower                 = NaN;
    out.hfPower                 = NaN;
    out.totPower                = NaN;
else
    out.Rpeak_t                 = t(R_valid_locs);
    out.Rpeak_sample            = R_valid_locs;
    out.R2R_t                   = t(R2R_valid_locs);
    out.R2R_sample              = R2R_valid_locs;
    out.R2R_valid               = R2R_valid;
    out.R2R_valid_bpm           = R2R_valid_bpm;
    out.idx_valid_R2R_consec    = idx_valid_R2R_consec; % index into R2R_valid vector!
    out.mean_R2R_valid_bpm      = mean_R2R_valid_bpm;
    out.median_R2R_valid_bpm    = median_R2R_valid_bpm;
    out.std_R2R_valid_bpm       = std_R2R_valid_bpm;
    out.rmssd_R2R_valid_ms      = rmssd_R2R_valid_ms;
    out.rmssd_R2R_valid_bpm     = rmssd_R2R_valid_bpm;
    out.Pxx                     = Pxx;
    out.freq                    = freq;
    out.vlfPower                = vlfPower;
    out.lfPower                 = lfPower;
    out.hfPower                 = hfPower;
    out.totPower                = totPower;
end

out.hf = [];

if TOPLOT
    hf = figure('Name',FigInfo,'Position',[200 100 1400 1200],'PaperPositionMode', 'auto');
    
    %% single HR-peak
%     t = t*1000; 
%      plot(t,ecgSignal,'b'); hold on;
%     set(gca,'xlim',[172 173]);    
%     
    ha1 = subplot(4,4,[1:4]); %   ha1 = subplot(4,4,[1:4]);
    plot(t,ecgSignal,'b'); hold on;
    plot(t,ecgFiltered,'g');    
    plot(t(locs(idx_wo_outliers)),ecgFiltered(locs(idx_wo_outliers)),'ko','MarkerSize',6);
    plot(t(locs(idx_outliers)),ecgFiltered(locs(idx_outliers)),'bx');
    plot(t(maybe_valid_pos_ecg_locs),ecgFiltered(maybe_valid_pos_ecg_locs),'kv','MarkerSize',6,'MarkerEdgeColor',[0.5 0.5 0.5]);
    plot(t(R_valid_locs),ecgFiltered(R_valid_locs),'mv','MarkerFaceColor',[1 1 1],'MarkerSize',6); % valid R peaks
    plot(t(R2R_valid_locs),ecgFiltered(R2R_valid_locs),'mv','MarkerFaceColor',[1.0000    0.6000    0.7843],'MarkerSize',6);
   
    
    plot([t(R2R_valid_locs(idx_valid_R2R_consec)) - R2R_valid(idx_valid_R2R_consec); t(R2R_valid_locs(idx_valid_R2R_consec))], ...
         [ecgFiltered(R2R_valid_locs(idx_valid_R2R_consec)); ecgFiltered(R2R_valid_locs(idx_valid_R2R_consec))],'k');
 
    if n_segments, % mark segment borders
        ig_add_multiple_vertical_lines(t(seg_ind(1,2:end)),'Color',[0.9294    0.6941    0.1255]);
    end
     
    set(gca,'Xlim',[0 max(t)]);
    xlabel('Time (s)');
    title(sprintf('ECG: %d valid peaks, %d valid R2R intervals',length(R_valid_locs),length(R2R_valid_locs)));
    
 
       
    
    %Graph - 
    %pks = 
    ha2 = subplot(4,4,[5:8]);
    plot(t,energyProfile_tc,'g'); hold on
    set(gca,'Xlim',[0 max(t)]);
    plot(t(locs),pks,'k.','MarkerSize',6);
    plot(t(locs(idx_outliers)),pks(idx_outliers),'bx');
    plot([t(1) t(end)],[eP_tc_minpeakheight_med_prop*median(energyProfile_tc) eP_tc_minpeakheight_med_prop*median(energyProfile_tc)],'k:');
    
   
    
    ha3 = subplot(4,4,[9:12]);
    plot(t(R2R_valid_locs),R2R_valid,'m.'); hold on
    set(gca,'Xlim',[0 max(t)]);
    plot(t(R2R_valid_locs(idx_valid_R2R_consec)),R2R_valid(idx_valid_R2R_consec),'k.','MarkerSize',6); hold on
    % plot(t(R2R_valid_locs(idx_valid_R2R_consec)),R2R_valid(idx_valid_R2R_consec) - R2R_diff(idx_valid_R2R_consec-1),'ks','MarkerSize',3);
    plot(t_valid_R2R(idx_to_delete_after_outliers),R2R_valid_before_hamplel(idx_to_delete_after_outliers),'cx'); hold on
    plot(t_valid_R2R(idx_outliers_hampel),R2R_valid_before_hamplel(idx_outliers_hampel),'rx'); hold on
    
    if R2R_valid_spectrum,
        % plot(t_interp,BPS,'y','Color',[0.4706    0.3059    0.4471]);
    end
    
    set(gca,'Xlim',[0 max(t)]);
    title(sprintf('R2R (s): %d valid, %d consecutive, %d outliers, RMSSD %.3f bpm | %.1f ms',...
        length(R2R_valid_locs),length(idx_valid_R2R_consec),length(unique([idx_outliers_hampel' idx_to_delete_after_outliers])), rmssd_R2R_valid_bpm, rmssd_R2R_valid_ms));
    ylabel('R2R (s)');
    legend({'valid','consecutive','after outliers','hampel outliers'},'location','Best');
    
    
    subplot(4,4,13);
    plot(bins,hist_R2R); hold on;
    plot(median_R2R,0,'rv','MarkerSize',6);
    plot(mode_R2R,0,'mv','MarkerSize',6);
    plot(bins,hist_R2R_valid,'m');
    title(sprintf('%d all R2R, %d valid R2R',length(R2R), length(R2R_valid)));
    xlabel('R2R (s)');
    ylabel('count');
    
    subplot(4,4,14);
    boxplot(R2R_valid_bpm);
    title(sprintf('mean %.1f med %.1f SD %.1f bpm',mean_R2R_valid_bpm,median_R2R_valid_bpm,std_R2R_valid_bpm));
    ylabel('BPM');
    
    subplot(4,4,15);
    plot(R2R_valid_bpm(1:end-1),R2R_valid_bpm(2:end),'k.','MarkerEdgeColor',[0.5 0.5 0.5]); hold on
    plot(R2R_valid_bpm_consec(1:end-1),R2R_valid_bpm_consec(2:end),'m.','MarkerEdgeColor',[0.4235    0.2510    0.3922]);
    
    xlabel('R2R(n)');
    ylabel('R2R(n+1)');
    title('Poincaré plot');
    axis square
    ig_set_xy_axes_equal;
    ig_add_equality_line;
    
    if R2R_valid_spectrum,
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
    
end % of if TOPLOT

function scales = wavelet_init_scales(minFreq, maxFreq, scalesPerDecade)
MorletFourierFactor = 4*pi/(6+sqrt(2+6^2));
sc0                 = 1/(maxFreq*MorletFourierFactor); % we do not consider frequencies above maxFreq
scMax               = 1/(minFreq*MorletFourierFactor); % we do not consider frequencies below minFreq
ds                  = 1/scalesPerDecade;
nSc                 =  fix(log2(scMax/sc0)/ds);
scales              = {sc0, ds, nSc}; % we use default formula for scales: sc0*2.^((0:nSc-1)*ds)

function energyProfile_tc = get_energy_profile(sig,waveName,sca)
cwtstruct = cwtft(sig, 'wavelet', waveName, 'scales', sca);
energyProfile = abs(cwtstruct.cfs).^2;
energyProfile_tc = mean(abs(energyProfile));
clear cwtstruct energyProfile


