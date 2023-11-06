%% Simulate SCE array

%define parameters
rows = 4;
columns = 8;
IED = 5;
seedPoint = [-66,-59,-10]; %any point on the SCE surface works


[pos_electrodesSCE,normalVecElecSCE]=simulateArraySCE(rows,columns,IED,seedPoint);

% Optional: add overlaps
% [addPos,addNormalVec]=simulateOverlaps(pos,normalVec,options)
% pos_electrodesSCE = [pos_electrodesSCE; addPos];
% normalVecElecSCE = [normalVecElecSCE; addNormalVec];

%% Simulate voxels
options=[];
options.M1=5; %IED
options.rows =  rows;
options.cols =  columns;
options.adjMat = makeAdjMat(rows,columns);
options.thresholdValue=-1;
options.type='grid';

[crdSCE,weightSCE,elecNumSCE]=simulateVoxels(pos_electrodesSCE,normalVecElecSCE,options); %crd: coordinates / weight: voxel weights


%% Simulate Noise

options.fractionAdd = 1;
options.fractionLose = 1;
options.sigma = .7; %noise level

options.noiseType = 'intensity_spatial_corr'; 
options.noiseDist = 'normal'; 
options.repetitions = 1;
options.thresholdValue = 0;
options.corr_ratio = .95;
options.image_res = 0.5;
options.pos=pos_electrodesSCE;

        
[crdSCE,weightSCE,elecNumSCE]=addnoise2electrodes(crdSCE,weightSCE,elecNumSCE,options);


%% plot

% load smooth MNI surface 
load([ 'simulation_points_MNI.mat'])

f1=figure;
scatter3(crdSCE(:,1),crdSCE(:,2),crdSCE(:,3),5,weightSCE); hold on; axis image;

mvis(v_hull,f_hull); hold on; caxis([0 1])

camlight;

%% Localize arrays
[elec_loc_kmedoids,elec_loc_kmeans]=localizeArray(crdSCE,weightSCE,rows,columns,pos_electrodesSCE,normalVecElecSCE)

