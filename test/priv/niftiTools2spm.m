function out=niftiTools2spm(nii)
% convert nifti tools format image to SPM format
% Images had already been resliced
% A Blenkmann 2017

disp(['Converting ' nii.fileprefix ' vol information from old image struture nifti-tools to SPM ']);

%tempname=[int2str(rand(1)*10^20) '.nii']; %20 char rand name '

% get S2 variable
if nii.hdr.hist.sform_code>0
    % get spatial transformations
    S2=[nii.hdr.hist.srow_x; nii.hdr.hist.srow_y; nii.hdr.hist.srow_z;];
elseif nii.hdr.hist.qform_code>0
    % qform not implemented
    error('please convert images to sform')
else
    S2=[diag(abs(nii.hdr.dime.pixdim(2:4))), (-nii.hdr.hist.originator(1:3).*abs(nii.hdr.dime.pixdim(2:4)))'];
end


%out.vol.fname=[pwd '/' tempname];       
out.vol.fname=[nii.fileprefix '.nii'];

out.vol.mat=[S2; 0 0 0 1];
out.vol.dim=size(nii.img);
types_str   = {'uint8','int16','int32','single','double','int8','uint16','uint32'};
types  = [    2      4      8   16   64   256    512    768];

k=find(strcmp(class(nii.img),types_str));
le=strcmp(nii.machine(end-1:end),'le'); %little endian

out.vol.dt=[types(k) ~le ];

out.vol = spm_create_vol_no_write(out.vol); %create vol, but don't write the file

out.img=nii.img;


end


% if nargin<2
%     hold = 4; % 4th order spline interpolation
% end
% if nargin<3
%     voxdim=[NaN NaN NaN];
% end
% if nargin<4
%     bbox=nan(2,3);
% end
% 
% file=[nii.fileprefix '.nii'];
% [PathName,name,ext] = fileparts(file); 
% try
%     disp(['Atempting to load image files using new SPM functions...']);
%     
%     [out,~]=loading_images_SPM([PathName filesep],[name ext],hold,voxdim, bbox);
% catch
%     disp(['File '  file ' not found ...' ]);
% %     disp(['Information is incomplete and may cause issues in the future.']);
% %     disp(['']);
% %     disp(['We recomend to export the electrodes (.mat file).']);
% %     disp(['Then make a new project, load the images from scratch']);
% %     disp(['and finally import the electrodes again.']);
% %     disp(['Sorry for the inconviniences.']);
% 
%     % make a temporary nii 
%     tempname=name;
%     
%     if exist([pwd filesep tempname ext],'file')
%        tempname=int2str(rand(1)*10^20); %20 char rand name '
%     end
%     save_nii(nii,[pwd filesep tempname ext]);
%     
%     [out,~]=loading_images_SPM([pwd filesep],[tempname ext],hold,voxdim, bbox);
%     if exist([pwd filesep tempname ext],'file')
%         delete([pwd filesep tempname ext]);
%     end
%     if exist([pwd filesep 'r' tempname ext],'file')
%        
%     end
% end
    
    
    
%     vol.fname    = [nii.fileprefix '.nii'];
%     vol.dim(1:3) = size(nii.img);
%     
%     % get transfomation matrix
%     if nii.hdr.hist.sform_code>0
%         % get sform spatial transformations
%         vol.mat=[nii.hdr.hist.srow_x; nii.hdr.hist.srow_y; nii.hdr.hist.srow_z];
%     elseif nii.hdr.hist.qform_code>0
%         % qform not implemented
%         error('please convert images to sform')
%     else
%         vol.mat=[diag(abs(nii.hdr.dime.pixdim(2:4))), (-nii.hdr.hist.originator(1:3).*abs(nii.hdr.dime.pixdim(2:4)))'];
%     end
%     vol.mat=[vol.mat; 0 0 0 1];
%     out.vol=vol;
%     out.img=nii.img;
%     nii.img=[];
%     out.old_nii_structure=nii; %saving old structure here
% end