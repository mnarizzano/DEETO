function [c,ceq]=gridVolumeConstrain(pos,vol_0,cuboidsInd)
% defined as in fmincon specs
% diference between the original grid volume and the actual one

% c(x)<=0
% ceq(x)=0;

%volume
vol=zeros(size(cuboidsInd,1),1);
for n=1:size(cuboidsInd,1)
    cubX=pos(cuboidsInd(n,:),:);
    DT=delaunayTriangulation(cubX);
    [~,vol(n)]=convexHull(DT);
end


c=[];
ceq=[(vol - vol_0)./vol_0];

