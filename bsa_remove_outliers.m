function [data_wo_outliers,idx_wo_outliers,outliers,idx_outliers,thresholdValue] = bsa_remove_outliers(data,sensitivityFactor)
%bsa_remove_outliers  - removes outliers, using median of the absolute differences
%
% USAGE:
% See bsa_ecg_analyze_one_run.m:
% remove outliers based on the difference between peaks
% [data_wo_outliers,idx_wo_outliers,outliers,idx_outliers,thresholdValue] = bsa_remove_outliers(diff_peaks,MAD_sensitivity_p2p_diff);
%
% INPUTS:
%		data                - data with outliers
%		sensitivityFactor   - 
%
% OUTPUTS:
%		data_wo_outliers		- data without outliers (outliers are replaced by NaNs)
%		idx_wo_outliers         - indices of data without outliers (based on original data)
%       outliers                - outliers
%       idx_outliers            - indices of outliers (based on original data)
%       thresholdValue          - actual threshold value for abs(absoluteDeviation)
%
% REQUIRES:	None
%
% See also BSA_ECG_ANALYZE_ONE_RUN
%
%
% Author(s):	I.Kagan, DAG, DPZ
% URL:		http://www.dpz.eu/dag
%
% Change log:
% 20190226:	Created function (Igor Kagan)
% ...
% $Revision: 1.0 $  $Date: 2019-02-26 14:40:30 $

% ADDITIONAL INFO:
% https://de.mathworks.com/help/matlab/ref/isoutlier.html#bvlllts-method
% https://de.mathworks.com/matlabcentral/answers/121247-how-can-i-detect-and-remove-outliers-from-a-large-dataset
%%%%%%%%%%%%%%%%%%%%%%%%%[DAG mfile header version 1]%%%%%%%%%%%%%%%%%%%%%%%%% 


c=-1/(sqrt(2)*erfcinv(3/2)); 

absoluteDeviation = abs(data - median(data));

% Compute the median of the absolute differences
MAD = median(absoluteDeviation);

% Find outliers: absolute difference is more than some factor times the mad value.
thresholdValue = sensitivityFactor * c * sensitivityFactor * MAD;
idx_outliers = find(abs(absoluteDeviation) > thresholdValue);

idx_wo_outliers = setdiff(1:length(data),idx_outliers);
outliers = data;
outliers(idx_wo_outliers) = NaN;


data_wo_outliers = data;
data_wo_outliers(idx_outliers) = NaN;




