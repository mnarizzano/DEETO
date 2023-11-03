function bb = world_bb(V)
%  world-bb -- get bounding box in world (mm) coordinates
% Based on John Ashburner's reorient.m, adapted by Ged Ridgway
% http://www.sph.umich.edu/~nichols/JohnsGems.html#Gem7
% http://www.sph.umich.edu/~nichols/JohnsGems5.html#Gem2
%  -- email bugs to drc.spm@gmail.com
% Adapted by Alejandro Blenkmann 2017

d = V.dim(1:3);
% corners in voxel-space
c = [ 1    1    1    1
    1    1    d(3) 1
    1    d(2) 1    1
    1    d(2) d(3) 1
    d(1) 1    1    1
    d(1) 1    d(3) 1
    d(1) d(2) 1    1
    d(1) d(2) d(3) 1 ]';
% corners in world-space
tc = V.mat(1:3,1:4)*c;

% bounding box (world) min and max
mn = min(tc,[],2)';
mx = max(tc,[],2)';
bb = [mn; mx];
