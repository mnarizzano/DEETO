function electrodesOut=checkElectrodeStructure(electrodesIn)

% electrodesOut=checkElectrodeStructure(electrodesIn)
%
%    Will go though each electrde array and check if all fields
%    are present. If not they will be filed with default / empty values.
%    The aim is to mantain compatibility with previous versions.
%
% electrodesOut=checkElectrodeStructure()
%
%    Will create a new and empty electrodes structure with all fields
%
% Also can be used to keep the Planning structure
% A Blenkmann 2017
%
% changed projections as cell structure, allowing multiple projections (SCE, pial, spherical_norm, spatial_norm)  
% space, method, and method parameters added to structure
% A Blenkmann April 2020

if nargin<1
    electrodesIn{1}.Name=''; % to start a new cell
end

for i=1:length(electrodesIn)
    if iscell(electrodesIn)
        elec=electrodesIn{i};
    else
        elec=electrodesIn(i);
    end
    
    if ~isfield(elec,'Name');               elec.Name='';                                       end % electrode name
    if ~isfield(elec,'x');                  elec.x=[];                                          end % x coordinates
    if ~isfield(elec,'y');                  elec.y=[];                                          end % y coordinates
    if ~isfield(elec,'z');                  elec.z=[];                                          end % z coordinates
    if ~isfield(elec,'nElectrodes');        elec.nElectrodes=length(elec.x);                    end % number of contacts in the electrode array
    if ~isfield(elec,'rows');               elec.rows=0;                                        end % number of rows 
    if ~isfield(elec,'columns');            elec.columns=0;                                     end % number of columns
    
    if ~isfield(elec,'ch_label');           elec.ch_label={};                                   end % channel labels of each electrode
    if ~isfield(elec,'Type');               elec.Type='';                                       end % electrode Type: 'grid' / 'depth' / 'strip'
    if ~isfield(elec,'adjMat');             elec.adjMat=makeAdjMat(elec.rows,elec.columns);     end % adjacency matrix 
    if isempty(elec.adjMat);               elec.adjMat=makeAdjMat(elec.rows,elec.columns);     end % adjacency matrix 
   
    if ~isfield(elec,'aLabels');            elec.aLabels={};                                    end % anatomical label of each electrode
    if ~isfield(elec,'validAnatLabels');    elec.validAnatLabels={};                            end % list of valid anatomical labels (remove? obsolete)
    if ~isfield(elec,'anatInd');            elec.anatInd=[];                                    end % anatomical index (in the atlas image - remove? obsolete)
    
    if ~isfield(elec,'brushCrd');           elec.brushCrd=[];                                   end % CT voxel coordinates corresponding to electrodes
    if ~isfield(elec,'brushWeight');        elec.brushWeight=[];                                end % weight (intensity) of each voxel
    if ~isfield(elec,'clusters');           elec.clusters=[];                                   end % cluster electrode index for each CT voxel coordinate
    if ~isfield(elec,'planning');           elec.planning='no';                                 end % planning or localization array
    if ~isfield(elec,'space');              elec.space='';                                      end % 'Native' / 'MNI' space

    if ~isfield(elec,'displacement');       elec.displacement=[];                               end % needed for projections
    if ~isfield(elec,'method');             elec.method='';                                     end % method used to build current electrode array structure 
    if ~isfield(elec,'methodParameters');   elec.methodParameters=[];                           end % options of the current method
    
    
    % projection. Now cell array of electrode projections. Space is used to describe type of projection
    if isfield(elec,'projection') 
        if~iscell(elec.projection) % old structure
            if isempty(elec.projection.x) %old and empty
                elec.projection={};
            else %old with content

                elec.projection.nElectrodes=elec.nElectrodes;
                elec.projection.rows=elec.rows;                
                elec.projection.columns=elec.columns;           
                elec.projection.ch_label=elec.ch_label;        
                elec.projection.Type=elec.Type;                 
                if ~isfield(elec.projection,'space');              elec.projection.space = 'SCE';                 end
                if ~isfield(elec.projection,'method')              elec.projection.method = '';                   end
                
                elec.projection={checkElectrodeStructure(elec.projection)};   % old struc - check recursivelly and convert to cell
            end
        elseif ~isempty(elec.projection)  % new structure present
            elec.projection=checkElectrodeStructure(elec.projection);   % check recursivelly
        end
    end
        
    if ~isfield(elec,'projection');                     elec.projection={};                     end %not existent at all
    

