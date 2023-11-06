function [addPos,addNormalVec]=simulateOverlaps(pos,normalVec,options)
% this function will define random coordinates of overlaping electrodes to
% an existing grid or strips electrode
% 
% not defined for SEEG 
%
% pos                   electrodes posiotion (Nx3)
% normalVec             normal vector at each position (Nx3) /grids)
% options.adjMat        adjacency matrix 
% options.rows          number of rows
% options.cols          number of cols
% options.fractionAdd   fraction 0-1 of electrodes to add.
% options.type          'grid' / 'depth' / 'strip'
% options.SCEpoints      SCE points in the vecinity of strips 


rows = options.rows;
cols = options.cols;
fractionOverlapAdd = options.fractionOverlapAdd;
adjMat = options.adjMat;
M1 = options.M1;       %inter-electrode distance

Nadd = max(round (rows * cols * fractionOverlapAdd),1); % number of overlap electrodes. At least 1

posOrig = pos;

rng('shuffle'); % avoid random numbers to repeat
%% rotate and center the coordinates

if strcmp (options.type, 'grid' )
    T=pca(pos);    % rotation matrix. First 2 cols have the bigger variance
    R=[cos(pi/4) -sin(pi/4) 0; sin(pi/4) cos(pi/4) 0; 0 0 1]; % rotate 45 degrees over z axis
    T = T*R;
    pos=pos*T;     % rotated data
    
    
    L=mean(pos);
    pos=[pos(:,1)-L(:,1),pos(:,2)-L(:,2),pos(:,3)-L(:,3)]; %center the data

elseif strcmp (options.type, 'strip' )

    T=pca(options.SCEpoints);    % rotation matrix. First 2 cols have the bigger variance
    R=[cos(pi/4) -sin(pi/4) 0; sin(pi/4) cos(pi/4) 0; 0 0 1]; % rotate 45 degrees over z axis
    T = T*R;
    pos=pos*T;     % rotated data
    options.SCEpoints = options.SCEpoints*T;
        
    L=mean(pos);
    pos=[pos(:,1)-L(:,1),pos(:,2)-L(:,2),pos(:,3)-L(:,3)]; %center the data
    options.SCEpoints =[options.SCEpoints(:,1)-L(:,1),options.SCEpoints(:,2)-L(:,2),options.SCEpoints(:,3)-L(:,3)]; %center the data
    
end


%% make surface

disp('Fitting surface to voxels')
if strcmp (options.type, 'grid' ) 
    surfFun = fit([pos(:, 1), pos(:, 2)], pos(:, 3), 'lowess'); % z = surfFun(x,y)
   
elseif strcmp (options.type, 'strip' ) 
    surfFun = fit([options.SCEpoints(:, 1), options.SCEpoints(:, 2)], options.SCEpoints(:, 3), 'lowess'); % z = surfFun(x,y)

end
% elseif strcmp (options.type, 'depth' )  %rows == 1 || cols == 1
%     linFun=fit(pos(:,1),pos(:,2),'poly3'); % fit a 3rd order polinomy to first 2 components of PCA data % y = linFun(x) 
% end

    
% plot
% figure;
% h=plot(surfFun); hold on;
% scatter3(pos(:,1),pos(:,2),pos(:,3),30,'r','filled'); axis image; 
% xlabel('PC1 [mm]'); ylabel('PC2 [mm]'); zlabel('PC3 [mm]'); grid off;
% alpha 0.8

%% random rotate grid over z axis, 
randAngle = rand(1)*2*pi;
R=[cos(randAngle) -sin(randAngle) 0; sin(randAngle) cos(randAngle) 0; 0 0 1]; % rotate random degrees over z axis

% for simplicity, here we use a grid of the same size and dimensions
addPos=pos*R;     % rotated data

% figure;
% scatter3(pos(:,1),pos(:,2),pos(:,3),30,'r','filled'); axis image; hold on;
% scatter3(addPos(:,1),addPos(:,2),addPos(:,3),30,'b','filled'); 
% xlabel('PC1 [mm]'); ylabel('PC2 [mm]'); zlabel('PC3 [mm]'); grid off;

%% translate the grid in a random direction until X percents of the electrodes remains close enought to the originals (min dist <M1)
Tr= [rand(1) rand(1) 0];

Tr= Tr / norm(Tr) * M1; % size relative to M1

if strcmp (options.type, 'grid' )
    condition = 1;
    stepSize=0.01;
    while condition
        
        addPos = addPos + Tr * stepSize;
        
        D=sort(eucDistMat(addPos(:,1:2),pos(:,1:2)),2);
        C=sum(D(:,1:4)<sqrt(2)*M1,2);
        
        condition = sum(C==4) >= Nadd + 1; %number overlapping between 4 contacts
    end
    
    addPos(C~=4,:)=[];
    
elseif strcmp (options.type, 'strip' )
    
    condition = 1;
    stepSize=0.01;
    while condition
        
        addPos = addPos + Tr * stepSize;
        
        D=sort(eucDistMat(addPos(:,1:2),pos(:,1:2)),2);
%         C=sum(D(:,1:4)<sqrt(2)*M1,2); %distance to the closest 4 pos points < sqrt(2)*M1 ????
%         C=sum(D<sqrt(2)*M1,2); %distance to the closest pos points < sqrt(2)*M1 ????
         C=sum(D<3/4*M1,2); %distance to the closest pos points < 3/4*M1 ????
        
        condition = sum(C~=0) >= Nadd + 1; %number overlapping electrodes
    end
    
    addPos(C==0,:)=[];
     
end

addPos(:,3)=surfFun(addPos(:,1),addPos(:,2)) + 1; %additional 1mm on z axis

% figure;
% scatter3(pos(:,1),pos(:,2),pos(:,3),30,'r','filled'); axis image; hold on;
% scatter3(addPos(:,1),addPos(:,2),addPos(:,3),30,'b','filled'); 
% xlabel('PC1 [mm]'); ylabel('PC2 [mm]'); zlabel('PC3 [mm]'); grid off;

%% rotate coords to original system
addPos=[addPos(:,1)+L(:,1),addPos(:,2)+L(:,2),addPos(:,3)+L(:,3)]; %center the data

addPos=((T)'\addPos')'; %solves: newCrd*inv(T);

%% plot
% figure;
% scatter3(posOrig(:,1),posOrig(:,2),posOrig(:,3),30,'r','filled'); axis image; hold on;
% scatter3(addPos(:,1),addPos(:,2),addPos(:,3),30,'b','filled'); 
% xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]'); grid off;

%% todo compute normal interpolating from neigbours
D=eucDistMat(addPos(:,1:2),posOrig(:,1:2));
ind=D<M1; %to avoid errors
for i=1:size(addPos,1)
        addNormalVec(i,:) = exp(-D(i,ind(i,:))) * normalVec(ind(i,:)',:);
        addNormalVec(i,:) = addNormalVec(i,:) / norm(addNormalVec(i,:));
end
   
% quiver3(addPos(:,1),addPos(:,2),addPos(:,3), addPos(:,1)+addNormalVec(:,1),...
%     addPos(:,2)+addNormalVec(:,2), addPos(:,3)+addNormalVec(:,3),'g');
            

