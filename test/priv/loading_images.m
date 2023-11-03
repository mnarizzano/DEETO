function [img,S2,imgFileOut]=loading_images(PathName,imgFile,resliceOpt,targetImage)

% INPUTS
%  reslice method (optional)
%     1:  for Trilinear interpolation
%	  2:  for Nearest Neighbor interpolation
%	  3:  for Fischer's Bresenham interpolation
%	      'method' is 1 if it is default or empty.

% targetImage (optional): nii structure providing dimensions and voxel size for
%     reslicing

% OUTPUTS
%   img = nifti structure
%   S2  =  transforamtion matrix
%   imgFile = file. If the images is transformed, a new file is made.
%


if nargin<3
    resliceOpt=1;
end
if nargin<4
    targetImage=[];
end

save_eFile=0;

try
    %load nii applies transformation to RAS.
    % non linear transformations are not supported
    img=load_nii([PathName imgFile]);
    imgFileOut=imgFile;
catch
    %reslice image and then open
    disp({
        'WARNING';
        'Non-orthogonal rotation or shearing found inside the affine matrix';
        'in this NIfTI file. Reslicing....';
        ['New image file is e' imgFile] });
    msgbox({
        'Non-orthogonal rotation or shearing found inside ';
        'the affine matrix in this NIfTI file.';
        'Now reslicing....';
        ['New image file is e' imgFile] },'Warning');
    
    % reslice_nii(old_fn, new_fn, voxel_size, verbose, bg, method, img_idx, preferredForm)
    if isempty(targetImage)
        imgFileOut=['temp' imgFile];
        reslice_nii([PathName imgFile], [PathName imgFileOut], [], [], [], resliceOpt,[],'S');
        save_eFile=1;
    else %use pixdim from target
        imgFileOut=['temp' imgFile];
        reslice_nii([PathName imgFile], [PathName imgFileOut], targetImage.hdr.dime.pixdim(2:4), [], [], resliceOpt,[],'S');
        save_eFile=1;
    end
    
    img=load_nii([PathName imgFileOut]);
end



% Need to match the target Image
if ~isempty(targetImage)
    
    % new and target dim and originator
    n_org = img.hdr.hist.originator(1:3);
    n_dim = img.hdr.dime.dim(2:4);
    n_pix = img.hdr.dime.pixdim(2:4);

    t_org = targetImage.hdr.hist.originator(1:3);
    t_dim = targetImage.hdr.dime.dim(2:4);
    t_pix = targetImage.hdr.dime.pixdim(2:4);

    
    %check pixels size
    if sum(n_pix==t_pix)~=3
        imgFileOut=['temp' imgFile];
        reslice_nii([PathName imgFile], [PathName imgFileOut],t_pix, [], [], resliceOpt,[],'S');
        save_eFile=1;
        img=load_nii([PathName imgFileOut]);
        disp({
            'WARNING';
            'Pixel size of images are different';
            'Now Reslicing....';
            ['New image file is e' imgFile] });
        msgbox({
            'Pixel size of images are different';
            'Now Reslicing....';
            ['New image file is e' imgFile] },'Warning');
        
        %new values
        n_org = img.hdr.hist.originator(1:3);
        n_dim = img.hdr.dime.dim(2:4);
        n_pix = img.hdr.dime.pixdim(2:4);

    end
    
    % check dimensions and origin
    if sum((n_dim==t_dim)+(abs(n_org-t_org)<t_pix))~=6 %differences of less than pixdim are not corrected
        
        % size diferences
        dL = t_org(1)-n_org(1);
        dR = (t_dim(1)-t_org(1))-(n_dim(1)-n_org(1));
        dP = t_org(2)-n_org(2) ;
        dA = (t_dim(2)-t_org(2))-(n_dim(2)-n_org(2));
        dI = t_org(3)-n_org(3);
        dS = (t_dim(3)-t_org(3))-(n_dim(3)-n_org(3));
        
        % pad options
        if dL>0; option.pad_from_L = dL; else  option.pad_from_L=0;   end
        if dR>0; option.pad_from_R = dR; else  option.pad_from_R=0;   end
        if dP>0; option.pad_from_P = dP; else  option.pad_from_P=0;   end
        if dA>0; option.pad_from_A = dA; else  option.pad_from_A=0;   end
        if dI>0; option.pad_from_I = dI; else  option.pad_from_I=0;   end
        if dS>0; option.pad_from_S = dS; else  option.pad_from_S=0;   end
        
        % pad
        img = pad_nii(img,option); %overwrite
        clear option

        %new values
        n_org = img.hdr.hist.originator(1:3);
        n_dim = img.hdr.dime.dim(2:4);
        n_pix = img.hdr.dime.pixdim(2:4);
        
        % new size diferences
        dL = t_org(1)-n_org(1);
        dR = (t_dim(1)-t_org(1))-(n_dim(1)-n_org(1));
        dP = t_org(2)-n_org(2) ;
        dA = (t_dim(2)-t_org(2))-(n_dim(2)-n_org(2));
        dI = t_org(3)-n_org(3);
        dS = (t_dim(3)-t_org(3))-(n_dim(3)-n_org(3));
        
        % cut options
        if dL<0; option.cut_from_L = -dL; else  option.cut_from_L=0;   end
        if dR<0; option.cut_from_R = -dR; else  option.cut_from_R=0;   end
        if dP<0; option.cut_from_P = -dP; else  option.cut_from_P=0;   end
        if dA<0; option.cut_from_A = -dA; else  option.cut_from_A=0;   end
        if dI<0; option.cut_from_I = -dI; else  option.cut_from_I=0;   end
        if dS<0; option.cut_from_S = -dS; else  option.cut_from_S=0;   end

        % clip
        img= clip_nii(img,option); %overwrite

        disp({
            'WARNING';
            'Dimension of images are different';
            'Now Reslicing....';
            ['New image file is e' imgFile] });
        msgbox({
            'Dimension of images are different';
            'Now Reslicing....';
            ['New image file is e' imgFile] },'Warning');
    end
end


if save_eFile
    % save
    imgFileOut=['e' imgFile];
    save_nii(img, [PathName imgFileOut]);
    
    if exist( [PathName 'temp' imgFile], 'file')
        delete( [PathName 'temp' imgFile])
    end
end


% get output S2 variable
if img.hdr.hist.sform_code>0
    % get spatial transformations
    S2=[img.hdr.hist.srow_x; img.hdr.hist.srow_y; img.hdr.hist.srow_z;];
elseif img.hdr.hist.qform_code>0
    % qform not implemented
    error('please convert images to sform')
else
    S2=[diag(abs(img.hdr.dime.pixdim(2:4))), (-img.hdr.hist.originator(1:3).*abs(img.hdr.dime.pixdim(2:4)))'];
end

end


