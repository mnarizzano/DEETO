function [img]=loading_images_SPM(PathName,imgFile,hold,voxdim, bbox)
% reorient and reslice images before loading

% INPUTS
% [PathName,imgFile] image file to open
%
% hold: sets the interpolation method for the resampling.
%       0          Zero-order hold (nearest neighbour).
%       1          First-order hold (trilinear interpolation). (Default)
%       2->127     Higher order Lagrange (polynomial) interpolation using
%                  different holds (second-order upwards).
%       -127 - -1   Different orders of sinc interpolation.
%
% voxdim (optional): voxel dimmension (3x1) (resolution) in mm.
%                    Default will use origal 
%
% bbox (optional)  : bounding box (3x1) in mm. Default will use original vol bb.    
%                    use world_bb(vol) to obtain bounding box

% OUTPUTS
%   img.img     : data matrix
%   img.vol     : volume structure from SPM 
%   img.vol.mat : transforamtion matrix (old S2) 
%   [PathName,imgFileOut] = image file transformed

% Based on John Ashburner's reorient.m, adapted by Ged Ridgway
% A Blenkmann 2017


if nargin<3 
    hold=1;
end
if nargin<4
    voxdim=[NaN NaN NaN];
end
if nargin<5
    bbox=nan(2,3);
end

disp(['Image is beeing resliced... Please wait.']);
% --- OLD WAY -----
% resize_img([PathName,imgFile], voxdim, bbox, false, hold);
% imgFileOut=['r' imgFile ];
% img.vol = spm_vol([PathName,imgFileOut]);
% img.img = spm_read_vols(img.vol);
% delete(imgFileOut)
% -----------------

% load volume
vol = spm_vol([PathName,imgFile]);

% use defined voxdim or load from file
if any(isnan(voxdim))
    vprm = spm_imatrix(vol.mat);
    vvoxdim = vprm(7:9);
    voxdim(isnan(voxdim)) = vvoxdim(isnan(voxdim));
end
voxdim = abs(voxdim(:)');

%bounding box
mn = bbox(1,:);
mx = bbox(2,:);

% default BB to current volume's
if any(isnan(bbox(:)))
    vbb = world_bb(vol);
    vmn = vbb(1,:);
    vmx = vbb(2,:);
    mn(isnan(mn)) = vmn(isnan(mn));
    mx(isnan(mx)) = vmx(isnan(mx));
end

% voxel [1 1 1] of output should map to BB mn
% (the combination of matrices below first maps [1 1 1] to [0 0 0])
mat = spm_matrix([mn 0 0 0 voxdim])*spm_matrix([-1 -1 -1]);
% voxel-coords of BB mx gives number of voxels required
% (round up if more than a tenth of a voxel over)
imgdim = ceil(mat \ [mx 1]' - 0.1)';


% output image
VO            = vol;
VO.dim(1:3)   = imgdim(1:3);
VO.mat        = mat;

types_str   = {'uint8','int16','int32','single','double','int8','uint16','uint32'};
types  = [    2      4      8   16   64   256    512    768];
k=find(ismember(types,vol.dt(1)));

img.img        = zeros(imgdim,types_str{k});

VO = spm_create_vol_no_write(VO); % No need to write to disk

% get slices from original vol
for i = 1:imgdim(3)
    M = inv(spm_matrix([0 0 -i])*inv(VO.mat)*vol.mat);
    img.img(:,:,i) = spm_slice_vol(vol, M, imgdim(1:2), hold); % (4th order Lagrange interp)
end

img.vol=VO;

disp('Done.')

