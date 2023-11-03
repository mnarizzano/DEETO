function faceArea = faceAreaCuboid(pos,faceInd)

% make 2 triangles with elements (1,2,3) and (2,3,4) of each face and
% compute the 2 areas and add

faceArea=zeros(1,length(faceInd));

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
    
    faceArea(i)=A1+A2;
end