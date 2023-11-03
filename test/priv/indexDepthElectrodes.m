function [electrodes,Ix]=indexDepthElectrodes(G,elecName)
% number the electrodes in G (list of coordinates)
% return the positions in the electrodes structure
% Ix, indexes order pos==G(Ix,:)
% A Blenkmann june 2016

N=size(G,1);

% make an empty electrodes sctructure
electrodes=checkElectrodeStructure();
electrodes=electrodes{1}; %convert to structure

electrodes.Name = elecName;
electrodes.nElectrodes=N;
electrodes.x=zeros(1,N);
electrodes.y=zeros(1,N);
electrodes.z=zeros(1,N);
%removed channels in this particular grid
%electrodes.removed_channels=[];
electrodes.rows=1;
electrodes.columns=N;
electrodes.Type='depth';


%recored channels % assume all are recording...
%electrodes.recorded_channels=1:N;

%sort according to maximum variability
C=cov(G);
[V,D]=eig(C);
P=V(:,3); %eigenvector associated to bigest eigenvalue
G2d=G*P;  %projection
[~,Ix]=sort(G2d);

% decide wich is 1 based on the abs value
if abs(G2d(Ix(1))) > abs(G2d(Ix(end)))
    Ix=flipud(Ix);
end
pos=G(Ix,:);

electrodes.x=pos(:,1);
electrodes.y=pos(:,2);
electrodes.z=pos(:,3);


%index
for i=1:N
    electrodes.ch_label{i}=int2str(i);%[elecBaseName int2str(i)];
end

