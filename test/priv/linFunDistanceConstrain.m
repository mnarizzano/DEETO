function [c,ceq]=linFunDistanceConstrain(pos,linFun)
% defined as in fmincon specs
% distance on the y- and z-axis  (3rd dimension) of each pos to the 
% fited line function:  
% y=linFun(x) 
% z should be == 0 for unidimensional arrays

% c(x)<=0
% ceq(x)=0;

c=[];
ceq=  sqrt( ( pos(:,2) - linFun(pos(:,1)) ).^2 + pos(:,3).^2);  

