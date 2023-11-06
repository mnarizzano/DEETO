function [pTan,hemisphere]=tangentialGrid(crd,rows,cols,eDist,vertices_SCE_L,vertices_SCE_R,options)
%  define tangential grid to brain surface for planning/simulations
% crd : center coordinate
% rows / cols:  grid dimensions
% eDist: inter-electrode distance
% vertices_SCE_L surface vertices on the left hemisphere
% vertices_SCE_R surface on the right hemisphere
% options.additionalRotation:  rotation about the center in degrees
% options.previousGrid: use rotation from previous grid
% options.radium: distance to look

% Dealing with options
if ~isfield(options, 'additionalRotation');      options.additionalRotation=[];     end;
if ~isfield(options, 'previousGrid');            options.previousGrid=[];           end;
if ~isfield(options, 'radium');                  options.radium=10;           end;


% get principal directions from data
if ~isempty (options.previousGrid)
    X=options.previousGrid;
    mprev=mean(X);
    desiredDirection1 = X(1,:)-mprev; % direction to 1st electrode from center
    if cols == 1 || rows == 1 % strips
        desiredDirection2=[];
    else
        desiredDirection2 = X(cols,:)-mprev; % direction to the 2nd corner
    end
    
else % don't use any prefered direction
    desiredDirection1=[];
    desiredDirection2=[];    
end


% search for surface points in a radium of 5mm
dLeft=eucDistMat(crd,vertices_SCE_L);
dRight=eucDistMat(crd,vertices_SCE_R);

% left or right
minLeft=min(dLeft);
minRight=min(dRight);

if minLeft < minRight
    hemisphere='left'; 
    surfInd=dLeft<options.radium; % threshold
    surfPoints=vertices_SCE_L(surfInd,:);
    hemCenter=mean(vertices_SCE_L); %hemisphere center
    
else
    hemisphere='right';
    surfInd=dRight<options.radium; % threshold
    surfPoints=vertices_SCE_R(surfInd,:);
    hemCenter=mean(vertices_SCE_R); %hemisphere center
end

if length(surfPoints)<4
    warning('Coordinate to far from surface. Not enought points to calculate tangential surface. Choose another point');
    return;
end
    
% center of points
center=mean(surfPoints,1);

% PCA decomposition of surface points
Vsurf=pca(surfPoints);

% to rotate items to this space use X/Vsurf
normalVec=Vsurf(:,3); % normal vector = axis of ratation

