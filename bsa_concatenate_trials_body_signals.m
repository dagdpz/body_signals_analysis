function out = bsa_concatenate_trials_body_signals(combined_matfile_path, TOPLOT, export2dlm)

if nargin < 2,
    TOPLOT = false;
end

if nargin < 3,
    export2dlm = false;
end

load(combined_matfile_path);

[pathstr,name,ext] = fileparts(combined_matfile_path);

Fs = trial(1).TDT_ECG1_samplingrate;

out.ECG1 = [First_trial_INI.ECG1 trial.TDT_ECG1];
out.POX1 = [First_trial_INI.POX1 trial.TDT_POX1];
out.CAP1 = [First_trial_INI.CAP1 trial.TDT_CAP1];
out.t    = 1/Fs:1/Fs:1/Fs*length(out.ECG1);


if TOPLOT,
    
   figure;
   ha(1) = subplot(3,1,1);
   plot(out.t,out.ECG1);
   title('ECG1');
   ha(2) = subplot(3,1,2);
   plot(out.t,out.POX1);
   title('POX1');
   ha(3) = subplot(3,1,3);
   plot(out.t,out.CAP1);
   title('CAP1');
   xlabel('Time (s)');
   set(ha,'Xlim',[0 max(out.t)]);
   
end

if export2dlm,  
    
    if ~isempty(pathstr),
        pathstr = [pathstr filesep];
    end
    Disp('Saving dlm, please wait...');
    dlmwrite([pathstr name '_ECG1.txt'],out.ECG1');
    dlmwrite([pathstr name '_POX1.txt'],out.POX1');
    dlmwrite([pathstr name '_CAP1.txt'],out.CAP1');
    dlmwrite([pathstr name '_time.txt'],out.t');
end
