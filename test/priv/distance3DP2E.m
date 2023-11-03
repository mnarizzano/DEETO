% Point-to-LineSegment Distance in 3D Space, Line defined by 2 Points (2,3)
% from Christopher Haccius distanceVertex2Mesh.m
function dist = distance3DP2E(v1,v2,v3)
    d = norm(cross((v3-v2),(v2-v1)))/norm(v3 - v2);
    % check if intersection is on edge
    s = - (v2-v1)*(v3-v2)' / (norm(v3-v2))^2;
    if (s>=0 && s<=1)
        dist = d;
    else
        dist = inf;
    end
end