function [pos_electrodes,normalVecElec]=simulatDepthArray(rows,IED,seedPoint,curvature,plotValues)
% simulate implantation of a Depth electrode
% Eg [pos_electrodes,normalVecElec]=simulatDepthArray(10,3, [-18 72	-4],0)

%% define path - change accordingly

if isunix
    %baseDir='/net/lagringshotell/uio/lagringshotell/sv-psi/Nevro/Prosjekt/Alejandro/data/';
else
    %baseDir='\\lagringshotell.uio.no\sv-psi\Nevro\Prosjekt\Alejandro\data\';
end
addpath(genpath('priv'))
%addpath(genpath([baseDir 'processing-codes-ieeg']))
%addpath(genpath([baseDir '/Images/electrodes/electrodes_gui/priv']))

rng('shuffle');

%% load smooth MNI surface and list of simulation points
load([ 'simulation_points_MNI.mat'])


%% compute normal vector at the seed point

D=eucDistMat(v_hull,seedPoint); % new corrected version
ind_mesh = D < 10; %10mm distance

[V]=pca(v_hull(ind_mesh,:));
normalVecMesh= V(:,3)';

%check normalVec points inwards
cmSurf = mean(v_hull(unique(f_hull(:)),:)); % center of mass surface

x_plus = seedPoint + normalVecMesh * IED * rows;
x_minus = seedPoint - normalVecMesh * IED * rows;

% point normal Vector direction outwards
if norm(x_plus- cmSurf) < norm(x_minus - cmSurf)
    normalVecMesh = - normalVecMesh;
end


%% simulate implant coords

% 1. Determine the range of valid electrodes within the brain

mesh=[];
mesh.faces = f_hull;
mesh.vertices = v_hull;
[faceInd,coeff]=interseccionVecMesh(normalVecMesh,mesh,seedPoint);

% intersections
intersections = seedPoint + coeff * normalVecMesh; % just for ploting

% redefine seed point to closest intersection, and coeff also
[~, indClosest]= min(abs(coeff));
seedPoint = seedPoint + coeff(indClosest) * normalVecMesh; %
coeff = coeff - coeff(indClosest);


% since norm(normalVecMesh) = 1, coeff operates as a distance along the
% normal vector. Use it to constrain the valid electrodes
% one of the coeff is always in the cortex (some mm of error are
% allowed)

x=(0:rows-1)'*IED;

x(x > max(abs(coeff))) = [];

distance2end = max(abs(coeff)) - max(x); % always possitive

% add some variability at the end
x = x + rand(1)*distance2end;


% this is the number of real electrodes implanted inside the brain
rows = length(x);

if curvature==1 % no deformation
    y=zeros(size(x));
    z=zeros(size(x));
else
    def = lanwin(rows); %arc shape
    def = def./max(def); %normalization
    def = def * rows * IED /100;
    
    v = rand(2,1)-.5;
    v = v /norm(v);
    y = def * v(1);
    z = def * v(2);
end

pos_electrodes=[x,y,z];


% along the x-axis vector
normalVecElec=repmat([1 0 0],rows,1);
% compute rotation matrix
R = vrrotvec2mat( vrrotvec( [1 0 0], -normalVecMesh)); % point electrode outwards


% rotation and translation
pos_electrodes=(R*pos_electrodes')'+ seedPoint;
normalVecElec = (R*normalVecElec')';


targetPoint = pos_electrodes(end,:);


%% plot
if plotValues
    f1=figure;
    subplot(2,2,1)
    h=mvis(v_hull,f_hull); hold on;
    view([-90,0]); %x-y
    camlight;  alpha(h,.2)

    % for debugging
    %     scatter3(seedPoint(:,1),seedPoint(:,2),seedPoint(:,3),'k','filled'), axis image; % seed
    %     scatter3(targetPoint(:,1),targetPoint(:,2),targetPoint(:,3),'r','filled'), axis image; % target
    %     scatter3(intersections(:,1),intersections(:,2),intersections(:,3),'b','filled'), axis image; %intersections
    %     quiver3(seedPoint(:,1),seedPoint(:,2),seedPoint(:,3),normalVecMesh(:,1),normalVecMesh(:,2),normalVecMesh(:,3),10)

    scatter3(pos_electrodes(:,1),pos_electrodes(:,2),pos_electrodes(:,3),'m','filled'), axis image;
    plotElectrodesLines(pos_electrodes,rows,1,[0 0 1]);


    subplot(2,2,2)
    h=mvis(v_hull,f_hull); hold on;
    view([-180,0]);
    camlight;  alpha(h,.2)

    scatter3(pos_electrodes(:,1),pos_electrodes(:,2),pos_electrodes(:,3),'m','filled'), axis image;
    plotElectrodesLines(pos_electrodes,rows,1,[0 0 1]);

    subplot(2,2,3)
    h=mvis(v_hull,f_hull); hold on;
    view([-90,90]);
    camlight;  alpha(h,.2)

    scatter3(pos_electrodes(:,1),pos_electrodes(:,2),pos_electrodes(:,3),'m','filled'), axis image;
    plotElectrodesLines(pos_electrodes,rows,1,[0 0 1]);
end
end




