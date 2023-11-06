function [aLabel,labels,indArea]=anatomicLabelFS(pos, atlasFile,LUTfile,lookAround,atlasMatrix,atlasS,labels,values,opt)

% obtain anatomical labels from FreeSurfer parcallation.
% 
% obtain anatomical labels from FreeSurfer parcallation.
%
%  pos          coordinates (Nx3) N-ponits x (x,y,z) in wmparc space
%               (can be MNI normalized or not)
%  atlasFile    string to aparc+aseg /aparc.2009+aseg /wmparc.nii file / [] if atlas in memory
%               if atlasMatrix in memory, use as:
%                   [aLabel,labels,indArea]=anatomicLabelFS(pos, [],[],lookArround,atlasMatrix,LUT,values,atlasS)
%                   [aLabel,labels,indArea]=anatomicLabelFS(pos, [],[],lookArround,atlasMatrix,LUT,values,atlasS,opt)
% atlasLUT      LUT file (.m) with values (Nx1) and labels {Nx1}
% lookAraound  1/0 looks for the most probable Labels in a radio (cube
%               around: pos +/- radio)
% opt.radio         optional radio distance for look arround in voxel dimension
%               in the matrix space (not in mm) (default=2)
% aLabel        nx1 cell of strings containig anatomical descriptions
% labels        cell of strings with all posible anatomical areas (M x 1 cell)
% indArea       vector with 1/0 indicating probability of that area for
%               each electrode (N x M)
% opt.mode      look arround mode: 'mode' most probable / 'prob'  probabilities (default)
% opt.minProb   minimum probability to consider in 'prob' 
%
% A Blenkmann 2016 2017
%
% ADDITIONAL NOTES:
%
% to proccess images for freesurfer labels:
% 1) convert wmparc.mgh to .nii using mgz2nii -> wwmparc.nii
% 2) normalize using previous normalization transformation file sn_....mat
%     change bounding box to  [-90 -126 -72; 91 91 109];
%     voxel size to 1 1 1 and interpolation closest neighbour
%
% labels were obtained from FreeSurferColorLUT.txt (or WMParcStatsLUT.txt) and converted to a vector
%  of values and a cell of labels in the FreeSurferColorLUT.mat (or wmparcLUT.mat)

if nargin<6
    opt.radio=2;
    opt.mode='prob'; %      look arround mode: 'mode' most probable (default)/ 'prob'  probabilities
    opt.minProb=0.2; %   minimum probability to consider in 'prob'
end


if ~isempty (LUTfile)
    load(LUTfile); % RGB / labels / values
end

if ~isempty (atlasFile)
    atlas=load_nii(atlasFile);
    S=[atlas.hdr.hist.srow_x;atlas.hdr.hist.srow_y;atlas.hdr.hist.srow_z];
else
    atlas.img=atlasMatrix;
    S=atlasS;
end

Sr=S(:,1:3);
St=S(:,4);

N=size(pos,1);  % number of points
pos=pos'; % convert matrix to (3xn)

posMat = round(inv(Sr) * (pos - repmat(St,[1,N])));

indArea=zeros(N,length(labels)); % matrix pos x labels

if lookAround==0 % atlas from exact pos
    for i=1:N;
        val=atlas.img(posMat(1,i),posMat(2,i),posMat(3,i));
        indArea(i,:)=(values==val)';
        if isempty(find(indArea(i,:),1))
            warning(['anatomical label ' num2str(val) ' not found in wmparc. Check normalization interpolation using nearest neighbour value'])
            aLabel(i)={'unknown label'};
        else
            aLabel(i)= labels(find(indArea(i,:),1,'first'));
            
        end
    end
    
    % make a small volume (5x5x5 voxels arround)
    % and compute most probable cortex inside
    
elseif lookAround==1 %most probable atlas
    % to remove...
    % 0=unknown
    
    
    for i=1:N
        
        
        valMat=atlas.img(posMat(1,i)-opt.radio:posMat(1,i)+opt.radio, posMat(2,i)-opt.radio:posMat(2,i)+opt.radio,...
            posMat(3,i)-opt.radio:posMat(3,i)+opt.radio);
        valMat=double(valMat);
        valMat(valMat==0)=NaN; % to remove unknown from search
        if strcmp(opt.mode,'mode')
            
            val=mode(valMat(:)); % get most probable
            indArea(i,:)=(values==val)';
            if isnan(val)
                aLabel(i)={'unknown'};
            else
                if isempty(find(indArea(i,:),1))
                    warning(['anatomical label ' num2str(val) ' not found in atlas. Check that normalization interpolation is using nearest neighbour value'])
                    aLabel(i)={'unknown'};
                else
                    aLabel(i)= labels(find(indArea(i,:),1,'first'));
                end
            end
        elseif strcmp(opt.mode,'prob')
            
            K=sum(~isnan(valMat(:))); %number of non nan elements
            if K
                u=unique(valMat);  %unique label indices in the area
                u(isnan(u))=[];
                p=[];
                for j=1:length(u)
                    p(j)=sum(valMat(:)==u(j))/K; %compute probability
                end
                
                % sort by probability
                [p,k]=sort(p,'descend');
                u=u(k);
                
                %reject by min probability
                u(p<opt.minProb)=[];
                p(p<opt.minProb)=[];
                
                [~,indLabels]=ismember(u,values);
                
                if ~all(indLabels) %  zero elements in lb
                    warning(['anatomical label ' num2str(u(indLabels==0)') ' not found in atlas. Check that normalization interpolation is using nearest neighbour value'])
                    p(indLabels==0)=[]; %remove unknown
                    u(indLabels==0)=[];
                    indLabels(indLabels==0)=[];
                end
                
                if isempty(indLabels) % catch if the atlas and the LUt do not correspond
                    aLabel(i,1)={'unknown'};
                else
                    indArea(i,indLabels)=p; % put prob in the indArea matrix
                    
                    for j=1:length(u)
                        aLabel{i,j}=[int2str(p(j)*100) '% ' labels{indLabels(j)}];
                    end
                end
            else
                aLabel(i,1)={'unknown'};
                % indArea full of zeros
            end
        end
    end
end


