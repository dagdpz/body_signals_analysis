function logFileName = createErrorLog(Folderpath)
    % This function checks for the existence of a log file. If it does not exist, it creates a new one.
    % Input:
    %   logFileName - Name of the log file to check or create

    existingLogs = dir(fullfile(Folderpath, 'ErrorLog*.txt')); 
    % Check if the log file exists
    if isempty(existingLogs)
        % The file does not exist, create a new file
        logFileName = fullfile(Folderpath, ['ErrorLog_' datestr(now, 'yyyy-mm-dd_HHMMSS') '.txt']); 
        fid = fopen(logFileName, 'w');
        if fid == -1
            error('Failed to create the log file.');
        else
            fprintf(fid, '%s: Log file created.\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
            fclose(fid);
        end
    else
        % Sort the files by date, most recent first
        dates = datetime({existingLogs.date}, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss')
        [~,idx] = sort(dates, 'descend');
        MostRecentLog = existingLogs(idx(1));
        logFileName = fullfile(Folderpath, MostRecentLog.name);
        disp(['Most recent log file: ' logFileName]);
    end
end