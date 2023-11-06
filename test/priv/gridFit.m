function [gridCords,clusteredCrd,clusteredWeight,clusters,exitflag]=gridFit(brushCrd,brushWeight,rows,cols,options)
% Fit a grid (rows x cols) to a cloud of voxels in coordinates brushCrd
% with intensity values weight.
%
% options.fixM1 = 1st neig inter-electrode distamce  
% options.thickness = grid thickness, circa 0.5 mm in most cases
% options.type = 'grid'/'strip'/'depth'
% options.model = '3D' or '2D'
% options.find_corners_grid_method = 'iterative_convexhull'/
% options.indexing_projection_method = 'sphereFit';
% options.DCT = 0 /1 reduce parameters using DCT (under development)
% options.constrain_type =  'none' / 'volume' / 'distance' /'volume_distance'
%
% 1st minimization parameters
% options.minDef1.recalcD0=       0 (default)/1 recalculate distance matrix in each iteration
% options.minDef1.sigmaRatio =    M1 * ratio  used for gaussian correlation
% options.minDef1.tolCon          nonlinear function tolerance constrain (distance to fit surface, default = 1)
% options.minDef1.UseParallel     true/false use parallel processing
% 3D models
% options.minDef1.Kt              translation K
% options.minDef1.Kc              coregistration K
% options.minDef1.Kd              deformation K. The smaller this number, the more flexible the grid
% options.minDef1.model = '3D' or '2D' or '1D_fix'
% options.minDef2.model = '3D' or '2D' or '1D_fix'
    
% 2D models
% options.minDef1.Kd_normal =       1.0 (scalar) ratio of normal (1st neig) deformation for 2D model
% options.minDef1.Kd_shear =        1.0 (scalar) ratio of shear (diagonal neig) deformation for 2D model
% options.minDef1.Kd_bend  =        1.0 (scalar) ratio of bending (2nd neig) deformation for 2D model


% Second minimization options (no surface constrain)
% options.minDef2.recalcD0 =        default=0 recalculate distance matrix in each iteration
% options.minDef2.sigmaRatio=      default=1/4  M1 * ratio : used for gaussian correlation
% options.minDef2.tolCon =          default = 0.01 nonlinear function tolerance constrain ( 'volume' / 'distance' /'volume_distance')
% options.minDef2.UseParallel=      true/false;
%
% 3D models
% options.minDef2.Kt=               translation constant
% Kc is obtained from optimal Kc. No need to set it up here
% options.minDef2.Kd                deformation constant: the smaller this number, the more flexible the strip. This number is smaller for strips than for grids

% 2D models
% options.minDef2.Kd_normal =       1.0 (scalar) ratio of normal (1st neig) deformation for 2D model
% options.minDef2.Kd_shear =        1.0 (scalar) ratio of shear (diagonal neig) deformation for 2D model
% options.minDef2.Kd_bend  =        1.0 (scalar) ratio of bending (2nd neig) deformation for 2D model

% options.NailElectrodeNumber =     index to nailed electrodes (N)
% options.NailElectrodeCrd =        coordinates of nailed electroed (Nx3) 
%
% Output coordinates are indexed in the right order 
% can be combined with adjMat=makeAdjMat(rows,cols);
% A Blenkmann 2018


