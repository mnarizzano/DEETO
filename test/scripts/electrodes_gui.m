%     iElectrodes
%     Copyright (C) 2014, 2015, 2016, 2017, 2018  Alejandro Omar Blenkmann
%     ablenkmann@gmail.com
%     https://sourceforge.net/projects/ielectrodes/  
%     
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%     iElectrodes toolbox includes parts of code developed by Jimmy Shen
%     (jimmy@rotman-baycrest.on.ca) (NIfTI toolbox), Qianqian Fang
%     (iso2mesh), Panagiotis Moulos (addremovelist), Levente Hunyadi
%     (spherefit),Divahar Jayaraman (Cylinder), Dirk-Jan Kroon 
%     (refinepatch), Jeng-Ren Duann (readedf), Wellcome Trust Centre for 
%     Neuroimaging (SPM12).
%     Related codes from these authors are included for user convenience. 
%     The copyrights of these codes are reserved by the original parties.
%
%     iElectrodes toolbox is FOR RESEARCH PURPOSES ONLY. This software is
%     for research purposes only and has NOT BEEN APPROVED FOR CLINICAL 
%     USE.
%     If you publish results whose generation used this software, you must
%     provide attribution to the author of the software by referencing the
%     appropriate papers, as outlined on the iElectrodes website
%     (https://sourceforge.net/projects/ielectrodes/wiki).
%
%     IN NO EVENT SHALL THE AUTHOR, OR THE DISTRIBUTORS BE LIABLE TO ANY
%     PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
%     DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS
%     SOFTWARE, ITS DOCUMENTATION, OR ANY DERIVATIVES THEREOF, EVEN IF THE
%     AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%     THE AUTHOR, AND THE DISTRIBUTORS SPECIFICALLY DISCLAIM ANY
%     WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
%     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND
%     NON-INFRINGEMENT. THIS TOOLBOX IS PROVIDED ON AN “AS IS” BASIS, AND
%     THE AUTHOR AND DISTRIBUTORS HAVE NO OBLIGATION TO PROVIDE
%     MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
%


%%

function varargout = electrodes_gui(varargin)
% ELECTRODES_GUI MATLAB code for electrodes_gui.fig
%      ELECTRODES_GUI, by itself, creates a new ELECTRODES_GUI or raises the existing
%      singleton*.
%
%      H = ELECTRODES_GUI returns the handle to a new ELECTRODES_GUI or the handle to
%      the existing singleton*.
%
%      ELECTRODES_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ELECTRODES_GUI.M with the given input arguments.
%
%      ELECTRODES_GUI('Property','Value',...) creates a new ELECTRODES_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before electrodes_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to electrodes_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help electrodes_gui

% Last Modified by GUIDE v2.5 14-Feb-2018 09:37:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @electrodes_gui_OpeningFcn, ...
    'gui_OutputFcn',  @electrodes_gui_OutputFcn, ...
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

% --- Outputs from this function are returned to the command line.
function varargout = electrodes_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes just before electrodes_gui is made visible.
function electrodes_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to electrodes_gui (see VARARGIN)

% Choose default command line output for electrodes_gui
handles.output = hObject;

[handles.pathstr,~,~] = fileparts(which('electrodes_gui.m'));
global debugging;
debugging=0;

if isunix
    addpath(genpath([handles.pathstr '/priv']));
else
    addpath(genpath([handles.pathstr '\priv']));
end

spm('defaults','PET');

disp('Welcome to iElectrodes.');
disp('iElectrodes toolbox is FOR RESEARCH PURPOSES ONLY. This software is');
disp('for research purposes only and has NOT BEEN APPROVED FOR CLINICAL USE.'); 
disp('');
disp('Help about using iElectrodes can be found online in ');
disp('https://sourceforge.net/p/ielectrodes/wiki/Home/')


% check for updates - current version is defined inside
handles=checkUpdates(handles);

% make project structure
handles=checkProjectStructure([],handles);

% load default options
options=[];
handles.options=default_ielectrodes_options(options);

colors=[];
handles.colors=defaultColors(colors);

% reset gui variables
handles=defaultGuiVariables(handles);

% layout 
if ~handles.options.showLocalizeTools;
    set(handles.PanelClustering,'Visible','off');
    set(handles.PanelLabel,'Visible','off');
end

if ~handles.options.showPlanTools;    
    set(handles.PanelPlanning,'Visible','off');
end

% Update handles structure
guidata(hObject, handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Construct a questdlg with three options
choice = questdlg('Do you want to save your project?', ...
    'Exit iElectrodes', ...
    'Yes','No','Cancel','Cancel');
% Handle response
switch choice
    case 'Yes'
        saved=Savepushtool_ClickedCallback(hObject, eventdata, handles);
        % Hint: delete(hObject) closes the figure
        if saved
            delete(hObject);
        end
    case 'No'
        % Hint: delete(hObject) closes the figure
        delete(hObject);
        
    case 'Cancel'
        return;
end

disp('Thank you for using iElectrodes.');
disp('Please remember to cite our paper Blenkmann et al., 2017 in Frontiens Neuroinformatics.');

       

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%                 MOUSE                       %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%              left click                     %%%%%%%%%%%%%%%
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project.')
    return
end

G=gca;
DD=get(G, 'CurrentPoint');
d1=DD(1,1); d2=DD(1,2);

%axes limits
xLimits = get(G, 'xlim');
yLimits = get(G, 'ylim');

if G == handles.axes2 || G == handles.axes1
        %handles.rotate3d.Enable='on';
        
        [pout]  = select3d(handles);
        
        if isempty(pout) %not a valid point
            %disp('not a valid point');
            return;
        end 
        
        D=AnatSpace2Mesh(pout',handles.S2);
        
        set(handles.sliderX,'Value',D(1));
        set(handles.sliderY,'Value',D(2));
        set(handles.sliderZ,'Value',D(3));

        handles=updateTAC(handles);
elseif d1>xLimits(1) && d1<xLimits(2) && d2>yLimits(1) && d2<yLimits(2)
    
    % X-view
    % z=d2
    % y=d1
    
    if G == handles.axesX
        set(handles.sliderY,'Value',d1);
        set(handles.sliderZ,'Value',d2);
        
        % Y-view
        %x=d1
        %z=d2;
    elseif G == handles.axesY
        set(handles.sliderX,'Value',d1);
        set(handles.sliderZ,'Value',d2);
        
        % Z-view
        %x=d1
        %y=d2
    elseif G == handles.axesZ
        set(handles.sliderX,'Value',d1);
        set(handles.sliderY,'Value',d2);
        
        
    end
    handles=updateTAC(handles);
end

% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%                scroll                       %%%%%%%%%%%%%%%
% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project.')
    return
end
step=-eventdata.VerticalScrollCount;
dim=size(handles.T1.img);

F=get(handles.figure1, 'CurrentPoint'); %mouse position in figure

% panel psition (it is easiest than axes position)
xPos=get(handles.PanelX,'pos');
yPos=get(handles.PanelY,'pos');
zPos=get(handles.PanelZ,'pos');

% X-view
tf1 = xPos(1) <= F(1) && F(1) <= xPos(1) + xPos(3);
tf2 = xPos(2) <= F(2) && F(2) <= xPos(2) + xPos(4);

if tf1 && tf2
    x=get(handles.sliderX,'Value') + step;
    
    if x>0 && x < dim(1)
        set(handles.sliderX,'Value',x);
    end
end

% Y-view
tf1 = yPos(1) <= F(1) && F(1) <= yPos(1) + yPos(3);
tf2 = yPos(2) <= F(2) && F(2) <= yPos(2) + yPos(4);

if tf1 && tf2
    y=get(handles.sliderY,'Value') + step;
    
    if y>0 && y < dim(2)
        set(handles.sliderY,'Value',y);
    end
end

% Z-view
tf1 = zPos(1) <= F(1) && F(1) <= zPos(1) + zPos(3);
tf2 = zPos(2) <= F(2) && F(2) <= zPos(2) + zPos(4);

if tf1 && tf2
    z=get(handles.sliderZ,'Value') + step;
    
    if z>0 && z < dim(3)
        set(handles.sliderZ,'Value',z);
    end
end

handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%            TOOLBAR                          %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%           New - MRI load             %%%%%%%%%%%%%%%%%%%%
function Newuipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Newuipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% load TAC

if ~isempty(handles.T1)
    % Construct a questdlg with three options
    choice = questdlg('Do you want to save your project?', ...
        '', ...
        'Yes','No','Cancel','Cancel');
    % Handle response
    switch choice
        case 'Yes'
            saved=Savepushtool_ClickedCallback(hObject, eventdata, handles);
            if saved   
                %nothing to do
            else
                %unable to save
                return;
            end
        case 'No'
            % nothing to do
        case 'Cancel'
            return;
    end
end

% load MRI
[T1file,PathName]=uigetfile('*.nii', 'Load MRI',handles.PathName);

if T1file ~=0
        
%    [T1,S2,T1file]=loading_images(PathName,T1file);
    [T1]=loading_images_SPM(PathName,T1file,4,handles.options.image_voxdim); %interpolation = 4
    disp (['Loaded MRI from ' PathName, T1file])

    handles=defaultGuiVariables(handles);
    handles=checkProjectStructure([],handles);
 
    %fiugre name
    set(handles.figure1,'name',['iElectrodes - ' PathName T1file]);
    
    handles.T1=T1; % MRI T1 origninal (SPM data structure)
    handles.S2=T1.vol.mat(1:3,:);
    
    handles.PathName=PathName;

    handles.maxValue=[];
    
    handles=updateMix_TAC_MR(handles);    
     
    [xM,yM,zM]=size(T1.img);
    set(handles.sliderX,'Min',1,'Max',xM,'SliderStep',[ 1/(xM-1) 10/(xM-1)],'Value',xM/2);
    set(handles.sliderY,'Min',1,'Max',yM,'SliderStep',[ 1/(yM-1) 10/(yM-1)],'Value',yM/2);
    set(handles.sliderZ,'Min',1,'Max',zM,'SliderStep',[ 1/(zM-1) 10/(zM-1)],'Value',zM/2);
    set(handles.TargetInXedit,'string','0');
    set(handles.TargetInYedit,'string','0');
    set(handles.TargetInZedit,'string','0');
    set(handles.TargetOutXedit,'string','0');
    set(handles.TargetOutYedit,'string','0');
    set(handles.TargetOutZedit,'string','0');
    set(handles.AzimuthTargetedit,'string','0');
    set(handles.ElevacionTargetedit,'string','0');
    set(handles.TargetNameedit,'string','name');
    set(handles.editArrayName,'string','');
    set(handles.editElecLabels,'string','');
    set(handles.arrayNumberText,'string','0');
    set(handles.elecNumberText,'string','0');
    set(handles.TargetArraytext,'string','0');
    set(handles.nClusText,'string', '0');

    handles.cursor=mesh2AnatSpace([xM/2 yM/2 zM/2], handles.S2);
      
    guidata(hObject, handles);
    
    view(handles.axes2,-135,25);
    handles=updateElectrodes3D(handles);
    handles=updateTAC(handles);
    handles=updatePlot(handles);
    
end

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%     CT and brain mask load          %%%%%%%%%%%%%%%%%%%%
function LoadCTtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to LoadCTtool2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% hObject    handle to Newuipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% load TAC

% MRI should be loaded first
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project')
    return
end

[TACfile,PathName]=uigetfile('*.nii', 'Load CT',handles.PathName);

if TACfile~=0
    
    %    [TAC,S2,TACfile]=loading_images(PathName,TACfile,1,handles.T1); %TAC S2 transformation matrix can be slightly different from MRI
    vprm = spm_imatrix(handles.T1.vol.mat);
    voxdim = vprm(7:9);
    bbox=world_bb(handles.T1.vol);
    [TAC]=loading_images_SPM(PathName,TACfile,4,voxdim,bbox); %interpolation = 4
    disp (['Loaded CT from ' PathName, TACfile])
    %load mask file
    
    [maskfile,PathName]=uigetfile('*.nii', 'Load mask file',PathName);
    
    if maskfile~=0
        %        [inskullMask,~,maskfile]=loading_images(PathName,maskfile,1,handles.T1);
        vprm = spm_imatrix(handles.T1.vol.mat);
        voxdim = vprm(7:9);
        bbox=world_bb(handles.T1.vol);
        [inskullMask]=loading_images_SPM(PathName,maskfile,1,voxdim,bbox); %interpolation = 1
        disp (['Loaded Mask from ' PathName, maskfile])
        

%        mask=logical(inskullMask.img);
        
        handles.TAC=TAC;   % TAC origninal (SPM structure)
        handles.mask=inskullMask; %loading the img and the vol
%        handles.mask=mask; % mask (logical matrix)
        handles.S2=TAC.vol.mat(1:3,:); 
%        handles.S2=S2;     % new transfomation matrix
        maxValue=max(TAC.img(:));
        handles.maxValue=maxValue;
               
        set(handles.text1,'String', get(handles.sliderThrMax,'Value')*maxValue);
        set(handles.text2,'String', get(handles.sliderThrMin,'Value')*maxValue);
        
        handles.PathName=PathName;
        
        handles=updateMix_TAC_MR(handles);

        handles.updatePlots.views2D=[1 1 1];     
        handles=updateElectrodes3D(handles);
        handles=updateTAC(handles);
        handles=updatePlot(handles);
    end
end

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%             Save Project             %%%%%%%%%%%%%%%%%%%%
function saved=Savepushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Savepushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saved=0;
if isempty(handles.T1)
    warning ('MRI is empty. Load images first. Click New button or open existing project');
    return;
else
    % get the variables needed to be saved
    s=checkProjectStructure(handles);
    
    if isempty( handles.FileName)
        [FileName,PathName] = uiputfile('*.iel','Save filename',handles.PathName);
    else
        [FileName,PathName] = uiputfile('*.iel','Save filename',[handles.PathName handles.FileName]);
    end
    if FileName ~=0
        handles.FileName=FileName;
        handles.PathName=PathName;
        save([handles.PathName, handles.FileName],'s','-v7.3');
        disp (['Saved project in ' handles.PathName, handles.FileName])
        
        %fiugre name
        set(handles.figure1,'name', ['iElectrodes - ' handles.PathName, handles.FileName]);
        
        saved=1;
    else
        return;
    end
end
guidata(hObject, handles);
    
%%%%%%%%%%%%%%%%%             Open Project             %%%%%%%%%%%%%%%%%%%%
function Openpushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Openpushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if ~isempty(handles.T1)
    % Construct a questdlg with three options
    choice = questdlg('Do you want to save your project?', ...
        '', ...
        'Yes','No','Cancel','Cancel');
    % Handle response
    switch choice
        case 'Yes'
            saved=Savepushtool_ClickedCallback(hObject, eventdata, handles);
            if saved   
                %nothing to do
            else
                %unable to save
                return;
            end
        case 'No'
            % nothing to do
        case 'Cancel'
            return;
    end
end

[FileName,PathName]=uigetfile('*.iel', 'Load iElectrodes file', handles.PathName);

if FileName ~=0   
    % varialbe is loaded as s
    load([PathName, FileName],'-mat');
    disp (['Loaded project from ' PathName, FileName])
       
    % load defaults, including plot updates
    handles=defaultGuiVariables(handles);
    % load .iel structure
    handles=checkProjectStructure(s,handles);

    handles.FileName=FileName;
    handles.PathName=PathName;
    
    if ~isempty(handles.electrodes)
        set(handles.arrayNumberText,'String','1');
        set(handles.elecNumberText,'String','1');
        set(handles.editArrayName,'String',handles.electrodes{1}.Name);
        set(handles.editElecLabels,'string',handles.electrodes{1}.ch_label{1});
        
    else
        
        set(handles.editArrayName,'string','');
        set(handles.editElecLabels,'string','');
        set(handles.arrayNumberText,'string','0');
        set(handles.elecNumberText,'string','0');
    end
    
    if ~isempty(handles.targets)
        l=1;
        
        set(handles.TargetArraytext,'String',num2str(l));
        UpdateTargetEditBox(hObject, eventdata, handles);   %this modifies handles
        handles = guidata(hObject);
    else
        
        set(handles.TargetInXedit,'string','0');
        set(handles.TargetInYedit,'string','0');
        set(handles.TargetInZedit,'string','0');
        set(handles.TargetOutXedit,'string','0');
        set(handles.TargetOutYedit,'string','0');
        set(handles.TargetOutZedit,'string','0');
        set(handles.AzimuthTargetedit,'string','0');
        set(handles.ElevacionTargetedit,'string','0');
        set(handles.TargetNameedit,'string','name');
        set(handles.TargetArraytext,'string','0');
    end
    
    set(handles.text1,'String', get(handles.sliderThrMax,'Value')*handles.maxValue);
    set(handles.text2,'String', get(handles.sliderThrMin,'Value')*handles.maxValue);
    set(handles.nClusText,'string',num2str(size(handles.GS,1)));

    
    % by default not show projections (they may not exist!)
    set(handles.projectSCEcheckbox,'Value',0);

    handles=updateMix_TAC_MR(handles);
    [xM,yM,zM]=size(handles.T1.img);
    set(handles.sliderX,'Min',1,'Max',xM,'SliderStep',[ 1/(xM-1) 10/(xM-1)],'Value',xM/2);
    set(handles.sliderY,'Min',1,'Max',yM,'SliderStep',[ 1/(yM-1) 10/(yM-1)],'Value',yM/2);
    set(handles.sliderZ,'Min',1,'Max',zM,'SliderStep',[ 1/(zM-1) 10/(zM-1)],'Value',zM/2);
    handles.cursor=mesh2AnatSpace([xM/2 yM/2 zM/2], handles.S2);

  
    if ~isempty(handles.wmparc)
        set(handles.MNILabelstogglebutton,'state','off');
    else
        set(handles.MNILabelstogglebutton,'state','on');    
    end

    view(handles.axes2,-135,25);
    handles=updateElectrodes3D(handles);
    handles=updateTAC(handles);
    handles=updatePlot(handles);

    %figure name
    set(handles.figure1,'name',['iElectrodes - ' handles.PathName, handles.FileName]);
end

% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
%%%%%%%%%%%      Export electrode structure or coordinates    %%%%%%%%%%%%%
function SaveElectrodespushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SaveElectrodespushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty (handles.electrodes)
    warning('Electrodes is empty');
    return;
end

[selection,valid] = listdlg('PromptString','Select output format:',...
    'SelectionMode','single',...
    'ListString',{'iElectrodes  - electrodes structure (.mat)',...
    'iElectrodes - electrodes (.txt)', 'EEGLAB - projections (.txt)',...
    'FIELDTRIP - electrodes (.mat)', 'FIELDTRIP - projections(.mat)'},...
    'ListSize', [300 150]);


if valid
    electrodes=handles.electrodes;
    i=1; x=[]; y=[]; z=[];

    if find (selection==[2 4]) % export coordinates electrodes
        for j=1:length(electrodes)
            for k=1:electrodes{j}.nElectrodes
                %get coordinates
                x(i)=electrodes{j}.x(k);
                y(i)=electrodes{j}.y(k);
                z(i)=electrodes{j}.z(k);
                
                % electrode labels
                %aStr=electrodes{j}.ch_label{k};
                %aStr(~isstrprop(aStr,'alphanum')) = '';  % remove non alpha num-characters
                %cl{i}=aStr;
                cl{i}=electrodes{j}.ch_label{k};
                i=i+1;
            end
        end
    end
    
    if find (selection==[3 5]) % export coordinates projections
        for j=1:length(electrodes)
            for k=1:electrodes{j}.nElectrodes
                %get coordinates
                x(i)=electrodes{j}.projection.x(k);
                y(i)=electrodes{j}.projection.y(k);
                z(i)=electrodes{j}.projection.z(k);
                
                % electrode labels
                %aStr=electrodes{j}.ch_label{k};
                %aStr(~isstrprop(aStr,'alphanum')) = '';  % remove non alpha num-characters
                %cl{i}=aStr;
                cl{i}=electrodes{j}.ch_label{k};
                i=i+1;
            end
        end
    end
    
    switch selection
        case 1 % MATLAB
            [FileName,PathName] = uiputfile('*.mat','Save electrodes structure', handles.PathName);
            if FileName~=0
                handles.PathName=PathName;
                save([handles.PathName, FileName],'electrodes');
                disp (['Saved electrode structure in ' handles.PathName, FileName])
            end
        case 2 % elec - EEGLAB
            [FileName,PathName] = uiputfile('*.txt','Save electrode coordinates in EEGLAB format', handles.PathName);
            if FileName~=0
                handles.PathName=PathName;
                fid=fopen([PathName FileName],'w+'); %overwrite
                for i=1:length(x)
                    fprintf(fid,'%s\t %e\t %e\t %e\n',cl{i},x(i),y(i),z(i));
                end
                disp([' electrode coordinates saved in ' PathName FileName ] )
                disp (' load to EEGLAB with the command:')
                disp (' EEG.chanlocs=readlocs( [ path file] , ''filetype'', ''custom'',''format'',{''labels'',''-Y'',''X'',''Z''}) ')
                fclose(fid)
            end
            
        case 3 % proj - EEGLAB
            
            [FileName,PathName] = uiputfile('*.txt','Save projection coordinates in EEGLAB format', handles.PathName);
            if FileName~=0
                handles.PathName=PathName;
                fid=fopen([PathName FileName],'w+'); %overwrite
                for i=1:length(x)
                    fprintf(fid,'%s\t %e\t %e\t %e\n',cl{i},x(i),y(i),z(i));
                end
                disp([' projection coordinates saved in ' PathName FileName ] )
                disp (' load to EEGLAB with the command:')
                disp (' EEG.chanlocs=readlocs( [ path file] , ''filetype'', ''custom'',''format'',{''labels'',''-Y'',''X'',''Z''}) ')
                fclose(fid)
            end

        case 4 % elec - FIELDTRIP
            
            elec.label=cl;
            elec.elecpos=[x',y',z'];
            % elec.chanpos= []; 
            % elec.tra = []; combination to make channels
            elec.unit='mm';
            elec.coordsys=handles.currentSpace; % 'MNI' or 'Native' (defined by user)
            elec.adjMat=concatenateAdjMat(electrodes); % Adjacency Matrix
            elec.cfg.method = 'iElectrodes';
            elec.cfg.projection='No';
            
            [FileName,PathName] = uiputfile('*.mat','Save electrode coordinates in FIELDTRIP structure', handles.PathName);
            if FileName~=0
                handles.PathName=PathName;
                save([handles.PathName, FileName],'elec');
                disp (['Saved electrode coordinates in FIELTRIP structure in ' handles.PathName, FileName])
            end

           
        case 5 % proj - FIELDTRIP
            
            elec.label=cl;
            elec.elecpos=[x',y',z'];
            % elec.chanpos= []; 
            % elec.tra = []; combination to make channels
            elec.unit='mm';
            elec.coordsys=handles.currentSpace; % 'MNI' or 'Native' (defined by user)
            elec.adjMat=concatenateAdjMat(electrodes); % Adjacency Matrix
            elec.cfg.method = 'iElectrodes';
            elec.cfg.projection='Yes';
            
            [FileName,PathName] = uiputfile('*.mat','Save projection coordinates in FIELDTRIP structure', handles.PathName);
            if FileName~=0
                handles.PathName=PathName;
                save([handles.PathName, FileName],'elec');
                disp (['Saved projections in FIELTRIP structure in ' handles.PathName, FileName])
            end

            
    end
end


% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%            Load electrode structure               %%%%%%%%%%%%%
function LoadElectrodespushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to LoadElectrodespushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% MRI should be loaded first
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project')
    return
end


[selection,valid] = listdlg('PromptString','Select file format to import:',...
    'SelectionMode','single',...
    'ListString',{'iElectrodes - electrodes structure (.mat)',...
    'EEGLAB dataset- electrodes (.set)', 'FIELDTRIP - elec structure (.mat)'},...
    'ListSize', [300 150]);

% all methods should end with a elecNew cell of electrodes
if valid
    switch selection
        case 1 % load  coordinates iElectrodes electrodes structure
        [FileName,PathName] = uigetfile('*.mat','Load electrodes structure', handles.PathName);

        if FileName~=0
            handles.PathName=PathName;
            s=load([handles.PathName, FileName],'electrodes');
            if ~isfield(s,'electrodes')
                warning(['The file ' handles.PathName FileName 'does not contain an electrodes structure]']);
                return;
            end
            electrodes=s.electrodes;
            
            % electrodes en forma de estructura los convierto a celda
            if isstruct(electrodes)
                electrodes2=electrodes;
                clear electrodes
                for i=1:length(electrodes2)
                    electrodes{i}=electrodes2(i);
                end
                clear electrodes2
            end
            
            elecNew=checkElectrodeStructure(electrodes); 
        else
            return;
        end
    
        case 2 % load EEGLAB coordinates electrodes
        [FileName,PathName] = uigetfile('*.set','Load EEGLAB dataset', handles.PathName);

        if FileName~=0
            handles.PathName=PathName;
            load([handles.PathName, FileName],'EEG','-mat'); %load as matlab file EEG structure
            labels={EEG.chanlocs.labels};
            pos = [-[EEG.chanlocs.Y];  [EEG.chanlocs.X];  [EEG.chanlocs.Z] ]'; 

        else
            return;
        end
   
    case 3 % load FIELDTRIP coordinates electrodes
        [FileName,PathName] = uigetfile('*.mat','Load FIELDTRIP elec structure', handles.PathName);

        if FileName~=0
            handles.PathName=PathName;
            s=load([handles.PathName, FileName],'elec'); %load as matlab file elec structure
            if ~isfield(s,'elec')
                warning(['The file ' handles.PathName FileName 'does not contain an elec structure]']);
                return;
            end
            labels=s.elec.label;
            pos=s.elec.elecpos;
            
            % remove if there is any NaN coordinate electrode
            i=find(sum(isnan(pos)')');
            pos(i,:)=[]; 
            labels(i)=[];
        else
            return;
        end
    end
    
    if find (selection==[2 3]) % EEGLAB or MATLAB (or txt file future)
        % make elec structure out of labels{Nx1} and pos[Nx3]
        % ask for the different types of arrays, index and label
        % automatically
        N=length(labels);
        % get array names
        for i=1:N
            l=labels{i};
            d=isstrprop(l, 'alpha'); 
            labelsAlpha{i}=l(d);
        end
        [labelsArray,~,ic]=unique(labelsAlpha); % ic==i contains the indexes to the electrodes in array labelsArray(i)
        A=length(labelsArray); 
        button=questdlg([ [num2str(A) ' arrays were found: '] labelsArray 'Continue?'],'','Yes','No','Yes');
        if strcmp(button,'No')
            return
        end
        for i=1:A
            [type,rows,columns]=elecImportDlg(labelsArray{i},sum(ic==i));
            
            % define the basic fields
            elecNew{i}.Name=labelsArray{i};
            elecNew{i}.nElectrodes=sum(ic==i);
            elecNew{i}.x=pos(ic==i,1);
            elecNew{i}.y=pos(ic==i,2);
            elecNew{i}.z=pos(ic==i,3);
            elecNew{i}.rows=rows;
            elecNew{i}.columns=columns;
            elecNew{i}.ch_label=labels(ic==i);
            elecNew{i}.Type=type;
            elecNew{i}.adjMat=makeAdjMat(rows,columns);
            elecNew{i}=checkElectrodeStructure(elecNew{i}); % check one by one. Makes it easy to detect errors
        end
    end
     
    handles.electrodes=[handles.electrodes elecNew]; %append new elecs to old ones
    
    set(handles.arrayNumberText,'String','1');
    set(handles.elecNumberText,'String','1');
    set(handles.editArrayName,'String',handles.electrodes{1}.Name);
    set(handles.editElecLabels,'string',handles.electrodes{1}.ch_label{1});
    

    % anatomical labeling (electrodes and projections)
    if strcmp(handles.currentSpace,'MNI'); % options are 'Native' 'MNI'        %strcmp (get(handles.MNILabelstogglebutton,'state'),'on')
        handles=labels2MNIspace(handles);
    else
        handles=labels2NativeSpace(handles);
    end
       
    handles.updatePlots.electrodes=1;
    handles.updatePlots.labels=1;
    handles.updatePlots.elecLines=1;
    handles=updateElectrodes3D(handles);
    handles=updateTAC(handles);
    handles=updatePlot(handles);
    
    % Update handles structure
    guidata(hObject, handles);
    disp (['Loaded electrodes structure from ' PathName, FileName])

end

%%%%%%%%%%%            Make electrode report                  %%%%%%%%%%%%%
function Reportuipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Reportuipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% MRI should be loaded first
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project')
    return
end

if ~isempty(handles.electrodes)
    [FileName,PathName] = uiputfile('.txt','.txt ouput file',handles.PathName);
    if FileName~=0
        aLabels2txt_new(handles.electrodes,[PathName FileName]);
        disp (['Report saved in ' PathName, FileName])

    end
else
    warning ('Electrodes structure is empty');
end

% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
%%%%%%%%%%%%%%%     FreeSurfer Labels structure (aparc+aseg / wmparc)    %%%%%%%%%%%%%%%
function LoadFSlabelsuipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to LoadFSlabelsuipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Not changing handles.currentSpace since can be both 'MNI' or 'Native' space 

% MRI should be loaded first
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project. Then load CT...')
    return
end

%load wmparc anatomical labels
[wmparcFile,PathName]=uigetfile('*.nii', 'Load parcellation file (aparc+aseg / aparc.a2009s / wmparc)',handles.PathName);

if ~isequal(wmparcFile,0)
    handles.PathName=PathName;
    vprm = spm_imatrix(handles.T1.vol.mat);
    voxdim = vprm(7:9);
    bbox=world_bb(handles.T1.vol);
    
    [handles.wmparc]=loading_images_SPM(PathName,wmparcFile,0,voxdim,bbox); %interpolation = nearest neighbour
    handles.wmparcS=handles.wmparc.vol.mat(1:3,:);
    
    load FreeSurferColorLUT.mat;% -> values(1271x1), labels{1271x1}, RGB(1271x3)
    % just for testing, random colors
    % RGB=round(rand(1271,3)*255)/255; %IMPORTANT add right solution to checkProjectStructure
    
    [~,lob]=ismember(int32(handles.wmparc.img),int32(values));
    lob(lob==0)=1; % in case index not found, set to 1 -> unknown
    c=RGB(lob,:)/255;
    handles.wmparcColors=reshape(c,[size(handles.wmparc.img),3]);
    
    
%    [handles.wmparc,handles.wmparcS,wmparcFile]=loading_images(handles.PathName,wmparcFile,2,handles.T1);
    disp (['Loaded FS labels from ' PathName, wmparcFile])
    
%     %anatomical labeling of all electrodes
%     if ~isempty(handles.electrodes)
%         L=length(handles.electrodes);
%         for l=1:L
%             pos=[handles.electrodes{l}.x handles.electrodes{l}.y handles.electrodes{l}.z];
%             lookArround=1; radio=1;
%             if ~isempty(handles.wmparc)
%                 handles.electrodes{l}.aLabels=anatomicLabelFS(pos, [],lookArround,handles.wmparc.img,handles.wmparcS,radio);
%             end
%         end
%     end
%     
%     %anatomical labeling of all planning electrodes
%     if ~isempty(handles.targets)
%         L=length(handles.targets);
%         for l=1:L
%             pos=[handles.targets(l).coordinates(:,1) handles.targets(l).coordinates(:,2) handles.targets(l).coordinates(:,3)];
%             lookArround=1; radio=1;
%             if ~isempty(handles.wmparc)
%                 handles.targets(l).aLabels=anatomicLabelFS(pos, [],lookArround,handles.wmparc.img,handles.wmparcS,radio);
%             end
%         end
%     end
    
    % Update handles structure
    guidata(hObject, handles);
    set(handles.MNILabelstogglebutton,'state','off');
    
    % Update labels
    handles=labels2NativeSpace(handles);
    
    handles=updateTAC(handles);
    guidata(hObject, handles); % update data again
end

% --------------------------------------------------------------------

%%%%%%%%%%%%%%%            MNI Labels On                  %%%%%%%%%%%%%%%%%
function MNILabelstogglebutton_OnCallback(hObject, eventdata, handles)
% hObject    handle to MNILabelstogglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.currentSpace='MNI'; % options are 'Native' 'MNI' 
handles=labels2MNIspace(handles);
handles.updatePlots.surfaces=1;

handles=updateElectrodes3D(handles);
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%            MNI Labels Off                   %%%%%%%%%%%%%%%
function MNILabelstogglebutton_OffCallback(hObject, eventdata, handles)
% hObject    handle to MNILabelstogglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.currentSpace='Native'; % options are 'Native' 'MNI' 
handles=labels2NativeSpace(handles);
handles.updatePlots.surfaces=1;

handles=updateElectrodes3D(handles);
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
%%%%%%%%%%%%%%%           Labels to MNI space               %%%%%%%%%%%%%%%
function handles=labels2MNIspace(handles)
% update handles to MNI space for electrodes and planning electrodes

%anatomical labeling of all electrodes
if ~isempty(handles.electrodes)
    L=length(handles.electrodes);
    for l=1:L
        pos=[handles.electrodes{l}.x handles.electrodes{l}.y handles.electrodes{l}.z];
%        handles.electrodes{l}.aLabels=anatomicLabel(pos,handles.MNI_S_matrix,handles.MNIlabels,handles.MNIprob);
        [handles.electrodes{l}.aLabels,handles.electrodes{l}.validAnatLabels,handles.electrodes{l}.anatInd]=...
            anatomicLabel(pos,handles.MNI_S_matrix,handles.MNIlabels,handles.MNIprob);
        if isfield(handles.electrodes{l},'projection') && ~isempty(handles.electrodes{l}.projection.x)
            pos=[handles.electrodes{l}.projection.x handles.electrodes{l}.projection.y...
                handles.electrodes{l}.projection.z];
            [handles.electrodes{l}.projection.aLabels,handles.electrodes{l}.projection.validAnatLabels,...
                handles.electrodes{l}.projection.anatInd]=...
                anatomicLabel(pos,handles.MNI_S_matrix,handles.MNIlabels,handles.MNIprob);
        end
    end
end

%anatomical labeling of all planning electrodes
if ~isempty(handles.targets)
    L=length(handles.targets);
    for l=1:L
        pos=[handles.targets(l).coordinates(:,1) handles.targets(l).coordinates(:,2) handles.targets(l).coordinates(:,3)];
%        handles.targets(l).aLabels=anatomicLabel(pos,handles.MNI_S_matrix,handles.MNIlabels,handles.MNIprob);
        [handles.targets(l).aLabels,handles.targets(l).validAnatLabels,handles.targets(l).anatInd]=...
            anatomicLabel(pos,handles.MNI_S_matrix,handles.MNIlabels,handles.MNIprob);
    end
end

%%%%%%%%%%%%%%%           Labels to Native space            %%%%%%%%%%%%%%%
function handles=labels2NativeSpace(handles)
% update handles to Native space for electrodes and planning electrodes

radio=handles.options.atlasLabelingRadio;
if radio>0
    lookArround=1;
else
    lookArround=0;
end

%anatomical labeling of all electrodes
if ~isempty(handles.electrodes)
    L=length(handles.electrodes);
    for l=1:L
        pos=[handles.electrodes{l}.x handles.electrodes{l}.y handles.electrodes{l}.z];
        
        if ~isempty(handles.wmparc)
%            handles.electrodes{l}.aLabels=anatomicLabelFS(pos, [],lookArround,handles.wmparc.img,handles.wmparcS,radio);
            [handles.electrodes{l}.aLabels,handles.electrodes{l}.validAnatLabels,handles.electrodes{l}.anatInd]=...
                anatomicLabelFS(pos, [],lookArround,handles.wmparc.img,handles.wmparcS,radio);

            if isfield(handles.electrodes{l},'projection') && ~isempty(handles.electrodes{l}.projection.x)
                pos=[handles.electrodes{l}.projection.x handles.electrodes{l}.projection.y...
                    handles.electrodes{l}.projection.z];
                [handles.electrodes{l}.projection.aLabels,handles.electrodes{l}.projection.validAnatLabels...
                    ,handles.electrodes{l}.projection.anatInd]=...
                    anatomicLabelFS(pos, [],lookArround,handles.wmparc.img,handles.wmparcS,radio);
            end
        else
            handles.electrodes{l}.aLabels=repmat({'no atlas loaded'},handles.electrodes{l}.nElectrodes,1);
            handles.electrodes{l}.validAnatLabels={};
            handles.electrodes{l}.anatInd=[];
            if isfield(handles.electrodes{l},'projection') && ~isempty(handles.electrodes{l}.projection.x)
                handles.electrodes{l}.projection.aLabels=repmat({'no atlas loaded'},handles.electrodes{l}.nElectrodes,1);
                handles.electrodes{l}.projection.validAnatLabels={};
                handles.electrodes{l}.projection.anatInd=[];
            end
        end
    end
end

%anatomical labeling of all planning electrodes
if ~isempty(handles.targets)
    L=length(handles.targets);
    for l=1:L
        pos=[handles.targets(l).coordinates(:,1) handles.targets(l).coordinates(:,2) handles.targets(l).coordinates(:,3)];

        if ~isempty(handles.wmparc)
%            handles.targets(l).aLabels=anatomicLabelFS(pos, [],lookArround,handles.wmparc.img,handles.wmparcS,radio);
            [handles.targets(l).aLabels,handles.targets(l).validAnatLabels,handles.targets(l).anatInd]=...
                anatomicLabelFS(pos, [],lookArround,handles.wmparc.img,handles.wmparcS,radio);
        else
            handles.targets(l).aLabels=repmat({'no atlas loaded'},handles.targets(l).nElectrodes,1);
            handles.targets(l).validAnatLabels={};
            handles.targets(l).anatInd=[];
        end
    end
end

% --------------------------------------------------------------------
%%%%%%%%%%%%%         Add brain PIAL surfaces from FS          %%%%%%%%%%%%
function addFSsurfacesuipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to addFSsurfacesuipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% MRI should be loaded first
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project. Then load surfaces...')
    return
end

% load right surface
[rFile,PathName]=uigetfile({'*.pial' , '*.pial';   '*.*', '*.*'}, 'Load RIGHT hemisphere surface ',handles.PathName);

if isequal(rFile,0)
    return;
end
rFile=[PathName rFile]; %concat file name
handles.PathName=PathName;

% load left surface
[lFile,PathName]=uigetfile({'*.pial' , '*.pial';   '*.*', '*.*'}, 'Load LEFT hemisphere surface ',PathName);

if isequal(lFile,0)
   return;
end
lFile=[PathName lFile]; %concat file name

        
[vR,fR]=read_surf(rFile);
[vL,fL]=read_surf(lFile);

disp (['Loaded surfaces from ' rFile ' and '  lFile ])


choice = questdlg('Do you want to center the surfaces? (Recommended)', ...
    '', 'Yes','No','Cancel','Yes');
% Handle response
switch choice
    case 'Yes'
        % translate pial surfaces to MRI center
        trans=mesh2AnatSpace(size(handles.imgW)/2,handles.S2);
        vR=vR+repmat(trans,size(vR,1),1);
        vL=vL+repmat(trans,size(vL,1),1);
        disp (['Surfaces centered'])

    case 'No'
        % do nothing
    case 'Cancel'
        return;
    case ''
        return;
end

%reduce to 15k vertices for nice resolution and speed plots
% k = handles.options.reduce_surfaces_elements / length(vR);
% if k< 1
%     try
%         [handles.verticesR,handles.facesR]=meshresample(vR,fR,k);
%         [handles.verticesL,handles.facesL]=meshresample(vL,fL,k);
%     catch
%         disp({'WARNING - iso2mesh function meshresample not found or error.'
%             'Pial surfaces will not be resampled. 3D view could be slowed down.'})
%         handles.verticesR=vR;
%         handles.facesR=fR;
%         handles.verticesL=vL;
%         handles.facesL=fL;
%     end
%     
% else
%     handles.verticesR=vR;
%     handles.verticesL=vL;
%     handles.facesR=fR;
%     handles.facesL=fL;
% end
% No reduction to be able to usse annotation information

handles.verticesR=vR;
handles.verticesL=vL;
handles.facesR=fR;
handles.facesL=fL;

% dealin with annotation files after surfaces are done
choice = questdlg('Do you want to load annotation files?', ...
    '', 'Yes','No','Cancel','Yes');

switch choice
    case 'Yes'
        % load right annotation
        [AnnotFile_R,PathName]=uigetfile({'*.annot' , '*.annot';   '*.*', '*.*'}, 'Load RIGHT hemisphere annotation ',PathName);
        
        if isequal(AnnotFile_R,0)
            return;
        end
        AnnotFile_R=[PathName AnnotFile_R]; %concat file name
        
        % load right annotation
        [AnnotFile_L,PathName]=uigetfile({'*.annot' , '*.annot';   '*.*', '*.*'}, 'Load LEFT hemisphere annotation ',PathName);
        
        if isequal(AnnotFile_L,0)
            return;
        end
        AnnotFile_L=[PathName AnnotFile_L]; %concat file name

        [~,AnnotLabel_R,AnnotColortable_R]=read_annotation(AnnotFile_R);
        [~,AnnotLabel_L,AnnotColortable_L]=read_annotation(AnnotFile_L);
        disp (['Loaded annotation files from ' AnnotFile_R ' and ' AnnotFile_L ])
        
        [~,rindC]=ismember(AnnotLabel_R,AnnotColortable_R.table(:,5)); %some labels (nodes) are not assigned to any structure
        [~,lindC]=ismember(AnnotLabel_L,AnnotColortable_L.table(:,5)); %some labels (nodes) are not assigned to any structure
        
        AnnotColor_R=ones(length(rindC),3)*.5; %grey?
        AnnotColor_L=ones(length(lindC),3)*.5; %grey?
        AnnotColor_R(find(rindC),:)=AnnotColortable_R.table(rindC(find(rindC)),1:3)/255; %get RGB colors of the defined nodes
        AnnotColor_L(find(lindC),:)=AnnotColortable_L.table(lindC(find(lindC)),1:3)/255;
        
        handles.AnnotLabel_R=AnnotLabel_R; %label for each node
        handles.AnnotLabel_L=AnnotLabel_L; %label for each node
        handles.AnnotColortable_R=AnnotColortable_R; %colortable info
        handles.AnnotColortable_L=AnnotColortable_L; %colortable info
        handles.AnnotColor_R=AnnotColor_R; %actual color used for each node
        handles.AnnotColor_L=AnnotColor_L; %actual color used for each node
        
    case 'No'
        
        handles.AnnotLabel_R=[]; %label for each node
        handles.AnnotLabel_L=[]; %label for each node
        handles.AnnotColortable_R=[]; %colortable info
        handles.AnnotColortable_L=[]; %colortable info
        handles.AnnotColor_R=ones(length(handles.verticesR),3)*.5; %actual color used for each node = grey; %actual color used for each node
        handles.AnnotColor_L=ones(length(handles.verticesL),3)*.5; %actual color used for each node
        
    case 'Cancel'
        return;
    case ''
        return;
end

handles.currentSpace='Native'; % options are 'Native' 'MNI'
% Update handles structure
guidata(hObject, handles);
%lock MNI labels button
set(handles.MNILabelstogglebutton,'State','Off'); % this will call to labels2NativeSpace and updateElectrodes3D

handles.updatePlots.surfaces=1;
handles=updateElectrodes3D (handles);
% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%         Clear brain PIAL surfaces from FS          %%%%%%%%%%%%
function ClearFSsurfaceuipushtool2_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ClearFSsurfaceuipushtool2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% MRI should be loaded first
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project. Then you can add surfaces...')
    return
end
handles.verticesR=[];
handles.verticesL=[];
handles.facesR=[];
handles.facesL=[];

handles.AnnotLabel_R=[];
handles.AnnotLabel_L=[];
handles.AnnotColortable_R=[]; 
handles.AnnotColortable_L=[]; 
handles.AnnotColor_R=[];
handles.AnnotColor_L=[];

handles.currentSpace='MNI'; % options are 'Native' 'MNI' 
handles.updatePlots.surfaces=1;
% Update handles structure
guidata(hObject, handles);

set(handles.MNILabelstogglebutton,'State','On'); % this will call to labels2MNIspace and updateElectrodes3D

% --------------------------------------------------------------------
%%%%%%%%%%%%%          Add SCE surfaces from FS                %%%%%%%%%%%%
function addSCEuipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to addSCEuipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% MRI should be loaded first
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project. Then load surfaces...')
    return
end
% load surface
[rFile,PathName]=uigetfile({'*.pial-outer-smoothed','*.pial-outer-smoothed'; '*.*', '*.*'}, 'Load RIGHT hemisphere Smoothed Cortical Envelope ',handles.PathName);

if ~isequal(rFile,0)
    handles.PathName=PathName;
    [lFile,PathName]=uigetfile({'*.pial-outer-smoothed','*.pial-outer-smoothed'; '*.*', '*.*'}, 'Load LEFT hemisphere Smoothed Cortical Envelope ',handles.PathName);
    
    if ~isequal(lFile,0)
        
        [vR,fR]=read_surf([PathName rFile]);
        [vL,fL]=read_surf([PathName lFile]);
        
        disp (['Loaded surfaces from ' PathName, rFile ' and ' PathName, lFile ])

        choice = questdlg('Do you want to center the surfaces? (Recommended)', ...
            '', 'Yes','No','Cancel','Yes');
        % Handle response
        switch choice
            case 'Yes'
                % translate pial surfaces to MRI center
                trans=mesh2AnatSpace(size(handles.imgW)/2,handles.S2);
                vR=vR+repmat(trans,size(vR,1),1);
                vL=vL+repmat(trans,size(vL,1),1);
                
            case 'No'
                % do nothing
            case 'Cancel'
                return;
            case ''
                return;
        end
        
        %reduce to 15k vertices for nice resolution and speed plots
        k=15000/length(vR);
        if k<1
            try
                [handles.vertices_SCE_R,handles.faces_SCE_R]=meshresample(vR,fR,k);
                [handles.vertices_SCE_L,handles.faces_SCE_L]=meshresample(vL,fL,k);
            catch
                disp({'WARNING - iso2mesh function meshresample not found or error.' 
                    'SCE surfaces will not be resampled. 3D view could be slowed down.'})
                handles.vertices_SCE_R=vR;
                handles.faces_SCE_R=fR;
                handles.vertices_SCE_L=vL;
                handles.faces_SCE_L=fL;
            end
            
        else
            handles.vertices_SCE_R=vR;
            handles.vertices_SCE_L=vL;
            handles.faces_SCE_R=fR;
            handles.faces_SCE_L=fL;
        end
           
        handles.currentSpace='Native'; % options are 'Native' 'MNI'
        % Update handles structure
        guidata(hObject, handles);
        set(handles.MNILabelstogglebutton,'State','Off'); % this will call to labels2NativeSpace and updateElectrodes3D
    end
end

%%%%%%%%%%%%%          Clear SCE surfaces from FS             %%%%%%%%%%%%
function removeSCEuipushtooluipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to removeSCEuipushtooluipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% MRI should be loaded first
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project. Then you can add surfaces...')
    return
end
handles.vertices_SCE_R=[];
handles.vertices_SCE_L=[];
handles.faces_SCE_R=[];
handles.faces_SCE_L=[];

handles.currentSpace='MNI'; % options are 'Native' 'MNI' 
% Update handles structure
guidata(hObject, handles);

set(handles.MNILabelstogglebutton,'State','On'); % this will call to labels2MNISpace and updateElectrodes3D

% --------------------------------------------------------------------
%%%%%%%%%%%%%%%        save planning structure              %%%%%%%%%%%%%%%
function savePlanninguitoggletool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to savePlanninguitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% MRI should be loaded first
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project. Then do the planning...')
    return
end
if isempty(handles.targets)
    warning('Targets is empty')
else
    targets=handles.targets;
    [FileName,PathName] = uiputfile('*.mat','Save planning structure', handles.PathName);
    if FileName~=0
    handles.PathName=PathName;
        save([handles.PathName, FileName],'targets');
        disp (['Saved targets in ' handles.PathName, FileName])
    end
end

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%        Load planning structure              %%%%%%%%%%%%%%%
function LoadPlanninguitoggletool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to LoadPlanninguitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% MRI should be loaded first
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project')
    return
end

[FileName,PathName] = uigetfile('*.mat','Load planning structure',handles.PathName);
if FileName~=0
    handles.PathName=PathName;
    load([handles.PathName, FileName],'targets');
    handles.targets=targets;
    disp (['Loaded targets from ' handles.PathName, FileName])

    
    % go to first target
    l=1;
    
    set(handles.TargetArraytext,'String',num2str(l));
    
    UpdateTargetEditBox(hObject, eventdata, handles);
    handles = guidata(hObject); %update handles structure
    
    handles.updatePlots.targets=1;
    handles.updatePlots.targetLines=1;
    handles=updateTAC(handles);
    handles=updateElectrodes3D(handles);
end

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%        Make report planning structure       %%%%%%%%%%%%%%%
function ReportPlanninguipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ReportPlanninguipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% MRI should be loaded first
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project')
    return
end

if ~isempty(handles.targets)
    [FileName,PathName] = uiputfile('.txt','.txt ouput file',handles.PathName);
    if FileName~=0
        aLabelsTargets2txt_new(handles.targets,[PathName FileName]);
        disp (['Saved targets report in ' handles.PathName, FileName])

    end
else
    warning ('Targets structure is empty');
end

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%              rotate 3d                   %%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function uitoggletool2_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.rotate3d.Enable,'on')
    handles.rotate3d.Enable='off';
else
    handles.rotate3d.Enable='on';
end

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%         change colormap                     %%%%%%%%%%%%%%%
function ColorMappushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ColorMappushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.figure1,'colormap'),gray)
    if exist('parula','file') % ver 2014b and above
        colormap parula
    else
        colormap jet
    end
else
    colormap gray
end

%%%%%%%%%%%%%%%         reset 2D view plots - remove?       %%%%%%%%%%%%%%%
function resetTACplotButton_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to resetTACplotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.updatePlots.resetTAC=1;
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%         change Layout                       %%%%%%%%%%%%%%%
%--------------------------------------------------------------------
function ToggleLayoutuitoggletool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ToggleLayoutuitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



if handles.layout==0
    %  3D view  + 2 views
    handles.layout=1;
    set(handles.PanelThres,'Visible','off');
    set(handles.Panel3D,'Position', [0.001 0.001 0.437 0.998]);
    set(handles.Panel3Doptions,'Position', [0.88 0.8 0.11 0.36/2]);
    
    set(handles.Panel3D,'FontSize',0.013);  
    
elseif handles.layout==1 
    % 2D views
    handles.layout=2;
    set(handles.Panel3D,'Visible','off');
    set(handles.PanelClustering,'Visible','off');
    set(handles.PanelLabel,'Visible','off');
    
    set(handles.PanelZ,'Position', [0.001 0.3 0.332 0.699]);
    set(handles.PanelY,'Position', [0.335 0.3 0.332 0.699]);
    set(handles.PanelX,'Position', [0.668 0.3 0.332 0.699]);
    
    set(handles.Panel2Dviews,'Position', [0.528 0.213 0.192 0.087]);
    set(handles.PanelCoordinates,'Position', [0.528 0.113 0.192 0.098]);
    
    set(handles.PanelX,'FontSize',0.018);
    set(handles.PanelY,'FontSize',0.018);
    set(handles.PanelZ,'FontSize',0.018);
    
else
    % set default view
    handles.layout=0;
    set(handles.Panel3D,'Position', [0.001 0.5 0.437 0.499]);
    set(handles.PanelThres,'Visible','on');
    if  handles.options.showLocalizeTools 
        set(handles.PanelClustering,'Visible','on');
        set(handles.PanelLabel,'Visible','on');
    else
        set(handles.PanelClustering,'Visible','off');
        set(handles.PanelLabel,'Visible','off');
    end
    if handles.options.showPlanTools
        set(handles.PanelPlanning,'Visible','on');
    else
        set(handles.PanelPlanning,'Visible','off');
    end
    set(handles.Panel3Doptions,'Position', [0.88 0.593 0.11 0.36]);
    set(handles.Panel3D,'Visible','on');
    set(handles.PanelZ,'Position', [0.441 0.0 0.278 0.5]);
    set(handles.PanelY,'Position', [0.441 0.5 0.278 0.5]);
    set(handles.PanelX,'Position', [0.721 0.5 0.278 0.5]);
    
    set(handles.PanelCoordinates,'Position', [0.801 0.309 0.192 0.098]);
    set(handles.Panel2Dviews,'Position', [0.801 0.409 0.192 0.087]);

    set(handles.Panel3D,'FontSize',0.026);   
    set(handles.PanelThres,'FontSize',0.026);
    set(handles.PanelX,'FontSize',0.026);
    set(handles.PanelY,'FontSize',0.026);
    set(handles.PanelZ,'FontSize',0.026);
end

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%              view cross                     %%%%%%%%%%%%%%%
function viewCrossbutton_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to viewCrossbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.T1); % avoid changing crosshairs wwithout images loaded
%    handles.updatePlots.views2D=[1 1 1];
%    handles=updateTAC(handles);
    handles=cross2D(handles); 
    handles=cross3D(handles);
    handles=cross3DThres(handles);
    
    % Update handles structure
    guidata(hObject, handles);
end

%%%%%%%%%%%%%%%              snapshoot                     %%%%%%%%%%%%%%%
function snapshoottool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to snapshoottool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uiputfile({'*.png'; '*.jpg'; '*.tif';'*.bmp';'*.eps';'*.fig'},'Save snapshot',handles.PathName);
if FileName~=0
    handles.PathName=PathName;
    if strcmpi( FileName(end-2:end), 'png')
        print('-dpng',[handles.PathName  FileName]);
    elseif strcmpi( FileName(end-2:end), 'jpg')
        print('-djpeg',[handles.PathName  FileName]);
    elseif strcmpi( FileName(end-2:end), 'tif')
        print('-dtiff',[handles.PathName  FileName]);
    elseif strcmpi( FileName(end-2:end), 'bmp')
        print('-dbmp',[handles.PathName  FileName]);
    elseif strcmpi( FileName(end-2:end), 'eps')
        print('-depsc','-r300',[handles.PathName  FileName]);
    elseif strcmpi( FileName(end-2:end), 'fig')        
        Fig1 = figure;
        copyobj(handles.axes2, Fig1);
        savefig(Fig1, [handles.PathName  FileName]);
        close(Fig1);
    end
    
end

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%%%%%%%%%%              about box                     %%%%%%%%%%%%%%%
function uipushtool13_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Or msg using a figure
[cdata,map] = imread('Icon_mini.jpg');
%Create the message dialog box, including the custom icon.
%h=msgbox('Operation Completed', 'Success','custom',cdata,map);

msgbox({
    ' iElectrodes'
    [' Version: ' handles.iElectrodes_version]
    [' ' handles.iElectrodes_date]
    ''
    ' Copyright (C) 2014, 2015, 2016, 2017  '
    ' Alejandro Omar Blenkmann, PhD'
    ' ablenkmann@gmail.com'
    ' '
    ' For more information visit '
    ' https://sourceforge.net/projects/ielectrodes/ ' 
    
    }, 'About this program' ,'custom',cdata,map);


%%%%%%%%%%%%%%%              help                           %%%%%%%%%%%%%%%
function helpPushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to helpPushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% open help Wiki in system web browser
web('https://sourceforge.net/p/ielectrodes/wiki/Home/','-browser')


function Configpushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Configpushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reload configuration from file
options=[];
handles.options=default_ielectrodes_options(options);
disp('Default_ielectrodes_options loaded')

colors=[];
handles.colors=defaultColors(colors);
disp('DefaultColors loaded')

handles=updateMix_TAC_MR(handles);

handles.updatePlots.views2D=[1 1 1]; % Force update all slices
handles.updatePlots.resetTAC=1;      % reset 2D views axes

handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%            VISUALIZATION                    %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%            update 2D views                  %%%%%%%%%%%%%%%
function handles=updateTAC(handles)

% This function is afecting the visual variables inside handles, but not
% updating handle structure. call guidata(hObject, handles) afterwards.
% inicialize cross handles
% calling to cross2D, cross3D, cross3DThres


markerPlanning=handles.colors.targetMarker2D;
colorPlanning=handles.colors.target2D;

if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project.')
    return
end

D=size(handles.T1.img);

% update sliders values to round values
x=round(get(handles.sliderX,'Value'));
y=round(get(handles.sliderY,'Value'));
z=round(get(handles.sliderZ,'Value'));

% set sliders values
set(handles.sliderX,'Value',x); set(handles.sliderY,'Value',y); set(handles.sliderZ,'Value',z);
% set matrix coords text
set(handles.textX,'String',x); set(handles.textY,'String', y); set(handles.textZ,'String', z);
% define anatomical coords
prevCursor=handles.cursor;
handles.cursor=mesh2AnatSpace([x y z], handles.S2);

%indicates if need to update current slice or not
updateSlice=(abs(handles.cursor-prevCursor)>=diag(handles.S2(1:3,1:3))') | handles.updatePlots.views2D; %Force update all slices;
handles.updatePlots.views2D=[0 0 0]; %remove force plot

% coordinates box
set(handles.textXac,'String', int2str(handles.cursor(1)));
set(handles.textYac,'String', int2str(handles.cursor(2)));
set(handles.textZac,'String', int2str(handles.cursor(3)));
 
% mWS=get(handles.MinWinslider,'Value'); not used in color data anymore
% MWS=get(handles.MaxWinslider,'Value');

%% X plane
set(handles.figure1,'CurrentAxes',handles.axesX);

if updateSlice(1)
    set(handles.axesX,'NextPlot','replacechildren');
    if handles.color
        img=squeeze(handles.imgW(x,:,:,:)); %true color imgW:(dimX,dimY,dimZ,3)
        if ~isempty(handles.wmparcColors)
            imgAtlas=squeeze(handles.wmparcColors(x,:,:,:));
            alphaMask=double(sum(imgAtlas,3)>0);
        else
            imgAtlas=[];
            alphaMask=1;
        end
    else
       img=squeeze(handles.imgW(x,:,:));
    end
%     imagesc(fliplr(rot90(img,3)),[mWS MWS]);
    imagesc(fliplr(rot90(img,3)));
    set(handles.axesX,'NextPlot','add');
    if get(handles.parcellationCheckbox,'Value')
        imagesc(fliplr(rot90(imgAtlas,3)),'AlphaData',fliplr(rot90(alphaMask,3))*handles.colors.alphaAtlas);
    end
    if handles.updatePlots.resetTAC
        %        axis(handles.axesX, 'image')
        pixdim=diag(handles.S2(:,1:3));
        DD=size(handles.T1.img);
        set(handles.axesX,'xlim',[0 DD(2)],'ylim',[0 DD(3)])
        set(handles.axesX,'DataAspectRatio',[1/pixdim(2) 1/pixdim(3) 1]);
        set(handles.axesX,'YDir','normal')
        set(handles.axesX,'XDir','reverse')
        %handles.updatePlots.resetTAC=0; only in last plane
    end
    
    %overlay electrodes
    if get(handles.ElecOverlaycheckbox,'value')
        if get(handles.plotAllRadiobutton,'value') %plot all
            for i=1:length(handles.electrodes)
                if strcmp(handles.electrodes{i}.Type,'grid')
                    colorElectrodes=handles.colors.electrodesGrid2D;
                    markerElectrodes=handles.colors.electrodesMarker2D;
                else
                    colorElectrodes=handles.colors.electrodesDepth2D;
                    markerElectrodes=handles.colors.electrodesMarker2D;
                end
                    
                if get(handles.projectSCEcheckbox,'Value') % projection to SCE
                    c=AnatSpace2Mesh([handles.electrodes{i}.projection.x handles.electrodes{i}.projection.y handles.electrodes{i}.projection.z],handles.S2);
                else
                    c=AnatSpace2Mesh([handles.electrodes{i}.x handles.electrodes{i}.y handles.electrodes{i}.z],handles.S2);
                end
                if get(handles.Collapsecheckbox,'Value')
                    line(c(:,2),c(:,3),'Marker',markerElectrodes,'Color',colorElectrodes,'LineStyle','none');
                else
                    % remove coordinates away from slice
                    ind= abs(c(:,1)-x)<1;
                    line(c(ind,2),c(ind,3),'Marker',markerElectrodes,'Color',colorElectrodes,'LineStyle','none');
                end
            end
        else %plot only selected electrode
            i=str2double(get(handles.arrayNumberText,'String'));
            if i~=0
                if strcmp(handles.electrodes{i}.Type,'grid')
                    colorElectrodes=handles.colors.electrodesGrid2D;
                    markerElectrodes=handles.colors.electrodesMarker2D;
                else
                    colorElectrodes=handles.colors.electrodesDepth2D;
                    markerElectrodes=handles.colors.electrodesMarker2D;
                end
                if get(handles.projectSCEcheckbox,'Value') % projection to SCE
                    c=AnatSpace2Mesh([handles.electrodes{i}.projection.x handles.electrodes{i}.projection.y handles.electrodes{i}.projection.z],handles.S2);
                else
                    c=AnatSpace2Mesh([handles.electrodes{i}.x handles.electrodes{i}.y handles.electrodes{i}.z],handles.S2);
                end
                if get(handles.Collapsecheckbox,'Value')
                    line(c(:,2),c(:,3),'Marker',markerElectrodes,'Color',colorElectrodes,'LineStyle','none');
                else
                    % remove coordinates away from slice
                    ind= abs(c(:,1)-x)<1;
                    line(c(ind,2),c(ind,3),'Marker',markerElectrodes,'Color',colorElectrodes,'LineStyle','none');
                end
            end
        end
    end
    
    %overlay planning electrodes
    if get(handles.planningOverlaycheckbox,'value')
        if get(handles.PlotAllTargetRadiobutton,'value') %plot all
            for i=1:length(handles.targets)
                c=AnatSpace2Mesh([handles.targets(i).coordinates(:,1) handles.targets(i).coordinates(:,2) handles.targets(i).coordinates(:,3)],handles.S2);
                if get(handles.Collapsecheckbox,'Value')
                    line(c(:,2),c(:,3),'Marker',markerPlanning,'Color',colorPlanning,'LineStyle','none');
                else
                    % remove coordinates away from slice
                    ind= abs(c(:,1)-x)<1;
                    line(c(ind,2),c(ind,3),'Marker',markerPlanning,'Color',colorPlanning,'LineStyle','none');
                end
            end
        else %plot only selected planning electrode
            i=str2double(get(handles.TargetArraytext,'String'));
            if i>0
                c=AnatSpace2Mesh([handles.targets(i).coordinates(:,1) handles.targets(i).coordinates(:,2) handles.targets(i).coordinates(:,3)],handles.S2);
                if get(handles.Collapsecheckbox,'Value')
                    line(c(:,2),c(:,3),'Marker',markerPlanning,'Color',colorPlanning,'LineStyle','none');
                else
                    % remove coordinates away from slice
                    ind= abs(c(:,1)-x)<1;
                    line(c(ind,2),c(ind,3),'Marker',markerPlanning,'Color',colorPlanning,'LineStyle','none');
                end
            end
        end
    end
end

%% Y plane
set(handles.figure1,'CurrentAxes',handles.axesY);

if updateSlice(2)
    
    set(handles.axesY,'NextPlot','replacechildren');
    if handles.color
        img=squeeze(handles.imgW(:,y,:,:));%true color imgW:(dimX,dimY,dimZ,3)
        if ~isempty(handles.wmparcColors)
            imgAtlas=squeeze(handles.wmparcColors(:,y,:,:));
            alphaMask=double(sum(imgAtlas,3)>0);
        else
            imgAtlas=[];
            alphaMask=1;
        end
    else
        img=squeeze(handles.imgW(:,y,:));
    end
%     imagesc(fliplr(rot90(img,3)),[mWS MWS]);
    imagesc(fliplr(rot90(img,3)));
    set(handles.axesY,'NextPlot','add');
    if get(handles.parcellationCheckbox,'Value')
        imagesc(fliplr(rot90(imgAtlas,3)),'AlphaData',fliplr(rot90(alphaMask,3))*handles.colors.alphaAtlas);
    end
    if handles.updatePlots.resetTAC
        %axis(handles.axesY, 'image')
        pixdim=diag(handles.S2(:,1:3));
        DD=size(handles.T1.img);
        set(handles.axesY,'xlim',[0 DD(1)],'ylim',[0 DD(3)])
        set(handles.axesY,'DataAspectRatio',[1/pixdim(1) 1/pixdim(3) 1]);
        set(handles.axesY,'YDir','normal')
        set(handles.axesY,'XDir','reverse')
        %handles.updatePlots.resetTAC=0; only in last plane
    end
    
    %overlay electrodes
    if get(handles.ElecOverlaycheckbox,'value')
        if get(handles.plotAllRadiobutton,'value') %plot all
            for i=1:length(handles.electrodes)
                if strcmp(handles.electrodes{i}.Type,'grid')
                    colorElectrodes=handles.colors.electrodesGrid2D;
                    markerElectrodes=handles.colors.electrodesMarker2D;
                else
                    colorElectrodes=handles.colors.electrodesDepth2D;
                    markerElectrodes=handles.colors.electrodesMarker2D;
                end

                if get(handles.projectSCEcheckbox,'Value') % projection to SCE
                    c=AnatSpace2Mesh([handles.electrodes{i}.projection.x handles.electrodes{i}.projection.y handles.electrodes{i}.projection.z],handles.S2);
                else
                    c=AnatSpace2Mesh([handles.electrodes{i}.x handles.electrodes{i}.y handles.electrodes{i}.z],handles.S2);
                end
                if get(handles.Collapsecheckbox,'Value')
                    line(c(:,1),c(:,3),'Marker',markerElectrodes,'Color',colorElectrodes,'LineStyle','none');
                else
                    % remove coordinates away from slice
                    ind= abs(c(:,2)-y)<1;
                    line(c(ind,1),c(ind,3),'Marker',markerElectrodes,'Color',colorElectrodes,'LineStyle','none');
                end
            end
        else %plot only selected electrode
            i=str2double(get(handles.arrayNumberText,'String'));
            if i~=0
                if strcmp(handles.electrodes{i}.Type,'grid')
                    colorElectrodes=handles.colors.electrodesGrid2D;
                    markerElectrodes=handles.colors.electrodesMarker2D;
                else
                    colorElectrodes=handles.colors.electrodesDepth2D;
                    markerElectrodes=handles.colors.electrodesMarker2D;
                end
                if get(handles.projectSCEcheckbox,'Value') % projection to SCE
                    c=AnatSpace2Mesh([handles.electrodes{i}.projection.x handles.electrodes{i}.projection.y handles.electrodes{i}.projection.z],handles.S2);
                else
                    c=AnatSpace2Mesh([handles.electrodes{i}.x handles.electrodes{i}.y handles.electrodes{i}.z],handles.S2);
                end
                if get(handles.Collapsecheckbox,'Value')
                    line(c(:,1),c(:,3),'Marker',markerElectrodes,'Color',colorElectrodes,'LineStyle','none');
                else
                    % remove coordinates away from slice
                    ind= abs(c(:,2)-y)<1;
                    line(c(ind,1),c(ind,3),'Marker',markerElectrodes,'Color',colorElectrodes,'LineStyle','none');
                end
            end
        end
    end
    %overlay planning electrodes
    if get(handles.planningOverlaycheckbox,'value')
        if get(handles.PlotAllTargetRadiobutton,'value') %plot all
            for i=1:length(handles.targets)
                c=AnatSpace2Mesh([handles.targets(i).coordinates(:,1) handles.targets(i).coordinates(:,2) handles.targets(i).coordinates(:,3)],handles.S2);
                if get(handles.Collapsecheckbox,'Value')
                    line(c(:,1),c(:,3),'Marker',markerPlanning,'Color',colorPlanning,'LineStyle','none');
                else
                    % remove coordinates away from slice
                    ind= abs(c(:,2)-y)<1;
                    line(c(ind,1),c(ind,3),'Marker',markerPlanning,'Color',colorPlanning,'LineStyle','none');
                end
            end
        else %plot only selected planning electrode
            i=str2double(get(handles.TargetArraytext,'String'));
            if i>0
                c=AnatSpace2Mesh([handles.targets(i).coordinates(:,1) handles.targets(i).coordinates(:,2) handles.targets(i).coordinates(:,3)],handles.S2);
                if get(handles.Collapsecheckbox,'Value')
                    line(c(:,1),c(:,3),'Marker',markerPlanning,'Color',colorPlanning,'LineStyle','none');
                else
                    % remove coordinates away from slice
                    ind= abs(c(:,2)-y)<1;
                    line(c(ind,1),c(ind,3),'Marker',markerPlanning,'Color',colorPlanning,'LineStyle','none');
                end
            end
        end
    end
end


%% Z plane
set(handles.figure1,'CurrentAxes',handles.axesZ);
if updateSlice(3)
    set(handles.axesZ,'NextPlot','replacechildren');
    if handles.color
        img=squeeze(handles.imgW(:,:,z,:)); %true color imgW:(dimX,dimY,dimZ,3)
        if ~isempty(handles.wmparcColors)
            imgAtlas=squeeze(handles.wmparcColors(:,:,z,:));
            alphaMask=double(sum(imgAtlas,3)>0);
        else
            imgAtlas=[];
            alphaMask=1;
        end
    else
        img=squeeze(handles.imgW(:,:,z));
    end
%     imagesc(fliplr(rot90(img,3)),[mWS MWS]);
    imagesc(fliplr(rot90(img,3)));
    set(handles.axesZ,'NextPlot','add');
    if get(handles.parcellationCheckbox,'Value')
        imagesc(fliplr(rot90(imgAtlas,3)),'AlphaData',fliplr(rot90(alphaMask,3))*handles.colors.alphaAtlas);
    end
    if handles.updatePlots.resetTAC
        %axis(handles.axesZ, 'image')
        pixdim=diag(handles.S2(:,1:3));
        DD=size(handles.T1.img);
        set(handles.axesZ,'xlim',[0 DD(1)],'ylim',[0 DD(2)])
        set(handles.axesZ,'DataAspectRatio',[1/pixdim(1) 1/pixdim(2) 1]);
        set(handles.axesZ,'YDir','normal')
        set(handles.axesZ,'XDir','reverse')
        handles.updatePlots.resetTAC=0;
    end
    
    %overlay electrodes
    if get(handles.ElecOverlaycheckbox,'value')
        if get(handles.plotAllRadiobutton,'value') %plot all
            for i=1:length(handles.electrodes)
                if strcmp(handles.electrodes{i}.Type,'grid')
                    colorElectrodes=handles.colors.electrodesGrid2D;
                    markerElectrodes=handles.colors.electrodesMarker2D;
                else
                    colorElectrodes=handles.colors.electrodesDepth2D;
                    markerElectrodes=handles.colors.electrodesMarker2D;
                end

                if get(handles.projectSCEcheckbox,'Value') % projection to SCE
                    c=AnatSpace2Mesh([handles.electrodes{i}.projection.x handles.electrodes{i}.projection.y handles.electrodes{i}.projection.z],handles.S2);
                else
                    c=AnatSpace2Mesh([handles.electrodes{i}.x handles.electrodes{i}.y handles.electrodes{i}.z],handles.S2);
                end
                if get(handles.Collapsecheckbox,'Value')
                    line(c(:,1),c(:,2),'Marker',markerElectrodes,'Color',colorElectrodes,'LineStyle','none');
                else
                    % remove coordinates away from slice
                    ind= abs(c(:,3)-z)<1;
                    line(c(ind,1),c(ind,2),'Marker',markerElectrodes,'Color',colorElectrodes,'LineStyle','none');
                end
            end
        else %plot only selected electrode
            i=str2double(get(handles.arrayNumberText,'String'));
            if i~=0
                if strcmp(handles.electrodes{i}.Type,'grid')
                    colorElectrodes=handles.colors.electrodesGrid2D;
                    markerElectrodes=handles.colors.electrodesMarker2D;
                else
                    colorElectrodes=handles.colors.electrodesDepth2D;
                    markerElectrodes=handles.colors.electrodesMarker2D;
                end
                if get(handles.projectSCEcheckbox,'Value') % projection to SCE
                    c=AnatSpace2Mesh([handles.electrodes{i}.projection.x handles.electrodes{i}.projection.y handles.electrodes{i}.projection.z],handles.S2);
                else
                    c=AnatSpace2Mesh([handles.electrodes{i}.x handles.electrodes{i}.y handles.electrodes{i}.z],handles.S2);
                end
                if get(handles.Collapsecheckbox,'Value')
                    line(c(:,1),c(:,2),'Marker',markerElectrodes,'Color',colorElectrodes,'LineStyle','none');
                else
                    % remove coordinates away from slice
                    ind= abs(c(:,3)-z)<1;
                    line(c(ind,1),c(ind,2),'Marker',markerElectrodes,'Color',colorElectrodes,'LineStyle','none');
                end
            end
        end
    end
    %overlay planning electrodes
    if get(handles.planningOverlaycheckbox,'value')
        if get(handles.PlotAllTargetRadiobutton,'value') %plot all
            for i=1:length(handles.targets)
                c=AnatSpace2Mesh([handles.targets(i).coordinates(:,1) handles.targets(i).coordinates(:,2) handles.targets(i).coordinates(:,3)],handles.S2);
                if get(handles.Collapsecheckbox,'Value')
                    line(c(:,1),c(:,2),'Marker',markerPlanning,'Color',colorPlanning,'LineStyle','none');
                else
                    % remove coordinates away from slice
                    ind= abs(c(:,3)-z)<1;
                    line(c(ind,1),c(ind,2),'Marker',markerPlanning,'Color',colorPlanning,'LineStyle','none');
                end
            end
        else %plot only selected planning electrode
            i=str2double(get(handles.TargetArraytext,'String'));
            if i>0
                c=AnatSpace2Mesh([handles.targets(i).coordinates(:,1) handles.targets(i).coordinates(:,2) handles.targets(i).coordinates(:,3)],handles.S2);
                if get(handles.Collapsecheckbox,'Value')
                    line(c(:,1),c(:,2),'Marker',markerPlanning,'Color',colorPlanning,'LineStyle','none');
                else
                    % remove coordinates away from slice
                    ind= abs(c(:,3)-z)<1;
                    line(c(ind,1),c(ind,2),'Marker',markerPlanning,'Color',colorPlanning,'LineStyle','none');
                end
            end
        end
    end
end

%% Update anatomical Labels in Coordinates box

lookArround=1;
if strcmp(handles.currentSpace, 'MNI')    %strcmp (get(handles.MNILabelstogglebutton,'state'),'on')
    aL=anatomicLabel(handles.cursor,handles.MNI_S_matrix,handles.MNIlabels,handles.MNIprob);
    set(handles.aLabelText,'String',aL);
elseif ~isempty(handles.wmparc) % Native space
    aL=anatomicLabelFS(handles.cursor, [],lookArround,handles.wmparc.img,handles.wmparcS);
    set(handles.aLabelText,'String',aL);
else
    set(handles.aLabelText,'String','No Native Atlas loaded');
end

%% update crosshairs
%update cross in 2D
handles=cross2D(handles);%,updateSlice);

% update cross in axes2 (3D)
handles=cross3D(handles);%,0);

% update cross in axes1 (3D Threshold)
handles=cross3DThres(handles);

%%%%%%%%%%%%%%%            update 3D view                   %%%%%%%%%%%%%%%
function handles=updateElectrodes3D (handles)
% this function is afecting the visual variables inside handles, but not
% updating handle structure. call guidata(hObject, handles) afterwards
% calling to cross3D and cross3DThres

%select axes
axes(handles.axes2);
if handles.updatePlots.cla
    cla %clear axes
    xlabel(handles.axes2,'x'); ylabel(handles.axes2,'y'); zlabel(handles.axes2,'z');
    set(handles.axes2, 'Clipping', 'on');
    hold on;
    axis image
    handles.updatePlots.cla=0;
end

%% plot GS clusterd coordinates

% if ~isempty(handles.GS) %plot just after cluster (not labeled or indexed)
%     scatter3(handles.axes2,handles.GS(:,1),handles.GS(:,2),handles.GS(:,3),'ro', 'filled')

if handles.updatePlots.GS %plot
    if ishandle(handles.plot3Dhandles.GS) %clear and replace
         delete(handles.plot3Dhandles.GS);
    end
    if ~isempty(handles.GS) 
        handles.plot3Dhandles.GS=scatter3(handles.axes2,handles.GS(:,1),handles.GS(:,2),handles.GS(:,3),'ro', 'filled');
    end
    handles.updatePlots.GS=0;
end
        
    
%% get plotlist for electrodes, labels, connections  
if ~isempty(handles.electrodes)>0 % plot electrodes (labeled or indexed)
    %plot all electrode arrays
    if get(handles.plotAllRadiobutton,'value')
        plotList=1:length(handles.electrodes);
    else %plot one electrode array
        plotList=str2double (get(handles.arrayNumberText,'String'));
    end
end
    
%% plot electrodes
if handles.updatePlots.electrodes %plot
    %clear and replace
    dlt=ishandle(handles.plot3Dhandles.electrodes);
    if any(dlt) 
        delete(handles.plot3Dhandles.electrodes(dlt));
    end
    
    if ~isempty(handles.electrodes)>0 % plot electrodes
        for j=plotList
            if get(handles.projectSCEcheckbox,'Value') % projection to SCE
                x=handles.electrodes{j}.projection.x;
                y=handles.electrodes{j}.projection.y;
                z=handles.electrodes{j}.projection.z;
            else %without projection
                x=handles.electrodes{j}.x;
                y=handles.electrodes{j}.y;
                z=handles.electrodes{j}.z;
            end
            %plot electrodes
            if isfield (handles.electrodes{j},'Type') & strcmp(handles.electrodes{j}.Type,'grid');
                %grids
                handles.plot3Dhandles.electrodes(j)=scatter3(handles.axes2,x,y,z,handles.colors.electrodesSize3D,handles.colors.electrodesGrid3D,handles.colors.electrodesMarker3D, 'filled');%'ro'
            else
                %depth
                handles.plot3Dhandles.electrodes(j)=scatter3(handles.axes2,x,y,z,handles.colors.electrodesSize3D,handles.colors.electrodesDepth3D,handles.colors.electrodesMarker3D, 'filled');%'bo'
            end
        end
        
        % plot selected electrode in black
        a=str2double(get(handles.arrayNumberText,'String'));
        l=str2double(get(handles.elecNumberText,'String'));
        if get(handles.projectSCEcheckbox,'Value')  && isfield(handles.electrodes{a},'projection')% projection to SCE
            handles.plot3Dhandles.electrodes(end+1)=scatter3(handles.axes2,handles.electrodes{a}.projection.x(l),...
                handles.electrodes{a}.projection.y(l),handles.electrodes{a}.projection.z(l),handles.colors.electrodesSize3D,handles.colors.electrodesSelected3D,handles.colors.electrodesMarker3D, 'filled');
        else
            handles.plot3Dhandles.electrodes(end+1)=scatter3(handles.axes2,handles.electrodes{a}.x(l),...
                handles.electrodes{a}.y(l),handles.electrodes{a}.z(l),handles.colors.electrodesSize3D,handles.colors.electrodesSelected3D,handles.colors.electrodesMarker3D, 'filled');
        end
    end

    handles.updatePlots.electrodes=0;    
end

%% plot lines(cylinders) between electrodes
 if ~isempty(handles.electrodes)>0 && handles.updatePlots.elecLines %% && get(handles.PlotConnCheckbox,'Value')
    %clear and replace
    for k=1:length(handles.plot3Dhandles.elecLines)
        dlt=ishandle(handles.plot3Dhandles.elecLines{k});
        if any(dlt)
            delete(handles.plot3Dhandles.elecLines{k}(dlt));
        end
    end
    if get(handles.PlotConnCheckbox,'Value')
        
        for j=plotList
            if get(handles.projectSCEcheckbox,'Value') % projection to SCE
                x=handles.electrodes{j}.projection.x;
                y=handles.electrodes{j}.projection.y;
                z=handles.electrodes{j}.projection.z;
            else %without projection
                x=handles.electrodes{j}.x;
                y=handles.electrodes{j}.y;
                z=handles.electrodes{j}.z;
            end
            
            X=[x,y,z];
            if isfield (handles.electrodes{j},'Type') && strcmp(handles.electrodes{j}.Type,'grid')
                color=handles.colors.cylColorGrid;
            else
                color=handles.colors.cylColorDepth;
            end
            handles.plot3Dhandles.elecLines{j}=plotElectrodesLines(X,handles.electrodes{j}.rows,handles.electrodes{j}.columns,color);
%            set(handles.plot3Dhandles.elecLines{j},'FaceAlpha',handles.options.cylAlpha);
        end
    end
     handles.updatePlots.elecLines = 0;       
 end
        
 %% plot electrode labels
 if ~isempty(handles.electrodes)>0 && handles.updatePlots.labels
    %clear and replace
    dlt=ishandle(handles.plot3Dhandles.labels);
    if any(dlt) 
        delete(handles.plot3Dhandles.labels(dlt));
    end
     
     %     if isfield(handles.electrodes{j},'recorded_channels') %for compatiblillity with previous versions
     %             labelList=handles.electrodes{j}.recorded_channels;
     %             ch_label=cell(1,handles.electrodes{j}.nElectrodes);
     %             ch_label(labelList)=handles.electrodes{j}.ch_label;
     %         else
     %             labelList=1:handles.electrodes{j}.nElectrodes;
     %             ch_label=handles.electrodes{j}.ch_label;
     %         end
     k=1;
     for j=plotList
        if get(handles.projectSCEcheckbox,'Value') % projection to SCE
            x=handles.electrodes{j}.projection.x;
            y=handles.electrodes{j}.projection.y;
            z=handles.electrodes{j}.projection.z;
        else %without projection
            x=handles.electrodes{j}.x;
            y=handles.electrodes{j}.y;
            z=handles.electrodes{j}.z;
        end
        
         labelList=1:handles.electrodes{j}.nElectrodes;
         ch_label=handles.electrodes{j}.ch_label;
         
         if get(handles.DispLabelsCheckbox,'Value')
             for i=labelList
                 %remove special characters
                 ch_label{i}(~isstrprop(ch_label{i},'alphanum')) = ' ';
                 handles.plot3Dhandles.labels(k)=...
                     text(x(i)+1,y(i)+1,z(i)+1,ch_label{i},...
                     'color',handles.colors.labelsColor,...
                     'FontSize',handles.colors.labelsFontSize,...
                 'FontWeight','bold');
                k=k+1;
             end
         end
     end
     handles.updatePlots.labels=0;
 end   
   
%% get plotlist for Targerts
plotList=[];
if ~isempty(handles.targets)>0 % plot targets
    %plot all targets array
    if get(handles.PlotAllTargetRadiobutton,'value')
        plotList=1:length(handles.targets);
    else %plot one target array
        plotList=str2double (get(handles.TargetArraytext,'String'));
    end
end

%% plot targets
   
if ~isempty(handles.targets)>0 && handles.updatePlots.targets

    %clear and replace
    dlt=ishandle(handles.plot3Dhandles.targets);
    if any(dlt) 
        delete(handles.plot3Dhandles.targets(dlt));
    end
    
    for j=plotList
        x=handles.targets(j).coordinates(:,1);
        y=handles.targets(j).coordinates(:,2);
        z=handles.targets(j).coordinates(:,3);
        handles.plot3Dhandles.targets(j)=scatter3(handles.axes2,x,y,z,handles.colors.targetSize3D,handles.colors.target3D,handles.colors.targetMarker3D, 'filled');%'go'
    end
    % plot selected target in black
    a=str2double(get(handles.TargetArraytext,'String'));
    l=str2double(get(handles.TargetElectext,'String'));
    scatter3(handles.axes2,handles.targets(a).coordinates(l,1),...
        handles.targets(a).coordinates(l,2),handles.targets(a).coordinates(l,3),handles.colors.targetSize3D,handles.colors.targetSelected3D,handles.colors.targetMarker3D, 'filled');%'ko'

    handles.updatePlots.targets=0;    
end

%% plot targetLines
if ~isempty(handles.targets)>0 && handles.updatePlots.targetLines
    %clear and replace
    dlt=ishandle(handles.plot3Dhandles.targetLines);
    if any(dlt) 
        delete(handles.plot3Dhandles.targetLines(dlt));
    end
    
    %plot lines(cylinders) between target electrodes
    for j=plotList
        if get(handles.PlotConnCheckbox,'Value')
            x=handles.targets(j).coordinates(:,1);
            y=handles.targets(j).coordinates(:,2);
            z=handles.targets(j).coordinates(:,3);
            X=[x,y,z];
            color=handles.colors.cylColorTargets;
            handles.plot3Dhandles.targetLines{j}=plotElectrodesLines(X,1,size(X,1),color);
%            set(handles.plot3Dhandles.targetLines{j},'FaceAlpha',handles.colors.cylAlphaTages);
        end
    end    
    handles.updatePlots.targetLines=0;    
end

%% Plot brain surfaces
if handles.updatePlots.surfaces
    hind=zeros(1,4);
    %clear and replace
    dlt=ishandle(handles.plot3Dhandles.surfaces);
    if any(dlt)
        delete(handles.plot3Dhandles.surfaces(dlt));
    end
    
    % use subject surface
    if strcmp(handles.currentSpace,'Native')
        if ~isempty(handles.verticesR) %plot pials
            if get(handles.Rightcheckbox,'Value')
                if get(handles.Annotationcheckbox,'Value')
                    handles.plot3Dhandles.surfaces(1)=mvis(handles.verticesR,handles.facesR,handles.AnnotColor_R); %annotation in colors
                else
                    handles.plot3Dhandles.surfaces(1)=mvis(handles.verticesR,handles.facesR); %grey
                end
                hind(1)=1;
                hold on;
            end
            if get(handles.Leftcheckbox,'Value')                
                if get(handles.Annotationcheckbox,'Value')
                    handles.plot3Dhandles.surfaces(2)=mvis(handles.verticesL,handles.facesL, handles.AnnotColor_L); % annotation in colors
                else
                    handles.plot3Dhandles.surfaces(2)=mvis(handles.verticesL,handles.facesL);% grey    
                end
                hind(2)=1;
                hold on;
            end
        end
        if ~isempty(handles.vertices_SCE_R) && get(handles.projectSCEcheckbox,'Value') % plot projection to SCE
            if get(handles.RightSCEcheckbox,'Value')
                handles.plot3Dhandles.surfaces(3)=mvis(handles.vertices_SCE_R,handles.faces_SCE_R);
                hind(3)=1;
                hold on;
            end
            if get(handles.LeftSCEcheckbox,'Value')
                handles.plot3Dhandles.surfaces(4)=mvis(handles.vertices_SCE_L,handles.faces_SCE_L);
                hind(4)=1;
                hold on;
            end
        end
        
    else %use MNI surface
        if get(handles.Rightcheckbox,'Value') %plot pials
            handles.plot3Dhandles.surfaces(1)=mvis(handles.v_MNI,handles.f_MNI(handles.f_MNI(:,4)==1,1:3));
            hind(1)=1;
            hold on;
        end
        if get(handles.Leftcheckbox,'Value')
            handles.plot3Dhandles.surfaces(2)=mvis(handles.v_MNI,handles.f_MNI(handles.f_MNI(:,4)==2,1:3));
            hind(2)=1;
            hold on;
        end
        
        if get(handles.projectSCEcheckbox,'Value') % projection to SCE
            if get(handles.RightSCEcheckbox,'Value')
                handles.plot3Dhandles.surfaces(3)=mvis(handles.v_MNI_SCE,handles.f_MNI_SCE(handles.f_MNI_SCE(:,4)==2,1:3));
                hind(3)=1;
                hold on;
            end
            if get(handles.LeftSCEcheckbox,'Value')
                handles.plot3Dhandles.surfaces(4)=mvis(handles.v_MNI_SCE,handles.f_MNI_SCE(handles.f_MNI_SCE(:,4)==1,1:3));
                hind(4)=1;
                hold on;
            end
        end
    end
    
    % change transparency values if there is any surface
    for i=1:length(hind);
        if hind(i)
            alpha ( handles.plot3Dhandles.surfaces(i), get(handles.AlphaSlider,'Value'));
        end
    end

    handles.updatePlots.surfaces=0;    
end

%% define camera handle
[vax2(1),vax2(2)]=view(handles.axes2);

% no camlight
if ~(any(ishandle(handles.plot3Dhandles.hcam)))
    handles.plot3Dhandles.hcam=camlight('headlight');
    handles.viewPoint=vax2;    

    
% camlight with diff angle
elseif any(handles.viewPoint~=vax2)
    delete(handles.plot3Dhandles.hcam);
    handles.plot3Dhandles.hcam=camlight('headlight');
    handles.viewPoint=vax2;        
end

handles=cross3D(handles);
handles=cross3DThres(handles);


function Reset3Dpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Reset3Dpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.updatePlots.GS=1;
handles.updatePlots.electrodes=1;
handles.updatePlots.labels=1;
handles.updatePlots.elecLines=1;

handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles.updatePlots.surfaces=1;
handles.updatePlots.cla=1;

handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%   update crosshairs in 2D and 3D view       %%%%%%%%%%%%%%%
function handles=cross2D(handles) %,updateSlice)
% Fuction to update 2D crosshairs. 
% if handles.cross.xh1 .xh2 .xv1 ..... .zv1 .zv2 are valid, the coordinates
% are updated. If not valid new lines are created.
%
% This method is afecting the visual variables inside handles, but not
% updating handle structure. call guidata(hObject, handles) afterwards.



    x=round(get(handles.sliderX,'Value'));
    y=round(get(handles.sliderY,'Value'));
    z=round(get(handles.sliderZ,'Value'));
    
    D=size(handles.T1.img);

    % X plane
    set(handles.figure1,'CurrentAxes',handles.axesX);
    if ~ishandle(handles.cross.xh1) %updateSlice(1)
        %inicialize cross handles
        %horizontal
        handles.cross.xh1=line([0 y-1],[z,z],'Color',handles.colors.y);
        handles.cross.xh2=line([y+1 D(2)],[z,z],'Color',handles.colors.y);
        % %vertical
        handles.cross.xv1=line([y y],[0,z-1],'Color',handles.colors.z);
        handles.cross.xv2=line([y y],[z+1,D(3)],'Color',handles.colors.z);
    else
        %horizontal
        set(handles.cross.xh1, 'XData', [0 y-1], 'YData', [z z],'Color',handles.colors.y);
        set(handles.cross.xh2, 'XData', [y+1 D(2)], 'YData', [z z],'Color',handles.colors.y);
        %vertical
        set(handles.cross.xv1,'XData', [y y], 'YData',[0,z-1],'Color',handles.colors.z);
        set(handles.cross.xv2, 'XData', [y y], 'YData', [z+1,D(3)],'Color',handles.colors.z);
    end
    
    % Y plane
    set(handles.figure1,'CurrentAxes',handles.axesY);
    if ~ishandle(handles.cross.yh1)  %updateSlice(2)    %inicialize cross handles
        %horizontal
        handles.cross.yh1=line([0 x-1],[z,z],'Color',handles.colors.x);
        handles.cross.yh2=line([x+1 D(1)],[z,z],'Color',handles.colors.x);
        % %vertical
        handles.cross.yv1=line([x x],[0,z-1],'Color',handles.colors.z);
        handles.cross.yv2=line([x x],[z+1,D(3)],'Color',handles.colors.z);
        
    else
        %horizontal
        set(handles.cross.yh1, 'XData', [0 x-1], 'YData', [z z],'Color',handles.colors.x);
        set(handles.cross.yh2, 'XData', [x+1 D(1)], 'YData', [z z],'Color',handles.colors.x);
        %vertical
        set(handles.cross.yv1,'XData', [x x], 'YData',[0,z-1],'Color',handles.colors.z);
        set(handles.cross.yv2, 'XData', [x x], 'YData', [z+1,D(3)],'Color',handles.colors.z);
    end
    
    %Z plane
    set(handles.figure1,'CurrentAxes',handles.axesZ);
    if ~ishandle(handles.cross.zh1) %updateSlice(3)
        %inicialize cross handles
        
        %horizontal
        handles.cross.zh1=line([0 x-1],[y,y],'Color',handles.colors.x);
        handles.cross.zh2=line([x+1 D(1)],[y,y],'Color',handles.colors.x);
        % %vertical
        handles.cross.zv1=line([x,x],[0 y-1],'Color',handles.colors.y);
        handles.cross.zv2=line([x,x],[y+1 D(2)],'Color',handles.colors.y);
        
    else
        %horizontal
        set(handles.cross.zh1, 'XData', [0 x-1], 'YData', [y y],'Color',handles.colors.x);
        set(handles.cross.zh2, 'XData', [x+1 D(1)], 'YData', [y y],'Color',handles.colors.x);
        %vertical
        set(handles.cross.zv1,'XData', [x x], 'YData',[0,y-1],'Color',handles.colors.y);
        set(handles.cross.zv2, 'XData', [x x], 'YData', [y+1,D(2)],'Color',handles.colors.y);
        
    end

