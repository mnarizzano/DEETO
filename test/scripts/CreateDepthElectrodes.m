function [crdDepths,weightDepths,elecNumDepths]=CreateDepthElectrodes(num_points_per_electrode,seeds)
crdDepths = {};
weightDepths = {};
elecNumDepths = {};
for i = 1:length(num_points_per_electrode)
    rows = num_points_per_electrode(i);
    columns = 1;
    IED = 5;
    seedPoint = seeds(i,:);
    %seedPoint = [-48,51,0];
    %seedPoint = [-66,-59,-10]; %any point on the SCE surface works
    curvature = 1; %no deformation 

    [pos_electrodesDepth,normalVecElecDepth]=simulatDepthArray(rows,IED,seedPoint, curvature,0);

    % Simulate voxels
    options=[];
    options.M1=5; %IED
    options.rows =  rows;
    options.cols =  columns;
    options.adjMat = makeAdjMat(rows,columns);
    options.thresholdValue=-1;
    options.type = 'depth';

    [crdDepth,weightDepth,elecNumDepth]=simulateVoxels(pos_electrodesDepth,normalVecElecDepth,options); %crd: coordinates / weight: voxel weights

    % Simulate Noise

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
    crdDepths{i} = crdDepth;
    elecNumDepths{i} = elecNumDepth;
    weightDepths{i} = weightDepth;
end
end

