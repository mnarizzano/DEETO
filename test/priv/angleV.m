function a=angleV(x,y)
% angle between vectors in degrees
a=acosd( (x*y') / (norm(x)*norm(y)) );
end