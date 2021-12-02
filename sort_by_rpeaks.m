function out=sort_by_rpeaks(RPEAK_ts,AT,trial_onsets,trial_ends,keys,ECG_event)
%% now the tricky part: sort by ECG peaks ...

            %% reduce RPEAK_ts potentially ? (f.e.: longer than recorded ephys, inter-trial-interval?)
            during_trial_index = arrayfun(@(x) any(trial_onsets<=x+keys.PSTH_WINDOWS{1,3} & trial_ends>=x+keys.PSTH_WINDOWS{1,4}),RPEAK_ts);
            RPEAK_ts=RPEAK_ts(during_trial_index);
            
out=struct('states',num2cell(ones(size(RPEAK_ts))*ECG_event),'states_onset',num2cell(zeros(size(RPEAK_ts))),'arrival_times',num2cell(NaN(size(RPEAK_ts))));

for t=1:numel(RPEAK_ts)
    out(t).states=ECG_event;
    out(t).states_onset=0;
    AT_temp=AT-RPEAK_ts(t);
    out(t).arrival_times=AT_temp(AT_temp>keys.PSTH_WINDOWS{1,3}-0.2 & AT_temp<keys.PSTH_WINDOWS{1,4}+0.2);
end
end