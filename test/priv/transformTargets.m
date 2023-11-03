function targets=transformTargets(targets,M)

L=length(targets);

for l=1:L
    clear xi crd2
    
    %Target In
    % read
    xi(1)=targets(l).targetIn.x;
    xi(2)=targets(l).targetIn.y;
    xi(3)=targets(l).targetIn.z;
    xi(4)=1;
    
    % transform
    xi2=M*xi';
    
    % write
    targets(l).targetIn.x=xi2(1);
    targets(l).targetIn.y=xi2(2);
    targets(l).targetIn.z=xi2(3);
    
    
    %Target Out
    % read
    crd(1)=targets(l).targetOut.x;
    crd(2)=targets(l).targetOut.y;
    crd(3)=targets(l).targetOut.z;
    crd(4)=1;
    
    % transform
    crd2=M*crd';
    
    % write
    targets(l).targetOut.x=crd2(1);
    targets(l).targetOut.y=crd2(2);
    targets(l).targetOut.z=crd2(3);
    
    
    dx=targets(l).targetOut.x - targets(l).targetIn.x;
    dy=targets(l).targetOut.y - targets(l).targetIn.y;
    dz=targets(l).targetOut.z - targets(l).targetIn.z;
    
    delta=[dx dy dz] / norm([dx dy dz]);
    targets(l).delta=delta;
    [az,el,~] =cart2sph(delta(1), delta(2), delta(3));
    %convert from radians to degres
    az=az*180/pi;
    el=el*180/pi;
    
    targets(l).azimut=az;
    targets(l).elevation=el;
    
    distances= [0 targets(l).FirstSecond targets(l).FirstSecond + ((1:(targets(l).n-2))*targets(l).SecondLast)];
    for i=1:targets(l).n
        coordinates(i,:)= xi2(1:3)'+ distances(i) * delta;
    end
    targets(l).distances=distances;
    targets(l).coordinates=coordinates;
    
    %% FRAME
    % check if frame is down
    targets(l).frameDown = targets(l).coordinates(targets(l).n,3) < 0;
    % set anterior position as default
    targets(l).framePosition='Anterior';
        
    
    framePosition=targets(l).framePosition;
    frameDown=targets(l).frameDown;
    
    [alpha,beta]=delta2alpha_beta(delta(1),delta(2),delta(3),framePosition,frameDown);
    
    targets(l).beta=beta;
    targets(l).alpha=alpha;
    
end


