function options=default_ielectrodes_options(options)
% default options for iElectrodes processing

if nargin<1
    options=[];
end

%% visualization

% Spatial resolution for images.
if ~isfield(options, 'image_voxdim')
    options.image_voxdim=[0.5 0.5 0.5]; %Force spatial resolution for images.
%     options.image_voxdim=[NaN NaN NaN]; %use original images spatial resolution for the MR. CT will be resliced to MR resolution 
end

% Number of elements in the scatter 3D plot (thresholded view)
if ~isfield(options, 'scatter3D_elem_limit')
    options.scatter3D_elem_limit=50000;
end

% Number of elements to reduce mesh surfaces (pial, SCE)
if ~isfield(options, 'reduce_surfaces_elements')
    options.reduce_surfaces_elements = 15000;      
end

%% clustering

% Projection of elec coordinates used for indexing 
if ~isfield(options, 'indexing_projection_method')
    options.indexing_projection_method='sphereFit'; %'PCA';
end

% Method for finding corners for indexing
if ~isfield(options, 'find_corners_grid_method')
    options.find_corners_grid_method = 'convexhull'; %'distance';
end

%% Grid Fit localization

% options are different for Grids, Strips, and depth electrodes


% GENERAL

optionsGridFit_general.find_corners_grid_method = 'iterative_convexhull';
optionsGridFit_general.indexing_projection_method = 'sphereFit';
optionsGridFit_general.DCT = 0;
optionsGridFit_general.minDef1.UseParallel=false;
optionsGridFit_general.minDef2.UseParallel=false;
optionsGridFit_general.minDef1.recalcD0=0;      % recalculate distance matrix in each iteration
optionsGridFit_general.minDef2.recalcD0=0;      % recalculate distance matrix in each iteration

optionsGridFit_general.minDef1.MaxFunEvals=1e6;
optionsGridFit_general.minDef2.MaxFunEvals=1e7;
optionsGridFit_general.minDef1.TolX=1e-2;       % Working tolerance is M1 * TolX 
optionsGridFit_general.minDef2.TolX=1e-6;      % Working tolerance is M1 * TolX 
optionsGridFit_general.minDef2.MaxIterations=1e4;

% copy general into individual options
options.gridFit_grids = optionsGridFit_general;
options.gridFit_strips = optionsGridFit_general;
options.gridFit_depth = optionsGridFit_general;


% GRIDS
options.gridFit_grids.type  = 'grid';                 % '2D' or '3D' grid modelling
options.gridFit_grids.minDef1.model = '2D';           % '2D' or '3D' grid modelling
options.gridFit_grids.minDef2.model = '3D';           % '2D' or '3D' grid modelling
options.gridFit_grids.constrain_type = 'volume_distance';    % 'none' / 'volume' / 'distance' /'volume_distance'
options.gridFit_grids.thickness = 0.5;        % 0.5 mm grid thickness


% 3D model parameters
% first minimization options
options.gridFit_grids.minDef1.sigmaRatio=1;    % M1 * ratio : used for gaussian correlation
options.gridFit_grids.minDef1.tolCon = 1;      % nonlinear function tolerance constrain (distance to fit surface)
options.gridFit_grids.minDef1.Kt=1e-6;         % translation
options.gridFit_grids.minDef1.Kc=1e5;          % coregistration
options.gridFit_grids.minDef1.Kd=1e5;          % deformation: the smaller this number, the more flexible the grid
options.gridFit_grids.minDef1.Kn=1;            % nail. Difficult to fullfill given surface constrain
options.gridFit_grids.minDef1.Kd_normal = 1.0; % (scalar) ratio of normal (1st neig) deformation for 2D model
options.gridFit_grids.minDef1.Kd_shear = 1.0;  % 0.5 (scalar) ratio of shear (diagonal neig) deformation for 2D model
options.gridFit_grids.minDef1.Kd_bend  = 1.0;  % 0.1 (scalar) ratio of bending (2nd neig) deformation for 2D model


% Second minimization options (no surface constrain)
options.gridFit_grids.minDef2.sigmaRatio=1/4;  % M1 * ratio : used for gaussian correlation
options.gridFit_grids.minDef2.tolCon = 0.01;   % nonlinear function tolerance constrain (volume constrain)
options.gridFit_grids.minDef2.Kt=1e-2;         % translation
% Kc obtained from optimal Kc
options.gridFit_grids.minDef2.Kd=1e5;          % deformation: the smaller this number, the more flexible the grid
options.gridFit_grids.minDef2.Kn=0;            % nail is a constrain in the second fit


% STRIPS
options.gridFit_strips.type = 'strip';
options.gridFit_strips.minDef1.model = '2D';           % '2D' or '3D' grid modelling
options.gridFit_strips.minDef2.model = '3D';           % '2D' or '3D' grid modelling
options.gridFit_strips.constrain_type = 'volume_distance';    % 'none' / 'volume' / 'distance' /'volume_distance'
options.gridFit_strips.thickness = 0.5;        % 0.5 mm grid thickness

