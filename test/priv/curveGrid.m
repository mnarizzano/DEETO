function s=curveGrid(G,p)
%project ideal grid (p) over spherical best match of the real grid (G)
% A Blenkmann 2016

global debugging;

%curve ideal grid (p) to the fiting sphere of the real grid (G)

    N=size(G,1);
    % Projection of real grid G onto an sphere azimuth and elevation
    [center,radius,~] = spherefit(G);
    Ce=repmat(center',N,1);
    pc=p-Ce;
   
    %project p into the same sphere
    [az,el,~]=cart2sph(pc(:,1),pc(:,2),pc(:,3));
    [x,y,z]=sph2cart(az,el,radius);
    s= [x,y,z]+Ce;

    if debugging
        figure;
        scatter3(G(:,1),G(:,2),G(:,3),'b'); hold on;
        scatter3(p(:,1),p(:,2),p(:,3),'r','filled');
        scatter3(s(:,1),s(:,2),s(:,3),'k','filled');
        legend({'real' ,'ideal','sphere fit'})
        axis vis3d    
    end
end