function cap_ecg_histogram2(basepath_ecg,basepath_spikes,basepath_to_save,session_info)
savePlot = 1; 
%20210706
% ToDos
% 1 - loading the data automatically
% 2 - each plot should get a label for the brain areas -> 
% 3 - average 
%% - average of the surrogate data pro unit (per taskType) 
%% - Mittelwert (SEM) �ber alle units per Brain area


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 session_info{1}={'Bacchus','20211001',[1 2  ]};  %3 4 5 6 7
% session_info{1}={'Bacchus','20210720',[4 5 6 7 8]};
% session_info{1}={'Bacchus','20210826',[2 3 4 5 6 7 8 9]};
%session_info{1}={'Bacchus','20211028',[1 2 3 4 5 6]};
% session_info{1}={'Bacchus','20211207',[1 2 3 4 6  9 10 11 12]};%4 VPL
% session_info{1}={'Bacchus','20211208',[2 4 6 7 8 9 10 11 12 13 14 15]};% VPL
% session_info{1}={'Bacchus','20211214',[1 2 3 4 5 6 7 ]}; %Dpul & VPL
% session_info{1}={'Bacchus','20211222',[1 2 3 4 5 6 7 8 9]}; %Dpul & VPL
% session_info{1}={'Bacchus','20220105',[1 2 3 4 5 6 7 8 9 10 11 12 13]}; %Dpul & VPL
% session_info{1}={'Bacchus','20220106',[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15]}; %MD & VPL
tic
basepath_ecg='Y:\Projects\Pulv_distractor_spatial_choice\Data\';
basepath_spikes='Y:\Projects\Pulv_distractor_spatial_choice\ephys\ECG_taskRest\';
basepath_to_save='Y:\Projects\Pulv_distractor_spatial_choice\Data\ECG_triggered_PSTH';

Sanity_check=0; % ECG triggered ECG, turn off since typically there is no ECG data in the spike format
remove_ini=0;   % to remove inter-trial intervals from ECG peaks (useful if ITI spikes were excluded during waveclus preprocessing)
n_permutations=100;

ECG_event=-1;
keys.PSTH_WINDOWS={'ECG',ECG_event,-2,2};
keys.PSTH_binwidth=0.1;% 0.01;
keys.kernel_type='gaussian';
keys.gaussian_kernel=0.02;

%%
if ~exist(basepath_to_save,'dir')
    mkdir(basepath_ecg, 'CAP_triggered_PSTH');
end

condition=struct('unit',{});
u=0; % unit counter across sessions

for s=1:numel(session_info)
    monkey=session_info{s}{1};
    session=session_info{s}{2};
    blocks=session_info{s}{3};
    
    % Rpeaks derived from concatenated ECG data [First_trial_INI.ECG1 trial.TDT_ECG1]
    load([basepath_ecg monkey filesep 'CAP' filesep session filesep session  '_cap.mat']);
    load([basepath_ecg monkey filesep 'ECG' filesep session filesep session  '_ecg.mat']);
    load([basepath_spikes 'population_' monkey '_' session '.mat']);
    
    T = 0; 
  for b=1:numel(blocks)  
      
         block=blocks(b);
            
            o=find([out.nrblock_combinedFiles]==block); %% this would be the easy version, but somehow this number can also be empty...
            for oo=1:numel(out)
                if out(oo).nrblock_combinedFiles==block
                    o=oo;
                end
            end
            
    % time of each exhalation peak
 BPEAK_ts=[out_cap(o).Rpeak_t];
 RPEAK_ts=[out(o).Rpeak_t];
 sorted=sort_by_rpeaks(BPEAK_ts,RPEAK_ts,keys,ECG_event);
 condition(1).unit(1).trial(T+1:T+numel(sorted))=sorted;

%figure
% plot([sorted.arrival_times], '.', 'MarkerSize',10)
sta=keys.PSTH_WINDOWS{1,2};
t_before_state=keys.PSTH_WINDOWS{1,3};
t_after_state=keys.PSTH_WINDOWS{1,4};
PSTH_ms =t_after_state-1:0.001:t_after_state+1;
Kernel=normpdf(-5*keys.gaussian_kernel:0.001:5*keys.gaussian_kernel,0,keys.gaussian_kernel);

SD_ms(1,:)= conv(hist([condition(1).unit(1).trial.arrival_times],PSTH_ms),Kernel,'same');
plot(hist([condition(1).unit(1).trial.arrival_times],PSTH_ms))
        

R2R_valid_bpm           = 60./sorted.arrival_times(1);
mean_R2R_valid_bpm      = mean(R2R_valid_bpm);
            %% find if to append it to rest or task condition
            %not ideal, but should work for  now