% 3D model parameters
% first minimization options
options.gridFit_strips.minDef1.sigmaRatio=1;    % M1 * ratio : used for gaussian correlation
options.gridFit_strips.minDef1.tolCon = 1;      % nonlinear function tolerance constrain (distance to fit surface)
options.gridFit_strips.minDef1.Kt=1e-4;         % translation
options.gridFit_strips.minDef1.Kc=1e3;          % coregistration
options.gridFit_strips.minDef1.Kd=1e2;          % deformation: the smaller this number, the more flexible the grid
options.gridFit_strips.minDef1.Kn=1;            % nail
options.gridFit_strips.minDef1.Kd_normal = 1.0; % (scalar) ratio of normal (1st neig) deformation for 2D model
options.gridFit_strips.minDef1.Kd_shear = 1.0;  % 0.5 (scalar) ratio of shear (diagonal neig) deformation for 2D model
options.gridFit_strips.minDef1.Kd_bend  = 1.0;  % 0.1 (scalar) ratio of bending (2nd neig) deformation for 2D model

% Second minimization options (no surface constrain)
options.gridFit_strips.minDef2.sigmaRatio=1/4;  % M1 * ratio : used for gaussian correlation
options.gridFit_strips.minDef2.tolCon = 0.01;   % nonlinear function tolerance constrain (volume constrain)
options.gridFit_strips.minDef2.Kt=1e-2;         % translation
% Kc obtained from optimal Kc
options.gridFit_strips.minDef2.Kd=1e4;           % deformation: the smaller this number, the more flexible the strip. This number is smaller for strips than for grids
options.gridFit_strips.minDef2.Kn=0;            % nail is a constrain in the second fit


%DEPTH
options.gridFit_depth.type = 'depth';
options.gridFit_depth.minDef1.model = '2D';           % '2D' modelling for depth only in 1st minimization
options.gridFit_depth.minDef2.model = '1D_fix';       % '2D' for flexible modelling, or 1D_fix for non deformable depth
options.gridFit_depth.thickness = [];                 % 0.5 mm grid thickness
options.gridFit_depth.constrain_type = 'distance';    % 'none' / 'distance' for depth

% 2D model parameters
% first minimization options
options.gridFit_depth.minDef1.sigmaRatio=1;    % M1 * ratio : used for gaussian correlation
options.gridFit_depth.minDef1.tolCon = 1;      % nonlinear function tolerance constrain (distance to fit surface)
options.gridFit_depth.minDef1.Kt=1e-4;         % translation
options.gridFit_depth.minDef1.Kd=1e2;          % deformation: the smaller this number, the more flexible the grid
options.gridFit_depth.minDef1.Kc=1e3;          % coregistration
options.gridFit_depth.minDef1.Kn=1;            % nail. Difficult to fullfill given surface constrain
options.gridFit_depth.minDef1.Kd_normal = 1.0; % (scalar) ratio of normal (1st neig) deformation for 2D model
options.gridFit_depth.minDef1.Kd_shear = 1.0;  %(scalar) ratio of shear (diagonal neig) deformation for 2D model
options.gridFit_depth.minDef1.Kd_bend  = 1.0;  % (scalar) ratio of bending (2nd neig) deformation for 2D model

% Second minimization options (no surface constrain)
options.gridFit_depth.minDef2.sigmaRatio=1/4;   % M1 * ratio : used for gaussian correlation
options.gridFit_depth.minDef2.tolCon = 1e-3;     %0.01; % nonlinear function tolerance constrain (distance = tolCon*M1).
options.gridFit_depth.minDef2.Kt=1e-2;          % translation
options.gridFit_depth.minDef2.Kd=1e4; %1e4;     % deformation: the smaller this number, the more flexible the depth. If image is too noisy, make non-deformable electrode: increase to 1e100, and TolX to 1e-12
% Kc obtained from optimal Kc
options.gridFit_depth.minDef2.Kn=0;            % nail is a constrain
options.gridFit_depth.minDef2.Kd_normal = 1.0; % (scalar) ratio of normal (1st neig) deformation for 2D model
options.gridFit_depth.minDef2.Kd_shear = 1.0;  % 0.5 (scalar) ratio of shear (diagonal neig) deformation for 2D model
options.gridFit_depth.minDef2.Kd_bend  = 1.0;  % 0.1 (scalar) ratio of bending (2nd neig) deformation for 2D model


%% electrode projection to brain surface (AKA Smooth Cortical Envelope, or brain-shift compensation)


if ~isfield(options, 'buildSCEradius') % radius to enclose pial surfaces. Points at larger distance are excluded to increase speed.
    options.buildSCEradius = 50;
end

if ~isfield(options, 'SCE_projection_method')
    options.SCE_projection_method='CEPA';    % 'CEPA' (Blenkmann et al 2023) (Default) / 'closestPoint' 
                                             % / 'springs' (Dykstra et al 2012 NeuroImage)
                                             % / 'normal' (Hermes et al 2010)
                                             % / 'normal-SCE' (Kubaeck & Schalk Neuroinformatics 2015)/  
                                             % / 'realistic' use a 3Dmodel (unpublished)