%% TODO
% Define a Non deformable model for depth electrodes. Change minimization, so only rotation and translation is available, instead of individual coordinates (4D rotation matrix, or quaternion rotation (smoother) + translation 
% Nailed coordinates should be available for the contrain (if more than one
% is used, the minimization will not converge to a solution with constrains
% satisfied. Only one should be used. 
% If 2 nails or more are used, its better to find the soulution by
% minimizing only the distance to these set of points
%%

global debugging

M1 = options.fixM1;
M2 = M1*sqrt(2); % diagonals
M3 = M1*2;       % second neigbours
M4 = options.thickness;                      % in between layer up-down z-axis
M5 = sqrt (options.thickness ^2 + M1^2);     % in between layer orthogonal
M6 = sqrt (options.thickness ^2 + M1^2 + M1^2);

% dealing with Behnke Fried electrodes (Ad-Tech)
if options.fixM1 ~= options.fixM1_BF
   depth_BF=true; % define as a BF electrode type

   M1_BF = options.fixM1_BF;
   M2_BF = M1_BF*sqrt(2); % diagonals
   M3_BF = M1_BF*2;       % second neigbours
else
   depth_BF=false; %defined as depth standard type
end 

options.surfFitType='lowess'; %surface fitting algorithm

%% rotate voxels data to principal components. brushCrd -> crd

T=pca(brushCrd);    % rotation matrix. 
crd=brushCrd*T;     % rotated data

if rows == 1 || cols == 1 % depth or strips
    
    if abs(min(crd(:,1))) > abs( max(crd(:,1)))
        R=[-1 0 0; 0 1 0; 0 0 1];
        crd=crd*R; % flip X axis (max variance) to make the depth increase with X axis
        T=T*R; % add to transformation matrix to invert properly
    end
end 

L=mean(crd);
crd=[crd(:,1)-L(:,1),crd(:,2)-L(:,2),crd(:,3)-L(:,3)]; %center the data

% if any nailed electrode crd, rotate also
if ~isempty(options.NailElectrodeNumber)
    options.NailElectrodeCrd = options.NailElectrodeCrd * T;
    options.NailElectrodeCrd = [options.NailElectrodeCrd(:,1)-L(:,1), options.NailElectrodeCrd(:,2)-L(:,2), options.NailElectrodeCrd(:,3)-L(:,3)];
end


if debugging
    figure
    subplot(1,2,1)
    scatter3(brushCrd(:,1),brushCrd(:,2),brushCrd(:,3),10,brushWeight,'filled')
    axis image; xlabel x; ylabel y; zlabel z;
    title ('original data')
    subplot(1,2,2)
    scatter3(crd(:,1),crd(:,2),crd(:,3),10,brushWeight,'filled');
    axis image; xlabel x; ylabel y; zlabel z;
    title('rotated data')
end


%% normalize weights 0-1 range
brushWeight=double(brushWeight);
brushWeight=brushWeight-min(brushWeight);
brushWeight=brushWeight/max(brushWeight);

%% make smooth approximation surface/line to voxels
% thinplateinterp is less noisy than biharmonicinterp, but more details that lowess
% thinplateinterp does not accept weights

disp('Fitting surface to voxels')

if rows == 1 || cols == 1 % depth or strip
    linFun=fit(crd(:,1),crd(:,2),'poly3'); % fit a 3rd order polinomy to first 2 components of PCA data
else %grid
    surfFun = fit([crd(:, 1), crd(:, 2)], crd(:, 3), options.surfFitType,'Weights',brushWeight);
end
    
if debugging
    figure;
    if rows == 1 || cols == 1
        plot(linFun); hold on;
        scatter3(crd(:, 1), crd(:, 2), crd(:, 3));
    else
        plot(surfFun, [crd(:, 1), crd(:, 2)], crd(:, 3));
    end
    axis image
    title 'projection line/surface'
end

%% get the corners of the cloud of voxels and build Uniformly Distributed grid to ininzialize 1st minimization
% This is not using the inter-electrode distance, just distance in between corners
% Is not taking intho consideration the distance betwen 1-2 elec in Behnke Fried electrodes

if debugging
    figure
    scatter(crd(:,1),crd(:,2))
    axis image; xlabel x; ylabel y;
    title('2D projection')
end

if  (rows == 1 || cols == 1)   %depth or strip 
    posUnifDist=defineStrip(linFun,rows*cols,[min(crd(:,1)) max(crd(:,1))]); % 2D position for electrodes
    posUnifDist=[posUnifDist, zeros(size(posUnifDist(:,1)))]; % add zeros for z
    adjMat=makeAdjMat(rows,cols);
    
    % define ideal distance for 2D
    if ~depth_BF
        posIdeal2D =( 0:M1:((rows*cols)-1)*M1)'; 
        d_ij_0_2D=eucDistMat(posIdeal2D,posIdeal2D);        % distance between all electrodes in the 2D model
    else
        % BF models have the 1st-2nd elec closer at the tip
        % crd are transformed so X dimension increases from in(target) to out.
        posIdeal2D =[0 M1_BF:M1:(((rows*cols)-2)*M1)+M1_BF]';
        d_ij_0_2D=eucDistMat(posIdeal2D,posIdeal2D);        % distance between all electrodes in the 2D model
    end
    posIdeal= zeros(rows*cols,3); % used in gridMatchEnergy & distance constrain function
    posIdeal(:,1) = posIdeal2D;   % works for BF electrodes


    if strcmp(options.type,'strip')
        rows_3D = 3;
        cols_3D = 2 * max(rows,cols) -1;
        M1_3D=M1/2;

        %add intermediate points
        posCenter = [posIdeal2D ; mean(cat(3,posIdeal2D(1:end-1,:),posIdeal2D(2:end,:)),3)];
        posCenter = [posCenter, zeros(size(posCenter)), zeros(size(posCenter))];
        [~,ix]=sort([1:2:cols_3D 2:2:cols_3D]);
        posCenter = posCenter (ix,:);
        
        % add lateral points on the y axes
        posUp_L = posCenter;
        posUp_L(:,2) = posUp_L(:,2) + M1_3D;        
        posUp_R = posCenter;
        posUp_R(:,2) = posUp_R(:,2) - M1_3D;     
        posUp = [posUp_L; posCenter; posUp_R];
        
        posDown = posUp;
        posUp(:,3) = posUp(:,3) + options.thickness /2;
        posDown(:,3) = posDown(:,3) - options.thickness /2;
        posIdeal3D = [posUp; posDown];
        d_ij_0_3D=eucDistMat(posIdeal3D,posIdeal3D);        % distance between all electrodes in the 3D ideal model

        %scatter3(posIdeal3D(:,1),posIdeal3D(:,2),posIdeal3D(:,3))
        
    elseif strcmp(options.type,'depth')    
        % no 3D model for depths
    end

else %grid
    tempDeb=debugging; % avoid debugging for a few lines
    debugging = 0;
    % find corners
    [north,south,east,west]=findCornersGrid(crd,rows,cols,options);
    
    % define ideal grid p (uniformly distributed - IED will not be acurate)
    posUnifDist = defineGrid(north,east,west,south,rows,cols); % 2D position for electrodes
    adjMat = makeAdjMat(rows,cols);    
    debugging=tempDeb;
    
    % define ideal distance for 2D grid
    posIdeal2D = defineGrid([0 (rows-1)*M1 0],[(cols-1)*M1 (rows-1)*M1 0],[0 0 0],[(cols-1)*M1 0 0],rows,cols);
    d_ij_0_2D=eucDistMat(posIdeal2D,posIdeal2D);        % distance between all electrodes in the 2D model
    
    posIdealUp = posIdeal2D;
    posIdealDown = posIdeal2D;
    posIdealUp(:,3) = posIdealUp(:,3) + options.thickness /2;
    posIdealDown(:,3) = posIdealDown(:,3) - options.thickness /2;

    posIdeal3D = [posIdealUp; posIdealDown];
    d_ij_0_3D=eucDistMat(posIdeal3D,posIdeal3D);        % distance between all electrodes in the 3D ideal model
    
end
options.minDef1.indexElecGrid = 1:(rows*cols);


%% Rotate posUnifDist to match NailElectrodes (if present)

if debugging
    figure;
    for l=1:rows*cols
        scatter3(posUnifDist(l,1),posUnifDist(l,2),posUnifDist(l,3),'.'); hold on;
        text(posUnifDist(l,1),posUnifDist(l,2),posUnifDist(l,3),num2str(l))
    end
    
    for l=1:length(options.NailElectrodeNumber)
        scatter3(options.NailElectrodeCrd(l,1),options.NailElectrodeCrd(l,2),options.NailElectrodeCrd(l,3),'.'); hold on;
        text(options.NailElectrodeCrd(l,1),options.NailElectrodeCrd(l,2),options.NailElectrodeCrd(l,3),num2str(options.NailElectrodeNumber(l)))
    end
    title('before')
end


if ~isempty(options.NailElectrodeNumber)
    
    aligned_grid_temp=posUnifDist;
    
    md = inf;
    if rows~=cols
        for j=1:2
            for i=1:2
                newOrder=1:rows*cols;
                newOrder=permute(reshape(newOrder,cols,rows),[2 1]);
                newOrder=permute(flipud(newOrder),[2 1]);
                aligned_grid_temp=aligned_grid_temp(newOrder,:);
                
                temp=sum(eucDist(options.NailElectrodeCrd,aligned_grid_temp(options.NailElectrodeNumber,:))); % distance to pattern
                if temp<md
                    md=temp;
                    aligned_cords=aligned_grid_temp;
                end
                
            end
            newOrder=1:rows*cols;
            newOrder=permute(reshape(newOrder,cols,rows),[2 1]);
            newOrder=permute(fliplr(newOrder),[2 1]);
            aligned_grid_temp=aligned_grid_temp(newOrder,:);
        end
    else
        
        for j=1:2
            for i=1:4
                newOrder=1:rows*cols;
                newOrder=permute(reshape(newOrder,cols,rows),[2 1]);
                newOrder=permute(rot90(newOrder),[2 1]);
                aligned_grid_temp=aligned_grid_temp(newOrder,:);
                
                temp=sum(eucDist(options.NailElectrodeCrd,aligned_grid_temp(options.NailElectrodeNumber,:))); % distance to pattern
                %
                %                 figure;
                %                 for l=1:rows*cols
                %                     scatter3(aligned_grid_temp(l,1),aligned_grid_temp(l,2),aligned_grid_temp(l,3),'.'); hold on;
                %                     text(aligned_grid_temp(l,1),aligned_grid_temp(l,2),aligned_grid_temp(l,3),num2str(l))
                %                 end
                %                 title ([num2str(i) '-' num2str(j) ' - ' num2str(temp)])
                
                
                if temp<md
                    md=temp;
                    aligned_cords=aligned_grid_temp;
                end
                
                
            end
            newOrder=1:rows*cols;
            newOrder=permute(reshape(newOrder,cols,rows),[2 1]);
            newOrder=permute(fliplr(newOrder),[2 1]);
            aligned_grid_temp=aligned_grid_temp(newOrder,:);
        end
        
        
    end
    
    % replace previous
    posUnifDist = aligned_cords;
    
end


if debugging
    figure;
    for l=1:rows*cols
        scatter3(posUnifDist(l,1),posUnifDist(l,2),posUnifDist(l,3),'.'); hold on;
        text(posUnifDist(l,1),posUnifDist(l,2),posUnifDist(l,3),num2str(l))
    end
    
    for l=1:length(options.NailElectrodeNumber)
        scatter3(options.NailElectrodeCrd(l,1),options.NailElectrodeCrd(l,2),options.NailElectrodeCrd(l,3),'.'); hold on;
        text(options.NailElectrodeCrd(l,1),options.NailElectrodeCrd(l,2),options.NailElectrodeCrd(l,3),num2str(options.NailElectrodeNumber(l)),'color','red')
    end
    title('after')
end


%% ploting posUnifDist and cloud of voxels
if debugging
    figure;
    scatter3(posUnifDist(:,1),posUnifDist(:,2),posUnifDist(:,3),80,'filled', 'k'); hold on; %plot electrodes
    axis image
    r = triu(adjMat)>0;
    for i=1:length(r)
        for j=1:length(r)
            if r(i,j) 
                s = posUnifDist(i,:); e = posUnifDist(j,:); l = [s ; e];
                line(l(:,1),l(:,2),l(:,3));
            end
        end
    end
    scatter3(crd(:,1),crd(:,2),crd(:,3),10,brushWeight,'filled'); hold on;
    axis image; legend('crd cloud','uniform dist')
    title('Uniform distributed grid 2D')
end

%% compute entropy and curvature - not used, yet?

% entropy(crd(:,[1 2])); % the higher the value, the noisier the data. Only
% 2D projection is used here.
%
% var(crd(:,3)) / options.fixM1; % the higher the value, the more curvature
% is present. This measure is sensitive to noise levels.
%
% Better is to measure the normalized area under of the smooth surface to z=0
% zSurf=surfFun(crd(:,1),crd(:,2));
% mean(abs(zSurf)) / options.fixM1;

%% ////////////////////////////////////////////////////////////////////////
%%  FIRST MINIMIZATION
%%  find min energy with constrains to smooth surface and penalizing translation

disp('performing first minimization')

pos_0=posUnifDist; % original coordinate

% optionsDef.lambda = 1/(M1/2);
options.minDef1.sigma = M1 * options.minDef1.sigmaRatio; %M1
options.minDef1.DCT=0; 
options.minDef1.model=options.minDef1.model; %2D for now works
options.minDef1.NailElectrodeNumber=options.NailElectrodeNumber;
options.minDef1.NailElectrodeCrd=options.NailElectrodeCrd;

% interelectrode distance - works for BF as well
d_ij_0=d_ij_0_2D;  
%d_ij_0=zeros(size(adjMat));
%d_ij_0((adjMat==1))=M1;
%d_ij_0((adjMat==2))=M2; %d_ij_0((adjMat==3))=M3;
d_ij_0((adjMat==0))=0;

f = @(x)gridMatchEnergy(x,pos_0,crd,brushWeight,d_ij_0,adjMat,options.minDef1);

% search options
optionsMin1=optimoptions(@fmincon);
optionsMin1.Display='iter';
optionsMin1.Algorithm= 'interior-point';
optionsMin1.TolCon=options.minDef1.tolCon;  % error distance to mesh (surfFun)
optionsMin1.MaxFunEvals=options.minDef1.MaxFunEvals;
optionsMin1.TolX=M1*options.minDef1.TolX;
optionsMin1.TypicalX=pos_0+rand(size(pos_0))*1e-6;
optionsMin1.UseParallel=options.minDef1.UseParallel;



if rows == 1 || cols == 1 % non linear constrain function - Line :-)
    nonlcon = @(x)linFunDistanceConstrain(x,linFun);
else
    % non linear constrain function - Surface :-)
     nonlcon = @(x)surfFunDistanceConstrain(x,surfFun);
