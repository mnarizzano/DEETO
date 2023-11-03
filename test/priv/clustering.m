function [GS,clusters]=clustering (nClusters,crd,weight)
% function GS=clustering (nClusters,crd)
% compute nClusters using k-means algorithm. 
% GS, center of mass of each cluster
%
% function GS=clustering (nClusters,crd,weight)
% calculate cluster coordinates using 
% a weigthed center of mass of each cluster

% modified AB 20/05/2015


l=size(crd,1);

temp=weight-min(weight);
normWeight=temp/max(temp);


% inicializo
clusters=ones(l,1); %matriz q indica a q hub pertenece cada punto

hubs=zeros(nClusters,1);    %indica el hub que punto corresponde
hubs(1,1)=1;                %el primero corresponde al primer punto

dist = distance(crd,clusters,normWeight); %distance of all crd to crd(1)

                 %hubs
counter =1;      %numero de hubs
continuar = 1;   % 1=true 0=false indicates whether to continue forming new
                 


while continuar
    counter = counter + 1;  % adding new hub
    [m,i]=max(dist);        % m = distancia maxima del punto mas lejano
                            % i = indice del punto mas lejano
      
    hubs(counter)=i;        % asigno ese punto al nuevo hub
 
    [dist,clusters] = recluster(crd,dist,clusters,normWeight,i);  % Clusters points
                                                                  % to nearest hub
                                                            
%    maxdist=max(dist);      %returns distance of point farthest from its hub
%    continuar = farout(counter,hubs,crd,maxdist); %Checks the stop condition
% si la distancia es mayor a 8mm continuo
%     if maxdist>10

% use known number of cluster to stop
     if counter<nClusters
        continuar=1;
     else
         continuar=0;
     end
    
end

%% calculate final locations for each cluster
% me quedo con las coordenadas promedio de cada cluster
GS=zeros(counter,3);

% weighted center of mass
if nargin==3 
    for i=1:counter
        weight=double(weight);
        ind=clusters==hubs(i);
        W=sum(weight(ind));
        GS(i,:)=sum(diag(weight(ind))* crd(ind,:),1)*(1/W);
    end

else
% non-weigthed center of mass    
    for i=1:counter
        GS(i,:)=mean(crd(clusters==hubs(i),:),1);
    end
end

%% reorganize output - Number clusters 1:N 
if nargout>1
    temp=clusters;
    for i=1:counter
        clusters(temp==hubs(i))=i;
    end
end


% matlab k-means produces not always the same output
% [clusters,GS] = kmeans(crd,nClusters,'Start','cluster','Replicates',100,'Display','Iter');

