function [dist,clusters] = recluster(crd,dist,clusters,weight,i)

%RECLUSTER  [dist,clusters] = recluster(crd,dist,clusters,weight,i)
%       reasigno cada punto a los hubs
% i index to new cluster hub

n = size(crd,1);
temp = i*ones(n,1);
newdist=distance(crd,temp,weight);  % calculo las distancias de todos los 
                                    % crd al nuevo hub

    for r=1:n
        if newdist(r) < dist(r)     %si la distancia nueva es menor reasigno
           dist(r)=newdist(r);
           clusters(r)=i;
        end     

     end        

end
