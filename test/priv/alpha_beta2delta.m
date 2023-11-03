function [dx,dy,dz]=alpha_beta2delta(alpha,beta,framePosition,frameDown)
% Estimate [dx, dy, dz] (norm=1) based on alpha and beta angles 
% framePosition can be 'Left' 'Right' 'Anterior' 'Posterior'
% frameDown = 1: used when z<0 and beta angle is rotated 180 degrees
% alpha and beta angles in DEGREES


% rotation of beta in 180
if frameDown
    beta=mod(beta-180,360);
end


%left frame
if strcmp(framePosition,'Left'); 
    dx=-cosd(alpha);
    h=sind(alpha);
    dy=cosd(beta)*h;
    dz=sind(beta)*h;
    
%right frame
elseif strcmp(framePosition,'Right')
    dx=cosd(alpha);
    h=sind(alpha);
    dy=-cosd(beta)*h;
    dz=sind(beta)*h;
 
%anterior frame
elseif strcmp(framePosition, 'Anterior')      
    dy=cosd(alpha);
    h=sind(alpha);
    dx=cosd(beta)*h;
    dz=sind(beta)*h;
    
%posterior frame
elseif strcmp(framePosition,'Posterior')    
    dy=-cosd(alpha);
    h=sind(alpha);
    dx=-cosd(beta)*h;
    dz=sind(beta)*h;
    
end

