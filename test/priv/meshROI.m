function outMesh=meshROI(pos,mesh,L)

% calculate a new mesh using the closest vertices of the mesh  from each
% electrode
% L radius to consider from pos
% pos vector of positions
% A Blenkmann 2016
% Update 2020
% The number of faces and vertices is reduced 

%D=eucDistMat(mesh.vertices,pos);
D=eucDistMat(pos,mesh.vertices); % new corrected version

[~,indexV]=find(D<L);
indF3=ismember(mesh.faces,indexV);

% L first vertices
% [~,indexV]=sort(D,2,'ascend');
% indF3=ismember(mesh.faces,indexV(:,1:L));


indF=(indF3(:,1) & indF3(:,2) & indF3(:,3));
outMesh.faces=mesh.faces(indF,:);
outMesh.vertices=mesh.vertices;%(indexV(i,1:L),:);
[outMesh.vertices,outMesh.faces]=meshcheckrepair(outMesh.vertices,outMesh.faces,'isolated'); 
 