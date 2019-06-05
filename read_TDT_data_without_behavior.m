session_to_read='Y:\Data\TDTtanks\Cornelius_phys\20190124\';
save_to_directory='Y:\Data\bodysignals_without_behavior'; %% to modify...

blocknames=dir([session_to_read 'Block*']);
 blocknames=strcat(session_to_read, {blocknames.name});
 
 for b=1:numel(blocknames)
     blockname=blocknames{b};
     data=TDTbin2mat_working(blockname,'EXCLUSIVELYREAD',{'POX1','ECG1','CAP1'});
     dat.ECG{b}=data.streams.ECG1.data;
     dat.POX{b}=data.streams.POX1.data;
     dat.CAP{b}=data.streams.CAP1.data;
     dat.ECG_SR=data.streams.ECG1.fs;
     dat.POX_SR=data.streams.POX1.fs;
     dat.CAP_SR=data.streams.CAP1.fs;
 end
 
 save([save_to_directory filesep 'bodysignals_wo_behavior'],'dat');