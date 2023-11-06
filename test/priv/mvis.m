%function h=vis(vertices,faces)
%function h=vis(vertices,faces,d)
%
%d: interp or flat (vertices o faces)
% 
function h=mvis(v,f,d)
if nargin==2; d=v(:,1); end;

s.Vertices=v; s.Faces=f;
s.FaceVertexCData=d;
hs=patch(s); 

%shading flat
%%shading faceted
%axis image;
%set(hs,'EdgeColor',[0.8 0.8 0.8],'facealpha',.3)

xlabel('x'); ylabel('y'),zlabel('z')       

if nargin==2
    set(hs,'faceColor',[0.8 0.8 0.8]);
else
    shading interp;
end   
set(hs,'linestyle','none');
lighting phong; material dull; %camlight
axis image

if nargout==1, h=hs; end


%ANTES
%function h=vis(v,f,d)
% s.Vertices=v;
% s.Faces=f;
% s.FaceVertexCData=d(:);
% hs=patch(s);
% if size(d(:),1)==size(v,1), shading interp; end
% if size(d(:),1)==size(f,1), shading flat; end
% colorbar
% 
% xlabel('x'); ylabel('y'); zlabel('z');
% if nargout==1, h=hs; end
