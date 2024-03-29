function bsa_Rpeak_STA

% variant using FieldTrip
% by Lukas

%clear all
plot_permutations=0;
from_raw=0;
monkey='Magnus';

for whattoplot= [8]
    switch whattoplot
        
        case 1
            
            session='20190124';
            blockspergroup={1,5};
            colorsspergroup={'r','c'};
            perturbation='inactivation';
            target='MIP';
            stream='LFPx';
            FigName_Long1=['R peak triggered' stream 'average, r=task, c=task_pert ' target perturbation];
            y_lim=[-7*10^-6 5*10^-6];
            
        case 2
            
            session='20190130';
            blockspergroup={1,6,[4 7]};
            colorsspergroup={'r','c','m'};
            perturbation='inactivation';
            target='dPul';
            stream='LFPx';
            FigName_Long1=['R peak triggered' stream 'average, r=task, b=notask, c=task_pert, m=rest_pert ' target perturbation];
            y_lim=[-7*10^-6 5*10^-6];
            
        case 3
            
            session='20190131';
            blockspergroup={[1 3],[2 4]};
            colorsspergroup={'r','b'};
            perturbation='control';
            target='dPul';
            stream='LFPx';
            FigName_Long1=['R peak triggered' stream 'average, r=task, b=notask ' target perturbation];
            %             y_lim=[-7*10^-6 5*10^-6];
            y_lim=[];
            
        case 4
            
            session='20190208';
            blockspergroup={[1,3,5,7],[2,4,6,8]};
            colorsspergroup={'r','b'};
            perturbation='control';
            target='MIP';
            stream='LFPx';
            FigName_Long1=['R peak triggered' stream 'average, r=task, b=notask ' target perturbation];
            %              y_lim=[-2*10^-5 2*10^-5];
            y_lim=[];
        case 5
            
            session='20190213';
            blockspergroup={[1,3,5],[2,4,6]};
            colorsspergroup={'r','b'};
            perturbation='control';
            target='dPul';
            stream='LFPx';
            FigName_Long1=['R peak triggered' stream 'average, r=task, b=notask ' target perturbation];
            %             y_lim=[-7*10^-6 5*10^-6];
            y_lim=[];
            
            
            
        case 6
            
            session='20190320';
            blockspergroup={1,[2 3 4 6],[5 7]}; % block are shifted here (e.g. 2 means 3 cause no combined files for block 2 (no task)
            colorsspergroup={'r','c','m'};
            perturbation='inactivation';
            target='MIP';
            stream='LFPx';
            FigName_Long1=['R peak triggered' stream 'average, r=task, c=task_pert, m=rest_pert ' target perturbation];
            %             y_lim=[-7*10^-6 5*10^-6];
            y_lim=[];
        
        case 7
            
            session='20190404';
            blockspergroup={[1 2 4],[3 5]};
            colorsspergroup={'r','b'};
            perturbation='control';
            target='dPul';
            stream='LFPx';
            FigName_Long1=['R peak triggered' stream 'average, r=task, b=notask ' target perturbation];
            %             y_lim=[-7*10^-6 5*10^-6];
            y_lim=[];
            
             
        case 8
            
            session='20190417';
            blockspergroup={[1 3 4],2};
            colorsspergroup={'r','b'};
            perturbation='control';
            target='dPul';
            stream='LFPx';
            FigName_Long1=['R peak triggered' stream 'average, r=task, b=notask ' target perturbation];
            %             y_lim=[-7*10^-6 5*10^-6];
            y_lim=[];
            
            
    end
    
    FigName_short1= ['RPeak_trig_' stream]; %name of the file
    
    if plot_permutations
        FigName_short1= [FigName_short1 '_perm']; %name of the file
    end
    
    
    keys.path_to_save=['Y:\Projects\PhysiologicalRecording\Data\' monkey '\' session '\'];
    
    load(['Y:\Projects\PhysiologicalRecording\Data\' monkey '\' session '\' session '_ecg.mat']);
    session_to_read=['Y:\Data\TDTtanks\' monkey '_phys\' session '\'];
    if from_raw==1
        blocknames=dir([session_to_read 'Block*']);
        blocknames=strcat(session_to_read, {blocknames.name});
    else
        blocknames=dir(['Y:\Data\' monkey '_phys_combined_monkeypsych_TDT\' session '\*.mat']);
        blocknames=strcat(['Y:\Data\' monkey '_phys_combined_monkeypsych_TDT\' session '\'], {blocknames.name});
    end
    
    STA_session=struct();
    for b=1:numel(blocknames)
        blockname=blocknames{b};
        if from_raw==1
            %      data=TDTbin2mat_working(blockname,'EXCLUSIVELYREAD',{'ECG1'});
            %      datatemp.trial{b}=data.streams.ECG1.data;
            %      LFP_SR=data.streams.ECG1.fs;
            
            data=TDTbin2mat_working(blockname,'EXCLUSIVELYREAD',{stream});
            datatemp.trial{b}=data.streams.(stream).data;
            LFP_SR=data.streams.(stream).fs;
            
        else
            load(blockname);
            datatemp.trial{b}=[First_trial_INI.(stream)  trial.(['TDT_' stream])];
            LFP_SR=trial(1).(['TDT_' stream '_samplingrate']);
            
        end
        
        
        datatemp.time{b}=0:1/LFP_SR:(size(datatemp.trial{b},2)-1)/LFP_SR;
        Rpeak_idx=round((out(b).Rpeak_t)*LFP_SR)+1;
        n_chans=size(datatemp.trial{b},1);
        
        datatemp.trial{b}(n_chans+1,:)=false(1,size(datatemp.trial{b},2));
        if ~isnan(out(b).Rpeak_t)
        datatemp.trial{b}(n_chans+1,Rpeak_idx)=true;
        else
            continue
        end
    end
    
    
    %% FT format
    for ch=1:n_chans
        datatemp.label{ch}=[session '_El_' num2str(ch)];
    end
    
    datatemp.label{end+1}='Rpeaks';
    datatemp.fsample=LFP_SR;
  
    datasim=datatemp;
    n_iterations=100;
    for b=1:numel(datasim.trial)
        for ni=1:n_iterations
            datasim.label{n_chans+ni}=num2str(ni);
            mean_ISI=1/nanmean(datasim.trial{b}(n_chans+1,:));
            poiss = poissrnd(mean_ISI,2*sum(datasim.trial{b}(n_chans+1,:)),1);
            poiss(poiss==0)=1;%% ??
            poiss=cumsum(poiss);
            poiss(poiss>size(datasim.trial{b},2))=[];
            datasim.trial{b}(n_chans+ni,:)=false(1,size(datasim.trial{b},2));
            datasim.trial{b}(n_chans+ni,poiss)=true;
        end
    end
    
    datasimsample=datasim;
    datasample=datatemp;
    
    % disp('Spike-triggered average (sta)');
    
    
    set(0,'DefaultTextInterpreter','none');
    wanted_papersize= [40 25];
    h1=figure('outerposition',[0 0 1900 1200],'name', FigName_Long1);
    for g=1:numel(blockspergroup)
        %  datasample.trial= datasim.trial(blockspergroup{g});
        %  datasample.time= datatemp.time(blockspergroup{g});
        
        datasample.time= datatemp.time(blockspergroup{g});
        datasimsample.time= datasim.time(blockspergroup{g});
        
        n_sps=ceil(sqrt(n_chans));
        for ch=1:n_chans
            
            datasample.trial= datatemp.trial(blockspergroup{g});
            for xxx=1:numel(datasample.trial)
                datasample.trial{xxx}=datasample.trial{xxx}([ch, n_chans+1],:);
            end
            
            datasample.label= datatemp.label([ch, n_chans+1]); % first unit
            subplot(n_sps,n_sps,ch);
            hold on
            
            cfg              = [];
            cfg.keeptrials	 = 'yes';
            cfg.timwin       = [-0.4 0.4]; % take 200 ms
            cfg.channel      = datasample.label(1); % first chan
            cfg.spikechannel = datasample.label(2); % first unit
            cfg.latency      = 'maxperiod';
            
            sta              = ft_spiketriggeredaverage(cfg, datasample); % converge on using bsa_R_triggered_avg instead of FT ft_spiketriggeredaverage here
            ttt=shadedErrorBar(sta.time,sta.avg,squeeze(sterr(sta.trial,1)),colorsspergroup{g});
            STA_session.group{g}.chanel{ch} = sta;
            
            if plot_permutations
                for ni=1:n_iterations
                    
                    datasimsample.trial= datasim.trial(blockspergroup{g});
                    for xxx=1:numel(datasimsample.trial)
                        datasimsample.trial{xxx}=datasimsample.trial{xxx}([ch, n_chans+ni],:);
                    end
                    
                    datasimsample.label= datasim.label([ch, n_chans+ni]); % first unit
                    
                    cfg.keeptrials	 = 'no';
                    cfg.spikechannel = datasimsample.label(2); % first unit
                    sim(ni)          = ft_spiketriggeredaverage(cfg, datasimsample); %% converge on using bsa_R_triggered_avg instead of FT ft_spiketriggeredaverage here
                    
                end
                AVGsim=vertcat(sim.avg);
                cnfdc_intervals = prctile(AVGsim,[2.5 97.5],1);
                plot([sta.time],cnfdc_intervals,'color',colorsspergroup{g},'linestyle',':');
            end
            
            xlim(cfg.timwin);
            if ~isempty(y_lim)
            ylim(y_lim);
            end
            
            if g==1
                title(sta.label,'interpreter','none');
            end
        end
    end
    
    % FigName_short1= sprintf('%s_%s', hemi,PPC_method); %name of the file
    % FigName_Long1=sprintf('%s_%s, %d SF pairs', hemi, PPC_method,sum(valid_SF_combinations)); % overall title of the figure
    
    save([keys.path_to_save filesep session_name '_STA.mat'],'STA_session');
    set(h1, 'Paperunits','centimeters','PaperSize', wanted_papersize,'PaperPositionMode', 'manual','PaperPosition', [0 0 wanted_papersize])
    mtit(h1,  [FigName_Long1 ], 'xoff', 0, 'yoff', 0.05, 'color', [0 0 0], 'fontsize', 14,'Interpreter', 'none');
    set(h1,'Color','white')
    export_fig(h1, [keys.path_to_save filesep FigName_short1], '-pdf') % pdf by run
end
end
