function pos=searchClosest(G,p,rows,columns,usePCA)
% find closest points between G and P
% can use PCA 2D projection or not
% A Blenkmann 2016

% IMPORTANT!!!
% There might be an error in the search of minimum distance Line 55
% 6 May 2018


global debugging;

if debugging
    figure;
    scatter3(G(:,1),G(:,2),G(:,3),'b'); hold on; axis vis3d;
    scatter3(p(:,1),p(:,2),p(:,3),'r','filled'); grid on;
end

n=length(G);

if usePCA
    C=cov([G;p]);
    [V,D]=eig(C);
    P=V(:,2:3); %matriz de proyeccion al espacio de los 2 componentes principales
    
    G2d=G*P;
    p2=p*P;
    
    if debugging
        figure; %plano 2D de proyeccion
        scatter(G2d(:,1),G2d(:,2),'b'); hold on;
        scatter(p2(:,1),p2(:,2),'r');
        title('2D PCA projection')
    end
else
    G2d=G;
    p2=p;
end

%%

pos=zeros(n,3);

% define a distance matrix (2D space) 
% pos1=repmat(G2d,[1,1,n]);
% pos2=repmat(p2,[1,1,n]);
% pos2=permute(pos2,[3 2 1]);
% DM=squeeze(sqrt(sum((pos1-pos2).^2,2)));

%DM=eucDistMat(G2d,p2)'; % distance matrix
DM=eucDistMat(p2,G2d)'; % distance matrix. New corrected version

%imagesc(DM);

Gindex=(1:n);
Pindex=(1:n);

% search minimum distances, one by one. No duplication is posible
for i=1:n
   [~,idx]=min(DM(:));
   [gInd,pInd]=ind2sub([n+1-i,n+1-i],idx);
   pos(Pindex(pInd),:)=G(Gindex(gInd),:); 
   DM(gInd,:)=[];
   DM(:,pInd)=[];  
   Gindex(gInd)=[];
   Pindex(pInd)=[];
end

%% do some permutations to improve matching

%minimize distance 2 ideal grid by permutations
pos=minimiseGridDistancePermutations(pos,rows,columns,p);

%minimize net distance by permutations
pos=minimiseGridDistancePermutations(pos,rows,columns);

end


function pos=minimiseGridDistancePermutations(pos,rows,columns,p)
global debugging;

origPos=pos;

n=length(pos);

if nargin==4
    minimize2ideal=1;
else
    minimize2ideal=0;
end
    
%check all distances making one permutation
index=reshape(1:n,columns,rows)'; 
indexNextColumn=index(:,2:end); %index to (1:N-1,1:M-1) elements 
indexNextRow=index(2:end,:);
indexC=index(1:end,1:end-1); %index to (1:N,1:M-1) elements 
indexR=index(1:end-1,1:end); %index to (1:N-1,1:M) elements 
clear index

if minimize2ideal
    dActual=distance(pos,p);
else
    dActual=netInternalDistance(pos,rows,columns);
end

beenChanged=1;
counter=0; 
maxCounter=100;

%add a counter in case of not reaching a minimum
while beenChanged && counter<maxCounter
    beenChanged=0;
    
    if debugging
        figure;
        scatter3(pos(:,1),pos(:,2),pos(:,3),60,'r','filled'); grid on;
        plotElectrodesLines(pos,rows,columns,[0.1 0.7 0.1]);
        set(gcf, 'Position',[5 30 800 600]);
        view(140,0);axis image; axis off;
        for i=1:n
            text(pos(i,1),pos(i,2)-2,pos(i,3)-3,int2str(i),...
                'color',[1 0 0],'FontSize',12,'FontWeight','bold');
        end
        title(['Counter = ' int2str(counter) ' - Actual Distance ' num2str(dActual)])
        
    end
    
   for i=1:numel(indexR)
        %distance fliping Row
        if minimize2ideal
            dFlipRow(i)=distance(flipCord(pos,indexR(i),indexNextRow(i)),p);            
        else
            posFlip=flipCord(pos,indexR(i),indexNextRow(i));
            dFlipRow(i)=netInternalDistance(posFlip,rows,columns);
        end
   end
        
   for i=1:numel(indexC)
        %distance fliping Column
        if minimize2ideal
            dFlipColumn(i)=distance(flipCord(pos,indexC(i),indexNextColumn(i)),p);
        else
            posFlip=flipCord(pos,indexC(i),indexNextColumn(i));
            dFlipColumn(i)=netInternalDistance(posFlip,rows,columns);
        end
   end

    
    if min(dFlipRow) <min(dFlipColumn)
        if min(dFlipRow) < dActual
            %flip Row
            [dActual,IX]=min(dFlipRow);
            pos=flipCord(pos,indexR(IX),indexNextRow(IX));
            beenChanged=1;
        end
    else
        if min(dFlipColumn) < dActual
            %flip Column
            [dActual,IX]=min(dFlipColumn);
            pos=flipCord(pos,indexC(IX),indexNextColumn(IX));
            beenChanged=1;
        end
    end
    counter=counter+1;    
end

disp([int2str(counter-1) ' permutation corrections done'])

if counter==maxCounter
    warning('No convergence in permutations correction' )
    pos=origPos;
end

end


function d=netInternalDistance(P,rows,columns)
%total net distance. All distances among neighbors

index=reshape(1:length(P),columns,rows)';
indexNextColumn=index(:,2:end); %index to (1:N,2:M) elements
indexNextRow=index(2:end,:);  %index to (2:N,1:M) elements

indexC=index(1:end,1:end-1); %index to (1:N,1:M-1) elements
indexR=index(1:end-1,1:end); %index to (1:N-1,1:M) elements

d=distance(P(indexR,:),P(indexNextRow,:))+ distance(P(indexC,:),P(indexNextColumn,:));
end

function d=distance(G,P)
%total distance beetwen points
d=sum(squeeze(sqrt(sum((G-P).^2,2))));
end

function G=flipCord(G,ind1,ind2)
temp=G(ind1,:);
G(ind1,:)=G(ind2,:);
G(ind2,:)=temp;
end