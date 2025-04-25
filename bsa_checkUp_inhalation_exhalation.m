
% Define the directory
ecgcapPath = 'Y:\Data\BodySignals\ECG_CAP\Cornelius';
capPath = 'Y:\Data\BodySignals\CAP\Cornelius';

% Get list of all files in the directory
ecgcapFiles = dir(fullfile(ecgcapPath, '*.*'));

% Filter out directories like '.' and '..'
ecgcapFiles = ecgcapFiles(~[ecgcapFiles.isdir]);

% Loop through the files (in this case, just the first one)
if ~isempty(files)
    for k = 1 : length(ecgcapFiles(k).name)% only the first file
        ecgcapFileName  = ecgcapFiles(k).name;
        dateStr = ecgcapFileName(1:8);
        capFileName = [dateStr '_cap.mat'];
        ecgcapFullPath  = fullfile(ecgcapPath, ecgcapFileName);
        capFullPath  = fullfile(capPath,filesep, dateStr, filesep, capFileName);  % Assuming same filename in CAP
        
        ecgData = load(ecgcapFullPath);
        capData = load(capFullPath);

        capData.Tab_outlier_cap.median_duration_exp
        capData.Tab_outlier_cap.median_duration_insp
        
        
        
                 % Extract values
            NrBlock = [     capData.Tab_outlier_cap.nrblock];
            insp = [capData.Tab_outlier_cap.median_duration_insp];
            exp  = [capData.Tab_outlier_cap.median_duration_exp];
            Date  = repmat({dateStr}, length(NrBlock), 1)';
Date = Date(:);  % now it's 20x1

% Ensure everything else is column vectors
NrBlock = NrBlock(:);
insp = insp(:);
exp = exp(:);
      
%Table per Session
T = table(Date, NrBlock, insp, exp, ...
    'VariableNames', {'Date', 'Block', 'median_InspDuration', 'median_ExhpDuration'});


% Graph per Session

figure;
plot(NrBlock, insp, '-o', 'DisplayName', 'Inspiration');
hold on;
plot(NrBlock, exp, '-x', 'DisplayName', 'Expiration');
xlabel('Block Number');
ylabel('Duration (s)');
title('Median Inspiration & Expiration Duration per Block');
legend('Location', 'best');
grid on;


% Monkey and session info
monkey = 'Cornelius';
sessionLabel = dateStr ;
% Full path to save the figure
saveDir = 'Y:\Projects\Pulv_bodysignal\3_Output\Plots\Debug_Inhalation_Exhalation';
saveFileName = strjoin({monkey, sessionLabel, 'MedianInh_Exh.png'}, '_');
saveFullPath = fullfile(saveDir, saveFileName);
saveas(gcf, saveFullPath);

    end 
else
    disp('No files found in the directory.');
end

% Display the mean oer block for inhalation and exhalation