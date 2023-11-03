% function mesh=AnatSpace2Mesh(mesh,S)
% aplica la transformada inversa de S
%
% ver mesh2AnatSpace
%
% A. Blenkmann 2013

function mesh=AnatSpace2Mesh(mesh,S)
S2=[S;  0 0 0 1];
S=inv(S2);
%S=[inv(S(1:3,1:3)) -S(:,4)];


if isfield(mesh,'V')
    mesh.V=mesh.V';
    mesh.V(4,:)=1;
    mesh.V=(S*mesh.V)';
elseif isfield(mesh,'v')
    mesh.v=mesh.v';
    mesh.v(4,:)=1;
    mesh.v=(S*mesh.v)';
else %just cordinates list 
    mesh=mesh';
    mesh(4,:)=1;
    mesh=(S*mesh)';
end
mesh=mesh(:,1:3);
    
end
