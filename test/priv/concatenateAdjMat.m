function cAdjMat=concatenateAdjMat(electrodes,labels)
% make a adjMat concatenatig all electrodes.adjMat
% electrodes: structure with all electrodes
% labels: cell of labaels (optional - use labels order from electrodes)
% cAdjMat size is length(labels) x length(labels)
% A Blenkmann 2016
% 2017 update to include bipolar montage

if iscell(electrodes)
    elecCell=electrodes;
    clear electrodes % clear to overwrite
    for i=1:length(elecCell); electrodes(i)=elecCell{i}; end
end

k=1;
for e=1:length(electrodes)
    elecLabCell{k}=electrodes(e).ch_label;
    l(k)=electrodes(e).nElectrodes;                    % length of each adjMat
    adjMatCell{k}=electrodes(e).adjMat;
    k=k+1;
    if isfield(electrodes,'bipolarH') && electrodes(e).bipolarH.nElectrodes
        elecLabCell{k}=electrodes(e).bipolarH.ch_label';
        l(k)=electrodes(e).bipolarH.nElectrodes;
        adjMatCell{k}=electrodes(e).bipolarH.adjMat;
        k=k+1;
    end
    if isfield(electrodes,'bipolarV') && electrodes(e).bipolarV.nElectrodes
        elecLabCell{k}=electrodes(e).bipolarV.ch_label';
        l(k)=electrodes(e).bipolarV.nElectrodes;
        adjMatCell{k}=electrodes(e).bipolarV.adjMat;
        k=k+1;
    end
end

elecLab=horzcat(elecLabCell{:}); % all labels


% indices to change
ind=[0 cumsum(l)];

cAdjMat=false(sum(l),sum(l));

for e=1:length(adjMatCell)
    a=ind(e)+1; b=ind(e+1);
    cAdjMat(a:b,a:b)=adjMatCell{e};
end

if nargin>1 % get indexes for the channels in the new order (labels)
    for e=1:length(labels)
        indLabels(e)=find(strcmp(elecLab,labels(e)));
    end
    
    % reorder the matrix acording to labels
    cAdjMat=cAdjMat(indLabels,:);
    cAdjMat=cAdjMat(:,indLabels);
    
end