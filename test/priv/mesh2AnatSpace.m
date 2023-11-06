% function mesh=mesh2AnatSpace(mesh,S)
%
% convierte las mallas en sistema de coordenadas del espacio matricial (o
% de datos) al espacio anatomico usando la info contenida en el hdr del
% archivo del cual se obutieron
%
% usar para convertir las mallas de salida del BET
%
%
% Ej NIFTI usando load_nii
% TAC=load_nii([path '/imagen.nii']);
% S=[TAC.hdr.hist.srow_x; TAC.hdr.hist.srow_y; TAC.hdr.hist.srow_z;];
% [mesh_temp.V,mesh_temp.C]=loadoff([path '/mesh.off']);
% inskull=mesh2AnatSpace(mesh_temp,S)
%
% A. Blenkmann 2013

function mesh=mesh2AnatSpace(mesh,S)
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
    
end
