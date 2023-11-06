function y = gridMatchEnergy(pos,pos_0,crd,weight,d_ij_0,adjMat,options)

% Energy function y = 1/P kt t + 1/L kd d - 1/(P N) kc c
% t is translation energy, d defformation energy, c is correlation

% pos (Px3) Actual position - what we want to change
% pos_0 (Px3) Original position - to measure displacements
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
% options.Kt        (scalar) ratio of translation
% options.Kd        (scalar) ratio of deformation
% options.Kc        (scalar) ratio of correlation
% options.Kn        (scalar) ratio of Nail electrodes translation (very high number)
%
% For 2D model 
% options.Kd_normal (scalar) ratio of normal (1st neig) deformation
% options.Kd_shear  (scalar) ratio of shear(diagonal neig) deformation
% options.Kd_bend   (scalar) ratio of bending (2nd neig) deformation
%
% options.sigma sigma value in the gaussian correlation function 
% options.recalcDo recalculates mean distance for d_ij_0
% options.model   '2D' or '3D'
% options.DCT      1/0 indicates if pos are expresed as DCT 
% options.rows
% options.columns
% options.posIdeal (Px3) for 1D_fix model
% 
% A Blenkmann 2018 2019

P=size(d_ij_0,1); % electrodes
N=size(crd,1);    % voxels 
L=size(pos,1);    % relevant for DCT 

% logical is neig
isNeig=triu(adjMat>0); %only upper triangular matrix 

%% is DCT 
if options.DCT
    posDCT_X = zeros(options.rows,options.cols); 
    posDCT_Y = zeros(options.rows,options.cols);
    posDCT_Z = zeros(options.rows,options.cols);
   
    % fill the 2D representation of DCT 
    posDCT_X(1:L) = pos(:,1); % make 2D
    posDCT_Y(1:L) = pos(:,2); % make 2D
    posDCT_Z(1:L) = pos(:,3); % make 2D
    
    % anti transform
    pos_x  = idct2(posDCT_X);
    pos_y  = idct2(posDCT_Y);
    pos_z  = idct2(posDCT_Z);
    
    % merge x y z
    pos = [pos_x(:), pos_y(:), pos_z(:)];
end

if strcmp (options.model, '1D_fix') % (pos contains [Tx Ty Tz p0 p1 p2 p3] = translation and rotation quaternion. No scale
    % posIdeal computed outside
    %posIdeal = zeros(P,3);
    %posIdeal(:,1) =( 0:options.M1:((options.rows*options.cols)-1)*options.M1)'; 
    
    t=pos(1:3);
    q=pos(4:7);
    pos=quatrotate(q,options.posIdeal+t);   
    t_0=pos_0(1:3);
    q_0=pos_0(4:7);
    pos_0=quatrotate(q_0,options.posIdeal+t_0);
end

%% Nail Electrodes Energy 

if (~isempty(options.NailElectrodeNumber))  & (options.Kn~=0) % avoid unnecessary comptations
    En = exp(sum(eucDist(pos(options.NailElectrodeNumber,:),options.NailElectrodeCrd).^2)/length(options.NailElectrodeNumber));
else
    En = 0;
end

%% translation energy - normalized
Et = sum(eucDist(pos,pos_0).^2) / P; 

%% actual distance to neighbors
d_ij=eucDistMat(pos,pos); % fastest if done outside for loop for all points

% recalculate M1 and M2 and replace in d_ij_0
if options.recalcD0
    M1=median(d_ij(adjMat==1));
    M2=median(d_ij(adjMat==2));
    M3=median(d_ij(adjMat==3));
    d_ij_0(adjMat==1)=M1;
    d_ij_0(adjMat==2)=M2;
    d_ij_0(adjMat==3)=M3;
end
    
%% deformation energy normalized
% normal, shear and bend need diferent amount of energy in 2D

if strcmp (options.model, '2D')
    
    isNeig1=triu(adjMat==1); %only upper triangular matrix. 1st order neig
    isNeig2=triu(adjMat==2); %only upper triangular matrix  Diagonal
    isNeig3=triu(adjMat==3); %only upper triangular matrix  2nd order neig
       
    d1=0; d2=0; d3=0;
    if any(isNeig1(:))
        delta_distance = ( (d_ij(isNeig1) - d_ij_0(isNeig1)) ./ d_ij_0(isNeig1) ).^2;
        d1 = options.Kd_normal * sum(sum (delta_distance.^2)) / sum(isNeig1(:));
    end
    if any(isNeig2(:))
        delta_distance = ( (d_ij(isNeig2) - d_ij_0(isNeig2)) ./ d_ij_0(isNeig2) ).^2;
        d2 = options.Kd_shear  * sum(sum (delta_distance.^2)) / sum(isNeig2(:));
    end
    if any(isNeig3(:))
        delta_distance = ( (d_ij(isNeig3) - d_ij_0(isNeig3)) ./ d_ij_0(isNeig3) ).^2;
        d3 = options.Kd_bend   * sum(sum (delta_distance.^2)) / sum(isNeig3(:));
    end
    
    Ed = (d1 + d2 + d3)/(options.Kd_normal + options.Kd_shear + options.Kd_bend);
    
else % 3D model
    % normalized deformation distance (strain). Hooke's law: stress = Y x strain
    delta_distance = ( (d_ij(isNeig) - d_ij_0(isNeig)) ./ d_ij_0(isNeig) ).^2;
    Ed = sum(delta_distance) / size(delta_distance,1); % Note that: size(delta_distance,1)=sum(isNeig(:)), the number of connections deformed
end

%% correlation energy normalized

% distance each electrode to a voxel
% d_ik = eucDistMat(pos,crd); % i = elec / crd = voxels 
d_ik = eucDistMat(pos(options.indexElecGrid,:),crd); % i = elec / crd = voxels 

% exponential decay function
% c=sum(sum(exp(-options.lambda * d_ik)));%*double(weight)) ; 

% number of connections
nC=sum(adjMat(options.indexElecGrid,:)>0,2);

% weighted distances by number of connections 
% the electrodes with less connection, have more weight, 
w_i = 1./nC /sum(1./nC); % let matlab fix the dimensions

% correlation weighted by gaussian decay function, voxel weights, and
% number of conections
%c = 1/(options.sigma*sqrt(2*pi)) * sum( weight'.*sum( exp ( -(1/2) * (wd_ik/options.sigma).^2),1)) /(P*N*sum(weight)) ; 
Ec = 1/(options.sigma*sqrt(2*pi)) * sum( weight'.*sum( w_i .* exp ( -(1/2) * (d_ik/options.sigma).^2),1)) /(P*sum(weight)) ; 

%% total energy 
y = options.Kt * Et + options.Kd * Ed - options.Kc * Ec + options.Kn * En;

% disp([ ' trans=' num2str(1/P * options.Kt * t) ' def=' num2str( 1/L * options.Kd * d) ' corr=' num2str(- 1/(P*N) * options.Kc * c)])

