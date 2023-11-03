function [c,ceq]=surfFunDistanceConstrain(pos,surfFun)%,closeSearchMode)
% defined as in fmincon specs
% distance on the z-axis (3rd dimension) of each pos to the fited surface 

% c(x)<=0
% ceq(x)=0;

c=[];
ceq=pos(:,3)-surfFun(pos(:,1),pos(:,2)); 
