function bsa_evaluate_outliers(monkey, sessions,targetBrainArea, inactivation_sessions, path_SaveFig )

%% Is there a difference in outlier between two conditions (inactivation vs baseline)?s


 figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
 set(gcf,'Name','EachSession: invalid time period '); hold on;

for s = 1:length(sessions),
    session_path = sessions{s};
	session_name_idx = strfind(session_path,'201');
	session_name = session_path(session_name_idx(1):session_name_idx(1)+7);
	load([session_path filesep session_name '_ecg.mat']);
    
%     Varable = fieldnames(Tab_outlier); 
%     idx = [strfind(Variable , 'outlier')]
%     length([idx{:,:}])
%     Variable(idx)
%     strcmp(idx , 1)
%     [Tab_outlier.outliers_all_abs]
%     [Tab_outlier.outlier]
%     [Tab_outlier.outliers_hampel_abs]
%     [Tab_outlier.outlier_Mode_abs]
% How many seconds did we exclude in a session? 
if ismember(session_name,inactivation_sessions)
    plot(2, sum([Tab_outlier.duration_NotValidSegments_s]), '.','MarkerSize',30); hold on;
    text(2.2, sum([Tab_outlier.duration_NotValidSegments_s]),session_name,'fontsize',10); 
else
   plot(1, sum([Tab_outlier.duration_NotValidSegments_s]), '.','MarkerSize',30); hold on;
   text(1.2, sum([Tab_outlier.duration_NotValidSegments_s]),session_name,'fontsize',10); 
end
ylabel('duration of not valid periods (s)','fontsize',26 , 'Interpreter', 'none');
set(gca,'xlim',[0 3],'Xtick',[1:2],'XTickLabel',{'Control' 'Injection'});

% hold off; 
% 
% figure('Position',[200 200 1200 900],'PaperPositionMode','auto'); % ,'PaperOrientation','landscape'
% set(gcf,'Name','EachSession: % of outlier related to Hampel treshold '); hold on;
% if ismember(session_name,inactivation_sessions)
%     g(s)= plot(2, sum([Tab_outlier.outliers_hampel_pct]), '.','MarkerSize',30); hold on;
%      g(s)=text(2.2, sum([Tab_outlier.outliers_hampel_pct]),session_name,'fontsize',10)
% else
%     g(s)= plot(1, sum([Tab_outlier.outliers_hampel_pct]), '.','MarkerSize',30); hold on;
%     text(1.2, sum([Tab_outlier.outliers_hampel_pct]),session_name,'fontsize',10)
% end


end % session
   h = [];
        h(1) = figure(1);
 print(h,[path_SaveFig filesep 'png' filesep targetBrainArea '_' monkey '_' 'OUTLIER_STATISTIC_NotValidDuration' ], '-dpng')
        set(h,'Renderer','Painters');
        set(h,'PaperPositionMode','auto')
        compl_filename =  [path_SaveFig filesep 'ai' filesep targetBrainArea '_', monkey, '_',  DVs{ind_DV} '_Blocks.ai'] ;
        print(h,'-depsc',compl_filename);
        close all;


%% Is there a difference between rest vs task?
%% variability between Blocks in a session

