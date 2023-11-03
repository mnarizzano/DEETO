function [north,south,east,west]=findCornersGrid(G,rows,columns,options)
% find the corners of the grid
% A Blenkmann 2016

method= options.find_corners_grid_method;
%method='distance';
%       'convexhull'  obtain a convex hull of clustered electrode coordinates to determine
%                      corners
%       'iterative_convexhull' obtain corners from a cloud of coordinates (non clustered electrodes) 
%                              using an iterative aproach until only 4
%                              angles are obtained
global debugging;
fsize=12;

%% 2D projection

switch method
    case 'distance'
        
        
        % define a distance matrix (2D space)
%         pos1=repmat(G,[1,1,N]);
%         pos2=permute(pos1,[3 2 1]);
%         
%         DM=squeeze(sqrt(sum((pos1-pos2).^2,2)));
        DM=eucDistMat(G,G);

        %figure; imagesc(DM);
        distAll=sum(DM); %distance of each electrode to all the others
        [~,IX]=sort(distAll,'descend');
        corners=G(IX(1:4),:);
        
        DM(IX(5:end),:)=[];
        DM(:,IX(5:end))=[];
        distCorners=sum(DM); %distance of each electrode to all the others
        
        
        if debugging
            figure;
            scatter3(G(:,1),G(:,2),G(:,3),'b'); hold on;
            scatter3(corners(:,1),corners(:,2),corners(:,3),'+r');
            for i=1:4
                text(corners(i,1),corners(i,2),corners(i,3),int2str(i),'color',[1 0 0],'FontSize',fsize,'FontWeight','bold');
            end
        end
        
        C=cov(corners);
        [V,D]=eig(C);
        if rows<columns
            P=V(:,[3 2]); %eigenvector associated to the 2 bigest eigenvalue (x largest dimmension)
        else
            P=V(:,[2 3]);
        end
        corners2=corners*P;  %projection to 2D
        
        %take the angle in a polar representation as a measure of order
        corners2=corners2-repmat(mean(corners2),4,1);
        [theta,~]=cart2pol(corners2(:,1),corners2(:,2));
        [~,ix]=sort(theta);
        
        west  = corners(ix(1),:);
        south = corners(ix(2),:);
        east  = corners(ix(3),:);
        north = corners(ix(4),:);
        
        
        %% use convex hull?
        
    case 'convexhull'
        C=cov(G);
        [V,D]=eig(C);
        P=V(:,[3 2]);
        G2d=G*P;
        k=convhull(G2d(:,1),G2d(:,2));
        
        if debugging
            figure;
            scatter(G2d(:,1),G2d(:,2));
            hold on; plot(G2d(k,1),G2d(k,2),'r--*')
            for i=1:length(k)-1
                text(G2d(k(i),1)-2,G2d(k(i),2)-2,int2str(i),'color',[0 0 0],...
                    'FontSize',fsize,'FontWeight','bold');
            end
        end
        
        border=G2d(k,:);
        
        a=border(2:end,:)-border(1:end-1,:);
        %b = circshift(a,1,1);
        b = circshift(a,1); %compatible MATLAB 2013a        
        
        for i=1:length(a)
            normA(i)=norm(a(i,:));
            normB(i)=norm(b(i,:));
            aN(i,:)=a(i,:)/normA(i);
            bN(i,:)=b(i,:)/normB(i);
        end
        
        costheta = dot(a',b')./(normA.*normB);
        theta = acosd(costheta); %angle in degrees
           
        if debugging
            quiver(border(1:end-1,1),border(1:end-1,2),aN(:,1),aN(:,2),.3,'b')
            quiver(border(1:end-1,1),border(1:end-1,2),bN(:,1),bN(:,2),.3,'g')
            for i=1:length(k)-1
                text(G2d(k(i),1)+2,G2d(k(i),2)+4,num2str(theta(i),3),...
                    'color',[0 0 1],'FontSize',fsize,'FontWeight','bold');
            end
        end
        
        %get the bigest 4 angles
        [~,IX]=sort(theta,'descend');
        ind=sort(IX(1:4)); %back to the original order
        corners=G(k(ind),:);
        
        
        west  = corners(1,:);
        south = corners(2,:);
        east  = corners(3,:);
        north = corners(4,:);
        
    case  'iterative_convexhull'
        iterG=G;
        while size(iterG,1)>4
            C=cov(iterG);
            [V,D]=eig(C);
            P=V(:,[3 2]);
            G2d=iterG*P;
            k=convhull(G2d(:,1),G2d(:,2)); % k has N relevant coords + 1 the 1st at the end
            
            if debugging
                figure;
                scatter(G2d(:,1),G2d(:,2));
                hold on; plot(G2d(k,1),G2d(k,2),'r--*')
                for i=1:length(k)-1
                    text(G2d(k(i),1)-2,G2d(k(i),2)-2,int2str(i),'color',[0 0 0],...
                        'FontSize',fsize,'FontWeight','bold');
                end
            end
            
            border=G2d(k,:); % has twice the first coord
            iterG=iterG(k(1:end-1),:); % reduce points to N for the next round. Last omitted
            if length(iterG)==4 % no need to eliminate more points
                break;
            end
            
            a=border(2:end,:)-border(1:end-1,:); % N segments
            %b = circshift(a,1,1);
            b = circshift(a,1); % compatible MATLAB 2013a. N segments
            
            normA=[];
            normB=[];
            aN=[];
            bN=[];
            for i=1:length(a)
                normA(i)=norm(a(i,:));
                normB(i)=norm(b(i,:));
                aN(i,:)=a(i,:)/normA(i);
                bN(i,:)=b(i,:)/normB(i);
            end
            
            costheta = dot(a',b')./(normA.*normB);
            theta = real(acosd(costheta)); % N angle in degrees 
            
            if debugging
                quiver(border(1:end-1,1),border(1:end-1,2),aN(:,1),aN(:,2),.3,'b')
                quiver(border(1:end-1,1),border(1:end-1,2),bN(:,1),bN(:,2),.3,'g')
                for i=1:length(k)-1
                    text(G2d(k(i),1)+2,G2d(k(i),2)+4,num2str(theta(i),3),...
                        'color',[0 0 1],'FontSize',fsize,'FontWeight','bold');
                end
            end
            
            %get the bigest angles
            [~,IX]=sort(theta,'descend');
            iterG(IX(end),:)=[]; % remove the smallest angle
        end
        
        corners=iterG; % already sorted
        west  = corners(1,:);
        south = corners(2,:);
        east  = corners(3,:);
        north = corners(4,:);
        
