function [rta,segments] = bsa_R_triggered_avg(Rpeak_t, t, sig, win_t)

% Inputs:
% Rpeak_t - time of Rpeak (or any event) (s)
% t - time axis (s)
% sig - signal to average
% win_t - [window_start window_end] relative to event (negative means before event) (s)

sampling_interval = t(2)-t(1);

% time befor and after the event
win1=win_t(1)/sampling_interval;
win2=win_t(2)/sampling_interval;

% Discard events in first and last windows
Rpeak_t(Rpeak_t<-win_t(1) | (Rpeak_t + win_t(2))>t(end))=[];

[C,Rpeak_idx] = intersect(t,Rpeak_t);

% loop version
% segments = zeros(n_peaks,winlen+1);
% for p = 1:n_peaks,
%     segments(p,:) = sig(Rpeak_idx+win1:Rpeak_idx+win2);
% end

segments = cell2mat(arrayfun(@(x) sig(x+win1:x+win2), Rpeak_idx,  'UniformOutput', false));

rta.t       = win_t(1):sampling_interval:win_t(2);
rta.Rpeak_t = Rpeak_t;
rta.mean    = mean(segments,1);
rta.median  = median(segments,1);
rta.std     = std(segments,0,1);