if strcmpi( get(handles.viewCrossbutton,'state'), 'on')
        
    set(handles.cross.xh1,'Visible','on');
    set(handles.cross.xh2,'Visible','on');
    set(handles.cross.xv1,'Visible','on');
    set(handles.cross.xv2,'Visible','on');
    set(handles.cross.yh1,'Visible','on');
    set(handles.cross.yh2,'Visible','on');
    set(handles.cross.yv1,'Visible','on');
    set(handles.cross.yv2,'Visible','on');
    set(handles.cross.zh1,'Visible','on');
    set(handles.cross.zh2,'Visible','on');
    set(handles.cross.zv1,'Visible','on');
    set(handles.cross.zv2,'Visible','on');
else
    set(handles.cross.xh1,'Visible','off');
    set(handles.cross.xh2,'Visible','off');
    set(handles.cross.xv1,'Visible','off');
    set(handles.cross.xv2,'Visible','off');
    set(handles.cross.yh1,'Visible','off');
    set(handles.cross.yh2,'Visible','off');
    set(handles.cross.yv1,'Visible','off');
    set(handles.cross.yv2,'Visible','off');
    set(handles.cross.zh1,'Visible','off');
    set(handles.cross.zh2,'Visible','off');
    set(handles.cross.zv1,'Visible','off');
    set(handles.cross.zv2,'Visible','off');
    
