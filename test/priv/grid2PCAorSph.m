function [ePCA, eSph]=grid2PCAorSph(G)
% define if projection is better to a PCA or to Sphere 

% ePCA is the ratio between the 2nd and 3rd eigenvalue in a PCA projection
% eSph is the ratio between the 2nd and 3rd eigenvalue in a sphere (azimuth
%     and elevation) projection


N=size(G,1);
%compute projection using PCA
C=cov(G);
[V,D]=eig(C);
ePCA=D(2,2)/D(3,3); %(D(2,2)+D(3,3))/sum(diag(D)); %if e is big, this means that the grid is not so curved

% compute projection using spherical coordinates and PCA
[center,~,~] = spherefit(G);
Ce=repmat(center',N,1);
Gc=G-Ce;
[az,el,rad]=cart2sph(Gc(:,1),Gc(:,2),Gc(:,3));
azMean=mean(az);
elMean=mean(el);
azw=wrapToPi(az-azMean); %angles in the interval -pi to pi
elw=wrapToPi(el-elMean); %angles in the interval -pi to pi
Gsph=[azw,elw,rad];
C=cov(Gsph);
[V,D]=eig(C);
eSph= D(2,2)/D(3,3);  %(D(2,2)+D(3,3))/sum(diag(D));
