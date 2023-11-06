function electrodes=electrodes2hullCorrection(electrodes,v_hull,f_hull, options, projDone)

% this function project grid electrodes to convex hull
% and then apply projection field to depth electrodes
% Usefull to correct for brain shift deformations due to grid implantation
%
% electrodes : electrodes cell array to modify
% electrodes.Type = 'depth' or 'grid' or 'strip'
% v_hull : hull vertices
% f_hull : hull faces
% projDone (optional) : indicates wich electrodes to exclude from project
% options.SCE_projection_method : projection to SCE method  
%                                'closestPoint' or 'springs' (Dykstra et al 2012 NeuroImage)


% electrodes.projection contains the projection coordinates (x,y,z) and displacement
% from orignal positions
% do anatomicLabel processing after.
%
% A Blenkmann 2016
%
% Updates
% Projections structure is same as electrodes structure
% 

global debugging;

if debugging 
    fig=figure;
    h=vis(v_hull,f_hull);
    alpha(h,.5); hold on;
end

% If projDone not defined as input argument, project all. 
if nargin<5
    projDone=zeros(1, length(electrodes));
end

projToDo=~logical(projDone);
indToDo=find(projToDo);

mesh.vertices=v_hull;
mesh.faces=f_hull;


%process grids first
for i=1:length(indToDo)
    
    if strcmp(electrodes{indToDo(i)}.Type,'grid') || strcmp(electrodes{indToDo(i)}.Type,'strip')
        posGrid_s=[electrodes{indToDo(i)}.x electrodes{indToDo(i)}.y electrodes{indToDo(i)}.z];
        
        %avoid NaN cordinates
        if ~sum(isnan(posGrid_s))
            
            % project
            SCE_projection_method = options.SCE_projection_method;
            
%             if strcmp(electrodes{indToDo(i)}.Type,'strip') && strcmp(SCE_projection_method,'CEPA')
%                 SCE_projection_method = 'springs'; % hybrid cant be used with strips
%             end

            if strcmp(electrodes{indToDo(i)}.Type,'strip') && strcmp(SCE_projection_method,'normal')
                SCE_projection_method = 'closestPoint'; % hybrid cant be used with strips
            end

            
            adjMat=makeAdjMat(electrodes{indToDo(i)}.rows,electrodes{indToDo(i)}.columns);
            
            optAM=[];
            optAM.model='connections';
            options.connMat = makeAdjMat(electrodes{indToDo(i)}.rows,electrodes{indToDo(i)}.columns, optAM);
            options.rows =  electrodes{indToDo(i)}.rows; 
            options.columns =  electrodes{indToDo(i)}.columns; 
            
            disp([' ///  Projecting Grid: ' electrodes{indToDo(i)}.Name] );
            tic;
            [posGrid_e,d]=projection2mesh(mesh,posGrid_s,SCE_projection_method,adjMat,options);                       
            disp(['Projection finished in : ' num2str(toc) ' seconds'] );
            
                   
            projectionElectrode = checkElectrodeStructure(); %make empty structure
            projectionElectrode=projectionElectrode{1}; %convert to structure
             % store results in the projection structure
%             electrodes{indToDo(i)}.projection.x=posGrid_e(:,1);
%             electrodes{indToDo(i)}.projection.y=posGrid_e(:,2);
%             electrodes{indToDo(i)}.projection.z=posGrid_e(:,3);
%             electrodes{indToDo(i)}.projection.displacement=d;
%             electrodes{indToDo(i)}.projection.nElectrodes=electrodes{indToDo(i)}.nElectrodes;%for compatibility with other methods
%             electrodes{indToDo(i)}.projection.rows=electrodes{indToDo(i)}.rows;%for compatibility with other methods
%             electrodes{indToDo(i)}.projection.columns=electrodes{indToDo(i)}.columns;%for compatibility with other methods
%             electrodes{indToDo(i)}.projection.ch_label=electrodes{indToDo(i)}.ch_label;%for compatibility with other methods
%             electrodes{indToDo(i)}.projection.Type=electrodes{indToDo(i)}.Type;%for compatibility with other methods

            projectionElectrode.x=posGrid_e(:,1);
            projectionElectrode.y=posGrid_e(:,2);
            projectionElectrode.z=posGrid_e(:,3);
            projectionElectrode.displacement=d;
            projectionElectrode.nElectrodes=electrodes{indToDo(i)}.nElectrodes;%for compatibility with other methods
            projectionElectrode.rows=electrodes{indToDo(i)}.rows;%for compatibility with other methods
            projectionElectrode.columns=electrodes{indToDo(i)}.columns;%for compatibility with other methods
            projectionElectrode.ch_label=electrodes{indToDo(i)}.ch_label;%for compatibility with other methods
            projectionElectrode.Type=electrodes{indToDo(i)}.Type;%for compatibility with other methods            
            projectionElectrode.space = [electrodes{indToDo(i)}.space]; % same space as before
            projectionElectrode.method = [' SCE_' SCE_projection_method];
            electrodes{indToDo(i)}.projection = {projectionElectrode}; % now is the only projection in the cell structure           
%           consider add to cell structure in the furure
%             electrodes{indToDo(i)}.projection = [electrodes{indToDo(i)}.projection , projectionElectrode]; 
            
