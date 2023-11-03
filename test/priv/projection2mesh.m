function [pos_mesh,d,indexMesh,normalVecFinal]=projection2mesh(mesh,pos,method,adjMat,options)
% project coordinates in pos (Px3) to the the mesh using differnt methods
% mesh.vertices (Mx3) 
% mesh.faces (Qx4) Last column indicate left(1) or right(2)
%
% method = 'closestPoint' (default) 
%          'springs' (Dykstra et al 2012, NeuroImage). A net of spirngs is deformed, fitting the surface with a minimum deformation energy
%          'normal' (Hermes et al 2010). Projection in the orthogonal direction of the electrodes. Works only for grids
%          'normal-SCE' 'Use the normal vector of the SCE surface within a radius (Kubanek et al., 2015)
%          'CEPA' (Blenkmann et al in preparation). A mix of the 'springs' and 'normal' methods
%          'realistic' (Blenkmann et al in preparation). A realistic 3D model with "springs". Used for planning purposes 
% adjMat : adjacency matrix (PxP) for springs  method
%
%
% Options for 'normal' method
% options.SCE_normal_projection.meshReduceL = 25; distance to look (mm)
%
%
% Options for 'normal-SCE' method
% options.SCE_normalSCE_projection.meshReduceL = 25; vertices included withing radius from electrode to compute normal (mm);
%
% options for 'springs' method
% options.SCE_springs_projection.K                  Energy ratio f = t + K d
% options.SCE_springs_projection.TolCon             Constrain Tolerance 
% options.SCE_springs_projection.RefineMesh         Refine Mesh before projection 1/0 
% options.SCE_springs_projection.meshReduceL = 20;  distance to look (mm)
% options.SCE_springs_projection.constrain= 'distance' / 'distance_deformation'
% options.SCE_springs_projection.d_ij_0 = d_ij_0    Use with distance_deformation constrain    
% options.SCE_springs_projection.UseParallel    

%
% options for 'CEPA' method
% options.SCE_CEPA_projection.Kt=1;           % translation
% options.SCE_CEPA_projection.Kd=1e3;         % deformation
% options.SCE_CEPA_projection.Ka=1e2;         % anchor deformation
% options.SCE_CEPA_projection.Ks=1e2;         % smoothness deformation
% options.SCE_CEPA_projection.Ka_weight =     % range [0 1]
% options.SCE_CEPA_projection.Kd_normal = 1.0; % (scalar) ratio of normal (1st neig) deformation
% options.SCE_CEPA_projection.Kd_shear = 0.5;  % (scalar) ratio of shear (diagonal neig) deformation
% options.SCE_CEPA_projection.Kd_bend  = 0.1;  % (scalar) ratio of bending (2nd neig) deformation
% options.SCE_CEPA_projection.RefineMesh          Refine Mesh before projection 1/0 
% options.SCE_CEPA_projection.meshReduceL=20;
% options.SCE_CEPA_projection.UseParallel   
% 
% options for 'realistic' method
% options.SCE_realistic_projection.K                 Energy ratio f = t + K d
% options.SCE_realistic_projection.RefineMesh        % Refine Mesh before projection 1/0 
% options.SCE_realistic_projection.thickness = 0.5
% options.SCE_realistic_projection.meshReduceL=20;
% options.SCE_realistic_projection.TolCon=0.1;   
% options.SCE_realistic_projection.UseParallel   

% TODO: Principal axis Brang et al., Journal of Neuroscience Methods, 2016 
% Voxel crds corresponding to each electrode has to be included in the
% options. Principal axis can be obtained from PCA analysis easily. 
% The already existing cluster info can be used. How different is
% this to the 'normal' vector? 


% options.connMat         % connectivity matrix
% options.rows            % needed for realistic projection
% options.columns         % needed for realistic projection
%
% Output
% pos_mesh: position in the mesh (Px3)
% d: Euclidean distance of projection (Px1)
% indexMesh: index pos_mes in the mesh (Px1) (only for closestPoint method)

% A Blenkmann August 2016
% NormalVecFinal normal vector on the mesh for each electrode (Px3)
% A Blenkmann June 2020

% number of electrodes
P=size(pos,1); 

%use left or right
if mean(pos(:,1))<0
    indLR=find(mesh.faces(:,4)==1); %left
    disp('Projecting to left hemisphere')
