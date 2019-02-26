function dat = bsa_read_and_save_TDT_data_without_behavior(session2read, save2dir)

%% What is the function doing?
% 1. sort the Block correctly
% 2. read the ECG, CAP, POX1 data & its sampling rate of each TDT-Block
% 3. output for the length of the block in seconds
% 3. save the structure 'dat' in bodysignals_wo_behavior.mat for each
% session
%% example to call the function
% bsa_read_and_save_TDT_data_without_behavior('Y:\Data\TDTtanks\Magnus_phys\20190124', 'Y:\Projects\PhysiologicalRecording\Data\Magnus\20190124\bodysignals_without_behavior');
%%

if isempty(strfind(path,'DAG\DAG_toolbox\Phys_scripts'))
    dropbox_path = DropboxRootPath;
    addpath([dropbox_path '\DAG\DAG_toolbox\Phys_scripts']);
end

blocknames=dir([session2read filesep 'Block*']);
blocknames_wrongly_sorted = {blocknames.name};
a = asort(blocknames_wrongly_sorted,'-s','descend');
blocknames_correctly_sorted = a.anr;
blocknames=strcat(session2read, filesep, blocknames_correctly_sorted);

for b=1:numel(blocknames)
    blockname=blocknames{b};
    data=TDTbin2mat_working(blockname,'EXCLUSIVELYREAD',{'POX1','ECG1','CAP1'});
    dat.ECG{b}=data.streams.ECG1.data;
    dat.POX{b}=data.streams.POX1.data;
    dat.CAP{b}=data.streams.CAP1.data;
    dat.ECG_SR=data.streams.ECG1.fs;
    dat.POX_SR=data.streams.POX1.fs;
    dat.CAP_SR=data.streams.CAP1.fs;
    disp(sprintf('Read block %d, block length %.2f s',b,length(dat.ECG{b})/dat.ECG_SR));
end

if ~exist(save2dir,'dir'),
    [suc,mes] = mkdir(save2dir);
    if suc
        disp(['Created ' save2dir])
    else
        disp(mes);
    end
end

save([save2dir filesep 'bodysignals_wo_behavior'],'dat');
disp(['Saved to ' save2dir]);