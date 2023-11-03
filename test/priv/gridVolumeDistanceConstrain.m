function [c,ceq]=gridVolumeDistanceConstrain(pos,vol_0,cuboidsInd,d_ij_0,adjMat,nailElectrodeNumber,nailElectrodeCrd)
% defined as in fmincon specs
% diference between the original grid volume and distance, and the actual one

% c(x)<=0
% ceq(x)=0;

%volume constrain
vol=zeros(size(cuboidsInd,1),1);
for n=1:size(cuboidsInd,1)
    cubX=pos(cuboidsInd(n,:),:);
    if all(isfinite(cubX)) %not nan or inf values
        DT=delaunayTriangulation(cubX);
        [~,vol(n)]=convexHull(DT);
    else
        vol(n)=nan;
    end
end

if isempty(nailElectrodeNumber)
    ceq=[(vol - vol_0)./vol_0];
else
    ceq=[(vol - vol_0)./vol_0;  eucDist(pos(nailElectrodeNumber,:),nailElectrodeCrd) ];
end

% distance constrain

% actual distance to neighbors
d_ij=eucDistMat(pos,pos); % fastest if done outside for loop for all points

% distance at least 75% of the original one, and not more than 125% times
% for the adjMat connected 10% error

W = adjMat==0;

c = [(d_ij_0 - d_ij).^2 - d_ij_0.^2 * 0.0625] .* W +... % 25 percent (0.25 * 0.25 = 0.0625)
    [(d_ij_0 - d_ij).^2 - d_ij_0.^2 * 0.0100] .* ~W ;   % 10 percent

%     [(d_ij_0 - d_ij).^2 - d_ij_0.^2 * 0.0025] .* ~W ;   % 5 percent



