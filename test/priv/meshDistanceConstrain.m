function [c,ceq]=meshDistanceConstrain(pos,mesh,indexElecGrid)
% defined as in fmincon specs
% pos to mesh distance vector
% This new method computes the minimum distance to mesh point vertices, mesh edges, and
% mesh faces
% indexElecGrid: optional parameter to define the electrodes to measure the
% distance to the surface 
% A Blenkmann 12 Nov 2019

L=size(pos,1); %number of electrodes
if nargin == 3 %measure only the distance of some electrodes to the surface
    L = length(indexElecGrid);
    pos=pos(indexElecGrid,:);
end
c=zeros(L,1);  

%distance pos to mesh
for i=1:L % use for loop to reduce mem use
    D=eucDistMat(mesh.vertices,pos(i,:));    
    [minVertex,indMin]=min(D);
    %faces connected to that vertex
    facesConnected=[find(mesh.faces(:,1)==indMin); find(mesh.faces(:,2)==indMin); find(mesh.faces(:,3)==indMin)];
       
    % compute the minimum distance to edges of those faces
    minEdge=inf;
    
    for j=1:size(facesConnected,1)
        % min distance to first edge
        minEdge1=distance3DP2E(pos(i,:),mesh.vertices(mesh.faces(facesConnected(j),1),:),...
            mesh.vertices(mesh.faces(facesConnected(j),2),:));
        % min distance to second edge
        minEdge2=distance3DP2E(pos(i,:),mesh.vertices(mesh.faces(facesConnected(j),2),:),...
            mesh.vertices(mesh.faces(facesConnected(j),3),:));
        % min distance to third edge
        minEdge3=distance3DP2E(pos(i,:),mesh.vertices(mesh.faces(facesConnected(j),1),:),...
            mesh.vertices(mesh.faces(facesConnected(j),3),:));
        minEdge = min([minEdge minEdge1 minEdge2 minEdge3]);
    end
    
    % compute distance to the faces (within the face area)
    minFace=inf;
    for j=1:size(facesConnected,1)
        minFaceJ = distance3DP2F(pos(i,:),mesh.vertices(mesh.faces(facesConnected(j),1),:),...
            mesh.vertices(mesh.faces(facesConnected(j),2),:),...
            mesh.vertices(mesh.faces(facesConnected(j),3),:));
        
        minFace = min([minFace minFaceJ]);
    end
    
    c(i)= min([minVertex minEdge minFace]);
end

ceq=[];
end




%% Fast definition / Only computing distance to vertices
% for i=1:L % use for loop to reduce mem use
%     D=eucDistMat(mesh.vertices,pos(i,:));
%     c(i)=min(D);
% end


%% full mem use
% distance pos to mesh
% D=eucDistMat(pos,mesh.vertices); % corrected for new version
% c=min(D,[],2);

%% ////

% M=size(pos,1);
% 
% %reduce search to closest 10 vertices and surfaces when all distances is smaller
% %than 3mm
% if closeSearchMode
%     
%     closeSearch=c<2;
%     L=10;
%     
%     if sum(closeSearch)==M;
%         [~,indexV]=sort(D,2,'ascend');
%         
%         for i=1:M
%             indF3=ismember(mesh.faces,indexV(i,1:L));
%             indF=(indF3(:,1) & indF3(:,2) & indF3(:,3));
%             meshElec.faces=mesh.faces(indF,:);
%             meshElec.vertices=mesh.vertices;%(indexV(i,1:L),:);
%             
%             [c(i), ~] = distanceVertex2Mesh(meshElec, pos(i,:)); %not very efficent code...
%         end
%     end
% end
