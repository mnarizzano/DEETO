function neighbours=electrodes2neighboursFTformat(electrodes,mode)
% buld up the neighbours structure for FieldTrip based on the electrodes
% structure from iElectrodes. Check ft_prepare_neighbours for more info
%
% mode = 'adjMat' use adjacencyMatrices
%        'distance' use contacts closer than 12mm
%
%
% ---//---//---//---//---//---//---//---//---//---//---//---//---//---//
% ft_prepare_neighbours.m documentation:
%
% The output is an array of structures with the "neighbours" which is
% structured like this:
%        neighbours(1).label = 'Fz';
%        neighbours(1).neighblabel = {'Cz', 'F3', 'F3A', 'FzA', 'F4A', 'F4'};
%        neighbours(2).label = 'Cz';
%        neighbours(2).neighblabel = {'Fz', 'F4', 'RT', 'RTP', 'P4', 'Pz', 'P3', 'LTP', 'LT', 'F3'};
%        neighbours(3).label = 'Pz';
%        neighbours(3).neighblabel = {'Cz', 'P4', 'P4P', 'Oz', 'P3P', 'P3'};
%        etc.
% Note that a channel is not considered to be a neighbour of itself.
% ---//---//---//---//---//---//---//---//---//---//---//---//---//---//
%
% A Blenkmann 2016
% if iscell(electrodes)
%     k=1;
%     for e=1:length(electrodes)
%         full_labels=cell(1,electrodes{e}.nElectrodes);
%         full_labels(electrodes{e}.recorded_channels)=electrodes{e}.ch_label;
%         for l=1:length(electrodes{e}.recorded_channels); %nElectrodes;
%             neighbours(k).label = electrodes{e}.ch_label{l};
%             neig=full_labels(logical(electrodes{e}.adjMat(l,:)));
%             neighbours(k).neighblabel = neig(~cellfun('isempty',neig)); %only non empty cell elements
%             k=k+1;
%         end
%     end
% else %struct

switch mode
    case 'adjMat'
        k=1;
        for e=1:length(electrodes)
            if length(electrodes(e).recorded_channels)~=electrodes(e).nElectrodes;
                error('remove old structure recorded/removed channels from electrodes')
            else
                for l=1:electrodes(e).nElectrodes;
                    neighbours(k).label = deblank(electrodes(e).ch_label{l});
                    neig=logical(electrodes(e).adjMat(l,:));
                    neighbours(k).neighblabel = deblank(electrodes(e).ch_label(neig)); %only non empty cell elements
                    k=k+1;
                end
                if isfield(electrodes(e),'bipolarH')
                    for l=1:electrodes(e).bipolarH.nElectrodes;
                        neighbours(k).label = deblank(electrodes(e).bipolarH.ch_label{l});
                        neig=logical(electrodes(e).bipolarH.adjMat(l,:));
                        neighbours(k).neighblabel = deblank(electrodes(e).bipolarH.ch_label(neig))'; %only non empty cell elements
                        k=k+1;
                    end
                end
                if isfield(electrodes(e),'bipolarV')
                    for l=1:electrodes(e).bipolarV.nElectrodes;
                        neighbours(k).label = deblank(electrodes(e).bipolarV.ch_label{l});
                        neig=logical(electrodes(e).bipolarV.adjMat(l,:));
                        neighbours(k).neighblabel = deblank(electrodes(e).bipolarV.ch_label(neig))'; %only non empty cell elements
                        k=k+1;
                    end
                end
            end
        end
        
    case 'distance'
        k=1;
        pos=[];
        for e=1:length(electrodes)
            for l=1:electrodes(e).nElectrodes;
                neighbours(k).label = deblank(electrodes(e).ch_label{l});
                pos(k,:)=[electrodes(e).x(l) electrodes(e).y(l) electrodes(e).z(l)];
                k=k+1;
            end
            if isfield(electrodes(e),'bipolarH')
                for l=1:electrodes(e).bipolarH.nElectrodes;
                    neighbours(k).label = deblank(electrodes(e).bipolarH.ch_label{l});
                    pos(k,:)=[electrodes(e).bipolarH.x(l) electrodes(e).bipolarH.y(l) electrodes(e).bipolarH.z(l)];
                    k=k+1;
                end
            end
            if isfield(electrodes(e),'bipolarV')
                for l=1:electrodes(e).bipolarV.nElectrodes;
                    neighbours(k).label = deblank(electrodes(e).bipolarV.ch_label{l});
                    pos(k,:)=[electrodes(e).bipolarV.x(l) electrodes(e).bipolarV.y(l) electrodes(e).bipolarV.z(l)];
                    k=k+1;
                end
            end
        end
            
        
        thresDistance=12;       % 10 mm distance to consider neighbours activation
        n=length(pos); pos1=repmat(pos,[1,1,n]); pos2=permute(pos1,[3 2 1]);
        distance=squeeze(sqrt(sum((pos1-pos2).^2,2)));
        adjMat= distance < thresDistance;   % neighbours matrix

        for i=1:length(pos)
            neig=logical(adjMat(i,:));
            neighbours(i).neighblabel = deblank({neighbours(neig).label})'; %only non empty cell elements
        end        
        
end