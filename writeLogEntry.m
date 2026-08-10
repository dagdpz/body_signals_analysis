function writeLogEntry(info)
    % This function writes an entry into the most recent or a new log file and saves the changes in a new file.
    % Inputs:
    %   folderPath - The path to the folder where log files are stored.
    %   monkey - Identifier for the monkey.
    %   session - Identifier for the session.
    %   block - Identifier for the block.
    %   taskType - Type of the task.
    %   errorMessage - Error message to log.

    % Find the most recent log file or create a new one
    logFileName = createErrorLog(info.folderPath);

    % Open the log file for appending
    fid = fopen(logFileName, 'a');
    if fid == -1
        error('Failed to open the log file.');
    end

    % Write the new log entry
    fprintf(fid, '%s: Monkey=%s, Session=%s, NrBlock=%s,i_Block=%s, TaskType_Excel=%s, TaskType_behav=%s,ErrorMessage=%s\n', ...
            datestr(now, 'yyyy-mm-dd HH:MM:SS'), info.monkey, info.session, info.Nrblock,info.i_block, info.taskType_Excel, info.taskType_Behavior, info.errorMessage);
    
    % Close the file
    fclose(fid);
  
    disp(['Log entry added. Data saved in: ' logFileName]);
end