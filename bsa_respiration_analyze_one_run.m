function [out,Tab_outlier] = bsa_respiration_analyze_one_run(capSignal,settings_path,Fs,TOPLOT,i_block,NrBlock)
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


if nargin < 3,
    TOPLOT = true;
end


if nargin < 4,
    FigInfo = '';
end

run(settings_path)


n_samples       = length(capSignal);
t               = 0:1/Fs:1/Fs*(n_samples-1); % time axis  -> IMPORTANT: first sample is time 0! (not 1/Fs)

% Step 1: flip cap signal if it's negative, leave the same if it's above zero
% This will keep the signal the same after swapping connectors between TDT
% and capnographic monitor (done by Luba in June 2023)
if median(capSignal) > 0
    % do nothing to the signal
else
    capSignal = (-1)*capSignal;
end

capFiltered = smooth(capSignal)'; 

if 0 % Debug
    figure ('Name','Single-sided amplitude spectrum');
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
% part of the quarter
capFiltered_rectified = ig_fullrectify(capFiltered); 
MinPeakProminence = median (capFiltered_rectified)* Set.cap.MinPeakProminenceCoef; 
% find peaks according to three critera:
% 1) amplitude of the previous & next minimum
% 2) Distance between two peaks
% 3) Min Peak height
[pks,locs_peak]=findpeaks(capFiltered, ...
    'MinPeakProminence',MinPeakProminence, ...
    'minpeakdistance',fix(Set.cap.min_P2P*Fs), ...
    'minpeakheight',Set.cap.eP_tc_minpeakheight_med_prop*median(capFiltered));
% find peaks which are next to each other without a minimum
% locs = [locs_min, locs_peak]; 
% locs = sort(locs); 
% [C, il,ilp] = intersect(locs,locs_peak );
% idx = locs(il(diff(il) == 1)); %shifted!!


%remove peaks which 
%criterium = 'SmallDifference';
%[data_wo_outliers_p2m,idx_wo_outliers_p2m,outliers_p2m,idx_outliers,thresholdValue_p2m] = bsa_remove_outliers(height_peaks,Set.cap.MAD_sensitivity_p2m_diff,criterium);


diff_peaks = [0 abs(diff(pks))];

% remove outliers based on the difference in height /between the amplitude of peaks
[data_wo_outliers,idx_wo_outliers,outliers,idx_outliers,thresholdValue] = bsa_remove_outliers(diff_peaks,Set.cap.MAD_sensitivity_p2p_diff);

Tab_outlier.outlier = length(idx_outliers);
Tab_outlier.NrRpeaks_orig       = length(pks); 

appr_cap_peak2peak_n_samples = mode(abs(diff(locs_peak(idx_wo_outliers)))); % rough number of samples between ecg R peaks

% half-way rectify - leave only positive values
capFiltered_pos             = max(capFiltered,0);
median(capFiltered_pos)
[~,pos_cap_locs]  = findpeaks(capFiltered_pos,'threshold',eps,'minpeakdistance',fix(Set.cap.min_P2P*Fs));

% find ecg peaks closest (in time) to valid energyProfile_tc peaks, within search_segment_n_samples
search_segment_n_samples    = fix(appr_cap_peak2peak_n_samples* Set.cap.fraction_B2B_look4peak);
maybe_valid_pos_cap_locs    = [];
for p = 1:length(idx_wo_outliers)
    idx_overlap = intersect( pos_cap_locs, locs_peak(idx_wo_outliers(p))-search_segment_n_samples : locs_peak(idx_wo_outliers(p))+search_segment_n_samples );
    
    if ~isempty(idx_overlap)
        maybe_valid_pos_cap_locs = [maybe_valid_pos_cap_locs idx_overlap(end)];
    end
    
end



%% Breathing to breathing intervals
B2B             = [NaN diff(t(maybe_valid_pos_cap_locs))]; % 
median_B2B      = median(B2B);
mode_B2B        = mode(B2B);
[hist_B2B,bins] = hist(B2B,[Set.cap.min_P2P:0.01:1]);

% invalidate all B2B less than minFactor_B2BMode (e.g. 0.66) of mode and more than maxFactor_B2BMode (e.g. 1.5) of mode
idx_valid_B2B         = find((B2B> Set.cap.minFactor_B2BMode*mode_B2B | B2B <  Set.cap.maxFactor_B2BMode *mode_B2B));
idx_Invalid_B2B       = find((B2B< Set.cap.minFactor_B2BMode*mode_B2B | B2B >  Set.cap.maxFactor_B2BMode *mode_B2B));

