function bsa_Rpeak_STA_avg_sessions

%this function loads and calculate average STA across sessions (manual
%input at the moment -> needs to define which sessions\blocks for which
%condition. needs to change bsa_Rpeak_STA format and then this one to make
%input automatic
%% input

%Specific inputs

monkey='Magnus';

%MIP dataset
target='MIP';
sessions={'20190208','20190320'};
% group_per_session={[1:2],[1:3]};
stream = 'LFPx';
group.task = [1 1;2 1]; %[session group;session group] etc...
group.rest = [1 2];
group.task_pert = [2 2];
group.rest_pert = [2 3];

% %dPul dataset
% target='dPul';
% sessions={'20190131','20190213','20190404'};
% % group_per_session={[1:2],[1:3]};
% stream = 'LFPx';
% group.task = [1 1;2 1;3 1]; %[session group;session group] etc...
% group.rest = [1 2;2 2;3 2];
% group.task_pert = [];
% group.rest_pert = [];



%general inputs
FigName_Long1=['R peak triggered average' stream ' '...
    'r=task(n=' num2str(size(group.task,1)) '), ' ...
    'b=rest(n=' num2str(size(group.rest,1)) '), ' ...
    'c=task_pert(n=' num2str(size(group.task_pert,1)) '), ' ...
    'm=rest_pert(n=' num2str(size(group.rest_pert,1)) '), ']; %figure title
FigName_short1= ['RPeak_trig_' stream '_' target]; %file name
keys.path_to_save=['Y:\Projects\PhysiologicalRecording\Data\' monkey '\' target '\'];
if ~exist(keys.path_to_save,'dir'),
    mkdir(keys.path_to_save);
end

%% computation
%load data
for n_session = 1:length(sessions)
    
    data_to_avg(n_session) = load(['Y:\Projects\PhysiologicalRecording\Data\' monkey '\' sessions{n_session} '\'...
        sessions{n_session} '_STA.mat']);
    for gr = 1:length(data_to_avg(1,n_session).STA_session.group)
        for ch = 1:length(data_to_avg(1,n_session).STA_session.group{1,1}.chanel)
            concatenate_channels(ch,:) = data_to_avg(1,n_session).STA_session.group{1,gr}.chanel{1,ch}.avg; %concatenate all channels per sessions and per group
        end
        avg_across_sites.session{1,n_session}.group{1,gr} = nanmean(concatenate_channels,1); %calculate average across sites
    end
end


%from here not elegant solutions to concatenate blocks across sessions from
%same condition and calculate the average and plot

h1=figure('outerposition',[0 0 1900 1200],'name', FigName_Long1);
hold on

if~isempty(group.task)
    for n_blocks = 1:size(group.task,1)
        concatenate_blocks_task(n_blocks, :) = avg_across_sites.session{1,group.task(n_blocks,1)}.group{group.task(n_blocks,2)};
    end
    avg_across_sessions_task = nanmean(concatenate_blocks_task,1);
    shadedErrorBar(data_to_avg(1,1).STA_session.group{1,1}.chanel{1,1}.time, avg_across_sessions_task...
        ,squeeze(sterr( concatenate_blocks_task,1)),'r');
end

if~isempty(group.rest)
    for n_blocks = 1:size(group.rest,1)
        concatenate_blocks_rest(n_blocks, :) = avg_across_sites.session{1,group.rest(n_blocks,1)}.group{group.rest(n_blocks,2)};
    end
    avg_across_sessions_rest = nanmean(concatenate_blocks_rest,1);
    shadedErrorBar(data_to_avg(1,1).STA_session.group{1,1}.chanel{1,1}.time, avg_across_sessions_rest...
        ,squeeze(sterr( concatenate_blocks_rest,1)),'b');
end

if~isempty(group.task_pert)
    for n_blocks = 1:size(group.task_pert,1)
        concatenate_blocks_task_pert(n_blocks, :) = avg_across_sites.session{1,group.task_pert(n_blocks,1)}.group{group.task_pert(n_blocks,2)};
    end
    avg_across_sessions_task_pert = nanmean(concatenate_blocks_task_pert,1);
    shadedErrorBar(data_to_avg(1,1).STA_session.group{1,1}.chanel{1,1}.time, avg_across_sessions_task_pert...
        ,squeeze(sterr( concatenate_blocks_task_pert,1)),'c');
end

if~isempty(group.rest_pert)
    for n_blocks = 1:size(group.rest_pert,1)
        concatenate_blocks_rest_pert(n_blocks, :) = avg_across_sites.session{1,group.rest_pert(n_blocks,1)}.group{group.rest_pert(n_blocks,2)};
    end
    avg_across_sessions_rest_pert = nanmean(concatenate_blocks_rest_pert,1);
    shadedErrorBar(data_to_avg(1,1).STA_session.group{1,1}.chanel{1,1}.time, avg_across_sessions_rest_pert...
        ,squeeze(sterr( concatenate_blocks_rest_pert,1)),'m');
end


set(0,'DefaultTextInterpreter','none');
wanted_papersize= [40 25];
set(h1, 'Paperunits','centimeters','PaperSize', wanted_papersize,'PaperPositionMode', 'manual','PaperPosition', [0 0 wanted_papersize])
mtit(h1,  [FigName_Long1 ], 'xoff', 0, 'yoff', 0.05, 'color', [0 0 0], 'fontsize', 14,'Interpreter', 'none');
set(h1,'Color','white')
export_fig(h1, [keys.path_to_save filesep FigName_short1], '-pdf') % pdf by run


end



 
    
  

  
    
  
    
    
    
