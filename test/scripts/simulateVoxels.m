function [crdOut,weightOut,elecNum] =  simulateVoxels(pos,normalVec,options)

% simulate voxels coordinates for a grid / depth electrodes
% spatial sampling is 0.5mm
% sampling matrix is randomly oriented to simuulate random aspects to CT
% aquisiton. Importantly, all electrodes are sampled with unique and
% consisten grid, like in a real CT.

% pos (Nx3) coordinates for the center of mass of each electrodes
% normalVec (Nx3) For grids, the vector normal to surface

% crd: (Mx3) coordinates
% weight: (Mx1) voxel weights

% options.M1 inter-elctrode distance (optional)
% options.type = 'grid' / 'depth'

% define electrode artifact with intensity as (updated Jan  2022)
% I = 1-r
% where r= sqrt(x^2 / a^2 + y^2/b^2 + z^2/c^2)
%
% semi-axis are provided (optional) in:
% options.a
% options.b
% options.c

% Threshold value
% options.thresholdValue (typically = 0 or lower (-1) if noise will be added later)

% elecNum keeps track of voxels correspodance with electrode artifact (1 to N)

% Eg 
% [pos_electrodes,normalVecElec]=simulateArraySCE(4,8,5, [-18 72	-4]);
% options=[];
% options.M1=5;
% options.rows =  4;
% options.cols =  8;
% options.adjMat = makeAdjMat(4,8);
% options.thresholdValue=-1.5;
% options.type = 'grid';
% [crd,weight,elecNum]=simulateVoxels(pos_electrodes,normalVecElec,options); %crd: coordinates / weight: voxel weights


% A Blenkmann 2019
% updated Jan 2022

%% define default equation parameters
% Some notes on the manufacturers. 
% Most use Platinum, except PMT

% Ad-Tech uses the same contacts for Grids with 10 and 5mm inter-electrode distance (4mm diameter).
% For Spenser probes, 5 and 10mm IED electrodes have 2 possible contact lenght (2.41 or 1.32 mm). Diameter 1.12 or 0.86 
% DIXI depth contact length 2mm and diameter 0.8, IED 3.5mm 
% PMT depth contact length 2mm and diameter 0.8 (same as DIXI), IED 3.5mm
% PMT Grids have more options acording to brochure. Contact size 2, 3 and 4.5mm.(It is not
% clear if it is exposed area or total size). Platinum and Stainless steel.



if ~isfield(options,'a')
    disp('using predefined electrode size for ellipsoid model')
    switch options.type
        case 'grid'
            switch options.M1
                case 10
                    % given the analysis of real data (see below code - heuristic approach)
                    a=2.2; b=2.2; c=1.5;
                    
                case 5
                    a=2.2; b=2.2; c=1.5; 
                    
                case 3
                    a=1.1; b=1.1; c=1;
                    
            end
            
        case 'depth'
            switch options.M1
                case 10
                    % given the analysis of real data (see below code - heuristic approach)
                    a=1.25; b=1.25; c=1.75; 
                    
                case 5
                    a=1.25; b=1.25; c=1.75; 
                    
                case 3
                    a=1.1; b=1.1; c=1.5; 
                    
            end
    end
    
else % parameters given by user
    a=options.a;
    b=options.b;
    c=options.c;
end

%% define default sampling space ( a 10x10x10 mm box at 0.5mm resolution with the coordinates of voxels)
n=1;
for i=-10:1:10
    for j=-10:1:10
        for k=-10:1:10
            sampling(n,:)=[i,j,k];
            n=n+1;
        end
    end
end

sampling = sampling * 0.5; % 0.5 = spatial resolution

% random rotation and translation of sampling coords around (0,0,0)

Rs=rotationmat3D(rand(1)*2*pi,rand(3,1)); % rotate "rand radians" around "rand axis"
sampling_rot=(Rs*sampling')'+(rand(1,3)-0.5); % rotate sampling grid and add random translation whithin 0.5 mm

% debugging: uncomment last two lines
% Rs=eye(3);
% sampling_rot = sampling;


%% build each electrode

crdOut=[];
weightOut=[];
elecNum=[];

for n=1:size(pos,1)
    
    Re=rotationFromTwoVectors( [0 0 1], normalVec(n,:)) ; % add rotation to normalVec here
    
    deltaPos= (2*pos(n,:)-round(2*pos(n,:)))/2; % 0.5 mm residual
    crdElec_space = (sampling_rot - deltaPos)*Re; %% add residual position  and rotate acording to normal vector
    
    
    % compute weights on rotated coords
    weightElec = sqrt (crdElec_space(:,1).^2 / a^2 + crdElec_space(:,2).^2/b^2 + crdElec_space(:,3).^2/c^2);
    weightElec = 1-weightElec;
    
    % add pos to center at elec coordinate
    crdElec = sampling_rot + (pos(n,:) - deltaPos); % sampling cords plus rounded electrode position
    
    %remove coords below threshold
    crdElec(weightElec < options.thresholdValue,:)=[];
    weightElec(weightElec < options.thresholdValue)=[];
    
    crdOut=[crdOut; crdElec];
    weightOut=[weightOut; weightElec];
    elecNum = [elecNum; n*ones(size(weightElec,1),1)];
end