end

function handles=cross3D(handles)%,new)
% Fuction to update 3D crosshairs. 
% if handles.cross.x3D .y3D .z3D are valid, the coordinates
% are updated. If not valid new lines are created.
%
% This method is afecting the visual variables inside handles, but not
% updating handle structure. call guidata(hObject, handles) afterwards.
% inicialize cross handles
%
% OLD stuff:
% new = 1 plot new
% new = 0 update plot

if isempty(handles.T1)
    warning('First Load MRI image. Click New button or open existing project');
    return;
end

%plot crosshair in 3D VIEW using 2D cords
x=floor(get(handles.sliderX,'Value'));
y=floor(get(handles.sliderY,'Value'));
z=floor(get(handles.sliderZ,'Value'));

crd=mesh2AnatSpace([x,y,z],handles.S2);

xl=get(handles.axes2,'XLim'); 
yl=get(handles.axes2,'YLim'); 
zl=get(handles.axes2,'ZLim'); 

if ~ishandle(handles.cross.x3D) %new
    axes(handles.axes2);
    handles.cross.x3D=line(xl,[crd(2) crd(2)],[crd(3) crd(3)],'Color',handles.colors.x);
    handles.cross.y3D=line([crd(1),crd(1)],yl,[crd(3) crd(3)],'Color',handles.colors.y);
    handles.cross.z3D=line([crd(1),crd(1)],[crd(2) crd(2)],zl,'Color',handles.colors.z);
    
