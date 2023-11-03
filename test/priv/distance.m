function dist=distance(crd,clusters,weight)
%calculo la distancia del punto a su hub

% traditional K-means distance
mode ='normal';

%  mode='weighted';
%  p=2; % metric (2=euclidean distance)

switch mode
    case 'normal'
        
        for i=1:length(crd)
            dist(i)=norm(crd(i,:)-crd(clusters(i),:));
        end
        
    case 'weighted'
        for i=1:length(crd)
            dist(i)=weight(i).^p * norm(crd(i,:)-crd(clusters(i),:),p);
        end
end