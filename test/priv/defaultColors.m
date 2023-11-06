function colors=defaultColors(colors)
% define here the default colors and markers for the 2D and 3D plots
% A Blenkmann 2017

% 3D electrodes
colors.electrodesGrid3D=[1 0 0];
colors.electrodesDepth3D=[0 0 1];
colors.electrodesMarker3D='o';
colors.electrodesSize3D=36;
colors.electrodesSelected3D=[0 0 0];

% 3D planning
colors.target3D=[0 1 0];
colors.targetMarker3D='o';
colors.targetSize3D=36;
colors.targetSelected3D=[0 0 0];

% 2D electrodes
colors.electrodesGrid2D=[1 0 0];
colors.electrodesDepth2D=[0 0 1];
colors.electrodesMarker2D='+';

% 2D planning
colors.target2D=[0 1 0];
colors.targetMarker2D='x';

% 3D labels
colors.labelsColor=[0 0 1];
colors.labelsFontSize=8;

% 3D electrode conectors
colors.cylAlpha=1;%.5;
colors.cylAlphaTaget=0.5;
colors.cylColorGrid=[0.5 .8 0.5];
colors.cylColorDepth=[0.8 0.1 0.1];
colors.cylColorTargets=[0.1 0.1 0.8];

% crosshair colors 
colors.x=[1 0 0]; %r
colors.y=[0 1 0]; %g
colors.z=[0 0 1]; %b

% atlas and 2D views
colors.colorT1=[1 1 1];    % gray scale for T1
colors.colorCT=[1 1 1];    % gray scale for CT
colors.edgeCTchannels=[2 3]; % green and blue channel for edge CT 
colors.percentileThres= 95; % percentile for binarizing CT
colors.alphaAtlas=.4;      % transparency for parcelation Atlas

