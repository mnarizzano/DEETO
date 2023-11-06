function simualteArtifactsGrids(implantationFile)
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

destDir = ([ baseDir 'Images/HDgrid_fit/Simulation_intracranial_electrodes/CT_artifacts_grids_corr/']);

dirCell = {[destDir 'noiseLevel1']; [destDir 'noiseLevel2']; [destDir 'noiseLevel3']; ...
    [destDir 'noiseLevel4'];[destDir 'noiseLevel5'];[destDir 'noiseLevel6'];...
    [destDir 'noiseLevel7'];[destDir 'noiseLevel8'];[destDir 'noiseLevel9'];...
    [destDir 'noiseLevel10']; [destDir 'noiseLevel11']; [destDir 'noiseLevel12']; [destDir 'noiseLevel1_overlap']; ...
    [destDir 'noiseLevel2_overlap']; [destDir 'noiseLevel3_overlap']; ...
    [destDir 'noiseLevel4_overlap'];[destDir 'noiseLevel5_overlap']...
    ;[destDir 'noiseLevel6_overlap'];[destDir 'noiseLevel7_overlap'];...
    [destDir 'noiseLevel8_overlap'];[destDir 'noiseLevel9_overlap'];...
    [destDir 'noiseLevel10_overlap']; [destDir 'noiseLevel11_overlap'];[destDir 'noiseLevel12_overlap']};

%  for i=1:24
%      mkdir(dirCell{i});
%  end

%% load implantation file
clear grid_size normalVecElec normalVecMesh
load (implantationFile,'pos_mesh','normalVecElec','normalVecMesh','M1','grid_size','grid_rows','grid_cols');
[~,name,~] = fileparts(implantationFile); %used later

if exist('grid_size','var') % square grid
    grid_rows = grid_size;
    grid_cols = grid_size;
end

if exist('normalVecMesh','var')
    normalVecElec=normalVecMesh;
end

%% load hull for ploting
load([ baseDir 'Images/HDgrid_fit/Simulation_intracranial_electrodes/simulation_points_MNI.mat'],'v_hull','f_hull');

% define simulation space
%% Add noise at different levels 100% - 1 time - sigma 0.10 to 0.50
sigmaVec = [logspace(log10(.2),log10(2.2),12)]; 
noiseVec = [1:12];
overlapVec = [0 1];

dir_k=0; % counter

for ovlp = overlapVec
    for sgm = noiseVec
        
        dir_k=dir_k+1;

        % figure and .mat name
        txt=[ name '-noise' num2str(sgm) '-overlap' num2str(ovlp)];
        
        % if the file exist, jump to next iteration
        if exist([ dirCell{dir_k} '/' txt '.mat'], 'file' )
            disp(['Simulation skipped. File ' txt ' already exist.'])
            continue; %
        end
        
        %% add voxel artifacts at pos_mesh
        
        options=[];
        options.M1=M1; 
        options.rows =  grid_rows;
        options.cols =  grid_cols;
        options.adjMat = makeAdjMat(grid_rows,grid_cols);
        options.pos = pos_mesh;
        options.thresholdValue=-1.5;
        
            
        if options.rows == 1 || options.cols == 1 % depth or grids
            options.type = 'strip';
        else
            options.type = 'grid';
        end
        [crd,weight,elecNum]=simulateVoxels(pos_mesh,normalVecElec,options); %crd: coordinates / weight: voxel weights
        
        %% apply overlaps
        if ovlp
            options.fractionOverlapAdd = 0.10; % 10 percent overlap
                   
            if  strcmp(options.type,'strip')
                D = eucDistMat(pos_mesh,v_hull);
                options.SCEpoints = v_hull(any(D<15),:);
            end
            
            %in same cases (~5%) overlaps are not working for strips
            overlapNotOk = true;
            k=0;
            while overlapNotOk
                try
                    [addPos,addNormalVec]=simulateOverlaps(pos_mesh,normalVecElec,options); % - Use normalVecMesh instead -

                    % add voxels at addPos
                    [crdAdd,weightAdd,elecNumOverlap]=simulateVoxels(addPos,addNormalVec,options); %crd: coordinates / weight: voxel weights
                    
                    overlapNotOk=any(isnan(crdAdd));
                end
                % avoid infinite loop
                k = k+1;
                if k>1000
                    error('error creating overlap')
                end
            end

            
            crd = [crd; crdAdd];
            weight = [weight; weightAdd];
            
            % reassign ovelap electrode numbers
            elecNum=[elecNum; elecNumOverlap+max(elecNum)];
        end
        
        
        %% apply noise
        
        options.fractionAdd = 1;
        options.fractionLose = 1;
        options.sigma = sigmaVec(sgm);
          
        options.noiseType = 'intensity_spatial_corr'; %'spatially-correlated';
        options.noiseDist = 'normal'; %'uniform';
        options.repetitions = 1;
        options.thresholdValue = 0;
        options.corr_ratio = .95; 
        options.image_res = 0.5;
        
        if options.fractionAdd % skip if 0
            [crd,weight,elecNum]=addnoise2electrodes(crd,weight,elecNum,options); %overwrite previous crd and weight definition
        end
        
        %% plot
        f1=figure;
        %         subplot(3,4,[1 2 5 6])
        scatter3(crd(:,1),crd(:,2),crd(:,3),5,weight); hold on; axis image;
%         scatter3(pos_mesh(:,1),pos_mesh(:,2),pos_mesh(:,3),30,'r','filled')
        
        mvis(v_hull,f_hull); hold on; caxis([0 1])
        
        % compute angle for view
        cmSurf = mean(v_hull);
        cmGrid = mean(pos_mesh);
        if norm(cmGrid-cmSurf) > norm(cmGrid-cmSurf-mean(normalVecMesh))
            view(mean(normalVecMesh));
        else
            view(-mean(normalVecMesh));
        end
        camlight;
        caxis([min(weight) max(weight)]);
            
        
        %% add note to figure
        boxTxt= { ['grid rows: ' num2str(grid_rows)]
            ['grid cols: ' num2str(grid_cols)]
            ['IED: ' num2str(M1)]
            ['noise level: ' num2str(sgm)]
            ['sigma: ' num2str(sigmaVec(sgm))]
            ['overlap: ' num2str(ovlp)]};
        

         % ['curvature: ' num2str(curvature)]};
         % ['real curvature: ' num2str(real_curvature)]
         % ['real noise: ' num2str(real_noise)]
         % ['angle:' num2str(main_angle)]
        
        annotation(f1,'textbox',[0.86 0.55 0.10 0.33], 'String',boxTxt,...
            'FitBoxToText','on');
        
        %% save
        
        set(f1, 'Position',[5 30 1900 980]); % Maximize figure 1200 x 800
        set(f1,'name',txt);
        mtit(txt,'fontsize',16,'xoff',0,'yoff',0.025,'Interpreter','none');
        
        print('-dpng','-r300',[ dirCell{dir_k} '/' txt]);
        close(f1);
        save([ dirCell{dir_k} '/' txt '.mat'],'-v7.3') %save
        
        
    end
end