%             if trcell{1}.type==1
%                 tasktype=1; % rest
%             elseif trcell{1}.type==2
%                 tasktype=2; % task
%             else
%                 continue
%             end
            
            %% check how many Rpeaks ("trials") we have already for that condition, so we can append across blocks
%             if numel(condition)>=tasktype && numel(condition(tasktype).unit)>=u  && isfield (condition(tasktype).unit(u),'trial')
%                 T=numel(condition(tasktype).unit(u).trial);
%             else
%                 T=0;
%             end
            
            %% now the tricky part: sort by ECG peaks ...
%             sorted=sort_by_rpeaks(BPEAK_ts,AT,trial_onsets,trial_ends,keys,ECG_event,remove_ini);
%             condition(tasktype).unit(u).trial(T+1:T+numel(sorted))=sorted;
            
            %% make surrogates
%             for p=1:n_permutations
%                 BPEAKS_intervals=diff([0 BPEAK_ts ]);
%                 %RPEAKS_intervals=Shuffle(RPEAKS_intervals); %% shuffle the intervals
%                 BPEAKS_intervals = BPEAKS_intervals(randperm(length(BPEAKS_intervals))); 
%                 BPEAK_ts_perm=cumsum(BPEAKS_intervals);
%                 sorted=sort_by_rpeaks(BPEAK_ts_perm,AT,trial_onsets,trial_ends,keys,ECG_event,remove_ini);
%                 condition(tasktype).unit(u).permuations(p).trial(T+1:T+numel(sorted))=sorted;
%             end
%             
            %% The part following here is internal sanity check and should be turned off in general since there typically is no ECG data in the spike format