else
    indLR=find(mesh.faces(:,4)==2); %right
    disp('Projecting to right hemisphere')
end

%remove unused nodes
[no,el]=meshcheckrepair(mesh.vertices,mesh.faces(indLR,1:3),'isolated');
meshLR.vertices=no;
meshLR.faces=el;

if nargin<3
    method='closestPoint';
end

% debugging
% if P<=4
%     method =  'closestPoint'
% end

%% Closest point is calculated always

% distance matrix
D=eucDistMat(pos,meshLR.vertices); % new corrected version

if P>1
    [d, indexMeshLR]=min(D,[],2);
else
    [d, indexMeshLR]=min(D);
end

%  Closest point output 
pos_Closest=meshLR.vertices(indexMeshLR,:); 


%% Projections 

switch method

%%%%%%%%%% Closest point method %%%%%%%%%
    case 'closestPoint'
        pos_mesh=pos_Closest;
        disp('Projection to SCE done using Closest Point method.')
        
%%%%%%%%%% Springs method  %%%%%%%%%%%%%% 
    case 'springs'
        
        % initial position
        pos_0=pos_Closest;
        
        optionsSprings=options.SCE_springs_projection; % K
        optionsSprings.model='2D'; % default model
        
        %interelectrode distance
        d_ij_0=eucDistMat(pos,pos); % fastest if done outside for loop for all points
    
        % to use fix interlectrode distances
        %     d_ij_0=zeros(size(d_ij));
        %     d_ij_0(adjMat==1)=options.M1;
        %     d_ij_0(adjMat==2)=options.M2;

        
        % reduce mesh to closest L nodes
        L = options.SCE_springs_projection.meshReduceL;
        outMesh=meshROI(pos,meshLR,L);
        
        % refine mesh not needed any more. New and more precise method
        % implemented to measure distance to a mesh
        
%         % refine patch twice to increase spatial resolution of the solution.  
%         if  options.SCE_springs_projection.RefineMesh 
%             [outMesh_refined] = refinepatch(refinepatch(outMesh));
%         else
%             outMesh_refined = outMesh;
%         end
        
%        distance distribution of contrain mesh function 
%         dOMR=eucDistMat( outMesh_refined.vertices, outMesh_refined.vertices);    
%         dOMR(logical(eye(size(dOMR))))=nan; % diagonal
%         md=min(dOMR);        
%         figure; hist(md,100)
         
        f = @(x)defSpringsEnergy(x,pos,d_ij_0,adjMat,optionsSprings);
        
        % search options
        % 0.05 mm steps / 0.1 mm tolerance constrain
        % step tolerance to 1e-6 mm
        % use closest point estimation as typicalX
        
        % OPTIONS are according the running MATLAB version
        % checked on MATLAB 2013a and 2016a
        
        options_fmincon=optimoptions(@fmincon);
        
        if isprop(options_fmincon,'Display')
            options_fmincon.Display='iter';
        end
        
        if isprop(options_fmincon,'Algorithm')
             options_fmincon.Algorithm='interior-point'; %'active-set' Tried, but didn't work
        end
        
        if isprop(options_fmincon,'TolCon')
            options_fmincon.TolCon = options.SCE_springs_projection.TolCon;
        elseif isprop(options_fmincon,'ConstraintTolerance')
            options_fmincon.ConstraintTolerance = options.SCE_springs_projection.TolCon;
        end
        
        % max fun evals should be changed if grids are have too many
        % electrodes
        if isprop(options_fmincon,'MaxFunEvals')
            options_fmincon.MaxFunEvals=1e6;
        elseif isprop(options_fmincon,'MaxFunctionEvaluations')
            options_fmincon.MaxFunctionEvaluations=1e6;
        end
        