else %modify
    set(handles.cross.x3D, 'XData',xl, 'YData', [crd(2) crd(2)], 'ZData',[crd(3) crd(3)], 'Color',handles.colors.x);
    set(handles.cross.y3D, 'XData',[crd(1),crd(1)], 'YData', yl, 'ZData',[crd(3) crd(3)], 'Color',handles.colors.y);
    set(handles.cross.z3D, 'XData',[crd(1),crd(1)], 'YData', [crd(2) crd(2)], 'ZData',zl, 'Color',handles.colors.z);    
end
    
if strcmpi( get(handles.viewCrossbutton,'state'), 'on')
        set(handles.cross.x3D,'Visible','on');
        set(handles.cross.y3D,'Visible','on');
        set(handles.cross.z3D,'Visible','on');
   
else
        set(handles.cross.x3D,'Visible','off');
        set(handles.cross.y3D,'Visible','off');
        set(handles.cross.z3D,'Visible','off');
        
end

function handles=cross3DThres(handles)
% Fuction to update 3D crosshairs in the 3DThres view. 
% if handles.cross.x3D .y3D .z3D are valid, the coordinates
% are updated. If not valid new lines are created.
%
% This method is afecting the visual variables inside handles, but not
% updating handle structure. call guidata(hObject, handles) afterwards.
% inicialize cross handles

