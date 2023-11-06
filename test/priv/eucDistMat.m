function D=eucDistMat(posX,posY)
% Meassure distance between posX points (Mx3) posY points(Px3)   
% and make a distance matrix D (MxP) 
% This is the corrected version. 6 May 2018
% A Blenkmann

% M=size(posX,1);
% P=size(posY,1);
% 
% % pos1=repmat(single(posY),[1,1,M]);
% % pos2=repmat(permute(single(posX),[3,2,1]),[P,1,1]);
% pos1=repmat((posY),[1,1,M]);
% pos2=repmat(permute((posX),[3,2,1]),[P,1,1]);
% 
% D=squeeze(sqrt(sum((pos1-pos2).^2,2)));


if isempty(posX) | isempty(posY)
    D=[];
    return;
end

% Fastest method by Roland Bunschoten:
XX = sum(posX.*posX,2);  
YY = sum(posY.*posY,2); 

% make a distance matrix D (MxP)
XY = posX*posY'; 
D  = sqrt(abs(repmat(YY',[size(XX,1) 1]) + repmat(XX,[1 size(YY,1)]) - 2*XY));

% make a distance matrix D (PxM)
% XY = posY*posX'; 
% D  = sqrt(abs(repmat(XX',[size(YY,1) 1]) + repmat(YY,[1 size(XX,1)]) - 2*XY));
