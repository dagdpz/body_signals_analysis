function out = bsa_concatenate_trials_any_stream(combined_matfile_path, stream)
%bsa_concatenate_trials_any_stream  - concatenates analog streams into one vector (First_trial_INI trial1 ITI trial2 ITI...)
%
% USAGE:
% bsa_concatenate_trials_any_stream;
%
% INPUTS:
%		combined_matfile_path		- path to combined mat file
%		stream                      - name of the streat
%
% OUTPUTS:
%		out		- see structure
%
% REQUIRES:	NONE
%
% See also BSA_CONCATENATE_TRIALS_BODY_SIGNALS
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
% ...
%%%%%%%%%%%%%%%%%%%%%%%%%[DAG mfile header version 1]%%%%%%%%%%%%%%%%%%%%%%%%% 


fprintf('Loading %s...',combined_matfile_path);
load(combined_matfile_path,'-mat');
fprintf('->Loaded\n');
[pathstr,name,ext] = fileparts(combined_matfile_path);

Fs = trial(1).(['TDT_' stream '_samplingrate']);

out.stream  = double([First_trial_INI.(stream) trial.(['TDT_' stream])]);
out.t       = double(0:1/Fs:1/Fs*(size(out.stream,2)-1));
out.Fs      = double(Fs);
    