end

tic;
[pos_constrained,~] = fmincon(f,pos_0,[],[],[],[],[],[],nonlcon,optionsMin1); %position constrained to surface
tt=toc;

disp(['First minimization completed in ' num2str(round(tt)) ' seconds'])

%% ploting first minimization results
if debugging
    f1=figure;
    scatter3(pos_constrained(:,1),pos_constrained(:,2),pos_constrained(:,3),20,'filled', 'k'); hold on; %plot electrodes axis image
    r = triu(adjMat)>0;
    for i=1:length(r)
        for j=1:length(r)
            if r(i,j) 
                s = pos_constrained(i,:); e = pos_constrained(j,:); l = [s ; e];
                line(l(:,1),l(:,2),l(:,3));
            end
        end
    end
    scatter3(crd(:,1),crd(:,2),crd(:,3),10,brushWeight,'filled'); hold on;
    axis image; legend('crd cloud','ideal')
    title('First minimization  - constrained')

    annotation(f1,'textbox',[0.2 0.7 0.1 0.1],'String',...
        {'M1',M1, 'kt', options.minDef1.Kt, 'kd', options.minDef1.Kd, 'kc', options.minDef1.Kc,...
        'sigma ratio',  options.minDef1.sigmaRatio},'FitBoxToText','on');

    disp('Energy')
    gridMatchEnergy(pos_constrained,pos_0,crd,brushWeight,d_ij_0,adjMat,options.minDef1)
    
    if rows == 1 || cols == 1
        linFunDistanceConstrain(pos_constrained,linFun)
    else
        surfFunDistanceConstrain(pos_constrained,surfFun)
    end