end

%%
% [~,in]=max(corners2(:,2)); % North
% [~,is]=min(corners2(:,2)); % South
%
% %remove used corners
% tempInd=1:4;
% tempInd([in,is])=[];
%
% temp=corners2(tempInd,:);
%
% [~,ie]=max(temp(:,1)); % East
% [~,iw]=min(temp(:,1)); % West
%
% north=corners(in,:);
% south=corners(is,:);
%
% east=corners(tempInd(ie),:);
% west=corners(tempInd(iw),:);

%% Old ideas
%
% %compute projection using PCA
% C=cov(G);
% [V,D]=eig(C);
% ePCA=D(2,2)/D(3,3); %(D(2,2)+D(3,3))/sum(diag(D)); %if e is big, this means that the grid is not so curved
%
% % compute projection using spherical coordinates and PCA
% [center,~,~] = spherefit(G);
% Ce=repmat(center',N,1);
% Gc=G-Ce;
% [az,el,~]=cart2sph(Gc(:,1),Gc(:,2),Gc(:,3));
% azMean=mean(az);
% elMean=mean(el);
% azw=wrapToPi(az-azMean); %angles in the interval -pi to pi
% elw=wrapToPi(el-elMean); %angles in the interval -pi to pi
% Gsph=[azw,elw];
% C=cov(Gsph);
% [V,D]=eig(C);
% eSph= D(1,1)/D(2,2);  %(D(2,2)+D(3,3))/sum(diag(D));
%
%
%
% if eSph > ePCA
%     disp('using spherical coordinates projection');
%     % Projection onto an sphere azimuth and elevation
%     [center,~,~] = spherefit(G);
%     Ce=repmat(center',N,1);
%     Gc=G-Ce;
%     [az,el,~]=cart2sph(Gc(:,1),Gc(:,2),Gc(:,3));
%     azMean=mean(az);
%     elMean=mean(el);
%     azw=wrapToPi(az-azMean); %angles in the interval -pi to pi
%     elw=wrapToPi(el-elMean); %angles in the interval -pi to pi
%     Gsph=[azw,elw]; %not using radius
%     C=cov(Gsph);
%     [V,D]=eig(C);
%     if rows<columns
%         P=V(:,[2 1]);
%     else
%         P=V;
%     end
%     G2d=Gsph*P;  %projection to 2D
%
% else
%     disp('using PCA projection');
%     % projection Only using principal components
%     C=cov(G);
%     [V,D]=eig(C);
%     if rows<columns
%         P=V(:,[3 2]); %eigenvector associated to the 2 bigest eigenvalue (x largest dimmension)
%     else
%         P=V(:,[2 3]);
%     end
%     G2d=G*P;  %projection to 2D
% end
%
% %      figure;
% %      scatter(G2d(:,1),G2d(:,2),'b'); hold on;
%
%
% %corner detecion from the principal components
% if ePCA>eSph
%     [~,ie]=max(G2d(:,1)); % East
%     [~,iw]=min(G2d(:,1)); % West
%     [~,in]=max(G2d(:,2)); % North
%     [~,is]=min(G2d(:,2)); % South
%
%     north=G(in,:);
%     east=G(ie,:);
%     west=G(iw,:);
%     south=G(is,:);
% else
%     % corner detecion from the distance to center
%
%     M=mean(G2d);
%     dist= eucDist(G2d,repmat(M,N,1));
%     [~,IX]=sort(dist,'descend');
%     corners2D=G2d(IX(1:4),:);
%
%     [~,norte]=sort(corners2D(:,2),'descend');
%     if corners2D(norte(1),1)<corners2D(norte(2),1)
%         north=G(IX(norte(1)),:);
%         west=G(IX(norte(2)),:);
%     else
%         north=G(IX(norte(2)),:);
%         west=G(IX(norte(1)),:);
%     end
%     if corners2D(norte(3),1)<corners2D(norte(4),1)
%         east=G(IX(norte(3)),:);
%         south=G(IX(norte(4)),:);
%     else
%         east=G(IX(norte(4)),:);
%         south=G(IX(norte(3)),:);
%     end
%
% end

%     corners2D=G2d([ie,iw,in,is],:);
%     scatter(corners2D(:,1),corners2D(:,2),'xk');

%scatter(corners2D(:,1),corners2D(:,2),'+r');

% %
% figure;
% scatter3(G(:,1),G(:,2),G(:,3),'b'); hold on;
% scatter3(north(1),north(2),north(3),'+r');
% scatter3(south(1),south(2),south(3),'+r');
% scatter3(east(1),east(2),east(3),'+r');
% scatter3(west(1),west(2),west(3),'+r');
%
% text(north(1),north(2),north(3),'north','color',[1 0 0],'FontSize',8,'FontWeight','bold');
% text(south(1),south(2),south(3),'south','color',[1 0 0],'FontSize',8,'FontWeight','bold');
% text(east(1),east(2),east(3),'east','color',[1 0 0],'FontSize',8,'FontWeight','bold');
% text(west(1),west(2),west(3),'west','color',[1 0 0],'FontSize',8,'FontWeight','bold');

% check rows and columns is ok
h=eucDist(north,east)+eucDist(west,south);
v=eucDist(north,west)+eucDist(east,south);

if (rows<columns && h<v) || (rows>columns && h>v)
    temp=east;
    east=west;
    west=temp;
end

%
% figure;
% scatter3(G(:,1),G(:,2),G(:,3),'b'); hold on;
% scatter3(north(1),north(2),north(3),'+r');
% scatter3(south(1),south(2),south(3),'+r');
% scatter3(east(1),east(2),east(3),'+r');
% scatter3(west(1),west(2),west(3),'+r');
%
% text(north(1),north(2),north(3),'north','color',[1 0 0],'FontSize',8,'FontWeight','bold');
% text(south(1),south(2),south(3),'south','color',[1 0 0],'FontSize',8,'FontWeight','bold');
% text(east(1),east(2),east(3),'east','color',[1 0 0],'FontSize',8,'FontWeight','bold');
% text(west(1),west(2),west(3),'west','color',[1 0 0],'FontSize',8,'FontWeight','bold');
%


end
