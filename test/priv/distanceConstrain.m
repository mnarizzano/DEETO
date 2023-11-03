function [c,ceq]=distanceConstrain(pos,d_ij_0,adjMat,nailElectrodeNumber,nailElectrodeCrd,model,posIdeal)
% defined as in fmincon specs
% diference between the original distance and the actual one
% posIdeal needed only for 1D_fix model

% c(x)<=0
% ceq(x)=0;

if strcmp (model, '1D_fix') % (pos contains [Tx Ty Tz p0 p1 p2 p3] = translation and rotation quaternion. No scale
    c=[];
else
    
    % actual distance to neighbors
    d_ij=eucDistMat(pos,pos); % fastest if done outside for loop for all points
    
    
    % % distance at least 1/2 of the original one, and not more than 2 times
    % c = [d_ij_0 / 2 - d_ij, d_ij / 2 - d_ij_0];
    
    % distance at least 3/4 of the original one, and not more than 5/4 times
    % for the adjMat connected 10% error
    W = [adjMat==0 adjMat==0] ;
    
    c = [d_ij_0 * 0.75 - d_ij, d_ij - d_ij_0 * 1.25] .* W +...
        [d_ij_0 * 0.9 - d_ij, d_ij - d_ij_0 * 1.1] .* ~W ;
    
end

if isempty(nailElectrodeNumber)
    ceq=[];
else
    if strcmp (model, '1D_fix')
        %M1=d_ij_0(2);
        %P=size(d_ij_0,1);
        %posIdeal = zeros(P,3);
        %posIdeal(:,1) =( 0:M1:((P)-1)*M1)';
        t=pos(1:3);
        q=pos(4:7);
        pos=quatrotate(q,posIdeal+t);
    end   
    ceq=eucDist(pos(nailElectrodeNumber,:),nailElectrodeCrd);
end