%    savefig(f1,[num2str(rows) 'x' num2str(cols) '_firstMin']);
end

%% ////////////////////////////////////////////////////////////////////////
%%  SECOND MINIMIZATION
%%  find min energy without constrain and penalizing translation

%% difine ideal grid as a 3D object with up and down nodes from previous localization
if strcmp (options.minDef2.model, '3D')
    if strcmp (options.type,'grid')
        
        posUp = pos_constrained;
        posDown = pos_constrained;
        posUp(:,3) = pos_constrained(:,3) + options.thickness /2;
        posDown(:,3) = pos_constrained(:,3) - options.thickness /2;
        pos_constrained3D = [posUp; posDown];
        
        % indices in the grid that will represent the electrodes pointwise - only the posDown
        indexElecGrid = size(pos_constrained,1) + [1:size(pos_constrained,1)];
        options.minDef2.indexElecGrid = indexElecGrid;

        options.minDef2.NailElectrodeNumber=[];%size(pos_constrained,1) + options.NailElectrodeNumber; %point to posDown electrodes
        options.minDef2.NailElectrodeCrd=[];%options.NailElectrodeCrd;
                
        adjMat = makeAdjMat(rows,cols,options.minDef2); % 3D adjacency Matrix
        
    elseif  strcmp (options.type,'strip')
        
        % redifine M1 for simplicity
        original_M1=M1;
        original_rows = rows;
        original_cols = cols;
        
        rows = 3;
        cols = 2 * max(original_rows,original_cols) -1;
        M1=M1/2;
        M2 = M1*sqrt(2); % diagonals
        M3 = M1*2;       % second neigbours
        M4 = options.thickness;                      % in between layer up-down z-axis
        M5 = sqrt (options.thickness ^2 + M1^2);     % in between layer orthogonal
        M6 = sqrt (options.thickness ^2 + M1^2 + M1^2);

        adjMat = makeAdjMat(rows,cols,options.minDef2); % 3D adjacency Matrix
                       
        %add intermediate points
        posCenter = [pos_constrained ; mean(cat(3,pos_constrained(1:end-1,:),pos_constrained(2:end,:)),3)];
        [~,ix]=sort([1:2:cols 2:2:cols]);
        posCenter = posCenter (ix,:);
        % add lateral points on the y axes
        posUp_L = posCenter;
        posUp_L(:,2) = posUp_L(:,2) + M1;        
        posUp_R = posCenter;
        posUp_R(:,2) = posUp_R(:,2) - M1;     
        posUp = [posUp_L; posCenter; posUp_R];
        
        posDown = posUp;
        posUp(:,3) = posUp(:,3) + options.thickness /2;
        posDown(:,3) = posDown(:,3) - options.thickness /2;
        pos_constrained3D = [posUp; posDown];
        
        % indices in the grid that will represent the electrodes pointwise - only the posDown
        indexElecGrid = rows*cols + cols + [1:2:cols];
        options.minDef2.indexElecGrid = indexElecGrid;          
        
        options.minDef2.NailElectrodeNumber=[];%options.NailElectrodeNumber; 
        options.minDef2.NailElectrodeCrd=[];%options.NailElectrodeCrd;
        
        
    elseif strcmp (options.type,'depth')
        error('3D model not defined for depth electrodes');
    end
    % ploting
    if debugging
        f1=figure;
        scatter3(pos_constrained3D(:,1),pos_constrained3D(:,2),pos_constrained3D(:,3),20,'filled', 'k'); hold on; %plot electrodes axis image
        scatter3(pos_constrained(:,1),pos_constrained(:,2),pos_constrained(:,3),20,'filled', 'r'); hold on; % localized in 1st run
        r = triu(adjMat)>0;
        colors = [0 0 0; 0 0 1; 0 1 0; 0 1 1; 1 0 0; 1 0 1];
        for i=1:length(r)
            for j=1:length(r)
                if r(i,j)
                    s = pos_constrained3D(i,:); e = pos_constrained3D(j,:); l = [s ; e];
                    line(l(:,1),l(:,2),l(:,3),'color',colors(adjMat(i,j),:),'linewidth',2);
                end
            end
        end
        scatter3(crd(:,1),crd(:,2),crd(:,3),10,brushWeight,'filled'); hold on;
        axis image; legend('crd cloud','ideal')
        title('Ideal grid 3D')
    end
    pos_0 = pos_constrained3D; %  coordinates for minimization
    
    disp('performing second minimization using 3D model')

