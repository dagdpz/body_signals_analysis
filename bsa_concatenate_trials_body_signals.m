function out = bsa_concatenate_trials_body_signals(combined_matfile_path, returnECGonly, TOPLOT, export2dlm)
%bsa_concatenate_trials_body_signals  - concatenates body signal streams into one vector (First_trial_INI trial1 ITI trial2 ITI...)
%
% USAGE:
% ecg = bsa_concatenate_trials_body_signals('Y:\Data\Cornelius_phys_combined_monkeypsych_TDT\20190207\Corcombined2019-02-07_04_block_01.mat', 1); % get ecg only
%
% INPUTS:
%		combined_matfile_path		- path to combined mat file
%		returnECGonly               - (self-explanatory)
%       TOPLOT                      - plot signals
%       export2dlm                  - export for Kubios
%
% OUTPUTS:
%		out		- see structure
%
% REQUIRES:	NONE
%
% See also BSA_CONCATENATE_TRIALS_ANY_STREAM
%
%
% Author(s):	I.Kagan, DAG, DPZ
% URL:		http://www.dpz.eu/dag
%
% Change log:
% 20190226:	Created function (Igor Kagan)
% ...
% $Revision: 1.0 $  $Date: 2019-02-26 12:16:25 $

% ADDITIONAL INFO:
% What is the function doing?
% 1. combines the data from all trials & the data which were recorded before starting the task 
% 2. plot all the data
% 3. save the concatenated trials as .txt-file
%%%%%%%%%%%%%%%%%%%%%%%%%[DAG mfile header version 1]%%%%%%%%%%%%%%%%%%%%%%%%% 


if nargin < 2,
    returnECGonly = false;
end

if nargin < 3,
    TOPLOT = false;
end

if nargin < 4,
    export2dlm = false;
end

fprintf('Loading %s...',combined_matfile_path);
load(combined_matfile_path,'-mat');
fprintf('->Loaded\n');
[pathstr,name,ext] = fileparts(combined_matfile_path);

Fs = trial(1).TDT_ECG1_samplingrate;

if isempty(fieldnames(First_trial_INI))  
   % choose  between [trial.TDT_ECG4]) or TDT_ECG1
    out.ECG1 = double([ trial.TDT_ECG4]);
else
out.ECG1 = double([First_trial_INI.ECG1 trial.TDT_ECG4]);
end
out.t    = double(0:1/Fs:1/Fs*(length(out.ECG1)-1));
out.Fs   = double(Fs);
    

if ~returnECGonly
    out.POX1 = double([First_trial_INI.POX1 trial.TDT_POX1]);
    out.CAP1 = double([First_trial_INI.CAP1 trial.TDT_CAP1]);
end


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
    dlmwrite([pathstr name '_time.txt'],out.t');
    
    if ~returnECGonly
        dlmwrite([pathstr name '_POX1.txt'],out.POX1');
        dlmwrite([pathstr name '_CAP1.txt'],out.CAP1');
    end
end
