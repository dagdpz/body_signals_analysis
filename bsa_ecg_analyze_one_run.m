function out = bsa_ecg_analyze_one_run(ecgSignal,Fs,TOPLOT,FigInfo)
% needs MATLAB 2014 or later for wavelet toolbox!
%
% https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0140783
% https://github.com/fieldtrip/fieldtrip/blob/master/ft_heartrate.m

% filtering according to https://de.mathworks.com/matlabcentral/answers/270238-how-can-i-filter-ecg-signals-with-high-motion-artifact
% (or see also https://de.mathworks.com/matlabcentral/answers/364788-ecg-signal-artifact-removing)

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
t               = 0:1/Fs:1/Fs*(n_samples-1);

min_R2R         = 0.25; % s
MAD_sensitivity_p2p_diff = 3;
hampel_T        = 4; % threshold for hamplel outlier detection



ecgSignal = detrend(ecgSignal);

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

% Filter Signal
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
sig = struct('val',ecgFiltered, 'period', 1/Fs);
waveName = {'morl', []};
% we ignore components outside of the doubled range of interest
sca = wavelet_init_scales(minFreq/2, 2*maxFreq, scalesPerDecade);
cwtstruct = cwtft(sig, 'wavelet', waveName, 'scales', sca);

% 1 global wavelet filtering
% filterSTD = 8/scalesPerDecade;
% filterAveragingPeriod = fix(30*Fs);
% 1.1 compute spectrum and average it in a sliding window
energyProfile = abs(cwtstruct.cfs).^2;
% energyProfileMean = movingmean(energyProfile, filterAveragingPeriod, 2); %2 stands for average along time

energyProfile_tc = mean(abs(energyProfile));
clear energyProfile




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
[pks,locs]=findpeaks(energyProfile_tc,'threshold',eps,'minpeakdistance',fix(min_R2R*Fs),'minpeakheight',median(energyProfile_tc));


diff_peaks = [0 abs(diff(pks))];


% remove outliers based on the difference between peaks
[data_wo_outliers,idx_wo_outliers,outliers,idx_outliers,thresholdValue] = bsa_remove_outliers(diff_peaks,MAD_sensitivity_p2p_diff);


appr_ecg_peak2peak_N_samples = mode(abs(diff(locs(idx_wo_outliers)))); % rough number of samples between ecg R peaks



ecgFiltered_pos = max(ecgFiltered,0);
[pos_ecg_pks,pos_ecg_locs]=findpeaks(ecgFiltered_pos,'threshold',eps,'minpeakdistance',fix(min_R2R*Fs));

% find ecg peaks closest (in time) to valid energyProfile_tc peaks, within search_segment_n_samples
search_segment_n_samples = fix(appr_ecg_peak2peak_N_samples/20);

maybe_valid_pos_ecg_locs = [];
for p = 1:length(idx_wo_outliers)
    idx_overlap = intersect( pos_ecg_locs, locs(idx_wo_outliers(p))-search_segment_n_samples : locs(idx_wo_outliers(p))+search_segment_n_samples );
    
    if ~isempty(idx_overlap)
        maybe_valid_pos_ecg_locs = [maybe_valid_pos_ecg_locs idx_overlap(end)];
    end
    
end


R2R = [NaN diff(t(maybe_valid_pos_ecg_locs))];
median_R2R = median(R2R);
mode_R2R = mode(R2R);
[hist_R2R,bins] = hist(R2R,[min_R2R:0.01:1]);


% invalidate all R2R less than 0.66 of mode and more than 1.5 of mode
idx_valid_R2R = find((R2R>0.66*mode_R2R & R2R<1.5*mode_R2R));
t_valid_R2R = t(maybe_valid_pos_ecg_locs(idx_valid_R2R));
R2R_valid_before_hamplel = R2R(idx_valid_R2R);


% remove outliers from R2R
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


R2R_valid_locs = maybe_valid_pos_ecg_locs(idx_valid_R2R);
R2R_valid = R2R(idx_valid_R2R);
[hist_R2R_valid,bins] = hist(R2R_valid,bins);


% find consecutive R2Rs
idx_valid_R2R_consec = find([NaN diff(t(R2R_valid_locs))]<1.5*mode_R2R);

R2R_valid_bpm           = 60./R2R_valid;
mean_R2R_valid_bpm      = mean(R2R_valid_bpm);
median_R2R_valid_bpm    = median(R2R_valid_bpm);
std_R2R_valid_bpm       = std(R2R_valid_bpm);

R2R_valid_spectrum = false;
if length(R2R_valid_locs)>1,
    R2R_valid_spectrum = true;
    % BPS spectrum
    % https://de.mathworks.com/matlabcentral/answers/143654-need-an-example-for-calculating-power-spectrum-density
    resampling_rate = 1; % Hz
    t_interp = t(R2R_valid_locs(1)):1/resampling_rate:t(R2R_valid_locs(end));

    BPS = interp1(t(R2R_valid_locs),R2R_valid,t_interp,'nearest');

    % compute the PSD, units of Pxx are squared seconds/Hz.
    [Pxx,F] = periodogram(BPS-mean(BPS),[],numel(BPS),resampling_rate);

    % compute the power in the various bands...
    vlf = bandpower(Pxx,F,[0 0.04],'psd'); % units of sec^2
    lf = bandpower(Pxx,F,[0.04 0.15],'psd'); % units of sec^2
    hf = bandpower(Pxx,F,[0.15 0.4],'psd'); % units of sec^2
    totPower = bandpower(Pxx,F,'psd'); % units of sec^2
    % you can then take the ratio of lf, hf, etc. to totPower * 100 to get the percentages etc.    
end

% output

if length(R2R_valid) < 100,
    out.R2R_valid               = NaN;
    out.R2R_valid_bpm           = NaN;
    out.mean_R2R_valid_bpm      = NaN;
    out.median_R2R_valid_bpm    = NaN;
    out.std_R2R_valid_bpm       = NaN;
else
    
    out.R2R_valid               = R2R_valid;
    out.R2R_valid_bpm           = R2R_valid_bpm;
    out.mean_R2R_valid_bpm      = mean_R2R_valid_bpm;
    out.median_R2R_valid_bpm    = median_R2R_valid_bpm;
    out.std_R2R_valid_bpm       = std_R2R_valid_bpm;

end

out.hf = [];

if TOPLOT
    hf = figure('Name',FigInfo,'Position',[200 100 1400 1200],'PaperPositionMode', 'auto');
    
    
    ha1 = subplot(4,4,[1:4]);
    plot(t,ecgSignal,'b'); hold on;
    plot(t,ecgFiltered,'g');    
    plot(t(locs(idx_wo_outliers)),ecgFiltered(locs(idx_wo_outliers)),'ko','MarkerSize',6);
    plot(t(locs(idx_outliers)),ecgFiltered(locs(idx_outliers)),'rx');
    plot(t(maybe_valid_pos_ecg_locs),ecgFiltered(maybe_valid_pos_ecg_locs),'kv','MarkerSize',6,'MarkerEdgeColor',[0.5 0.5 0.5]);
    plot(t(R2R_valid_locs),ecgFiltered(R2R_valid_locs),'mv','MarkerFaceColor',[1.0000    0.6000    0.7843],'MarkerSize',6);
    
    set(gca,'Xlim',[0 max(t)]);
    xlabel('Time (s)');
       
    
    
    ha2 = subplot(4,4,[5:8]);
    plot(t,energyProfile_tc,'g'); hold on
    set(gca,'Xlim',[0 max(t)]);
    plot(t(locs),pks,'ko','MarkerSize',4);
    plot(t(locs(idx_outliers)),pks(idx_outliers),'rx');
    
   
    
    ha3 = subplot(4,4,[9:12]);
    plot(t(R2R_valid_locs),R2R_valid,'m.'); hold on
    set(gca,'Xlim',[0 max(t)]);
    plot(t(R2R_valid_locs(idx_valid_R2R_consec)),R2R_valid(idx_valid_R2R_consec),'ko','MarkerSize',4); hold on
    plot(t_valid_R2R(idx_to_delete_after_outliers),R2R_valid_before_hamplel(idx_to_delete_after_outliers),'cx'); hold on
    plot(t_valid_R2R(idx_outliers_hampel),R2R_valid_before_hamplel(idx_outliers_hampel),'rx'); hold on
    set(gca,'Xlim',[0 max(t)]);
    title('valid R2R');
    ylabel('P2P (s)');
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
    plot(R2R_valid_bpm(1:end-1),R2R_valid_bpm(2:end),'k.','MarkerFaceColor',[0.5 0.5 0.5]); hold on
    xlabel('n');
    ylabel('n+1');
    title('Poincaré plot');
    axis equal
    axis square
    
    if R2R_valid_spectrum,
    subplot(4,4,16);
    plot(F,Pxx,'k'); hold on;
    plot(F(F>0 & F<0.04),Pxx(F>0 & F<0.04),'g');
    plot(F(F>=0.04 & F<0.15),Pxx(F>=0.04 & F<0.15),'b');
    plot(F(F>=0.15 & F<=0.4),Pxx(F>=0.15 & F<=0.4),'r');
    xlabel('Hz');
    ylabel('s^2 / Hz');
    end
    
    
    ax = get(gcf,'Children');
    set(ax,'FontSize',8);
    
    
    out.hf = hf;
    
end % of if TOPLOT




function scales = wavelet_init_scales(minFreq, maxFreq, scalesPerDecade)
MorletFourierFactor = 4*pi/(6+sqrt(2+6^2));
sc0 = 1/(maxFreq*MorletFourierFactor); % we do not consider frequencies above maxFreq
scMax = 1/(minFreq*MorletFourierFactor); % we do not consider frequencies below minFreq
ds = 1/scalesPerDecade;
nSc =  fix(log2(scMax/sc0)/ds);
scales = {sc0, ds, nSc}; % we use default formula for scales: sc0*2.^((0:nSc-1)*ds)






