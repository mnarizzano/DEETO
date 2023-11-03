function [aLabel,labels,indArea]=anatomicLabel(posMNI,S,labels,prob)
%  posMNI : coordinates (Nx3) n-ponits x (x,y,z) in MNI space
%  optionals 
%       S : transformation matrix from MNI to matrix space
%       labels : cell of strings
%       prob : Probability images structure (contains prob.img) 
%
%  aLabel: nx1 cell of string containig anatomical descriptions and asociated
%  probabilities
%  labels = cell with labels 
%  indArea = anatomical probability for each area (matrix) 
%
%  update 30/08/2016
%  uses HO atlas information in HOatlas_cort-subCort_lateralized.mat
%  that contains labels, prob and S
% 
%  ----
%  previous version:
%   uses 1)S-matrix_to_MNI for convertion
%              nii=load_nii('HarvardOxford-cort-prob-1mm.nii')
%              S=[nii.hdr.hist.srow_x; nii.hdr.hist.srow_y; nii.hdr.hist.srow_z;];
%
%        2) labels.amt
%        3) HOatlas.mat
%  ----
%
%   http://nifti.nimh.nih.gov/nifti-1/documentation/nifti1fields/nifti1fields_pages/qsform.html
%   METHOD 3 (used when sform_code > 0):
%    -----------------------------------
%    The (x,y,z) coordinates are given by a general affine transformation
%    of the (i,j,k) indexes:
% 
%      x = srow_x[0] * i + srow_x[1] * j + srow_x[2] * k + srow_x[3]
%      y = srow_y[0] * i + srow_y[1] * j + srow_y[2] * k + srow_y[3]
%      z = srow_z[0] * i + srow_z[1] * j + srow_z[2] * k + srow_z[3]
%  
%    The srow_* vectors are in the NIFTI_1 header.  Note that no use is
%    made of pixdim[] in this method.


if nargin<2
      load HOatlas_cort-subCort_lateralized.mat
%     load S-matrix_to_MNI.mat
%     load labels.mat
%     load HOatlas.mat
end

n=size(posMNI,1);
posMNI=posMNI'; % convert matrix to (3xn)

nAreas=length(labels);

indArea=zeros(n,nAreas);

Sr=S(:,1:3);
St=S(:,4);

posMat = round(inv(Sr) * (posMNI - repmat(St,[1,n])));

dim=size(prob.img);

if sum(posMat(1,:)> dim(1) | posMat(2,:) > dim(2)  | posMat(3,:) > dim(3)  ...
        | posMat(1,:)< 1 | posMat(2,:) < 1  | posMat(3,:) < 1 )
    warning('coordinates out of MNI matrix space');
    aLabel='';
    return;
end


for i=1:n;
    for j=1:nAreas
        indArea(i,j)=prob.img(posMat(1,i),posMat(2,i),posMat(3,i),j);
    end
end


for i=1:n;
    [probCh,indCh]=sort(indArea(i,:),'descend');
    L=length(find(probCh)); %gives the indexes to non zero prob labels
    for j=1:L
        aLabel{i,j}= [int2str(probCh(j)) '% ' labels{indCh(j)} ];
    end
    if L==0
        aLabel{i,1}='';
    end        
end


















