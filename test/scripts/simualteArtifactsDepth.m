function simualteArtifactsDepth(implantationFile)
% simulate CT aritifacts with different noise levels and overlaps


%% path setup - add path for HPC

hn = getenv('HOSTNAME');
if isempty(hn)
    [~,hn]=system('hostname');
end

if isunix
    if strfind(hn,'vdi-alejanob.uio.no') %#ok<STRIFCND> %workstation
        baseDir='/net/lagringshotell/uio/lagringshotell/sv-psi/Nevro/Prosjekt/Alejandro/data/';
    else % 'bioint01.hpc.uio.no'
        baseDir='/work/users/alejanob/data/';%'/home/alejanob/Nevro/Prosjekt/Alejandro/data/';
    end
else
    baseDir='\\lagringshotell\sv-psi\Nevro\Prosjekt\Alejandro\data\';

end

addpath(genpath([baseDir 'processing-codes-ieeg']))
addpath(genpath([baseDir '/Images/electrodes/electrodes_gui/priv']))

addpath([ baseDir 'Images/HDgrid_fit/Testing_Scripts/']);

rng('shuffle'); % avoid random numbers to repeat

destDir = ([ baseDir 'Images/HDgrid_fit/Simulation_intracranial_electrodes/CT_artifacts_depth_corr/']);

dirCell = {[destDir 'noiseLevel1']; [destDir 'noiseLevel2']; [destDir 'noiseLevel3']; ...
    [destDir 'noiseLevel4'];[destDir 'noiseLevel5'];[destDir 'noiseLevel6'];...
    [destDir 'noiseLevel7'];[destDir 'noiseLevel8'];[destDir 'noiseLevel9'];...
    [destDir 'noiseLevel10']; [destDir 'noiseLevel11']; [destDir 'noiseLevel12']};


%  for i=1:12
%      mkdir(dirCell{i});
%  end

%% load hull for ploting
load([ baseDir 'Images/HDgrid_fit/Simulation_intracranial_electrodes/simulation_points_MNI.mat'],'v_hull','f_hull');

load([ baseDir 'Images/HDgrid_fit/Simulation_intracranial_electrodes/simulation_points_MNI.mat'],'v_hull','f_hull');
%% load implantation file

clear grid_size normalVecElec normalVecMesh
load (implantationFile,'pos_mesh','normalVecMesh','M1','grid_size');
[~,name,~] = fileparts(implantationFile);

    
% define simulation space
%% Add noise at different levels 100% - 1 time - sigma 0.10 to 0.50
sigmaVec = [logspace(log10(.2),log10(2.2),12)]; 
noiseVec = [1:12];

dir_k=0; % counter


for sgm = noiseVec
    
    dir_k=dir_k+1;
    
    % figure and .mat name
    txt=[ name '-noise' num2str(sgm)];
    
        
    % if the file exist, jump to next iteration
    if exist([ dirCell{dir_k} '/' txt '.mat'], 'file' )
        disp(['Simulation skipped. File ' txt ' already exist.'])
        continue; %
    end
    
    
    %% add voxel artifaces at pos_mesh
    
    options=[];
    options.M1=M1;
    options.type = 'depth';
    options.rows =  grid_size;
    options.cols =  1;
    options.pos = pos_mesh;  
    options.thresholdValue=-1.5;    
    [crd,weight,elecNum]=simulateVoxels(pos_mesh,repmat(normalVecMesh,grid_size,1),options); %crd: coordinates / weight: voxel weights
    
    
    %% apply noise
    
    options.fractionAdd = 1;
    options.fractionLose = 1;
    options.sigma = sigmaVec(sgm);
    
    options.noiseType = 'intensity_spatial_corr'; %'spatially-correlated';
    options.noiseDist = 'normal'; %'uniform';
    options.repetitions = 1;
    options.thresholdValue = 0.2;
    options.corr_ratio = .95;
    options.image_res = 0.5;
    
    if options.fractionAdd % skip if 0
        [crd,weight,elecNum]=addnoise2electrodes(crd,weight,elecNum,options); %overwrite previous crd and weight definition
    end
    
       
    %% plot
    f1=figure;
    subplot(2,2,1)
    h=mvis(v_hull,f_hull); hold on;
    view([-90,0]); %x-y
    camlight;  alpha(h,.2)
    
    scatter3(crd(:,1),crd(:,2),crd(:,3),10,weight); hold on; axis image;
    scatter3(pos_mesh(:,1),pos_mesh(:,2),pos_mesh(:,3),'r','filled');    
    caxis([min(weight) max(weight)]);
        
    subplot(2,2,2)
    h=mvis(v_hull,f_hull); hold on;
    view([-180,0]);
    camlight;  alpha(h,.2)
    
    scatter3(crd(:,1),crd(:,2),crd(:,3),10,weight); hold on; axis image;
    scatter3(pos_mesh(:,1),pos_mesh(:,2),pos_mesh(:,3),'r','filled');
    caxis([min(weight) max(weight)]);
    
    subplot(2,2,3)
    h=mvis(v_hull,f_hull); hold on;
    view([-90,90]);
    camlight;  alpha(h,.2)
    
    scatter3(crd(:,1),crd(:,2),crd(:,3),10,weight); hold on; axis image;
    scatter3(pos_mesh(:,1),pos_mesh(:,2),pos_mesh(:,3),'r','filled');    
    caxis([min(weight) max(weight)]);  
    
    
    %% add note to figure
    
    boxTxt= { ['grid size: ' num2str(grid_size)]
        ['IED: ' num2str(M1)]
        ['noise level: ' num2str(sgm)]};
    
%         ['seed: ' num2str(seed)]
%         ['overlap: ' num2str(ovlp)]};
    
         % ['curvature: ' num2str(curvature)]};
         % ['real curvature: ' num2str(real_curvature)]
         % ['real noise: ' num2str(real_noise)]
        
         
    annotation(f1,'textbox',[0.86 0.55 0.10 0.33], 'String',boxTxt,...
        'FitBoxToText','on');
    
    %% save
    
    set(f1, 'Position',[5 30 1900 980]); % Maximize figure 1200 x 800
    set(f1,'name',txt);
    mtit(txt,'fontsize',16,'xoff',0,'yoff',0.025,'Interpreter','none');
    
    save([ dirCell{dir_k} '/' txt '.mat'],'-v7.3') %save
    print('-dpng','-r300',[ dirCell{dir_k} '/' txt]);
    
    
end