if isempty(handles.T1)
    warning('First Load MRI image. Click New button or open existing project');
    return;
end

%plot crosshair in 3D VIEW using 2D cords
x=floor(get(handles.sliderX,'Value'));
y=floor(get(handles.sliderY,'Value'));
z=floor(get(handles.sliderZ,'Value'));

crd=mesh2AnatSpace([x,y,z],handles.S2);

%plot crosshair in 3D Threshold using 2D cords
axes(handles.axes1);
xl=get(handles.axes1,'XLim');
yl=get(handles.axes1,'YLim');
zl=get(handles.axes1,'ZLim');

if ~ishandle(handles.cross.x3DThres) %new
    handles.cross.x3DThres=line(xl,[crd(2) crd(2)],[crd(3) crd(3)],'Color','r');
    handles.cross.y3DThres=line([crd(1),crd(1)],yl,[crd(3) crd(3)],'Color','g');
    handles.cross.z3DThres=line([crd(1),crd(1)],[crd(2) crd(2)],zl,'Color','b');
else %modify
    set(handles.cross.x3DThres, 'XData',xl, 'YData', [crd(2) crd(2)], 'ZData',[crd(3) crd(3)], 'Color','r');
    set(handles.cross.y3DThres, 'XData',[crd(1),crd(1)], 'YData', yl, 'ZData',[crd(3) crd(3)], 'Color','g');
    set(handles.cross.z3DThres, 'XData',[crd(1),crd(1)], 'YData', [crd(2) crd(2)], 'ZData',zl, 'Color','b');
end


if strcmpi( get(handles.viewCrossbutton,'state'), 'on')
    set(handles.cross.x3DThres,'Visible','on');
    set(handles.cross.y3DThres,'Visible','on');
    set(handles.cross.z3DThres,'Visible','on');
else
    set(handles.cross.x3DThres,'Visible','off');
    set(handles.cross.y3DThres,'Visible','off');
    set(handles.cross.z3DThres,'Visible','off');
    
end

%--------------------------------------------------------------------
%%%%%%%%%%%%%%%           Go to Button (invisible)          %%%%%%%%%%%%%%%
function GoToButton_Callback(hObject, eventdata, handles)
% hObject    handle to GoToButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project.')
    return
end

%axes(handles.axesX);
[d1,d2]=ginput(1);

G=gca;
% X-view
% z=d2
% y=d1

if G == handles.axesX %get(handles.radiobuttonX,'Value')
    set(handles.sliderY,'Value',d1);
    set(handles.sliderZ,'Value',d2);
    
    % Y-view
    %x=d1
    %z=d2;
elseif G == handles.axesY %get(handles.radiobuttonY,'Value')
    set(handles.sliderX,'Value',d1);
    set(handles.sliderZ,'Value',d2);
    
    % Z-view
    %x=d1
    %y=d2
elseif G == handles.axesZ % get(handles.radiobuttonZ,'Value')
    set(handles.sliderX,'Value',d1);
    set(handles.sliderY,'Value',d2);
end
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%         update thresholding view            %%%%%%%%%%%%%%%
function handles=updatePlot (handles)
% This method is afecting the visual variables inside handles, but not
% updating handle structure. call guidata(hObject, handles) afterwards.
% inicialize cross handles.
% Function calls to cross3DThres

axes(handles.axes1) %makes a new axes
axis image
cla

if isempty(handles.TAC)
    text (0.25,0.5,'No CT image to threshold. Click Load CT button');
else
    
    img=32767*int16((handles.TAC.img> get(handles.sliderThrMin,'Value') * handles.maxValue)...
        .*(handles.TAC.img< get(handles.sliderThrMax,'Value') * handles.maxValue).*logical(handles.mask.img)); %me quedo con el inskull de la TAC
    ind=find(img);
    % agregar condicion para cuando no hay coordenadas para plotear
    
    if ~isempty(ind)
         if length(ind)> 25000 %arbitrary limit value
             ind=ind(randperm(length(ind),25000));
             warning('More than 25000 voxels thresholded. Only a random selection of 25000 voxels are ploted');
         end     
        vTAC=handles.TAC.img(ind); %values
        [crd(1,:),crd(2,:),crd(3,:)]=ind2sub(size(img),ind);
        crd=mesh2AnatSpace(crd',handles.S2);
        handles.sct=scatter3(handles.axes1, crd(:,1),crd(:,2),crd(:,3),20,vTAC,'o', 'filled');
    end
    xlabel(handles.axes1,'x'); ylabel(handles.axes1,'y'); zlabel(handles.axes1,'z');
    axis(handles.axes1, 'image')
    %----------
    
    set(handles.text1,'String', get(handles.sliderThrMax,'Value')*handles.maxValue);
    set(handles.text2,'String', get(handles.sliderThrMin,'Value')*handles.maxValue);
    
    
    % update cross in axes1 (3D Threshold)
    handles=cross3DThres(handles);
end

%--------------------------------------------------------------------
%%%%%%%%%%%%%%%          3D surfaces to plot                %%%%%%%%%%%%%%%
% --- Leftcheckbox.
function Leftcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to Leftcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Leftcheckbox

handles.updatePlots.surfaces=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

% --- Rightcheckbox.
function Rightcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to Rightcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Rightcheckbox

handles.updatePlots.surfaces=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

% --- LeftSCEcheckbox.
function LeftSCEcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to LeftSCEcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LeftSCEcheckbox
handles.updatePlots.surfaces=1;
handles=updateElectrodes3D(handles);
guidata(hObject, handles);

% --- RightSCEcheckbox.
function RightSCEcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to RightSCEcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RightSCEcheckbox

handles.updatePlots.surfaces=1;
handles=updateElectrodes3D(handles);
guidata(hObject, handles);

% --- PlotConnCheckbox.
function PlotConnCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to PlotConnCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.updatePlots.elecLines=1;
handles.updatePlots.targetLines=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

% --- DispLabelsCheckbox.
function DispLabelsCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to DispLabelsCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DispLabelsCheckbox
handles.updatePlots.labels=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);


% --- Display Cortical parcellation (annotation) 
function Annotationcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to Annotationcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Annotationcheckbox

handles.updatePlots.surfaces=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);


%--------------------------------------------------------------------
%%%%%%%%%%%%%%%            2D view sliders                  %%%%%%%%%%%%%%%
% --- sliderX
function sliderX_Callback(hObject, eventdata, handles)
% hObject    handle to sliderX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% make value integer
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

% --- sliderY 
function sliderY_Callback(hObject, eventdata, handles)
% hObject    handle to sliderY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% make value integer
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

% --- sliderZ
function sliderZ_Callback(hObject, eventdata, handles)
% hObject    handle to sliderZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% make value integer
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%%%%%%%%%%         3D view transparency slider         %%%%%%%%%%%%%%%
function AlphaSlider_Callback(hObject, eventdata, handles)
% hObject    handle to AlphaSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.updatePlots.surfaces=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%            2D VIEWS                         %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%         visualzation window                 %%%%%%%%%%%%%%%
% --- MinWinslider
function MinWinslider_Callback(hObject, eventdata, handles)
% hObject    handle to MinWinslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if get(handles.MinWinslider,'Value') > get(handles.MaxWinslider,'Value')
    set(handles.MinWinslider,'Value',get(handles.MaxWinslider,'Value')-1e-10); %need to be diferent values
end

handles=updateMix_TAC_MR(handles);
handles.updatePlots.views2D=[1 1 1];
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

% --- MaxWinslider
function MaxWinslider_Callback(hObject, eventdata, handles)
% hObject    handle to MaxWinslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if get(handles.MinWinslider,'Value') > get(handles.MaxWinslider,'Value')
    set(handles.MaxWinslider,'Value',get(handles.MinWinslider,'Value')+1e-10); %need to be diferent values
end

handles=updateMix_TAC_MR(handles);

handles.updatePlots.views2D=[1 1 1];
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%%%%%%%%%%               MRI-CT mixture                %%%%%%%%%%%%%%%
function TAC_MRIslider_Callback(hObject, eventdata, handles)
% hObject    handle to TAC_MRIslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles=updateMix_TAC_MR(handles);
handles=updateTAC(handles);
% Update handles structure
guidata(hObject, handles);

function handles=updateMix_TAC_MR(handles)
% Updates the content of handles.imgW based on the available images and
% color options options. Should call for updateTAC after

opt.colorT1=handles.colors.colorT1; %from defaultGuiVariables
opt.colorCT=handles.colors.colorCT; %from defaultGuiVariables
opt.edgeCTchannels=handles.colors.edgeCTchannels;
opt.edgeCT=get(handles.edgeCheckbox,'Value'); %edgeCT
opt.win=[get(handles.MinWinslider,'Value') get(handles.MaxWinslider,'Value')];
mixValue=get(handles.TAC_MRIslider,'Value');

if ~isempty(handles.T1)
    
    T1=single(handles.T1.img);
        
    if isempty(handles.TAC)
        %only MRI
       handles.imgW=mixImages(T1,[],mixValue,opt);
    else
        %MRI and CT mixture
        TAC=single(handles.TAC.img);
        handles.imgW=mixImages(T1,TAC,mixValue,opt);
    end
    handles.updatePlots.views2D=[1 1 1];
end

%--------------------------------------------------------------------
%%%%%%%%%%%%%%%             overlays                       %%%%%%%%%%%%%%%
% --- Electrodes Overlay
function ElecOverlaycheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to ElecOverlaycheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ElecOverlaycheckbox
handles.updatePlots.views2D=[1 1 1]; %Force update all slices
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

% --- planning Overlay
function planningOverlaycheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to planningOverlaycheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of planningOverlaycheckbox
handles.updatePlots.views2D=[1 1 1]; %Force update all slices
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

% --- Collapse 
function Collapsecheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to Collapsecheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Collapsecheckbox
handles.updatePlots.views2D=[1 1 1]; %Force update all slices
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

% --- Parcellation atlas
function parcellationCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to parcellationCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of parcellationCheckbox

handles.updatePlots.views2D=[1 1 1];
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

% --- Edge CT
function edgeCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to edgeCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edgeCheckbox

