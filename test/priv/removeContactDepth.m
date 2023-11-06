function electrodes=removeContactDepth(electrodes,contacts)
% remove contacts from depth electrode structure
% electrodes structure
% contacts to remove vector

if ~strcmp(electrodes.Type,'depth')
    error('not depth electrode')
end

if length(contacts)==electrodes.nElectrodes
    index=contacts;
else
    index=ones(1,electrodes.nElectrodes);
    index(contacts)=0;
end

%at least one contact should be in the electrode structure
if sum(index)==0
    return;
end

index=logical(index);


electrodes.nElectrodes=sum(index);
electrodes.x(~index)=[];
electrodes.y(~index)=[];
electrodes.z(~index)=[];

electrodes.columns=sum(index);

electrodes.recorded_channels=electrodes.recorded_channels-cumsum(~index(:)');


electrodes.recorded_channels(~index)=[];

electrodes.ch_label(~index)=[];
if size(electrodes.aLabels,1)==1
    electrodes.aLabels(:,~index)=[]; %from FS atlas
else
    electrodes.aLabels(~index,:)=[]; %from HO atlas
end



