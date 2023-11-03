function handles=checkUpdates(handles)


% Version managing 
% ALWAYS USE X.xxx format !!!!

handles.iElectrodes_version='1.020';
handles.iElectrodes_date='12 May 2023';

% overwrite version.txt automatically - Important for developing new
% versions

fid=fopen([handles.pathstr '/version.txt'],'w+'); 
if fid~=-1
    fprintf(fid,'%s \n',handles.iElectrodes_version);
    fprintf(fid,'%s \n',handles.iElectrodes_date);
    fclose(fid);
else
    warning('cannot update version.txt');
end

web_data=[];
try
    web_data=webread('https://sourceforge.net/p/ielectrodes/code/ci/master/tree/version.txt?format=raw');
catch 
    warning('Unable to check last version on-line' );
end
if ~isempty(web_data)
    last_version=web_data(1:5);
    last_date=web_data(8:end);

if str2double(last_version)>str2double(handles.iElectrodes_version)
    
    % Construct a questdlg with 2 options
    choice = questdlg( {'Would you like to download the last version?';
          '';
          ['Your version: ' handles.iElectrodes_version ' - ' handles.iElectrodes_date];
          ['Last version: ' last_version ' - ' last_date]} , ...
        'You don''t have the last iElectrodes version',...
        'Yes (recomended)','No','Yes (recomended)');
    
    % Handle response
    switch choice
        case 'Yes (recomended)'
            % open browser
            web('https://sourceforge.net/projects/ielectrodes/','-browser');
            %close gui
            %close(hObject);
            return;
        case 'No'
            % do nothing
    end
    
else
    disp('You have the last version of iElectrodes :-)');
end
end