detectedOutliers_mode = (length(idx_Invalid_B2B)/length(B2B))*100; 
disp(['Fraction of B2B outliers detected using deviations from B2B mode: ', num2str(detectedOutliers_mode) ])
Tab_outlier.outlier_Mode_abs = length(idx_Invalid_B2B);
Tab_outlier.outlier_Mode_pct = round((length(idx_Invalid_B2B)/length(B2B))*100 ,4); 

t_valid_B2B                         = t(maybe_valid_pos_cap_locs(idx_valid_B2B));
B2B_valid_before_hampel             = B2B(idx_valid_B2B);
Tab_outlier.NrB2B_beforehampel      = length(B2B_valid_before_hampel); 
%% remove outliers from B2B using hampel
[YY,idx_outliers_hampel] = hampel(t_valid_B2B,B2B_valid_before_hampel, Set.cap.hampel_DX, Set.cap.hampel_T);

%[YY,idx_outliers_hampel, xmedian, xsigma] = hampel(B2B_valid_before_hampel, Set.cap.hampel_nb_of_std,  Set.cap.hampel_adjacentSampleToComputeMean); %B2B_valid_before_hampel, Set.cap.hampel_DX, Set.cap.hampel_T
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
detectedOutlier2                = 100-((length(idx_valid_B2B)/length(B2B))*100); 
disp(['Fraction of B2B outliers detected using deviations from B2B mode and Hampel: ', num2str(detectedOutlier2) ])

Tab_outlier.outliers_delete_abs = length(idx_to_delete);
%
Tab_outlier.outliers_hampel_pct = 100- (((length(idx_valid_B2B)+Tab_outlier.outlier_Mode_abs)/length(B2B))*100) ;

%R-peaks
idx_valid_R     = unique([idx_valid_B2B idx_valid_B2B-1]); % add start of each valid B2B interval to valid R peaks
R_valid_locs    = maybe_valid_pos_cap_locs(idx_valid_R);
%B2Binterval
B2B_valid_locs  = maybe_valid_pos_cap_locs(idx_valid_B2B);
B2B_valid       = B2B(idx_valid_B2B);

Tab_outlier.NrRpeaks_valid      = length(R_valid_locs); 
Tab_outlier.NrB2B_valid         = length(B2B_valid); 
Tab_outlier.outliers_all_abs    = Tab_outlier.outliers_delete_abs  +   Tab_outlier.outlier_Mode_abs    + Tab_outlier.outlier;
Tab_outlier.outliers_all_pct    = (Tab_outlier.outliers_all_abs/Tab_outlier.NrRpeaks_orig)*100;
disp(['Nr of deleted R peaks & B2B outliers: ', num2str(Tab_outlier.outliers_all_abs) ])
disp(['Fraction of deleted R peaks & B2B outliers: ', num2str(Tab_outlier.outliers_all_pct) ])

%%  CALCULATE VARIABLES
%% amplitude of the peak
[minimum,locs_min]=findpeaks(-capFiltered,'threshold',eps,'minpeakdistance',fix(Set.cap.min_P2P*Fs),'minpeakheight',Set.cap.eP_tc_minpeakheight_med_prop*median(capFiltered));
minimum                         = capFiltered(locs_min); 
%height_peaks = abs(minimum)+pks(idx_wo_outliers);

%
median_B2B_valid        = median(B2B_valid);
mode_B2B_valid          = mode(B2B_valid);
[hist_B2B_valid,bins]   = hist(B2B_valid,[Set.cap.min_P2P:0.01:5]);

B2B_valid_bpm           = 60./B2B_valid;
mean_B2B_valid_bpm      = mean(B2B_valid_bpm);
median_B2B_valid_bpm    = median(B2B_valid_bpm);
std_B2B_valid_bpm       = std(B2B_valid_bpm);


% find consecutive B2Bs
idx_valid_B2B_consec = find([NaN diff(t(B2B_valid_locs))]< Set.cap.maxFactor_B2BMode * mode_B2B_valid);
B2B_valid_bpm_consec = B2B_valid_bpm(idx_valid_B2B_consec);
Tab_outlier.B2B_consec = numel(idx_valid_B2B_consec);

% RMSSD ("root mean square of successive differences")
% the square root of the mean of the squares of the successive differences between ***adjacent*** intervals
B2B_diff = diff(B2B_valid);
B2B_bpm_diff = diff(B2B_valid_bpm);

rmssd_B2B_valid_bpm     = sqrt(mean(B2B_bpm_diff(idx_valid_B2B_consec-1).^2));
rmssd_B2B_valid_ms      = sqrt(mean((1000*B2B_diff(idx_valid_B2B_consec-1)).^2));

B2B_valid_spectrum = false;
if length(B2B_valid_locs)>1,
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
%% How "much time of the run" was deleted related to the detection of outlier?
Tab_outlier.durationRun_s                   = max(t);
Tab_outlier.duration_NotValidSegments_s     = max(t)-sum(B2B(idx_valid_B2B));
Tab_outlier.nrblock                         = i_block; 
Tab_outlier.nrblock_combinedFiles           = NrBlock;
if Set.OutlierModus == 1; 
display(Tab_outlier)
end