%% difine ideal grid/depth as a 2D/1D object
else 
    if strcmp (options.minDef2.model, '1D_fix')
        
        %posIdeal = zeros(rows*cols,3);
        %posIdeal(:,1) =( 0:M1:((rows*cols)-1)*M1)'; 
        % compute translation
        t=pos_constrained(1,:); 
        % pos_constrained and posIdeal are along the x axis. No rotation
        % needed
        pos_0 = [t 1 0 0 0]; % [tx ty tz p0 p1 p2 p3]; % no translation, no rotation

        options.minDef2.posIdeal = posIdeal;   % works for BF electrodes
        disp('performing second minimization using 1D_fix model')

    else
        pos_0 = pos_constrained;
        disp('performing second minimization using 2D model')
    end
    
    indexElecGrid = 1:size(pos_constrained,1); % indices in the grid that will represent the electrodes pointwise - all points
    options.minDef2.indexElecGrid = indexElecGrid;    
    options.minDef2.NailElectrodeNumber=options.NailElectrodeNumber; %point to posDown electrodes
    options.minDef2.NailElectrodeCrd=options.NailElectrodeCrd;
    
    % ploting
    if debugging
        f1=figure;
        scatter3(pos_constrained(:,1),pos_constrained(:,2),pos_constrained(:,3),20,'filled', 'k'); hold on; %plot electrodes axis image
        r = triu(adjMat)>0;
        for i=1:length(r)
            for j=1:length(r)
                if r(i,j)
                    s = pos_constrained(i,:); e = pos_constrained(j,:); l = [s ; e];
                    line(l(:,1),l(:,2),l(:,3));
                end
            end
        end
        scatter3(crd(:,1),crd(:,2),crd(:,3),10,brushWeight,'filled'); hold on;
        axis image; legend('crd cloud','pos constrained')
        title('Ideal grid 2D')
    end   

