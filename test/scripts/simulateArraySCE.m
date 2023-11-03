function [pos_electrodes,normalVecElec]=simulateArraySCE(rows,columns,IED,seedPoint)
% simulate the implantation of one electrode array over SCE surface
% Eg [pos_electrodes,normalVecElec]=simulateArraySCE(4,8,5, [-18 72	-4]);

%% path setup - change accordingly
if isunix
    %baseDir='/net/lagringshotell/uio/lagringshotell/sv-psi/Nevro/Prosjekt/Alejandro/data/';
else
    %baseDir='\\lagringshotell.uio.no\sv-psi\Nevro\Prosjekt\Alejandro\data\';
end

%addpath(genpath([baseDir 'processing-codes-ieeg']))
addpath(genpath(['priv'])) % iElectrodes toolbox needed


%% load smooth MNI surface and list of simulation points
load(['simulation_points_MNI.mat'])

%% build tangential grid
options = [];
options.additionalRotation = 0; % rotation angle in degrees

[pTan,~]=tangentialGrid(seedPoint,rows,columns,IED,v_hull,[1e10 1e10 1e10],options); % a cordinate in the not used hemisphere is needed

%% project grid to hull

adjMat=makeAdjMat(rows,columns);
d_ij_0 = eucDistMat(pTan,pTan); % fastest if done outside for loop for all points

options = [];
options.SCE_springs_projection.K=1000; %all=1000 except HD, use 100%
options.SCE_springs_projection.TolCon=0.5; %0.5; %0.1 increased for HD % Constrain Tolerance
options.SCE_springs_projection.StepTolerance=1e-6;               %
options.SCE_springs_projection.meshReduceL=20;                   % reduce mesh to the closest L radium
options.SCE_springs_projection.RefineMesh=1;
options.rows = rows;
options.columns = columns;
options.SCE_springs_projection.constrain = 'distance';
options.SCE_springs_projection.d_ij_0 = d_ij_0;

options.SCE_springs_projection.UseParallel = false;

mesh.vertices=v_hull;
mesh.faces=[f_hull ones(length(f_hull),1)];

[pos_electrodes,~,indexMesh]=projection2mesh(mesh,pTan,'springs',adjMat,options);

%% calculate normal vector for each electrode, using electrode coordinate
normalVecElec = zeros(3,rows*columns);
for i=1:rows*columns
    % neigbours indices
    neigInd = [find(adjMat(i,:)==1) find(adjMat(i,:)==2)]; % lateral and diagonal electrodes
    neig=[pos_electrodes(neigInd,:); pos_electrodes(i,:)];
    [V]=pca(neig);
    normalVecElec(:,i)= V(:,3);
end
normalVecElec = normalVecElec';


%% plot array on SCE
f1=figure;

% plot SCE surface
mvis(v_hull,f_hull); hold on;

% compute angle for view
cmSurf = mean(mesh.vertices);
cmGrid = mean(pos_electrodes);
if norm(cmGrid-cmSurf) > norm(cmGrid-cmSurf-mean(normalVecElec))
    view(mean(normalVecElec));
else
    view(-mean(normalVecElec));
end
camlight;

% plot electrode coordinates
scatter3(pos_electrodes(:,1),pos_electrodes(:,2),pos_electrodes(:,3),'m','filled'), axis image;
plotElectrodesLines(pos_electrodes,rows,columns,[0 0 1]);

% plot normal vectors
quiver3(pos_electrodes(:,1),pos_electrodes(:,2),pos_electrodes(:,3), pos_electrodes(:,1)+normalVecElec(:,1),...
    pos_electrodes(:,2)+normalVecElec(:,2), pos_electrodes(:,3)+normalVecElec(:,3),'g');

%% plot deformation histogram
d_ij=eucDistMat(pos_electrodes,pos_electrodes)/IED; %deformations

figure
hist((d_ij(adjMat==1)))

xlabel('deformation [% of IED] ')
ylabel('count')
% detect outliers
if max(d_ij(adjMat==1))>1.05 || min(d_ij(adjMat==1))<0.95
    w=1;
    warning('deformation is bigger than 5%')
    title ('deformation is bigger than 5');
else
    w=0;
end

