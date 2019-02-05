function [data_wo_outliers,idx_wo_outliers,outliers,idx_outliers,thresholdValue] = bsa_remove_outliers(data,sensitivityFactor)


c=-1/(sqrt(2)*erfcinv(3/2)); %https://de.mathworks.com/help/matlab/ref/isoutlier.html#bvlllts-method

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