end

if ~isfield(options, 'SCE_springs_projection')
    options.SCE_springs_projection.K=1000; %  used fpr 'springs' method.  Energy ratio f = t + K d
    options.SCE_springs_projection.TolCon=0.1;                  % Constrain Tolerance 
    options.SCE_springs_projection.StepTolerance=1e-6;          %     
    options.SCE_springs_projection.meshReduceL=20;              % reduce mesh to the closest L radium   
    options.SCE_springs_projection.RefineMesh=1;
    options.SCE_springs_projection.constrain='distance';
    options.SCE_springs_projection.UseParallel=false;

end

if ~isfield(options, 'SCE_normal_projection')
    options.SCE_normal_projection.meshReduceL=20;              % reduce mesh to the closest L radium              

end

if ~isfield(options, 'SCE_realistic_projection')
    options.SCE_realistic_projection.K=1e10;                % -> very rigid
    options.SCE_realistic_projection.thickness = 0.5;       % grid thickness
    options.SCE_realistic_projection.TolCon=0.1;   
    options.SCE_realistic_projection.StepTolerance = 1e-6;  %     
    options.SCE_realistic_projection.RefineMesh = 1;        % Refine Mesh before projection 1/0 
    options.SCE_realistic_projection.meshReduceL = 20;      % reduce mesh to the closest L radium 
    options.SCE_realistic_projection.UseParallel=false;
end


% Minimization options for 'CEPA' method
if ~isfield(options, 'SCE_CEPA_projection')
    options.SCE_CEPA_projection.Kt=1;       % translation
    options.SCE_CEPA_projection.Kd=1e2;        % springs deformation
    options.SCE_CEPA_projection.Ka=1e2;        % anchor deformation
    options.SCE_CEPA_projection.Ks=1e2;        % smoothness
    
    options.SCE_CEPA_projection.Kd_normal = 1.0; % (scalar) ratio of normal (1st neig) deformation
    options.SCE_CEPA_projection.Kd_shear = 0.5;  % (scalar) ratio of shear (diagonal neig) deformation
    options.SCE_CEPA_projection.Kd_bend  = 0.1;  % (scalar) ratio of bending (2nd neig) deformation
    options.SCE_CEPA_projection.TolCon = 0.1;  
    options.SCE_CEPA_projection.StepTolerance=1e-6;           %     
    options.SCE_CEPA_projection.meshReduceL=20;              % reduce mesh to the closest L radium                  
    options.SCE_CEPA_projection.RefineMesh=1;
    options.SCE_CEPA_projection.UseParallel=false;
end


% Minimization options for 'normal-SCE' method

if ~isfield(options, 'SCE_normalSCE_projection')
     options.SCE_normalSCE_projection.meshReduceL=20;
end

% Minimization options for 'normal' method
if ~isfield(options, 'SCE_normal_projection')
     options.SCE_normal_projection.meshReduceL=20;
end  
       

% options for planning projection. Method is always springs.  No
% deformation are expected
if ~isfield(options, 'SCE_springs_projection_planning')
    options.SCE_springs_projection_planning.K=1000; %  used fpr 'springs' method.  Energy ratio f = t + K d
    options.SCE_springs_projection_planning.TolCon=0.1;                  % Constrain Tolerance 
    options.SCE_springs_projection_planning.StepTolerance=1e-6;          %     
    options.SCE_springs_projection_planning.meshReduceL=100;              % reduce mesh to the closest L radium   
    options.SCE_springs_projection_planning.RefineMesh=0;
    options.SCE_springs_projection_planning.constrain='distance';
    options.SCE_springs_projection_planning.UseParallel=false;
end


%% atlas
% to update atlas labels for export/report: after reloading config options, change space to "MNI" and back
% to "Native" using toolbar button

if ~isfield(options, 'atlasLabelingRadio')  
    options.atlasLabelingRadio = 2; % number of voxels to look arround to define the labeling of electrodes      
end

if ~isfield(options, 'atlasLabelingMode')
    options.atlasLabelingMode = 'prob'; % % look arround mode: 'mode' most probable (default)/ 'prob'  probabilities 
 
end

if ~isfield(options, 'atlasLabelingMinProb')
    options.atlasLabelingMinProb = .2; % % minimum probability to consider in 'prob' 

end

%% layout

if ~isfield (options, 'showLocalizeTools') 
    options.showLocalizeTools=true; 
end

if ~isfield (options, 'showPlanTools')
    options.showPlanTools=true;
end

if ~isfield (options, 'atlasLUTFile') % atlas LUT file. If you change the LUT file, load the atlas again.
%    Files should contain - values integer      Nx1     values present in the atlas file 
%                         - labels str cell     Nx1     anatomical labels
%                         - RGB    double       Nx3     color definitions value range 0-255 

    options.atlasLUTFile='FreeSurferColorLUT.mat'; % default FreeSufer LUT file. 
%    options.atlasLUTFile='Yeo2011LUT.mat'; % default FreeSufer LUT file. 
%   options.atlasLUTFile='HMAT_LUT.mat';
end