%         %        Difficult to control outcome
%         if isprop(options_fmincon,'DiffMinChange')
%             options_fmincon.DiffMinChange=0.3;%1e-3;
%         end
%         if isprop(options_fmincon,'DiffMaxChange')
%             options_fmincon.DiffMaxChange=2;
%         end
        
        if isprop(options_fmincon,'TolX')
            options_fmincon.TolX=options.SCE_springs_projection.StepTolerance;
        elseif isprop(options_fmincon,'StepTolerance')
            options_fmincon.StepTolerance=options.SCE_springs_projection.StepTolerance;
        end
        
        if isprop(options_fmincon,'TypicalX')
            options_fmincon.TypicalX=pos_Closest;
        end
        
        if isprop(options_fmincon,'TolFun')
            options_fmincon.TolFun=0.01;
        end
        
        if isprop(options_fmincon,'UseParallel')
            if ischar(options_fmincon.UseParallel)
                if options.SCE_springs_projection.UseParallel
                    options_fmincon.UseParallel='always';
                else
                    options_fmincon.UseParallel='no'; %unsure if this works
                end
            else
                if     options.SCE_springs_projection.UseParallel
                    options_fmincon.UseParallel=true;
                else
                    options_fmincon.UseParallel=false;
                end
            end
        end
%         options_fmincon.Display = 'final';
        
         
%         options_fmincon = optimset('Algorithm','active-set',...
%             'MaxIter', 1e3, 'MaxFunEvals', Inf, 'GradObj', 'off', 'TypicalX', pos_mesh(:),...
%             'DiffMaxChange', 2, 'DiffMinChange', 0.3, 'TolFun', 0.3, ...
%             'TolCon', 0.01 * size(pos_mesh, 1),'TolX', 0.5, 'Diagnostics', 'off', 'RelLineSrchBnd',1);

        if strcmp( options.SCE_springs_projection.constrain, 'distance' )

            nonlcon = @(x)meshDistanceConstrain(x,outMesh);
        
        elseif strcmp( options.SCE_springs_projection.constrain, 'distance_deformation')
            
             nonlcon = @(x)meshDistance_Deformation_Constrain(x,outMesh,[],options.SCE_springs_projection.d_ij_0,adjMat);
        end
        [pos_mesh,~] = fmincon(f,pos_0,[],[],[],[],[],[],nonlcon,options_fmincon);
        
        disp('Projection to SCE done using Springs method.')
         
%%%%%%%%%%% Normal-Grid projection %%%%%%%%%%
     case 'normal'

         % reduce mesh to closest 25 nodes. Don't need to resample mesh
         L=options.SCE_normal_projection.meshReduceL;
         outMesh=meshROI(pos,mesh,L);
         
         % calculate normal vector for each electrode
         normalVec = zeros(3,P);
         for i=1:P
             % neigbours indices
             neigInd = [find(adjMat(i,:)==1) find(adjMat(i,:)==2)]; % lateral and diagonal electrodes
             neig=[pos(neigInd,:); pos(i,:)];
             
             [V]=pca(neig);
             normalVec(:,i)= V(:,3);
         end
         normalVec = normalVec';
         
%         %debugging
%          figure;
%          scatter3(pos(:,1),pos(:,2),pos(:,3),'k','filled')
%          axis image
%          hold on
%          quiver3(pos(:,1),pos(:,2),pos(:,3), pos(:,1)+normalVec(:,1), pos(:,2)+normalVec(:,2), pos(:,3)+normalVec(:,3))
%          mvis(outMesh.vertices,outMesh.faces(:,1:3));    
%          %normal grid vector
%          m=mean(pos);
%          n=mean(normalVec);
%          
%          quiver3(m(1),m(2),m(3),m(1)+n(1),m(2)+n(2),m(3)+n(3));
          
         C=[]; Q=[]; pos_mesh=[]; useClosest=[];
         for i=1:P
             [c_temp,Q_temp]=interseccionVecMesh(normalVec(i,:),outMesh,pos(i,:));
             [~,indQ]=min(abs(Q_temp)); %take the closest intersection if more than one

             % no intersection case (reduced patch too small?)
             if isempty(indQ)  
                 disp(['Error computing normal projection in electrode:' str2num(i) '. Closest point used instead.'])
                 Q(i)=nan;
                 C(i)=nan;
                 useClosest=[useClosest i];
             else
                 Q(i)=Q_temp(indQ);
                 C(i)=c_temp(indQ);
             end
         end
         
         % compute projection
         for i=1:P
             pos_mesh(i,:) = pos(i,:)  + Q(i) * normalVec(i,:) ;                 % using scale coeficient
             %     pos_mesh(i,:) = mean(outMesh.vertices(outMesh.faces(C(i),1:3),:));   % using face mean
         end
         
         for i=useClosest
             pos_mesh(i,:) = pos_Closest(i,:);                          
         end        
        disp('Projection to SCE done using Normal-Grid method.')

