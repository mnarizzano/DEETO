% Point-to-Face Distance in 3D Space, Face defined by 3 Points (2,3,4)
% from Christopher Haccius distanceVertex2Mesh.m
function dist = distance3DP2F(v1,v2,v3,v4)
    n = cross((v4-v2),(v3-v2)) / norm(cross((v4-v2),(v3-v2)));
    d = abs(n * (v1 - v2)');
    % check if intersection is on face
    n = cross((v4-v2),(v3-v2)) / norm(cross((v4-v2),(v3-v2)));
    f1 = v1 + d * n;
    f2 = v1 - d * n;
    m = [v3-v2;v4-v2]';
    try 
        r1 = m\(f1-v2)';
    catch
        r1 = [inf;inf];
    end
    try
        r2 = m\(f2-v2)';
    catch
        r2 = [inf;inf];
    end
    if ((sum(r1)<=1 && sum(r1)>=0 && all(r1 >=0) && all(r1 <=1)) || ...
            (sum(r2)<=1 && sum(r2)>=0 && all(r2 >=0) && all(r2 <=1)))
        dist = d;
    else
        dist = inf;
    end
end
