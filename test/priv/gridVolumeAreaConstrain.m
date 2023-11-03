function [c,ceq]=gridVolumeAreaConstrain(pos,vol_0,area_0,cuboidsInd,faceInd)
% defined as in fmincon specs
% concatenation of 
% 1- diference between the original grid volume and the actual one
% 2 - diference between the original faces area and the actual one

% c(x)<=0
% ceq(x)=0;

%volume
vol=zeros(size(cuboidsInd,1),1);
for n=1:size(cuboidsInd,1)
    cubX=pos(cuboidsInd(n,:),:);
    DT=delaunayTriangulation(cubX);
    [~,vol(n)]=convexHull(DT);
end

% area
area=zeros(length(faceInd),1);
for i=1:length(faceInd)
    % first triangle
    % a = length 1-2
    a = norm(pos(faceInd(i,1),:) - pos(faceInd(i,2),:));
    % b = length 2-3
    b = norm(pos(faceInd(i,2),:) - pos(faceInd(i,3),:));
    % c = length 1-3
    c = norm(pos(faceInd(i,1),:) - pos(faceInd(i,3),:));
    s=(a+b+c)/2;
    A1=sqrt(s*(s-a)*(s-b)*(s-c));
    
    % same for the second triangle
    % a = length 2-3
    a = norm(pos(faceInd(i,2),:) - pos(faceInd(i,3),:));
    % b = length 3-4
    b = norm(pos(faceInd(i,3),:) - pos(faceInd(i,4),:));
    % c = length 2-4
    c = norm(pos(faceInd(i,2),:) - pos(faceInd(i,4),:));
    s=(a+b+c)/2;
    A2=sqrt(s*(s-a)*(s-b)*(s-c));
    
    area(i)=A1+A2;
end

c=[];
ceq=[(vol - vol_0)./vol_0;
    (area - area_0)./area_0];