%     if ~isfield(elec,'projection');                     elec.projection=[];                     end
%     if ~isfield(elec.projection,'nElectrodes');         elec.projection.nElectrodes=[];         end
%     if ~isfield(elec.projection,'rows');                elec.projection.rows=[];                end
%     if ~isfield(elec.projection,'columns');             elec.projection.columns=[];             end
%     if ~isfield(elec.projection,'ch_label');            elec.projection.ch_label=[];            end
%     if ~isfield(elec.projection,'Type');                elec.projection.Type=[];                end
%     
%     if ~isfield(elec.projection,'x');                   elec.projection.x=[];                   end
%     if ~isfield(elec.projection,'y');                   elec.projection.y=[];                   end
%     if ~isfield(elec.projection,'z');                   elec.projection.z=[];                   end
%     
%     
%     if ~isfield(elec.projection,'displacement');        elec.projection.displacement=[];                    end
%     if ~isfield(elec.projection,'aLabels');             elec.projection.aLabels={};                         end
%     if ~isfield(elec.projection,'validAnatLabels');     elec.projection.validAnatLabels={};                 end
%     if ~isfield(elec.projection,'anatInd');             elec.projection.anatInd=[];                         end
    
    
    % bipolar montage
    if ~isfield(elec,'bipolarH');                       elec.bipolarH=[];                                   end
    if ~isfield(elec,'bipolarV');                       elec.bipolarV=[];                                   end
    
    if (~isfield(elec,'bipolarH') || ~isfield(elec,'bipolarV')) && elec.nElectrodes; elec=makeBipolarMontageElectrodes(elec,0);   end
    
    
    if ~isfield(elec.bipolarH,'rows');                  elec.bipolarH.rows=0;                               end
    if ~isfield(elec.bipolarH,'columns');               elec.bipolarH.columns=0;                            end
    if ~isfield(elec.bipolarH,'nElectrodes');           elec.bipolarH.nElectrodes=0;                        end
    if ~isfield(elec.bipolarH,'x');                     elec.bipolarH.x=[];                                 end
    if ~isfield(elec.bipolarH,'y');                     elec.bipolarH.y=[];                                 end
    if ~isfield(elec.bipolarH,'z');                     elec.bipolarH.z=[];                                 end
    if ~isfield(elec.bipolarH,'indicesPos');            elec.bipolarH.indicesPos=[];                        end
    if ~isfield(elec.bipolarH,'indicesNeg');            elec.bipolarH.indicesNeg=[];                        end
    if ~isfield(elec.bipolarH,'Type');                  elec.bipolarH.Type='';                              end
    if ~isfield(elec.bipolarH,'ch_label');              elec.bipolarH.ch_label={};                          end
    if ~isfield(elec.bipolarH,'adjMat');                elec.bipolarH.adjMat=[];                            end
    if isempty(elec.bipolarH.adjMat);                   elec.bipolarH.adjMat=makeAdjMat(elec.bipolarH.rows,elec.bipolarH.columns);     end % adjacency matrix 
    if ~isfield(elec.bipolarH,'aLabels');               elec.bipolarH.aLabels={};                           end
    if ~isfield(elec.bipolarH,'validAnatLabels');       elec.bipolarH.validAnatLabels={};                   end
    if ~isfield(elec.bipolarH,'anatInd');               elec.bipolarH.anatInd=[];                           end
    if ~isfield(elec.bipolarH,'displacement');          elec.bipolarH.displacement=[];                      end % needed for projections
    if ~isfield(elec.bipolarH,'method');                elec.bipolarH.method='';                            end % method used to build current electrode array structure 
    if ~isfield(elec.bipolarH,'methodParameters');      elec.bipolarH.methodParameters=[];                  end % options of the current method
    
    if ~isfield(elec.bipolarV,'rows');                  elec.bipolarV.rows=0;                               end
    if ~isfield(elec.bipolarV,'columns');               elec.bipolarV.columns=0;                            end
    if ~isfield(elec.bipolarV,'nElectrodes');           elec.bipolarV.nElectrodes=0;                        end
    if ~isfield(elec.bipolarV,'x');                     elec.bipolarV.x=[];                                 end
    if ~isfield(elec.bipolarV,'y');                     elec.bipolarV.y=[];                                 end
    if ~isfield(elec.bipolarV,'z');                     elec.bipolarV.z=[];                                 end
    if ~isfield(elec.bipolarV,'indicesPos');            elec.bipolarV.indicesPos=[];                        end
    if ~isfield(elec.bipolarV,'indicesNeg');            elec.bipolarV.indicesNeg=[];                        end
    if ~isfield(elec.bipolarV,'Type');                  elec.bipolarV.Type='';                              end
    if ~isfield(elec.bipolarV,'ch_label');              elec.bipolarV.ch_label={};                          end
    if ~isfield(elec.bipolarV,'adjMat');                elec.bipolarV.adjMat=[];                            end
    if isempty(elec.bipolarV.adjMat);                   elec.bipolarV.adjMat=makeAdjMat(elec.bipolarV.rows,elec.bipolarV.columns);     end % adjacency matrix 
    if ~isfield(elec.bipolarV,'aLabels');               elec.bipolarV.aLabels={};                           end
    if ~isfield(elec.bipolarV,'validAnatLabels');       elec.bipolarV.validAnatLabels={};                   end
    if ~isfield(elec.bipolarV,'anatInd');               elec.bipolarV.anatInd=[];                           end
    if ~isfield(elec.bipolarV,'displacement');          elec.bipolarV.displacement=[];                      end % needed for projections
    if ~isfield(elec.bipolarV,'method');                elec.bipolarV.method='';                            end % method used to build current electrode array structure 
    if ~isfield(elec.bipolarV,'methodParameters');      elec.bipolarV.methodParameters=[];                  end % options of the current method
    
    
    %% remove old fields removed_channels and recorded_channels
    if isfield(elec,'removed_channels')
        elec=rmfield(elec, 'removed_channels');
        disp('Old Field ''removed_channels''  removed from structure');
    end
    if isfield(elec,'recorded_channels')
        elec=rmfield(elec, 'recorded_channels');
        disp('Old Field ''recorded_channels'' removed from structure');
    end
    
    
    %% planning sub fields
    
    if strcmp( elec.planning, 'yes')
        
        
        if strcmp(elec.Type, 'grid')
            
            if ~isfield(elec,'hemisphere');                     elec.hemisphere='';                                      end
            if ~isfield(elec,'rotation');                       elec.rotation=[];                                      end
            if ~isfield(elec,'distance');                       elec.distance=[];                                      end
            
            
        end
        
        if strcmp(elec.Type, 'depth')
            
            if isfield(elec,'coordinates');  % backward compatibility
                elec.x = elec.coordinates(:,1);
                elec.y = elec.coordinates(:,2);
                elec.z = elec.coordinates(:,3);
                
                elec=rmfield(elec, 'coordinates');
            end
            
            if ~isfield(elec,'targetIn');                     elec.targetIn=[];                                      end
            if ~isfield(elec.targetIn,'x');                   elec.targetIn.x=[];                                    end
            if ~isfield(elec.targetIn,'y');                   elec.targetIn.y=[];                                    end
            if ~isfield(elec.targetIn,'z');                   elec.targetIn.z=[];                                    end
            
            if ~isfield(elec,'targetOut');                    elec.targetOut=[];                                     end
            if ~isfield(elec.targetOut,'x');                  elec.targetOut.x=[];                                   end
            if ~isfield(elec.targetOut,'y');                  elec.targetOut.y=[];                                   end
            if ~isfield(elec.targetOut,'z');                  elec.targetOut.z=[];                                   end
            if ~isfield(elec,'FirstSecond');                  elec.FirstSecond=[];                                   end
            
            if ~isfield(elec,'SecondLast');                   elec.SecondLast=[];                                    end
            if ~isfield(elec,'framePosition');                elec.framePosition='';                                 end
            
            if ~isfield(elec,'frameDown');                   elec.frameDown=[];                                      end
            if ~isfield(elec,'delta');                       elec.delta=[];                                          end
            if ~isfield(elec,'beta');                        elec.beta=[];                                          end
            if ~isfield(elec,'azimut');                      elec.azimut=[];                                         end
            if ~isfield(elec,'elevation');                   elec.elevation=[];                                      end
            
            if ~isfield(elec,'distances');                   elec.x=[];                                              end
            if ~isfield(elec,'coordinates');                 elec.coordinates=[];                                    end
            
        end
        
        
    end

    %
    
    if iscell(electrodesIn)
        electrodesOut{i}=elec;
    else
        electrodesOut(i)=elec;
    end
end