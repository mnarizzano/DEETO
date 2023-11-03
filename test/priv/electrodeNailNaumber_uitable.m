function electrodeNailNaumber_uitable (hObject, handles)
% graphical interface to introduce the electrode number of nailed electrode
% coordinates. changes will be stored in handles.uitable_elecNum

% use in the following way
%     guidata(hObject, handles);     % % Update content in handles structure
%     electrodeNailNaumber_uitable (hObject, handles); %use graphical interface. This will change content in handles.
%     handles = guidata(hObject); % retrive updated data
    

coords=handles.GS;
N=size(coords,1); % number of selected electrodes
elecNumber=zeros(N,1);
order=1:N;
data=[];

fig = uifigure('Position',[300 300 752 250]);
set(fig,'name','Define Electrode Number for Nailed Coordinates and close this window ')

uit = uitable(fig,'Data',[order', coords, elecNumber], 'DeleteFcn',{@MyDeleteFcn_uitable, hObject, handles},'Parent',fig,'Position',[25 50 700 200]);
uit.ColumnEditable = [false false false false true];
uit.ColumnName = {'Selection','X','Y','Z','Elec Number' };

% TODO t.SelfAssessedHealthStatus = categorical(t.SelfAssessedHealthStatus,{'Poor','Fair','Good','Excellent'},' Ordinal',true);

waitfor(uit) % wait untilt table is closed

%elecNumber = tableOut(:,end); % save output as vector

end

function data = MyDeleteFcn_uitable(hTable, event, hObject, handles)
  data = hTable.Data;                        % Get data from UI table
%   dat = guidata(handles);                 % Get data stored in main GUI (if any)
  handles.uitable_elecNum = data(:,end);    % Store the UI table data
  guidata(hObject,handles)                  % store the data into the main GUI
end