if length(B2B_valid) < Set.B2B_minValidData,
    out.Rpeak_t                 = [];
    out.Rpeak_sample            = [];
    out.B2B_t                   = [];
    out.B2B_sample              = [];   
    out.B2B_valid               = [];
    out.B2B_valid_bpm           = [];
    out.idx_valid_B2B_consec    = [];
    out.mean_B2B_valid_bpm      = nan;
    out.median_B2B_valid_bpm    = [];
    out.std_B2B_valid_bpm       = [];
    out.rmssd_B2B_valid_ms      = [];
    out.rmssd_B2B_valid_bpm     = [];
    out.Pxx                     = [];
    out.freq                    = [];
    out.vlfPower                = [];
    out.lfPower                 = [];
    out.hfPower                 = [];
    out.totPower                = [];
else
    out.Rpeak_t                 = t(R_valid_locs);
    out.Rpeak_sample            = R_valid_locs;
    out.B2B_t                   = t(B2B_valid_locs);
    out.B2B_sample              = B2B_valid_locs;
    out.B2B_valid               = B2B_valid;
    out.B2B_valid_bpm           = B2B_valid_bpm;
    out.idx_valid_B2B_consec    = idx_valid_B2B_consec; % index into B2B_valid vector!
    out.mean_B2B_valid_bpm      = mean_B2B_valid_bpm;
    out.median_B2B_valid_bpm    = median_B2B_valid_bpm;
    out.std_B2B_valid_bpm       = std_B2B_valid_bpm;
    out.rmssd_B2B_valid_ms      = rmssd_B2B_valid_ms;
    out.rmssd_B2B_valid_bpm     = rmssd_B2B_valid_bpm;
    out.Pxx                     = Pxx;
    out.freq                    = freq;
    out.vlfPower                = vlfPower;
    out.lfPower                 = lfPower;
    out.hfPower                 = hfPower;
    out.totPower                = totPower;
end





out.hf = [];

if TOPLOT
    hf = figure('Name',sprintf('block%02d',i_block),'Position',[200 100 1400 1200],'PaperPositionMode', 'auto');
    
    %% single HR-peak
%     t = t*1000; 
%     plot(t,capSignal,'b'); hold on;
%     set(gca,'xlim',[172 173]);    
%     
    ha1 = subplot(4,4,[1:4]); 
    plot(t,capSignal,'g'); hold on;
    plot(t,capFiltered,'b'); 
    plot(t(locs_min),capFiltered(locs_min),'bo','MarkerSize',6);

    plot(t(locs_peak(idx_wo_outliers)),capSignal(locs_peak(idx_wo_outliers)),'ko','MarkerSize',6);
     % valid R peaks
    plot(t(R_valid_locs),capSignal(R_valid_locs),'mv','MarkerFaceColor',[1 1 1],'MarkerSize',6);
    %valid B2B intervals -> filled TRIANGLE
    plot(t(B2B_valid_locs),capSignal(B2B_valid_locs),'mv','MarkerFaceColor',[1.0000    0.6000    0.7843],'MarkerSize',6);
    plot(t(locs_peak(idx_outliers)),capSignal(locs_peak(idx_outliers)),'bx');
   
    %line for 
    plot([t(B2B_valid_locs(idx_valid_B2B_consec)) - B2B_valid(idx_valid_B2B_consec); t(B2B_valid_locs(idx_valid_B2B_consec))], ...
         [capFiltered(B2B_valid_locs(idx_valid_B2B_consec)); capFiltered(B2B_valid_locs(idx_valid_B2B_consec))],'k');
 
 
     
    set(gca,'Xlim',[0 max(t)]);
    xlabel('Time (s)');
    title(sprintf('CAP: %d valid peaks, %d valid P2P intervals',length(R_valid_locs),length(B2B_valid_locs)));
    if isempty(idx_outliers)
    legend({'capSignal','capFiltered','allPeaks','only posPeaks','valid Peaks','valid P2Pinterval'},'location','Best');
    else
    legend({'capSignal','capFiltered','allPeaks','posPeaks','valid Rpeaks','valid P2Pinterval','outlier.diff Peaks'},'location','Best');
    end
 
    
    ha3 = subplot(4,4,[9:12]);
    plot(t(B2B_valid_locs),B2B_valid,'m.'); hold on
    set(gca,'Xlim',[0 max(t)]);
    plot(t(B2B_valid_locs(idx_valid_B2B_consec)),B2B_valid(idx_valid_B2B_consec),'k.','MarkerSize',6); hold on
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