handles=updateMix_TAC_MR(handles);
handles.updatePlots.views2D=[1 1 1];
handles=updateTAC(handles);
% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%             CLUSTERUÌNG                     %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%         Thresholding Sliders                %%%%%%%%%%%%%%%
% --- sliderThrMax
function sliderThrMax_Callback(hObject, eventdata, handles)
% hObject    handle to sliderThrMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles=updatePlot(handles);

% Update handles structure
guidata(hObject, handles);


% --- sliderThrMin
function sliderThrMin_Callback(hObject, eventdata, handles)
% hObject    handle to sliderThrMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% --- Executes during object creation, after setting all properties.

handles=updatePlot(handles);

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%%%%%%%%%%           Erode - Dilate                    %%%%%%%%%%%%%%%
% --- Dilate
function ImgDilatePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ImgDilatePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.mask)
    warning('Mask image not present');
    return;
else
    handles.mask.img=imdilate( handles.mask.img, ones(3,3,3));
    handles=updatePlot(handles);
end

% Update handles structure
guidata(hObject, handles);

% --- Erode
function ImgErodePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ImgErodePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.mask)
    warning('Mask image not present');
    return;
else
    handles.mask.img=imerode( handles.mask.img, ones(3,3,3));
    handles=updatePlot(handles);
end

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%%%%%%%%%%             Brushing                       %%%%%%%%%%%%%%%
% --- Select Voxels
function SelectVoxelspushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SelectVoxelspushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
brushObj=brush;
set(brushObj,'Enable','on');
handles.brushObj=brushObj;


% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%             Clustering                      %%%%%%%%%%%%%%%
% --- ClusterButton.
function ClusterButton1_Callback(hObject, eventdata, handles)
% hObject    handle to ClusterButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% do to incompatible access to brushed data in different matlab versions

if verLessThan('matlab','8.4.0')
    % execute code for R2014a or earlier
    hBrushPoints = findall(handles.axes1,'tag','Brushing');
    if isempty(hBrushPoints)
        warning ('There are no points selected to be clustered');
        return;
    else
        brushedData = get(hBrushPoints, {'Xdata','Ydata','Zdata'});
        brushCrd= [brushedData{1}' brushedData{2}' brushedData{3}'];
        removeCrd=isnan(brushedData{1});
        brushCrd(removeCrd,:)=[];
    end
else
    % execute code for R2014b or later
    if isempty(handles.sct)
        warning ('There are no points selected to be clustered');
        return;
    else
        brushedIdx = logical(handles.sct.BrushData);  % logical array of scatter brushed points
        if isempty(brushedIdx)
            warning ('There are no points selected to be clustered');
            return;
        else
            brushCrd(:,1) = handles.sct.XData(brushedIdx);
            brushCrd(:,2) = handles.sct.YData(brushedIdx);
            brushCrd(:,3) = handles.sct.ZData(brushedIdx);
        end
    end
end

nClus=str2double( get(handles.edit1,'String'));
TACCords=round(AnatSpace2Mesh(brushCrd,handles.S2));
indexTAC=sub2ind(size(handles.TAC.img),TACCords(:,1),TACCords(:,2),TACCords(:,3));
weight=handles.TAC.img(indexTAC)-min(handles.TAC.img(:));


% new cluster algorithm (performs better is most cases)
if exist('kmedoids.m','file')
    [clusters] = kmedoids(brushCrd,nClus);
    
    GS=zeros(nClus,3);
    %get center of mass
    for i=1:nClus
        weight=double(weight);
        ind=clusters==i;
        W=sum(weight(ind));
        GS(i,:)=sum(diag(weight(ind))* brushCrd(ind,:),1)*(1/W);
    end
else % call OLD clustering algorithm
    [GS,clusters]=clustering (nClus,brushCrd,weight);
end

% save old GS
handles.oldGS=handles.GS;
handles.oldbrushCrd=handles.brushCrd;
handles.oldbrushWeight=handles.brushWeight;
handles.oldclusters=handles.clusters;

%add electrodes coordinates to previous
handles.GS=[handles.GS; GS];
handles.brushCrd=[handles.brushCrd; brushCrd];
handles.clusters=[handles.clusters; (clusters+length(unique(handles.clusters)))];
handles.brushWeight=[handles.brushWeight; weight];
set(handles.nClusText,'string',num2str(size(handles.GS,1)));

handles.updatePlots.GS=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%        Manually add coordinates             %%%%%%%%%%%%%%%
% --- AddCoordinateButton.
function AddCoordinateButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddCoordinateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get sliders values
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project.')
    return
end

x=floor(get(handles.sliderX,'Value'));
y=floor(get(handles.sliderY,'Value'));
z=floor(get(handles.sliderZ,'Value'));

crd=[x y z];
crd=mesh2AnatSpace(crd,handles.S2);

if ~isempty(handles.TAC)
    weight=handles.TAC.img(x,y,z)-min(handles.TAC.img(:));
else
    weight=0; % force to zero if CT not present
end
        
% save old GS
handles.oldGS=handles.GS;
handles.oldbrushCrd=handles.brushCrd;
handles.oldbrushWeight=handles.brushWeight;
handles.oldclusters=handles.clusters;

handles.GS=[handles.GS; crd];
handles.brushCrd=[handles.brushCrd; crd];
handles.clusters=[handles.clusters; (length(unique(handles.clusters))+1)];
handles.brushWeight=[handles.brushWeight; weight];
set(handles.nClusText,'string',num2str(size(handles.GS,1)));

handles.updatePlots.GS=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%     Manually delete coordinates             %%%%%%%%%%%%%%%
% --- DelCoordinateButton.
function DelCoordinateButton_Callback(hObject, eventdata, handles)
% hObject    handle to DelCoordinateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project.')
    return
end

x=floor(get(handles.sliderX,'Value'));
y=floor(get(handles.sliderY,'Value'));
z=floor(get(handles.sliderZ,'Value'));

crd=[x y z];
crd=mesh2AnatSpace(crd,handles.S2);

%search for closest coordinate 
dist=eucDistMat(handles.GS,crd);
[m,ind]=min(dist);

if m<2 %2mm
    % save old GS
    handles.oldGS=handles.GS;
    handles.oldbrushCrd=handles.brushCrd;
    handles.oldbrushWeight=handles.brushWeight;
    handles.oldclusters=handles.clusters;
    
    %remove coordinate from GS
    handles.GS(ind,:)=[];
    
    indClus=find(handles.clusters==ind); %actual cluster
    indBigClus=find(handles.clusters>ind); %clusters of bigger index
    
    handles.clusters(indBigClus,:)= handles.clusters(indBigClus,:)-1; %decrease the clus num
    handles.clusters(indClus,:)=[]; % remove cluster elements 
        
    handles.brushCrd(indClus,:)=[]; %remove brush coords
    handles.brushWeight(indClus,:)=[]; %remove brushweight
    
    set(handles.nClusText,'string',num2str(size(handles.GS,1)));
    
    handles.updatePlots.GS=1;
    handles=updateElectrodes3D(handles);
    
    % Update handles structure
    guidata(hObject, handles);

else
    warning('No electrodes in the proximity (2mm) to be deleted')
end

%%%%%%%%%%%%%%%   Clear Coordinates in case of error        %%%%%%%%%%%%%%%
% --- ClearAllButton.
function ClearAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project.')
    return
end

% save old GS
handles.oldGS=handles.GS;
handles.oldbrushCrd=handles.brushCrd;
handles.oldbrushWeight=handles.brushWeight;
handles.oldclusters=handles.clusters;

handles.GS=[];
handles.brushCrd=[];
handles.brushWeight=[];
handles.clusters=[];
set(handles.nClusText,'string',num2str(size(handles.GS,1)));

handles.updatePlots.electrodes=1;
handles.updatePlots.labels=1;
handles.updatePlots.elecLines=1;
handles.updatePlots.GS=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);


% --- Removed // ClearLastButton.
function ClearLastButton_Callback(hObject, eventdata, handles)
% % hObject    handle to ClearLastButton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% if isempty(handles.T1)
%     warning ('First Load MRI image. Click New button or open existing project.')
%     return
% end
% 
% handles.oldGS=handles.GS;
% handles.GS(end,:)=[];
% set(handles.nClusText,'string',num2str(size(handles.GS,1)));
%
% handles.updatePlots.GS=1;
% handles=updateElectrodes3D(handles);
% 
% % Update handles structure
% guidata(hObject, handles);
% 

% --- Undo 
function Recpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Recpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%recover GS, brushCrd, and brushWeight from old  

tempGS=handles.GS;
handles.GS=handles.oldGS;
handles.oldGS=tempGS;

tempbrushCrd=handles.brushCrd;
handles.brushCrd=handles.oldbrushCrd;
handles.oldbrushCrd=tempbrushCrd;

tempbrushWeight=handles.brushWeight;
handles.brushWeight=handles.oldbrushWeight;
handles.oldbrushWeight=tempbrushWeight;

tempclusters=handles.clusters;
handles.clusters=handles.oldclusters;
handles.oldclusters=tempclusters;

set(handles.nClusText,'string',num2str(size(handles.GS,1)));

handles.updatePlots.GS=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%             LABELING                        %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%   Change grid or depth electrode labeling   %%%%%%%%%%%%%%%
% --- Executes when selected object is changed in arrayUipanel.
function arrayUipanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in arrayUipanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

if get(handles.DepthButton,'Value') % deepth electrode selected
    set(handles.text19,'Visible','off');
    set(handles.text20,'Visible','off');
    
    set(handles.rowsEdit,'Visible','off');
    set(handles.colsEdit,'Visible','off');
    
    set(handles.rLpushbutton,'Visible','off');
    set(handles.rRpushbutton,'Visible','off');
    set(handles.fLRpushbutton,'Visible','off');
    set(handles.fUDpushbutton,'Visible','off');
    
    set(handles.FlipLabelsPushbutton,'Visible','on');
    
else  %grid selected
    
    set(handles.text19,'Visible','on');
    set(handles.text20,'Visible','on');
    
    set(handles.rowsEdit,'Visible','on');
    set(handles.colsEdit,'Visible','on');
    
    set(handles.rLpushbutton,'Visible','on');
    set(handles.rRpushbutton,'Visible','on');
    set(handles.fLRpushbutton,'Visible','on');
    set(handles.fUDpushbutton,'Visible','on');
    
    set(handles.FlipLabelsPushbutton,'Visible','off');
    
end

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%                Indexing                     %%%%%%%%%%%%%%%
% --- Executes on button press in Indexpushbutton.
function Indexpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Indexpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.GS)
    warning('First Cluster some electrodes.');
    return
end

% strips or depth
if get(handles.DepthButton,'value')
    [electrodes,Ix]=indexDepthElectrodes(handles.GS,'depth');   
elseif get(handles.GridButton,'value')
    rows=str2double(get(handles.rowsEdit,'string'));
    columns=str2double(get(handles.colsEdit,'string'));
    [electrodes,Ix]=indexGridElectrodes(handles.GS,rows,columns,'grid',handles.options);
end

% add info from all voxels in the clusters
% rename clusters in the proper order
tempC=handles.clusters;
for i=1:size(handles.GS,1)
     handles.clusters(tempC==Ix(i))=i;
end

% include in electrodes structure
electrodes.clusters=handles.clusters; 
electrodes.brushCrd=handles.brushCrd;
electrodes.brushWeight=handles.brushWeight;

% make adjacency Matrix
electrodes.adjMat=makeAdjMat(electrodes.rows,electrodes.columns);

% add to structure
L=length(handles.electrodes);
l=L+1; % new electrode array
handles.electrodes{l}=electrodes;

% process projections if needed
handles=processProjections(handles);

% anatomical labeling (electrodes and projections)
if strcmp(handles.currentSpace,'MNI'); % options are 'Native' 'MNI'        %strcmp (get(handles.MNILabelstogglebutton,'state'),'on')
    handles=labels2MNIspace(handles);
else
    handles=labels2NativeSpace(handles);
end
    
% pos=[electrodes.x electrodes.y electrodes.z];
% lookArround=1; radio=2;
% if strcmp(handles.currentSpace,'MNI'); % options are 'Native' 'MNI'        %strcmp (get(handles.MNILabelstogglebutton,'state'),'on')
%     electrodes.aLabels=anatomicLabel(pos,handles.MNI_S_matrix,handles.MNIlabels,handles.MNIprob);
% elseif ~isempty(handles.wmparc)
%     electrodes.aLabels=anatomicLabelFS(pos, [],lookArround,handles.wmparc.img,handles.wmparcS,radio);
% else
%     electrodes.aLabels=repmat({'no atlas loaded'},electrodes.nElectrodes,1);
% end


%save to old coordinates
handles.oldGS=handles.GS;
handles.oldbrushCrd=handles.brushCrd;
handles.oldbrushWeight=handles.brushWeight;
handles.oldclusters=handles.clusters;

handles.GS=[];
handles.brushCrd=[];
handles.brushWeight=[];
handles.clusters=[];
set(handles.nClusText,'string',num2str(size(handles.GS,1)));

%set visualization to this electrode
set(handles.arrayNumberText,'String',num2str(l));
set(handles.elecNumberText,'String',num2str(1));
set(handles.editArrayName,'String',handles.electrodes{l}.Name);
set(handles.editElecLabels,'string',handles.electrodes{l}.ch_label{1});

% go to first electrode coordinate for checking
d1=handles.electrodes{l}.x(1);
d2=handles.electrodes{l}.y(1);
d3=handles.electrodes{l}.z(1);

D=AnatSpace2Mesh([d1 d2 d3],handles.S2);
set(handles.sliderX,'Value',D(1));
set(handles.sliderY,'Value',D(2));
set(handles.sliderZ,'Value',D(3));

handles.updatePlots.GS=1;
handles.updatePlots.electrodes=1;
handles.updatePlots.labels=1;
handles.updatePlots.elecLines=1;

handles=updateElectrodes3D(handles);
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%%%%%%%%%%   grid Indexing/labeling modifications      %%%%%%%%%%%%%%%
% --- Executes on button press in rLpushbutton.
function rLpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to rLpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.electrodes)
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end

a=str2double(get(handles.arrayNumberText,'String'));

electrodes=handles.electrodes{a};
if electrodes.rows ~= electrodes.columns
    warning('rows ~= columns');
    
else
    newOrder=1:electrodes.nElectrodes;
    newOrder=permute(reshape(newOrder,electrodes.columns,electrodes.rows),[2 1]);
    newOrder=permute(rot90(newOrder,-1),[2 1]);
    electrodes=reorderElectrodes(electrodes,newOrder(:));

%     LabelsInd=1:electrodes.nElectrodes;
%     LabelsMat=permute(reshape(LabelsInd,electrodes.columns,electrodes.rows),[2 1]);
%     LabelsMat=permute(rot90(LabelsMat,-1),[2 1]);
%     
%     %rotate electrodes
%     electrodes.x=electrodes.x(LabelsMat(:));
%     electrodes.y=electrodes.y(LabelsMat(:));
%     electrodes.z=electrodes.z(LabelsMat(:));
%     
%     %rotate anatomical labels
%     electrodes.aLabels=electrodes.aLabels(LabelsMat(:));
%     electrodes.anatInd=electrodes.anatInd(LabelsMat(:),:);
% 
%     %rotate clusters
%     tmp=zeros(size(electrodes.clusters));
%     for i=LabelsInd
%         tmp(electrodes.clusters==i)=LabelsMat(i);
%     end
%     electrodes.clusters=tmp;
%     
%     % no need to change adjMat
    
    handles.electrodes{a}=electrodes;    

    handles.updatePlots.labels=1;
    handles=updateElectrodes3D(handles);
    
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in rRpushbutton.
function rRpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to rRpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.electrodes)
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end

a=str2double(get(handles.arrayNumberText,'String'));

electrodes=handles.electrodes{a};
if electrodes.rows ~= electrodes.columns
    warning('rows ~= columns');
else
    
    newOrder=1:electrodes.nElectrodes;
    newOrder=permute(reshape(newOrder,electrodes.columns,electrodes.rows),[2 1]);
    newOrder=permute(rot90(newOrder),[2 1]);
    electrodes=reorderElectrodes(electrodes,newOrder(:));

%     LabelsInd=1:electrodes.nElectrodes;
%     LabelsMat=permute(reshape(LabelsInd,electrodes.columns,electrodes.rows),[2 1]);
%     LabelsMat=permute(rot90(LabelsMat),[2 1]);
%     
%     %rotate coordinates
%     electrodes.x=electrodes.x(LabelsMat(:));
%     electrodes.y=electrodes.y(LabelsMat(:));
%     electrodes.z=electrodes.z(LabelsMat(:));
%     
%     %rotate anatomical labels
%     electrodes.aLabels=electrodes.aLabels(LabelsMat(:));
%     electrodes.anatInd=electrodes.anatInd(LabelsMat(:),:);
%     
%     %rotate clusters
%     tmp=zeros(size(electrodes.clusters));
%     for i=LabelsInd
%         tmp(electrodes.clusters==i)=LabelsMat(i);
%     end
%     electrodes.clusters=tmp;
%     
%     % no need to change adjMat
    
    handles.electrodes{a}=electrodes;    

    handles.updatePlots.labels=1;
    handles=updateElectrodes3D(handles);
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in fLRpushbutton.
function fLRpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to fLRpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.electrodes)
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end

a=str2double(get(handles.arrayNumberText,'String'));

electrodes=handles.electrodes{a};

newOrder=1:electrodes.nElectrodes;
newOrder=permute(reshape(newOrder,electrodes.columns,electrodes.rows),[2 1]);
newOrder=permute(fliplr(newOrder),[2 1]);
electrodes=reorderElectrodes(electrodes,newOrder(:));

% LabelsInd=1:electrodes.nElectrodes;
% LabelsMat=permute(reshape(LabelsInd,electrodes.columns,electrodes.rows),[2 1]);
% LabelsMat=permute(fliplr(LabelsMat),[2 1]);
% 
% %flip coordinates
% electrodes.x=electrodes.x(LabelsMat(:));
% electrodes.y=electrodes.y(LabelsMat(:));
% electrodes.z=electrodes.z(LabelsMat(:));
% 
% %flip anatomical labels
% electrodes.aLabels=electrodes.aLabels(LabelsMat(:));
% electrodes.anatInd=electrodes.anatInd(LabelsMat(:),:);
% 
% %flip clusters
% tmp=zeros(size(electrodes.clusters));
% for i=LabelsInd
%     tmp(electrodes.clusters==i)=LabelsMat(i);
% end
% electrodes.clusters=tmp;
% 
% % no need to change adjMat
% 
handles.electrodes{a}=electrodes;

handles.updatePlots.labels=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in fUDpushbutton.
function fUDpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to fUDpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.electrodes)
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end

a=str2double(get(handles.arrayNumberText,'String'));

electrodes=handles.electrodes{a};

newOrder=1:electrodes.nElectrodes;
newOrder=permute(reshape(newOrder,electrodes.columns,electrodes.rows),[2 1]);
newOrder=permute(flipud(newOrder),[2 1]);
electrodes=reorderElectrodes(electrodes,newOrder(:));

% LabelsInd=1:electrodes.nElectrodes;
% LabelsMat=permute(reshape(LabelsInd,electrodes.columns,electrodes.rows),[2 1]);
% LabelsMat=permute(flipud(LabelsMat),[2 1]);
% 
% %flip coordinates
% electrodes.x=electrodes.x(LabelsMat(:));
% electrodes.y=electrodes.y(LabelsMat(:));
% electrodes.z=electrodes.z(LabelsMat(:));
% 
% %flip anatomical labels
% electrodes.aLabels=electrodes.aLabels(LabelsMat(:));
% electrodes.anatInd=electrodes.anatInd(LabelsMat(:),:);
% 
%     
% %flip clusters
% tmp=zeros(size(electrodes.clusters));
% for i=LabelsInd
%     tmp(electrodes.clusters==i)=LabelsMat(i);
% end
% electrodes.clusters=tmp;
% 
% % no need to change adjMat
% 
handles.electrodes{a}=electrodes;

handles.updatePlots.labels=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%%%%%%%%     flip depth electrodes Index/labels        %%%%%%%%%%%%%%%
% --- Executes on button press in FlipLabelsPushbutton.
function FlipLabelsPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to FlipLabelsPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=str2double(get(handles.arrayNumberText,'String'));


if a==0
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end
electrodes=handles.electrodes{a};

newOrder=fliplr(1:electrodes.nElectrodes);
electrodes=reorderElectrodes(electrodes,newOrder(:));

% electrodes.x=flipud(electrodes.x);
% electrodes.y=flipud(electrodes.y);
% electrodes.z=flipud(electrodes.z);
% 
% LabelsInd=1:electrodes.nElectrodes;
% LabelsMat=flipud(LabelsInd);
% 
% %flip anatomical labels
% electrodes.aLabels=electrodes.aLabels(LabelsMat(:));
% electrodes.anatInd=electrodes.anatInd(LabelsMat(:),:);
% 
% %flip clusters
% tmp=zeros(size(electrodes.clusters));
% for i=LabelsInd
%     tmp(electrodes.clusters==i)=LabelsMat(i);
% end
% electrodes.clusters=tmp;

handles.electrodes{a}=electrodes;

handles.updatePlots.labels=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);


%--------------------------------------------------------------------
%%%%%%%%%%%%%     Manual indexing electrodes        %%%%%%%%%%%%%%%
% --- Manual Index pushbutton.
function manualIndexpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to manualIndexpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.electrodes)
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end

a=str2double(get(handles.arrayNumberText,'String'));

electrodes=handles.electrodes{a};

[newOrder, chLabelsOut]=movelist(electrodes.ch_label);

