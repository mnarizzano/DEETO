function y = hybridEnergy(pos,pos_0,pos_A,d_ij_0,rows,columns,adjMat,connMat,options)

% Energy function y = 1/P kt t + 1/L kd d + 1/P  ka a + 1/C Ks  s;
% t is translation energy, d defformation energy, a is anchor deformation,
% s is smoothness

% pos (Px3) Actual position - what we want to change
% pos_0 (Px3) Original position 
% pos_A (Px3xQ) Anchor positions (from Hermes,  Kubanek, or others
% projections on the surface) Q is the number of anchor methods added 
% d_ij_0 (PxP) interelectrode orginal distance
%        d_ij_0=eucDistMat(pos_0,pos_0); % fastest if done outside for loop for all points       
%   to use fix interlectrode distances
%        d_ij_0=zeros(size(d_ij));
%        d_ij_0(adjMat==1)=options.M1;
%        d_ij_0(adjMat==2)=options.M2;
%        d_ij_0(adjMat==3)=options.M3;
% crd (Mx3) cloud of voxel points
% weight (M x 1) weight for each voxel
% adjMat (PxP) adjacency matrix with the active conections
% connMat           (P x P) connectivity matrix.  1=horizontal;  2=vertical. Obtained from makeAdjMat.m
% options.Kt        (scalar) ratio of translation
% options.Kd        (scalar) ratio of deformation
% options.Ka        (scalar) ratio of anchors
% options.Ka        (scalar) ratio of smoothness
% options.Kd_normal (scalar) ratio of normal (1st neig) deformation
% options.Kd_shear  (scalar) ratio of shear(diagonal neig) deformation
% options.Kd_bend   (scalar) ratio of bending (2nd neig) deformation
% options.Ka_weight (P x Q) weight for each anchor in [0 1] range


% P = number of electrodes
P=size(pos,1);

% logical is neig
isNeig=triu(adjMat>0); %only upper triangular matrix 

isNeig1=triu(adjMat==1); %only upper triangular matrix. 1st order neig 
isNeig2=triu(adjMat==2); %only upper triangular matrix  Diagonal
isNeig3=triu(adjMat==3); %only upper triangular matrix  2nd order neig

% M1 = mean2(d_ij_0(isNeig1));

% L = number of neighbors
L=sum(isNeig(:)); %neig 1 2 and 3 have the same number

% translation energy
t=sum(eucDist(pos,pos_0).^2);

% actual distance to neighbors
d_ij=eucDistMat(pos,pos); % fastest if done outside for loop for all points
    
% normal, shear and bend need diferent amount of energy
d1 = options.Kd_normal * sum(sum ((isNeig1.*(d_ij-d_ij_0)).^2)); 
d2 = options.Kd_shear  * sum(sum ((isNeig2.*(d_ij-d_ij_0)).^2));
d3 = options.Kd_bend   * sum(sum ((isNeig3.*(d_ij-d_ij_0)).^2));

d = (d1 + d2 + d3) /(options.Kd_normal + options.Kd_shear + options.Kd_bend);

% anchor energy
if length(size(pos_A)) == 3 % more than one anchor per electrode
    Q = size(pos_A,3);
    a=0;
    for q=1:Q
        a = a + 1/Q * sum(options.Ka_weight(:,q).*eucDist(pos,pos_A(:,:,q)).^2);   % compute energy for each anchor 
    end
    
else
    a=sum(options.Ka_weight.*eucDist(pos,pos_A).^2); %only one anchor
end


% smoothness energy

% deformation Horizontal
defH = reshape(d_ij(triu(connMat==1))  -  d_ij_0(triu(connMat==1)) , columns-1, rows)'; %fixed 4.12.20

% deformation Vertical
defV = reshape (d_ij(triu(connMat==2))  -  d_ij_0(triu(connMat==2)),columns,rows-1)';

  
% 2D convolve. Use extended convolution to include edges
% Laplacian Kernel
% kernel2D = [0  1  0; 1 -4  1; 0  1  0]; % 5-stencil kernel
%try also  
kernel2D = [1 2 1; 2  -12  2; 1 2 1]/3; % 9-stencil kernel
kernel1D = [1 -2  1];

if rows == 1 %strips
    laplacianH = conv(defH,kernel1D,'valid');
    laplacianV = 0;

elseif rows == 2 % 2 x cols grids
    laplacianH(1,:) = conv(defH(1,:),kernel1D,'valid');
    laplacianH(2,:) = conv(defH(2,:),kernel1D,'valid');
    laplacianV = 0;
    
elseif columns == 1 %strips
    laplacianH = 0;
    laplacianV = conv(defV',kernel1D,'valid');

elseif columns == 2 % rows x 2 grids
    laplacianH = 0;
    laplacianV(1,:) = conv(defV(:,1)',kernel1D,'valid');
    laplacianV(2,:) = conv(defV(:,2)',kernel1D,'valid');

else % bigger grids
    laplacianH = conv2(defH,kernel2D,'valid');
    laplacianV = conv2(defV,kernel2D,'valid');
end

C = sum(triu(connMat>0),'all'); % number of connections

s = sum(laplacianH .^2,'all') + sum(laplacianV.^2,'all'); % smoothness from Horizontal + Vertical connections



%% total energy 
y = 1/P * options.Kt * t + 1/L * options.Kd * d + 1/P * options.Ka * a + 1/C * options.Ks * s;




% kernel1D=[1 -2 1];
% if rows>1 & columns>1
%     laplacianH = conv2(defH,kernel2D,'valid');
%     laplacianV = conv2(defV,kernel2D,'valid');
%     
% elseif columns>1
%     
%     laplacianH = conv(defH,kernel1D,'valid'); 
%     laplacianV = [];
% else
%     laplacianV = conv(defV,kernel1D,'valid'); 
%     laplacianH = [];
% end



