function out = bsa_concatenate_trials_any_stream(combined_matfile_path, stream)


fprintf('Loading %s...',combined_matfile_path);
load(combined_matfile_path,'-mat');
fprintf('->Loaded\n');
[pathstr,name,ext] = fileparts(combined_matfile_path);

Fs = trial(1).(['TDT_' stream '_samplingrate']);

out.stream  = double([First_trial_INI.(stream) trial.(['TDT_' stream])]);
out.t       = double(0:1/Fs:1/Fs*(size(out.stream,2)-1));
out.Fs      = double(Fs);
    