electrodes=reorderElectrodes(electrodes,newOrder(:));
 
handles.electrodes{a}=electrodes;

handles.updatePlots.electrodes=1;
handles.updatePlots.labels=1;
handles.updatePlots.elecLines=1;

handles=updateElectrodes3D(handles);


% Update handles structure
guidata(hObject, handles);


%--------------------------------------------------------------------
%%%%%%%%%%%%%     Label electrodes using base name          %%%%%%%%%%%%%%%
% --- Executes on button press in LabelAutoPushbutton.
function LabelAutoPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LabelAutoPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% works over the current electrode array
if isempty(handles.electrodes)
    warning('Electrodes is empty. First index some electrodes');
    return;
end
l=str2double(get(handles.arrayNumberText,'String'));
N=handles.electrodes{l}.nElectrodes;
elecBaseName=get(handles.labelEdit, 'String');
handles.electrodes{l}.Name = elecBaseName;

for i=1:N
    handles.electrodes{l}.ch_label{i}=[elecBaseName int2str(i)];
end

set(handles.elecNumberText,'String',num2str(1));
set(handles.editArrayName,'String', handles.electrodes{l}.Name);
set(handles.editElecLabels,'string', handles.electrodes{l}.ch_label{1});

handles.updatePlots.labels=1;
handles=updateElectrodes3D(handles);
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%     Label electrodes from list                %%%%%%%%%%%%%%%
% --- Executes on button press in LabelListPushbutton.
function LabelListPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LabelListPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.electrodes)
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end
% works over the current electrode array
l=str2double(get(handles.arrayNumberText,'String'));
N=handles.electrodes{l}.nElectrodes;
elecBaseName=get(handles.labelEdit, 'String');
handles.electrodes{l}.Name = elecBaseName;
    
%get labels from file
if isempty(handles.elecListLabels)
    temp=getLabelsFromFile(handles.PathName);
    
%     temp={
%         'a1' 'b1' 'c1' 'd1' 'e1' 'f1' 'g1' 'h1'...
%         'a2' 'b2' 'c2' 'd2' 'e2' 'f2' 'g2' 'h2'...
%         'a3' 'b3' 'c3' 'd3' 'e3' 'f3' 'g3' 'h3'...
%         'a4' 'b4' 'c4' 'd4' 'e4' 'f4' 'g4' 'h4'...
%         'a5' 'b5' 'c5' 'd5' 'e5' 'f5' 'g5' 'h5'...
%         'a6' 'b6' 'c6' 'd6' 'e6' 'f6' 'g6' 'h6'...
%         'a7' 'b7' 'c7' 'd7' 'e7' 'f7' 'g7' 'h7'...
%         'a8' 'b8' 'c8' 'd8' 'e8' 'f8' 'g8' 'h8'...
%         'a9' 'b9' 'c9' 'd9' 'e9' 'f9' 'g9' 'h9'};
    
    if isempty(temp)
        return;
    end
    handles.elecListLabels=temp;
else
    % add option to go again into electrodes list
    choice = questdlg('Do you want to load new labels from file?', ...
        '', 'Yes','No','Cancel','No');
    % Handle response
    switch choice
        case 'Yes'
            temp=getLabelsFromFile(handles.PathName);
            if isempty(temp)
                return;
            end
            handles.elecListLabels=temp;            
        case 'No'
            % do nothing
        case 'Cancel'
            return;
        case ''
            return;
    end
end

left=handles.elecListLabels;
right=handles.electrodes{l}.ch_label;

while true
    [right,left]=addremovelist(...
        'LeftContents',left,...
        'RightContents',right,...
        'ListNames',{'Available Labels' 'Array Labels'},'KeepSorted',false,...
        'Title',['Select ' int2str(N) ' labels for curret array']);
    
    if length(right)==N    % check number of selected electrodes
        break;
    elseif isempty(right)  % no changes (Accept button)
        return;
    else
        disp(['Select ' int2str(N) ' electrodes'])
    end
    
end

handles.elecListLabels=left;

%label
for i=1:N
    handles.electrodes{l}.ch_label{i}=right{i};
end

set(handles.editArrayName,'String',handles.electrodes{l}.Name);
set(handles.elecNumberText,'String',num2str(1));
set(handles.editElecLabels,'string', handles.electrodes{l}.ch_label{1});

handles.updatePlots.labels=1;
handles=updateElectrodes3D(handles);
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%%%%%%%%%%    Project electrodes to SCE  %%%%%%%%%%%%%%%
% --- Executes on button press in projectSCEcheckbox.
function projectSCEcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to projectSCEcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of projectSCEcheckbox

%% TODO: add atlas and compatibility with native space surfaces

% global debugging
% debugging=1;

if isempty(handles.electrodes)
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end

handles=processProjections(handles);

handles.updatePlots.electrodes=1;
handles.updatePlots.labels=1;
handles.updatePlots.elecLines=1;
handles.updatePlots.surfaces=1;

handles=updateElectrodes3D(handles);
handles.updatePlots.views2D=[1 1 1];
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);


function handles=processProjections(handles)

if get(handles.projectSCEcheckbox,'Value') % calculate projection
    
    for i=1:length(handles.electrodes)
        isgrid(i)=strcmp({handles.electrodes{i}.Type},'grid') || strcmp({handles.electrodes{i}.Type},'strip');
    end
    if ~any(isgrid)
        warning('It is not posible to project electrodes to SCE. No grids localized yet. Please localize grids first.');
        set(handles.projectSCEcheckbox,'Value',0);
        return;
    else
        
        % Deal with previous projections
        projDone=[];
        for i=1:length(handles.electrodes)
            projDone(i)=isfield(handles.electrodes{i},'projection');
        end
        
        if sum(projDone)>0 %some projections were done before
            % Do you want to recalculate all?
            choice = questdlg('Do you want to recalculate all projections?', ...
                '', 'Yes','No','No');
            % Handle response
            switch choice
                case 'Yes'
                    projDone=projDone-projDone; % put all to cero and recalculate
                case 'No'
                    % do nothing
                case '' % close the dialog box
                    set(handles.projectSCEcheckbox,'Value',0);
                    return;
            end
        end
        
        
        % Do the projections
        if sum(~projDone)>0
            if strcmp(handles.currentSpace,'MNI'); % MNI space
                handles.electrodes=electrodes2hullCorrection(handles.electrodes,handles.v_MNI_SCE,handles.f_MNI_SCE, handles.options, projDone);
                
            else  % Native space
                if ~isempty(handles.vertices_SCE_L)
                    [vertices,faces]=mergemesh(handles.vertices_SCE_L, handles.faces_SCE_L, handles.vertices_SCE_R, handles.faces_SCE_R );
                    handles.electrodes=electrodes2hullCorrection(handles.electrodes,vertices,faces,handles.options,projDone);
                else
                    warning('You need to load Smoothed Cortical Envelope (SCE) for the Native space')
                    set(handles.projectSCEcheckbox,'Value',0);
                end
            end

            % anatomical labeling (electrodes and projections)
            if strcmp(handles.currentSpace,'MNI'); % options are 'Native' 'MNI'       
                handles=labels2MNIspace(handles);
            else
                handles=labels2NativeSpace(handles);
            end
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%             NAVIGATE ELECTRODES             %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%          edit array name                %%%%%%%%%%%%%%%
function editArrayName_Callback(hObject, eventdata, handles)
% hObject    handle to editArrayName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editArrayName as text
%        str2double(get(hObject,'String')) returns contents of editArrayName as a double
if isempty(handles.electrodes)
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end

str=get(handles.editArrayName,'String');
a=str2double(get(handles.arrayNumberText,'String'));

handles.electrodes{a}.Name=str;

% Electrode labels and Array are independent now
% N=handles.electrodes{a}.nElectrodes;
% 
% for i=1:N
%     handles.electrodes{a}.ch_label{i}=[str int2str(i)];
% end

handles.updatePlots.labels=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%          edit electrode name                %%%%%%%%%%%%%%%

function editElecLabels_Callback(hObject, eventdata, handles)
% hObject    handle to editElecLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editElecLabels as text
%        str2double(get(hObject,'String')) returns contents of editElecLabels as a double

if isempty(handles.electrodes)
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end

str=get(handles.editElecLabels,'String');
a=str2double(get(handles.elecNumberText,'String'));
l=str2double(get(handles.arrayNumberText,'String'));

handles.electrodes{l}.ch_label{a}=str;

handles.updatePlots.labels=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%          navigate electrodes                %%%%%%%%%%%%%%%
% --- Executes on button press in AmasPushbutton.
function AmasPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AmasPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.electrodes)
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end

l=str2double(get(handles.arrayNumberText,'String'));
if l < length(handles.electrodes)
    a=1; %set electrode to 1
    
    set(handles.arrayNumberText,'String',num2str(l+1));
    set(handles.elecNumberText,'String',num2str(a));
    
    d1=handles.electrodes{l+1}.x(a);
    d2=handles.electrodes{l+1}.y(a);
    d3=handles.electrodes{l+1}.z(a);
    
    D=AnatSpace2Mesh([d1 d2 d3],handles.S2);
    set(handles.sliderX,'Value',D(1));
    set(handles.sliderY,'Value',D(2));
    set(handles.sliderZ,'Value',D(3));    
    
    handles.updatePlots.electrodes=1;
    handles.updatePlots.labels=1;
    handles.updatePlots.elecLines=1;
    
    handles=updateElectrodes3D(handles);
    handles=updateTAC(handles);
    
    set(handles.editArrayName,'String',handles.electrodes{l+1}.Name);
    set(handles.editElecLabels,'string', handles.electrodes{l+1}.ch_label{a});

    
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in AmenosPushbutton.
function AmenosPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AmenosPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.electrodes)
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end


l=str2double(get(handles.arrayNumberText,'String'));

if l>1
    a=1; %set electrode to 1
    set(handles.arrayNumberText,'String',num2str(l-1));
    set(handles.elecNumberText,'String',num2str(a));
    
    d1=handles.electrodes{l-1}.x(a);
    d2=handles.electrodes{l-1}.y(a);
    d3=handles.electrodes{l-1}.z(a);
    
    D=AnatSpace2Mesh([d1 d2 d3],handles.S2);
    set(handles.sliderX,'Value',D(1));
    set(handles.sliderY,'Value',D(2));
    set(handles.sliderZ,'Value',D(3));
    
    handles.updatePlots.electrodes=1;
    handles.updatePlots.labels=1;
    handles.updatePlots.elecLines=1;
    
    handles=updateElectrodes3D(handles);
    handles=updateTAC(handles);
    
    set(handles.editArrayName,'String',handles.electrodes{l-1}.Name);
    set(handles.editElecLabels,'string', handles.electrodes{l-1}.ch_label{a});
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in EmasPushbutton.
function EmasPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to EmasPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.electrodes)
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end

l=str2double(get(handles.elecNumberText,'String'))+1;
a=str2double(get(handles.arrayNumberText,'String'));

if l <= handles.electrodes{a}.nElectrodes
    set(handles.elecNumberText,'String',num2str(l));
    set(handles.editElecLabels,'string', handles.electrodes{a}.ch_label{l});
    
    d1=handles.electrodes{a}.x(l);
    d2=handles.electrodes{a}.y(l);
    d3=handles.electrodes{a}.z(l);
    
    D=AnatSpace2Mesh([d1 d2 d3],handles.S2);
    set(handles.sliderX,'Value',D(1));
    set(handles.sliderY,'Value',D(2));
    set(handles.sliderZ,'Value',D(3));
    
    
    handles.updatePlots.electrodes=1;
    handles=updateElectrodes3D(handles);
    handles=updateTAC(handles);
    
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in EmenosPushbutton.
function EmenosPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to EmenosPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.electrodes)
    warning('Electrodes is empty. First cluster some electrodes');
    return;
end

l=str2double(get(handles.elecNumberText,'String'))-1;
a=str2double(get(handles.arrayNumberText,'String'));

if l >= 1
    set(handles.elecNumberText,'String',num2str(l));
    set(handles.editElecLabels,'string', handles.electrodes{a}.ch_label{l});
    
    d1=handles.electrodes{a}.x(l);
    d2=handles.electrodes{a}.y(l);
    d3=handles.electrodes{a}.z(l);
    
    D=AnatSpace2Mesh([d1 d2 d3],handles.S2);
    set(handles.sliderX,'Value',D(1));
    set(handles.sliderY,'Value',D(2));
    set(handles.sliderZ,'Value',D(3));
    
    handles.updatePlots.electrodes=1;
    handles=updateElectrodes3D(handles);
    handles=updateTAC(handles);
end

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%%%%%%  Select what electrodes to plot in 3D and 2D views  %%%%%%%%%%%
% --- Executes when selected object is changed in plotElectrodesOneAllUipanel.
function plotElectrodesOneAllUipanel_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in plotElectrodesOneAllUipanel
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.updatePlots.views2D=[1 1 1]; %Force update all slices
handles=updateTAC(handles);

handles.updatePlots.electrodes=1;
handles.updatePlots.labels=1;
handles.updatePlots.elecLines=1;
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%%%%%%%%                Remove Array                   %%%%%%%%%%%%%%%
% --- Executes on button press in RemoveArraypushbutton.
function RemoveArrayPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveArrayPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.electrodes) 
    
    l=str2double(get(handles.arrayNumberText,'String')); %actual elec to remove
% add warning image
    choice = questdlg([ 'Are you sure to remove electrode array number ' num2str(l) ' ?'], ...
        'Delete array', ...
        'Yes','No','No');
    if strcmp(choice,'No')
       return;
    end
    handles.electrodes(l)=[];
    if isempty(handles.electrodes)
        set(handles.arrayNumberText,'String','0');
        set(handles.elecNumberText,'String','0');

    else % at least one electrode left
        if l-1>0 
            a=l-1;
            set(handles.arrayNumberText,'String',num2str(a));
        else
            a=l;
            set(handles.arrayNumberText,'String',num2str(a));
        end
        set(handles.elecNumberText,'String','1');
        
        d1=handles.electrodes{a}.x(1);
        d2=handles.electrodes{a}.y(1);
        d3=handles.electrodes{a}.z(1);
        
        D=AnatSpace2Mesh([d1 d2 d3],handles.S2);
        set(handles.sliderX,'Value',D(1));
        set(handles.sliderY,'Value',D(2));
        set(handles.sliderZ,'Value',D(3));
    end
    
    handles.updatePlots.views2D=[1 1 1]; % Force update all slices
    handles.updatePlots.resetTAC=1;      % reset 2D views axes
    handles.updatePlots.electrodes=1;
    handles.updatePlots.labels=1;
    handles.updatePlots.elecLines=1;
    handles=updateElectrodes3D(handles);
    handles=updateTAC(handles);
end

% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%                   PLANNING                  %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%        new target definition               %%%%%%%%%%%%%%%
% --- Executes on button press in NewTargetpushbutton.
function NewTargetpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to NewTargetpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

l=length(handles.targets);
l=l+1;
%set defaults
set(handles.TargetArraytext,'String',num2str(l));
set(handles.TargetNameedit,'String','name');
handles.targets(l).name='name';

set(handles.TargetInXedit,'String','0');
set(handles.TargetInYedit,'String','0');
set(handles.TargetInZedit,'String','0');
handles.targets(l).targetIn.x=0;
handles.targets(l).targetIn.y=0;
handles.targets(l).targetIn.z=0;

set(handles.TargetOutXedit,'String','1');
set(handles.TargetOutYedit,'String','1');
set(handles.TargetOutZedit,'String','1');
handles.targets(l).targetOut.x=1;
handles.targets(l).targetOut.y=1;
handles.targets(l).targetOut.z=1;

set(handles.nTargetEdit,'String','10');
handles.targets(l).n=10;

set(handles.FirstSecondTargetedit,'String','2');
handles.targets(l).FirstSecond=2;

set(handles.SecondLastTargetEdit,'String','5');
handles.targets(l).SecondLast=5;


set(handles.AnteriorFrameradiobutton,'value',1)
handles.targets(l).framePosition='Anterior';
handles.targets(l).frameDown=0;

set(handles.TargetElectext,'String','1');

handles=updateTarget(handles);

