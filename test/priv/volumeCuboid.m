function vol=volumeCuboid(pos,cuboidsInd)
%compute the volume of the cuboids
% A Blenkmann

vol=zeros(size(cuboidsInd,1),1);

for n=1:size(cuboidsInd,1)
    cubX=pos(cuboidsInd(n,:),:);
    DT=delaunayTriangulation(cubX);
    [~,vol(n)]=convexHull(DT);
end