end

%% minimization    
options.minDef2.M1=M1;
options.minDef2.sigma = M1 * options.minDef2.sigmaRatio; %M1/2
options.minDef2.model = options.minDef2.model;
options.minDef2.DCT = options.DCT;
options.minDef2.rows=rows; 
options.minDef2.cols=cols; 

% inter-electrode distance ideal 
if ~depth_BF
    d_ij_0=zeros(size(adjMat));
    d_ij_0((adjMat==1))=M1;  
    d_ij_0((adjMat==2))=M2; 
    d_ij_0((adjMat==3))=M3; %only used in 2D
    d_ij_0((adjMat==4))=M4; %only used in 3D
    d_ij_0((adjMat==5))=M5; %only used in 3D
    d_ij_0((adjMat==6))=M6; %only used in 3D
else  % BF interelectrode distance
    d_ij_0=d_ij_0_2D;
    d_ij_0((adjMat==0))=0;
end

f = @(x)gridMatchEnergy(x,pos_0,crd,brushWeight,d_ij_0,adjMat,options.minDef2);

% search options
optionsMin2=optimoptions(@fmincon);
optionsMin2.Display='iter';
optionsMin2.Algorithm= 'interior-point'; % consider X for faster results. /'active-set' not really working faster / 'sqp' need too much memory /. 
% Interior point is usssing a barrier function to deal with constrains.
% Active set ussees

optionsMin2.MaxFunEvals=options.minDef2.MaxFunEvals;
optionsMin2.TolX=M1 * options.minDef2.TolX;
optionsMin2.MaxIterations = options.minDef2.MaxIterations;

optionsMin2.TypicalX=pos_0+rand(size(pos_0))*1e-6;
optionsMin2.UseParallel=options.minDef2.UseParallel;

if strcmp (options.minDef2.model, '2D')
    if strcmp (options.constrain_type, 'none')
        nonlcon = [];
    elseif strcmp (options.constrain_type, 'distance')
        nonlcon = @(x)distanceConstrain(x,d_ij_0_2D,adjMat,options.NailElectrodeNumber,options.NailElectrodeCrd,[]);
        optionsMin2.TolCon = options.minDef2.tolCon * M1;  %constrain error  % distance constrain error 1 percent M1
    elseif strcmp (options.constrain_type, 'volume')
        error('volume constrain not defined for 2D model')
    elseif strcmp (options.constrain_type, 'volume_distance')
        error('volume constrain not defined for 2D model')
    end

elseif strcmp (options.minDef2.model, '1D_fix')
    if strcmp (options.constrain_type, 'none')
        nonlcon = [];
    elseif strcmp (options.constrain_type, 'distance')
        nonlcon = @(x)distanceConstrain(x,d_ij_0_2D,adjMat,options.NailElectrodeNumber,options.NailElectrodeCrd,options.minDef2.model,options.minDef2.posIdeal);
        optionsMin2.TolCon = options.minDef2.tolCon * M1;  %constrain error  % distance constrain error 1 percent M1
    elseif strcmp (options.constrain_type, 'volume')
        error('volume constrain not defined for 1D_fix model')
    elseif strcmp (options.constrain_type, 'volume_distance')
        error('volume constrain not defined for 1D_fix model')
    end
    
    
else % 3D model
    if strcmp (options.type,'depth')
        error('3D model not defined for depth electrodes. Change settings.');
    else 
        optionsMin2.TolCon=options.minDef2.tolCon;  %constrain error
        if strcmp (options.constrain_type, 'none')
            nonlcon = [];
        elseif strcmp (options.constrain_type, 'volume')
            cuboidsInd = makeCouboidsInd(rows,cols);
            vol_0 = ones(size(cuboidsInd,1),1) * M1 * M1 * options.thickness; % original volume
            nonlcon = @(x)gridVolumeConstrain(x,vol_0,cuboidsInd); %volume constrain only
        elseif strcmp (options.constrain_type, 'volume_distance')
            cuboidsInd = makeCouboidsInd(rows,cols);
            vol_0 = ones(size(cuboidsInd,1),1) * M1 * M1 * options.thickness; % original volume           
            nonlcon = @(x)gridVolumeDistanceConstrain(x,vol_0,cuboidsInd,d_ij_0_3D,adjMat,indexElecGrid(options.NailElectrodeNumber),options.NailElectrodeCrd); %volume, distance , and nail constrain
        elseif strcmp (options.constrain_type, 'distance')
            nonlcon = @(x)distanceConstrain(x,d_ij_0_3D,adjMat,size(pos_constrained,1) + options.NailElectrodeNumber,options.NailElectrodeCrd,[]);
            optionsMin2.TolCon = options.minDef2.tolCon * M1;  %constrain error  % distance constrain error 1 percent M1
        end
    end