D=AnatSpace2Mesh([0 0 0],handles.S2);
set(handles.sliderX,'Value',D(1));
set(handles.sliderY,'Value',D(2));
set(handles.sliderZ,'Value',D(3));

        
handles.updatePlots.views2D=[1 1 1];     
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;
handles=updateTAC(handles);
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%        edit target Name                     %%%%%%%%%%%%%%%
function TargetNameedit_Callback(hObject, eventdata, handles)
% hObject    handle to TargetNameedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TargetNameedit as text
%        str2double(get(hObject,'String')) returns contents of TargetNameedit as a double
l=str2double(get(handles.TargetArraytext,'String'));
handles.targets(l).name=get(handles.TargetNameedit,'String');

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%   edit target distance beteween electrodes  %%%%%%%%%%%%%%%
function FirstSecondTargetedit_Callback(hObject, eventdata, handles)
% hObject    handle to FirstSecondTargetedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FirstSecondTargetedit as text
%        str2double(get(hObject,'String')) returns contents of FirstSecondTargetedit as a double
l=str2double(get(handles.TargetArraytext,'String'));
handles.targets(l).FirstSecond=str2double(get(handles.FirstSecondTargetedit,'String'));
handles=updateTarget(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateTAC(handles);
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

function SecondLastTargetEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SecondLastTargetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SecondLastTargetEdit as text
%        str2double(get(hObject,'String')) returns contents of SecondLastTargetEdit as a double
l=str2double(get(handles.TargetArraytext,'String'));
handles.targets(l).SecondLast=str2double(get(handles.SecondLastTargetEdit,'String'));
handles=updateTarget(handles);

handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;
handles=updateTAC(handles);
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%      edit target number of electrodes       %%%%%%%%%%%%%%%
function nTargetEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nTargetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nTargetEdit as text
%        str2double(get(hObject,'String')) returns contents of nTargetEdit as a double
l=str2double(get(handles.TargetArraytext,'String'));
handles.targets(l).n=str2double(get(handles.nTargetEdit,'String'));
handles=updateTarget(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateTAC(handles);
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%%%%%%%%%  change target locations with mouse click    %%%%%%%%%%%%%%%
% --- Executes on button press in TargetInpushbutton.
function TargetInpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to TargetInpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project.')
    return
end

if isempty(handles.targets)
    warning('First create a new target');
    return;
end

[d1,d2]=ginput(1);

G=gca;
% X-view
if G == handles.axesX %get(handles.radiobuttonX,'Value')
    x=get(handles.sliderX,'Value');
    y=d1;
    z=d2;
    set(handles.sliderY,'Value',d1);
    set(handles.sliderZ,'Value',d2);
    
    % Y-view
elseif G == handles.axesY %get(handles.radiobuttonY,'Value')
    x=d1;
    y=get(handles.sliderY,'Value');
    z=d2;
    set(handles.sliderX,'Value',d1);
    set(handles.sliderZ,'Value',d2);
    
    % Z-view
elseif G == handles.axesZ % get(handles.radiobuttonZ,'Value')
    x=d1;
    y=d2;
    z=get(handles.sliderZ,'Value');
    set(handles.sliderX,'Value',d1);
    set(handles.sliderY,'Value',d2);
else
    warning('you must click inside one off the three 2D plane views')
    return;
end

% set target coordinates
% define anatomical coords
coords=mesh2AnatSpace([x y z], handles.S2);

l=str2double(get(handles.TargetArraytext,'String'));
handles.targets(l).targetIn.x=coords(1);
handles.targets(l).targetIn.y=coords(2);
handles.targets(l).targetIn.z=coords(3);

%handles.targets(l).frameDown = handles.targets(l).coordinates(handles.targets(l).n,3) < 0; %handles.targets(l).targetIn.z < 0;



if verLessThan('matlab','8.4.0')
    % execute code for R2014a or earlier
else
    % execute code for R2014b or later
    coords=round(coords,3,'significant');
end

set(handles.TargetInXedit,'String',num2str(coords(1)));
set(handles.TargetInYedit,'String',num2str(coords(2)));
set(handles.TargetInZedit,'String',num2str(coords(3)));

handles=updateTarget(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateTAC(handles);
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in TargetOutpushbutton.
function TargetOutpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to TargetOutpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.T1)
    warning ('First Load MRI image. Click New button or open existing project.')
    return
end

if isempty(handles.targets)
    warning('First create a new target')
    return;
end
[d1,d2]=ginput(1);

if verLessThan('matlab','8.4.0')
    % execute code for R2014a or earlier
else
    % execute code for R2014b or later
    d1=round(d1,3,'significant');
    d2=round(d2,3,'significant');
end

G=gca;
% X-view
if G == handles.axesX %get(handles.radiobuttonX,'Value')
    x=get(handles.sliderX,'Value');
    y=d1;
    z=d2;
    set(handles.sliderY,'Value',d1);
    set(handles.sliderZ,'Value',d2);
    
    % Y-view
elseif G == handles.axesY %get(handles.radiobuttonY,'Value')
    x=d1;
    y=get(handles.sliderY,'Value');
    z=d2;
    set(handles.sliderX,'Value',d1);
    set(handles.sliderZ,'Value',d2);
    
    % Z-view
elseif G == handles.axesZ % get(handles.radiobuttonZ,'Value')
    x=d1;
    y=d2;
    z=get(handles.sliderZ,'Value');
    set(handles.sliderX,'Value',d1);
    set(handles.sliderY,'Value',d2);
else
    warning('you must click inside one off the three 2D plane views')
    return;
end

% set target coordinates
% define anatomical coords
coords=mesh2AnatSpace([x y z], handles.S2);

l=str2double(get(handles.TargetArraytext,'String'));
handles.targets(l).targetOut.x=coords(1);
handles.targets(l).targetOut.y=coords(2);
handles.targets(l).targetOut.z=coords(3);


if verLessThan('matlab','8.4.0')
    % execute code for R2014a or earlier
else
    % execute code for R2014b or later
   coords=round(coords,3,'significant');
end
set(handles.TargetOutXedit,'String',num2str(coords(1)));
set(handles.TargetOutYedit,'String',num2str(coords(2)));
set(handles.TargetOutZedit,'String',num2str(coords(3)));

handles=updateTarget(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;
handles=updateTAC(handles);
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%%%%%%%%% change target locations editing coordinates  %%%%%%%%%%%%%%%
function TargetInXedit_Callback(hObject, eventdata, handles)
% hObject    handle to TargetInXedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TargetInXedit as text
%        str2double(get(hObject,'String')) returns contents of TargetInXedit as a double

l=str2double(get(handles.TargetArraytext,'String'));
handles.targets(l).targetIn.x=str2double(get(handles.TargetInXedit,'String'));
handles=updateTarget(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateTAC(handles);
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

function TargetInYedit_Callback(hObject, eventdata, handles)
% hObject    handle to TargetInYedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TargetInYedit as text
%        str2double(get(hObject,'String')) returns contents of TargetInYedit as a double
l=str2double(get(handles.TargetArraytext,'String'));
handles.targets(l).targetIn.y=str2double(get(handles.TargetInYedit,'String'));
handles=updateTarget(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateTAC(handles);
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

function TargetInZedit_Callback(hObject, eventdata, handles)
% hObject    handle to TargetInZedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TargetInZedit as text
%        str2double(get(hObject,'String')) returns contents of TargetInZedit as a double
l=str2double(get(handles.TargetArraytext,'String'));
handles.targets(l).targetIn.z=str2double(get(handles.TargetInZedit,'String'));

%handles.targets(l).frameDown = handles.targets(l).coordinates(handles.targets(l).n,3) < 0; % handles.targets(l).targetIn.z < 0;
handles=updateTarget(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateTAC(handles);
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

function TargetOutXedit_Callback(hObject, eventdata, handles)
% hObject    handle to TargetOutXedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TargetOutXedit as text
%        str2double(get(hObject,'String')) returns contents of TargetOutXedit as a double
l=str2double(get(handles.TargetArraytext,'String'));
handles.targets(l).targetOut.x=str2double(get(handles.TargetOutXedit,'String'));
handles=updateTarget(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateTAC(handles);
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

function TargetOutYedit_Callback(hObject, eventdata, handles)
% hObject    handle to TargetOutYedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TargetOutYedit as text
%        str2double(get(hObject,'String')) returns contents of TargetOutYedit as a double
l=str2double(get(handles.TargetArraytext,'String'));
handles.targets(l).targetOut.y=str2double(get(handles.TargetOutYedit,'String'));
handles=updateTarget(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateTAC(handles);
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

function TargetOutZedit_Callback(hObject, eventdata, handles)
% hObject    handle to TargetOutZedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TargetOutZedit as text
%        str2double(get(hObject,'String')) returns contents of TargetOutZedit as a double
l=str2double(get(handles.TargetArraytext,'String'));
handles.targets(l).targetOut.z=str2double(get(handles.TargetOutZedit,'String'));
handles=updateTarget(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateTAC(handles);
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%% change targetOut location editing angles Azimuth or Elevation %%%%%%
function ElevacionTargetedit_Callback(hObject, eventdata, handles)
% hObject    handle to ElevacionTargetedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ElevacionTargetedit as text
%        str2double(get(hObject,'String')) returns contents of ElevacionTargetedit as a double
handles=angleChange(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateTAC(handles);
handles=updateElectrodes3D(handles);

% Update handles structure
guidata(hObject, handles);

function AzimuthTargetedit_Callback(hObject, eventdata, handles)
% hObject    handle to AzimuthTargetedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AzimuthTargetedit as text
%        str2double(get(hObject,'String')) returns contents of AzimuthTargetedit as a double
handles=angleChange(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateTAC(handles);
handles=updateElectrodes3D(handles);
% Update handles structure
guidata(hObject, handles);

%%%%%%             change targetOut location                         %%%%%%
%%%%%%              editing angles Azimuth or Elevation              %%%%%%
function handles=angleChange(handles)

l=str2double(get(handles.TargetArraytext,'String'));
n=handles.targets(l).n;
fs_dist=handles.targets(l).FirstSecond;
sl_dist=handles.targets(l).SecondLast;

%punto Target IN
xi(1)= handles.targets(l).targetIn.x;
xi(2)= handles.targets(l).targetIn.y;
xi(3)= handles.targets(l).targetIn.z;

az=str2double( get(handles.AzimuthTargetedit,'String') );
el=str2double( get(handles.ElevacionTargetedit,'String') );

% if an error with conversion to double occurs, do nothing
if isnan(az)
    return;
end

if isnan(el)
    return;
end
%convert degres to radians
az=az*pi/180;
el=el*pi/180;

[dx, dy, dz] =sph2cart(az,el,1); %radius=1
delta=[dx dy dz];

dist=fs_dist+(n-2)*sl_dist; %length from first to last

xo=xi+dist*delta;

handles.targets(l).targetOut.x=xo(1);
handles.targets(l).targetOut.y=xo(2);
handles.targets(l).targetOut.z=xo(3);


if verLessThan('matlab','8.4.0')
    % execute code for R2014a or earlier
else
    % execute code for R2014b or later
    xo=round(xo,3,'significant');
end

%punto taget Out
set(handles.TargetOutXedit,'String',num2str(xo(1)));
set(handles.TargetOutYedit,'String',num2str(xo(2)));
set(handles.TargetOutZedit,'String',num2str(xo(3)));

handles=updateTarget(handles);

%--------------------------------------------------------------------
%%%%%%%%% update targets structure after changing parameters      %%%%%%%%%
function handles=updateTarget(handles)
%%%%%%%%% update targets structure after changing parameters      %%%%%%%%%
%%%%%%%%% targetIn, TargetOut, n, fs_dist, sl_dist
%%%%%%%%% Changes: delta, coordinates, az, el, distances, alpha, beta %%%%%

% read defined values
l=str2double(get(handles.TargetArraytext,'String'));

n=handles.targets(l).n;

fs_dist=handles.targets(l).FirstSecond;

sl_dist=handles.targets(l).SecondLast;

%punto Target IN
xi(1)=handles.targets(l).targetIn.x;
xi(2)=handles.targets(l).targetIn.y;
xi(3)=handles.targets(l).targetIn.z;

%punto taget Out
xo(1)=handles.targets(l).targetOut.x;
xo(2)=handles.targets(l).targetOut.y;
xo(3)=handles.targets(l).targetOut.z;

dx=handles.targets(l).targetOut.x - handles.targets(l).targetIn.x;
dy=handles.targets(l).targetOut.y - handles.targets(l).targetIn.y;
dz=handles.targets(l).targetOut.z - handles.targets(l).targetIn.z;

% compute az, el, coordinates, distances
delta=[dx dy dz] / norm([dx dy dz]);
handles.targets(l).delta=delta;
[az,el,~] =cart2sph(delta(1), delta(2), delta(3));
%convert from radians to degres
az=az*180/pi;
el=el*180/pi;

handles.targets(l).azimut=az;
handles.targets(l).elevation=el;

if verLessThan('matlab','8.4.0')
    % execute code for R2014a or earlier
else
    % execute code for R2014b or later
    az=round(az,3,'significant');
    el=round(el,3,'significant');
end

if abs(az)<0.01
    az=0;
end
if abs(el)<0.01
    el=0;
end


set(handles.AzimuthTargetedit,'String',num2str(az))
set(handles.ElevacionTargetedit,'String',num2str(el))

distances= [0 fs_dist fs_dist + ((1:(n-2))*sl_dist)];
for i=1:n
    coordinates(i,:)= xi+ distances(i) * delta;
end
handles.targets(l).distances=distances;
handles.targets(l).coordinates=coordinates;

%anatomical labels
lookArround=1; radio=3;

if strcmp (get(handles.MNILabelstogglebutton,'state'),'on')
    handles.targets(l).aLabels=anatomicLabel(coordinates,handles.MNI_S_matrix,handles.MNIlabels,handles.MNIprob);
elseif ~isempty(handles.wmparc)
    handles.targets(l).aLabels=anatomicLabelFS(coordinates, [],lookArround,handles.wmparc.img,handles.wmparcS,radio);
end

handles=estimateAnglesFrame(handles);


%--------------------------------------------------------------------
%%%%%%%%%%      calculate frame  angles alpha and beta      %%%%%%%%%%%%%%%
function handles=estimateAnglesFrame(handles)
% estimate angles frame based on coordinates
% ALL angles in DEGREES

% beta   0 - 360 degres
% alpha  0 - 90

l=str2double(get(handles.TargetArraytext,'String'));

delta=handles.targets(l).delta;
%
% % backward compatibility ---
% if isfield (handles.targets(l),'frameDown')
%     if isempty (handles.targets(l).frameDown)
%         handles.targets(l).framePosition='Anterior';
%         framePosition='Anterior';
%     else
%         framePosition=handles.targets(l).framePosition;
%     end
% else
%     handles.targets(l).framePosition='Anterior';
%     framePosition='Anterior';
% end
% % ----
handles.targets(l).frameDown = handles.targets(l).coordinates(handles.targets(l).n,3) < 0; 
framePosition=handles.targets(l).framePosition;
frameDown=handles.targets(l).frameDown;

[alpha,beta]=delta2alpha_beta(delta(1),delta(2),delta(3),framePosition,frameDown);

handles.targets(l).beta=beta;
handles.targets(l).alpha=alpha;

if verLessThan('matlab','8.4.0')
    % execute code for R2014a or earlier
else
    % execute code for R2014b or later
    alpha=round(alpha,3,'significant');
    beta=round(beta,3,'significant');
end

if abs(alpha)<0.01
    alpha=0;
end
if abs(beta)<0.01
    beta=0;
end
set(handles.AlphaAngleEdit,'string', num2str(alpha));
set(handles.BetaAngleEdit,'string', num2str(beta));

%--------------------------------------------------------------------
%%%%%%%%%%          change in frame position                %%%%%%%%%%%%%%%
function Framebuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Framebuttongroup
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

l=str2double(get(handles.TargetArraytext,'String'));

%left frame
if get(handles.LeftFrameradiobutton,'value')
    handles.targets(l).framePosition='Left';
    %right frame
elseif get(handles.RightFrameradiobutton,'value')
    handles.targets(l).framePosition='Right';
    %anterior frame
elseif get(handles.AnteriorFrameradiobutton,'value')
    handles.targets(l).framePosition='Anterior';
    %posterior frame
elseif get(handles.PosteriorFrameradiobutton,'value')
    handles.targets(l).framePosition='Posterior';
end
handles=estimateAnglesFrame( handles);

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%% change target locations editing Alpha and Beta frame angles  %%%%%%
function AlphaAngleEdit_Callback(hObject, eventdata, handles)
% hObject    handle to AlphaAngleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of AlphaAngleEdit as text
%        str2double(get(hObject,'String')) returns contents of AlphaAngleEdit as a double
handles=AlphaBetaChange(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateTAC(handles);
handles=updateElectrodes3D(handles);
% Update handles structure
guidata(hObject, handles);

function BetaAngleEdit_Callback(hObject, eventdata, handles)
% hObject    handle to BetaAngleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of BetaAngleEdit as text
%        str2double(get(hObject,'String')) returns contents of BetaAngleEdit as a double
handles=AlphaBetaChange(handles);
handles.updatePlots.views2D=[1 1 1];
handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateTAC(handles);
handles=updateElectrodes3D(handles);
% Update handles structure
guidata(hObject, handles);

function handles=AlphaBetaChange(handles)
% estimates xo based on changes on alpha or beta anlges
% saves alpha and beta in targets structure

l=str2double(get(handles.TargetArraytext,'String'));

n=handles.targets(l).n;
fs_dist=handles.targets(l).FirstSecond;
sl_dist=handles.targets(l).SecondLast;

%punto Target IN
xi(1)= handles.targets(l).targetIn.x;
xi(2)= handles.targets(l).targetIn.y;
xi(3)= handles.targets(l).targetIn.z;

alpha = str2double( get(handles.AlphaAngleEdit,'String'));
beta = str2double( get(handles.BetaAngleEdit,'String'));

handles.targets(l).alpha=alpha;
handles.targets(l).alpha=beta;

framePosition=handles.targets(l).framePosition;
frameDown=handles.targets(l).frameDown;

[dx,dy,dz]=alpha_beta2delta(alpha,beta,framePosition,frameDown);

delta=[dx dy dz];

dist=fs_dist+(n-2)*sl_dist; %length from first to last

% estimate xo
xo=xi+dist*delta;

handles.targets(l).targetOut.x=xo(1);
handles.targets(l).targetOut.y=xo(2);
handles.targets(l).targetOut.z=xo(3);
if verLessThan('matlab','8.4.0')
    % execute code for R2014a or earlier
else
    xo=round(xo,3,'significant');
end

%punto taget Out
set(handles.TargetOutXedit,'String',num2str(xo(1)));
set(handles.TargetOutYedit,'String',num2str(xo(2)));
set(handles.TargetOutZedit,'String',num2str(xo(3)));

handles=updateTarget(handles); %this will call to estimateAnglesFrame that should estimate the same angles

%--------------------------------------------------------------------
%%%%%%%%%%%%%%%        Navigate target arrays              %%%%%%%%%%%%%%%
% --- Executes on button press in PrevTargetpushbutton.
function PrevTargetpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to PrevTargetpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
l=str2double(get(handles.TargetArraytext,'String'));
L=length(handles.targets);

if l>1
    l=l-1;
    
    set(handles.TargetArraytext,'String',num2str(l));
    UpdateTargetEditBox(hObject, eventdata, handles);
    handles = guidata(hObject); %update handles structure
    
    d1=handles.targets(l).coordinates(1,1);
    d2=handles.targets(l).coordinates(1,2);
    d3=handles.targets(l).coordinates(1,3);
    
    D=AnatSpace2Mesh([d1 d2 d3],handles.S2);
    set(handles.sliderX,'Value',D(1));
    set(handles.sliderY,'Value',D(2));
    set(handles.sliderZ,'Value',D(3));
    
    handles.updatePlots.targets=1;
    handles.updatePlots.targetLines=1;
    handles=updateTAC(handles);
    handles=updateElectrodes3D(handles);
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in NextTargetpushbutton.
function NextTargetpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to NextTargetpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
l=str2double(get(handles.TargetArraytext,'String'));
L=length(handles.targets);

if l<L
    l=l+1;
    
    set(handles.TargetArraytext,'String',num2str(l));
    UpdateTargetEditBox(hObject, eventdata, handles);
    handles = guidata(hObject); %update handles structure
    
    d1=handles.targets(l).coordinates(1,1);
    d2=handles.targets(l).coordinates(1,2);
    d3=handles.targets(l).coordinates(1,3);
    D=AnatSpace2Mesh([d1 d2 d3],handles.S2);
    set(handles.sliderX,'Value',D(1));
    set(handles.sliderY,'Value',D(2));
    set(handles.sliderZ,'Value',D(3));
    
    handles.updatePlots.targets=1;
    handles.updatePlots.targetLines=1;
    handles=updateTAC(handles);
    handles=updateElectrodes3D(handles);
    
end

% Update handles structure
guidata(hObject, handles);

% update target edit box to the values in target l=TargetArraytext
function UpdateTargetEditBox(hObject, eventdata, handles)

l=str2num(get(handles.TargetArraytext,'String'));
set(handles.TargetNameedit,'String',handles.targets(l).name);
set(handles.nTargetEdit,'String',num2str(handles.targets(l).n));
set(handles.FirstSecondTargetedit,'String',num2str(handles.targets(l).FirstSecond));
set(handles.SecondLastTargetEdit,'String',num2str(handles.targets(l).SecondLast));
set(handles.TargetElectext,'String',num2str(1));

%punto Target IN
xi(1)=handles.targets(l).targetIn.x;
xi(2)=handles.targets(l).targetIn.y;
xi(3)=handles.targets(l).targetIn.z;

if verLessThan('matlab','8.4.0')
    % execute code for R2014a or earlier
else
    xi=round(xi,3,'significant');
end

set(handles.TargetInXedit,'String',num2str(xi(1)));
set(handles.TargetInYedit,'String',num2str(xi(2)));
set(handles.TargetInZedit,'String',num2str(xi(3)));


%punto taget OUT
xo(1)=handles.targets(l).targetOut.x;
xo(2)=handles.targets(l).targetOut.y;
xo(3)=handles.targets(l).targetOut.z;

if verLessThan('matlab','8.4.0')
    % execute code for R2014a or earlier
else
    xo=round(xo,3,'significant');
end

%punto taget Out
set(handles.TargetOutXedit,'String',num2str(xo(1)));
set(handles.TargetOutYedit,'String',num2str(xo(2)));
set(handles.TargetOutZedit,'String',num2str(xo(3)));


if verLessThan('matlab','8.4.0')
    % execute code for R2014a or earlier 
    az=handles.targets(l).azimut;
    el=handles.targets(l).elevation;
else
    % execute code for R2014b or later
    az=round(handles.targets(l).azimut,4,'significant');
    el=round(handles.targets(l).elevation,4,'significant');
end


% Azimuth
set(handles.AzimuthTargetedit,'String',num2str(az))

% Elevation
set(handles.ElevacionTargetedit,'String',num2str(el))


% backward compatibility ---
if isfield (handles.targets(l),'frameDown')
    if isempty (handles.targets(l).frameDown)
        handles.targets(l).framePosition='Anterior';
        handles.targets(l).frameDown =  handles.targets(l).coordinates(handles.targets(l).n,3) < 0; %handles.targets(l).targetIn.z < 0;
        handles=estimateAnglesFrame(handles); %estimate alpha and beta
    end
else
    handles.targets(l).framePosition='Anterior';
    handles.targets(l).frameDown = handles.targets(l).coordinates(handles.targets(l).n,3) < 0; %handles.targets(l).targetIn.z < 0;
    
    handles=estimateAnglesFrame(handles); %estimate alpha and beta
    
end
% ----


%left frame
if strcmp(handles.targets(l).framePosition,'Left');
    set(handles.LeftFrameradiobutton,'value',1)
    %right frame
elseif  strcmp(handles.targets(l).framePosition,'Right');
    set(handles.RightFrameradiobutton,'value',1)
    %anterior frame
elseif  strcmp(handles.targets(l).framePosition,'Anterior');
    set(handles.AnteriorFrameradiobutton,'value',1)
    %posterior frame
elseif strcmp(handles.targets(l).framePosition,'Posterior');
    set(handles.PosteriorFrameradiobutton,'value',1)
end



beta=handles.targets(l).beta;
alpha=handles.targets(l).alpha;
if verLessThan('matlab','8.4.0')
    % execute code for R2014a or earlier
else
    % execute code for R2014b or later
    alpha=round(alpha,3,'significant');
    beta=round(beta,3,'significant');
end

set(handles.AlphaAngleEdit,'string', num2str(alpha));
set(handles.BetaAngleEdit,'string', num2str(beta));

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in TargetEmaspushbutton.
function TargetEmaspushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to TargetEmaspushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
l=str2double(get(handles.TargetElectext,'String'))+1;
a=str2double(get(handles.TargetArraytext,'String'));

if a~=0
    if l <= handles.targets(a).n
        set(handles.TargetElectext,'String',num2str(l));
        
        d1=handles.targets(a).coordinates(l,1);
        d2=handles.targets(a).coordinates(l,2);
        d3=handles.targets(a).coordinates(l,3);
        
        D=AnatSpace2Mesh([d1 d2 d3],handles.S2);
        set(handles.sliderX,'Value',D(1));
        set(handles.sliderY,'Value',D(2));
        set(handles.sliderZ,'Value',D(3));
        
        handles.updatePlots.targets=1;
        handles.updatePlots.targetLines=1;
        handles=updateElectrodes3D(handles);
        handles=updateTAC(handles);
        
    end
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in TargetEmenospushbutton.
function TargetEmenospushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to TargetEmenospushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
l=str2double(get(handles.TargetElectext,'String'))-1;
a=str2double(get(handles.TargetArraytext,'String'));

if a~=0
    if l >= 1
        set(handles.TargetElectext,'String',num2str(l));
        
        d1=handles.targets(a).coordinates(l,1);
        d2=handles.targets(a).coordinates(l,2);
        d3=handles.targets(a).coordinates(l,3);
        
        D=AnatSpace2Mesh([d1 d2 d3],handles.S2);
        set(handles.sliderX,'Value',D(1));
        set(handles.sliderY,'Value',D(2));
        set(handles.sliderZ,'Value',D(3));

        handles.updatePlots.targets=1;
        handles.updatePlots.targetLines=1;
        
        handles=updateElectrodes3D(handles);
        handles=updateTAC(handles);
        
    end
end

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------
%%%%%%%%%%%%%%%     Select what planning electrodes to plot %%%%%%%%%%%%%%%
%                   in 3D and 2D views
% --- Executes when selected object is changed in plotTargetsOneAllUipanel.
function plotTargetsOneAllUipanel_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in plotTargetsOneAllUipanel
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.updatePlots.views2D=[1 1 1]; %Force update all slices

handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles=updateElectrodes3D(handles);
handles=updateTAC(handles);

% Update handles structure
guidata(hObject, handles);