%             if Sanity_check
%                 ECG_data=[pop.trial(tr).TDT_ECG1];
%                 ECG_time=cellfun(@(x) [1/x.TDT_ECG1_SR:1/x.TDT_ECG1_SR:numel(x.TDT_ECG1)/x.TDT_ECG1_SR]+x.TDT_ECG1_t0_from_rec_start+x.TDT_ECG1_tStart,trcell,'Uniformoutput',false);
%                 CG_time=[ECG_time{:}];
%                 tt=0;
%                 clear ECG_to_plot
%                 for t=1:numel(BPEAK_ts)
%                     ECg_t_idx=CG_time>RPEAK_ts(t)-0.5 & CG_time<RPEAK_ts(t)+0.5;
%                     if round(sum(ECg_t_idx)-trcell{1}.TDT_ECG1_SR)~=0
%                         continue
%                     end
%                     tt=tt+1;
%                     ECG_to_plot(tt,:)=ECG_data(ECg_t_idx);
%                 end
%                 
%                 figure
%                 filename=[unit_ID '_block_' num2str(block) '_ECG_average'];
%                 lineProps={'color','b','linewidth',1};
%                 shadedErrorBar(1:size(ECG_to_plot,2),mean(ECG_to_plot,1),sterr(ECG_to_plot,1),lineProps,1);
%                 export_fig([basepath_to_save, filesep, filename], '-pdf','-transparent') % pdf by run
%                 close(gcf);
%                 
%                 figure
%                 filename=[unit_ID '_block_' num2str(block) '_ECG_per5trials'];
%                 plot(ECG_to_plot(1:5:end,:)');
%                 export_fig([basepath_to_save, filesep, filename], '-pdf','-transparent') % pdf by run
%                 close(gcf);
%             end
            
        end
        
        
        figure;
        %title([unit_ID,'__',target ],'interpreter','none');
        hold on
        Output = []; 
        if numel(condition(1).unit) >= 1
            trial=condition(1).unit(1).trial;
            [SD  bins SD_VAR SD_SEM]=ph_spike_density(trial,1,keys,zeros(size(trial)),ones(size(trial)));

            for p=1:n_permutations                
            trial=condition(1).unit(u).permuations(p).trial;
            SDP(p,:)                =ph_spike_density(trial,1,keys,zeros(size(trial)),ones(size(trial)));
            end
            
            lineProps={'color','b','linewidth',1};
            shadedErrorBar((keys.PSTH_WINDOWS{1,3}:keys.PSTH_binwidth:keys.PSTH_WINDOWS{1,4})*1000,SD,SD_SEM,lineProps,1);
            
            %% get mean and confidence intervals of shuffle predictor
            SDPmean=nanmean(SDP,1);
            SDPconf(1,:)=abs(prctile(SDP,2.5,1)-SDPmean);
            SDPconf(2,:)=abs(prctile(SDP,97.5,1)-SDPmean);
            
            lineProps={'color','b','linewidth',1,'linestyle',':'};
            shadedErrorBar((keys.PSTH_WINDOWS{1,3}:keys.PSTH_binwidth:keys.PSTH_WINDOWS{1,4})*1000,SDPmean,SDPconf,lineProps,1);
        end
        % separate for Rest and Task, group for Target
            Output.target.Rest.SD(U,:)       = SD ; 
            Output.target.Rest.SDP(U,:)   = SDPmean ; 

          if numel(condition(2).unit) >= u
            trial=condition(2).unit(u).trial;
            [SD  bins SD_VAR SD_SEM]=ph_spike_density(trial,1,keys,zeros(size(trial)),ones(size(trial)));
            
              for p=1:n_permutations                
            trial=condition(2).unit(u).permuations(p).trial;
            SDP(p,:)               =ph_spike_density(trial,1,keys,zeros(size(trial)),ones(size(trial)));
              end
            
            lineProps={'color','r','linewidth',1};
            shadedErrorBar((keys.PSTH_WINDOWS{1,3}:keys.PSTH_binwidth:keys.PSTH_WINDOWS{1,4})*1000,SD,SD_SEM,lineProps,1);
            
            %% get mean and confidence intervals of shuffle predictor
            SDPmean=nanmean(SDP,1);
            SDPconf(1,:)=abs(prctile(SDP,2.5,1)-SDPmean);
            SDPconf(2,:)=abs(prctile(SDP,97.5,1)-SDPmean);
            
            lineProps={'color','r','linewidth',1,'linestyle',':'};
            shadedErrorBar((keys.PSTH_WINDOWS{1,3}:keys.PSTH_binwidth:keys.PSTH_WINDOWS{1,4})*1000,SDPmean,SDPconf,lineProps,1);
          end
            Output.target.Task.SD(U,:)       = SD ; 
            Output.target.Task.SDP(U,:)   = SDPmean ; 
            
        
        filename= [unit_ID, '__' target];
        if savePlot; export_fig([basepath_to_save, filesep, filename], '-pdf','-transparent'); end % pdf by run
        close(gcf);
end %SessionInfo

%% Here comes some sort of across population plot i assume?
TaskTyp = {'Rest', 'Task'};
figure;
TargetBrainArea = fieldnames(Output); 
for i_BrArea = 1: numel(TargetBrainArea)
    
    title(['Mean_', (TargetBrainArea{i_BrArea})],'interpreter','none');
    for i_tsk = 1: numel(TaskTyp)
        O = [Output.(TargetBrainArea{i_BrArea}).(TaskTyp{i_tsk})];
        TaskType(i_tsk).SDmean          =   mean(O.SD - O.SDP);
        TaskType(i_tsk).SDmean_SEM      =  std(O.SD - O.SDP)/ sqrt(length(TaskType(i_tsk).SDmean )) ;
        hold on
        if i_tsk == 1
            lineProps={'color','r','linewidth',3};
        else
            lineProps={'color','b','linewidth',3}; 
        end
        shadedErrorBar((keys.PSTH_WINDOWS{1,3}:keys.PSTH_binwidth:keys.PSTH_WINDOWS{1,4})*1000,TaskType(i_tsk).SDmean ,TaskType(i_tsk).SDmean_SEM ,lineProps,1);
    end

toc
end
        filename= [monkey,'_' session,'_' (TargetBrainArea{i_BrArea})];

        if savePlot; export_fig([basepath_to_save, filesep, filename], '-pdf','-transparent'); end % pdf by run

end

function out=sort_by_rpeaks(RPEAK_ts,AT,keys,ECG_event)
%% now the tricky part: sort by ECG peaks ...

% if remove_ini
% %% reduce RPEAK_ts potentially ? (f.e.: longer than recorded ephys, inter-trial-interval?)
% during_trial_index = arrayfun(@(x) any(trial_onsets<=x+keys.PSTH_WINDOWS{1,3} & trial_ends>=x+keys.PSTH_WINDOWS{1,4}),RPEAK_ts);
% RPEAK_ts=RPEAK_ts(during_trial_index);
% end
% 
out=struct('states',num2cell(ones(size(RPEAK_ts))*ECG_event),'states_onset',num2cell(zeros(size(RPEAK_ts))),'arrival_times',num2cell(NaN(size(RPEAK_ts))));

for t=1:numel(RPEAK_ts)
    out(t).states=ECG_event;
    out(t).states_onset=0;
    AT_temp=AT-RPEAK_ts(t);
    out(t).arrival_times=AT_temp(AT_temp>keys.PSTH_WINDOWS{1,3}-0.2 & AT_temp<keys.PSTH_WINDOWS{1,4}+0.2);
end
end




