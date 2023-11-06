function [electrodes,Ix]=indexGridElectrodes(G,rows,columns,elecName,options)
% number the electrodes in G (list of coordinates)
% return the positions in the electrodes structure
% Ix, indexes order pos==G(Ix,:)
% A Blenkmann June 2016

method=options.indexing_projection_method;
% method= 'sphereFit'
% method= 'PCA'
% method= 'skip' % use whith gridFit


N=size(G,1);

if rows*columns ~= N
    error('rows*columns ~= N electrodes');
end

% consider processing of strip grids as depth
if rows==1 || columns==1
    [electrodes,Ix]=indexDepthElectrodes(G,elecName);
    electrodes.Type='strip';
else
    
    % make an empty electrodes sctructure
    electrodes=checkElectrodeStructure();
    electrodes=electrodes{1}; %convert to structure
    
    electrodes.Name = elecName; %elecBaseName;
    electrodes.nElectrodes=N;
    electrodes.x=zeros(1,N);
    electrodes.y=zeros(1,N);
    electrodes.z=zeros(1,N);
    %removed channels in this particular grid
%    electrodes.removed_channels=[];
    electrodes.rows=rows;
    electrodes.columns=columns;
    
    %recored channels % assume all are recording...
%    electrodes.recorded_channels=1:N;
    electrodes.Type='grid';
    
    if ~strcmp(method,'skip')
        % find corners
        [north,south,east,west]=findCornersGrid(G,rows,columns,options);
        
        %define ideal grid
        p=defineGrid(north,east,west,south,rows,columns);
    end
    
    % figure; %
    % scatter3(G(:,1),G(:,2),G(:,3),'b','filled'); hold on; axis vis3d;
    % scatter3(p(:,1),p(:,2),p(:,3),'r','filled');
    
    %[ePCA, eSph]=grid2PCAorSph(G);
    switch method
        case 'sphereFit'
            disp('using spherical coordinates projection');
            s=curveGrid(G,p); % prject grid over fiting spehre
            usePCA=0;
            pos=searchClosest(G,s,rows,columns,usePCA); %consider to remove 2D projection
            
        case 'PCA'
            disp('using PCA projection');
            usePCA=1;
            pos=searchClosest(G,p,rows,columns,usePCA);
        case 'skip'
            pos=G;
    end
    
    electrodes.x=pos(:,1);
    electrodes.y=pos(:,2);
    electrodes.z=pos(:,3);
    
    
    %index
    for i=1:N
        electrodes.ch_label{i}=int2str(i);%[elecBaseName int2str(i)];
    end
    
    %compute index (check!)
%     [~,Ix]=min(eucDistMat(G,pos),[],2);
    [~,Ix]=min(eucDistMat(pos,G),[],2); % new corrected version
end