%%%%%%%%%%% Normal projection %%%%%%%%%%
     case 'normal-SCE'        
         
         % reduce mesh to closest (<25mm) nodes from all electrodes. Don't need to resample mesh
         L=options.SCE_normalSCE_projection.meshReduceL;
         outMesh=meshROI(pos,mesh,L);
         triModel = triangulation(outMesh.faces(:,1:3), outMesh.vertices); % triangular model
         normalVecVertices = vertexNormal(triModel); % Normal vector in each triangle
         
         % calculate normal vector for each electrode
         normalVec = zeros(3,P);
         for i=1:P

             % select SCE vertex points within radius L
             D=eucDistMat(pos(i,:),outMesh.vertices); % new corrected version
             [~,indexV]=find(D<L);
             
            % Kubanek et al., 2015 approach
            normalVec(:,i)= nanmean(normalVecVertices(indexV,:)); %some can be NaN

            
            % compute normal vector form all vertices within the radius L
            % using PCA - Results are almost the same results as computing the average
            % of normals
%              [V]=pca(mesh.vertices(indexV,:));
%              normalVec(:,i)= V(:,3);

         end
         normalVec = normalVec';
         
%         %debugging
%          figure;
%          scatter3(pos(:,1),pos(:,2),pos(:,3),'k','filled')
%          axis image
%          hold on
%          quiver3(pos(:,1),pos(:,2),pos(:,3), pos(:,1)+normalVec(:,1), pos(:,2)+normalVec(:,2), pos(:,3)+normalVec(:,3))
%          mvis(outMesh.vertices,outMesh.faces(:,1:3));    
%          %normal grid vector
%          m=mean(pos);
%          n=mean(normalVec);
%          
%          quiver3(m(1),m(2),m(3),m(1)+n(1),m(2)+n(2),m(3)+n(3));
          
         C=[]; Q=[]; pos_mesh=[]; useClosest=[];
         for i=1:P
             [c_temp,Q_temp]=interseccionVecMesh(normalVec(i,:),outMesh,pos(i,:));
             [~,indQ]=min(abs(Q_temp)); %take the closest intersection if more than one

             % no intersection case (reduced patch too small?)
             if isempty(indQ)  
                 disp(['Error computing normal projection in electrode:' str2num(i)])
                 Q(i)=nan;
                 C(i)=nan;
                 useClosest=[useClosest i];
             else
                 Q(i)=Q_temp(indQ);
                 C(i)=c_temp(indQ);
             end
         end
         
         % compute projection
         for i=1:P
             pos_mesh(i,:) = pos(i,:)  + Q(i) * normalVec(i,:) ;                 % using scale coeficient
             %     pos_mesh(i,:) = mean(outMesh.vertices(outMesh.faces(C(i),1:3),:));   % using face mean
         end
         
         for i=useClosest
             pos_mesh(i,:) = pos_Closest(i,:);                          
         end        
        disp('Projection to SCE done using Normal-SCE vector method.')
   
