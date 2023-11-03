function [alpha,beta]=delta2alpha_beta(dx,dy,dz,framePosition,frameDown)
% Estimate alpha and beta angles based on [dx, dy, dz]
% framePosition can be 'Left' 'Right' 'Anterior' 'Posterior'
% frameDown = 1: used when z<0 and beta angle is rotated 180 degrees
% alpha and beta angles in DEGREES


% beta   0 - 360 degres
% alpha  0 - 90

%left frame
if strcmp(framePosition,'Left');
    
    beta = mod (atan2d(dz,dy), 360);
    h = sqrt(dy.^2+dz.^2);
    alpha = atan2d(h,-dx);
    
%right frame
elseif strcmp(framePosition,'Right')
    
    beta = mod(atan2d(dz,-dy),360);
    h=sqrt(dy.^2+dz.^2);
    alpha = atan2d(h,dx);
    
%anterior frame
elseif strcmp(framePosition, 'Anterior')
    
    beta= mod ( atan2d(dz,dx),360);
    h=sqrt(dx.^2+dz.^2);
    alpha= atan2d(h,dy);
    
%posterior frame
elseif strcmp(framePosition,'Posterior')
    
    beta= mod(atan2d(dz,-dx),360);
    h=sqrt(dx.^2+dz.^2);
    alpha= atan2d(h,-dy);
end


% rotation of beta in 180
if frameDown
    beta=mod(beta+180,360);
end