end

if options.DCT
    optionsMin2.TolX=M1*1e-6;
    pos_x = zeros(rows,cols); 
    pos_y = zeros(rows,cols);
    pos_z= zeros(rows,cols);
   
    % fill the 2D representation of pos 
    pos_x(1:end) = pos_0(:,1); % make 2D
    pos_y(1:end) = pos_0(:,2); % make 2D
    pos_z(1:end) = pos_0(:,3); % make 2D

    posDCT_X = dct2(pos_x); 
    posDCT_Y = dct2(pos_y); 
    posDCT_Z = dct2(pos_z); 
    
    posDCT = [posDCT_X(:), posDCT_Y(:), posDCT_Z(:)];

    if debugging
        f1=figure;
        subplot(1,3,1); imagesc(log10(pow2(posDCT_X))); colorbar;
        subplot(1,3,2); imagesc(log10(pow2(posDCT_Y))); colorbar;
        subplot(1,3,3); imagesc(log10(pow2(posDCT_Z))); colorbar;
        title('DCT coef 1st fit' )
    end
    
    tic;
    [pos_fix2DCT,~,exitflag] = fmincon(f,posDCT,[],[],[],[],[],[],nonlcon,optionsMin2);
    tt=toc;

    % anti transform
    posDCT_X = zeros(rows,cols); 
    posDCT_Y = zeros(rows,cols);
    posDCT_Z = zeros(rows,cols);
   
    % fill the 2D representation of DCT 
    posDCT_X(1:end) = pos_fix2DCT(:,1); % make 2D
    posDCT_Y(1:end) = pos_fix2DCT(:,2); % make 2D
    posDCT_Z(1:end) = pos_fix2DCT(:,3); % make 2D
    
    if debugging 
        %posDCT_X(2:end,2:end)=0; % ->less than 1mm max error in 10mm grid
        %posDCT_Y(2:end,2:end)=0; % ->less than 1mm max error in 10mm grid
        posDCT_X(3:end,3:end)=0; % ->less than 1mm max error in 10mm grid
        posDCT_Y(3:end,3:end)=0; % ->less than 1mm max error in 10mm grid
        %posDCT_Z = zeros(rows,cols); -> big errors
    end
    
    % anti transform
    pos_x  = idct2(posDCT_X);
    pos_y  = idct2(posDCT_Y);
    pos_z  = idct2(posDCT_Z);
    
    % merge x y z
    pos_fix2 = [pos_x(:), pos_y(:), pos_z(:)];

    if debugging
        f1=figure;
        subplot(2,3,1); imagesc(pos_x); colorbar; 
        subplot(2,3,2); imagesc(pos_y); colorbar; 
        subplot(2,3,3); imagesc(pos_z); colorbar; 
        
        subplot(2,3,4); imagesc(log10(pow2(posDCT_X))); colorbar; caxis([0 50]);
        subplot(2,3,5); imagesc(log10(pow2(posDCT_Y))); colorbar; caxis([0 50]);
        subplot(2,3,6); imagesc(log10(pow2(posDCT_Z))); colorbar; caxis([0 10]);
        title('DCT coef 2nd fit' )
    end
    
elseif strcmp(options.minDef2.model, '1D_fix')
    tic;
    [pos_fixQuat,~,exitflag] = fmincon(f,pos_0,[],[],[],[],[],[],nonlcon,optionsMin2);
    % compute full model postions
    t=pos_fixQuat(1:3);
    q=pos_fixQuat(4:7);
    pos_fix2=quatrotate(q,posIdeal+t);   
    tt=toc;
    
else
    tic;
    [pos_fix2,~,exitflag] = fmincon(f,pos_0,[],[],[],[],[],[],nonlcon,optionsMin2);
    tt=toc;
end


switch exitflag
    case {1,2} 
        disp(['Second minimization completed in ' num2str(round(tt)) ' seconds with no errors'])
    case 0  
        warning('GridFit solution might be inacurate. Algorithm stopped due to too many function evaluations or iterations.')
        disp('You can change GridFit parameters in priv/default_ielectrodes_options.m, update configuration in iElectrodes, and try again.')
    case -1 
        warning('GridFit solution might be inacurate. Algorithm stopped by output/plot function.')
        disp('You can change GridFit parameters in priv/default_ielectrodes_options.m,update configuration in iElectrodes, and try again.')
    case -2 
        warning('GridFit solution might be inacurate. No feasible point found.')
        disp('You can change GridFit parameters in priv/default_ielectrodes_options.m, update configuration in iElectrodes, and try again.')
end

pos_elec = pos_fix2(indexElecGrid,:);