%%%%%%%%%%%%%% Combined Electrode Projection (CEPA) - aka Hybrid %%%%%%%%%%%
    case 'CEPA'
        
        disp(' ---- Starting Projection to SCE using CEPA method. This method will call other methods. -----')

        % initial position
        pos_0=pos;
        
        %interelectrode distance
        d_ij_0=eucDistMat(pos_0,pos_0); % fastest if done outside for loop for all points
           
        % reduce mesh to closest nodes (distance < L)
        L=options.SCE_CEPA_projection.meshReduceL;
        outMesh=meshROI(pos,meshLR,L);
  
        
        % normal projection postions to use as anchors: pos_A
        % distance to the pos_0 points: d_A
        if options.rows>1 & options.columns>1
            method='normal'; % recursive call
            options.SCE_normal_projection.meshReduceL =25;        
            [pos_An,d_An]=projection2mesh(mesh,pos,method,adjMat,options);        
        else 
            pos_An = []; %not possible for strips
            d_An =[];
        end            

        method='normal-SCE'; % recursive call
        options.SCE_normalSCE_projection.meshReduceL =25;        
        [pos_An_sce,d_An_sce]=projection2mesh(mesh,pos,method,adjMat,options);        

        pos_anchors = cat(3,pos_An,pos_An_sce);
        
        method='CEPA'; % restore to previous       
        optionsCEPA=options.SCE_CEPA_projection;
        
        % Ka_weight can only be computed here - idividual electrode anchor
        % weight
        if options.rows>1 & options.columns>1
            optionsCEPA.Ka_weight = ones(size(pos_anchors,1),2); %exp(-d_A); % range [0 1], but not normalized
        else
             optionsCEPA.Ka_weight = ones(size(pos_anchors,1),1); %exp(-d_A); % range [0 1], but not normalized
        end
        f = @(x)hybridEnergy(x,pos_0,pos_anchors,d_ij_0,options.rows,options.columns,adjMat,options.connMat,optionsCEPA);

        
        % OPTIONS are according the running MATLAB version
        % checked on MATLAB 2013a and 2016a
        
        options_fmincon=optimoptions(@fmincon);
        
        if isprop(options_fmincon,'Algorithm')
            options_fmincon.Algorithm='interior-point'; %'active-set' Tried, but didn't work
        end
        
        if isprop(options_fmincon,'TolCon')
            options_fmincon.TolCon=options.SCE_CEPA_projection.TolCon;
        elseif isprop(options_fmincon,'ConstraintTolerance')
            options_fmincon.ConstraintTolerance=options.SCE_CEPA_projection.TolCon;
        end
        
        % max fun evals should be changed if grids are have too many
        % electrodes
        if isprop(options_fmincon,'MaxFunEvals')
            options_fmincon.MaxFunEvals=1e6;
        elseif isprop(options_fmincon,'MaxFunctionEvaluations')
            options_fmincon.MaxFunctionEvaluations=1e6;
        end
                
        if isprop(options_fmincon,'TolX')
            options_fmincon.TolX=options.SCE_CEPA_projection.StepTolerance;
        elseif isprop(options_fmincon,'StepTolerance')
            options_fmincon.StepTolerance=options.SCE_CEPA_projection.StepTolerance;
        end
        
        if isprop(options_fmincon,'TypicalX')
            options_fmincon.TypicalX=pos_Closest;
        end
        
        if isprop(options_fmincon,'UseParallel')
            if ischar(options_fmincon.UseParallel)
                if options.SCE_CEPA_projection.UseParallel
                    options_fmincon.UseParallel='always';
                else
                    options_fmincon.UseParallel='no'; %unsure if this works
                end
            else
                if     options.SCE_CEPA_projection.UseParallel
                    options_fmincon.UseParallel=true;
                else
                    options_fmincon.UseParallel=false;
                end
            end
        end
                
        
%         options_fmincon.Display = 'final';
        
        % contrain function 
        nonlcon = @(x)meshDistanceConstrain(x,outMesh);
        
        % run minimization - sensible to initial coordinate
        [pos_mesh,~] = fmincon(f,pos_0,[],[],[],[],[],[],nonlcon,options_fmincon); % start from pos_A
   
        disp('Projection to SCE done using CEPA method.')

%%%%%%%%%%%%%% Realistic 3D model %%%%%%%%%%%
    case 'realistic'
        
        % convert 2D in 3D grid
        C=cov(pos);
        [eV,eD]=eig(C); % get average normal vector
              
        % model 3D
        delta =  eV(:,1)'* options.SCE_realistic_projection.thickness/2;
        posUp = [pos(:,1) + delta(1) pos(:,2) + delta(2) pos(:,3) + delta(3)];
        posDown = [pos(:,1) - delta(1) pos(:,2) - delta(2) pos(:,3) - delta(3)];
        pos_3D = [posUp; posDown];
        
        % position to start minimization - Starting from the projection
        % makes a huge difference
        posUp_0 = [pos_Closest(:,1) + delta(1) pos_Closest(:,2) + delta(2) pos_Closest(:,3) + delta(3)];
        posDown_0 = [pos_Closest(:,1) - delta(1) pos_Closest(:,2) - delta(2) pos_Closest(:,3) - delta(3)];
        pos_0 = [posUp_0; posDown_0];
        
        figure;
        scatter3(pos(:,1),pos(:,2),pos(:,3)); hold on;
        plotElectrodesLines(pos,options.rows,options.columns,[0 1 0])
        
        scatter3(posUp(:,1),posUp(:,2),posUp(:,3)); hold on;
        plotElectrodesLines(posUp,options.rows,options.columns,[1 0 0])
                
        scatter3(posDown(:,1),posDown(:,2),posDown(:,3)); hold on;
        plotElectrodesLines(posDown,options.rows,options.columns,[1 0 0])      

        indexElecGrid = 1:length(pos); %Only posUp are considered as real electrodes
        options.minDef2.indexElecGrid = indexElecGrid;
    
        options.model = '3D';
        adjMat3D = makeAdjMat(options.rows,options.columns, options); % 3D model
                
        % reduce mesh to closest L nodes
        L = options.SCE_realistic_projection.meshReduceL;
        outMesh=meshROI(pos,meshLR,L);
        
        % Obsolete
