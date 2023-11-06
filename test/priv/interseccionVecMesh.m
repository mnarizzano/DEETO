% function [c,Q]=interseccionVecMesh(v,fv,cm) 
% v  vector fila
% fv malla
%    fv.vertices vertices 
%    fv.faces caras
% cm centro de masa del poliedro
%
% c caras donde hubo interseccion
% Q vector de coeficientes tales que Pi=Q(i)*v 
% donde Pi es el punto de interseccion entre 
% el triangulo c(i) y el vector v
%
% A. Blenkmann 2011

function [c,Q]=interseccionVecMesh(v,fv,cm)

l=size(fv.faces,1);

inter=false(l,1); q=zeros(l,1);
fv.vertices=fv.vertices-repmat(cm,size(fv.vertices,1),1);
% v=v-cm';
v=v'; % v is centered 
 
% pa=patch('Faces',fv.faces,'Vertices',fv.vertices);
% set(pa,'FaceColor','red','EdgeColor','black');
% xlabel('x'); ylabel('y');zlabel('z');

for i=1:l
    % tomo los nodos de la cara correspondiente i
    % vectores columna
%     disp (i)
    A=fv.vertices(fv.faces(i,1) ,:)';
    B=fv.vertices(fv.faces(i,2) ,:)';
    C=fv.vertices(fv.faces(i,3) ,:)';
    [inter(i),q(i)]=interseccionVecTri(A,B,C,v,0);
end

%caras donde hubo interseccion
c=find(inter);
% q tales que Pi=Q(i)*v donde Pi es el punto de interseccion entre 
% el triangulo c(i) y el vector v
Q=q(c);
