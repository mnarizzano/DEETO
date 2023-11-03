function varargout = elecImportDlg(varargin)
% ELECIMPORTDLG MATLAB code for elecImportDlg.fig
% use as [type,rows,columns]=elecImportDlg(labelArray,Nelectrodes));
%      output: type = 'grid' / 'depth'
%      rows and columns
%
%      ELECIMPORTDLG, by itself, creates a new ELECIMPORTDLG or raises the existing
%      singleton*.
%
%      H = ELECIMPORTDLG returns the handle to a new ELECIMPORTDLG or the handle to
%      the existing singleton*.
%
%      ELECIMPORTDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ELECIMPORTDLG.M with the given input arguments.
%
%      ELECIMPORTDLG('Property','Value',...) creates a new ELECIMPORTDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before elecImportDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to elecImportDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help elecImportDlg

% Last Modified by GUIDE v2.5 31-Jan-2018 10:22:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @elecImportDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @elecImportDlg_OutputFcn, ...
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


% --- Executes just before elecImportDlg is made visible.
function elecImportDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to elecImportDlg (see VARARGIN)

% Choose default command line output for elecImportDlg
handles.output = hObject;

set(handles.nameText,'String',varargin{1});
handles.Nelectrodes=varargin{2};
set(handles.NelectrodesText,'String', num2str(handles.Nelectrodes));
handles.Type='grid'; % by default

if handles.Nelectrodes<20
    set(handles.depthButton,'value',1);
    set(handles.gridButton,'value',0);
    set(handles.rowsEdit,'String','1');
    set(handles.colsEdit,'String',num2str(handles.Nelectrodes));
    set(handles.rowsEdit,'Enable','off');
    set(handles.colsEdit,'Enable','off');
    handles.Type='depth';
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes elecImportDlg wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = elecImportDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;
varargout{1} = handles.Type;
varargout{2} = str2num(get(handles.rowsEdit,'string'));
varargout{3} = str2num(get(handles.colsEdit,'string'));

% 
% % when output is defined, close the window
delete(handles.figure1);

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1



% --- Executes on button press in gridButton.
function gridButton_Callback(hObject, eventdata, handles)
% hObject    handle to gridButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gridButton
set(handles.depthButton,'value',0);
set(handles.rowsEdit,'Enable','on');
set(handles.colsEdit,'Enable','on');
handles.Type='grid';
guidata(hObject, handles);

% --- Executes on button press in depthButton.
function depthButton_Callback(hObject, eventdata, handles)
% hObject    handle to depthButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of depthButton
set(handles.gridButton,'value',0);
set(handles.rowsEdit,'String','1');
set(handles.colsEdit,'String',num2str(handles.Nelectrodes));
set(handles.rowsEdit,'Enable','off');
set(handles.colsEdit,'Enable','off');
handles.Type='depth';
guidata(hObject, handles);

function rowsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to rowsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rowsEdit as text
%        str2double(get(hObject,'String')) returns contents of rowsEdit as a double


% --- Executes during object creation, after setting all properties.
function rowsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rowsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function colsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to colsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of colsEdit as text
%        str2double(get(hObject,'String')) returns contents of colsEdit as a double


% --- Executes during object creation, after setting all properties.
function colsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nextbutton.
function nextbutton_Callback(hObject, eventdata, handles)
% hObject    handle to nextbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

rows = str2num(get(handles.rowsEdit,'string'));
cols = str2num(get(handles.colsEdit,'string'));

if rows*cols==handles.Nelectrodes
    if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.figure1);
    else
        % The GUI is no longer waiting, just close it
        delete(handles.figure1);
    end
else
    errordlg('Rows * cols not equal to Number of electrodes')
end
