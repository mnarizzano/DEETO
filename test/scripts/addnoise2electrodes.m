function [newCrd,newWeight,newElecNum]=addnoise2electrodes(crd,weight,elecNum,options)
% this function will add noise to a group of voxels that represent an
% electrode. Works for grids and depth electrodes
%
% crd                   voxel coordinates
% weight                voxel weights
% elecNum               electrode number for each voxel
% options.rows          number of rows
% options.cols          number of rows
% options.fractionAdd   fraction 0-1 of voxels to add/change.
%                       *Random*: New noise voxels are
%                       added in plausible coordinates arround the actual
%                       ones
%                       *spatial_displacement* voxels moved
%                       *intensity* voxels to be replaced
%                       'intensity_spatial_corr'  not used
% options.fracctionLose fraction 0-1 of voxels to remove in *random*
%                       Not used in intensity of 'intensity_spatial_corr' or *spatial_displacement*
% options.pos           electrode positions
% options.M1
% options.noiseType    'intensity_spatial_corr' / intensity' / 'spatial_displacement' (before spatially-correlated') 
% options.noiseDist    'uniform' / 'normal' / TODO: 'poisson'
% options.sigma         spatial correlation std
% options.repetitions   number of repetitions of the procedure
% options.thresholdValue Apply threshold to low intensity voxels
% options.corr_ratio     Add some correlated noise too, sugested ratio = 0.02 (visually estimated); 
% options.image_res     Image resolution (typically 0.5mm)


% Fixed bug on replacement of added Voxels (selectVoxelsAdd)
% A Blenkmann Feb 2022

rows = options.rows;
cols = options.cols;
fractionAdd = options.fractionAdd;
fractionLose = options.fractionLose;
M1=options.M1;
pos=options.pos;
origCrd=crd;
origWeight=weight;

rng('shuffle'); % avoid random numbers to repeat


%% normalize weights 0-1 range - not needed really
% weight=double(weight);
% weight=weight-min(weight);
% weight=weight/max(weight);


%% Switch by noise type

switch options.noiseType
    

%% plot before rotation to origin
% figure;
% ax1= subplot(1,2,1);
% scatter3(origCrd(:,1),origCrd(:,2),origCrd(:,3),20,weight); axis image; title ('original')
% ax2 = subplot(2,2,2);
% scatter3(remainCrd(:,1),remainCrd(:,2),remainCrd(:,3),20,'r','filled'); hold on;
% scatter3(addCrd(:,1),addCrd(:,2),addCrd(:,3),20,'b','filled'); axis image; title ('add noise')
% ax3= subplot(1,2,2);
% scatter3(newCrd(:,1),newCrd(:,2),newCrd(:,3),20,newWeight); axis image; title ('final')

% Link = linkprop([ax1, ax2,ax3],   {'CameraUpVector', 'CameraPosition', 'CameraTarget'});
% Link = linkprop([ax1,ax3],   {'CameraUpVector', 'CameraPosition', 'CameraTarget'});
% setappdata(gcf, 'StoreTheLink', Link);


% plot final
% figure;
% ax1=subplot(1,2,1);
% scatter3(origCrd(:,1),origCrd(:,2),origCrd(:,3),20,origWeight); axis image; title ('original')
% ax2=subplot(1,2,2);
% scatter3(newCrd(:,1),newCrd(:,2),newCrd(:,3),20,newWeight); hold on; axis image; title ('final')
% % scatter3(origCrd(:,1),origCrd(:,2),origCrd(:,3),10,'r'); axis image; title ('original')
%
% Link = linkprop([ax1, ax2], {'CameraUpVector', 'CameraPosition', 'CameraTarget'});
% setappdata(gcf, 'StoreTheLink', Link);


    %% spatially correlated noise. Keep voxel intensity and change location
    
    case 'spatial_displacement' % (BEFORE 'spatially-correlated') fixed 2022 rand Distance and rand Direction error
        
        newElecNum=elecNum;
        % noise fraction. Number of voxels affected by the noise
        N = size(crd,1); %number of voxels
        kAdd = round( N * fractionAdd);
        kLose = kLadd; % removed are the changed ones
        
        for i=1:options.repetitions
            
            selectVoxelsAdd = randperm(N,kAdd);  %index random permutation on each repetition
            selectVoxelsLose = selectVoxelsAdd;
                                    
            addCrd=nan(kAdd,3); 
            addWeight=nan(kAdd,1); 
            
            for n=1:kAdd
                K=selectVoxelsAdd(n); %randperm(N,1);
                seedPoint = crd(K,:);
                randDirection = (rand(1,3)-0.5);
                randDirection = randDirection / norm(randDirection);
                switch options.noiseDist
                    case 'uniform'
                        randDistance = rand(1)*options.sigma;
                    case 'normal'
                        randDistance = random('normal',0,options.sigma);
                end
                newPoint =  seedPoint + randDirection * randDistance;
                
                newWeight = weight(K); % just use the same intensity
                
                addCrd (n,:)= newPoint;
                addWeight (n)= newWeight;
                
            end
            
            % put all noise crd toghether
            remainCrd = crd;
            remainCrd(selectVoxelsLose,:)=[];
            
            remainWeight = weight;
            remainWeight(selectVoxelsLose)=[];
            
            newCrd = [remainCrd; addCrd];
            newWeight = [remainWeight; addWeight];
            
            % for the repetition loop
            crd=newCrd;
            weight=newWeight;
        end
        
