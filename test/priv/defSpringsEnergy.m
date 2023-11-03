function y = defSpringsEnergy (pos,pos_0,d_ij_0,adjMat,options)
% Energy function y = t + k d
% t is translation energy and d defformation energy
% See Dykstra 2012 for details
% pos_i (Px3) Actual position - what we want to change
% pos_0 (Px3) Original position 
% d_ij_0 (PxP) interelectrode distance
%     d_ij_0=eucDistMat(pos_0,pos_0); % fastest if done outside for loop for all points       
% to use fix interlectrode distances
%     d_ij_0=zeros(size(d_ij));
%     d_ij_0(adjMat==1)=options.M1;
%     d_ij_0(adjMat==2)=options.M2;

% adjMat (PxP) adjacency matrix with the active conections
% options.K    (scalar) ratio of deformation to translation: y = T + k D


if nargin<4
    options.M1=[];
    options.M2=[];
    options.K=1000;
    options.model='2D'; % default
end

P=size(pos,1);

% % logical is neig (all neighbors are considered: 1st, 2nd, and diagonal)
isNeig=triu(adjMat>0); %only upper triangular matrix

% % actual distance to neighbors
d_ij=eucDistMat(pos,pos); % fastest if done outside for loop for all points

if strcmp(options.model,'2D')
    t=sum(eucDist(pos,pos_0).^2);
    
    d = sum(sum ((isNeig.*(d_ij-d_ij_0)).^2));
    
else % 3D model / normalized measures
    %  normalized translation energy 
    t = sum(eucDist(pos,pos_0).^2) / P;
    
    % normalized deformation distance
    delta_distance = ( (d_ij(isNeig) - d_ij_0(isNeig)) ./ d_ij_0(isNeig) ).^2;
    d = sum(delta_distance) / size(delta_distance,1); % Note that: size(delta_distance,1)=sum(isNeig(:))
end

y = t + options.K * d;
    
end
