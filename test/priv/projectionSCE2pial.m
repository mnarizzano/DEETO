function [pos_pial,normalDistance,normalVecSCE,normalVecPatch,distance]=projectionSCE2pial(mesh_pial,mesh_SCE)

% compute distance between each vertex on the SCE in orthogonal direction (25mm radius) to
% the pial surface.
% Based on Kubanek and Schalk, 2015

% distance gives the shortest distance


% A Blenkmann 2021

% also check projection2mesh.m
addpath('/net/lagringshotell/uio/lagringshotell/sv-psi/Nevro/Prosjekt/Alejandro/data/MATLAB/toolbox/MatlabProgressBar/')

L=25; % like in Branco paper

N=size(mesh_SCE.vertices,1); % number of vertices to project
M=size(mesh_pial.vertices,1); 

% Positions in Pial, i.e., projections, for every SCE point
pos_pial=nan(N,3);

% compute normal vector for each SCE vertex
triModel = triangulation(mesh_SCE.faces(:,1:3), mesh_SCE.vertices);
normalVecSCE = vertexNormal(triModel);
normalVecPatch = nan(size(normalVecSCE));


% Compute orthogonal vector in SCE points
%one point in the vertex at the time
for i=1:N
    % select SCE vertex points within disatance L
    D=eucDistMat(mesh_SCE.vertices(i,:),mesh_SCE.vertices); % new corrected version
    [~,indexV]=find(D<L);
    
    % Kubanek et al., 2015 -  smooth normal vector in a patch  of radius L
    normalVecPatch(i,:)= nanmean(normalVecSCE(indexV,:)); %some can be NaN
    
end


% Compute shortest distance Pial to SCE, and keep Pial index
try
    dpp=eucDistMat(mesh_pial.vertices,mesh_SCE.vertices);
    
    % shortest distance SCE-pial
    [distance,ind_pial_d]=min(dpp);
    
catch % out of memory? Do one by one
    distance=zeros(1,N);
    ind_pial_d=zeros(1,N);
    for i=1:N
        dpp=eucDistMat(mesh_SCE.vertices(i,:),mesh_pial.vertices); % new corrected version
        [distance(i),ind_pial_d(i)]=min(dpp);
    end
end
 
% %debugging
% figure;
% scatter3(mesh_SCE.vertices(:,1),mesh_SCE.vertices(:,2),mesh_SCE.vertices(:,3),'k','filled')
% axis image
% hold on
% quiver3(mesh_SCE.vertices(:,1),mesh_SCE.vertices(:,2),mesh_SCE.vertices(:,3), ...
%     mesh_SCE.vertices(:,1)+normalVecPatch(:,1), mesh_SCE.vertices(:,2)+normalVecPatch(:,2), mesh_SCE.vertices(:,3)+normalVecPatch(:,3))
% mvis(outMesh.vertices,outMesh.faces(:,1:3));
% normal grid vector
% m=mean(mesh_SCE.vertices);
% n=mean(normalVecPatch);
% 
% quiver3(m(1),m(2),m(3),m(1)+n(1),m(2)+n(2),m(3)+n(3));

    
% C=zeros(1,N); 
Q=zeros(1,N); noIntersect=[]; useClosest=[];
for i=progress(1:N)
    
   %look for close faces
    if distance(i)>0.05
        
        [c_temp,Q_temp]=interseccionVecMesh(normalVecPatch(i,:),mesh_pial,mesh_SCE.vertices(i,:)); % c is the intersection face index, distance = Q*norm(v)
        [~,indQ]=min(abs(Q_temp)); %take the closest intersection if more than one
        
        % no intersection case (reduced patch too small?)
        if isempty(indQ)
            disp(['Error computing normal projection on: ' num2str(i)])
            Q(i)=nan;
            %         C(i)=nan;
            noIntersect=[noIntersect i];
        else
            Q(i)=Q_temp(indQ);
            %         C(i)=c_temp(indQ);
        end
        
        % compute projection
        pos_pial(i,:) = mesh_SCE.vertices(i,:)  + Q(i) * normalVecPatch(i,:) ;                    % using scale coeficient
        
    else % use closest point
        pos_pial(i,:) = mesh_pial.vertices(ind_pial_d(i),:);    
        useClosest=[useClosest i];
    end
end


normalDistance=eucDist(mesh_SCE.vertices,pos_pial);

%plot
% mvis(mesh_SCE.vertices,mesh_SCE.faces,normalDistance)
% mvis(mesh_SCE.vertices,mesh_SCE.faces,min_dpp')

