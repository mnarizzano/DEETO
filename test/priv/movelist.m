function varargout = movelist(varargin)
% MOVELIST MATLAB code for movelist.fig
%      MOVELIST, by itself, creates a new MOVELIST or raises the existing
%      singleton*.
%
%      H = MOVELIST returns the handle to a new MOVELIST or the handle to
%      the existing singleton*.
%
%      MOVELIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVELIST.M with the given input arguments.
%
%      MOVELIST('Property','Value',...) creates a new MOVELIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before movelist_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to movelist_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help movelist

% Last Modified by GUIDE v2.5 14-Apr-2017 15:49:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @movelist_OpeningFcn, ...
                   'gui_OutputFcn',  @movelist_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before movelist is made visible.
function movelist_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to movelist (see VARARGIN)

% Choose default command line output for movelist
% handles.output = hObject;

% load varargin as a cell array of strings channel labels
handles.originalList=varargin{1};
handles.actualList=varargin{1};
handles.originalOrder=1:length(varargin{1});
handles.actualOrder=1:length(varargin{1});
set(handles.list,'String',handles.actualList);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes movelist wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = movelist_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.actualOrder;
varargout{2} = handles.actualList;

% when output is defined, close the window
delete(handles.figure1);

% --- Executes on selection change in list.
function list_Callback(hObject, eventdata, handles)
% hObject    handle to list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list


% --- Executes during object creation, after setting all properties.
function list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UpButton.
function UpButton_Callback(hObject, eventdata, handles)
% hObject    handle to UpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
v=get(handles.list,'value');
if v>1
%     tempV=handles.actualList{v};
%     handles.actualList{v}=handles.actualList{v-1};
%     handles.actualList{v-1}=tempV;
%     set(handles.list,'String',handles.actualList);
%     set(handles.list,'value',v-1);
    tempV=handles.actualOrder(v);
    handles.actualOrder(v)=handles.actualOrder(v-1);
    handles.actualOrder(v-1)=tempV;
    handles.actualList=handles.originalList(handles.actualOrder);
    set(handles.list,'String',handles.actualList);
    set(handles.list,'value',v-1);
end
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in DownButton.
function DownButton_Callback(hObject, eventdata, handles)
% hObject    handle to DownButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
v=get(handles.list,'value');
if v<length(handles.actualList)
%     tempV=handles.actualList{v};
%     handles.actualList{v}=handles.actualList{v+1};
%     handles.actualList{v+1}=tempV;
%     set(handles.list,'String',handles.actualList);
%     set(handles.list,'value',v+1);
    tempV=handles.actualOrder(v);
    handles.actualOrder(v)=handles.actualOrder(v+1);
    handles.actualOrder(v+1)=tempV;
    handles.actualList=handles.originalList(handles.actualOrder);
    set(handles.list,'String',handles.actualList);
    set(handles.list,'value',v+1);
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in OKbutton.
function OKbutton_Callback(hObject, eventdata, handles)
% hObject    handle to OKbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.actualList is the function output
% no changes need

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end

% --- Executes on button press in Cancelbutton.
function Cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.actualList is the function output
handles.actualList=handles.originalList;
handles.actualOrder=handles.originalOrder;

% Update handles structure
guidata(hObject, handles);

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% disable close window function

% Hint: delete(hObject) closes the figure
% delete(hObject);
