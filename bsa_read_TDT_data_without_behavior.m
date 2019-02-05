function bsa_read_TDT_data_without_behavior(session2read, save2dir)

% E.g.
% session2read='Y:\Data\TDTtanks\Cornelius_phys\20190124\';
% save2dir='Y:\Data\bodysignals_without_behavior';.

blocknames=dir([session2read filesep 'Block*']);
blocknames=strcat(session2read, filesep, {blocknames.name});

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