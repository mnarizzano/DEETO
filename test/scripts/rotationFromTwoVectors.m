function R=rotationFromTwoVectors(A, B) 
v = cross(A,B); 
ssc = [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0]; 
R = eye(3) + ssc + ssc^2*(1-dot(A,B))/(norm(v))^2;

