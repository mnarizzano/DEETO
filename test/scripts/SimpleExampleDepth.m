%% Simulate Depth array
% define parameters
rows = 8;
columns = 1;
IED = 5;
seedPoint = [-48,51,0];
%seedPoint = [-66,-59,-10]; %any point on the SCE surface works
curvature = 1; %no deformation 

[pos_electrodesDepth,normalVecElecDepth]=simulatDepthArray(rows,IED,seedPoint, curvature,0);



%% Simulate voxels
options=[];
options.M1=5; %IED
options.rows =  rows;
options.cols =  columns;
options.adjMat = makeAdjMat(rows,columns);
options.thresholdValue=-1;
options.type = 'depth';

[crdDepth,weightDepth,elecNumDepth]=simulateVoxels(pos_electrodesDepth,normalVecElecDepth,options); %crd: coordinates / weight: voxel weights


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
options.pos=pos_electrodesDepth;
        
[crdDepth,weightDepth,elecNumDepth]=addnoise2electrodes(crdDepth,weightDepth,elecNumDepth,options);


%% plot

% load smooth MNI surface 
load([ 'simulation_points_MNI.mat'])

f1=figure;
%           X               Y           Z          S    Color
scatter3(crdDepth(:,1),crdDepth(:,2),crdDepth(:,3),5,weightDepth); hold on; axis image;

h=mvis(v_hull,f_hull); hold on; caxis([0 1])
h.FaceAlpha = .2
camlight;

%% Localize arrays
%[elec_loc_kmedoids,elec_loc_kmeans]=localizeArray(crdDepth,weightDepth,rows,columns,pos_electrodesDepth,normalVecElecDepth)


% DOMANDE: cos'è f_hull, cos'è h_hull? come creo la ct image? metto neri
% tutti i pixel del cervello e coloro con l'intensità in percentuale di
% weidghtDepth tutti quelli dei punti colorati?


%% 
clear
seeds = ones(5,3);
seeds(1,:) = [-48,51,4];
seeds(2,:) = [-66,-59,-10];
seeds(3,:) = [-60,-40,51];
seeds(4,:) = [-62,8.5,4];
seeds(5,:) = [-17.5,-108,-1];

num_electr = floor(rand(length(seeds),1)*7)+5;

[crdDepths,weightDepths,elecNumDepths] = CreateDepthElectrodes(num_electr,seeds);
% load smooth MNI surface 
load([ 'simulation_points_MNI.mat'])

f1=figure;
%           X               Y           Z          S    Color
for i = 1:length(seeds)
    scatter3(crdDepths{i}(:,1),crdDepths{i}(:,2),crdDepths{i}(:,3),5,weightDepths{i}); hold on; axis image;
end


h=mvis(v_hull,f_hull); hold on; caxis([0 1])
h.FaceAlpha = .2
camlight;

voxels = voxelize()