%             posGrid_s_All=[posGrid_s_All;posGrid_s];
%             posGrid_e_All=[posGrid_e_All;posGrid_e];
            
            if debugging
                projectionsGrid =posGrid_e -posGrid_s;
                scatter3(posGrid_s(:,1),posGrid_s(:,2),posGrid_s(:,3),'b','filled');
                hold on;axis image;
                quiver3(posGrid_s(:,1),posGrid_s(:,2),posGrid_s(:,3),...
                    projectionsGrid(:,1),projectionsGrid(:,2),projectionsGrid(:,3),0,'b')
                plotElectrodesLines(posGrid_s,electrodes{indToDo(i)}.rows,electrodes{indToDo(i)}.columns,[0 0 1]);
                
            end
        end
    end
end

% save all grid transformations in this two matrices
posGrid_s_All=[];
posGrid_e_All=[];

for i=1:length(electrodes)
    if strcmp(electrodes{i}.Type,'grid') || strcmp(electrodes{i}.Type,'strip')
        
        posGrid_s=[electrodes{i}.x electrodes{i}.y electrodes{i}.z];
        posGrid_e=[electrodes{i}.projection{end}.x electrodes{i}.projection{end}.y electrodes{i}.projection{end}.z]; %use last projection in the cell array
        posGrid_s_All=[posGrid_s_All;posGrid_s];
        posGrid_e_All=[posGrid_e_All;posGrid_e];
    end
end


posDepth_s_All=[];
posDepth_e_All=[];

if isempty(posGrid_e_All) %skip if there were no grid electrodes projected
   warning('no grid electrodes to do projection');
else
    %process depths now
    for i=1:length(indToDo)
        
        if strcmp(electrodes{indToDo(i)}.Type,'depth')
            posDepth_s=[electrodes{indToDo(i)}.x electrodes{indToDo(i)}.y electrodes{indToDo(i)}.z];
            
            % estimate sigma
            % 2*sigma = grid electrodes - brain center average distance
            sigmaS=mean(eucDistMat(mean(mesh.vertices),posGrid_e_All))/2;
            sigmaR=5; % 5 mm
            
            % project using previous displacements
            
            disp([' ///  projecting depth electrode: ' electrodes{indToDo(i)}.Name] );
            [posDepth_e, d]=depthDisplacementCorrection(posDepth_s,posGrid_s_All,posGrid_e_All,sigmaR,sigmaS);
            
            projectionElectrode = checkElectrodeStructure(); %make empty structure
            projectionElectrode=projectionElectrode{1}; %convert to structure
            % store results in the projection structure
%             electrodes{indToDo(i)}.projection.x=posDepth_e(:,1);
%             electrodes{indToDo(i)}.projection.y=posDepth_e(:,2);
%             electrodes{indToDo(i)}.projection.z=posDepth_e(:,3);
%             electrodes{indToDo(i)}.projection.displacement=d;
% 
%             electrodes{indToDo(i)}.projection.nElectrodes=electrodes{indToDo(i)}.nElectrodes; %for compatibility with other methods
%             electrodes{indToDo(i)}.projection.rows=electrodes{indToDo(i)}.rows; %for compatibility with other methods
%             electrodes{indToDo(i)}.projection.columns=electrodes{indToDo(i)}.columns; %for compatibility with other methods
%             electrodes{indToDo(i)}.projection.ch_label=electrodes{indToDo(i)}.ch_label;%for compatibility with other methods
%             electrodes{indToDo(i)}.projection.Type=electrodes{indToDo(i)}.Type;%for compatibility with other methods
            projectionElectrode.x=posDepth_e(:,1);
            projectionElectrode.y=posDepth_e(:,2);
            projectionElectrode.z=posDepth_e(:,3);
            projectionElectrode.displacement=d;

            projectionElectrode.nElectrodes=electrodes{indToDo(i)}.nElectrodes; %for compatibility with other methods
            projectionElectrode.rows=electrodes{indToDo(i)}.rows;               %for compatibility with other methods
            projectionElectrode.columns=electrodes{indToDo(i)}.columns;         %for compatibility with other methods
            projectionElectrode.ch_label=electrodes{indToDo(i)}.ch_label;       %for compatibility with other methods
            projectionElectrode.Type=electrodes{indToDo(i)}.Type;               %for compatibility with other methods
            projectionElectrode.space = [electrodes{indToDo(i)}.space];         % allows for native or normalized
            projectionElectrode.method = 'SCE_projection_field';

            electrodes{indToDo(i)}.projection = {projectionElectrode}; % now is the only projection in the cell structure           
%           consider add to cell structure in the furure
%             electrodes{indToDo(i)}.projection = [electrodes{indToDo(i)}.projection , projectionElectrode]; 

            posDepth_s_All=[posDepth_s_All;posDepth_s];
            posDepth_e_All=[posDepth_e_All;posDepth_s];
            if debugging
                projectionsDepth =posDepth_e -posDepth_s;
                scatter3(posDepth_s(:,1),posDepth_s(:,2),posDepth_s(:,3),'r','filled');
                quiver3(posDepth_s(:,1),posDepth_s(:,2),posDepth_s(:,3),...
                    projectionsDepth(:,1),projectionsDepth(:,2),projectionsDepth(:,3),0,'r')
                
            end
        end
    end
end