% make normal vec to point outside 
if eucDist(hemCenter,center) > eucDist(hemCenter,center+normalVec')
    normalVec = - normalVec;
%     disp('normalVec inverted')
    Vsurf(:,3) = normalVec;
    
end

% quiver3(center(1),center(2),center(3), center(1)+normalVec(1),center(2)+normalVec(2),center(3)+normalVec(3),'k') %normal

if rows==1 || cols==1 %strip
    
    NW=[0,0,0];
    NE=[max(rows-1,cols-1)*eDist,0,0];
    p=defineGrid(NW,NE,[],[],rows,cols);

else
    % define grid corners 
    %  NW -- NE
    %   |     |
    %  SW -- SE
    
    SW=[0,0,0]; % z=0 always
    SE=[(cols-1)*eDist,0,0];
    NW=[0,(rows-1)*eDist,0];
    NE=[(cols-1)*eDist,(rows-1)*eDist,0];

    % define ideal grid on X-Y plane
    p=defineGrid(NW,NE,SW,SE,rows,cols);
end

% center grid
p=p-repmat(mean(p,1),size(p,1),1);

% rotate ideal grid at (0,0,0) to the surface plane (centered)
pTan_c=(p/Vsurf); %+ repmat(m,size(p,1),1); % more accurate


if ~isempty(desiredDirection1)
    % get the actual directions
    direction1 = pTan_c(1,:); %
    if cols == 1 || rows == 1 % strips
        direction2=[];
    else
        direction2 = pTan_c(cols,:); % direction to the 2nd corner
    end
    
     
%     % for debugging
%     % blue for actual
%     % red for desired
%     
%     figure
%     scatter3(pTan_c(:,1),pTan_c(:,2),pTan_c(:,3),'b','filled')
%     scatter3(pTan_c(1,1),pTan_c(1,2),pTan_c(1,3),'k','filled')
%     
%     hold on
%     axis vis3d
%     X=X-repmat(mean(X),size(X,1),1);
%     scatter3(X(:,1),X(:,2),X(:,3),'r','filled')
%     scatter3(X(1,1),X(1,2),X(1,3),'k','filled')
%     quiver3(0,0,0, Vsurf(1,1),Vsurf(2,1),Vsurf(3,1),'r') %1st
%     quiver3(0,0,0, Vsurf(1,2),Vsurf(2,2),Vsurf(3,2),'g') %2nd
%     quiver3(0,0,0, Vsurf(1,3),Vsurf(2,3),Vsurf(3,3),'b') %3rd
%     
%     quiver3(0,0,0, direction1(1),direction1(2),direction1(3),'b') %actual
%     quiver3(0,0,0, desiredDirection1(1),desiredDirection1(2),desiredDirection1(3),'r') %desired
    
    % robust computation of roation angle in radians
    angle = 2 * atan(norm(direction1*norm(desiredDirection1) - norm(direction1)*desiredDirection1)...
        / norm(direction1 * norm(desiredDirection1) + norm(direction1) * desiredDirection1));
    
    
    % compute rotation matrix (2 options depending on normal vector)
    % A option
    [RA,~]=AxelRot(rad2deg(angle),normalVec,[]);
    pRotA=pTan_c*RA; % rotate to align direction1 and desiredDirection1

    % B option
    [RB,~]=AxelRot(rad2deg(-angle),normalVec,[]);
    pRotB=pTan_c*RB; % rotate to align direction1 and desiredDirection1

    
    % after rotation
    direction1afterA = pRotA(1,:); %
    direction1afterB = pRotB(1,:); %
    
    
    angleAfterA = 2 * atan(norm(direction1afterA*norm(desiredDirection1) - norm(direction1afterA)*desiredDirection1)...
        / norm(direction1afterA * norm(desiredDirection1) + norm(direction1afterA) * desiredDirection1));
    
    angleAfterB = 2 * atan(norm(direction1afterB*norm(desiredDirection1) - norm(direction1afterB)*desiredDirection1)...
        / norm(direction1afterB * norm(desiredDirection1) + norm(direction1afterB) * desiredDirection1));
    
    % take the smallest option
    if abs(angleAfterA) < abs(angleAfterB)
        angleAfter = angleAfterA;
        direction1after = direction1afterA;
        pRot = pRotA;
%         disp('using A')
    else
        angleAfter = angleAfterB;
        direction1after = direction1afterB;
        pRot = pRotB;
%         disp('using B')
    end
    
        
    if cols == 1 || rows == 1 % strips
        direction2After=[];
    else
        direction2After = pRot(cols,:); % direction to the 2nd corner
    end
    
%         % for debugging
%         quiver3(0,0,0, direction1after(1),direction1after(2),direction1after(3),'k') %obtained
%         disp(rad2deg(angleAfter)) % in degrees
        
    % flip grids on 180 deg
    if ~isempty(desiredDirection2)
        % angle of direction 2
        angle2After = 2 * atan(norm(direction2After*norm(desiredDirection2) - norm(direction2After)*desiredDirection2)...
            / norm(direction2After * norm(desiredDirection2) + norm(direction2After) * desiredDirection2));
%         disp(rad2deg(angle2After)) % in degrees

        if abs(angle2After) > 2 * abs(angleAfter)
            % flip grid 180
            [R,~]=AxelRot(180,direction1after,[]);
            pRot=pRot*R; % rotate to align direction1 and desiredDirection1
%             disp('rotated 180')
        end
        
    end
%     scatter3(pRot(:,1),pRot(:,2),pRot(:,3),'*k')
else
    pRot=pTan_c; % No rotations
    
end

% additional rotations (use for rotate left or right)
if ~isempty(options.additionalRotation)
   [R,~]=AxelRot(options.additionalRotation,normalVec,[]);
   pRot=pRot*R;
end
    
% translate back to original point
pTan=pRot+repmat(center,size(pRot,1),1); 
%scatter3(pTrans(:,1),pTrans(:,2),pTrans(:,3),'k')

