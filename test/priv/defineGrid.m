function p=defineGrid(NW,NE,SW,SE,rows,columns)
% Define expected grid/depth electrodes coordinates
% 
% For grids
% function p=defineGrid(NW,NE,SW,SE,rows,columns)
% Grid corners
% NW NE
% SW SE
%
% For depth electrodes
% function p=defineGrid(NW,NE,[],[],rows,columns)

%working on deep electrodes or strips
if isempty(SW) 
    h=NE-NW;
    n=max(rows,columns);
    dh=h./(n-1);
    for i=1:n
        p(i,:)=NW+(i-1)*dh;
    end    
    
else %working on grids
    
    h1=NE-NW;
    h2=SE-SW;
    v1=SW-NW;
    v2=SE-NE;
    
    % distancia entre electrodos en los lados
    dh1=h1./(columns-1); dh2=h2./(columns-1); dv1=v1./(rows-1); dv2=v2./(rows-1);
    
    for i=1:columns
        d_h1(i,:)=NW+(i-1)*dh1;
        d_h2(i,:)=SW+(i-1)*dh2;
    end
    
    for i=1:rows
        d_v1(i,:)=NW+(i-1)*dv1;
        d_v2(i,:)=NE+(i-1)*dv2;
    end
    
    n=1;
    %make a grid of expected elecrodes locations
    for i=1:rows %rows
        for j=1:columns % columns
            p(n,:)=lineIntersect3D([d_h1(j,:);d_v1(i,:)],[d_h2(j,:);d_v2(i,:)]);
            n=n+1;
        end
    end
end