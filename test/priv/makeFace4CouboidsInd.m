function faceInd = makeFace4CouboidsInd(cuboidsInd)
% compute indices to vertices that form faces of cuboids.
% cuboids indices (from a 3D grid model) are obtained using
% makeCuboidsInd.m
% A Blenkmann 2019

faceInd=zeros(size(cuboidsInd,1)*6,4);
faceElem= [1 2 3 4;
    5 6 7 8;
    1 2 5 6;
    3 4 7 8;
    1 3 5 7;
    2 4 6 8];

for i=1:size(cuboidsInd,1)
    faceInd((i-1)*6+1 : (i-1)*6+6 ,:)=reshape(cuboidsInd(1,faceElem(:)),6,4);
end