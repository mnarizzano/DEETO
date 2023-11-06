function electrodes=transformElectrodes(electrodes,transformation)
% Transform electrodes coordinates using:
% 4x4 transfromation Matrix M
% SPM transformation file sn (.mat)
% SPM transformation Field (.nii)


% bipolars and brush coordinates are also transformed
% A Blenkmann april 2020
% fix transposed output from ft_warp_apply Jan 2021 

L=length(electrodes);

for l=1:L
    clear crd crdBipolarV crdBipolarH
    
    % read original
    crd(:,1)=electrodes{l}.x;
    crd(:,2)=electrodes{l}.y;
    crd(:,3)=electrodes{l}.z;
    
    % read bipolars
    if electrodes{l}.bipolarV.nElectrodes>0
        crdBipolarV(:,1)=electrodes{l}.bipolarV.x;
        crdBipolarV(:,2)=electrodes{l}.bipolarV.y;
        crdBipolarV(:,3)=electrodes{l}.bipolarV.z;
    end
    if electrodes{l}.bipolarH.nElectrodes>0
        crdBipolarH(:,1)=electrodes{l}.bipolarH.x;
        crdBipolarH(:,2)=electrodes{l}.bipolarH.y;
        crdBipolarH(:,3)=electrodes{l}.bipolarH.z;
    end
    
    % brush crd
    crdBrush = electrodes{l}.brushCrd;
    
    if ismatrix(transformation) & isnumeric(transformation)
        
        % transform original
        crd(:,4)=ones(1, length(electrodes{l}.x)); % make quaternion
        crd_out=transformation*crd; %apply transformation
        
        % transform bipolar V
        if electrodes{l}.bipolarV.nElectrodes>0
            crdBipolarV(:,4)=ones(1, length(electrodes{l}.bipolarV.x));
            crd_bipolarV_out=transformation*crdBipolarV;
        end
        
        % transform bipolar H
        if electrodes{l}.bipolarH.nElectrodes>0
            crdBipolarH(:,4)=ones(1, length(electrodes{l}.bipolarH.x));
            crd_bipolarH_out=transformation*crdBipolarH;
        end
        
        %transform brush crd
        crdBrush(:,4)=ones(1, size(crdBrush,1)); % make quaternion
        crdBrush_out=transformation*crdBrush; %apply transformation
        
    elseif ischar(transformation)
        ext=transformation(end-2:end);
        if strcmp(ext,'mat')
            load(transformation)
            M=[];
            M.Affine=Affine;
            M.Tr=Tr;
            M.VF=VF;
            M.VG=VG;
            M.flags=flags;
            
            
            % apply transformation
            [crd_out] = ft_warp_apply(M, crd, 'individual2sn')';
            % transform bipolar V
            if electrodes{l}.bipolarV.nElectrodes>0
                [crd_bipolarV_out] = ft_warp_apply(M, crdBipolarV, 'individual2sn')';
            end
            % transform bipolar H
            if electrodes{l}.bipolarH.nElectrodes>0
                [crd_bipolarH_out] = ft_warp_apply(M, crdBipolarH, 'individual2sn')';
            end
            % transform brush
            [crdBrush_out] = ft_warp_apply(M, crdBrush, 'individual2sn')';
            
        elseif strcmp(ext,'nii')
            
            % [crd_out]=ieeg_spm_transformation_field_warp(crd,transformation);
            [crd_out] = ieeg_spm_transformation_field_warp(crd, transformation);
            % transform bipolar V
            if electrodes{l}.bipolarV.nElectrodes>0
                [crd_bipolarV_out] = ieeg_spm_transformation_field_warp(crdBipolarV, transformation);
            end
            % transform bipolar H
            if electrodes{l}.bipolarH.nElectrodes>0
                [crd_bipolarH_out] = ieeg_spm_transformation_field_warp(crdBipolarH, transformation);
            end
            % transform brush
            [crdBrush_out]= ieeg_spm_transformation_field_warp(crdBrush, transformation);
            
            
        else
            error('Imposible to transform. Unknown transformation');
        end
    else
        error('Imposible to transform. Unknown transformation');
        
    end
    % write
    if size(crd)==flip(size(crd_out))  % crd_out is transposed
        crd_out=crd_out';
        if electrodes{l}.bipolarV.nElectrodes>0
            crd_bipolarV_out=crd_bipolarV_out';
        end
        
        if electrodes{l}.bipolarH.nElectrodes>0
            crd_bipolarH_out=crd_bipolarH_out';
        end
        crdBrush_out=crdBrush_out';
    end

    electrodes{l}.x=crd_out(:,1);
    electrodes{l}.y=crd_out(:,2);
    electrodes{l}.z=crd_out(:,3);
    
    % write bipolars
    if electrodes{l}.bipolarV.nElectrodes>0
        electrodes{l}.bipolarV.x = crd_bipolarV_out(:,1);
        electrodes{l}.bipolarV.y = crd_bipolarV_out(:,2);
        electrodes{l}.bipolarV.z = crd_bipolarV_out(:,3);
    end
    if electrodes{l}.bipolarH.nElectrodes>0
        electrodes{l}.bipolarH.x = crd_bipolarH_out(:,1);
        electrodes{l}.bipolarH.y = crd_bipolarH_out(:,2);
        electrodes{l}.bipolarH.z = crd_bipolarH_out(:,3);
    end
    %write brus
    electrodes{l}.brushCrd = crdBrush_out;
    
end