%% Change voxel intensity and leave the same location        
    case 'intensity'
        newElecNum=elecNum;
        
        % noise fraction. Number of voxels affected by the noise
        N = size(crd,1); %number of voxels
        kAdd = round( N * fractionAdd);
        
        newWeight = weight; % copy old weight values
        newCrd = crd; % no changes
        
        for i=1:options.repetitions
            
            selectVoxelsAdd = randperm(N,kAdd);  %index random permutation on each repetition
            
            switch options.noiseDist
                case 'uniform'
                    randIntensity = rand(kAdd,1)*options.sigma;
                case 'normal'
                    randIntensity = random('normal',0,options.sigma,kAdd,1);
                case 'poisson'
                    randIntensity = (random('poiss',options.lambda,kAdd,1) - options.lambda) /options.lambda *  options.sigma;
            end
            
            % apply random additive noise
            newWeight (selectVoxelsAdd) =  newWeight(selectVoxelsAdd) + randIntensity;
        end
        




%% Add spatially correlated noise: Change voxel intensity only
% half of noise variance is correlated and half uncorrelated

    case 'intensity_spatial_corr'
        
        newElecNum=elecNum;
        
        % kernel for spatial correlation from Britten et al., 2004
        % DOI:10.1259/bjr/78576048
        % values from auto correlation function (ACF)
        
%         x=[-3:3];
        x=[-3:3] * options.image_res;
        y=[0 0.12 0.74 1 0.74 0.12 0];

        fitKernel = fit(x.', y.', 'pchipinterp', 'Normalize', 'off'); % piecewise cubic Hermite interpolation


        % All voxels are affected by the noise, wich is spatally correlated
        N = size(crd,1); %number of voxels        
        newWeight = weight; % copy old weight values
        newCrd = crd; % no changes
        
        
        % ratio of correlated noise
        R = options.corr_ratio; 
        
        total_variance = options.sigma^2;
        uncorr_std=sqrt(total_variance * (1-R));
        corr_std=sqrt(total_variance * R ); 
        
        disp(['adding correlated noise (sigma = ' num2str(corr_std) ...
            ') and uncorrelated noise (sigma = ' num2str(uncorr_std) ...
            '). Total sigma = ' num2str(options.sigma)]);
        
        for i=1:options.repetitions
            
            
            
            %work on one electrode at the time
            for e=1:size(options.pos,1)
                
                idxElec=find(elecNum ==e); % index to current electrode voxels
                V=length(idxElec); % number of voxels in the current electrode
                
                % compute random intensity
                switch options.noiseDist
                    case 'uniform'
                        randIntensity_corr = rand(V,1)*corr_std;
                        randIntensity_uncorr = rand(V,1)*uncorr_std;
                    case 'normal'
                        randIntensity_corr = random('normal',0,corr_std ,V,1);
                        randIntensity_uncorr = random('normal',0,uncorr_std ,V,1);
                end
                
                % compute distance between voxels
                DD= eucDistMat( crd(idxElec,:),crd(idxElec,:));
                idx2=find(DD(:)<3);
                idx2=find(DD(:)<3*options.image_res);
                attenuation = zeros(size(DD));
                attenuation(idx2)=fitKernel(DD(idx2)); %values outside D>3 are not valid!!
                randIntensity_corr = (attenuation * randIntensity_corr) ./ sum(attenuation,2); % spatial convolution
                
                % apply additive correlated and uncorrelated noise
                newWeight (idxElec) =  newWeight(idxElec) + randIntensity_uncorr+ randIntensity_corr ;
                
                %newWeight (idxElec) =  randIntensity_corr; %used to plot noise
            end
            
            
%             All voxels correlations takes to long
%
%             % compute random intensity
%             switch options.noiseDist
%                 case 'uniform'
%                     randIntensity = rand(N,1)*options.sigma;
%                 case 'normal'
%                     randIntensity = random('normal',0,options.sigma,N,1);
%                 case 'poisson'
%                     randIntensity = (random('poiss',options.lambda,N,1) - options.lambda) /options.lambda *  options.sigma;
%             end
%             
%             randIntensity_corr = zeros(size(randIntensity));
%             
%             %work on one voxel at the time (long but memory efficient approach
%             for i=1:N
%                 % compute distance between voxels
%                 DD = eucDistMat( crd(i,:),crd); % Nx1
%                 idx2=DD(:)<3; %M points only
%                 attenuation=fitKernel(DD(idx2)); %Mx1
%                 randIntensity_corr(idx2) =  randIntensity_corr(idx2) + (attenuation .* randIntensity( idx2)) ./ sum(attenuation,1); % spatial convolution
%             end
%             
%             % apply random additive noise
% %             newWeight =  newWeight + randIntensity_corr;
%             newWeight =  randIntensity_corr;
            
        end
        
end

%% Apply thresholding

%remove coords below threshold
newCrd(newWeight < options.thresholdValue,:)=[];
newWeight(newWeight < options.thresholdValue)=[];
newElecNum(newWeight < options.thresholdValue)=[];