%         % refine patch twice to increase spatial resolution of the solution.
%         if  options.SCE_realistic_projection.RefineMesh 
%             [outMesh_refined] = refinepatch(refinepatch(outMesh));
%         else
%             outMesh_refined = outMesh;
%         end
        
        % inter-electrode distance 
        d_ij_0=eucDistMat(pos_3D,pos_3D);
        
        M1_estimate = mean(d_ij_0(adjMat3D==1));
        
        %% minimization        
        optionsSprings=options.SCE_realistic_projection;
        optionsSprings.model='3D';         
        
        % energy function
        f = @(x)defSpringsEnergy (x,pos_3D,d_ij_0,adjMat3D,optionsSprings);
        
        % search options
        options_fmincon=optimoptions(@fmincon);
        options_fmincon.Display='iter';
        options_fmincon.Algorithm='interior-point'; % consider 'active-set' for faster results (?) - not really working faster
        options_fmincon.MaxFunEvals=1e6; 
        options_fmincon.MaxIterations=1e3; %default
        options_fmincon.TolX=M1_estimate * options.SCE_realistic_projection.StepTolerance; % step tolerance
        options_fmincon.TypicalX=pos_0+rand(size(pos_0))*1e-6;
        options_fmincon.UseParallel=true;
        options_fmincon.ConstraintTolerance = options.SCE_realistic_projection.TolCon;
        options_fmincon.TolFun=0.01; 
            
        % contrain function 
        nonlcon = @(x)meshDistanceConstrain(x,outMesh,indexElecGrid);
        
        % run minimization
        [pos_mesh_3D,~] = fmincon(f,pos_0,[],[],[],[],[],[],nonlcon,options_fmincon); %  
      
        pos_mesh = pos_mesh_3D(indexElecGrid,:);
        
        disp('Projection to SCE done using Realistic 3D model method.')
        
end

% compute displacement
d=eucDist(pos,pos_mesh);
        
%% calculate the index to the original mesh

%D=eucDistMat(mesh.vertices,pos_mesh);
D=eucDistMat(pos_mesh,mesh.vertices); % new corrected version
if P>1
    [~, indexMesh]=min(D,[],2);
else
    [~, indexMesh]=min(D);
end

%% compute normal vector on the final surface

D=eucDistMat(pos_mesh,pos_mesh); % new corrected version
L = mean2( D(adjMat==1)) * 2; % estimate of interelectrode distance * 2
for i=1:P
    outMesh_elec=meshROI(pos_mesh(i,:),meshLR,L);
    [V]=pca(outMesh_elec.vertices);
    normalVecFinal(:,i)= V(:,3);

%     mvis(outMesh_elec.vertices,outMesh_elec.faces(:,1:3),outMesh_elec.vertices);
end

normalVecFinal = normalVecFinal';
% 
% 
% figure;
% scatter3(pos(:,1),pos(:,2),pos(:,3),'k','filled')
% axis image
% hold on
% mvis(outMesh.vertices,outMesh.faces(:,1:3));
% scatter3(pos_mesh(:,1),pos_mesh(:,2),pos_mesh(:,3),'r','filled')
% quiver3(pos_mesh(:,1),pos_mesh(:,2),pos_mesh(:,3), pos_mesh(:,1)+normalVecFinal(:,1), pos_mesh(:,2)+normalVecFinal(:,2), pos_mesh(:,3)+normalVecFinal(:,3))
% 
