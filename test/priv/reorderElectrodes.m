function electrodes=reorderElectrodes(electrodes,newOrder)
% reorder electrodes
electrodes.x=electrodes.x(newOrder);
electrodes.y=electrodes.y(newOrder);
electrodes.z=electrodes.z(newOrder);

% reorder anatomical labels
electrodes.aLabels=electrodes.aLabels(newOrder);
if ~isempty(electrodes.anatInd) %no atlas assigned
    electrodes.anatInd=electrodes.anatInd(newOrder,:);
end

% reorder clusters
tmp=zeros(size(electrodes.clusters));
for i=1:length(newOrder)
    tmp(electrodes.clusters==i)=newOrder(i);
end

electrodes.clusters=tmp;

% brushCrd and brushWeight need no change
% adjMat no change

% reorder projection
if isfield(electrodes,'projection') && ~isempty(electrodes.projection)
    
    electrodes.projection.x=electrodes.projection.x(newOrder);
    electrodes.projection.y=electrodes.projection.y(newOrder);
    electrodes.projection.z=electrodes.projection.z(newOrder);
    electrodes.projection.displacement=electrodes.projection.displacement(newOrder);
    electrodes.projection.aLabels=electrodes.projection.aLabels(newOrder);
    if ~isempty(electrodes.projection.anatInd) %no atlas assigned
        electrodes.projection.anatInd=electrodes.projection.anatInd(newOrder,:);
    end
end