function handles=defaultGuiVariables(handles)


%MNI brain
load MNImesh.mat;
handles.f_MNI=f_MNI;
handles.v_MNI=v_MNI;

%load MNI convex hull
load MNI_hull_LR.mat;
handles.f_MNI_SCE=f_hull;
handles.v_MNI_SCE=v_hull;


% HO atlas
load ('HOatlas_cort-subCort_lateralized.mat');
handles.MNIlabels=labels;
handles.MNIprob = prob;
handles.MNI_S_matrix=S;

colormap gray
handles.layout=0; %default layaut

handles.buttonDown=0;

% Plot update options. 
% If update = 0, no changes to current plot

handles.updatePlots.views2D=[1 1 1]; % Force update all slices
handles.updatePlots.resetTAC=1;      % reset 2D views axes
handles.updatePlots.GS=1;
handles.updatePlots.electrodes=1;
handles.updatePlots.labels=1;
handles.updatePlots.elecLines=1;

handles.updatePlots.targets=1;
handles.updatePlots.targetLines=1;

handles.updatePlots.surfaces=1;

handles.updatePlots.cla=1;

% plot 3D handles
handles.plot3Dhandles.GS=[];
handles.plot3Dhandles.electrodes=[];
handles.plot3Dhandles.labels=[];
handles.plot3Dhandles.elecLines=[];
handles.plot3Dhandles.targets=[];
handles.plot3Dhandles.targetLines=[];
handles.plot3Dhandles.surfaces=[];
handles.plot3Dhandles.hcam=[];

handles.viewPoint=[-135,25];


handles.PathName=pwd;

handles.color=1;

% we assume starting in MNI
handles.currentSpace='MNI'; % options are 'Native' 'MNI' 
set(handles.MNILabelstogglebutton,'State','On'); % this will call to labels2NativeSpace and updateElectrodes3D

% cursor
handles.cursor=[0 0 0];

handles.rotate3d=rotate3d(handles.figure1);
setAllowAxesRotate(handles.rotate3d,handles.axesX,false); 
setAllowAxesRotate(handles.rotate3d,handles.axesY,false); 
setAllowAxesRotate(handles.rotate3d,handles.axesZ,false); 
%handles.rotate3d.ActionPreCallback=@Rotate3dActionPreCallback; %how to
%send handles structure as a parameter in this function??

handles.hlink = linkprop([handles.axes1,handles.axes2],{'CameraPosition','CameraUpVector'});
% add select lock/unlock checkbox on axes1 or 2 

% crosshair handles 

axes(handles.axes2);
handles.cross.x3D=line([0 0],[0 0],[0 0],'Color',handles.colors.x);
handles.cross.y3D=line([0 0],[0 0],[0 0],'Color',handles.colors.y);
handles.cross.z3D=line([0 0],[0 0],[0 0],'Color',handles.colors.z);
view(handles.axes2,-135,25);

axes(handles.axesX);
handles.cross.xh1=line([0 0],[0 0],'Color',handles.colors.y);
handles.cross.xh2=line([0 0],[0 0],'Color',handles.colors.y);
handles.cross.xv1=line([0 0],[0 0],'Color',handles.colors.z);
handles.cross.xv2=line([0 0],[0 0],'Color',handles.colors.z);

axes(handles.axesY);
handles.cross.yh1=line([0 0],[0 0],'Color',handles.colors.x);
handles.cross.yh2=line([0 0],[0 0],'Color',handles.colors.x);
handles.cross.yv1=line([0 0],[0 0],'Color',handles.colors.z);
handles.cross.yv2=line([0 0],[0 0],'Color',handles.colors.z);

axes(handles.axesZ);
handles.cross.zh1=line([0 0],[0 0],'Color',handles.colors.x);
handles.cross.zh2=line([0 0],[0 0],'Color',handles.colors.x);
handles.cross.zv1=line([0 0],[0 0],'Color',handles.colors.y);
handles.cross.zv2=line([0 0],[0 0],'Color',handles.colors.y);

axes(handles.axes1);
handles.cross.x3DThres=line([0 0],[0 0],[0 0],'Color',handles.colors.x);
handles.cross.y3DThres=line([0 0],[0 0],[0 0],'Color',handles.colors.y);
handles.cross.z3DThres=line([0 0],[0 0],[0 0],'Color',handles.colors.z);


% scatter points
handles.sct=[];

% max value
handles.maxValue=[];