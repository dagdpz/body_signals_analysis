function bsa_getSummary_SessionInfo(session_path, pathExcel )
session_path = 'Y:\Projects\PhysiologicalRecording\Data\Curius';
pathExcel = 'Y:\Logs\Inactivation\Curius\Curius_Inactivation_log_since201905.xlsx';
% check in the folder the monkey which sessions
SessionName         = dir([session_path filesep '201*']);
Table_SessionInfo   = [];
PreviousSavedTable  = dir([session_path filesep '*.mat']);

if ~isempty(PreviousSavedTable) % there is a file & there is THE table
    %& %check if table includes all sessions in this directionary
     table = readtable(pathExcel);
     load([session_path filesep PreviousSavedTable(2).name])
     %all Dates from the      SessionName.name nare also included in the
     %file

    idx=find(ismember(Table_SessionInfo.date ,    {SessionName.name}));
    length(Table_SessionInfo.date)
    length( {SessionName.name})


else %no file with table -> create the table OR not all sessions included
    %open the excel sheet
    
    table = readtable(pathExcel);
    t = [];
    session_name  = unique(table.date);
    session_name = session_name(~isnan(session_name)); 
    
    for i_Sess = 1: length( session_name)%
        table_session =  table(table.date == session_name(i_Sess),:);
        if  (sum(strcmp(table_session.volume_ul , table_session.volume_ul(1)) == 0 ) > 0) || ...
                (sum(strcmp(table_session.experiment , table_session.experiment(1)) == 0 ) > 0)  || ...
                (sum(strcmp(table_session.depthfromTheTopOfTheGrid_mm , table_session.depthfromTheTopOfTheGrid_mm(1)) == 0 ) > 0)
            disp([ 'the entries for this session ' num2str(session_name(i_Sess)) ' vary between runs'])
            %Which Variable?
            %
        else
            t(i_Sess).monkey         =  table_session.monkey{1}  ;
            t(i_Sess).date           =  num2str(table_session.date(1) ) ;
            t(i_Sess).experiment     =  table_session.experiment{1}  ;
            t(i_Sess).brain_area     =  table_session.brain_area{1}  ;
            t(i_Sess).hemisphere     =  table_session.hemisphere{1}  ;
            t(i_Sess).x_grid         =  table_session.x_grid{1}  ;
            t(i_Sess).y_grid         =  table_session.y_grid{1}  ;
            t(i_Sess).concentration_mg_ml =  table_session.concentration_mg_ml(1)  ;
            t(i_Sess).volume_ul      =  table_session.volume_ul{1}  ;
            t(i_Sess).substance      =  table_session.substance{1}  ;
            t(i_Sess).depthfromTheTopOfTheGrid_mm =  table_session.depthfromTheTopOfTheGrid_mm{1}  ;
            t(i_Sess).injection_method =  table_session.injection_method{1}  ;
            t(i_Sess).ePhys          =  table_session.ePhys{1}  ;
            t(i_Sess).nrRuns         =  max(table_session.run)  ;
            t(i_Sess).nrBlock        =  max(table_session.block) ;
            
            
            table_session.injection(table_session.block == 0) = num2cell(nan(1,sum(table_session.block == 0)));
            t(i_Sess).first_inj_block =  min(table_session.block(strcmp(table_session.injection , 'Post'))) ;
        end
        
        
    end %Session
    Table_SessionInfo = struct2table(t);
    save([session_path filesep t(i_Sess).monkey '_Table_SessionInfos' ],'Table_SessionInfo');
    save([session_path filesep t(i_Sess).monkey '_Structure_SessionInfos' ],'t');
    
end