if strcmp (options.type,'strip') & strcmp (options.minDef2.model, '3D')
    if debugging
        f1=figure;
        scatter3(pos_fix2(:,1),pos_fix2(:,2),pos_fix2(:,3),20,'filled', 'r'); hold on; %plot electrodes axis image
        %     scatter3(pos_elec(:,1),pos_elec(:,2),pos_elec(:,3),80,'filled', 'k'); hold on; %plot electrodes axis image
        adjMat = makeAdjMat(rows,cols,options.minDef2);
        r = triu(adjMat)>0;
        for i=1:length(r)
            for j=1:length(r)
                if r(i,j)
                    s = pos_fix2(i,:); e = pos_fix2(j,:); l = [s ; e];
                    line(l(:,1),l(:,2),l(:,3));
                end
            end
        end
        scatter3(crd(:,1),crd(:,2),crd(:,3),10,brushWeight,'filled'); hold on;
        axis image; legend('grid','elec','crd')
        
        title('Second minimization - not constrained to surface')
        annotation(f1,'textbox',[0.2 0.7 0.1 0.1],'String',...
            {'M1',M1, 'kt', options.minDef2.Kt, 'kd', options.minDef2.Kd, 'kc', options.minDef2.Kc,...
            'sigma ratio',  options.minDef2.sigmaRatio},'FitBoxToText','on');
        disp('Energy')
        gridMatchEnergy(pos_fix2,pos_0,crd,brushWeight,d_ij_0,adjMat,options.minDef2)
    end
    
    M1 = original_M1;
    rows = original_rows;
    cols  = original_cols;
    
    M2 = M1*sqrt(2); % diagonals
    M3 = M1*2;       % second neigbours
    M4 = options.thickness;                      % in between layer up-down z-axis
    M5 = sqrt (options.thickness ^2 + M1^2);     % in between layer orthogonal
    M6 = sqrt (options.thickness ^2 + M1^2 + M1^2);
    
    adjMat = makeAdjMat(rows,cols,options.minDef2); % 3D adjacency Matrix
end


%% output electrodes structure with fixed coords

if debugging
    f1=figure;
    scatter3(pos_fix2(:,1),pos_fix2(:,2),pos_fix2(:,3),20,'filled', 'r'); hold on; %plot electrodes axis image
%     scatter3(pos_elec(:,1),pos_elec(:,2),pos_elec(:,3),80,'filled', 'k'); hold on; %plot electrodes axis image
    adjMat = makeAdjMat(rows,cols,options.minDef2);
    r = triu(adjMat)>0;
    for i=1:length(r)
        for j=1:length(r)
            if r(i,j) 
                s = pos_fix2(i,:); e = pos_fix2(j,:); l = [s ; e];
                line(l(:,1),l(:,2),l(:,3));
            end
        end
    end
    scatter3(crd(:,1),crd(:,2),crd(:,3),10,brushWeight,'filled'); hold on;
    axis image; legend('grid','elec','crd')

    title('Second minimization - not constrained to surface')
    annotation(f1,'textbox',[0.2 0.7 0.1 0.1],'String',...
        {'M1',M1, 'kt', options.minDef2.Kt, 'kd', options.minDef2.Kd, 'kc', options.minDef2.Kc,...
        'sigma ratio',  options.minDef2.sigmaRatio},'FitBoxToText','on');
%     disp('Energy')
%     gridMatchEnergy(pos_fix2,pos_0,crd,brushWeight,d_ij_0,adjMat,options.minDef2)
    
    %%plot projection mesh
    %plot(surfFun, [crd(:, 1), crd(:, 2)], crd(:, 3));
    axis image
    %savefig(f1,[num2str(rows) 'x' num2str(cols) '_secondMin']);

    
    f1=figure;
    d=eucDistMat(pos_elec,pos_elec);
    d1=d;
    d2=d;
    adjMat = makeAdjMat(rows,cols);
    d1(~(adjMat==1))=nan;
    d2(~(adjMat==2))=nan;
    subplot(1,2,1)
    hist(d1(:)./M1,10);
    title 'normalized inter-electrode 1st neig distance '
    subplot(1,2,2)
    hist(d2(:)./M2,10);
    title 'normalized inter-electrode diagonal distance '
    %savefig(f1,[num2str(rows) 'x' num2str(cols) '_secondMin_histogram']);
    
end
%% rotate coords to original system
pos_elec=[pos_elec(:,1)+L(:,1),pos_elec(:,2)+L(:,2),pos_elec(:,3)+L(:,3)]; %center the data

gridCords=(T'\pos_elec')'; %solves: pos_elec*inv(T);

% Threshold distance used for gaussian correlation
dThr = M1 * 2 * options.minDef2.sigmaRatio; 

% compute clustered coordinates and cluster number
clusteredCrd = [];
clusters=[];
clusteredWeight=[];
allClustered =false(1,size(brushCrd,1));
    
for j=1: rows*cols

    l=eucDistMat(gridCords(j,:),brushCrd) < dThr; % logical index to original data
    
    clusteredCrd = [clusteredCrd; brushCrd(l,:) ];
    clusteredWeight=[clusteredWeight; brushWeight(l)];
    clusters=[clusters; j * ones(sum(l),1)];
    
    allClustered = allClustered | l;

end

% add non-clusterd Crd
clusteredCrd =  [clusteredCrd; brushCrd(~allClustered,:) ]; % add non clustered at the end
clusteredWeight =  [clusteredWeight; brushWeight(~allClustered,:) ]; % add non clustered at the end
clusters=[clusters; nan * ones(sum(~allClustered),1)]; % NaN at tje 
